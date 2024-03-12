extends Area3D

func _on_player_entered(player: Player) -> void:
	player.safe = true

func _on_player_exited(player: Player) -> void:
	player.safe = false
