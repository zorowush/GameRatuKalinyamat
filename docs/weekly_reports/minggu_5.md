# Laporan Progres Mingguan — Minggu 5 (21–27 Desember 2026)

- **Proyek:** Jejak Sang Ratu: Kejayaan Jepara
- **Pelapor:** Ahmad Zuhri Fahrudin (Game Programmer & Developer)
- **Fase:** Fase 6 (Bagian 2) — Konfigurasi Build Web & Windows, Draf BAB III & Persiapan Presentasi UAS (`M5 Final`)

## 1. Pencapaian Minggu Ini
1. **Konfigurasi Export Presets Lintas Platform (`export_presets.cfg`):**
   - Preset 0: **Windows Desktop** (`builds/windows/JejakSangRatu.exe`, `embed_pck=true`).
   - Preset 1: **Web HTML5 single-thread** (`builds/web/index.html`, `variant/thread_support=false` agar kompatibel langsung di itch.io & GitHub Pages).
   - Kedua preset menyertakan filter `Data/*.json,Data/**/*.json` dan mengecualikan `Tests/*,docs/*`.
2. **Dokumentasi Final & Bahan Laporan UAS:**
   - Menyusun panduan build & deploy `docs/04_build_and_deploy_guide.md`.
   - Menyusun draf lengkap **BAB III porsi Programmer (3.1, 3.2, 3.5, 3.6, 3.7)** + **Lampiran 5** + Q&A teknis presentasi individu di `docs/05_draft_bab3_programmer.md`.
   - Melengkapi Formulir Bukti Kontribusi Individu (`docs/06_formulir_kontribusi_individu.md`) dan keterbukaan kredit aset & AI (`docs/02_asset_and_ai_credits.md`).
3. **Verifikasi Akhir Repositori Git:**
   - Seluruh 6 fase terekam dalam riwayat commit terstruktur pada branch `main` dengan remote terhubung ke `https://github.com/zorowush/GameRatuKalinyamat.git`, siap untuk `git push -u origin main`.

## 2. Checklist Akhir Sebelum Pengumpulan UAS
- [ ] Pasang aset final PNG/OGG dari Diva Anggi ke `Assets/` (bila sudah selesai) lalu jalankan ulang `python Tests/validate_data.py`.
- [ ] Jalankan playtest GUI manual 6 skenario wajib di Godot Editor bersama Anggi & Chika lalu lengkapi kolom Manual GUI di `docs/03_testing_and_bug_log.md`.
- [ ] Export build **Windows Desktop (`.exe`)** & **Web (HTML5)** dari Godot Editor (pastikan Export Templates 4.7.2 terpasang) dan upload build Web ke itch.io / GitHub Pages.
- [ ] Jalankan `git push -u origin main` ke GitHub.
