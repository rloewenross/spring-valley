extends Node

var player_scene: PackedScene = preload("res://player.tscn")
var fake_player_scene: PackedScene = preload("res://fake_player.tscn")
@onready var hud_3d_scene = get_node("SubViewportContainer/HUD3D/HUD3DScene")
@onready var hud_2d_scene = get_node("SubViewportContainer/HUD2D/HUD2DScene")

var visibility_decreasing := false
var visibility_decreasing_speed: float = 3.0
var vignette_outer_radius: float = 20.0
var showing_ending := false
var ending_text_alpha := 0
var showing_ending_background := false
var show_ending_background_timer: float = 5.0
var showing_ending_text := false
var show_ending_text_timer: float = 5.0

var play_music_countdown := 3.0
var music_countdown: bool = false

var map: Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map = load_map(preload("res://levels/bottom.tscn"))
	map.name = "current_map"
	add_child(map)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if visibility_decreasing:
		vignette_outer_radius -= delta * visibility_decreasing_speed
		if vignette_outer_radius < 0.0:
			vignette_outer_radius = 0
		hud_2d_scene.vignette.material.set_shader_parameter("outer_radius", vignette_outer_radius)
		
		if vignette_outer_radius <= 0.0:
			visibility_decreasing = false
			showing_ending = true

			hud_2d_scene.ending_background.visible = true
			hud_2d_scene.ending_text.modulate.a = ending_text_alpha
			hud_2d_scene.ending_text.visible = true
			showing_ending = true
			showing_ending_background = true
			AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx"), true)

	if showing_ending:
		if showing_ending_background:
			show_ending_background_timer -= delta
			if show_ending_background_timer <= 0.0:
				showing_ending_background = false
				showing_ending_text = true
		elif showing_ending_text:
			hud_2d_scene.ending_text.modulate.a = 255
			show_ending_text_timer -= delta
			if show_ending_text_timer <= 0.0:
				showing_ending_text = false

	if music_countdown:
		play_music_countdown -= delta
		if play_music_countdown <= 0.0:
			get_node("Music").play()
			music_countdown = false

func load_map(map_scene: PackedScene) -> Node:
	var loaded_map := map_scene.instantiate()
	
	var map_children = loaded_map.find_children("*", "CollisionObject3D")
	for child in map_children:
		child.set_collision_layer_value(2, true)
	
	var spawnpoint := loaded_map.find_child("*_spawnpoint")
	if spawnpoint == null:
		return null
	
	var endarea := loaded_map.find_child("*_endarea")
	if endarea == null:
		return null
	endarea.body_entered.connect(on_end)

	get_node("SubViewportContainer").visible = false
	var fake_player = fake_player_scene.instantiate()
	fake_player.position = spawnpoint.position
	fake_player.rotation = spawnpoint.rotation
	fake_player.land_on_ground.connect(on_fake_player_land)
	loaded_map.add_child(fake_player)
	
	return loaded_map

func on_fake_player_land(node: CharacterBody3D):
	node.rotation.z = 0

	var player := player_scene.instantiate()
	map.add_child(player)
	player.name = "player"
	player.hud_3d_scene = hud_3d_scene
	player.global_position = node.global_position
	player.camera.basis = node.basis
	
	node.queue_free()

	get_node("SubViewportContainer").visible = true

	music_countdown = true

func on_end(body: Node3D):
	if body.name != "player":
		return
	
	visibility_decreasing = true
	hud_2d_scene.vignette.visible = true
	hud_2d_scene.vignette.material.set_shader_parameter("outer_radius", vignette_outer_radius)
