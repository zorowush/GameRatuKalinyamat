# Log Pengujian (6 Skenario Wajib) & Pelacakan Bug

Dokumen ini mencatat hasil pengujian otomatis (Python + Godot 4.7.2 Headless) serta checklist pengujian GUI manual 6 skenario wajib untuk **BAB IV (Pengujian dan Evaluasi)**.

---

## 1. Hasil Pengujian Otomatis (Fase 6 — Terverifikasi di Mesin Pengembangan)
1. **Validasi Data & Integritas Resource (`python Tests/validate_data.py`):**
   - **Hasil:** **407 checks PASSED, 0 errors.**
   - **Cakupan:** Validasi sintaks UTF-8 pada 14 file JSON, kelengkapan label sumber (`FAKTA`, `TRADISI`, `FIKSI GAME`) & sitasi referensi pada setiap baris dialog/arsip/bukti/soal, distribusi kunci jawaban Evaluasi 10 Soal, dan eksistensi seluruh path `res://` pada `project.godot`, `.tscn`, dan `.gd`.
2. **Godot 4.7.2 Headless Unit & Integration Suite (`Tests/TestRunner.tscn`):**
   - **Hasil:** **164 assertions PASSED, 0 FAILED, 0 ObjectDB leaks** (Exit Code `0`).
   - **Cakupan:** Verifikasi seluruh 12 binding InputMap (`WASD`/Panah/`E`/`ESC`/`Enter`) pada device-0, logika skor (`+30/+10/+5/0`) & anti-duplikasi, batas nilai lencana *De Kranige Dame* (`69%` gagal vs `70%` lulus) + retensi skor kuis terbaik, Save/Load JSON & ketahanan file korup, persistensi langkah misi tengah-level & reset otomatis `MissionManager`, fallback `AssetLoader`, `AudioManager`, `DialogueManager` (cabang pilihan & silent cancel), layering `ModalLayer` di atas `ChallengeLayer`, instansiasi **18 scene**, serta pengujian state machine langsung **seluruh 6 mini-game** (`ChronologyPuzzle`, `TapaInvestigation`, `CommendaTradeGame`, `DiplomacyGame`, `ExpeditionStrategyGame`, `HeritageQuizGame`).

---

## 2. Tabel 6 Skenario Pengujian Minimal (Panduan Tugas)

| No | Skenario Uji | Langkah Pengujian | Hasil yang Diharapkan | Status Otomatis | Status Manual GUI (Editor/Web/Exe) |
| :-: | :--- | :--- | :--- | :---: | :---: |
| 1 | **Menu Utama** | Buka game (Splash → klik/Enter), uji tombol *Mulai/Lanjutkan*, *Pilih Level*, *Petunjuk*, *Tentang & Sumber*, *Reset Progres*. | Semua scene termuat tanpa error, tombol responsif, status progres akurat. | **PASS** (Scene instantiation + `GameManager.reset_progress` teruji) | *Perlu klik manual di Godot Editor / Browser oleh Anggi & Zuhri* |
| 2 | **Petunjuk** | Dari Menu Utama atau Pause Menu, buka layar *Petunjuk Bermain*. | Kontrol, aturan skor (`+30/+10/+5/0`), dan label `FAKTA`/`TRADISI`/`FIKSI GAME` tampil jelas. | **PASS** (`InstructionsScreen.tscn` & `GameplayHUD.tscn` termuat bersih) | *Perlu verifikasi keterbacaan visual manual* |
| 3 | **Gameplay** | Mainkan Level 1, 2, dan 3: gerakkan karakter (WASD & klik), interaksi NPC/Arsip (`E`/klik), selesaikan 6 tantangan & Galeri Warisan. | Karakter bergerak lancar, interaksi berjalan, semua mini-game dapat dituntaskan, unlock Level 1→2→3 bekerja. | **PASS** (Semua 18 scene, unlock level, & kontroler mini-game teruji) | *Perlu playtest manual penuh WASD/klik di Editor* |
| 4 | **Sistem Skor** | Cek skor awal (`0`), arsip (`+5`), tantangan/kuis benar (`+10`), salah (`0`), misi utama (`+30`), simpan & muat ulang. | Perhitungan akurat, tidak tergandakan pada item sama, tersimpan di `user://save_data.json`. | **PASS** (Teruji penuh unit & integrasi di `TestRunner.tscn`) | *Perlu cek ulang persistensi setelah refresh browser Web* |
| 5 | **Umpan Balik** | Sengaja memilih jawaban salah pada puzzle kronologi, investigasi, niaga, diplomasi, ekspedisi, dan kuis; lalu coba lagi hingga benar. | Jawaban salah memberi `0` poin + umpan balik korektif + opsi coba lagi; benar memberi `+10` + penjelasan. | **PASS** (Teruji penuh pada seluruh 6 mini-game di `TestRunner.tscn`) | *Perlu uji visual tiap layar umpan balik oleh Tester* |
| 6 | **Akhir Permainan** | Selesaikan Level 3 hingga layar *Ending*. Uji kuis < 70% vs ≥ 70%. | Layar akhir tampilkan total skor, persentase kuis, epilog 2023, Lencana **De Kranige Dame** (khusus ≥ 70%), dan tombol *Main Lagi* / *Menu*. | **PASS** (Batas `69%` vs `70%` & `EndingScreen.tscn` teruji) | *Perlu verifikasi end-to-end hingga tombol Main Lagi* |

