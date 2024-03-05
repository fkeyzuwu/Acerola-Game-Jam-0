class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones

@onready var camera_position: Node3D = $CameraPosition

var current_stone_sigil: SigilStone = null
@export var radius = 0.6

func _ready() -> void:
	deactivate()

func _process(delta: float) -> void:
	if current_stone_sigil:
		var mouse_pos = get_viewport().get_mouse_position()
		var angle = mouse_pos.angle_to(Vector2(current_stone_sigil.global_position.x, current_stone_sigil.global_position.z))
		current_stone_sigil.rotation.y = angle
		if Input.is_action_just_released("mouse_left"):
			current_stone_sigil = null

func solved() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.LIGHT_GREEN, light_up_duration)

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
	activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
	deactivate()

func activate() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.RED, light_up_duration)
	sigil.reveal_sigil()

func deactivate() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.PURPLE, light_up_duration)
	sigil.hide_sigil()

