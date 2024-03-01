extends Node3D

@export var event: EventAsset

func _ready() -> void:
	FMODRuntime.play_one_shot(event)
