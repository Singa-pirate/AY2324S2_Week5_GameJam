extends Area2D

const RAINBOWNESS = 3
var is_used = false


func _on_body_entered(body):
	if is_used:
		return
	is_used = true
	body.increase_rainbowness(RAINBOWNESS)
	$DisappearTimer.start()


func _on_disappear_timer_timeout():
	queue_free()
