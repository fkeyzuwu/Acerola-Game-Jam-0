class_name SigilStone extends Node3D

signal stone_pressed(sigil_stone: SigilStone)
signal stone_released()

func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			stone_pressed.emit(self)
		elif event.is_released():
			stone_released.emit()
