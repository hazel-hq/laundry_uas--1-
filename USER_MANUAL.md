# User Manual FreshLaundry

## 1. Pendahuluan

FreshLaundry adalah aplikasi mobile berbasis Flutter untuk layanan laundry kiloan. Aplikasi ini digunakan oleh pelanggan untuk membuat pesanan laundry, melakukan pembayaran, melihat riwayat pesanan, memantau status laundry, serta mengakses informasi profil dan bantuan. Aplikasi juga menyediakan halaman admin untuk mengelola status pesanan pelanggan.

User manual ini menjelaskan cara menggunakan aplikasi FreshLaundry dari sisi pelanggan, guest, dan admin.

## 2. Peran Pengguna

### 2.1 Pelanggan

Pelanggan adalah pengguna yang memiliki akun dan dapat menggunakan fitur utama aplikasi, yaitu:

- Login ke aplikasi.
- Membuat pesanan laundry.
- Mendapatkan diskon bulanan otomatis jika memenuhi syarat.
- Melakukan pembayaran.
- Melihat riwayat pesanan.
- Melacak status pesanan.
- Mengakses halaman profil.
- Logout dari aplikasi.

### 2.2 Guest

Guest adalah pengguna yang masuk tanpa akun. Mode guest digunakan untuk mencoba aplikasi secara terbatas. Jika guest ingin membuat pesanan, aplikasi akan menampilkan dialog bahwa pengguna harus login terlebih dahulu.

### 2.3 Admin

Admin adalah pengguna yang bertugas mengelola pesanan pelanggan. Admin dapat:

- Login ke Dashboard Admin.
- Melihat semua pesanan pelanggan.
- Melihat ringkasan jumlah pesanan.
- Mengubah status pesanan.
- Melakukan refresh data.
- Logout dari Dashboard Admin.

## 3. Akun Demo

Aplikasi menyediakan akun demo untuk kebutuhan pengujian.

| Role | Email | Username | Password |
| --- | --- | --- | --- |
| Pelanggan | `pelanggan1@freshlaundry.test` | `pelanggan1` | `123456` |
| Pelanggan | `pelanggan2@freshlaundry.test` | `pelanggan2` | `123456` |
| Admin | `admin@freshlaundry.test` | `admin` | `admin123` |

## 4. Membuka Aplikasi

1. Jalankan aplikasi FreshLaundry.
2. Aplikasi akan menampilkan halaman splash screen.
3. Setelah proses awal selesai, sistem akan mengarahkan pengguna ke halaman login.

## 5. Login

Halaman login digunakan untuk masuk sebagai pelanggan atau admin.

Langkah login:

1. Masukkan email.
2. Masukkan username.
3. Masukkan password.
4. Tekan tombol **Login**.
5. Jika data benar:
   - Pelanggan diarahkan ke halaman Home.
   - Admin diarahkan ke Dashboard Admin.
6. Jika data salah, aplikasi menampilkan pesan error.

Catatan:

- Semua field wajib diisi.
- Email harus menggunakan format yang benar.
- Kombinasi email, username, dan password harus sesuai dengan data akun.

## 6. Registrasi Pelanggan

Fitur registrasi digunakan untuk membuat akun pelanggan baru.

Langkah registrasi:

1. Pada halaman login, tekan tombol **Daftar sebagai pelanggan**.
2. Isi form registrasi:
   - Email
   - Nama lengkap
   - Username
   - Password
3. Pastikan password minimal 6 karakter.
4. Tekan tombol **Daftar**.
5. Jika berhasil, akun akan disimpan dan pengguna diarahkan ke halaman Home.

Jika registrasi gagal, aplikasi akan menampilkan pesan error. Penyebab yang umum adalah email atau username sudah digunakan.

## 7. Masuk Sebagai Guest

Pengguna dapat mencoba aplikasi tanpa membuat akun.

Langkah masuk sebagai guest:

