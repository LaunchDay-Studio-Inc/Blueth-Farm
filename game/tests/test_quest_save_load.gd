extends GutTest
## Test suite for QuestSystem save/load functionality
##
## Tests that quest progress is properly saved and restored

var quest_system: Node


func before_each():
	"""Set up before each test"""
	# Create a test quest system
	quest_system = Node.new()
	quest_system.set_script(load("res://scripts/npcs/quest_system.gd"))
	quest_system.add_to_group("quest_system")
	add_child_autofree(quest_system)

	# Register test quests
	_register_test_quests()


func _register_test_quests():
	"""Register quests for testing"""
	var quest1 = {
		"id": "test_quest_1",
		"title": "First Quest",
		"description": "This is the first test quest",
		"objectives": [
			{"description": "Collect 5 items", "target": 5},
			{"description": "Talk to NPC", "target": 1}
		],
		"rewards": {
			"gold": 100,
			"research_points": 10
		}
	}

	var quest2 = {
		"id": "test_quest_2",
		"title": "Second Quest",
		"description": "This is the second test quest",
		"objectives": [
			{"description": "Plant 10 seeds", "target": 10}
		],
		"rewards": {
			"gold": 50
		}
	}

	quest_system.register_quest(quest1)
	quest_system.register_quest(quest2)


func test_save_active_quest():
	"""Test saving an active quest"""
	# Start a quest
	quest_system.start_quest("test_quest_1")

	# Make some progress
	quest_system.update_objective("test_quest_1", 0, 3)

	# Get save data
	var save_data = quest_system.get_save_data()

	assert_has(save_data, "active_quests", "Save data should have active_quests")
	assert_has(save_data["active_quests"], "test_quest_1", "Should have test_quest_1 in active_quests")

	var saved_quest = save_data["active_quests"]["test_quest_1"]
	assert_eq(saved_quest["objectives"][0]["current"], 3, "Should save objective progress")


func test_save_completed_quest():
	"""Test saving a completed quest"""
	# Start and complete a quest
	quest_system.start_quest("test_quest_1")
	quest_system.update_objective("test_quest_1", 0, 5)
	quest_system.update_objective("test_quest_1", 1, 1)

	# Get save data
	var save_data = quest_system.get_save_data()

	assert_has(save_data, "completed_quests", "Save data should have completed_quests")
	assert_has(save_data["completed_quests"], "test_quest_1", "Should have test_quest_1 in completed_quests")
	assert_eq(save_data["active_quests"].size(), 0, "Should have no active quests")


func test_load_active_quest():
	"""Test loading an active quest"""
	# Create save data with an active quest
	var save_data = {
		"active_quests": {
			"test_quest_1": {
				"id": "test_quest_1",
				"title": "First Quest",
				"description": "This is the first test quest",
				"objectives": [
					{"description": "Collect 5 items", "target": 5, "current": 3, "completed": false},
					{"description": "Talk to NPC", "target": 1, "current": 0, "completed": false}
				],
				"rewards": {"gold": 100, "research_points": 10},
				"state": 1  # QuestState.ACTIVE
			}
		},
		"completed_quests": {},
		"failed_quests": []
	}

	# Load the data
	quest_system.load_save_data(save_data)

	# Verify the quest was loaded
	var active_quests = quest_system.get_active_quests()
	assert_eq(active_quests.size(), 1, "Should have 1 active quest")
	assert_eq(active_quests[0]["quest_id"], "test_quest_1", "Should have test_quest_1")
	assert_eq(active_quests[0]["objectives"][0]["current"], 3, "Should restore objective progress")


func test_load_completed_quest():
	"""Test loading a completed quest"""
	# Create save data with a completed quest
	var save_data = {
		"active_quests": {},
		"completed_quests": {
			"test_quest_1": {
				"id": "test_quest_1",
				"title": "First Quest",
				"description": "This is the first test quest",
				"objectives": [
					{"description": "Collect 5 items", "target": 5, "current": 5, "completed": true},
					{"description": "Talk to NPC", "target": 1, "current": 1, "completed": true}
				],
				"rewards": {"gold": 100, "research_points": 10},
				"state": 2  # QuestState.COMPLETED
			}
		},
		"failed_quests": []
	}

	# Load the data
	quest_system.load_save_data(save_data)

	# Verify the quest was loaded
	var completed_quests = quest_system.get_completed_quests()
	assert_eq(completed_quests.size(), 1, "Should have 1 completed quest")
	assert_eq(completed_quests[0]["quest_id"], "test_quest_1", "Should have test_quest_1")
	assert_true(quest_system.is_quest_completed("test_quest_1"), "Quest should be marked as completed")


func test_save_load_roundtrip():
	"""Test that saving and loading preserves all quest data"""
	# Start multiple quests with different states
	quest_system.start_quest("test_quest_1")
	quest_system.update_objective("test_quest_1", 0, 3)

	quest_system.start_quest("test_quest_2")
	quest_system.update_objective("test_quest_2", 0, 10)  # Complete it

	# Get save data
	var save_data = quest_system.get_save_data()

	# Create a new quest system and load the data
	var new_quest_system = Node.new()
	new_quest_system.set_script(load("res://scripts/npcs/quest_system.gd"))
	add_child_autofree(new_quest_system)

	new_quest_system.load_save_data(save_data)

	# Verify active quests
	var active_quests = new_quest_system.get_active_quests()
	assert_eq(active_quests.size(), 1, "Should have 1 active quest")
	assert_eq(active_quests[0]["quest_id"], "test_quest_1", "Should restore test_quest_1")
	assert_eq(active_quests[0]["objectives"][0]["current"], 3, "Should restore progress")

	# Verify completed quests
	var completed_quests = new_quest_system.get_completed_quests()
	assert_eq(completed_quests.size(), 1, "Should have 1 completed quest")
	assert_eq(completed_quests[0]["quest_id"], "test_quest_2", "Should restore test_quest_2")


func test_load_empty_save_data():
	"""Test loading empty save data doesn't crash"""
	var save_data = {
		"active_quests": {},
		"completed_quests": {},
		"failed_quests": []
	}

	quest_system.load_save_data(save_data)

	assert_eq(quest_system.get_active_quests().size(), 0, "Should have no active quests")
	assert_eq(quest_system.get_completed_quests().size(), 0, "Should have no completed quests")


func test_load_missing_fields():
	"""Test loading save data with missing fields uses defaults"""
	var save_data = {}

	quest_system.load_save_data(save_data)

	# Should use defaults without crashing
	assert_eq(quest_system.get_active_quests().size(), 0, "Should default to empty active quests")
	assert_eq(quest_system.get_completed_quests().size(), 0, "Should default to empty completed quests")
