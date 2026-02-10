extends Node

signal dialogue_started(speaker: String, text: String)
signal dialogue_choices_presented(choices: Array)
signal dialogue_ended()

var current_dialogue_data: Dictionary = {}
var current_node_id: String = ""
var dialogue_tree: Dictionary = {}

func start_dialogue(dialogue_data: Dictionary) -> void:
	dialogue_tree = dialogue_data
	current_node_id = "start"
	
	if not dialogue_tree.has(current_node_id):
		push_error("Dialogue tree missing 'start' node")
		return
	
	_process_current_node()

func advance_dialogue(choice_index: int) -> void:
	if current_node_id.is_empty():
		return
	
	var current_node = dialogue_tree.get(current_node_id, {})
	var choices = current_node.get("choices", [])
	
	if choice_index < 0 or choice_index >= choices.size():
		push_error("Invalid choice index: %d" % choice_index)
		return
	
	var selected_choice = choices[choice_index]
	var next_node_id = selected_choice.get("next", "")
	
	if next_node_id.is_empty() or next_node_id == "end":
		_end_dialogue()
		return
	
	current_node_id = next_node_id
	_process_current_node()

func _process_current_node() -> void:
	var current_node = dialogue_tree.get(current_node_id, {})
	
	if current_node.is_empty():
		push_error("Dialogue node not found: %s" % current_node_id)
		_end_dialogue()
		return
	
	var speaker = current_node.get("speaker", "")
	var text = current_node.get("text", "")
	var choices = current_node.get("choices", [])
	
	dialogue_started.emit(speaker, text)
	
	if choices.size() > 0:
		dialogue_choices_presented.emit(choices)
	else:
		_end_dialogue()

func _end_dialogue() -> void:
	current_node_id = ""
	current_dialogue_data = {}
	dialogue_tree = {}
	dialogue_ended.emit()

func get_current_node_id() -> String:
	return current_node_id

func is_dialogue_active() -> bool:
	return not current_node_id.is_empty()
