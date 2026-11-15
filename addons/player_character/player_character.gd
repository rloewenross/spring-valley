extends CharacterBody3D
class_name PlayerCharacter

@export var friction: float = 0.90
@export var speed: float = 50.0
@export var air_slowdown: float = 25.0
@export var jump_velocity: float = 5.0
@export var max_air_turn_angle_per_frame: float = 5.0
@export var buffer_frames: float = 6.0
@export var coyote_frames: float = 6.0
@export var camera: PlayerCamera

@onready var max_air_turn_angle: float = deg_to_rad(max_air_turn_angle_per_frame) * 60.0

var jump_buffer: float = 0.0
var coyote_buffer: float = 0.0

signal land_on_ground

func handle_player_character_physics(delta: float):
	velocity += get_gravity() * delta

	if is_on_floor():
		velocity.x *= friction
		velocity.z *= friction

	var input_direction := Input.get_vector("left","right","forward","backward") # Y will map to Z
	input_direction = input_direction.normalized().rotated(-camera.rotation.y)

	if is_on_floor():
		velocity.x += input_direction.x * speed * delta
		velocity.z += input_direction.y * speed * delta
	else:
		if !input_direction.is_zero_approx():
			var velocity_2d := Vector2(velocity.x, velocity.z)
			var current_direction := velocity_2d.normalized()
			var angle := current_direction.angle_to(input_direction)

			if abs(angle) > 7 * PI / 16:
				var subtract_velocity := input_direction * air_slowdown * delta
				if subtract_velocity.length() > velocity_2d.length():
					velocity.x = 0
					velocity.z = 0
				else:
					velocity_2d += subtract_velocity
					velocity.x = velocity_2d.x
					velocity.z = velocity_2d.y
			else:
				if angle > 0:
					angle = min(angle, max_air_turn_angle * delta)
				elif angle < 0:
					angle = max(angle, -max_air_turn_angle * delta)
				velocity_2d = velocity_2d.rotated(angle)
				velocity.x = velocity_2d.x
				velocity.z = velocity_2d.y

	if coyote_buffer > 0.0:
		coyote_buffer -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer = buffer_frames / 60.0
	if jump_buffer > 0.0:
		if is_on_floor() or coyote_buffer > 0.0:
			coyote_buffer = 0.0
			velocity.y += jump_velocity
			jump_buffer = 0
		else:
			jump_buffer -= delta

	var prev_on_floor := is_on_floor()
	move_and_slide()

	if !prev_on_floor and is_on_floor():
		land_on_ground.emit()
	elif prev_on_floor and !is_on_floor():
		coyote_buffer = coyote_frames / 60.0

func _physics_process(delta: float):
	handle_player_character_physics(delta)
