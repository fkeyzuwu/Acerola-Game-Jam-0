class_name SquidGod extends CharacterBody3D

@export var submerged_y_value = -300.0
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var eye: SquidEye = $SquidModel/SquidMesh/Eye/EyeBall
@onready var rotation_node: Node3D = $RotationNode
@onready var squid_model: Node3D = $SquidModel
@onready var squid_patrol_points: Node3D = $"../SquidPatrolPoints"
@onready var shore_position: Marker3D = $"../ShorePosition"
@onready var throw_wall_position: Marker3D = $"../ThrowWallPosition"

@onready var points = squid_patrol_points.get_children()
var current_point_index := 0
@export var idle_speed = 20.0
@export var rotate_lerp_speed = 1

var submerge_lerp_speed = 100.0
var emerge_lerp_speed = 50.0

@export_category("floating")
@export_range(0.0, 50.0) var float_freq := 50.0
@export_range(0.0, 50.0) var float_amp := 50.0
var bobbing_tween: Tween

var state := SquidState.Idle

var real := false

@onready var sigils: Array[ColorRect] = [%Sigil1, %Sigil2, %Sigil3]
@onready var sigil_meshes: Array[MeshInstance3D] = [%SigilMesh1, %SigilMesh2, %SigilMesh3]
@onready var sub_viewports: Array[SubViewport] = [%SubViewport1, %SubViewport2, %SubViewport3]

enum SquidState {
	Idle,
	Submerge,
	Emerge,
	Messaging,
	ThorwingPlayer
}

func _ready() -> void:
	await get_tree().process_frame
	for i in range(sigil_meshes.size()):
		var sigil_mesh = sigil_meshes[i]
		var sub_viewport = sub_viewports[i]
		sigil_mesh.mesh.material.albedo_texture.viewport_path = sub_viewport.get_path()
	
	var sigil_machines := get_tree().current_scene.find_child("SigilMachines").get_children()
	var sigils_used := 0
	for i in range(sigil_machines.size()): # remember to disable sigils by hand if needed
		var sigil_machine = sigil_machines[i] as SigilMachine
		var sigil: ColorRect = sigils[i]
		for key in sigil_machine.sigil.target_sigil:
			sigil.material.set_shader_parameter(key, sigil_machine.sigil.target_sigil[key])
		
		sigils_used += 1
	
	for i in range(sigils_used, sigils.size()):
		sigil_meshes[i].visible = false
		
	enter_state(SquidState.Idle)

func start_bobbing() -> void:
	bobbing_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	bobbing_tween.tween_property(squid_model, "position:y", 12.0, randf_range(2.0, 3.5))
	bobbing_tween.tween_property(squid_model, "position:y", -12.0, randf_range(2.0, 3.5))
	
func stop_bobbing() -> void:
	bobbing_tween.kill()

func enter_state(_state: SquidState) -> void:
	state = _state
	
	match state:
		SquidState.Idle:
			rotation_node.global_rotation = rotation
			if !player.mobile: player.resume_mobility()
			start_bobbing()
		SquidState.Submerge:
			stop_bobbing()
			await get_tree().create_timer(2.0).timeout
			var submerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			submerge_tween.tween_property(self, "global_position:y", submerged_y_value, 2.0);
			await submerge_tween.finished
			enter_state(SquidState.Emerge)
		SquidState.Emerge:
			player.stop_mobility()
			var emerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			global_position = player.global_position - (player.orientation.basis.z * 45)
			global_position.y = submerged_y_value
			emerge_tween.tween_property(self, "global_position:y", player.global_position.y, 5.0)
			await emerge_tween.finished
			enter_state(SquidState.Messaging)
		SquidState.Messaging:
			await get_tree().create_timer(4.0).timeout
			# do whatever sigil message shit, then go back to submerge
			enter_state(SquidState.ThorwingPlayer)
		SquidState.ThorwingPlayer:
			if !real:
				player.resume_mobility()
				var shore_pos = shore_position.global_position
				var direction_to_shore = player.global_position.direction_to(shore_pos)
				var distance_to_shore = player.global_position.distance_to(shore_pos)
				var peak_distance = distance_to_shore / 2
				var peak_position = direction_to_shore * peak_distance
				peak_position.y += player.global_position.y + 50
				
				var throw_tween = create_tween()
				throw_tween.tween_property(player, "global_position", peak_position, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
				throw_tween.tween_property(player, "global_position", shore_pos, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
				await throw_tween.finished
				await get_tree().create_timer(2.0).timeout
				real = true
				enter_state(SquidState.Idle)
			else:
				player.resume_mobility()
				var throw_wall_pos = throw_wall_position.global_position
				var direction_to_throw = player.global_position.direction_to(throw_wall_pos)
				var distance_to_throw = player.global_position.direction_to(throw_wall_pos)
				var peak_distance = distance_to_throw / 3
				var peak_position = direction_to_throw * peak_distance
				peak_position.y += player.global_position.y + throw_wall_pos.y + throw_wall_pos.y / 4
				
				var throw_tween = create_tween()
				throw_tween.tween_property(player, "global_position", peak_position, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
				throw_tween.tween_property(player, "global_position", throw_wall_pos, 2.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
				await throw_tween.finished
				player.should_wake_up = true
				# play aya sound and then player should fall to ground

func _process(delta: float) -> void:
	match state:
		SquidState.Idle:
			var target_pos = points[current_point_index].global_position
			var direction = global_position.direction_to(target_pos)
			look_at_target(target_pos, delta)
			global_position += -transform.basis.z * idle_speed * delta
			if global_position.y < squid_patrol_points.global_position.y:
				global_position.y += idle_speed * delta
			
			if global_position.distance_to(target_pos) <= 1.0:
				current_point_index += 1
				current_point_index %= points.size()
		SquidState.Submerge:
			look_at_target(player.global_position, delta)
		SquidState.Emerge:
			var prev_y = global_position.y
			global_position = player.global_position - (player.orientation.basis.z * 45)
			global_position.y = prev_y
			look_at_target(player.global_position, delta)
			eye.look_at_player(player)
		SquidState.Messaging:
			look_at_target(player.global_position, delta)
			eye.look_at_player(player)
		SquidState.ThorwingPlayer:
			look_at_target(player.global_position, delta)
			eye.look_at_player(player)
			#var direction_to_squid = player.global_position.direction_to(global_position)
			#player.basis.z = lerp(player.basis.z, -direction_to_squid, delta * 20)

func look_at_target(target: Vector3, delta: float) -> void:
	var rot = rotation_node.global_rotation
	rotation_node.look_at(target)
	rotation_node.global_rotation.x = rot.x
	rotation_node.global_rotation.z = rot.z
	global_rotation.y = lerp_angle(global_rotation.y, rotation_node.global_rotation.y, rotate_lerp_speed * delta)

func _on_initial_player_detector_body_entered(_player: Player) -> void:
	print("penis")
	if state == SquidState.Idle and !real:
		enter_state(SquidState.Submerge)

func _on_player_detection_area_body_entered(player: Player) -> void:
	if state == SquidState.Idle and real and !player.safe:
		enter_state(SquidState.Submerge)
