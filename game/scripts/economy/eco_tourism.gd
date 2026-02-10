extends Node
class_name EcoTourism
## Passive income system based on ecosystem biodiversity
## Unlocked after Eco-Tourism Center is built

signal tourist_visit(visitor_count: int, income: int)
signal income_generated(amount: int)

# Base income rate per biodiversity point
const BASE_INCOME_RATE: float = 2.0

# Seasonal modifiers for tourism
const SEASON_MODIFIERS: Dictionary = {
	"spring": 1.2,  # Peak season
	"summer": 1.5,  # Peak season
	"fall": 1.0,    # Normal
	"winter": 0.6   # Off season
}

# Tourist visit event flavor text
const TOURIST_EVENTS: Array[String] = [
	"A group of birdwatchers spotted rare shorebirds in your restored marsh!",
	"Students from the marine biology program came to study your seagrass meadows.",
	"Nature photographers captured stunning shots of your kelp forest.",
	"A documentary crew filmed the thriving ecosystem you've created.",
	"Kayakers enjoyed paddling through your restored waterways.",
	"School children learned about blue carbon at your eco-tourism center.",
	"Scientists from a nearby university came to collect data on your restoration.",
	"A environmental journalism team featured your work in their publication.",
	"Eco-tourists marveled at the dolphins playing in your seagrass beds.",
	"Local families enjoyed a guided nature walk through your restored habitats."
]

var is_enabled: bool = false
var total_income_generated: int = 0
var last_visit_day: int = 0


func _ready() -> void:
	# Connect to TimeManager for daily income
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)


func enable() -> void:
	"""Enable eco-tourism (called when center is built)"""
	is_enabled = true
	print("Eco-Tourism enabled!")


func disable() -> void:
	"""Disable eco-tourism"""
	is_enabled = false


func _on_day_changed(day: int) -> void:
	"""Calculate and award daily passive income"""
	if not is_enabled:
		return
	
	# Random chance for tourist visit event (30% chance)
	if randf() < 0.3:
		generate_tourist_visit()


func generate_tourist_visit() -> void:
	"""Generate a tourist visit event with income"""
	if not EcosystemManager:
		return
	
	# Get current biodiversity score
	var biodiversity = EcosystemManager.get_biodiversity_score()
	
	# Get current season
	var current_season = "spring"
	if TimeManager:
		current_season = TimeManager.current_season
	
	# Calculate income
	var season_mod = SEASON_MODIFIERS.get(current_season, 1.0)
	var income = int(BASE_INCOME_RATE * biodiversity / 100.0 * season_mod * randf_range(0.8, 1.2))
	
	# Ensure minimum income
	income = max(income, 5)
	
	# Generate visitor count for flavor
	var visitor_count = randi_range(3, 15)
	
	# Award income
	if income > 0 and GameManager:
		GameManager.add_gold(income)
		total_income_generated += income
		
		# Emit signals
		tourist_visit.emit(visitor_count, income)
		income_generated.emit(income)
		
		# Show event notification
		show_tourist_event(visitor_count, income)


func show_tourist_event(visitor_count: int, income: int) -> void:
	"""Display tourist visit notification"""
	var event_text = TOURIST_EVENTS[randi() % TOURIST_EVENTS.size()]
	print("🌊 TOURIST VISIT: ", visitor_count, " visitors. Income: +", income, "g")
	print("   ", event_text)
	
	# TODO: Show UI notification when notification system is implemented


func calculate_potential_income() -> int:
	"""Calculate potential income for current biodiversity"""
	if not EcosystemManager:
		return 0
	
	var biodiversity = EcosystemManager.get_biodiversity_score()
	var current_season = "spring"
	if TimeManager:
		current_season = TimeManager.current_season
	
	var season_mod = SEASON_MODIFIERS.get(current_season, 1.0)
	var income = int(BASE_INCOME_RATE * biodiversity / 100.0 * season_mod)
	
	return max(income, 1)


func get_income_breakdown() -> Dictionary:
	"""Get detailed income calculation breakdown"""
	if not EcosystemManager:
		return {}
	
	var biodiversity = EcosystemManager.get_biodiversity_score()
	var current_season = "spring"
	if TimeManager:
		current_season = TimeManager.current_season
	
	var season_mod = SEASON_MODIFIERS.get(current_season, 1.0)
	
	return {
		"biodiversity_score": biodiversity,
		"base_rate": BASE_INCOME_RATE,
		"season": current_season,
		"season_modifier": season_mod,
		"potential_daily_income": calculate_potential_income(),
		"total_earned": total_income_generated
	}


func get_stats_text() -> String:
	"""Get human-readable stats for UI"""
	var breakdown = get_income_breakdown()
	
	var text = "Eco-Tourism Stats:\n"
	text += "Biodiversity Score: %d/100\n" % breakdown.get("biodiversity_score", 0)
	text += "Season: %s (×%.1f)\n" % [breakdown.get("season", ""), breakdown.get("season_modifier", 1.0)]
	text += "Potential Daily Income: %d gold\n" % breakdown.get("potential_daily_income", 0)
	text += "Total Income Earned: %d gold" % breakdown.get("total_earned", 0)
	
	return text


func is_eco_tourism_enabled() -> bool:
	"""Check if eco-tourism is enabled"""
	return is_enabled


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	return {
		"is_enabled": is_enabled,
		"total_income_generated": total_income_generated,
		"last_visit_day": last_visit_day
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	is_enabled = data.get("is_enabled", false)
	total_income_generated = data.get("total_income_generated", 0)
	last_visit_day = data.get("last_visit_day", 0)
