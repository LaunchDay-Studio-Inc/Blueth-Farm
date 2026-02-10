extends CanvasLayer
## Settings Menu Controller
##
## Manages game settings including audio, display, and gameplay options.
## Saves settings to user://settings.cfg for persistence.

## Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const HEADER_COLOR := Color("#2E5E8C")
const BUTTON_NORMAL_COLOR := Color("#4A7C59")
const BUTTON_HOVER_COLOR := Color("#6B9D6E")

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var tab_container := $MainPanel/MarginContainer/VBoxContainer/TabContainer
@onready var back_button := $MainPanel/MarginContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var apply_button := $MainPanel/MarginContainer/VBoxContainer/ButtonsContainer/ApplyButton

# Audio Tab
@onready var master_volume_slider := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/MasterVolume/Slider
@onready var master_volume_value := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/MasterVolume/ValueLabel
@onready var music_volume_slider := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/MusicVolume/Slider
@onready var music_volume_value := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/MusicVolume/ValueLabel
@onready var sfx_volume_slider := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/SFXVolume/Slider
@onready var sfx_volume_value := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/SFXVolume/ValueLabel
@onready var ambient_volume_slider := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/AmbientVolume/Slider
@onready var ambient_volume_value := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Audio/AudioSettings/AmbientVolume/ValueLabel

# Display Tab
@onready var fullscreen_toggle := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Display/DisplaySettings/FullscreenToggle
@onready var vsync_toggle := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Display/DisplaySettings/VSyncToggle
@onready var resolution_dropdown := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Display/DisplaySettings/ResolutionOption

# Gameplay Tab
@onready var autosave_toggle := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Gameplay/GameplaySettings/AutosaveToggle
@onready var game_speed_slider := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Gameplay/GameplaySettings/GameSpeed/Slider
@onready var game_speed_value := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Gameplay/GameplaySettings/GameSpeed/ValueLabel

## Settings storage
var config := ConfigFile.new()
const SETTINGS_PATH := "user://settings.cfg"

## Resolution options
const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

## Caller tracking (main_menu or pause_menu)
var _caller: String = ""


func _ready() -> void:
	# Set process mode for pause handling
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	back_button.pressed.connect(_on_back_pressed)
	apply_button.pressed.connect(_on_apply_pressed)
	
	# Connect audio sliders
	if master_volume_slider:
		master_volume_slider.value_changed.connect(_on_master_volume_changed)
	if music_volume_slider:
		music_volume_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_volume_slider:
		sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	if ambient_volume_slider:
		ambient_volume_slider.value_changed.connect(_on_ambient_volume_changed)
	
	# Connect display options
	if fullscreen_toggle:
		fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	if vsync_toggle:
		vsync_toggle.toggled.connect(_on_vsync_toggled)
	if resolution_dropdown:
		resolution_dropdown.item_selected.connect(_on_resolution_selected)
	
	# Connect gameplay options
	if autosave_toggle:
		autosave_toggle.toggled.connect(_on_autosave_toggled)
	if game_speed_slider:
		game_speed_slider.value_changed.connect(_on_game_speed_changed)
	
	# Apply styling
	_apply_styling()
	
	# Setup resolution dropdown
	_setup_resolution_dropdown()
	
	# Load settings
	load_settings()


## Show settings menu
func show_settings(caller: String = "") -> void:
	_caller = caller
	visible = true
	
	# Reload settings to ensure we have latest values
	load_settings()


## Hide settings menu
func hide_settings() -> void:
	visible = false
	
	# Return to caller if specified
	if _caller == "pause_menu":
		var pause_menu = get_node_or_null("/root/GameWorld/PauseMenu")
		if pause_menu and pause_menu.has_method("show_pause_menu"):
			pause_menu.show_pause_menu()
	elif _caller == "main_menu":
		# Already on main menu, nothing to do
		pass
	
	_caller = ""


## Apply Art Direction color styling
func _apply_styling() -> void:
	# Main panel styling
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BG_COLOR
	panel_style.border_color = BORDER_COLOR
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	
	if main_panel:
		main_panel.add_theme_stylebox_override("panel", panel_style)


## Setup resolution dropdown with available options
func _setup_resolution_dropdown() -> void:
	if not resolution_dropdown:
		return
	
	resolution_dropdown.clear()
	
	for resolution in RESOLUTIONS:
		var text := str(resolution.x) + " x " + str(resolution.y)
		resolution_dropdown.add_item(text)


## Load settings from file
func load_settings() -> void:
	var err = config.load(SETTINGS_PATH)
	
	if err != OK:
		# No settings file exists, use defaults
		_apply_default_settings()
		return
	
	# Audio settings
	if master_volume_slider:
		master_volume_slider.value = config.get_value("audio", "master_volume", 1.0)
	if music_volume_slider:
		music_volume_slider.value = config.get_value("audio", "music_volume", 0.8)
	if sfx_volume_slider:
		sfx_volume_slider.value = config.get_value("audio", "sfx_volume", 1.0)
	if ambient_volume_slider:
		ambient_volume_slider.value = config.get_value("audio", "ambient_volume", 0.6)
	
	# Display settings
	if fullscreen_toggle:
		fullscreen_toggle.button_pressed = config.get_value("display", "fullscreen", false)
	if vsync_toggle:
		vsync_toggle.button_pressed = config.get_value("display", "vsync", true)
	if resolution_dropdown:
		var res_index = config.get_value("display", "resolution_index", 2)
		resolution_dropdown.selected = res_index
	
	# Gameplay settings
	if autosave_toggle:
		autosave_toggle.button_pressed = config.get_value("gameplay", "autosave", true)
	if game_speed_slider:
		game_speed_slider.value = config.get_value("gameplay", "game_speed", 1.0)
	
	# Apply settings
	_apply_audio_settings()
	_apply_display_settings()
	_apply_gameplay_settings()


