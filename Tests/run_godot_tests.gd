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
	# Isolate all test writes away from player's real user://save_data.json
	GameManager.save_path_override = TEST_SAVE_PATH

	_test_input_map_actions()
	_test_game_manager_scoring_and_edge_cases()
	_test_game_manager_persistence_and_reset()
	_test_mission_manager_persistence_and_reset()
	_test_asset_loader_and_fallbacks()
	_test_audio_manager()
	_test_dialogue_manager_edge_cases()
	_test_instantiate_all_scenes()
	_test_pause_layering_and_interaction_lock()
	_test_all_six_minigames()

	# Clean up temporary test save WITHOUT ever overwriting real user://save_data.json
	GameManager.reset_progress()
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	GameManager.save_path_override = ""

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


func _test_input_map_actions() -> void:
	print("[1/10] Testing InputMap keyboard actions (WASD/Arrows/E/ESC/Enter)...")
	var checks := [
		["move_up", KEY_W],
		["move_up", KEY_UP],
		["move_down", KEY_S],
		["move_down", KEY_DOWN],
		["move_left", KEY_A],
		["move_left", KEY_LEFT],
		["move_right", KEY_D],
		["move_right", KEY_RIGHT],
		["interact", KEY_E],
		["pause", KEY_ESCAPE],
		["confirm", KEY_ENTER],
		["cancel", KEY_ESCAPE],
	]
	for pair in checks:
		var action_name: String = pair[0]
		var key_code: Key = pair[1]
		_assert(InputMap.has_action(action_name), "InputMap must define action '%s'" % action_name)
		var ev := InputEventKey.new()
		ev.device = 0
		ev.physical_keycode = key_code
		ev.pressed = true
		_assert(InputMap.event_is_action(ev, action_name), "Device-0 key %d must match action '%s'" % [key_code, action_name])


func _test_game_manager_scoring_and_edge_cases() -> void:
	print("[2/10] Testing GameManager scoring, badges, unlock boundaries & quiz high-water mark...")
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

	# Lower replay score must NOT overwrite best saved quiz score (high-water mark)
	var res_replay_low := GameManager.record_quiz_result(4, 10)
	_assert(res_replay_low["percentage"] == 40.0, "Replay dict returns current attempt percentage (40%)")
	_assert(GameManager.quiz_correct == 7 and GameManager.quiz_percentage == 70.0, "Saved quiz_percentage retains best score (70%)")


func _test_game_manager_persistence_and_reset() -> void:
	print("[3/10] Testing Save/Load JSON persistence and corrupt file resilience...")
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


func _test_mission_manager_persistence_and_reset() -> void:
	print("[4/10] Testing MissionManager across levels 1-3, mid-level persistence & auto-reset...")
	GameManager.reset_progress()
	for lv in [1, 2, 3]:
		MissionManager.start_level_missions(lv)
		var steps := MissionManager.get_level_steps(lv)
		_assert(steps.size() == 4, "Level %d must have 4 mission steps" % lv)
		_assert(not MissionManager.get_active_objective_text().is_empty(), "Level %d active objective must be non-empty" % lv)

	MissionManager.complete_step("l1_intro", false)
	MissionManager.complete_step("l1_challenge_chronology", false)
	_assert(MissionManager.is_step_completed("l1_intro"), "Completed step must be tracked")
	_assert(not MissionManager.are_required_steps_completed(["l1_challenge_chronology", "l1_challenge_tapa"]), "Partial required steps must return false")

	# Verify mid-level step persists across save/load
	GameManager.completed_mission_steps.clear()
	_assert(not MissionManager.is_step_completed("l1_challenge_chronology"), "Cleared in-memory steps before reload")
	_assert(GameManager.load_game() == OK, "Reload save with mid-level mission steps")
	_assert(MissionManager.is_step_completed("l1_challenge_chronology"), "Mid-level mission step must persist across save/load")

	# Verify GameManager.reset_progress() automatically clears MissionManager state!
	GameManager.reset_progress()
	_assert(not MissionManager.is_step_completed("l1_challenge_chronology"), "GameManager.reset_progress must automatically clear MissionManager steps")


