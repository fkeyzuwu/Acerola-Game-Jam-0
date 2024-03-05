class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones

var current_stone_sigil: SigilStone = null
@export var radius = 0.6

func _ready() -> void:
	for sigil_stone: SigilStone in sigil_stones.get_children():
		sigil_stone.stone_pressed.connect(_on_stone_pressed)
	deactivate()

func _process(delta: float) -> void:
	if current_stone_sigil:
		current_stone_sigil.rotate_y(PI * delta)
		if Input.is_action_just_released("mouse_left"):
			current_stone_sigil = null

func solved() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.LIGHT_GREEN, light_up_duration)

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
	activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
	deactivate()

func _on_stone_pressed(sigil_stone: SigilStone) -> void:
	current_stone_sigil = sigil_stone

func _on_stone_released() -> void:
	current_stone_sigil = null

func activate() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.RED, light_up_duration)
	sigil.reveal_sigil()

func deactivate() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.PURPLE, light_up_duration)
	sigil.hide_sigil()
