extends Node3D


func _on_player_area_detector_body_entered(player: Player) -> void:
	player.safe = true


func _on_player_area_detector_body_exited(player: Player) -> void:
	player.safe = false
