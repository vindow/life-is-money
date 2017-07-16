extends Area2D

export var max_health = 100
var health = 100
var velocity = 500
var move_direction = Vector2(0, 0)
var pos = Vector2(0, 0)

var shoot_direction = Vector2(1, 0)
var shot_timer = 0.5
var rps = 5
var shot_cooldown = 0.2
export var damage = 7

var cant_shoot_timer = 1.0
var cant_shoot_cooldown = 1.0

var regen_amount = 10
var regen_timer = 3.0
export var regen_cooldown = 3.0

var invulnerable = false

var sound
var bullet = preload("res://scenes/bullet.tscn")
var size

var dying = false

func _ready():
	sound = get_node("sound")
	size = get_node("Sprite").get_texture().get_size()
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	# process movement inputs and move the player
	pos = get_node(".").get_pos()
	move_direction = Vector2(0, 0)
	if (Input.is_action_pressed("move_up")):
		move_direction.y = -1
	elif (Input.is_action_pressed("move_down")):
		move_direction.y = 1
		
	if (Input.is_action_pressed("move_left")):
		move_direction.x = -1
		if (move_direction.y != 0):
			move_direction *= sqrt(2) / 2
	elif (Input.is_action_pressed("move_right")):
		move_direction.x = 1
		if (move_direction.y != 0):
			move_direction *= sqrt(2) / 2
	pos += move_direction * velocity * delta
	
	#Check if player is out of bounds and set them back in bounds if so
	if (pos.x - size.height / 2 < 0):
		pos.x = size.height / 2
	elif (pos.x + size.height / 2 > 1920):
		pos.x = 1920 - size.height / 2
	if (pos.y - size.height / 2 < 0):
		pos.y = size.height / 2
	elif (pos.y + size.height / 2 > 1080):
		pos.y = 1080 - size.height / 2
	
	#Process direction turret is facing
	var mouse_pos = get_global_mouse_pos()
	shoot_direction = (mouse_pos - pos).normalized()
	shoot_direction.y *= -1
	
	#Shoot if shot has cooled down, increment the cooldown timer if it still needs to cooldown
	if(Input.is_action_pressed("fire") and shot_timer >= shot_cooldown and health > damage):
		sound.play("shoot")
		var binstance = bullet.instance()
		var xpos = 45 * shoot_direction.x
		var ypos = 45 * -shoot_direction.y
		binstance.damage = damage
		binstance.set_pos(pos + Vector2(xpos, ypos))
		binstance.set_rot(atan2(shoot_direction.y, shoot_direction.x))
		get_parent().add_child(binstance)
		change_health(-damage)
		shot_timer = 0
	elif (Input.is_action_pressed("fire") and cant_shoot_timer >= cant_shoot_cooldown and health < damage):
		sound.play("cant_shoot")
		cant_shoot_timer = 0.0
	
	if (cant_shoot_timer < cant_shoot_cooldown):
		cant_shoot_timer += delta
	
	if (shot_timer < shot_cooldown):
		shot_timer += delta
	
	#Regen if no combat has been done for 3 seconds, increment regen timer otherwise
	if (regen_timer >= regen_cooldown):
		change_health(regen_amount)
		regen_timer = 2.0
	else:
		regen_timer += delta
	#Update visual direction and position
	get_node("Sprite").set_rot(atan2(shoot_direction.y, shoot_direction.x))
	get_node(".").set_pos(pos)

func change_health(amount):
	if (amount < 0):
		regen_timer = 0.0
	health += amount
	get_node("Sprite").set_modulate(Color(1.0, health * 1.0 / max_health, health * 1.0 / max_health))
	if (health > max_health):
		health = max_health
	elif (health <= 0):
		die()

func set_fire_rate(rounds_per_sec):
	shot_cooldown = 1.0 / rounds_per_sec

func hit_player(amount):
	if (!invulnerable):
		get_parent().shake_camera()
		sound.play("player_hit")
		invulnerable = true
		get_node("invul_timer").start()
		get_node("anim").play("invulnerable")
		get_node("hit_particles").set_emitting(true)
		change_health(-amount)

func die():
	get_node("anim").stop()
	sound.play("player_explode", true)
	get_node("anim").play("destroyed")
	dying = true
	set_fixed_process(false)
	get_node("death_timer").start()
	


func _on_invul_timer_timeout():
	invulnerable = false


func _on_death_timer_timeout():
	get_parent().game_over()
