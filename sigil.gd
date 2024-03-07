class_name Sigil extends ColorRect

@export var current_sigil_index := 0
@export_range(1.0, 7.0) var reveal_tween_duration := 4.0
@export_range(1.0, 3.0) var hide_tween_duration := 2.5

var animating := false

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

@export var use_random_sigil := true
@export var premade_sigil: Dictionary
@export var starting_permutation: Dictionary

var target_sigil: Dictionary
var current_sigil: Dictionary

var tween: Tween

func _ready() -> void:
	if use_random_sigil:
		target_sigil = create_random_sigil()
		current_sigil = get_starting_sigil_permutation(target_sigil)
	else:
		target_sigil = premade_sigil
		current_sigil = starting_permutation		
	
	for key in base_sigil:
		material.set_shader_parameter(key, base_sigil[key])
	
	material.set_shader_parameter("m0", current_sigil["m0"]) # Amount of thingies - dont animate cuz it jumps
	material.set_shader_parameter("m1", current_sigil["m1"]) # Amount of thingies - dont animate cuz it jumps

func get_starting_sigil_permutation(target: Dictionary) -> Dictionary:
	var random_permutation := {}
	random_permutation["m0"] = target["m0"]
	random_permutation["m1"] = target["m1"]
	
	#check what actual sigil parameter the sigils stone are controlling
	
	if target["s0"] >= 1.875:
		random_permutation["s0"] = randf_range(0.75, 1.875)
	else:
		random_permutation["s0"] = randf_range(1.875, 3.0)
	
	if target["s1"] >= 1.875:
		random_permutation["s1"] = randf_range(0.75, 1.875)
	else:
		random_permutation["s1"] = randf_range(1.875, 3.0)
	
	if target["twirl0"] >= 0.0:
		random_permutation["twirl0"] = randf_range(-10.0, 0)
	else:
		random_permutation["twirl0"] = randf_range(0, 10.0)
	
	if target["twirl1"] >= 0.0:
		random_permutation["twirl1"] = randf_range(-10.0, 0)
	else:
		random_permutation["twirl1"] = randf_range(0, 10.0)
		
	if target["rotate0"] >= 0.5:
		random_permutation["rotate0"] = randf_range(0.0, 0.5)
	else:
		random_permutation["rotate0"] = randf_range(0.5, 1.0)
		
	if target["rotate1"] >= 0.5:
		random_permutation["rotate1"] = randf_range(0.0, 0.5)
	else:
		random_permutation["rotate1"] = randf_range(0.5, 1.0)
	
	return random_permutation

func create_random_sigil() -> Dictionary:
	var random_sigil := {}
	
	random_sigil["p0"] = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	random_sigil["p1"] = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	random_sigil["s0"] = randf_range(0.75, 3.0)
	random_sigil["s1"] = randf_range(0.75, 3.0)
	
	random_sigil["m0"] = randi_range(1, 5)
	random_sigil["m1"] = randi_range(1, 5)
	
	random_sigil["twirl0"] = randf_range(-10.0, 10.0)
	random_sigil["twirl1"] = randf_range(-10.0, 10.0)
	
	random_sigil["rotate0"] = randf_range(0.0, 1.0)
	random_sigil["rotate1"] = randf_range(0.0, 1.0)
	
	return random_sigil

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
	
	await tween.finished
	animating = false
	
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
	
	await tween.finished
	animating = false

# Degree value is wrapped in -180 to 180 degrees.
func set_shader_parameter(param_name: String, degree_value: float, min_degree: float, max_degree: float, pmin = -2, pmax = 2) -> void:
	var value = get_remapped_value(param_name, degree_value, min_degree, max_degree, pmin, pmax)
	if param_name.ends_with("x"):
		var param = param_name.substr(0,2)
		var current_y =  material.get_shader_parameter(param).y
		material.set_shader_parameter(param, Vector2(value, current_y))
		current_sigil[param] = Vector2(value, current_y)
	elif param_name.ends_with("y"):
		var param = param_name.substr(0,2)
		var current_x = material.get_shader_parameter(param).x
		material.set_shader_parameter(param, Vector2(current_x, value))
		current_sigil[param] = Vector2(current_x, value)
	else:
		material.set_shader_parameter(param_name, value)
		current_sigil[param_name] = value

func get_remapped_value(param_name: String, degree_value: float, min_degree: float, max_degree: float, pmin: float, pmax: float) -> float:
	match param_name:
		"p0x", "p0y", "p1x", "p1y": return remap(degree_value, min_degree, max_degree, pmin, pmax)
		"s0", "s1": return remap(degree_value, min_degree, max_degree, 3.0, 0.75)
		"twirl0", "twirl1": return remap(degree_value, min_degree, max_degree, 10, -10)
		"rotate0", "rotate1": return remap(degree_value, min_degree, max_degree, 1.0, 0.0)
	
	push_error("nonexistent parameter name passed in")
	return INF
	
