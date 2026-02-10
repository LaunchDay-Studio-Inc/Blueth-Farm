extends GutTest
## Test suite for tutorial system integration with Old Salt NPC

var tutorial_system: Node
var npc_manager: Node
var dialogue_box: Node
var old_salt_data: NPCData

func before_each() -> void:
	"""Set up test environment before each test"""
	# Create tutorial system
	tutorial_system = Node.new()
	tutorial_system.set_script(load("res://scripts/progression/tutorial_system.gd"))
	tutorial_system.name = "TutorialSystem"
	add_child(tutorial_system)
	tutorial_system.add_to_group("tutorial_system")

	# Create NPC manager
	npc_manager = Node.new()
	npc_manager.set_script(load("res://scripts/npcs/npc_manager.gd"))
	npc_manager.name = "NPCManager"
	add_child(npc_manager)
	npc_manager.add_to_group("npc_manager")

	# Load Old Salt data
	old_salt_data = load("res://resources/npcs/old_salt.tres")

	# Create dialogue box
	var dialogue_scene = load("res://scenes/ui/dialogue_box.tscn")
	if dialogue_scene:
		dialogue_box = dialogue_scene.instantiate()
		dialogue_box.name = "DialogueBox"
		add_child(dialogue_box)


func after_each() -> void:
	"""Clean up after each test"""
	if tutorial_system:
		tutorial_system.queue_free()
	if npc_manager:
		npc_manager.queue_free()
	if dialogue_box:
		dialogue_box.queue_free()


func test_old_salt_has_tutorial_dialogues() -> void:
	"""Test that Old Salt has all required tutorial dialogue trees"""
	assert_not_null(old_salt_data, "Old Salt NPC data should exist")

	var required_dialogues = [
		"tutorial_welcome",
		"tutorial_after_movement",
		"tutorial_meet_at_dock",
		"tutorial_give_seeds",
		"tutorial_about_planting",
		"tutorial_first_plant_complete",
		"tutorial_about_dashboard",
		"tutorial_complete"
	]

	for dialogue_key in required_dialogues:
		assert_true(
			dialogue_key in old_salt_data.dialogue_trees,
			"Old Salt should have '%s' dialogue" % dialogue_key
		)

		var dialogue = old_salt_data.dialogue_trees[dialogue_key]
		assert_has(dialogue, "text", "Dialogue '%s' should have text" % dialogue_key)
		assert_gt(
			dialogue["text"].length(),
			10,
			"Dialogue '%s' should have meaningful text" % dialogue_key
		)


func test_tutorial_system_has_old_salt_integration() -> void:
	"""Test that tutorial system has methods to interact with Old Salt"""
	assert_has_method(tutorial_system, "_trigger_old_salt_dialogue")
	assert_has_method(tutorial_system, "start_tutorial")
	assert_has_method(tutorial_system, "_show_current_step")


func test_tutorial_steps_defined() -> void:
	"""Test that all tutorial steps are defined"""
	var required_steps = [
		tutorial_system.TutorialStep.WELCOME,
		tutorial_system.TutorialStep.OPEN_JOURNAL,
		tutorial_system.TutorialStep.WALK_TO_DOCK,
		tutorial_system.TutorialStep.TALK_TO_OLD_SALT,
		tutorial_system.TutorialStep.OPEN_INVENTORY,
		tutorial_system.TutorialStep.EQUIP_AND_PLANT,
		tutorial_system.TutorialStep.CHECK_DASHBOARD,
		tutorial_system.TutorialStep.COMPLETE
	]

	for step in required_steps:
		assert_true(
			step in tutorial_system.step_objectives or step == tutorial_system.TutorialStep.COMPLETE,
			"Tutorial step %d should be defined" % step
		)


func test_tutorial_can_start() -> void:
	"""Test that tutorial can be started"""
	# Set GameManager to indicate tutorial not completed
	if GameManager:
		GameManager.tutorial_completed = false

	tutorial_system.start_tutorial()

	assert_true(tutorial_system.tutorial_active, "Tutorial should be active after starting")
	assert_eq(
		tutorial_system.current_step,
		tutorial_system.TutorialStep.WELCOME,
		"Tutorial should start at WELCOME step"
	)


func test_tutorial_dialogue_format() -> void:
	"""Test that Old Salt dialogue is in correct format"""
	for key in old_salt_data.dialogue_trees:
		var dialogue = old_salt_data.dialogue_trees[key]

		assert_typeof(dialogue, TYPE_DICTIONARY, "Dialogue should be a Dictionary")
		assert_has(dialogue, "text", "Dialogue should have 'text' field")
		assert_has(dialogue, "choices", "Dialogue should have 'choices' field")
		assert_typeof(dialogue["text"], TYPE_STRING, "Dialogue text should be a String")
		assert_typeof(dialogue["choices"], TYPE_ARRAY, "Dialogue choices should be an Array")


func test_old_salt_has_associated_quests() -> void:
	"""Test that Old Salt has associated tutorial quests"""
	assert_not_null(old_salt_data, "Old Salt data should exist")
	assert_has(old_salt_data, "associated_quests", "Old Salt should have associated_quests")

	var expected_quests = ["meet_old_salt", "first_planting"]
	for quest_id in expected_quests:
		assert_has(
			old_salt_data.associated_quests,
			quest_id,
			"Old Salt should have '%s' quest" % quest_id
		)
