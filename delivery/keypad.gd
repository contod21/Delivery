extends Control
class_name Keypad

@onready var title_label := $PanelContainer/VBoxContainer/Label
@onready var display := $PanelContainer/VBoxContainer/LineEdit
@onready var feedback_label := $PanelContainer/VBoxContainer/Label2
@onready var grid_container := $PanelContainer/VBoxContainer/GridContainer
@onready var clear_button := $PanelContainer/VBoxContainer/HBoxContainer/Button
@onready var enter_button := $PanelContainer/VBoxContainer/HBoxContainer/Button2

@export var correct_code := "1234"
@export var max_digits := 6

var current_input := ""

signal code_correct
signal code_incorrect

func _ready():
	title_label.text = "Enter Code"
	display.editable = false
	display.placeholder_text = "Enter " + str(correct_code.length()) + " digit code"
	feedback_label.text = ""
	
	# Connect number buttons
	var buttons = grid_container.get_children()
	for i in range(buttons.size()):
		var button = buttons[i] as Button
		if button:
			button.pressed.connect(_on_number_pressed.bind(button.text))
	
	# Connect action buttons
	clear_button.pressed.connect(_on_clear_pressed)
	enter_button.pressed.connect(_on_enter_pressed)

func _on_number_pressed(number: String):
	# Only accept actual numbers (ignore * and #)
	if number.is_valid_int() and current_input.length() < max_digits:
		current_input += number
		display.text = current_input
		feedback_label.text = ""  # Clear any previous feedback

func _on_clear_pressed():
	current_input = ""
	display.text = ""
	feedback_label.text = ""

func _on_enter_pressed():
	if current_input.length() == 0:
		show_feedback("Enter a code first", Color.ORANGE)
		return
	
	if current_input == correct_code:
		show_feedback("ACCESS GRANTED", Color.GREEN)
		code_correct.emit()
		# Optional: Close keypad after delay
		await get_tree().create_timer(1.5).timeout
		hide_keypad()
	else:
		show_feedback("ACCESS DENIED", Color.RED)
		code_incorrect.emit()
		# Clear input after wrong attempt
		await get_tree().create_timer(1.0).timeout
		_on_clear_pressed()

func show_feedback(message: String, color: Color):
	feedback_label.text = message
	feedback_label.modulate = color

func set_code(new_code: String):
	correct_code = new_code
	display.placeholder_text = "Enter " + str(correct_code.length()) + " digit code"

func show_keypad():
	visible = true
	current_input = ""
	display.text = ""
	feedback_label.text = ""

func hide_keypad():
	visible = false
