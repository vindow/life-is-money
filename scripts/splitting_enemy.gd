extends Area2D

var direction = Vector2(0, 0)
var speed = 250
var max_health = 40
var health

var size
var pos = Vector2(0, 0)
var can_interact = false

var player = null
var basic_enemy = preload("res://scenes/basic_enemy.tscn")
var powerup = preload("res://scenes/powerup.tscn")

export var has_powerup = false

func _ready():
	get_node("anim").play("spawn")
	size = get_node("Sprite").get_texture().get_size()
	health = max_health
	player = get_tree().get_root().get_node("game/player")
	randomize()
	direction.x = randi() % 5 + 5
	direction.y = randi() % 5 + 5
	if (randi() % 2 == 0):
		direction.x *= -1
	if (randi() % 2 == 0):
		direction.y *= -1
	direction = direction.normalized()
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (can_interact):
		pos = get_node(".").get_pos()
		pos += direction * speed * delta
		if (pos.x < 0 + size.x / 2|| pos.x + size.x / 2 > 1920):
			direction.x *= -1
		if (pos.y < 0 + size.y / 2|| pos.y + size.y / 2> 1080):
			direction.y *= -1
		get_node(".").set_pos(pos)

func lower_health(amount):
	health -= amount
	if (health <= 0):
		split()

func split():
	var einstance1 = basic_enemy.instance()
	var einstance2 = basic_enemy.instance()
	einstance1.set_pos(pos)
	einstance2.set_pos(pos)
	einstance1.can_interact = true
	einstance2.can_interact = true
	get_parent().add_child(einstance1)
	get_parent().add_child(einstance2)
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

func _on_splitting_enemy_area_enter( area ):
	if (can_interact):
		if (area extends preload("res://scripts/bullet.gd")):
			get_node("sound").play("enemy_hit")
			lower_health(area.damage)
			player.change_health(area.damage)
			area.queue_free()
		elif (area extends preload("res://scripts/player.gd") and !area.dying):
			area.hit_player(20)


func _on_spawn_timer_timeout():
	can_interact = true


func _on_death_timer_timeout():
	queue_free()
