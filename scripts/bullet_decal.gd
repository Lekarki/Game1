extends Node3D

@onready var gpuparticles = $GPUParticles3D

func _ready():
	gpuparticles.emitting = true

func _on_timer_timeout():
	queue_free()
