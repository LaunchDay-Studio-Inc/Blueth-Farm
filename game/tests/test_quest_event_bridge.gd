extends GutTest
## Test suite for QuestEventBridge using GUT framework
## Tests quest resource loading, signal handling, and quest chain progression

var quest_system: Node
var quest_bridge: Node
var mock_tile_manager: Node
var mock_weather_system: Node
var mock_carbon_manager: Node


func before_each():
	"""Set up test systems before each test"""
	# Create QuestSystem
	quest_system = Node.new()
	quest_system.set_script(load("res://scripts/npcs/quest_system.gd"))
	quest_system.name = "QuestSystem"
	add_child_autofree(quest_system)
	
	# Create mock TileMapManager with signals
	mock_tile_manager = Node.new()
	mock_tile_manager.name = "TileMapManager"
	var tile_mgr_script = GDScript.new()
	tile_mgr_script.source_code = """
extends Node
signal tile_planted(tile_pos: Vector2i, species: String)
signal tile_harvested(tile_pos: Vector2i)
"""
	tile_mgr_script.reload()
	mock_tile_manager.set_script(tile_mgr_script)
	add_child_autofree(mock_tile_manager)
	
	# Create mock WeatherSystem with signals
	mock_weather_system = Node.new()
	mock_weather_system.name = "WeatherSystem"
	var weather_script = GDScript.new()
	weather_script.source_code = """
extends Node
signal storm_ended(damage_prevented: float)
"""
	weather_script.reload()
	mock_weather_system.set_script(weather_script)
	add_child_autofree(mock_weather_system)
	
	# Create mock CarbonManager (if not already present as autoload)
	var existing_carbon = get_node_or_null("/root/CarbonManager")
	if not existing_carbon:
		mock_carbon_manager = Node.new()
		mock_carbon_manager.name = "CarbonManager"
		var carbon_script = GDScript.new()
		carbon_script.source_code = """
extends Node
signal carbon_updated(total_co2: float, daily_rate: float)
"""
		carbon_script.reload()
		mock_carbon_manager.set_script(carbon_script)
		# Add as child so it's accessible in tests
		get_tree().root.add_child(mock_carbon_manager)
	
	# Create QuestEventBridge
	quest_bridge = Node.new()
	quest_bridge.set_script(load("res://scripts/npcs/quest_event_bridge.gd"))
	quest_bridge.name = "QuestEventBridge"
	add_child_autofree(quest_bridge)
	
	# Wait for bridge to initialize
	await wait_frames(2)


func after_each():
	"""Clean up after each test"""
	# Remove mock CarbonManager if we created it
	if mock_carbon_manager and is_instance_valid(mock_carbon_manager):
		mock_carbon_manager.queue_free()
		mock_carbon_manager = null


func test_quest_resources_loaded():
	"""Quest resources should be loaded and registered from .tres files"""
	# Check that quests were registered
	var quest_count = quest_system.quest_definitions.size()
	assert_gt(quest_count, 0, "Should have loaded quest resources")
	
	# Check specific quest
	assert_true(quest_system.quest_definitions.has("welcome_home"), "Should have loaded welcome_home quest")
	
	# Verify quest structure
	var welcome_home = quest_system.quest_definitions["welcome_home"]
	assert_eq(welcome_home.get("title"), "Welcome Home", "Should have correct title")
	assert_gt(welcome_home.get("objectives", []).size(), 0, "Should have objectives")


func test_auto_start_quests():
	"""Quests with no prerequisites should be auto-started"""
	# Check active quests
	var active_quests = quest_system.get_active_quests()
	
	# Should have at least one auto-started quest
	var has_active_quest = false
	for quest in active_quests:
		if quest.get("quest_id") == "welcome_home" or quest.get("id") == "welcome_home":
			has_active_quest = true
			break
	
	assert_true(has_active_quest, "Should have auto-started a quest with no prerequisites")


func test_plant_objective_update():
	"""Plant objectives should be updated when plants are placed"""
	# Create a test quest with plant objective
	var test_quest = {
		"id": "test_plant_quest",
		"title": "Test Planting",
		"description": "Plant some eelgrass",
		"objectives": [
			{
				"type": "plant",
				"species": "eelgrass",
				"description": "Plant 3 eelgrass",
				"target": 3
			}
		],
		"rewards": {"gold": 50}
	}
	quest_system.register_quest(test_quest)
	quest_system.start_quest("test_plant_quest")
	
	# Simulate planting
	mock_tile_manager.tile_planted.emit(Vector2i(0, 0), "eelgrass")
	await wait_frames(1)
	
	# Check objective progress
	var quest = quest_system.get_quest("test_plant_quest")
	assert_eq(quest["objectives"][0]["current"], 1, "Should have updated objective progress")
	
	# Plant more to complete
	mock_tile_manager.tile_planted.emit(Vector2i(1, 0), "eelgrass")
	mock_tile_manager.tile_planted.emit(Vector2i(2, 0), "eelgrass")
	await wait_frames(1)
	
	# Check if quest completed
	assert_true(quest_system.is_quest_completed("test_plant_quest"), "Should have completed quest after reaching target")


