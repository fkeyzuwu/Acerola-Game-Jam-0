class_name Player extends CharacterBody3D

var base_speed := 10.0
@onready var speed := base_speed
var jump_velocity := 4.5
var mobile := true

var safe := false

var current_sigil_machine: SigilMachine = null

@export_group("Camera Settings")
@export var base_yaw_sensitivity := 600.0
@export var base_pitch_sensitivity := 600.0
@onready var yaw_sensitivity := base_yaw_sensitivity
@onready var pitch_sensitivity := base_pitch_sensitivity
@export_range(-90.0, -80.0, 1.0, "degrees") var min_pitch = -85.0
@export_range(80.0, 90.0, 1.0, "degrees") var max_pitch := 85.0
@export_range(60.0, 100.0) var normal_fov := 75.0

@onready var orientation: Node3D = $Orientation
@onready var camera: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var crosshair: TextureRect = $Crosshair

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var should_wake_up := false

func _input(event: InputEvent) -> void:
	if event.is_action("increase_speed"):
		speed += 2
	elif event.is_action("decrease_speed"):
		speed -= 2
	
	if event is InputEventMouseMotion and current_sigil_machine == null:
		orientation.rotation.y -= (event.relative.x / yaw_sensitivity)
		orientation.rotation.x -= (event.relative.y / pitch_sensitivity)
		orientation.rotation_degrees.x = clamp(orientation.rotation_degrees.x, min_pitch, max_pitch)
		camera.rotation = Vector3(orientation.rotation.x, orientation.rotation.y, camera.rotation.z)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if current_sigil_machine == null and raycast.is_colliding():
				var sigil_machine = raycast.get_collider()
				if sigil_machine is SigilMachine and !sigil_machine.locked:
					enter_sigil_machine(sigil_machine)
			elif current_sigil_machine:
				if !current_sigil_machine.sigil.animating and !current_sigil_machine.locked:
					current_sigil_machine.current_stone_sigil = try_get_sigil_stone()
		elif event.button_index == MOUSE_BUTTON_RIGHT and current_sigil_machine != null:
			exit_sigil_machine()

func enter_sigil_machine(sigil_machine: SigilMachine) -> void:
	current_sigil_machine = sigil_machine
	current_sigil_machine.input_ray_pickable = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, "global_position", current_sigil_machine.camera_position.global_position, 0.8)
	#var target_rotation = camera.rotation.y - transform.basis.z.signed_angle_to(camera.transform.basis.z ,Vector3.UP) + sigil_machine.rotation.y
	var dummy = Node3D.new()
	add_child(dummy)
	dummy.global_position = current_sigil_machine.camera_position.global_position
	dummy.rotation = orientation.rotation
	dummy.look_at(sigil_machine.sigil_mesh.global_position)
	tween.tween_property(camera, "rotation:y", dummy.rotation.y, 0.8)
	tween.tween_property(camera, "rotation:x", 0, 0.8)
	dummy.queue_free()
	crosshair.visible = false
	current_sigil_machine.player_solving = true
	
func exit_sigil_machine() -> void:
	current_sigil_machine.input_ray_pickable = !current_sigil_machine.locked
	current_sigil_machine.player_solving = false
	current_sigil_machine = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	orientation.rotation = camera.rotation
	crosshair.visible = true

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	if !mobile:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif is_on_floor() and should_wake_up:
		LevelManager.wake_up(false)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	var direction := (orientation.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and current_sigil_machine == null:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func stop_mobility() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, "speed", 0.0, 2.0).set_delay(3.0)
	
	await tween.finished
	mobile = false
	
func resume_mobility() -> void:
	mobile = true
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, "speed", base_speed, 0.5)

func try_get_sigil_stone() -> SigilStone:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var raycast_origin = camera.project_ray_origin(mouse_pos)
	var raycast_end = camera.project_position(mouse_pos, 1000)
	var query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end, 8)
	query.collide_with_areas = true
	var ray_info = space_state.intersect_ray(query)
	if !ray_info.is_empty():
		return ray_info.collider.get_parent()
	else:
		print("didnt find collider")
		return null
