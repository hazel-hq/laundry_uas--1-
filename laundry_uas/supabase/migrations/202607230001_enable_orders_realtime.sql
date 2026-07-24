-- Mengirim perubahan status pesanan ke aplikasi pelanggan melalui Realtime.
do $$
begin
  alter publication supabase_realtime add table public.orders;
exception
  when duplicate_object then null;
end $$;
