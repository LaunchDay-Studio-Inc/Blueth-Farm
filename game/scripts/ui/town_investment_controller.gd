extends CanvasLayer
## Town Investment UI Controller
##
## Manages town building investments.
## Shows building status, costs, benefits, and construction progress.

## Art Direction color palette
const BG_COLOR := Color("#1A3A52", 0.9)
const BORDER_COLOR := Color("#8B7355")
const TEXT_COLOR := Color("#F5F0E1")
const HEADER_COLOR := Color("#2E5E8C")
const LOCKED_COLOR := Color("#6B5D52")
const AVAILABLE_COLOR := Color("#4A7C59")
const CONSTRUCTION_COLOR := Color("#D4A76A")
const COMPLETED_COLOR := Color("#6B9D6E")

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var gold_label := $MainPanel/MarginContainer/VBoxContainer/Header/GoldDisplay
@onready var buildings_container := $MainPanel/MarginContainer/VBoxContainer/Content/ScrollContainer/BuildingsVBox

## State
var _town_investment: Node = null
var _building_panels: Dictionary = {}  # building_id -> Panel

## Building display info (fallback if system doesn't provide)
const BUILDING_INFO := {
	"nursery": {
		"name": "Nursery Building",
		"description": "Grow seedlings faster before transplanting to the wild.",
		"icon": "🌱"
	},
	"marine_lab": {
		"name": "Marine Research Lab",
		"description": "Unlocks Engineering research branch and advanced tools.",
		"icon": "🔬"
	},
	"visitor_center": {
		"name": "Visitor Center",
		"description": "Generates eco-tourism income from your restoration efforts.",
		"icon": "🏛️"
	},
	"dock": {
		"name": "Community Dock",
		"description": "Enables boat access to deeper planting zones.",
		"icon": "⚓"
	},
	"market_expansion": {
		"name": "Market Expansion",
		"description": "Unlocks rare seeds and better prices at the market.",
		"icon": "🏪"
	}
}


func _ready() -> void:
	# Set process mode for pause handling
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get TownInvestment reference
	_town_investment = get_node_or_null("/root/TownInvestment")
	if not _town_investment:
		_town_investment = get_tree().get_first_node_in_group("town_investment")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	
	# Connect to TownInvestment signals
	if _town_investment:
		if _town_investment.has_signal("building_started"):
			_town_investment.building_started.connect(_on_building_started)
		if _town_investment.has_signal("building_completed"):
			_town_investment.building_completed.connect(_on_building_completed)
		if _town_investment.has_signal("building_unlocked"):
			_town_investment.building_unlocked.connect(_on_building_unlocked)
	
	# Apply styling
	_apply_styling()
	
	# Create building panels
	_create_building_panels()
	
	# Initialize display
	_refresh_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_town_investment"):
		toggle_town_investment()


## Toggle town investment visibility
func toggle_town_investment() -> void:
	if visible:
		hide_town_investment()
	else:
		show_town_investment()


## Show the town investment UI
func show_town_investment() -> void:
	visible = true
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").open_panel("town_investment")
	
	_refresh_ui()


## Hide the town investment UI
func hide_town_investment() -> void:
	visible = false
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").close_panel()


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
	
	# Set text colors
	if gold_label:
		gold_label.add_theme_color_override("font_color", TEXT_COLOR)


## Create building panels
func _create_building_panels() -> void:
	if not buildings_container:
		return
	
	# Clear existing panels
	for child in buildings_container.get_children():
		child.queue_free()
	_building_panels.clear()
	
	# Get building list from system
	var buildings = []
	if _town_investment and _town_investment.has_method("get_all_buildings"):
		buildings = _town_investment.get_all_buildings()
	else:
		# Use fallback list
		for building_id in BUILDING_INFO.keys():
			buildings.append({"building_id": building_id})
	
	# Create panel for each building
	for building in buildings:
		var building_id = building.get("building_id", "")
		if building_id.is_empty():
			continue
		
		var panel := _create_building_panel(building_id)
		buildings_container.add_child(panel)
		_building_panels[building_id] = panel


