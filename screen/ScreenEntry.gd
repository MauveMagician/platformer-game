extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Preloader.player_spawned:
		var new_player = Preloader.player.instance()
		new_player.position = Preloader.player_map_position
		self.add_child(new_player)
		Preloader.player_spawned = true
		new_player.set_camera_limits()
