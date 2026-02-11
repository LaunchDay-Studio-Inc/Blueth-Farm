extends GutTest
## Test suite for TutorialSystem save/load functionality
##
## Tests that tutorial progress is properly saved and restored

var tutorial_system: Node


func before_each():
	"""Set up before each test"""
	# Create a test tutorial system
	tutorial_system = Node.new()
	tutorial_system.set_script(load("res://scripts/progression/tutorial_system.gd"))
	tutorial_system.add_to_group("tutorial_system")
	add_child_autofree(tutorial_system)


func test_save_tutorial_not_started():
	"""Test saving tutorial when not started"""
	# Get save data
	var save_data = tutorial_system.get_save_data()

	assert_has(save_data, "tutorial_completed", "Save data should have tutorial_completed")
	assert_has(save_data, "current_step", "Save data should have current_step")
	assert_false(save_data["tutorial_completed"], "Tutorial should not be completed")
	assert_eq(save_data["current_step"], 0, "Current step should be WELCOME (0)")


func test_save_tutorial_in_progress():
	"""Test saving tutorial when in progress"""
	# Start tutorial and advance a few steps
	tutorial_system.tutorial_active = true
	tutorial_system.current_step = 3  # TALK_TO_OLD_SALT

	# Get save data
	var save_data = tutorial_system.get_save_data()

	assert_false(save_data["tutorial_completed"], "Tutorial should not be completed")
	assert_eq(save_data["current_step"], 3, "Should save current step")


func test_save_tutorial_completed():
	"""Test saving tutorial when completed"""
	# Mark tutorial as completed
	tutorial_system.tutorial_completed_flag = true
	tutorial_system.current_step = 7  # COMPLETE

	# Get save data
	var save_data = tutorial_system.get_save_data()

	assert_true(save_data["tutorial_completed"], "Tutorial should be completed")
	assert_eq(save_data["current_step"], 7, "Should save completed step")


func test_load_tutorial_not_started():
	"""Test loading tutorial when not started"""
	# Create save data for tutorial not started
	var save_data = {
		"tutorial_completed": false,
		"current_step": 0
	}

	# Load the data
	tutorial_system.load_save_data(save_data)

	assert_false(tutorial_system.tutorial_completed_flag, "Tutorial should not be completed")
	assert_eq(tutorial_system.current_step, 0, "Should restore current step to WELCOME")


func test_load_tutorial_in_progress():
	"""Test loading tutorial when in progress"""
	# Create save data for tutorial in progress
	var save_data = {
		"tutorial_completed": false,
		"current_step": 5  # EQUIP_AND_PLANT
	}

	# Load the data
	tutorial_system.load_save_data(save_data)

	assert_false(tutorial_system.tutorial_completed_flag, "Tutorial should not be completed")
	assert_eq(tutorial_system.current_step, 5, "Should restore current step")
	assert_false(tutorial_system.tutorial_active, "Tutorial should not be auto-started on load")


func test_load_tutorial_completed():
	"""Test loading tutorial when completed"""
	# Create save data for completed tutorial
	var save_data = {
		"tutorial_completed": true,
		"current_step": 7  # COMPLETE
	}

	# Load the data
	tutorial_system.load_save_data(save_data)

	assert_true(tutorial_system.tutorial_completed_flag, "Tutorial should be completed")
	assert_eq(tutorial_system.current_step, 7, "Should restore current step to COMPLETE")
	assert_false(tutorial_system.tutorial_active, "Tutorial should not be active")


func test_save_load_roundtrip():
	"""Test that saving and loading preserves all tutorial data"""
	# Set tutorial to a mid-progress state
	tutorial_system.tutorial_active = true
	tutorial_system.tutorial_completed_flag = false
	tutorial_system.current_step = 4  # OPEN_INVENTORY

	# Get save data
	var save_data = tutorial_system.get_save_data()

	# Create a new tutorial system and load the data
	var new_tutorial_system = Node.new()
	new_tutorial_system.set_script(load("res://scripts/progression/tutorial_system.gd"))
	add_child_autofree(new_tutorial_system)

	new_tutorial_system.load_save_data(save_data)

	# Verify all data was preserved
	assert_false(new_tutorial_system.tutorial_completed_flag, "Should preserve completed flag")
	assert_eq(new_tutorial_system.current_step, 4, "Should preserve current step")


func test_load_missing_fields():
	"""Test loading save data with missing fields uses defaults"""
	var save_data = {}

	tutorial_system.load_save_data(save_data)

	# Should use defaults without crashing
	assert_false(tutorial_system.tutorial_completed_flag, "Should default to not completed")
	assert_eq(tutorial_system.current_step, 0, "Should default to WELCOME step")


func test_load_after_tutorial_completed():
	"""Test that completed tutorial stays completed after load"""
	# Complete the tutorial
	tutorial_system.tutorial_completed_flag = true
	tutorial_system.current_step = 7

	# Save and reload
	var save_data = tutorial_system.get_save_data()

	# Create new instance
	var new_tutorial_system = Node.new()
	new_tutorial_system.set_script(load("res://scripts/progression/tutorial_system.gd"))
	add_child_autofree(new_tutorial_system)

	new_tutorial_system.load_save_data(save_data)

	# Try to start tutorial - it should not start
	new_tutorial_system.start_tutorial()

	assert_true(new_tutorial_system.tutorial_completed_flag, "Tutorial should remain completed")
	assert_false(new_tutorial_system.tutorial_active, "Tutorial should not become active")
