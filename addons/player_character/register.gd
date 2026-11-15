@tool
extends EditorPlugin

const PLUGIN_PATH = "res://addons/player_character/"

func _enable_plugin() -> void:
	add_custom_type("PlayerCharacter", "CharacterBody3D", preload(PLUGIN_PATH + "player_character.gd"), preload(PLUGIN_PATH + "player_character.svg"))
	add_custom_type("PlayerCamera", "Camera3D", preload(PLUGIN_PATH + "player_camera.gd"), preload(PLUGIN_PATH + "player_camera.svg"))


func _disable_plugin() -> void:
	remove_custom_type("PlayerCharacter")
	remove_custom_type("PlayerCamera")
