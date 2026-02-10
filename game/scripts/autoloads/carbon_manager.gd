extends Node
## Carbon tracking and ledger system
## Manages carbon sequestration calculations based on real science data

signal carbon_updated(total_co2: float, daily_rate: float)
signal carbon_milestone_reached(milestone_tonnes: int)
signal carbon_credit_earned(credits: float)

# Carbon tracking (in tonnes CO₂)
var total_biomass_carbon: float = 0.0  # Volatile - stored in living plants
var total_sediment_carbon: float = 0.0  # Permanent - stored in sediment
var total_co2_sequestered: float = 0.0  # Lifetime total
var daily_sequestration_rate: float = 0.0  # Current daily CO₂ capture

# Carbon credits
var total_carbon_credits: float = 0.0  # Verified carbon credits
var unverified_carbon: float = 0.0  # Carbon not yet verified
var credit_price: float = 25.0  # Gold per carbon credit
var verification_unlocked: bool = false

# Historical data for graphs
var carbon_history: Array[Dictionary] = []
var max_history_days: int = 365

# Carbon equivalencies (for UI display)
var cars_offset: float = 0.0
var flights_offset: float = 0.0
var trees_equivalent: float = 0.0

# Science-based carbon rates (tonnes CO₂/km²/year)
const CARBON_RATES = {
	"seagrass_zostera": 138.0,
	"seagrass_posidonia": 145.0,
	"seagrass_thalassia": 132.0,
	"salt_marsh_spartina": 218.0,
	"salt_marsh_salicornia": 195.0,
	"mangrove_red": 226.0,
	"mangrove_black": 215.0,
	"kelp_macrocystis": 165.0,
	"kelp_laminaria": 155.0
}

# Conversion factors
const TILE_SIZE_KM2: float = 0.0001  # Each tile = 0.0001 km² (10m x 10m)
const TONNES_PER_CAR_YEAR: float = 4.6  # Average car emissions per year
const TONNES_PER_FLIGHT: float = 0.9  # One-way domestic flight
const TONNES_PER_TREE_YEAR: float = 0.021  # Average tree sequestration per year


func _ready() -> void:
	print("CarbonManager initialized")
	# Connect to day change to update daily carbon
	TimeManager.day_changed.connect(_on_day_changed)


func add_plant_carbon(species_key: String, growth_stage: int, tile_count: int = 1) -> void:
	"""Add carbon from a planted species at a specific growth stage"""
	if species_key not in CARBON_RATES:
		print("Warning: Unknown species key: ", species_key)
		return
	
	# Get annual rate and convert to daily rate per tile
	var annual_rate_per_km2 = CARBON_RATES[species_key]
	var daily_rate_per_tile = (annual_rate_per_km2 * TILE_SIZE_KM2) / 365.0
	
	# Growth stage multiplier (0.2 at seed, 1.0 at established)
	var stage_multiplier = 0.2 + (growth_stage * 0.2)
	
	var carbon_added = daily_rate_per_tile * stage_multiplier * tile_count
	
	total_biomass_carbon += carbon_added
	daily_sequestration_rate += daily_rate_per_tile * stage_multiplier * tile_count
	
	_update_totals()


func add_sediment_carbon(amount: float) -> void:
	"""Add permanent carbon stored in sediment"""
	total_sediment_carbon += amount
	_update_totals()


func remove_plant_carbon(species_key: String, growth_stage: int) -> void:
	"""Remove carbon when a plant dies or is removed"""
	if species_key not in CARBON_RATES:
		return
	
	var annual_rate_per_km2 = CARBON_RATES[species_key]
	var daily_rate_per_tile = (annual_rate_per_km2 * TILE_SIZE_KM2) / 365.0
	var stage_multiplier = 0.2 + (growth_stage * 0.2)
	
	var carbon_removed = daily_rate_per_tile * stage_multiplier
	
	total_biomass_carbon = max(0, total_biomass_carbon - carbon_removed)
	daily_sequestration_rate = max(0, daily_sequestration_rate - daily_rate_per_tile * stage_multiplier)
	
	_update_totals()


func _update_totals() -> void:
	"""Recalculate total carbon and equivalencies"""
	total_co2_sequestered = total_biomass_carbon + total_sediment_carbon
	
	# Calculate equivalencies
	cars_offset = total_co2_sequestered / TONNES_PER_CAR_YEAR
	flights_offset = total_co2_sequestered / TONNES_PER_FLIGHT
	trees_equivalent = total_co2_sequestered / TONNES_PER_TREE_YEAR
	
	carbon_updated.emit(total_co2_sequestered, daily_sequestration_rate)
	
	# Check for milestones
	_check_milestones()


