extends CanvasLayer
## Codex UI Controller
##
## Educational encyclopedia tracking discovered species, wildlife, and blue carbon science.
## Displays real-world data from species resources and SCIENCE_REFERENCE.md.

## Art Direction color palette
const OCEAN_DEEP := Color("#0A2540")
const OCEAN_MID := Color("#1B4965")
const SAND_LIGHT := Color("#F5DEB3")
const CORAL_ACCENT := Color("#FF6B6B")
const SEAGRASS_GREEN := Color("#4A7C59")
const TEXT_LIGHT := Color("#FFFFFF")
const TEXT_DARK := Color("#2C2416")
const LOCKED_COLOR := Color("#6B5D52")
const DISCOVERED_GLOW := Color("#4A7C59", 0.2)
const OVERLAY_COLOR := Color(0, 0, 0, 0.5)

## UI References
@onready var overlay := $Overlay
@onready var main_panel := $MainPanel
@onready var close_button := $MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var tab_container := $MainPanel/MarginContainer/VBoxContainer/TabContainer

# Species Tab
@onready var species_counter := $MainPanel/MarginContainer/VBoxContainer/Header/SpeciesCounter
@onready var species_scroll := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Species/SpeciesScroll
@onready var species_list := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Species/SpeciesScroll/SpeciesList

# Wildlife Tab
@onready var wildlife_scroll := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Wildlife/WildlifeScroll
@onready var wildlife_list := $MainPanel/MarginContainer/VBoxContainer/TabContainer/Wildlife/WildlifeScroll/WildlifeList

# Ecosystem Services Tab
@onready var services_scroll := $MainPanel/MarginContainer/VBoxContainer/TabContainer/"Ecosystem Services"/ServicesScroll
@onready var services_list := $MainPanel/MarginContainer/VBoxContainer/TabContainer/"Ecosystem Services"/ServicesScroll/ServicesList

# Science Facts Tab
@onready var facts_scroll := $MainPanel/MarginContainer/VBoxContainer/TabContainer/"Science Facts"/FactsScroll
@onready var facts_list := $MainPanel/MarginContainer/VBoxContainer/TabContainer/"Science Facts"/FactsScroll/FactsList

## Species Data (loaded from resources)
const SPECIES_PATHS := {
	"zostera": "res://game/resources/species/seagrass_zostera.tres",
	"posidonia": "res://game/resources/species/seagrass_posidonia.tres",
	"thalassia": "res://game/resources/species/seagrass_thalassia.tres",
	"spartina": "res://game/resources/species/saltmarsh_spartina.tres",
	"salicornia": "res://game/resources/species/saltmarsh_salicornia.tres",
	"black_mangrove": "res://game/resources/species/mangrove_black.tres",
	"red_mangrove": "res://game/resources/species/mangrove_red.tres",
	"macrocystis": "res://game/resources/species/kelp_macrocystis.tres",
	"laminaria": "res://game/resources/species/kelp_laminaria.tres",
}

