# Database Supabase FreshLaundry

File utama database ada di:

`supabase/migrations/202606110001_create_laundry_schema.sql`

## Cara Menjalankan

Pilihan 1, lewat Supabase SQL Editor:

1. Buka project Supabase.
2. Masuk ke menu SQL Editor.
3. Salin isi file migration.
4. Klik Run.

Pilihan 2, lewat Supabase CLI:

```bash
supabase db push
```

Untuk reset database lokal:

```bash
supabase db reset
```

## Cara Menghubungkan ke Aplikasi Flutter

Setelah SQL database berhasil dijalankan, ambil credential Supabase:

1. Buka project Supabase.
2. Masuk ke **Project Settings**.
3. Pilih **API**.
4. Salin **Project URL**.
5. Salin **anon public key** atau **publishable key**.

Jalankan aplikasi Flutter dengan perintah:

```bash
flutter run --dart-define=SUPABASE_URL=PROJECT_URL_KAMU --dart-define=SUPABASE_ANON_KEY=ANON_KEY_KAMU
```

Contoh formatnya:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Kalau ingin cara paling praktis untuk demo, kamu juga bisa mengisi langsung nilai default di:

`lib/supabase_config.dart`

Ganti:

```dart
defaultValue: 'ISI_SUPABASE_URL_KAMU'
```

dan:

```dart
defaultValue: 'ISI_SUPABASE_ANON_KEY_KAMU'
```

## Struktur Tabel

### `profiles`

Menyimpan data pengguna yang terhubung dengan `auth.users` milik Supabase Auth.

Kolom penting:

- `id`: ID user dari Supabase Auth.
- `full_name`: nama pengguna.
- `phone`: nomor telepon.
- `address`: alamat pengguna.
- `role`: peran user, yaitu `customer` atau `admin`.

### `services`

Menyimpan daftar layanan laundry.

Data awal yang otomatis dibuat:

- `Cuci`: Rp 5.000/kg.
- `Setrika`: Rp 4.000/kg.
- `Express`: Rp 8.000/kg.

## Akun Demo Aplikasi

Migration juga membuat 3 akun demo untuk login aplikasi:

| Role | Username | Password |
| --- | --- | --- |
| Pelanggan | `pelanggan1` | `123456` |
| Pelanggan | `pelanggan2` | `123456` |
| Admin | `admin` | `admin123` |

Pelanggan baru juga bisa dibuat dari tombol **Daftar sebagai pelanggan** di halaman login.

Kolom penting:

- `name`: nama layanan.
- `description`: deskripsi layanan.
- `price_per_kg`: harga per kilogram.
- `estimated_hours`: estimasi waktu pengerjaan.
- `is_active`: status layanan aktif atau tidak.

### `orders`

Menyimpan data pesanan utama.

Kolom penting:

- `order_code`: kode pesanan, contoh `LDR-ABC12345`.
- `customer_id`: relasi ke tabel `profiles`, boleh kosong untuk mode guest.
- `customer_name`: nama pelanggan dari form pesanan.
- `status`: status pengerjaan, seperti `Menunggu`, `Dicuci`, `Dijemur`, `Selesai`, atau `Diantar`.
- `payment_status`: status pembayaran, seperti `Belum dibayar` atau `Lunas`.
- `subtotal`: total sebelum diskon.
- `discount`: diskon.
- `total`: total akhir, dihitung otomatis dari `subtotal - discount`.
- `ordered_at`: waktu pesanan dibuat.
- `completed_at`: waktu pesanan selesai.

### `order_items`

Menyimpan detail layanan dalam satu pesanan.

Kolom penting:

- `order_id`: relasi ke tabel `orders`.
- `service_id`: relasi ke tabel `services`.
- `service_name`: nama layanan saat transaksi dibuat.
- `weight_kg`: berat laundry.
- `price_per_kg`: harga layanan saat transaksi dibuat.
- `line_total`: total item, dihitung otomatis dari `weight_kg * price_per_kg`.

### `payments`

Menyimpan data pembayaran pesanan.

Kolom penting:

- `order_id`: relasi ke tabel `orders`.
- `method`: metode pembayaran, yaitu `QRIS`, `COD`, atau `Transfer Bank`.
- `status`: status pembayaran.
- `amount`: nominal pembayaran.
- `reference_no`: nomor referensi pembayaran.
- `paid_at`: waktu pembayaran berhasil.

### `order_status_histories`

Menyimpan riwayat perubahan status pesanan untuk fitur tracking.

Kolom penting:

- `order_id`: relasi ke tabel `orders`.
- `status`: status pesanan pada saat riwayat dibuat.
- `note`: catatan perubahan status.
- `changed_by`: admin/user yang mengubah status.

## Relasi Antar Tabel

- `profiles` terhubung ke `auth.users`.
- `orders.customer_id` terhubung ke `profiles.id`.
- `order_items.order_id` terhubung ke `orders.id`.
- `order_items.service_id` terhubung ke `services.id`.
- `payments.order_id` terhubung ke `orders.id`.
- `order_status_histories.order_id` terhubung ke `orders.id`.

## Trigger Otomatis

Database ini memakai beberapa trigger:

- `set_updated_at`: otomatis memperbarui kolom `updated_at`.
- `recalculate_order_subtotal`: otomatis menghitung ulang subtotal pesanan ketika item ditambah, diubah, atau dihapus.
- `add_initial_order_status_history`: otomatis membuat riwayat status saat pesanan dibuat.
- `add_order_status_history_on_change`: otomatis menambah riwayat ketika status pesanan berubah.
- `sync_order_payment_status`: otomatis menyamakan status pembayaran di tabel `orders` ketika tabel `payments` berubah.
- `handle_new_user`: otomatis membuat baris `profiles` saat user baru dibuat di Supabase Auth.

## Keamanan RLS

Row Level Security sudah diaktifkan.

Aturan utamanya:

- User hanya bisa melihat data profil dan pesanan miliknya sendiri.
- Admin bisa mengelola semua data.
- Semua user bisa membaca layanan yang aktif.
- Riwayat status dan pembayaran hanya bisa dibaca oleh pemilik pesanan atau admin.

Untuk membuat user menjadi admin, jalankan SQL berikut setelah user terdaftar:

```sql
update public.profiles
set role = 'admin'
where id = 'USER_ID_SUPABASE';
```

## Contoh Insert Pesanan

```sql
insert into public.orders (customer_name, customer_phone, pickup_address)
values ('Budi', '081234567890', 'Jl. Kost Mahasiswa No. 1')
returning id, order_code;
```

Misalnya `id` pesanan yang dikembalikan adalah `ORDER_ID`, tambahkan item:

```sql
insert into public.order_items (
  order_id,
  service_id,
  service_name,
  weight_kg,
  price_per_kg
)
select
  'ORDER_ID',
  id,
  name,
  3,
  price_per_kg
from public.services
where name = 'Cuci';
```

Subtotal dan total pesanan akan dihitung otomatis oleh database.
