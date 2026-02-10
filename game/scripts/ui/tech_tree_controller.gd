extends CanvasLayer
## Tech Tree UI Controller
##
## Visual interface for the research and technology tree system.
## Shows 4 research branches (Ecology, Engineering, Policy, Culture) with 8 nodes each.
## Handles node unlocking, prerequisites, and branch unlock conditions.

## Art Direction color palette
const OCEAN_DEEP := Color("#0A2540")
const OCEAN_MID := Color("#1B4965")
const SAND_LIGHT := Color("#F5DEB3")
const CORAL_ACCENT := Color("#FF6B6B")
const SEAGRASS_GREEN := Color("#4A7C59")
const TEXT_LIGHT := Color("#FFFFFF")
const TEXT_DARK := Color("#2C2416")
const LOCKED_COLOR := Color("#6B5D52")
const AVAILABLE_GLOW := Color("#4A7C59")
const RESEARCHED_COLOR := Color("#1B4965")

## Branch colors
const ECOLOGY_COLOR := Color("#4A7C59")      # Seagrass green
const ENGINEERING_COLOR := Color("#FF6B6B")  # Coral accent
const POLICY_COLOR := Color("#1B4965")       # Ocean mid
const CULTURE_COLOR := Color("#F5DEB3")      # Sand light

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var research_points_label := $MainPanel/MarginContainer/VBoxContainer/Header/ResearchPointsDisplay/Points

# Branch containers
@onready var ecology_nodes := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/EcologyBranch/NodesContainer
@onready var engineering_nodes := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/EngineeringBranch/NodesContainer
@onready var policy_nodes := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/PolicyBranch/NodesContainer
@onready var culture_nodes := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/CultureBranch/NodesContainer

# Branch status labels
@onready var ecology_status := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/EcologyBranch/BranchHeader/HeaderContent/Status
@onready var engineering_status := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/EngineeringBranch/BranchHeader/HeaderContent/Status
@onready var policy_status := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/PolicyBranch/BranchHeader/HeaderContent/Status
@onready var culture_status := $MainPanel/MarginContainer/VBoxContainer/TreeContainer/TreePanel/BranchColumns/CultureBranch/BranchHeader/HeaderContent/Status

# Detail popup
@onready var detail_popup := $DetailPopup
@onready var popup_node_name := $DetailPopup/MarginContainer/VBoxContainer/Header/NodeName
@onready var popup_description := $DetailPopup/MarginContainer/VBoxContainer/ScrollContainer/DetailsContent/Description
@onready var popup_cost := $DetailPopup/MarginContainer/VBoxContainer/ScrollContainer/DetailsContent/CostLabel
@onready var popup_effect := $DetailPopup/MarginContainer/VBoxContainer/ScrollContainer/DetailsContent/EffectLabel
@onready var popup_prerequisites := $DetailPopup/MarginContainer/VBoxContainer/ScrollContainer/DetailsContent/PrerequisitesLabel
@onready var popup_research_button := $DetailPopup/MarginContainer/VBoxContainer/ButtonsContainer/ResearchButton
@onready var popup_cancel_button := $DetailPopup/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var popup_close_button := $DetailPopup/MarginContainer/VBoxContainer/Header/PopupCloseButton

## System references
var tech_tree: TechTree

## Node tracking
var node_buttons: Dictionary = {}  # node_id -> Button
var current_selected_node: String = ""

## Branch node order (8 nodes per branch)
const BRANCH_NODE_IDS := {
	TechTree.Branch.ECOLOGY: [
		"eco_survey", "eco_growth", "eco_symbiosis", "eco_sediment",
		"eco_migration", "eco_resilience", "eco_diversity", "eco_mastery"
	],
	TechTree.Branch.ENGINEERING: [
		"eng_sensors", "eng_sediment", "eng_oyster", "eng_shoreline",
		"eng_drones", "eng_breakwater", "eng_carbon", "eng_mastery"
	],
	TechTree.Branch.POLICY: [
		"pol_assessment", "pol_credits", "pol_fishing", "pol_mpa",
		"pol_grants", "pol_education", "pol_blue_carbon", "pol_mastery"
	],
	TechTree.Branch.CULTURE: [
		"cul_fishing", "cul_calendar", "cul_medicine", "cul_fire",
		"cul_stories", "cul_sacred", "cul_mentorship", "cul_mastery"
	]
}


