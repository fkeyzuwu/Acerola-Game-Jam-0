class_name SigilStone extends Node3D

signal stone_pressed(sigil_stone: SigilStone)

func _on_sigil_stone_area_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			print("stone pressed")
			stone_pressed.emit(self)
