extends KinematicBody2D

const MOVE_ACCEL = 10
const MAX_MOVE_SPEED = 140
const JUMP_FORCE = 500
const GRAVITY = 30
const MAX_FALL_SPEED = 250
const PEEK_TOLERANCE = 30

signal jumped
signal touched_ground

onready var animation_state_machine = $PlayerSprite/Player_Polygons/AnimationTree.get("parameters/playback")
onready var tilemap = get_parent().get_node("TileMap")

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
var can_attack = true
var animation_lock = false

func get_class():
	return "Player"

func _ready():
	$PlayerSprite/Player_Polygons/AnimationTree.active = true
	ScreenShake.set("camera", $CameraPivot/Camera_Offset/Camera2D)

func _physics_process(_delta):
	#Horizontal Movement Code
	var move_dir = 0
	if not animation_lock:
		if Input.is_action_pressed("move_right"):
			self.speed += MOVE_ACCEL
			move_dir = 1
			if self.grounded:
				animation_state_machine.travel("walk")
				if abs(self.speed) > MAX_MOVE_SPEED/2.0:
					$PlayerSprite/FootDust.emitting = true
		elif Input.is_action_pressed("move_left"):
			self.speed += MOVE_ACCEL
			move_dir = -1
			if self.grounded:
				animation_state_machine.travel("walk")
				if abs(self.speed) > MAX_MOVE_SPEED/2.0:
					$PlayerSprite/FootDust.emitting = true
		if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			self.speed -= MOVE_ACCEL*2
			if speed < 0:
				speed = 0
			if self.grounded:
				animation_state_machine.travel("tail_wag")
				$PlayerSprite/FootDust.emitting = false
	if self.facing_right and move_dir < 0:
		flip()
	elif not self.facing_right and move_dir > 0:
		flip()
	self.speed = min(self.speed, self.MAX_MOVE_SPEED)
	#Vertical Movement Code
	#Gravity code
	if not grounded:
		y_velo += self.GRAVITY
		$PlayerSprite/FootDust.emitting = false
	#Camera Control
	if Input.is_action_pressed("look_up"):
		if peek_count < 0:
			peek_count = 0
		self.peek_count += 1
		if self.peek_count >= self.PEEK_TOLERANCE:
			self.look_direction.y = -1
			self.peek_count = self.PEEK_TOLERANCE
			#animation_state_machine.travel("look_up")
	elif Input.is_action_pressed("look_down"):
		if peek_count > 0:
			peek_count = 0
		self.peek_count -= 1
		if self.peek_count <= -1 * self.PEEK_TOLERANCE:
			self.look_direction.y = +1
			self.peek_count = self.PEEK_TOLERANCE
			#animation_state_machine.travel("look_down")
	else:
		look_direction.y = 0
		self.peek_count = 0
	if not self.grounded:
		if not self.animation_lock:
			animation_state_machine.travel("jump")
		emit_signal("jumped")
	#Half Gravity Jump Peak
	if not self.grounded and abs(y_velo) < self.GRAVITY:
		y_velo -= 0.5 * self.GRAVITY
	#Jump code
	if (self.grounded or coyote) and (Input.is_action_just_pressed("jump") or buffered_jump) and not self.animation_lock:
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
	#Attack Code
	if Input.is_action_pressed("attack_1") and self.can_attack:
		$PlayerSprite/FootDust.emitting = false
		var new_axe = Preloader.axe_projectile.instance()
		if not self.grounded:
			new_axe.velocity = Vector2(self.look_direction.x*(self.speed/50)+(1.5*self.look_direction.x),-4)
		else:
			new_axe.velocity = Vector2((1.5*self.look_direction.x),-4)
		new_axe.global_position = self.global_position + Vector2(-12*self.look_direction.x, 0)
		new_axe.rotation_degrees = -170
		self.get_parent().add_child(new_axe)
		self.can_attack = false
		if self.grounded:
			self.animation_lock = true
			self.animation_state_machine.travel("throw_axe")
			$AnimationLockTimer.start()
		$AttackCooldown.start()
		if not self.facing_right:
			new_axe.rotation_direction = -1
			new_axe.sprite.flip_h = true
	if Input.is_action_pressed("attack_2") and self.can_attack:
		$PlayerSprite/FootDust.emitting = false
		var new_fireball = Preloader.fireball_projectile.instance()
		var fireball_y_arc = 60
		var fireball_x_arc = 180*self.look_direction.x
		if Input.is_action_pressed("look_down") and not self.grounded:
			fireball_x_arc = 15*self.look_direction.x
			fireball_y_arc = 180
		elif Input.is_action_pressed("look_up"):
			fireball_x_arc = 15*self.look_direction.x
			fireball_y_arc = -180
		new_fireball.apply_impulse(Vector2(0,0), Vector2(fireball_x_arc, fireball_y_arc))
		new_fireball.global_position = self.global_position + Vector2(-10*self.look_direction.x, -6)
		self.get_parent().add_child(new_fireball)
		self.can_attack = false
		if self.grounded:
			self.animation_lock = true
			self.animation_state_machine.travel("throw_axe")
			$AnimationLockTimer.start()
		$AttackCooldown.start()
		if not self.facing_right:
			new_fireball.rotation_direction = -1
			new_fireball.sprite.flip_h = true
	#warning-ignore:return_value_discarded
	self.move_and_slide_with_snap(Vector2(move_dir*self.speed, self.y_velo), Vector2(0,1), Vector2(0,-1))
	var prv_ground = self.grounded
	self.grounded = self.is_on_floor()
	if self.grounded and not prv_ground:
		$PlayerSprite/FallParticle.restart()
		$PlayerSprite/FallParticle.emitting = true

func flip():
	facing_right = !facing_right
	self.look_direction.x *= -1
	$PlayerSprite.scale.x *= -1

func set_camera_limits():
	self.tilemap = get_parent().get_node("TileMap")
	var map_limits = self.tilemap.get_used_rect()
	var map_cellsize = self.tilemap.cell_size
	$CameraPivot/Camera_Offset/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$CameraPivot/Camera_Offset/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$CameraPivot/Camera_Offset/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$CameraPivot/Camera_Offset/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func _on_CoyoteTimer_timeout():
	self.coyote = false
	self.can_coyote = false

func _on_JumpBufferTimer_timeout():
	self.buffered_jump = false

func _on_AttackCooldown_timeout():
	self.can_attack = true

func _on_AnimationLockTimer_timeout():
	self.animation_lock = false
