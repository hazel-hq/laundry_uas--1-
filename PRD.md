# PRD FreshLaundry

## 1. Ringkasan Produk

FreshLaundry adalah aplikasi mobile berbasis Flutter untuk layanan laundry kiloan yang ditujukan bagi mahasiswa kost. Aplikasi membantu pengguna membuat pesanan laundry, melihat estimasi harga, memantau status pengerjaan, melihat riwayat pesanan, dan melakukan konfirmasi pembayaran melalui QRIS atau COD.

## 2. Tujuan Produk

Mempermudah proses pemesanan laundry bagi mahasiswa dengan alur yang cepat, sederhana, dan transparan.

Tujuan utama:

- Pengguna dapat membuat pesanan laundry tanpa datang langsung ke outlet.
- Pengguna dapat melihat total biaya berdasarkan berat dan jenis layanan.
- Pengguna dapat memantau status laundry secara bertahap.
- Pengguna dapat memilih dan mengonfirmasi metode pembayaran.
- Admin sederhana dapat memperbarui status pesanan melalui halaman tracking.

## 3. Target Pengguna

- Mahasiswa kost yang membutuhkan layanan laundry kiloan.
- Pemilik atau admin laundry skala kecil.
- Pengguna guest yang ingin mencoba aplikasi tanpa registrasi penuh.

## 4. Fitur Utama

### 4.1 Login

- Pengguna dapat masuk menggunakan username dan password.
- Pengguna dapat masuk sebagai guest.
- Login saat ini belum melakukan validasi autentikasi ke backend.

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
- Sistem menghitung total otomatis dengan rumus:

```text
Total = berat x harga layanan
```

- Validasi:
  - Nama wajib diisi.
  - Berat wajib diisi.
  - Berat harus lebih dari 0.
- Setelah berhasil, pesanan disimpan ke daftar lokal aplikasi.

### 4.4 Riwayat Pesanan

- Menampilkan semua pesanan.
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
- Tersedia panel admin untuk mengubah status pesanan.

### 4.7 Pembayaran

- Menampilkan ringkasan tagihan.
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

## 5. Alur Pengguna

1. Pengguna membuka aplikasi.
2. Pengguna masuk melalui login atau guest.
3. Pengguna melihat home dan daftar layanan.
4. Pengguna membuat pesanan baru.
5. Sistem menghitung total biaya.
6. Pesanan masuk ke riwayat.
7. Pengguna membuka detail pesanan.
8. Pengguna melacak status laundry.
9. Pengguna memilih metode pembayaran.
10. Pengguna mengonfirmasi pembayaran.
11. Status pembayaran menjadi lunas.

## 6. Data Pesanan

Model data utama: `Order`

Field:

- `id`
- `nama`
- `berat`
- `layanan`
- `total`
- `status`
- `statusBayar`
- `tanggal`

Status default:

- `status`: Menunggu
- `statusBayar`: Belum dibayar

Penyimpanan saat ini masih menggunakan list lokal di memori:

```dart
List<Order> orderList = [];
```

Artinya data akan hilang jika aplikasi ditutup atau restart.

## 7. Kebutuhan Non-Fungsional

- Aplikasi harus mudah digunakan oleh pengguna awam.
- UI harus ringan dan responsif di perangkat mobile.
- Validasi input harus mencegah pesanan tidak valid.
- Perhitungan harga harus akurat.
- Status pesanan dan pembayaran harus konsisten antar halaman.

## 8. Batasan Saat Ini

- Belum ada backend/database aktif.
- Folder `supabase` tersedia, tetapi kode aplikasi belum menggunakan Supabase.
- Login belum memiliki autentikasi sungguhan.
- Data pesanan belum persisten.
- QRIS masih berupa placeholder.
- Tidak ada role user/admin yang benar-benar dipisahkan.
- Profil belum masuk ke bottom navigation.
- Belum ada fitur alamat jemput/antar.
- Belum ada notifikasi status pesanan.

## 9. Rekomendasi Pengembangan Berikutnya

- Integrasi Supabase untuk menyimpan pesanan.
- Implementasi autentikasi user.
- Tambahkan role admin dan customer.
- Pisahkan halaman admin untuk update status.
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