const WILDLIFE_INFO := {
	"fish_small": {
		"name": "Small Fish",
		"icon": "🐟",
		"description": "Schools of small fish like minnows and silversides thrive in the protected waters of blue carbon habitats. These fish provide food for larger predators and indicate a healthy food web.",
		"requirements": "Requires: Biodiversity 15+, Any 3+ blue carbon plants"
	},
	"fish_large": {
		"name": "Large Fish",
		"icon": "🐟",
		"description": "Larger species like snook, redfish, and tarpon use blue carbon ecosystems as nurseries. These commercially important fish depend on healthy seagrass and mangrove habitats.",
		"requirements": "Requires: Biodiversity 30+, Any 8+ blue carbon plants"
	},
	"crab": {
		"name": "Crabs",
		"icon": "🦀",
		"description": "Blue crabs and fiddler crabs are ecosystem engineers, aerating sediment and processing organic matter. They're vital links in the coastal food chain.",
		"requirements": "Requires: Biodiversity 20+, Any 5+ blue carbon plants"
	},
	"shorebird": {
		"name": "Shorebirds",
		"icon": "🐦",
		"description": "Sandpipers, plovers, and other shorebirds feed in the rich intertidal zones created by salt marshes and mangroves, especially during migration.",
		"requirements": "Requires: Biodiversity 25+, 3+ Spartina, 2+ Salicornia"
	},
	"wadingbird": {
		"name": "Wading Birds",
		"icon": "🦩",
		"description": "Herons, egrets, and ibises hunt in the shallow waters among mangrove roots and seagrass beds. Their presence indicates abundant fish populations.",
		"requirements": "Requires: Biodiversity 30+, 4+ Mangroves, 3+ Seagrass"
	},
	"turtle": {
		"name": "Sea Turtles",
		"icon": "🐢",
		"description": "Green sea turtles graze on seagrass meadows, while other species use these habitats as foraging grounds. Protecting blue carbon ecosystems is critical for turtle conservation.",
		"requirements": "Requires: Biodiversity 40+, 5+ Seagrass of any type"
	},
	"dolphin": {
		"name": "Dolphins",
		"icon": "🐬",
		"description": "Bottlenose dolphins frequently hunt in seagrass meadows and mangrove channels, using echolocation to find fish. They're indicators of exceptional ecosystem health.",
		"requirements": "Requires: Biodiversity 50+, 15+ total plants, High fish populations"
	},
	"manatee": {
		"name": "Manatees",
		"icon": "🦭",
		"description": "Florida manatees depend entirely on seagrass meadows, consuming up to 10% of their body weight daily. They're gentle giants requiring pristine water quality.",
		"requirements": "Requires: Biodiversity 60+, 20+ Seagrass (any type)"
	}
}

## State
var _species_data: Dictionary = {}  # species_id -> Resource
var _discovered_species: Array[String] = []
var _discovered_wildlife: Array[String] = []
var _first_sightings: Dictionary = {}  # wildlife_type -> date string


func _ready() -> void:
	# Hide initially
	hide()
	
	# Wait for scene tree
	await get_tree().process_frame
	
	# Load species resources
	_load_species_data()
	
	# Connect signals
	close_button.pressed.connect(_on_close_pressed)
	
	# Connect to ecosystem manager
	if EcosystemManager:
		EcosystemManager.species_discovered.connect(_on_species_discovered)
		EcosystemManager.wildlife_spawned.connect(_on_wildlife_spawned)
		
		# Get current discovered species
		_discovered_species = EcosystemManager.discovered_species.duplicate()
	
	# Get wildlife data from spawner
	_refresh_wildlife_data()
	
	# Build all tabs
	_build_species_tab()
	_build_wildlife_tab()
	_build_ecosystem_services_tab()
	_build_science_facts_tab()
	
	# Update counter
	_update_species_counter()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_codex"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	# Check for mutual exclusion with other UIs
	var other_uis := [
		get_node_or_null("/root/GameWorld/MarketUI"),
		get_node_or_null("/root/GameWorld/JournalUI"),
		get_node_or_null("/root/GameWorld/InventoryUI"),
		get_node_or_null("/root/GameWorld/CarbonDashboardUI")
	]
	
	for ui in other_uis:
		if ui and ui.visible:
			return  # Another UI is open
	
	# Refresh data before showing
	_refresh_wildlife_data()
	_rebuild_all_tabs()
	
	show()
	get_tree().paused = true


func close() -> void:
	hide()
	get_tree().paused = false


func _on_close_pressed() -> void:
	close()


func _load_species_data() -> void:
	for species_id in SPECIES_PATHS:
		var resource_path = SPECIES_PATHS[species_id]
		var species_resource = load(resource_path)
		if species_resource:
			_species_data[species_id] = species_resource


func _on_species_discovered(species_id: String) -> void:
	if species_id not in _discovered_species:
		_discovered_species.append(species_id)
		_update_species_counter()
		if visible:
			_build_species_tab()


