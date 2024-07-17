extends Area2D


onready var rayFolder := $rayFolder.get_children()
onready var radiusVis := $vision/CollisionPolygon2D
var boidsISee := []
var bo_vel := Vector2.ZERO
var screensize : Vector2
var movv := 42
var repel := 250
var previous_rotation : float

var b_type : int
#Boids types,
#1 - Boid group 1 (White)
#2 - Boid group 2 (Green)
#3 - Boid group 3 (Blue)
#4 - Predator boid (Red)

#Customisable Variables
export var bo_speed := 3.5

export var bo_speed_2 : int = 1
export var bo_max_speed := 3
export var bo_min_speed := 1
export var bo_size := 0.5

export var margin = 50
export var margin_fix := Vector2(0, 0)
export var margin_max := 0.05

func _ready() -> void:
	screensize = get_viewport_rect().size
	randomize()
	
#	b_type = round(rand_range(1, 4)) #Summon types of Boids
	bo_speed = bo_speed * bo_size
	scale = Vector2(bo_size, bo_size)
	rotation = rand_range(0, 360)
	radiusVis.scale = Vector2(1.2, 1.2)
	
	if b_type == 1: modulate = Color(1, 1, 1, 1)
	elif b_type == 2: modulate = Color(0, 1, 0, 1)
	elif b_type == 3: modulate = Color(0, 0, 1, 1)
	elif b_type == 4: 
		modulate = Color(1, 0, 0, 1)
		radiusVis.scale = Vector2(1.25, 0.3)
		scale = Vector2(bo_size + (bo_size / 2), bo_size + (bo_size / 2))


func _physics_process(_delta: float) -> void:
	boids()
	checkCollision()
	bo_vel = bo_vel.normalized() * bo_speed
	move()
	
	rotation = lerp_angle(rotation, bo_vel.angle_to_point(Vector2.ZERO), 0.2)
	clamp_rotation()
	
	mouseCheck()
	
	
func mouseCheck():
	if Input.is_action_pressed("rClick"):
		var c_mouse_pos = get_global_mouse_position()
		var c_pos = Vector2(c_mouse_pos.x - position.x, c_mouse_pos.y - position.y)
		var c_mouse_dis = (sqrt((c_pos.x * c_pos.x) + (c_pos.y * c_pos.y)))
		
		if c_mouse_dis <= 75: queue_free()


func clamp_rotation():
	var maxDeltaRotation = 1.5708
	var clampedRotation = clamp(rotation, previous_rotation - maxDeltaRotation, previous_rotation + maxDeltaRotation)
	rotation = clampedRotation 
	previous_rotation = rotation


func boids() -> void:
	bo_speed_2 += (bo_min_speed - bo_speed_2) / 24
	
	if boidsISee:
		var numOfBoids := boidsISee.size()
		var avgVel := Vector2.ZERO
		var avgPos := Vector2.ZERO
		var steerAway := Vector2.ZERO
		
		for boid in boidsISee:
			var seg_dis : float
			if boid.b_type <= 3 && b_type != 4: #Normal, unmatching normal in range
				seg_dis = 2.25
				
			if boid.b_type <= 3 && b_type == 4: #Red, normal in range
				seg_dis = 1.05
			
			if boid.b_type == b_type && b_type != 4: #Normal, matching normal in range
				seg_dis = 0.9
				bo_speed_2 -= 0.3
			
			if boid.b_type == b_type && b_type == 4: #Red, red in range
				seg_dis = 2
				bo_speed_2 += 0.35
			
			if boid.b_type == 4 && b_type <= 3: #Normal, red in range
				seg_dis = 10
				bo_speed_2 += 2
			
			avgPos += boid.position
			avgVel += boid.bo_vel
			steerAway -= (boid.global_position - global_position) * (((movv * seg_dis) * bo_size) / (global_position - boid.global_position).length())
		
		avgVel /= numOfBoids
		bo_vel += (avgVel - bo_vel) / 2.5 
		
		avgPos /= numOfBoids
		bo_vel += (avgPos - position)
		
		steerAway /= numOfBoids
		bo_vel += (steerAway)
		
		bo_speed_2 = clamp(bo_speed_2, bo_min_speed, bo_max_speed)
		
		bo_vel *= bo_speed_2
	
func checkCollision() -> void:
	for ray in rayFolder:
		var r : RayCast2D = ray
		
		if r.is_colliding():
			if r.get_collider().is_in_group("blocks"):
				var magi := abs(repel / (r.get_collision_point() - global_position).length())
				bo_vel -= (r.cast_to.rotated(rotation) * sqrt(magi))
		pass

func move() -> void:
	global_position += bo_vel
	if global_position.x < 0:
		global_position.x = screensize.x 
	if global_position.x > screensize.x:
		global_position.x = 0
	if global_position.y < 0:
		global_position.y = screensize.y 
	if global_position.y > screensize.y:
		global_position.y = 0
		
	if global_position.x < margin: 
		margin_fix.x += margin_max
		bo_vel.x += margin_fix.x
	elif global_position.x > screensize.x - margin: 
		margin_fix.x += margin_max
		bo_vel.x -= margin_fix.x
	else: margin_fix.x = 0
	
	if global_position.y < margin: 
		margin_fix.y += margin_max
		bo_vel.y += margin_fix.y
	elif global_position.y > screensize.y - margin: 
		margin_fix.y += margin_max
		bo_vel.y -= margin_fix.y
	else: margin_fix.y = 0


func _on_vision_area_entered(area: Area2D) -> void:
	if area != self and area.is_in_group("boid"):
		boidsISee.append(area)
func _on_vision_area_exited(area: Area2D) -> void:
	if area:
		boidsISee.erase(area)

func _on_boid_body_entered(body: Node) -> void:
	if body:
		queue_free()
