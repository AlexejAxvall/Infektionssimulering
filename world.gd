extends Node2D

@export var person_scene: PackedScene = preload("res://person.tscn")

var id = 0
var population = 10

var statistics = {
	"Healthy": 0,
	"Infected":  1,
	"Immune": 0,
	"Alive": 0
}

var spawn_toggle = true

var infect = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	statistics["Healthy"] = population - 1
	statistics["Alive"] = population
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawn_toggle and get_tree().get_nodes_in_group("Person").size() < population:
		var person_instance = person_scene.instantiate()
		person_instance.add_to_group("Person")
		person_instance.global_position.x = randi_range(100, 1000)
		person_instance.global_position.y = randi_range(100, 600)
		
		if infect:
			person_instance.statuses["Sick"] = true
			person_instance.statuses["Infected"] = true
			infect = false
			
		person_instance.world = self
		person_instance.id = id
		id += 1
		add_child(person_instance)
		spawn_toggle = false
		await get_tree().create_timer(0.1).timeout
		spawn_toggle = true
	else:
		spawn_toggle = false

func update_statistics():
	print(str(statistics) + str(statistics["Healthy"] + statistics["Infected"]))
