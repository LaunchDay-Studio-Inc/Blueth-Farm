extends Node
class_name NurserySystem
## Seedling nursery system for protected, faster growth

signal seedling_added(species: String)
signal seedling_ready(species: String, index: int)
signal nursery_full()

# Nursery configuration
const BASE_CAPACITY: int = 10
const GROWTH_SPEED_MULTIPLIER: float = 0.5  # 50% faster growth in nursery
const TRANSPLANT_SURVIVAL_BONUS: float = 0.25  # +25% survival rate

# Seedling data structure
class Seedling:
	var species_id: String
	var days_growing: int = 0
	var ready_to_transplant: bool = false
	var growth_stage: int = 0
	var target_stage: int = 1  # Sprout stage before transplanting
	
	func _init(p_species: String):
		species_id = p_species

var nursery_slots: Array[Seedling] = []
var max_capacity: int = BASE_CAPACITY
var is_unlocked: bool = false


func _ready() -> void:
	# Connect to TimeManager for daily growth
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)


func unlock_nursery() -> void:
	"""Unlock the nursery system"""
	is_unlocked = true
	print("🌱 Nursery System Unlocked!")


func can_add_seedling() -> bool:
	"""Check if nursery has space for a new seedling"""
	if not is_unlocked:
		return false
	return nursery_slots.size() < max_capacity


func add_seedling(species_id: String) -> bool:
	"""Add a seed to the nursery"""
	if not can_add_seedling():
		nursery_full.emit()
		return false
	
	var seedling = Seedling.new(species_id)
	nursery_slots.append(seedling)
	
	seedling_added.emit(species_id)
	print("🌱 Seedling added to nursery: ", species_id)
	
	return true


func _on_day_changed(_day: int) -> void:
	"""Process daily growth for all seedlings"""
	if not is_unlocked:
		return
	
	for i in range(nursery_slots.size()):
		var seedling = nursery_slots[i]
		
		# Grow seedling (faster than normal)
		seedling.days_growing += 1
		
		# Check if ready to transplant (reached sprout stage)
		# This would need species data to get accurate growth rates
		# For now, use simplified logic: ready after 5 days
		if seedling.days_growing >= 5 and not seedling.ready_to_transplant:
			seedling.ready_to_transplant = true
			seedling.growth_stage = 1  # Sprout
			seedling_ready.emit(seedling.species_id, i)
			print("🌱 Seedling ready for transplant: ", seedling.species_id)


func transplant_seedling(index: int) -> Dictionary:
	"""Remove a seedling from nursery and prepare it for planting"""
	if index < 0 or index >= nursery_slots.size():
		return {}
	
	var seedling = nursery_slots[index]
	
	if not seedling.ready_to_transplant:
		return {}
	
	# Create seedling data for planting
	var seedling_data = {
		"species_id": seedling.species_id,
		"growth_stage": seedling.growth_stage,
		"survival_bonus": TRANSPLANT_SURVIVAL_BONUS,
		"from_nursery": true
	}
	
	# Remove from nursery
	nursery_slots.remove_at(index)
	
	print("🌱 Seedling transplanted: ", seedling.species_id)
	
	return seedling_data


func get_seedling_info(index: int) -> Dictionary:
	"""Get information about a specific seedling"""
	if index < 0 or index >= nursery_slots.size():
		return {}
	
	var seedling = nursery_slots[index]
	
	return {
		"species_id": seedling.species_id,
		"days_growing": seedling.days_growing,
		"ready": seedling.ready_to_transplant,
		"growth_stage": seedling.growth_stage
	}


func get_all_seedlings() -> Array:
	"""Get information about all seedlings"""
	var seedlings_info = []
	for i in range(nursery_slots.size()):
		seedlings_info.append(get_seedling_info(i))
	return seedlings_info


func get_available_slots() -> int:
	"""Get number of available nursery slots"""
	return max_capacity - nursery_slots.size()


func get_ready_count() -> int:
	"""Get count of seedlings ready for transplant"""
	var count = 0
	for seedling in nursery_slots:
		if seedling.ready_to_transplant:
			count += 1
	return count


func upgrade_capacity(additional_slots: int) -> void:
	"""Upgrade nursery capacity"""
	max_capacity += additional_slots
	print("🌱 Nursery capacity increased to: ", max_capacity)


func is_nursery_unlocked() -> bool:
	"""Check if nursery is unlocked"""
	return is_unlocked


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	var seedlings_data = []
	for seedling in nursery_slots:
		seedlings_data.append({
			"species_id": seedling.species_id,
			"days_growing": seedling.days_growing,
			"ready_to_transplant": seedling.ready_to_transplant,
			"growth_stage": seedling.growth_stage
		})
	
	return {
		"is_unlocked": is_unlocked,
		"max_capacity": max_capacity,
		"seedlings": seedlings_data
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	is_unlocked = data.get("is_unlocked", false)
	max_capacity = data.get("max_capacity", BASE_CAPACITY)
	
	nursery_slots.clear()
	var seedlings_data = data.get("seedlings", [])
	for seedling_data in seedlings_data:
		var seedling = Seedling.new(seedling_data.get("species_id", ""))
		seedling.days_growing = seedling_data.get("days_growing", 0)
		seedling.ready_to_transplant = seedling_data.get("ready_to_transplant", false)
		seedling.growth_stage = seedling_data.get("growth_stage", 0)
		nursery_slots.append(seedling)
