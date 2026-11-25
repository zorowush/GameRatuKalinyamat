extends Node
## Automated Godot 4 Headless Integration & Unit Test Runner.
## Run via:
## Godot_v4.7.2-stable_win64_console.exe --headless --path . res://Tests/TestRunner.tscn

const TEST_SAVE_PATH := "res://Tests/.tmp_test_save.json"

var _passed: int = 0
var _failed: int = 0
var _failures: Array[String] = []


func _ready() -> void:
	print("=== GODOT HEADLESS TEST SUITE: JEJAK SANG RATU ===")
	_test_game_manager_scoring_and_edge_cases()
	_test_game_manager_persistence_and_reset()
	_test_mission_manager()
	_test_asset_loader_and_fallbacks()
	_test_audio_manager()
	_test_dialogue_manager_edge_cases()
	_test_instantiate_all_scenes()
	_test_minigame_interactions()

	# Clean up temporary save override & test file
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	GameManager.save_path_override = ""
	GameManager.reset_progress()

	print("=== SUMMARY: %d PASSED, %d FAILED ===" % [_passed, _failed])
	await get_tree().process_frame
	if _failed > 0:
		for f in _failures:
			push_error("[TEST FAIL] " + f)
		get_tree().quit(1)
	else:
		print("ALL GODOT HEADLESS TESTS PASSED.")
		get_tree().quit(0)


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
	else:
		_failed += 1
		_failures.append(msg)
		print("  [FAIL] " + msg)


func _test_game_manager_scoring_and_edge_cases() -> void:
	print("[1/8] Testing GameManager scoring, badges, unlock boundaries & edge cases...")
	GameManager.save_path_override = TEST_SAVE_PATH
	GameManager.reset_progress()

	_assert(GameManager.total_score == 0, "Initial score must be 0")
	_assert(GameManager.is_level_unlocked(1) == true, "Level 1 must be unlocked initially")
	_assert(GameManager.is_level_unlocked(2) == false, "Level 2 must be locked initially")
	_assert(GameManager.is_level_unlocked(0) == false, "Level 0 out of range must be false")
	_assert(GameManager.is_level_unlocked(4) == false, "Level 4 out of range must be false")

	# Archive +5 and duplicate prevention
	var g1 := GameManager.record_archive("arc_test", {"title": "Arsip Uji", "source_tag": "FAKTA"})
	_assert(g1 == 5 and GameManager.total_score == 5, "First archive grants +5")
	var g1_dup := GameManager.record_archive("arc_test", {"title": "Arsip Uji"})
	_assert(g1_dup == 0 and GameManager.total_score == 5, "Duplicate archive grants 0")
	_assert(GameManager.record_archive("", {}) == 0, "Empty archive_id grants 0")

	# Challenge wrong = 0, then retry correct = +10, duplicate correct = 0
	var wrong_pts := GameManager.add_challenge_score("step_a", false)
	_assert(wrong_pts == 0 and GameManager.total_score == 5, "Wrong answer grants 0")
	var right_pts := GameManager.add_challenge_score("step_a", true)
	_assert(right_pts == 10 and GameManager.total_score == 15, "Correct retry grants +10")
	var dup_right := GameManager.add_challenge_score("step_a", true)
	_assert(dup_right == 0 and GameManager.total_score == 15, "Duplicate correct challenge grants 0")

	# Mission complete +30 & duplicate prevention
	var m_pts := GameManager.add_mission_score("m_l1")
	_assert(m_pts == 30 and GameManager.total_score == 45, "Mission complete grants +30")
	_assert(GameManager.add_mission_score("m_l1") == 0, "Duplicate mission grants 0")

	# Level completion unlocks next level & awards Level 1/2 badges
	GameManager.complete_level(1)
	_assert(GameManager.is_level_unlocked(2) == true, "Completing Level 1 unlocks Level 2")
	_assert(GameManager.has_badge(GameManager.BADGE_LEVEL_1), "Completing Level 1 awards Penyelidik Sejarah")
	GameManager.complete_level(2)
	_assert(GameManager.is_level_unlocked(3) == true, "Completing Level 2 unlocks Level 3")
	_assert(GameManager.has_badge(GameManager.BADGE_LEVEL_2), "Completing Level 2 awards Ratu Bandar")

	# Quiz boundary: 6/10 (60%) and 69/100 (69%) must NOT award De Kranige Dame; 7/10 (70%) MUST award it
	var res_fail := GameManager.record_quiz_result(6, 10)
	_assert(res_fail["passed"] == false, "6/10 must not pass 70% threshold")
	_assert(not GameManager.has_badge(GameManager.BADGE_LEVEL_3), "6/10 must not award De Kranige Dame")

	var res_edge := GameManager.record_quiz_result(69, 100)
	_assert(res_edge["passed"] == false and not GameManager.has_badge(GameManager.BADGE_LEVEL_3), "69% must not award De Kranige Dame")

	var res_pass := GameManager.record_quiz_result(7, 10)
	_assert(res_pass["passed"] == true and GameManager.has_badge(GameManager.BADGE_LEVEL_3), "7/10 (70%) must award De Kranige Dame")


