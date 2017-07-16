extends Area2D

enum {HEALTH, DAMAGE, FIRE_RATE, REGEN, SPEED}
var powerup_type = HEALTH
var is_picked_up = false
var despawning = false
var timer

func _ready():
	timer = get_node("despawn_timer")
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (timer.get_time_left() <= 3.0 and !despawning and !is_picked_up):
		despawning = true
		get_node("anim").play("despawning")

func set_powerup_type(type):
	var pickup_text = get_node("pickup_text")
	get_node("Sprite").set_frame(type % 5)
	if (type == HEALTH):
		pickup_text.set_text("Health Up")
	elif (type == DAMAGE):
		pickup_text.set_text("Damage Up")
	elif (type == FIRE_RATE):
		pickup_text.set_text("Fire Rate Up")
	elif (type == REGEN):
		pickup_text.set_text("Regen Up")
	elif (type == SPEED):
		pickup_text.set_text("Speed Up")
	else:
		print("Something went wrong")
	powerup_type = type


func _on_powerup_area_enter( area ):
	if (area extends preload("res://scripts/player.gd") and !is_picked_up):
		print("PICKED UP")
		if (powerup_type == HEALTH):
			print("SET HEALTH")
			if (area.max_health < 250):
				area.max_health += 10
		elif (powerup_type == DAMAGE):
			area.damage += 1
		elif (powerup_type == FIRE_RATE):
			if (area.rps < 15):
				area.set_fire_rate(area.rps + 1)
		elif (powerup_type == REGEN):
			area.regen_amount += 2
		elif (powerup_type == SPEED):
			if (area.velocity < 1000):
				area.velocity += 50
		else:
			print("Something went wrong")
		timer.stop()
		get_node("anim").play("picked_up")
		get_node("pickup_timer").start()
		is_picked_up = true


func _on_despawn_timer_timeout():
	queue_free()


func _on_pickup_timer_timeout():
	queue_free()
