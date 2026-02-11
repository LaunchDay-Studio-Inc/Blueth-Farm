extends Node
## Save and load game system
## Manages save slots and game state persistence

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(error: String)

const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_slot_"
const SAVE_FILE_EXTENSION = ".json"
const AUTO_SAVE_SLOT = 0
const MAX_SAVE_SLOTS = 3

var autosave_enabled: bool = true


func _ready() -> void:
	print("SaveManager initialized")
	# Create save directory if it doesn't exist
	_ensure_save_directory()
	
	# Connect to day change for autosave
	if autosave_enabled:
		TimeManager.day_changed.connect(_on_day_changed)


func _ensure_save_directory() -> void:
	"""Create save directory if it doesn't exist"""
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
		print("Created save directory at: ", SAVE_DIR)


func _on_day_changed(day: int) -> void:
	"""Auto-save when a new day starts"""
	if autosave_enabled:
		save_game(AUTO_SAVE_SLOT)


func save_game(slot: int = 1) -> bool:
	"""Save the current game state to a slot"""
	print("Saving game to slot ", slot, "...")
	
	var save_data = _collect_save_data()
	save_data["slot"] = slot
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["version"] = "1.0"
	
	var file_path = _get_save_file_path(slot)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		var error = "Failed to open save file: " + file_path
		print(error)
		save_failed.emit(error)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Game saved successfully to slot ", slot)
	save_completed.emit(slot)
	return true


func load_game(slot: int = 1) -> bool:
	"""Load game state from a slot"""
	print("Loading game from slot ", slot, "...")
	
	var file_path = _get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		var error = "Save file not found: " + file_path
		print(error)
		save_failed.emit(error)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		var error = "Failed to open save file: " + file_path
		print(error)
		save_failed.emit(error)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		var error = "Failed to parse save file JSON"
		print(error)
		save_failed.emit(error)
		return false
	
	var save_data = json.data
	_apply_save_data(save_data)
	
	print("Game loaded successfully from slot ", slot)
	load_completed.emit(slot)
	return true


func _collect_save_data() -> Dictionary:
	"""Collect all game state data from managers"""
	var data = {
		"game_manager": GameManager.get_save_data(),
		"time_manager": TimeManager.get_save_data(),
		"carbon_manager": CarbonManager.get_save_data(),
		"ecosystem_manager": EcosystemManager.get_save_data(),
	}

	# Get Player data if it exists in the scene tree
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_save_data"):
		data["player"] = player.get_save_data()

		# Also get player inventory data
		var player_inventory = player.get_node_or_null("PlayerInventory")
		if player_inventory and player_inventory.has_method("get_save_data"):
			data["player_inventory"] = player_inventory.get_save_data()

	# Get QuestSystem data if it exists in the scene tree
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	if quest_system and quest_system.has_method("get_save_data"):
		data["quest_system"] = quest_system.get_save_data()

	# Get RelationshipSystem data if it exists in the scene tree
	var relationship_system = get_tree().get_first_node_in_group("relationship_system")
	if relationship_system and relationship_system.has_method("get_save_data"):
		data["relationship_system"] = relationship_system.get_save_data()

	# Get TileMapManager data if it exists in the scene tree
	var tile_map_manager = get_tree().get_first_node_in_group("tile_map_manager")
	if tile_map_manager and tile_map_manager.has_method("get_save_data"):
		data["tile_map_manager"] = tile_map_manager.get_save_data()

	# Get JournalSystem data if it exists in the scene tree
	var journal_system = get_tree().get_first_node_in_group("journal_system")
	if journal_system and journal_system.has_method("get_save_data"):
		data["journal_system"] = journal_system.get_save_data()

	# Get JournalUI data if it exists in the scene tree
	var journal_ui = get_tree().get_first_node_in_group("journal_ui")
	if journal_ui and journal_ui.has_method("get_save_data"):
		data["journal_ui"] = journal_ui.get_save_data()

	return data


