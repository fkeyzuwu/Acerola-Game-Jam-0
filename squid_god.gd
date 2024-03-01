class_name SquidGod extends CharacterBody3D

@export var submerged_y_value = -300.0
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var eye: SquidEye = $Eye

var submerge_lerp_speed = 100.0
var emerge_lerp_speed = 50.0

var state := SquidState.Idle

enum SquidState {
	Idle,
	Submerge,
	Emerge,
	Messaging,
	ThorwingPlayer
}

func _ready() -> void:
	enter_state(SquidState.Submerge)

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
		SquidState.Messaging:
			await get_tree().create_timer(2.0).timeout
			# do whatever sigil message shit, then go back to submerge
		SquidState.ThorwingPlayer:
			pass # throw player animation type shit, then go back after to idle

func _process(_delta: float) -> void:
	match state:
		SquidState.Idle:
			pass # move around until seeing player
		SquidState.Submerge:
			pass
		SquidState.Emerge:
			var prev_y = global_position.y
			global_position = player.global_position - (player.orientation.basis.z * 45)
			global_position.y = prev_y
			look_at(player.global_position)
			eye.look_at_player(player)
		SquidState.Messaging:
			look_at(player.global_position)
			eye.look_at_player(player)
		SquidState.ThorwingPlayer:
			look_at(player.global_position)
			eye.look_at_player(player)
