# PRD FreshLaundry

## 1. Ringkasan Produk

FreshLaundry adalah aplikasi mobile berbasis Flutter untuk layanan laundry kiloan yang ditujukan bagi mahasiswa kost. Aplikasi membantu pengguna membuat pesanan laundry, melihat estimasi harga, memantau status pengerjaan, melihat riwayat pesanan, dan melakukan konfirmasi pembayaran melalui QRIS atau COD.

## 2. Tujuan Produk

Mempermudah proses pemesanan laundry bagi mahasiswa dengan alur yang cepat, sederhana, dan transparan.

Tujuan utama:

- Pengguna dapat membuat pesanan laundry tanpa datang langsung ke outlet.
- Pengguna dapat melihat total biaya berdasarkan berat dan jenis layanan.
- Pengguna pelanggan tetap dapat memperoleh diskon bulanan otomatis setelah mencapai jumlah pemesanan tertentu.
- Pengguna dapat memantau status laundry secara bertahap.
- Pengguna dapat memilih dan mengonfirmasi metode pembayaran.
- Admin dapat memantau seluruh pesanan dan memperbarui status pesanan melalui Dashboard Admin.

## 3. Target Pengguna

- Mahasiswa kost yang membutuhkan layanan laundry kiloan.
- Pemilik atau admin laundry skala kecil.
- Pengguna guest yang ingin mencoba aplikasi tanpa registrasi penuh.

## 4. Fitur Utama

### 4.1 Login

- Pengguna dapat masuk menggunakan username dan password.
- Pengguna dapat mendaftar sebagai pelanggan baru.
- Pengguna dapat masuk sebagai guest.
- Sistem membedakan role pelanggan dan admin.
- Pelanggan diarahkan ke Home pelanggan.
- Admin diarahkan ke Dashboard Admin.

### 4.2 Home

- Menampilkan sapaan berdasarkan waktu.
- Menampilkan jumlah total pesanan.
- Menampilkan jumlah pesanan aktif.
- Menampilkan daftar layanan:
  - Cuci: Rp 5.000/kg
  - Setrika: Rp 4.000/kg
  - Express: Rp 8.000/kg
- Menampilkan dua pesanan terbaru.

### 4.3 Buat Pesanan

- Pengguna mengisi nama pelanggan, berat laundry, dan jenis layanan.
- Sistem menghitung subtotal otomatis dengan rumus:

```text
Subtotal = berat x harga layanan
```

- Sistem memberikan diskon bulanan otomatis sebesar 10% jika pelanggan sudah membuat minimal 5 pesanan dalam bulan berjalan.
- Total pembayaran dihitung dengan rumus:

```text
Total = subtotal - diskon
```

- Validasi:
  - Nama wajib diisi.
  - Berat wajib diisi.
  - Berat harus lebih dari 0.
  - Setelah berhasil, pesanan disimpan ke database Supabase.
- Setelah pesanan berhasil dibuat, sistem langsung mengarahkan pelanggan ke halaman Pembayaran.

### 4.4 Riwayat Pesanan

- Pelanggan melihat pesanan miliknya sendiri.
- Admin melihat seluruh pesanan melalui Dashboard Admin.
- Menampilkan ringkasan total pesanan, pesanan selesai, dan pesanan proses.
- Filter riwayat:
  - Semua
  - Proses
  - Selesai
  - Diantar
- Pengguna dapat membuka detail pesanan.

### 4.5 Detail Pesanan

- Menampilkan ID pesanan, nama pelanggan, tanggal, status pesanan, layanan, berat, harga satuan, total pembayaran, dan status pembayaran.
- Pengguna dapat masuk ke halaman tracking.
- Pengguna dapat masuk ke halaman pembayaran jika status pembayaran masih "Belum dibayar".

### 4.6 Tracking Pesanan

- Menampilkan status pesanan saat ini.
- Status yang tersedia:
  - Menunggu
  - Dicuci
  - Dijemur
  - Selesai
  - Diantar
- Menampilkan progress dalam bentuk timeline.
- Pelanggan dapat melihat perkembangan status pesanan.
- Perubahan status dilakukan oleh admin melalui Dashboard Admin.

### 4.7 Pembayaran

- Menampilkan ringkasan tagihan, meliputi subtotal, diskon bulanan jika ada, dan total tagihan akhir.
- Metode pembayaran:
  - QRIS
  - COD / Tunai
- Untuk QRIS:
  - Menampilkan placeholder QR.
  - Menampilkan nominal transfer.
  - Menampilkan nomor rekening / QRIS ID.
  - Pengguna dapat menyalin nomor pembayaran.
- Untuk COD:
  - Menampilkan instruksi pembayaran di tempat.
- Pengguna dapat mengonfirmasi pembayaran.
- Setelah dikonfirmasi, status pembayaran berubah menjadi "Lunas".

### 4.8 Profil

- Fitur profil:
  - Informasi pengguna
  - Riwayat pesanan
  - Tentang aplikasi
  - Bantuan
  - Info laundry
  - Logout

### 4.9 Dashboard Admin

