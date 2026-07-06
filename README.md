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

### Langkah 1 — Clone project & ambil semua branch

```bash
git clone https://github.com/megan0088/urbanan.git
cd urbanan
git fetch --all
```

`git fetch --all` mengambil semua branch yang ada di GitHub (`dev`, `feature/...`, dst) supaya kamu bisa lihat dan pindah ke branch mana pun secara lokal. Cek daftarnya dengan `git branch -a`.

### Langkah 2 — Pindah ke branch `dev` (BUKAN `main`!)

**Penting banget:** branch `main` di repo ini sudah lama tidak di-update — semua kerjaan aktif ada di branch **`dev`**. Kalau kamu clone lalu langsung buka Xcode tanpa pindah branch dulu, kamu akan buka kode yang sudah ketinggalan jauh (`main` bahkan belum punya struktur `TaggoMain`/`TaggoClip` yang terbaru).

```bash
git checkout dev
```

`dev` ini yang jadi dasar kerja kamu sehari-hari — setiap branch fitur baru dibuat dari `dev`, dan Pull Request juga diarahkan balik ke `dev`, bukan ke `main` (detail alurnya ada di bagian "Cara Kerja Sehari-hari dengan Git" di bawah).

### Langkah 3 — Setup signing kamu sendiri (WAJIB, sebelum buka Xcode)

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

**Supaya bisa build target `TaggoClip` dan fitur yang pakai iCloud/CloudKit sungguhan**, kamu perlu diundang jadi member di Apple Developer Program yang sama dengan pemilik project (minta diundang di grup). Dua hal yang wajib dipastikan saat diundang — banyak yang kejebak di sini:
- Undangannya harus lewat **developer.apple.com/account** (bagian **People**), **bukan** cuma lewat App Store Connect "Users and Access". Dua sistem itu terlihat mirip tapi beda: undangan App Store Connect saja **tidak** memberi akses sertifikat/signing yang dibutuhkan Xcode.
- Kalau pemilik project pakai akun **Individual** (bukan Organization), dia mungkin tidak akan menemukan menu "People" itu sama sekali — itu memang keterbatasan akun Individual di Apple, bukan kesalahan setting. Kalau kalian kena kasus ini, lihat solusi "Pakai Bundle Identifier sendiri" di bagian "Soal Bundle Identifier & Capabilities" di bawah.

Kalau kamu **belum** diundang/belum jadi member: tetap bisa buka project dan build **TaggoMain** untuk kerja di logic/UI yang tidak butuh capability tersebut (banyak yang sudah pakai Mock, bukan CloudKit asli).

### Langkah 4 — Buka di Xcode

```bash
open urbanan.xcodeproj
```

### Langkah 5 — Jalankan aplikasi

Di pojok kiri atas Xcode, pastikan scheme yang dipilih **TaggoMain** (bukan TaggoClip/TaggoTests), pilih simulator, lalu tekan `Cmd + R`.

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

