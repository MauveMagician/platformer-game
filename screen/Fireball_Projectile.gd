extends RigidBody2D

const MAXIMUM_ROTATION_SPEED = 10

var rotation_direction = 1
var power = 2

# warning-ignore:unused_class_variable
onready var sprite = $Sprite

func burst():
	$DespawnParticle.emitting = true
	$Sprite.visible = false
	self.sleeping = true
	self.set_collision_mask_bit(1,false)
	$Hurtbox.set_deferred("monitoring", false)
	var timer = Timer.new()
	timer.connect("timeout", self, "queue_free")
	timer.set_wait_time($DespawnParticle.lifetime*2)
	self.add_child(timer)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Sprite.rotation_degrees += MAXIMUM_ROTATION_SPEED * rotation_direction

func _on_Hurtbox_body_entered(body):
	if body.get_class() == "Monster":
		if body.has_method("take_damage"):
			body.take_damage(power)
			self.burst()

func _on_LifetimeTimer_timeout():
	self.burst()
