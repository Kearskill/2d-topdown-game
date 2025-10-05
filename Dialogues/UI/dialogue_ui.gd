extends Control
class_name DialogueUI

@export var type_speed: float = 0.012

signal dialogue_finished
signal node_action(action_str: String)
signal choice_selected(goto_id: String)

var _is_typing := false
var _skip_next := false

@onready var portrait: TextureRect = $Panel/HBoxContainer/TextureRect
@onready var speaker_label: Label = $Panel/HBoxContainer/VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/HBoxContainer/VBoxContainer/TextLabel
@onready var choices_container: VBoxContainer = $Panel/HBoxContainer/VBoxContainer/ChoicesContainer

func _ready() -> void:
	visible = false
	text_label.clear()

# public entrypoint
func play_nodes(nodes: Array, finished_callback: Callable = Callable()) -> void:
	visible = true
	await _play_sequence(nodes)
	visible = false
	dialogue_finished.emit()
	if finished_callback.is_valid():
		finished_callback.call()

# sequence runner
func _play_sequence(nodes: Array) -> void:
	var idx := 0
	while idx < nodes.size():
		var node: Dictionary = nodes[idx]
		await _show_node(node)

		if node.has("action"):
			node_action.emit(node["action"])

		if node.has("choices"):
			var choice_result: String = node.get("_choice_result", "")
			if choice_result == "":
				break
			idx = nodes.find(nodes.filter(func(n): return n.get("id") == choice_result)[0])
			continue
		elif node.has("next") and node["next"] != null:
			var id_next: String = node["next"]
			var next_node = nodes.filter(func(n): return n.get("id") == id_next)
			if next_node.size() > 0:
				idx = nodes.find(next_node[0])
				continue
			else:
				idx += 1
		else:
			idx += 1

# show single node
func _show_node(node: Dictionary) -> void:
	# portrait
	if node.has("portrait") and node["portrait"] != "":
		portrait.texture = load(node["portrait"])
		portrait.visible = true
	else:
		portrait.visible = false

	speaker_label.text = node.get("speaker", "")
	text_label.clear()

	# typewriter
	_is_typing = true
	var full_text : String = node.get("text", "")
	var buffer := ""
	for c in full_text:
		if _skip_next:
			break
		buffer += c
		text_label.text = buffer
		await get_tree().create_timer(type_speed).timeout
	if _skip_next:
		text_label.text = full_text
		_skip_next = false
	_is_typing = false

	# choices
	for child in choices_container.get_children():
		child.queue_free()

	if node.has("choices"):
		for choice in node["choices"]:
			var b := Button.new()
			b.text = choice.get("text", "Choice")
			choices_container.add_child(b)
			b.pressed.connect(func():
				node["_choice_result"] = choice.get("goto", "")
				choices_container.queue_free() # clear choices
				choice_selected.emit(node["_choice_result"])
			)
		var choice_made = await choice_selected
	else:
		await _wait_for_continue()

# input wait
func _wait_for_continue() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("click"):
			if _is_typing:
				_skip_next = true
			else:
				break
