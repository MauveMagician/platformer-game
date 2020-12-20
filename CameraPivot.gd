extends Position2D

onready var parent = self.get_parent()
var y_direction = 1
var ground_camera_mode = true

func _physics_process(_delta):
	update_pivot_angle()

func update_pivot_angle():
	self.y_direction = parent.get("look_direction").y
	if abs(self.y_direction) > 0:
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2($Camera_Offset.position.x,64*self.y_direction), 0.3,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Camera_Offset/Camera2D.drag_margin_h_enabled = false
		$Camera_Offset/Camera2D.drag_margin_v_enabled = false
		$Lookup_Tween.start()
	elif ground_camera_mode:
		self.position = Vector2(0,0)
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2(parent.get("look_direction").x*48, 64*self.y_direction), 0.3,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Camera_Offset/Camera2D.drag_margin_h_enabled = false
		$Camera_Offset/Camera2D.drag_margin_v_enabled = false
		$Lookup_Tween.start()
		$Camera_Offset.position = Vector2(parent.get("look_direction").x*48,0)
	else:
		$Camera_Offset.global_position = $Camera_Offset.global_position

func _on_Lookup_Tween_tween_completed(_object, _key):
	$Camera_Offset/Camera2D.drag_margin_h_enabled = true
	$Camera_Offset/Camera2D.drag_margin_v_enabled = true

func _on_Player_jumped():
	$Camera_Offset/Camera2D.drag_margin_h_enabled = false
	$Camera_Offset/Camera2D.drag_margin_v_enabled = false
	ground_camera_mode = false

func _on_Player_touched_ground():
	$Camera_Offset/Camera2D.drag_margin_h_enabled = true
	$Camera_Offset/Camera2D.drag_margin_v_enabled = true
	ground_camera_mode = true

func _on_Player_rotate():
	pass # Replace with function body.
