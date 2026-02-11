extends GutTest
## Test suite for JournalSystem and JournalUI save/load functionality
##
## Tests that journal entries and new-entry state are properly saved and restored

var journal_system: Node


func before_each():
	"""Set up before each test"""
	# Create a test journal system
	journal_system = Node.new()
	journal_system.set_script(load("res://scripts/npcs/journal_system.gd"))
	journal_system.add_to_group("journal_system")
	add_child_autofree(journal_system)

	# Register test entries
	_register_test_entries()


func _register_test_entries():
	"""Register journal entries for testing"""
	var JournalEntryClass = journal_system.get_script().JournalEntry

	# Entry 1 - unlocked at game start
	var entry1 = JournalEntryClass.new()
	entry1.entry_id = "test_entry_1"
	entry1.title = "First Entry"
	entry1.content = "This is the first test entry"
	entry1.unlock_condition = "game_start"
	entry1.research_point_bonus = 5
	entry1.unlocks = ""
	journal_system.register_entry(entry1)

	# Entry 2 - unlocked after first plant
	var entry2 = JournalEntryClass.new()
	entry2.entry_id = "test_entry_2"
	entry2.title = "Second Entry"
	entry2.content = "This is the second test entry"
	entry2.unlock_condition = "first_plant"
	entry2.research_point_bonus = 10
	entry2.unlocks = "recipe:kelp_salad"
	journal_system.register_entry(entry2)

	# Entry 3 - unlocked at year 3
	var entry3 = JournalEntryClass.new()
	entry3.entry_id = "test_entry_3"
	entry3.title = "Third Entry"
	entry3.content = "This is the third test entry"
	entry3.unlock_condition = "year_3"
	entry3.research_point_bonus = 15
	entry3.unlocks = ""
	journal_system.register_entry(entry3)


func test_save_discovered_entries():
	"""Test saving discovered journal entries"""
	# Unlock some entries
	journal_system.unlock_entry("test_entry_1")
	journal_system.unlock_entry("test_entry_2")

	# Get save data
	var save_data = journal_system.get_save_data()

	assert_has(save_data, "discovered_entries", "Save data should have discovered_entries")
	assert_eq(save_data["discovered_entries"].size(), 2, "Should have 2 discovered entries")
	assert_true("test_entry_1" in save_data["discovered_entries"], "Should include test_entry_1")
	assert_true("test_entry_2" in save_data["discovered_entries"], "Should include test_entry_2")
	assert_false("test_entry_3" in save_data["discovered_entries"], "Should not include test_entry_3")


func test_load_discovered_entries():
	"""Test loading discovered journal entries"""
	# Create save data with discovered entries
	var save_data = {
		"discovered_entries": ["test_entry_1", "test_entry_3"]
	}

	# Load the data
	journal_system.load_save_data(save_data)

	# Verify entries were loaded
	assert_true(journal_system.is_entry_discovered("test_entry_1"), "test_entry_1 should be discovered")
	assert_false(journal_system.is_entry_discovered("test_entry_2"), "test_entry_2 should not be discovered")
	assert_true(journal_system.is_entry_discovered("test_entry_3"), "test_entry_3 should be discovered")

	# Verify discovered_entries array
	var discovered = journal_system.get_discovered_entries()
	assert_eq(discovered.size(), 2, "Should have 2 discovered entries")
	assert_true("test_entry_1" in discovered, "Should include test_entry_1")
	assert_true("test_entry_3" in discovered, "Should include test_entry_3")


func test_load_marks_entries_as_discovered():
	"""Test that loading marks entries as discovered in the entry objects"""
	# Create save data
	var save_data = {
		"discovered_entries": ["test_entry_2"]
	}

	# Load the data
	journal_system.load_save_data(save_data)

	# Verify entry objects are marked as discovered
	var entry1 = journal_system.get_entry("test_entry_1")
	var entry2 = journal_system.get_entry("test_entry_2")
	var entry3 = journal_system.get_entry("test_entry_3")

	assert_false(entry1.discovered, "Entry 1 should not be marked as discovered")
	assert_true(entry2.discovered, "Entry 2 should be marked as discovered")
	assert_false(entry3.discovered, "Entry 3 should not be marked as discovered")


