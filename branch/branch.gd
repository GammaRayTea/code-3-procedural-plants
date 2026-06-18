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


var child_branch_properties:Array[Dictionary] = []

##Maximum angle a segment can be rotated by compared to the previous segment
@export_range(0,50,0.01,"suffix:deg","or_greater") var twist_angle_range:float = 2.0:
	set(value):
		twist_angle_range = value

var base_wind_effect:float = 0.0

##Material for branch and all it's children
@export var branch_material: Material

@export_category("Leaves")
##base scene for leaves
@export var leaves_scene:PackedScene
##Material for leaves
@export var leaves_material:Material
@export var enable_leaves:bool = false

@export_category("Growth")
## Direction to which branches will orient themselves towards 
@export var growth_direction: Vector3 = Vector3(0,1,0)
## Controls how strong [code]growth_direction[/code] influences branch orientation
@export var growth_force:float = 0.0

@export_category("Child Branches")
## Curve controlling the probability y along the length of this branch x for a child branch to spawn.
@export var child_branch_distribution: Curve
@export var child_branch_lengths: Curve


##Amount of recursions
@export var recursion_level:int = 0:
	set(value):
		recursion_level = value
		if value>child_branch_properties.size():
			
			for i in value-child_branch_properties.size():
				child_branch_properties.append({
					"segments":0,
					"length_modifier": 1.0,
					"twist_angle_range":2.0
				})

		else:
			child_branch_properties = child_branch_properties.slice(0, value)

		
		notify_property_list_changed()




func _get_property_list() -> Array[Dictionary]:
	var properties:Array[Dictionary] = []
	properties.append({
		"name":"Child Branch Properties",
		"type": TYPE_NIL,
		"hint_string" :"Child",
		"usage" : PROPERTY_USAGE_GROUP
	})
			
	for i in recursion_level:
		properties.append(
			{
			"name":"Child_Level_%d_properties" % (i+1),
			"type": TYPE_DICTIONARY,
			"hint_string":"%d:" % [TYPE_STRING],
			"usage":PROPERTY_USAGE_DEFAULT
			})
			
	return properties

func _get(property: StringName) -> Variant:

	for i in recursion_level:
		if property.begins_with("Child_Level_%d"% (i+1)):
			return child_branch_properties[i]

	return null

func _set(property: StringName, value: Variant) -> bool:
	for i in recursion_level:
		if property.begins_with("Child_Level_%d"% (i+1)):
			if value.segments >= 0 and value.length_modifier >= 0.0 and value.size()==3:
				child_branch_properties[i]= value
			
				return true
			else: return false
	return false
	

var rng :RandomNumberGenerator
var segments:Array = []


#Initialise
func _init(_plant_seed:int = 1,_recursion_level:int = 0, _start_radius:float =1,_end_radius:float =0.01,_height:float = 10,_radial_segments:int = 8,_vertical_segments:int = 10, _twist_angle_range:float = 2.0):
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
		twist_angle_range = _twist_angle_range

	
func _ready():
	generate()

func generate() -> void:

	for child in get_children():
		child.queue_free()
	rng.seed = plant_seed
	mesh.clear_surfaces()
	segments = []
	
	var branch_mesh_arrays:Array = []
	branch_mesh_arrays.resize(Mesh.ARRAY_MAX)
	
	branch_mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	branch_mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	branch_mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	branch_mesh_arrays[Mesh.ARRAY_COLOR] = PackedColorArray()
	branch_mesh_arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	
	
	var segments_with_child_branch:Array[int] = []
	
	# Generate Sections
	var segment_height = height / vertical_segments
	
	#first circle
	var carry_circle = make_circle(0, start_radius, false)
	var carry_transform = Transform3D()
	segments.append({
			segment_transform = carry_transform,
			circle_center = Vector3(0,0,0),
			top_radius = start_radius
		})
	branch_mesh_arrays[Mesh.ARRAY_VERTEX].append_array(carry_circle[0].slice(1))
	branch_mesh_arrays[Mesh.ARRAY_NORMAL].append_array(carry_circle[0].slice(1))
	for i in radial_segments:
		branch_mesh_arrays[Mesh.ARRAY_COLOR].push_back(Color(base_wind_effect,0,0,1))
		branch_mesh_arrays[Mesh.ARRAY_TEX_UV].push_back(Vector2(float(i)/radial_segments, 0))


	for i in range(0,vertical_segments):
		var new_radius = start_radius - (start_radius - end_radius )/vertical_segments * (i+1)
		var new_top_circle:Array = make_circle(0,new_radius,true)

			
		#Transform Circle with random rotations
		carry_transform = carry_transform.translated(Vector3(0,-segment_height,0))

		carry_transform = carry_transform.rotated(Vector3.RIGHT,1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*twist_angle_range))

		carry_transform = carry_transform.rotated(Vector3.FORWARD, 1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*twist_angle_range))

		carry_transform = carry_transform.rotated(Vector3.UP, 1 / sqrt(new_radius) * deg_to_rad(rng.randf_range(-1,1)*twist_angle_range))

		
		new_top_circle[0] = new_top_circle[0] * carry_transform
		
		var distance_along_length  = float(i+1)/vertical_segments

		#Generate cylinder with previous and new circle
		var segment_arrays = generate_segment(
			carry_circle, 
			new_top_circle,
			base_wind_effect + distance_along_length*(1 - base_wind_effect), 
			i*radial_segments, 
			(i+1)*radial_segments-radial_segments
			)
		
		branch_mesh_arrays[Mesh.ARRAY_VERTEX].append_array((segment_arrays[Mesh.ARRAY_VERTEX]as Array).slice(radial_segments))
		branch_mesh_arrays[Mesh.ARRAY_INDEX].append_array(segment_arrays[Mesh.ARRAY_INDEX])
		branch_mesh_arrays[Mesh.ARRAY_NORMAL].append_array((segment_arrays[Mesh.ARRAY_NORMAL]as Array).slice(radial_segments))
		branch_mesh_arrays[Mesh.ARRAY_COLOR].append_array((segment_arrays[Mesh.ARRAY_COLOR]as Array).slice(radial_segments)) 
		branch_mesh_arrays[Mesh.ARRAY_TEX_UV].append_array((segment_arrays[Mesh.ARRAY_TEX_UV]as Array))

		carry_circle = new_top_circle.duplicate(true)
		
		#Test if segment gets a child branch, store in array if test is successful
		var child_branch_roll = rng.randf_range(0,1)
		if (child_branch_roll <= child_branch_distribution.sample(distance_along_length)):
			segments_with_child_branch.push_back(i)
		#Cache some data for later
		segments.append({
			segment_transform = carry_transform,
			circle_center = new_top_circle[0][0],
			top_radius = new_radius
		})
	
	#generate child branches
	if recursion_level>0:
		generate_child_branches(recursion_level,segments_with_child_branch)
	elif enable_leaves :
		generate_leaves(segments_with_child_branch)
	#add surface
	finalize_branch_surface(branch_mesh_arrays)



