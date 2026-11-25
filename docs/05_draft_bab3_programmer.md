# Draf BAB III (Perancangan & Implementasi — Porsi Programmer) + Lampiran 5 & 7

Dokumen ini disiapkan khusus untuk bagian laporan **Ahmad Zuhri Fahrudin (Game Programmer & Developer)**: **BAB III (3.1, 3.2, 3.5, 3.6, 3.7)**, **Lampiran 5 (Cuplikan Struktur Kode)**, **Lampiran 7 (Bukti Kontribusi)**, serta panduan tanya-jawab teknis saat presentasi UAS.

---

## 3.1 Software dan Tools yang Digunakan
1. **Godot Engine 4.7.2 Stable (GL Compatibility Renderer):** Game engine open-source 2D/3D yang ringan dan mendukung ekspor lintas platform (Windows `.exe` & Web HTML5 single-thread).
2. **GDScript:** Bahasa skrip bawaan Godot dengan static typing untuk arsitektur modular dan bebas overhead runtime tambahan.
3. **Git & GitHub (`https://github.com/zorowush/GameRatuKalinyamat.git`):** Sistem kontrol versi untuk pencatatan riwayat commit bertahap dari Fase 1 hingga Fase 6.
4. **Python 3.10:** Digunakan untuk menjalankan skrip validasi otomatis (`Tests/validate_data.py`) terhadap integritas 14 file JSON, label sumber sejarah, dan path resource.
5. **Visual Studio Code / Godot Script Editor:** Editor penulisan kode dan dokumentasi Markdown.

## 3.2 Spesifikasi Perangkat Pengembangan & Target Pengguna
- **Perangkat Pengembangan:** OS Windows 10/11 (64-bit), CPU multi-core, RAM ≥ 8 GB, Godot 4.7.2 Stable (OpenGL Compatibility).
- **Spesifikasi Minimal Pengguna (Windows Desktop):** Windows 10 64-bit, RAM 4 GB, GPU mendukung OpenGL 3.3 / Compatibility, ruang disk ~80 MB.
- **Spesifikasi Minimal Pengguna (Web HTML5):** Browser modern (Chrome, Edge, Firefox) dengan dukungan WebAssembly & WebGL2, koneksi internet standar (target build < 40 MB).

## 3.5 Struktur Program & Arsitektur Proyek
Proyek menerapkan pola **Data-Driven & Modular Autoload Architecture** sehingga kode permainan terpisah bersih dari konten sejarah (`Data/*.json`) dan aset visual/audio (`Assets/`):

1. **6 Autoload Global (`Scripts/Autoload/`):**
   - `AssetLoader.gd`: Memuat JSON, membangkitkan tema UI Relief Mantingan, dan menyediakan mekanisme fallback otomatis (memuat aset PNG/OGG dari `Assets/` jika tersedia, atau visual prosedural bila belum disetor).
   - `GameManager.gd`: Pusat manajemen skor (`+30/+10/+5/0`), pencegahan penggandaan skor, status unlock Level 1–3, pencatatan 9 arsip, 3 lencana (*Penyelidik Sejarah*, *Ratu Bandar*, *De Kranige Dame*), serta Save/Load ke `user://save_data.json`.
   - `AudioManager.gd`: Kontrol BGM/SFX, tombol mute, penanganan aman kebijakan *autoplay* browser Web, serta sintesis nada `AudioStreamWAV` cadangan.
   - `MissionManager.gd`: Membaca daftar misi dari `Data/Missions/missions.json` dan menyiarkan pembaruan objektif ke HUD melalui signal.
   - `DialogueManager.gd`: Overlay dialog global dengan potret tokoh, pilihan cabang, serta badge sumber berwarna (`FAKTA`, `TRADISI`, `FIKSI GAME`).
   - `SceneManager.gd`: Pengelola transisi scene dengan efek fade halus.
2. **Sistem Eksplorasi Reusable (`Scripts/Player/`, `Scripts/Systems/`):**
   - `PlayerController.gd` (`CharacterBody2D`): Mendukung input ganda (keyboard `WASD`/Panah dan klik lantai arena) dengan pembatasan batas arena (*clamping*).
   - `InteractableSpot.gd`: Titik interaktif serbaguna untuk NPC, Arsip, Meja Tantangan, dan Gerbang Akhir Level (dipicu via `E` atau klik langsung).
   - `BaseLevelArena.gd`: Kelas induk Level 1, 2, dan 3 yang menyatukan HUD, penguncian gerak saat modal terbuka, dan pop-up penyelesaian level.
3. **Kontroler Level & 6 Mini-Game Edukatif:**
   - Level 1: `Level1Controller.gd`, `ChronologyPuzzle.gd` (1A), `TapaInvestigation.gd` (1B).
   - Level 2: `Level2Controller.gd`, `CommendaTradeGame.gd` (2A), `DiplomacyGame.gd` (2B).
   - Level 3: `Level3Controller.gd`, `ExpeditionStrategyGame.gd` (3A), `HeritageQuizGame.gd` (3B), dan `EndingScreen.gd`.

