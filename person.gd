# Person.gd

extends CharacterBody2D

class_name Person
var id

@onready var navigation_agent_2D: NavigationAgent2D = $NavigationAgent2D
@onready var colorRect = $ColorRect
@onready var collisionshape2D = $Body
var shape
var world
var random_position = Vector2.ZERO

const SPEED = 200.0

var statuses = {
	"Sick": false,
	"Infected": false,
	"Immune": false,
	"Dead": false
}

var timer_on = false

func _ready() -> void:
	#print_debug_info("Person _ready() called on node: " + get_name() + ", ID: " + str(id))
	if statuses["Infected"]:
		colorRect.color = Color(1, 0, 0)  # Use normalized color values (0-1)
		#print_debug_info("Person ID " + str(id) + " is initially infected.")
	shape = collisionshape2D.shape
	random_position.x = randi_range(200, 1000)
	random_position.y = randi_range(200, 600)

func _physics_process(delta: float) -> void:
	var current_position = global_position
	navigation_agent_2D.target_position = random_position
	var next_path_position = navigation_agent_2D.get_next_path_position()
	var new_velocity = current_position.direction_to(next_path_position).normalized() * SPEED
	
	if navigation_agent_2D.avoidance_enabled:
		navigation_agent_2D.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

func _on_infektion_area_body_entered(body: Node2D) -> void:
	#print_debug_info("Person ID " + str(id) + " entered infection area with body: " + body.get_name())
	if not timer_on and body is Person and id != body.id:
		if not statuses["Sick"] and not statuses["Infected"] and not statuses["Immune"] and body.statuses["Infected"]:
			#print_debug_info("Person ID " + str(id) + " is at risk of infection from Person ID " + str(body.id))
			var infection_roll = randi_range(1, 6)
			#print_debug_info("Infection roll: " + str(infection_roll))
			if infection_roll > 3:
				#print_debug_info("Person ID " + str(id) + " avoided infection.")
				pass
			else:
				#print_debug_info("Person ID " + str(id) + " got infected.")
				statuses["Sick"] = true
				world.statistics["Sick"] += 1
				world.statistics["Healthy"] -= 1
				statuses["Infected"] = true
				world.statistics["Infected"] += 1
				colorRect.color = Color(1, 0, 0)
				world.update_statistics()
				timer_on = true
				await handle_infection_progress()

func handle_infection_progress():
	await get_tree().create_timer(1).timeout
	var roll = randi_range(1, 6)
	#print_debug_info("Recovery roll for Person ID " + str(id) + ": " + str(roll))
	if roll > 4:
		#print_debug_info("Person ID " + str(id) + " became immune.")
		colorRect.color = Color(0, 0, 255)
		statuses["Immune"] = true
		world.statistics["Immune"] += 1
		statuses["Sick"] = false
		world.statistics["Sick"] -= 1
		world.statistics["Healthy"] += 1
		statuses["Infected"] = false
		world.statistics["Infected"] -= 1
	elif roll > 2:
		#print_debug_info("Person ID " + str(id) + " recovered.")
		colorRect.color = Color(255, 255, 255)
		statuses["Sick"] = false
		world.statistics["Healthy"] += 1
		world.statistics["Sick"] -= 1
		statuses["Infected"] = false
		world.statistics["Infected"] -= 1
	else:
		#print_debug_info("Person ID " + str(id) + " died.")
		statuses["Dead"] = true
		world.statistics["Sick"] -= 1
		world.statistics["Infected"] -= 1
		world.statistics["Alive"] -= 1
		world.statistics["Dead"] += 1
		world.update_statistics()
		queue_free()
		return
	world.update_statistics()
	timer_on = false

func _on_navigation_agent_2d_target_reached() -> void:
	random_position.x = randi_range(200, 1000)
	random_position.y = randi_range(200, 600)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

#func print_debug_info(message: String):
	#print("[DEBUG] [Person ID " + str(id) + "] " + message)
