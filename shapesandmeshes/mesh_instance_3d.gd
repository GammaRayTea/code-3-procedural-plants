extends MeshInstance3D

var arrays = []
var vertices = PackedVector3Array()
# Called when the node enters the scene tree for the first time.

func _ready() -> void:

	vertices.push_back(Vector3(0,0 , -1))#0
	vertices.push_back(Vector3(0, 1, -1))#1
	
	vertices.push_back(Vector3(0,  0,-0.5))#2
	vertices.push_back(Vector3(0, 1, -0.5))#3
	
	vertices.push_back(Vector3(-0.5, 0, 0))#4
	vertices.push_back(Vector3(-0.5, 1,0 ))#5
	
	vertices.push_back(Vector3(-1, 0, 0))#6
	vertices.push_back(Vector3(-1, 1, 0))#7
	

	
	var indices:PackedInt32Array= [
		0,2,1,
		1,2,3,
		2,5,3,
		2,4,5,
		4,7,5,
		4,6,7
	]

	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	
	var normals = PackedVector3Array()
	normals.push_back(Vector3(1,0,0))
	normals.push_back(Vector3(1,0,0))
	
	normals.push_back(Vector3(1,0,0.5))
	normals.push_back(Vector3(1,0,0.5))
	
	normals.push_back(Vector3(0.5,0,1))
	normals.push_back(Vector3(0.5,0,1))
	
	normals.push_back(Vector3(0,0,1))
	normals.push_back(Vector3(0,0,1))
	arrays[Mesh.ARRAY_NORMAL] = normals
	
	#var colors:PackedColorArray = [
		#Color(0,1,0),
		#Color(1,0,0),
		#Color(0,0,1),
		#Color(1,1,0),
		#Color(0,1,0),
		#Color(1,0,0),
		#Color(0,0,1),
		#Color(1,1,0)
#
	#]
	#arrays[Mesh.ARRAY_COLOR] = colors
	
	
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
