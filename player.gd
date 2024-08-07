class_name Player extends CharacterBody3D

@export var base_speed := 8.0
@onready var speed := base_speed
@onready var sprint_speed := base_speed * 1.5
@onready var footstep_timer: Timer = $FootstepTimer
var footstep_guid := FMODGuids.Events.FOOTSTEPS

@export var walk_footstep_time := 0.55
@export var run_footstep_time := 0.35

var jump_velocity := 4.5
var mobile := true
var mobilizing := true

var safe := false

var current_sigil_machine: SigilMachine = null

@export_group("Camera Settings")
var mouse_sensitivity:
	get: return LevelManager.mouse_sensitivity
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

func _ready() -> void:
	footstep_timer.wait_time = walk_footstep_time

func _input(event: InputEvent) -> void:
	if mobile and mobilizing:
		if event.is_action_pressed("sprint"):
			speed = sprint_speed
			footstep_timer.wait_time = run_footstep_time
		elif event.is_action_released("sprint"):
			speed = base_speed
			footstep_timer.wait_time = walk_footstep_time
	
	if event is InputEventMouseMotion and current_sigil_machine == null:
		orientation.rotation.y -= (event.relative.x / mouse_sensitivity)
		orientation.rotation.x -= (event.relative.y / mouse_sensitivity)
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
	#var dummy = Node3D.new()
	#add_child(dummy)
	#dummy.global_position = current_sigil_machine.camera_position.global_position
	#dummy.rotation = orientation.rotation
	##dummy.look_at(sigil_machine.sigil_mesh.global_position)
	#tween.tween_property(camera, "rotation:y", dummy.rotation.y, 0.8)
	#var point_infront = find_obj_position_infront()
	tween.tween_property(camera, "rotation:y", camera.rotation.y - transform.basis.z.signed_angle_to(camera.transform.basis.z ,Vector3.UP), 0.8)
	tween.tween_property(camera, "rotation:x", 0, 0.8)
	#dummy.queue_free()
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
		if footstep_timer.is_stopped(): 
			play_footstep()
			footstep_timer.start()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func stop_mobility() -> void:
	mobilizing = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, "speed", 0.0, 2.0).set_delay(3.0)
	
	await tween.finished
	mobile = false
	mobilizing = true
	
func resume_mobility() -> void:
	mobile = true
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, "speed", base_speed, 0.5)

func find_obj_position_infront() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var raycast_origin = camera.project_ray_origin(mouse_pos)
	var raycast_end = camera.project_position(mouse_pos, 1000)
	var query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var ray_info = space_state.intersect_ray(query)
	if !ray_info.is_empty():
		return ray_info.collider.get_parent().global_position
	else:
		print("didnt find collider to look when entering sigil machine")
		return Vector3.ZERO


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

func set_safe(seconds: float) -> void:
	safe = true
	await get_tree().create_timer(seconds).timeout
	safe = false

func _on_footstep_timer_timeout() -> void:
	if velocity != Vector3.ZERO:
		play_footstep()
	else:
		footstep_timer.stop()

func play_footstep() -> void:
	FMODRuntime.play_one_shot_id(footstep_guid)
