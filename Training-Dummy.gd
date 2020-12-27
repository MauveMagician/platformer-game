extends KinematicBody2D

var max_hp = 6
onready var hp = max_hp

func get_class():
	return "Monster"

func take_damage(damage=1):
	print("I got hit! " + String(damage))
	self.hp -= damage
	Hitstop.start(0.1)
	if self.hp <= 0:
		self.die()

func die():
	ScreenShake.start(0.15)
	self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# warning-ignore:unused_argument
func _process(delta):
	$Sprite.rotation_degrees += 5
