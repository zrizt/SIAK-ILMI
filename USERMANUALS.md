# BUKU PANDUAN PENGGUNA (USER MANUAL)
# SIAK-ILMI: Sistem Informasi Administrasi & Keuangan Darul Ilmi

> **Versi Dokumen:** 1.0.0  
> **Target Aplikasi:** SIAK-ILMI Android (Smartphone & Tablet)  
> **Lembaga Naungan:**  
> 1. **SD IT Baitul Akbar Parabek** (Jenjang SD Kelas 1–6)  
> 2. **SMP IT Darul Ilmi** (Jenjang SMP Kelas 7–9)  
> **Arsitektur:** Offline-First (SQLite Drift) & Cloud Backup (Supabase Storage)

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
   - [8.2 Cadangan Cloud Supabase (Tanpa Login Akun)](#82-cadangan-cloud-supabase-tanpa-login-akun)
   - [8.3 Pemulihan Database Aman (Safe Restore & Rollback)](#83-pemulihan-database-aman-safe-restore--rollback)
9. [Pengaturan Sistem & Pemeliharaan](#9-pengaturan-sistem--pemeliharaan)
10. [Panduan Pemecahan Masalah (Troubleshooting & FAQ)](#10-panduan-pemecahan-masalah-troubleshooting--faq)

---

## 1. INFORMASI UMUM & KREDENSIAL AWAL

SIAK-ILMI dirancang khusus untuk mempermudah tata kelola keuangan santri/siswa di lingkungan Darul Ilmi. Sistem ini bekerja secara **100% Offline-First**, artinya kasir tetap dapat memproses pembayaran, mencetak struk, dan mengelola tagihan tanpa koneksi internet sama sekali.

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

### 2.2 Login Operator Petugas Kasir (Pencatatan Nama di Kuitansi)
Agar setiap kuitansi dan struk pembayaran memuat nama kasir yang bertugas:
1. Masuk ke tab **Pengaturan** (ikon gerigi di bilah navigasi bawah).
2. Pada bagian **Akun Operator**, tekan tombol **Login**.
3. Masukkan Username: `admin` dan Password: `admin123`.
4. Tekan **Masuk**. Nama operator akan otomatis dicantumkan di bawah tanda tangan kuitansi.

### 2.3 Mengubah PIN Keamanan
1. Buka tab **Pengaturan** > bagian **Keamanan PIN**.
2. Pilih **Ganti PIN Admin** atau **Ganti PIN Viewer**.
3. Masukkan PIN lama, lalu masukkan PIN baru (6 digit angka) dan ulangi untuk konfirmasi.
4. Tekan **Simpan**.

---

## 3. BERANDA & RINGKASAN KEUANGAN (DASHBOARD)

Layar Beranda menyajikan ringkasan keuangan dan operasional secara *real-time*:

```
+-------------------------------------------------------------+
| SIAK-ILMI              [Filter: Semua Lembaga v]   [Keluar] |
+-------------------------------------------------------------+
|  [ Pemasukan Hari Ini ]         [ Pemasukan Bulan Ini ]     |
|    Rp 1.450.000                   Rp 24.800.000             |
|                                                             |
|  [ Siswa Aktif ]                [ Total Tunggakan Berjalan] |
|    86 Siswa                       Rp 8.750.000              |
+-------------------------------------------------------------+
|  Aksi Cepat:                                                |
|  [ Kasir POS ]  [ + Siswa ]  [ Buat Tagihan ]  [ Backup ]   |
+-------------------------------------------------------------+
```

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

---

### 4.4 Tarif Khusus Siswa (Beasiswa / Keringanan)
Jika ada siswa yang mendapatkan beasiswa yatim, potongan saudara kandung, atau keringanan biaya:
1. Buka profil detail siswa yang bersangkutan.
2. Tekan menu **Tarif Khusus (Custom Rate)**.
3. Pilih jenis biaya yang ingin disesuaikan (misal: SPP Bulanan).
4. Masukkan nominal khusus (misal: dari normal Rp 150.000 menjadi Rp 75.000 atau Rp 0).
5. Masukkan catatan/alasan (misal: *"Beasiswa Anak Yatim Yayasan"*).
6. Tekan **Simpan Tarif Khusus**. Tagihan siswa ini ke depannya akan selalu mengikuti nominal khusus tersebut.

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

---

## 5. MANAJEMEN BIAYA & PEMBUATAN TAGIHAN

### 5.1 Master Tarif
Daftar tarif standar tersimpan di tab **Biaya & Tagihan**:
- **SPP Rutin Bulanan:** Rp 150.000 / bulan (SD & SMP).
- **Infaq Gedung:** Rp 400.000 (Satu kali saat masuk).
- **Pendaftaran PPDB:** Rp 100.000 (Satu kali saat mendaftar).

Admin dapat mengubah tarif master kapan saja melalui tombol ubah pada daftar kategori biaya.

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

### 6.2 Pembayaran Sebagian / Cicilan
Untuk tagihan berukuran besar seperti Infaq Gedung:
1. Centang item tagihan tersebut.
2. Aktifkan opsi **Bayar Sebagian (Cicilan)** di bawah item tersebut.
3. Ketikkan jumlah uang yang ingin disetor saat ini (misal: Rp 200.000 dari total Rp 400.000).
4. Sistem otomatis mencatat sisa tagihan Rp 200.000 untuk dibayarkan di masa mendatang.

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

### 7.1 Cetak Struk Thermal Bluetooth (ESC/POS)
1. Pastikan Bluetooth pada perangkat Android Anda dalam kondisi **Aktif**.
2. Hubungkan printer kasir Bluetooth (58mm atau 80mm):
   - Masuk ke **Pengaturan** > **Printer** > **Printer Bluetooth**.
   - Tekan **Pindai Perangkat**, lalu pilih printer Anda dari daftar untuk menghubungkan.
3. Pada saat selesai transaksi, tekan **Cetak Struk Thermal**. Struk kasir akan langsung keluar dari printer dalam hitungan detik.

### 7.2 Kuitansi Resmi PDF (Format A5 Resmi Yayasan)
1. Tekan tombol **Buka Kuitansi Resmi PDF** atau **Bagikan Kuitansi**.
2. Sistem otomatis menghasilkan dokumen PDF dengan spesifikasi:
   - **Kop Surat Yayasan:** Dilengkapi logo resmi `logo_yayasan.png` dan alamat sekolah.
   - **Rincian Pembayaran:** Memuat tabel alokasi per item tagihan secara transparan.
   - **Terbilang Otomatis:** Nilai rupiah diterjemahkan ke teks bahasa Indonesia (contoh: *"Lima Ratus Ribu Rupiah"*).
   - **Nama Kasir & Tanda Tangan:** Nama operator yang sedang login tercetak otomatis.
3. Dokumen PDF dapat langsung dicetak ke printer biasa (printer kantor via WiFi/OTG) atau dibagikan langsung ke nomor WhatsApp wali murid.

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

### 8.1 Cadangan Lokal (.ZIP)
1. Masuk ke menu **Pengaturan** > **Backup Data Sekarang**, atau buka **Riwayat Backup**.
2. Tekan tombol **Buat Backup**.
3. File `.zip` lengkap yang berisi database `siak_ilmi.db` dan `manifest.json` akan disimpan di folder:  
   📁 `Penyimpanan Internal/Download/SIAK-ILMI-Backup/`
4. File ini dapat disalin ke flashdisk (OTG), laptop, atau kartu memori.

### 8.2 Cadangan Cloud Supabase (Tanpa Login Akun)
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

---

## 9. PENGATURAN SISTEM & PEMELIHARAAN

Tab **Pengaturan** menyediakan kontrol administratif lengkap:

1. **Akun Operator Kasir:**
   - Tambah akun operator baru untuk staf TU lain.
   - Nonaktifkan akun operator yang sudah tidak bertugas.
2. **Koneksi Printer Bluetooth:**
   - Pengaturan printer default untuk kasir POS.
3. **Pilihan Tema:**
   - Mode Terang (Light Mode): Cocok untuk pemakaian siang hari di kantor TU.
   - Mode Gelap (Dark Mode): Nyaman untuk mata saat pencatatan malam hari.
   - Mengikuti Pengaturan Sistem Android.
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

*Buku panduan ini disusun untuk operasional harian SD IT Baitul Akbar Parabek & SMP IT Darul Ilmi.*  
*Hak Cipta © 2026 Yayasan Darul Ilmi. Dilindungi Undang-Undang.*
