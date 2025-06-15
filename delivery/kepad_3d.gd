extends StaticBody3D
class_name KeypadObject

@export var keypad_code := "1234"
var keypad_ui: Keypad
var keypad_scene = preload("res://keypad_script.tscn")

@onready var interaction_area := Area3D.new()
@onready var interaction_collision := CollisionShape3D.new()

signal keypad_unlocked

func _ready():
	# Set up interaction area
	add_child(interaction_area)
	interaction_area.add_child(interaction_collision)
	
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 2.0
	interaction_collision.shape = sphere_shape
	
	interaction_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		show_keypad()

func show_keypad():
	if not keypad_ui:
		keypad_ui = keypad_scene.instantiate()
		get_tree().current_scene.add_child(keypad_ui)
		keypad_ui.set_code(keypad_code)
		keypad_ui.code_correct.connect(_on_code_correct)
		keypad_ui.code_incorrect.connect(_on_code_incorrect)
	
	keypad_ui.show_keypad()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_code_correct():
	print("Keypad unlocked!")
	keypad_unlocked.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_code_incorrect():
	print("Wrong code entered")
	# Could add sound effects, screen shake, etc.extends StaticBody3D
