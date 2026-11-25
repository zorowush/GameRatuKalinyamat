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
| Placeholder Visual 2D Relief Mantingan | Dibangkitkan prosedural via `Scripts/Autoload/AssetLoader.gd` | Karya Tim (MIT) | Aktif (otomatis terganti saat PNG Anggi masuk ke `Assets/`) |
| Efek Suara (SFX) Prosedural Cadangan | Disintesis prosedural (`AudioStreamWAV`) via `Scripts/Autoload/AudioManager.gd` | Karya Tim (MIT) | Aktif (otomatis terganti saat OGG Anggi masuk ke `Assets/Audio/SFX/`) |
| Aset Visual & Audio Final (`Assets/`) | Diva Anggi Wulan Maulida (UI/Asset Creator) | Karya Orisinal Tim / CC0 (diisi saat serah terima) | Menunggu serah terima Fase 6 |

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