1. Buka halaman login.
2. Tekan tombol **Masuk sebagai Guest**.
3. Aplikasi akan menampilkan halaman Home dalam mode guest.

Batasan mode guest:

- Guest dapat melihat tampilan Home.
- Guest tidak dapat membuat pesanan.
- Saat guest mencoba membuat pesanan, aplikasi akan meminta pengguna login terlebih dahulu.

## 8. Navigasi Utama Pelanggan

Setelah login sebagai pelanggan, aplikasi menampilkan bottom navigation dengan menu:

- **Home**
- **Riwayat**
- **Tracking**
- **Profil**

## 9. Home

Halaman Home menampilkan ringkasan informasi pelanggan.

Informasi yang tersedia:

- Sapaan pengguna berdasarkan waktu.
- Username pelanggan.
- Jumlah total pesanan.
- Jumlah pesanan aktif.
- Promo atau informasi layanan.
- Tombol **Buat Pesanan Baru**.
- Daftar layanan laundry.
- Pesanan terbaru.

Layanan yang tersedia:

| Layanan | Harga |
| --- | --- |
| Cuci | Rp 5.000/kg |
| Setrika | Rp 4.000/kg |
| Express | Rp 8.000/kg |
| Cuci+Setrika | Rp 8.500/kg |

## 10. Membuat Pesanan

Fitur ini digunakan pelanggan untuk membuat pesanan laundry baru.

Langkah membuat pesanan:

1. Login sebagai pelanggan.
2. Buka halaman **Home**.
3. Tekan tombol **Buat Pesanan Baru**.
4. Isi data pelanggan:
   - Nama lengkap
   - Berat laundry dalam kilogram
5. Pilih layanan laundry:
   - Cuci
   - Setrika
   - Express
6. Aplikasi akan menampilkan estimasi harga.
7. Tekan tombol **Buat pesanan**.
8. Jika berhasil, aplikasi langsung mengarahkan pelanggan ke halaman **Pembayaran**.

Validasi pesanan:

- Nama wajib diisi.
- Berat wajib diisi.
- Berat harus lebih dari 0.
- Layanan harus dipilih.

## 11. Diskon Langganan Bulanan

FreshLaundry memiliki fitur diskon otomatis untuk pelanggan yang sering melakukan laundry.

Aturan diskon:

- Diskon berlaku untuk pelanggan yang sudah membuat minimal 5 pesanan dalam bulan berjalan.
- Diskon diberikan otomatis pada pesanan ke-5 dan pesanan berikutnya dalam bulan yang sama.
- Besar diskon adalah 10% dari subtotal pesanan.
- Diskon hanya berlaku untuk pelanggan yang login, bukan guest.

Rumus perhitungan:

```text
Subtotal = berat laundry x harga layanan
Diskon = subtotal x 10%
Total bayar = subtotal - diskon
```

Contoh:

```text
Berat laundry = 3 kg
Layanan Cuci = Rp 5.000/kg
Subtotal = 3 x 5.000 = Rp 15.000
Diskon 10% = Rp 1.500
Total bayar = Rp 13.500
```

Pada halaman Buat Pesanan, aplikasi akan menampilkan informasi apakah diskon bulanan sudah aktif atau belum.

## 12. Pembayaran

Setelah pesanan berhasil dibuat, pelanggan langsung diarahkan ke halaman Pembayaran.

Informasi yang ditampilkan:

- Nama pelanggan.
- Layanan.
- Berat.
- Harga satuan.
- Subtotal.
- Diskon bulanan jika memenuhi syarat.
- Total tagihan akhir.

Metode pembayaran:

### 12.1 QRIS

Langkah pembayaran QRIS:

1. Pilih metode **QRIS**.
2. Lihat nominal transfer.
3. Scan QR placeholder atau gunakan QRIS ID yang tersedia.
4. Tekan tombol salin jika ingin menyalin nomor rekening atau QRIS ID.
5. Setelah transfer, tekan tombol **Saya sudah transfer**.
6. Aplikasi mengubah status pembayaran menjadi **Lunas**.

