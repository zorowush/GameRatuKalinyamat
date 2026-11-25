# Log Pengujian (6 Skenario Wajib) & Pelacakan Bug

Dokumen ini mencatat hasil pengujian otomatis (Python + Godot 4.7.2 Headless) serta checklist pengujian GUI manual 6 skenario wajib untuk **BAB IV (Pengujian dan Evaluasi)**.

---

## 1. Hasil Pengujian Otomatis (Fase 6 — Terverifikasi di Mesin Pengembangan)
1. **Validasi Data & Integritas Resource (`python Tests/validate_data.py`):**
   - **Hasil:** **407 checks PASSED, 0 errors.**
   - **Cakupan:** Validasi sintaks UTF-8 pada 14 file JSON, kelengkapan label sumber (`FAKTA`, `TRADISI`, `FIKSI GAME`) & sitasi referensi pada setiap baris dialog/arsip/bukti/soal, distribusi kunci jawaban Evaluasi 10 Soal, dan eksistensi seluruh path `res://` pada `project.godot`, `.tscn`, dan `.gd`.
2. **Godot 4.7.2 Headless Unit & Integration Suite (`Tests/TestRunner.tscn`):**
   - **Hasil:** **106 assertions PASSED, 0 FAILED** (Exit Code `0`).
   - **Cakupan:** Logika skor (`+30/+10/+5/0`) & anti-duplikasi, batas nilai lencana *De Kranige Dame* (`69%` gagal vs `70%` lulus), Save/Load JSON & ketahanan terhadap file save korup, pelacakan misi 3 level, fallback prosedural `AssetLoader`, `AudioManager` mute/playback, validasi `DialogueManager`, instansiasi & `SceneTree` check seluruh **18 scene**, serta pengujian interaksi langsung `ChronologyPuzzle`, `CommendaTradeGame`, dan `HeritageQuizGame`.

---

## 2. Tabel 6 Skenario Pengujian Minimal (Panduan Tugas)

| No | Skenario Uji | Langkah Pengujian | Hasil yang Diharapkan | Status Otomatis | Status Manual GUI (Editor/Web/Exe) |
| :-: | :--- | :--- | :--- | :---: | :---: |
| 1 | **Menu Utama** | Buka game (Splash → klik/Enter), uji tombol *Mulai/Lanjutkan*, *Pilih Level*, *Petunjuk*, *Tentang & Sumber*, *Reset Progres*. | Semua scene termuat tanpa error, tombol responsif, status progres akurat. | **PASS** (Scene instantiation + `GameManager.reset_progress` teruji) | *Perlu klik manual di Godot Editor / Browser oleh Anggi & Zuhri* |
| 2 | **Petunjuk** | Dari Menu Utama atau Pause Menu, buka layar *Petunjuk Bermain*. | Kontrol, aturan skor (`+30/+10/+5/0`), dan label `FAKTA`/`TRADISI`/`FIKSI GAME` tampil jelas. | **PASS** (`InstructionsScreen.tscn` & `GameplayHUD.tscn` termuat bersih) | *Perlu verifikasi keterbacaan visual manual* |
| 3 | **Gameplay** | Mainkan Level 1, 2, dan 3: gerakkan karakter (WASD & klik), interaksi NPC/Arsip (`E`/klik), selesaikan 6 tantangan & Galeri Warisan. | Karakter bergerak lancar, interaksi berjalan, semua mini-game dapat dituntaskan, unlock Level 1→2→3 bekerja. | **PASS** (Semua 18 scene, unlock level, & kontroler mini-game teruji) | *Perlu playtest manual penuh WASD/klik di Editor* |
| 4 | **Sistem Skor** | Cek skor awal (`0`), arsip (`+5`), tantangan/kuis benar (`+10`), salah (`0`), misi utama (`+30`), simpan & muat ulang. | Perhitungan akurat, tidak tergandakan pada item sama, tersimpan di `user://save_data.json`. | **PASS** (Teruji penuh unit & integrasi di `TestRunner.tscn`) | *Perlu cek ulang persistensi setelah refresh browser Web* |
| 5 | **Umpan Balik** | Sengaja memilih jawaban salah pada puzzle kronologi, investigasi, niaga, diplomasi, ekspedisi, dan kuis; lalu coba lagi hingga benar. | Jawaban salah memberi `0` poin + umpan balik korektif + opsi coba lagi; benar memberi `+10` + penjelasan. | **PASS** (Teruji pada Chronology, Commenda Trade & Quiz) | *Perlu uji visual tiap layar umpan balik oleh Tester* |
| 6 | **Akhir Permainan** | Selesaikan Level 3 hingga layar *Ending*. Uji kuis < 70% vs ≥ 70%. | Layar akhir tampilkan total skor, persentase kuis, epilog 2023, Lencana **De Kranige Dame** (khusus ≥ 70%), dan tombol *Main Lagi* / *Menu*. | **PASS** (Batas `69%` vs `70%` & `EndingScreen.tscn` teruji) | *Perlu verifikasi end-to-end hingga tombol Main Lagi* |

---

## 3. Daftar Pelacakan Bug (Bug Tracker)

| ID Bug | Tanggal | Pelapor | Level / Modul | Deskripsi Masalah | Tingkat | Status | Perbaikan (Commit) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **BUG-001** | 26 Nov 2026 | Zuhri (Headless Test) | `BaseLevelArena.gd` & `Level1Controller.gd` | Parse error pada Godot 4.7 headless: `class_name BaseLevelArena` belum terindeks sebelum editor dibuka & type inference `var locked :=` pada nilai `Variant` dari `hud.is_any_overlay_open()`. | Kritis | **Fixed** | Diperbaiki dengan path extends langsung (`extends "res://Scripts/Systems/BaseLevelArena.gd"`) dan explicit type `var locked: bool =` pada commit Fase 3 (`ccdf0e6`). |
| **BUG-002** | 26 Nov 2026 | Zuhri (Review) | `GameplayHUD.gd` | Struktur child `_make_modal_backdrop()` menaruh `ColorRect` sebagai child 0 sehingga pemanggilan `get_child(0)` sempat menargetkan dim backdrop bukan `CenterContainer`. | Kritis | **Fixed** | Diperbaiki dengan menamai node `"Center"` dan menambahkan modal card ke `get_node("Center")` pada commit Fase 2 (`455c6be`). |
| **BUG-003** | 26 Nov 2026 | Zuhri (Review) | `level3_heritage_quiz.json` | Pada draf awal, sebagian besar soal kuis memiliki `correct_index: 0` sehingga pola jawaban mudah ditebak. | Sedang | **Fixed** | Kunci jawaban didistribusikan merata pada indeks 0–3 dan ditambahkan aturan pengecekan distribusi kunci di `Tests/validate_data.py` pada Fase 5–6. |