func _test_game_manager_persistence_and_reset() -> void:
	print("[2/8] Testing Save/Load JSON persistence and corrupt file resilience...")
	GameManager.save_path_override = TEST_SAVE_PATH
	var save_err := GameManager.save_game()
	_assert(save_err == OK, "save_game() to test path must succeed")

	var expected_score := GameManager.total_score
	GameManager.total_score = 0
	GameManager.unlocked_level = 1
	GameManager.badges.clear()

	var load_err := GameManager.load_game()
	_assert(load_err == OK, "load_game() must succeed")
	_assert(GameManager.total_score == expected_score, "Loaded score must match saved score")
	_assert(GameManager.unlocked_level == 3, "Loaded unlocked_level must be 3")
	_assert(GameManager.badges.size() == 3, "Loaded badges count must be 3")

	# Corrupt JSON handling
	var f := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	f.store_string("{invalid json!!!")
	f.close()
	var corrupt_err := GameManager.load_game()
	_assert(corrupt_err == ERR_PARSE_ERROR, "Corrupt save file must return ERR_PARSE_ERROR cleanly")

	# Reset progress
	GameManager.reset_progress()
	_assert(GameManager.total_score == 0 and GameManager.unlocked_level == 1 and GameManager.badges.is_empty(), "reset_progress clears state")


func _test_mission_manager() -> void:
	print("[3/8] Testing MissionManager across levels 1-3...")
	MissionManager.reset_runtime_steps()
	for lv in [1, 2, 3]:
		MissionManager.start_level_missions(lv)
		var steps := MissionManager.get_level_steps(lv)
		_assert(steps.size() == 4, "Level %d must have 4 mission steps" % lv)
		_assert(not MissionManager.get_active_objective_text().is_empty(), "Level %d active objective must be non-empty" % lv)
	MissionManager.complete_step("l1_intro", false)
	_assert(MissionManager.is_step_completed("l1_intro"), "Completed step must be tracked")
	_assert(not MissionManager.are_required_steps_completed(["l1_intro", "l1_challenge_chronology"]), "Partial required steps must return false")
	MissionManager.reset_runtime_steps()


func _test_asset_loader_and_fallbacks() -> void:
	print("[4/8] Testing AssetLoader JSON loading, fallback textures & tag styles...")
	var tex := AssetLoader.load_texture_or_placeholder("res://Assets/NonExistent/test.png", Vector2i(64, 64), AssetLoader.COLOR_TERRACOTTA, AssetLoader.COLOR_GOLD, "ship")
	_assert(tex != null and tex.get_width() == 64 and tex.get_height() == 64, "Fallback procedural texture must be 64x64")
	var bad_json: Variant = AssetLoader.load_json_file("res://Data/does_not_exist.json")
	_assert(bad_json == null, "Missing JSON path must safely return null")
	_assert(AssetLoader.get_tag_color("FAKTA") == AssetLoader.COLOR_TAG_FAKTA, "FAKTA color mapping")
	_assert(AssetLoader.get_tag_color("TRADISI") == AssetLoader.COLOR_TAG_TRADISI, "TRADISI color mapping")
	_assert(AssetLoader.get_tag_color("FIKSI GAME") == AssetLoader.COLOR_TAG_FIKSI, "FIKSI GAME color mapping")


func _test_audio_manager() -> void:
	print("[5/8] Testing AudioManager mute toggle & safe playback...")
	var initial_muted := AudioManager.is_muted()
	AudioManager.toggle_mute()
	_assert(AudioManager.is_muted() != initial_muted, "toggle_mute flips state")
	AudioManager.set_muted(false)
	AudioManager.play_sfx("click")
	AudioManager.play_bgm("bgm_menu")
	AudioManager.stop_bgm()
	_assert(true, "AudioManager playback calls completed without crash")


func _test_dialogue_manager_edge_cases() -> void:
	print("[6/8] Testing DialogueManager valid & invalid dialogue IDs...")
	var bad := DialogueManager.start_dialogue_from_file("res://Data/Dialogues/level1_dialogues.json", "unknown_id")
	_assert(bad == false and not DialogueManager.is_dialogue_active(), "Unknown dialogue_id must safely return false")
	var ok := DialogueManager.start_dialogue_from_file("res://Data/Dialogues/level1_dialogues.json", "prolog_keraton")
	_assert(ok == true and DialogueManager.is_dialogue_active(), "Valid dialogue starts cleanly")
	DialogueManager.close_dialogue()
	_assert(not DialogueManager.is_dialogue_active(), "close_dialogue resets active flag")


