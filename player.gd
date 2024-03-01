class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_group("Camera Settings")
@export var yaw_sensitivity := 600.0
@export var pitch_sensitivity := 600.0
@export_range(-90.0, -80.0, 1.0, "degrees") var min_pitch = -85.0
@export_range(80.0, 90.0, 1.0, "degrees") var max_pitch := 85.0
@export_range(60.0, 100.0) var normal_fov := 75.0

@onready var orientation: Node3D = $Orientation
@onready var camera: Camera3D = $Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		orientation.rotation.y -= (event.relative.x / yaw_sensitivity)
		orientation.rotation.x -= (event.relative.y / pitch_sensitivity)
		orientation.rotation_degrees.x = clamp(orientation.rotation_degrees.x, min_pitch, max_pitch)
		camera.rotation = Vector3(orientation.rotation.x, orientation.rotation.y, camera.rotation.z)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forwards", "backwards")
	var direction := (orientation.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
