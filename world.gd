extends Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"): 
		await get_tree().process_frame
		get_tree().quit()

