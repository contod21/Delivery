extends CharacterBody3D


const SPEED = 5.0
const SPRINT_MULTIPLIER = 1.5

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

@export var max_stamina := 5.0 
@export var stamina_recovery_rate := 1.0
@export var stamina_depletion_rate := 2.0
@export var sensitivity: float = 1

@export_group("headbob")
@export var headbob_frequency := 2.0
@export var headbob_amplitude := 0.04
var headbob_time := 0.0

var stamina := max_stamina
var can_sprint := true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * (sensitivity / 1000))
			camera.rotate_x(-event.relative.y * (sensitivity / 1000))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var is_sprinting = Input.is_action_pressed("sprint") and can_sprint and stamina > 0
	var current_speed = SPEED
	if is_sprinting:
		current_speed = current_speed * SPRINT_MULTIPLIER
		stamina -= stamina_depletion_rate * delta
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		stamina += stamina_recovery_rate * delta
		if stamina >= max_stamina:
			stamina  = max_stamina
			can_sprint = true
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	headbob_time += delta * velocity.length() * float(is_on_floor())
	%Camera3D.transform.origin = headbob(headbob_time)
	
func headbob(headbob_time):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = sin(headbob_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position
