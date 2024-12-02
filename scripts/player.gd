extends CharacterBody3D


#const SPEED = 8.0
#const JUMP_VELOCITY = 4.5

@export_category("Movement Parameters")

@export var Aim_Sensitivity: float = 0.15
@export var Jump_Peak_Time: float = 0.5
@export var Jump_Fall_Time: float = 0.5
@export var Jump_Height: float = 2.0
@export var Jump_Distance: float = 4.0
@export var Coyote_Time: float = .15
@export var Jump_Buffer_time: float = .1

@onready var coyote_timer: Timer = $Coyote_timer


var Speed: float = 12.0
var Jump_Velocity: float = 5.0

var Jump_Available: bool = true
var Jump_Buffer: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var Jump_Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var Fall_Gravity: float = 5.0



func _ready():
	Calculate_Movement_Parameters()
	
func Calculate_Movement_Parameters()->void:
	Jump_Gravity = (2*Jump_Height/pow(Jump_Peak_Time,2))
	Fall_Gravity = (3*Jump_Height/pow(Jump_Peak_Time,2))
	Jump_Velocity = Jump_Gravity * Jump_Peak_Time
	
	

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * Aim_Sensitivity))
			%CameraHolder.rotate_x(deg_to_rad(-event.relative.y * Aim_Sensitivity))
			%CameraHolder.rotation.x = clamp(%CameraHolder.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _handle_air_physics(delta) -> void:
	pass
	
	
func _handle_ground_physics(delta) -> void:
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
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
	# Handle jump.
	
	if Input.is_action_just_pressed("ui_accept"):
		if Jump_Available:
			Jump()
		else:
			Jump_Buffer = true
			get_tree().create_timer(Jump_Buffer_time).timeout.connect(on_Jump_Buffer_timeout)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * Speed
		velocity.z = direction.z * Speed 
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)

	move_and_slide()
func Jump()->void:
	velocity.y = Jump_Velocity
	Jump_Available = false
		
		
func Coyote_timeout():
	Jump_Available = false

func on_Jump_Buffer_timeout():
	Jump_Buffer = false
