-- FreshLaundry database schema for Supabase.
-- Run with: supabase db push
-- Or paste this file into the Supabase SQL Editor.

create extension if not exists pgcrypto;

do $$
begin
  create type public.user_role as enum ('customer', 'admin');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.order_status as enum (
    'Menunggu',
    'Dicuci',
    'Dijemur',
    'Selesai',
    'Diantar',
    'Dibatalkan'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_status as enum (
    'Belum dibayar',
    'Menunggu konfirmasi',
    'Lunas',
    'Gagal',
    'Dikembalikan'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.payment_method as enum ('QRIS', 'COD', 'Transfer Bank');
exception
  when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  address text,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  username text not null unique,
  password text not null,
  full_name text not null,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  price_per_kg numeric(12,2) not null check (price_per_kg >= 0),
  estimated_hours integer check (estimated_hours is null or estimated_hours > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique default ('LDR-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))),
  customer_id uuid references public.profiles(id) on delete set null,
  customer_username text references public.app_users(username) on delete set null,
  customer_name text not null,
  customer_phone text,
  pickup_address text,
  status public.order_status not null default 'Menunggu',
  payment_status public.payment_status not null default 'Belum dibayar',
  subtotal numeric(12,2) not null default 0 check (subtotal >= 0),
  discount numeric(12,2) not null default 0 check (discount >= 0),
  total numeric(12,2) generated always as (subtotal - discount) stored,
  notes text,
  ordered_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint orders_total_non_negative check ((subtotal - discount) >= 0)
);

alter table public.orders
add column if not exists customer_username text;

alter table public.app_users
add column if not exists email text;

update public.app_users
set email = case username
  when 'pelanggan1' then 'pelanggan1@freshlaundry.test'
  when 'pelanggan2' then 'pelanggan2@freshlaundry.test'
  when 'admin' then 'admin@freshlaundry.test'
  else lower(username || '@freshlaundry.test')
end
where email is null;

alter table public.app_users
alter column email set not null;

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  service_id uuid references public.services(id) on delete set null,
  service_name text not null,
  weight_kg numeric(8,2) not null check (weight_kg > 0),
  price_per_kg numeric(12,2) not null check (price_per_kg >= 0),
  line_total numeric(12,2) generated always as (weight_kg * price_per_kg) stored,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  method public.payment_method not null,
  status public.payment_status not null default 'Menunggu konfirmasi',
  amount numeric(12,2) not null check (amount >= 0),
  reference_no text,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_status_histories (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  status public.order_status not null,
  note text,
  changed_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists profiles_role_idx on public.profiles(role);
create index if not exists app_users_role_idx on public.app_users(role);
create unique index if not exists app_users_email_unique_idx on public.app_users(lower(email));
create index if not exists orders_customer_id_idx on public.orders(customer_id);
create index if not exists orders_customer_username_idx on public.orders(customer_username);
create index if not exists orders_status_idx on public.orders(status);
create index if not exists orders_payment_status_idx on public.orders(payment_status);
create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists payments_order_id_idx on public.payments(order_id);
create index if not exists order_status_histories_order_id_idx on public.order_status_histories(order_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_app_users_updated_at on public.app_users;
create trigger set_app_users_updated_at
before update on public.app_users
for each row execute function public.set_updated_at();

drop trigger if exists set_services_updated_at on public.services;
create trigger set_services_updated_at
before update on public.services
for each row execute function public.set_updated_at();

drop trigger if exists set_orders_updated_at on public.orders;
create trigger set_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

drop trigger if exists set_payments_updated_at on public.payments;
create trigger set_payments_updated_at
before update on public.payments
for each row execute function public.set_updated_at();

create or replace function public.recalculate_order_subtotal()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_order_id uuid;
begin
  target_order_id = coalesce(new.order_id, old.order_id);

  update public.orders
  set subtotal = coalesce((
    select sum(line_total)
    from public.order_items
    where order_id = target_order_id
  ), 0)
  where id = target_order_id;

  return null;
end;
$$;

drop trigger if exists recalculate_order_subtotal_after_insert on public.order_items;
create trigger recalculate_order_subtotal_after_insert
after insert on public.order_items
for each row execute function public.recalculate_order_subtotal();

drop trigger if exists recalculate_order_subtotal_after_update on public.order_items;
create trigger recalculate_order_subtotal_after_update
after update on public.order_items
for each row execute function public.recalculate_order_subtotal();

drop trigger if exists recalculate_order_subtotal_after_delete on public.order_items;
create trigger recalculate_order_subtotal_after_delete
after delete on public.order_items
for each row execute function public.recalculate_order_subtotal();

create or replace function public.add_initial_order_status_history()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.order_status_histories (order_id, status, note)
  values (new.id, new.status, 'Pesanan dibuat');
  return new;
end;
$$;

drop trigger if exists add_initial_order_status_history_after_insert on public.orders;
create trigger add_initial_order_status_history_after_insert
after insert on public.orders
for each row execute function public.add_initial_order_status_history();

create or replace function public.add_order_status_history_on_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status is distinct from old.status then
    insert into public.order_status_histories (order_id, status, note)
    values (new.id, new.status, 'Status pesanan diperbarui');

    if new.status in ('Selesai', 'Diantar') and new.completed_at is null then
      new.completed_at = now();
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists add_order_status_history_before_update on public.orders;
create trigger add_order_status_history_before_update
before update on public.orders
for each row execute function public.add_order_status_history_on_change();

create or replace function public.sync_order_payment_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.orders
  set payment_status = new.status
  where id = new.order_id;

  return new;
end;
$$;

drop trigger if exists sync_order_payment_status_after_insert_or_update on public.payments;
create trigger sync_order_payment_status_after_insert_or_update
after insert or update of status on public.payments
for each row execute function public.sync_order_payment_status();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1), 'Pengguna'),
    new.raw_user_meta_data ->> 'phone'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into public.services (name, description, price_per_kg, estimated_hours)
values
  ('Cuci', 'Cuci bersih standar', 5000, 24),
  ('Setrika', 'Setrika rapi', 4000, 24),
  ('Express', 'Selesai dalam 6 jam', 8000, 6)
on conflict (name) do update
set
  description = excluded.description,
  price_per_kg = excluded.price_per_kg,
  estimated_hours = excluded.estimated_hours,
  is_active = true;

insert into public.app_users (email, username, password, full_name, role)
values
  ('pelanggan1@freshlaundry.test', 'pelanggan1', '123456', 'Pelanggan Satu', 'customer'),
  ('pelanggan2@freshlaundry.test', 'pelanggan2', '123456', 'Pelanggan Dua', 'customer'),
  ('admin@freshlaundry.test', 'admin', 'admin123', 'Admin Laundry', 'admin')
on conflict (username) do update
set
  email = excluded.email,
  password = excluded.password,
  full_name = excluded.full_name,
  role = excluded.role;

alter table public.profiles enable row level security;
alter table public.app_users enable row level security;
alter table public.services enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.order_status_histories enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

drop policy if exists "Profiles are readable by owner or admin" on public.profiles;
create policy "Profiles are readable by owner or admin"
on public.profiles for select
using (id = auth.uid() or public.is_admin());

drop policy if exists "Users update their own profile" on public.profiles;
create policy "Users update their own profile"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid() and role = 'customer');

drop policy if exists "Admins manage profiles" on public.profiles;
create policy "Admins manage profiles"
on public.profiles for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Demo app users are readable" on public.app_users;
create policy "Demo app users are readable"
on public.app_users for select
using (true);

drop policy if exists "Customers can register demo account" on public.app_users;
create policy "Customers can register demo account"
on public.app_users for insert
with check (role = 'customer');

drop policy if exists "Services are readable by everyone" on public.services;
create policy "Services are readable by everyone"
on public.services for select
using (is_active = true or public.is_admin());

drop policy if exists "Admins manage services" on public.services;
create policy "Admins manage services"
on public.services for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Users create their own orders" on public.orders;
create policy "Users create their own orders"
on public.orders for insert
with check (customer_id = auth.uid() or customer_id is null);

drop policy if exists "Demo app creates orders" on public.orders;
create policy "Demo app creates orders"
on public.orders for insert
with check (
  customer_username is null
  or exists (
    select 1 from public.app_users
    where app_users.username = orders.customer_username
      and app_users.role = 'customer'
  )
);

drop policy if exists "Users read their own orders" on public.orders;
create policy "Users read their own orders"
on public.orders for select
using (customer_id = auth.uid() or public.is_admin());

drop policy if exists "Demo guests read guest orders" on public.orders;
create policy "Demo guests read guest orders"
on public.orders for select
using (customer_id is null);

drop policy if exists "Users update their own unpaid order notes" on public.orders;
create policy "Users update their own unpaid order notes"
on public.orders for update
using (customer_id = auth.uid())
with check (customer_id = auth.uid());

drop policy if exists "Demo guests update guest orders" on public.orders;
create policy "Demo guests update guest orders"
on public.orders for update
using (customer_id is null)
with check (customer_id is null);

drop policy if exists "Admins manage orders" on public.orders;
create policy "Admins manage orders"
on public.orders for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Users create order items for own orders" on public.order_items;
create policy "Users create order items for own orders"
on public.order_items for insert
with check (
  exists (
    select 1 from public.orders
    where orders.id = order_items.order_id
      and (orders.customer_id = auth.uid() or orders.customer_id is null)
  )
);

drop policy if exists "Users read order items for own orders" on public.order_items;
create policy "Users read order items for own orders"
on public.order_items for select
using (
  public.is_admin()
  or exists (
    select 1 from public.orders
    where orders.id = order_items.order_id
      and orders.customer_id = auth.uid()
  )
);

drop policy if exists "Demo guests read guest order items" on public.order_items;
create policy "Demo guests read guest order items"
on public.order_items for select
using (
  exists (
    select 1 from public.orders
    where orders.id = order_items.order_id
      and orders.customer_id is null
  )
);

drop policy if exists "Admins manage order items" on public.order_items;
create policy "Admins manage order items"
on public.order_items for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Users create payments for own orders" on public.payments;
create policy "Users create payments for own orders"
on public.payments for insert
with check (
  exists (
    select 1 from public.orders
    where orders.id = payments.order_id
      and orders.customer_id = auth.uid()
  )
);

drop policy if exists "Demo guests create payments for guest orders" on public.payments;
create policy "Demo guests create payments for guest orders"
on public.payments for insert
with check (
  exists (
    select 1 from public.orders
    where orders.id = payments.order_id
      and orders.customer_id is null
  )
);

drop policy if exists "Users read payments for own orders" on public.payments;
create policy "Users read payments for own orders"
on public.payments for select
using (
  public.is_admin()
  or exists (
    select 1 from public.orders
    where orders.id = payments.order_id
      and orders.customer_id = auth.uid()
  )
);

drop policy if exists "Demo guests read payments for guest orders" on public.payments;
create policy "Demo guests read payments for guest orders"
on public.payments for select
using (
  exists (
    select 1 from public.orders
    where orders.id = payments.order_id
      and orders.customer_id is null
  )
);

drop policy if exists "Admins manage payments" on public.payments;
create policy "Admins manage payments"
on public.payments for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Users read histories for own orders" on public.order_status_histories;
create policy "Users read histories for own orders"
on public.order_status_histories for select
using (
  public.is_admin()
  or exists (
    select 1 from public.orders
    where orders.id = order_status_histories.order_id
      and orders.customer_id = auth.uid()
  )
);

drop policy if exists "Demo guests read histories for guest orders" on public.order_status_histories;
create policy "Demo guests read histories for guest orders"
on public.order_status_histories for select
using (
  exists (
    select 1 from public.orders
    where orders.id = order_status_histories.order_id
      and orders.customer_id is null
  )
);

drop policy if exists "Admins manage histories" on public.order_status_histories;
create policy "Admins manage histories"
on public.order_status_histories for all
using (public.is_admin())
with check (public.is_admin());
