@tool
extends Node3D

var parent

func _ready() -> void:
	parent = get_parent() as Arm

func _process(_delta:float) -> void:
	position.z = parent.length
	#position.x = -parent.width 