func _ready() -> void:
	# Set process mode for pause handling
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide initially
	hide()
	
	# Hide detail popup
	if detail_popup:
		detail_popup.hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get system references
	tech_tree = get_node_or_null("/root/TechTree")
	
	if not tech_tree:
		push_warning("TechTree autoload not found!")
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	popup_close_button.pressed.connect(_on_popup_close_pressed)
	popup_cancel_button.pressed.connect(_on_popup_close_pressed)
	popup_research_button.pressed.connect(_on_research_button_pressed)
	
	if tech_tree:
		tech_tree.research_completed.connect(_on_research_completed)
		tech_tree.branch_unlocked.connect(_on_branch_unlocked)
	
	# Setup UI
	setup_branch_nodes()
	update_research_points_display()
	update_all_nodes()
	update_branch_statuses()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_tech_tree"):
		toggle_visibility()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_tech_tree()


func toggle_visibility() -> void:
	"""Toggle tech tree visibility - shows if hidden, hides if shown"""
	if visible:
		hide_tech_tree()
	else:
		show_tech_tree()


func show_tech_tree() -> void:
	"""Show the tech tree UI"""
	visible = true
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").open_panel("tech_tree")
	
	update_research_points_display()
	update_all_nodes()
	update_branch_statuses()


func hide_tech_tree() -> void:
	"""Hide the tech tree UI"""
	visible = false
	
	# Notify UI State Manager
	if has_node("/root/UIStateManager"):
		get_node("/root/UIStateManager").close_panel()


func setup_branch_nodes() -> void:
	"""Create node buttons for all branches"""
	if not tech_tree:
		return
	
	# Ecology branch
	create_branch_nodes(TechTree.Branch.ECOLOGY, ecology_nodes, ECOLOGY_COLOR)
	
	# Engineering branch
	create_branch_nodes(TechTree.Branch.ENGINEERING, engineering_nodes, ENGINEERING_COLOR)
	
	# Policy branch
	create_branch_nodes(TechTree.Branch.POLICY, policy_nodes, POLICY_COLOR)
	
	# Culture branch
	create_branch_nodes(TechTree.Branch.CULTURE, culture_nodes, CULTURE_COLOR)


func create_branch_nodes(branch: TechTree.Branch, container: VBoxContainer, branch_color: Color) -> void:
	"""Create node buttons for a specific branch"""
	var node_ids = BRANCH_NODE_IDS[branch]
	
	for i in range(node_ids.size()):
		var node_id = node_ids[i]
		if node_id not in tech_tree.tech_nodes:
			continue
		
		var node = tech_tree.tech_nodes[node_id]
		
		# Create node button
		var node_button = create_node_button(node, branch_color, i)
		container.add_child(node_button)
		node_buttons[node_id] = node_button
		
		# Add connection lines for prerequisites (visual indicator)
		if node.prerequisites.size() > 0:
			var prereq_label = Label.new()
			prereq_label.text = "   ↑ Requires: " + ", ".join(get_prerequisite_names(node.prerequisites))
			prereq_label.add_theme_font_size_override("font_size", 11)
			prereq_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			prereq_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			container.add_child(prereq_label)
			container.move_child(prereq_label, prereq_label.get_index() - 1)


