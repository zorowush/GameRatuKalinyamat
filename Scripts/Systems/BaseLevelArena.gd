extends Node2D
class_name BaseLevelArena
## Kelas dasar arena 2D untuk Level 1, 2, dan 3.
## Mengelola HUD, pemain, daftar InteractableSpot, klik-untuk-jalan, dan modal tantangan/selesai level.

const HUD_SCENE := preload("res://Scenes/UI/GameplayHUD.tscn")
const PLAYER_SCENE := preload("res://Scenes/Characters/Player.tscn")
const SPOT_SCENE := preload("res://Scenes/Interactables/InteractableSpot.tscn")
const INTERACT_RADIUS := 125.0

var level_number: int = 1
var level_title: String = ""
var bg_asset_path: String = ""
var arena_floor_color: Color = Color("#342116")
var arena_accent_color: Color = AssetLoader.COLOR_TERRACOTTA

var hud: CanvasLayer
var player: CharacterBody2D
var spots: Dictionary = {}
var archives_data: Dictionary = {}

var _challenge_layer: CanvasLayer
var _active_challenge: Node = null
var _complete_overlay: Control = null


func init_arena(p_level_num: int, p_title: String, p_bg_path: String, p_floor: Color, p_accent: Color, player_start: Vector2) -> void:
	level_number = p_level_num
	level_title = p_title
	bg_asset_path = p_bg_path
	arena_floor_color = p_floor
	arena_accent_color = p_accent

	MissionManager.start_level_missions(level_number)
	AudioManager.play_bgm("bgm_level%d" % level_number)

	_setup_background()

	player = PLAYER_SCENE.instantiate()
	player.position = player_start
	player.interact_requested.connect(_on_player_interact_requested)
	add_child(player)

	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.set_level_title(level_title)

	_challenge_layer = CanvasLayer.new()
	_challenge_layer.name = "ChallengeLayer"
	_challenge_layer.layer = 45
	add_child(_challenge_layer)

	queue_redraw()


func is_interaction_locked() -> bool:
	return (
		DialogueManager.is_dialogue_active()
		or (hud != null and bool(hud.call("is_any_overlay_open")))
		or _active_challenge != null
		or (_complete_overlay != null and _complete_overlay.visible)
	)


func _process(_delta: float) -> void:
	if player == null:
		return
	var locked: bool = is_interaction_locked()
	player.movement_locked = locked

	for spot_id in spots.keys():
		var spot: Node2D = spots[spot_id]
		if is_instance_valid(spot):
			var dist := player.global_position.distance_to(spot.global_position)
			spot.set_player_near(dist <= INTERACT_RADIUS and not locked)


func _unhandled_input(event: InputEvent) -> void:
	if player == null or is_interaction_locked():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos: Vector2 = get_global_mouse_position()
		if click_pos.y > 76.0:
			player.set_move_target(click_pos)


func spawn_spot(spot_id: String, title: String, kind: String, pos: Vector2, asset_path: String = "") -> Node2D:
	var spot := SPOT_SCENE.instantiate()
	spot.position = pos
	spot.setup(spot_id, title, kind, asset_path)
	spot.interacted.connect(_handle_spot_interacted)
	add_child(spot)
	spots[spot_id] = spot
	return spot


func _handle_spot_interacted(spot_id: String) -> void:
	if is_interaction_locked():
		return
	_on_spot_interacted(spot_id)


func mark_spot_completed(spot_id: String) -> void:
	if spots.has(spot_id) and is_instance_valid(spots[spot_id]):
		spots[spot_id].set_completed(true)


func load_archives_from_json(json_path: String) -> void:
	var data: Variant = AssetLoader.load_json_file(json_path)
	archives_data.clear()
	if data is Dictionary and data.get("archives") is Array:
		for item in data["archives"]:
			if item is Dictionary and item.has("id"):
				archives_data[str(item["id"])] = item


func trigger_archive(archive_id: String) -> void:
	if not archives_data.has(archive_id):
		return
	var entry: Dictionary = archives_data[archive_id]
	var gained := GameManager.record_archive(archive_id, entry)
	mark_spot_completed(archive_id)
	hud.show_archive_popup(entry, gained)


