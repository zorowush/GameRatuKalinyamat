# Laporan Progres Mingguan — Minggu 1 (23–29 November 2026)

- **Proyek:** Jejak Sang Ratu: Kejayaan Jepara
- **Pelapor:** Ahmad Zuhri Fahrudin (Game Programmer & Developer)
- **Fase:** Fase 1 — Setup Proyek, Repositori Git, Dokumentasi & Kontrak Tim (`M1`)

## 1. Pencapaian Minggu Ini
1. **Setup Proyek Godot 4:** Konfigurasi `project.godot` (Godot 4.7.2, GL Compatibility, resolusi `1280x720`, stretch `canvas_items`, serta 8 Input Action: `move_up`, `move_down`, `move_left`, `move_right`, `interact`, `pause`, `confirm`, `cancel`).
2. **Kebersihan Struktur Folder & Repositori Git:**
   - Memindahkan utilitas `setup_input_map.gd` ke `Scripts/Tools/setup_input_map.gd` agar direktori root bersih.
   - Memperbarui `.gitignore` untuk mengabaikan `.godot/`, hasil build biner, dan file sementara OS.
   - Menambahkan `.gitkeep` pada folder aset/resource kosong agar struktur `Assets/`, `Data/`, `Scenes/`, `Scripts/`, `Tests/` tersimpan konsisten di Git.
   - Menginisialisasi repositori Git lokal (branch `main`) dan menghubungkan remote `origin` ke `https://github.com/zorowush/GameRatuKalinyamat.git`.
3. **Dokumentasi & Kontrak Kolaborasi Tim:**
   - Membuat `README.md` proyek.
   - Menyusun `docs/00_project_charter_and_scope.md` (penyelarasan ruang lingkup 3 level, aturan skor, dan pemisahan label `FAKTA`/`TRADISI`/`FIKSI GAME`).
   - Menyusun `docs/01_handoff_spec_json_and_assets.md` (kontrak JSON untuk Chika dan daftar target aset palet Relief Mantingan untuk Anggi).
   - Menyiapkan `docs/02_asset_and_ai_credits.md` dan `docs/03_testing_and_bug_log.md`.

## 2. Kendala & Solusi
- **Kendala:** Aset final dari UI/Asset Creator dan naskah final dari Game Designer baru akan siap bertahap di Minggu 2–4.
- **Solusi:** Diterapkan arsitektur *Playable-First* (data terpisah di `Data/*.json` dan pemuat aset otomatis `AssetLoader` dengan fallback palet Relief Mantingan) agar pemrograman tidak terhambat.

## 3. Rencana Minggu Depan (Minggu 2 — Fase 2 & Fase 3)
- Membangun 6 Autoload Inti (`AssetLoader`, `GameManager`, `AudioManager`, `MissionManager`, `DialogueManager`, `SceneManager`).
- Membangun seluruh UI wajib (Splash, Main Menu, Petunjuk, Tentang & Sumber, Pilih Level, Gameplay HUD, Pause Menu).
- Mengimplementasikan penuh **Level 1 (Putri dari Demak)**: eksplorasi 2D, 3 arsip sejarah, Puzzle Kronologi Konflik Demak, dan Investigasi *Tapa Wuda* (simbolis).

## 4. Bukti Kontribusi Individu (Programmer)
- Commit Fase 1 (`M1`) pada repositori Git `main`.
- File dokumentasi & struktur proyek lengkap di root dan `docs/`.
