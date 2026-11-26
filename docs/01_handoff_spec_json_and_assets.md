# Spesifikasi Handoff Konten (Chika) & Aset Visual/Audio (Anggi)

Dokumen ini menjadi kontrak kerja antara **Game Programmer (Zuhri)** dengan **Game Designer (Chika)** dan **UI/Asset Creator (Anggi)** agar seluruh naskah dan aset dapat masuk ke proyek tanpa merusak kode.

---

## Bagian A — Kontrak File JSON untuk Game Designer (Chika)

Seluruh teks game disimpan terpisah di folder `Data/` dalam format **UTF-8 JSON**. Chika cukup mengedit teks di dalam file JSON tanpa mengubah nama *key* utama. Setelah mengedit, jalankan `python Tests/validate_data.py` untuk memastikan format valid.

### Aturan Wajib Label Sumber (`source_tag`)
Setiap dialog, catatan arsip, kartu bukti, dan soal wajib memiliki salah satu dari 3 nilai berikut:
- `"FAKTA"` — Fakta sejarah terverifikasi lintas sumber (S1–S4).
- `"TRADISI"` — Bersumber dari babad, cerita tutur, atau perbedaan tradisi lokal.
- `"FIKSI GAME"` — Dialog fiktif/pemandu gameplay (mis. tokoh pembantu pelabuhan/keraton).

### Daftar File JSON di `Data/`
| Path File | Isi & Struktur Ringkas |
| :--- | :--- |
| `Data/Missions/missions.json` | Daftar misi per level (`levels -> "1"/"2"/"3" -> steps[]`). |
| `Data/Historical_Data/references.json` | Daftar pustaka S1–S4 dan informasi tim untuk layar *Tentang & Sumber*. |
| `Data/Dialogues/level1_dialogues.json` | Naskah dialog Level 1 (`prolog_keraton`, `danaraja_briefing`, `penobatan_1549`). |
| `Data/Historical_Data/level1_archives.json` | 3 Arsip sejarah Level 1 (Silsilah Retna Kencana, Asal Pangeran Hadiri, Candrasengkala 1549). |
| `Data/Historical_Data/level1_chronology.json` | 5 kartu urutan konflik Demak untuk Tantangan 1A. |
| `Data/Historical_Data/level1_tapa_investigation.json` | 4 kartu bukti + 3 opsi kesimpulan untuk Tantangan 1B (*Tapa Wuda* simbolis). |
| `Data/Dialogues/level2_dialogues.json` | Naskah dialog Level 2 (Syahbandar, Sungging Badar Duwung, Utusan). |
| `Data/Historical_Data/level2_archives.json` | 3 Arsip sejarah Level 2 (Diego de Couto, Sistem Commenda & 4 Pelabuhan, Seni Ukir Mantingan). |
| `Data/Historical_Data/level2_trade.json` | 6 giliran simulasi dagang *commenda* & klasifikasi komoditas untuk Tantangan 2A. |
| `Data/Historical_Data/level2_diplomacy.json` | 3 skenario utusan (Johor 1550, Hitu 1565, Aceh 1573) untuk Tantangan 2B. |
| `Data/Dialogues/level3_dialogues.json` | Naskah dialog Level 3 (Dewan Perang, Kiai Demang Laksamana, Epilog Pahlawan Nasional 2023). |
| `Data/Historical_Data/level3_archives.json` | 3 Arsip sejarah Level 3 (Ekspedisi 1551, Ekspedisi 1574, Pahlawan Nasional 2023). |
| `Data/Historical_Data/level3_expedition.json` | Skenario strategi 1551 & 1574 + refleksi objektif sebab kegagalan (Tantangan 3A). |
| `Data/Historical_Data/level3_heritage_quiz.json` | 3 item Galeri Warisan (Masjid Mantingan, Seni Ukir, Benteng Kalinyamat) + 10 soal evaluasi akhir (Tantangan 3B). |

---

## Bagian B — Kontrak Aset Visual & Audio untuk UI/Asset Creator (Anggi)

Sistem `AssetLoader` di Godot otomatis memeriksa keberadaan file di `Assets/`. Selama file belum tersedia, game menampilkan placeholder bertema **Relief Mantingan**. Begitu Anggi menaruh file dengan **nama & lokasi persis** di bawah ini lalu membuka Godot, aset asli akan langsung tampil!

### Palet Warna Resmi (Relief Mantingan)
| Nama Warna | Kode Hex | Penggunaan |
| :--- | :--- | :--- |
| Bata Merah (Terracotta) | `#9E3B2B` | Aksen tombol utama, header panel, tag `FIKSI GAME` |
| Krem Lontar | `#F5EAD6` | Latar teks utama, kartu arsip, teks terang |
| Hijau-Biru Laut | `#1E6B7B` | Aksen maritim, tombol sekunder, tag `FAKTA` |
| Emas Aksen | `#D4A24C` | Bingkai, lencana, highlight interaktif, tag `TRADISI` |
| Cokelat Tua | `#3B2418` | Latar panel gelap, bayangan, teks gelap di atas krem |

