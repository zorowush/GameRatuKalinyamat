extends Node
## Mengelola BGM & SFX dengan fallback nada sintetis (AudioStreamWAV)
## dan dukungan aman kebijakan autoplay Web (HTML5).

signal mute_changed(is_muted: bool)

var _bgm_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _current_bgm_name: String = ""
var _web_audio_unlocked: bool = false
var _muted: bool = false
var _synth_sfx: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)

	_muted = bool(GameManager.player_settings.get("muted", false))
	_apply_volumes()
	_build_fallback_sfx()


func _exit_tree() -> void:
	if _bgm_player != null:
		_bgm_player.stop()
		_bgm_player.stream = null
	if _sfx_player != null:
		_sfx_player.stop()
		_sfx_player.stream = null
	_synth_sfx.clear()


func unlock_web_audio() -> void:
	_web_audio_unlocked = true
	if not _current_bgm_name.is_empty() and not _bgm_player.playing and not _muted:
		play_bgm(_current_bgm_name)


func play_bgm(track_name: String) -> void:
	_current_bgm_name = track_name
	if _muted:
		return
	if OS.has_feature("web") and not _web_audio_unlocked:
		return

	var ogg_path := "res://Assets/Audio/BGM/%s.ogg" % track_name
	var stream := AssetLoader.load_audio_or_null(ogg_path)
	if stream == null:
		# Jika aset BGM dari Anggi belum diletakkan, biarkan hening tanpa error
		return
	if _bgm_player.stream == stream and _bgm_player.playing:
		return
	_bgm_player.stop()
	_bgm_player.stream = stream
	_apply_volumes()
	if AudioServer.get_driver_name() != "Dummy":
		_bgm_player.play()


func stop_bgm() -> void:
	_current_bgm_name = ""
	if _bgm_player != null:
		_bgm_player.stop()


func play_sfx(sfx_name: String) -> void:
	if _muted:
		return
	if OS.has_feature("web") and not _web_audio_unlocked:
		_web_audio_unlocked = true

	var stream: AudioStream = null
	var ogg_path := "res://Assets/Audio/SFX/sfx_%s.ogg" % sfx_name
	var wav_path := "res://Assets/Audio/SFX/sfx_%s.wav" % sfx_name
	stream = AssetLoader.load_audio_or_null(ogg_path)
	if stream == null:
		stream = AssetLoader.load_audio_or_null(wav_path)
	if stream == null and _synth_sfx.has(sfx_name):
		stream = _synth_sfx[sfx_name]
	if stream == null:
		return

	_sfx_player.stop()
	_sfx_player.stream = stream
	_apply_volumes()
	if AudioServer.get_driver_name() != "Dummy":
		_sfx_player.play()


func set_muted(muted: bool) -> void:
	_muted = muted
	GameManager.player_settings["muted"] = _muted
	GameManager.save_game()
	if _muted:
		_bgm_player.stop()
	elif not _current_bgm_name.is_empty():
		play_bgm(_current_bgm_name)
	mute_changed.emit(_muted)


func toggle_mute() -> bool:
	set_muted(not _muted)
	return _muted


func is_muted() -> bool:
	return _muted


func _apply_volumes() -> void:
	var bgm_lin := clampf(float(GameManager.player_settings.get("bgm_volume", 0.7)), 0.01, 1.0)
	var sfx_lin := clampf(float(GameManager.player_settings.get("sfx_volume", 0.85)), 0.01, 1.0)
	if _bgm_player != null:
		_bgm_player.volume_db = linear_to_db(bgm_lin)
	if _sfx_player != null:
		_sfx_player.volume_db = linear_to_db(sfx_lin)


func _build_fallback_sfx() -> void:
	_synth_sfx["click"] = _make_tone_wav([520.0], 0.06, 0.25)
	_synth_sfx["correct"] = _make_tone_wav([523.25, 659.25, 783.99], 0.11, 0.30)
	_synth_sfx["wrong"] = _make_tone_wav([240.0, 190.0], 0.14, 0.28)
	_synth_sfx["archive"] = _make_tone_wav([587.33, 880.0], 0.12, 0.28)
	_synth_sfx["badge"] = _make_tone_wav([523.25, 659.25, 783.99, 1046.5], 0.13, 0.32)


func _make_tone_wav(freqs: Array, note_duration: float, amplitude: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var samples_per_note := int(sample_rate * note_duration)
	var total_samples := samples_per_note * freqs.size()
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)

	var idx := 0
	for f in freqs:
		var freq := float(f)
		for i in range(samples_per_note):
			var t := float(i) / float(sample_rate)
			var progress := float(i) / float(maxi(1, samples_per_note))
			var env := sin(progress * PI)
			var sample_val := sin(TAU * freq * t) * amplitude * env
			var s16 := int(clampf(sample_val, -1.0, 1.0) * 32767.0)
			bytes.encode_s16(idx * 2, s16)
			idx += 1

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav
