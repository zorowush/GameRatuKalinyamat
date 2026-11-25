extends Control
## Layar Pilih Level menampilkan 3 bab sejarah, status kunci/terbuka, dan lencana.


func _ready() -> void:
	theme = AssetLoader.build_theme()
	_build_ui()


func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)


func _on_level_pressed(scene_path: String) -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(scene_path)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "PILIH LEVEL & KOLEKSI LENCANA"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	if GameManager.is_level_completed(3):
		var ending_btn := Button.new()
		ending_btn.text = "Lihat Ringkasan & Epilog"
		ending_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
		ending_btn.pressed.connect(_on_level_pressed.bind(SceneManager.SCENE_ENDING))
		header.add_child(ending_btn)

	var back_btn := Button.new()
	back_btn.text = "◀ Menu Utama"
	back_btn.custom_minimum_size = Vector2(160, 42)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 20)
	vbox.add_child(cards_row)

	var level_specs := [
		{
			"num": 1,
			"title": "Level 1\nPutri dari Demak",
			"desc": "Selidiki kronologi konflik Demak, tafsir simbolis Pertapaan Danaraja (Sejarah vs Mitos), dan penobatan Ratu Kalinyamat 1549.",
			"badge": GameManager.BADGE_LEVEL_1,
			"badge_path": "res://Assets/UI/badge_penyelidik.png",
			"motif": "scroll",
			"scene": SceneManager.SCENE_LEVEL_1,
		},
		{
			"num": 2,
			"title": "Level 2\nKejayaan Maritim Jepara",
			"desc": "Kelola niaga sistem commenda di 4 pelabuhan Jepara, kenali seni ukir Mantingan, dan jalin diplomasi dengan Johor, Hitu, serta Aceh.",
			"badge": GameManager.BADGE_LEVEL_2,
			"badge_path": "res://Assets/UI/badge_ratu_bandar.png",
			"motif": "ship",
			"scene": SceneManager.SCENE_LEVEL_2,
		},
		{
			"num": 3,
			"title": "Level 3\nArmada ke Malaka",
			"desc": "Pimpin strategi & refleksi objektif Ekspedisi Malaka 1551 & 1574, tinjau Galeri Warisan Mantingan, lalu tuntaskan Evaluasi 10 Soal.",
			"badge": GameManager.BADGE_LEVEL_3,
			"badge_path": "res://Assets/UI/badge_kranige_dame.png",
			"motif": "crown",
			"scene": SceneManager.SCENE_LEVEL_3,
		},
	]

	for spec in level_specs:
		cards_row.add_child(_make_level_card(spec))


func _make_level_card(spec: Dictionary) -> PanelContainer:
	var lv_num: int = int(spec["num"])
	var unlocked := GameManager.is_level_unlocked(lv_num)
	var completed := GameManager.is_level_completed(lv_num)
	var badge_name: String = str(spec["badge"])
	var has_badge := GameManager.has_badge(badge_name)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var border_col := AssetLoader.COLOR_GOLD if unlocked else Color("#66554A")
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, border_col, 14, 2, 20))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(96, 96)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var bg_col := AssetLoader.COLOR_SEA_TEAL if unlocked else Color("#40342E")
	icon.texture = AssetLoader.load_texture_or_placeholder(
		str(spec["badge_path"]), Vector2i(96, 96), bg_col, AssetLoader.COLOR_GOLD, str(spec["motif"])
	)
	col.add_child(icon)

	var title_lbl := Label.new()
	title_lbl.text = str(spec["title"])
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD if unlocked else Color("#9E8D80"))
	col.add_child(title_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = str(spec["desc"])
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.add_theme_font_size_override("font_size", 14)
	col.add_child(desc_lbl)

	var badge_lbl := Label.new()
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if has_badge:
		badge_lbl.text = "★ Lencana Diraih: %s" % badge_name
		badge_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	else:
		badge_lbl.text = "Lencana: %s (Belum diraih)" % badge_name
		badge_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	col.add_child(badge_lbl)

	var play_btn := Button.new()
	play_btn.custom_minimum_size = Vector2(0, 44)
	play_btn.disabled = not unlocked
	if not unlocked:
		play_btn.text = "🔒 Terkunci (Selesaikan Level %d)" % (lv_num - 1)
	elif completed:
		play_btn.text = "Mainkan Ulang ✓"
		play_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	else:
		play_btn.text = "Mulai Level %d ▶" % lv_num
	play_btn.pressed.connect(_on_level_pressed.bind(str(spec["scene"])))
	col.add_child(play_btn)

	return panel
