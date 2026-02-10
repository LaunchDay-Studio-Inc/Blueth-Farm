extends Node
## UI State Manager
##
## Manages which UI panels are open and handles mutual exclusion.
## Ensures only one non-HUD panel is open at a time and integrates with GameManager.

signal panel_opened(panel_name: String)
signal panel_closed(panel_name: String)

## Currently open panel name, or empty string if none
var current_panel: String = ""

## List of all managed panel names
const MANAGED_PANELS := [
	"inventory",
	"market",
	"journal",
	"codex",
	"tech_tree",
	"quest_log",
	"settings",
	"nursery",
	"town_investment",
	"carbon_dashboard"
]


func _ready() -> void:
	print("UIStateManager initialized")


## Opens a UI panel by name
## Automatically closes any other open panel
func open_panel(panel_name: String) -> void:
	# If this panel is already open, do nothing
	if current_panel == panel_name:
		return
	
	# Close currently open panel if any
	if current_panel != "":
		close_panel()
	
	# Set new panel as current
	current_panel = panel_name
	
	# Set game state to MENU
	if GameManager:
		GameManager.set_game_state(GameManager.GameState.MENU)
	
	# Emit signal
	panel_opened.emit(panel_name)
	
	print("UI Panel opened: ", panel_name)


## Closes the currently open panel
func close_panel() -> void:
	if current_panel == "":
		return
	
	var closed_panel = current_panel
	current_panel = ""
	
	# Return to PLAYING state
	if GameManager:
		GameManager.set_game_state(GameManager.GameState.PLAYING)
	
	# Emit signal
	panel_closed.emit(closed_panel)
	
	print("UI Panel closed: ", closed_panel)


## Returns true if a panel is currently open
func is_panel_open() -> bool:
	return current_panel != ""


## Returns the name of the currently open panel, or empty string
func get_current_panel() -> String:
	return current_panel


## Returns true if player input should be disabled
func should_disable_player_input() -> bool:
	return is_panel_open()
