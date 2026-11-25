extends Control
## Tantangan 1B: Investigasi "Sejarah atau Mitos?" (Tapa Wuda di Danaraja secara simbolis).
## Pemain membaca 4 kartu bukti lintas sumber, mencentang minimal 2 kartu pendukung,
## dan memilih kesimpulan sejarah yang kritis & objektif.

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level1_tapa_investigation.json"

var _data: Dictionary = {}
var _evidence_checks: Dictionary = {}
var _selected_conclusion_idx: int = -1
var _conclusion_buttons: Array[Button] = []
var _feedback_label: RichTextLabel
var _verify_btn: Button
var _finish_btn: Button
var _solved: bool = false


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	_build_ui()


func _select_conclusion(idx: int) -> void:
	if _solved:
		return
	AudioManager.play_sfx("click")
	_selected_conclusion_idx = idx
	for i in range(_conclusion_buttons.size()):
		var btn := _conclusion_buttons[i]
		if i == idx:
			btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
		else:
			btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_CREAM_DARK))


func _on_verify_pressed() -> void:
	var checked_count := 0
	for cid in _evidence_checks.keys():
		var cb: CheckBox = _evidence_checks[cid]
		if cb.button_pressed:
			checked_count += 1

	if checked_count < 2:
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]Pilih minimal 2 kartu bukti pendukung[/b][/color] terlebih dahulu agar kesimpulanmu berbasis bukti lintas sumber!"
		return

	if _selected_conclusion_idx < 0:
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]Pilih salah satu kesimpulan[/b][/color] di bagian bawah sebelum memverifikasi."
		return

	var conclusions: Array = _data.get("conclusions", [])
	var chosen: Dictionary = conclusions[_selected_conclusion_idx]
	var is_correct := bool(chosen.get("is_correct", false))
	var fb := str(chosen.get("feedback", ""))

	if is_correct:
		_solved = true
		var gained := GameManager.add_challenge_score("l1_tapa_solved", true)
		AudioManager.play_sfx("correct")
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_feedback_label.text = "[color=#56E38B][b]✓ ANALISIS TEPAT (%s)![/b][/color] " % pts_note + fb
		for cid in _evidence_checks.keys():
			(_evidence_checks[cid] as CheckBox).disabled = true
		for btn in _conclusion_buttons:
			btn.disabled = true
		_verify_btn.visible = false
		_finish_btn.visible = true
	else:
		GameManager.add_challenge_score("l1_tapa_solved", false)
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]✕ Belum Tepat (0 Poin).[/b][/color] " + fb + " Silakan tinjau kembali kartu bukti dan coba lagi!"


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.80)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 18))
	margin.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = str(_data.get("title", "Tantangan 1B: Investigasi Sejarah atau Mitos?"))
	title.add_theme_font_size_override("font_size", 21)
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

	var note := Label.new()
	note.text = str(_data.get("instruction", "")) + "\n" + str(_data.get("symbolic_note", ""))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	vbox.add_child(note)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	# Grid 2x2 untuk 4 kartu bukti
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)

	var cards: Array = _data.get("evidence_cards", [])
	for c in cards:
		if c is Dictionary:
			var cid := str(c.get("id", ""))
			var card := PanelContainer.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 8, 1, 12))
			grid.add_child(card)

			var cv := VBoxContainer.new()
			cv.add_theme_constant_override("separation", 6)
			card.add_child(cv)

			var ch := HBoxContainer.new()
			cv.add_child(ch)

			var cb := CheckBox.new()
			cb.text = str(c.get("title", ""))
			cb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cb.add_theme_font_size_override("font_size", 14)
			cb.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
			ch.add_child(cb)
			_evidence_checks[cid] = cb

			var tag := str(c.get("source_tag", "TRADISI")).to_upper()
			var b := PanelContainer.new()
			b.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))
			ch.add_child(b)
			var bl := Label.new()
			bl.text = tag
			bl.add_theme_font_size_override("font_size", 11)
			b.add_child(bl)

			var body := Label.new()
			body.text = str(c.get("summary", ""))
			body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			body.add_theme_font_size_override("font_size", 13)
			cv.add_child(body)

			var ref := Label.new()
			ref.text = "Sumber: " + str(c.get("reference", ""))
			ref.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			ref.add_theme_font_size_override("font_size", 11)
			ref.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
			cv.add_child(ref)

	var conc_heading := Label.new()
	conc_heading.text = "Pilih Kesimpulan Kritis Paling Tepat:"
	conc_heading.add_theme_font_size_override("font_size", 16)
	conc_heading.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	content.add_child(conc_heading)

	var conclusions: Array = _data.get("conclusions", [])
	_conclusion_buttons.clear()
	for i in range(conclusions.size()):
		var conc: Dictionary = conclusions[i]
		var btn := Button.new()
		btn.text = "%s. %s" % [char(65 + i), str(conc.get("text", ""))]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_CREAM_DARK))
		btn.pressed.connect(_select_conclusion.bind(i))
		content.add_child(btn)
		_conclusion_buttons.append(btn)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.custom_minimum_size = Vector2(0, 56)
	_feedback_label.add_theme_font_size_override("normal_font_size", 14)
	_feedback_label.text = "[color=#E2D0B1]Centang minimal 2 kartu bukti di atas, pilih kesimpulan A/B/C, lalu tekan Verifikasi Analisis.[/color]"
	vbox.add_child(_feedback_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(footer)

	_verify_btn = Button.new()
	_verify_btn.text = "Verifikasi Analisis ✓"
	_verify_btn.custom_minimum_size = Vector2(210, 42)
	_verify_btn.pressed.connect(_on_verify_pressed)
	footer.add_child(_verify_btn)

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
