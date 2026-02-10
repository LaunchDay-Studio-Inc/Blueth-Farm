extends Control
## Main menu controller

@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var load_game_button = $VBoxContainer/LoadGameButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check if saves exist
	load_game_button.disabled = SaveManager.get_all_save_info().is_empty()


func _on_new_game_pressed() -> void:
	print("Starting new game...")
	GameManager.set_game_state(GameManager.GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")


func _on_load_game_pressed() -> void:
	print("Loading game...")
	# For now, load slot 1
	if SaveManager.load_game(1):
		GameManager.set_game_state(GameManager.GameState.PLAYING)
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")


func _on_settings_pressed() -> void:
	print("Settings menu not yet implemented")
	# TODO: Open settings menu


func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
