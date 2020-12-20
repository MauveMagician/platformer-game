extends Position2D

export var interpolate_cam_time = 0.3
onready var parent = self.get_parent()
var y_direction = 1
var ground_camera_mode = true


func _physics_process(_delta):
	update_pivot_angle()

func update_pivot_angle():
	self.y_direction = parent.get("look_direction").y
	if abs(self.y_direction) > 0:
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2($Camera_Offset.position.x,64*self.y_direction), interpolate_cam_time,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Camera_Offset/Camera2D.drag_margin_h_enabled = false
		$Camera_Offset/Camera2D.drag_margin_v_enabled = false
		$Lookup_Tween.start()
	elif ground_camera_mode:
		self.position = Vector2(0,0)
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2(parent.get("look_direction").x*32, 64*self.y_direction), interpolate_cam_time,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Camera_Offset/Camera2D.drag_margin_h_enabled = false
		$Camera_Offset/Camera2D.drag_margin_v_enabled = false
		$Lookup_Tween.start()
		$Camera_Offset.position = Vector2(parent.get("look_direction").x*32,0)
	else:
		$Camera_Offset.global_position = $Camera_Offset.global_position

func _on_Lookup_Tween_tween_completed(_object, _key):
	$Camera_Offset/Camera2D.drag_margin_h_enabled = true
	$Camera_Offset/Camera2D.drag_margin_v_enabled = true

func _on_Player_jumped():
	$Camera_Offset/Camera2D.drag_margin_left = 0.5
	$Camera_Offset/Camera2D.drag_margin_right = 0.5
	$Camera_Offset/Camera2D.drag_margin_top = 0.5
	$Camera_Offset/Camera2D.drag_margin_bottom = 0.5
	ground_camera_mode = false

func _on_Player_touched_ground():
	$Camera_Offset/Camera2D.drag_margin_h_enabled = true
	$Camera_Offset/Camera2D.drag_margin_v_enabled = true
	$Camera_Offset/Camera2D.drag_margin_left = 0.1
	$Camera_Offset/Camera2D.drag_margin_right = 0.1
	$Camera_Offset/Camera2D.drag_margin_top = 0.1
	$Camera_Offset/Camera2D.drag_margin_bottom = 0.1
	ground_camera_mode = true

func _on_Player_rotate():
	pass # Replace with function body.
