extends Node2D

const MAXIMUM_ROTATION_SPEED = 10
const AXE_GRAVITY = 0.1
const MAX_FALL_SPEED = 10
const ROTATION_ACCEL = 0.05

var rotation_speed = 5
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.rotation_degrees += rotation_speed
	rotation_speed += ROTATION_ACCEL
	if self.rotation_speed > MAXIMUM_ROTATION_SPEED:
		self.rotation_speed = MAXIMUM_ROTATION_SPEED
	self.velocity.y += AXE_GRAVITY
	if self.velocity.y > MAX_FALL_SPEED:
		self.velocity.y += MAX_FALL_SPEED
	self.position += self.velocity

func _on_Lifetime_timeout():
	self.queue_free()
