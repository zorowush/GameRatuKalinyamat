extends Node
## Melacak daftar misi dan objektif aktif pada setiap level dari Data/Missions/missions.json.

signal missions_updated(level_num: int, objective_text: String)
signal step_completed(step_id: String)

const MISSIONS_PATH := "res://Data/Missions/missions.json"

var _missions_data: Dictionary = {}
var active_level: int = 0
var _completed_steps: Dictionary = {}


func _ready() -> void:
	reload_missions()


func reload_missions() -> void:
	var loaded: Variant = AssetLoader.load_json_file(MISSIONS_PATH)
	if loaded is Dictionary:
		_missions_data = loaded
	else:
		_missions_data = {}


func start_level_missions(level_num: int) -> void:
	active_level = level_num
	missions_updated.emit(active_level, get_active_objective_text())


func get_level_info(level_num: int) -> Dictionary:
	var levels: Variant = _missions_data.get("levels", {})
	if levels is Dictionary and levels.has(str(level_num)):
		return levels[str(level_num)]
	return {}


func get_level_steps(level_num: int) -> Array:
	var info := get_level_info(level_num)
	var steps: Variant = info.get("steps", [])
	return steps if steps is Array else []


func complete_step(step_id: String, award_main_mission_score: bool = false) -> void:
	if step_id.is_empty():
		return
	var is_new := not _completed_steps.has(step_id)
	_completed_steps[step_id] = true
	if award_main_mission_score:
		GameManager.add_mission_score(step_id)
	if is_new:
		step_completed.emit(step_id)
	missions_updated.emit(active_level, get_active_objective_text())


func is_step_completed(step_id: String) -> bool:
	return _completed_steps.has(step_id)


func are_required_steps_completed(step_ids: Array) -> bool:
	for sid in step_ids:
		if not is_step_completed(str(sid)):
			return false
	return true


func get_active_objective_text() -> String:
	var steps := get_level_steps(active_level)
	for s in steps:
		if s is Dictionary:
			var sid := str(s.get("id", ""))
			if not is_step_completed(sid):
				return str(s.get("title", "Jelajahi arena sejarah."))
	if steps.is_empty():
		return "Jelajahi arena dan temukan catatan sejarah."
	return "Semua misi level ini selesai! Menuju gerbang akhir level."


func reset_runtime_steps() -> void:
	_completed_steps.clear()
	missions_updated.emit(active_level, get_active_objective_text())
