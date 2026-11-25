extends Control
## Layar Akhir Permainan & Rangkuman Edukasi Sejarah Ratu Kalinyamat.
## Menampilkan total skor, persentase evaluasi, 3 lencana, epilog 2023, dan referensi S1-S4.

const REF_PATH := "res://Data/Historical_Data/references.json"


func _ready() -> void:
	theme = AssetLoader.build_theme()
	AudioManager.play_bgm("bgm_menu")
	_build_ui()


func _build_ui() -> void:
	var ref_loaded: Variant = AssetLoader.load_json_file(REF_PATH)
	var ref_dict: Dictionary = ref_loaded if ref_loaded is Dictionary else {}

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	# Title Banner
	var heading := Label.new()
	heading.text = "JEJAK SANG RATU SELESAI — WARISAN KEJAYAAN JEPARA"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	vbox.add_child(heading)

	# Score & Quiz Summary Strip
	var stats_panel := PanelContainer.new()
	stats_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_TERRACOTTA_DARK, AssetLoader.COLOR_GOLD, 10, 2, 14))
	vbox.add_child(stats_panel)

	var stats_row := HBoxContainer.new()
	stats_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_row.add_theme_constant_override("separation", 36)
	stats_panel.add_child(stats_row)

	stats_row.add_child(_make_stat_item("TOTAL SKOR", "%d Poin" % GameManager.total_score))
	stats_row.add_child(_make_stat_item("EVALUASI AKHIR", "%d/%d (%.0f%%)" % [GameManager.quiz_correct, GameManager.quiz_total, GameManager.quiz_percentage]))
	stats_row.add_child(_make_stat_item("ARSIP SEJARAH", "%d / 9 Arsip" % GameManager.get_archive_count()))
	stats_row.add_child(_make_stat_item("LENCANA", "%d / 3 Diraih" % GameManager.badges.size()))

	# Split Content: Badges + Epilogue & References
	var mid_row := HBoxContainer.new()
	mid_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid_row.add_theme_constant_override("separation", 18)
	vbox.add_child(mid_row)

	# Left: Badge Showcase
	var badge_panel := PanelContainer.new()
	badge_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_panel.size_flags_stretch_ratio = 0.85
	badge_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 2, 18))
	mid_row.add_child(badge_panel)

	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 10)
	badge_panel.add_child(bv)

	var bh := Label.new()
	bh.text = "KOLEKSI LENCANA KEHORMATAN"
	bh.add_theme_font_size_override("font_size", 18)
	bh.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	bv.add_child(bh)

	var badge_defs := [
		{"name": GameManager.BADGE_LEVEL_1, "cond": "Selesaikan Level 1 (Putri dari Demak)", "path": "res://Assets/UI/badge_penyelidik.png", "motif": "scroll"},
		{"name": GameManager.BADGE_LEVEL_2, "cond": "Selesaikan Level 2 (Kejayaan Maritim Jepara)", "path": "res://Assets/UI/badge_ratu_bandar.png", "motif": "ship"},
		{"name": GameManager.BADGE_LEVEL_3, "cond": "Evaluasi Akhir Level 3 ≥ 70%", "path": "res://Assets/UI/badge_kranige_dame.png", "motif": "crown"},
	]

	for bdef in badge_defs:
		var bname: String = str(bdef["name"])
		var owned := GameManager.has_badge(bname)
		var bcard := PanelContainer.new()
		var bcol := AssetLoader.COLOR_SEA_TEAL_DARK if owned else AssetLoader.COLOR_DARK_BROWN
		bcard.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(bcol, AssetLoader.COLOR_GOLD if owned else Color("#66554A"), 8, 2, 10))
		bv.add_child(bcard)

		var brow := HBoxContainer.new()
		brow.add_theme_constant_override("separation", 12)
		bcard.add_child(brow)

		var bicon := TextureRect.new()
		bicon.custom_minimum_size = Vector2(54, 54)
		bicon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bicon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bicon.texture = AssetLoader.load_texture_or_placeholder(
			str(bdef["path"]), Vector2i(64, 64), AssetLoader.COLOR_TERRACOTTA if owned else Color("#3E322C"), AssetLoader.COLOR_GOLD, str(bdef["motif"])
		)
		brow.add_child(bicon)

		var binfo := VBoxContainer.new()
		binfo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		brow.add_child(binfo)

		var btitle := Label.new()
		btitle.text = ("★ %s (DIRAIH)" % bname) if owned else ("%s (Belum diraih)" % bname)
		btitle.add_theme_font_size_override("font_size", 15)
		btitle.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD if owned else Color("#A59487"))
		binfo.add_child(btitle)

		var bcond := Label.new()
		bcond.text = str(bdef["cond"])
		bcond.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bcond.add_theme_font_size_override("font_size", 12)
		bcond.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
		binfo.add_child(bcond)

	# Right: Historical Epilogue & References
	var ep_panel := PanelContainer.new()
	ep_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ep_panel.size_flags_stretch_ratio = 1.25
	ep_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 2, 18))
	mid_row.add_child(ep_panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ep_panel.add_child(scroll)

	var ep_box := VBoxContainer.new()
	ep_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ep_box.add_theme_constant_override("separation", 10)
	scroll.add_child(ep_box)

	var ep_h := Label.new()
	ep_h.text = "EPILOG SEJARAH & PENGAKUAN PAHLAWAN NASIONAL"
	ep_h.add_theme_font_size_override("font_size", 18)
	ep_h.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	ep_box.add_child(ep_h)

	var ep_text := RichTextLabel.new()
	ep_text.bbcode_enabled = true
	ep_text.fit_content = true
	ep_text.add_theme_font_size_override("normal_font_size", 15)
	ep_text.text = (
		"Ratu Kalinyamat (Retna Kencana) memerintah Jepara dari 1549/1550 hingga wafatnya pada [b]1579[/b] dan dimakamkan di kompleks [b]Masjid Mantingan[/b] (dibangun 1559 M / 1481 Saka, candrasengkala [i]Rupa Brahmana Warna Sari[/i]).\n\n"
		+ "Selain memajukan perniagaan maritim sistem [i]commenda[/i] di 4 pelabuhan (Jepara, Juana, Rembang, Lasem), diplomasi Nusantara (Johor, Hitu, Aceh), seni ukir Mantingan, dan Benteng Kalinyamat (±5–6 km), keberaniannya mengirimkan armada ke Malaka pada 1551 dan 1574 membuatnya dihormati hingga catatan kronik Portugis ([i]Rainha de Japara[/i] & [i]De Kranige Dame[/i]).\n\n"
		+ "[color=#D4A24C][b]Penghargaan Negara:[/b] Pada tanggal [b]10 November 2023[/b], Pemerintah Republik Indonesia secara resmi menetapkan Ratu Kalinyamat sebagai [b]Pahlawan Nasional Republik Indonesia[/b].[/color]"
	)
	ep_box.add_child(ep_text)

	var ref_h := Label.new()
	ref_h.text = "Daftar Referensi Utama:"
	ref_h.add_theme_font_size_override("font_size", 15)
	ref_h.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	ep_box.add_child(ref_h)

	var refs: Variant = ref_dict.get("references", [])
	if refs is Array:
		for r in refs:
			if r is Dictionary:
				var rl := Label.new()
				rl.text = "[%s] %s" % [str(r.get("code", "")), str(r.get("citation", ""))]
				rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				rl.add_theme_font_size_override("font_size", 12)
				rl.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
				ep_box.add_child(rl)

	# Bottom Actions
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 16)
	vbox.add_child(footer)

	var replay_btn := Button.new()
	replay_btn.text = "Main Lagi dari Awal (Reset) ↻"
	replay_btn.custom_minimum_size = Vector2(250, 44)
	replay_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_TERRACOTTA))
	replay_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		GameManager.reset_progress()
		MissionManager.reset_runtime_steps()
		SceneManager.change_scene(SceneManager.SCENE_LEVEL_1)
	)
	footer.add_child(replay_btn)

	var select_btn := Button.new()
	select_btn.text = "Pilih Level & Ulangi Kuis"
	select_btn.custom_minimum_size = Vector2(230, 44)
	select_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	select_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		SceneManager.change_scene(SceneManager.SCENE_LEVEL_SELECT)
	)
	footer.add_child(select_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Kembali ke Menu Utama"
	menu_btn.custom_minimum_size = Vector2(230, 44)
	menu_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)
	)
	footer.add_child(menu_btn)


func _make_stat_item(label_text: String, value_text: String) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	var l := Label.new()
	l.text = label_text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	col.add_child(l)
	var v := Label.new()
	v.text = value_text
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_theme_font_size_override("font_size", 20)
	v.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	col.add_child(v)
	return col
