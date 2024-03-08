class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones

@onready var camera_position: Node3D = $CameraPosition

var current_stone_sigil: SigilStone = null
@export var radius = 0.6

@onready var camera := get_viewport().get_camera_3d()
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var player_detection_area: Area3D = $PlayerDetectionArea

var locked := false
var player_solving := false

@export_range(0.01, 0.2) var sensitiveness := 0.05

func _ready() -> void:
	deactivate(true)
	for sigil_stone: SigilStone in sigil_stones.get_children():
		var param_name := sigil_stone.shader_parameter_name
		var param_value: float
		if param_name.ends_with("x"):
			param_value = sigil.current_sigil[param_name.substr(0, 2)].x
		elif param_name.ends_with("y"):
			param_value = sigil.current_sigil[param_name.substr(0, 2)].y
		else:
			param_value = sigil.current_sigil[param_name]
		var min_degree = sigil_stone.min_degrees
		var max_degree = sigil_stone.max_degrees
		var target_degrees: float
		
		match param_name:
			"p0x", "p0y", "p1x", "p1y": target_degrees = remap(param_value, -2.0, 2.0, min_degree, max_degree)
			"s0", "s1": target_degrees = remap(param_value, 3.0, 0.75, min_degree, max_degree)
			"twirl0", "twirl1": target_degrees = remap(param_value, 10.0, -10.0, min_degree, max_degree)
			"rotate0", "rotate1": target_degrees = remap(param_value, 1.0, 0.0, min_degree, max_degree)
		
		sigil_stone.rotation_degrees.y = target_degrees

func is_solved() -> bool:
	for key in sigil.current_sigil:
		var current_value = sigil.current_sigil[key]
		var target_value = sigil.target_sigil[key]
		var remapped_current_value: float
		var remapped_target_value: float
		match key:
			"p0", "p1":
				var remapped_current_value_x = remap(current_value.x, -2.0, 2.0, 0.0, 1.0)
				var remapped_current_value_y = remap(current_value.y, -2.0, 2.0, 0.0, 1.0)
				var remapped_target_value_x = remap(target_value.x, -2.0, 2.0, 0.0, 1.0)
				var remapped_target_value_y = remap(target_value.y, -2.0, 2.0, 0.0, 1.0)
				if abs(remapped_current_value_x - remapped_target_value_x) >= sensitiveness:
					return false
				elif abs(remapped_current_value_y - remapped_target_value_y) >= sensitiveness:
					return false
				else:
					continue
			"s0", "s1":
				remapped_current_value = remap(current_value, 3.0, 0.75, 0.0, 1.0)
				remapped_target_value = remap(target_value, 3.0, 0.75, 0.0, 1.0)
			"twirl0", "twirl1":
				remapped_current_value = remap(current_value, 10, -10, 0.0, 1.0)
				remapped_target_value = remap(target_value, 10, -10, 0.0, 1.0)
			"rotate0", "rotate1":
				remapped_current_value = remap(current_value, 1.0, 0.0, 0.0, 1.0)
				remapped_target_value = remap(target_value, 1.0, 0.0, 0.0, 1.0)
				
		if abs(remapped_current_value - remapped_target_value) >= sensitiveness:
			return false
			
	return true

func _process(delta: float) -> void:
	if player_solving:
		for sigil_stone: SigilStone in sigil_stones.get_children():
			sigil.set_shader_parameter(
				sigil_stone.shader_parameter_name,
				sigil_stone.rotation_degrees.y,
				sigil_stone.min_degrees,
				sigil_stone.max_degrees)
	
	if current_stone_sigil:
		if Input.is_action_just_released("mouse_left"):
			current_stone_sigil = null
			return
		
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()
		var length = camera.global_position.distance_to(current_stone_sigil.global_position)
		var from = camera.project_ray_origin(mouse_pos)
		var mouse_pos_real = from + camera.project_ray_normal(mouse_pos) * length
		mouse_pos_real.z = sigil_stones.global_position.z
		var mouse_pos_real_real = Vector2(mouse_pos_real.x, mouse_pos_real.y)
		var sigil_position = Vector2(sigil_stones.global_position.x, sigil_stones.global_position.y)
		var angle_center_to_mouse = sigil_position.direction_to(mouse_pos_real_real).angle() - PI / 2
		angle_center_to_mouse = wrapf(angle_center_to_mouse, -PI, PI)
		angle_center_to_mouse = rad_to_deg(angle_center_to_mouse)
		current_stone_sigil.rotation_degrees.y = clampf(
			angle_center_to_mouse, current_stone_sigil.min_degrees, current_stone_sigil.max_degrees)
		sigil.set_shader_parameter(
			current_stone_sigil.shader_parameter_name, current_stone_sigil.rotation_degrees.y, current_stone_sigil.min_degrees, current_stone_sigil.max_degrees)
		
		if is_solved():
			solved()

func solved() -> void:
	# Do solved animation
	# Stop allowing player to interact with machine anymore
	input_ray_pickable = false
	locked = true
	current_stone_sigil = null
	await get_tree().create_timer(1.0).timeout
	
	if player.current_sigil_machine != null:
		player.exit_sigil_machine()
	
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.LIGHT_GREEN, light_up_duration)

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
	if !locked: activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
	if !locked: deactivate()

func activate() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.RED, light_up_duration)
	sigil.reveal_sigil()

func deactivate(init := false) -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.PURPLE, light_up_duration)
	if !init:
		sigil.hide_sigil()

