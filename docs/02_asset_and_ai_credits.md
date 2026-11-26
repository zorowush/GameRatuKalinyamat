# Kredit Aset, Referensi Sejarah & Keterbukaan Penggunaan AI

Dokumen ini mencatat seluruh sumber referensi sejarah, asal aset visual/audio/kode, serta transparansi penggunaan alat bantu AI sesuai ketentuan Mata Kuliah Game Programming.

---

## 1. Sumber Referensi Sejarah
| Kode | Referensi | Pemanfaatan di Game |
| :--- | :--- | :--- |
| **S1** | Chusnul Hayati, *"Ratu Kalinyamat: Ratu Jepara yang Pemberani"* (UNDIP) & Hayati dkk. (2000), *"Peranan Ratu Kalinyamat di Jepara pada Abad XVI"*. | Tahun penobatan 10 April 1549 (*Trus Karya Tataning Bumi*), sistem dagang *commenda*, 4 pelabuhan (Jepara, Juana, Rembang, Lasem), julukan Portugis Diego de Couto, diplomasi Johor/Hitu/Aceh, data ekspedisi 1551 & 1574, Masjid Mantingan 1559. |
| **S2** | Bambang Sulistyanto (2019), *"Ratu Kalinyamat: Sejarah atau Mitos?"* (Puslit Arkenas). | Analisis kritis perbedaan Babad vs catatan Portugis, pembahasan simbolis *tapa wuda asinjang rikma*, keberagaman versi asal Pangeran Hadiri, dan temuan arkeologis Benteng Kalinyamat & Mantingan. |
| **S3** | Sri Wintala Achmad (2020), *"Melacak Gerakan Perlawanan dan Laku Spiritualitas Ratu Kalinyamat"* (Araska). | Konteks konflik Demak (Pangeran Sekar, Sunan Prawata, Arya Penangsang, Hadiwijaya), nilai spiritualitas/zuhud, variasi tahun 1550, dan peran Sungging Badar Duwung (Tjie Wie Gwan). |
| **S4** | Ngatawi El-Zastrow (2020) FIN UNUSIA & Beni Jo (2023) Tirto.id. | Status penetapan resmi Ratu Kalinyamat sebagai Pahlawan Nasional Republik Indonesia (10 November 2023) untuk narasi epilog. |

---

## 2. Log Aset Visual, Audio & Font
| Aset | Sumber | Lisensi | Status |
| :--- | :--- | :--- | :--- |
| `icon.svg` | Template bawaan Godot Engine 4 | MIT License | Aktif |
| Potret Karakter (`portrait_retna_muda.png`, `portrait_ratu.png`, `portrait_sultan_trenggana.png`, `portrait_pangeran_hadiri.png`, `portrait_penasihat.png` [basis pedagang], `portrait_utusan.png`, `portrait_laksamana.png` [basis prajurit]) — `144×144` PNG | Diva Anggi Wulan Maulida (UI/Asset Creator) | Karya Orisinal Tim | **Terintegrasi** (`Assets/Characters/`) |
| Spritesheet Animasi Jalan 4 Arah (`walk_retna_muda.png`, `walk_ratu.png`, `walk_sultan_trenggana.png`, `walk_pangeran_hadiri.png`, `walk_penasihat.png`, `walk_utusan.png`, `walk_prajurit.png`, `player_ratu.png`) — `144×192` / `48×48` PNG | Diva Anggi Wulan Maulida (UI/Asset Creator) | Karya Orisinal Tim | **Terintegrasi** (`Assets/Characters/`) |
| Peta Latar Scrolling Pixel-Art (`bg_level1.png`, `bg_level2.png`, `bg_level3.png` — `2304×768`, dirender bersih dari tilemap tanpa baked NPC) & `bg_menu.png` (`1280×720`) | Diva Anggi Wulan Maulida (UI/Asset Creator) | Karya Orisinal Tim | **Terintegrasi** (`Assets/Environments/`) |
| Ikon Objek Arena (`icon_archive.png` `48×48`, `icon_challenge.png` `96×96`, `icon_gate.png` `96×96` dari tileset Anggi) | Diva Anggi Wulan Maulida (UI/Asset Creator) | Karya Orisinal Tim | **Terintegrasi** (`Assets/Objects/`) |
| Placeholder Visual Cadangan (`portrait_sungging.png`, 3 Lencana `Assets/UI/badge_*.png`) | Dibangkitkan prosedural via `Scripts/Autoload/AssetLoader.gd` | Karya Tim (MIT) | Aktif sementara — menunggu serah terima dari Anggi |
| BGM & SFX (`Assets/Audio/BGM/*.ogg`, `Assets/Audio/SFX/*.ogg`) | SFX prosedural cadangan (`AudioStreamWAV`) via `Scripts/Autoload/AudioManager.gd` | Karya Tim (MIT) | Aktif sementara — menunggu audio OGG final dari Anggi |

---

## 3. Keterbukaan Penggunaan Alat Bantu AI (AI Disclosure)
Sesuai etika akademik proyek PjBL, tim mencatat penggunaan asisten AI pengkodean (**Antigravity AI Coding Assistant**) secara transparan:
- **Ruang Lingkup Bantuan AI:**
  - Membantu perancangan arsitektur modular Godot 4 (Autoloads, pola Scene-Data separation).
  - Membantu penulisan boilerplate GDScript, struktur file `.tscn`, format file JSON awal berbasis ringkasan 4 referensi mahasiswa, skrip validasi otomatis (`Tests/validate_data.py` & `Tests/run_godot_tests.gd`), dan penyusunan draf dokumentasi teknis.
- **Peran & Verifikasi Mahasiswa (Ahmad Zuhri Fahrudin — Programmer):**
  - Menentukan arsitektur final, aturan skor, skenario edukasi, dan kontrak integrasi bersama anggota tim (Chika & Anggi).
  - Menjalankan, memeriksa, menguji langsung seluruh kode di Godot Engine 4.7.2, memverifikasi hasil pengujian otomatis & manual 6 skenario, mengelola repositori GitHub, serta memahami penuh alur kode untuk dipertanggungjawabkan pada presentasi UAS.
- **Catatan Keaslian Konten Sejarah:** Seluruh materi sejarah disusun berdasarkan 4 sumber referensi ilmiah/jurnalistik yang telah disiapkan tim (S1–S4) dan diberi penanda `FAKTA`, `TRADISI`, atau `FIKSI GAME` agar tidak terjadi klaim historis keliru.