#generate child branches
func generate_child_branches(_recursion_level:int, _at_segments:Array[int]):


	for i in range(_at_segments.size()):
		var distance_along_length  = float(_at_segments[i])/vertical_segments
		
		#Branch params
		var bot_rad =segments[max(  0, (_at_segments[i]) )].top_radius*0.4
		var branch_height = child_branch_properties[0].length_modifier * child_branch_lengths.sample(distance_along_length)
		var wind_influence = base_wind_effect + distance_along_length*(1.0 - base_wind_effect)
		
		
		#Create branch
		var branch = Branch.new(plant_seed+rng.randi(), _recursion_level-1, bot_rad,  end_radius, branch_height, radial_segments, child_branch_properties[0].segments , child_branch_properties[0].twist_angle_range)
		branch.child_branch_properties = child_branch_properties.slice(1,0x7FFFFFFF,1,true)
		branch.child_branch_distribution = child_branch_distribution
		branch.child_branch_lengths = child_branch_lengths
		branch.branch_material = branch_material
		branch.leaves_material= leaves_material
		branch.base_wind_effect = wind_influence
		branch.growth_direction = growth_direction
		branch.growth_force = growth_force
		branch.enable_leaves = enable_leaves
		#transform
		set_child_transform(branch,_at_segments[i])
		#Add branch to scene
		add_child(branch)
		branch.owner = self
		branch.generate()

func generate_leaves( _at_segments:Array[int]) ->void:
	for i in range(_at_segments.size()):
		var distance_along_length  = float(_at_segments[i])/vertical_segments
		var wind_influence = base_wind_effect + distance_along_length*(1 - base_wind_effect)
		
		

		var leaves:BasicLeaves = load("res://leaves/basic_leaves.tscn").instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		leaves.apply_material(leaves_material.duplicate(),wind_influence)
		set_child_transform(leaves,_at_segments[i])
		add_child(leaves)
		leaves.set_owner( self)
		
		

func set_child_transform(object:Node3D,segment_id:int):
	#position transform
	object.transform.origin = segments[segment_id].circle_center
	
	#angle around parent
	#var angle =2.0*PI* (float(_at_segments[i])/vertical_segments)
	var angle =2.0*PI* rng.randf_range(0,1)
	var rot_vec = Vector3(cos(angle),0 , -sin(angle))
	rot_vec = rot_vec * (segments[segment_id].segment_transform as Transform3D)
	
	
	#angle toward growth direction
	rot_vec = rot_vec.move_toward(growth_direction,growth_force)

	#apply angle
	object.rotation = rot_vec
	

#generate mesh based on 2 circles
func generate_segment( _bottom_circle:Array, _top_circle:Array,_distance_along_length:float, _top_index_offset:int, _bottom_index_offset:int):
	var side_arrays:Array = []
	side_arrays.resize(Mesh.ARRAY_MAX)
	
	var sides = connect_circles(_top_circle[0],_bottom_circle[0],Color(_distance_along_length,0,0,1),_top_index_offset, _bottom_index_offset,_distance_along_length)
	side_arrays[Mesh.ARRAY_VERTEX] = sides[0]
	side_arrays[Mesh.ARRAY_INDEX] = sides[1]
	side_arrays[Mesh.ARRAY_NORMAL] = sides[2]
	side_arrays[Mesh.ARRAY_COLOR] = sides[3]
	side_arrays[Mesh.ARRAY_TEX_UV] = sides[4]
	
	
	return side_arrays


func finalize_branch_surface(arrays:Array)->void:

	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh.surface_set_material(0,branch_material)
	mesh.surface_get_material(0).set("shader_parameter/uv_scale",Vector2(1.0,height))