func _apply_save_data(data: Dictionary) -> void:
	"""Apply loaded data to all managers"""
	if "game_manager" in data:
		GameManager.load_save_data(data.game_manager)

	if "time_manager" in data:
		TimeManager.load_save_data(data.time_manager)

	if "carbon_manager" in data:
		CarbonManager.load_save_data(data.carbon_manager)

	if "ecosystem_manager" in data:
		EcosystemManager.load_save_data(data.ecosystem_manager)

	# Apply Player data if it exists in the scene tree
	if "player" in data:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("load_save_data"):
			player.load_save_data(data.player)

	# Apply Player Inventory data if it exists in the scene tree
	if "player_inventory" in data:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var player_inventory = player.get_node_or_null("PlayerInventory")
			if player_inventory and player_inventory.has_method("load_save_data"):
				player_inventory.load_save_data(data.player_inventory)

	# Apply QuestSystem data if it exists in the scene tree
	if "quest_system" in data:
		var quest_system = get_tree().get_first_node_in_group("quest_system")
		if quest_system and quest_system.has_method("load_save_data"):
			quest_system.load_save_data(data.quest_system)

	# Apply RelationshipSystem data if it exists in the scene tree
	if "relationship_system" in data:
		var relationship_system = get_tree().get_first_node_in_group("relationship_system")
		if relationship_system and relationship_system.has_method("load_save_data"):
			relationship_system.load_save_data(data.relationship_system)

	# Apply TileMapManager data if it exists in the scene tree
	if "tile_map_manager" in data:
		var tile_map_manager = get_tree().get_first_node_in_group("tile_map_manager")
		if tile_map_manager and tile_map_manager.has_method("load_save_data"):
			tile_map_manager.load_save_data(data.tile_map_manager)

	# Apply JournalSystem data if it exists in the scene tree
	if "journal_system" in data:
		var journal_system = get_tree().get_first_node_in_group("journal_system")
		if journal_system and journal_system.has_method("load_save_data"):
			journal_system.load_save_data(data.journal_system)

	# Apply JournalUI data if it exists in the scene tree
	if "journal_ui" in data:
		var journal_ui = get_tree().get_first_node_in_group("journal_ui")
		if journal_ui and journal_ui.has_method("load_save_data"):
			journal_ui.load_save_data(data.journal_ui)


func _get_save_file_path(slot: int) -> String:
	"""Get the file path for a save slot"""
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION


func delete_save(slot: int) -> bool:
	"""Delete a save slot"""
	var file_path = _get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		print("No save file to delete at slot ", slot)
		return false
	
	var dir = DirAccess.open(SAVE_DIR)
	var error = dir.remove(file_path)
	
	if error == OK:
		print("Deleted save slot ", slot)
		return true
	else:
		print("Failed to delete save slot ", slot)
		return false


func save_exists(slot: int) -> bool:
	"""Check if a save file exists for a slot"""
	return FileAccess.file_exists(_get_save_file_path(slot))


func get_save_info(slot: int) -> Dictionary:
	"""Get information about a save slot"""
	if not save_exists(slot):
		return {}
	
	var file_path = _get_save_file_path(slot)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return {}
	
	var data = json.data
	
	# Extract key info
	var info = {
		"slot": slot,
		"timestamp": data.get("timestamp", 0),
		"version": data.get("version", "unknown")
	}
	
	if "game_manager" in data:
		info["year"] = data.game_manager.get("current_year", 1)
		info["gold"] = data.game_manager.get("gold", 0)
	
	if "time_manager" in data:
		info["day"] = data.time_manager.get("current_day", 1)
		info["season"] = data.time_manager.get("current_season", 0)
	
	if "carbon_manager" in data:
		info["total_carbon"] = data.carbon_manager.get("total_co2_sequestered", 0.0)
	
	return info


func get_all_save_info() -> Array:
	"""Get info for all save slots"""
	var saves = []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var info = get_save_info(slot)
		if not info.is_empty():
			saves.append(info)
	return saves
