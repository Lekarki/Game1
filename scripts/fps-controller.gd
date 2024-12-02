extends CharacterBody3D


@export var Aim_Sensitivity: float = 0.25


# Ground Movement Settings
@export_category("Ground movement")
@export var Walk_Speed := 15.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0


# Jump Settings
@export_category("Movement Parameters")
@export var Jump_Peak_Time: float = 0.5
@export var Jump_Fall_Time: float = 0.5
@export var Jump_Height: float = 8.0
@export var Jump_Distance: float = 4.0
@export var Coyote_Time: float = .15
@export var Jump_Buffer_time: float = .1
@export var Auto_Bhop := true



@export_category("Air movement")
@export var air_cap := 0.85 # Surf Mechanic
@export var air_accel := 800.0 
@export var air_move_speed := 500.0


@onready var coyote_timer: Timer = $Coyote_timer
@onready var weaponswitchtimer = $Weaponswitchtimer
@onready var hud = %Hud

@onready var weapon_holder = $CameraHolder/WeaponHolder
@onready var shotgun_1 = %shotgunbetter
@onready var pistolbetter = %Pistolbetter
@onready var knife = %knife

@onready var player = $"."
@onready var camera_holder = %CameraHolder
@onready var camera3d = %Camera3D
@onready var animation_player = $AnimationPlayer

@onready var ray_container = $CameraHolder/Camera3D/RayContainer

@onready var footsteps_audio = $FootstepsAudio
@onready var walk_timer = $WalkTimer


const HEADBOB_MOVE_AMOUNT = 0.018
const HEADBOB_FREQUENCY = 1.1
var headbob_time := 0.0

var camera_sway_amount: float = 1
var camera_sway_speed: float = 0

var wish_dir := Vector3.ZERO
var cam_aligned_wish_dir := Vector3.ZERO

var noclip_speed_mult := 4.0
var noclip = false

var Jump_Velocity: float = 5.0

var Jump_Available: bool = true
var Jump_Buffer: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var Jump_Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var Fall_Gravity: float = 5.0

# Weapon mechanics




func _ready():
	
	randomize()
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Calculate_Movement_Parameters()
	%Hud/Crosshair.visible = true
		
		

					
	

func _process(delta):
	pass
	
func Calculate_Movement_Parameters()->void:
	Jump_Gravity = (2*Jump_Height/pow(Jump_Peak_Time,2))
	Fall_Gravity = (2*Jump_Height/pow(Jump_Fall_Time,2))
	Jump_Velocity = Jump_Gravity * Jump_Peak_Time
	
	

