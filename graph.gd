extends GraphEdit

# Statistics arrays
var healthy_stats = []
var sick_stats = []
var infected_stats = []
var dead_stats = []

const MAX_POINTS = 100  # Maximum number of points to display on the graph

# Reference to the viewport for drawing
@onready var graph_viewport = $GraphViewport

func _ready():
	# Initialize empty statistics arrays
	healthy_stats.resize(MAX_POINTS)
	sick_stats.resize(MAX_POINTS)
	infected_stats.resize(MAX_POINTS)
	dead_stats.resize(MAX_POINTS)

	# Fill arrays with initial values (zeros)
	for i in range(MAX_POINTS):
		healthy_stats[i] = 0
		sick_stats[i] = 0
		infected_stats[i] = 0
		dead_stats[i] = 0


func _process(delta):
	if World:  # Ensure World is accessible
		# Fetch statistics from the World singleton
		var healthy = World.statistics.get("Healthy", 0)
		var sick = World.statistics.get("Sick", 0)
		var infected = World.statistics.get("Infected", 0)
		var dead = World.statistics.get("Dead", 0)

		# Debugging: Print statistics to verify
		print("World statistics: Healthy =", healthy, ", Sick =", sick, ", Infected =", infected, ", Dead =", dead)

		# Update the graph with the fetched statistics
		update_statistics(healthy, sick, infected, dead)
	else:
		print("World singleton is not accessible!")


func update_statistics(healthy: int, sick: int, infected: int, dead: int):
	# Add new statistics to the arrays
	healthy_stats.append(healthy)
	sick_stats.append(sick)
	infected_stats.append(infected)
	dead_stats.append(dead)

	# Ensure we only display the latest MAX_POINTS
	if healthy_stats.size() > MAX_POINTS:
		healthy_stats.pop_front()
		sick_stats.pop_front()
		infected_stats.pop_front()
		dead_stats.pop_front()

	# Trigger the graph to redraw
	graph_viewport.update()


func _draw():
	# Draw the graph
	draw_graph()


func draw_graph():
	var graph_width = graph_viewport.get_rect().size.x
	var graph_height = graph_viewport.get_rect().size.y
	var step_x = graph_width / MAX_POINTS

	# Draw the graph lines for each dataset
	draw_graph_line(healthy_stats, graph_height, Color(0, 1, 0), step_x)  # Green for healthy
	draw_graph_line(sick_stats, graph_height, Color(1, 0.5, 0), step_x)   # Orange for sick
	draw_graph_line(infected_stats, graph_height, Color(1, 0, 0), step_x)  # Red for infected
	draw_graph_line(dead_stats, graph_height, Color(0.5, 0.5, 0.5), step_x)  # Gray for dead


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
	var all_stats = healthy_stats + sick_stats + infected_stats + dead_stats
	if all_stats.size() == 0:
		return 0
	var max_value = all_stats[0]
	for value in all_stats:
		if value > max_value:
			max_value = value
	return max_value
