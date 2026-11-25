extends CanvasLayer
## HUD Reusable untuk seluruh level: skor, objektif aktif, catatan arsip sejarah,
## tombol audio, pause menu, dan notifikasi toast (skor & lencana).

signal pause_toggled(is_paused: bool)

var _level_title_label: Label
var _objective_label: Label
var _score_label: Label
var _archive_button: Button
var _mute_button: Button
var _toast_panel: PanelContainer
var _toast_label: Label
var _toast_tween: Tween

var _pause_overlay: Control
var _archive_overlay: Control
var _archive_list_vbox: VBoxContainer
var _help_overlay: Control
var _archive_popup_overlay: Control
var _archive_popup_title: Label
var _archive_popup_tag_panel: PanelContainer
var _archive_popup_tag_label: Label
var _archive_popup_body: RichTextLabel
var _archive_popup_ref: Label

var _is_paused: bool = false


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_hud()
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.archive_found.connect(_on_archive_found)
	GameManager.badge_awarded.connect(_on_badge_awarded)
	MissionManager.missions_updated.connect(_on_missions_updated)
	_refresh_labels()


func _exit_tree() -> void:
	if GameManager.score_changed.is_connected(_on_score_changed):
		GameManager.score_changed.disconnect(_on_score_changed)
	if GameManager.archive_found.is_connected(_on_archive_found):
		GameManager.archive_found.disconnect(_on_archive_found)
	if GameManager.badge_awarded.is_connected(_on_badge_awarded):
		GameManager.badge_awarded.disconnect(_on_badge_awarded)
	if MissionManager.missions_updated.is_connected(_on_missions_updated):
		MissionManager.missions_updated.disconnect(_on_missions_updated)


func set_level_title(title_text: String) -> void:
	if _level_title_label != null:
		_level_title_label.text = title_text


func is_any_overlay_open() -> bool:
	return (
		(_pause_overlay != null and _pause_overlay.visible)
		or (_archive_overlay != null and _archive_overlay.visible)
		or (_help_overlay != null and _help_overlay.visible)
		or (_archive_popup_overlay != null and _archive_popup_overlay.visible)
	)


func show_toast(message: String, accent_color: Color = AssetLoader.COLOR_GOLD) -> void:
	if _toast_panel == null or _toast_label == null:
		return
	_toast_label.text = message
	_toast_panel.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, accent_color, 10, 2, 12))
	_toast_panel.visible = true
	_toast_panel.modulate.a = 1.0
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	if DisplayServer.get_name() == "headless":
		return
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.6)
	_toast_tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(func(): _toast_panel.visible = false)


func show_archive_popup(archive_data: Dictionary, score_gained: int) -> void:
	_archive_popup_title.text = str(archive_data.get("title", "Arsip Sejarah"))
	var tag := str(archive_data.get("source_tag", "FAKTA")).to_upper()
	_archive_popup_tag_label.text = tag
	_archive_popup_tag_panel.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))
	var gained_note := "\n\n[color=#D4A24C][b]+%d Poin — Arsip Baru Tercatat![/b][/color]" % score_gained if score_gained > 0 else "\n\n[color=#E2D0B1](Arsip ini sudah tersimpan di Catatan Arsip Anda)[/color]"
	_archive_popup_body.text = str(archive_data.get("content", "")) + gained_note
	_archive_popup_ref.text = "Sumber: " + str(archive_data.get("reference", "-"))
	_archive_popup_overlay.visible = true
	AudioManager.play_sfx("archive")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if DialogueManager.is_dialogue_active():
			return
		if _archive_popup_overlay.visible:
			_archive_popup_overlay.visible = false
			get_viewport().set_input_as_handled()
			return
		if _archive_overlay.visible:
			_archive_overlay.visible = false
			get_viewport().set_input_as_handled()
			return
		if _help_overlay.visible:
			_help_overlay.visible = false
			get_viewport().set_input_as_handled()
			return
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	_is_paused = not _is_paused
	_pause_overlay.visible = _is_paused
	get_tree().paused = _is_paused
	pause_toggled.emit(_is_paused)


