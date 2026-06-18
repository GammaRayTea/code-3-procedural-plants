@tool
class_name Leaves extends MeshInstance3D
var distance_scalar:float
var material
func _init(_distance_scalar:float,_material):
	mesh = ArrayMesh.new()
	distance_scalar = _distance_scalar
	material = _material
	
	generate()


func generate():
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	#verts
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	
	arrays[Mesh.ARRAY_VERTEX].push_back(Vector3(0,0,0))
	arrays[Mesh.ARRAY_VERTEX].push_back(Vector3(5,0,0))
	arrays[Mesh.ARRAY_VERTEX].push_back(Vector3(5,0,5))
	arrays[Mesh.ARRAY_VERTEX].push_back(Vector3(0,0,5))
	
	#indices
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()

	arrays[Mesh.ARRAY_INDEX].push_back(0)
	arrays[Mesh.ARRAY_INDEX].push_back(3)
	arrays[Mesh.ARRAY_INDEX].push_back(1)
	
	arrays[Mesh.ARRAY_INDEX].push_back(1)
	arrays[Mesh.ARRAY_INDEX].push_back(3)
	arrays[Mesh.ARRAY_INDEX].push_back(2)
	#normals
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	
	arrays[Mesh.ARRAY_NORMAL].push_back(Vector3(0,-1,0))
	arrays[Mesh.ARRAY_NORMAL].push_back(Vector3(0,-1,0))
	arrays[Mesh.ARRAY_NORMAL].push_back(Vector3(0,-1,0))
	arrays[Mesh.ARRAY_NORMAL].push_back(Vector3(0,-1,0))

	#uvs
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	arrays[Mesh.ARRAY_TEX_UV].push_back(Vector2(1,0))
	arrays[Mesh.ARRAY_TEX_UV].push_back(Vector2(0,0))
	arrays[Mesh.ARRAY_TEX_UV].push_back(Vector2(0,1))
	arrays[Mesh.ARRAY_TEX_UV].push_back(Vector2(1,1))




	#colors
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray()
	
	arrays[Mesh.ARRAY_COLOR].push_back(Color(distance_scalar,0,0,1))
	arrays[Mesh.ARRAY_COLOR].push_back(Color(distance_scalar,0,0,1))
	arrays[Mesh.ARRAY_COLOR].push_back(Color(distance_scalar,0,0,1))
	arrays[Mesh.ARRAY_COLOR].push_back(Color(distance_scalar,0,0,1))

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0,material)
