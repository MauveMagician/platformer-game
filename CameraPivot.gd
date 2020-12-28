extends Position2D

const ORIGINAL_INTERPOLATE_CAM_TIME = 1.0/3.0
const ORIGINAL_LOOK_UP_PIXELS = 64
const ORIGINAL_CAMERA_OFFSET_DISTANCE = 64

export var interpolate_cam_time = ORIGINAL_INTERPOLATE_CAM_TIME
export var look_up_pixels = ORIGINAL_LOOK_UP_PIXELS
export var camera_offset_distance = ORIGINAL_CAMERA_OFFSET_DISTANCE
onready var parent = self.get_parent()
var y_direction = 1
var ground_camera_mode = true

func _ready():
	$Camera_Offset.position.x = camera_offset_distance

func _physics_process(_delta):
	update_pivot_angle()

func update_pivot_angle():
	self.y_direction = parent.get("look_direction").y
	if ground_camera_mode:
		$Lookup_Tween.interpolate_property($Camera_Offset,"position",$Camera_Offset.position, Vector2(parent.get("look_direction").x*camera_offset_distance, look_up_pixels*self.y_direction), interpolate_cam_time,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Camera_Offset/Camera2D.drag_margin_h_enabled = false
		$Camera_Offset/Camera2D.drag_margin_v_enabled = false
		$Lookup_Tween.start()

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
	$Camera_Offset/Camera2D.drag_margin_left = 0.15
	$Camera_Offset/Camera2D.drag_margin_right = 0.15
	$Camera_Offset/Camera2D.drag_margin_top = 0.1
	$Camera_Offset/Camera2D.drag_margin_bottom = 0.1
	self.interpolate_cam_time = ORIGINAL_INTERPOLATE_CAM_TIME/2
	if $Speedup_Timer.is_stopped():
		$Speedup_Timer.start()
	ground_camera_mode = true

func _on_Speedup_Timer_timeout():
	self.interpolate_cam_time = ORIGINAL_INTERPOLATE_CAM_TIME

func _on_PlayerVisible_screen_exited():
	$Lookup_Tween.stop_all()
	$Camera_Offset.position = Vector2(0,0)
	$Camera_Offset/Camera2D.smoothing_enabled = false
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	t.autostart = true
	get_parent().call_deferred("add_child", t)
	yield(t, "timeout")
	$Camera_Offset/Camera2D.smoothing_enabled = true
