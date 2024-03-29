class_name SigilMachine extends StaticBody3D

@export var slider_amount := 3

@onready var table: Table = $Table
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones
@onready var sigil_mesh: MeshInstance3D = $SigilTabletBackground/SigilMesh
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

@onready var camera_position: Node3D = $CameraPosition

var current_stone_sigil: SigilStone = null:
	set(value):
		if value != null and current_stone_sigil == null:
			move_stone_instance.start()
		elif value == null and current_stone_sigil != null:
			move_stone_instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)
			
		current_stone_sigil = value
	get:
		return current_stone_sigil
@export var radius = 0.6

@onready var camera := get_viewport().get_camera_3d()
@onready var player := get_tree().get_first_node_in_group("player") as Player
@onready var player_detection_area: Area3D = $PlayerDetectionArea

var locked := false
var player_solving := false

@export_range(0.01, 0.2) var sensitiveness := 0.1

signal solved

var move_stone_guid = FMODGuids.Events.MOVESTONE
@onready var move_stone_instance: EventInstance = FMODRuntime.create_instance_id(move_stone_guid)

# play these as oneshot
var machine_solved_guid
var sigil_enter_guid
var sigil_exit_guid

func _ready() -> void:
	deactivate(true)
	sigil_mesh.mesh.material.albedo_texture.viewport_path = sub_viewport.get_path()
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
			"p0x", "p1x": target_degrees = remap(param_value, -0.3, 1.1, min_degree, max_degree)
			"p0y", "p1y": target_degrees = remap(param_value, -0.3, 1.5, min_degree, max_degree)
			"s0", "s1": target_degrees = remap(param_value, 1.0, 0.75, min_degree, max_degree)
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
				var remapped_current_value_x = remap(current_value.x, -0.3, 1.1, 0.0, 1.0)
				var remapped_current_value_y = remap(current_value.y, -0.3, 1.5, 0.0, 1.0)
				var remapped_target_value_x = remap(target_value.x, -0.3, 1.1, 0.0, 1.0)
				var remapped_target_value_y = remap(target_value.y, -0.3, 1.5, 0.0, 1.0)
				if abs(remapped_current_value_x - remapped_target_value_x) >= sensitiveness:
					return false
				elif abs(remapped_current_value_y - remapped_target_value_y) >= sensitiveness:
					return false
				else:
					continue
			"s0", "s1":
				remapped_current_value = remap(current_value, 1.0, 0.75, 0.0, 1.0)
				remapped_target_value = remap(target_value, 1.0, 0.75, 0.0, 1.0)
			"twirl0", "twirl1":
				remapped_current_value = remap(current_value, 10, -10, 0.0, 1.0)
				remapped_target_value = remap(target_value, 10, -10, 0.0, 1.0)
			"rotate0", "rotate1":
				remapped_current_value = remap(current_value, 1.0, 0.0, 0.0, 1.0)
				remapped_target_value = remap(target_value, 1.0, 0.0, 0.0, 1.0)
				
		if abs(remapped_current_value - remapped_target_value) >= sensitiveness:
			return false
			
	return true

func _process(_delta: float) -> void:
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
			machine_solved()

func machine_solved() -> void:
	# Do solved animation
	# Stop allowing player to interact with machine anymore
	input_ray_pickable = false
	locked = true
	current_stone_sigil = null
	player_solving = false
	await sigil.tween_sigil_to_target()
	await get_tree().create_timer(0.5).timeout
	
	if player.current_sigil_machine != null:
		player.exit_sigil_machine()
	
	table.machine_solved()
	solved.emit()

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
	if !locked: activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
	if !locked: deactivate()

func activate() -> void:
	table.light_up()
	sigil.reveal_sigil()

func deactivate(init := false) -> void:
	table.light_down()
	if !init:
		sigil.hide_sigil()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		move_stone_instance.release()
