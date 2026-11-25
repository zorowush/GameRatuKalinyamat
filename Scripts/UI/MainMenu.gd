extends Control
## Menu Utama game: Mulai/Lanjutkan, Pilih Level, Petunjuk, Tentang & Sumber,
## Reset Progres (dengan konfirmasi), Toggle Audio, dan status skor/lencana.

var _play_button: Button
var _stats_label: Label
var _mute_button: Button
var _confirm_dialog: ConfirmationDialog


func _ready() -> void:
	theme = AssetLoader.build_theme()
	AudioManager.play_bgm("bgm_menu")
	_build_ui()
	_refresh_status()


func _refresh_status() -> void:
	if _play_button != null:
		_play_button.text = "Lanjutkan Permainan ▶" if GameManager.has_save_progress() else "Mulai Permainan ▶"
	if _stats_label != null:
		var badge_str := ", ".join(GameManager.badges) if not GameManager.badges.is_empty() else "Belum ada"
		_stats_label.text = "Skor: %d   |   Level Terbuka: %d/3   |   Arsip: %d   |   Lencana: %s" % [
			GameManager.total_score,
			GameManager.unlocked_level,
			GameManager.get_archive_count(),
			badge_str,
		]
	if _mute_button != null:
		_mute_button.text = "Audio: MATI" if AudioManager.is_muted() else "Audio: AKTIF"


func _on_play_pressed() -> void:
	AudioManager.unlock_web_audio()
	AudioManager.play_sfx("click")
	SceneManager.change_scene(GameManager.get_next_playable_level_scene())


func _on_level_select_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_LEVEL_SELECT)


func _on_instructions_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_INSTRUCTIONS)


func _on_about_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_ABOUT)


func _on_reset_pressed() -> void:
	AudioManager.play_sfx("click")
	_confirm_dialog.popup_centered()


func _on_reset_confirmed() -> void:
	AudioManager.play_sfx("click")
	GameManager.reset_progress()
	MissionManager.reset_runtime_steps()
	_refresh_status()


