extends GutTest
## Test suite for RelationshipSystem save/load functionality
##
## Tests that relationship progress is properly saved and restored

var relationship_system: Node


func before_each():
	"""Set up before each test"""
	# Create a test relationship system
	relationship_system = Node.new()
	relationship_system.set_script(load("res://scripts/npcs/relationship_system.gd"))
	relationship_system.add_to_group("relationship_system")
	add_child_autofree(relationship_system)


func test_save_single_relationship():
	"""Test saving a single NPC relationship"""
	# Set a relationship value
	relationship_system.set_relationship("TestNPC", 50)

	# Get save data
	var save_data = relationship_system.get_save_data()

	assert_has(save_data, "relationships", "Save data should have relationships")
	assert_has(save_data["relationships"], "TestNPC", "Should have TestNPC in relationships")
	assert_eq(save_data["relationships"]["TestNPC"], 50, "Should save correct relationship value")


func test_save_multiple_relationships():
	"""Test saving multiple NPC relationships"""
	# Set multiple relationships
	relationship_system.set_relationship("NPC1", 25)
	relationship_system.set_relationship("NPC2", 50)
	relationship_system.set_relationship("NPC3", 75)

	# Get save data
	var save_data = relationship_system.get_save_data()

	assert_eq(save_data["relationships"].size(), 3, "Should save 3 relationships")
	assert_eq(save_data["relationships"]["NPC1"], 25, "Should save NPC1 correctly")
	assert_eq(save_data["relationships"]["NPC2"], 50, "Should save NPC2 correctly")
	assert_eq(save_data["relationships"]["NPC3"], 75, "Should save NPC3 correctly")


func test_load_single_relationship():
	"""Test loading a single NPC relationship"""
	# Create save data
	var save_data = {
		"relationships": {
			"TestNPC": 60
		}
	}

	# Load the data
	relationship_system.load_save_data(save_data)

	# Verify the relationship was loaded
	assert_eq(relationship_system.get_relationship("TestNPC"), 60, "Should restore relationship value")
	assert_eq(relationship_system.get_relationship_tier("TestNPC"),
		relationship_system.TIER_CLOSE_FRIEND, "Should restore correct tier")


func test_load_multiple_relationships():
	"""Test loading multiple NPC relationships"""
	# Create save data
	var save_data = {
		"relationships": {
			"NPC1": 20,
			"NPC2": 40,
			"NPC3": 80
		}
	}

	# Load the data
	relationship_system.load_save_data(save_data)

	# Verify relationships were loaded
	assert_eq(relationship_system.get_relationship("NPC1"), 20, "Should restore NPC1")
	assert_eq(relationship_system.get_relationship("NPC2"), 40, "Should restore NPC2")
	assert_eq(relationship_system.get_relationship("NPC3"), 80, "Should restore NPC3")

	# Verify tiers
	assert_eq(relationship_system.get_relationship_tier("NPC1"),
		relationship_system.TIER_ACQUAINTANCE, "NPC1 should be Acquaintance")
	assert_eq(relationship_system.get_relationship_tier("NPC2"),
		relationship_system.TIER_FRIEND, "NPC2 should be Friend")
	assert_eq(relationship_system.get_relationship_tier("NPC3"),
		relationship_system.TIER_CLOSE_FRIEND, "NPC3 should be Close Friend")


func test_save_load_roundtrip():
	"""Test that saving and loading preserves all relationship data"""
	# Set multiple relationships
	relationship_system.set_relationship("OldSalt", 35)
	relationship_system.set_relationship("Marina", 65)
	relationship_system.set_relationship("TechExpert", 100)

	# Get save data
	var save_data = relationship_system.get_save_data()

	# Create a new relationship system and load the data
	var new_relationship_system = Node.new()
	new_relationship_system.set_script(load("res://scripts/npcs/relationship_system.gd"))
	add_child_autofree(new_relationship_system)

	new_relationship_system.load_save_data(save_data)

	# Verify all relationships
	assert_eq(new_relationship_system.get_relationship("OldSalt"), 35, "Should restore OldSalt")
	assert_eq(new_relationship_system.get_relationship("Marina"), 65, "Should restore Marina")
	assert_eq(new_relationship_system.get_relationship("TechExpert"), 100, "Should restore TechExpert")

	# Verify tiers
	assert_eq(new_relationship_system.get_relationship_tier("OldSalt"),
		relationship_system.TIER_FRIEND, "OldSalt tier should be preserved")
	assert_eq(new_relationship_system.get_relationship_tier("Marina"),
		relationship_system.TIER_CLOSE_FRIEND, "Marina tier should be preserved")
	assert_eq(new_relationship_system.get_relationship_tier("TechExpert"),
		relationship_system.TIER_BEST_FRIEND, "TechExpert tier should be preserved")


func test_load_empty_save_data():
	"""Test loading empty save data doesn't crash"""
	var save_data = {
		"relationships": {}
	}

	relationship_system.load_save_data(save_data)

	var all_relationships = relationship_system.get_all_relationships()
	assert_eq(all_relationships.size(), 0, "Should have no relationships")


func test_load_missing_fields():
	"""Test loading save data with missing fields uses defaults"""
	var save_data = {}

	relationship_system.load_save_data(save_data)

	# Should use defaults without crashing
	var all_relationships = relationship_system.get_all_relationships()
	assert_eq(all_relationships.size(), 0, "Should default to empty relationships")


func test_load_overwrites_existing_relationships():
	"""Test that loading save data overwrites existing relationships"""
	# Set initial relationships
	relationship_system.set_relationship("NPC1", 50)
	relationship_system.set_relationship("NPC2", 30)

	# Load different data
	var save_data = {
		"relationships": {
			"NPC1": 80,
			"NPC3": 20
		}
	}

	relationship_system.load_save_data(save_data)

	# Verify NPC1 was overwritten
	assert_eq(relationship_system.get_relationship("NPC1"), 80, "Should overwrite NPC1")

	# Verify NPC2 is gone (relationships were replaced, not merged)
	assert_eq(relationship_system.get_relationship("NPC2"), 0, "NPC2 should be reset")

	# Verify NPC3 was added
	assert_eq(relationship_system.get_relationship("NPC3"), 20, "Should add NPC3")
