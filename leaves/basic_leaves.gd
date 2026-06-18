@tool
class_name BasicLeaves extends Node3D

@export var mesh1:MeshInstance3D
@export var mesh2:MeshInstance3D

func apply_material(_material:Material,_wind_modifier:float):
	mesh1.mesh.surface_set_material(0,_material)
	mesh2.mesh.surface_set_material(0,_material)

	mesh1.mesh.surface_get_material(0).set("shader_parameter/wind_distance_mod", _wind_modifier)
	mesh2.mesh.surface_get_material(0).set("shader_parameter/wind_distance_mod", _wind_modifier)
