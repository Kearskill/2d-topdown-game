extends Node

var dialogue_data = {}
var current_lines = []
var current_index = 0

var full_text = ""
var visible_text = "" # what's typed so far
var char_index = 0


# need to add canvaslayer (ui layer)
# inside, need RichTextLabel
# add timer node

# RichTextLabel is named DialogueLabel
# Timer is named TypeTimer
@onready var dialogue_label = $CanvasLayer/DialogueLabel
@onready var type_timer = $CanvasLayer/TypeTimer

func _ready():
	# LOAD JSON
	var file = FileAccess.open("res://Dialogues/sample_dialogue.json", FileAccess.READ)
	if file:
		dialogue_data = JSON.parse_string(file.get_as_text())
		file.close()
		
	type_timer.timeout.connect(_on_type_timer_timeout)
