extends Control
## Tantangan 3A: Strategi Armada & Refleksi Objektif Ekspedisi Malaka 1551 & 1574.
## Menggunakan mekanik 3 Semangat Armada dan layar refleksi sebab kegagalan historis.

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level3_expedition.json"

var _data: Dictionary = {}
var _scenarios: Array = []
var _idx: int = 0
var _spirit: int = 3
var _max_spirit: int = 3
var _answered: bool = false
var _in_reflection: bool = false

var _spirit_label: Label
var _era_label: Label
var _tag_panel: PanelContainer
var _tag_label: Label
var _situation_label: Label
var _options_box: VBoxContainer
var _reflection_checks: Dictionary = {}
var _feedback_label: RichTextLabel
var _action_btn: Button
var _retry_btn: Button


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	var raw_sc: Variant = _data.get("scenarios", [])
	_scenarios = raw_sc if raw_sc is Array else []
	_max_spirit = int(_data.get("max_spirit", 3))
	_spirit = _max_spirit
	_build_ui()
	_show_scenario()


func _update_spirit_display() -> void:
	var hearts := ""
	for i in range(_max_spirit):
		hearts += "★ " if i < _spirit else "☆ "
	_spirit_label.text = "Semangat Armada: %s(%d/%d)" % [hearts, _spirit, _max_spirit]


func _show_scenario() -> void:
	_in_reflection = false
	_answered = false
	_retry_btn.visible = false
	_update_spirit_display()

	if _idx >= _scenarios.size():
		_show_reflection_phase()
		return

	var sc: Dictionary = _scenarios[_idx]
	_era_label.text = "Babak %d/%d — %s" % [_idx + 1, _scenarios.size(), str(sc.get("era", ""))]
	_situation_label.text = str(sc.get("situation", ""))

	var tag := str(sc.get("source_tag", "FAKTA")).to_upper()
	_tag_label.text = tag
	_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))

	for c in _options_box.get_children():
		_options_box.remove_child(c)
		c.queue_free()

	var options: Array = sc.get("options", [])
	for i in range(options.size()):
		var opt: Dictionary = options[i]
		var btn := Button.new()
		btn.text = "%s. %s" % [char(65 + i), str(opt.get("text", ""))]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
		btn.pressed.connect(_on_scenario_option.bind(i))
		_options_box.add_child(btn)

	_feedback_label.text = "[color=#E2D0B1]Tentukan keputusan taktis terbaik berdasarkan catatan sejarah Ekspedisi Malaka.[/color]"
	_action_btn.visible = false


func _on_scenario_option(opt_idx: int) -> void:
	if _answered or _in_reflection:
		return
	var sc: Dictionary = _scenarios[_idx]
	var options: Array = sc.get("options", [])
	var chosen: Dictionary = options[opt_idx]
	var step_id := "l3_exp_" + str(sc.get("id", str(_idx)))

	if bool(chosen.get("is_correct", false)):
		_answered = true
		var gained := GameManager.add_challenge_score(step_id, true)
		AudioManager.play_sfx("correct")
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_feedback_label.text = "[color=#56E38B][b]✓ KEPUTUSAN STRATEGIS TEPAT (%s)![/b][/color] " % pts_note + str(chosen.get("feedback", ""))
		for child in _options_box.get_children():
			if child is Button:
				child.disabled = true
		_action_btn.visible = true
		_action_btn.text = "Masuk ke Refleksi Sejarah ▶" if _idx == _scenarios.size() - 1 else "Skenario Berikutnya ▶"
	else:
		_spirit = maxi(0, _spirit - 1)
		_update_spirit_display()
		GameManager.add_challenge_score(step_id, false)
		AudioManager.play_sfx("wrong")
		if _spirit == 0:
			_feedback_label.text = "[color=#FF867A][b]✕ Semangat Armada Habis (0 Poin).[/b][/color] " + str(chosen.get("feedback", "")) + " Tekan 'Pulihkan Armada & Coba Lagi' untuk mengulang babak ini!"
			for child in _options_box.get_children():
				if child is Button:
					child.disabled = true
			_retry_btn.visible = true
		else:
			_feedback_label.text = "[color=#FF867A][b]✕ Keputusan Berisiko (0 Poin, -1 Semangat).[/b][/color] " + str(chosen.get("feedback", "")) + " Coba pilih strategi lain!"


