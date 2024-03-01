class_name SquidGod extends CharacterBody3D

@export var submerged_y_value = -300
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var eye: SquidEye = $Eye

func _ready() -> void:
	submerge()

func _process(_delta: float) -> void:
	look_at(player.global_position)
	eye.look_at_player(player)

func submerge() -> void:
	while(player):
		var submerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		submerge_tween.tween_property(self, "global_position:y", submerged_y_value, 2.0);
		await submerge_tween.finished
		
		var emerge_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		global_position = player.global_position - (player.orientation.basis.z * 45)
		global_position.y = submerged_y_value
		emerge_tween.tween_property(self, "global_position:y", player.global_position.y, 4.0)
		await emerge_tween.finished
		await get_tree().create_timer(2.0).timeout
