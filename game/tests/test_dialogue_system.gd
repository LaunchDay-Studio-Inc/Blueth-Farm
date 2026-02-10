extends GutTest
## Unit tests for DialogueSystem
## Tests dialogue tree navigation, choice handling, and state management


var dialogue_system: Node


func before_each():
	"""Set up DialogueSystem before each test"""
	# Get or create DialogueSystem instance
	if has_node("/root/DialogueSystem"):
		dialogue_system = get_node("/root/DialogueSystem")
	else:
		# Create a temporary instance for testing
		var DialogueSystemScript = load("res://scripts/npcs/dialogue_system.gd")
		dialogue_system = DialogueSystemScript.new()
		add_child(dialogue_system)


func after_each():
	"""Clean up after each test"""
	if dialogue_system and not dialogue_system.is_queued_for_deletion():
		if not has_node("/root/DialogueSystem"):
			dialogue_system.queue_free()


func test_dialogue_starts_at_start_node():
	"""Test that dialogue begins at 'start' node"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Hello!",
			"choices": [
				{"text": "Continue", "next": "end"}
			]
		}
	}

	dialogue_system.start_dialogue(test_tree)
	assert_eq(dialogue_system.current_node_id, "start", "Should start at 'start' node")


func test_dialogue_emits_started_signal():
	"""Test that dialogue_started signal is emitted with correct data"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Hello there!",
			"choices": [
				{"text": "Continue", "next": "end"}
			]
		}
	}

	watch_signals(dialogue_system)
	dialogue_system.start_dialogue(test_tree)

	assert_signal_emitted(dialogue_system, "dialogue_started",
		"dialogue_started signal should be emitted")


func test_advance_dialogue_with_valid_choice():
	"""Test advancing dialogue with a valid choice index"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Choose wisely!",
			"choices": [
				{"text": "Option A", "next": "node_a"},
				{"text": "Option B", "next": "end"}
			]
		},
		"node_a": {
			"speaker": "TestNPC",
			"text": "You chose A!",
			"choices": [
				{"text": "Done", "next": "end"}
			]
		}
	}

	dialogue_system.start_dialogue(test_tree)
	assert_eq(dialogue_system.current_node_id, "start")

	dialogue_system.advance_dialogue(0)
	assert_eq(dialogue_system.current_node_id, "node_a",
		"Should advance to node_a")


func test_advance_dialogue_to_end():
	"""Test that advancing to 'end' terminates dialogue"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Goodbye!",
			"choices": [
				{"text": "Leave", "next": "end"}
			]
		}
	}

	dialogue_system.start_dialogue(test_tree)
	watch_signals(dialogue_system)
	dialogue_system.advance_dialogue(0)

	assert_signal_emitted(dialogue_system, "dialogue_ended",
		"dialogue_ended signal should be emitted")
	assert_true(dialogue_system.current_node_id.is_empty(),
		"Current node should be empty after ending")


func test_branching_dialogue_tree():
	"""Test multi-branch dialogue navigation"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "What do you want?",
			"choices": [
				{"text": "Trade", "next": "trade"},
				{"text": "Chat", "next": "chat"}
			]
		},
		"trade": {
			"speaker": "TestNPC",
			"text": "I have goods!",
			"choices": [
				{"text": "Done", "next": "end"}
			]
		},
		"chat": {
			"speaker": "TestNPC",
			"text": "Nice weather!",
			"choices": [
				{"text": "Done", "next": "end"}
			]
		}
	}

	# Test trade branch
	dialogue_system.start_dialogue(test_tree)
	dialogue_system.advance_dialogue(0)  # Choose "Trade"
	assert_eq(dialogue_system.current_node_id, "trade")

	# Reset and test chat branch
	dialogue_system.start_dialogue(test_tree)
	dialogue_system.advance_dialogue(1)  # Choose "Chat"
	assert_eq(dialogue_system.current_node_id, "chat")


func test_is_dialogue_active():
	"""Test dialogue active state tracking"""
	assert_false(dialogue_system.is_dialogue_active(),
		"Dialogue should not be active initially")

	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Hello!",
			"choices": [
				{"text": "Hi", "next": "end"}
			]
		}
	}

	dialogue_system.start_dialogue(test_tree)
	assert_true(dialogue_system.is_dialogue_active(),
		"Dialogue should be active after starting")

	dialogue_system.advance_dialogue(0)
	assert_false(dialogue_system.is_dialogue_active(),
		"Dialogue should not be active after ending")


func test_choices_presented_signal():
	"""Test that dialogue_choices_presented signal emits choices"""
	var test_tree = {
		"start": {
			"speaker": "TestNPC",
			"text": "Choose!",
			"choices": [
				{"text": "A", "next": "end"},
				{"text": "B", "next": "end"}
			]
		}
	}

	watch_signals(dialogue_system)
	dialogue_system.start_dialogue(test_tree)

	assert_signal_emitted(dialogue_system, "dialogue_choices_presented",
		"dialogue_choices_presented signal should be emitted")
