extends Node

var axe_projectile
var fireball_projectile
var player

# warning-ignore:unused_class_variable
var pocket = []
# warning-ignore:unused_class_variable
var player_map_position = Vector2(32,95)

# warning-ignore:unused_class_variable
var player_spawned = false

func go_to_scene(scene_path : String, player_spawn_location : Vector2, player_reference : Node2D):
	self.pocket.append(player_reference)
	self.player_map_position = player_spawn_location
	player_reference.get_parent().remove_child(player_reference)
	if get_tree().change_scene(scene_path) != OK:
		print("unavailable scene")
	else:
		yield(get_tree(), "idle_frame")
		var instanced_player = self.pocket.pop_front()
		instanced_player.global_position = self.player_map_position
		get_tree().get_root().get_node("Game").add_child(instanced_player)
		instanced_player.set_camera_limits()

func _ready():
	player = preload("res://Player.tscn")
	axe_projectile = preload("res://Axe_Projectile.tscn")
	fireball_projectile = preload("res://Fireball_Projectile.tscn")