### 12.2 COD / Tunai

Langkah pembayaran COD:

1. Pilih metode **COD / Tunai**.
2. Baca instruksi pembayaran di tempat.
3. Siapkan uang tunai sesuai total tagihan.
4. Tekan tombol **Konfirmasi COD**.
5. Aplikasi mengubah status pembayaran menjadi **Lunas**.

Setelah pembayaran dikonfirmasi, aplikasi menampilkan dialog bahwa pembayaran berhasil.

## 13. Riwayat Pesanan

Halaman Riwayat digunakan untuk melihat pesanan yang sudah selesai.

Informasi yang tersedia:

- Jumlah pesanan selesai.
- Total pengeluaran.
- Layanan favorit.
- Daftar pesanan.
- Pencarian berdasarkan nama atau kode pesanan.
- Filter berdasarkan layanan:
  - Semua
  - Cuci
  - Setrika
  - Express
  - Cuci+Setrika

Langkah membuka detail pesanan:

1. Buka menu **Riwayat**.
2. Pilih salah satu pesanan.
3. Aplikasi menampilkan halaman Detail Pesanan.

## 14. Detail Pesanan

Halaman Detail Pesanan menampilkan informasi lengkap dari satu pesanan.

Informasi yang ditampilkan:

- Kode pesanan.
- Nama pelanggan.
- Tanggal pesanan.
- Status pesanan.
- Layanan.
- Berat.
- Harga satuan.
- Subtotal.
- Diskon bulanan jika ada.
- Total pembayaran.
- Status pembayaran.

Aksi yang tersedia:

- **Lacak pesanan** untuk membuka halaman tracking.
- **Bayar sekarang** jika status pembayaran masih **Belum dibayar**.

## 15. Tracking Pesanan

Fitur tracking digunakan untuk memantau proses laundry.

Status pesanan:

1. Menunggu
2. Dicuci
3. Dijemur
4. Selesai
5. Diantar

Langkah melihat tracking:

1. Buka menu **Tracking**, atau buka Detail Pesanan lalu tekan **Lacak pesanan**.
2. Aplikasi menampilkan status pesanan saat ini.
3. Aplikasi menampilkan progress dalam bentuk timeline.

Catatan:

- Pelanggan hanya dapat melihat status.
- Perubahan status dilakukan oleh admin.

## 16. Profil

Halaman Profil menampilkan informasi dan menu tambahan.

Menu profil:

- Edit Profil
- Riwayat Pesanan
- Tracking
- FAQ
- Hubungi Kami
- Tentang Aplikasi
- Notifikasi
- Kebijakan Privasi
- Syarat & Ketentuan
- Logout

Beberapa menu masih berupa informasi atau placeholder untuk pengembangan berikutnya.

## 17. Logout Pelanggan

Langkah logout:

1. Buka menu **Profil**.
2. Pilih **Logout**.
3. Aplikasi menampilkan dialog konfirmasi.
4. Pilih **Keluar**.
5. Sistem menghapus sesi pengguna dan kembali ke halaman login.

## 18. Dashboard Admin

Dashboard Admin digunakan untuk mengelola pesanan pelanggan.

Cara masuk:

1. Buka halaman login.
2. Masukkan akun admin:
   - Email: `admin@freshlaundry.test`
   - Username: `admin`
   - Password: `admin123`
3. Tekan tombol **Login**.
4. Aplikasi menampilkan Dashboard Admin.

Informasi yang tersedia:

- Total seluruh pesanan.
- Jumlah pesanan aktif.
- Jumlah pesanan lunas.
- Jumlah pesanan selesai.
- Daftar pesanan pelanggan.

## 19. Mengubah Status Pesanan Admin

Langkah mengubah status:

1. Login sebagai admin.
2. Buka Dashboard Admin.
3. Pilih pesanan yang ingin diperbarui.
4. Gunakan dropdown **Status pesanan**.
5. Pilih status baru:
   - Menunggu
   - Dicuci
   - Dijemur
   - Selesai
   - Diantar