func create_node_button(node: TechTree.TechNode, branch_color: Color, tier: int) -> Button:
	"""Create a styled button for a tech node"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)
	button.text = node.name + "\n" + str(node.cost) + " RP"
	button.add_theme_font_size_override("font_size", 16)
	
	# Connect click handler
	button.pressed.connect(_on_node_clicked.bind(node.id))
	
	return button


func get_prerequisite_names(prereq_ids: Array) -> Array:
	"""Get human-readable names for prerequisite node IDs"""
	var names = []
	for prereq_id in prereq_ids:
		if prereq_id in tech_tree.tech_nodes:
			names.append(tech_tree.tech_nodes[prereq_id].name)
	return names


func update_all_nodes() -> void:
	"""Update visual state of all nodes"""
	if not tech_tree:
		return
	
	for node_id in node_buttons.keys():
		update_node_visual(node_id)


func update_node_visual(node_id: String) -> void:
	"""Update the visual state of a node button"""
	if node_id not in node_buttons or node_id not in tech_tree.tech_nodes:
		return
	
	var button = node_buttons[node_id]
	var node = tech_tree.tech_nodes[node_id]
	
	# Determine node state
	if node.unlocked:
		# Researched - filled color
		var color = get_branch_color(node.branch)
		button.add_theme_color_override("font_color", TEXT_LIGHT)
		button.modulate = color
		button.disabled = true
	elif tech_tree.can_research(node_id):
		# Available - glowing border effect
		button.add_theme_color_override("font_color", TEXT_DARK)
		button.modulate = Color.WHITE
		button.disabled = false
		# Add a subtle animation or border in actual Godot
	else:
		# Locked - gray
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		button.modulate = LOCKED_COLOR
		button.disabled = true


func get_branch_color(branch: TechTree.Branch) -> Color:
	"""Get the color for a branch"""
	match branch:
		TechTree.Branch.ECOLOGY:
			return ECOLOGY_COLOR
		TechTree.Branch.ENGINEERING:
			return ENGINEERING_COLOR
		TechTree.Branch.POLICY:
			return POLICY_COLOR
		TechTree.Branch.CULTURE:
			return CULTURE_COLOR
	return Color.WHITE


func update_branch_statuses() -> void:
	"""Update branch unlock status displays"""
	if not tech_tree:
		return
	
	# Ecology - always unlocked
	if tech_tree.is_branch_unlocked(TechTree.Branch.ECOLOGY):
		ecology_status.text = "✓ Unlocked"
		ecology_status.add_theme_color_override("font_color", SEAGRASS_GREEN)
	else:
		# Unlock ecology by default on first load
		tech_tree.unlock_branch(TechTree.Branch.ECOLOGY)
	
	# Engineering - requires Marine Lab
	if tech_tree.is_branch_unlocked(TechTree.Branch.ENGINEERING):
		engineering_status.text = "✓ Unlocked"
		engineering_status.add_theme_color_override("font_color", SEAGRASS_GREEN)
	else:
		engineering_status.text = "🔒 Requires: Marine Lab"
		engineering_status.add_theme_color_override("font_color", LOCKED_COLOR)
		check_engineering_unlock()
	
	# Policy - requires Mayor Hayes friendship 40+
	if tech_tree.is_branch_unlocked(TechTree.Branch.POLICY):
		policy_status.text = "✓ Unlocked"
		policy_status.add_theme_color_override("font_color", SEAGRASS_GREEN)
	else:
		policy_status.text = "🔒 Requires: Mayor Hayes 40+"
		policy_status.add_theme_color_override("font_color", LOCKED_COLOR)
		check_policy_unlock()
	
	# Culture - requires Elder Tide friendship 20+
	if tech_tree.is_branch_unlocked(TechTree.Branch.CULTURE):
		culture_status.text = "✓ Unlocked"
		culture_status.add_theme_color_override("font_color", SEAGRASS_GREEN)
	else:
		culture_status.text = "🔒 Requires: Elder Tide 20+"
		culture_status.add_theme_color_override("font_color", LOCKED_COLOR)
		check_culture_unlock()


func check_engineering_unlock() -> void:
	"""Check if Engineering branch should be unlocked (Marine Lab built)"""
	# TODO: Check if Marine Lab building exists
	# For now, placeholder - would connect to BuildingManager
	pass


func check_policy_unlock() -> void:
	"""Check if Policy branch should be unlocked (Mayor Hayes 40+ friendship)"""
	if GameManager and GameManager.has_method("get_npc_friendship"):
		var friendship = GameManager.get_npc_friendship("mayor_hayes")
		if friendship >= 40:
			tech_tree.unlock_branch(TechTree.Branch.POLICY)


func check_culture_unlock() -> void:
	"""Check if Culture branch should be unlocked (Elder Tide 20+ friendship)"""
	if GameManager and GameManager.has_method("get_npc_friendship"):
		var friendship = GameManager.get_npc_friendship("elder_tide")
		if friendship >= 20:
			tech_tree.unlock_branch(TechTree.Branch.CULTURE)


func update_research_points_display() -> void:
	"""Update the research points counter"""
	if GameManager:
		research_points_label.text = str(GameManager.research_points)
	else:
		research_points_label.text = "0"


func _on_node_clicked(node_id: String) -> void:
	"""Handle node button click"""
	if node_id not in tech_tree.tech_nodes:
		return
	
	current_selected_node = node_id
	show_node_details(node_id)


func show_node_details(node_id: String) -> void:
	"""Display the detail popup for a node"""
	if node_id not in tech_tree.tech_nodes:
		return
	
	var node = tech_tree.tech_nodes[node_id]
	
	# Update popup content
	popup_node_name.text = node.name
	popup_description.text = node.description
	popup_cost.text = "Cost: " + str(node.cost) + " Research Points"
	popup_effect.text = "Effect: " + format_effect_description(node.unlock_effect)
	
	# Prerequisites
	if node.prerequisites.size() > 0:
		var prereq_names = get_prerequisite_names(node.prerequisites)
		popup_prerequisites.text = "Prerequisites: " + ", ".join(prereq_names)
	else:
		popup_prerequisites.text = "Prerequisites: None"
	
	# Update research button
	popup_research_button.text = "🔬 Research (Cost: " + str(node.cost) + ")"
	
	# Enable/disable research button based on availability
	var can_research = tech_tree.can_research(node_id)
	var can_afford = GameManager and GameManager.research_points >= node.cost
	popup_research_button.disabled = not (can_research and can_afford)
	
	if node.unlocked:
		popup_research_button.text = "✓ Already Researched"
		popup_research_button.disabled = true
	elif not can_research:
		popup_research_button.text = "🔒 Prerequisites Required"
	elif not can_afford:
		popup_research_button.text = "❌ Insufficient Research Points"
	
	# Show popup
	detail_popup.visible = true


func format_effect_description(effect: String) -> String:
	"""Convert effect ID to human-readable description"""
	# Map effect IDs to descriptions
	var effect_descriptions = {
		"unlock_codex": "Unlock the species codex",
		"growth_rate_15": "+15% plant growth rate",
		"diversity_bonus": "Diversity planting bonus",
		"show_sediment_carbon": "Display sediment carbon data",
		"predict_wildlife": "Show wildlife spawn predictions",
		"storm_resistance": "Reduced storm damage to ecosystems",
		"unlock_rare_species": "Unlock rare species variants",
		"ecology_mastery": "+25% to all ecology bonuses",
		
		"enhanced_water_data": "Enhanced water testing data",
		"sediment_bonus_20": "+20% sediment carbon storage",
		"unlock_oyster_reefs": "Unlock oyster reef structures",
		"reduce_erosion": "Reduce storm erosion damage",
		"aerial_view": "Unlock aerial ecosystem view",
		"storm_protection_major": "Major storm protection",
		"carbon_bonus_15": "+15% carbon sequestration",
		"engineering_mastery": "+25% to all engineering bonuses",
		
		"show_eco_value": "Display ecosystem monetary value",
		"unlock_carbon_credits": "Unlock carbon credit sales",
		"sustainable_fishing": "Sustainable fishing bonuses",
		"unlock_mpa": "Designate marine protected areas",
		"periodic_grants": "Receive periodic grant funding",
		"town_reputation": "Increase town reputation",
		"premium_carbon_prices": "Premium carbon credit prices",
		"policy_mastery": "+25% to all policy bonuses",
		
		"traditional_fishing": "Traditional sustainable harvest",
		"seasonal_predictions": "Better seasonal predictions",
		"unlock_medicinal_plants": "Harvest medicinal plants",
		"controlled_burning": "Traditional fire management",
		"unlock_stories": "Unlock oral history content",
		"unlock_sacred_sites": "Special sacred planting zones",
		"unlock_mentorship": "Unlock mentorship quests",
		"culture_mastery": "+25% to all culture bonuses"
	}
	
	return effect_descriptions.get(effect, effect)


func _on_research_button_pressed() -> void:
	"""Handle research button press in detail popup"""
	if current_selected_node.is_empty():
		return
	
	if not tech_tree:
		return
	
	# Attempt to research the node
	var success = tech_tree.research_node(current_selected_node)
	
	if success:
		# Research successful
		update_research_points_display()
		update_node_visual(current_selected_node)
		update_all_nodes()  # Update all nodes in case new ones became available
		
		# Close popup
		detail_popup.visible = false
		current_selected_node = ""
		
		# Show success notification
		if GameManager and GameManager.has_method("show_notification"):
			var node = tech_tree.tech_nodes[current_selected_node]
			GameManager.show_notification("Research Complete: " + node.name, 3.0)
	else:
		# Research failed
		if GameManager and GameManager.has_method("show_notification"):
			GameManager.show_notification("Cannot research this node", 2.0)


func _on_popup_close_pressed() -> void:
	"""Close the detail popup"""
	detail_popup.visible = false
	current_selected_node = ""


func _on_close_pressed() -> void:
	"""Close the tech tree UI"""
	hide_tech_tree()


func _on_research_points_changed(new_total: int, delta: int) -> void:
	"""Handle research points changing - Called externally when GameManager updates points"""
	update_research_points_display()
	
	# Update node availability
	if detail_popup.visible and not current_selected_node.is_empty():
		show_node_details(current_selected_node)


func _on_research_completed(node_id: String) -> void:
	"""Handle research completion"""
	update_all_nodes()
	update_research_points_display()


func _on_branch_unlocked(branch_name: String) -> void:
	"""Handle branch unlock"""
	update_branch_statuses()
	update_all_nodes()
