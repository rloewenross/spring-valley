extends CharacterBody3D

signal land_on_ground(node: CharacterBody3D)

func _ready() -> void:
	get_node("FallingWind").play()

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta

	var prev_on_floor = is_on_floor()
	move_and_slide()
	if !prev_on_floor and is_on_floor():
		land_on_ground.emit(self)
