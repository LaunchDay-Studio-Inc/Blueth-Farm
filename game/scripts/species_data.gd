extends Resource
class_name SpeciesData
## Resource defining a plantable blue carbon species
## Based on real scientific data from SCIENCE_REFERENCE.md

@export var species_name: String = ""
@export var scientific_name: String = ""
@export_multiline var description: String = ""
@export_multiline var codex_entry: String = ""

# Zone requirements
@export_enum("shallows", "mudflats", "estuary", "reef_edge") var zone: String = "shallows"

# Environmental requirements
@export var preferred_depth_min: float = 0.0  # meters
@export var preferred_depth_max: float = 3.0  # meters
@export var preferred_salinity: float = 35.0  # ppt (parts per thousand)
@export var salinity_tolerance: float = 5.0   # +/- tolerance
@export_enum("sand", "mud", "rocky", "organic") var preferred_substrate: String = "sand"

# Growth parameters
@export var growth_stages: int = 5  # seed, sprout, juvenile, mature, established
@export var days_per_stage: Array[int] = [7, 14, 21, 28, 35]  # Days to reach each stage

# Carbon sequestration (tonnes CO₂ per day per tile at each stage)
# Calculated from annual rates in CARBON_RATES
@export var carbon_per_day: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
@export var sediment_carbon_rate: float = 0.0  # Long-term sediment storage rate

# Ecosystem benefits
@export var biodiversity_bonus: float = 1.0  # Multiplier for biodiversity score
@export var coastal_protection: float = 0.5  # 0-1 scale, storm damage reduction

# Visual
@export var base_color: Color = Color.GREEN  # For placeholder graphics
@export var stage_colors: Array[Color] = []  # Different colors per growth stage

# Species-specific properties
@export var can_spread: bool = false  # Can spread to adjacent tiles
@export var spread_chance: float = 0.0  # Chance per day to spread
@export var wildlife_attraction: Dictionary = {}  # Wildlife types attracted


func _init() -> void:
	# Default stage colors (green gradient)
	if stage_colors.is_empty():
		stage_colors = [
			Color(0.4, 0.5, 0.3),  # Seed - brown/green
			Color(0.5, 0.7, 0.4),  # Sprout - light green
			Color(0.4, 0.8, 0.5),  # Juvenile - medium green
			Color(0.3, 0.85, 0.6), # Mature - bright green
			Color(0.2, 0.9, 0.7)   # Established - vibrant green
		]


func is_compatible_with_tile(depth: float, salinity: float, substrate: String) -> bool:
	"""Check if this species can grow on a tile with given conditions"""
	# Check depth
	if depth < preferred_depth_min or depth > preferred_depth_max:
		return false
	
	# Check salinity
	if abs(salinity - preferred_salinity) > salinity_tolerance:
		return false
	
	# Check substrate
	if substrate != preferred_substrate:
		return false
	
	return true


func get_stage_color(stage: int) -> Color:
	"""Get the color for a specific growth stage"""
	if stage >= 0 and stage < stage_colors.size():
		return stage_colors[stage]
	return base_color


func get_carbon_rate_at_stage(stage: int) -> float:
	"""Get daily carbon sequestration rate at a specific growth stage"""
	if stage >= 0 and stage < carbon_per_day.size():
		return carbon_per_day[stage]
	return 0.0


func get_days_to_stage(stage: int) -> int:
	"""Get total days required to reach a specific growth stage"""
	if stage >= 0 and stage < days_per_stage.size():
		return days_per_stage[stage]
	return 0


func get_resource_key() -> String:
	"""Get a unique key for this species (for dictionary lookups)"""
	return species_name.to_lower().replace(" ", "_")
