extends Resource
class_name JournalEntryData
## Journal entry resource for Grandmother's journal
## Contains narrative content and unlock conditions

@export var entry_id: String = ""
@export var title: String = ""
@export_multiline var content: String = ""
@export var unlock_condition: String = ""
@export var research_point_bonus: int = 5
@export var unlocks: String = ""