- Menampilkan ringkasan total pesanan.
- Menampilkan jumlah pesanan aktif.
- Menampilkan jumlah pesanan lunas.
- Menampilkan jumlah pesanan selesai.
- Menampilkan daftar seluruh pesanan pelanggan.
- Admin dapat mengubah status pesanan.
- Admin dapat melakukan refresh data pesanan.
- Admin dapat logout dari halaman admin.

## 5. Alur Aplikasi

Alur aplikasi dibagi berdasarkan peran pengguna, yaitu pelanggan dan admin. Pemisahan alur ini diperlukan agar pengalaman pengguna lebih jelas, aman, dan sesuai dengan tanggung jawab masing-masing role.

### 5.1 Alur Masuk Aplikasi

1. Pengguna membuka aplikasi FreshLaundry.
2. Sistem menampilkan halaman login.
3. Pengguna memilih salah satu opsi:
   - Login sebagai pelanggan menggunakan username dan password.
   - Login sebagai admin menggunakan akun admin.
   - Daftar sebagai pelanggan baru.
   - Masuk sebagai guest untuk mencoba aplikasi.
4. Sistem memvalidasi data login.
5. Jika login berhasil:
   - Pelanggan diarahkan ke halaman Home pelanggan.
   - Admin diarahkan ke Dashboard Admin.
6. Jika login gagal, sistem menampilkan pesan error yang jelas tanpa menghapus input pengguna.

### 5.2 Alur Registrasi Pelanggan

1. Pengguna memilih opsi **Daftar sebagai pelanggan** pada halaman login.
2. Sistem menampilkan form registrasi.
3. Pengguna mengisi:
   - Nama lengkap
   - Username
   - Password
4. Sistem melakukan validasi:
   - Semua field wajib diisi.
   - Password minimal 6 karakter.
   - Username tidak boleh sama dengan akun yang sudah terdaftar.
5. Jika registrasi berhasil, sistem menyimpan akun pelanggan dan mengarahkan pengguna ke halaman Home pelanggan.
6. Jika registrasi gagal, sistem menampilkan penyebab kegagalan, misalnya username sudah digunakan.

### 5.3 Alur Pelanggan Membuat Pesanan

1. Pelanggan masuk ke halaman Home.
2. Sistem menampilkan:
   - Sapaan pengguna
   - Ringkasan jumlah pesanan
   - Jumlah pesanan aktif
   - Daftar layanan laundry
   - Pesanan terbaru
3. Pelanggan memilih menu **Buat pesanan baru**.
4. Sistem menampilkan form pesanan.
5. Pelanggan mengisi:
   - Nama pelanggan
   - Berat laundry
   - Jenis layanan
6. Sistem menghitung estimasi total secara otomatis berdasarkan berat dan harga layanan.
   - Jika pesanan tersebut menjadi pesanan ke-5 atau lebih dalam bulan berjalan, sistem otomatis menerapkan diskon bulanan 10%.
7. Pelanggan menekan tombol **Buat pesanan**.
8. Sistem melakukan validasi:
   - Nama pelanggan wajib diisi.
   - Berat wajib diisi.
   - Berat harus lebih dari 0.
   - Layanan harus dipilih.
9. Jika validasi berhasil, sistem menyimpan pesanan ke database dengan status awal:
   - Status pesanan: `Menunggu`
   - Status pembayaran: `Belum dibayar`
   - Diskon: `10%` dari subtotal jika memenuhi syarat langganan bulanan, selain itu `0`
10. Sistem langsung mengarahkan pelanggan ke halaman Pembayaran untuk menyelesaikan pembayaran pesanan tersebut.

### 5.4 Alur Pelanggan Melihat Riwayat dan Detail Pesanan

1. Pelanggan membuka menu Riwayat.
2. Sistem menampilkan daftar pesanan milik pelanggan tersebut.
3. Pelanggan dapat memfilter pesanan berdasarkan:
   - Semua
   - Proses
   - Selesai
   - Diantar
4. Pelanggan memilih salah satu pesanan.
5. Sistem menampilkan detail pesanan, meliputi:
   - Kode pesanan
   - Nama pelanggan
   - Tanggal pesanan
   - Layanan
   - Berat
   - Harga satuan
   - Subtotal
   - Diskon bulanan jika ada
   - Total pembayaran
   - Status pesanan
   - Status pembayaran
6. Dari halaman detail, pelanggan dapat memilih:
   - Lacak pesanan
   - Bayar sekarang

### 5.5 Alur Tracking Pesanan

1. Pelanggan membuka halaman Tracking dari detail pesanan.
2. Sistem menampilkan status pesanan saat ini.
3. Sistem menampilkan progress pesanan dalam bentuk timeline.
4. Status pesanan mengikuti urutan:
   - `Menunggu`
   - `Dicuci`
   - `Dijemur`
   - `Selesai`
   - `Diantar`
5. Pelanggan hanya melihat perkembangan status pesanan.
6. Perubahan status dilakukan oleh admin melalui Dashboard Admin.

### 5.6 Alur Pembayaran Pelanggan