func test_harvest_objective_update():
	"""Harvest objectives should be updated when plants are harvested"""
	# Create a test quest with harvest objective
	var test_quest = {
		"id": "test_harvest_quest",
		"title": "Test Harvesting",
		"description": "Harvest some plants",
		"objectives": [
			{
				"type": "harvest",
				"description": "Harvest 2 plants",
				"target": 2
			}
		],
		"rewards": {"gold": 50}
	}
	quest_system.register_quest(test_quest)
	quest_system.start_quest("test_harvest_quest")
	
	# Simulate harvesting
	mock_tile_manager.tile_harvested.emit(Vector2i(0, 0))
	await wait_frames(1)
	
	# Check objective progress
	var quest = quest_system.get_quest("test_harvest_quest")
	assert_eq(quest["objectives"][0]["current"], 1, "Should have updated objective progress")
	
	# Harvest more to complete
	mock_tile_manager.tile_harvested.emit(Vector2i(1, 0))
	await wait_frames(1)
	
	# Check if quest completed
	assert_true(quest_system.is_quest_completed("test_harvest_quest"), "Should have completed quest after reaching target")


func test_carbon_goal_update():
	"""Carbon goal objectives should be updated when carbon threshold is reached"""
	# Create a test quest with carbon goal objective
	var test_quest = {
		"id": "test_carbon_quest",
		"title": "Test Carbon Goal",
		"description": "Sequester carbon",
		"objectives": [
			{
				"type": "carbon_goal",
				"amount": 5.0,
				"description": "Sequester 5 tonnes CO2",
				"target": 1
			}
		],
		"rewards": {"gold": 100}
	}
	quest_system.register_quest(test_quest)
	quest_system.start_quest("test_carbon_quest")
	
	# Get CarbonManager (either real or mocked)
	var carbon_mgr = get_node_or_null("/root/CarbonManager")
	if not carbon_mgr:
		carbon_mgr = mock_carbon_manager
	
	if carbon_mgr and carbon_mgr.has_signal("carbon_updated"):
		# Simulate carbon update below threshold
		carbon_mgr.carbon_updated.emit(3.0, 0.5)
		await wait_frames(1)
		
		assert_false(quest_system.is_quest_completed("test_carbon_quest"), "Should not complete quest below threshold")
		
		# Simulate carbon update above threshold
		carbon_mgr.carbon_updated.emit(6.0, 0.5)
		await wait_frames(1)
		
		assert_true(quest_system.is_quest_completed("test_carbon_quest"), "Should complete quest when threshold reached")
	else:
		pending("CarbonManager not available in test environment")


func test_storm_survival_update():
	"""Storm survival objectives should be updated when storms end"""
	# Create a test quest with survive_storm objective
	var test_quest = {
		"id": "test_storm_quest",
		"title": "Test Storm Survival",
		"description": "Survive a storm",
		"objectives": [
			{
				"type": "survive_storm",
				"description": "Survive a storm",
				"target": 1
			}
		],
		"rewards": {"gold": 100}
	}
	quest_system.register_quest(test_quest)
	quest_system.start_quest("test_storm_quest")
	
	# Simulate storm ending
	mock_weather_system.storm_ended.emit(50.0)
	await wait_frames(1)
	
	# Check if quest completed
	assert_true(quest_system.is_quest_completed("test_storm_quest"), "Should complete quest after surviving storm")


func test_quest_chain_progression():
	"""Quest chains should progress automatically when prerequisites are met"""
	# Create a chain of quests
	var quest_a = {
		"id": "chain_quest_a",
		"title": "Chain Quest A",
		"description": "First quest in chain",
		"objectives": [{"description": "Complete task", "target": 1, "type": "generic"}],
		"rewards": {"gold": 50},
		"prerequisite_quests": [],
		"required_year": 1
	}
	
	var quest_b = {
		"id": "chain_quest_b",
		"title": "Chain Quest B",
		"description": "Second quest in chain",
		"objectives": [{"description": "Complete task", "target": 1, "type": "generic"}],
		"rewards": {"gold": 50},
		"prerequisite_quests": ["chain_quest_a"],
		"required_year": 1
	}
	
	quest_system.register_quest(quest_a)
	quest_system.register_quest(quest_b)
	
	# Start first quest
	quest_system.start_quest("chain_quest_a")
	
	# Check that second quest is not active yet
	assert_false(quest_system.active_quests.has("chain_quest_b"), "Chain Quest B should not be active yet")
	
	# Complete first quest
	quest_system.update_objective("chain_quest_a", 0, 1)
	await wait_frames(2)
	
	# Check that second quest auto-started
	assert_true(quest_system.active_quests.has("chain_quest_b"), "Chain Quest B should auto-start after A completes")


func test_npc_visit_tracking():
	"""NPC visit tracking should update visit_npc objectives"""
	# Create a test quest with visit_npc objective
	var test_quest = {
		"id": "test_visit_quest",
		"title": "Test NPC Visit",
		"description": "Visit Old Salt",
		"objectives": [
			{
				"type": "visit_npc",
				"npc_id": "old_salt",
				"description": "Visit Old Salt",
				"target": 1
			}
		],
		"rewards": {"gold": 50}
	}
	quest_system.register_quest(test_quest)
	quest_system.start_quest("test_visit_quest")
	
	# Simulate NPC interaction
	quest_bridge.set_last_npc_talked_to("old_salt")
	quest_bridge._on_dialogue_ended()
	await wait_frames(1)
	
	# Check if quest completed
	assert_true(quest_system.is_quest_completed("test_visit_quest"), "Should complete quest after visiting NPC")

