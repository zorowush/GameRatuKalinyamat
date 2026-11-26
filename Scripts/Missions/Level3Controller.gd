extends "res://Scripts/Systems/BaseLevelArena.gd"
## Controller Level 3 — Armada ke Malaka, Galeri Warisan, Evaluasi 10 Soal & Epilog.

const DIALOGUES_PATH := "res://Data/Dialogues/level3_dialogues.json"
const ARCHIVES_PATH := "res://Data/Historical_Data/level3_archives.json"
const EXPEDITION_SCENE := "res://Scenes/Challenges/ExpeditionStrategyGame.tscn"
const QUIZ_SCENE := "res://Scenes/Challenges/HeritageQuizGame.tscn"

var _intro_played: bool = false


func _ready() -> void:
	init_arena(
		3,
		"Level 3: Armada ke Malaka (Dewan Perang, Warisan & Evaluasi)",
		"res://Assets/Environments/bg_level3.png",
		Color("#241F29"),
		AssetLoader.COLOR_TERRACOTTA_DARK,
		Vector2(220, 565),
		Rect2(50, 465, 2060, 195),
		"res://Assets/Characters/walk_ratu.png"
	)
	player.set_character_label("Ratu Kalinyamat")
	load_archives_from_json(ARCHIVES_PATH)
	_spawn_level3_spots()
	_sync_completed_visuals()
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	if not MissionManager.is_step_completed("l3_intro") and DisplayServer.get_name() != "headless":
		call_deferred("_play_intro_dialogue")


func _exit_tree() -> void:
	if DialogueManager.dialogue_finished.is_connected(_on_dialogue_finished):
		DialogueManager.dialogue_finished.disconnect(_on_dialogue_finished)


func _play_intro_dialogue() -> void:
	if _intro_played:
		return
	_intro_played = true
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "dewan_perang")


func _spawn_level3_spots() -> void:
	# NPC Kiai Demang Laksamana (Quilidamao) di dermaga armada 2160x720
	spawn_spot("npc_laksamana", "Kiai Demang Laksamana\n(Quilidamao)", "npc", Vector2(385, 585), "res://Assets/Characters/walk_prajurit.png")

	# 3 Arsip Sejarah Level 3
	spawn_spot("l3_arc_1551", "Arsip: Ekspedisi\nMalaka 1551", "archive", Vector2(660, 560), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l3_arc_1574", "Arsip: Ekspedisi\nMalaka 1574", "archive", Vector2(940, 575), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l3_arc_pahlawan", "Arsip: Pahlawan\nNasional 2023", "archive", Vector2(1455, 610), "res://Assets/Objects/icon_archive.png")

	# 2 Tantangan Utama Level 3
	spawn_spot("challenge_expedition", "Tantangan 3A:\nPeta Strategi Malaka", "challenge", Vector2(1220, 565), "res://Assets/Objects/icon_challenge.png")
	spawn_spot("challenge_quiz", "Tantangan 3B:\nWarisan & Evaluasi", "challenge", Vector2(1690, 565), "res://Assets/Objects/icon_challenge.png")

	# Monumen Epilog Mantingan (Tamat Game -> EndingScreen)
	spawn_spot("gate_epilog", "Monumen Epilog\nMantingan (Tamat)", "gate", Vector2(1960, 560), "res://Assets/Objects/icon_gate.png")


func _sync_completed_visuals() -> void:
	for aid in archives_data.keys():
		if GameManager.has_archive(aid):
			mark_spot_completed(aid)
	if MissionManager.is_step_completed("l3_intro"):
		mark_spot_completed("npc_laksamana")
	if MissionManager.is_step_completed("l3_challenge_expedition"):
		mark_spot_completed("challenge_expedition")
	if MissionManager.is_step_completed("l3_challenge_quiz"):
		mark_spot_completed("challenge_quiz")
	if MissionManager.is_step_completed("l3_complete"):
		mark_spot_completed("gate_epilog")


func _on_spot_interacted(spot_id: String) -> void:
	match spot_id:
		"npc_laksamana":
			DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "dewan_perang")
		"l3_arc_1551", "l3_arc_1574", "l3_arc_pahlawan":
			trigger_archive(spot_id)
		"challenge_expedition":
			open_challenge_scene(EXPEDITION_SCENE, func():
				MissionManager.complete_step("l3_challenge_expedition", false)
				mark_spot_completed("challenge_expedition")
			)
		"challenge_quiz":
			open_challenge_scene(QUIZ_SCENE, func():
				MissionManager.complete_step("l3_challenge_quiz", false)
				mark_spot_completed("challenge_quiz")
			)
		"gate_epilog":
			_try_complete_level3()


func _on_dialogue_finished(dialogue_id: String, _flags: Array) -> void:
	match dialogue_id:
		"dewan_perang":
			MissionManager.complete_step("l3_intro", false)
			mark_spot_completed("npc_laksamana")
		"epilog_mantingan":
			MissionManager.complete_step("l3_complete", true)
			GameManager.complete_level(3)
			mark_spot_completed("gate_epilog")
			SceneManager.change_scene(SceneManager.SCENE_ENDING)


func _try_complete_level3() -> void:
	var ready := MissionManager.are_required_steps_completed(["l3_challenge_expedition", "l3_challenge_quiz"])
	if not ready:
		AudioManager.play_sfx("wrong")
		hud.show_toast("Selesaikan Tantangan 3A (Ekspedisi) & 3B (Warisan & Evaluasi) dahulu!", AssetLoader.COLOR_TERRACOTTA)
		return
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "epilog_mantingan")


func _draw() -> void:
	super._draw()
	if _has_bg_texture:
		return
	# Zona Peta Selat Malaka dekoratif
	draw_rect(Rect2(580, 125, 420, 190), Color(0.11, 0.25, 0.34, 0.42))
	draw_rect(Rect2(580, 125, 420, 190), AssetLoader.COLOR_GOLD, false, 2.0)
