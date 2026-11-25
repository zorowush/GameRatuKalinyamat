extends Control
## Layar Petunjuk Bermain: kontrol, aturan skor, dan pemisahan label sumber sejarah.


func _ready() -> void:
	theme = AssetLoader.build_theme()
	_build_ui()


func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "PETUNJUK BERMAIN"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_btn := Button.new()
	back_btn.text = "◀ Kembali ke Menu Utama"
	back_btn.custom_minimum_size = Vector2(220, 42)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	var grid := HBoxContainer.new()
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("separation", 18)
	vbox.add_child(grid)

	# Kolom 1: Kontrol & Alur Eksplorasi
	grid.add_child(_make_info_card(
		"1. Kontrol & Cara Bermain",
		"[b]Gerak Karakter:[/b]\n"
		+ "• Tombol [color=#D4A24C]W / A / S / D[/color] atau [color=#D4A24C]Panah[/color]\n"
		+ "• Atau [color=#D4A24C]Klik langsung[/color] pada lantai arena untuk berjalan\n\n"
		+ "[b]Interaksi Tokoh & Arsip:[/b]\n"
		+ "• Dekati titik interaktif lalu tekan [color=#D4A24C]E[/color]\n"
		+ "• Atau [color=#D4A24C]Klik langsung[/color] ikon tokoh/gulungan/tantangan\n\n"
		+ "[b]Dialog & Menu:[/b]\n"
		+ "• [color=#D4A24C]Enter / E[/color] untuk melanjutkan dialog\n"
		+ "• [color=#D4A24C]ESC[/color] untuk membuka Pause Menu"
	))

	# Kolom 2: Sistem Skor & Lencana
	grid.add_child(_make_info_card(
		"2. Sistem Skor & Lencana",
		"[b]Perolehan Skor:[/b]\n"
		+ "• Misi Utama Level selesai: [color=#D4A24C][b]+30 poin[/b][/color]\n"
		+ "• Tantangan / Puzzle / Kuis benar: [color=#D4A24C][b]+10 poin[/b][/color]\n"
		+ "• Menemukan Arsip Sejarah: [color=#D4A24C][b]+5 poin[/b][/color]\n"
		+ "• Jawaban salah: [color=#E2D0B1][b]0 poin[/b][/color] (muncul umpan balik korektif & bisa dicoba lagi)\n\n"
		+ "[b]3 Lencana Kehormatan:[/b]\n"
		+ "• [color=#D4A24C]Penyelidik Sejarah[/color] — Selesaikan Level 1\n"
		+ "• [color=#D4A24C]Ratu Bandar[/color] — Selesaikan Level 2\n"
		+ "• [color=#D4A24C]De Kranige Dame[/color] — Selesaikan Level 3 dengan skor Evaluasi Akhir [b]≥ 70%[/b]\n\n"
		+ "Progres tersimpan otomatis."
	))

	# Kolom 3: Transparansi Sumber Sejarah
	grid.add_child(_make_info_card(
		"3. Arti Label Sumber Sejarah",
		"Setiap dialog, arsip, dan kartu bukti dipisahkan dengan jelas:\n\n"
		+ "[color=#4BC6DE][b][FAKTA][/b][/color]\n"
		+ "Fakta sejarah yang tercatat lintas sumber primer/sekunder (arsip Portugis, penelitian akademis).\n\n"
		+ "[color=#E8B55B][b][TRADISI][/b][/color]\n"
		+ "Kisah babad, cerita rakyat, tradisi tutur lokal, atau perbedaan tafsir antar sumber.\n\n"
		+ "[color=#E87461][b][FIKSI GAME][/b][/color]\n"
		+ "Tokoh pemandu dan jembatan narasi permainan untuk memudahkan pembelajaran."
	))


func _make_info_card(heading: String, body_bbcode: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 2, 20))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)

	var h := Label.new()
	h.text = heading
	h.add_theme_font_size_override("font_size", 20)
	h.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	col.add_child(h)

	var sep := HSeparator.new()
	col.add_child(sep)

	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rt.add_theme_font_size_override("normal_font_size", 15)
	rt.text = body_bbcode
	col.add_child(rt)
	return panel
