# Project Charter & Ruang Lingkup Final — Jejak Sang Ratu: Kejayaan Jepara

## 1. Identitas Proyek
- **Judul Game:** Jejak Sang Ratu: Kejayaan Jepara
- **Genre:** Game Edukasi Sejarah 2D (Hybrid Eksplorasi Ringan + Dialog + Mini-Game + Kuis)
- **Engine & Bahasa:** Godot Engine 4 (4.7.2 Stable, Renderer: GL Compatibility), GDScript
- **Resolusi & Stretch:** `1280x720`, Stretch Mode `canvas_items`
- **Target Platform:** Web (HTML5 single-thread untuk akses cepat dosen) dan Windows Desktop (`.exe` untuk demo offline)
- **Repositori GitHub:** `https://github.com/zorowush/GameRatuKalinyamat.git` (branch `main`)
- **Durasi PjBL:** 5 Minggu (23 November – 27 Desember 2026)

## 2. Ruang Lingkup Final (Penyelarasan Dokumen & Keputusan Tim)
1. **Struktur 3 Level Playable:**
   - **Level 1 — Putri dari Demak:** Arena Keraton Demak & Bukit Danaraja (simbolis), 3 arsip sejarah, Tantangan 1A (Puzzle Kronologi Konflik Demak — 5 peristiwa), Tantangan 1B (Investigasi "Sejarah atau Mitos?" *Tapa Wuda* — 4 kartu bukti). Lencana: **Penyelidik Sejarah**.
   - **Level 2 — Kejayaan Maritim Jepara:** Arena Pelabuhan & Bandar Niaga Jepara, 3 arsip maritim/budaya, Tantangan 2A (Simulasi Niaga *Commenda* — 6 giliran), Tantangan 2B (Simulasi Diplomasi Nusantara: Johor 1550, Hitu 1565, Aceh 1573). Lencana: **Ratu Bandar**.
   - **Level 3 — Armada ke Malaka:** Arena Pangkalan Armada Laut Jepara, 3 arsip ekspedisi & pahlawan nasional, Tantangan 3A (Strategi & Refleksi Objektif Ekspedisi Malaka 1551 & 1574), Tantangan 3B (Galeri Warisan: Masjid Mantingan 1559, Seni Ukir Jepara, Benteng Kalinyamat + Evaluasi 10 Soal), serta Layar Ending & Epilog. Lencana: **De Kranige Dame** (skor kuis ≥ 70%).
2. **Aturan Edukasi & Sensitivitas Sejarah:**
   - Pemisahan tegas label sumber: `FAKTA`, `TRADISI`, dan `FIKSI GAME` pada setiap dialog, arsip, dan kartu bukti.
   - Adegan *tapa wuda asinjang rikma* ditampilkan secara **simbolis** (siluet/kabut, tanpa unsur ketelanjangan) dan dibingkai sebagai diskusi kritis lintas sumber.
   - Perbedaan versi sejarah (tahun naik tahta 1549/1550, asal-usul Pangeran Hadiri, jumlah pasukan ekspedisi 1551) disajikan secara transparan sebagai dinamika sumber sejarah.
   - Hasil Ekspedisi Malaka 1551 & 1574 **tidak diubah menjadi kemenangan fiktif**; pemain dinilai pada pemahaman strategi dan refleksi objektif faktor kegagalan militer.
3. **Aturan Skor & Progres:**
   - Misi Utama selesai: `+30`
   - Tantangan / Puzzle / Kuis benar: `+10`
   - Temuan Arsip / Informasi Sejarah: `+5`
   - Jawaban salah: `0` (wajib menampilkan umpan balik korektif + opsi coba lagi)
   - Penyimpanan progres otomatis di `user://save_data.json`.
4. **Strategi Playable-First:**
   - Programmer menyediakan naskah awal JSON di `Data/` berdasarkan 4 referensi utama agar game bisa dimainkan dari awal, sementara Chika dapat menyunting/memperkaya JSON kapan saja tanpa menyentuh kode.
   - Programmer menyediakan visual placeholder rapi bernuansa palet **Relief Mantingan** (`#9E3B2B` bata merah, `#F5EAD6` krem, `#1E6B7B` hijau-biru laut, `#D4A24C` emas aksen, `#3B2418` cokelat tua) dan SFX sintetis cadangan; sistem `AssetLoader` otomatis beralih ke aset PNG/OGG Anggi saat file diletakkan di `Assets/`.

## 3. Jadwal Milestone 5 Minggu
| Minggu | Periode | Fase | Target Milestone |
| :--- | :--- | :--- | :--- |
| Minggu 1 | 23–29 Nov 2026 | Fase 1 | **M1:** Repo GitHub, struktur proyek, dokumentasi kontrak tim, laporan Minggu 1 |
| Minggu 2 | 30 Nov–6 Des 2026 | Fase 2 & 3 | **M2:** Core Systems, UI lengkap, Prototype Playable Level 1 |
| Minggu 3 | 7–13 Des 2026 | Fase 4 & 5 | **M3 (Alpha):** Level 2, Level 3, Galeri Warisan, Kuis 10 Soal & Ending |
| Minggu 4 | 14–20 Des 2026 | Fase 6 (Bag. 1) | **M4 (Beta):** Integrasi aset, validasi otomatis, pengujian 6 skenario & perbaikan bug |
| Minggu 5 | 21–27 Des 2026 | Fase 6 (Bag. 2) | **M5 (Final/UAS):** Build Web & Windows, draf BAB III, presentasi & evaluasi individu |
