class_name SquidEye extends Node3D

@export var max_horizontal = 0.3
@export var max_vertical = 0.45
@export var lerp_speed = 1
@onready var base_position := Vector2(position.x, position.y)
@onready var eye_light: SpotLight3D = $"Eye Light"

func look_at_player(player: Player) -> void:
	look_at(player.global_position)
	#var player_pos = Vector2(player.global_position.x, player.global_position.y)
	#var positionXY = Vector2(position.x, position.y)
	#var direction_to_player = positionXY.direction_to(player_pos)
	#var distance_to_player = positionXY.distance_to(player_pos)
	#var look_at_position = lerp(positionXY, base_position + direction_to_player * distance_to_player, get_process_delta_time() * lerp_speed)
	#position.x = base_position.x + clampf(look_at_position.x, base_position.x, base_position.x + max_horizontal)
	#position.x = base_position.y + clampf(look_at_position.y, base_position.y, base_position.y + max_vertical)
