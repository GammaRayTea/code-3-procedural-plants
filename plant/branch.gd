@tool
class_name Branch extends Cylinder

@export_tool_button("Generate") var new_branch = generate


@export var plant_seed:int
var segment_arrays = []
@export var vertical_segments:int = 10
@export_range(0,100,0.5,"suffix:deg") var section_angle_margin:float = 2.0
var rng 


func _init(_plant_seed:int = 1,_start_radius:float =1,_end_radius:float =0.1,_height:float = 10,_radial_segments:int = 8, _fill_top:bool = true, _fill_bottom:bool = true):
	mesh = ArrayMesh.new()
	plant_seed = _plant_seed
	rng = RandomNumberGenerator.new()
	rng.seed = plant_seed
	if _start_radius:
		start_radius = _start_radius
		end_radius = _end_radius
		height = _height
		radial_segments = _radial_segments
	generate()


func generate() -> void:
	mesh.clear_surfaces()
	segment_arrays = []
	print("A")

	
	
	


	var segment_height = height / vertical_segments
	print("segment_height" , segment_height)
	var carry_circle = make_circle(0,start_radius)
	
	for i in range(0,vertical_segments):

		var new_radius = start_radius - (start_radius - end_radius )/vertical_segments * (i+1)
		var new_bottom_circle:Array = carry_circle
		var new_top_circle:Array = make_circle(segment_height*(i+1),new_radius,true)
		
		
		var new_transform = Transform3D()
		#new_transform = new_transform.rotated(Vector3.UP,deg_to_rad(randf()*section_angle_margin))
		
		print(rng.randf_range(-1,1))
		var circle_rotation = max(1, 1 / sqrt(new_radius))*deg_to_rad(rng.randf_range(-1,1)*section_angle_margin)
		new_transform = new_transform.rotated(Vector3.RIGHT, circle_rotation)
		new_transform = new_transform.rotated(Vector3.FORWARD, circle_rotation)
		
		new_top_circle[0] = new_top_circle[0]*new_transform
		generate_segment(new_bottom_circle,new_top_circle)
		
		carry_circle = new_top_circle.duplicate(true)
		




func generate_segment( _bottom_circle:Array, _top_circle:Array, _fill_bottom:bool = false, _fill_top:bool = false):
	var top_arrays = []
	var bottom_arrays = []
	var side_arrays = []
	
	
	
	bottom_arrays = []
	bottom_arrays.resize(Mesh.ARRAY_MAX)
	bottom_arrays[Mesh.ARRAY_VERTEX] = _bottom_circle[0]
	bottom_arrays[Mesh.ARRAY_INDEX] = _bottom_circle[1]
	bottom_arrays[Mesh.ARRAY_NORMAL] = _bottom_circle[2]
	
	top_arrays = []
	top_arrays.resize(Mesh.ARRAY_MAX)
	top_arrays[Mesh.ARRAY_VERTEX] = _top_circle[0]
	top_arrays[Mesh.ARRAY_INDEX] = _top_circle[1]
	top_arrays[Mesh.ARRAY_NORMAL] = _top_circle[2]
	
	
	
	side_arrays = []
	side_arrays.resize(Mesh.ARRAY_MAX)
	
	var sides = connect_circles(_top_circle[0],_bottom_circle[0])
	side_arrays[Mesh.ARRAY_VERTEX] = sides[0]
	side_arrays[Mesh.ARRAY_INDEX] = sides[1]
	side_arrays[Mesh.ARRAY_NORMAL] = sides[2]
	#if _fill_bottom:
		#(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bottom_arrays)
	#if _fill_top:
		#(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, top_arrays)


	segment_arrays.push_back([bottom_arrays,top_arrays,side_arrays])
	
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, side_arrays)
