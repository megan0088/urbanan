# Urbanan (Taggo)

Halo tim! Ini adalah project iOS kita yang dibangun bareng-bareng menggunakan SwiftUI. Nama aplikasinya sekarang **Taggo** (sebelumnya sempat disebut "TransitInsure" di draft awal) — tapi repo/folder project-nya tetap bernama `urbanan`, jadi jangan bingung kalau lihat folder `TaggoMain`, `TaggoClip`, dll di dalam repo `urbanan`.

README ini dibuat biar semua orang bisa langsung paham cara kerja project ini dan bisa langsung `Cmd + R` tanpa nyangkut di error signing/provisioning yang bikin pusing.

Kalau ada yang bingung, langsung tanya di grup ya — tidak ada pertanyaan yang bodoh!

> Dokumen arsitektur lengkap (`PROJECT_CONTEXT.md`) sengaja **tidak** ikut ter-push ke repo ini (ada di `.gitignore`, karena isinya masih berubah-ubah di tahap concept). Kalau butuh detail model data / roadmap fase, minta filenya langsung ke yang pegang.

---

## Apa yang Kita Pakai?

- **Bahasa**: Swift 6
- **UI**: SwiftUI, minimum **iOS 17+**
- **State management**: `@Observable` + `@State` saja — **jangan** pakai `ObservableObject` / `@Published` / Combine
- **Database**: CloudKit (Public Database) — cuma 2 record type: `Item` dan `FoundReport`
- **Arsitektur**: MVVM (View ↔ ViewModel) + UseCase (Domain) + Service protocol (Infrastructure), semua logic bersama ada di `SharedCore`

---

## Struktur Folder

Project ini punya **4 target Xcode**, ditambah satu folder kode bersama:

```
urbanan.xcodeproj

SharedCore/                 # dipakai bareng oleh TaggoMain + TaggoClip + TaggoTests
├── Data/                   # Models, Enums, Errors, Mappers, Schema
├── Domain/UseCases/        # satu file per use case (RegisterItem, ReportFoundItem, dst)
└── Infrastructure/         # CloudKitManager, QRManager, ScannerService, AppConfiguration

TaggoMain/                  # App utama (Owner: daftar barang, lihat Inbox, dst)
├── Infrastructure/         # NotificationManager, CurrentUserProvider, OwnedItemsStore
├── Presentation/           # ViewModels + Views (baseplate, bukan UI final)
├── App/TaggoMainApp.swift
└── TaggoMain.entitlements

TaggoClip/                  # App Clip (Finder yang belum install app, scan QR langsung lapor)
├── Infrastructure/DeepLink/
├── Presentation/
├── App/TaggoClipApp.swift
└── TaggoClip.entitlements

TaggoTests/
├── UnitTests/              # target: TaggoTests
└── UITests/                # target: TaggoUITests
```

