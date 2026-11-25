extends Node2D
## Titik interaktif di arena (NPC, Arsip Sejarah, Tantangan, Gerbang Akhir Level).
## Dapat dipicu melalui klik langsung pada ikon maupun menekan tombol E saat pemain dekat.

signal interacted(spot_id: String)

var spot_id: String = ""
var display_title: String = "Objek"
var spot_kind: String = "npc" # "npc", "archive", "challenge", "gate"
var asset_path: String = ""
var is_completed: bool = false
var is_player_near: bool = false

var _icon_rect: TextureRect
var _title_label: Label
var _prompt_label: Label
var _status_label: Label
var _click_btn: Button


func setup(p_id: String, p_title: String, p_kind: String, p_asset_path: String = "") -> void:
	spot_id = p_id
	display_title = p_title
	spot_kind = p_kind
	asset_path = p_asset_path
	if is_inside_tree():
		_refresh_visual()


func _ready() -> void:
	_build_visual()
	_refresh_visual()


func set_completed(completed: bool) -> void:
	is_completed = completed
	_refresh_visual()


func set_player_near(near: bool) -> void:
	if is_player_near == near:
		return
	is_player_near = near
	if _prompt_label != null:
		_prompt_label.visible = is_player_near
	queue_redraw()


func trigger() -> void:
	AudioManager.play_sfx("click")
	interacted.emit(spot_id)


func _draw() -> void:
	var ring_col := AssetLoader.COLOR_GOLD if is_player_near else Color(0.83, 0.64, 0.30, 0.35)
	var radius := 44.0 if is_player_near else 38.0
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, ring_col, 3.0 if is_player_near else 1.5)


func _build_visual() -> void:
	_icon_rect = TextureRect.new()
	_icon_rect.position = Vector2(-34, -34)
	_icon_rect.size = Vector2(68, 68)
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon_rect)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.position = Vector2(-95, 38)
	_title_label.size = Vector2(190, 36)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_label.add_theme_font_size_override("font_size", 13)
	_title_label.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM)
	_title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_title_label.add_theme_constant_override("outline_size", 3)
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_label)

	_prompt_label = Label.new()
	_prompt_label.text = "[E / Klik]"
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.position = Vector2(-55, -58)
	_prompt_label.size = Vector2(110, 22)
	_prompt_label.add_theme_font_size_override("font_size", 13)
	_prompt_label.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	_prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt_label.add_theme_constant_override("outline_size", 3)
	_prompt_label.visible = false
	_prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompt_label)

	_status_label = Label.new()
	_status_label.text = "✓"
	_status_label.position = Vector2(22, -40)
	_status_label.size = Vector2(26, 26)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 18)
	_status_label.add_theme_color_override("font_color", Color("#56E38B"))
	_status_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_status_label.add_theme_constant_override("outline_size", 3)
	_status_label.visible = false
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_status_label)

	# Tombol transparan di atas ikon agar klik/tap 100% responsif di Desktop & Web
	_click_btn = Button.new()
	_click_btn.position = Vector2(-42, -42)
	_click_btn.size = Vector2(84, 84)
	_click_btn.flat = true
	_click_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_click_btn.focus_mode = Control.FOCUS_NONE
	_click_btn.pressed.connect(trigger)
	add_child(_click_btn)


func _refresh_visual() -> void:
	if _icon_rect == null:
		return
	var bg_col := AssetLoader.COLOR_SEA_TEAL
	var motif := "crest"
	match spot_kind:
		"archive":
			bg_col = AssetLoader.COLOR_GOLD_DARK
			motif = "scroll"
		"challenge":
			bg_col = AssetLoader.COLOR_TERRACOTTA
			motif = "challenge"
		"gate":
			bg_col = AssetLoader.COLOR_SUCCESS
			motif = "gate"
		"npc":
			bg_col = AssetLoader.COLOR_SEA_TEAL
			motif = "crown"

	_icon_rect.texture = AssetLoader.load_texture_or_placeholder(
		asset_path, Vector2i(72, 72), bg_col, AssetLoader.COLOR_GOLD, motif
	)
	_title_label.text = display_title
	_status_label.visible = is_completed
