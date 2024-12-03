# World.gd

extends Node2D

@export var person_scene: PackedScene = preload("res://person.tscn")
@export var graph_scene: PackedScene = preload("res://Graph.tscn")
var graph_scene_instance

var id = 0
var population = 10

var statistics = {
	"Healthy": 0,
	"Sick": 1,
	"Immune": 0,
	"Infected": 1,
	"Alive": 0,
	"Dead": 0
}

var spawn_toggle = true
var infect = true

func _ready() -> void:
	print_debug_info("World _ready() called on node: " + get_name())
	statistics["Healthy"] = population - 1
	statistics["Alive"] = population
	print_debug_info("Initial statistics: " + str(statistics))
	#print_scene_tree()
	graph_scene_instance = graph_scene.instantiate()
	add_child(graph_scene_instance)

func _process(delta: float) -> void:
	if spawn_toggle and get_tree().get_nodes_in_group("Person").size() < population:
		var person_instance = person_scene.instantiate()
		person_instance.add_to_group("Person")
		person_instance.global_position.x = randi_range(100, 1000)
		person_instance.global_position.y = randi_range(100, 600)
		person_instance.name = "Person_" + str(id)
		
		if infect:
			person_instance.statuses["Sick"] = true
			person_instance.statuses["Infected"] = true
			infect = false
			
		person_instance.world = self
		person_instance.id = id
		#print_debug_info("Adding Person instance with ID: " + str(id))
		id += 1
		add_child(person_instance)
		spawn_toggle = false
		await get_tree().create_timer(0.1).timeout
		spawn_toggle = true
	else:
		spawn_toggle = false

func update_statistics():
	print_debug_info("Statistics updated: " + str(statistics) + " Total Healthy and Infected: " + str(statistics["Healthy"] + statistics["Infected"]))
	graph_scene_instance.world = self
	graph_scene_instance.max_points = population

func print_debug_info(message: String):
	print("[DEBUG] [" + get_name() + "] " + message)

#func print_scene_tree():
	#print("\n[DEBUG] Current Scene Tree:")
	#get_tree().get_root().print_tree_pretty()
	#print("")
