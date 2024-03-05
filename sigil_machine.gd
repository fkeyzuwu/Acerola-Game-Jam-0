class_name SigilMachine extends StaticBody3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var light_tween: Tween
@export_range(0.1, 1.0) var light_up_duration := 0.3
@onready var sigil: Sigil = $SubViewportContainer/SubViewport/Sigil
@onready var sigil_stones: Node3D = $SigilTabletBackground/SigilStones

@onready var camera_position: Node3D = $CameraPosition

var current_stone_sigil: SigilStone = null
@export var radius = 0.6

@onready var camera := get_viewport().get_camera_3d()

func _ready() -> void:
    deactivate()

func _process(delta: float) -> void:
    if current_stone_sigil:
        var space_state = get_world_3d().direct_space_state
        var mouse_pos = get_viewport().get_mouse_position()
        var length = camera.global_position.distance_to(current_stone_sigil.global_position)
        var from = camera.project_ray_origin(mouse_pos)
        var mouse_pos_real = from + camera.project_ray_normal(mouse_pos) * length
        mouse_pos_real.z = sigil_stones.global_position.z
        var mouse_pos_real_real = Vector2(mouse_pos_real.x, mouse_pos_real.y)
        var sigil_position = Vector2(sigil_stones.global_position.x, sigil_stones.global_position.y)
        var angle_center_to_mouse = sigil_position.direction_to(mouse_pos_real_real).angle() - PI / 2
        angle_center_to_mouse = wrapf(angle_center_to_mouse, -PI, PI)
        angle_center_to_mouse = rad_to_deg(angle_center_to_mouse)
        prints("angle to mouse: ", angle_center_to_mouse)
        current_stone_sigil.rotation_degrees.y = clampf(angle_center_to_mouse, -130.0, 130.0)
        if Input.is_action_just_released("mouse_left"):
            current_stone_sigil = null

func solved() -> void:
    if light_tween: light_tween.kill()
    light_tween = create_tween().set_trans(Tween.TRANS_SINE)
    light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.LIGHT_GREEN, light_up_duration)

func _on_player_detection_area_body_entered(_player: Player) -> void: #lightup
    activate()

func _on_player_detection_area_body_exited(_player: Player) -> void: #lightdown
    deactivate()

func activate() -> void:
    if light_tween: light_tween.kill()
    light_tween = create_tween().set_trans(Tween.TRANS_SINE)
    light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.RED, light_up_duration)
    sigil.reveal_sigil()

func deactivate() -> void:
    if light_tween: light_tween.kill()
    light_tween = create_tween().set_trans(Tween.TRANS_SINE)
    light_tween.tween_property(mesh_instance.mesh.material, "albedo_color", Color.PURPLE, light_up_duration)
    sigil.hide_sigil()

