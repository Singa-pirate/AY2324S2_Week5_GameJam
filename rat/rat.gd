extends CharacterBody2D

@export var speed: int = 100
@export var duration: float = 2.0
var direction: Vector2

const DAMAGE = 5


func _ready():
	$DirectionTimer.wait_time = duration
	$DirectionTimer.start()
	var angle = deg_to_rad(rotation_degrees)
	direction = Vector2(cos(angle), sin(angle))


func _physics_process(delta):
	velocity = speed * direction
	move_and_slide()


func _on_hitbox_body_entered(body):
	# hit the player
	body.decrease_rainbowness(DAMAGE)


func _on_direction_timer_timeout():
	reverse_direction()


func reverse_direction():
	direction = -direction
	$AnimatedSprite2D.scale.x = -$AnimatedSprite2D.scale.x