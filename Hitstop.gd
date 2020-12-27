extends Node

onready var timer = self.get_child(0)
var can_unpause = true

func start(hitstop_time=0.2):
	timer.wait_time = hitstop_time
	timer.start()
	get_tree().paused = true

func _on_Hitstop_Time_timeout():
	if can_unpause:
		get_tree().paused = false