func _on_wildlife_spawned(wildlife_type: String) -> void:
	if wildlife_type not in _discovered_wildlife:
		_discovered_wildlife.append(wildlife_type)
		if visible:
			_build_wildlife_tab()


func _refresh_wildlife_data() -> void:
	# Get data from wildlife spawner if available
	var wildlife_spawner = get_tree().get_first_node_in_group("wildlife_spawner")
	if wildlife_spawner:
		# Get discovered wildlife from first_sightings
		_discovered_wildlife.clear()
		for wildlife_type in wildlife_spawner.first_sightings:
			_discovered_wildlife.append(wildlife_type)
			_first_sightings[wildlife_type] = wildlife_spawner.first_sightings[wildlife_type]


func _update_species_counter() -> void:
	var total = SPECIES_PATHS.size()
	var discovered = _discovered_species.size()
	species_counter.text = "%d/%d Species Discovered" % [discovered, total]


func _rebuild_all_tabs() -> void:
	_build_species_tab()
	_build_wildlife_tab()
	_build_ecosystem_services_tab()


## ============================================================================
## SPECIES TAB
## ============================================================================

func _build_species_tab() -> void:
	# Clear existing entries
	for child in species_list.get_children():
		child.queue_free()
	
	# Group species by zone
	var zones := {
		"Seagrass": ["zostera", "posidonia", "thalassia"],
		"Salt Marsh": ["spartina", "salicornia"],
		"Mangrove": ["black_mangrove", "red_mangrove"],
		"Kelp Forest": ["macrocystis", "laminaria"]
	}
	
	for zone in zones:
		_add_zone_header(species_list, zone)
		
		for species_id in zones[zone]:
			if species_id in _discovered_species:
				_add_discovered_species_entry(species_list, species_id)
			else:
				_add_undiscovered_species_entry(species_list, species_id, zone)
		
		# Add spacing between zones
		_add_spacer(species_list, 20)


func _add_zone_header(parent: Control, zone_name: String) -> void:
	var header = Label.new()
	header.text = "━━━ %s ━━━" % zone_name.to_upper()
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", OCEAN_MID)
	parent.add_child(header)
	_add_spacer(parent, 10)


func _add_discovered_species_entry(parent: Control, species_id: String) -> void:
	var species = _species_data.get(species_id)
	if not species:
		return
	
	# Main container
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_discovered_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	# Title row
	var title = Label.new()
	title.text = "🌿 %s" % species.species_name
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", SEAGRASS_GREEN)
	vbox.add_child(title)
	
	# Scientific name
	var scientific = Label.new()
	scientific.text = species.scientific_name
	scientific.add_theme_font_size_override("font_size", 16)
	scientific.add_theme_color_override("font_color", LOCKED_COLOR)
	vbox.add_child(scientific)
	
	# Zone
	var zone_label = Label.new()
	zone_label.text = "Zone: %s" % species.zone
	zone_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(zone_label)
	
	# Carbon sequestration
	var carbon_rate = _get_max_carbon_rate(species)
	var carbon = Label.new()
	carbon.text = "Carbon Sequestration: %.1f kg CO₂/year/m²" % carbon_rate
	carbon.add_theme_font_size_override("font_size", 15)
	carbon.add_theme_color_override("font_color", SEAGRASS_GREEN)
	vbox.add_child(carbon)
	
	# Growth stages
	var stages = Label.new()
	stages.text = "Growth Stages: %d" % species.growth_stages.size()
	stages.add_theme_font_size_override("font_size", 15)
	vbox.add_child(stages)
	
	# Preferred conditions
	var conditions = Label.new()
	conditions.text = "Depth: %.1f-%.1fm | Salinity: %.1f-%.1f ppt" % [
		species.min_depth, species.max_depth,
		species.min_salinity, species.max_salinity
	]
	conditions.add_theme_font_size_override("font_size", 14)
	conditions.add_theme_color_override("font_color", LOCKED_COLOR)
	vbox.add_child(conditions)
	
	# Codex entry (science fact)
	if species.get("codex_entry") and species.codex_entry != "":
		_add_spacer(vbox, 5)
		var codex = Label.new()
		codex.text = "📖 %s" % species.codex_entry
		codex.add_theme_font_size_override("font_size", 14)
		codex.add_theme_color_override("font_color", TEXT_DARK)
		codex.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(codex)
	
	_add_spacer(parent, 12)


