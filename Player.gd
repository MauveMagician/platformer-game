extends KinematicBody2D

const MOVE_ACCEL = 20
const MAX_MOVE_SPEED = 120
const JUMP_FORCE = 500
const GRAVITY = 45
const MAX_FALL_SPEED = 300

var y_velo = 0
var speed = 0
var facing_right = true
var coyote = false
var can_coyote = true
var buffered_jump = false

func _physics_process(_delta):
	#Horizontal Movement Code
	var move_dir = 0
	var grounded = self.is_on_floor()
	if Input.is_action_pressed("move_right"):
		self.speed += MOVE_ACCEL
		move_dir = 1
	elif Input.is_action_pressed("move_left"):
		self.speed += MOVE_ACCEL
		move_dir = -1
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		self.speed -= MOVE_ACCEL*2
		if speed < 0:
			speed = 0
	if self.facing_right and move_dir < 0:
		flip()
	elif not self.facing_right and move_dir > 0:
		flip()
	self.speed = min(self.speed, self.MAX_MOVE_SPEED)
	#Vertical Movement Code
	y_velo += self.GRAVITY
	#Half Gravity Jump Peak
	if not grounded and abs(y_velo) < (self.GRAVITY * 2):
		y_velo -= 0.5 * self.GRAVITY
	if (grounded or coyote) and (Input.is_action_just_pressed("jump") or buffered_jump):
		self.y_velo = -JUMP_FORCE
	#Jump Buffering code
	elif not grounded and Input.is_action_just_pressed("jump") and $JumpBufferTimer.is_stopped():
		self.buffered_jump = true
		$JumpBufferTimer.start()
	#Mario jump code - stop jumping on button release
	elif Input.is_action_just_released("jump") and self.y_velo < 0:
		self.y_velo = 0
	if grounded and self.y_velo >= 5:
		self.can_coyote = true
		self.y_velo = 5
	#Coyote Timer
	if not grounded and self.can_coyote and $CoyoteTimer.is_stopped():
		self.coyote = true
		$CoyoteTimer.start()
	if y_velo > self.MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
	#Corner Correction
	if not grounded:
		if facing_right:
			for ray in $CornerCorrection_Right.get_children():
				if $CornerCorrection_Left.get_child(0).is_colliding():
						break
				if ray.is_colliding():
					self.speed -= Vector2(2,0)
		else:
			for ray in $CornerCorrection_Left.get_children():
				if $CornerCorrection_Right.get_child(0).is_colliding():
						break
				if ray.is_colliding():
					self.position += Vector2(2,0)
	#warning-ignore:return_value_discarded
	self.move_and_slide(Vector2(move_dir*self.speed, self.y_velo), Vector2(0,-1))

func flip():
	facing_right = !facing_right
	$Sprite.flip_h = !$Sprite.flip_h

func _on_CoyoteTimer_timeout():
	self.coyote = false
	self.can_coyote = false

func _on_JumpBufferTimer_timeout():
	self.buffered_jump = false

