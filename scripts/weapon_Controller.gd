extends Node

@onready var shotgunbetter = %shotgunbetter
@onready var knife = %knife

var knife_current = true
var shotgun_current = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#SHOTGUN
func _process(delta):
	if Input.is_action_just_pressed("weapon1") and knife_current == true:
		shotgun_current = true
		knife_current = false
		shotgunbetter.animation_player.play("get")
	elif Input.is_action_just_pressed("weapon3") and shotgun_current == true:
		shotgun_current = false
		knife_current = true
		shotgunbetter.animation_player.play("away")
		
#KNIFE
	if Input.is_action_just_pressed("weapon3") and knife_current == false:
		shotgun_current = false
		knife_current = true
		knife.animation_player.play("get")
	elif Input.is_action_just_pressed("weapon3") and shotgun_current == false:
		shotgun_current = true
		knife_current = false
		knife.animation_player.play("away")
		
