# Laporan Progres Mingguan — Minggu 2 (30 November – 6 Desember 2026)

- **Proyek:** Jejak Sang Ratu: Kejayaan Jepara
- **Pelapor:** Ahmad Zuhri Fahrudin (Game Programmer & Developer)
- **Fase:** Fase 2 & Fase 3 — Core Systems, UI Lengkap & Prototype Playable Level 1 (`M2`)

## 1. Pencapaian Minggu Ini
1. **Sistem Inti (6 Autoload Global):**
   - `AssetLoader`: Pemuat aset otomatis dari `Assets/` dengan fallback visual prosedural bertema Relief Mantingan, pemuat JSON aman, dan builder tema UI.
   - `GameManager`: Implementasi aturan skor (`+30` misi utama, `+10` tantangan/kuis benar, `+5` arsip baru, `0` salah), sistem unlock level 1–3, lencana, dan Save/Load JSON ke `user://save_data.json`.
   - `AudioManager`: Pemutar BGM/SFX dengan aktivasi audio aman untuk Web (HTML5) serta cadangan SFX sintetis (`AudioStreamWAV`).
   - `MissionManager`: Pelacakan objektif per level dari `Data/Missions/missions.json`.
   - `DialogueManager`: Sistem dialog berlabel sumber (`FAKTA`, `TRADISI`, `FIKSI GAME`) dengan pilihan cabang respons.
   - `SceneManager`: Transisi scene mulus dengan efek fade.
2. **Antarmuka Wajib Lengkap:**
   - `SplashScreen`, `MainMenu`, `InstructionsScreen`, `AboutScreen`, `LevelSelectScreen`, dan `GameplayHUD` (Skor, Misi, Catatan Arsip, Audio Toggle, Pause Menu, Toast notifikasi).
3. **Kit Eksplorasi 2D Reusable & Implementasi Penuh Level 1 (*Putri dari Demak*):**
   - `PlayerController` (`WASD`/Panah + Klik-untuk-jalan + interaksi `E`) dan `InteractableSpot` (interaksi `E`/Klik).
   - 4 file JSON Level 1 (`level1_dialogues.json`, `level1_archives.json`, `level1_chronology.json`, `level1_tapa_investigation.json`).
   - **Tantangan 1A:** Puzzle Urutan 5 Peristiwa Kronologi Konflik Demak (`ChronologyPuzzle`).
   - **Tantangan 1B:** Investigasi "Sejarah atau Mitos?" (*Tapa Wuda* simbolis dengan 4 kartu bukti lintas sumber — `TapaInvestigation`).
   - Gerbang Penobatan 1549: memberikan `+30` Misi Utama, Lencana **Penyelidik Sejarah**, dan membuka akses Level 2.

## 2. Kendala & Solusi
- **Kendala:** Menyajikan episode *tapa wuda* agar tetap akurat secara kajian historiografi tanpa visual sensitif.
- **Solusi:** Arena Bukit Danaraja divisualisasikan secara simbolis (zona kabut/siluet) dan dikemas dalam mini-game investigasi 4 kartu bukti (Babad Tanah Jawi, Kritik Sejarawan, Makna Zuhud/Tasawuf, Budaya Keraton Islam).

## 3. Rencana Minggu Depan (Minggu 3 — Fase 4 & Fase 5)
- Implementasi penuh **Level 2 (Kejayaan Maritim Jepara)**: Simulasi Niaga *Commenda* & Diplomasi Johor/Hitu/Aceh.
- Implementasi penuh **Level 3 (Armada ke Malaka)**: Strategi & Refleksi Objektif 1551 & 1574, Galeri Warisan, Evaluasi 10 Soal & Layar Ending (`M3 Alpha`).

## 4. Bukti Kontribusi Individu (Programmer)
- Commit Fase 2 (Core Systems & UI) dan Fase 3 (Level 1 Playable / `M2`) di repositori Git `main`.