6. Sistem menyimpan perubahan status.
7. Status baru akan terlihat pada halaman tracking dan riwayat pelanggan.

## 20. Refresh Data Admin

Jika admin ingin mengambil data terbaru:

1. Tekan ikon refresh di bagian atas Dashboard Admin.
2. Aplikasi memuat ulang data dari database.

## 21. Logout Admin

Langkah logout admin:

1. Tekan ikon logout di bagian atas Dashboard Admin.
2. Sistem menghapus sesi admin.
3. Aplikasi kembali ke halaman login.

## 22. Pesan Error dan Kondisi Kosong

Aplikasi dapat menampilkan beberapa kondisi berikut:

### 22.1 Login Gagal

Penyebab:

- Email kosong.
- Username kosong.
- Password kosong.
- Format email salah.
- Kombinasi email, username, dan password tidak sesuai.

Solusi:

- Periksa kembali email, username, dan password.
- Gunakan akun demo jika sedang melakukan pengujian.

### 22.2 Registrasi Gagal

Penyebab:

- Field belum lengkap.
- Password kurang dari 6 karakter.
- Email atau username sudah digunakan.

Solusi:

- Lengkapi semua field.
- Gunakan email atau username lain.
- Pastikan password minimal 6 karakter.

### 22.3 Pesanan Gagal Disimpan

Penyebab:

- Nama pelanggan kosong.
- Berat kosong atau tidak valid.
- Koneksi database bermasalah.
- Konfigurasi Supabase belum benar.

Solusi:

- Isi nama dan berat dengan benar.
- Pastikan berat lebih dari 0.
- Periksa koneksi internet.
- Periksa konfigurasi Supabase.

### 22.4 Data Pesanan Gagal Dimuat

Penyebab:

- Koneksi internet bermasalah.
- Database Supabase belum berjalan.
- Credential Supabase belum dikonfigurasi.

Solusi:

- Tekan tombol **Coba lagi**.
- Periksa koneksi internet.
- Pastikan Supabase URL dan anon key sudah benar.

### 22.5 Riwayat Kosong

Riwayat dapat kosong jika:

- Belum ada pesanan selesai.
- Filter yang dipilih tidak memiliki pesanan.
- Kata kunci pencarian tidak sesuai.

Solusi:

- Buat pesanan baru.
- Pilih filter **Semua**.
- Hapus kata kunci pencarian.

## 23. Catatan Batasan Aplikasi

Beberapa fitur masih dalam tahap simulasi atau pengembangan:

- Autentikasi masih memakai tabel demo `app_users`, belum Supabase Auth resmi.
- Password akun demo masih disimpan untuk kebutuhan simulasi.
- QRIS masih berupa placeholder.
- Belum ada upload bukti pembayaran.
- Belum ada fitur alamat jemput dan antar.
- Belum ada notifikasi real-time.
- Beberapa menu profil masih berupa informasi atau placeholder.

## 24. Ringkasan Alur Utama Pelanggan

```text
Buka aplikasi
-> Login / Registrasi
-> Home
-> Buat Pesanan Baru
-> Isi nama, berat, dan layanan
-> Sistem menghitung subtotal, diskon jika ada, dan total bayar
-> Pesanan disimpan
-> Pembayaran
-> Konfirmasi pembayaran
-> Tracking pesanan
-> Riwayat pesanan
```

## 25. Ringkasan Alur Utama Admin

```text
Buka aplikasi
-> Login sebagai admin
-> Dashboard Admin
-> Lihat daftar pesanan
-> Ubah status pesanan
-> Refresh data jika diperlukan
-> Logout
```

## 26. Penutup

User manual ini dibuat untuk membantu pengguna memahami cara menggunakan aplikasi FreshLaundry. Dengan adanya panduan ini, pelanggan dapat melakukan pemesanan dan pembayaran dengan lebih mudah, sementara admin dapat mengelola status pesanan dengan lebih jelas.

