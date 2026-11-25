extends Control
## Tantangan 3B: Galeri Warisan (Masjid Mantingan 1559, Seni Ukir, Benteng Kalinyamat)
## dilanjutkan Evaluasi Akhir 10 Soal untuk meraih Lencana De Kranige Dame (>= 70%).

signal challenge_completed(success: bool)
signal challenge_closed()

const DATA_PATH := "res://Data/Historical_Data/level3_heritage_quiz.json"

var _data: Dictionary = {}
var _questions: Array = []
var _q_idx: int = 0
var _correct_count: int = 0
var _answered_current: bool = false

var _gallery_panel: VBoxContainer
var _quiz_panel: VBoxContainer
var _q_progress_label: Label
var _q_tag_panel: PanelContainer
var _q_tag_label: Label
var _q_text_label: Label
var _q_options_box: VBoxContainer
var _q_feedback_label: RichTextLabel
var _q_next_btn: Button


func _ready() -> void:
	theme = AssetLoader.build_theme()
	var loaded: Variant = AssetLoader.load_json_file(DATA_PATH)
	_data = loaded if loaded is Dictionary else {}
	var raw_q: Variant = _data.get("questions", [])
	_questions = raw_q if raw_q is Array else []
	_build_ui()


func _start_quiz() -> void:
	AudioManager.play_sfx("click")
	_q_idx = 0
	_correct_count = 0
	_gallery_panel.visible = false
	_quiz_panel.visible = true
	_show_question()


func _show_question() -> void:
	if _q_idx >= _questions.size():
		_finish_quiz()
		return

	_answered_current = false
	var q: Dictionary = _questions[_q_idx]
	_q_progress_label.text = "Soal Evaluasi %d / %d   •   Benar: %d" % [_q_idx + 1, _questions.size(), _correct_count]
	_q_text_label.text = str(q.get("question", ""))

	var tag := str(q.get("source_tag", "FAKTA")).to_upper()
	_q_tag_label.text = tag
	_q_tag_panel.visible = true
	_q_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))

	for c in _q_options_box.get_children():
		_q_options_box.remove_child(c)
		c.queue_free()

	var options: Array = q.get("options", [])
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = "%s. %s" % [char(65 + i), str(options[i])]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
		btn.pressed.connect(_on_answer_pressed.bind(i))
		_q_options_box.add_child(btn)

	_q_feedback_label.text = "[color=#E2D0B1]Pilih jawaban A, B, C, atau D yang paling tepat.[/color]"
	_q_next_btn.visible = false


