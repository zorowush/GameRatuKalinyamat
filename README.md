# Jejak Sang Ratu: Kejayaan Jepara

Game edukasi sejarah 2D berbasis **Godot Engine 4 (GDScript)** yang mengangkat kisah perjuangan, kepemimpinan maritim, seni ukir, dan keteladanan **Ratu Kalinyamat** (Retna Kencana), penguasa Jepara abad ke-16 dan Pahlawan Nasional RI (ditetapkan 10 November 2023).

Proyek ini dikembangkan untuk memenuhi tugas PjBL **Mata Kuliah Game Programming** — Prodi Rekayasa Perangkat Lunak (Semester 5), Dosen Pengampu: **A. Faiq Abror** (Periode 23 November – 27 Desember 2026).

---

## Anggota Tim & Pembagian Tugas

| Nama | Peran | Tanggung Jawab Utama |
| :--- | :--- | :--- |
| **Chika Anggraini** | Game Designer & Project Manager | Konsep game, riset sejarah, GDD, storyboard, flowchart, naskah JSON (`Data/`), koordinasi tim, BAB I–II |
| **Ahmad Zuhri Fahrudin** | Game Programmer & Developer | Setup engine, arsitektur kode & autoload, gameplay 3 level, mini-game, sistem skor/save, pengujian otomatis, build Web & Windows, BAB III (3.1, 3.2, 3.5–3.7), Lampiran 5 & 7 |
| **Diva Anggi Wulan Maulida** | UI/UX Designer, Asset Creator & Tester | Desain UI/UX Figma, aset visual & audio (`Assets/`), pengujian manual 6 skenario & tabel bug, video demo, PPT, BAB III (3.3, 3.4, 3.8), BAB IV |

---

## Ringkasan Gameplay & Fitur Utama

- **Gaya Permainan:** Hybrid Eksplorasi 2D Ringan (`WASD`/Panah atau Klik arena, interaksi `E` atau Klik objek) + Dialog Historis + 6 Tantangan Edukatif + Evaluasi Akhir 10 Soal.
- **Transparansi Sumber Sejarah:** Setiap dialog, kartu bukti, dan catatan arsip diberi label jelas:
  - `FAKTA` — Fakta sejarah berbasis sumber multi-referensi.
  - `TRADISI` — Babad, cerita rakyat, atau tradisi lisan.
  - `FIKSI GAME` — Tokoh pembantu atau narasi pemandu permainan.
- **3 Level Utama:**
  1. **Level 1 — Putri dari Demak:** Konflik suksesi Demak (Puzzle Kronologi 5 peristiwa) & Investigasi "Sejarah atau Mitos?" (*Tapa Wuda* secara simbolis). Lencana: **Penyelidik Sejarah**.
  2. **Level 2 — Kejayaan Maritim Jepara:** Simulasi niaga *commenda* & 4 pelabuhan (6 giliran) + Simulasi Diplomasi Nusantara (Johor 1550, Hitu 1565, Aceh 1573). Lencana: **Ratu Bandar**.
  3. **Level 3 — Armada ke Malaka:** Strategi & Refleksi Objektif Ekspedisi Malaka 1551 & 1574 + Galeri Warisan (Masjid Mantingan 1559, Seni Ukir Jepara, Benteng Kalinyamat) + Evaluasi 10 Soal & Epilog. Lencana: **De Kranige Dame** (skor kuis ≥ 70%).
- **Sistem Skor:** Misi Utama selesai `+30` | Tantangan/Puzzle/Kuis benar `+10` | Temuan Arsip Sejarah `+5` | Jawaban salah `0` (disertai umpan balik korektif & opsi coba lagi).
- **Save & Load Otomatis:** Disimpan pada `user://save_data.json` (kompatibel Windows Desktop & Web IndexedDB).
- **Playable-First Asset Pipeline:** Seluruh visual/audio menggunakan palet tema **Relief Mantingan** (bata merah, krem, hijau-biru laut, emas, cokelat tua) secara otomatis, dan akan langsung memuat aset PNG/OGG asli begitu diletakkan di `Assets/`.

---

## Struktur Proyek

```text
game-ratu-kalinyamat/
├── Assets/              # Aset visual (PNG), audio (OGG/WAV), font (diisi UI/Asset Creator)
├── Data/                # Konten JSON terpisah dari kode (Dialogues, Historical_Data, Missions)
├── Resources/           # Resource Godot tambahan (tema/style)
├── Scenes/              # Scene Godot (.tscn): Main, UI, Characters, Interactables, Challenges, Levels
├── Scripts/             # Skrip GDScript: Autoload, Player, Systems, Missions, Puzzle, Strategy, UI, Tools
├── Tests/               # Validasi JSON otomatis (Python) & unit/scene test Godot headless
├── docs/                # Dokumentasi proyek, handoff Chika/Anggi, log bug, laporan mingguan, draft BAB III
├── project.godot        # Konfigurasi Godot 4 (1280x720, GL Compatibility, Input Map, Autoloads)
└── export_presets.cfg   # Preset export Windows Desktop (.exe) & Web (HTML5 single-thread)
```

---

## Cara Menjalankan & Menguji

1. **Membuka di Godot Engine 4 (4.7.2+ GL Compatibility):**
   - Buka Godot Engine → *Import* → pilih `project.godot` → jalankan (`F5`).
2. **Menjalankan Validasi Data Otomatis (Python 3):**
   ```powershell
   python Tests/validate_data.py
   ```
3. **Menjalankan Pengujian Headless Godot (Unit Logic + Verifikasi Semua Scene):**
   ```powershell
   & "D:\Game Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --script res://Tests/run_godot_tests.gd
   ```

---

## Daftar Referensi Sejarah Utama

- **S1:** Chusnul Hayati, *"Ratu Kalinyamat: Ratu Jepara yang Pemberani"* (UNDIP) & Hayati dkk. (2000), *"Peranan Ratu Kalinyamat di Jepara pada Abad XVI"*.
- **S2:** Bambang Sulistyanto (2019), *"Ratu Kalinyamat: Sejarah atau Mitos?"* (Puslit Arkenas).
- **S3:** Sri Wintala Achmad (2020), *"Melacak Gerakan Perlawanan dan Laku Spiritualitas Ratu Kalinyamat"* (Araska).
- **S4:** Ngatawi El-Zastrow (2020) FIN UNUSIA & Beni Jo (2023) Tirto.id (Penetapan Pahlawan Nasional RI 10 November 2023).
