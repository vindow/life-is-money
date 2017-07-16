extends Area2D

var max_health = 30
var forward_speed = 400
var back_speed = 200

var shot_cooldown = 5.0
var shot_timer = 3.0
var num_shots = 0

var health
var follow_distance = 500
var can_interact = false

var size
var player = null
var bullet = preload("res://scenes/enemy_bullet.tscn")
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
		var pos = get_node(".").get_pos()
		var player_pos = player.pos
		var move_direction = (player_pos - get_node(".").get_pos()).normalized()
		var shoot_direction = (player_pos + player.move_direction * player.velocity / 2 - get_node(".").get_pos()).normalized()
		get_node(".").set_rot(atan2(-shoot_direction.y, shoot_direction.x))
		if (abs(pos.distance_to(player_pos)) > follow_distance + 10):
			pos += move_direction * forward_speed * delta
		elif (abs(pos.distance_to(player_pos)) <= follow_distance - 10):
			move_direction *= -1
			pos += move_direction * back_speed * delta
		
		if (pos.x < 0 + size.width / 2):
			pos.x = size.width / 2
		elif (pos.x + size.width / 2 > 1920):
			pos.x = 1920 - size.width / 2
		if (pos.y < 0 + size.height / 2):
			pos.y = size.height / 2
		elif (pos.y + size.height / 2 > 1080):
			pos.y = 1080 - size.height / 2
		get_node(".").set_pos(pos)
		if (shot_timer >= shot_cooldown):
			var binstance = bullet.instance()
			var xpos = 35 * shoot_direction.x
			var ypos = 35 * shoot_direction.y
			binstance.direction = shoot_direction
			binstance.set_pos(pos + Vector2(xpos, ypos))
			get_parent().add_child(binstance)
			num_shots += 1
			if (num_shots < 3):
				shot_timer = 4.0
			else:
				num_shots = 0
				shot_timer = 0.0
		if (shot_timer < shot_cooldown):
			shot_timer += delta
		
func lower_health(amount):
	health -= amount
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

func _on_shooting_enemy_area_enter( area ):
	if (can_interact):
		if (area extends preload("res://scripts/bullet.gd")):
			get_node("sound").play("enemy_hit")
			get_node("hit_particles").set_emitting(true)
			lower_health(area.damage)
			player.change_health(area.damage)
			area.queue_free()
		elif (area extends preload("res://scripts/player.gd") and !area.dying):
			area.hit_player(20)


func _on_spawn_timer_timeout():
	can_interact = true


func _on_death_timer_timeout():
	queue_free()
