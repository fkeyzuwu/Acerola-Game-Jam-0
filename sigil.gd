@tool
extends ColorRect

@export var current_sigil_index := 0
@export_range(1.0, 7.0) var tween_duration := 5.0

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
		animate_sigil()
	get:
		return animate

var base_sigil := {
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

func animate_sigil() -> void:
	for key in base_sigil:
		material.set_shader_parameter(key, base_sigil[key])
	
	var sigil = sigils[current_sigil_index]
	material.set_shader_parameter("m0", sigil["m0"]) # Amount of thingies - dont animate cuz it jumps
	material.set_shader_parameter("m1", sigil["m1"]) # Amount of thingies - dont animate cuz it jumps
	
	var tween = create_tween().set_parallel()
	tween.tween_property(material, "shader_parameter/p0", sigil["p0"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/p1", sigil["p1"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/s0", sigil["s0"], tween_duration / 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "shader_parameter/s1", sigil["s1"], tween_duration / 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(material, "shader_parameter/twirl0", sigil["twirl0"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/twirl1", sigil["twirl1"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/rotate0", sigil["rotate0"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(material, "shader_parameter/rotate1", sigil["rotate1"], tween_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
