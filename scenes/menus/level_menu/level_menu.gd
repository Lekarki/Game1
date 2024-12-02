class_name LevelMenu
extends Control

@onready var inside_level1 = preload("res://scenes/inside_test_level.tscn") 

func _on_shooter_1_pressed():
	get_tree().change_scene_to_file("res://scenes/inside_test_level.tscn")


func _on_jumps_pressed():
	get_tree().change_scene_to_file("res://scenes/jump_testing.tscn")


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
