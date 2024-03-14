class_name SigilMachineContainer extends Node3D

var machines_solved := 0
@onready var omni_light_spread: OmniLight3D = $"../OmniLight3D"
@onready var omni_light_spot: OmniLight3D = $"../OmniLight3D2"

signal all_solved

func _ready() -> void:
	for sigil_machine: SigilMachine in get_children():
		sigil_machine.solved.connect(_on_machine_solved)
	
func _on_machine_solved() -> void:
	machines_solved += 1
	if machines_solved == get_child_count():
		all_solved.emit()
		var instance_machine_solved := FMODRuntime.create_instance_id(FMODGuids.Events.SIGILMACHINESOLVED)
		instance_machine_solved.start()
		instance_machine_solved.release()
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(omni_light_spread, "light_energy", 16.0, 3.0)
		tween.tween_property(omni_light_spot, "light_energy", 16.0, 3.0)
		await LevelManager.fade_to_white()
		if LevelManager.current_level == 2:
			instance_machine_solved.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
			LevelManager.animation_player.play("RESET")
			omni_light_spread.light_energy = 0.872
			omni_light_spot.light_energy = 0.872
			var squid_god = get_tree().current_scene.find_child("SquidGod") as SquidGod
			await get_tree().create_timer(1.0).timeout
			squid_god.super_real = true
			squid_god.enter_state(SquidGod.SquidState.Emerge)
		else:
			LevelManager.wake_up(true)