1. Pelanggan diarahkan ke halaman Pembayaran setelah berhasil membuat pesanan, atau membuka halaman Pembayaran dari detail pesanan jika pesanan belum dibayar.
2. Sistem menampilkan ringkasan tagihan:
   - Nama pelanggan
   - Layanan
   - Berat
   - Harga satuan
   - Subtotal
   - Diskon bulanan jika memenuhi syarat
   - Total tagihan
3. Pelanggan memilih metode pembayaran:
   - QRIS
   - COD / Tunai
4. Jika memilih QRIS:
   - Sistem menampilkan QR / ID pembayaran.
   - Sistem menampilkan nominal transfer.
   - Pelanggan dapat menyalin nomor pembayaran.
5. Jika memilih COD:
   - Sistem menampilkan instruksi pembayaran di tempat.
6. Pelanggan menekan tombol konfirmasi pembayaran.
7. Sistem menyimpan data pembayaran ke database.
8. Status pembayaran berubah menjadi `Lunas`.
9. Sistem menampilkan notifikasi bahwa pembayaran berhasil dikonfirmasi.

### 5.7 Alur Admin Mengelola Pesanan

1. Admin login menggunakan akun admin.
2. Sistem mengarahkan admin ke Dashboard Admin.
3. Dashboard Admin menampilkan:
   - Total seluruh pesanan
   - Jumlah pesanan aktif
   - Jumlah pesanan lunas
   - Jumlah pesanan selesai
   - Daftar seluruh pesanan pelanggan
4. Admin memilih pesanan yang ingin dikelola.
5. Admin dapat mengubah status pesanan sesuai tahapan proses laundry:
   - `Menunggu`
   - `Dicuci`
   - `Dijemur`
   - `Selesai`
   - `Diantar`
6. Sistem menyimpan perubahan status ke database.
7. Perubahan status langsung terlihat pada halaman riwayat dan tracking pelanggan.
8. Admin dapat melakukan refresh data untuk melihat pesanan terbaru.
9. Admin dapat logout dari Dashboard Admin.

### 5.8 Alur Logout

1. Pengguna memilih tombol logout.
2. Sistem menghapus sesi pengguna aktif.
3. Sistem mengarahkan pengguna kembali ke halaman login.

### 5.9 Alur Error dan Kondisi Kosong

1. Jika aplikasi gagal mengambil data dari database, sistem menampilkan pesan error dan tombol **Coba lagi**.
2. Jika belum ada pesanan, sistem menampilkan empty state yang informatif.
3. Jika proses simpan data gagal, sistem menampilkan pesan gagal tanpa menutup halaman.
4. Jika koneksi database belum dikonfigurasi, sistem menampilkan informasi bahwa konfigurasi Supabase belum lengkap.

## 6. Data Pesanan

Model data utama: `Order`

Field:

- `id`
- `orderCode`
- `customerUsername`
- `nama`
- `berat`
- `layanan`
- `subtotal`
- `discount`
- `total`
- `status`
- `statusBayar`
- `tanggal`

Status default:

- `status`: Menunggu
- `statusBayar`: Belum dibayar

Penyimpanan utama menggunakan database Supabase. Aplikasi tetap memakai `orderList` sebagai cache sementara di sisi Flutter agar data mudah ditampilkan ulang antar halaman.

```dart
List<Order> orderList = [];
```

Data pesanan tetap tersimpan di Supabase selama proses simpan ke database berhasil.

## 7. Kebutuhan Non-Fungsional

- Aplikasi harus mudah digunakan oleh pengguna awam.
- UI harus ringan dan responsif di perangkat mobile.
- Validasi input harus mencegah pesanan tidak valid.
- Perhitungan harga harus akurat.
- Status pesanan dan pembayaran harus konsisten antar halaman.

## 8. Batasan Saat Ini

- Autentikasi masih menggunakan tabel demo `app_users`, belum menggunakan Supabase Auth resmi.
- Password akun demo masih disimpan untuk kebutuhan simulasi aplikasi.
- QRIS masih berupa placeholder.
- Profil belum masuk ke bottom navigation.
- Belum ada fitur alamat jemput/antar.
- Belum ada notifikasi status pesanan.

## 9. Rekomendasi Pengembangan Berikutnya

- Migrasi autentikasi demo ke Supabase Auth resmi.
- Terapkan enkripsi atau hashing password jika tetap memakai tabel user khusus.
- Perkuat RLS agar akses pelanggan benar-benar dibatasi di level database.
- Tambahkan alamat pelanggan dan opsi antar/jemput.
- Tambahkan QRIS asli atau upload bukti transfer.
- Tambahkan persistensi data lokal sementara menggunakan shared preferences atau database lokal.
- Hubungkan screen profil ke navigasi utama.
- Tambahkan testing untuk validasi pesanan dan perhitungan harga.

## 10. Indikator Keberhasilan

- Pengguna dapat membuat pesanan dalam kurang dari 1 menit.
- Total harga selalu sesuai dengan berat dan layanan.
- Pengguna dapat melihat status pesanan tanpa bertanya manual ke admin.
- Riwayat pesanan tampil sesuai filter.
- Status pembayaran berubah dengan benar setelah konfirmasi.