func _add_undiscovered_species_entry(parent: Control, species_id: String, zone: String) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_locked_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "❓ ???"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", LOCKED_COLOR)
	vbox.add_child(title)
	
	var hint = Label.new()
	hint.text = "Undiscovered %s species" % zone
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", LOCKED_COLOR)
	vbox.add_child(hint)
	
	_add_spacer(parent, 12)


func _get_max_carbon_rate(species) -> float:
	var max_rate := 0.0
	for stage in species.growth_stages:
		if stage.carbon_sequestration_rate > max_rate:
			max_rate = stage.carbon_sequestration_rate
	return max_rate


## ============================================================================
## WILDLIFE TAB
## ============================================================================

func _build_wildlife_tab() -> void:
	# Clear existing entries
	for child in wildlife_list.get_children():
		child.queue_free()
	
	var header = Label.new()
	header.text = "━━━ WILDLIFE SIGHTINGS ━━━"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", OCEAN_MID)
	wildlife_list.add_child(header)
	_add_spacer(wildlife_list, 15)
	
	# Show wildlife in order
	var wildlife_order := ["fish_small", "fish_large", "crab", "shorebird", "wadingbird", "turtle", "dolphin", "manatee"]
	
	for wildlife_type in wildlife_order:
		if wildlife_type in _discovered_wildlife:
			_add_discovered_wildlife_entry(wildlife_list, wildlife_type)
		else:
			_add_undiscovered_wildlife_entry(wildlife_list, wildlife_type)


