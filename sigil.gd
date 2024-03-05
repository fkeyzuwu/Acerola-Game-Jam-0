@tool
class_name Sigil extends ColorRect

@export var current_sigil_index := 0
@export_range(1.0, 7.0) var reveal_tween_duration := 4.0
@export_range(1.0, 3.0) var hide_tween_duration := 2.5

var animating := false

@export var get_sigil: bool:
	set(value):
		var sigil := {}
		sigil["p0"] = material.get_shader_parameter("p0")
		sigil["p1"] = material.get_shader_parameter("p1")
		sigil["s0"] = material.get_shader_parameter("s0")
		sigil["s1"] = material.get_shader_parameter("s1")
		sigil["m0"] = material.get_shader_parameter("m0")
		sigil["m1"] = material.get_shader_parameter("m1")
		sigil["twirl0"] = material.get_shader_parameter("twirl0")
		sigil["twirl1"] = material.get_shader_parameter("twirl1")
		sigil["rotate0"] = material.get_shader_parameter("rotate0")
		sigil["rotate1"] = material.get_shader_parameter("rotate1")
		sigils.append(sigil)
	get:
		return get_sigil

@export var animate: bool:
	set(value):
		reveal_sigil()
	get:
		return animate

const base_sigil := {
	"p0": Vector2.ZERO,
	"p1": Vector2.ZERO,
	"s0": 20.0,
	"s1": 20.0,
	"m0": 1,
	"m1": 1,
	"twirl0" : 0.0,
	"twirl1" : 0.0,
	"rotate0" : 0.0,
	"rotate1" : 0.0
}

@export var sigils: Array[Dictionary]

@onready var current_sigil := sigils[current_sigil_index].duplicate()

var tween: Tween

func _ready() -> void:
	for key in base_sigil:
		material.set_shader_parameter(key, base_sigil[key])
	
	material.set_shader_parameter("m0", current_sigil["m0"]) # Amount of thingies - dont animate cuz it jumps
	material.set_shader_parameter("m1", current_sigil["m1"]) # Amount of thingies - dont animate cuz it jumps

func reveal_sigil() -> void:
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	
	animating = true
	
	tween.tween_property(material, "shader_parameter/p0", current_sigil["p0"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/p1", current_sigil["p1"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/s0", current_sigil["s0"], reveal_tween_duration / 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "shader_parameter/s1", current_sigil["s1"], reveal_tween_duration / 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(material, "shader_parameter/twirl0", current_sigil["twirl0"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/twirl1", current_sigil["twirl1"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/rotate0", current_sigil["rotate0"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/rotate1", current_sigil["rotate1"], reveal_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_callback(func(): animating = false).set_delay(reveal_tween_duration)
	
func hide_sigil() -> void:
	for key in current_sigil: #save latest state
		current_sigil[key] = material.get_shader_parameter(key)
	
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	
	animating = true
	
	tween.tween_property(material, "shader_parameter/p0", base_sigil["p0"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/p1", base_sigil["p1"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/s0", base_sigil["s0"], hide_tween_duration).set_trans(Tween.TRANS_EXPO).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/s1", base_sigil["s1"], hide_tween_duration).set_trans(Tween.TRANS_EXPO).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(material, "shader_parameter/twirl0", base_sigil["twirl0"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/twirl1", base_sigil["twirl1"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/rotate0", base_sigil["rotate0"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/rotate1", base_sigil["rotate1"], hide_tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(func(): animating = false).set_delay(hide_tween_duration)

# Degree value is wrapped in -180 to 180 degrees.
func set_shader_parameter(param_name: String, degree_value: float, min_degree: float, max_degree: float, pmin = -2, pmax = 2) -> void:
	#var remapped_value = degree_value + 180 # from 0 to 360
	var remapped_value: float
	match param_name:
		"p0x", "p0y", "p1x", "p1y":
			remapped_value = remap(degree_value, min_degree, max_degree, pmin, pmax)
		"s0", "s1":
			remapped_value = remap(degree_value, min_degree, max_degree, 0.75, 3.0)
		"twirl0", "twirl1":
			remapped_value = remap(degree_value, min_degree, max_degree, -10, 10)
		"rotate0", "rotate1":
			remapped_value = remap(degree_value, min_degree, max_degree, 0.0, 1.0)
	
	if param_name.ends_with("x"):
		var param = param_name.substr(0,2)
		material.set_shader_parameter(param, Vector2(remapped_value, material.get_shader_param(param).y))
	elif param_name.ends_with("y"):
		var param = param_name.substr(0,2)
		material.set_shader_parameter(param, Vector2(material.get_shader_param(param).x, remapped_value))
	else:
		material.set_shader_parameter(param_name, remapped_value)
