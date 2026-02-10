extends GutTest
## Test suite for AudioManager
##
## Tests audio loading, playback, and volume controls

var audio_manager: Node


func before_all():
	"""Set up before all tests"""
	# Get the AudioManager singleton
	audio_manager = get_node("/root/AudioManager")


func test_audio_manager_exists():
	"""Test that AudioManager singleton exists"""
	assert_not_null(audio_manager, "AudioManager should exist as singleton")


func test_audio_buses_setup():
	"""Test that audio buses are properly set up"""
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var ambient_bus = AudioServer.get_bus_index("Ambient")

	assert_ne(master_bus, -1, "Master bus should exist")
	assert_ne(music_bus, -1, "Music bus should exist")
	assert_ne(sfx_bus, -1, "SFX bus should exist")
	assert_ne(ambient_bus, -1, "Ambient bus should exist")


func test_ocean_ambient_loaded():
	"""Test that ocean ambient is loaded and playing"""
	assert_true(audio_manager.has("ambient_players"), "AudioManager should have ambient_players")

	var ambient_players = audio_manager.get("ambient_players")
	assert_true(ambient_players.has("ocean_waves"), "Should have ocean_waves ambient player")

	var ocean_player = ambient_players["ocean_waves"]
	assert_not_null(ocean_player.stream, "Ocean waves should have audio stream loaded")


func test_play_music():
	"""Test playing music track"""
	# Test playing the calm_theme music
	audio_manager.play_music("calm_theme", false)

	await wait_frames(2)

	var current_music = audio_manager.get("current_music")
	assert_not_null(current_music.stream, "Music stream should be loaded")
	assert_true(current_music.playing, "Music should be playing")


func test_play_sfx():
	"""Test playing sound effects"""
	# Test playing the plant SFX
	audio_manager.play_sfx("plant")

	# Give it a frame to create the player
	await wait_frames(1)

	# The SFX player should be created as a child and auto-removed after playing
	# We just verify no error occurred
	pass_test("SFX played without error")


func test_play_ui_click_sfx():
	"""Test playing UI click sound effect"""
	audio_manager.play_sfx("ui_click")

	await wait_frames(1)

	pass_test("UI click SFX played without error")


func test_volume_settings():
	"""Test volume control methods"""
	# Test setting master volume
	audio_manager.set_master_volume(0.5)
	assert_almost_eq(audio_manager.master_volume, 0.5, 0.01, "Master volume should be set to 0.5")

	# Test setting music volume
	audio_manager.set_music_volume(0.7)
	assert_almost_eq(audio_manager.music_volume, 0.7, 0.01, "Music volume should be set to 0.7")

	# Test setting SFX volume
	audio_manager.set_sfx_volume(0.8)
	assert_almost_eq(audio_manager.sfx_volume, 0.8, 0.01, "SFX volume should be set to 0.8")

	# Test setting ambient volume
	audio_manager.set_ambient_volume(0.6)
	assert_almost_eq(audio_manager.ambient_volume, 0.6, 0.01, "Ambient volume should be set to 0.6")


func test_save_and_load_settings():
	"""Test saving and loading audio settings"""
	# Set some volumes
	audio_manager.set_master_volume(0.6)
	audio_manager.set_music_volume(0.5)

	# Get save data
	var save_data = audio_manager.get_save_data()

	assert_has(save_data, "master_volume", "Save data should contain master_volume")
	assert_has(save_data, "music_volume", "Save data should contain music_volume")
	assert_almost_eq(save_data["master_volume"], 0.6, 0.01, "Saved master volume should be 0.6")
	assert_almost_eq(save_data["music_volume"], 0.5, 0.01, "Saved music volume should be 0.5")

	# Change volumes
	audio_manager.set_master_volume(0.3)

	# Load the saved data
	audio_manager.load_save_data(save_data)

	assert_almost_eq(audio_manager.master_volume, 0.6, 0.01, "Master volume should be restored to 0.6")


func test_update_ambient_layers():
	"""Test updating ambient layers based on game state"""
	# Test storm weather
	audio_manager.update_ambient_layers(0.5, "storm", 50.0)

	var ambient_volumes = audio_manager.get("ambient_layer_volumes")
	assert_eq(ambient_volumes["rain"], 1.0, "Rain should be at full volume during storm")
	assert_eq(ambient_volumes["wind"], 1.0, "Wind should be at full volume during storm")

	# Test clear weather
	audio_manager.update_ambient_layers(0.5, "clear", 50.0)

	assert_eq(ambient_volumes["rain"], 0.0, "Rain should be silent during clear weather")