func _test_asset_loader_and_fallbacks() -> void:
	print("[5/10] Testing AssetLoader JSON loading, fallback textures & tag styles...")
	var tex := AssetLoader.load_texture_or_placeholder("res://Assets/NonExistent/test.png", Vector2i(64, 64), AssetLoader.COLOR_TERRACOTTA, AssetLoader.COLOR_GOLD, "ship")
	_assert(tex != null and tex.get_width() == 64 and tex.get_height() == 64, "Fallback procedural texture must be 64x64")
	var bad_json: Variant = AssetLoader.load_json_file("res://Data/does_not_exist.json")
	_assert(bad_json == null, "Missing JSON path must safely return null")
	_assert(AssetLoader.get_tag_color("FAKTA") == AssetLoader.COLOR_TAG_FAKTA, "FAKTA color mapping")
	_assert(AssetLoader.get_tag_color("TRADISI") == AssetLoader.COLOR_TAG_TRADISI, "TRADISI color mapping")
	_assert(AssetLoader.get_tag_color("FIKSI GAME") == AssetLoader.COLOR_TAG_FIKSI, "FIKSI GAME color mapping")


func _test_audio_manager() -> void:
	print("[6/10] Testing AudioManager mute toggle & safe playback...")
	var initial_muted := AudioManager.is_muted()
	AudioManager.toggle_mute()
	_assert(AudioManager.is_muted() != initial_muted, "toggle_mute flips state")
	AudioManager.set_muted(false)
	AudioManager.play_sfx("click")
	AudioManager.play_bgm("bgm_menu")
	AudioManager.stop_bgm()
	_assert(true, "AudioManager playback calls completed without crash")


func _test_dialogue_manager_edge_cases() -> void:
	print("[7/10] Testing DialogueManager valid/invalid IDs, choices & silent cancel...")
	var bad := DialogueManager.start_dialogue_from_file("res://Data/Dialogues/level1_dialogues.json", "unknown_id")
	_assert(bad == false and not DialogueManager.is_dialogue_active(), "Unknown dialogue_id must safely return false")

	# Silent cancel (used by SceneManager) must NOT emit dialogue_finished
	var finished_fired := [false]
	var cb := func(_id: String, _flags: Array): finished_fired[0] = true
	DialogueManager.dialogue_finished.connect(cb)

	var ok := DialogueManager.start_dialogue_from_file("res://Data/Dialogues/level1_dialogues.json", "penobatan_1549")
	_assert(ok == true and DialogueManager.is_dialogue_active(), "Valid dialogue starts cleanly")
	DialogueManager.close_dialogue(false)
	_assert(not DialogueManager.is_dialogue_active(), "close_dialogue(false) resets active flag")
	_assert(finished_fired[0] == false, "close_dialogue(false) must NOT emit dialogue_finished")

	# Normal completion with choice flag
	var captured_flags := []
	var cb_flags := func(_id: String, flags: Array): captured_flags.assign(flags)
	DialogueManager.dialogue_finished.connect(cb_flags)
	DialogueManager.start_dialogue_from_file("res://Data/Dialogues/level1_dialogues.json", "prolog_keraton")
	DialogueManager.call("_on_next_pressed") # line 1 -> 2
	DialogueManager.call("_on_next_pressed") # line 2 -> 3 (choices)
	DialogueManager.call("_on_choice_selected", "asked_labels", "Test reply")
	_assert(DialogueManager.get("_next_button").text == "Selesai ✓", "Final line after choice reply must show 'Selesai ✓'")
	DialogueManager.call("_on_next_pressed") # finish
	_assert(not DialogueManager.is_dialogue_active(), "Dialogue closes after final next")
	_assert(finished_fired[0] == true and captured_flags.has("asked_labels"), "Normal dialogue finish emits signal & chosen flags")

	DialogueManager.dialogue_finished.disconnect(cb)
	DialogueManager.dialogue_finished.disconnect(cb_flags)


func _test_instantiate_all_scenes() -> void:
	print("[8/10] Instantiating & entering SceneTree for ALL 18 playable/UI scenes...")
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


