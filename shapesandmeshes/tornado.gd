extends MeshInstance3D

var arrays = []
var vertices = PackedVector3Array()
# Called when the node enters the scene tree for the first time.
var highest_index 
func _ready() -> void:

	vertices.push_back(Vector3(0, 0.3, 0))#0
	vertices.push_back(Vector3(0.3, 0, 0))#1
	vertices.push_back(Vector3(0, 0, 0))#2
	
	vertices.push_back(Vector3(0.3, 0.3, 0))#3
	
	
	vertices.push_back(Vector3(0.3, 0, -0.3))#4
	vertices.push_back(Vector3(0.3, 0.3, -0.3))#5

	
	var indices:PackedInt32Array= [0,1,2,3,1,0,3,4,1,5,4,3]
	highest_index = 5
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
var carry = Vector3(0,0,0)
var counter = 0
var offset = 0
var rot_offset= 0

func _process(delta: float) -> void:
	if counter % 1 == 0 and counter < 1000:
		
	
		var rand = randf_range(0.0,1.0)
		vertices.push_back(Vector3(offset+rand, offset+rand, offset-rand).rotated(Vector3.UP,rot_offset))
		vertices.push_back(Vector3(offset,offset,offset).rotated(Vector3.UP,rot_offset))
		carry = Vector3(offset+rand, offset+rand, offset-rand).rotated(Vector3.UP,rot_offset)
		offset += rand/100
		rot_offset +=0.1
		print("A")
		arrays[Mesh.ARRAY_INDEX].append(highest_index+1)
		arrays[Mesh.ARRAY_INDEX].append(highest_index-1)
		arrays[Mesh.ARRAY_INDEX].append(highest_index+2)
		highest_index += 2
	
	counter += 1
	arrays[Mesh.ARRAY_VERTEX] = vertices
	(mesh as ArrayMesh).clear_surfaces()
	(mesh as ArrayMesh).add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
