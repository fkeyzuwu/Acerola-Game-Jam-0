class_name SigilMachineContainer extends Node3D

var machines_solved := 0

func _ready() -> void:
	for sigil_machine: SigilMachine in get_children():
		sigil_machine.solved.connect(_on_machine_solved)
	
func _on_machine_solved() -> void:
	machines_solved += 1
	if machines_solved == get_child_count():
		# all machines solved animations
		await LevelManager.fade_to_white()
		LevelManager.wake_up(true)