## Create a single building panel
func _create_building_panel(building_id: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 120)
	
	# Panel styling (will be updated based on status)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = LOCKED_COLOR
	panel_style.border_color = BORDER_COLOR
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Main container
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	
	var hbox := HBoxContainer.new()
	margin.add_child(hbox)
	
	# Left side - Icon and name
	var left_vbox := VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(left_vbox)
	
	var name_label := Label.new()
	name_label.text = _get_building_name(building_id)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.name = "NameLabel"
	left_vbox.add_child(name_label)
	
	var desc_label := Label.new()
	desc_label.text = _get_building_description(building_id)
	desc_label.add_theme_color_override("font_color", TEXT_COLOR)
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.name = "DescLabel"
	left_vbox.add_child(desc_label)
	
	var status_label := Label.new()
	status_label.text = "Status: Unknown"
	status_label.add_theme_color_override("font_color", TEXT_COLOR)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.name = "StatusLabel"
	left_vbox.add_child(status_label)
	
	# Right side - Cost and button
	var right_vbox := VBoxContainer.new()
	right_vbox.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(right_vbox)
	
	var cost_label := Label.new()
	cost_label.text = "Cost: ?"
	cost_label.add_theme_color_override("font_color", TEXT_COLOR)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.name = "CostLabel"
	right_vbox.add_child(cost_label)
	
	var invest_button := Button.new()
	invest_button.text = "Invest"
	invest_button.disabled = true
	invest_button.pressed.connect(_on_invest_pressed.bind(building_id))
	invest_button.name = "InvestButton"
	right_vbox.add_child(invest_button)
	
	# Store metadata
	panel.set_meta("building_id", building_id)
	
	return panel


## Get building name
func _get_building_name(building_id: String) -> String:
	if _town_investment and _town_investment.has_method("get_building_name"):
		return _town_investment.get_building_name(building_id)
	
	return BUILDING_INFO.get(building_id, {}).get("name", building_id.capitalize())


## Get building description
func _get_building_description(building_id: String) -> String:
	if _town_investment and _town_investment.has_method("get_building_description"):
		return _town_investment.get_building_description(building_id)
	
	return BUILDING_INFO.get(building_id, {}).get("description", "")


## Refresh the entire UI display
func _refresh_ui() -> void:
	# Update gold display
	if gold_label and GameManager:
		gold_label.text = "Gold: " + str(GameManager.gold)
	
	# Update all building panels
	for building_id in _building_panels.keys():
		_update_building_panel(building_id)


## Update a single building panel
func _update_building_panel(building_id: String) -> void:
	var panel = _building_panels.get(building_id)
	if not panel:
		return
	
	# Get building status from system
	var building_data = null
	if _town_investment and _town_investment.has_method("get_building"):
		building_data = _town_investment.get_building(building_id)
	
	if not building_data:
		return
	
	var status = building_data.get("status", "locked")
	var cost = building_data.get("cost", 0)
	var days_remaining = building_data.get("days_remaining", 0)
	
	# Update status label
	var status_label = panel.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/StatusLabel")
	if status_label:
		match status:
			"locked":
				status_label.text = "Status: Locked"
			"available":
				status_label.text = "Status: Available"
			"constructing":
				status_label.text = "Status: Under Construction (%d days)" % days_remaining
			"completed":
				status_label.text = "Status: Completed ✓"
			_:
				status_label.text = "Status: Unknown"
	
	# Update cost label
	var cost_label = panel.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer2/CostLabel")
	if cost_label:
		if status == "completed":
			cost_label.text = "Completed"
		else:
			cost_label.text = "Cost: %d Gold" % cost
	
	# Update invest button
	var invest_button = panel.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer2/InvestButton")
	if invest_button:
		invest_button.disabled = status != "available"
		
		if status == "available":
			var can_afford = GameManager and GameManager.gold >= cost
			invest_button.disabled = not can_afford
			invest_button.text = "Invest" if can_afford else "Need %d Gold" % cost
		elif status == "constructing":
			invest_button.text = "Building..."
			invest_button.disabled = true
		elif status == "completed":
			invest_button.text = "Completed"
			invest_button.disabled = true
		else:
			invest_button.text = "Locked"
			invest_button.disabled = true
	
	# Update panel color based on status
	var panel_style = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style:
		var cloned_style = panel_style.duplicate() as StyleBoxFlat
		
		match status:
			"locked":
				cloned_style.bg_color = LOCKED_COLOR
			"available":
				cloned_style.bg_color = AVAILABLE_COLOR
			"constructing":
				cloned_style.bg_color = CONSTRUCTION_COLOR
			"completed":
				cloned_style.bg_color = COMPLETED_COLOR
		
		panel.add_theme_stylebox_override("panel", cloned_style)


## Signal handlers

func _on_close_pressed() -> void:
	hide_town_investment()


func _on_invest_pressed(building_id: String) -> void:
	if not _town_investment:
		return
	
	# Attempt to invest in building
	if _town_investment.has_method("invest_in_building"):
		var success = _town_investment.invest_in_building(building_id)
		
		if success:
			print("Invested in building: ", building_id)
		else:
			print("Failed to invest in building: ", building_id)
		
		_refresh_ui()


func _on_building_started(building_id: String) -> void:
	_refresh_ui()


func _on_building_completed(building_id: String) -> void:
	_refresh_ui()
	
	# Show notification
	var building_name = _get_building_name(building_id)
	print("Building completed: ", building_name)


func _on_building_unlocked(building_id: String) -> void:
	_refresh_ui()
