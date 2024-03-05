class_name SigilStone extends Node3D

signal stone_pressed(sigil_stone: SigilStone)
signal stone_released()

func _on_sigil_stone_area_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	print("hello")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			print("stone pressed")
			stone_pressed.emit(self)
		elif event.is_released():
			stone_released.emit()
			print("stone released")
