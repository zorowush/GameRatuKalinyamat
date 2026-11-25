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

### Daftar Target File Aset (`Assets/`)
| Path File Target | Jenis | Resolusi / Format Rekomendasi | Batas Ukuran |
| :--- | :--- | :--- | :--- |
| `Assets/Characters/player_ratu.png` | Sprite Karakter Utama | `128x128` PNG transparan | < 150 KB |
| `Assets/Characters/portrait_ratu.png` | Potret Dialog Ratu Kalinyamat | `256x256` PNG transparan | < 200 KB |
| `Assets/Characters/portrait_penasihat.png` | Potret Penasihat / Syahbandar | `256x256` PNG transparan | < 200 KB |
| `Assets/Characters/portrait_sungging.png` | Potret Sungging Badar Duwung | `256x256` PNG transparan | < 200 KB |
| `Assets/Characters/portrait_laksamana.png` | Potret Kiai Demang Laksamana | `256x256` PNG transparan | < 200 KB |
| `Assets/Characters/portrait_utusan.png` | Potret Utusan Kerajaan | `256x256` PNG transparan | < 200 KB |
| `Assets/Environments/bg_menu.png` | Latar Main Menu / Splash | `1280x720` PNG / WebP | < 600 KB |
| `Assets/Environments/bg_level1.png` | Latar Arena Level 1 (Demak & Danaraja) | `1280x720` PNG | < 600 KB |
| `Assets/Environments/bg_level2.png` | Latar Arena Level 2 (Pelabuhan Jepara) | `1280x720` PNG | < 600 KB |
| `Assets/Environments/bg_level3.png` | Latar Arena Level 3 (Pangkalan Armada) | `1280x720` PNG | < 600 KB |
| `Assets/Objects/icon_archive.png` | Ikon Arsip Gulungan | `96x96` PNG transparan | < 80 KB |
| `Assets/Objects/icon_challenge.png` | Ikon Meja Tantangan | `96x96` PNG transparan | < 80 KB |
| `Assets/Objects/icon_gate.png` | Ikon Gerbang/Monumen Akhir Level | `96x96` PNG transparan | < 80 KB |
| `Assets/UI/badge_penyelidik.png` | Lencana Penyelidik Sejarah | `128x128` PNG transparan | < 100 KB |
| `Assets/UI/badge_ratu_bandar.png` | Lencana Ratu Bandar | `128x128` PNG transparan | < 100 KB |
| `Assets/UI/badge_kranige_dame.png` | Lencana De Kranige Dame | `128x128` PNG transparan | < 100 KB |
| `Assets/Audio/BGM/bgm_menu.ogg` | Musik Latar Menu (Gamelan lembut) | OGG Vorbis, 96–128 kbps, loop | < 1.5 MB |
| `Assets/Audio/BGM/bgm_level1.ogg` | Musik Latar Level 1 | OGG Vorbis, 96–128 kbps, loop | < 1.5 MB |
| `Assets/Audio/BGM/bgm_level2.ogg` | Musik Latar Level 2 | OGG Vorbis, 96–128 kbps, loop | < 1.5 MB |
| `Assets/Audio/BGM/bgm_level3.ogg` | Musik Latar Level 3 | OGG Vorbis, 96–128 kbps, loop | < 1.5 MB |
| `Assets/Audio/SFX/sfx_click.ogg` | Suara Klik Tombol | OGG / WAV pendek (< 0.3 dtk) | < 50 KB |
| `Assets/Audio/SFX/sfx_correct.ogg` | Suara Jawaban Benar | OGG / WAV (< 1 dtk) | < 80 KB |
| `Assets/Audio/SFX/sfx_wrong.ogg` | Suara Jawaban Salah | OGG / WAV (< 1 dtk) | < 80 KB |
| `Assets/Audio/SFX/sfx_archive.ogg` | Suara Menemukan Arsip | OGG / WAV (< 1 dtk) | < 80 KB |
| `Assets/Audio/SFX/sfx_badge.ogg` | Suara Raih Lencana / Level Selesai | OGG / WAV (< 2 dtk) | < 150 KB |

> **Target Ukuran Build Web (HTML5):** Total folder `Assets/` dijaga di bawah **20 MB** agar ukuran ekspor Web keseluruhan tetap **< 40 MB** dan cepat dibuka dosen melalui browser.
