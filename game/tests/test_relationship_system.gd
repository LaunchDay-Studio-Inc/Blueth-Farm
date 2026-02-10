extends GutTest
## Unit tests for RelationshipSystem
## Tests friendship tier transitions, relationship bounds, and signal emissions


var relationship_system: Node


func before_each():
	"""Set up RelationshipSystem before each test"""
	# Get or create RelationshipSystem instance
	if has_node("/root/RelationshipSystem"):
		relationship_system = get_node("/root/RelationshipSystem")
	else:
		# Create a temporary instance for testing
		var RelationshipSystemScript = load("res://scripts/npcs/relationship_system.gd")
		relationship_system = RelationshipSystemScript.new()
		add_child(relationship_system)
	
	# Reset all relationships
	relationship_system.relationships.clear()


func after_each():
	"""Clean up after each test"""
	if relationship_system and not relationship_system.is_queued_for_deletion():
		if not has_node("/root/RelationshipSystem"):
			relationship_system.queue_free()


func test_initial_relationship_is_stranger():
	"""Test that new NPCs start as strangers"""
	var tier = relationship_system.get_relationship_tier("TestNPC")
	assert_eq(tier, relationship_system.TIER_STRANGER, "New NPC should be Stranger")


func test_stranger_to_acquaintance_transition():
	"""Test transition from Stranger to Acquaintance at 20 points"""
	relationship_system.set_relationship("TestNPC", 0)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_STRANGER, "Should start as Stranger")
	
	relationship_system.set_relationship("TestNPC", 20)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_ACQUAINTANCE, "Should be Acquaintance at 20")


func test_acquaintance_to_friend_transition():
	"""Test transition from Acquaintance to Friend at 40 points"""
	relationship_system.set_relationship("TestNPC", 20)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_ACQUAINTANCE, "Should be Acquaintance at 20")
	
	relationship_system.set_relationship("TestNPC", 40)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_FRIEND, "Should be Friend at 40")


func test_friend_to_close_friend_transition():
	"""Test transition from Friend to Close Friend at 60 points"""
	relationship_system.set_relationship("TestNPC", 40)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_FRIEND, "Should be Friend at 40")
	
	relationship_system.set_relationship("TestNPC", 60)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_CLOSE_FRIEND, "Should be Close Friend at 60")


func test_close_friend_to_best_friend_transition():
	"""Test transition from Close Friend to Best Friend at 80 points"""
	relationship_system.set_relationship("TestNPC", 60)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_CLOSE_FRIEND, "Should be Close Friend at 60")
	
	relationship_system.set_relationship("TestNPC", 80)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_CLOSE_FRIEND, "Should be Close Friend at 80")
	
	# Need to reach 100 for Best Friend
	relationship_system.set_relationship("TestNPC", 100)
	assert_eq(relationship_system.get_relationship_tier("TestNPC"), 
		relationship_system.TIER_BEST_FRIEND, "Should be Best Friend at 100")


func test_relationship_clamped_at_0():
	"""Test that relationship value cannot go below 0"""
	relationship_system.set_relationship("TestNPC", 50)
	relationship_system.modify_relationship("TestNPC", -100)
	
	var value = relationship_system.get_relationship("TestNPC")
	assert_eq(value, 0, "Relationship should be clamped at 0")


func test_relationship_clamped_at_100():
	"""Test that relationship value cannot exceed 100"""
	relationship_system.set_relationship("TestNPC", 50)
	relationship_system.modify_relationship("TestNPC", 100)
	
	var value = relationship_system.get_relationship("TestNPC")
	assert_eq(value, 100, "Relationship should be clamped at 100")


func test_modify_relationship_positive():
	"""Test that modify_relationship increases relationship"""
	relationship_system.set_relationship("TestNPC", 30)
	relationship_system.modify_relationship("TestNPC", 10)
	
	var value = relationship_system.get_relationship("TestNPC")
	assert_eq(value, 40, "Relationship should increase by 10")


func test_modify_relationship_negative():
	"""Test that modify_relationship decreases relationship"""
	relationship_system.set_relationship("TestNPC", 50)
	relationship_system.modify_relationship("TestNPC", -15)
	
	var value = relationship_system.get_relationship("TestNPC")
	assert_eq(value, 35, "Relationship should decrease by 15")


func test_relationship_changed_signal_emission():
	"""Test that relationship_changed signal is emitted"""
	watch_signals(relationship_system)
	
	relationship_system.modify_relationship("TestNPC", 20)
	
	assert_signal_emitted(relationship_system, "relationship_changed", 
		"relationship_changed signal should be emitted")


func test_tier_change_detection():
	"""Test that tier changes are detected when crossing thresholds"""
	relationship_system.set_relationship("TestNPC", 19)
	var tier_before = relationship_system.get_relationship_tier("TestNPC")
	
	relationship_system.modify_relationship("TestNPC", 1)
	var tier_after = relationship_system.get_relationship_tier("TestNPC")
	
	assert_ne(tier_before, tier_after, "Tier should change when crossing threshold")
	assert_eq(tier_before, relationship_system.TIER_STRANGER)
	assert_eq(tier_after, relationship_system.TIER_ACQUAINTANCE)


func test_get_all_relationships():
	"""Test getting all relationships"""
	relationship_system.set_relationship("NPC1", 25)
	relationship_system.set_relationship("NPC2", 50)
	relationship_system.set_relationship("NPC3", 75)
	
	var all_relationships = relationship_system.get_all_relationships()
	
	assert_eq(all_relationships.size(), 3, "Should have 3 relationships")
	assert_eq(all_relationships["NPC1"], 25)
	assert_eq(all_relationships["NPC2"], 50)
	assert_eq(all_relationships["NPC3"], 75)


func test_reset_relationship():
	"""Test resetting a relationship to 0"""
	relationship_system.set_relationship("TestNPC", 50)
	assert_eq(relationship_system.get_relationship("TestNPC"), 50)
	
	relationship_system.reset_relationship("TestNPC")
	
	var value = relationship_system.get_relationship("TestNPC")
	assert_eq(value, 0, "Relationship should be reset to 0")
	
	var tier = relationship_system.get_relationship_tier("TestNPC")
	assert_eq(tier, relationship_system.TIER_STRANGER, "Tier should be Stranger after reset")


func test_multiple_npcs_independent():
	"""Test that different NPCs have independent relationships"""
	relationship_system.set_relationship("NPC1", 20)
	relationship_system.set_relationship("NPC2", 60)
	
	assert_eq(relationship_system.get_relationship("NPC1"), 20)
	assert_eq(relationship_system.get_relationship("NPC2"), 60)
	
	relationship_system.modify_relationship("NPC1", 10)
	
	assert_eq(relationship_system.get_relationship("NPC1"), 30, "NPC1 should increase")
	assert_eq(relationship_system.get_relationship("NPC2"), 60, "NPC2 should remain unchanged")
