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
@onready var bar_fill: StyleBoxFlat
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var camera: Camera2D = $Camera2D
var rainbow_speed = 400
var jump_enabled = true
var rainbow_start_position
var rainbow_strength = 0
var last_position


func _ready():
	strength_bar.max_value = RAINBOW_SHOOT_UPPER_BOUND
	get_parent().set_initial_raudino(position, scale)
	bar_fill = StyleBoxFlat.new()
	strength_bar.add_theme_stylebox_override("fill", bar_fill)

func _physics_process(delta):
	
	if Input.is_action_just_released("ui_mwu"):
		camera.zoom = lerp(camera.zoom, Vector2(4, 4), 0.2)
		camera.global_position = lerp(camera.global_position, global_position, 0.1)
	elif Input.is_action_just_released("ui_mwd"):
		camera.zoom = lerp(camera.zoom, Vector2(1, 1), 0.3)

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
	#else:
		#camera.global_position = lerp(camera.global_position, global_position, 0.1)
	
	if is_on_floor() and jump_enabled:
		update_rainbow_start_position()
		arrow.rotation = calculate_arrow_angle()
		arrow.show()
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			rainbow_strength = min(rainbow_strength + 1, RAINBOW_SHOOT_UPPER_BOUND)
		else:
			shoot_rainbow()
	
	strength_bar.value = rainbow_strength
	var strength_ratio = float(rainbow_strength) / RAINBOW_SHOOT_UPPER_BOUND
	bar_fill.bg_color = Color(1, \
		min(1, 2 - 2 * strength_ratio), \
		max(0, 1 - 2 * strength_ratio))
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		attempt_start_fall_timer()
	else:
		attempt_stop_fall_timer()
	
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
		rainbow_head.init_speed = rainbow_speed * rainbow_strength / RAINBOW_SHOOT_UPPER_BOUND
		rainbow_head.rainbow_increased.connect(add_rainbowness)
		get_parent().add_child(rainbow_head)
		rainbow_strength = 0

func update_position(position):
	if global_position.x > position.x:
		get_node("AnimatedSprite2D").flip_h = true
	else:
		get_node("AnimatedSprite2D").flip_h = false
	last_position = global_position
	global_position = position


func add_rainbowness(value: int):
	strength_bar.size.x += value * 5
	rainbow_speed += value * 10
	if rainbow_speed < 200:
		queue_free()
		return
	if value < 0:
		play_hit_animation()


func attempt_start_fall_timer():
	if $FallTimer.is_stopped():
		$FallTimer.start()


func attempt_stop_fall_timer():
	$FallTimer.stop()


func play_hit_animation():
	$AnimatedSprite2D.play("hit")
	$HitTimer.start()


func _on_hit_timer_timeout():
	$AnimatedSprite2D.play("default")


func _on_fall_timer_timeout():
	update_position(last_position)
