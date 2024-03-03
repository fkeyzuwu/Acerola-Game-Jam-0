class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $ActualSigil/SubViewportContainer/SubViewport/Sigil

func _ready() -> void:
	deactivate()

func show_ui() -> void:
	print("go inside sigil machine UI")
	
func hide_ui() -> void:
	pass

func solved() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.LIGHT_GREEN, light_up_duration)

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
	activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
	deactivate()

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
