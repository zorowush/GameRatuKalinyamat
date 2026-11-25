extends Control
## Layar Tentang Game, Tim Pengembang & Daftar Pustaka Referensi Sejarah (S1-S4).

const REF_PATH := "res://Data/Historical_Data/references.json"


func _ready() -> void:
	theme = AssetLoader.build_theme()
	_build_ui()


func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)


func _build_ui() -> void:
	var data: Variant = AssetLoader.load_json_file(REF_PATH)
	var ref_dict: Dictionary = data if data is Dictionary else {}

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "TENTANG GAME & REFERENSI SEJARAH"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_btn := Button.new()
	back_btn.text = "◀ Kembali ke Menu Utama"
	back_btn.custom_minimum_size = Vector2(220, 42)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	# Panel Tim Pengembang
	var team_panel := PanelContainer.new()
	team_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 2, 18))
	content.add_child(team_panel)

	var team_box := VBoxContainer.new()
	team_box.add_theme_constant_override("separation", 8)
	team_panel.add_child(team_box)

	var course_lbl := Label.new()
	course_lbl.text = "%s • Dosen Pengampu: %s" % [
		str(ref_dict.get("course", "Mata Kuliah Game Programming")),
		str(ref_dict.get("lecturer", "A. Faiq Abror")),
	]
	course_lbl.add_theme_font_size_override("font_size", 16)
	course_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	team_box.add_child(course_lbl)

	var members: Variant = ref_dict.get("team", [])
	if members is Array:
		for m in members:
			if m is Dictionary:
				var line := Label.new()
				line.text = "• %s — %s (%s)" % [str(m.get("name", "")), str(m.get("role", "")), str(m.get("scope", ""))]
				line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				team_box.add_child(line)

	# Panel Kebijakan Sejarah
	var policy_panel := PanelContainer.new()
	policy_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_SEA_TEAL, 12, 2, 16))
	content.add_child(policy_panel)

	var policy_lbl := Label.new()
	policy_lbl.text = "Prinsip Akurasi Sejarah: " + str(ref_dict.get("historical_policy", ""))
	policy_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	policy_panel.add_child(policy_lbl)

	# Panel Daftar Pustaka S1-S4
	var ref_panel := PanelContainer.new()
	ref_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 2, 18))
	content.add_child(ref_panel)

	var ref_box := VBoxContainer.new()
	ref_box.add_theme_constant_override("separation", 10)
	ref_panel.add_child(ref_box)

	var ref_heading := Label.new()
	ref_heading.text = "Daftar Referensi Sejarah Utama"
	ref_heading.add_theme_font_size_override("font_size", 20)
	ref_heading.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	ref_box.add_child(ref_heading)

	var refs: Variant = ref_dict.get("references", [])
	if refs is Array:
		for r in refs:
			if r is Dictionary:
				var r_lbl := Label.new()
				r_lbl.text = "[%s] %s" % [str(r.get("code", "")), str(r.get("citation", ""))]
				r_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				ref_box.add_child(r_lbl)
