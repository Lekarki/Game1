extends CharacterBody3D
@onready var animation_player = $AnimationPlayer
@onready var death_sound = $DeathSound
var health = 50

func _process(delta):
	if health <= 0:
		
		animation_player.play("Death")


