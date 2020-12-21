extends KinematicBody2D

const MOVE_ACCEL = 20
const MAX_MOVE_SPEED = 120
const JUMP_FORCE = 500
const GRAVITY = 30
const MAX_FALL_SPEED = 250
const PEEK_TOLERANCE = 30

signal jumped
signal touched_ground

var y_velo = 0
var speed = 0
var facing_right = true
var coyote = false
var can_coyote = true
var buffered_jump = false
var v_corrected = false
var look_direction = Vector2(1,0)
var peek_count = 0
var grounded = false

func _physics_process(_delta):
	#Horizontal Movement Code
	var move_dir = 0
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
	#Gravity code
	if not self.grounded:
		y_velo += self.GRAVITY
	#Camera Control
	if Input.is_action_pressed("look_up"):
		if peek_count < 0:
			peek_count = 0
		self.peek_count += 1
		if self.peek_count >= self.PEEK_TOLERANCE:
			self.look_direction.y = -1
			self.peek_count = self.PEEK_TOLERANCE
	elif Input.is_action_pressed("look_down"):
		if peek_count > 0:
			peek_count = 0
		self.peek_count -= 1
		if self.peek_count <= -1 * self.PEEK_TOLERANCE:
			self.look_direction.y = +1
			self.peek_count = self.PEEK_TOLERANCE
	else:
		look_direction.y = 0
		self.peek_count = 0
	if not self.grounded:
		emit_signal("jumped")
	#Half Gravity Jump Peak
	if not self.grounded and abs(y_velo) < self.GRAVITY:
		y_velo -= 0.5 * self.GRAVITY
	#Jump code
	if (self.grounded or coyote) and (Input.is_action_just_pressed("jump") or buffered_jump):
		self.y_velo = -JUMP_FORCE
		self.coyote = false
		self.can_coyote = false
	#Jump Buffering code
	elif not self.grounded and Input.is_action_just_pressed("jump") and $JumpBufferTimer.is_stopped():
		self.buffered_jump = true
		$JumpBufferTimer.start()
	#Mario jump code - stop jumping on button release
	elif Input.is_action_just_released("jump") and self.y_velo < 0:
		self.y_velo = 0
	if self.grounded and self.y_velo >= 5:
		#Refresh Coyote Jump
		self.can_coyote = true
		self.y_velo = 5
		#Camera Control Signal
		emit_signal("touched_ground")
	#Coyote Timer
	if not self.grounded and self.can_coyote and $CoyoteTimer.is_stopped():
		self.coyote = true
		$CoyoteTimer.start()
	if y_velo > self.MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
	#Corner Correction
	if not self.grounded and not v_corrected and abs(y_velo) > 100:
		if facing_right and not Input.is_action_pressed("move_right"):
			for ray in $CornerCorrection_Right.get_children():
				if $CornerCorrection_Left.get_child(1).is_colliding():
						break
				if ray.is_colliding():
					self.position -= Vector2(3,0)
					break
		elif not Input.is_action_pressed("move_left"):
			for ray in $CornerCorrection_Left.get_children():
				if $CornerCorrection_Right.get_child(1).is_colliding():
						break
				if ray.is_colliding():
					self.position += Vector2(3,0)
					break
		v_corrected = true
	else:
		v_corrected = false
	#warning-ignore:return_value_discarded
	self.move_and_slide(Vector2(move_dir*self.speed, self.y_velo), Vector2(0,-1))
	self.grounded = self.is_on_floor()

func flip():
	facing_right = !facing_right
	self.look_direction.x *= -1
	$PlayerSprite/Sprite.flip_h = !$PlayerSprite/Sprite.flip_h

func _on_CoyoteTimer_timeout():
	self.coyote = false
	self.can_coyote = false

func _on_JumpBufferTimer_timeout():
	self.buffered_jump = false
