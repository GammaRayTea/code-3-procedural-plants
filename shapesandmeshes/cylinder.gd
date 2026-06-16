@tool
class_name Cylinder extends MeshInstance3D

@export var start_radius:float = 1:
	set(value):
		start_radius = value
		if initialised:
			generate()


@export var end_radius:float = 1:
	set(value):
		end_radius = value
		if initialised:
			generate()

@export var height:float = 1:
	set(value):
		height = value
		if initialised:
			generate()
@export var radial_segments:int = 8:
	set(value):
		if value > 2:
			radial_segments = value
			if initialised:
				generate()


var initialised = false


func _init(_start_radius:float =1,_end_radius:float =1,_height:float = 1,_radial_segments:int = 8, _fill_top:bool = true, _fill_bottom:bool = true):
	mesh = ArrayMesh.new()
	if _start_radius:
		start_radius = _start_radius
		end_radius = _end_radius
		height = _height
		radial_segments = _radial_segments


		generate()
		initialised = true

	



func generate() -> void:
	
	var top_arrays = []
	var bottom_arrays = []
	var side_arrays = []
	
	var bottom_circle:Array = []
	var top_circle:Array = []
	(mesh as ArrayMesh).clear_surfaces()
	
	
	bottom_circle = make_circle(0,start_radius, false)
	bottom_arrays = []
	bottom_arrays.resize(Mesh.ARRAY_MAX)
	bottom_arrays[Mesh.ARRAY_VERTEX] = bottom_circle[0]
	bottom_arrays[Mesh.ARRAY_INDEX] = bottom_circle[1]
	bottom_arrays[Mesh.ARRAY_NORMAL] = bottom_circle[2]
	
	top_circle = make_circle(height,end_radius)
	top_arrays = []
	top_arrays.resize(Mesh.ARRAY_MAX)
	top_arrays[Mesh.ARRAY_VERTEX] = top_circle[0]
	top_arrays[Mesh.ARRAY_INDEX] = top_circle[1]
	top_arrays[Mesh.ARRAY_NORMAL] = top_circle[2]
	
	
	
	
	
	
	
	side_arrays = []
	side_arrays.resize(Mesh.ARRAY_MAX)
	
	var sides = connect_circles(top_circle[0],bottom_circle[0])
	
	side_arrays[Mesh.ARRAY_VERTEX] = sides[0]
	side_arrays[Mesh.ARRAY_INDEX] = sides[1]
	side_arrays[Mesh.ARRAY_NORMAL] = sides[2]

	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, top_arrays)
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bottom_arrays)
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, side_arrays)

	
	
	

func make_circle(_height:float,_radius:float, _facing_up:bool =true ):
	if (radial_segments < 3):
		push_error("radiual_segments must be at least 3. Cannot make circle")
	
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()
	var normals = PackedVector3Array()
	#print(_height)
	
	var segment_angle = deg_to_rad(360)/radial_segments
	var center:Vector3 = Vector3(0,_height,0)
	verts.push_back(center)
	
	
	if _facing_up :
		normals.append(Vector3(0,1,0))
		normals.append(Vector3(0,1,0))
	else :
		normals.append(Vector3(0,-1,0))
		normals.append(Vector3(0,-1,0))
	for i in range(0,radial_segments-1):
		var point:Vector3 = Vector3(_radius*cos(segment_angle*i),_height,-_radius*sin(segment_angle*i))
		
		verts.push_back(point)
		
		if _facing_up :
			
			normals.push_back(Vector3(0,1,0))
		else :
			normals.push_back(Vector3(0,-1,0))
		
		indices.push_back(0)
		indices.push_back(i+2)
		indices.push_back(i+1)
	
	var last_point:Vector3 = Vector3( _radius * cos( segment_angle * (radial_segments - 1)), _height , - _radius * sin( segment_angle * ( radial_segments - 1 )))
	verts.push_back(last_point)
	indices.push_back(0)
	indices.push_back(1)
	indices.push_back(radial_segments)
	if !_facing_up :
		indices.reverse()
	#print(verts.size()," indices: ", indices.size(), " normals: ",normals.size())
	return [verts, indices, normals]


func connect_circles(_top_verts:PackedVector3Array, _bottom_verts:PackedVector3Array):
	var verts = PackedVector3Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	verts.append_array(_top_verts.slice(1))
	verts.append_array(_bottom_verts.slice(1))
	
	var top_normals =  PackedVector3Array()
	var bot_normals =  PackedVector3Array()
	var top_vert_amount = _top_verts.size()-1
	for i in range(0,verts.size()/2.0):
		
		
		#ids
		indices.push_back(i)
		indices.push_back((i+1)%top_vert_amount )
		indices.push_back(top_vert_amount +i)
		
		indices.push_back(top_vert_amount +i)
		indices.push_back((i+1)%top_vert_amount )
		indices.push_back(top_vert_amount  +((i+1) % top_vert_amount ))

		#normals

		var bot_normal =_bottom_verts[0].direction_to(_bottom_verts[i+1]) 

		bot_normals.push_back(bot_normal)
		var top_normal = _top_verts[0].direction_to(_top_verts[i+1]) 
		top_normals.push_back(top_normal)

		
	normals.append_array(top_normals)
	normals.append_array(bot_normals)

	#print("verts: ",verts.size()," indices: ", indices.size(), " normals: ",normals.size())
	return [verts, indices,normals]
