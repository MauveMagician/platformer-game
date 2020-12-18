extends Position2D

onready var parent = self.get_parent()
var y_direction = 1

func _physics_process(_delta):
	update_pivot_angle()

func update_pivot_angle():
	self.rotation = parent.get("look_direction").angle()
	self.y_direction = parent.get("look_direction").y
	if abs(self.y_direction) > 0:
		$Lookup_Tween.stop_all()
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2(0,96*self.y_direction), 0.3,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Lookup_Tween.start()
	else:
		self.position = Vector2(0,0)
		$Camera_Offset.position = Vector2(48,0)
