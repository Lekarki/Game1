extends CharacterBody3D
@onready var animation_player = $AnimationPlayer
var health = 100

func _process(delta):
	if health <= 0:
		animation_player.play("Death")