func _add_discovered_wildlife_entry(parent: Control, wildlife_type: String) -> void:
	var info = WILDLIFE_INFO.get(wildlife_type, {})
	if info.is_empty():
		return
	
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_discovered_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "%s %s" % [info.icon, info.name]
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", CORAL_ACCENT)
	vbox.add_child(title)
	
	# Description
	var desc = Label.new()
	desc.text = info.description
	desc.add_theme_font_size_override("font_size", 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	# Requirements
	var req = Label.new()
	req.text = "📋 %s" % info.requirements
	req.add_theme_font_size_override("font_size", 14)
	req.add_theme_color_override("font_color", SEAGRASS_GREEN)
	req.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(req)
	
	# First sighting date
	if _first_sightings.has(wildlife_type):
		var sighting = Label.new()
		sighting.text = "🗓️ First Sighting: %s" % _first_sightings[wildlife_type]
		sighting.add_theme_font_size_override("font_size", 14)
		sighting.add_theme_color_override("font_color", LOCKED_COLOR)
		vbox.add_child(sighting)
	
	_add_spacer(parent, 12)


func _add_undiscovered_wildlife_entry(parent: Control, wildlife_type: String) -> void:
	var info = WILDLIFE_INFO.get(wildlife_type, {})
	if info.is_empty():
		return
	
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_locked_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "❓ ???"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", LOCKED_COLOR)
	vbox.add_child(title)
	
	var hint = Label.new()
	hint.text = info.requirements
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", LOCKED_COLOR)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)
	
	_add_spacer(parent, 12)


## ============================================================================
## ECOSYSTEM SERVICES TAB
## ============================================================================

func _build_ecosystem_services_tab() -> void:
	# Clear existing
	for child in services_list.get_children():
		child.queue_free()
	
	var header = Label.new()
	header.text = "━━━ CURRENT ECOSYSTEM SERVICES ━━━"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", OCEAN_MID)
	services_list.add_child(header)
	_add_spacer(services_list, 15)
	
	if not EcosystemManager:
		var error = Label.new()
		error.text = "Ecosystem data unavailable"
		services_list.add_child(error)
		return
	
	# Biodiversity Score
	_add_service_metric(
		services_list,
		"🌊 Biodiversity Index",
		EcosystemManager.biodiversity_score,
		100,
		"Measures species diversity and habitat complexity. Higher values support more wildlife."
	)
	
	# Ecosystem Health
	_add_service_metric(
		services_list,
		"💚 Ecosystem Health",
		EcosystemManager.ecosystem_health,
		100,
		"Overall ecosystem vitality combining biodiversity and food web balance."
	)
	
	# Carbon Sequestration (from CarbonManager)
	if CarbonManager:
		var total_carbon = CarbonManager.total_carbon_sequestered
		_add_service_value(
			services_list,
			"🍃 Total Carbon Sequestered",
			"%.1f tonnes CO₂" % total_carbon,
			"Carbon dioxide removed from atmosphere and stored in plant biomass and sediment."
		)
	
	# Coastal Protection
	var protection_score = _calculate_coastal_protection()
	_add_service_metric(
		services_list,
		"🌊 Coastal Protection",
		protection_score,
		100,
		"Wave attenuation and erosion prevention from plant roots and structure."
	)
	
	# Fisheries Support
	var fishery_value = _calculate_fishery_value()
	_add_service_metric(
		services_list,
		"🐟 Fisheries Habitat Value",
		fishery_value,
		100,
		"Nursery habitat quality for commercially important fish species."
	)
	
	# Water Quality
	var water_quality = _calculate_water_quality()
	_add_service_metric(
		services_list,
		"💧 Water Filtration",
		water_quality,
		100,
		"Sediment trapping and nutrient filtering capacity of blue carbon plants."
	)
	
	# Wildlife Population Summary
	_add_spacer(services_list, 20)
	var wildlife_header = Label.new()
	wildlife_header.text = "━━━ WILDLIFE POPULATIONS ━━━"
	wildlife_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wildlife_header.add_theme_font_size_override("font_size", 20)
	wildlife_header.add_theme_color_override("font_color", OCEAN_MID)
	services_list.add_child(wildlife_header)
	_add_spacer(services_list, 10)
	
	for wildlife_type in EcosystemManager.wildlife_populations:
		var count = EcosystemManager.wildlife_populations[wildlife_type]
		if count > 0:
			var info = WILDLIFE_INFO.get(wildlife_type, {})
			var name = info.get("name", wildlife_type)
			var icon = info.get("icon", "🐾")
			_add_wildlife_population(services_list, icon, name, count)


func _add_service_metric(parent: Control, title: String, value: float, max_value: float, description: String) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_service_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)
	
	# Title with value
	var title_label = Label.new()
	title_label.text = "%s: %.1f / %.0f" % [title, value, max_value]
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", OCEAN_MID)
	vbox.add_child(title_label)
	
	# Progress bar
	var progress = ProgressBar.new()
	progress.min_value = 0
	progress.max_value = max_value
	progress.value = value
	progress.custom_minimum_size = Vector2(0, 25)
	progress.show_percentage = false
	vbox.add_child(progress)
	
	# Description
	var desc = Label.new()
	desc.text = description
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", TEXT_DARK)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	_add_spacer(parent, 12)


func _add_service_value(parent: Control, title: String, value: String, description: String) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_service_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = "%s: %s" % [title, value]
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", SEAGRASS_GREEN)
	vbox.add_child(title_label)
	
	var desc = Label.new()
	desc.text = description
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", TEXT_DARK)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	_add_spacer(parent, 12)


func _add_wildlife_population(parent: Control, icon: String, name: String, count: int) -> void:
	var hbox = HBoxContainer.new()
	parent.add_child(hbox)
	
	var label = Label.new()
	label.text = "%s %s: %d" % [icon, name, count]
	label.add_theme_font_size_override("font_size", 16)
	hbox.add_child(label)
	
	_add_spacer(parent, 5)


