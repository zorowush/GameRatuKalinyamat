extends Control
## Tantangan 2B: Simulasi Diplomasi Aliansi Maritim Nusantara (Johor 1550, Hitu 1565, Aceh 1573).

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level2_diplomacy.json"

var _data: Dictionary = {}
var _missions: Array = []
var _idx: int = 0
var _answered: bool = false

var _envoy_label: Label
var _progress_label: Label
var _tag_panel: PanelContainer
var _tag_label: Label
var _petition_label: Label
var _options_box: VBoxContainer
var _feedback_label: RichTextLabel
var _next_btn: Button


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	var raw_missions: Variant = _data.get("missions", [])
	_missions = raw_missions if raw_missions is Array else []
	_build_ui()
	_show_mission()


func _show_mission() -> void:
	if _idx >= _missions.size():
		challenge_completed.emit(true)
		return

	_answered = false
	var m: Dictionary = _missions[_idx]
	_progress_label.text = "Audiensi Utusan %d / %d" % [_idx + 1, _missions.size()]
	_envoy_label.text = str(m.get("envoy_name", ""))
	_petition_label.text = str(m.get("petition", ""))

	var tag := str(m.get("source_tag", "FAKTA")).to_upper()
	_tag_label.text = tag
	_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))

	for c in _options_box.get_children():
		_options_box.remove_child(c)
		c.queue_free()

	var options: Array = m.get("options", [])
	for i in range(options.size()):
		var opt: Dictionary = options[i]
		var btn := Button.new()
		btn.text = "%s. %s" % [char(65 + i), str(opt.get("text", ""))]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
		btn.pressed.connect(_on_option_chosen.bind(i))
		_options_box.add_child(btn)

	_feedback_label.text = "[color=#E2D0B1]Pilih tanggapan diplomatik Ratu Kalinyamat untuk utusan ini.[/color]"
	_next_btn.visible = false


func _on_option_chosen(opt_idx: int) -> void:
	if _answered or _idx >= _missions.size():
		return
	var m: Dictionary = _missions[_idx]
	var options: Array = m.get("options", [])
	var chosen: Dictionary = options[opt_idx]
	var step_id := "l2_dip_" + str(m.get("id", str(_idx)))

	if bool(chosen.get("is_correct", false)):
		_answered = true
		var gained := GameManager.add_challenge_score(step_id, true)
		AudioManager.play_sfx("correct")
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_feedback_label.text = "[color=#56E38B][b]✓ KEPUTUSAN DIPLOMATIK TEPAT (%s)![/b][/color] " % pts_note + str(chosen.get("feedback", ""))
		for child in _options_box.get_children():
			if child is Button:
				child.disabled = true
		_next_btn.visible = true
		_next_btn.text = "Selesai Diplomasi ✓" if _idx == _missions.size() - 1 else "Sambut Utusan Berikutnya ▶"
	else:
		GameManager.add_challenge_score(step_id, false)
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]✕ Kurang Tepat (0 Poin).[/b][/color] " + str(chosen.get("feedback", "")) + " Silakan pertimbangkan kembali pilihan lainnya!"


func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	_idx += 1
	_show_mission()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.80)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 74)
	margin.add_theme_constant_override("margin_right", 74)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 22))
	margin.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = str(_data.get("title", "Tantangan 2B: Simulasi Diplomasi Nusantara"))
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "Tutup ✕"
	close_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	close_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		challenge_closed.emit()
	)
	header.add_child(close_btn)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_SEA_TEAL, 10, 2, 16))
	vbox.add_child(card)

	var card_row := HBoxContainer.new()
	card_row.add_theme_constant_override("separation", 16)
	card.add_child(card_row)

	var envoy_portrait := TextureRect.new()
	envoy_portrait.custom_minimum_size = Vector2(92, 92)
	envoy_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	envoy_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	envoy_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	envoy_portrait.texture = AssetLoader.load_texture_or_placeholder(
		"res://Assets/Characters/portrait_utusan.png", Vector2i(96, 96), AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD, "ship"
	)
	card_row.add_child(envoy_portrait)

	var cv := VBoxContainer.new()
	cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cv.add_theme_constant_override("separation", 8)
	card_row.add_child(cv)

	var ch := HBoxContainer.new()
	cv.add_child(ch)

	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 14)
	_progress_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch.add_child(_progress_label)

	_tag_panel = PanelContainer.new()
	ch.add_child(_tag_panel)
	_tag_label = Label.new()
	_tag_label.add_theme_font_size_override("font_size", 12)
	_tag_panel.add_child(_tag_label)

	_envoy_label = Label.new()
	_envoy_label.add_theme_font_size_override("font_size", 22)
	_envoy_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	cv.add_child(_envoy_label)

	_petition_label = Label.new()
	_petition_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_petition_label.add_theme_font_size_override("font_size", 16)
	cv.add_child(_petition_label)

	_options_box = VBoxContainer.new()
	_options_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_options_box.add_theme_constant_override("separation", 10)
	vbox.add_child(_options_box)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.custom_minimum_size = Vector2(0, 68)
	_feedback_label.add_theme_font_size_override("normal_font_size", 15)
	vbox.add_child(_feedback_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(footer)

	_next_btn = Button.new()
	_next_btn.text = "Sambut Utusan Berikutnya ▶"
	_next_btn.custom_minimum_size = Vector2(240, 42)
	_next_btn.visible = false
	_next_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	_next_btn.pressed.connect(_on_next_pressed)
	footer.add_child(_next_btn)
