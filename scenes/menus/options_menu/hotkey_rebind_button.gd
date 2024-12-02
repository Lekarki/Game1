class_name HotkeyRebindButton
extends Control


@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "left"

var awaiting_input: bool = false

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	
func set_action_name() -> void:
	label.text = "Unassigned"

	match action_name:
		"left":
			label.text = "Move Left"
		"right":
			label.text = "Move Right"
		"up":
			label.text = "Move Forward"
		"down":
			label.text = "Move Back"
		"fire":
			label.text = "Fire Weapon"
		"jump":
			label.text = "Jump"
		"reload":
			label.text = "Reload"
		"crouch":
			label.text = "Crouch"

#func set_text_for_key() -> void:
	#var action_events = InputMap.action_get_events(action_name)
	#var action_event = action_events[0]
	#var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	#button.text = "%s" % action_keycode
	
func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	if action_event is InputEventKey:
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		button.text = "%s" % action_keycode
	elif action_event is InputEventMouseButton:
		var action_keycode = OS.get_keycode_string(action_event.button_index)
		button.text = "%s" % "Mouse " + str(action_event.button_index)
	


func _on_button_toggled(toggled_on):
	
	
	
	if toggled_on:
		awaiting_input = true
		button.text = "Press any key..."
		set_process_unhandled_input(toggled_on)
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_input(false)
	else:
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_input(false)
				awaiting_input = false
				
		set_text_for_key()

func _unhandled_input(event):
	
	if awaiting_input == true:
		if event is InputEventKey or get_allowed_mouse_options(event):
			rebind_action_key(event)
			
		button.button_pressed = false

func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	

	set_process_unhandled_input(false)
	set_text_for_key()
	set_action_name()

func get_allowed_mouse_options(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			return true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			return true
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			return true
	return false
