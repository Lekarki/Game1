class_name MainMenu
extends Control




@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var practise_button = $MarginContainer/HBoxContainer/VBoxContainer/Practise_Button as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/Options_Button as Button
@onready var options_menu = $options_menu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer

@onready var level_one = preload("res://scenes/inside_test_level.tscn") as PackedScene
@onready var level_practise = preload("res://scenes/jump_testing.tscn") as PackedScene


func _ready():
	handle_connecting_signals()

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level_one)
	
	
func on_practise_pressed() -> void:
	get_tree().change_scene_to_packed(level_practise)
	
	
func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
	
func on_exit_pressed() -> void:
	get_tree().quit()
	

func on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false


func handle_connecting_signals() -> void:
	
	start_button.button_down.connect(on_start_pressed)
	practise_button.button_down.connect(on_practise_pressed)
	options_button.button_down.connect(on_options_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	
	
