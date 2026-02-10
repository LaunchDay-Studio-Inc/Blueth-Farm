extends Node
class_name WildlifeSpawner
## Wildlife spawning system based on ecosystem health

signal wildlife_spawned(wildlife_type: String)
signal first_sighting(wildlife_type: String)

# Wildlife spawn requirements
const WILDLIFE_REQUIREMENTS: Dictionary = {
	"fish": {"plants": 10, "biodiversity": 15, "zones": ["shallows", "reef_edge"]},
	"crab": {"plants": 5, "biodiversity": 10, "zones": ["mudflats"]},
	"bird": {"plants": 15, "biodiversity": 20, "zones": ["mudflats", "shallows"]},
	"turtle": {"plants": 20, "biodiversity": 40, "zones": ["shallows"], "species": ["seagrass"]},
	"dolphin": {"plants": 50, "biodiversity": 60, "zones": ["shallows", "reef_edge"]},
	"manatee": {"plants": 30, "biodiversity": 50, "zones": ["shallows"], "species": ["seagrass"]}
}

var spawned_wildlife: Dictionary = {}  # wildlife_type -> count
var first_sightings: Array[String] = []  # wildlife types seen for first time
var last_spawn_day: int = 0


func _ready() -> void:
	# Connect to daily updates
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)


func _on_day_changed(day: int) -> void:
	"""Check for wildlife spawning each day"""
	# Spawn check every few days to avoid spam
	if day - last_spawn_day < 3:
		return
	
	last_spawn_day = day
	check_spawn_conditions()


func check_spawn_conditions() -> void:
	"""Check if conditions are met for wildlife spawning"""
	if not EcosystemManager:
		return
	
	var biodiversity = EcosystemManager.get_biodiversity_score()
	var planted_tiles = EcosystemManager.get_total_planted_tiles()
	
	for wildlife_type in WILDLIFE_REQUIREMENTS.keys():
		var req = WILDLIFE_REQUIREMENTS[wildlife_type]
		
		# Check if requirements are met
		if planted_tiles >= req.plants and biodiversity >= req.biodiversity:
			# Random chance to spawn (30% per check)
			if randf() < 0.3:
				spawn_wildlife(wildlife_type)


func spawn_wildlife(wildlife_type: String) -> void:
	"""Spawn a wildlife instance"""
	# Increment count
	if wildlife_type not in spawned_wildlife:
		spawned_wildlife[wildlife_type] = 0
	
	spawned_wildlife[wildlife_type] += 1
	
	# Check for first sighting
	var is_first_sighting = wildlife_type not in first_sightings
	if is_first_sighting:
		first_sightings.append(wildlife_type)
		first_sighting.emit(wildlife_type)
		show_first_sighting_celebration(wildlife_type)
	
	# Emit spawn signal
	wildlife_spawned.emit(wildlife_type)
	
	# Award research points for first sighting
	if is_first_sighting and GameManager:
		GameManager.add_research_points(10)
	
	print("🐟 Wildlife spawned: ", wildlife_type, " (Total: ", spawned_wildlife[wildlife_type], ")")


func show_first_sighting_celebration(wildlife_type: String) -> void:
	"""Show celebration notification for first wildlife sighting"""
	var messages = {
		"fish": "🐟 First Sighting: Small Fish! Your seagrass meadows are attracting marine life!",
		"crab": "🦀 First Sighting: Fiddler Crab! The mudflats are coming alive!",
		"bird": "🦅 First Sighting: Shorebird! Birds are returning to feast on the restored ecosystem!",
		"turtle": "🐢 First Sighting: Sea Turtle! These endangered creatures are using your seagrass beds!",
		"dolphin": "🐬 First Sighting: Bottlenose Dolphin! The bay is healthy enough for dolphins to return!",
		"manatee": "🦛 First Sighting: Manatee! These gentle giants have found sanctuary in your restoration!"
	}
	
	var message = messages.get(wildlife_type, "New wildlife spotted!")
	print("\n⭐ ", message, " ⭐\n")
	
	# TODO: Show UI notification when notification system is implemented


func get_wildlife_count(wildlife_type: String) -> int:
	"""Get count of a specific wildlife type"""
	return spawned_wildlife.get(wildlife_type, 0)


func has_seen_wildlife(wildlife_type: String) -> bool:
	"""Check if wildlife type has been seen"""
	return wildlife_type in first_sightings


func get_discovered_wildlife() -> Array:
	"""Get list of all discovered wildlife types"""
	return first_sightings.duplicate()


func get_total_wildlife_types() -> int:
	"""Get count of different wildlife types discovered"""
	return first_sightings.size()


func get_wildlife_diversity_bonus() -> float:
	"""Get biodiversity bonus from wildlife variety"""
	# Each wildlife type adds 0.05 to diversity
	return first_sightings.size() * 0.05


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	return {
		"spawned_wildlife": spawned_wildlife,
		"first_sightings": first_sightings,
		"last_spawn_day": last_spawn_day
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	spawned_wildlife = data.get("spawned_wildlife", {})
	first_sightings = data.get("first_sightings", [])
	last_spawn_day = data.get("last_spawn_day", 0)
