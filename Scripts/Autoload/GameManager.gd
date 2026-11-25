extends Node
## Mengelola state global permainan: skor, progres level, arsip sejarah,
## lencana, hasil kuis akhir, dan Save/Load JSON (Windows & Web IndexedDB).

signal score_changed(new_score: int, delta: int, reason: String)
signal archive_found(archive_id: String, archive_data: Dictionary)
signal badge_awarded(badge_name: String)
signal level_unlocked(level_num: int)
signal progress_reset()

const SCORE_MISSION_COMPLETE := 30
const SCORE_CHALLENGE_CORRECT := 10
const SCORE_ARCHIVE_FOUND := 5
const SCORE_WRONG := 0
const QUIZ_PASS_PERCENTAGE := 70.0
const MAX_LEVEL := 3
const DEFAULT_SAVE_PATH := "user://save_data.json"

const BADGE_LEVEL_1 := "Penyelidik Sejarah"
const BADGE_LEVEL_2 := "Ratu Bandar"
const BADGE_LEVEL_3 := "De Kranige Dame"

var total_score: int = 0
var unlocked_level: int = 1
var completed_levels: Array[int] = []
var completed_missions: Dictionary = {}
var completed_mission_steps: Dictionary = {}
var scored_challenges: Dictionary = {}
var found_archives: Dictionary = {}
var badges: Array[String] = []
var quiz_correct: int = 0
var quiz_total: int = 10
var quiz_percentage: float = 0.0
var quiz_completed: bool = false
var player_settings: Dictionary = {
	"muted": false,
	"bgm_volume": 0.7,
	"sfx_volume": 0.85,
}
var save_path_override: String = ""


func _ready() -> void:
	load_game()


func get_save_path() -> String:
	if not save_path_override.is_empty():
		return save_path_override
	return DEFAULT_SAVE_PATH


func add_mission_score(mission_id: String) -> int:
	if mission_id.is_empty() or completed_missions.has(mission_id):
		return 0
	completed_missions[mission_id] = true
	total_score += SCORE_MISSION_COMPLETE
	score_changed.emit(total_score, SCORE_MISSION_COMPLETE, "Misi Utama Selesai")
	save_game()
	return SCORE_MISSION_COMPLETE


func add_challenge_score(step_id: String, is_correct: bool) -> int:
	if not is_correct:
		score_changed.emit(total_score, SCORE_WRONG, "Jawaban belum tepat")
		return SCORE_WRONG
	if step_id.is_empty() or scored_challenges.has(step_id):
		return 0
	scored_challenges[step_id] = true
	total_score += SCORE_CHALLENGE_CORRECT
	score_changed.emit(total_score, SCORE_CHALLENGE_CORRECT, "Tantangan Benar")
	save_game()
	return SCORE_CHALLENGE_CORRECT


func record_archive(archive_id: String, archive_data: Dictionary) -> int:
	if archive_id.is_empty():
		return 0
	if found_archives.has(archive_id):
		return 0
	found_archives[archive_id] = archive_data.duplicate(true)
	total_score += SCORE_ARCHIVE_FOUND
	archive_found.emit(archive_id, found_archives[archive_id])
	score_changed.emit(total_score, SCORE_ARCHIVE_FOUND, "Temuan Arsip Sejarah")
	save_game()
	return SCORE_ARCHIVE_FOUND


func has_archive(archive_id: String) -> bool:
	return found_archives.has(archive_id)


func get_archive_count() -> int:
	return found_archives.size()


func award_badge(badge_name: String) -> bool:
	if badge_name.is_empty() or badges.has(badge_name):
		return false
	badges.append(badge_name)
	badge_awarded.emit(badge_name)
	save_game()
	return true


func has_badge(badge_name: String) -> bool:
	return badges.has(badge_name)


func complete_level(level_num: int) -> void:
	if level_num < 1 or level_num > MAX_LEVEL:
		return
	if not completed_levels.has(level_num):
		completed_levels.append(level_num)
	if level_num == 1:
		award_badge(BADGE_LEVEL_1)
	elif level_num == 2:
		award_badge(BADGE_LEVEL_2)

	var next_lvl := mini(MAX_LEVEL, level_num + 1)
	if next_lvl > unlocked_level:
		unlocked_level = next_lvl
		level_unlocked.emit(unlocked_level)
	save_game()


