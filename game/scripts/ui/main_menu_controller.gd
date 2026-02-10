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
	# Open settings menu
	var settings_menu = get_node_or_null("/root/SettingsMenu")
	if not settings_menu:
		settings_menu = get_tree().get_first_node_in_group("settings_menu")
	
	if settings_menu and settings_menu.has_method("show_settings"):
		settings_menu.show_settings("main_menu")
	else:
		print("Settings menu not found")


func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
