extends Area2D

var direction = Vector2(0, 0)
export var speed = 300
var max_health = 8
var health

var size
var can_interact = false

var player = null
var powerup = preload("res://scenes/powerup.tscn")

export var has_powerup = false

func _ready():
	if (!can_interact):
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
		var pos = get_node(".").get_pos()
		pos += direction * speed * delta
		if (pos.x < 0 + size.x / 2|| pos.x + size.x / 2 > 1920):
			direction.x *= -1
		if (pos.y < 0 + size.y / 2|| pos.y + size.y / 2> 1080):
			direction.y *= -1
		get_node(".").set_pos(pos)

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

func _on_basic_enemy_area_enter( area ):
	if (can_interact and area extends preload("res://scripts/player.gd") and !area.dying):
		area.hit_player(25)

func _on_spawn_timer_timeout():
	can_interact = true


func _on_death_timer_timeout():
	queue_free()