func _on_mute_pressed() -> void:
	AudioManager.toggle_mute()
	AudioManager.play_sfx("click")
	_refresh_status()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().quit()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	add_child(bg)

	var bg_tex := TextureRect.new()
	bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_tex.modulate = Color(1, 1, 1, 0.22)
	bg_tex.texture = AssetLoader.load_texture_or_placeholder(
		"res://Assets/Environments/bg_menu.png", Vector2i(320, 180), AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, "crest"
	)
	add_child(bg_tex)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 20)
	margin.add_child(root_vbox)

	# Header bar
	var top_row := HBoxContainer.new()
	root_vbox.add_child(top_row)

	var brand := Label.new()
	brand.text = "JEJAK SANG RATU: KEJAYAAN JEPARA"
	brand.add_theme_font_size_override("font_size", 26)
	brand.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(brand)

	_mute_button = Button.new()
	_mute_button.custom_minimum_size = Vector2(140, 38)
	_mute_button.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	_mute_button.pressed.connect(_on_mute_pressed)
	top_row.add_child(_mute_button)

	# Middle split: Left Hero Lore Card + Right Menu Buttons
	var content_row := HBoxContainer.new()
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 28)
	root_vbox.add_child(content_row)

	var hero_panel := PanelContainer.new()
	hero_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_panel.size_flags_stretch_ratio = 1.25
	hero_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 2, 26))
	content_row.add_child(hero_panel)

	var hero_vbox := VBoxContainer.new()
	hero_vbox.add_theme_constant_override("separation", 14)
	hero_panel.add_child(hero_vbox)

	var hero_header := HBoxContainer.new()
	hero_header.add_theme_constant_override("separation", 18)
	hero_vbox.add_child(hero_header)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(112, 112)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = AssetLoader.load_texture_or_placeholder(
		"res://Assets/Characters/portrait_ratu.png", Vector2i(128, 128), AssetLoader.COLOR_TERRACOTTA, AssetLoader.COLOR_GOLD, "crown"
	)
	hero_header.add_child(portrait)

	var title_col := VBoxContainer.new()
	title_col.alignment = BoxContainer.ALIGNMENT_CENTER
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_header.add_child(title_col)

	var hero_title := Label.new()
	hero_title.text = "Ratu Kalinyamat (Retna Kencana)"
	hero_title.add_theme_font_size_override("font_size", 24)
	hero_title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title_col.add_child(hero_title)

	var hero_sub := Label.new()
	hero_sub.text = "Rainha de Japara • De Kranige Dame • Pahlawan Nasional RI (2023)"
	hero_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_sub.add_theme_font_size_override("font_size", 15)
	hero_sub.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	title_col.add_child(hero_sub)

	var hero_desc := RichTextLabel.new()
	hero_desc.bbcode_enabled = true
	hero_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero_desc.text = (
		"Telusuri perjalanan bersejarah [color=#D4A24C][b]Ratu Kalinyamat[/b][/color], penguasa Jepara abad ke-16 "
		+ "yang membangun kejayaan ekonomi maritim, seni ukir Mantingan, diplomasi Nusantara, serta mengirimkan armada laut besar ke Malaka.\n\n"
		+ "[b]Tiga Babak Pembelajaran:[/b]\n"
		+ "• [color=#F5EAD6]Level 1 — Putri dari Demak[/color] (Kronologi Konflik Demak & Investigasi Kritis Danaraja)\n"
		+ "• [color=#F5EAD6]Level 2 — Kejayaan Maritim Jepara[/color] (Niaga Commenda & Diplomasi Johor, Hitu, Aceh)\n"
		+ "• [color=#F5EAD6]Level 3 — Armada ke Malaka[/color] (Strategi 1551 & 1574, Galeri Warisan & Evaluasi 10 Soal)\n\n"
		+ "[color=#E2D0B1]Setiap dialog dan arsip dilengkapi label transparansi sumber: [b]FAKTA[/b], [b]TRADISI[/b], atau [b]FIKSI GAME[/b].[/color]"
	)
	hero_vbox.add_child(hero_desc)

	# Right Menu Panel
	var menu_panel := PanelContainer.new()
	menu_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_panel.size_flags_stretch_ratio = 0.75
	menu_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 2, 24))
	content_row.add_child(menu_panel)

	var menu_vbox := VBoxContainer.new()
	menu_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_vbox.add_theme_constant_override("separation", 12)
	menu_panel.add_child(menu_vbox)

	var menu_heading := Label.new()
	menu_heading.text = "MENU UTAMA"
	menu_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_heading.add_theme_font_size_override("font_size", 20)
	menu_heading.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	menu_vbox.add_child(menu_heading)

	_play_button = Button.new()
	_play_button.name = "PlayButton"
	_play_button.custom_minimum_size = Vector2(0, 48)
	_play_button.pressed.connect(_on_play_pressed)
	menu_vbox.add_child(_play_button)

	var level_btn := Button.new()
	level_btn.name = "LevelSelectButton"
	level_btn.text = "Pilih Level & Lencana"
	level_btn.custom_minimum_size = Vector2(0, 44)
	level_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	level_btn.pressed.connect(_on_level_select_pressed)
	menu_vbox.add_child(level_btn)

	var help_btn := Button.new()
	help_btn.name = "InstructionsButton"
	help_btn.text = "Petunjuk Bermain"
	help_btn.custom_minimum_size = Vector2(0, 44)
	help_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	help_btn.pressed.connect(_on_instructions_pressed)
	menu_vbox.add_child(help_btn)

	var about_btn := Button.new()
	about_btn.name = "AboutButton"
	about_btn.text = "Tentang & Sumber Sejarah"
	about_btn.custom_minimum_size = Vector2(0, 44)
	about_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	about_btn.pressed.connect(_on_about_pressed)
	menu_vbox.add_child(about_btn)

	var reset_btn := Button.new()
	reset_btn.name = "ResetButton"
	reset_btn.text = "Reset Progres"
	reset_btn.custom_minimum_size = Vector2(0, 40)
	reset_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_TERRACOTTA))
	reset_btn.pressed.connect(_on_reset_pressed)
	menu_vbox.add_child(reset_btn)

	if not OS.has_feature("web"):
		var quit_btn := Button.new()
		quit_btn.name = "QuitButton"
		quit_btn.text = "Keluar"
		quit_btn.custom_minimum_size = Vector2(0, 40)
		quit_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_BG_DEEP, AssetLoader.COLOR_CREAM_DARK))
		quit_btn.pressed.connect(_on_quit_pressed)
		menu_vbox.add_child(quit_btn)

	# Footer status strip
	var status_panel := PanelContainer.new()
	status_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 8, 1, 10))
	root_vbox.add_child(status_panel)

	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_font_size_override("font_size", 15)
	_stats_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM)
	status_panel.add_child(_stats_label)

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Konfirmasi Reset Progres"
	_confirm_dialog.dialog_text = "Apakah Anda yakin ingin menghapus seluruh skor, arsip, lencana, dan progres level yang tersimpan?"
	_confirm_dialog.ok_button_text = "Ya, Reset"
	_confirm_dialog.cancel_button_text = "Batal"
	_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(_confirm_dialog)
