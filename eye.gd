class_name SquidEye extends Node3D

func look_at_player(player: Player) -> void:
	look_at(player.global_position)
