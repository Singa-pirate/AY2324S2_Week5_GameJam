extends CharacterBody2D

const ARROW = preload("res://Arrow.tscn")
const RAINBOW_HEAD = preload("res://RainbowHead.tscn")
const WIDTH_FROM_CENTER_TO_HORN = 1
const HEIGHT_FROM_CENTER_TO_HORN = 29
const RAINBOW_SHOOT_LOWER_BOUND = 20
const RAINBOW_SHOOT_UPPER_BOUND = 100
const CAMERA_MOVE_SPEED = 50
const CAMERA_MAX_DISPLACEMENT = 300
@onready var arrow: Node2D = $Arrow
var rainbow_head
@onready var strength_bar: ProgressBar = $Strength
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var camera: Camera2D = $Camera2D
var rainbow_speed = 500
var jump_enabled = true
var rainbow_start_position
var rainbow_strength = 0


func _ready():
	strength_bar.max_value = RAINBOW_SHOOT_UPPER_BOUND

func _physics_process(delta):
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
			if Input.is_action_pressed("ui_left") and camera.global_position.x > global_position.x - CAMERA_MAX_DISPLACEMENT:
					camera.position.x -= CAMERA_MOVE_SPEED
			elif Input.is_action_pressed("ui_right") and camera.global_position.x < global_position.x + CAMERA_MAX_DISPLACEMENT:
					camera.position.x += CAMERA_MOVE_SPEED
			elif Input.is_action_pressed("ui_up") and camera.global_position.y > global_position.y - CAMERA_MAX_DISPLACEMENT:
					camera.position.y -= CAMERA_MOVE_SPEED
			elif Input.is_action_pressed("ui_down") and camera.global_position.y < global_position.y + CAMERA_MAX_DISPLACEMENT:
					camera.position.y += CAMERA_MOVE_SPEED
	else:
		camera.global_position = lerp(camera.global_position, global_position, 0.1)
	
	if is_on_floor() and jump_enabled:
		update_rainbow_start_position()
		arrow.rotation = calculate_arrow_angle()
		arrow.show()
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			rainbow_strength = min(rainbow_strength + 1, RAINBOW_SHOOT_UPPER_BOUND)
		else:
			shoot_rainbow()
	
	strength_bar.value = rainbow_strength
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

func update_rainbow_start_position():
	rainbow_start_position = global_position - Vector2(WIDTH_FROM_CENTER_TO_HORN, HEIGHT_FROM_CENTER_TO_HORN)

func calculate_arrow_angle():
	var mouse_position = get_global_mouse_position()
	var dx = mouse_position.x - rainbow_start_position.x
	var dy = mouse_position.y - rainbow_start_position.y
	return atan2(dy, dx)
	
func shoot_rainbow():
	if rainbow_strength < RAINBOW_SHOOT_LOWER_BOUND:
		rainbow_strength = 0
	else:
		jump_enabled = false
		arrow.hide()
		rainbow_head = RAINBOW_HEAD.instantiate()
		rainbow_head.player = self
		var mouse_position = get_global_mouse_position()
		var dx = mouse_position.x - rainbow_start_position.x
		var dy = mouse_position.y - rainbow_start_position.y
		rainbow_head.global_position = arrow.global_position
		rainbow_head.vx = dx
		rainbow_head.vy = dy
		rainbow_head.speed = rainbow_speed * rainbow_strength / RAINBOW_SHOOT_UPPER_BOUND
		rainbow_head.rainbow_increased.connect(add_rainbowness)
		get_parent().add_child(rainbow_head)
		rainbow_strength = 0

func update_position(position):
	if global_position.x > position.x:
		get_node("AnimatedSprite2D").flip_h = true
	else:
		get_node("AnimatedSprite2D").flip_h = false
	global_position = position


func add_rainbowness(value: int):
	strength_bar.size.x += value * 20
	rainbow_speed += value * 40
	if value < 0:
		play_hit_animation()


func play_hit_animation():
	$AnimatedSprite2D.play("hit")
	$HitTimer.start()


func _on_hit_timer_timeout():
	$AnimatedSprite2D.play("default")
