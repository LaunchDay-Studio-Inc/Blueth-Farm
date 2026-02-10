extends Node
class_name TechTree
## Technology tree system with 4 branches and research nodes

signal research_completed(node_id: String)
signal branch_unlocked(branch_id: String)
signal effect_applied(effect: String)

enum Branch {
	ECOLOGY,
	ENGINEERING,
	POLICY,
	CULTURE
}

# Tech node structure
class TechNode:
	var id: String
	var name: String
	var description: String
	var branch: Branch
	var cost: int
	var prerequisites: Array[String] = []
	var unlock_effect: String
	var unlocked: bool = false
	
	func _init(p_id: String, p_name: String, p_desc: String, p_branch: Branch, p_cost: int, p_effect: String):
		id = p_id
		name = p_name
		description = p_desc
		branch = p_branch
		cost = p_cost
		unlock_effect = p_effect

var tech_nodes: Dictionary = {}
var unlocked_branches: Array[Branch] = []
var active_effects: Dictionary = {}  # effect_id -> value


func _ready() -> void:
	initialize_tech_tree()


func initialize_tech_tree() -> void:
	"""Initialize all tech nodes for all branches"""
	# ECOLOGY BRANCH
	add_tech_node("eco_survey", "Species Survey", "Unlock the codex to track discovered species and wildlife.", 
		Branch.ECOLOGY, 10, "unlock_codex")
	
	add_tech_node("eco_growth", "Growth Optimization", "Increase plant growth rates by 15%.", 
		Branch.ECOLOGY, 20, "growth_rate_15", ["eco_survey"])
	
	add_tech_node("eco_symbiosis", "Symbiosis Studies", "Plants near different species get growth bonus.", 
		Branch.ECOLOGY, 30, "diversity_bonus", ["eco_growth"])
	
	add_tech_node("eco_sediment", "Sediment Analysis", "See sediment carbon storage in tile info.", 
		Branch.ECOLOGY, 25, "show_sediment_carbon", ["eco_survey"])
	
	add_tech_node("eco_migration", "Migration Patterns", "Predict wildlife spawning locations and times.", 
		Branch.ECOLOGY, 35, "predict_wildlife", ["eco_symbiosis"])
	
	add_tech_node("eco_resilience", "Resilience Research", "Ecosystems resist storm damage better.", 
		Branch.ECOLOGY, 40, "storm_resistance", ["eco_symbiosis", "eco_sediment"])
	
	add_tech_node("eco_diversity", "Genetic Diversity", "Unlock rare and heritage species variants.", 
		Branch.ECOLOGY, 50, "unlock_rare_species", ["eco_migration"])
	
	add_tech_node("eco_mastery", "Ecosystem Mastery", "All ecology bonuses increased by 25%.", 
		Branch.ECOLOGY, 75, "ecology_mastery", ["eco_resilience", "eco_diversity"])
	
	# ENGINEERING BRANCH
	add_tech_node("eng_sensors", "Water Quality Sensors", "Enhanced water tester shows more detailed data.", 
		Branch.ENGINEERING, 15, "enhanced_water_data")
	
	add_tech_node("eng_sediment", "Sediment Traps", "Increase sediment carbon storage by 20%.", 
		Branch.ENGINEERING, 25, "sediment_bonus_20", ["eng_sensors"])
	
	add_tech_node("eng_oyster", "Oyster Reef Design", "Build oyster reefs for coastal protection.", 
		Branch.ENGINEERING, 30, "unlock_oyster_reefs", ["eng_sediment"])
	
	add_tech_node("eng_shoreline", "Living Shorelines", "Reduce storm erosion damage.", 
		Branch.ENGINEERING, 40, "reduce_erosion", ["eng_sediment"])
	
	add_tech_node("eng_drones", "Monitoring Drones", "Unlock aerial view of entire ecosystem.", 
		Branch.ENGINEERING, 35, "aerial_view", ["eng_sensors"])
	
	add_tech_node("eng_breakwater", "Breakwater Systems", "Major storm protection structures.", 
		Branch.ENGINEERING, 50, "storm_protection_major", ["eng_oyster", "eng_shoreline"])
	
	add_tech_node("eng_carbon", "Carbon Capture Tech", "Increase carbon sequestration by 15%.", 
		Branch.ENGINEERING, 45, "carbon_bonus_15", ["eng_sediment"])
	
	add_tech_node("eng_mastery", "Coastal Engineering Mastery", "All engineering bonuses increased by 25%.", 
		Branch.ENGINEERING, 75, "engineering_mastery", ["eng_breakwater", "eng_carbon"])
	
	# POLICY BRANCH
	add_tech_node("pol_assessment", "Environmental Assessment", "Show ecosystem services monetary value.", 
		Branch.POLICY, 15, "show_eco_value")
	
	add_tech_node("pol_credits", "Carbon Credit Certification", "Unlock ability to sell carbon credits.", 
		Branch.POLICY, 25, "unlock_carbon_credits", ["pol_assessment"])
	
	add_tech_node("pol_fishing", "Fishing Regulations", "Sustainable fishing improves fish populations.", 
		Branch.POLICY, 20, "sustainable_fishing", ["pol_assessment"])
	
	add_tech_node("pol_mpa", "Marine Protected Area", "Designate protected zones with bonuses.", 
		Branch.POLICY, 40, "unlock_mpa", ["pol_credits", "pol_fishing"])
	
	add_tech_node("pol_grants", "Grant Applications", "Receive periodic gold bonuses from grants.", 
		Branch.POLICY, 30, "periodic_grants", ["pol_credits"])
	
	add_tech_node("pol_education", "Community Education", "Increase town reputation and support.", 
		Branch.POLICY, 35, "town_reputation", ["pol_assessment"])
	
	add_tech_node("pol_blue_carbon", "Blue Carbon Policy", "Premium prices for carbon credits.", 
		Branch.POLICY, 50, "premium_carbon_prices", ["pol_mpa", "pol_grants"])
	
	add_tech_node("pol_mastery", "Policy Mastery", "All policy bonuses increased by 25%.", 
		Branch.POLICY, 75, "policy_mastery", ["pol_education", "pol_blue_carbon"])
	
	# CULTURE BRANCH
	add_tech_node("cul_fishing", "Traditional Fishing", "Sustainable harvest methods from indigenous knowledge.", 
		Branch.CULTURE, 10, "traditional_fishing")
	
	add_tech_node("cul_calendar", "Seasonal Calendars", "Better seasonal predictions and planting times.", 
		Branch.CULTURE, 15, "seasonal_predictions", ["cul_fishing"])
	
	add_tech_node("cul_medicine", "Medicinal Plants", "Harvest valuable medicinal species.", 
		Branch.CULTURE, 25, "unlock_medicinal_plants", ["cul_fishing"])
	
	add_tech_node("cul_fire", "Fire Management", "Traditional controlled burning techniques.", 
		Branch.CULTURE, 30, "controlled_burning", ["cul_calendar"])
	
	add_tech_node("cul_stories", "Oral Histories", "Story content and research point bonuses.", 
		Branch.CULTURE, 20, "unlock_stories", ["cul_fishing"])
	
	add_tech_node("cul_sacred", "Sacred Sites", "Special planting zones with bonuses.", 
		Branch.CULTURE, 35, "unlock_sacred_sites", ["cul_medicine", "cul_stories"])
	
	add_tech_node("cul_mentorship", "Intergenerational Knowledge", "Mentor young NPCs, unlock special quests.", 
		Branch.CULTURE, 40, "unlock_mentorship", ["cul_stories"])
	
	add_tech_node("cul_mastery", "Cultural Mastery", "All culture bonuses increased by 25%.", 
		Branch.CULTURE, 75, "culture_mastery", ["cul_sacred", "cul_mentorship"])