func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		%Hud/VBoxContainer.visible = false
		%Hud/Crosshair.visible = true
		shotgun_1.can_fire = true
		
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		%Hud/VBoxContainer.visible = true
		%Hud/Crosshair.visible = false
		shotgun_1.can_fire = false
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * Aim_Sensitivity))
			%CameraHolder.rotate_x(deg_to_rad(-event.relative.y * Aim_Sensitivity))
			%CameraHolder.rotation.x = clamp(%CameraHolder.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("weapon1"):
		set_weapon1_active()
	if event.is_action_pressed("weapon2"):
		set_weapon2_active()
	if event.is_action_pressed("weapon3"):
		set_weapon3_active()
	
func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func _footsteps():
	var current_velocity_rounded = snappedf(Vector3(self.velocity.x, 0, self.velocity.z).length(), 0.01)
	if is_on_floor() and current_velocity_rounded >= 8:
		if walk_timer.time_left <= 0:
			footsteps_audio.pitch_scale = randf_range(0.6, 1)
			footsteps_audio.play()
			walk_timer.start(0.32)

func _handle_noclip(delta) -> bool:
	
		if Input.is_action_just_pressed("_noclip"):
			noclip = !noclip
			
		$CollisionShape3D.disabled = noclip
		
		if not noclip:
			return false
			
		var speed = Walk_Speed * noclip_speed_mult
		
		self.velocity = cam_aligned_wish_dir * speed
		global_position += self.velocity * delta
			
		return true
	

# AIR PHYSICS
func clip_velocity(normal: Vector3, overbounce : float, delta : float) -> void:
	
	var backoff := self.velocity.dot(normal) * overbounce
	
	if backoff >= 0: return
	
	var change := normal * backoff
	self.velocity -= change
	
	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust

func is_surface_too_steep(normal : Vector3) -> bool:
	var max_slope_ang_dot = Vector3(0,1,0).rotated(Vector3(1.0,0,0), self.floor_max_angle).dot(Vector3(0,1,0))
	if normal.dot(Vector3(0,1,0)) < max_slope_ang_dot:
		return true
	return false
		
func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# air movement
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	# wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir

	if is_on_wall():
		if is_surface_too_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		
		else: 
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		
		clip_velocity(get_wall_normal(), 1, delta) # surf
		
# GROUND PHYSICS

func _handle_ground_physics(delta) -> void:
	# Ground acceleration
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = Walk_Speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * Walk_Speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	# Apply friction
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed
	
	_headbob_effect(delta)
	


func _physics_process(delta):
	
			
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	cam_aligned_wish_dir = %Camera3D.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if not _handle_noclip(delta):
		
		if is_on_floor():
			_handle_ground_physics(delta)
				
		else:
			_handle_air_physics(delta)
			
		
		# JUMP physics
		if not is_on_floor():
			_handle_air_physics(delta)
			if Jump_Available:
				if coyote_timer.is_stopped():
					coyote_timer.start(Coyote_Time)
			else:
				if velocity.y>0:
					velocity.y -= Jump_Gravity * delta
				else:
					velocity.y -= Fall_Gravity * delta
		else:
			Jump_Available = true
			coyote_timer.stop() 
			if Jump_Buffer:
				Jump()
				Jump_Buffer = false
		
		if Input.is_action_just_pressed("jump") or (Auto_Bhop and Input.is_action_pressed("jump")):
			if Jump_Available:
				Jump()
			else:
				Jump_Buffer = true
				get_tree().create_timer(Jump_Buffer_time).timeout.connect(on_Jump_Buffer_timeout)
		
		if camera_holder.rotation.x < deg_to_rad(80) and camera_holder.rotation.x > deg_to_rad(-80):
			if is_on_floor():
				
				
				if input_dir.x>0:
					camera_holder.rotation.z = lerp_angle(camera_holder.rotation.z, deg_to_rad(-3.5), 0.13)
				elif input_dir.x<0:
					camera_holder.rotation.z = lerp_angle(camera_holder.rotation.z, deg_to_rad(3.5), 0.13)
				else:
					camera_holder.rotation.z = lerp_angle(camera_holder.rotation.z, deg_to_rad(0), 0.13)
			else:
				camera_holder.rotation.z = lerp_angle(camera_holder.rotation.z, deg_to_rad(0), 0.13)
		
		_footsteps()
		move_and_slide()
	
		
			
func Jump()->void:
	velocity.y = Jump_Velocity
	Jump_Available = false
		
		
func Coyote_timeout():
	Jump_Available = false

func on_Jump_Buffer_timeout():
	Jump_Buffer = false

# weapons
func _calculate_current_velocity(delta):
	pass

func set_weapon1_active():
	knife.visible = false
	pistolbetter.visible = false
	pistolbetter.can_fire = false
	shotgun_1.visible = true
	shotgun_1.can_fire = true
	
func set_weapon2_active():
	knife.visible = false
	shotgun_1.visible = false
	shotgun_1.can_fire = false
	pistolbetter.visible = true
	pistolbetter.can_fire = true
	
func set_weapon3_active():
	pistolbetter.visible = false
	pistolbetter.can_fire = false
	shotgun_1.visible = false
	shotgun_1.can_fire = false
	knife.visible = true
#func _process(delta) -> void:
	#var current_velocity_rounded = snappedf(Vector3(velocity.x, 0, velocity.z).length(), 0.01) 
	#%Hud/label.text = str(current_velocity_rounded)

	


