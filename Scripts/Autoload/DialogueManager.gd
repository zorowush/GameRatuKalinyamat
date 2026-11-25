extends Node
## Menampilkan dialog naratif dari Data/Dialogues/*.json lengkap dengan
## potret tokoh, pilihan respons, serta badge sumber (FAKTA / TRADISI / FIKSI GAME).

signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: String, chosen_flags: Array)

var _layer: CanvasLayer
var _root: Control
var _backdrop: ColorRect
var _panel: PanelContainer
var _portrait_rect: TextureRect
var _speaker_label: Label
var _role_label: Label
var _tag_panel: PanelContainer
var _tag_label: Label
var _ref_label: Label
var _body_label: RichTextLabel
var _choices_box: VBoxContainer
var _next_button: Button
var _progress_label: Label

var _is_active: bool = false
var _current_dialogue_id: String = ""
var _lines: Array = []
var _current_index: int = 0
var _chosen_flags: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_overlay_ui()


func is_dialogue_active() -> bool:
	return _is_active


func start_dialogue_from_file(json_path: String, dialogue_id: String) -> bool:
	var data: Variant = AssetLoader.load_json_file(json_path)
	if not (data is Dictionary):
		return false
	var dialogues: Variant = data.get("dialogues", {})
	if not (dialogues is Dictionary) or not dialogues.has(dialogue_id):
		push_warning("[DialogueManager] Dialogue ID '%s' tidak ditemukan di %s" % [dialogue_id, json_path])
		return false
	var entry: Variant = dialogues[dialogue_id]
	if not (entry is Dictionary):
		return false
	var lines: Variant = entry.get("lines", [])
	if not (lines is Array) or lines.is_empty():
		return false
	return start_dialogue_lines(dialogue_id, lines)


func start_dialogue_lines(dialogue_id: String, lines: Array) -> bool:
	if lines.is_empty():
		return false
	_current_dialogue_id = dialogue_id
	_lines = lines
	_current_index = 0
	_chosen_flags.clear()
	_is_active = true
	_root.visible = true
	dialogue_started.emit(dialogue_id)
	_show_current_line()
	return true


func close_dialogue() -> void:
	if not _is_active:
		return
	var finished_id := _current_dialogue_id
	var flags_copy := _chosen_flags.duplicate()
	_is_active = false
	_root.visible = false
	_lines = []
	_current_dialogue_id = ""
	dialogue_finished.emit(finished_id, flags_copy)


func _show_current_line() -> void:
	if _current_index >= _lines.size():
		close_dialogue()
		return

	var line: Dictionary = _lines[_current_index]
	var speaker := str(line.get("speaker", "Narator"))
	var role := str(line.get("role", ""))
	var text := str(line.get("text", ""))
	var source_tag := str(line.get("source_tag", "FIKSI GAME")).to_upper()
	var reference := str(line.get("reference", ""))
	var portrait_path := str(line.get("portrait", ""))

	_speaker_label.text = speaker
	_role_label.text = role
	_role_label.visible = not role.is_empty()

	_tag_label.text = source_tag
	_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(source_tag))

	_ref_label.text = ("Sumber: %s" % reference) if not reference.is_empty() else ""
	_ref_label.visible = not reference.is_empty()

	_body_label.text = text
	_progress_label.text = "%d / %d" % [_current_index + 1, _lines.size()]

	var motif := "crown" if speaker.to_lower().contains("ratu") or speaker.to_lower().contains("retna") else "crest"
	var portrait_bg := AssetLoader.COLOR_TERRACOTTA if motif == "crown" else AssetLoader.COLOR_SEA_TEAL
	_portrait_rect.texture = AssetLoader.load_texture_or_placeholder(
		portrait_path, Vector2i(110, 110), portrait_bg, AssetLoader.COLOR_GOLD, motif
	)

	for child in _choices_box.get_children():
		child.queue_free()

	var choices: Variant = line.get("choices", [])
	if choices is Array and not choices.is_empty():
		_choices_box.visible = true
		_next_button.visible = false
		for c in choices:
			if c is Dictionary:
				var btn := Button.new()
				btn.text = str(c.get("text", "Lanjut"))
				btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
				btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				var flag := str(c.get("flag", ""))
				var reply := str(c.get("reply", ""))
				btn.pressed.connect(_on_choice_selected.bind(flag, reply))
				_choices_box.add_child(btn)
	else:
		_choices_box.visible = false
		_next_button.visible = true
		_next_button.text = "Selesai ✓" if _current_index == _lines.size() - 1 else "Lanjut ▶"


func _on_choice_selected(flag: String, reply: String) -> void:
	AudioManager.play_sfx("click")
	if not flag.is_empty():
		_chosen_flags.append(flag)
	if not reply.is_empty():
		_body_label.text = reply
		for child in _choices_box.get_children():
			child.queue_free()
		_choices_box.visible = false
		_next_button.visible = true
		_next_button.text = "Lanjut ▶"
	else:
		_advance_line()


func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	_advance_line()


func _advance_line() -> void:
	_current_index += 1
	_show_current_line()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
	if event.is_action_pressed("confirm") or event.is_action_pressed("interact"):
		if _next_button.visible:
			_on_next_pressed()
			get_viewport().set_input_as_handled()


func _build_overlay_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.name = "DialogueLayer"
	_layer.layer = 60
	add_child(_layer)

	_root = Control.new()
	_root.name = "DialogueRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.theme = AssetLoader.build_theme()
	_root.visible = false
	_layer.add_child(_root)

	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.08, 0.04, 0.02, 0.58)
	_root.add_child(_backdrop)

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.07
	_panel.anchor_right = 0.93
	_panel.anchor_top = 0.56
	_panel.anchor_bottom = 0.95
	_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 12, 3, 18))
	_root.add_child(_panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	_panel.add_child(hbox)

	var portrait_wrap := PanelContainer.new()
	portrait_wrap.custom_minimum_size = Vector2(126, 126)
	portrait_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait_wrap.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 8, 2, 6))
	hbox.add_child(portrait_wrap)

	_portrait_rect = TextureRect.new()
	_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_rect.custom_minimum_size = Vector2(110, 110)
	portrait_wrap.add_child(_portrait_rect)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 20)
	_speaker_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	header.add_child(_speaker_label)

	_role_label = Label.new()
	_role_label.add_theme_font_size_override("font_size", 14)
	_role_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	header.add_child(_role_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	_tag_panel = PanelContainer.new()
	header.add_child(_tag_panel)

	_tag_label = Label.new()
	_tag_label.add_theme_font_size_override("font_size", 13)
	_tag_label.add_theme_color_override("font_color", Color.WHITE)
	_tag_panel.add_child(_tag_label)

	_body_label = RichTextLabel.new()
	_body_label.bbcode_enabled = true
	_body_label.fit_content = false
	_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_label.add_theme_font_size_override("normal_font_size", 17)
	vbox.add_child(_body_label)

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 6)
	_choices_box.visible = false
	vbox.add_child(_choices_box)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	vbox.add_child(footer)

	_ref_label = Label.new()
	_ref_label.add_theme_font_size_override("font_size", 13)
	_ref_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	_ref_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_ref_label)

	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 13)
	_progress_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	footer.add_child(_progress_label)

	_next_button = Button.new()
	_next_button.text = "Lanjut ▶"
	_next_button.custom_minimum_size = Vector2(140, 38)
	_next_button.pressed.connect(_on_next_pressed)
	footer.add_child(_next_button)
