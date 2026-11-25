# Panduan Build Final (Windows & Web HTML5), Integrasi Aset & Deploy

Dokumen ini memandu proses ekspor game **Jejak Sang Ratu: Kejayaan Jepara** ke platform **Windows Desktop (`.exe`)** dan **Web (HTML5 single-thread)** menggunakan `export_presets.cfg` yang sudah dikonfigurasi.

---

## 1. Prasyarat Export Templates di Godot 4.7.2
1. Buka Godot Engine `4.7.2-stable` → buka `project.godot`.
2. Klik menu **Editor → Manage Export Templates…** → klik **Download and Install** untuk versi `4.7.2.stable`.
3. Pastikan di `Project → Export…` sudah tampil 2 preset dari `export_presets.cfg`:
   - **Windows Desktop** → output: `builds/windows/JejakSangRatu.exe` (`embed_pck = true`, sehingga hanya 1 file `.exe` siap demo offline!).
   - **Web** → output: `builds/web/index.html` (`variant/thread_support = false` / single-thread agar bebas error COOP/COEP di GitHub Pages & itch.io!).

> **Penting:** Kedua preset sudah menyertakan `include_filter="Data/*.json,Data/**/*.json"` agar seluruh file JSON naskah, arsip, dan soal otomatis masuk ke dalam build, sementara folder `Tests/*` dan `docs/*` dikecualikan agar ukuran build tetap ramping.

---

## 2. Checklist Integrasi Aset Final (Dari Diva Anggi)
1. Letakkan file PNG/OGG dari Anggi pada path persis sesuai `docs/01_handoff_spec_json_and_assets.md`.
2. **Panduan Kompresi Ukuran Web (< 40 MB):**
   - Background (`1280x720`): kompres PNG/WebP ≤ 500 KB per gambar.
   - Potret tokoh (`256x256`) & Sprite (`128x128`): PNG transparan ≤ 150 KB.
   - Musik BGM: format **OGG Vorbis** bitrate `96–128 kbps`, mono/stereo ringan ≤ 1.5 MB per trek, aktifkan **Loop** di tab *Import* Godot.
   - SFX pendek: OGG/WAV ≤ 80 KB.
3. Jalankan `python Tests/validate_data.py` dan uji langsung di Godot (`F5`).

---

## 3. Langkah Export Windows Desktop (`.exe`)
- Via Godot Editor: **Project → Export… → pilih "Windows Desktop" → Export Project… → simpan ke `builds/windows/JejakSangRatu.exe`**.
- Atau via PowerShell CLI (jika Export Templates sudah terpasang):
  ```powershell
  New-Item -ItemType Directory -Force builds\windows | Out-Null
  & "D:\Game Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --export-release "Windows Desktop" builds/windows/JejakSangRatu.exe
  ```

---

## 4. Langkah Export Web (HTML5) & Deploy untuk Akses Dosen
- Via Godot Editor: **Project → Export… → pilih "Web" → Export Project… → simpan ke `builds/web/index.html`**.
- **Uji Lokal di Browser:** Jangan buka `index.html` dengan double-click `file://`. Jalankan server lokal singkat:
  ```powershell
  python -m http.server 8080 --directory builds/web
  ```
  Lalu buka `http://localhost:8080` di Chrome/Edge. Pastikan klik di Splash Screen mengaktifkan audio dan progres tersimpan setelah refresh (`F5`).
- **Deploy ke itch.io (Rekomendasi Tercepat untuk Dosen):**
  1. Kompres seluruh isi folder `builds/web/` menjadi `jejak_sang_ratu_web.zip` (pastikan `index.html` di root zip).
  2. Buat proyek baru di [itch.io](https://itch.io) → *Kind of project: HTML* → upload zip → centang *"This file will be played in the browser"* → resolusi `1280 x 720`.
- **Alternatif Deploy ke GitHub Pages:**
  - Push isi `builds/web/` ke branch `gh-pages`, lalu aktifkan **Settings → Pages → Deploy from branch `gh-pages`**.