- Bundle identifier **default** project ini sama untuk semua orang: `com.urbananTaggo.app` (Main), `.Clip`, `.Tests`, `.UITests`. Kalau kamu sudah jadi member di Apple Developer Program yang sama (lihat Langkah 3), **tidak perlu ubah apa-apa** — pakai saja default-nya, jangan diedit langsung di Xcode/`project.pbxproj`.
- Capability seperti **iCloud/CloudKit, App Clip, dan Associated Domains** hanya bisa dipegang oleh **satu** Apple Developer Team — bundle identifier itu unik secara global di seluruh Apple, jadi tim/akun lain (walau sama-sama berbayar) tidak bisa ikut memegang identifier yang sama tanpa jadi member di team yang sama persis.
- **Kalau kamu tidak bisa/tidak diundang jadi member** (misal karena pemilik project pakai akun Individual yang tidak mendukung undang-mengundang di Developer Portal — lihat Langkah 3), kamu tetap bisa kerja mandiri pakai bundle identifier + iCloud container **milikmu sendiri**, tanpa perlu mengedit satu pun file yang ikut ter-push:
  1. Daftarkan App ID + iCloud Container kamu sendiri secara manual di [developer.apple.com/account](https://developer.apple.com/account) → Identifiers, di bawah akun Apple Developer Program kamu sendiri, dengan capability iCloud/App Clip/Push yang dibutuhkan sudah dicentang — lakukan ini **sebelum** buka Xcode/coba build.
  2. Di `Config.xcconfig` kamu (lihat Langkah 3), tambahkan baris:
     ```
     TAGGO_BUNDLE_ID_BASE = com.namakamu.taggo
     ```
  3. Semua target otomatis memakai identifier itu, dan entitlements (iCloud container, link App Clip ↔ App induk) otomatis ikut menyesuaikan sendiri — tidak perlu sentuh file `.entitlements` atau `project.pbxproj` sama sekali.
  - **Catatan penting:** dengan cara ini, iCloud container kamu jadi **terpisah** dari container tim yang lain — data yang kamu simpan lokal tidak akan muncul di build orang lain, dan sebaliknya. Ini solusi supaya kamu bisa tetap kerja & test mandiri, bukan untuk lihat data yang sama dengan tim.
- Associated Domains masih **placeholder** (`applinks:TODO-REPLACE-DOMAIN.example`) karena domain aslinya belum ada — ini **bukan** sesuatu yang perlu diperbaiki sendiri, memang belum jadi prioritas di tahap ini.

---

## Error yang Sering Muncul (Baca Ini Duluan Sebelum Panik!)

### "No Account for Team 'XXXXXXXXXX'" / "No profiles for '...' were found"

**Penyebab:** kamu belum bikin `Config.xcconfig`, atau isinya masih Team ID orang lain.

**Solusi:** ikuti **Langkah 3** di atas — copy `Config.xcconfig.example` → `Config.xcconfig`, isi Team ID **kamu sendiri**.

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

### "Multiple commands produce '...XXX.stringsdata'" (atau nama file lain yang sama)

**Penyebab:** beda dari error di atas — ini karena ada satu file Swift yang sama persis ke-compile dua kali ke target yang sama, biasanya gara-gara folder biru (synchronized folder) yang keanggotaan targetnya tumpang tindih, atau ada file yang "dibagi" ke lebih dari satu target dengan cara yang salah.

**Solusi:** jangan asal ubah warna folder (biru/synchronized vs abu-abu/classic group) di Project Navigator kalau tidak yakin bedanya — khususnya folder `TaggoTests`, yang isinya harus terpisah presisi antara target `TaggoTests` dan `TaggoUITests`. Kalau ini muncul, tanya di grup dulu sebelum coba benerin sendiri lewat trial-and-error; beberapa kasus butuh edit `project.pbxproj` langsung yang berisiko kalau caranya salah.

### `DEVELOPMENT_TEAM` balik lagi ke akun orang lain padahal `Config.xcconfig` sudah benar

**Penyebab:** ada yang tanpa sadar memilih Team secara manual di dropdown tab **Signing & Capabilities** Xcode. Begitu itu terjadi, Xcode langsung menulis Team ID itu secara **literal** ke `project.pbxproj` — menimpa mekanisme `Config.xcconfig` untuk **semua orang** yang pull setelahnya, bukan cuma di laptop kamu.

**Solusi:**
1. Jangan pernah pilih Team secara manual di dropdown Signing & Capabilities. Kalau dropdown itu menunjukkan Team yang salah/basi, **jangan diklik untuk diganti** — justru itu penyebab masalahnya.
2. Kalau Team yang tampil di situ salah, perbaiki dengan cara lain: quit Xcode sepenuhnya → **Xcode → Settings → Accounts** → hapus lalu tambahkan ulang Apple ID kamu → buka Xcode lagi, supaya Xcode mengambil ulang daftar Team dari server Apple.
3. Sebelum commit perubahan apa pun yang menyentuh signing, cek dulu:
   ```bash
   grep DEVELOPMENT_TEAM urbanan.xcodeproj/project.pbxproj
   ```
   Kalau muncul baris dengan Team ID literal (bukan hasil kosong), itu tandanya kejadian di atas — hapus baris itu (jangan sampai ikut ter-commit) sebelum push.

### Sudah diundang jadi member tim, tapi Xcode tetap tidak menampilkan Team itu

**Penyebab paling umum:** diundang lewat App Store Connect "Users and Access", padahal yang dibutuhkan Xcode untuk signing adalah akses di level **Developer Portal** (developer.apple.com/account → People) — dua sistem itu beda walau namanya mirip (lihat juga Langkah 3 di atas).

**Solusi, coba urut dari atas:**
1. Pastikan kamu diundang lewat developer.apple.com/account, bukan cuma App Store Connect.
2. Cek role yang diberikan minimal **Developer**, **App Manager**, atau **Admin** — role seperti Marketing/Sales/Finance/Customer Support tidak memberi akses signing.
3. Setelah invite di-accept: **Xcode → Settings → Accounts** → hapus Apple ID kamu → quit Xcode sepenuhnya → buka lagi → tambahkan ulang Apple ID. Xcode sering menyimpan cache daftar Team lama dan tidak refresh otomatis.
4. Kalau pemilik project pakai akun **Individual** (bukan Organization), ini kemungkinan besar memang tidak bisa dilakukan sama sekali — akun Individual di Apple tidak mendukung undang-mengundang member Developer Portal. Kalau ini kasusnya, pakai solusi "Pakai Bundle Identifier sendiri" di bagian "Soal Bundle Identifier & Capabilities" di atas.

---

## Cara Kerja Sehari-hari dengan Git

Ini alur yang harus diikuti setiap kali mau mengerjakan sesuatu. **Branch dasar kita adalah `dev`, bukan `main`** — `main` sudah lama tidak dipakai aktif, jadi semua langkah di bawah ini selalu mengacu ke `dev`.

### 1. Sebelum mulai kerja — selalu pull dulu

```bash
git checkout dev
git pull origin dev
```

Ini untuk mengambil perubahan terbaru dari teman tim. **Jangan skip langkah ini** atau nanti kode kamu ketinggalan zaman.

### 2. Buat branch baru untuk fitur kamu (dari `dev`)

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

Buka GitHub, klik **"Compare & pull request"**, **pastikan base branch-nya `dev`** (bukan `main`), lalu minta salah satu anggota tim untuk review sebelum di-merge.

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
- Merge ke `dev` bergantian, jangan bersamaan
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