**Singkatnya:**
- Logic yang dipakai bareng Main App & App Clip (Models, UseCases, Services) → **SharedCore/**
- Tampilan/ViewModel khusus App utama → **TaggoMain/Presentation/**
- Tampilan/ViewModel khusus App Clip → **TaggoClip/Presentation/**
- Test → **TaggoTests/**

---

## Cara Pertama Kali Setup (Wajib Dibaca!)

### Langkah 1 — Clone project

```bash
git clone https://github.com/megan0088/urbanan.git
cd urbanan
```

### Langkah 2 — Setup signing kamu sendiri (WAJIB, sebelum buka Xcode)

Setiap orang di tim ini pakai **akun Apple pribadi masing-masing** (bukan satu akun organisasi bersama), jadi Team ID **tidak** boleh ditulis langsung di file project yang di-push — tiap orang isi punya sendiri secara lokal.

```bash
cp Config.xcconfig.example Config.xcconfig
```

Buka `Config.xcconfig`, isi baris berikut dengan **Team ID kamu sendiri**:

```
DEVELOPMENT_TEAM = TEAM_ID_KAMU_DI_SINI
```

Cara cari Team ID kamu: buka Xcode → **Settings → Accounts** → pastikan Apple ID kamu sudah login → klik nama Team-nya, ID-nya muncul di situ.

`Config.xcconfig` sudah otomatis di-ignore oleh git, jadi aman — tidak akan ke-push dan tidak akan menimpa punya orang lain.

### Langkah 3 — Buka di Xcode

```bash
open urbanan.xcodeproj
```

### Langkah 4 — Jalankan aplikasi

Di pojok kiri atas Xcode, pastikan scheme yang dipilih **TaggoMain** (bukan TaggoClip/TaggoTests), pilih simulator (contoh: iPhone 16), lalu tekan `Cmd + R`.

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

## Soal Bundle Identifier & Capabilities (Baca Sebelum Ubah Apa-apa di Signing!)

- Bundle identifier project ini **sudah ditentukan dan sama untuk semua orang**: `com.urbananTaggo.app` (Main), `.Clip`, `.Tests`, `.UITests`. **Jangan diubah sendiri-sendiri** — beda dengan Team ID, identifier ini memang harus sama persis untuk semua orang karena dipakai bareng oleh iCloud Container dan relasi App Clip ↔ App induk.
- Yang **boleh dan wajib** beda per-orang cuma `DEVELOPMENT_TEAM` di `Config.xcconfig` kamu (lihat Langkah 2 di atas).
- Capability seperti **iCloud/CloudKit, App Clip, dan Associated Domains hanya bisa diregistrasi oleh akun Apple Developer Program berbayar** ($99/tahun), bukan akun personal gratisan. Kalau kamu belum punya akun berbayar (atau belum jadi member di Program milik salah satu tim), kamu tetap bisa:
  - Build & jalankan **TaggoMain** untuk kerja di UI/logic yang tidak butuh CloudKit sungguhan (banyak test pakai Mock, bukan CloudKit asli)
  - Tapi belum bisa build **TaggoClip** sampai diundang jadi member di Program yang sama, atau sampai kita punya solusi lain.
- Associated Domains masih **placeholder** (`applinks:TODO-REPLACE-DOMAIN.example`) karena domain aslinya belum ada — ini **bukan** sesuatu yang perlu diperbaiki sendiri, memang belum jadi prioritas di tahap ini.

---

## Error yang Sering Muncul (Baca Ini Duluan Sebelum Panik!)

### "No Account for Team 'XXXXXXXXXX'" / "No profiles for '...' were found"

**Penyebab:** kamu belum bikin `Config.xcconfig`, atau isinya masih Team ID orang lain.

**Solusi:** ikuti **Langkah 2** di atas — copy `Config.xcconfig.example` → `Config.xcconfig`, isi Team ID **kamu sendiri**.

### "Failed Registering Parent Bundle Identifier... cannot be registered... not available"

**Penyebab:** ada yang mencoba mengubah `PRODUCT_BUNDLE_IDENTIFIER` jadi string lain yang ternyata sudah dipakai akun Apple lain di seluruh dunia (bundle ID itu unik secara global, bukan cuma di tim kita).

**Solusi:** jangan ubah bundle identifier sendiri. Kalau memang harus ganti, diskusikan dulu di grup — ini mempengaruhi semua orang sekaligus (lihat bagian "Soal Bundle Identifier" di atas).

### "Automatic signing failed" / "Provisioning profile doesn't include capability X"

**Penyebab:** akun Apple kamu belum terdaftar sebagai member di Apple Developer Program yang sama dengan yang meregistrasi `com.urbananTaggo.app`, atau akun kamu masih pakai Personal Team gratisan (tidak bisa pegang iCloud/App Clip/Associated Domains).

**Solusi:** untuk sementara fokus kerja di **TaggoMain** yang tidak butuh capability tersebut, atau minta diundang jadi member di Program yang dipakai bersama.

### "Provisioning profile doesn't match the entitlements file's value for X entitlement"

**Penyebab:** Xcode punya provisioning profile lama yang belum sinkron dengan perubahan capability terbaru.

**Solusi, coba urut dari atas:**
1. Xcode → **Settings → Accounts** → pilih Team kamu → **Download Manual Profiles**
2. Di tab **Signing & Capabilities** target yang error, matikan lalu nyalakan lagi "Automatically manage signing"
3. **Product → Clean Build Folder** (`Shift + Cmd + K`), lalu build ulang
4. Kalau masih gagal, cek di [developer.apple.com/account](https://developer.apple.com/account) → Identifiers → pastikan capability & container yang dibutuhkan memang sudah dicentang di identifier yang error tersebut.

### "Multiple commands produce '.../XXX.app'"

**Penyebab:** ada target yang `PRODUCT_NAME`-nya kosong/salah (biasanya gara-gara ada yang oprek target baru manual di pbxproj tanpa isi nama produk).

**Solusi:** jangan bikin target baru manual lewat Xcode UI tanpa koordinasi — tanya dulu di grup kalau butuh target baru.

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

### `Config.xcconfig` — jangan pernah dipaksa commit
File ini memang gitignored. Kalau `git status` menunjukkan file ini sebagai perubahan, jangan di-`git add` — itu tandanya ada yang salah konfigurasi `.gitignore` di laptop kamu.

### `project.pbxproj` — File yang paling sering konflik

File ini adalah "daftar isi" project Xcode — setiap kali kamu menambah atau menghapus file Swift, atau menambah target baru, file ini ikut berubah.

**Cara menghindarinya:**

- Selalu `git pull` sebelum mulai kerja
- Satu orang mengerjakan satu fitur di satu waktu
- Kabari teman di grup kalau mau menambah banyak file baru atau target baru
- Merge ke `main` bergantian, jangan bersamaan
- Setelah membuka project di Xcode, cek `git status` — kalau `project.pbxproj` berubah padahal kamu cuma buka & langsung tutup, itu biasanya Xcode nulis ulang signing settings; jangan ikut ter-commit kalau bukan perubahan yang kamu maksud

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