func _on_answer_pressed(opt_idx: int) -> void:
	if _answered_current or _q_idx >= _questions.size():
		return
	_answered_current = true

	var q: Dictionary = _questions[_q_idx]
	var correct_idx := int(q.get("correct_index", 0))
	var step_id := "l3_quiz_" + str(q.get("id", str(_q_idx)))
	var explanation := str(q.get("explanation", ""))
	var reference := str(q.get("reference", ""))

	var buttons := _q_options_box.get_children()
	for i in range(buttons.size()):
		if buttons[i] is Button:
			var b: Button = buttons[i]
			b.disabled = true
			if i == correct_idx:
				b.add_theme_stylebox_override("disabled", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
			elif i == opt_idx:
				b.add_theme_stylebox_override("disabled", AssetLoader.create_button_style(AssetLoader.COLOR_ERROR, AssetLoader.COLOR_CREAM))

	if opt_idx == correct_idx:
		_correct_count += 1
		var gained := GameManager.add_challenge_score(step_id, true)
		AudioManager.play_sfx("correct")
		var pts_note := "+%d Poin" % gained if gained > 0 else "Skor sudah tercatat"
		_q_feedback_label.text = "[color=#56E38B][b]✓ BENAR (%s)![/b][/color] %s [color=#E2D0B1](Sumber: %s)[/color]" % [pts_note, explanation, reference]
	else:
		GameManager.add_challenge_score(step_id, false)
		AudioManager.play_sfx("wrong")
		_q_feedback_label.text = "[color=#FF867A][b]✕ Belum Tepat (0 Poin).[/b][/color] %s [color=#E2D0B1](Sumber: %s)[/color]" % [explanation, reference]

	_q_next_btn.visible = true
	_q_next_btn.text = "Lihat Hasil Evaluasi ▶" if _q_idx == _questions.size() - 1 else "Soal Berikutnya ▶"


func _on_next_question() -> void:
	AudioManager.play_sfx("click")
	_q_idx += 1
	_show_question()


func _finish_quiz() -> void:
	var result := GameManager.record_quiz_result(_correct_count, _questions.size())
	var pct: float = float(result["percentage"])
	var passed: bool = bool(result["passed"])

	for c in _q_options_box.get_children():
		_q_options_box.remove_child(c)
		c.queue_free()

	_q_tag_panel.visible = false
	_q_progress_label.text = "HASIL EVALUASI AKHIR SEJARAH"
	_q_text_label.text = "Skor Kuis Anda: %d / %d (%.0f%%)" % [_correct_count, _questions.size(), pct]

	if passed:
		AudioManager.play_sfx("badge")
		_q_feedback_label.text = (
			"[color=#56E38B][b]★ SELAMAT! Anda Lulus Evaluasi (≥ 70%) dan meraih Lencana 'De Kranige Dame'![/b][/color]\n"
			+ "Anda telah memahami kisah, strategi, dan warisan Ratu Kalinyamat secara kritis dan objektif."
		)
	else:
		_q_feedback_label.text = (
			"[color=#F9D877][b]Evaluasi selesai dengan skor %.0f%%.[/b][/color] " % pct
			+ "Untuk meraih Lencana [b]De Kranige Dame[/b] diperlukan skor minimal 70%. Anda dapat langsung melanjutkan ke Epilog atau mengulang kuis!"
		)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	_q_options_box.add_child(btn_row)

	var retry_btn := Button.new()
	retry_btn.text = "Ulangi Evaluasi 10 Soal ↻"
	retry_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	retry_btn.pressed.connect(_start_quiz)
	btn_row.add_child(retry_btn)

	var done_btn := Button.new()
	done_btn.text = "Selesai & Menuju Monumen Epilog ▶"
	done_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	done_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		challenge_completed.emit(true)
	)
	btn_row.add_child(done_btn)

	_q_next_btn.visible = false


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.84)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 20))
	margin.add_child(panel)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	panel.add_child(root_v)

	var header := HBoxContainer.new()
	root_v.add_child(header)

	var title := Label.new()
	title.text = "Tantangan 3B: Galeri Warisan & Evaluasi Akhir (10 Soal)"
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

	# === FASE 1: GALERI WARISAN ===
	_gallery_panel = VBoxContainer.new()
	_gallery_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_gallery_panel.add_theme_constant_override("separation", 12)
	root_v.add_child(_gallery_panel)

	var g_sub := Label.new()
	g_sub.text = "Tinjau 3 peninggalan bersejarah Ratu Kalinyamat di Jepara sebelum mengerjakan Evaluasi Akhir 10 Soal:"
	g_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_gallery_panel.add_child(g_sub)

	var g_row := HBoxContainer.new()
	g_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	g_row.add_theme_constant_override("separation", 14)
	_gallery_panel.add_child(g_row)

	var items: Array = _data.get("heritage_items", [])
	for item in items:
		if item is Dictionary:
			var card := PanelContainer.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.size_flags_vertical = Control.SIZE_EXPAND_FILL
			card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 10, 2, 16))
			g_row.add_child(card)

			var cv := VBoxContainer.new()
			cv.add_theme_constant_override("separation", 8)
			card.add_child(cv)

			var tag := str(item.get("source_tag", "FAKTA")).to_upper()
			var tb := PanelContainer.new()
			tb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			tb.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))
			cv.add_child(tb)
			var tl := Label.new()
			tl.text = tag
			tl.add_theme_font_size_override("font_size", 11)
			tb.add_child(tl)

			var it := Label.new()
			it.text = str(item.get("title", ""))
			it.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			it.add_theme_font_size_override("font_size", 17)
			it.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
			cv.add_child(it)

			var idesc := Label.new()
			idesc.text = str(item.get("description", ""))
			idesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			idesc.size_flags_vertical = Control.SIZE_EXPAND_FILL
			idesc.add_theme_font_size_override("font_size", 14)
			cv.add_child(idesc)

			var iref := Label.new()
			iref.text = "Sumber: " + str(item.get("reference", ""))
			iref.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			iref.add_theme_font_size_override("font_size", 11)
			iref.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
			cv.add_child(iref)

	var start_quiz_btn := Button.new()
	start_quiz_btn.text = "Mulai Evaluasi Akhir (10 Soal) ▶"
	start_quiz_btn.custom_minimum_size = Vector2(300, 46)
	start_quiz_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	start_quiz_btn.pressed.connect(_start_quiz)
	_gallery_panel.add_child(start_quiz_btn)

	# === FASE 2: EVALUASI 10 SOAL ===
	_quiz_panel = VBoxContainer.new()
	_quiz_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_quiz_panel.add_theme_constant_override("separation", 10)
	_quiz_panel.visible = false
	root_v.add_child(_quiz_panel)

	var qcard := PanelContainer.new()
	qcard.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_SEA_TEAL, 10, 2, 16))
	_quiz_panel.add_child(qcard)

	var qv := VBoxContainer.new()
	qv.add_theme_constant_override("separation", 8)
	qcard.add_child(qv)

	var qh := HBoxContainer.new()
	qv.add_child(qh)

	_q_progress_label = Label.new()
	_q_progress_label.add_theme_font_size_override("font_size", 15)
	_q_progress_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	_q_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qh.add_child(_q_progress_label)

	_q_tag_panel = PanelContainer.new()
	qh.add_child(_q_tag_panel)
	_q_tag_label = Label.new()
	_q_tag_label.add_theme_font_size_override("font_size", 12)
	_q_tag_panel.add_child(_q_tag_label)

	_q_text_label = Label.new()
	_q_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_q_text_label.add_theme_font_size_override("font_size", 19)
	_q_text_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	qv.add_child(_q_text_label)

	_q_options_box = VBoxContainer.new()
	_q_options_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_q_options_box.add_theme_constant_override("separation", 8)
	_quiz_panel.add_child(_q_options_box)

	_q_feedback_label = RichTextLabel.new()
	_q_feedback_label.bbcode_enabled = true
	_q_feedback_label.custom_minimum_size = Vector2(0, 74)
	_q_feedback_label.add_theme_font_size_override("normal_font_size", 14)
	_quiz_panel.add_child(_q_feedback_label)

	var qf := HBoxContainer.new()
	qf.alignment = BoxContainer.ALIGNMENT_END
	_quiz_panel.add_child(qf)

	_q_next_btn = Button.new()
	_q_next_btn.text = "Soal Berikutnya ▶"
	_q_next_btn.custom_minimum_size = Vector2(230, 42)
	_q_next_btn.visible = false
	_q_next_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SUCCESS, AssetLoader.COLOR_GOLD))
	_q_next_btn.pressed.connect(_on_next_question)
	qf.add_child(_q_next_btn)
