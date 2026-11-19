# BUKU PANDUAN PENGGUNA (USER MANUAL)
# SIAK-ILMI: Sistem Informasi Administrasi & Keuangan Darul Ilmi

> **Versi Dokumen:** 1.1.0 (Edisi Lengkap dengan Panduan Gambar Instruksional)  
> **Target Aplikasi:** SIAK-ILMI Android (Smartphone & Tablet)  
> **Lembaga Naungan:**  
> 1. **SD IT Baitul Akbar Parabek** (Jenjang SD Kelas 1–6)  
> 2. **SMP IT Darul Ilmi** (Jenjang SMP Kelas 7–9)  
> **Arsitektur:** Offline-First (SQLite Drift) & Direct Cloud Backup (Supabase Storage)

---

## DAFTAR ISI

1. [Informasi Umum & Kredensial Awal](#1-informasi-umum--kredensial-awal)
2. [Sistem Keamanan, PIN, dan Akun Operator](#2-sistem-keamanan-pin-dan-akun-operator)
3. [Beranda & Ringkasan Keuangan (Dashboard)](#3-beranda--ringkasan-keuangan-dashboard)
4. [Manajemen Data Siswa](#4-manajemen-data-siswa)
   - [4.1 Pencarian dan Daftar Siswa](#41-pencarian-dan-daftar-siswa)
   - [4.2 Pendaftaran Siswa Baru (Auto-NIS)](#42-pendaftaran-siswa-baru-auto-nis)
   - [4.3 Import Siswa dari Excel/CSV (PPDB & Dapodik)](#43-import-siswa-dari-excelcsv-ppdb--dapodik)
   - [4.4 Tarif Khusus Siswa (Beasiswa / Keringanan)](#44-tarif-khusus-siswa-beasiswa--keringanan)
   - [4.5 Kenaikan Kelas & Kelulusan Otomatis](#45-kenaikan-kelas--kelulusan-otomatis)
5. [Manajemen Biaya & Pembuatan Tagihan](#5-manajemen-biaya--pembuatan-tagihan)
   - [5.1 Master Tarif](#51-master-tarif)
   - [5.2 Diskon Gelombang PPDB Otomatis](#52-diskon-gelombang-ppdb-otomatis)
   - [5.3 Pembuatan Tagihan Massal per Semester (Bulk Billing)](#53-pembuatan-tagihan-massal-per-semester-bulk-billing)
6. [Kasir Pembayaran POS (Point of Sale)](#6-kasir-pembayaran-pos-point-of-sale)
   - [6.1 Alur Transaksi Checklist POS](#61-alur-transaksi-checklist-pos)
   - [6.2 Pembayaran Sebagian / Cicilan](#62-pembayaran-sebagian--cicilan)
   - [6.3 Pembatalan / Void Transaksi](#63-pembatalan--void-transaksi)
7. [Kuitansi & Cetak Struk (Thermal & PDF)](#7-kuitansi--cetak-struk-thermal--pdf)
   - [7.1 Cetak Struk Thermal Bluetooth (ESC/POS)](#71-cetak-struk-thermal-bluetooth-escpos)
   - [7.2 Kuitansi Resmi PDF (Ukuran A5 dengan Logo Yayasan)](#72-kuitansi-resmi-pdf-ukuran-a5-dengan-logo-yayasan)
8. [Pencadangan & Pemulihan Data (Backup & Restore)](#8-pencadangan--pemulihan-data-backup--restore)
   - [8.1 Cadangan Lokal (.ZIP)](#81-cadangan-lokal-zip)
   - [8.2 Cadangan Cloud Supabase (Direct Cloud Sync)](#82-cadangan-cloud-supabase-direct-cloud-sync)
   - [8.3 Pemulihan Database Aman (Safe Restore & Rollback)](#83-pemulihan-database-aman-safe-restore--rollback)
9. [Pengaturan Sistem & Pemeliharaan](#9-pengaturan-sistem--pemeliharaan)
10. [Panduan Pemecahan Masalah (Troubleshooting & FAQ)](#10-panduan-pemecahan-masalah-troubleshooting--faq)
11. [Daftar Indeks Gambar Instruksional](#11-daftar-indeks-gambar-instruksional)

---

## 1. INFORMASI UMUM & KREDENSIAL AWAL

SIAK-ILMI dirancang khusus untuk mempermudah tata kelola keuangan santri/siswa di lingkungan Darul Ilmi. Sistem ini bekerja secara **100% Offline-First**, artinya kasir tetap dapat memproses pembayaran, mencetak struk, dan mengelola tagihan tanpa koneksi internet sama sekali.

![Gambar 1.1: Ikon Aplikasi dan Logo Resmi Yayasan](docs/images/manual/fig_01_app_identity.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 1.1]**
> - **File Target:** `docs/images/manual/fig_01_app_identity.png`
> - **Tangkapan Layar:** Tampilan Ikon Launcher Aplikasi di Layar Utama Android dan Logo Resmi Yayasan Darul Ilmi.
> - **Elemen Penting:** Tampilkan ikon aplikasi berlatar hijau khas institusi dengan teks "SIAK-ILMI".
> - **Keterangan Gambar:** *Gambar 1.1: Ikon resmi aplikasi SIAK-ILMI dan identitas visual institusi.*

### Kredensial Bawaan Pabrik (Default):

| Jenis Akses | Identitas Bawaan | PIN / Password | Hak Akses |
|---|---|---|---|
| **PIN Administrator** | Staf Tata Usaha / Admin | `123456` | Akses Penuh: Transaksi, Tagihan, Siswa, Tarif, Backup, Void |
| **PIN Viewer** | Kepala Sekolah / Pimpinan | `654321` | Akses Baca: Lihat Dashboard, Laporan Kas, Data Siswa (Tanpa Ubah Data) |
| **Akun Operator Kasir** | Username: `admin` | Password: `admin123` | Nama kasir tercetak resmi pada kuitansi & struk |

> [!IMPORTANT]
> Sangat disarankan untuk segera mengubah PIN Administrator dan Password Operator pada menu **Pengaturan** saat pertama kali menggunakan aplikasi.

---

## 2. SISTEM KEAMANAN, PIN, DAN AKUN OPERATOR

Aplikasi menggunakan sistem keamanan ganda: **PIN Level Peran** dan **Akun Operator Kasir**.

```
                         +-----------------------------+
                         |      BUKA APLIKASI          |
                         +--------------+--------------+
                                        |
                         +--------------v--------------+
                         |  Layar Input 6-Digit PIN    |
                         |  [123456] Admin             |
                         |  [654321] Kepala Sekolah    |
                         +--------------+--------------+
                                        |
                 +----------------------+----------------------+
                 |                                             |
    [ Peran: Administrator ]                       [ Peran: Kepala Sekolah ]
    - Kelola Siswa & Tagihan                       - Melihat Laporan Keuangan
    - Eksekusi Pembayaran POS                      - Memantau Tunggakan
    - Backup & Restore Database                    - Monitoring Siswa Aktif
    - Otorisasi Void / Pembatalan                  - (Read-Only / Tanpa Ubah Data)
```

### 2.1 Masuk Menggunakan PIN
1. Buka aplikasi SIAK-ILMI.
2. Masukkan 6-digit PIN pada keypad numerik layar:
   - Ketik `123456` untuk masuk sebagai **Administrator**.
   - Ketik `654321` untuk masuk sebagai **Kepala Sekolah** (Viewer).
3. Aplikasi akan langsung membuka layar utama Beranda.

![Gambar 2.1: Layar Masuk 6-Digit PIN](docs/images/manual/fig_02_pin_screen.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 2.1]**
> - **File Target:** `docs/images/manual/fig_02_pin_screen.png`
> - **Tangkapan Layar:** Layar autentikasi PIN awal saat pertama kali membuka aplikasi.
> - **Elemen Penting:** Beri sorotan kotak merah pada 6 bulatan indikator PIN, tombol keypad numerik, dan label nama sekolah di bagian atas.
> - **Keterangan Gambar:** *Gambar 2.1: Tampilan antarmuka input 6-digit PIN pengaman.*

### 2.2 Login Operator Petugas Kasir (Pencatatan Nama di Kuitansi)
Agar setiap kuitansi dan struk pembayaran memuat nama kasir yang bertugas:
1. Masuk ke tab **Pengaturan** (ikon gerigi di bilah navigasi bawah).
2. Pada bagian **Akun Operator**, tekan tombol **Login**.
3. Masukkan Username: `admin` dan Password: `admin123`.
4. Tekan **Masuk**. Nama operator akan otomatis dicantumkan di bawah tanda tangan kuitansi.

![Gambar 2.2: Dialog Login Akun Operator Kasir](docs/images/manual/fig_02_operator_login.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 2.2]**
> - **File Target:** `docs/images/manual/fig_02_operator_login.png`
> - **Tangkapan Layar:** Pop-up dialog login operator pada menu Pengaturan.
> - **Elemen Penting:** Beri tanda panah pada kolom input Username, kolom Password, dan tombol "Login/Masuk".
> - **Keterangan Gambar:** *Gambar 2.2: Dialog login operator untuk identitas petugas pada kuitansi.*

### 2.3 Mengubah PIN Keamanan
1. Buka tab **Pengaturan** > bagian **Keamanan PIN**.
2. Pilih **Ganti PIN Admin** atau **Ganti PIN Viewer**.
3. Masukkan PIN lama, lalu masukkan PIN baru (6 digit angka) dan ulangi untuk konfirmasi.
4. Tekan **Simpan**.

![Gambar 2.3: Dialog Perubahan PIN Keamanan](docs/images/manual/fig_02_change_pin.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 2.3]**
> - **File Target:** `docs/images/manual/fig_02_change_pin.png`
> - **Tangkapan Layar:** Modal dialog ganti PIN di layar Pengaturan.
> - **Elemen Penting:** Beri sorotan pada input PIN Lama, PIN Baru 6 digit, dan Konfirmasi PIN Baru.
> - **Keterangan Gambar:** *Gambar 2.3: Formulir pembaruan PIN keamanan Administrator / Kepala Sekolah.*

---

## 3. BERANDA & RINGKASAN KEUANGAN (DASHBOARD)

Layar Beranda menyajikan ringkasan keuangan dan operasional secara *real-time*:

![Gambar 3.1: Layar Utama Beranda (Dashboard Metrics)](docs/images/manual/fig_03_dashboard_screen.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 3.1]**
> - **File Target:** `docs/images/manual/fig_03_dashboard_screen.png`
> - **Tangkapan Layar:** Tampilan penuh Beranda aplikasi dalam mode vertikal (tablet/HP).
> - **Elemen Penting:** Berikan kotak sorot bernomor pada: (1) Dropdown Filter Lembaga, (2) Kartu Metrik Keuangan 4 kolom, (3) Tombol Aksi Cepat, dan (4) Bilah Navigasi Bawah.
> - **Keterangan Gambar:** *Gambar 3.1: Layar Beranda utama dengan metrik keuangan real-time.*

- **Filter Lembaga:** Tekan menu dropdown di bagian atas untuk memfilter data:
  - **Semua Lembaga:** Menampilkan total gabungan SD & SMP.
  - **SD IT Baitul Akbar:** Menampilkan metrik khusus tingkat SD.
  - **SMP IT Darul Ilmi:** Menampilkan metrik khusus tingkat SMP.
- **Kartu Metrik Keuangan:**
  - **Pemasukan Hari Ini:** Akumulasi pembayaran yang diterima per hari ini (00:00 - 23:59).
  - **Pemasukan Bulan Ini:** Akumulasi pembayaran sejak tanggal 1 bulan berjalan.
  - **Siswa Aktif:** Total santri/siswa yang berstatus aktif belajar.
  - **Total Tunggakan Berjalan:** Sisa tagihan siswa yang belum dibayar.

---

## 4. MANAJEMEN DATA SISWA

### 4.1 Pencarian dan Daftar Siswa
1. Tekan tab **Siswa** di bilah bawah.
2. Gunakan kolom pencarian di bagian atas untuk mencari berdasarkan **Nama Siswa** atau **NIS**.
3. Gunakan filter tab di bawahnya untuk menyaring:
   - Jenjang: **Semua**, **SD**, atau **SMP**.
   - Status: **Aktif**, **Lulus**, **Pindahan**, atau **Keluar**.

![Gambar 4.1: Layar Direktori & Pencarian Siswa](docs/images/manual/fig_04_student_list.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.1]**
> - **File Target:** `docs/images/manual/fig_04_student_list.png`
> - **Tangkapan Layar:** Daftar siswa dengan bilah pencarian aktif dan tab filter jenjang.
> - **Elemen Penting:** Tunjukkan kartu siswa (Nama, NIS, Kelas, Jenjang SD/SMP, Status Aktif) serta tombol Floating Action Button (+) di pojok kanan bawah.
> - **Keterangan Gambar:** *Gambar 4.1: Antarmuka daftar siswa dengan filter pencarian instan.*

### 4.2 Pendaftaran Siswa Baru (Auto-NIS)
Aplikasi memiliki generator Nomor Induk Siswa (NIS) otomatis sesuai aturan resmi Darul Ilmi:
- **Format NIS:** `[Tahun 2 Digit][Kode Jenjang: 1=SD, 2=SMP][Nomor Urut 3 Digit]`
  - Contoh SD tahun 2026 urutan ke-1: **261001**
  - Contoh SMP tahun 2026 urutan ke-5: **262005**

**Langkah Tambah Siswa:**
1. Pada tab **Siswa**, tekan tombol **+ Tambah Siswa** (Floating Action Button).
2. Pilih Lembaga: **SD IT Baitul Akbar** atau **SMP IT Darul Ilmi**.
3. NIS akan terisi secara otomatis (dapat disesuaikan jika diperlukan).
4. Lengkapi formulir:
   - Nama Lengkap Siswa, Nama Panggilan, Jenis Kelamin (L/P).
   - Kelas Awal (misal: Kelas 1 untuk SD atau Kelas 7 untuk SMP).
   - Tanggal Masuk & Gelombang PPDB (Gelombang 1, 2, atau 3).
   - Data Orang Tua (Nama Ayah/Ibu, Nomor WhatsApp, Alamat).
5. Tekan **Simpan Data Siswa**.

![Gambar 4.2: Formulir Pendaftaran Siswa Baru (Auto-NIS)](docs/images/manual/fig_04_student_form.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.2]**
> - **File Target:** `docs/images/manual/fig_04_student_form.png`
> - **Tangkapan Layar:** Formulir input data siswa baru.
> - **Elemen Penting:** Beri sorotan pada field "Nomor Induk Siswa (Auto Generated)", dropdown jenjang sekolah, dan pilihan gelombang PPDB.
> - **Keterangan Gambar:** *Gambar 4.2: Formulir penambahan siswa baru dengan fitur pembuatan NIS otomatis.*

---

### 4.3 Import Siswa dari Excel/CSV (PPDB & Dapodik)

Aplikasi menyediakan fitur import massal menggunakan **File Picker perangkat asli**:

```
+-------------------------------------------------------------+
| FILE PICKER -> Pilih File Excel (.xlsx) atau CSV (.csv)     |
+-------------------------------------------------------------+
                              |
+-----------------------------v-------------------------------+
| PRATINJAU & VALIDASI DATA SISWA IMPORT                      |
|                                                             |
| Total Baris Terbaca: 45                                     |
| [✓] Status "Lulus"       : 42 Siswa  (Akan Diimpor)         |
| [X] Status "Tidak Lulus" :  3 Siswa  (Diabaikan/Dilewati)   |
|                                                             |
| Opsi Otomatis:                                              |
| [✓] Generate Tagihan SPP Semester 1                         |
| [✓] Terapkan Diskon Gelombang PPDB Otomatis                 |
+-----------------------------+-------------------------------+
                              |
                   [ KONFIRMASI IMPOR DATA ]
```

**Langkah Import:**
1. Masuk ke tab **Siswa**, tekan tombol **Ikon Upload/Import** di pojok kanan atas.
2. Pilih file Excel (`.xlsx`) atau file CSV (`.csv`) dari penyimpanan memori perangkat.
3. Aplikasi akan membuka layar **Pratinjau Impor (Import Preview)**:
   - **Filter Status PPDB:** Sistem otomatis mendeteksi kolom status kelulusan:
     - Calon siswa bertanda **Lulus** akan dicentang untuk disimpan.
     - Calon siswa bertanda **Tidak Lulus** otomatis diabaikan agar database tetap bersih.
   - **Deteksi Duplikasi:** Nama/NIS yang sudah terdaftar sebelumnya akan ditandai agar tidak terjadi data ganda.
   - **Opsi Tagihan Awal:** Centang opsi untuk sekaligus membuat tagihan SPP semester awal & biaya masuk.
4. Periksa ringkasan baris data, lalu tekan tombol **Konfirmasi Impor Siswa**.

![Gambar 4.3: Pemilihan File Excel/CSV via Native File Picker](docs/images/manual/fig_04_file_picker.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.3]**
> - **File Target:** `docs/images/manual/fig_04_file_picker.png`
> - **Tangkapan Layar:** Antarmuka penjelajah file bawaan Android (File Picker) saat memilih file `.xlsx` atau `.csv`.
> - **Elemen Penting:** Tunjukkan seleksi file berekstensi Excel/CSV dari memori internal atau folder Download.
> - **Keterangan Gambar:** *Gambar 4.3: Jendela pemilihan file Excel/CSV dokumen PPDB.*

![Gambar 4.4: Layar Pratinjau Impor & Filter Status Kelulusan](docs/images/manual/fig_04_import_preview.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.4]**
> - **File Target:** `docs/images/manual/fig_04_import_preview.png`
> - **Tangkapan Layar:** Layar Import Preview yang membedakan calon siswa berstatus "Lulus" (hijau dicentang) dan "Tidak Lulus" (abu-abu/merah diabaikan).
> - **Elemen Penting:** Beri sorotan pada ringkasan jumlah data lulus/tidak lulus, opsi checkbox "Generate Tagihan SPP", dan tombol "Konfirmasi Impor".
> - **Keterangan Gambar:** *Gambar 4.4: Layar pratinjau impor data siswa PPDB dengan filter otomatis.*

---

### 4.4 Tarif Khusus Siswa (Beasiswa / Keringanan)
Jika ada siswa yang mendapatkan beasiswa yatim, potongan saudara kandung, atau keringanan biaya:
1. Buka profil detail siswa yang bersangkutan.
2. Tekan menu **Tarif Khusus (Custom Rate)**.
3. Pilih jenis biaya yang ingin disesuaikan (misal: SPP Bulanan).
4. Masukkan nominal khusus (misal: dari normal Rp 150.000 menjadi Rp 75.000 atau Rp 0).
5. Masukkan catatan/alasan (misal: *"Beasiswa Anak Yatim Yayasan"*).
6. Tekan **Simpan Tarif Khusus**. Tagihan siswa ini ke depannya akan selalu mengikuti nominal khusus tersebut.

![Gambar 4.5: Formulir Penetapan Tarif Khusus / Beasiswa Siswa](docs/images/manual/fig_04_custom_rate.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.5]**
> - **File Target:** `docs/images/manual/fig_04_custom_rate.png`
> - **Tangkapan Layar:** Dialog penetapan tarif khusus pada detail profil siswa.
> - **Elemen Penting:** Tampilkan dropdown jenis biaya, input nominal baru khusus, dan field catatan alasan beasiswa.
> - **Keterangan Gambar:** *Gambar 4.5: Dialog konfigurasi tarif khusus beasiswa/keringanan santri.*

---

### 4.5 Kenaikan Kelas & Kelulusan Otomatis
Pada akhir tahun pelajaran (misal dari 2026/2027 ke 2027/2028):
1. Buka tab **Pengaturan** > **Akademik & Siswa** > pilih **Kenaikan Kelas Otomatis**.
2. Sistem otomatis memetakan seluruh siswa:
   - **SD Kelas 1–5:** Dipromosikan naik ke Kelas 2–6.
   - **SD Kelas 6:** Ditandai **Lulus**.
   - **SMP Kelas 7–8:** Dipromosikan naik ke Kelas 8–9.
   - **SMP Kelas 9:** Ditandai **Lulus**.
3. **Pengecualian Tinggal Kelas:** Jika ada santri yang tinggal kelas, cukup ubah status baris santri tersebut dari *Naik Kelas* menjadi *Tinggal Kelas (Tetap)*.
4. Periksa Tahun Ajaran Baru di formulir (misal: `2027/2028`).
5. Masukkan PIN Admin untuk otorisasi, lalu tekan **Eksekusi Kenaikan Kelas**. Seluruh proses diproses secara atomik dalam 1 detik.

![Gambar 4.6: Layar Kenaikan Kelas & Kelulusan Otomatis](docs/images/manual/fig_04_grade_promotion.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 4.6]**
> - **File Target:** `docs/images/manual/fig_04_grade_promotion.png`
> - **Tangkapan Layar:** Layar eksekusi kenaikan kelas massal akhir tahun pelajaran.
> - **Elemen Penting:** Beri sorotan pada field input Tahun Ajaran Baru, daftar tabel siswa dengan status kelas saat ini -> kelas tujuan, dan tombol "Eksekusi Kenaikan Kelas".
> - **Keterangan Gambar:** *Gambar 4.6: Antarmuka evaluasi kenaikan kelas dan kelulusan santri.*

---

## 5. MANAJEMEN BIAYA & PEMBUATAN TAGIHAN

### 5.1 Master Tarif
Daftar tarif standar tersimpan di tab **Biaya & Tagihan**:
- **SPP Rutin Bulanan:** Rp 150.000 / bulan (SD & SMP).
- **Infaq Gedung:** Rp 400.000 (Satu kali saat masuk).
- **Pendaftaran PPDB:** Rp 100.000 (Satu kali saat mendaftar).

Admin dapat mengubah tarif master kapan saja melalui tombol ubah pada daftar kategori biaya.

![Gambar 5.1: Layar Master Tarif & Kategori Biaya](docs/images/manual/fig_05_fee_management.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 5.1]**
> - **File Target:** `docs/images/manual/fig_05_fee_management.png`
> - **Tangkapan Layar:** Tab Biaya & Tagihan yang memuat daftar kategori tarif SD dan SMP.
> - **Elemen Penting:** Tampilkan nominal SPP Rutin, Infaq Gedung, Biaya Pendaftaran, dan ikon pensil (edit) di setiap baris.
> - **Keterangan Gambar:** *Gambar 5.1: Daftar master tarif biaya pendidikan sekolah.*

### 5.2 Diskon Gelombang PPDB Otomatis
Sistem secara cerdas menerapkan skema diskon biaya masuk berdasarkan tanggal pendaftaran siswa:

| Gelombang PPDB | Periode Pendaftaran | Kebijakan Diskon Biaya |
|---|---|---|
| **Gelombang 1** | Oktober – Desember | **Gratis 100%** semua biaya awal (Pendaftaran, Infaq Gedung, & SPP Awal) |
| **Gelombang 2** | Januari – Maret | Bebas Biaya Pendaftaran, **Diskon 50%** Infaq Gedung & SPP Awal |
| **Gelombang 3** | April – Juni | Bebas Biaya Pendaftaran, **Diskon 50%** Infaq Gedung, SPP normal |
| **Reguler** | Di luar gelombang di atas | Seluruh tarif berlaku normal |

### 5.3 Pembuatan Tagihan Massal per Semester (Bulk Billing)
Untuk menerbitkan tagihan bulanan kepada seluruh siswa secara serentak:
1. Buka tab **Biaya & Tagihan** > pilih tombol **Tagihan Massal**.
2. Pilih Semester yang dituju:
   - **Semester Ganjil (Semester 1):** Bulan Juli hingga Desember.
   - **Semester Genap (Semester 2):** Bulan Januari hingga Juni.
3. Pilih Jenjang target (**SD**, **SMP**, atau **Semua Siswa**).
4. Tekan **Pratinjau Tagihan**:
   - Sistem akan menampilkan daftar siswa dan tagihan yang akan dibuat.
   - **Anti-Duplikasi:** Siswa yang sudah memiliki tagihan pada bulan terkait otomatis dilewati (skip) sehingga tidak akan terjadi tagihan ganda.
5. Masukkan PIN Admin dan tekan **Terbitkan Tagihan Massal**.

![Gambar 5.2: Layar Pembuatan Tagihan Massal per Semester](docs/images/manual/fig_05_bulk_billing.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 5.2]**
> - **File Target:** `docs/images/manual/fig_05_bulk_billing.png`
> - **Tangkapan Layar:** Layar konfigurasi Bulk Billing per semester.
> - **Elemen Penting:** Beri sorotan pada pilihan Radio Button Semester (Semester 1 / Semester 2), daftar 6 bulan yang dicakup, dan tombol "Terbitkan Tagihan".
> - **Keterangan Gambar:** *Gambar 5.2: Layar pembuatan tagihan massal per semester untuk seluruh santri.*

---

## 6. KASIR PEMBAYARAN POS (POINT OF SALE)

Antarmuka kasir SIAK-ILMI menggunakan metode **Checklist POS** yang cepat dan bebas dari kesalahan ketik.

```
+-------------------------------------------------------------------+
|  KASIR POS: Muhammad Fatih (NIS: 262001 - SMP Kelas 7)            |
+-------------------------------------------------------------------+
|  Daftar Tagihan Belum Lunas:                                      |
|                                                                   |
|  [✓] SPP Juli 2026 ----------------------------- Rp 150.000       |
|  [✓] SPP Agustus 2026 -------------------------- Rp 150.000       |
|  [✓] Infaq Gedung (Sisa Rp 400.000) ------------ Rp 200.000       |
|      └── [✓] Bayar Sebagian (Cicil): [ Rp 200.000 ]               |
|                                                                   |
|-------------------------------------------------------------------|
|  TOTAL PEMBAYARAN : Rp 500.000                                    |
|  Metode Bayar     : (●) Tunai     (○) Transfer Bank               |
|  Uang Diterima    : [ Rp 500.000                  ]               |
|  Kembalian        : Rp 0                                          |
|-------------------------------------------------------------------|
|          [ KONFIRMASI BAYAR & CETAK KUITANSI ]                    |
+-------------------------------------------------------------------+
```

### 6.1 Alur Transaksi Checklist POS
1. Dari Beranda atau Daftar Siswa, cari dan buka profil siswa.
2. Di **Tab 1: Tagihan Aktif**, kasir akan melihat seluruh tagihan yang belum lunas.
3. Beri centang `[✓]` pada satu atau beberapa item tagihan yang ingin dibayarkan wali santri.
4. Total tagihan akan dihitung secara otomatis di bar bagian bawah.
5. Pilih Metode Pembayaran: **Tunai (Cash)** atau **Transfer Bank**.
6. Masukkan nominal uang yang diserahkan:
   - Sistem otomatis menghitung nilai **Kembalian**.
7. Tekan tombol **Konfirmasi Bayar & Cetak Kuitansi**.
8. Transaksi tersimpan secara permanen dan aplikasi langsung membuka menu cetak kuitansi.

![Gambar 6.1: Antarmuka Checklist Kasir POS](docs/images/manual/fig_06_pos_checklist.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 6.1]**
> - **File Target:** `docs/images/manual/fig_06_pos_checklist.png`
> - **Tangkapan Layar:** Layar POS Checklist dengan beberapa item tagihan tercentang.
> - **Elemen Penting:** Berikan panah dan nomor pada: (1) Checkbox tagihan per bulan, (2) Bar ringkasan total pembayaran di bawah, (3) Pilihan metode Tunai/Transfer, dan (4) Tombol utama "Konfirmasi Bayar".
> - **Keterangan Gambar:** *Gambar 6.1: Antarmuka transaksi kasir Checklist POS multi-item.*

### 6.2 Pembayaran Sebagian / Cicilan
Untuk tagihan berukuran besar seperti Infaq Gedung:
1. Centang item tagihan tersebut.
2. Aktifkan opsi **Bayar Sebagian (Cicilan)** di bawah item tersebut.
3. Ketikkan jumlah uang yang ingin disetor saat ini (misal: Rp 200.000 dari total Rp 400.000).
4. Sistem otomatis mencatat sisa tagihan Rp 200.000 untuk dibayarkan di masa mendatang.

![Gambar 6.2: Pembayaran Sebagian (Cicilan Tagihan)](docs/images/manual/fig_06_partial_payment.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 6.2]**
> - **File Target:** `docs/images/manual/fig_06_partial_payment.png`
> - **Tangkapan Layar:** Detail item tagihan saat toggle "Bayar Sebagian" diaktifkan dan field input cicilan terbuka.
> - **Elemen Penting:** Tampilkan input nominal parsial (Rp 200.000) dan teks keterangan sisa tagihan berikutnya.
> - **Keterangan Gambar:** *Gambar 6.2: Fitur cicilan tagihan pada transaksi kasir POS.*

### 6.3 Pembatalan / Void Transaksi (Jika Terjadi Salah Input)
Jika kasir keliru memilih siswa atau memasukkan item:
1. Masuk ke profil siswa > pilih **Tab 2: Riwayat Pembayaran**.
2. Cari transaksi yang keliru, lalu tekan tombol **Batalkan / Void Transaksi**.
3. Masukkan alasan pembatalan (misal: *"Salah input santri"*).
4. Masukkan **PIN Administrator** (Wajib otorisasi Admin).
5. Sistem akan:
   - Menandai transaksi sebagai Dibatalkan (Void).
   - Mengembalikan seluruh status tagihan ke posisi **Belum Lunas**.
   - Mencatat log pembatalan ke dalam audit trail database.

![Gambar 6.3: Riwayat Pembayaran Siswa & Otorisasi Void Transaksi](docs/images/manual/fig_06_void_transaction.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 6.3]**
> - **File Target:** `docs/images/manual/fig_06_void_transaction.png`
> - **Tangkapan Layar:** Tab Riwayat Transaksi siswa dan pop-up dialog konfirmasi Void dengan verifikasi PIN Admin.
> - **Elemen Penting:** Beri sorotan pada tombol "Batalkan Transaksi", kolom input alasan, dan keypad PIN otorisasi.
> - **Keterangan Gambar:** *Gambar 6.3: Prosedur pembatalan (void) transaksi pembayaran dengan otorisasi Admin.*

---

## 7. KUITANSI & CETAK STRUK (THERMAL & PDF)

Setelah transaksi selesai, sistem menampilkan lembar opsi kuitansi:

```
+-------------------------------------------------------+
|  TRANSAKSI BERHASIL (No: TRX-20261120-001)            |
+-------------------------------------------------------+
|  [ 🖨️ Cetak Struk Thermal (Bluetooth 58mm/80mm) ]      |
|  [ 📄 Unduh / Buka Kuitansi Resmi PDF (A5)        ]   |
|  [ 💬 Bagikan Kuitansi Digital via WhatsApp        ]   |
|  [ Selesai / Tutup                                 ]  |
+-------------------------------------------------------+
```

![Gambar 7.1: Lembar Tindakan Pasca-Transaksi](docs/images/manual/fig_07_receipt_action_sheet.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 7.1]**
> - **File Target:** `docs/images/manual/fig_07_receipt_action_sheet.png`
> - **Tangkapan Layar:** Bottom Sheet pasca-transaksi yang memuat 3 opsi kuitansi.
> - **Elemen Penting:** Tampilkan tombol "Cetak Struk Thermal", "Buka Kuitansi PDF", dan "Bagikan ke WhatsApp".
> - **Keterangan Gambar:** *Gambar 7.1: Lembar opsi pencetakan dan pembagian kuitansi setelah transaksi berhasil.*

### 7.1 Cetak Struk Thermal Bluetooth (ESC/POS)
1. Pastikan Bluetooth pada perangkat Android Anda dalam kondisi **Aktif**.
2. Hubungkan printer kasir Bluetooth (58mm atau 80mm):
   - Masuk ke **Pengaturan** > **Printer** > **Printer Bluetooth**.
   - Tekan **Pindai Perangkat**, lalu pilih printer Anda dari daftar untuk menghubungkan.
3. Pada saat selesai transaksi, tekan **Cetak Struk Thermal**. Struk kasir akan langsung keluar dari printer dalam hitungan detik.

![Gambar 7.2: Contoh Struk Thermal Kasir (ESC/POS 58mm/80mm)](docs/images/manual/fig_07_thermal_receipt.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 7.2]**
> - **File Target:** `docs/images/manual/fig_07_thermal_receipt.png`
> - **Tangkapan Layar:** Foto atau render hasil cetak struk kasir thermal kertas 58mm/80mm.
> - **Elemen Penting:** Tunjukkan header "Darul Ilmi", tanggal/jam, nomor transaksi, tabel item biaya, total bayar, dan nama kasir.
> - **Keterangan Gambar:** *Gambar 7.2: Format fisik struk thermal kasir ESC/POS.*

### 7.2 Kuitansi Resmi PDF (Format A5 Resmi Yayasan)
1. Tekan tombol **Buka Kuitansi Resmi PDF** atau **Bagikan Kuitansi**.
2. Sistem otomatis menghasilkan dokumen PDF dengan spesifikasi:
   - **Kop Surat Yayasan:** Dilengkapi logo resmi `logo_yayasan.png` dan alamat sekolah.
   - **Rincian Pembayaran:** Memuat tabel alokasi per item tagihan secara transparan.
   - **Terbilang Otomatis:** Nilai rupiah diterjemahkan ke teks bahasa Indonesia (contoh: *"Lima Ratus Ribu Rupiah"*).
   - **Nama Kasir & Tanda Tangan:** Nama operator yang sedang login tercetak otomatis.
3. Dokumen PDF dapat langsung dicetak ke printer biasa (printer kantor via WiFi/OTG) atau dibagikan langsung ke nomor WhatsApp wali murid.

![Gambar 7.3: Kuitansi Resmi Format PDF (A5 dengan Logo Yayasan)](docs/images/manual/fig_07_pdf_receipt.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 7.3]**
> - **File Target:** `docs/images/manual/fig_07_pdf_receipt.png`
> - **Tangkapan Layar:** Tampilan pratinjau dokumen PDF kuitansi ukuran A5.
> - **Elemen Penting:** Beri sorotan pada Kop Yayasan & Logo, rincian tabel biaya, blok teks "Terbilang", dan kolom tanda tangan petugas kasir.
> - **Keterangan Gambar:** *Gambar 7.3: Dokumen kuitansi resmi PDF standar yayasan.*

---

## 8. PENCADANGAN & PEMULIHAN DATA (BACKUP & RESTORE)

Data keuangan adalah aset paling berharga. SIAK-ILMI menyediakan sistem proteksi berlapis:

```
                      +-----------------------------+
                      |   TEKAN "BUAT BACKUP"       |
                      +--------------+--------------+
                                     |
               +---------------------v---------------------+
               | 1. CHECKPOINT SQLITE DATABASE             |
               | 2. HITUNG SHA-256 CHECKSUM                |
               | 3. BUAT ARSIP ZIP + MANIFEST.JSON         |
               +---------------------+---------------------+
                                     |
                 +-------------------+-------------------+
                 |                                       |
  [ SIMPAN DI PERANGKAT LOKAL ]             [ SINKRON KE CLOUD SUPABASE ]
  Folder: Download/SIAK-ILMI-Backup          Bucket: siak-ilmi-backups
  (Aman meskipun offline)                    (Tersimpan di Cloud Server)
```

![Gambar 8.1: Layar Manajemen Backup & Restore (Direct Cloud Sync)](docs/images/manual/fig_08_backup_screen.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 8.1]**
> - **File Target:** `docs/images/manual/fig_08_backup_screen.png`
> - **Tangkapan Layar:** Layar Backup & Restore yang menunjukkan status koneksi Supabase ("Terkoneksi"), tombol aksi "Buat Backup" & "Pulihkan Zip", serta daftar riwayat arsip.
> - **Elemen Penting:** Beri sorotan pada badge hijau "Terkoneksi", tombol "Buat Backup", dan daftar file backup di cloud.
> - **Keterangan Gambar:** *Gambar 8.1: Layar utama pencadangan lokal dan sinkronisasi cloud Supabase.*

### 8.1 Cadangan Lokal (.ZIP)
1. Masuk ke menu **Pengaturan** > **Backup Data Sekarang**, atau buka **Riwayat Backup**.
2. Tekan tombol **Buat Backup**.
3. File `.zip` lengkap yang berisi database `siak_ilmi.db` dan `manifest.json` akan disimpan di folder:  
   📁 `Penyimpanan Internal/Download/SIAK-ILMI-Backup/`
4. File ini dapat disalin ke flashdisk (OTG), laptop, atau kartu memori.

![Gambar 8.2: Dialog Informasi Hasil Pembuatan Backup](docs/images/manual/fig_08_backup_result.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 8.2]**
> - **File Target:** `docs/images/manual/fig_08_backup_result.png`
> - **Tangkapan Layar:** Pop-up dialog setelah menekan tombol "Buat Backup".
> - **Elemen Penting:** Tampilkan path lokasi file ZIP lokal dan status centang hijau "Tersinkronisasi ke Supabase Storage".
> - **Keterangan Gambar:** *Gambar 8.2: Notifikasi hasil sukses backup lokal dan cloud.*

### 8.2 Cadangan Cloud Supabase (Direct Cloud Sync)
- Aplikasi telah dilengkapi fitur **Direct Cloud Sync** ke server Supabase Storage.
- Kasir **tidak perlu memasukkan email/password akun Supabase**.
- Selama perangkat terhubung ke internet (WiFi atau kuota data), setiap kali menekan tombol **Buat Backup**, file backup akan otomatis terunggah ke cloud secara *fail-silent* (tanpa mengganggu kinerja kasir jika internet lambat).
- Daftar file backup di cloud dapat dipantau langsung pada layar **Riwayat Backup**.

### 8.3 Pemulihan Database Aman (Safe Restore & Rollback)
Jika perangkat rusak, hilang, atau Anda ingin memindahkan database ke tablet baru:
1. Pindahkan file arsip `.zip` backup ke perangkat baru.
2. Buka layar **Backup & Restore** di aplikasi.
3. Pilih salah satu metode pemulihan:
   - **Pulihkan dari Cloud:** Tekan tombol *Pulihkan* pada daftar backup cloud yang tersedia.
   - **Pulihkan Zip Lokal:** Tekan tombol *Pulihkan Zip* dan pilih file backup dari memori internal.
4. Muncul dialog konfirmasi pemulihan. Tekan **Ya, Pulihkan Database**.
5. **Mesin Pemulihan Aman (10-Step Safe Restore Engine):**
   - Sistem membuat *Safety Backup* otomatis sebelum menyalin data baru.
   - Memvalidasi integritas file arsip dan memeriksa checksum SHA-256.
   - Melakukan uji integritas SQLite (`PRAGMA quick_check`).
   - Jika file terbukti valid: data dipulihkan dan safety backup dibersihkan.
   - Jika arsip rusak/korup: sistem otomatis melakukan **Rollback** ke kondisi semula sehingga database tidak akan pernah rusak atau hilang.
6. Setelah muncul pesan sukses, **tutup dan buka kembali (restart) aplikasi** agar seluruh data termuat sempurna.

![Gambar 8.3: Dialog Konfirmasi & Peringatan Pemulihan Database](docs/images/manual/fig_08_restore_confirm.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 8.3]**
> - **File Target:** `docs/images/manual/fig_08_restore_confirm.png`
> - **Tangkapan Layar:** Dialog peringatan sebelum penimpaan database dimulai.
> - **Elemen Penting:** Sorot teks peringatan merah "PERINGATAN: Memulihkan database...", nama file arsip, dan tombol "Ya, Pulihkan Database".
> - **Keterangan Gambar:** *Gambar 8.3: Konfirmasi pengamanan data sebelum proses pemulihan berjalan.*

---

## 9. PENGATURAN SISTEM & PEMELIHARAAN

Tab **Pengaturan** menyediakan kontrol administratif lengkap:

![Gambar 9.1: Layar Utama Menu Pengaturan Aplikasi](docs/images/manual/fig_09_settings_screen.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 9.1]**
> - **File Target:** `docs/images/manual/fig_09_settings_screen.png`
> - **Tangkapan Layar:** Seluruh menu Pengaturan (Bagian Peran, Keamanan PIN, Operator, Akademik, Tampilan, Printer, Backup, Tentang).
> - **Elemen Penting:** Berikan label sorotan pada setiap grup menu pengaturan.
> - **Keterangan Gambar:** *Gambar 9.1: Pusat kendali konfigurasi dan pemeliharaan sistem.*

1. **Akun Operator Kasir:**
   - Tambah akun operator baru untuk staf TU lain.
   - Nonaktifkan akun operator yang sudah tidak bertugas.

![Gambar 9.2: Layar Kelola Akun Operator Kasir](docs/images/manual/fig_09_operator_management.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 9.2]**
> - **File Target:** `docs/images/manual/fig_09_operator_management.png`
> - **Tangkapan Layar:** Daftar akun operator kasir dan tombol tambah operator.
> - **Elemen Penting:** Tampilkan daftar nama operator, username, NIP, status aktif/nonaktif, dan tombol (+) Tambah Operator.
> - **Keterangan Gambar:** *Gambar 9.2: Layar manajemen akun operator kasir tata usaha.*

2. **Koneksi Printer Bluetooth:**
   - Pengaturan printer default untuk kasir POS.

![Gambar 9.3: Lembar Pemindaian & Pemilihan Printer Bluetooth](docs/images/manual/fig_09_printer_picker.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 9.3]**
> - **File Target:** `docs/images/manual/fig_09_printer_picker.png`
> - **Tangkapan Layar:** Modal sheet Bluetooth Scanner saat mencari printer kasir di sekitar.
> - **Elemen Penting:** Tampilkan daftar perangkat bluetooth yang terdeteksi (nama printer thermal dan alamat MAC).
> - **Keterangan Gambar:** *Gambar 9.3: Jendela pemindaian dan penyambungan printer thermal Bluetooth.*

3. **Pilihan Tema:**
   - Mode Terang (Light Mode): Cocok untuk pemakaian siang hari di kantor TU.
   - Mode Gelap (Dark Mode): Nyaman untuk mata saat pencatatan malam hari.
   - Mengikuti Pengaturan Sistem Android.

![Gambar 9.4: Perbandingan Tampilan Mode Terang dan Mode Gelap](docs/images/manual/fig_09_theme_modes.png)
> 📸 **[PANDUAN GAMBAR - GAMBAR 9.4]**
> - **File Target:** `docs/images/manual/fig_09_theme_modes.png`
> - **Tangkapan Layar:** Gambar perbandingan berdampingan (side-by-side) antara Light Mode dan Dark Mode.
> - **Elemen Penting:** Tunjukkan kenyamanan kontras warna pada kedua mode tampilan.
> - **Keterangan Gambar:** *Gambar 9.4: Pilihan tema tampilan antarmuka (Light Mode vs Dark Mode).*

4. **Informasi Versi & Pembaruan:**
   - Memeriksa versi build aplikasi yang sedang terpasang.

---

## 10. PANDUAN PEMECAHAN MASALAH (TROUBLESHOOTING & FAQ)

### T: Printer Bluetooth tidak ditemukan saat dipindai?
**J:** 
1. Pastikan Bluetooth di perangkat Android dalam posisi Aktif.
2. Pastikan printer kasir dalam kondisi menyala (lampu indikator menyala hijau/biru).
3. Jika menggunakan Android 12 atau yang lebih baru, pastikan izin *Perangkat Terdekat (Nearby Devices)* dan *Lokasi* telah diberikan kepada aplikasi SIAK-ILMI melalui Pengaturan Aplikasi Android.
4. Lakukan pairing printer terlebih dahulu di menu Bluetooth bawaan Android sebelum membuka aplikasi.

### T: Apakah aplikasi bisa dipakai di 2 atau 3 tablet kasir sekaligus?
**J:** Bisa. Masing-masing tablet dapat mengoperasikan aplikasi secara mandiri (offline). Di akhir hari kerja, lakukan **Buat Backup** ke cloud Supabase agar cadangan data harian dari kasir utama tersimpan secara aman di cloud.

### T: Bagaimana jika internet mati saat kasir sedang memproses pembayaran?
**J:** Transaksi tetap berjalan 100% lancar tanpa hambatan! SIAK-ILMI beroperasi secara offline. Pembayaran tersimpan di database internal tablet dan kuitansi struk thermal tetap dapat dicetak seperti biasa. File backup cloud akan terunggah saat koneksi internet kembali tersedia.

### T: Lupa PIN Administrator?
**J:** Jika belum diubah, PIN Administrator bawaan adalah `123456`. Jika sudah diubah dan lupa, hubungi pihak IT/pengembang yayasan untuk melakukan reset PIN via database atau restore dari backup sebelumnya.

---

## 11. DAFTAR INDEKS GAMBAR INSTRUKSIONAL

Untuk mempermudah tim penyusun dokumentasi mengambil dan melengkapi seluruh tangkapan layar, berikut adalah daftar inventaris seluruh gambar yang terdaftar di dalam buku panduan ini:

| No. Gambar | Kode File Screenshot | Bagian / Modul Terkait | Deskripsi Tangkapan Layar |
|---|---|---|---|
| **Gambar 1.1** | `fig_01_app_identity.png` | Bab 1 (Identitas Sistem) | Ikon Launcher Aplikasi & Logo Resmi Yayasan Darul Ilmi |
| **Gambar 2.1** | `fig_02_pin_screen.png` | Bab 2 (Keamanan) | Layar Input 6-Digit PIN Numerik (Layar Kunci Awal) |
| **Gambar 2.2** | `fig_02_operator_login.png` | Bab 2 (Keamanan) | Dialog Pop-up Login Operator Kasir (Username & Password) |
| **Gambar 2.3** | `fig_02_change_pin.png` | Bab 2 (Keamanan) | Formulir Dialog Pengubahan PIN Admin & Viewer |
| **Gambar 3.1** | `fig_03_dashboard_screen.png` | Bab 3 (Beranda) | Layar Beranda Utama (4 Kartu Metrik Keuangan & Aksi Cepat) |
| **Gambar 4.1** | `fig_04_student_list.png` | Bab 4 (Siswa) | Layar Daftar Siswa, Kolom Pencarian, & Tab Jenjang SD/SMP |
| **Gambar 4.2** | `fig_04_student_form.png` | Bab 4 (Siswa) | Formulir Pendaftaran Siswa Baru dengan Auto-NIS |
| **Gambar 4.3** | `fig_04_file_picker.png` | Bab 4 (Siswa) | Jendela Pemilihan Dokumen File Excel/CSV (Native File Picker) |
| **Gambar 4.4** | `fig_04_import_preview.png` | Bab 4 (Siswa) | Layar Pratinjau Impor Siswa & Filter Kelulusan PPDB |
| **Gambar 4.5** | `fig_04_custom_rate.png` | Bab 4 (Siswa) | Formulir Dialog Pengaturan Tarif Khusus Beasiswa Santri |
| **Gambar 4.6** | `fig_04_grade_promotion.png` | Bab 4 (Siswa) | Layar Kenaikan Kelas Otomatis Akhir Tahun Pelajaran |
| **Gambar 5.1** | `fig_05_fee_management.png` | Bab 5 (Biaya & Tagihan) | Daftar Master Tarif Biaya Pendidikan (SPP, Infaq, PPDB) |
| **Gambar 5.2** | `fig_05_bulk_billing.png` | Bab 5 (Biaya & Tagihan) | Layar Pembuatan Tagihan Massal per Semester (Bulk Billing) |
| **Gambar 6.1** | `fig_06_pos_checklist.png` | Bab 6 (Kasir POS) | Layar Transaksi Kasir Checklist POS dengan Tagihan Tercentang |
| **Gambar 6.2** | `fig_06_partial_payment.png` | Bab 6 (Kasir POS) | Fitur Pembayaran Sebagian / Cicilan Tagihan |
| **Gambar 6.3** | `fig_06_void_transaction.png` | Bab 6 (Kasir POS) | Riwayat Transaksi & Dialog Otorisasi Pembatalan (Void) |
| **Gambar 7.1** | `fig_07_receipt_action_sheet.png`| Bab 7 (Kuitansi) | Lembar Opsi Pasca-Transaksi (Thermal, PDF, WhatsApp) |
| **Gambar 7.2** | `fig_07_thermal_receipt.png` | Bab 7 (Kuitansi) | Hasil Cetak Fisik Struk Kasir Thermal ESC/POS (58mm/80mm) |
| **Gambar 7.3** | `fig_07_pdf_receipt.png` | Bab 7 (Kuitansi) | Format Dokumen Kuitansi Resmi PDF A5 dengan Kop Yayasan |
| **Gambar 8.1** | `fig_08_backup_screen.png` | Bab 8 (Backup & Restore)| Layar Utama Backup & Restore (Direct Cloud Sync Supabase) |
| **Gambar 8.2** | `fig_08_backup_result.png` | Bab 8 (Backup & Restore)| Dialog Hasil Pembuatan Backup Lokal dan Status Cloud |
| **Gambar 8.3** | `fig_08_restore_confirm.png` | Bab 8 (Backup & Restore)| Dialog Peringatan & Konfirmasi Pemulihan Database |
| **Gambar 9.1** | `fig_09_settings_screen.png` | Bab 9 (Pengaturan) | Layar Menu Pengaturan Sistem Aplikasi |
| **Gambar 9.2** | `fig_09_operator_management.png` | Bab 9 (Pengaturan) | Layar Manajemen dan Tambah Akun Operator Kasir |
| **Gambar 9.3** | `fig_09_printer_picker.png` | Bab 9 (Pengaturan) | Modal Pemindaian dan Penyambungan Printer Bluetooth |
| **Gambar 9.4** | `fig_09_theme_modes.png` | Bab 9 (Pengaturan) | Perbandingan Tampilan Mode Terang vs Mode Gelap |

---

*Buku panduan ini disusun untuk operasional harian SD IT Baitul Akbar Parabek & SMP IT Darul Ilmi.*  
*Hak Cipta © 2026 Yayasan Darul Ilmi. Dilindungi Undang-Undang.*
