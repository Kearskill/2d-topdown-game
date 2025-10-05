extends CharacterBody2D

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)

# parameters/Idle/blend_position

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var raycast: RayCast2D = $RayCast2D

var facing_direction: Vector2 = Vector2.DOWN
var current_npc: Node = null


func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	update_animation_parameters(input_direction)
	
	if input_direction != Vector2.DOWN:
		facing_direction = input_direction # dialogue uses facing_direction
	
	# Update velocity
	velocity = input_direction * move_speed
	
	# Move and Slide function usess velocitiy of character body to move character on map
	move_and_slide()
	
	# If near NPC and player presses interact
	
	pick_new_state()
	
	raycast.target_position = facing_direction * 16 # 16 is distance
	if Input.is_action_just_pressed("ui_accept"):
		_check_npc_interaction()

func update_animation_parameters(move_input : Vector2):
	# don't change animation parameters if there is no input for moving
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		
		
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func _check_npc_interaction():
	if raycast.is_colliding():
		var collider =raycast.get_collider()
		if collider.is_in_group("NPC"):
			current_npc = collider
			print("Talking to NPC: ", current_npc.name)
			
