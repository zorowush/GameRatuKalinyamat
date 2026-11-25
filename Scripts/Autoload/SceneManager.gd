extends Node
## Mengelola perpindahan scene dengan efek fade halus antar layar.

const SCENE_SPLASH := "res://Scenes/Main/SplashScreen.tscn"
const SCENE_MAIN_MENU := "res://Scenes/Main/MainMenu.tscn"
const SCENE_INSTRUCTIONS := "res://Scenes/UI/InstructionsScreen.tscn"
const SCENE_ABOUT := "res://Scenes/UI/AboutScreen.tscn"
const SCENE_LEVEL_SELECT := "res://Scenes/UI/LevelSelectScreen.tscn"
const SCENE_LEVEL_1 := "res://Scenes/Levels/Level1/Level1.tscn"
const SCENE_LEVEL_2 := "res://Scenes/Levels/Level2/Level2.tscn"
const SCENE_LEVEL_3 := "res://Scenes/Levels/Level3/Level3.tscn"
const SCENE_ENDING := "res://Scenes/UI/EndingScreen.tscn"

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_layer = CanvasLayer.new()
	_fade_layer.name = "TransitionLayer"
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0.11, 0.07, 0.04, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)


func change_scene(scene_path: String, instant: bool = false) -> void:
	if _is_transitioning:
		return
	if not ResourceLoader.exists(scene_path):
		push_error("[SceneManager] Scene tidak ditemukan: %s" % scene_path)
		return

	DialogueManager.close_dialogue(false)
	get_tree().paused = false

	if instant or DisplayServer.get_name() == "headless":
		get_tree().change_scene_to_file(scene_path)
		return

	_is_transitioning = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween_out := create_tween()
	tween_out.tween_property(_fade_rect, "color:a", 1.0, 0.18)
	await tween_out.finished

	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("[SceneManager] Gagal berpindah ke scene %s (err=%d)" % [scene_path, err])

	var tween_in := create_tween()
	tween_in.tween_property(_fade_rect, "color:a", 0.0, 0.20)
	await tween_in.finished
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
