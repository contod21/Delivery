extends Node3D
class_name InteractionBillboard

@onready var mesh_instance := $MeshInstance3D
@onready var viewport := $SubViewport
@onready var key_label := $SubViewport/Control/PanelContainer/VBoxContainer/Label2

var player_camera: Camera3D

func _ready():
	# Create material and assign viewport texture
	var material = StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	
	# Make background transparent
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mesh_instance.material_override = material

func setup(interaction_text: String, action_name: String = "interact"):
	if key_label:
		var key_text = get_key_for_action(action_name)
		#print(action_name, key_text)
		key_label.text = "[" + key_text + "] to interact"

func set_player_camera(camera: Camera3D):
	player_camera = camera

func get_key_for_action(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	#for i in InputMap.get_actions():
		#print(i, "  ", InputMap.action_get_events(i))
	#print(InputMap.get_actions())
	#print(action_name, events)
	print("list of events", events)
	if events.size() > 0:
		
		var event = events[0]  # Get the first assigned key
		if event is InputEventKey:
			var yyel = OS.get_keycode_string(event.key_label)
			print(yyel)
			return event.as_text_key_label()
	return "?"

func _process(_delta):
	# Always face the player camera (optional - billboard mode should handle this)
	if player_camera:
		look_at(player_camera.global_position, Vector3.UP)
