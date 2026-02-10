extends CanvasLayer
## Year Summary Controller
## Displays year-end statistics and highlights

signal continue_pressed()

# Art Direction colors
const BG_COLOR = Color("#1A3A52", 0.95)
const BORDER_COLOR = Color("#8B7355")
const TEXT_COLOR = Color("#F5F0E1")
const HIGHLIGHT_COLOR = Color("#E8A87C")


func _ready() -> void:
	_apply_styling()
	
	# Disable pause mode processing
	process_mode = Node.PROCESS_MODE_ALWAYS


func _apply_styling() -> void:
	"""Apply Art Direction color palette"""
	var panel = $CenterContainer/PanelContainer
	
	# Create StyleBoxFlat for panel
	var style = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = BORDER_COLOR
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	panel.add_theme_stylebox_override("panel", style)
	
	# Set text colors
	var title = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
	if title:
		title.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
		title.add_theme_font_size_override("font_size", 32)
	
	var stats_container = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer
	if stats_container:
		for child in stats_container.get_children():
			if child is Label:
				child.add_theme_color_override("font_color", TEXT_COLOR)
	
	var highlight_label = stats_container.get_node_or_null("HighlightLabel")
	if highlight_label:
		highlight_label.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
		highlight_label.add_theme_font_size_override("font_size", 20)
	
	var highlight_text = stats_container.get_node_or_null("HighlightText")
	if highlight_text:
		highlight_text.add_theme_color_override("font_color", HIGHLIGHT_COLOR)


func display_summary(year: int, stats: Dictionary) -> void:
	"""Display year summary with stats"""
	# Update title
	var title = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
	if title:
		title.text = "Year " + str(year) + " Complete!"
	
	# Update stats labels
	var carbon_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/CarbonLabel
	if carbon_label:
		var carbon = stats.get("carbon_sequestered", 0.0)
		carbon_label.text = "📊 Carbon Sequestered: %.1f tonnes" % carbon
	
	var species_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/SpeciesLabel
	if species_label:
		var species_dict = stats.get("species_planted", {})
		var species_count = species_dict.size()
		species_label.text = "🌱 Species Planted: %d different types" % species_count
	
	var wildlife_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/WildlifeLabel
	if wildlife_label:
		var wildlife = stats.get("wildlife_attracted", [])
		wildlife_label.text = "🐬 Wildlife Attracted: %d species" % wildlife.size()
	
	var gold_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/GoldLabel
	if gold_label:
		var gold = stats.get("gold_earned", 0)
		gold_label.text = "💰 Gold Earned: %d" % gold
	
	var investments_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/InvestmentsLabel
	if investments_label:
		var investments = stats.get("town_investments", [])
		investments_label.text = "🏗️ Town Investments: %d completed" % investments.size()
	
	var research_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/ResearchLabel
	if research_label:
		var research = stats.get("research_unlocked", [])
		research_label.text = "🔬 Research Nodes: %d unlocked" % research.size()
	
	var journal_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/JournalLabel
	if journal_label:
		var journal = stats.get("journal_entries", [])
		journal_label.text = "📖 Journal Entries: %d discovered" % journal.size()
	
	# Determine highlight of the year
	var highlight = _determine_highlight(stats)
	var highlight_text = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatsContainer/HighlightText
	if highlight_text:
		highlight_text.text = highlight
	
	# Update continue button
	var continue_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton
	if continue_button:
		continue_button.text = "Continue to Year " + str(year + 1)


func _determine_highlight(stats: Dictionary) -> String:
	"""Determine the most impactful event of the year"""
	var highlights = []
	
	# Check carbon milestone
	var carbon = stats.get("carbon_sequestered", 0.0)
	if carbon > 100:
		highlights.append("You sequestered over 100 tonnes of carbon!")
	elif carbon > 50:
		highlights.append("Your ecosystems are making a real impact on carbon storage!")
	elif carbon > 10:
		highlights.append("Your first major carbon sequestration achievement!")
	
	# Check wildlife
	var wildlife = stats.get("wildlife_attracted", [])
	if wildlife.size() >= 3:
		highlights.append("Multiple wildlife species have returned to the coast!")
	elif wildlife.size() >= 1:
		highlights.append("Wildlife is returning to your restored ecosystems!")
	
	# Check investments
	var investments = stats.get("town_investments", [])
	if investments.size() >= 2:
		highlights.append("The town is investing heavily in restoration!")
	elif investments.size() >= 1:
		highlights.append("The community is supporting your work!")
	
	# Check journal entries
	var journal = stats.get("journal_entries", [])
	if journal.size() >= 3:
		highlights.append("You've discovered many of your grandmother's journal entries!")
	
	# Default highlight
	if highlights.is_empty():
		highlights.append("You took the first steps in restoring the coast!")
	
	# Return the first (most significant) highlight
	return highlights[0]


func _on_continue_pressed() -> void:
	"""Handle continue button press"""
	continue_pressed.emit()
	queue_free()