---

## 3. Daftar Pelacakan Bug (Bug Tracker)

| ID Bug | Tanggal | Pelapor | Level / Modul | Deskripsi Masalah | Tingkat | Status | Perbaikan (Commit) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **BUG-001** | 26 Nov 2026 | Zuhri (Headless Test) | `BaseLevelArena.gd` & `Level1Controller.gd` | Parse error pada Godot 4.7 headless: `class_name BaseLevelArena` belum terindeks sebelum editor dibuka & type inference `var locked :=` pada nilai `Variant` dari `hud.is_any_overlay_open()`. | Kritis | **Fixed** | Diperbaiki dengan path extends langsung (`extends "res://Scripts/Systems/BaseLevelArena.gd"`) dan explicit type `var locked: bool =` pada commit Fase 3 (`ccdf0e6`). |
| **BUG-002** | 26 Nov 2026 | Zuhri (Review) | `GameplayHUD.gd` | Struktur child `_make_modal_backdrop()` menaruh `ColorRect` sebagai child 0 sehingga pemanggilan `get_child(0)` sempat menargetkan dim backdrop bukan `CenterContainer`. | Kritis | **Fixed** | Diperbaiki dengan menamai node `"Center"` dan menambahkan modal card ke `get_node("Center")` pada commit Fase 2 (`455c6be`). |
| **BUG-003** | 26 Nov 2026 | Zuhri (Review) | `level3_heritage_quiz.json` | Pada draf awal, sebagian besar soal kuis memiliki `correct_index: 0` sehingga pola jawaban mudah ditebak. | Sedang | **Fixed** | Kunci jawaban didistribusikan merata pada indeks 0–3 dan ditambahkan aturan pengecekan distribusi kunci di `Tests/validate_data.py` pada Fase 5–6. |
| **BUG-004** | 26 Nov 2026 | Zuhri (Audit) | `project.godot` & `setup_input_map.gd` | Seluruh 12 event InputMap tersimpan dengan `"device":16`, sehingga keyboard standar (`device = 0`) gagal mencocokkan aksi `WASD`/Panah/`E`/`ESC`/`Enter`. | Kritis | **Fixed** | Diubah menjadi `"device":-1` (`ALL_DEVICES`) di `project.godot` & `setup_input_map.gd`, serta ditambahkan 24 assertion InputMap di `Tests/run_godot_tests.gd`. |
| **BUG-005** | 26 Nov 2026 | Zuhri (Audit) | `GameplayHUD.gd` & `BaseLevelArena.gd` | Menekan `ESC` saat mini-game (`layer 45`) aktif membuka Pause Menu di `layer 30` (tersembunyi di belakang mini-game) sambil menjeda `SceneTree` (soft-lock). | Kritis | **Fixed** | Memindahkan seluruh modal HUD (Pause, Arsip, Petunjuk) ke `ModalLayer` (`layer = 70`) di atas Challenge & Dialogue, serta menambahkan guard `is_interaction_locked()` dan pencegahan input dialog saat paused. |
| **BUG-006** | 26 Nov 2026 | Zuhri (Audit) | `GameManager.gd`, `MissionManager.gd`, `DialogueManager.gd` | Langkah misi tengah-level tidak tersimpan ke `save_data.json` & tidak ikut ter-reset otomatis saat `GameManager.reset_progress()`, serta `SceneManager` memicu `dialogue_finished` saat membatalkan dialog. | Tinggi | **Fixed** | Menyimpan `completed_mission_steps` di `GameManager`, menyambungkan sinyal `progress_reset`, menambahkan `close_dialogue(false)` untuk pembatalan senyap, dan menjaga skor kuis terbaik (high-water mark). |
| **BUG-007** | 26 Nov 2026 | Zuhri (Audit) | `AudioManager.gd` & `Tests/run_godot_tests.gd` | 21 instance `AudioStreamWAV`/`AudioStreamPlaybackWAV` bocor saat keluar (ObjectDB leak) dan cleanup test sempat menghapus `user://save_data.json` asli. | Sedang | **Fixed** | Menambahkan pembersihan stream di `AudioManager._exit_tree()` + guard driver `Dummy` (hasil: **0 ObjectDB leaks**) serta isolasi total `save_path_override` pada test runner. |
| **BUG-008** | 26 Nov 2026 | Zuhri (Audit) | 6 Mini-Game, `PlayerController.gd`, `BaseLevelArena.gd`, `docs/01` | Teks replay masih menulis `(+10 Poin)` saat skor 0, beberapa label/checkbox kurang autowrap, sprite/BG belum auto-scale terhadap aset Anggi, dan kunci dialog Level 1 di dokumen handoff berbeda. | Sedang | **Fixed** | Memperbaiki pesan poin replay dinamis, autowrap, `remove_child` sebelum `queue_free`, auto-scaling sprite/BG, menampilkan `portrait_utusan.png` di `DiplomacyGame`, dan menyelaraskan `docs/01_handoff_spec_json_and_assets.md`. |
