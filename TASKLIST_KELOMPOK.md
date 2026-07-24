# Task List Kelompok FreshLaundry

## Anggota Kelompok

| No | Nama Anggota |
| --- | --- |
| 1 | Adzriel |
| 2 | Faruq |
| 3 | Yanita |

## Ringkasan Pembagian Tugas

| No | Anggota | Fokus Utama | Output Utama |
| --- | --- | --- | --- |
| 1 | Adzriel | Database, model data, service, dan integrasi Supabase | Database berjalan, data tersimpan, query aplikasi berfungsi |
| 2 | Faruq | UI/UX aplikasi pelanggan dan admin | Tampilan aplikasi rapi, responsif, dan mudah digunakan |
| 3 | Yanita | Validasi, alur aplikasi, testing, dan dokumentasi | Aplikasi sesuai PRD, alur jelas, minim bug, dan terdokumentasi |

## Task List Utama

| No | Modul / Fitur | Deskripsi Tugas | Penanggung Jawab | Output |
| --- | --- | --- | --- | --- |
| 1 | Konfigurasi Supabase | Membuat konfigurasi koneksi Supabase pada aplikasi Flutter | Adzriel | File konfigurasi Supabase siap digunakan |
| 2 | Database Supabase | Membuat schema database untuk user, layanan, pesanan, item pesanan, pembayaran, dan riwayat status | Adzriel | SQL migration tersedia dan dapat dijalankan |
| 3 | Relasi Database | Membuat relasi antar tabel agar data pesanan, pembayaran, dan user saling terhubung | Adzriel | Relasi database tersusun dengan benar |
| 4 | Seed Data Layanan | Menambahkan data awal layanan Cuci, Setrika, dan Express | Adzriel | Data layanan tersedia di database |
| 5 | Akun Demo | Membuat akun demo pelanggan dan admin | Adzriel | Akun demo dapat digunakan untuk login |
| 6 | Model User | Membuat model `AppUser` yang memuat email, username, nama lengkap, dan role | Adzriel | Data user dapat dibaca dari Supabase |
| 7 | Model Pesanan | Membuat model `Order` untuk data pesanan, subtotal, diskon, total, status pesanan, dan status pembayaran | Adzriel | Data pesanan dapat diproses di aplikasi |
| 8 | Repository Auth | Membuat service login dan register pelanggan | Adzriel | Login dan registrasi terhubung ke database |
| 9 | Repository Pesanan | Membuat service untuk mengambil, menyimpan, dan memperbarui data pesanan | Adzriel | Query pesanan berjalan |
| 10 | Repository Pembayaran | Membuat service konfirmasi pembayaran | Adzriel | Data pembayaran tersimpan |
| 11 | Fitur Diskon Bulanan | Membuat logika diskon otomatis 10% jika pelanggan sudah membuat minimal 5 pesanan dalam bulan berjalan | Adzriel, Yanita | Diskon otomatis diterapkan pada pesanan yang memenuhi syarat |
| 12 | Halaman Login | Membuat dan merapikan form login dengan email, username, password, dan logo aset `app_icon.png` | Faruq, Yanita | Halaman login lebih profesional dengan logo resmi |
| 13 | Validasi Login | Memastikan email, username, dan password wajib diisi serta format email valid | Yanita | Login memiliki validasi dan pesan error |
| 14 | Halaman Register | Membuat form registrasi pelanggan dengan email, nama lengkap, username, dan password | Faruq, Yanita | Pelanggan dapat membuat akun baru |
| 15 | Validasi Register | Memastikan data register lengkap dan password minimal 6 karakter | Yanita | Registrasi lebih aman dan informatif |
| 16 | Home Pelanggan | Membuat halaman Home berisi sapaan, ringkasan pesanan, layanan, promo, dan pesanan terbaru | Faruq | Home pelanggan tampil informatif |
| 17 | Navigasi Utama | Membuat bottom navigation untuk Home, Riwayat, Tracking, dan Profil dengan transisi `AnimatedSwitcher` | Faruq | Navigasi aplikasi halus dan mudah digunakan |
| 18 | Dialog Login Required | Membatasi guest agar harus login saat ingin membuat pesanan | Yanita | Guest tidak dapat membuat pesanan tanpa akun |
| 19 | Form Buat Pesanan | Membuat form input nama pelanggan, nomor HP, berat laundry, dan pilihan layanan | Faruq | Pelanggan dapat mengisi data pesanan |
| 20 | Validasi Pesanan | Memastikan nama, nomor HP, dan berat wajib diisi, nomor HP valid, serta berat harus lebih dari 0 | Yanita | Pesanan tidak valid dapat dicegah |
| 21 | Estimasi Harga | Menghitung subtotal dari berat laundry dan harga layanan | Adzriel, Faruq | Estimasi biaya tampil otomatis |
| 22 | Tampilan Diskon | Menampilkan status diskon bulanan, subtotal, potongan diskon, dan total bayar | Faruq, Yanita | Pelanggan memahami rincian tagihan |
| 23 | Alur Setelah Pesan | Mengarahkan pelanggan langsung ke halaman Pembayaran setelah pesanan berhasil dibuat | Yanita | Alur pemesanan tidak membingungkan |
| 24 | Halaman Pembayaran | Membuat halaman pembayaran berisi ringkasan tagihan, subtotal, diskon, dan total akhir | Faruq | Tagihan tampil lengkap |
| 25 | Metode QRIS | Menampilkan QRIS pembayaran, nominal transfer, dan tombol salin | Faruq | Pembayaran QRIS dapat dipindai dan disimulasikan |
| 26 | Metode COD | Membuat tampilan pembayaran tunai / COD dan instruksi pembayaran | Faruq | Pembayaran COD dapat disimulasikan |
| 27 | Konfirmasi Pembayaran | Menyimpan pembayaran dan mengubah status pembayaran menjadi Lunas | Adzriel, Yanita | Status pembayaran berubah dengan benar |
| 28 | Riwayat Pesanan | Membuat halaman riwayat pesanan selesai, pencarian, dan ringkasan pengeluaran | Faruq, Adzriel | Riwayat pesanan dapat dilihat |
| 29 | Filter Riwayat | Membuat filter riwayat berdasarkan layanan: Semua, Cuci, Setrika, Express, dan Cuci+Setrika | Faruq | Riwayat dapat difilter berdasarkan layanan |
| 30 | Detail Pesanan | Membuat halaman detail pesanan berisi data pelanggan, nomor HP, layanan, subtotal, diskon, total, status, dan pembayaran | Faruq | Detail pesanan tampil lengkap |
| 31 | Timeline Tracking Pesanan | Membuat timeline visual dengan tahap selesai, tahap aktif, dan tahap berikutnya untuk status Menunggu, Dicuci, Dijemur, Selesai, dan Diantar | Faruq, Yanita | Pelanggan dapat memantau progres pesanan dengan jelas |
| 32 | Dashboard Admin | Membuat dashboard admin berisi total pesanan, pesanan aktif, lunas, selesai, dan daftar pesanan | Faruq, Adzriel | Admin dapat memantau pesanan |
| 33 | Update Status Admin | Membuat dropdown untuk mengubah status pesanan pelanggan | Adzriel, Faruq | Admin dapat memperbarui progress laundry |
| 34 | Refresh Data Admin | Membuat fitur refresh data pesanan pada dashboard admin | Faruq | Admin dapat mengambil data terbaru |
| 35 | Profil Pelanggan | Membuat halaman profil berisi menu edit profil, riwayat, tracking, FAQ, kontak, dan logout | Faruq | Profil pelanggan tersedia |
| 36 | Logout | Membuat alur logout untuk pelanggan dan admin | Yanita | Pengguna dapat keluar dari aplikasi |
| 37 | Error Handling | Membuat pesan error saat login, register, simpan pesanan, pembayaran, atau load data gagal | Yanita | Pengguna mendapat informasi saat terjadi error |
| 38 | Empty State | Membuat tampilan saat belum ada pesanan atau data tidak ditemukan | Yanita, Faruq | Tampilan kosong lebih informatif |
| 39 | Testing Manual | Mengecek alur login, register, pemesanan, diskon, pembayaran, tracking, admin, dan logout | Yanita | Hasil testing dapat dicatat |
| 40 | Flutter Analyze | Menjalankan analisis kode untuk memastikan tidak ada error pada file utama | Yanita | Kode lebih stabil |
| 41 | PRD | Menyusun dan memperbarui PRD sesuai fitur terbaru aplikasi | Yanita | `PRD.md` sesuai implementasi |
| 42 | User Manual | Menyusun user manual lengkap untuk pelanggan, guest, dan admin | Yanita | `USER_MANUAL.md` tersedia |
| 43 | Dokumentasi Database | Menyusun dokumentasi struktur database dan cara menjalankan migration | Adzriel | Dokumentasi database tersedia |
| 44 | Screenshot / Presentasi | Menyiapkan screenshot tampilan aplikasi untuk laporan atau presentasi | Faruq | Materi presentasi lebih lengkap |
| 45 | Notifikasi Status Pesanan | Menampilkan push notifikasi lokal & feed notifikasi lonceng ber-badge merah saat status tracking diperbarui via Supabase Realtime | Adzriel, Faruq, Yanita | Pelanggan yang terhubung menerima notifikasi & riwayat tersimpan |
| 46 | Polishing UI/UX | Menambahkan aksen gelembung laundry (`_BubbleDecoration`) pada kartu utama dan transisi tab halus | Faruq | Tampilan aplikasi lebih modern & menarik |

