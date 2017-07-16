extends Area2D

var max_health = 15
var speed = 350

var health
var is_cloaking = false

var cloak_cooldown = 4.0
var cloak_timer = 2.0
var can_interact = false

var player = null
var size
var powerup = preload("res://scenes/powerup.tscn")

export var has_powerup = false

func _ready():
	size = get_node("Sprite").get_texture().get_size()
	get_node("anim").play("spawn")
	health = max_health
	player = get_tree().get_root().get_node("game/player")
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (can_interact):
		if (cloak_timer >= cloak_cooldown):
			if (is_cloaking):
				get_node("anim").play("decloak")
				is_cloaking = false
			else:
				get_node("anim").play("cloak")
				is_cloaking = true
			cloak_timer = 0.0
		else:
			cloak_timer += delta
		var player_pos = player.pos + player.move_direction * player.velocity / 2
		var direction = (player_pos - get_node(".").get_pos()).normalized()
		var target_pos = get_node(".").get_pos() + direction * speed * delta
		if (target_pos.x < 0 + size.width / 2):
			target_pos.x = size.width / 2
		elif (target_pos.x > 1920 - size.width / 2):
			target_pos.x = 1920 - size.width / 2
		if (target_pos.y < 0 + size.height / 2):
			target_pos.y = size.height / 2
		elif (target_pos.y > 1080 - size.height / 2):
			target_pos.y = 1080 - size.height / 2
		get_node(".").set_rot(atan2(-direction.y, direction.x))
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

func _on_cloaking_enemy_area_enter( area ):
	if (can_interact and area extends preload("res://scripts/player.gd") and !area.dying):
		area.hit_player(30)


func _on_spawn_timer_timeout():
	can_interact = true


func _on_death_timer_timeout():
	queue_free()