func open_challenge_scene(scene_path: String, on_completed: Callable) -> void:
	if _active_challenge != null:
		return
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[BaseLevelArena] Gagal memuat scene tantangan: %s" % scene_path)
		return
	var instance := packed.instantiate()
	_active_challenge = instance
	_challenge_layer.add_child(instance)
	if instance.has_signal("challenge_completed"):
		instance.challenge_completed.connect(func(success: bool):
			if is_instance_valid(_active_challenge):
				_active_challenge.queue_free()
			_active_challenge = null
			if success and on_completed.is_valid():
				on_completed.call()
		)
	if instance.has_signal("challenge_closed"):
		instance.challenge_closed.connect(func():
			if is_instance_valid(_active_challenge):
				_active_challenge.queue_free()
			_active_challenge = null
		)


func show_level_complete_modal(heading: String, summary_text: String, badge_name: String, next_scene: String, next_btn_text: String) -> void:
	if _complete_overlay != null:
		_complete_overlay.queue_free()

	_complete_overlay = Control.new()
	_complete_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_complete_overlay.theme = AssetLoader.build_theme()
	_challenge_layer.add_child(_complete_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.78)
	_complete_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_complete_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(640, 380)
	card.add_theme_stylebox_override("panel", AssetLoader.create_panel_style(AssetLoader.COLOR_PANEL_DARK, AssetLoader.COLOR_GOLD, 16, 3, 26))
	center.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	card.add_child(vbox)

	var h := Label.new()
	h.text = heading
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_size_override("font_size", 26)
	h.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	vbox.add_child(h)

	if not badge_name.is_empty():
		var b := Label.new()
		b.text = "★ Lencana Kehormatan: %s ★" % badge_name
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_font_size_override("font_size", 19)
		b.add_theme_color_override("font_color", Color("#F9D877"))
		vbox.add_child(b)

	var body := Label.new()
	body.text = summary_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)

	var score_info := Label.new()
	score_info.text = "Total Skor Saat Ini: %d Poin  •  Arsip Terkumpul: %d" % [GameManager.total_score, GameManager.get_archive_count()]
	score_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_info.add_theme_color_override("font_color", AssetLoader.COLOR_CREAM_DARK)
	vbox.add_child(score_info)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 14)
	vbox.add_child(btn_row)

	var menu_btn := Button.new()
	menu_btn.text = "Menu Utama"
	menu_btn.add_theme_stylebox_override("normal", AssetLoader.create_button_style(AssetLoader.COLOR_DARK_BROWN, AssetLoader.COLOR_GOLD))
	menu_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU)
	)
	btn_row.add_child(menu_btn)

	var next_btn := Button.new()
	next_btn.text = next_btn_text
	next_btn.custom_minimum_size = Vector2(220, 44)
	next_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		SceneManager.change_scene(next_scene)
	)
	btn_row.add_child(next_btn)


func _on_player_interact_requested(player_pos: Vector2) -> void:
	var best_spot: Node2D = null
	var best_dist := INTERACT_RADIUS
	for spot_id in spots.keys():
		var spot: Node2D = spots[spot_id]
		if is_instance_valid(spot):
			var d := player_pos.distance_to(spot.global_position)
			if d <= best_dist:
				best_dist = d
				best_spot = spot
	if best_spot != null:
		best_spot.trigger()


func _on_spot_interacted(_spot_id: String) -> void:
	# Di-override oleh setiap Level Controller
	pass


func _setup_background() -> void:
	if not bg_asset_path.is_empty() and ResourceLoader.exists(bg_asset_path):
		var tex := load(bg_asset_path) as Texture2D
		if tex != null:
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.position = Vector2(640, 360)
			var tex_size := tex.get_size()
			if tex_size.x > 0.0 and tex_size.y > 0.0:
				sprite.scale = Vector2(1280.0 / tex_size.x, 720.0 / tex_size.y)
			sprite.z_index = -10
			add_child(sprite)


func _draw() -> void:
	# Latar Relief Mantingan prosedural yang rapi & informatif jika bg_levelX.png belum tersedia
	draw_rect(Rect2(0, 0, 1280, 720), arena_floor_color)
	draw_rect(Rect2(36, 90, 1208, 594), arena_floor_color.lightened(0.08))
	draw_rect(Rect2(36, 90, 1208, 594), AssetLoader.COLOR_GOLD, false, 3.0)
	# Jalur setapak dekoratif horizontal & vertikal
	draw_rect(Rect2(80, 355, 1120, 56), arena_accent_color.darkened(0.45))
	draw_rect(Rect2(610, 130, 60, 500), arena_accent_color.darkened(0.45))
	# Ornamen sudut Relief Mantingan
	for corner in [Vector2(66, 120), Vector2(1214, 120), Vector2(66, 654), Vector2(1214, 654)]:
		draw_circle(corner, 12.0, AssetLoader.COLOR_GOLD)
		draw_circle(corner, 6.0, arena_accent_color)
