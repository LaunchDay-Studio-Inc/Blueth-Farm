extends Node
## NPC Manager - Spawns and manages all NPCs in the game world
## Loads NPC resources and instantiates them at appropriate positions

signal all_npcs_spawned()

const NPC_SCENE = preload("res://scenes/entities/npc.tscn")

# NPC resource paths
const NPC_RESOURCES = [
	"res://resources/npcs/old_salt.tres",
	"res://resources/npcs/dr_marina.tres",
	"res://resources/npcs/mayor_hayes.tres",
	"res://resources/npcs/coral_reyes.tres",
	"res://resources/npcs/elder_tide.tres",
	"res://resources/npcs/chef_wave.tres"
]

var spawned_npcs: Array = []
var npcs_by_id: Dictionary = {}


func _ready() -> void:
	# Wait a frame for world to be ready
	await get_tree().process_frame
	_spawn_all_npcs()


func _spawn_all_npcs() -> void:
	"""Load and spawn all NPC resources"""
	print("NPCManager: Spawning NPCs...")
	
	for resource_path in NPC_RESOURCES:
		var npc_data = load(resource_path)
		if npc_data and npc_data is NPCData:
			_spawn_npc(npc_data)
		else:
			push_error("Failed to load NPC resource: " + resource_path)
	
	print("NPCManager: Spawned ", spawned_npcs.size(), " NPCs")
	all_npcs_spawned.emit()


func _spawn_npc(npc_data: NPCData) -> void:
	"""Spawn a single NPC in the world"""
	var npc_instance = NPC_SCENE.instantiate()
	
	# Set NPC data
	npc_instance.npc_data = npc_data
	
	# Set initial position (will be updated by schedule)
	npc_instance.global_position = _get_spawn_position(npc_data)
	
	# Add to scene tree
	add_child(npc_instance)
	
	# Track spawned NPC
	spawned_npcs.append(npc_instance)
	npcs_by_id[npc_data.npc_id] = npc_instance
	
	print("NPCManager: Spawned ", npc_data.display_name, " at ", npc_instance.global_position)


func _get_spawn_position(npc_data: NPCData) -> Vector2:
	"""Get initial spawn position for an NPC based on their zone"""
	# Get the NPC's current scheduled location
	var current_hour = 8  # Default spawn hour
	if TimeManager:
		current_hour = TimeManager.current_hour
	
	var location = npc_data.get_location_at_hour(current_hour)
	
	# Map locations to world positions
	# TODO: These should reference actual world locations/markers
	var location_positions = {
		"dock": Vector2(300, 200),
		"beach": Vector2(500, 400),
		"home": Vector2(700, 300),
		"market": Vector2(400, 500),
		"lab": Vector2(600, 200),
		"shallows": Vector2(450, 350),
		"town": Vector2(550, 250),
		"community_center": Vector2(650, 400)
	}
	
	return location_positions.get(location, Vector2(400, 300))


func get_npc_by_id(npc_id: String) -> Node:
	"""Get NPC node by their ID"""
	return npcs_by_id.get(npc_id, null)


func get_all_npcs() -> Array:
	"""Get array of all spawned NPC nodes"""
	return spawned_npcs


func get_npcs_at_location(location: String) -> Array:
	"""Get all NPCs currently at a specific location"""
	var npcs_at_location = []
	
	for npc in spawned_npcs:
		if npc and npc.npc_data:
			var current_hour = TimeManager.current_hour if TimeManager else 8
			var npc_location = npc.npc_data.get_location_at_hour(current_hour)
			if npc_location == location:
				npcs_at_location.append(npc)
	
	return npcs_at_location
