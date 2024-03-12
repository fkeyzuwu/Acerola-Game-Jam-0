class_name Table extends Node3D

var light_tween: Tween
@onready var meshes := [$Top, $Base, $BaseCylindar]
@onready var light: OmniLight3D = $Light

@export var incative_color := Color.CADET_BLUE
@export var active_color := Color.SKY_BLUE
@export var solved_color := Color.AQUAMARINE

@export_range(0.1, 3.0) var light_up_duration := 2.0
@export_range(0.1, 3.0) var max_light_energy := 2.0

func light_up() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	light_tween.tween_property(light, "light_energy", max_light_energy , light_up_duration)
	for mesh in meshes:
		light_tween.tween_property(mesh.material, "albedo_color", active_color, light_up_duration)
	
func light_down() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	light_tween.tween_property(light, "light_energy", 0.0 , light_up_duration)
	for mesh in meshes:
		light_tween.tween_property(mesh.material, "albedo_color", incative_color, light_up_duration)
	
func machine_solved() -> void:
	if light_tween: light_tween.kill()
	light_tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	light_tween.tween_property(light, "light_energy", 0.0 , light_up_duration)
	for mesh in meshes:
		light_tween.tween_property(mesh.material, "albedo_color", solved_color, light_up_duration)