func _calculate_coastal_protection() -> float:
	if not EcosystemManager:
		return 0.0
	
	var protection := 0.0
	var total_plants := 0
	
	for species_id in EcosystemManager.planted_species:
		var count = EcosystemManager.planted_species[species_id]
		total_plants += count
		
		# Mangroves and salt marsh provide most protection
		if "mangrove" in species_id:
			protection += count * 2.5
		elif "spartina" in species_id or "salicornia" in species_id:
			protection += count * 2.0
		elif "seagrass" in species_id:
			protection += count * 1.0
	
	return min(protection / 40.0, 100.0)  # Scale to 100


func _calculate_fishery_value() -> float:
	if not EcosystemManager:
		return 0.0
	
	# Fishery value is based on seagrass and mangrove coverage
	var value := 0.0
	
	for species_id in EcosystemManager.planted_species:
		var count = EcosystemManager.planted_species[species_id]
		
		if "seagrass" in species_id:
			value += count * 2.0  # Seagrass is critical nursery habitat
		elif "mangrove" in species_id:
			value += count * 1.5
	
	return min(value / 30.0, 100.0)


func _calculate_water_quality() -> float:
	if not EcosystemManager:
		return 0.0
	
	# Water quality based on plant density and diversity
	var quality := 0.0
	var total_plants := 0
	
	for species_id in EcosystemManager.planted_species:
		var count = EcosystemManager.planted_species[species_id]
		total_plants += count
		quality += count
	
	# Bonus for diversity
	var diversity_bonus = EcosystemManager.planted_species.size() * 5.0
	
	return min((quality + diversity_bonus) / 50.0, 100.0)


## ============================================================================
## SCIENCE FACTS TAB
## ============================================================================

func _build_science_facts_tab() -> void:
	# Clear existing
	for child in facts_list.get_children():
		child.queue_free()
	
	var header = Label.new()
	header.text = "━━━ BLUE CARBON SCIENCE ━━━"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", OCEAN_DEEP)
	facts_list.add_child(header)
	_add_spacer(facts_list, 15)
	
	# Introduction
	_add_fact_section(
		facts_list,
		"🌊 What is Blue Carbon?",
		"Blue carbon refers to carbon captured and stored by coastal and marine ecosystems. Despite covering less than 2% of the ocean surface, these habitats sequester carbon up to 40 times faster than terrestrial forests and store it for thousands of years in sediment."
	)
	
	# Blue vs Green Carbon
	_add_fact_section(
		facts_list,
		"🌿 Blue vs Green Carbon",
		"BLUE CARBON (Coastal/Marine):\n• 10-50x faster sequestration than forests\n• Stores carbon for 1,000+ years in sediment\n• 3-5x more carbon per hectare\n• Critical for climate mitigation\n\nGREEN CARBON (Terrestrial):\n• Trees store carbon in biomass\n• Released when trees die/burn\n• Important but shorter-term storage"
	)
	
	# Sequestration Rates
	_add_comparison_table(facts_list)
	
	# Seagrass Facts
	_add_fact_section(
		facts_list,
		"🌱 Seagrass Meadows",
		"• Sequester 138 tonnes CO₂/km²/year\n• Store carbon for 1,000+ years in sediment\n• Cover <0.2% of seafloor but store 10% of ocean carbon\n• Provide nursery habitat for 20% of major fisheries\n• Stabilize sediment and improve water clarity\n• One hectare supports ~40,000 fish and 50 million invertebrates"
	)
	
	# Salt Marsh Facts
	_add_fact_section(
		facts_list,
		"🌾 Salt Marshes",
		"• Sequester 218 tonnes CO₂/km²/year\n• Peat deposits extend 5+ meters deep\n• Reduce wave energy by up to 70%\n• Filter pollutants and excess nutrients\n• Provide critical habitat for migratory birds\n• Support commercial fisheries worth billions annually"
	)
	
	# Mangrove Facts
	_add_fact_section(
		facts_list,
		"🌳 Mangrove Forests",
		"• Sequester 226 tonnes CO₂/km²/year\n• Store 3-5x more carbon per hectare than rainforests\n• Protect coastlines from storm surge and tsunamis\n• Reduce wave height by up to 66% per 100m\n• Nursery for 80% of global fish catch\n• Prop roots create complex 3D habitat structure"
	)
	
	# Kelp Facts
	_add_fact_section(
		facts_list,
		"🌊 Kelp Forests",
		"• Grow up to 30cm per day - fastest on Earth\n• Export organic carbon to deep ocean\n• Create underwater forests 30+ meters tall\n• Support incredibly diverse marine ecosystems\n• Absorb excess nutrients from coastal pollution\n• Critical habitat for sea otters, fish, and invertebrates"
	)
	
	# Global Impact
	_add_fact_section(
		facts_list,
		"🌍 Global Impact",
		"CURRENT STATUS:\n• 25-50% of blue carbon habitats lost globally\n• 1-2% additional loss per year\n• Degraded habitats release stored carbon\n\nRESTORATION POTENTIAL:\n• Protecting/restoring = major climate solution\n• Can offset 0.5 billion tonnes CO₂/year\n• Creates jobs and supports fisheries\n• Enhances coastal resilience to climate change"
	)
	
	# Why It Matters
	_add_fact_section(
		facts_list,
		"💡 Why Blue Carbon Matters",
		"Blue carbon ecosystems are among the most powerful natural climate solutions available. By restoring and protecting these habitats, we:\n\n✓ Sequester massive amounts of CO₂\n✓ Protect coastlines from storms and erosion\n✓ Support fisheries worth billions\n✓ Create jobs and economic opportunities\n✓ Preserve biodiversity hotspots\n✓ Improve water quality\n✓ Build climate resilience\n\nEvery hectare restored makes a measurable difference!"
	)


