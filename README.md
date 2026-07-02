# Urbanan

Aplikasi iOS dibangun menggunakan SwiftUI dengan arsitektur MVVM.

---

## Teknologi

- **Platform**: iOS
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Arsitektur**: MVVM (Model - View - ViewModel)
- **Minimum iOS**: 17+

---

## Struktur Project

```
urbanan/
├── urbananApp.swift          # Entry point aplikasi
├── Models/                   # Data model & business logic
├── Views/                    # SwiftUI Views
│   └── ContentView.swift
├── ViewModels/               # State & logic untuk Views
│   └── ContentViewModel.swift
└── Assets.xcassets           # Gambar, warna, ikon
```

---

## Cara Menjalankan

1. Clone repo ini
   ```bash
   git clone https://github.com/megan0088/urbanan.git
   ```

2. Buka project di Xcode
   ```bash
   cd urbanan
   open urbanan.xcodeproj
   ```

3. Pilih simulator atau device, lalu tekan `Cmd + R`

---

## Alur Kerja Git

```bash
git pull origin main              # ambil perubahan terbaru sebelum mulai kerja
git checkout -b feature/nama      # buat branch baru untuk fitur
# ... kerjakan fitur ...
git add NamaFile.swift
git commit -m "feat: deskripsi"
git push origin feature/nama      # push ke branch, bukan langsung ke main
```

### Format Commit Message

| Prefix | Kegunaan |
|--------|----------|
| `feat:` | Fitur baru |
| `fix:` | Bug fix |
| `refactor:` | Refactor tanpa ubah fungsionalitas |
| `style:` | Perubahan UI/layout |
| `docs:` | Update dokumentasi |
| `chore:` | Konfigurasi, dependency, dll |

---

## Kontributor

| Nama | GitHub |
|------|--------|
| Muhamad Ega Nugraha | [@megan0088](https://github.com/megan0088) |

---

> Tambahkan nama anggota tim di tabel Kontributor saat bergabung ke repo.