func _refresh_labels() -> void:
	if _score_label != null:
		_score_label.text = "Skor: %d" % GameManager.total_score
	if _archive_button != null:
		_archive_button.text = "Arsip (%d)" % GameManager.get_archive_count()
	if _objective_label != null:
		_objective_label.text = "Misi: " + MissionManager.get_active_objective_text()
	if _mute_button != null:
		_mute_button.text = "🔇" if AudioManager.is_muted() else "🔊"


func _on_score_changed(_new_score: int, delta: int, reason: String) -> void:
	_refresh_labels()
	if delta > 0:
		show_toast("+%d Poin • %s" % [delta, reason], AssetLoader.COLOR_GOLD)


func _on_archive_found(_archive_id: String, _archive_data: Dictionary) -> void:
	_refresh_labels()


func _on_badge_awarded(badge_name: String) -> void:
	AudioManager.play_sfx("badge")
	show_toast("★ Lencana Diraih: %s!" % badge_name, AssetLoader.COLOR_GOLD)


func _on_missions_updated(_level_num: int, _objective_text: String) -> void:
	_refresh_labels()


func _on_open_archives_pressed() -> void:
	AudioManager.play_sfx("click")
	_populate_archive_list()
	_archive_overlay.visible = true


func _populate_archive_list() -> void:
	for child in _archive_list_vbox.get_children():
		child.queue_free()

	if GameManager.found_archives.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Belum ada arsip ditemukan. Jelajahi arena dan periksa gulungan sejarah!"
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_archive_list_vbox.add_child(empty_lbl)
		return

	for aid in GameManager.found_archives.keys():
		var entry: Dictionary = GameManager.found_archives[aid]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, 8, 1, 12))
		_archive_list_vbox.add_child(card)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 6)
		card.add_child(cv)

		var top := HBoxContainer.new()
		cv.add_child(top)

		var t := Label.new()
		t.text = str(entry.get("title", aid))
		t.add_theme_font_size_override("font_size", 17)
		t.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(t)

		var tag := str(entry.get("source_tag", "FAKTA")).to_upper()
		var badge := PanelContainer.new()
		badge.add_theme_stylebox_override("panel", AssetLoader.create_badge_style(tag))
		top.add_child(badge)

		var bl := Label.new()
		bl.text = tag
		bl.add_theme_font_size_override("font_size", 12)
		badge.add_child(bl)

		var body := Label.new()
		body.text = str(entry.get("content", ""))
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_theme_font_size_override("font_size", 14)
		cv.add_child(body)

		var ref := Label.new()
		ref.text = "Sumber: " + str(entry.get("reference", "-"))
		ref.add_theme_font_size_override("font_size", 12)
		ref.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
		cv.add_child(ref)


func _on_mute_pressed() -> void:
	AudioManager.toggle_mute()
	AudioManager.play_sfx("click")
	_refresh_labels()