func _show_reflection_phase() -> void:
	_in_reflection = true
	_answered = false
	_retry_btn.visible = false
	var ref_data: Dictionary = _data.get("reflection", {})

	_era_label.text = str(ref_data.get("title", "Refleksi Sebab Kegagalan Ekspedisi"))
	_situation_label.text = str(ref_data.get("prompt", ""))
	var tag := str(ref_data.get("source_tag", "FAKTA")).to_upper()
	_tag_label.text = tag
	_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))

	for c in _options_box.get_children():
		_options_box.remove_child(c)
		c.queue_free()
	_reflection_checks.clear()

	var factors: Array = ref_data.get("factors", [])
	for f in factors:
		if f is Dictionary:
			var fid := str(f.get("id", ""))
			var cb := CheckBox.new()
			cb.text = str(f.get("text", ""))
			cb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cb.add_theme_font_size_override("font_size", 15)
			_options_box.add_child(cb)
			_reflection_checks[fid] = {"box": cb, "is_true": bool(f.get("is_true", false))}

	_feedback_label.text = "[color=#E2D0B1]Centang semua faktor historis yang benar (hati-hati terhadap pernyataan keliru), lalu klik 'Periksa Refleksi'.[/color]"
	_action_btn.visible = true
	_action_btn.text = "Periksa Refleksi ✓"


func _on_action_pressed() -> void:
	AudioManager.play_sfx("click")
	if not _in_reflection:
		_idx += 1
		_show_scenario()
		return

	if _answered:
		challenge_completed.emit(true)
		return

	var all_correct := true
	for fid in _reflection_checks.keys():
		var entry: Dictionary = _reflection_checks[fid]
		var cb: CheckBox = entry["box"]
		var expected: bool = bool(entry["is_true"])
		if cb.button_pressed != expected:
			all_correct = false
			break

	var ref_data: Dictionary = _data.get("reflection", {})
	if all_correct:
		_answered = true
		var gained := GameManager.add_challenge_score("l3_exp_reflection", true)
		AudioManager.play_sfx("correct")
		for fid in _reflection_checks.keys():
			(_reflection_checks[fid]["box"] as CheckBox).disabled = true
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_feedback_label.text = "[color=#56E38B][b]✓ REFLEKSI OBJEKTIF TEPAT (%s)![/b][/color] " % pts_note + str(ref_data.get("summary", ""))
		_action_btn.text = "Selesaikan Tantangan 3A ▶"
	else:
		GameManager.add_challenge_score("l3_exp_reflection", false)
		AudioManager.play_sfx("wrong")
		_feedback_label.text = "[color=#FF867A][b]✕ Pilihan faktor belum sepenuhnya tepat (0 Poin).[/b][/color] Pastikan Anda mencentang keempat faktor objektif (meriam/kapal Portugis, koordinasi waktu Aceh, jalur logistik 6 kapal, dan badai 1551) serta TIDAK mencentang pernyataan keliru."


func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	_spirit = _max_spirit
	_show_scenario()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.82)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
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
	title.text = str(_data.get("title", "Tantangan 3A: Ekspedisi Malaka"))
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_spirit_label = Label.new()
	_spirit_label.add_theme_font_size_override("font_size", 16)
	_spirit_label.add_theme_color_override("font_color", Color("#F9D877"))
	header.add_child(_spirit_label)

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

	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 8)
	card.add_child(cv)

	var ch := HBoxContainer.new()
	cv.add_child(ch)

	_era_label = Label.new()
	_era_label.add_theme_font_size_override("font_size", 19)
	_era_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	_era_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch.add_child(_era_label)

	_tag_panel = PanelContainer.new()
	ch.add_child(_tag_panel)
	_tag_label = Label.new()
	_tag_label.add_theme_font_size_override("font_size", 12)
	_tag_panel.add_child(_tag_label)

	_situation_label = Label.new()
	_situation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_situation_label.add_theme_font_size_override("font_size", 15)
	cv.add_child(_situation_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_options_box = VBoxContainer.new()
	_options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_options_box.add_theme_constant_override("separation", 10)
	scroll.add_child(_options_box)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.custom_minimum_size = Vector2(0, 68)
	_feedback_label.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(_feedback_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 12)
	vbox.add_child(footer)

	_retry_btn = Button.new()
	_retry_btn.text = "Pulihkan Armada & Coba Lagi ↻"
	_retry_btn.visible = false
	_retry_btn.pressed.connect(_on_retry_pressed)
	footer.add_child(_retry_btn)

	_action_btn = Button.new()
	_action_btn.text = "Lanjut ▶"
	_action_btn.custom_minimum_size = Vector2(240, 42)
	_action_btn.visible = false
	_action_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	_action_btn.pressed.connect(_on_action_pressed)
	footer.add_child(_action_btn)
