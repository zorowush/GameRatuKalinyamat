extends "res://Scripts/Systems/BaseLevelArena.gd"
## Controller Level 1 — Putri dari Demak (Keraton Demak & Bukit Danaraja simbolis).

const DIALOGUES_PATH := "res://Data/Dialogues/level1_dialogues.json"
const ARCHIVES_PATH := "res://Data/Historical_Data/level1_archives.json"
const CHRONOLOGY_SCENE := "res://Scenes/Challenges/ChronologyPuzzle.tscn"
const TAPA_SCENE := "res://Scenes/Challenges/TapaInvestigation.tscn"

var _intro_played: bool = false


func _ready() -> void:
	init_arena(
		1,
		"Level 1: Putri dari Demak (Keraton Demak & Danaraja)",
		"res://Assets/Environments/bg_level1.png",
		Color("#352017"),
		AssetLoader.COLOR_TERRACOTTA,
		Vector2(210, 385)
	)
	player.set_character_label("Retna Kencana")
	load_archives_from_json(ARCHIVES_PATH)
	_spawn_level1_spots()
	_sync_completed_visuals()
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	if not MissionManager.is_step_completed("l1_intro") and DisplayServer.get_name() != "headless":
		call_deferred("_play_intro_dialogue")


func _exit_tree() -> void:
	if DialogueManager.dialogue_finished.is_connected(_on_dialogue_finished):
		DialogueManager.dialogue_finished.disconnect(_on_dialogue_finished)


func _play_intro_dialogue() -> void:
	if _intro_played:
		return
	_intro_played = true
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "prolog_keraton")


func _spawn_level1_spots() -> void:
	# NPC Penasihat Keraton
	spawn_spot("npc_penasihat", "Ki Wira\n(Penasihat Keraton)", "npc", Vector2(210, 210), "res://Assets/Characters/portrait_penasihat.png")

	# 3 Arsip Sejarah Level 1
	spawn_spot("l1_arc_silsilah", "Arsip: Silsilah\nRetna Kencana", "archive", Vector2(450, 195), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l1_arc_hadiri", "Arsip: Versi Asal\nPangeran Hadiri", "archive", Vector2(450, 560), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l1_arc_sengkalan", "Arsip: Sengkalan\n10 April 1549", "archive", Vector2(840, 565), "res://Assets/Objects/icon_archive.png")

	# 2 Tantangan Utama Level 1
	spawn_spot("challenge_chronology", "Tantangan 1A:\nKronologi Demak", "challenge", Vector2(640, 260), "res://Assets/Objects/icon_challenge.png")
	spawn_spot("challenge_tapa", "Tantangan 1B:\nInvestigasi Danaraja", "challenge", Vector2(890, 250), "res://Assets/Objects/icon_challenge.png")

	# Gerbang Akhir Level 1
	spawn_spot("gate_penobatan", "Gerbang Penobatan\n1549 (Tamat Lv.1)", "gate", Vector2(1110, 385), "res://Assets/Objects/icon_gate.png")


func _sync_completed_visuals() -> void:
	for aid in archives_data.keys():
		if GameManager.has_archive(aid):
			mark_spot_completed(aid)
	if MissionManager.is_step_completed("l1_intro"):
		mark_spot_completed("npc_penasihat")
	if MissionManager.is_step_completed("l1_challenge_chronology"):
		mark_spot_completed("challenge_chronology")
	if MissionManager.is_step_completed("l1_challenge_tapa"):
		mark_spot_completed("challenge_tapa")
	if MissionManager.is_step_completed("l1_complete"):
		mark_spot_completed("gate_penobatan")


func _on_spot_interacted(spot_id: String) -> void:
	match spot_id:
		"npc_penasihat":
			DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "prolog_keraton")
		"l1_arc_silsilah", "l1_arc_hadiri", "l1_arc_sengkalan":
			trigger_archive(spot_id)
		"challenge_chronology":
			open_challenge_scene(CHRONOLOGY_SCENE, func():
				MissionManager.complete_step("l1_challenge_chronology", false)
				mark_spot_completed("challenge_chronology")
			)
		"challenge_tapa":
			DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "danaraja_briefing")
		"gate_penobatan":
			_try_complete_level1()


func _on_dialogue_finished(dialogue_id: String, _flags: Array) -> void:
	match dialogue_id:
		"prolog_keraton":
			MissionManager.complete_step("l1_intro", false)
			mark_spot_completed("npc_penasihat")
		"danaraja_briefing":
			open_challenge_scene(TAPA_SCENE, func():
				MissionManager.complete_step("l1_challenge_tapa", false)
				mark_spot_completed("challenge_tapa")
			)
		"penobatan_1549":
			MissionManager.complete_step("l1_complete", true)
			GameManager.complete_level(1)
			mark_spot_completed("gate_penobatan")
			show_level_complete_modal(
				"LEVEL 1 SELESAI — PENOBATAN 1549!",
				"Anda berhasil merangkai kronologi konflik Demak dan menganalisis tafsir simbolis Pertapaan Danaraja secara kritis.\n\nRetna Kencana kini resmi memimpin Jepara sebagai Ratu Kalinyamat. Level 2 (Kejayaan Maritim Jepara) telah terbuka!",
				GameManager.BADGE_LEVEL_1,
				SceneManager.SCENE_LEVEL_2,
				"Lanjut ke Level 2 ▶"
			)


func _try_complete_level1() -> void:
	var ready := MissionManager.are_required_steps_completed(["l1_challenge_chronology", "l1_challenge_tapa"])
	if not ready:
		AudioManager.play_sfx("wrong")
		hud.show_toast("Selesaikan Tantangan 1A & 1B terlebih dahulu sebelum penobatan!", AssetLoader.COLOR_TERRACOTTA)
		return
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "penobatan_1549")


func _draw() -> void:
	super._draw()
	# Zona simbolis kabut Bukit Danaraja di sisi kanan atas (siluet & kabut edukatif)
	draw_rect(Rect2(785, 130, 225, 180), Color(0.18, 0.25, 0.30, 0.42))
	draw_rect(Rect2(785, 130, 225, 180), AssetLoader.COLOR_SEA_TEAL, false, 2.0)
