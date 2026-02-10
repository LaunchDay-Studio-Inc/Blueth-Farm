extends Control
## Pause menu controller

@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var save_button = $Panel/VBoxContainer/SaveButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_on_resume_pressed()
		else:
			show_pause_menu()


func show_pause_menu() -> void:
	"""Show the pause menu"""
	show()
	get_tree().paused = true
	GameManager.set_game_state(GameManager.GameState.PAUSED)


func hide_pause_menu() -> void:
	"""Hide the pause menu"""
	hide()
	get_tree().paused = false
	GameManager.set_game_state(GameManager.GameState.PLAYING)


func _on_resume_pressed() -> void:
	hide_pause_menu()


func _on_save_pressed() -> void:
	SaveManager.save_game(1)
	
	# Show save confirmation to player
	var notification_system = get_node_or_null("/root/GameWorld/NotificationSystem")
	if notification_system and notification_system.has_method("show_notification"):
		notification_system.show_notification("💾 Game saved successfully!", 4)  # BUILDING type for general confirmations


func _on_settings_pressed() -> void:
	# Open settings menu
	var settings_menu = get_node_or_null("/root/GameWorld/SettingsMenu")
	if settings_menu and settings_menu.has_method("show_settings"):
		hide_pause_menu()
		settings_menu.show_settings("pause_menu")
	else:
		print("Settings menu not found in scene tree")


func _on_main_menu_pressed() -> void:
	print("Returning to main menu...")
	hide_pause_menu()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
