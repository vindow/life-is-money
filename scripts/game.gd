extends Node2D

var player_max_health
var player_health
var enemies

var levels = []
var current_level = 0
var shake_amount = 0

func _ready():
	VisualServer.set_default_clear_color(Color((current_level + 1) / 25.0, (current_level+1) / 25.0, (current_level+1) / 25.0,1.0))
	for i in range (21):
		levels.append(load("res://scenes/levels/level" + str(i + 1) + ".tscn"))
	get_node("level").add_child(levels[0].instance())
	player_max_health = get_node("player").max_health
	player_health = get_node("player").health
	enemies = get_node("enemies")
	set_process(true)
	
func _draw():
	var health_container = Vector2Array()
	var start = Vector2(90, 19)
	health_container.push_back(start)
	health_container.push_back(start + Vector2(player_max_health * 2 + 1, 0))
	health_container.push_back(start + Vector2(player_max_health * 2 + 1, 27))
	health_container.push_back(start + Vector2(0, 27))
	health_container.push_back(start)
	for i in range (health_container.size() - 1):
		draw_line(health_container[i], health_container[i+1], Color("550000"))
	var health_bar = Rect2(start.x + 1, start.y + 1, player_health * 2, 25)
	var health_bar_color = Color("CE0000")
	draw_rect(health_bar, health_bar_color)
	
func _process(delta):
	if (Input.is_action_pressed("pause")):
		get_node("pause_panel").show()
		get_tree().set_pause(true)
	player_max_health = get_node("player").max_health
	player_health = get_node("player").health
	if (get_node("level").get_child_count() == 0):
		if ((current_level + 1) % 5 == 0):
			get_node("level").hide()
			update_shop()
			get_node("shop").show()
			get_tree().set_pause(true)
		current_level += 1
		get_node("wave_popup").set_text("Wave " + str(current_level + 1))
		if (current_level >= 10):
			get_node("wave_popup").set("custom_colors/font_color", Color(0, 0, 0))
			get_node("HP").set("custom_colors/font_color", Color(0, 0, 0))
		if (current_level > levels.size()):
			victory()
		get_node("anim").play("wave_notify")
		VisualServer.set_default_clear_color(Color((current_level + 1) / 25.0, (current_level+1) / 25.0, (current_level+1) / 25.0,1.0))
		get_node("level").add_child(levels[current_level].instance())
	update()

func victory():
	get_node("victory_panel").show()
	get_tree().set_pause(true)

func update_shop():
	player_max_health = get_node("player").max_health
	var width = get_node("shop/max_health").get_texture().get_size().width
	var scale = get_node("player").max_health / 100.0
	get_node("shop/max_health").set_scale(Vector2(scale, 1))
	get_node("shop/health_amount").set_text(str(get_node("player").max_health))
	get_node("shop/damage_amount").set_text(str(get_node("player").damage))
	get_node("shop/fire_rate_amount").set_text(str(1.0 / get_node("player").shot_cooldown))
	get_node("shop/regen_amount").set_text(str(get_node("player").regen_amount))
	get_node("shop/speed_amount").set_text(str(get_node("player").velocity))

func check_button_status():
	if (get_node("player").max_health <= 10):
		get_node("shop/damage_up").set_disabled(true)
		get_node("shop/fire_rate_up").set_disabled(true)
		get_node("shop/regen_up").set_disabled(true)
		get_node("shop/speed_up").set_disabled(true)
	else:
		get_node("shop/damage_up").set_disabled(false)
		if (get_node("player").rps < 15):
			get_node("shop/fire_rate_up").set_disabled(false)
		get_node("shop/regen_up").set_disabled(false)
		if (get_node("player").velocity < 999):
			get_node("shop/speed_up").set_disabled(false)
	if (get_node("player").max_health >= 250):
		get_node("shop/damage_down").set_disabled(true)
		get_node("shop/fire_rate_down").set_disabled(true)
		get_node("shop/regen_down").set_disabled(true)
		get_node("shop/speed_down").set_disabled(true)
	else:
		get_node("shop/damage_down").set_disabled(false)
		if (get_node("player").rps > 1):
			get_node("shop/fire_rate_down").set_disabled(false)
		get_node("shop/regen_down").set_disabled(false)
		get_node("shop/speed_down").set_disabled(false)
	if (get_node("player").damage <= 1):
		get_node("shop/damage_down").set_disabled(true)
	if (get_node("player").rps >= 15):
		get_node("shop/fire_rate_up").set_disabled(true)
	if (get_node("player").rps <= 1):
		get_node("shop/fire_rate_down").set_disabled(true)
	if (get_node("player").regen_amount <= 2):
		get_node("shop/regen_down").set_disabled(true)
	if (get_node("player").velocity > 999):
		get_node("shop/speed_up").set_disabled(true)
		
func game_over():
	get_node("game_over_panel").show()
	get_tree().set_pause(true)
	
func shake_camera():
	get_node("camera").shake(0.5, 15, 30)
	

func _on_damage_up_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health -= 10
	get_node("player").health = get_node("player").max_health
	get_node("player").damage += 1
	check_button_status()
	update_shop()
	

func _on_damage_down_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health += 7
	get_node("player").health = get_node("player").max_health
	get_node("player").damage -= 1
	check_button_status()
	update_shop()


func _on_fire_rate_up_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health -= 10
	get_node("player").health = get_node("player").max_health
	get_node("player").rps += 1
	get_node("player").set_fire_rate(get_node("player").rps)
	check_button_status()
	update_shop()


func _on_fire_rate_down_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health += 7
	get_node("player").health = get_node("player").max_health
	get_node("player").rps -= 1
	get_node("player").set_fire_rate(get_node("player").rps)
	check_button_status()
	update_shop()


func _on_regen_up_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health -= 10
	get_node("player").health = get_node("player").max_health
	get_node("player").regen_amount += 2
	check_button_status()
	update_shop()


func _on_regen_down_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health += 7
	get_node("player").health = get_node("player").max_health
	get_node("player").regen_amount -= 2
	check_button_status()
	update_shop()


func _on_speed_up_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health -= 10
	get_node("player").health = get_node("player").max_health
	get_node("player").velocity += 50
	check_button_status()
	update_shop()


func _on_speed_down_pressed():
	get_node("sound").play("Blip_Select")
	get_node("player").max_health += 7
	get_node("player").health = get_node("player").max_health
	get_node("player").velocity -= 50
	check_button_status()
	update_shop()

func _on_close_pressed():
	get_node("shop").hide()
	get_node("level").show()
	get_tree().set_pause(false)

func _on_retry_button_pressed():
	get_tree().set_pause(false)
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_resume_button_pressed():
	get_tree().set_pause(false)
	get_node("pause_panel").hide()