func _build_hud() -> void:
	var root := Control.new()
	root.name = "HUDRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = AssetLoader.build_theme()
	add_child(root)

	# Top Bar
	var top_bar := PanelContainer.new()
	top_bar.anchor_left = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_top = 0.0
	top_bar.offset_bottom = 66
	top_bar.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(Color(0.17, 0.10, 0.07, 0.94), AssetLoader.COLOR_GOLD, 0, 2, 10))
	root.add_child(top_bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	top_bar.add_child(hbox)

	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_col.add_theme_constant_override("separation", 2)
	hbox.add_child(title_col)

	_level_title_label = Label.new()
	_level_title_label.text = "Jejak Sang Ratu"
	_level_title_label.add_theme_font_size_override("font_size", 17)
	_level_title_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	title_col.add_child(_level_title_label)

	_objective_label = Label.new()
	_objective_label.text = "Misi: Jelajahi arena sejarah."
	_objective_label.add_theme_font_size_override("font_size", 14)
	_objective_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM)
	_objective_label.clip_text = true
	title_col.add_child(_objective_label)

	var score_pill := PanelContainer.new()
	score_pill.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_TERRACOTTA, AssetLoader.COLOR_GOLD, 8, 2, 8))
	hbox.add_child(score_pill)

	_score_label = Label.new()
	_score_label.text = "Skor: 0"
	_score_label.add_theme_font_size_override("font_size", 16)
	score_pill.add_child(_score_label)

	_archive_button = Button.new()
	_archive_button.text = "Arsip (0)"
	_archive_button.custom_minimum_size = Vector2(110, 38)
	_archive_button.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	_archive_button.pressed.connect(_on_open_archives_pressed)
	hbox.add_child(_archive_button)

	_mute_button = Button.new()
	_mute_button.text = "🔊"
	_mute_button.custom_minimum_size = Vector2(46, 38)
	_mute_button.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	_mute_button.pressed.connect(_on_mute_pressed)
	hbox.add_child(_mute_button)

	var pause_btn := Button.new()
	pause_btn.text = "Pause"
	pause_btn.custom_minimum_size = Vector2(84, 38)
	pause_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	pause_btn.pressed.connect(_toggle_pause)
	hbox.add_child(pause_btn)

	# Toast Banner
	_toast_panel = PanelContainer.new()
	_toast_panel.anchor_left = 0.5
	_toast_panel.anchor_right = 0.5
	_toast_panel.offset_left = -240
	_toast_panel.offset_right = 240
	_toast_panel.offset_top = 76
	_toast_panel.offset_bottom = 122
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.visible = false
	root.add_child(_toast_panel)

	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 16)
	_toast_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	_toast_panel.add_child(_toast_label)

	# Pause Overlay
	_pause_overlay = _make_modal_backdrop(root)
	var pause_card := PanelContainer.new()
	pause_card.custom_minimum_size = Vector2(400, 320)
	pause_card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 24))
	_pause_overlay.get_node("Center").add_child(pause_card)

	var pv := VBoxContainer.new()
	pv.alignment = BoxContainer.ALIGNMENT_CENTER
	pv.add_theme_constant_override("separation", 12)
	pause_card.add_child(pv)

	var pt := Label.new()
	pt.text = "PERMAINAN DIJEDA"
	pt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pt.add_theme_font_size_override("font_size", 24)
	pt.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	pv.add_child(pt)

	var resume_btn := Button.new()
	resume_btn.text = "Lanjutkan Bermain"
	resume_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		_toggle_pause()
	)
	pv.add_child(resume_btn)

	var help_btn := Button.new()
	help_btn.text = "Petunjuk Singkat"
	help_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_SEA_TEAL, AssetLoader.COLOR_GOLD))
	help_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		_help_overlay.visible = true
	)
	pv.add_child(help_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Kembali ke Menu Utama"
	menu_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	menu_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		_is_paused = false
		get_tree().paused = false
		SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)
	)
	pv.add_child(menu_btn)

	# Archive List Overlay
	_archive_overlay = _make_modal_backdrop(root)
	var arch_card := PanelContainer.new()
	arch_card.custom_minimum_size = Vector2(780, 520)
	arch_card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 20))
	_archive_overlay.get_node("Center").add_child(arch_card)

	var av := VBoxContainer.new()
	av.add_theme_constant_override("separation", 12)
	arch_card.add_child(av)

	var ah := HBoxContainer.new()
	av.add_child(ah)
	var at := Label.new()
	at.text = "CATATAN ARSIP SEJARAH TERKUMPUL"
	at.add_theme_font_size_override("font_size", 22)
	at.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ah.add_child(at)
	var aclose := Button.new()
	aclose.text = "Tutup ✕"
	aclose.pressed.connect(func():
		AudioManager.play_sfx("click")
		_archive_overlay.visible = false
	)
	ah.add_child(aclose)

	var ascroll := ScrollContainer.new()
	ascroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	av.add_child(ascroll)

	_archive_list_vbox = VBoxContainer.new()
	_archive_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_archive_list_vbox.add_theme_constant_override("separation", 10)
	ascroll.add_child(_archive_list_vbox)

	# Single Archive Discovery Popup
	_archive_popup_overlay = _make_modal_backdrop(root)
	var ap_card := PanelContainer.new()
	ap_card.custom_minimum_size = Vector2(680, 390)
	ap_card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 24))
	_archive_popup_overlay.get_node("Center").add_child(ap_card)

	var apv := VBoxContainer.new()
	apv.add_theme_constant_override("separation", 12)
	ap_card.add_child(apv)

	var aph := HBoxContainer.new()
	apv.add_child(aph)

	_archive_popup_title = Label.new()
	_archive_popup_title.add_theme_font_size_override("font_size", 22)
	_archive_popup_title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	_archive_popup_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aph.add_child(_archive_popup_title)

	_archive_popup_tag_panel = PanelContainer.new()
	aph.add_child(_archive_popup_tag_panel)

	_archive_popup_tag_label = Label.new()
	_archive_popup_tag_label.add_theme_font_size_override("font_size", 13)
	_archive_popup_tag_panel.add_child(_archive_popup_tag_label)

	_archive_popup_body = RichTextLabel.new()
	_archive_popup_body.bbcode_enabled = true
	_archive_popup_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_archive_popup_body.add_theme_font_size_override("normal_font_size", 16)
	apv.add_child(_archive_popup_body)

	var apf := HBoxContainer.new()
	apv.add_child(apf)

	_archive_popup_ref = Label.new()
	_archive_popup_ref.add_theme_font_size_override("font_size", 13)
	_archive_popup_ref.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	_archive_popup_ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apf.add_child(_archive_popup_ref)

	var ap_ok := Button.new()
	ap_ok.text = "Simpan ke Catatan ✓"
	ap_ok.pressed.connect(func():
		AudioManager.play_sfx("click")
		_archive_popup_overlay.visible = false
	)
	apf.add_child(ap_ok)

	# Quick Help Overlay inside Pause
	_help_overlay = _make_modal_backdrop(root)
	var hc := PanelContainer.new()
	hc.custom_minimum_size = Vector2(560, 340)
	hc.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 14, 3, 22))
	_help_overlay.get_node("Center").add_child(hc)

	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 12)
	hc.add_child(hv)

	var htitle := Label.new()
	htitle.text = "PETUNJUK SINGKAT"
	htitle.add_theme_font_size_override("font_size", 22)
	htitle.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	hv.add_child(htitle)

	var hbody := Label.new()
	hbody.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbody.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbody.text = (
		"• Gerak: WASD / Panah atau Klik lantai arena.\n"
		+ "• Interaksi: Dekati NPC/Arsip/Tantangan lalu tekan E atau Klik ikonnya.\n"
		+ "• Skor: Misi Utama +30 | Tantangan/Kuis Benar +10 | Arsip +5 | Salah 0 (bisa coba lagi).\n"
		+ "• Label Sumber: FAKTA (sejarah terverifikasi), TRADISI (babad/tutur), FIKSI GAME (narasi pemandu)."
	)
	hv.add_child(hbody)

	var hclose := Button.new()
	hclose.text = "Tutup"
	hclose.pressed.connect(func():
		AudioManager.play_sfx("click")
		_help_overlay.visible = false
	)
	hv.add_child(hclose)


func _make_modal_backdrop(parent: Control) -> Control:
	var wrap := Control.new()
	wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.visible = false
	parent.add_child(wrap)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.06, 0.03, 0.02, 0.72)
	wrap.add_child(dim)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrap.add_child(center)
	return wrap
