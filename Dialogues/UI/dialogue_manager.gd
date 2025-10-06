extends Node
class_name DialogueManager

@export var dialogues_path: String = "res://Dialogues/sample_dialogue.json"

var dialogues: Dictionary = {}
var ui: DialogueUI

func _ready() -> void:
	load_dialogues()
	ui = get_tree().root.get_node("Game_level/CanvasLayer/DialogueUI") # adapt to your scene res://Dialogues/UI/
	if ui:
		ui.node_action.connect(_on_node_action)

func load_dialogues() -> void:
	if FileAccess.file_exists(dialogues_path):
		var f := FileAccess.open(dialogues_path, FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		f.close()
		dialogues = data
	else:
		push_error("Dialogues file missing: %s" % dialogues_path)

func play(dialogue_key: String, finished_callback: Callable = Callable()) -> void:
	if not dialogues.has(dialogue_key):
		push_warning("Dialogue not found: %s" % dialogue_key)
		return
	var nodes: Array = dialogues[dialogue_key]["nodes"]
	get_tree().paused = true
	ui.play_nodes(nodes, func():
		get_tree().paused = false
		if finished_callback.is_valid():
			finished_callback.call()
	)

func _on_node_action(action_str: String) -> void:
	var parts = action_str.split(":")
	match parts[0]:
		"start_quest":
			print("Start quest: ", parts[1])
		"give_item":
			print("Give item: ", parts[1])
		_:
			print("Unknown action: ", action_str)
