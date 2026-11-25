extends Control
## Tantangan 2A: Simulasi Niaga Commenda & Klasifikasi Komoditas (6 Giliran).

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level2_trade.json"

var _data: Dictionary = {}
var _turns: Array = []
var _turn_idx: int = 0
var _turn_answered: bool = false

var _progress_label: Label
var _commodity_label: Label
var _origin_label: Label
var _desc_label: Label
var _tag_panel: PanelContainer
var _tag_label: Label
var _ports_row: HBoxContainer
var _feedback_label: RichTextLabel
var _next_btn: Button


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	var raw_turns: Variant = _data.get("turns", [])
	_turns = raw_turns if raw_turns is Array else []
	_build_ui()
	_show_turn()


func _show_turn() -> void:
	if _turn_idx >= _turns.size():
		challenge_completed.emit(true)
		return

	_turn_answered = false
	var turn: Dictionary = _turns[_turn_idx]
	_progress_label.text = "Giliran Niaga %d / %d" % [_turn_idx + 1, _turns.size()]
	_commodity_label.text = "Komoditas: " + str(turn.get("commodity", ""))
	_origin_label.text = "Asal Pelabuhan: " + str(turn.get("origin_port", ""))
	_desc_label.text = str(turn.get("description", ""))

	var tag := str(turn.get("source_tag", "FAKTA")).to_upper()
	_tag_label.text = tag
	_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))

	_feedback_label.text = "[color=#E2D0B1]Pilih bandar tujuan paling tepat untuk muatan commenda ini.[/color]"
	_next_btn.visible = false
	_set_port_buttons_disabled(false)


func _on_port_chosen(port_name: String) -> void:
	if _turn_answered or _turn_idx >= _turns.size():
		return
	var turn: Dictionary = _turns[_turn_idx]
	var correct_port := str(turn.get("correct_port", ""))
	var step_id := "l2_trade_" + str(turn.get("id", str(_turn_idx)))

	if port_name == correct_port:
		_turn_answered = true
		GameManager.add_challenge_score(step_id, true)
		AudioManager.play_sfx("correct")
		_feedback_label.text = "[color=#56E38B][b]✓ TEPAT (+10 Poin)![/b][/color] " + str(turn.get("feedback_correct", ""))
		_set_port_buttons_disabled(true)
		_next_btn.visible = true
		_next_btn.text = "Selesai & Simpan Hasil ✓" if _turn_idx == _turns.size() - 1 else "Giliran Berikutnya ▶"
	else:
		GameManager.add_challenge_score(step_id, false)
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]✕ Belum Tepat (0 Poin).[/b][/color] " + str(turn.get("feedback_wrong", "")) + " Silakan coba pilih rute pelabuhan lain!"


func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	_turn_idx += 1
	_show_turn()


func _set_port_buttons_disabled(disabled_state: bool) -> void:
	for child in _ports_row.get_children():
		if child is Button:
			child.disabled = disabled_state


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
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
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
	title.text = str(_data.get("title", "Tantangan 2A: Simulasi Niaga Commenda"))
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

	# Kartu info sistem Commenda
	var info_box := PanelContainer.new()
	info_box.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_SEA_TEAL_DARK, AssetLoader.COLOR_GOLD, 8, 1, 12))
	vbox.add_child(info_box)

	var info_lbl := Label.new()
	info_lbl.text = str(_data.get("commenda_info", ""))
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_lbl.add_theme_font_size_override("font_size", 14)
	info_box.add_child(info_lbl)

	# Kartu Komoditas aktif
	var turn_card := PanelContainer.new()
	turn_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	turn_card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 10, 2, 18))
	vbox.add_child(turn_card)

	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 10)
	turn_card.add_child(tv)

	var th := HBoxContainer.new()
	tv.add_child(th)

	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 15)
	_progress_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	th.add_child(_progress_label)

	_tag_panel = PanelContainer.new()
	th.add_child(_tag_panel)
	_tag_label = Label.new()
	_tag_label.add_theme_font_size_override("font_size", 12)
	_tag_panel.add_child(_tag_label)

	_commodity_label = Label.new()
	_commodity_label.add_theme_font_size_override("font_size", 22)
	_commodity_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	tv.add_child(_commodity_label)

	_origin_label = Label.new()
	_origin_label.add_theme_font_size_override("font_size", 15)
	_origin_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	tv.add_child(_origin_label)

	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_size_override("font_size", 17)
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tv.add_child(_desc_label)

	var choose_lbl := Label.new()
	choose_lbl.text = "Pilih Rute Pelabuhan Tujuan:"
	choose_lbl.add_theme_font_size_override("font_size", 15)
	choose_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	vbox.add_child(choose_lbl)

	_ports_row = HBoxContainer.new()
	_ports_row.add_theme_constant_override("separation", 12)
	vbox.add_child(_ports_row)

	var ports: Array = _data.get("ports", ["Malaka", "Maluku", "Banten", "Makassar"])
	for p in ports:
		var pname := str(p)
		var btn := Button.new()
		btn.text = "⚓ " + pname
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
		btn.pressed.connect(_on_port_chosen.bind(pname))
		_ports_row.add_child(btn)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.custom_minimum_size = Vector2(0, 66)
	_feedback_label.add_theme_font_size_override("normal_font_size", 15)
	vbox.add_child(_feedback_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(footer)

	_next_btn = Button.new()
	_next_btn.text = "Giliran Berikutnya ▶"
	_next_btn.custom_minimum_size = Vector2(230, 42)
	_next_btn.visible = false
	_next_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	_next_btn.pressed.connect(_on_next_pressed)
	footer.add_child(_next_btn)
