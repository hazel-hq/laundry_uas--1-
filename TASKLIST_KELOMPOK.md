# Task List Kelompok FreshLaundry

Anggota kelompok:

- Adzriel
- Faruq
- Yanita

Pembagian tugas dibuat berdasarkan PRD FreshLaundry dan memastikan setiap anggota mendapat bagian coding.

## Ringkasan Pembagian

| Anggota | Fokus Utama | Output Utama |
| --- | --- | --- |
| Adzriel | Database, model, dan service Supabase | Database berjalan, data tersimpan, query aplikasi berfungsi |
| Faruq | UI/UX pelanggan dan admin | Tampilan aplikasi lengkap dan rapi |
| Yanita | Validasi, alur aplikasi, testing, dan dokumentasi | Aplikasi sesuai PRD, minim bug, dan terdokumentasi |

## 1. Task List Adzriel

Fokus: database, model data, dan integrasi Supabase.

### Coding

- Membuat konfigurasi koneksi Supabase di `lib/supabase_config.dart`.
- Membuat dan merapikan model pesanan di `lib/models/order.dart`.
- Membuat model user aplikasi di `lib/models/app_user.dart`.
- Mengatur cache data pesanan di `lib/models/order_data.dart`.
- Membuat service query pesanan di `lib/services/order_repository.dart`.
- Membuat service login dan register di `lib/services/auth_repository.dart`.
- Membuat SQL migration Supabase di folder `supabase/migrations`.
- Membuat tabel `app_users` untuk akun pelanggan dan admin.
- Membuat tabel `services` untuk layanan laundry.
- Membuat tabel `orders` untuk data pesanan.
- Membuat tabel `order_items` untuk detail layanan pesanan.
- Membuat tabel `payments` untuk pembayaran.
- Membuat tabel `order_status_histories` untuk riwayat status.
- Membuat relasi antar tabel database.
- Membuat seed data layanan:
  - Cuci
  - Setrika
  - Express
- Membuat akun demo:
  - `pelanggan1`
  - `pelanggan2`
  - `admin`
- Membuat query untuk menyimpan pesanan baru.
- Membuat query untuk mengambil riwayat pesanan.
- Membuat query untuk menyimpan pembayaran.
- Membuat query untuk update status pesanan.
- Memastikan data tetap tersimpan di Supabase setelah aplikasi ditutup.

### Dokumentasi Pendukung

- Menjelaskan struktur database.
- Menjelaskan relasi antar tabel.
- Menjelaskan cara menjalankan SQL migration di Supabase.
- Membantu mengisi bagian database pada laporan.

## 2. Task List Faruq

Fokus: tampilan aplikasi pelanggan dan admin.

### Coding

- Membuat dan merapikan halaman login di `lib/screens/login_screen.dart`.
- Membuat tombol **Daftar sebagai pelanggan**.
- Membuat halaman register di `lib/screens/register_screen.dart`.
- Membuat halaman home pelanggan di `lib/screens/home_screen.dart`.
- Membuat tampilan daftar layanan laundry.
- Membuat tampilan ringkasan pesanan aktif.
- Membuat form buat pesanan di `lib/screens/order_screen.dart`.
- Membuat tampilan riwayat pesanan di `lib/screens/history_screen.dart`.
- Membuat filter riwayat pesanan:
  - Semua
  - Proses
  - Selesai
  - Diantar
- Membuat halaman detail pesanan di `lib/screens/order_detail_screen.dart`.
- Membuat halaman tracking pesanan di `lib/screens/tracking_screen.dart`.
- Membuat timeline status pesanan.
- Membuat halaman pembayaran di `lib/screens/payment_screen.dart`.
- Membuat tampilan metode pembayaran QRIS.
- Membuat tampilan metode pembayaran COD.
- Membuat dashboard admin di `lib/screens/admin_screen.dart`.
- Membuat card ringkasan admin:
  - Total pesanan
  - Pesanan aktif
  - Pesanan lunas
  - Pesanan selesai
