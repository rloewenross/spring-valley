extends Camera3D
class_name PlayerCamera

@export var sensitivity: float = 50;
@export var max_vertical_camera_angle: float = 75.0;
@onready var max_vertical_camera_angle_rad = deg_to_rad(max_vertical_camera_angle)

var real_sensitivity: float;

func sens_to_real_sens():
    real_sensitivity = sensitivity / -10000

func _input(event: InputEvent) -> void:
    if not event is InputEventMouseMotion:
        return
    var mouse_event: InputEventMouseMotion = event

    var mouse_movement := mouse_event.screen_relative
    rotation.y += mouse_movement.x * real_sensitivity
    rotation.x = clampf(rotation.x + mouse_movement.y * real_sensitivity, -max_vertical_camera_angle_rad, max_vertical_camera_angle_rad)

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    sens_to_real_sens()