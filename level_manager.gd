extends Control

var current_level := 0
var can_go_to_sleep := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	if get_tree().current_scene.name == "BedroomNight":
		can_go_to_sleep = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left") and can_go_to_sleep:
		go_to_sleep()

func wake_up(success: bool) -> void:
	get_tree().change_scene_to_file("res://bedroom_morning.tscn")
	if success:
		current_level += 1
	else:
		pass
		#add camera animation and HUUHHHH HUHHH sfx
	
	await get_tree().create_timer(5.0).timeout
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://bedroom_night.tscn")
	animation_player.play("fade_in")
	await animation_player.animation_finished
	can_go_to_sleep = true

# when press left click, go to sleep
func go_to_sleep() -> void:
	can_go_to_sleep = false
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://world.tscn")
	animation_player.play("fade_in")
