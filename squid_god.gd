class_name SquidGod extends CharacterBody3D

@export var submerged_y_value = -300.0
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var eye: SquidEye = $SquidModel/SquidMesh/Eye/EyeBall
@onready var rotation_node: Node3D = $RotationNode
@onready var squid_model: Node3D = $SquidModel
@onready var squid_patrol_points: Node3D = $"../SquidPatrolPoints"

@onready var points = squid_patrol_points.get_children()
var current_point_index := 0
@export var idle_speed = 20.0
@export var rotate_lerp_speed = 1

var submerge_lerp_speed = 100.0
var emerge_lerp_speed = 50.0

@export_category("floating")
@export_range(0.0, 50.0) var float_freq := 50.0
@export_range(0.0, 50.0) var float_amp := 50.0

var state := SquidState.Idle

enum SquidState {
	Idle,
	Submerge,
	Emerge,
	Messaging,
	ThorwingPlayer
}

func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(squid_model, "position:y", 12.0, randf_range(2.0, 3.5))
	tween.tween_property(squid_model, "position:y", -12.0, randf_range(2.0, 3.5))
	
func enter_state(_state: SquidState) -> void:
	state = _state
	
	match state:
		SquidState.Idle:
			if !player.mobile: player.resume_mobility()
		SquidState.Submerge:
			var submerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			submerge_tween.tween_property(self, "global_position:y", submerged_y_value, 2.0);
			await submerge_tween.finished
			enter_state(SquidState.Emerge)
		SquidState.Emerge:
			player.stop_mobility()
			var emerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			global_position = player.global_position - (player.orientation.basis.z * 45)
			global_position.y = submerged_y_value
			emerge_tween.tween_property(self, "global_position:y", player.global_position.y, 4.0)
			await emerge_tween.finished
			await get_tree().create_timer(2.0).timeout
			enter_state(SquidState.Messaging)
		SquidState.Messaging:
			await get_tree().create_timer(2.0).timeout
			# do whatever sigil message shit, then go back to submerge
		SquidState.ThorwingPlayer:
			pass # throw player animation type shit, then go back after to idle

func _process(delta: float) -> void:
	match state:
		SquidState.Idle:
			var target_pos = points[current_point_index].global_position
			var direction = global_position.direction_to(target_pos)
			look_at_target(target_pos, delta)
			global_position += -transform.basis.z * idle_speed * delta
			
			if global_position.distance_to(target_pos) <= 1.0:
				current_point_index += 1
				current_point_index %= points.size()
		SquidState.Submerge:
			pass
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

func look_at_target(target: Vector3, delta: float) -> void:
	var rot = rotation_node.global_rotation
	rotation_node.look_at(target)
	rotation_node.global_rotation.x = rot.x
	rotation_node.global_rotation.z = rot.z
	rotation = lerp(global_rotation, rotation_node.global_rotation, rotate_lerp_speed * delta)

func _on_player_detection_area_body_entered(player: Player) -> void:
	print("player entered forbidden area O;")
