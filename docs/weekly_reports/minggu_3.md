# Laporan Progres Mingguan — Minggu 3 (7–13 Desember 2026)

- **Proyek:** Jejak Sang Ratu: Kejayaan Jepara
- **Pelapor:** Ahmad Zuhri Fahrudin (Game Programmer & Developer)
- **Fase:** Fase 4 & Fase 5 — Level 2, Level 3, Galeri Warisan, Evaluasi 10 Soal & Ending (`M3 Alpha`)

## 1. Pencapaian Minggu Ini
1. **Implementasi Penuh Level 2 (*Kejayaan Maritim Jepara*):**
   - 4 file JSON (`level2_dialogues.json`, `level2_archives.json`, `level2_trade.json`, `level2_diplomacy.json`) memuat julukan Portugis Diego de Couto (*Rainha de Japara, senhora poderosa e rica* & *De Kranige Dame*), sistem *commenda*, 4 pelabuhan (Jepara, Juana, Rembang, Lasem), seni ukir Mantingan (Sungging Badar Duwung / Tjie Wie Gwan), serta diplomasi Johor (1550), Hitu (1565), dan Aceh (1573).
   - **Tantangan 2A:** `CommendaTradeGame` (6 giliran niaga & klasifikasi komoditas ke rute Malaka, Maluku, Banten, Makassar).
   - **Tantangan 2B:** `DiplomacyGame` (3 audiensi utusan kerajaan Nusantara dengan umpan balik historis).
   - Penyelesaian Level 2 memberikan `+30` Misi Utama, Lencana **Ratu Bandar**, dan membuka Level 3.
2. **Implementasi Penuh Level 3 (*Armada ke Malaka*) & Layar Ending:**
   - 4 file JSON (`level3_dialogues.json`, `level3_archives.json`, `level3_expedition.json`, `level3_heritage_quiz.json`) memuat data akurat Ekspedisi 1551 & 1574 (Kiai Demang Laksamana / *Quilidamao*, 300 kapal, 80 jung besar 400 ton, 15.000 prajurit, blokade 3 bulan, 6 kapal logistik), Galeri Warisan (Masjid Mantingan 1559 candrasengkala *Rupa Brahmana Warna Sari*, Seni Ukir Jepara, Benteng Kalinyamat ±5–6 km), 10 soal evaluasi akhir, dan epilog Pahlawan Nasional RI (10 November 2023).
   - **Tantangan 3A:** `ExpeditionStrategyGame` dengan mekanik **3 Semangat Armada** serta layar **Refleksi Objektif Sebab Kegagalan** (tanpa memalsukan kemenangan historis).
   - **Tantangan 3B:** `HeritageQuizGame` (Galeri Warisan + Evaluasi 10 Soal dengan umpan balik langsung dan ambang Lencana **De Kranige Dame** ≥ 70%).
   - **Layar Akhir (`EndingScreen`):** Menampilkan total skor, persentase kuis, koleksi 3 lencana, epilog Pahlawan Nasional 2023, daftar referensi S1–S4, serta tombol *Main Lagi* / *Pilih Level* / *Menu Utama*.

## 2. Kendala & Solusi
- **Kendala:** Memastikan evaluasi akhir 10 soal tidak bias pola jawaban dan tetap mencerminkan keempat referensi sejarah secara seimbang.
- **Solusi:** Distribusi kunci jawaban divariasikan pada seluruh pilihan A–D, dilengkapi penjelasan korektif + sitasi sumber pada tiap soal.

## 3. Rencana Minggu Depan (Minggu 4–5 — Fase 6)
- Membangun skrip validasi otomatis JSON (`Tests/validate_data.py`) dan suite pengujian unit & verifikasi scene Godot headless (`Tests/run_godot_tests.gd`).
- Menjalankan dan mendokumentasikan 6 skenario uji wajib pada `docs/03_testing_and_bug_log.md`.
- Menyiapkan `export_presets.cfg` untuk **Windows Desktop (`.exe`)** & **Web (HTML5 single-thread)**, panduan deploy, draf BAB III Programmer, dan formulir kontribusi individu.

## 4. Bukti Kontribusi Individu (Programmer)
- Commit Fase 4 (Level 2) dan Fase 5 (Level 3 + Galeri + Kuis 10 Soal + Ending / `M3 Alpha`) pada branch `main`.
