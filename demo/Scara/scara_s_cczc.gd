@tool
class_name Scara_S_SSCZ extends Node3D

@export_category("Dimensions")
@export var BicepLength:float = 1.0:
	set(value):
		BicepLength = value
		_gen()
@export var BicepRadius:float = 1.0:
	set(value):
		BicepRadius = value
		_gen()
@export var ForearmLength:float = 1.0:
	set(value):
		ForearmLength = value
		_gen()
@export var ForearmRadius:float = 1.0:
	set(value):
		ForearmRadius = value
		_gen()


enum ControlMode {FORWARD,INVERSE}
@export_category("Control Points")
@export var EnableKinematic:bool = false
@export var ControlType:ControlMode = ControlMode.FORWARD

@export_subgroup("Forward Kinematics")
@export var Q1:float = 0.0
@export var Q2:float = 0.0
@export var Q3:float = 0.0
@export var Q4:float = 0.0

@export_subgroup("Inverse Kinematics")
@export var X:float = 0.0
@export var Y:float = 0.0
@export var Z:float = 0.0
@export var C:float = 0.0

#Model generation
@onready var bicep: MeshInstance3D = %Bicep
@onready var elbow: Node3D = %Elbow
@onready var forearm: MeshInstance3D = %Forearm
@onready var wrist: Node3D = $%Wrist
@onready var tcp: Node3D = %Tcp

var _ready_complete = false

func _ready() -> void:
	_ready_complete = true

#generate the entire model based on the input parameters
func _gen() -> void:
	if not _ready_complete:
		return
	var bicep_mesh = bicep.mesh as CapsuleMesh
	bicep_mesh.radius = BicepRadius
	bicep_mesh.height = BicepLength
	bicep.mesh = bicep_mesh
	bicep.position.z = BicepLength / 2.0

	elbow.position.y = BicepLength / 2.0

	var forearm_mesh = forearm.mesh as CapsuleMesh
	forearm_mesh.radius = ForearmRadius
	forearm_mesh.height = ForearmLength
	forearm.mesh = forearm_mesh
	forearm.position.y = ForearmLength / 2.0
	wrist.position.y = ForearmLength / 2.0

func forward_kin(_q1:float, _q2:float, _q3:float, _q4:float) -> Array[float]:
	#[X,Y,Z,C]
	var elbow_pos = Vector2(
		sin(deg_to_rad(_q1)) * BicepLength,
		cos(deg_to_rad(_q1)) * BicepLength,
	)
	var wrist_pos = Vector2(
		elbow_pos.x + sin(deg_to_rad(_q2)) * BicepLength,
		elbow_pos.y + cos(deg_to_rad(_q2)) * BicepLength,
	)

	return [
		wrist_pos.x,
		wrist_pos.y,
		_q3,
		_q4	]
	
func inverse_kin(_x:float,_y:float, _z:float, _c:float) -> Array[float]:
	var reach = sqrt(_x * _x + _y * _y)
	# if reach > ForearmLength + BicepLength:
	# 	return {"error": "Target point out of reach"}
		
	# Calculate Q2 (elbow angle)
	var cos_q2 = (_x * _x + _y * _y - BicepLength * BicepLength - ForearmLength * ForearmLength) / (2 * BicepLength * ForearmLength)
	# if cos_q2 < -1 or cos_q2 > 1:
	# 	return {"error": "Invalid configuration"}
	var _Q2 = acos(cos_q2)

	var k1 = BicepLength + ForearmLength * cos(Q2)
	var k2 = ForearmLength * sin(Q2)
	var _Q1 = atan2(_y, _x) - atan2(k2, k1)

	return [_Q1,
		_Q2,
		_z,
		_c]

func _apply_joints(joints:Array[float]) -> void:
	rotation_degrees.y = joints[0]
	elbow.rotation_degrees.z = joints[1]

	wrist.position.z = joints[2]
	tcp.rotation_degrees.y = joints[3]

func _process(_delta: float) -> void:
	if EnableKinematic:
		match ControlType:
			ControlMode.FORWARD:
				var res = forward_kin(Q1,Q2,Q3,Q4)
				X = res[0]
				Y = res[1]
				Z = res[2]
				C = res[3]
				_apply_joints([Q1,Q2,Q3,Q4])

			ControlMode.INVERSE:
				var res = inverse_kin(X,Y,Z,C)
				Q1 = res[0]
				Q2 = res[1]
				Q3 = res[2]
				Q4 = res[3]
				_apply_joints(res)
