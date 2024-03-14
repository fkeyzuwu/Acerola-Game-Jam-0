extends Node3D

@export var ambience_event: EventAsset
var ambience_instance: EventInstance

var music_guid = FMODGuids.Events.MUSIC
var music_instance: EventInstance

@onready var squid_god: SquidGod = $SquidGod

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	ambience_instance = FMODRuntime.create_instance(ambience_event)
	ambience_instance.start()
	
	music_instance = FMODRuntime.create_instance_id(music_guid)
	music_instance.start()
	
	squid_god.start_interacting.connect(stop_ambience)
	squid_god.stop_interacting.connect(start_ambience)

func stop_ambience() -> void:
	ambience_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
	music_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)

func start_ambience() -> void:
	ambience_instance.start()
	music_instance.start()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		ambience_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		ambience_instance.release()
		music_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		music_instance.release()
