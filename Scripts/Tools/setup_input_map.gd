@tool
extends EditorScript


func _run() -> void:
	# =================================
	# MOVEMENT CONTROLS
	# =================================
	set_action("move_up", [KEY_W, KEY_UP])
	set_action("move_down", [KEY_S, KEY_DOWN])
	set_action("move_left", [KEY_A, KEY_LEFT])
	set_action("move_right", [KEY_D, KEY_RIGHT])

	# =================================
	# INTERACTION
	# =================================
	set_action("interact", [KEY_E])

	# =================================
	# UI CONTROLS
	# =================================
	set_action("pause", [KEY_ESCAPE])
	set_action("confirm", [KEY_ENTER])
	set_action("cancel", [KEY_ESCAPE])

	# =================================
	# SAVE PROJECT SETTINGS
	# =================================
	var result = ProjectSettings.save()

	if result == OK:
		print("================================")
		print(" JEJAK SANG RATU")
		print(" INPUT MAP SETUP SUCCESS!")
		print("================================")
		print("8 Input Actions berhasil dibuat.")
		print("Silakan restart Godot Editor.")
	else:
		push_error("Gagal menyimpan Input Map!")


func set_action(action_name: String, keys: Array) -> void:
	var events: Array[InputEvent] = []

	for key_code in keys:
		var event := InputEventKey.new()
		event.device = -1
		event.physical_keycode = key_code
		events.append(event)

	ProjectSettings.set_setting(
		"input/" + action_name,
		{
			"deadzone": 0.5,
			"events": events
		}
	)
