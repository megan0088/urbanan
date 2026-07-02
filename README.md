# Urbanan

Halo tim! Ini adalah project iOS kita yang dibangun bareng-bareng menggunakan SwiftUI. README ini dibuat biar semua orang bisa langsung paham cara kerja project ini tanpa harus tanya-tanya dulu.

Kalau ada yang bingung, langsung tanya di grup ya — tidak ada pertanyaan yang bodoh!

---

## Apa yang Kita Pakai?

- **Bahasa**: Swift
- **UI**: SwiftUI
- **Arsitektur**: MVVM (dijelaskan di bawah)
- **Minimum iOS**: 17+

---

## Struktur Folder

Kita pakai pola **MVVM** — ini cara kita memisahkan kode biar tidak campur aduk:

```
urbanan/
├── urbananApp.swift       # Pintu masuk aplikasi, jangan diubah sembarangan
├── Models/                # Tempat data — contoh: struktur User, Produk, dll
├── Views/                 # Tampilan yang dilihat pengguna
│   └── ContentView.swift
├── ViewModels/            # Logika di balik tampilan
│   └── ContentViewModel.swift
└── Assets.xcassets        # Gambar, ikon, warna
```

**Singkatnya:**
- Mau buat tampilan baru? Taruh di **Views/**
- Mau buat logika atau olah data? Taruh di **ViewModels/**
- Mau buat struktur data? Taruh di **Models/**

---

## Cara Pertama Kali Setup (Wajib Dibaca!)

### Langkah 1 — Clone project

Buka Terminal, lalu ketik:

```bash
git clone https://github.com/megan0088/urbanan.git
```

### Langkah 2 — Buka di Xcode

```bash
cd urbanan
open urbanan.xcodeproj
```

### Langkah 3 — Jalankan aplikasi

Di Xcode, pilih simulator (contoh: iPhone 16), lalu tekan `Cmd + R`.

---

## Setup Sekali Seumur Hidup (Wajib!)

Ini untuk mencegah file sampah dari Mac kamu (`.DS_Store`) masuk ke repo dan ganggu teman tim. Cukup **satu kali** di laptop kamu:

```bash
echo ".DS_Store" >> ~/.gitignore_global
echo "**/.DS_Store" >> ~/.gitignore_global
echo "xcuserdata/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

Kalau sudah, kamu tidak perlu lakukan ini lagi untuk selamanya.

---

## Cara Kerja Sehari-hari dengan Git

Ini alur yang harus diikuti setiap kali mau mengerjakan sesuatu:

### 1. Sebelum mulai kerja — selalu pull dulu

```bash
git pull origin main
```

Ini untuk mengambil perubahan terbaru dari teman tim. **Jangan skip langkah ini** atau nanti kode kamu ketinggalan zaman.

### 2. Buat branch baru untuk fitur kamu

```bash
git checkout -b feature/nama-fitur
```

Contoh: `feature/halaman-login`, `feature/tombol-checkout`

Branch itu seperti "ruang kerja pribadi" kamu — perubahan di sini tidak akan ganggu pekerjaan orang lain.

### 3. Kerjakan fiturnya, lalu simpan perubahan

```bash
git add NamaFile.swift          # pilih file yang sudah diubah
git commit -m "feat: tambah halaman login"
```

### 4. Kirim ke GitHub

```bash
git push origin feature/nama-fitur
```

### 5. Buat Pull Request di GitHub

Buka GitHub, klik **"Compare & pull request"**, minta salah satu anggota tim untuk review sebelum di-merge ke `main`.

---

## Format Pesan Commit

Supaya history git kita rapi dan mudah dibaca:

| Contoh | Kapan dipakai |
|--------|---------------|
| `feat: tambah halaman profil` | Fitur baru |
| `fix: perbaiki tombol tidak bisa diklik` | Bug fix |
| `style: ubah warna tombol jadi biru` | Perubahan tampilan |
| `docs: update README` | Update dokumentasi |
| `chore: update gitignore` | Hal teknis, bukan fitur |

---

## Menghindari Konflik (Baca Ini Baik-baik!)

Konflik terjadi ketika dua orang mengubah file yang sama di waktu yang sama. Ini wajar, tapi bisa dicegah.

### .DS_Store
File ini dibuat otomatis oleh Mac dan **tidak ada hubungannya dengan kode**. Sudah di-ignore di repo ini, tapi pastikan kamu sudah menjalankan setup di atas.

### `project.pbxproj` — File yang paling sering konflik

File ini adalah "daftar isi" project Xcode — setiap kali kamu menambah atau menghapus file Swift, file ini ikut berubah.

**Cara menghindarinya:**

- Selalu `git pull` sebelum mulai kerja
- Satu orang mengerjakan satu fitur di satu waktu
- Kabari teman di grup kalau mau menambah banyak file baru
- Merge ke `main` bergantian, jangan bersamaan

**Kalau sudah terlanjur konflik:**

Jangan panik! Jangan klik "Accept Ours" atau "Accept Theirs" begitu saja — nanti ada file yang hilang dari project.

1. Buka file `project.pbxproj` di text editor
2. Cari tanda `<<<<<<<`, `=======`, `>>>>>>>`
3. Gabungkan kedua bagian secara manual
4. Pastikan tidak ada baris yang terhapus
5. Setelah beres:

```bash
git add urbanan.xcodeproj/project.pbxproj
git commit -m "fix: resolve pbxproj conflict"
```

Kalau bingung, **minta tolong ke teman tim** — lebih baik tanya daripada salah resolve.

---

## Kontributor

| Nama | GitHub |
|------|--------|
| Muhamad Ega Nugraha | [@megan0088](https://github.com/megan0088) |

---

> Kalau kamu baru join tim, tambahkan nama kamu di tabel di atas ya!
