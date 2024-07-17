extends Node2D


export var num := 0
export var margin := 300
var screensize : Vector2
var tile_col : bool = true
var poly_col : bool = false

onready var boid_setting = 5

func _process(_delta):
	$Poly.position = get_global_mouse_position()
	$Poly.rotation += 0.02
	
	var b_count = $boidFolder.get_child_count() 
	$CanvasLayer/Text1.text = str(" # of Boids - ", b_count, "\n Controls -\n 1, Toggles Tilemap\n 2, Toggles Polygon Map\n Left Click, Spawns Boids\n Right Click, Kills Boids\n Middle Click to Change Boid Setting")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #Hide mouse
	
	screensize = get_viewport_rect().size
	randomize()
	
	boid_setting = 5
	poly_col()
	
	for i in num: spawnBoid()
	
	$TileMap.global_position.y = 0
	$PolygonMap.global_position.y = 5000
	$TextureMap.visible = false


func poly_col():
	if boid_setting == 1: $Poly.modulate = Color(1, 1, 1, 0.75)
	if boid_setting == 2: $Poly.modulate = Color(0, 1, 0, 0.75)
	if boid_setting == 3: $Poly.modulate = Color(0, 0, 1, 0.75)
	if boid_setting == 4: $Poly.modulate = Color(1, 0, 0, 0.75)
	if boid_setting == 5: $Poly.modulate = Color(1, 1, 1, 0.75)
	if boid_setting == 6: $Poly.modulate = Color(0, 0, 0, 0.75)


func _on_Timer_timeout() -> void:
	var c := $boidFolder.get_child_count() 
	if c < num:
		print("fishless :(")
		for i in floor(num - c):
			spawnBoid()


func spawnBoid() -> void:
	var boid : Area2D = preload("res://boid.tscn").instance()
	$boidFolder.add_child(boid)
	boid.global_position = Vector2((rand_range(margin, screensize.x - margin)), (rand_range(margin, screensize.y - margin)) )


func _unhandled_input(event) -> void:
	if event.is_action_pressed("toggle_map"): #Toggle Tilemap Collsion
		tile_col = !tile_col
		
		if tile_col == true: 
			$TileMap.global_position.y = 0
			poly_col = false
			$PolygonMap.global_position.y = -5000
			$TextureMap.visible = false
		
		else: $TileMap.global_position.y = 5000
	
	
	if event.is_action_pressed("toggle_poly_map"): #Toggle Polygon Collsion
		poly_col = !poly_col
		
		if poly_col == true: 
			$PolygonMap.global_position.y = 0
			tile_col = false
			$TileMap.global_position.y = 5000
			$TextureMap.visible = true
			
		else: 
			$PolygonMap.global_position.y = -5000
			$TextureMap.visible = false
	
	if Input.is_action_just_pressed("lClick"): #Spawns 5 Boids
		var spawn_am : int
		if boid_setting != 4: spawn_am = 5
		else: spawn_am = 1
		 
		for i in spawn_am:
			var boid : Area2D = preload("res://boid.tscn").instance()
			
			if boid_setting == 5: boid.b_type = round(rand_range(1, 4))
			elif boid_setting == 6: boid.b_type = round(rand_range(1, 3))
			else: boid.b_type = boid_setting
			
			$boidFolder.add_child(boid)
			var mouse_pos : Vector2 = get_global_mouse_position()
			boid.global_position = Vector2(mouse_pos.x + rand_range(-10, 10), mouse_pos.y + rand_range(-10, 10))

		
	if Input.is_action_just_pressed("midClick"): #Change boid spawn system
		boid_setting += 1
		if boid_setting >= 7: boid_setting = 1
		poly_col()
