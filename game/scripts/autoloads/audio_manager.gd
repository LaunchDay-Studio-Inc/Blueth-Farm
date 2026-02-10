extends Node
## Audio management system
## Handles music, sound effects, and ambient audio with bus mixing

signal music_changed(track_name: String)

# Audio buses
var master_bus: int
var music_bus: int
var sfx_bus: int
var ambient_bus: int

# Volume settings (0.0 - 1.0)
var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ambient_volume: float = 0.6

# Current music
var current_music: AudioStreamPlayer
var next_music: AudioStreamPlayer
var crossfade_duration: float = 2.0
var is_crossfading: bool = false

# Ambient layers
var ambient_players: Dictionary = {}
var ambient_layer_volumes: Dictionary = {
	"ocean_waves": 1.0,
	"wind": 0.0,
	"birds": 0.0,
	"rain": 0.0
}


func _ready() -> void:
	print("AudioManager initialized")
	_setup_audio_buses()
	_create_music_players()
	_create_ambient_players()


func _setup_audio_buses() -> void:
	"""Set up audio bus indices"""
	master_bus = AudioServer.get_bus_index("Master")
	
	# Create buses if they don't exist
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		var music_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_idx, "Music")
		AudioServer.set_bus_send(music_idx, "Master")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var sfx_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")
	
	if AudioServer.get_bus_index("Ambient") == -1:
		AudioServer.add_bus()
		var ambient_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(ambient_idx, "Ambient")
		AudioServer.set_bus_send(ambient_idx, "Master")
	
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	ambient_bus = AudioServer.get_bus_index("Ambient")
	
	# Set initial volumes
	_apply_volume_settings()


func _create_music_players() -> void:
	"""Create audio stream players for music"""
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Music"
	add_child(current_music)
	
	next_music = AudioStreamPlayer.new()
	next_music.bus = "Music"
	next_music.volume_db = -80
	add_child(next_music)


func _create_ambient_players() -> void:
	"""Create looping ambient audio players"""
	for layer in ambient_layer_volumes.keys():
		var player = AudioStreamPlayer.new()
		player.bus = "Ambient"
		player.volume_db = linear_to_db(0.0)  # Start silent
		add_child(player)
		ambient_players[layer] = player

		# Load ocean waves ambient immediately
		if layer == "ocean_waves":
			var stream = load("res://assets/audio/ambient/ocean_waves.wav")
			if stream:
				player.stream = stream
				player.volume_db = linear_to_db(ambient_layer_volumes[layer])
				# Loop the ambient sound
				if stream is AudioStreamWAV:
					stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
				player.play()
				print("Loaded ocean ambient audio")


func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 - 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	_apply_volume_settings()


func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 - 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	_apply_volume_settings()


func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 - 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	_apply_volume_settings()


func set_ambient_volume(volume: float) -> void:
	"""Set ambient volume (0.0 - 1.0)"""
	ambient_volume = clamp(volume, 0.0, 1.0)
	_apply_volume_settings()


func _apply_volume_settings() -> void:
	"""Apply volume settings to audio buses"""
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(ambient_bus, linear_to_db(ambient_volume))


func play_music(track_name: String, crossfade: bool = true) -> void:
	"""Play a music track with optional crossfade"""
	print("Playing music: ", track_name)

	# Try to load the music track (support both .wav and .ogg)
	var stream = null
	var wav_path = "res://assets/audio/music/" + track_name + ".wav"
	var ogg_path = "res://assets/audio/music/" + track_name + ".ogg"

	if ResourceLoader.exists(wav_path):
		stream = load(wav_path)
	elif ResourceLoader.exists(ogg_path):
		stream = load(ogg_path)

	if stream == null:
		print("Music track not found: ", track_name)
		return

	# Set loop mode for music
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	if crossfade and current_music.playing:
		_crossfade_music(stream)
	else:
		current_music.stop()
		current_music.stream = stream
		current_music.play()
		music_changed.emit(track_name)


func _crossfade_music(new_stream: AudioStream) -> void:
	"""Crossfade from current music to new music"""
	is_crossfading = true
	
	# Would implement actual crossfading here
	# For now, just switch
	current_music.stop()
	if new_stream:
		current_music.stream = new_stream
		current_music.play()
	
	is_crossfading = false


func stop_music(fade_out: bool = true) -> void:
	"""Stop currently playing music"""
	if fade_out:
		# Would implement fade out here
		pass
	current_music.stop()


func play_sfx(sfx_name: String, volume: float = 1.0) -> void:
	"""Play a one-shot sound effect"""
	# Create a one-shot player
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.volume_db = linear_to_db(volume)
	add_child(player)

	# Try to load the sound effect (support both .wav and .ogg)
	var stream = null
	var wav_path = "res://assets/audio/sfx/" + sfx_name + ".wav"
	var ogg_path = "res://assets/audio/sfx/" + sfx_name + ".ogg"

	if ResourceLoader.exists(wav_path):
		stream = load(wav_path)
	elif ResourceLoader.exists(ogg_path):
		stream = load(ogg_path)

	if stream:
		player.stream = stream
		player.play()
	else:
		print("SFX not found: ", sfx_name)

	# Clean up when finished
	player.finished.connect(func(): player.queue_free())


func update_ambient_layers(ecosystem_health: float, weather: String, biodiversity: float) -> void:
	"""Update ambient layer volumes based on game state"""
	# Ocean waves - always present, varies with proximity
	ambient_layer_volumes["ocean_waves"] = 0.8
	
	# Wind - increases in bad weather
	if weather == "storm":
		ambient_layer_volumes["wind"] = 1.0
	elif weather == "rain":
		ambient_layer_volumes["wind"] = 0.6
	else:
		ambient_layer_volumes["wind"] = 0.3
	
	# Birds - increases with biodiversity
	ambient_layer_volumes["birds"] = biodiversity / 100.0
	
	# Rain - only during rain/storm
	if weather in ["rain", "storm"]:
		ambient_layer_volumes["rain"] = 1.0
	else:
		ambient_layer_volumes["rain"] = 0.0
	
	# Apply volumes to players
	for layer in ambient_layer_volumes:
		if layer in ambient_players:
			var target_volume = ambient_layer_volumes[layer]
			ambient_players[layer].volume_db = linear_to_db(max(target_volume, 0.001))


func get_save_data() -> Dictionary:
	"""Get audio settings for saving"""
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"ambient_volume": ambient_volume
	}


func load_save_data(data: Dictionary) -> void:
	"""Load audio settings from save"""
	master_volume = data.get("master_volume", 0.8)
	music_volume = data.get("music_volume", 0.7)
	sfx_volume = data.get("sfx_volume", 0.8)
	ambient_volume = data.get("ambient_volume", 0.6)
	_apply_volume_settings()