func _test_pause_layering_and_interaction_lock() -> void:
	print("[9/10] Testing HUD ModalLayer above ChallengeLayer & interaction lock guard...")
	GameManager.reset_progress()
	var lv1 := (load("res://Scenes/Levels/Level1/Level1.tscn") as PackedScene).instantiate()
	add_child(lv1)

	var hud_node: CanvasLayer = lv1.get("hud")
	var challenge_layer: CanvasLayer = lv1.get("_challenge_layer")
	var modal_layer := hud_node.get_node_or_null("ModalLayer") as CanvasLayer
	_assert(modal_layer != null, "GameplayHUD must have dedicated ModalLayer")
	_assert(modal_layer.layer > challenge_layer.layer, "HUD ModalLayer (%d) must render ABOVE ChallengeLayer (%d)" % [modal_layer.layer, challenge_layer.layer])
	_assert(modal_layer.layer > 60, "HUD ModalLayer must also render above DialogueLayer (60)")

	# Open a challenge and confirm interaction lock blocks triggering another spot
	lv1.call("_handle_spot_interacted", "challenge_chronology")
	_assert(lv1.call("is_interaction_locked") == true, "Opening challenge must lock arena interactions")
	lv1.call("_handle_spot_interacted", "l1_arc_silsilah")
	_assert(not GameManager.has_archive("l1_arc_silsilah"), "Archive spot must NOT trigger while challenge is open")

	# Toggle pause while challenge is open and unpause cleanly
	hud_node.call("_toggle_pause")
	_assert(get_tree().paused == true and hud_node.call("is_any_overlay_open") == true, "Pause activates cleanly over challenge")
	hud_node.call("_toggle_pause")
	_assert(get_tree().paused == false, "Unpause resumes cleanly")

	remove_child(lv1)
	lv1.free()


