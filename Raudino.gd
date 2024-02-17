extends CharacterBody2D

const ARROW = preload("res://Arrow.tscn")
const RAINBOW_HEAD = preload("res://RainbowHead.tscn")
const WIDTH_FROM_CENTER_TO_HORN = 1
const HEIGHT_FROM_CENTER_TO_HORN = 29
const RAINBOW_SHOOT_LOWER_BOUND = 20
const RAINBOW_SHOOT_UPPER_BOUND = 100
var arrow
var rainbow_head
var strength_bar
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rainbowness = 0
var rainbow_speed = 200
var jump_enabled = true
var rainbow_start_position
var rainbow_strength = 0


func _ready():
	arrow = get_node("Arrow")
	strength_bar = get_node("Strength")
	strength_bar.max_value = RAINBOW_SHOOT_UPPER_BOUND

func _physics_process(delta):
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
		get_parent().add_child(rainbow_head)
		rainbow_strength = 0
		

func add_rainbowness(value):
	rainbowness += value