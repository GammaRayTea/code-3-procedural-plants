@tool
extends Node3D

@export var plant_seed = randi() % 1000000000 + 1

@export_tool_button("New Seed") var new_seed =  generate_seed

@export_tool_button("Generate") var new_plant = generate




func generate_seed() -> void:
	print("New Seed: ",plant_seed)
	plant_seed = randi() % 1000000000 + 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func generate()->void:
	print("Generating...")
