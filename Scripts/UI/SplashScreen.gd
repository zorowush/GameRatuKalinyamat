extends Control
## Layar Splash pembuka sekaligus memicu aktivasi konteks audio Web (HTML5).

var _hint_label: Label
var _pulse_time: float = 0.0
var _proceeded: bool = false


func _ready() -> void:
	theme = AssetLoader.build_theme()
	_build_ui()


func _process(delta: float) -> void:
	_pulse_time += delta * 2.8
	if _hint_label != null:
		_hint_label.modulate.a = 0.55 + 0.45 * absf(sin(_pulse_time))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_proceed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") or event.is_action_pressed("interact") or event is InputEventKey and event.pressed:
		_proceed()


func _proceed() -> void:
	if _proceeded:
		return
	_proceeded = true
	AudioManager.unlock_web_audio()
	AudioManager.play_sfx("click")
	AudioManager.play_bgm("bgm_menu")
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AssetLoader.COLOR_BG_DEEP
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var bg_tex := TextureRect.new()
	bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_tex.modulate = Color(1, 1, 1, 0.25)
	bg_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_tex.texture = AssetLoader.load_texture_or_placeholder(
		"res://Assets/Environments/bg_menu.png", Vector2i(320, 180), AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD, "crest"
	)
	add_child(bg_tex)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(760, 440)
	card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 16, 3, 32))
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	card.add_child(vbox)

	var emblem := TextureRect.new()
	emblem.custom_minimum_size = Vector2(108, 108)
	emblem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	emblem.texture = AssetLoader.load_texture_or_placeholder(
		"res://Assets/Characters/portrait_ratu.png", Vector2i(112, 112), AssetLoader.COLOR_TERRACOTTA, AssetLoader.COLOR_GOLD, "crown"
	)
	vbox.add_child(emblem)

	var title := Label.new()
	title.text = "JEJAK SANG RATU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Kejayaan Jepara — Kisah Sejarah Ratu Kalinyamat (Abad XVI)"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM)
	vbox.add_child(subtitle)

	var course := Label.new()
	course.text = "Game Edukasi Sejarah • Prodi Rekayasa Perangkat Lunak • Tema Relief Mantingan"
	course.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	course.add_theme_font_size_override("font_size", 14)
	course.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	vbox.add_child(course)

	var start_btn := Button.new()
	start_btn.text = "Masuk ke Menu Utama ▶"
	start_btn.custom_minimum_size = Vector2(280, 48)
	start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_btn.pressed.connect(_proceed)
	vbox.add_child(start_btn)

	_hint_label = Label.new()
	_hint_label.text = "Klik di mana saja atau tekan Enter untuk memulai & mengaktifkan audio"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	vbox.add_child(_hint_label)
