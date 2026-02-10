extends Node
## Toast-style notification system for game events
## Displays small notification panels that slide in from top-right

signal notification_shown(message: String, notification_type: String)

enum NotificationType {
	JOURNAL,        # 📖 Journal entry discovered (gold border)
	WILDLIFE,       # 🐬 Wildlife first sighting (blue border)
	RESEARCH,       # 🔬 Research completed (purple border)
	BUILDING,       # 🏗️ Building completed (brown border)
	GOLD,           # 💰 Gold earned (yellow border)
	GROWTH,         # 🌱 Growth milestone (green border)
	WARNING,        # ⚠️ Warning/storm approaching (red border)
	CARBON          # 📊 Carbon milestone (teal border)
}

const MAX_VISIBLE_NOTIFICATIONS: int = 3
const NOTIFICATION_DURATION: float = 3.5
const SLIDE_DURATION: float = 0.3

var notification_queue: Array = []
var active_notifications: Array = []
var notification_scene: PackedScene


func _ready() -> void:
	# Load notification scene
	notification_scene = preload("res://scenes/ui/notification_popup.tscn")
	
	# Connect to all manager signals
	_connect_signals()
	
	print("NotificationSystem initialized")


func _connect_signals() -> void:
	"""Connect to all relevant manager signals"""
	# Journal System
	if has_node("/root/GameWorld/JournalSystem"):
		var journal_system = get_node("/root/GameWorld/JournalSystem")
		if journal_system.has_signal("entry_discovered"):
			journal_system.entry_discovered.connect(_on_journal_entry_discovered)
	
	# Ecosystem Manager - Wildlife
	if EcosystemManager.has_signal("wildlife_first_sighting"):
		EcosystemManager.wildlife_first_sighting.connect(_on_wildlife_sighting)
	
	# TODO: Connect to other signals when available:
	# - TechTree.research_completed
	# - TownInvestment.building_completed
	# - CarbonManager.milestone_reached
	# - WeatherSystem.storm_approaching


func show_notification(message: String, type: NotificationType, icon: String = "") -> void:
	"""Queue a notification to be shown"""
	var notification_data = {
		"message": message,
		"type": type,
		"icon": icon,
		"timestamp": Time.get_ticks_msec()
	}
	
	notification_queue.append(notification_data)
	_process_queue()
	
	notification_shown.emit(message, NotificationType.keys()[type])


func _process_queue() -> void:
	"""Process notification queue and show notifications"""
	# Check if we can show more notifications
	while notification_queue.size() > 0 and active_notifications.size() < MAX_VISIBLE_NOTIFICATIONS:
		var data = notification_queue.pop_front()
		_show_notification_popup(data)


func _show_notification_popup(data: Dictionary) -> void:
	"""Instantiate and show a notification popup"""
	if not notification_scene:
		return
	
	var popup = notification_scene.instantiate()
	add_child(popup)
	
	# Configure popup
	popup.setup(data.message, data.type, data.icon)
	
	# Track active notification
	active_notifications.append(popup)
	
	# Position notification based on current active count
	_update_notification_positions()
	
	# Auto-remove after duration
	await get_tree().create_timer(NOTIFICATION_DURATION).timeout
	
	if popup and is_instance_valid(popup):
		_remove_notification(popup)


func _remove_notification(popup: Node) -> void:
	"""Remove a notification and update positions"""
	if popup in active_notifications:
		active_notifications.erase(popup)
	
	if popup and is_instance_valid(popup):
		popup.queue_free()
	
	_update_notification_positions()
	_process_queue()


func _update_notification_positions() -> void:
	"""Update vertical positions of all active notifications"""
	for i in range(active_notifications.size()):
		var popup = active_notifications[i]
		if popup and popup.has_method("update_position"):
			popup.update_position(i)


## Signal handlers

func _on_journal_entry_discovered(entry_id: String, entry_title: String) -> void:
	show_notification("📖 Journal Entry: " + entry_title, NotificationType.JOURNAL)


func _on_wildlife_sighting(wildlife_type: String) -> void:
	var display_name = wildlife_type.capitalize()
	show_notification("🐬 New Wildlife: " + display_name + " spotted!", NotificationType.WILDLIFE)


func _on_research_completed(research_id: String, research_name: String) -> void:
	show_notification("🔬 Research Complete: " + research_name, NotificationType.RESEARCH)


func _on_building_completed(building_id: String, building_name: String) -> void:
	show_notification("🏗️ Building Complete: " + building_name, NotificationType.BUILDING)


func _on_gold_changed(amount: int, reason: String) -> void:
	if amount > 0:
		show_notification("💰 +" + str(amount) + " gold: " + reason, NotificationType.GOLD)


func _on_growth_milestone(milestone_text: String) -> void:
	show_notification("🌱 " + milestone_text, NotificationType.GROWTH)


func _on_storm_approaching(days_until: int) -> void:
	show_notification("⚠️ Storm approaching in " + str(days_until) + " days!", NotificationType.WARNING)


func _on_carbon_milestone(amount: float, milestone: String) -> void:
	show_notification("📊 Carbon Milestone: " + milestone, NotificationType.CARBON)