func _test_all_six_minigames() -> void:
	print("[10/10] Testing ALL 6 live mini-game state machines...")
	GameManager.reset_progress()

	# 1. ChronologyPuzzle (1A)
	var chrono := (load("res://Scenes/Challenges/ChronologyPuzzle.tscn") as PackedScene).instantiate()
	add_child(chrono)
	chrono.call("_on_check_pressed")
	_assert(GameManager.total_score == 0, "1A: Scrambled chronology check awards 0")
	var raw_events: Array = chrono.get("_data").get("events", [])
	chrono.set("_current_order", raw_events.duplicate())
	chrono.call("_on_check_pressed")
	_assert(GameManager.total_score == 10, "1A: Sorted chronology awards +10")
	remove_child(chrono)
	chrono.free()

	# 2. TapaInvestigation (1B)
	var tapa := (load("res://Scenes/Challenges/TapaInvestigation.tscn") as PackedScene).instantiate()
	add_child(tapa)
	tapa.call("_select_conclusion", 1) # correct conclusion, 0 cards checked
	tapa.call("_on_verify_pressed")
	_assert(GameManager.total_score == 10 and not bool(tapa.get("_solved")), "1B: <2 evidence cards must reject verification")
	var ev_checks: Dictionary = tapa.get("_evidence_checks")
	var keys := ev_checks.keys()
	(ev_checks[keys[0]] as CheckBox).button_pressed = true
	(ev_checks[keys[1]] as CheckBox).button_pressed = true
	tapa.call("_select_conclusion", 0) # wrong conclusion
	tapa.call("_on_verify_pressed")
	_assert(GameManager.total_score == 10 and not bool(tapa.get("_solved")), "1B: Wrong conclusion awards 0")
	tapa.call("_select_conclusion", 1) # right symbolic conclusion
	tapa.call("_on_verify_pressed")
	_assert(GameManager.total_score == 20 and bool(tapa.get("_solved")), "1B: >=2 cards + symbolic conclusion awards +10")
	remove_child(tapa)
	tapa.free()

	# 3. CommendaTradeGame (2A)
	var trade := (load("res://Scenes/Challenges/CommendaTradeGame.tscn") as PackedScene).instantiate()
	add_child(trade)
	trade.call("_on_port_chosen", "Makassar") # turn 0 correct is Malaka
	_assert(GameManager.total_score == 20, "2A: Wrong trade port awards 0")
	trade.call("_on_port_chosen", "Malaka")
	_assert(GameManager.total_score == 30, "2A: Correct trade port awards +10")
	remove_child(trade)
	trade.free()

	# 4. DiplomacyGame (2B) — all 3 envoys (Johor, Hitu, Aceh)
	var dip := (load("res://Scenes/Challenges/DiplomacyGame.tscn") as PackedScene).instantiate()
	add_child(dip)
	var dip_done := [false]
	dip.connect("challenge_completed", func(s: bool): dip_done[0] = s)
	var dip_missions: Array = dip.get("_missions")
	for mi in range(dip_missions.size()):
		var opts: Array = dip_missions[mi].get("options", [])
		var wrong_i := -1
		var right_i := -1
		for oi in range(opts.size()):
			if bool(opts[oi].get("is_correct", false)):
				right_i = oi
			elif wrong_i == -1:
				wrong_i = oi
		var score_before := GameManager.total_score
		dip.call("_on_option_chosen", wrong_i)
		_assert(GameManager.total_score == score_before, "2B mission %d: wrong envoy reply awards 0" % mi)
		dip.call("_on_option_chosen", right_i)
		_assert(GameManager.total_score == score_before + 10, "2B mission %d: right envoy reply awards +10" % mi)
		dip.call("_on_next_pressed")
	_assert(dip_done[0] == true, "2B: Completing all 3 envoys emits challenge_completed(true)")
	remove_child(dip)
	dip.free()

	# 5. ExpeditionStrategyGame (3A) — spirit depletion, retry recovery, 4 scenarios + reflection phase
	var exp := (load("res://Scenes/Challenges/ExpeditionStrategyGame.tscn") as PackedScene).instantiate()
	add_child(exp)
	var exp_done := [false]
	exp.connect("challenge_completed", func(s: bool): exp_done[0] = s)
	# Deplete 3 Armada Spirit on scenario 0 (option 0 is wrong)
	exp.call("_on_scenario_option", 0)
	exp.call("_on_scenario_option", 0)
	exp.call("_on_scenario_option", 0)
	_assert(int(exp.get("_spirit")) == 0 and bool(exp.get("_retry_btn").visible), "3A: 3 wrong choices deplete spirit & show retry")
	exp.call("_on_retry_pressed")
	_assert(int(exp.get("_spirit")) == 3 and not bool(exp.get("_retry_btn").visible), "3A: Retry restores spirit to 3")
	# Answer all 4 scenarios correctly
	var exp_scenarios: Array = exp.get("_scenarios")
	for si in range(exp_scenarios.size()):
		var opts: Array = exp_scenarios[si].get("options", [])
		var right_i := 0
		for oi in range(opts.size()):
			if bool(opts[oi].get("is_correct", false)):
				right_i = oi
				break
		exp.call("_on_scenario_option", right_i)
		exp.call("_on_action_pressed")
	_assert(bool(exp.get("_in_reflection")) == true, "3A: Finishing 4 scenarios enters reflection phase")
	# Check wrong combination (including false factor) -> 0 pts
	var ref_checks: Dictionary = exp.get("_reflection_checks")
	for fid in ref_checks.keys():
		(ref_checks[fid]["box"] as CheckBox).button_pressed = true
	var score_before_ref := GameManager.total_score
	exp.call("_on_action_pressed")
	_assert(GameManager.total_score == score_before_ref and not bool(exp.get("_answered")), "3A: Checking false reflection factor awards 0")
	# Check exact 4 true factors only -> +10 pts
	for fid in ref_checks.keys():
		(ref_checks[fid]["box"] as CheckBox).button_pressed = bool(ref_checks[fid]["is_true"])
	exp.call("_on_action_pressed")
	_assert(GameManager.total_score == score_before_ref + 10 and bool(exp.get("_answered")), "3A: Checking exact 4 true factors awards +10")
	exp.call("_on_action_pressed") # emit challenge_completed
	_assert(exp_done[0] == true, "3A: Reflection finish emits challenge_completed(true)")
	remove_child(exp)
	exp.free()

	# 6. HeritageQuizGame (3B) — 7/10 awards De Kranige Dame, replay does not duplicate points or lower best %
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
	_assert(GameManager.quiz_correct == 7 and GameManager.quiz_percentage == 70.0, "3B: Quiz records 7/10 (70%)")
	_assert(GameManager.has_badge(GameManager.BADGE_LEVEL_3), "3B: 70% live quiz completion awards De Kranige Dame")
	_assert(not bool(quiz.get("_q_tag_panel").visible), "3B: Results screen hides previous question source tag")
	remove_child(quiz)
	quiz.free()