## Save settings to file
func save_settings() -> void:
	# Audio settings
	config.set_value("audio", "master_volume", master_volume_slider.value if master_volume_slider else 1.0)
	config.set_value("audio", "music_volume", music_volume_slider.value if music_volume_slider else 0.8)
	config.set_value("audio", "sfx_volume", sfx_volume_slider.value if sfx_volume_slider else 1.0)
	config.set_value("audio", "ambient_volume", ambient_volume_slider.value if ambient_volume_slider else 0.6)
	
	# Display settings
	config.set_value("display", "fullscreen", fullscreen_toggle.button_pressed if fullscreen_toggle else false)
	config.set_value("display", "vsync", vsync_toggle.button_pressed if vsync_toggle else true)
	config.set_value("display", "resolution_index", resolution_dropdown.selected if resolution_dropdown else 2)
	
	# Gameplay settings
	config.set_value("gameplay", "autosave", autosave_toggle.button_pressed if autosave_toggle else true)
	config.set_value("gameplay", "game_speed", game_speed_slider.value if game_speed_slider else 1.0)
	
	var err = config.save(SETTINGS_PATH)
	
	if err != OK:
		push_error("Failed to save settings: " + str(err))
	else:
		print("Settings saved successfully")


## Apply default settings
func _apply_default_settings() -> void:
	if master_volume_slider:
		master_volume_slider.value = 1.0
	if music_volume_slider:
		music_volume_slider.value = 0.8
	if sfx_volume_slider:
		sfx_volume_slider.value = 1.0
	if ambient_volume_slider:
		ambient_volume_slider.value = 0.6
	
	if fullscreen_toggle:
		fullscreen_toggle.button_pressed = false
	if vsync_toggle:
		vsync_toggle.button_pressed = true
	if resolution_dropdown:
		resolution_dropdown.selected = 2
	
	if autosave_toggle:
		autosave_toggle.button_pressed = true
	if game_speed_slider:
		game_speed_slider.value = 1.0


## Apply audio settings to AudioManager
func _apply_audio_settings() -> void:
	if not AudioManager:
		return
	
	# Set bus volumes (convert 0-1 slider to -80 to 0 dB)
	var master_db = linear_to_db(master_volume_slider.value if master_volume_slider else 1.0)
	var music_db = linear_to_db(music_volume_slider.value if music_volume_slider else 0.8)
	var sfx_db = linear_to_db(sfx_volume_slider.value if sfx_volume_slider else 1.0)
	var ambient_db = linear_to_db(ambient_volume_slider.value if ambient_volume_slider else 0.6)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), ambient_db)


## Apply display settings
func _apply_display_settings() -> void:
	# Fullscreen
	if fullscreen_toggle:
		if fullscreen_toggle.button_pressed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# VSync
	if vsync_toggle:
		if vsync_toggle.button_pressed:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Resolution
	if resolution_dropdown and resolution_dropdown.selected >= 0 and resolution_dropdown.selected < RESOLUTIONS.size():
		var resolution = RESOLUTIONS[resolution_dropdown.selected]
		DisplayServer.window_set_size(resolution)


## Apply gameplay settings
func _apply_gameplay_settings() -> void:
	# Autosave
	if SaveManager and autosave_toggle:
		if SaveManager.has_method("set_autosave_enabled"):
			SaveManager.set_autosave_enabled(autosave_toggle.button_pressed)
	
	# Game speed
	if TimeManager and game_speed_slider:
		if TimeManager.has_method("set_time_scale"):
			TimeManager.set_time_scale(game_speed_slider.value)


## Signal handlers

func _on_close_pressed() -> void:
	hide_settings()


func _on_back_pressed() -> void:
	hide_settings()


func _on_apply_pressed() -> void:
	_apply_audio_settings()
	_apply_display_settings()
	_apply_gameplay_settings()
	save_settings()


func _on_master_volume_changed(value: float) -> void:
	if master_volume_value:
		master_volume_value.text = str(int(value * 100)) + "%"
	_apply_audio_settings()


func _on_music_volume_changed(value: float) -> void:
	if music_volume_value:
		music_volume_value.text = str(int(value * 100)) + "%"
	_apply_audio_settings()


func _on_sfx_volume_changed(value: float) -> void:
	if sfx_volume_value:
		sfx_volume_value.text = str(int(value * 100)) + "%"
	_apply_audio_settings()


func _on_ambient_volume_changed(value: float) -> void:
	if ambient_volume_value:
		ambient_volume_value.text = str(int(value * 100)) + "%"
	_apply_audio_settings()


func _on_fullscreen_toggled(_toggled_on: bool) -> void:
	_apply_display_settings()


func _on_vsync_toggled(_toggled_on: bool) -> void:
	_apply_display_settings()


func _on_resolution_selected(_index: int) -> void:
	_apply_display_settings()


func _on_autosave_toggled(_toggled_on: bool) -> void:
	_apply_gameplay_settings()


func _on_game_speed_changed(value: float) -> void:
	if game_speed_value:
		game_speed_value.text = "%.1fx" % value
	_apply_gameplay_settings()
