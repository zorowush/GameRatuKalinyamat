# Log Pengujian (6 Skenario Wajib) & Pelacakan Bug

Dokumen ini digunakan oleh Programmer (Zuhri) dan Tester (Anggi) sebagai bahan **BAB IV (Pengujian dan Evaluasi)**.

---

## 1. Tabel 6 Skenario Pengujian Minimal (Panduan Tugas)

| No | Skenario Uji | Langkah Pengujian | Hasil yang Diharapkan | Status | Catatan / Bukti |
| :-: | :--- | :--- | :--- | :---: | :--- |
| 1 | **Menu Utama** | Buka game (Splash → klik/Enter), lalu uji tombol *Mulai/Lanjutkan*, *Pilih Level*, *Petunjuk*, *Tentang & Sumber*, *Reset Progres*. | Semua tombol responsif, tidak ada crash, transisi scene mulus, status progres/skor tampil akurat. | *Terjadwal (Fase 6)* | - |
| 2 | **Petunjuk** | Dari Menu Utama atau Pause Menu, buka layar *Petunjuk Bermain*. | Kontrol (`WASD`/Panah, Klik, `E`, `ESC`), aturan skor (`+30/+10/+5/0`), dan arti label (`FAKTA`, `TRADISI`, `FIKSI GAME`) tampil jelas dan bisa kembali ke menu sebelumnya. | *Terjadwal (Fase 6)* | - |
| 3 | **Gameplay** | Mainkan Level 1, 2, dan 3: gerakkan karakter (WASD & klik), interaksi NPC/Arsip (`E`/klik), selesaikan 6 tantangan utama & Galeri Warisan. | Karakter bergerak lancar tanpa tersangkut, interaksi terpicu, setiap mini-game dapat diselesaikan, level berikutnya terbuka berurutan. | *Terjadwal (Fase 6)* | - |
| 4 | **Sistem Skor** | Cek skor awal (`0`), temukan arsip (`+5`), jawab tantangan/kuis benar (`+10`), jawab salah (`0`), selesaikan misi utama level (`+30`), lalu restart game. | Perhitungan skor tepat, tidak bisa digandakan pada item yang sama, dan skor tersimpan otomatis di `user://save_data.json` setelah restart. | *Terjadwal (Fase 6)* | - |
| 5 | **Umpan Balik** | Sengaja memilih jawaban salah pada puzzle kronologi, investigasi *tapa wuda*, dagang *commenda*, diplomasi, ekspedisi, dan kuis; lalu coba lagi hingga benar. | Muncul pesan umpan balik korektif + opsi coba lagi (tanpa mengurangi skor atau macet); saat benar muncul penjelasan edukatif + badge sumber. | *Terjadwal (Fase 6)* | - |
| 6 | **Akhir Permainan** | Selesaikan Level 3 (termasuk Kuis 10 Soal) hingga masuk layar *Ending*. Uji dua kondisi kuis (< 70% vs ≥ 70%). | Layar akhir menampilkan total skor, persentase kuis, epilog Pahlawan Nasional 2023, daftar lencana (**De Kranige Dame** hanya jika ≥ 70%), dan tombol *Main Lagi* / *Menu Utama* bekerja. | *Terjadwal (Fase 6)* | - |

---

## 2. Daftar Pelacakan Bug (Bug Tracker)

| ID Bug | Tanggal | Pelapor | Level / Modul | Deskripsi Masalah | Tingkat | Status | Perbaikan (Commit) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| *Belum ada* | - | - | - | *Akan diisi selama pengujian Fase 2–6* | - | - | - |
