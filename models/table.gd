class_name Table extends Node3D

var light_tween: Tween
@onready var meshes := [$Top, $Base, $BaseCylindar]

@export var incative_color := Color.CADET_BLUE
@export var active_color := Color.SKY_BLUE
@export var solved_color := Color.AQUAMARINE

@export_range(0.1, 1.0) var light_up_duration := 0.3

func light_up() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	for mesh in meshes:
		light_tween.tween_property(mesh.mesh.material, "albedo_color", active_color, light_up_duration)
	
func light_down() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	for mesh in meshes:
		light_tween.tween_property(mesh.mesh.material, "albedo_color", incative_color, light_up_duration)
	
func machine_solved() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE)
	for mesh in meshes:
		light_tween.tween_property(mesh.mesh.material, "albedo_color", solved_color, light_up_duration)
