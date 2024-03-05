class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones

var current_stone_sigil: SigilStone = null
@export var radius = 0.6

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	deactivate()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and player.current_sigil_machine == self:
		if event.is_pressed():
			current_stone_sigil = try_get_sigil_stone()
		elif event.is_released():
			current_stone_sigil = null

func try_get_sigil_stone() -> SigilStone:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_start = player.camera.project_ray_origin(mouse_pos)
	var ray_end = ray_start + player.camera.project_ray_normal(mouse_pos) * 100.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 8)
	query.collide_with_areas = true
	var ray_info = space_state.intersect_ray(query)
	if !ray_info.is_empty():
		return ray_info.collider.get_parent()
	else:
		return null

func _process(delta: float) -> void:
	if current_stone_sigil:
		current_stone_sigil.rotate_y(PI * delta)

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