func test_save_load_roundtrip():
	"""Test that saving and loading preserves all journal data"""
	# Unlock some entries
	journal_system.unlock_entry("test_entry_1")
	journal_system.unlock_entry("test_entry_2")

	# Get save data
	var save_data = journal_system.get_save_data()

	# Create a new journal system and load the data
	var new_journal_system = Node.new()
	new_journal_system.set_script(load("res://scripts/npcs/journal_system.gd"))
	add_child_autofree(new_journal_system)

	# Register the same test entries
	var JournalEntryClass = new_journal_system.get_script().JournalEntry

	var entry1 = JournalEntryClass.new()
	entry1.entry_id = "test_entry_1"
	entry1.title = "First Entry"
	entry1.content = "This is the first test entry"
	entry1.unlock_condition = "game_start"
	new_journal_system.register_entry(entry1)

	var entry2 = JournalEntryClass.new()
	entry2.entry_id = "test_entry_2"
	entry2.title = "Second Entry"
	entry2.content = "This is the second test entry"
	entry2.unlock_condition = "first_plant"
	new_journal_system.register_entry(entry2)

	var entry3 = JournalEntryClass.new()
	entry3.entry_id = "test_entry_3"
	entry3.title = "Third Entry"
	entry3.content = "This is the third test entry"
	entry3.unlock_condition = "year_3"
	new_journal_system.register_entry(entry3)

	# Load the saved data
	new_journal_system.load_save_data(save_data)

	# Verify discovered entries
	assert_true(new_journal_system.is_entry_discovered("test_entry_1"), "Should restore test_entry_1")
	assert_true(new_journal_system.is_entry_discovered("test_entry_2"), "Should restore test_entry_2")
	assert_false(new_journal_system.is_entry_discovered("test_entry_3"), "Should not restore test_entry_3")

	var discovered = new_journal_system.get_discovered_entries()
	assert_eq(discovered.size(), 2, "Should have 2 discovered entries")


func test_load_empty_save_data():
	"""Test loading empty save data doesn't crash"""
	var save_data = {
		"discovered_entries": []
	}

	journal_system.load_save_data(save_data)

	assert_eq(journal_system.get_discovered_entries().size(), 0, "Should have no discovered entries")


func test_load_missing_fields():
	"""Test loading save data with missing fields uses defaults"""
	var save_data = {}

	journal_system.load_save_data(save_data)

	# Should use defaults without crashing
	assert_eq(journal_system.get_discovered_entries().size(), 0, "Should default to empty discovered entries")


func test_journal_ui_save_new_entries():
	"""Test that JournalUI saves new entries state"""
	# Create a mock JournalUI
	var journal_ui = CanvasLayer.new()
	journal_ui.set_script(load("res://scripts/ui/journal_controller.gd"))
	add_child_autofree(journal_ui)

	# Manually set new entries (simulating unlocked but unread entries)
	journal_ui._new_entries = ["test_entry_1", "test_entry_2"]

	# Get save data
	var save_data = journal_ui.get_save_data()

	assert_has(save_data, "new_entries", "Save data should have new_entries")
	assert_eq(save_data["new_entries"].size(), 2, "Should have 2 new entries")
	assert_true("test_entry_1" in save_data["new_entries"], "Should include test_entry_1")
	assert_true("test_entry_2" in save_data["new_entries"], "Should include test_entry_2")


func test_journal_ui_load_new_entries():
	"""Test that JournalUI loads new entries state"""
	# Create a mock JournalUI
	var journal_ui = CanvasLayer.new()
	journal_ui.set_script(load("res://scripts/ui/journal_controller.gd"))
	add_child_autofree(journal_ui)

	# Load save data
	var save_data = {
		"new_entries": ["test_entry_3"]
	}

	journal_ui.load_save_data(save_data)

	# Verify new entries were loaded
	assert_eq(journal_ui._new_entries.size(), 1, "Should have 1 new entry")
	assert_true("test_entry_3" in journal_ui._new_entries, "Should include test_entry_3")


func test_journal_ui_empty_new_entries():
	"""Test JournalUI with empty new entries"""
	var journal_ui = CanvasLayer.new()
	journal_ui.set_script(load("res://scripts/ui/journal_controller.gd"))
	add_child_autofree(journal_ui)

	# Load empty save data
	var save_data = {
		"new_entries": []
	}

	journal_ui.load_save_data(save_data)

	assert_eq(journal_ui._new_entries.size(), 0, "Should have no new entries")


func test_journal_ui_missing_fields():
	"""Test JournalUI loading with missing fields uses defaults"""
	var journal_ui = CanvasLayer.new()
	journal_ui.set_script(load("res://scripts/ui/journal_controller.gd"))
	add_child_autofree(journal_ui)

	# Load empty save data
	var save_data = {}

	journal_ui.load_save_data(save_data)

	# Should use defaults without crashing
	assert_eq(journal_ui._new_entries.size(), 0, "Should default to empty new entries")
