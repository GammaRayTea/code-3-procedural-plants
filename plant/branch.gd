@tool
class_name Branch extends Cylinder

@export_tool_button("Generate") var new_branch = generate

##RNG seed
@export var plant_seed:int:
	set(value):
		plant_seed = value

		
##Amount of segments along a branch
@export var vertical_segments:int = 10:
	set(value):
		vertical_segments = value


var children_segment_amount:Array[int] = []

##Maximum angle a segment can be rotated by compared to the previous segment
@export_range(0,50,0.01,"suffix:deg","or_greater") var section_angle_margin:float = 2.0:
	set(value):
		section_angle_margin = value

##Amount of recursions
@export var recursion_level:int = 0:
	set(value):
		recursion_level = value
		children_segment_amount.resize(value)
		notify_property_list_changed()


func _get_property_list() -> Array[Dictionary]:
	var properties:Array[Dictionary] = []
	properties.append({
			"name":"Child Segment Amount",
			"type": TYPE_NIL,
			"hint_string" :"Level_",
			"usage" : PROPERTY_USAGE_GROUP
		})
	for i in recursion_level:
		
		properties.append(
			{
				"name":"Level_%d_Vertical Segments" % (i+1),
				"type": TYPE_INT,
				"usage":PROPERTY_USAGE_DEFAULT
			}
		)
	return properties

func _get(property: StringName) -> Variant:
	for i in recursion_level:
		if property.begins_with("Level_%d"% (i+1)):
			return children_segment_amount[i]
	return null

func _set(property: StringName, value: Variant) -> bool:
	for i in recursion_level:
		if property.begins_with("Level_%d"% (i+1)):
			if value >= 0:
				children_segment_amount[i] = value
			
				return true
			else: return false
	return false
	
var rng :RandomNumberGenerator
var segments = []

#Initialise variables
func _init(_plant_seed:int = 1,_recursion_level:int = 0, _start_radius:float =1,_end_radius:float =0.01,_height:float = 10,_radial_segments:int = 8,_vertical_segments:int = 10, _fill_top:bool = true, _fill_bottom:bool = true):
	mesh = ArrayMesh.new()
	
	rng = RandomNumberGenerator.new()
	rng.seed = plant_seed
	
	
	plant_seed = _plant_seed
	recursion_level = _recursion_level
	if _start_radius:
		start_radius = _start_radius
		end_radius = _end_radius
		height = _height
		radial_segments = _radial_segments
		vertical_segments = _vertical_segments

	
func _ready():
	generate()

func generate() -> void:
	print("generated")
	for child in get_children():
		child.queue_free()
	rng.seed = plant_seed
	mesh.clear_surfaces()
	segments = []
	

	
	var segments_with_child_branch:Array[int] = []
	
	# Generate Sections
	var segment_height = height / vertical_segments
	var carry_circle = make_circle(0, start_radius, false)
	var carry_transform = Transform3D()
	segments.append({
			id = 0,
			segment_transform = carry_transform,
			circle_center = Vector3(0,0,0),
			top_radius = start_radius
		})
	
	
	for i in range(0,vertical_segments):
		var new_radius = start_radius - (start_radius - end_radius )/vertical_segments * (i+1)
		var new_top_circle:Array = make_circle(0,new_radius,true)

		#Transform Circle
		carry_transform = carry_transform.translated(Vector3(0,-segment_height,0))

		carry_transform = carry_transform.rotated(Vector3.RIGHT,1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*section_angle_margin))

		carry_transform = carry_transform.rotated(Vector3.FORWARD, 1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*section_angle_margin))

		carry_transform = carry_transform.rotated(Vector3.UP, 1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*section_angle_margin))

		
		new_top_circle[0] = new_top_circle[0] * carry_transform

		#Generate cylinder with previous and new circle
		if i == 0:
			generate_segment(carry_circle, new_top_circle,true)
		else:
			generate_segment(carry_circle, new_top_circle)
		
		carry_circle = new_top_circle.duplicate(true)
		
		#Test if segment gets a child branch, store in array if test is successful
		var child_branch_roll = rng.randf_range(0,vertical_segments-i)
		if (child_branch_roll <= 1.0):
			segments_with_child_branch.push_back(i)
		#Cache some data for later
		segments.append({
			id = i+1,
			segment_transform = carry_transform,
			circle_center = new_top_circle[0][0],
			top_radius = new_radius
		})
	if recursion_level>0:
		generate_child_branches(recursion_level,segments_with_child_branch)



func generate_child_branches(_recursion_level:int, _at_segments:Array[int]):


	for i in range(_at_segments.size()):
		
		#Branch params
		var bot_rad =segments[max(  0, (_at_segments[i]-1) )].top_radius*0.8
		var top_rad = bot_rad - segments[_at_segments[i]].top_radius*0.8
		var branch_height = height /4
		
		if(bot_rad == 0):
			print("bot_rad. rec_lev: ", recursion_level) 
		if(top_rad == 0):
			print("toprad. rec_lev: ", recursion_level) 
		if(branch_height == 0):
			print("height. rec_lev: ", recursion_level) 
		#Create branch
		var branch = Branch.new(plant_seed+rng.randi(), _recursion_level-1, bot_rad,  top_rad, branch_height, radial_segments, max(1,floor(vertical_segments/(i+1.0))))
		#Branch transform
		branch.transform.origin = segments[_at_segments[i]].circle_center
		
		var angle = rng.randf_range(0, 2*PI)
		var rot_vec = Vector3(cos(angle),0 , -sin(angle))
		rot_vec = rot_vec * (segments[_at_segments[i]].segment_transform as Transform3D)
		branch.rotation = rot_vec
		#Add branch to scene
		add_child(branch)
		branch.owner = self

#generate mesh based on 2 circles
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
	if _fill_bottom:
		(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bottom_arrays)

	if _fill_top:
		(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, top_arrays)

	
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, side_arrays)
	
	return [bottom_arrays,top_arrays,side_arrays]


func assemble_to_mesh():
	pass
