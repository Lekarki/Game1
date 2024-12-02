extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var SPEED = 5
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("w"):
		position.z -= SPEED * delta
	if Input.is_action_pressed("a"):
		position.x -= SPEED * delta
	if Input.is_action_pressed("s"):
		position.z += SPEED * delta
	if Input.is_action_pressed("d"):
		position.x += SPEED * delta
