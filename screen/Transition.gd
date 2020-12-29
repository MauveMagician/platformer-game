tool

extends Area2D

export (String, FILE) var next_scene_path = ""
export (Vector2) var player_spawn_location = Vector2(0,0)

var active = true

func _get_configuration_warning():
	if next_scene_path == "":
		return "export var next_scene_path must be set"
	else:
		return ""

func transition(body):
	Preloader.call_deferred("go_to_scene", next_scene_path, player_spawn_location, body)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Transition_body_entered(body):
	if body.get_class() == "Player" and self.active:
		self.active = false
		self.set_deferred("monitoring", false)
		self.transition(body)