func add_tech_node(id: String, name: String, desc: String, branch: Branch, cost: int, effect: String, prereqs: Array = []) -> void:
	"""Add a tech node to the tree"""
	var node = TechNode.new(id, name, desc, branch, cost, effect)
	node.prerequisites = prereqs
	tech_nodes[id] = node


func can_research(node_id: String) -> bool:
	"""Check if a node can be researched"""
	if node_id not in tech_nodes:
		return false
	
	var node = tech_nodes[node_id]
	
	# Already unlocked
	if node.unlocked:
		return false
	
	# Check prerequisites
	for prereq_id in node.prerequisites:
		if prereq_id not in tech_nodes or not tech_nodes[prereq_id].unlocked:
			return false
	
	# Check if branch is unlocked
	if node.branch not in unlocked_branches:
		return false
	
	# Check if player has enough research points
	# This will be checked by ResearchPoints system
	return true


func research_node(node_id: String) -> bool:
	"""Research/unlock a tech node"""
	if not can_research(node_id):
		return false
	
	var node = tech_nodes[node_id]
	
	# Spend research points (via GameManager/ResearchPoints)
	if GameManager:
		if not GameManager.spend_research_points(node.cost):
			return false
	
	# Unlock the node
	node.unlocked = true
	
	# Apply effect
	apply_effect(node.unlock_effect)
	
	# Emit signals
	research_completed.emit(node_id)
	print("🔬 Research Completed: ", node.name)
	
	return true


