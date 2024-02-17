extends CharacterBody2D

const ARROW = preload("res://Arrow.tscn")
const WIDTH_FROM_CENTER_TO_HORN = 50
const HEIGHT_FROM_CENTER_TO_HORN = 320
var arrow
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rainbowness = 0
var jump_enabled = true
var rainbow_start_position


func _ready():
	arrow = ARROW.instantiate()
	arrow.hide()
	add_child(arrow)

func _physics_process(delta):
	if is_on_floor() and jump_enabled:
		update_rainbow_start_position()
		arrow.position = rainbow_start_position
		arrow.show()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

func update_rainbow_start_position():
	rainbow_start_position = position - Vector2(WIDTH_FROM_CENTER_TO_HORN, HEIGHT_FROM_CENTER_TO_HORN)

func add_rainbowness(value):
	rainbowness += value