func _add_fact_section(parent: Control, title: String, content: String) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_fact_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", OCEAN_DEEP)
	vbox.add_child(title_label)
	
	var content_label = Label.new()
	content_label.text = content
	content_label.add_theme_font_size_override("font_size", 15)
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(content_label)
	
	_add_spacer(parent, 12)


func _add_comparison_table(parent: Control) -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _create_fact_panel_style())
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "📊 Carbon Sequestration Comparison"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", OCEAN_DEEP)
	vbox.add_child(title)
	
	var table_text = """
ECOSYSTEM          | CO₂ SEQUESTERED/YEAR | STORAGE DURATION
-------------------|----------------------|------------------
🌳 Mangroves       | 226 tonnes/km²       | 1,000+ years
🌾 Salt Marshes    | 218 tonnes/km²       | 1,000+ years  
🌱 Seagrass        | 138 tonnes/km²       | 1,000+ years
🌲 Tropical Forest | 8-15 tonnes/km²      | Decades (variable)
🌲 Temperate Forest| 4-8 tonnes/km²       | Decades (variable)

Blue carbon ecosystems achieve this through:
• Rapid plant growth in nutrient-rich coastal waters
• Permanent burial in low-oxygen sediment
• Minimal decomposition in anaerobic conditions
• Continuous accumulation over centuries
"""
	
	var table = Label.new()
	table.text = table_text
	table.add_theme_font_size_override("font_size", 14)
	table.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(table)
	
	_add_spacer(parent, 12)


## ============================================================================
## STYLE HELPERS
## ============================================================================

func _create_discovered_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = DISCOVERED_GLOW
	style.border_color = SEAGRASS_GREEN
	style.set_border_width_all(2)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style


func _create_locked_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.3)
	style.border_color = LOCKED_COLOR
	style.set_border_width_all(1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style


func _create_service_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#E8F4F8")
	style.border_color = OCEAN_MID
	style.set_border_width_all(2)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style


func _create_fact_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = SAND_LIGHT
	style.border_color = OCEAN_DEEP
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style


func _add_spacer(parent: Control, height: int) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	parent.add_child(spacer)