func apply_effect(effect: String) -> void:
	"""Apply a research effect"""
	active_effects[effect] = true
	effect_applied.emit(effect)
	print("   Effect Applied: ", effect)
	
	# Specific effect handling can be done by other systems listening to the signal


func unlock_branch(branch: Branch) -> void:
	"""Unlock a research branch"""
	if branch not in unlocked_branches:
		unlocked_branches.append(branch)
		branch_unlocked.emit(get_branch_name(branch))
		print("🌳 Research Branch Unlocked: ", get_branch_name(branch))


func is_branch_unlocked(branch: Branch) -> bool:
	"""Check if a branch is unlocked"""
	return branch in unlocked_branches


func is_effect_active(effect: String) -> bool:
	"""Check if an effect is active"""
	return active_effects.get(effect, false)


func get_branch_name(branch: Branch) -> String:
	"""Get human-readable branch name"""
	match branch:
		Branch.ECOLOGY: return "Ecology"
		Branch.ENGINEERING: return "Engineering"
		Branch.POLICY: return "Policy"
		Branch.CULTURE: return "Culture"
	return "Unknown"


func get_unlocked_nodes_in_branch(branch: Branch) -> Array:
	"""Get all unlocked nodes in a branch"""
	var nodes = []
	for node_id in tech_nodes.keys():
		var node = tech_nodes[node_id]
		if node.branch == branch and node.unlocked:
			nodes.append(node)
	return nodes


func get_available_nodes_in_branch(branch: Branch) -> Array:
	"""Get all available (can research) nodes in a branch"""
	var nodes = []
	for node_id in tech_nodes.keys():
		if can_research(node_id):
			var node = tech_nodes[node_id]
			if node.branch == branch:
				nodes.append(node)
	return nodes


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	var unlocked_node_ids = []
	for node_id in tech_nodes.keys():
		if tech_nodes[node_id].unlocked:
			unlocked_node_ids.append(node_id)
	
	return {
		"unlocked_nodes": unlocked_node_ids,
		"unlocked_branches": unlocked_branches,
		"active_effects": active_effects
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	var unlocked_node_ids = data.get("unlocked_nodes", [])
	for node_id in unlocked_node_ids:
		if node_id in tech_nodes:
			tech_nodes[node_id].unlocked = true
	
	unlocked_branches = data.get("unlocked_branches", [])
	active_effects = data.get("active_effects", {})