### Daftar Target File Aset (`Assets/`) & Status Integrasi
| Path File Target | Jenis | Resolusi / Format Aktual / Target | Status |
| :--- | :--- | :--- | :--- |
| `Assets/Characters/walk_retna_muda.png` & `walk_ratu.png` | Spritesheet Animasi Jalan 4 Arah Pemain (Lv.1 & Lv.2–3) | `144x192` PNG (3×4 frame `48x48`) | **Sudah Masuk** |
| `Assets/Characters/player_ratu.png` | Sprite Idle Cadangan Ratu | `48x48` PNG transparan | **Sudah Masuk** |
| `Assets/Characters/portrait_retna_muda.png` & `portrait_ratu.png` | Potret Dialog Retna Muda (Lv.1) & Ratu Kalinyamat | `144x144` PNG | **Sudah Masuk** |
| `Assets/Characters/portrait_sultan_trenggana.png` & `walk_sultan_trenggana.png` | Potret & Walk Sheet Sultan Trenggana | `144x144` & `144x192` PNG | **Sudah Masuk** |
| `Assets/Characters/portrait_pangeran_hadiri.png` & `walk_pangeran_hadiri.png` | Potret & Walk Sheet Pangeran Hadiri | `144x144` & `144x192` PNG | **Sudah Masuk** |
| `Assets/Characters/portrait_penasihat.png` & `walk_penasihat.png` | Potret & Walk Penasihat/Syahbandar *(sementara pakai aset pedagang)* | `144x144` & `144x192` PNG | **Sudah Masuk** *(opsional revisi khusus Ki Wira)* |
| `Assets/Characters/portrait_laksamana.png` & `walk_prajurit.png` | Potret & Walk Kiai Demang Laksamana *(sementara pakai aset prajurit)* | `144x144` & `144x192` PNG | **Sudah Masuk** *(opsional revisi khusus Laksamana)* |
| `Assets/Characters/portrait_utusan.png` & `walk_utusan.png` | Potret & Walk Utusan Kerajaan | `144x144` & `144x192` PNG | **Sudah Masuk** |
| `Assets/Characters/portrait_sungging.png` | Potret Sungging Badar Duwung (Lv.2) | `144x144` atau `256x256` PNG transparan | **Belum** *(masih placeholder)* |
| `Assets/Environments/bg_menu.png` | Latar Main Menu / Splash | `1280x720` PNG | **Sudah Masuk** |
| `Assets/Environments/bg_level1.png` | Latar Arena Scrolling Level 1 (Keraton Demak & Gapura) | `2304x768` PNG (skala `2160x720` di game) | **Sudah Masuk** |
| `Assets/Environments/bg_level2.png` | Latar Arena Scrolling Level 2 (Pelabuhan Jepara) | `2304x768` PNG (skala `2160x720` di game) | **Sudah Masuk** |
| `Assets/Environments/bg_level3.png` | Latar Arena Scrolling Level 3 (Pangkalan Armada) | `2304x768` PNG (skala `2160x720` di game) | **Sudah Masuk** |
| `Assets/Objects/icon_archive.png` | Ikon Arsip Gulungan | `48x48` PNG transparan | **Sudah Masuk** |
| `Assets/Objects/icon_challenge.png` | Ikon Meja Tantangan | `96x96` PNG transparan | **Sudah Masuk** |
| `Assets/Objects/icon_gate.png` | Ikon Gerbang/Monumen Akhir Level | `96x96` PNG transparan | **Sudah Masuk** |
| `Assets/UI/badge_penyelidik.png` | Lencana Penyelidik Sejarah | `128x128` PNG transparan | **Belum** *(masih placeholder)* |
| `Assets/UI/badge_ratu_bandar.png` | Lencana Ratu Bandar | `128x128` PNG transparan | **Belum** *(masih placeholder)* |
| `Assets/UI/badge_kranige_dame.png` | Lencana De Kranige Dame | `128x128` PNG transparan | **Belum** *(masih placeholder)* |
| `Assets/Audio/BGM/bgm_menu.ogg` | Musik Latar Menu (Gamelan lembut) | OGG Vorbis, 96–128 kbps, loop (< 1.5 MB) | **Belum** |
| `Assets/Audio/BGM/bgm_level1.ogg` | Musik Latar Level 1 | OGG Vorbis, 96–128 kbps, loop (< 1.5 MB) | **Belum** |
| `Assets/Audio/BGM/bgm_level2.ogg` | Musik Latar Level 2 | OGG Vorbis, 96–128 kbps, loop (< 1.5 MB) | **Belum** |
| `Assets/Audio/BGM/bgm_level3.ogg` | Musik Latar Level 3 | OGG Vorbis, 96–128 kbps, loop (< 1.5 MB) | **Belum** |
| `Assets/Audio/SFX/sfx_click.ogg` | Suara Klik Tombol | OGG / WAV pendek (< 0.3 dtk, < 50 KB) | **Belum** *(cadangan sintesis aktif)* |
| `Assets/Audio/SFX/sfx_correct.ogg` | Suara Jawaban Benar | OGG / WAV (< 1 dtk, < 80 KB) | **Belum** *(cadangan sintesis aktif)* |
| `Assets/Audio/SFX/sfx_wrong.ogg` | Suara Jawaban Salah | OGG / WAV (< 1 dtk, < 80 KB) | **Belum** *(cadangan sintesis aktif)* |
| `Assets/Audio/SFX/sfx_archive.ogg` | Suara Menemukan Arsip | OGG / WAV (< 1 dtk, < 80 KB) | **Belum** *(cadangan sintesis aktif)* |
| `Assets/Audio/SFX/sfx_badge.ogg` | Suara Raih Lencana / Level Selesai | OGG / WAV (< 2 dtk, < 150 KB) | **Belum** *(cadangan sintesis aktif)* |

> **Target Ukuran Build Web (HTML5):** Total folder `Assets/` dijaga di bawah **20 MB** agar ukuran ekspor Web keseluruhan tetap **< 40 MB** dan cepat dibuka dosen melalui browser.
