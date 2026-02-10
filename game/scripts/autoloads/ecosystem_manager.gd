extends Node
## Ecosystem and biodiversity management
## Tracks species diversity, wildlife, and ecosystem health

signal biodiversity_changed(score: float)
signal wildlife_spawned(species: String)
signal ecosystem_health_changed(health: float)
signal species_discovered(species_name: String)

# Biodiversity tracking
var planted_species: Dictionary = {}  # species_key -> count
var discovered_species: Array[String] = []
var biodiversity_score: float = 0.0  # 0-100 scale
var ecosystem_health: float = 50.0  # 0-100 scale

# Wildlife populations
var wildlife_populations: Dictionary = {
	"fish_small": 0,
	"fish_large": 0,
	"crab": 0,
	"shorebird": 0,
	"wadingbird": 0,
	"turtle": 0,
	"dolphin": 0,
	"manatee": 0
}

# Species requirements for wildlife
var wildlife_requirements: Dictionary = {
	"fish_small": {"min_biodiversity": 10, "required_coverage": 5, "species": ["seagrass"]},
	"fish_large": {"min_biodiversity": 20, "required_coverage": 10, "species": ["seagrass", "kelp"]},
	"crab": {"min_biodiversity": 15, "required_coverage": 5, "species": ["salt_marsh", "mangrove"]},
	"shorebird": {"min_biodiversity": 25, "required_coverage": 8, "species": ["salt_marsh"]},
	"wadingbird": {"min_biodiversity": 30, "required_coverage": 10, "species": ["salt_marsh", "mangrove"]},
	"turtle": {"min_biodiversity": 40, "required_coverage": 15, "species": ["seagrass"]},
	"dolphin": {"min_biodiversity": 60, "required_coverage": 20, "species": ["seagrass", "kelp"]},
	"manatee": {"min_biodiversity": 50, "required_coverage": 15, "species": ["seagrass"]}
}

# Food web tracking
var food_web_balance: float = 0.5  # 0-1 scale, 0.5 is balanced

# Coverage tracking
var total_planted_tiles: int = 0


func _ready() -> void:
	print("EcosystemManager initialized")


func register_planted_species(species_key: String) -> void:
	"""Register a newly planted species"""
	if species_key not in planted_species:
		planted_species[species_key] = 0
	planted_species[species_key] += 1
	total_planted_tiles += 1
	
	# Check if this is a new species discovery
	if species_key not in discovered_species:
		discovered_species.append(species_key)
		species_discovered.emit(species_key)
		print("New species discovered: ", species_key)
	
	_update_biodiversity()
	_check_wildlife_spawning()


func unregister_planted_species(species_key: String) -> void:
	"""Unregister a removed plant"""
	if species_key in planted_species and planted_species[species_key] > 0:
		planted_species[species_key] -= 1
		total_planted_tiles = max(0, total_planted_tiles - 1)
		_update_biodiversity()


func _update_biodiversity() -> void:
	"""Calculate biodiversity score using Shannon diversity index"""
	if total_planted_tiles == 0:
		biodiversity_score = 0.0
		biodiversity_changed.emit(biodiversity_score)
		return
	
	# Shannon diversity index calculation
	var shannon_index: float = 0.0
	for species_key in planted_species:
		var count = planted_species[species_key]
		if count > 0:
			var proportion = float(count) / float(total_planted_tiles)
			shannon_index -= proportion * log(proportion)
	
	# Normalize to 0-100 scale (max Shannon for 9 species ~= 2.2)
	biodiversity_score = (shannon_index / 2.2) * 100.0
	biodiversity_score = clamp(biodiversity_score, 0.0, 100.0)
	
	# Add bonus for total coverage
	var coverage_bonus = min(total_planted_tiles / 100.0, 1.0) * 20.0
	biodiversity_score = min(biodiversity_score + coverage_bonus, 100.0)
	
	biodiversity_changed.emit(biodiversity_score)
	
	# Update ecosystem health based on biodiversity
	_update_ecosystem_health()


func _update_ecosystem_health() -> void:
	"""Calculate overall ecosystem health"""
	# Base health from biodiversity
	var health = biodiversity_score * 0.6
	
	# Add food web balance component
	health += food_web_balance * 40.0
	
	# Season modifier
	var season_mod = TimeManager.get_current_season_modifiers()
	health *= season_mod.species_activity
	
	ecosystem_health = clamp(health, 0.0, 100.0)
	ecosystem_health_changed.emit(ecosystem_health)


func _check_wildlife_spawning() -> void:
	"""Check if wildlife should be spawned based on ecosystem state"""
	for wildlife_type in wildlife_requirements:
		var requirements = wildlife_requirements[wildlife_type]
		
		# Check biodiversity threshold
		if biodiversity_score < requirements.min_biodiversity:
			continue
		
		# Check coverage requirement
		if total_planted_tiles < requirements.required_coverage:
			continue
		
		# Check if required species are present
		var has_required_species = false
		for required in requirements.species:
			for planted_key in planted_species:
				if required in planted_key:
					has_required_species = true
					break
			if has_required_species:
				break
		
		if not has_required_species:
			continue
		
		# Spawn wildlife if not already present
		if wildlife_populations[wildlife_type] == 0:
			_spawn_wildlife(wildlife_type)


func _spawn_wildlife(wildlife_type: String) -> void:
	"""Spawn new wildlife"""
	wildlife_populations[wildlife_type] = 1
	wildlife_spawned.emit(wildlife_type)
	print("Wildlife spawned: ", wildlife_type)
	
	# Add research points for first sighting
	GameManager.add_research_points(10)


func get_species_count() -> int:
	"""Get number of unique species planted"""
	return planted_species.size()


func get_overall_health() -> float:
	"""Get ecosystem health as 0-1 value"""
	return ecosystem_health / 100.0


func get_biodiversity_bonus() -> float:
	"""Get growth bonus from biodiversity (0-1.5)"""
	return 1.0 + (biodiversity_score / 200.0)


func get_wildlife_count() -> int:
	"""Get total wildlife population"""
	var total = 0
	for count in wildlife_populations.values():
		total += count
	return total


func update_food_web_balance(balance: float) -> void:
	"""Update food web balance (from food web system)"""
	food_web_balance = clamp(balance, 0.0, 1.0)
	_update_ecosystem_health()


func get_save_data() -> Dictionary:
	"""Get ecosystem data for saving"""
	return {
		"planted_species": planted_species,
		"discovered_species": discovered_species,
		"biodiversity_score": biodiversity_score,
		"ecosystem_health": ecosystem_health,
		"wildlife_populations": wildlife_populations,
		"food_web_balance": food_web_balance,
		"total_planted_tiles": total_planted_tiles
	}


func load_save_data(data: Dictionary) -> void:
	"""Load ecosystem data from save"""
	planted_species = data.get("planted_species", {})
	discovered_species = data.get("discovered_species", [])
	biodiversity_score = data.get("biodiversity_score", 0.0)
	ecosystem_health = data.get("ecosystem_health", 50.0)
	wildlife_populations = data.get("wildlife_populations", wildlife_populations)
	food_web_balance = data.get("food_web_balance", 0.5)
	total_planted_tiles = data.get("total_planted_tiles", 0)
	
	_update_biodiversity()
