extends CharacterBody2D
## Karakter pemain 2D reusable: gerak WASD/Panah + Klik-untuk-jalan + interaksi tombol E.

signal interact_requested(player_pos: Vector2)

@export var move_speed: float = 290.0
@export var arena_bounds: Rect2 = Rect2(64, 115, 1152, 550)

var movement_locked: bool = false
var _click_target: Vector2 = Vector2.ZERO
var _has_click_target: bool = false
var _sprite: Sprite2D
var _target_marker: Node2D


func _ready() -> void:
	_build_visual()


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


func set_character_label(text: String) -> void:
	var lbl := get_node_or_null("NameLabel") as Label
	if lbl != null:
		lbl.text = text


func _physics_process(_delta: float) -> void:
	if movement_locked:
		velocity = Vector2.ZERO
		_has_click_target = false
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
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if movement_locked:
		return
	if event.is_action_pressed("interact"):
		interact_requested.emit(global_position)
		get_viewport().set_input_as_handled()


func _draw() -> void:
	# Bayangan kaki karakter
	draw_circle(Vector2(0, 26), 20.0, Color(0.05, 0.03, 0.02, 0.45))
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

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite2D"
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
		var target_px := 60.0
		var factor := target_px / maxf(tex_size.x, tex_size.y)
		_sprite.scale = Vector2(factor, factor)
	add_child(_sprite)

	var name_lbl := Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "Ratu Kalinyamat"
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.position = Vector2(-80, -56)
	name_lbl.size = Vector2(160, 24)
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", AssetLoader.COLOR_GOLD)
	name_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	name_lbl.add_theme_constant_override("outline_size", 3)
	add_child(name_lbl)
