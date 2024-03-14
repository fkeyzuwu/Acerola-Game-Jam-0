extends Control

var current_level := 0
var levels := ["res://level_0.tscn", "res://level_1.tscn", "res://level_2.tscn", "res://level_3.tscn"]
var can_go_to_sleep := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var options_menu: Control = $CanvasLayer/OptionsMenu
@onready var game_over_label: Label = $CanvasLayer/CenterContainer/GameOverLabel

var mouse_sensitivity := 600.0
var brightness: float

var is_options_open := false

var game_over := false

func _ready() -> void:
	options_menu.visible = false
	animation_player.play("fade_in_black_long")
	await animation_player.animation_finished
	if get_tree().current_scene.name == "BedroomNight":
		can_go_to_sleep = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left") and game_over:
		get_tree().quit()
	elif event.is_action_pressed("mouse_left") and can_go_to_sleep:
		go_to_sleep()
	elif event.is_action_pressed("quit"):
		if !is_options_open:
			open_options()
		else:
			close_options()

func wake_up(success: bool) -> void:
	deferred_goto_scene.call_deferred("res://bedroom_morning.tscn")
	if success:
		current_level += 1
		animation_player.play("fade_in_white")
	else:
		var play = func(): get_tree().current_scene.animation_player.play("wake_up")
		play.call_deferred()
		animation_player.play("RESET")
		FMODRuntime.play_one_shot_id(FMODGuids.Events.HEAVYBREATHING)
	
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

func fade_to_black() -> void:
	animation_player.play("fade_out_black")

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

func open_options() -> void:
	is_options_open = true
	options_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func close_options() -> void:
	is_options_open = false
	options_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity = 2000.0 - value

func _on_resume_button_pressed() -> void:
	close_options()

func _on_quit_button_pressed() -> void:
	get_tree().quit.call_deferred()

func you_didnt_get_out_of_my_dream() -> void:
	var text = "you didn't get out of my dream..."
	for i in range(text.length()):
		game_over_label.text += text[i]
		await get_tree().create_timer(0.1)
		
	game_over = true
