extends Area2D

var max_health = 20
var speed = 300

var health
var can_interact = false
var target_direction
var current_direction

var size
var player = null
var powerup = preload("res://scenes/powerup.tscn")

export var has_powerup = false

func _ready():
	size = get_node("Sprite").get_texture().get_size()
	get_node("anim").play("spawn")
	health = max_health
	player = get_tree().get_root().get_node("game/player")
	target_direction = (player.pos - get_node(".").get_pos()).normalized()
	current_direction = target_direction
	get_node(".").set_rot(atan2(-current_direction.y, current_direction.x))
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (can_interact):
		var player_pos = player.pos
		
		target_direction = (player.pos - get_node(".").get_pos()).normalized()
		if (target_direction.x > current_direction.x):
			current_direction.x += delta / 2
		elif (target_direction.x < current_direction.x):
			current_direction.x -= delta / 2
		if (target_direction.y > current_direction.y):
			current_direction.y += delta / 2
		elif (target_direction.y < current_direction.y):
			current_direction.y -= delta / 2
		var target_pos = get_node(".").get_pos() + current_direction * speed * delta
		if (target_pos.x < 0 + size.width / 2):
			target_pos.x = size.width / 2
		elif (target_pos.x > 1920 - size.width / 2):
			target_pos.x = 1920 - size.width / 2
		if (target_pos.y < 0 + size.height / 2):
			target_pos.y = size.height / 2
		elif (target_pos.y > 1080 - size.height / 2):
			target_pos.y = 1080 - size.height / 2
		get_node(".").set_rot(atan2(-current_direction.y, current_direction.x))
		get_node(".").set_pos(target_pos)


func lower_health(amount):
	health -= amount
	get_node("sound").play("enemy_hit")
	get_node("hit_particles").set_emitting(true)
	if (health <= 0):
		die()

func die():
	can_interact = false
	get_tree().get_root().get_node("game").shake_camera()
	player.change_health(max_health / 2)
	get_node("anim").play("destroyed")
	get_node("death_timer").start()
	if (has_powerup):
		var pinstance = powerup.instance()
		pinstance.set_pos(get_node(".").get_pos())
		pinstance.set_powerup_type(randi() % 5)
		get_parent().add_child(pinstance)

func _on_tracking_enemy_area_enter( area ):
	if (can_interact and area extends preload("res://scripts/player.gd") and !area.dying):
		area.hit_player(25)


func _on_spawn_timer_timeout():
	can_interact = true


func _on_death_timer_timeout():
	queue_free()
