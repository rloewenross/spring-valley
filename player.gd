extends PlayerCharacter

var spring_scene: PackedScene = preload("res://spring.tscn")
var spring: CharacterBody3D

var hud_3d_scene: Node3D
@export var spring_velocity: float = 20.0
@export var use_spring_buffer_amount_frames: float = 6.0
@export var max_spring_distance: float = 10.0
@onready var use_spring_buffer_amount = use_spring_buffer_amount_frames / 60.0
var use_spring_buffer: float = 0.0
@export var use_spring_delay_amount: float = 1.0
var use_spring_delay: float = 0.0
var spring_finished: bool = true
var spring_throw_origin: Vector3
@export var spring_bounce_amount: float = 8.0

var finished_climbing_sunction_point := Vector3(-141.0, 29.5, -15.0)

@onready var spring_boing: AudioStreamPlayer = get_node("SpringBoing")
@onready var hit_ground: AudioStreamPlayer = get_node("HitGround")

func _ready() -> void:
	pass

func throw_spring():
	spring = spring_scene.instantiate()
	spring.collided.connect(_on_spring_collided)
	add_sibling(spring)

	spring_finished = false

	hud_3d_scene.spring.visible = false

	spring.basis = camera.basis.rotated(camera.basis.x, PI / 2)
	spring.global_position = camera.global_position
	spring.velocity = (camera.basis * Vector3.FORWARD).normalized() * spring_velocity

	spring_throw_origin = spring.global_position
	
	spring.visible = true
	spring.collision.disabled = false
	
	use_spring_delay = use_spring_delay_amount


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		use_spring_buffer = use_spring_buffer_amount

	if use_spring_buffer > 0.0:
		if use_spring_delay <= 0.0:
			use_spring_buffer = 0.0
			throw_spring()
		else:
			use_spring_buffer -= delta

	if use_spring_delay > 0.0 && spring_finished:
		use_spring_delay -= delta
		if use_spring_delay <= 0:
			hud_3d_scene.spring.visible = true

	if !spring_finished && \
			spring_throw_origin.distance_to(spring.global_position) > max_spring_distance:
		spring.queue_free()
		spring_finished = true

	if global_position.y > 28.5:
		var suction_direction = (finished_climbing_sunction_point - global_position).normalized()
		velocity += suction_direction * 10.0 * delta

	handle_player_character_physics(delta)


func _on_spring_collided(normal: Vector3) -> void:
	spring.queue_free()
	spring_finished = true
	
	if velocity.y < 0:
		velocity.y = 0
	velocity += normal.slerp(spring.velocity.normalized() * -1, 0.5) * spring_bounce_amount
	
	spring_boing.play()


func _on_land_on_ground() -> void:
	hit_ground.play()
