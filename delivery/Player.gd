extends CharacterBody3D


const SPEED = 5.0
const SPRINT_MULTIPLIER = 1.5


@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var hand_sprite := $Neck/Camera3D/Sprite3D
@onready var animated_hand := $Neck/Camera3D/AnimatedSprite3D
@onready var flashlight := $Neck/Camera3D/SpotLight3D

@export var max_stamina := 5.0 
@export var stamina_recovery_rate := 1.0
@export var stamina_depletion_rate := 2.0
@export var sensitivity: float = 1

@export_group("headbob")
@export var headbob_frequency := 2.0
@export var headbob_amplitude := 0.04
@export var idle_headbob_multiplier := 0.3
@export var idle_frequency_multiplier := 0.4
var headbob_time := 0.0

var stamina := max_stamina
var can_sprint := true

var nearby_interactables: Array[InteractableBox] = []

var original_hand_position: Vector3
var original_animated_hand_position: Vector3


func _ready():
	original_hand_position = hand_sprite.transform.origin
	original_animated_hand_position = animated_hand.transform.origin


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if animated_hand.visible == true: 
				play_click_animation()
			
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("flashlight"):
		toggle_visibility()
	elif event.is_action_pressed("interact"):
		interact_with_nearest()
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * (sensitivity / 1000))
			camera.rotate_x(-event.relative.y * (sensitivity / 1000))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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
			stamina = max_stamina
			can_sprint = true
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	var is_moving = velocity.length() > 0.1 and is_on_floor()
	if is_moving:
		headbob_time += delta * velocity.length()
	else:
		headbob_time += delta * 0.5
	
	var headbob_offset = headbob(headbob_time, is_moving)
	
	camera.transform.origin = headbob_offset
	
	hand_sprite.transform.origin = original_hand_position + headbob_offset
	
	animated_hand.transform.origin = original_animated_hand_position + headbob_offset
	
func headbob(headbob_time, is_moving: bool):
	var headbob_position = Vector3.ZERO
	
	if is_moving:
		headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
		headbob_position.x = sin(headbob_time * headbob_frequency / 2) * headbob_amplitude
	else:
		var idle_amplitude = headbob_amplitude * idle_headbob_multiplier
		var idle_frequency = headbob_frequency * idle_frequency_multiplier
		headbob_position.y = sin(headbob_time * idle_frequency) * idle_amplitude
		headbob_position.x = sin(headbob_time * idle_frequency / 3) * (idle_amplitude * 0.5)
	
	return headbob_position
	
	
func play_click_animation():
	hand_sprite.visible = false
	animated_hand.visible = true
	
	animated_hand.play("punch")


func _on_animated_sprite_3d_animation_finished() -> void:
	pass

func toggle_visibility():
	var is_flashlight_on = !hand_sprite.visible
	
	hand_sprite.visible = is_flashlight_on
	animated_hand.visible = !is_flashlight_on
	flashlight.visible = is_flashlight_on

func interact_with_nearest():
	var interactables = get_tree().get_nodes_in_group("interactables")
	var closest_interactable: InteractableBox = null
	var closest_distance := 999.0
	
	for interactable in interactables:
		if interactable is InteractableBox and interactable.can_interact:
			var distance = global_position.distance_to(interactable.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_interactable = interactable
	
	if closest_interactable:
		closest_interactable.interact()
