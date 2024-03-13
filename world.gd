extends Node3D

@export var ambience_event: EventAsset
var ambience_instance: EventInstance

@onready var squid_god: SquidGod = $SquidGod

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ambience_instance = FMODRuntime.create_instance(ambience_event)
	ambience_instance.start()
	squid_god.start_interacting.connect(stop_ambience)
	squid_god.stop_interacting.connect(start_ambience)

func stop_ambience() -> void:
	ambience_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)

func start_ambience() -> void:
	ambience_instance.start()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ambience_instance.release()