func record_quiz_result(correct_count: int, total_count: int) -> Dictionary:
	var attempt_total := maxi(1, total_count)
	var attempt_correct := clampi(correct_count, 0, attempt_total)
	var attempt_pct := (float(attempt_correct) / float(attempt_total)) * 100.0

	if not quiz_completed or attempt_pct >= quiz_percentage:
		quiz_correct = attempt_correct
		quiz_total = attempt_total
		quiz_percentage = attempt_pct
	quiz_completed = true

	var earned_badge := false
	if attempt_pct >= QUIZ_PASS_PERCENTAGE:
		earned_badge = award_badge(BADGE_LEVEL_3)

	save_game()
	return {
		"correct": attempt_correct,
		"total": attempt_total,
		"percentage": attempt_pct,
		"best_percentage": quiz_percentage,
		"passed": attempt_pct >= QUIZ_PASS_PERCENTAGE,
		"earned_badge": earned_badge,
	}


func is_level_unlocked(level_num: int) -> bool:
	if level_num < 1 or level_num > MAX_LEVEL:
		return false
	return level_num <= unlocked_level


func is_level_completed(level_num: int) -> bool:
	return completed_levels.has(level_num)


func has_save_progress() -> bool:
	return (
		total_score > 0
		or unlocked_level > 1
		or not found_archives.is_empty()
		or not completed_levels.is_empty()
		or not completed_mission_steps.is_empty()
	)


func get_next_playable_level_scene() -> String:
	if unlocked_level >= 3 and not is_level_completed(3):
		return SceneManager.SCENE_LEVEL_3
	if unlocked_level == 2 and not is_level_completed(2):
		return SceneManager.SCENE_LEVEL_2
	if is_level_completed(3):
		return SceneManager.SCENE_ENDING
	return SceneManager.SCENE_LEVEL_1


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"total_score": total_score,
		"unlocked_level": unlocked_level,
		"completed_levels": completed_levels,
		"completed_missions": completed_missions,
		"completed_mission_steps": completed_mission_steps,
		"scored_challenges": scored_challenges,
		"found_archives": found_archives,
		"badges": badges,
		"quiz_correct": quiz_correct,
		"quiz_total": quiz_total,
		"quiz_percentage": quiz_percentage,
		"quiz_completed": quiz_completed,
		"player_settings": player_settings,
	}


func from_dict(data: Dictionary) -> void:
	total_score = int(data.get("total_score", 0))
	unlocked_level = clampi(int(data.get("unlocked_level", 1)), 1, MAX_LEVEL)

	completed_levels.clear()
	var raw_levels: Variant = data.get("completed_levels", [])
	if raw_levels is Array:
		for lv in raw_levels:
			var lv_int := int(lv)
			if lv_int >= 1 and lv_int <= MAX_LEVEL and not completed_levels.has(lv_int):
				completed_levels.append(lv_int)

	var raw_missions: Variant = data.get("completed_missions", {})
	completed_missions = raw_missions.duplicate(true) if raw_missions is Dictionary else {}

	var raw_steps: Variant = data.get("completed_mission_steps", {})
	completed_mission_steps = raw_steps.duplicate(true) if raw_steps is Dictionary else {}

	var raw_challenges: Variant = data.get("scored_challenges", {})
	scored_challenges = raw_challenges.duplicate(true) if raw_challenges is Dictionary else {}

	var raw_archives: Variant = data.get("found_archives", {})
	found_archives = raw_archives.duplicate(true) if raw_archives is Dictionary else {}

	badges.clear()
	var raw_badges: Variant = data.get("badges", [])
	if raw_badges is Array:
		for b in raw_badges:
			var b_str := str(b)
			if not b_str.is_empty() and not badges.has(b_str):
				badges.append(b_str)

	quiz_correct = int(data.get("quiz_correct", 0))
	quiz_total = maxi(1, int(data.get("quiz_total", 10)))
	quiz_percentage = float(data.get("quiz_percentage", 0.0))
	quiz_completed = bool(data.get("quiz_completed", false))

	var raw_settings: Variant = data.get("player_settings", {})
	if raw_settings is Dictionary:
		player_settings["muted"] = bool(raw_settings.get("muted", false))
		player_settings["bgm_volume"] = float(raw_settings.get("bgm_volume", 0.7))
		player_settings["sfx_volume"] = float(raw_settings.get("sfx_volume", 0.85))


func save_game() -> Error:
	var path := get_save_path()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_dict(), "\t"))
	file.close()
	return OK


func load_game() -> Error:
	var path := get_save_path()
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	var parse_err := json.parse(content)
	if parse_err != OK or not (json.data is Dictionary):
		push_warning("[GameManager] File save rusak, menggunakan nilai awal.")
		return ERR_PARSE_ERROR
	from_dict(json.data)
	return OK


func reset_progress() -> void:
	total_score = 0
	unlocked_level = 1
	completed_levels.clear()
	completed_missions.clear()
	completed_mission_steps.clear()
	scored_challenges.clear()
	found_archives.clear()
	badges.clear()
	quiz_correct = 0
	quiz_total = 10
	quiz_percentage = 0.0
	quiz_completed = false
	save_game()
	progress_reset.emit()
