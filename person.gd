extends CharacterBody2D

class_name Person
var id

@onready var navigation_agent_2D : NavigationAgent2D = $NavigationAgent2D
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
	if statuses["Infected"]:
		colorRect.color = Color(100, 0, 0)
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
	if not timer_on and body is Person and id != body.id:
		if not statuses["Sick"] and not statuses["Infected"] and not statuses["Immune"] and body.statuses["Infected"]:
			#print("Stranger danger!")
			var infection_roll = randi_range(1, 6)
			#print("Infection roll: " + str(infection_roll))
			if infection_roll > 3:
				#print("Avoided infection!")
				pass
			else:
				#print("Infected")
				statuses["Sick"] = true
				world.statistics["Healthy"] -= 1
				statuses["Infected"] = true
				world.statistics["Infected"] += 1
				world.update_statistics()
				colorRect.color = Color(100, 0, 0)
				timer_on = true
				await get_tree().create_timer(4).timeout
				var roll = randi_range(1, 6)
				if roll > 4:
					statuses["Immune"] = true
					world.statistics["Immune"] += 1
					statuses["Sick"] = false
					world.statistics["Healthy"] += 1
					statuses["Infected"] = false
					world.statistics["Infected"] -= 1
					colorRect.color = Color(0, 100, 255)
				elif roll > 2:
					statuses["Sick"] = false
					world.statistics["Healthy"] += 1
					statuses["Infected"] = false
					world.statistics["Infected"] -= 1
					colorRect.color = Color(255, 255, 255)
				elif roll < 3:
					statuses["Dead"] = true
					world.statistics["Alive"] -= 1
					if not statuses["Sick"] and not statuses["Infected"]:
						#print("WTF death")
						pass
					else:
						world.statistics["Healthy"] -= 1
						world.statistics["Infected"] -= 1
						world.statistics["Alive"] -= 1
						#print("Roll outcome: " + str(roll))
						#print("Died!")
						pass
					#print("Statuses: " + str(statuses))
					#print()
					queue_free()
				world.update_statistics()
				timer_on = false


func _on_navigation_agent_2d_target_reached() -> void:
	random_position.x = randi_range(200, 1000)
	random_position.y = randi_range(200, 600)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
