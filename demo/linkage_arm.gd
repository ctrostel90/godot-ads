@tool
class_name Arm extends MeshInstance3D

@export var test:bool = false

var origin = Vector3.ZERO
@export var width:float = 1.0 : 
	set(value): 
		width = value
		gen()
@export var length:float = 2.0:
	set(value): 
		length = value
		gen()
@export var height:float = 1.0:
	set(value): 
		height = value
		gen()
@export var divisions:int = 12:
	set(value): 
		divisions = value
		gen()


func gen() -> void:
	var vertices = PackedVector3Array()
	#Create the first 1/2 circle
	for i in range(divisions):
		vertices.push_back(origin)
		vertices.push_back(Vector3(
			width * cos(PI * i / divisions),
			0,
			-width * sin(PI * i / divisions),
		))
		vertices.push_back(Vector3(
			width * cos(PI * (i+1) / divisions),
			0,
			-width * sin(PI * (i+1) / divisions),
		))
	for i in range(divisions):
		vertices.push_back(Vector3(0,height,0))
		vertices.push_back(Vector3(
			width * cos(PI * (i+1) / divisions),
			height,
			-width * sin(PI * (i+1) / divisions),
		))
		vertices.push_back(Vector3(
			width * cos(PI * i / divisions),
			height,
			-width * sin(PI * i / divisions),
		))
	for i in range(divisions):
		vertices.push_back(vertices[i*3 + 1])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 1])
		vertices.push_back(vertices[i*3 + 2])
	
	for i in range(divisions):
		vertices.push_back(vertices[i*3 + 1])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 2])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 1])

	#Create the main body

	#-y face
	vertices.push_back(Vector3(	width * cos(PI),	0,	width * sin(PI)))
	vertices.push_back(Vector3(	-width,	0,	length))
	vertices.push_back(Vector3(	width,	0,	length))
	
	vertices.push_back(Vector3(	width,	0,	-width * sin(PI)))
	vertices.push_back(Vector3(	-width,	0,	0))
	vertices.push_back(Vector3(	width,	0,	length))

	#+y face
	vertices.push_back(Vector3(	width * cos(PI),	height,	width * sin(PI)))
	vertices.push_back(Vector3(	width,	height,	length))
	vertices.push_back(Vector3(	-width,	height,	length))
	
	vertices.push_back(Vector3(	width,	height,	-width * sin(PI)))
	vertices.push_back(Vector3(	width,	height,	length))
	vertices.push_back(Vector3(	-width,	height,	0))

	#+x face
	vertices.push_back(Vector3(	width,	0,	width * sin(PI) ))
	vertices.push_back(Vector3(	width,	0,	length ))
	vertices.push_back(Vector3(	width,	height,	length ))

	vertices.push_back(Vector3(	width,	height,	width * sin(PI) ))
	vertices.push_back(Vector3(	width,	0,	0 ))
	vertices.push_back(Vector3(	width,	height,	length ))

	#-x face
	vertices.push_back(Vector3(	-width,	0,	width * sin(PI) ))
	vertices.push_back(Vector3(	-width,	height,	length ))
	vertices.push_back(Vector3(	-width,	0,	length ))

	vertices.push_back(Vector3(	-width,	height,	width * sin(PI) ))
	vertices.push_back(Vector3(	-width,	height,	length ))
	vertices.push_back(Vector3(	-width,	0,	0 ))

	var end_of_middle:int = vertices.size()
	for i in range(divisions):
		vertices.push_back(Vector3(0,0,length))
		vertices.push_back(Vector3(
			width * cos(PI * (i+1) / divisions),
			0,
			width * sin(PI * (i+1) / divisions) + length,
		))
		vertices.push_back(Vector3(
			width * cos(PI * i / divisions),
			0,
			width * sin(PI * i / divisions) + length,
		))
	
	for i in range(divisions):
		vertices.push_back(Vector3(0,height,length))
		vertices.push_back(Vector3(
			width * cos(PI * i / divisions),
			height,
			width * sin(PI * i / divisions) + length,
		))
		vertices.push_back(Vector3(
			width * cos(PI * (i+1) / divisions),
			height,
			width * sin(PI * (i+1) / divisions) + length,
		))
	for i in range(divisions):
		vertices.push_back(vertices[i*3 + 1 + end_of_middle])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 1 + end_of_middle])
		vertices.push_back(vertices[i * 3 + 2 + end_of_middle])
		
	
	for i in range(divisions):
		vertices.push_back(vertices[i*3 + 1 + end_of_middle])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 2 + end_of_middle])
		vertices.push_back(vertices[divisions * 3 + i * 3 + 1 + end_of_middle])

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = arr_mesh

func _process(_delta: float) -> void:
	if test:
		test = false
		gen()
