extends Node
## Audio Testing Scene
##
## Simple scene to manually test audio playback
## Add this to a scene and run it to hear the audio files

@onready var ui_container := VBoxContainer.new()


func _ready() -> void:
	# Set up UI
	add_child(ui_container)
	ui_container.position = Vector2(50, 50)

	# Add test buttons
	_add_button("Play Music (calm_theme)", _on_play_music)
	_add_button("Stop Music", _on_stop_music)
	_add_button("Play SFX (plant)", _on_play_plant_sfx)
	_add_button("Play SFX (ui_click)", _on_play_click_sfx)
	_add_button("Toggle Ocean Ambient", _on_toggle_ocean)

	print("Audio test scene loaded. Click buttons to test audio.")


func _add_button(text: String, callback: Callable) -> void:
	var button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	ui_container.add_child(button)


func _on_play_music() -> void:
	print("Playing calm_theme music...")
	AudioManager.play_music("calm_theme", false)


func _on_stop_music() -> void:
	print("Stopping music...")
	AudioManager.stop_music()


func _on_play_plant_sfx() -> void:
	print("Playing plant SFX...")
	AudioManager.play_sfx("plant")


func _on_play_click_sfx() -> void:
	print("Playing ui_click SFX...")
	AudioManager.play_sfx("ui_click")


func _on_toggle_ocean() -> void:
	var ocean_player = AudioManager.ambient_players.get("ocean_waves")
	if ocean_player:
		if ocean_player.playing:
			ocean_player.stop()
			print("Stopped ocean ambient")
		else:
			ocean_player.play()
			print("Playing ocean ambient")