func _test_instantiate_all_scenes() -> void:
	print("[7/8] Instantiating & entering SceneTree for ALL 18 playable/UI scenes...")
	var scene_paths := [
		"res://Scenes/Main/SplashScreen.tscn",
		"res://Scenes/Main/MainMenu.tscn",
		"res://Scenes/UI/InstructionsScreen.tscn",
		"res://Scenes/UI/AboutScreen.tscn",
		"res://Scenes/UI/LevelSelectScreen.tscn",
		"res://Scenes/UI/GameplayHUD.tscn",
		"res://Scenes/UI/EndingScreen.tscn",
		"res://Scenes/Characters/Player.tscn",
		"res://Scenes/Interactables/InteractableSpot.tscn",
		"res://Scenes/Challenges/ChronologyPuzzle.tscn",
		"res://Scenes/Challenges/TapaInvestigation.tscn",
		"res://Scenes/Challenges/CommendaTradeGame.tscn",
		"res://Scenes/Challenges/DiplomacyGame.tscn",
		"res://Scenes/Challenges/ExpeditionStrategyGame.tscn",
		"res://Scenes/Challenges/HeritageQuizGame.tscn",
		"res://Scenes/Levels/Level1/Level1.tscn",
		"res://Scenes/Levels/Level2/Level2.tscn",
		"res://Scenes/Levels/Level3/Level3.tscn",
	]

	for sp in scene_paths:
		var packed := load(sp) as PackedScene
		_assert(packed != null, "Failed to load PackedScene: %s" % sp)
		if packed != null:
			var inst := packed.instantiate()
			_assert(inst != null, "Failed to instantiate scene: %s" % sp)
			if inst != null:
				add_child(inst)
				_assert(inst.is_inside_tree(), "Scene failed to enter SceneTree: %s" % sp)
				remove_child(inst)
				inst.free()


func _test_minigame_interactions() -> void:
	print("[8/8] Testing live challenge controllers (Chronology, Commenda Trade, Heritage Quiz)...")
	GameManager.save_path_override = TEST_SAVE_PATH
	GameManager.reset_progress()

	# 1. ChronologyPuzzle: scrambled initial order fails check (0 pts), sorted order succeeds (+10 pts)
	var chrono := (load("res://Scenes/Challenges/ChronologyPuzzle.tscn") as PackedScene).instantiate()
	add_child(chrono)
	chrono.call("_on_check_pressed")
	_assert(GameManager.total_score == 0, "Scrambled chronology check must award 0 points")
	# Sort cards into expected 1..5 order and verify
	var raw_events: Array = chrono.get("_data").get("events", [])
	chrono.set("_current_order", raw_events.duplicate())
	chrono.call("_on_check_pressed")
	_assert(GameManager.total_score == 10, "Correctly ordered chronology must award +10 points")
	remove_child(chrono)
	chrono.free()

	# 2. CommendaTradeGame: wrong port awards 0, correct port awards +10
	var trade := (load("res://Scenes/Challenges/CommendaTradeGame.tscn") as PackedScene).instantiate()
	add_child(trade)
	trade.call("_on_port_chosen", "Makassar") # turn 0 correct is Malaka
	_assert(GameManager.total_score == 10, "Wrong trade port must award 0 points")
	trade.call("_on_port_chosen", "Malaka")
	_assert(GameManager.total_score == 20, "Correct trade port must award +10 points")
	remove_child(trade)
	trade.free()

	# 3. HeritageQuizGame: answer 7/10 correctly -> awards De Kranige Dame
	var quiz := (load("res://Scenes/Challenges/HeritageQuizGame.tscn") as PackedScene).instantiate()
	add_child(quiz)
	quiz.call("_start_quiz")
	var questions: Array = quiz.get("_questions")
	for i in range(questions.size()):
		var q: Dictionary = questions[i]
		var cidx := int(q.get("correct_index", 0))
		var pick := cidx if i < 7 else (cidx + 1) % 4
		quiz.call("_on_answer_pressed", pick)
		quiz.call("_on_next_question")
	_assert(GameManager.quiz_correct == 7 and GameManager.quiz_percentage == 70.0, "Quiz should record 7/10 (70%)")
	_assert(GameManager.has_badge(GameManager.BADGE_LEVEL_3), "70% live quiz completion must award De Kranige Dame")
	remove_child(quiz)
	quiz.free()
