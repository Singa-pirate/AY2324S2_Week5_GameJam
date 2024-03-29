extends CharacterBody2D

const RAINBOW_DOT = preload("res://Rainbow.tscn")
const RAINBOW_BODY = preload("res://RainbowBody.tscn")
const KILL_VERTICAL_SPEED_COEFFICIENT = 1.3
const KILL_HORIZONTAL_SPEED_COEFFICIENT = 3
var player
var rainbow_body
var vx
var vy
var init_speed
var angle
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
signal rainbow_increased

func _ready():
	rainbow_body = RAINBOW_BODY.instantiate()
	if abs(vx) < 1:
		vx = 1
	if abs(vy) < 1:
		vy = -1
	var norm_factor = 1 / sqrt(vx * vx + vy * vy)
	velocity.x = vx * init_speed * norm_factor
	velocity.y = vy * init_speed * norm_factor
	

func _physics_process(delta):
	get_parent().add_child(rainbow_body)
	angle = calculate_angle(velocity.x, velocity.y)
	rotation = angle
	spawn_rainbow()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if global_position.y > player.rainbow_start_position.y + player.rainbow_speed * KILL_VERTICAL_SPEED_COEFFICIENT or \
		abs(global_position.x - player.rainbow_start_position.x) > player.rainbow_speed * KILL_HORIZONTAL_SPEED_COEFFICIENT:
			die()
	if Input.is_action_pressed("ui_cancel"):
		die()
	move_and_slide()


func calculate_angle(x, y):
	if abs(x) < 1:
		x = 1
	if abs(y) < 1:
		y = 1
	return atan2(y, x)

func spawn_rainbow():
	var rainbow = RAINBOW_DOT.instantiate()
	rainbow.rotation = angle
	rainbow.position = position
	rainbow_body.add_child(rainbow)

func die():
	player.jump_enabled = true
	rainbow_body.queue_free()
	queue_free()

func _on_area_2d_body_entered(body):
	if is_instance_of(body, TileMap):
		if body.get_tileset().get_physics_layer_collision_layer(0) == 4:
			# touch cloud platform
			player.update_position(global_position)
			die()
			
	else:
		if body.collision_layer == 8:
			var curr_angle = calculate_angle(velocity.x, velocity.y)
			var reflected_angle = 2 * body.rotation - rotation
			var curr_speed = velocity.length()
			velocity.x = curr_speed * cos(reflected_angle)
			velocity.y = curr_speed * sin(reflected_angle)


func add_rainbowness(amount):
	rainbow_increased.emit(amount)

