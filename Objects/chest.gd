extends Sprite2D

@export var npc_id: String = "npc_default"
@export var npc_name: String = "Bobb"
@export_multiline var dialogue: Array[String] = [
	"Hello there!",
	"Nice weather today, isn't it?",
	"See you around."
]

func _ready():
	add_to_group("NPC")
