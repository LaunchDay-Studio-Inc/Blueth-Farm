extends Node
## Test suite for QuestSystem

var quest_system: Node

func _ready() -> void:
	print("\n=== Testing QuestSystem ===")
	
	# Create a test quest system
	quest_system = Node.new()
	quest_system.set_script(load("res://scripts/npcs/quest_system.gd"))
	add_child(quest_system)
	
	# Register a test quest
	var test_quest = {
		"id": "test_quest_1",
		"title": "Test Quest",
		"description": "This is a test quest",
		"objectives": [
			{"description": "Collect 5 items", "target": 5},
			{"description": "Talk to NPC", "target": 1}
		],
		"rewards": {
			"gold": 100,
			"research_points": 10
		}
	}
	
	quest_system.register_quest(test_quest)
	
	# Test 1: Start quest
	print("\nTest 1: Start quest")
	quest_system.start_quest("test_quest_1")
	var active_quests = quest_system.get_active_quests()
	print("  Active quests count: ", active_quests.size())
	print("  Expected: 1")
	assert(active_quests.size() == 1, "Should have 1 active quest")
	print("  ✓ PASSED")
	
	# Test 2: Get quest by ID
	print("\nTest 2: Get quest by ID")
	var quest = quest_system.get_quest("test_quest_1")
	print("  Quest ID: ", quest.get("quest_id", "NOT FOUND"))
	print("  Quest Title: ", quest.get("title", "NOT FOUND"))
	assert(quest.get("quest_id") == "test_quest_1", "Should have quest_id")
	assert(quest.get("title") == "Test Quest", "Should have correct title")
	print("  ✓ PASSED")
	
	# Test 3: Update objective
	print("\nTest 3: Update objective")
	quest_system.update_objective("test_quest_1", 0, 3)
	quest = quest_system.get_quest("test_quest_1")
	var obj_progress = quest["objectives"][0]["current"]
	print("  Objective 0 progress: ", obj_progress)
	print("  Expected: 3")
	assert(obj_progress == 3, "Objective should have progress of 3")
	print("  ✓ PASSED")
	
	# Test 4: Complete all objectives
	print("\nTest 4: Complete all objectives")
	quest_system.update_objective("test_quest_1", 0, 2)  # Complete first objective
	quest_system.update_objective("test_quest_1", 1, 1)  # Complete second objective
	
	# Quest should auto-complete
	var completed_quests = quest_system.get_completed_quests()
	print("  Completed quests count: ", completed_quests.size())
	print("  Expected: 1")
	assert(completed_quests.size() == 1, "Should have 1 completed quest")
	
	# Active quests should be empty
	active_quests = quest_system.get_active_quests()
	print("  Active quests count: ", active_quests.size())
	print("  Expected: 0")
	assert(active_quests.size() == 0, "Should have 0 active quests")
	print("  ✓ PASSED")
	
	# Test 5: Get completed quest data
	print("\nTest 5: Get completed quest data")
	quest = quest_system.get_quest("test_quest_1")
	print("  Quest state: ", quest.get("state"))
	print("  Quest title: ", quest.get("title"))
	assert(quest.get("title") == "Test Quest", "Should still have quest data after completion")
	print("  ✓ PASSED")
	
	# Test 6: Verify internal Dictionary storage
	print("\nTest 6: Verify internal Dictionary storage")
	print("  completed_quests type: ", typeof(quest_system.completed_quests))
	assert(typeof(quest_system.completed_quests) == TYPE_DICTIONARY, "completed_quests should be Dictionary")
	assert(quest_system.completed_quests.has("test_quest_1"), "Should have quest_id as key")
	var stored_quest = quest_system.completed_quests["test_quest_1"]
	print("  Stored quest title: ", stored_quest.get("title"))
	print("  Stored quest objectives count: ", stored_quest.get("objectives", []).size())
	assert(stored_quest.get("title") == "Test Quest", "Stored quest should have complete data")
	assert(stored_quest.get("objectives", []).size() == 2, "Should preserve objectives")
	print("  ✓ PASSED")
	
	print("\n=== All QuestSystem tests PASSED! ===\n")
	
	# Clean up
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
