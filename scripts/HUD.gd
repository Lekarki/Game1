extends Control

@onready var player = $".."

@onready var shotgunbetter = %shotgunbetter
@onready var show_key_binds = $show_key_binds
@onready var speed_label = $speed_label
@onready var ammo_label = $ammo_label
@onready var info_at_start = $info_at_start
@onready var v_box_container = $VBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer.visible = false
	$info_at_start.visible = true
	await get_tree().create_timer(4).timeout
	$info_at_start.queue_free()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("help"):
		if show_key_binds.visible:
			show_key_binds.visible = false
		else:
			show_key_binds.visible = true
			
	if show_key_binds.visible and Input.is_action_just_pressed("p"):
		if speed_label.visible:
			speed_label.visible = false
		else:
			speed_label.visible = true
			
func _physics_process(delta) -> void:
	
			
		
	#showspeed
	var current_velocity_rounded = snappedf(Vector3(player.velocity.x, 0, player.velocity.z).length(), 0.01)
	var _y_velocity_current = snappedf(Vector3(player.velocity.y, 0, 0).length(), 0.01) 	
	%Hud/speed_label.text = str(current_velocity_rounded * 10)#, "  /  ", y_velocity_current)
	
	#showammo for shutgun
	var current_ammo = %shotgunbetter.ammo_in_gun
	var inv_ammo = %shotgunbetter.ammo_in_inv
	%Hud/ammo_label.text = str(current_ammo, "  /  ", inv_ammo)
	
	#showammo for pistol
	var current_ammo_pistol = %Pistolbetter.ammo_in_gun
	var inv_ammo_pistol = %Pistolbetter.ammo_in_inv
	%Hud/ammo_labelpistol.text = str(current_ammo_pistol, "  /  ", inv_ammo_pistol)
	
	



func _on_exit_to_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu.tscn")


func _on_backto_game_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	v_box_container.visible = false
	shotgunbetter.can_fire = true
	