func _check_milestones() -> void:
	"""Check if carbon milestones have been reached"""
	var milestones = [10, 50, 100, 500, 1000, 5000, 10000]
	for milestone in milestones:
		if total_co2_sequestered >= milestone and total_co2_sequestered - daily_sequestration_rate < milestone:
			carbon_milestone_reached.emit(milestone)
			print("Carbon milestone reached: ", milestone, " tonnes CO₂!")


func _on_day_changed(day: int) -> void:
	"""Called when a new day starts - process daily carbon"""
	# Add daily sequestration to totals
	var daily_biomass = daily_sequestration_rate
	var daily_sediment = daily_sequestration_rate * 0.1  # 10% goes to long-term sediment storage
	
	total_biomass_carbon += daily_biomass
	total_sediment_carbon += daily_sediment
	
	_update_totals()
	
	# Record history
	carbon_history.append({
		"day": day,
		"total": total_co2_sequestered,
		"biomass": total_biomass_carbon,
		"sediment": total_sediment_carbon,
		"daily_rate": daily_sequestration_rate
	})
	
	# Trim history if too long
	if carbon_history.size() > max_history_days:
		carbon_history.pop_front()
	
	# Generate carbon credits if verification is unlocked
	if verification_unlocked:
		_generate_carbon_credits()


func _generate_carbon_credits() -> void:
	"""Generate verified carbon credits from sequestration"""
	# Require minimum ecosystem health
	var ecosystem_health = EcosystemManager.get_overall_health()
	if ecosystem_health < 0.5:
		print("Ecosystem health too low for carbon credit verification")
		return
	
	# Convert unverified carbon to credits
	var new_credits = unverified_carbon * ecosystem_health
	total_carbon_credits += new_credits
	unverified_carbon = 0.0
	
	if new_credits > 0:
		carbon_credit_earned.emit(new_credits)
		print("Carbon credits earned: ", new_credits)


func sell_carbon_credits(amount: float) -> bool:
	"""Sell carbon credits for gold"""
	if total_carbon_credits >= amount:
		total_carbon_credits -= amount
		var gold_earned = int(amount * credit_price)
		GameManager.add_gold(gold_earned)
		print("Sold ", amount, " carbon credits for ", gold_earned, " gold")
		return true
	return false


func unlock_verification() -> void:
	"""Unlock carbon credit verification (research unlock)"""
	verification_unlocked = true
	print("Carbon credit verification unlocked!")


func get_projected_annual_sequestration() -> float:
	"""Get projected annual CO₂ sequestration based on current rate"""
	return daily_sequestration_rate * 365.0


func get_carbon_breakdown() -> Dictionary:
	"""Get breakdown of carbon storage for UI"""
	var total = total_co2_sequestered
	if total == 0:
		return {"biomass_percent": 0.0, "sediment_percent": 0.0}
	
	return {
		"biomass_percent": (total_biomass_carbon / total) * 100.0,
		"sediment_percent": (total_sediment_carbon / total) * 100.0,
		"biomass_tonnes": total_biomass_carbon,
		"sediment_tonnes": total_sediment_carbon
	}


func get_equivalencies() -> Dictionary:
	"""Get carbon equivalencies for display"""
	return {
		"cars_offset": int(cars_offset),
		"flights_offset": int(flights_offset),
		"trees_equivalent": int(trees_equivalent)
	}


func get_history_data(days: int = 30) -> Array:
	"""Get recent carbon history for graphs"""
	var start_index = max(0, carbon_history.size() - days)
	return carbon_history.slice(start_index)


func get_save_data() -> Dictionary:
	"""Get carbon data for saving"""
	return {
		"total_biomass_carbon": total_biomass_carbon,
		"total_sediment_carbon": total_sediment_carbon,
		"total_co2_sequestered": total_co2_sequestered,
		"daily_sequestration_rate": daily_sequestration_rate,
		"total_carbon_credits": total_carbon_credits,
		"unverified_carbon": unverified_carbon,
		"credit_price": credit_price,
		"verification_unlocked": verification_unlocked,
		"carbon_history": carbon_history
	}


func load_save_data(data: Dictionary) -> void:
	"""Load carbon data from save"""
	total_biomass_carbon = data.get("total_biomass_carbon", 0.0)
	total_sediment_carbon = data.get("total_sediment_carbon", 0.0)
	total_co2_sequestered = data.get("total_co2_sequestered", 0.0)
	daily_sequestration_rate = data.get("daily_sequestration_rate", 0.0)
	total_carbon_credits = data.get("total_carbon_credits", 0.0)
	unverified_carbon = data.get("unverified_carbon", 0.0)
	credit_price = data.get("credit_price", 25.0)
	verification_unlocked = data.get("verification_unlocked", false)
	carbon_history = data.get("carbon_history", [])
	
	_update_totals()