- Membuat daftar pesanan pada halaman admin.
- Membuat komponen dropdown update status untuk admin.
- Merapikan warna, ikon, tombol, card, spacing, dan layout aplikasi.
- Memastikan tampilan tetap nyaman digunakan pada ukuran layar mobile.

### Dokumentasi Pendukung

- Menjelaskan desain tampilan aplikasi.
- Menjelaskan perbedaan tampilan pelanggan dan admin.
- Membantu screenshot tampilan untuk laporan atau presentasi.

## 3. Task List Yanita

Fokus: validasi, alur aplikasi, testing, dan dokumentasi.

### Coding

- Membuat validasi form login.
- Membuat validasi form register.
- Membuat validasi form buat pesanan.
- Memastikan nama pelanggan wajib diisi.
- Memastikan berat laundry wajib diisi.
- Memastikan berat laundry lebih dari 0.
- Membuat pesan error jika login gagal.
- Membuat pesan error jika register gagal.
- Membuat pesan error jika pesanan gagal disimpan.
- Membuat loading state pada proses login.
- Membuat loading state pada proses register.
- Membuat loading state saat mengambil data pesanan.
- Membuat empty state ketika belum ada pesanan.
- Membuat alur navigasi pelanggan:
  - Login
  - Home
  - Buat pesanan
  - Riwayat
  - Detail
  - Tracking
  - Pembayaran
- Membuat alur navigasi admin:
  - Login
  - Dashboard Admin
  - Update status
  - Logout
- Membuat logout flow untuk pelanggan dan admin.
- Membuat atau memperbarui test di `test/widget_test.dart`.
- Menjalankan dan mengecek hasil `flutter analyze`.
- Menjalankan dan mengecek hasil `flutter test`.
- Membantu menemukan dan mencatat bug aplikasi.
- Membantu memperbaiki bug kecil dari hasil testing.

### Dokumentasi

- Menyusun PRD di `PRD.md`.
- Menyusun alur aplikasi pelanggan.
- Menyusun alur aplikasi admin.
- Menyusun dokumentasi cara menjalankan aplikasi.
- Menyusun dokumentasi akun demo.
- Menyusun dokumentasi cara menjalankan SQL migration.
- Menyusun skenario testing aplikasi.
- Memastikan fitur akhir sesuai PRD.

## Pembagian Modul Berdasarkan PRD

| Modul PRD | Penanggung Jawab |
| --- | --- |
| Ringkasan produk | Yanita |
| Tujuan produk | Yanita |
| Target pengguna | Yanita |
| Login | Faruq, Yanita |
| Register pelanggan | Faruq, Yanita |
| Role pelanggan dan admin | Adzriel, Yanita |
| Home pelanggan | Faruq |
| Buat pesanan | Faruq, Adzriel, Yanita |
| Riwayat pesanan | Faruq, Adzriel |
| Detail pesanan | Faruq |
| Tracking pesanan | Faruq, Adzriel, Yanita |
| Pembayaran | Faruq, Adzriel, Yanita |
| Dashboard admin | Faruq, Adzriel |
| Database Supabase | Adzriel |
| Validasi input | Yanita |
| Error handling | Yanita |
| Testing | Yanita |
| Dokumentasi | Yanita |

## Checklist Akhir

- [ ] Database Supabase sudah dibuat.
- [ ] SQL migration sudah dijalankan.
- [ ] Akun demo pelanggan dan admin tersedia.
- [ ] Login pelanggan berjalan.
- [ ] Login admin berjalan.
- [ ] Register pelanggan berjalan.
- [ ] Pelanggan dapat membuat pesanan.
- [ ] Pesanan tersimpan ke Supabase.
- [ ] Riwayat pesanan tampil.
- [ ] Detail pesanan tampil.
- [ ] Tracking pesanan tampil.
- [ ] Pembayaran dapat dikonfirmasi.
- [ ] Admin dapat melihat seluruh pesanan.
- [ ] Admin dapat mengubah status pesanan.
- [ ] Logout berjalan.
- [ ] `flutter analyze` tidak memiliki error.
- [ ] `flutter test` berhasil.
- [ ] PRD sudah diperbarui.
- [ ] Dokumentasi cara menjalankan aplikasi tersedia.