## 3.6 Implementasi Fitur Utama
1. **Navigasi Lengkap:** Splash Screen (pembuka konteks audio Web) → Main Menu (*Mulai/Lanjutkan*, *Pilih Level*, *Petunjuk*, *Tentang & Sumber*, *Reset Progres*) → Gameplay 3 Level → Layar Ending.
2. **Sistem Skor & Pencegahan Kecurangan:** Setiap ID misi, tantangan, dan arsip dicatat di dictionary (`completed_missions`, `scored_challenges`, `found_archives`). Jawaban salah memberi `0` poin dan umpan balik korektif agar pemain bisa mencoba ulang sampai paham, namun poin `+10` hanya diberikan satu kali per item.
3. **Penyimpanan Progres Lintas Platform:** Menggunakan `FileAccess.open("user://save_data.json", ...)` dengan serialisasi `JSON.stringify`, yang secara otomatis bekerja di folder AppData Windows maupun IndexedDB browser Web.

## 3.7 Implementasi Unsur Edukasi & Sensitivitas Sejarah
1. **Pemisahan Label Sumber (`FAKTA`, `TRADISI`, `FIKSI GAME`):** Diterapkan sebagai field wajib pada seluruh 14 file JSON dan diverifikasi oleh skrip `Tests/validate_data.py`.
2. **Penyajian Simbolis *Tapa Wuda*:** Episode Bukit Danaraja divisualisasikan dengan zona kabut/siluet dan dikemas dalam Tantangan 1B (Investigasi 4 kartu bukti lintas sumber) agar pemain memahami perbedaan tafsir babad vs tafsir simbolis zuhud & etika keraton Islam.
3. **Objektivitas Ekspedisi Malaka 1551 & 1574:** Hasil militer tidak dipalsukan menjadi kemenangan; Tantangan 3A ditutup dengan layar **Refleksi Sebab Kegagalan** (keunggulan meriam Portugis, koordinasi waktu Aceh, jalur logistik 6 kapal, dan badai 1551).
4. **Pengakuan Pahlawan Nasional 2023:** Epilog dan soal evaluasi memuat penetapan Ratu Kalinyamat sebagai Pahlawan Nasional RI (10 November 2023) serta peninggalan Masjid Mantingan (1559 M), Seni Ukir Jepara, dan Benteng Kalinyamat (±5–6 km).

---

## Lampiran 5 — Ringkasan Modul Kode Kunci & Panduan Q&A Presentasi Individu (UAS 30%)

Pertanyaan yang sering diajukan dosen kepada Programmer saat demonstrasi:
1. **"Bagaimana game memisahkan konten sejarah dari kode program?"**
   - Jawab: Seluruh dialog, arsip, soal kuis, dan skenario disimpan di `Data/*.json`. Kode membaca JSON lewat `AssetLoader.load_json_file()`, sehingga Game Designer (Chika) dapat memperbarui teks tanpa mengubah skrip GDScript.
2. **"Bagaimana sistem mencegah pemain mengulang soal yang sama terus-menerus untuk menaikkan skor?"**
   - Jawab: Di `GameManager.gd`, metode `add_challenge_score(step_id, is_correct)` memeriksa dictionary `scored_challenges.has(step_id)`. Jika salah (`false`), skor `+0` dan ID belum dikunci sehingga pemain bisa mencoba lagi; setelah benar pertama kali, skor `+10` ditambahkan dan `step_id` dicatat agar tidak bisa digandakan.
3. **"Bagaimana game tetap jalan di Web (HTML5) terkait audio dan save data?"**
   - Jawab: (a) Preset Web diset `variant/thread_support=false` (single-thread) agar jalan di GitHub Pages/itch.io tanpa header COOP/COEP. (b) `SplashScreen` memanggil `AudioManager.unlock_web_audio()` saat klik pertama user untuk memenuhi kebijakan autoplay browser. (c) `user://save_data.json` otomatis disimpan ke IndexedDB browser oleh Godot Web runtime.
4. **"Bagaimana alur pengujian otomatis yang Anda buat?"**
   - Jawab: Ada 2 lapis verifikasi: `Tests/validate_data.py` (memvalidasi 407 aturan JSON, label sumber `FAKTA`/`TRADISI`/`FIKSI GAME`, dan seluruh path `res://`) serta `Tests/TestRunner.tscn` yang dijalankan dengan Godot 4.7.2 headless untuk menguji logika `GameManager`, batas kelulusan kuis `69% vs 70%`, persistensi save/load & file korup, instansiasi seluruh 18 scene, serta simulasi interaksi mini-game.
