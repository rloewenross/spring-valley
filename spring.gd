extends CharacterBody3D

@onready var collision: CollisionShape3D = get_node("CollisionShape3D")

signal collided(normal: Vector3)


func _physics_process(delta: float) -> void:
	var move = move_and_collide(delta * velocity)
	if move:
		collided.emit(move.get_normal())
