extends Node
class_name ResearchPoints
## Research points tracking and earning system

signal research_points_changed(new_total: int, delta: int)
signal milestone_reached(milestone: int)

var total_points: int = 0
var lifetime_points: int = 0  # Total ever earned

# Milestones for notifications
const MILESTONES: Array[int] = [10, 25, 50, 100, 250, 500, 1000]
var reached_milestones: Array[int] = []


func _ready() -> void:
	# Connect to various systems for point earning
	if GameManager:
		GameManager.first_plant_done = false
		GameManager.first_harvest_done = false
	
	if EcosystemManager:
		EcosystemManager.wildlife_spawned.connect(_on_wildlife_spawned)


func add_points(amount: int, source: String = "") -> void:
	"""Add research points"""
	if amount <= 0:
		return
	
	total_points += amount
	lifetime_points += amount
	
	research_points_changed.emit(total_points, amount)
	
	if not source.is_empty():
		print("📚 Research Points +", amount, " (", source, ") - Total: ", total_points)
	else:
		print("📚 Research Points +", amount, " - Total: ", total_points)
	
	# Check for milestones
	check_milestones()


func spend_points(amount: int) -> bool:
	"""Spend research points if available"""
	if total_points < amount:
		return false
	
	total_points -= amount
	research_points_changed.emit(total_points, -amount)
	print("📚 Research Points -", amount, " - Remaining: ", total_points)
	
	return true


func check_milestones() -> void:
	"""Check if any new milestones have been reached"""
	for milestone in MILESTONES:
		if lifetime_points >= milestone and milestone not in reached_milestones:
			reached_milestones.append(milestone)
			milestone_reached.emit(milestone)
			print("🎯 Research Milestone Reached: ", milestone, " points!")


func award_planting_milestone(plants_count: int) -> void:
	"""Award points for planting milestones (every 10 plants)"""
	if plants_count % 10 == 0 and plants_count > 0:
		add_points(5, "Planting Milestone")


func award_wildlife_observation(wildlife_type: String) -> void:
	"""Award points for first wildlife sighting"""
	add_points(10, "Wildlife Discovery: " + wildlife_type)


func award_quest_completion(quest_points: int) -> void:
	"""Award points from quest completion"""
	if quest_points > 0:
		add_points(quest_points, "Quest Completed")


func award_journal_discovery() -> void:
	"""Award points for discovering journal entry"""
	add_points(5, "Journal Entry Discovered")


func award_friendship_milestone(npc_name: String) -> void:
	"""Award points for reaching friendship milestones"""
	add_points(10, "Friendship with " + npc_name)


func _on_wildlife_spawned(wildlife_type: String) -> void:
	"""Handle wildlife spawning events"""
	award_wildlife_observation(wildlife_type)


func get_total_points() -> int:
	"""Get current available research points"""
	return total_points


func get_lifetime_points() -> int:
	"""Get total points ever earned"""
	return lifetime_points


func can_afford(cost: int) -> bool:
	"""Check if player can afford a research cost"""
	return total_points >= cost


func get_save_data() -> Dictionary:
	"""Get all data for saving"""
	return {
		"total_points": total_points,
		"lifetime_points": lifetime_points,
		"reached_milestones": reached_milestones
	}


func load_save_data(data: Dictionary) -> void:
	"""Load saved data"""
	total_points = data.get("total_points", 0)
	lifetime_points = data.get("lifetime_points", 0)
	reached_milestones = data.get("reached_milestones", [])
