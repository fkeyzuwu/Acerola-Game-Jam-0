extends Control

var current_level := 0
var levels := ["res://level_0.tscn", "res://level_1.tscn", "res://level_2.tscn", "res://level_3.tscn"]
var can_go_to_sleep := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("fade_in_black_long")
	await animation_player.animation_finished
	if get_tree().current_scene.name == "BedroomNight":
		can_go_to_sleep = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left") and can_go_to_sleep:
		go_to_sleep()

func wake_up(success: bool) -> void:
	deferred_goto_scene.call_deferred("res://bedroom_morning.tscn")
	if success:
		current_level += 1
		animation_player.play("fade_in_white")
	else:
		var play = func(): get_tree().current_scene.animation_player.play("wake_up")
		play.call_deferred()
	
	await get_tree().create_timer(5.0).timeout
	
	animation_player.play("fade_out_black")
	await animation_player.animation_finished
	deferred_goto_scene.call_deferred("res://bedroom_night.tscn")
	animation_player.play("fade_in_black")
	await animation_player.animation_finished
	can_go_to_sleep = true

# when press left click, go to sleep
func go_to_sleep() -> void:
	can_go_to_sleep = false
	animation_player.play("fade_out_black")
	await animation_player.animation_finished
	deferred_goto_scene.call_deferred(levels[current_level])
	await get_tree().create_timer(1.0).timeout
	animation_player.play("fade_in_black_long")

func fade_to_white() -> void:
	animation_player.play("fade_out_white")
	await animation_player.animation_finished

func deferred_goto_scene(path: String):
	# Immediately free the current scene. There is no risk here because the
	# call to this method is already deferred.
	get_tree().current_scene.free()

	var packed_scene := ResourceLoader.load(path) as PackedScene

	var instanced_scene := packed_scene.instantiate()

	# Add it to the scene tree, as direct child of root
	get_tree().root.add_child(instanced_scene)

	# Set it as the current scene, only after it has been added to the tree
	get_tree().current_scene = instanced_scene
