extends Area2D

var max_health = 25
var speed = 900
var direction = Vector2(0, 0)

var dash_timer = 1.0
var dash_cooldown = 2.5

var size
var health
var can_interact = false

var player = null
var powerup = preload("res://scenes/powerup.tscn")

export var has_powerup = false

func _ready():
	randomize()
	size = get_node("Sprite").get_texture().get_size()
	get_node("anim").play("spawn")
	health = max_health
	player = get_tree().get_root().get_node("game/player")
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (can_interact):
		var pos = get_node(".").get_pos()
		var player_pos = player.pos
		if (dash_timer < 1):
			direction = (player_pos - get_node(".").get_pos()).normalized()
			get_node(".").set_rot(atan2(-direction.y, direction.x))
			dash_timer += delta
		elif (dash_timer > 1 && dash_timer < dash_cooldown):
			pos += direction * speed * delta
			if (pos.x < 0 + size.width / 2):
				pos.x = size.width / 2
			elif (pos.x + size.width / 2 > 1920):
				pos.x = 1920 - size.width / 2
			if (pos.y < 0 + size.height / 2):
				pos.y = size.height / 2
			elif (pos.y + size.height / 2 > 1080):
				pos.y = 1080 - size.height / 2
			get_node(".").set_pos(pos)
			dash_timer += delta
		else:
			dash_timer = 0.0
		
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

func _on_fast_enemy_area_enter( area ):
	if (can_interact):
		if (area extends preload("res://scripts/bullet.gd")):
			get_node("sound").play("enemy_hit")
			get_node("hit_particles").set_emitting(true)
			lower_health(area.damage)
			player.change_health(area.damage)
			area.queue_free()
		elif (area extends preload("res://scripts/player.gd") and !area.dying):
			area.hit_player(40)


func _on_spawn_timer_timeout():
	can_interact = true

func _on_death_timer_timeout():
	queue_free()
