extends Control
## Tantangan 1A: Menyusun 5 peristiwa konflik suksesi Kesultanan Demak secara kronologis.

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level1_chronology.json"

var _data: Dictionary = {}
var _current_order: Array = []
var _list_box: VBoxContainer
var _feedback_label: RichTextLabel
var _check_btn: Button
var _finish_btn: Button
var _solved: bool = false


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	_init_scrambled_order()
	_build_ui()
	_render_cards()


func _init_scrambled_order() -> void:
	var events: Variant = _data.get("events", [])
	_current_order.clear()
	if not (events is Array) or events.is_empty():
		return
	var scramble := [2, 4, 0, 3, 1]
	if events.size() == scramble.size():
		for idx in scramble:
			_current_order.append(events[idx])
	else:
		_current_order = events.duplicate()


func _move_item(index: int, direction: int) -> void:
	if _solved:
		return
	var target := index + direction
	if target < 0 or target >= _current_order.size():
		return
	AudioManager.play_sfx("click")
	var tmp: Variant = _current_order[index]
	_current_order[index] = _current_order[target]
	_current_order[target] = tmp
	_render_cards()


func _on_check_pressed() -> void:
	var wrong_positions: Array[int] = []
	for i in range(_current_order.size()):
		var item: Dictionary = _current_order[i]
		if int(item.get("order", -1)) != i + 1:
			wrong_positions.append(i + 1)

	if wrong_positions.is_empty():
		_solved = true
		var gained := GameManager.add_challenge_score("l1_chronology_solved", true)
		AudioManager.play_sfx("correct")
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_feedback_label.text = "[color=#56E38B][b]✓ BENAR (%s)![/b][/color] " % pts_note + str(_data.get("success_summary", ""))
		_check_btn.visible = false
		_finish_btn.visible = true
		_render_cards(true)
	else:
		GameManager.add_challenge_score("l1_chronology_solved", false)
		AudioManager.play_sfx("wrong")
		var pos_str := ", ".join(wrong_positions.map(func(n): return str(n)))
		_feedback_label.text = (
			"[color=#FF867A][b]✕ Urutan belum tepat (0 Poin).[/b][/color] "
			+ "Periksa kembali posisi nomor [b]%s[/b]. " % pos_str
			+ "Petunjuk: Konflik dimulai dari gugurnya Pangeran Sekar, berlanjut ke Sunan Prawata (1549), gugurnya Pangeran Hadiri, Pertapaan Danaraja, lalu penobatan Ratu Kalinyamat. Silakan atur ulang dan coba lagi!"
		)


func _render_cards(show_verified: bool = false) -> void:
	for c in _list_box.get_children():
		_list_box.remove_child(c)
		c.queue_free()

	for i in range(_current_order.size()):
		var ev: Dictionary = _current_order[i]
		var card := PanelContainer.new()
		var border := AssetLoader.COLOR_SUCCESS if show_verified else AssetLoader.COLOR_GOLD
		card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, border, 8, 2, 10))
		_list_box.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)

		var num_lbl := Label.new()
		num_lbl.text = "#%d" % (i + 1)
		num_lbl.custom_minimum_size = Vector2(36, 0)
		num_lbl.add_theme_font_size_override("font_size", 20)
		num_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
		row.add_child(num_lbl)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)
		row.add_child(info)

		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 8)
		info.add_child(head)

		var t := Label.new()
		t.text = str(ev.get("title", ""))
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.add_theme_font_size_override("font_size", 16)
		t.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(t)

		var tag := str(ev.get("source_tag", "FAKTA")).to_upper()
		var badge := PanelContainer.new()
		badge.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))
		head.add_child(badge)
		var bl := Label.new()
		bl.text = tag
		bl.add_theme_font_size_override("font_size", 11)
		badge.add_child(bl)

		var desc := Label.new()
		desc.text = str(ev.get("description", ""))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 13)
		desc.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
		info.add_child(desc)

		if not _solved:
			var btns := VBoxContainer.new()
			btns.add_theme_constant_override("separation", 4)
			row.add_child(btns)

			var up_btn := Button.new()
			up_btn.text = "▲"
			up_btn.custom_minimum_size = Vector2(40, 28)
			up_btn.disabled = (i == 0)
			up_btn.pressed.connect(_move_item.bind(i, -1))
			btns.add_child(up_btn)

			var down_btn := Button.new()
			down_btn.text = "▼"
			down_btn.custom_minimum_size = Vector2(40, 28)
			down_btn.disabled = (i == _current_order.size() - 1)
			down_btn.pressed.connect(_move_item.bind(i, 1))
			btns.add_child(down_btn)


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.78)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 72)
	margin.add_theme_constant_override("margin_right", 72)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 20))
	margin.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = str(_data.get("title", "Tantangan 1A: Kronologi Konflik Demak"))
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

	var inst := Label.new()
	inst.text = str(_data.get("instruction", ""))
	inst.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inst.add_theme_font_size_override("font_size", 14)
	vbox.add_child(inst)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_list_box = VBoxContainer.new()
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_box.add_theme_constant_override("separation", 8)
	scroll.add_child(_list_box)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.custom_minimum_size = Vector2(0, 62)
	_feedback_label.add_theme_font_size_override("normal_font_size", 14)
	_feedback_label.text = "[color=#E2D0B1]Gunakan tombol ▲ / ▼ untuk mengurutkan peristiwa 1 sampai 5, lalu tekan Periksa Urutan.[/color]"
	vbox.add_child(_feedback_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 12)
	vbox.add_child(footer)

	_check_btn = Button.new()
	_check_btn.text = "Periksa Urutan ✓"
	_check_btn.custom_minimum_size = Vector2(200, 42)
	_check_btn.pressed.connect(_on_check_pressed)
	footer.add_child(_check_btn)

	_finish_btn = Button.new()
	_finish_btn.text = "Lanjutkan Petualangan ▶"
	_finish_btn.custom_minimum_size = Vector2(240, 42)
	_finish_btn.visible = false
	_finish_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	_finish_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		challenge_completed.emit(true)
	)
	footer.add_child(_finish_btn)
