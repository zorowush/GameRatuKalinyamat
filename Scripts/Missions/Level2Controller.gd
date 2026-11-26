extends "res://Scripts/Systems/BaseLevelArena.gd"
## Controller Level 2 — Kejayaan Maritim Jepara (Pelabuhan, Seni Ukir & Diplomasi Nusantara).

const DIALOGUES_PATH := "res://Data/Dialogues/level2_dialogues.json"
const ARCHIVES_PATH := "res://Data/Historical_Data/level2_archives.json"
const TRADE_SCENE := "res://Scenes/Challenges/CommendaTradeGame.tscn"
const DIPLOMACY_SCENE := "res://Scenes/Challenges/DiplomacyGame.tscn"

var _intro_played: bool = false


func _ready() -> void:
	init_arena(
		2,
		"Level 2: Kejayaan Maritim Jepara (Bandar Niaga & Diplomasi)",
		"res://Assets/Environments/bg_level2.png",
		Color("#1C353C"),
		AssetLoader.COLOR_SEA_TEAL,
		Vector2(210, 560),
		Rect2(50, 455, 2060, 205),
		"res://Assets/Characters/walk_ratu.png"
	)
	player.set_character_label("Ratu Kalinyamat")
	load_archives_from_json(ARCHIVES_PATH)
	_spawn_level2_spots()
	_sync_completed_visuals()
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	if not MissionManager.is_step_completed("l2_intro") and DisplayServer.get_name() != "headless":
		call_deferred("_play_intro_dialogue")


func _exit_tree() -> void:
	if DialogueManager.dialogue_finished.is_connected(_on_dialogue_finished):
		DialogueManager.dialogue_finished.disconnect(_on_dialogue_finished)


func _play_intro_dialogue() -> void:
	if _intro_played:
		return
	_intro_played = true
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "syahbandar_pelabuhan")


func _spawn_level2_spots() -> void:
	# NPC Syahbandar & Empu Ukir Mantingan (jalur dermaga & pasar pelabuhan 2160x720)
	spawn_spot("npc_syahbandar", "Ki Raksa\n(Syahbandar Jepara)", "npc", Vector2(520, 585), "res://Assets/Characters/walk_penasihat.png")
	spawn_spot("npc_sungging", "Sungging Badar Duwung\n(Seni Ukir Mantingan)", "npc", Vector2(1370, 560), "res://Assets/Characters/portrait_sungging.png")

	# 3 Arsip Maritim & Budaya Level 2
	spawn_spot("l2_arc_couto", "Arsip: Julukan\nDiego de Couto", "archive", Vector2(360, 550), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l2_arc_commenda", "Arsip: Commenda &\n4 Pelabuhan", "archive", Vector2(1145, 535), "res://Assets/Objects/icon_archive.png")
	spawn_spot("l2_arc_ukir", "Arsip: Seni Ukir\nMantingan", "archive", Vector2(1520, 610), "res://Assets/Objects/icon_archive.png")

	# 2 Tantangan Utama Level 2
	spawn_spot("challenge_trade", "Tantangan 2A:\nNiaga Commenda", "challenge", Vector2(855, 555), "res://Assets/Objects/icon_challenge.png")
	spawn_spot("challenge_diplomacy", "Tantangan 2B:\nBalai Diplomasi", "challenge", Vector2(1735, 585), "res://Assets/Characters/walk_utusan.png")

	# Gerbang Akhir Level 2 (Dermaga & papan peta sisi kanan)
	spawn_spot("gate_kejayaan", "Dermaga Kejayaan\n(Tamat Lv.2)", "gate", Vector2(1990, 560), "res://Assets/Objects/icon_gate.png")


func _sync_completed_visuals() -> void:
	for aid in archives_data.keys():
		if GameManager.has_archive(aid):
			mark_spot_completed(aid)
	if MissionManager.is_step_completed("l2_intro"):
		mark_spot_completed("npc_syahbandar")
	if MissionManager.is_step_completed("l2_challenge_trade"):
		mark_spot_completed("challenge_trade")
	if MissionManager.is_step_completed("l2_challenge_diplomacy"):
		mark_spot_completed("challenge_diplomacy")
	if MissionManager.is_step_completed("l2_complete"):
		mark_spot_completed("gate_kejayaan")


func _on_spot_interacted(spot_id: String) -> void:
	match spot_id:
		"npc_syahbandar":
			DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "syahbandar_pelabuhan")
		"npc_sungging":
			DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "sungging_ukir")
			mark_spot_completed("npc_sungging")
		"l2_arc_couto", "l2_arc_commenda", "l2_arc_ukir":
			trigger_archive(spot_id)
		"challenge_trade":
			open_challenge_scene(TRADE_SCENE, func():
				MissionManager.complete_step("l2_challenge_trade", false)
				mark_spot_completed("challenge_trade")
			)
		"challenge_diplomacy":
			open_challenge_scene(DIPLOMACY_SCENE, func():
				MissionManager.complete_step("l2_challenge_diplomacy", false)
				mark_spot_completed("challenge_diplomacy")
			)
		"gate_kejayaan":
			_try_complete_level2()


func _on_dialogue_finished(dialogue_id: String, _flags: Array) -> void:
	match dialogue_id:
		"syahbandar_pelabuhan":
			MissionManager.complete_step("l2_intro", false)
			mark_spot_completed("npc_syahbandar")
		"kejayaan_selesai":
			MissionManager.complete_step("l2_complete", true)
			GameManager.complete_level(2)
			mark_spot_completed("gate_kejayaan")
			show_level_complete_modal(
				"LEVEL 2 SELESAI — KEJAYAAN MARITIM JEPARA!",
				"Jaringan perdagangan commenda di 4 pelabuhan (Jepara, Juana, Rembang, Lasem) berjalan makmur, seni ukir Mantingan berkembang, dan aliansi dengan Johor, Hitu, serta Aceh telah terjalin.\n\nLevel 3 (Armada ke Malaka) kini terbuka!",
				GameManager.BADGE_LEVEL_2,
				SceneManager.SCENE_LEVEL_3,
				"Lanjut ke Level 3 ▶"
			)


func _try_complete_level2() -> void:
	var ready := MissionManager.are_required_steps_completed(["l2_challenge_trade", "l2_challenge_diplomacy"])
	if not ready:
		AudioManager.play_sfx("wrong")
		hud.show_toast("Selesaikan Tantangan 2A (Niaga) & 2B (Diplomasi) terlebih dahulu!", AssetLoader.COLOR_TERRACOTTA)
		return
	DialogueManager.start_dialogue_from_file(DIALOGUES_PATH, "kejayaan_selesai")


func _draw() -> void:
	super._draw()
	if _has_bg_texture:
		return
	# Zona perairan pelabuhan Jepara di sisi bawah-kanan
	draw_rect(Rect2(970, 470, 250, 190), Color(0.08, 0.30, 0.38, 0.55))
	draw_rect(Rect2(970, 470, 250, 190), AssetLoader.COLOR_GOLD, false, 2.0)
