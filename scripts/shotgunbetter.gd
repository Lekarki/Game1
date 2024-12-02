extends Node3D

@onready var animation_player = $AnimationPlayer

@onready var ray_holder = $RayHolder

@onready var ray_container = $"../../Camera3D/RayContainer"

@export var can_fire = true

@export var active_weapon = true

@export var max_rounds_in_gun = 8
@export var ammo_in_gun = 8
@export var ammo_in_inv = 32

@export_category("Weapon mechanics")
@export var shotgun_damage = 10
@export var shotgun_spread = 3

@onready var bullet_decal = preload("res://scenes/bullet_decal.tscn")
@onready var blood_decal = preload("res://scenes/bullet_decal_blood.tscn")

func _ready():
	randomize()
	for r in ray_container.get_children():
			r.target_position.x = randi_range(shotgun_spread, -shotgun_spread)
			r.target_position.y = randi_range(shotgun_spread, -shotgun_spread)
			
func _process(delta):
	if visible:
		active_weapon = true
	else:
		active_weapon = false
	if active_weapon:
		if Input.is_action_just_pressed("reload"):
			if can_fire:
				reload()
		if Input.is_action_just_pressed("fire"):
			if can_fire:
				if ammo_in_gun > 0:
					altFire()
				else:
					reload()
		if Input.is_action_just_pressed("altfire"):
			if can_fire:
				if ammo_in_gun > 0:
					fire()
				else:
					reload()				

func reload():
	
	can_fire = false
	var rounds_needed = max_rounds_in_gun-ammo_in_gun
	if ammo_in_inv > rounds_needed:
		ammo_in_inv -= rounds_needed
		ammo_in_gun = max_rounds_in_gun
	else:
		if ammo_in_gun == 0:
			$misfiresound.play()
			print("no ammo")
			can_fire = true
			return
		else:
			ammo_in_gun = ammo_in_inv
			ammo_in_inv = 0
	animation_player.play("Reload")
	$Reloadsound.play()
	await get_tree().create_timer(1.15).timeout
	$shellreloadsound.play()
	await get_tree().create_timer(0.5).timeout
	$Pumposund.play()


func fire():
	can_fire = false
	$GPUParticles3D.emitting = true
	ammo_in_gun -= 1
	print("ammo in gun ", ammo_in_gun)
	print("ammo in inv", ammo_in_inv)
	$Firesound.play()
	animation_player.play("Fire")
	
	

func altFire():
	can_fire = false
	$GPUParticles3D.emitting = true
	ammo_in_gun -= 1
	print("ammo in gun ", ammo_in_gun)
	print("ammo in inv", ammo_in_inv)
	$Firesound.volume_db = 10
	$Firesound.play()
	animation_player.play("Fire2")
	
	for r in ray_container.get_children():
			r.target_position.x = randi_range(shotgun_spread, -shotgun_spread)
			r.target_position.y = randi_range(shotgun_spread, -shotgun_spread)
			if r.is_colliding():
				
				if r.get_collider().is_in_group("Enemy"):
					r.get_collider().health -= shotgun_damage
					
					var col_nor = r.get_collision_normal()	
					var col_point = r.get_collision_point()
					var b = blood_decal.instantiate()
					r.get_collider().add_child(b)
					b.global_transform.origin = col_point
					if col_nor == Vector3.DOWN:
						b.rotation_degrees.x = 90
					elif col_nor != Vector3.UP:
						b.look_at(col_point - col_nor, Vector3(0,1,0))
				else:
					var col_nor = r.get_collision_normal()	
					var col_point = r.get_collision_point()
					var b = bullet_decal.instantiate()
					r.get_collider().add_child(b)
					b.global_transform.origin = col_point
					if col_nor == Vector3.DOWN:
						b.rotation_degrees.x = 90
					elif col_nor != Vector3.UP:
						b.look_at(col_point - col_nor, Vector3(0,1,0))
						
func _on_animation_player_animation_finished(anim_name):
	print("anim name ", anim_name)
	if anim_name == "Fire":
		animation_player.play("Pump")
		$Pumposund.play()
	
	if anim_name == "Fire2":
		animation_player.play("Pump360")
		$Pumposund.play()
		
	
	if anim_name == "Pump":
		can_fire = true
		
	if anim_name == "Pump360":
		can_fire = true
		$Firesound.volume_db = 1
	
	if anim_name == "Reload":
		can_fire = true
	
	if anim_name == "away":
		active_weapon = false
		
	if anim_name == "get":
		active_weapon = true
	