## Pembagian Modul Berdasarkan PRD

| No | Modul PRD | Penanggung Jawab | Keterangan |
| --- | --- | --- | --- |
| 1 | Ringkasan Produk | Yanita | Menjelaskan tujuan dan gambaran aplikasi |
| 2 | Target Pengguna | Yanita | Menentukan pelanggan, guest, dan admin |
| 3 | Login | Faruq, Yanita, Adzriel | UI login, validasi, dan auth repository |
| 4 | Register Pelanggan | Faruq, Yanita, Adzriel | UI register, validasi, dan simpan akun |
| 5 | Role Pelanggan dan Admin | Adzriel, Yanita | Penentuan akses berdasarkan role |
| 6 | Home Pelanggan | Faruq | Tampilan home, layanan, dan pesanan terbaru |
| 7 | Buat Pesanan | Faruq, Adzriel, Yanita | UI form, validasi, simpan pesanan |
| 8 | Diskon Bulanan | Adzriel, Faruq, Yanita | Logika diskon, tampilan rincian, dan dokumentasi |
| 9 | Pembayaran | Faruq, Adzriel, Yanita | UI pembayaran, metode bayar, dan konfirmasi pembayaran |
| 10 | Riwayat Pesanan | Faruq, Adzriel | UI riwayat dan query data pesanan |
| 11 | Detail Pesanan | Faruq, Yanita | Tampilan detail dan konsistensi data tagihan |
| 12 | Tracking Pesanan | Faruq, Adzriel, Yanita | Timeline status dan data tracking |
| 13 | Dashboard Admin | Faruq, Adzriel | Tampilan admin dan update status |
| 14 | Database Supabase | Adzriel | Schema, migration, seed data, dan relasi |
| 15 | Validasi Input | Yanita | Validasi login, register, dan pesanan |
| 16 | Error Handling | Yanita | Pesan error dan kondisi gagal |
| 17 | Testing | Yanita | Pengujian alur utama aplikasi |
| 18 | Dokumentasi | Yanita | PRD, user manual, dan skenario penggunaan |

