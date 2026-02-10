extends Node
## Core planting mechanics system
## Handles planting validation and species placement

signal plant_placed(tile_pos: Vector2i, species_key: String)
signal plant_failed(reason: String)

@export var tile_map_manager: TileMapManager
@export var player_inventory: Node


func can_plant_at(tile_pos: Vector2i, species_key: String) -> bool:
	"""Check if a species can be planted at the given tile position"""
	# Get tile data
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if tile == null:
		return false
	
	# Check if tile is already planted
	if tile.is_planted:
		return false
	
	# Load species data to check requirements
	var species_data = _load_species_data(species_key)
	if species_data == null:
		print("Warning: Species data not found for: ", species_key)
		return false
	
	# Calculate actual water depth with tide
	var actual_depth = tile.water_depth + tile_map_manager.current_tide_offset
	
	# Check compatibility using species requirements
	if not species_data.is_compatible_with_tile(actual_depth, tile.salinity, TileMapManager.SubstrateType.keys()[tile.substrate_type].to_lower()):
		return false
	
	return true


func plant_species(tile_pos: Vector2i, species_key: String) -> bool:
	"""Plant a species at the given tile position"""
	# Validate planting
	if not can_plant_at(tile_pos, species_key):
		plant_failed.emit("Invalid planting location")
		return false
	
	# Check if player has seeds
	var seed_item_name = species_key + "_seed"
	if player_inventory and not player_inventory.has_item(seed_item_name, 1):
		plant_failed.emit("No seeds available")
		return false
	
	# Deduct seed from inventory
	if player_inventory:
		player_inventory.remove_item(seed_item_name, 1)
	
	# Plant the species using TileMapManager
	if tile_map_manager.plant_species(tile_pos, species_key):
		# Show planting effect (placeholder for future particle effects)
		_show_planting_effect(tile_pos)
		
		# Emit success signal
		plant_placed.emit(tile_pos, species_key)
		
		print("Successfully planted ", species_key, " at ", tile_pos)
		return true
	
	# If planting failed, refund the seed
	if player_inventory:
		player_inventory.add_item(seed_item_name, 1)
	
	plant_failed.emit("Planting failed")
	return false


func _load_species_data(species_key: String) -> SpeciesData:
	"""Load species data resource"""
	var resource_path = "res://game/data/species/" + species_key + ".tres"
	if ResourceLoader.exists(resource_path):
		return load(resource_path) as SpeciesData
	return null


func _show_planting_effect(tile_pos: Vector2i) -> void:
	"""Visual feedback for planting (placeholder)"""
	# TODO: Spawn particle effect or animation
	pass


func get_planting_incompatibility_reason(tile_pos: Vector2i, species_key: String) -> String:
	"""Get detailed reason why planting is not possible"""
	var tile = tile_map_manager.get_tile_at(tile_pos)
	if tile == null:
		return "Invalid tile position"
	
	if tile.is_planted:
		return "Tile already planted"
	
	var species_data = _load_species_data(species_key)
	if species_data == null:
		return "Unknown species"
	
	var actual_depth = tile.water_depth + tile_map_manager.current_tide_offset
	
	# Check depth
	if actual_depth < species_data.preferred_depth_min:
		return "Water too shallow (%.1fm, needs %.1f-%.1fm)" % [actual_depth, species_data.preferred_depth_min, species_data.preferred_depth_max]
	if actual_depth > species_data.preferred_depth_max:
		return "Water too deep (%.1fm, needs %.1f-%.1fm)" % [actual_depth, species_data.preferred_depth_min, species_data.preferred_depth_max]
	
	# Check salinity
	if abs(tile.salinity - species_data.preferred_salinity) > species_data.salinity_tolerance:
		return "Salinity incompatible (%.1f ppt, needs %.1f ± %.1f ppt)" % [tile.salinity, species_data.preferred_salinity, species_data.salinity_tolerance]
	
	# Check substrate
	var substrate_name = TileMapManager.SubstrateType.keys()[tile.substrate_type].to_lower()
	if substrate_name != species_data.preferred_substrate:
		return "Wrong substrate (%s, needs %s)" % [substrate_name, species_data.preferred_substrate]
	
	return "Unknown incompatibility"
