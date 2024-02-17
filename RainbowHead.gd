extends CharacterBody2D

const RAINBOW_DOT = preload("res://Rainbow.tscn")
const RAINBOW_BODY = preload("res://RainbowBody.tscn")
var rainbow_body
var vx = 100
var vy = -100
var speed = 300
var angle
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	rainbow_body = RAINBOW_BODY.instantiate()
	if abs(vx) < 1:
		vx = 1
	if abs(vy) < 1:
		vy = -1
	var norm_factor = 1 / sqrt(vx * vx + vy * vy)
	velocity.x = vx * speed * norm_factor
	velocity.y = vy * speed * norm_factor
	

func _physics_process(delta):
	get_parent().add_child(rainbow_body)
	angle = calculate_angle(velocity.x, velocity.y)
	rotation = angle
	spawn_rainbow()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()


func calculate_angle(x, y):
	if abs(x) < 1:
		x = 1
	if abs(y) < 1:
		y = 1
	return atan(y/x)

func spawn_rainbow():
	var rainbow = RAINBOW_DOT.instantiate()
	rainbow.rotation = angle
	rainbow.position = position
	rainbow_body.add_child(rainbow)

func _on_area_2d_body_entered(body):
	if body.get_collision_layer_value() == 8:
		pass # reflect
	elif body.get_collision_layer_value() == 4:
		rainbow_body.queue_free()
		# teleport player to this 
		queue_free()