## Checklist Akhir

| No | Checklist | Status |
| --- | --- | --- |
| 1 | Database Supabase sudah dibuat | Belum dicek final |
| 2 | SQL migration sudah dijalankan | Belum dicek final |
| 3 | Akun demo pelanggan dan admin tersedia | Selesai |
| 4 | Login memakai email, username, dan password | Selesai |
| 5 | Login pelanggan berjalan | Belum dicek final |
| 6 | Login admin berjalan | Belum dicek final |
| 7 | Register pelanggan berjalan | Belum dicek final |
| 8 | Pelanggan dapat membuat pesanan | Belum dicek final |
| 9 | Pesanan tersimpan ke Supabase | Belum dicek final |
| 10 | Setelah pemesanan pelanggan diarahkan ke pembayaran | Selesai |
| 11 | Diskon bulanan otomatis tersedia | Selesai |
| 12 | Rincian subtotal, diskon, dan total tampil di buat pesanan | Selesai |
| 13 | Rincian subtotal, diskon, dan total tampil di pembayaran | Selesai |
| 14 | Riwayat pesanan tampil | Belum dicek final |
| 15 | Detail pesanan tampil | Belum dicek final |
| 16 | Timeline tracking pesanan tampil dengan status selesai, aktif, dan berikutnya | Selesai |
| 17 | Pembayaran dapat dikonfirmasi | Belum dicek final |
| 18 | Admin dapat melihat seluruh pesanan | Belum dicek final |
| 19 | Admin dapat mengubah status pesanan | Belum dicek final |
| 20 | Logout pelanggan dan admin berjalan | Belum dicek final |
| 21 | `dart analyze` pada file yang diubah tidak memiliki issue | Selesai |
| 22 | `flutter test` berhasil | Belum dicek final |
| 23 | PRD sudah diperbarui | Selesai |
| 24 | User manual tersedia | Selesai |
| 25 | Dokumentasi cara menjalankan aplikasi tersedia | Selesai |

## Catatan Koreksi

| No | Bagian Lama | Koreksi |
| --- | --- | --- |
| 1 | Login hanya ditulis menggunakan username dan password | Disesuaikan menjadi email, username, dan password |
| 2 | Filter riwayat ditulis berdasarkan status Proses, Selesai, dan Diantar | Disesuaikan dengan implementasi terbaru, yaitu filter berdasarkan layanan |
| 3 | Fitur diskon bulanan belum tercantum | Ditambahkan sebagai task dan modul tersendiri |
| 4 | Alur setelah membuat pesanan belum ditegaskan | Disesuaikan menjadi langsung ke halaman Pembayaran |
| 5 | User manual belum tercantum | Ditambahkan sebagai bagian dokumentasi akhir |
| 6 | Timeline tracking hanya dicatat sebagai status umum | Diperjelas menjadi timeline visual dengan penanda tahap selesai, aktif, dan berikutnya |
| 7 | Notifikasi perubahan status belum tercantum | Ditambahkan melalui Supabase Realtime dan push notifikasi lokal saat aplikasi pelanggan terhubung |
| 8 | Logo aplikasi masih memakai ikon generik Flutter | Diganti menggunakan logo aset resmi `app_icon.png` di Login, Splash, dan Profil |
| 9 | Transisi navigasi tab masih instan | Diperbarui menggunakan `AnimatedSwitcher` (fade + slide) untuk perpindahan tab yang halus |
| 10 | Riwayat notifikasi status belum tersimpan di UI | Ditambahkan feed notifikasi in-app pada ikon lonceng Home lengkap dengan unread badge merah dan modal `NotificationSheet` |
