#graph script

extends GraphEdit

var world

# Statistics arrays
var healthy_stats = []
var sick_stats = []
var immune_stats = []
var infected_stats = []
var alive_stats = []

var max_points = 0

# Reference to the viewport for drawing
@onready var graph_viewport = $GraphViewport

func _ready():
	# Fill arrays with initial values (zeros)
	for i in range(max_points):
		healthy_stats[i] = 0
		sick_stats[i] = 0
		immune_stats[i] = 0
		infected_stats[i] = 0
		alive_stats[i] = 0
		
	# Initialize empty statistics arrays
	healthy_stats.resize(max_points)
	sick_stats.resize(max_points)
	immune_stats.resize(max_points)
	infected_stats.resize(max_points)
	alive_stats.resize(max_points)


func _process(delta):
	if world:  # Ensure world is accessible
		# Fetch statistics from the world singleton
		var healthy = world.statistics.get("Healthy", 0)
		var sick = world.statistics.get("Sick", 0)
		var immune = world.statistics.get("Immune", 0)
		var infected = world.statistics.get("Infected", 0)
		var alive = world.statistics.get("Alive", 0)

		# Debugging: Print statistics to verify
		#print("world statistics: Healthy: ", healthy, ", Sick: ", sick, ", Immune: ", immune, ", Infected: ", infected, ", Alive: ", alive)

		# Update the graph with the fetched statistics
		update_statistics(healthy, sick, immune, infected, alive)
	else:
		#print("What is world?")
		pass


func update_statistics(healthy: int, sick: int, immune: int, infected: int, alive: int):
	# Add new statistics to the arrays
	healthy_stats.append(healthy)
	sick_stats.append(sick)
	immune_stats.append(immune)
	infected_stats.append(infected)
	alive_stats.append(alive)

	# Ensure we only display the latest max_points
	if healthy_stats.size() > max_points:
		healthy_stats.pop_front()
		sick_stats.pop_front()
		immune_stats.pop_front()
		infected_stats.pop_front()
		alive_stats.pop_front()


func _draw():
	# Draw the graph
	draw_graph()


func draw_graph():
	var graph_width = graph_viewport.get_rect().size.x
	var graph_height = graph_viewport.get_rect().size.y
	var step_x = graph_width / max_points

	# Draw the graph lines for each dataset
	draw_graph_line(healthy_stats, graph_height, Color(255, 255, 255), step_x)  # Green for healthy
	draw_graph_line(sick_stats, graph_height, Color(100, 255, 100), step_x)   # Orange for sick
	draw_graph_line(immune_stats, graph_height, Color(0, 0, 255), step_x)  # Blue for immune
	draw_graph_line(infected_stats, graph_height, Color(100, 0, 0), step_x)  # Red for infected
	draw_graph_line(alive_stats, graph_height, Color(0.5, 0.5, 0.5), step_x)  # Gray for alive


func draw_graph_line(data: Array, graph_height: float, color: Color, step_x: float):
	var max_value = get_max_value()
	if max_value == 0:
		return  # Avoid division by zero

	var scale = graph_height / max_value

	for i in range(data.size() - 1):
		var x1 = i * step_x
		var y1 = graph_height - (data[i] * scale)
		var x2 = (i + 1) * step_x
		var y2 = graph_height - (data[i + 1] * scale)
		draw_line(Vector2(x1, y1), Vector2(x2, y2), color, 2)


func get_max_value() -> int:
	var all_stats = healthy_stats + sick_stats + infected_stats + alive_stats
	if all_stats.size() == 0:
		return 0
	var max_value = all_stats[0]
	for value in all_stats:
		if value > max_value:
			max_value = value
	return max_value
