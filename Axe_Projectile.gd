extends Node2D

const MAXIMUM_ROTATION_SPEED = 10
const AXE_GRAVITY = 0.1
const MAX_FALL_SPEED = 10
const ROTATION_ACCEL = 0.10

var rotation_speed = 5
var rotation_direction = 1
var velocity = Vector2(0,0)
var power = 3

# warning-ignore:unused_class_variable
onready var sprite = $Sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.rotation_degrees += rotation_speed * rotation_direction
	rotation_speed += ROTATION_ACCEL
	if self.rotation_speed > MAXIMUM_ROTATION_SPEED:
		self.rotation_speed = MAXIMUM_ROTATION_SPEED
	self.velocity.y += AXE_GRAVITY
	if self.velocity.y > MAX_FALL_SPEED:
		self.velocity.y += MAX_FALL_SPEED
	self.position += self.velocity

func _on_Lifetime_timeout():
	self.queue_free()

func _on_Hurtbox_body_entered(body):
	if body.get_class() == "Monster":
		if body.has_method("take_damage"):
			body.take_damage(power)
