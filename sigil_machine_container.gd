class_name SigilMachineContainer extends Node3D

var machines_solved := 0
@onready var omni_light_spread: OmniLight3D = $"../OmniLight3D"
@onready var omni_light_spot: OmniLight3D = $"../OmniLight3D2"

func _ready() -> void:
	for sigil_machine: SigilMachine in get_children():
		sigil_machine.solved.connect(_on_machine_solved)
	
func _on_machine_solved() -> void:
	machines_solved += 1
	if machines_solved == get_child_count():
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(omni_light_spread, "light_energy", 16.0, 3.0)
		tween.tween_property(omni_light_spot, "light_energy", 16.0, 3.0)
		await LevelManager.fade_to_white()
		LevelManager.wake_up(true)
