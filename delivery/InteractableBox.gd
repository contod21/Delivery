extends RigidBody3D
class_name InteractableBox

@export var interaction_text := "Pick up box"
@export var interaction_range := 3.0

var can_interact := false
var player_reference: CharacterBody3D
var interaction_billboard: InteractionBillboard
var billboard_scene = preload("res://interaction_billboard.tscn")

@onready var interaction_area := Area3D.new()
@onready var interaction_collision := CollisionShape3D.new()

func _ready():
	# Set up interaction area
	add_child(interaction_area)
	interaction_area.add_child(interaction_collision)
	
	# Create sphere collision for interaction range
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_range
	interaction_collision.shape = sphere_shape
	
	# Connect signals
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player":  # Your player node name
		can_interact = true
		player_reference = body
		show_interaction_ui()

func _on_body_exited(body):
	if body.name == "player":
		can_interact = false
		player_reference = null
		hide_interaction_ui()

func show_interaction_ui():
	if not interaction_billboard:
		interaction_billboard = billboard_scene.instantiate()
		add_child(interaction_billboard)
		
		# Position closer to the top of the box
		interaction_billboard.position = Vector3(0, 0, 0)  # Much closer to the box
		interaction_billboard.setup(interaction_text,"interact")

func hide_interaction_ui():
	if interaction_billboard:
		interaction_billboard.queue_free()
		interaction_billboard = null

func interact():
	if can_interact:
		print("Picked up box!")
		hide_interaction_ui()
		# Add pickup effects, sound, etc.
		queue_free()
