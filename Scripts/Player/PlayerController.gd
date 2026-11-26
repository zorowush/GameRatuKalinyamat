extends CharacterBody2D
## Karakter pemain 2D reusable: gerak WASD/Panah + Klik-untuk-jalan + interaksi tombol E.
## Mendukung spritesheet 4 arah (144x192, grid 3x4 frame 48x48) + Camera2D scrolling horizontal.

signal interact_requested(player_pos: Vector2)

@export var move_speed: float = 310.0
@export var arena_bounds: Rect2 = Rect2(64, 115, 1152, 550)

var movement_locked: bool = false
var _click_target: Vector2 = Vector2.ZERO
var _has_click_target: bool = false
var _sprite: Sprite2D
var _anim_sprite: AnimatedSprite2D
var _camera: Camera2D
var _facing: String = "down"
var _walk_sheet_path: String = "res://Assets/Characters/walk_ratu.png"


func _ready() -> void:
	_build_visual()


func set_walk_spritesheet(sheet_path: String) -> void:
	_walk_sheet_path = sheet_path
	if is_inside_tree():
		_apply_walk_visual()


func configure_camera(world_width: float, world_height: float) -> void:
	if _camera == null:
		_camera = Camera2D.new()
		_camera.name = "Camera2D"
		add_child(_camera)
	if world_width > 1280.5:
		_camera.enabled = true
		_camera.limit_left = 0
		_camera.limit_right = int(roundf(world_width))
		_camera.limit_top = 0
		_camera.limit_bottom = int(roundf(world_height))
		_camera.position_smoothing_enabled = true
		_camera.position_smoothing_speed = 8.0
		_camera.make_current()
	else:
		_camera.enabled = false


func set_move_target(world_pos: Vector2) -> void:
	if movement_locked:
		return
	_click_target = Vector2(
		clampf(world_pos.x, arena_bounds.position.x, arena_bounds.end.x),
		clampf(world_pos.y, arena_bounds.position.y, arena_bounds.end.y)
	)
	_has_click_target = true


func clear_move_target() -> void:
	_has_click_target = false
	velocity = Vector2.ZERO
	_update_animation()


func set_character_label(text: String) -> void:
	var lbl := get_node_or_null("NameLabel") as Label
	if lbl != null:
		lbl.text = text


func _physics_process(_delta: float) -> void:
	if movement_locked:
		velocity = Vector2.ZERO
		_has_click_target = false
		_update_animation()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir.length_squared() > 0.01:
		_has_click_target = false
		velocity = input_dir.normalized() * move_speed
	elif _has_click_target:
		var diff := _click_target - global_position
		if diff.length() <= 10.0:
			_has_click_target = false
			velocity = Vector2.ZERO
		else:
			velocity = diff.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	global_position.x = clampf(global_position.x, arena_bounds.position.x, arena_bounds.end.x)
	global_position.y = clampf(global_position.y, arena_bounds.position.y, arena_bounds.end.y)
	_update_animation()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if movement_locked:
		return
	if event.is_action_pressed("interact"):
		interact_requested.emit(global_position)
		get_viewport().set_input_as_handled()


func _update_animation() -> void:
	if _anim_sprite == null or not _anim_sprite.visible:
		return
	var moving := velocity.length_squared() > 4.0
	if moving:
		if absf(velocity.x) >= absf(velocity.y):
			_facing = "right" if velocity.x > 0.0 else "left"
		else:
			_facing = "down" if velocity.y > 0.0 else "up"
	var anim_name := ("walk_" if moving else "idle_") + _facing
	if _anim_sprite.sprite_frames != null and _anim_sprite.sprite_frames.has_animation(anim_name):
		if _anim_sprite.animation != anim_name or not _anim_sprite.is_playing():
			_anim_sprite.play(anim_name)


func _draw() -> void:
	# Bayangan kaki karakter
	draw_circle(Vector2(0, 30), 20.0, Color(0.05, 0.03, 0.02, 0.42))
	# Penanda klik tujuan jika sedang berjalan menuju titik klik
	if _has_click_target and not movement_locked:
		var local_target := _click_target - global_position
		draw_arc(local_target, 12.0, 0.0, TAU, 24, AssetLoader.COLOR_GOLD, 2.5)


func _build_visual() -> void:
	if get_node_or_null("CollisionShape2D") == null:
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape := CircleShape2D.new()
		shape.radius = 22.0
		col.shape = shape
		add_child(col)

	_anim_sprite = AnimatedSprite2D.new()
	_anim_sprite.name = "AnimatedSprite2D"
	_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim_sprite.scale = Vector2(1.5, 1.5)
	_anim_sprite.visible = false
	add_child(_anim_sprite)

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite2D"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_apply_walk_visual()

	var name_lbl := Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "Ratu Kalinyamat"
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.position = Vector2(-80, -60)
	name_lbl.size = Vector2(160, 24)
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	name_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	name_lbl.add_theme_constant_override("outline_size", 3)
	add_child(name_lbl)


func _apply_walk_visual() -> void:
	if _anim_sprite == null or _sprite == null:
		return
	var sheet_tex: Texture2D = null
	if not _walk_sheet_path.is_empty() and ResourceLoader.exists(_walk_sheet_path):
		sheet_tex = load(_walk_sheet_path) as Texture2D

	if sheet_tex != null and sheet_tex.get_width() >= 144 and sheet_tex.get_height() >= 192:
		var frames := SpriteFrames.new()
		var dirs := ["down", "left", "right", "up"]
		for row in range(4):
			var dir_name: String = dirs[row]
			var idle_anim := "idle_" + dir_name
			frames.add_animation(idle_anim)
			frames.set_animation_speed(idle_anim, 1.0)
			frames.set_animation_loop(idle_anim, true)
			frames.add_frame(idle_anim, _make_atlas_frame(sheet_tex, 1, row))

			var walk_anim := "walk_" + dir_name
			frames.add_animation(walk_anim)
			frames.set_animation_speed(walk_anim, 7.5)
			frames.set_animation_loop(walk_anim, true)
			for col in [0, 1, 2, 1]:
				frames.add_frame(walk_anim, _make_atlas_frame(sheet_tex, col, row))

		_anim_sprite.sprite_frames = frames
		_anim_sprite.visible = true
		_anim_sprite.play("idle_" + _facing)
		_sprite.visible = false
		return

	# Fallback ke gambar statis / placeholder jika walk sheet tidak tersedia
	_anim_sprite.visible = false
	_sprite.visible = true
	var player_tex := AssetLoader.load_texture_or_placeholder(
		"res://Assets/Characters/player_ratu.png",
		Vector2i(64, 64),
		AssetLoader.COLOR_TERRACOTTA,
		AssetLoader.COLOR_GOLD,
		"player"
	)
	_sprite.texture = player_tex
	var tex_size := player_tex.get_size()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		var factor := 64.0 / maxf(tex_size.x, tex_size.y)
		_sprite.scale = Vector2(factor, factor)


func _make_atlas_frame(sheet: Texture2D, col: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(col * 48, row * 48, 48, 48)
	return atlas
