@tool
class_name Delta_Type_1 extends Node3D

@export var UpdateDims:bool
@export var TestCalc: bool

@export_category("Physical Dimensions")
@export var UpperRadius:float = 0.150;
@export var TCPRadius:float = 0.050;
@export var UpperArmLength:float = 0.401;
@export var LowerArmLength:float = 0.801;
@export var UpperArmRadius:float = 0.05;
@export var LowerArmRadius:float = 0.015;

enum CoordinateSpace { ACS, MCS}
@export_category("Driven Settings")
@export var DrivenMode: CoordinateSpace = CoordinateSpace.MCS
@export_subgroup("Forward")
@export_range(-360.0,360.0) var Q1: float;
@export_range(-360.0,360.0) var Q2: float;
@export_range(-360.0,360.0) var Q3: float;
@export_subgroup("Inverse")
@export var tcp_position: Vector3;

#Upper Arms
@onready var upper_arm_attach_1: Node3D = $RobotBase/MountingPoint1/Node3D
@onready var upper_arm_attach_2: Node3D = $RobotBase/MountingPoint2/Node3D
@onready var upper_arm_attach_3: Node3D = $RobotBase/MountingPoint3/Node3D
@onready var upper_arm_1: MeshInstance3D = $RobotBase/MountingPoint1/Node3D/UpperArm
@onready var upper_arm_2: MeshInstance3D = $RobotBase/MountingPoint2/Node3D/UpperArm
@onready var upper_arm_3: MeshInstance3D = $RobotBase/MountingPoint3/Node3D/UpperArm

#Lower Arms
@onready var lower_arm_left_1: MeshInstance3D = $RobotBase/MountingPoint1/Node3D/UpperArm/LowerArmAttachmentLeft/LowerArm
@onready var lower_arm_right_1: MeshInstance3D = $RobotBase/MountingPoint1/Node3D/UpperArm/LowerArmAttachmentRight/LowerArm
@onready var lower_arm_attachment_left_1: Node3D = $RobotBase/MountingPoint1/Node3D/UpperArm/LowerArmAttachmentLeft
@onready var lower_arm_attachment_right_1: Node3D = $RobotBase/MountingPoint1/Node3D/UpperArm/LowerArmAttachmentRight
@onready var lower_arm_left_2: MeshInstance3D = $RobotBase/MountingPoint2/Node3D/UpperArm/LowerArmAttachmentLeft/LowerArm
@onready var lower_arm_right_2: MeshInstance3D = $RobotBase/MountingPoint2/Node3D/UpperArm/LowerArmAttachmentRight/LowerArm
@onready var lower_arm_attachment_left_2: Node3D = $RobotBase/MountingPoint2/Node3D/UpperArm/LowerArmAttachmentLeft
@onready var lower_arm_attachment_right_2: Node3D = $RobotBase/MountingPoint2/Node3D/UpperArm/LowerArmAttachmentRight
@onready var lower_arm_left_3: MeshInstance3D = $RobotBase/MountingPoint3/Node3D/UpperArm/LowerArmAttachmentLeft/LowerArm
@onready var lower_arm_right_3: MeshInstance3D = $RobotBase/MountingPoint3/Node3D/UpperArm/LowerArmAttachmentRight/LowerArm
@onready var lower_arm_attachment_left_3: Node3D = $RobotBase/MountingPoint3/Node3D/UpperArm/LowerArmAttachmentLeft
@onready var lower_arm_attachment_right_3: Node3D = $RobotBase/MountingPoint3/Node3D/UpperArm/LowerArmAttachmentRight

const sqrt3 = sqrt(3.0)
const sin120 = sqrt3/2.0
const cos120 = -0.5   
const tan60 = sqrt3
const sin30 = 0.5
const tan30 = 1/sqrt3

#TCP Plate
@onready var tcp_flange: MeshInstance3D = $RobotBase/TcpFlange

func _update_dimensions() -> void:
	#Upper Arms
	var upper_arm_attach = Vector3(UpperRadius,0,0)
	upper_arm_attach_1.position = upper_arm_attach
	upper_arm_attach_2.position = upper_arm_attach
	upper_arm_attach_3.position = upper_arm_attach
	
	var upper_mesh = upper_arm_1.mesh as CylinderMesh
	upper_mesh.top_radius = UpperArmRadius
	upper_mesh.bottom_radius = UpperArmRadius
	upper_mesh.height = UpperArmLength
	upper_arm_1.mesh = upper_mesh
	upper_arm_1.position.y = UpperArmLength / 2.0
	upper_arm_2.mesh = upper_mesh
	upper_arm_2.position.y = UpperArmLength / 2.0
	upper_arm_3.mesh = upper_mesh
	upper_arm_3.position.y = UpperArmLength / 2.0

	#Lower Arms
	var lower_left_arm_attach = Vector3(
		-(LowerArmRadius + UpperArmRadius) ,
		UpperArmLength / 2.0 - LowerArmRadius * 2,
		0
	)
	var lower_right_arm_attach = Vector3(
		(LowerArmRadius + UpperArmRadius),
		UpperArmLength / 2.0 - LowerArmRadius * 2,
		0
	)
	lower_arm_attachment_left_1.position = lower_left_arm_attach
	lower_arm_attachment_left_2.position = lower_left_arm_attach
	lower_arm_attachment_left_3.position = lower_left_arm_attach
	lower_arm_attachment_right_1.position = lower_right_arm_attach
	lower_arm_attachment_right_2.position = lower_right_arm_attach
	lower_arm_attachment_right_3.position = lower_right_arm_attach

	var lower_mesh = lower_arm_left_1.mesh
	lower_mesh.top_radius = LowerArmRadius
	lower_mesh.bottom_radius = LowerArmRadius
	lower_mesh.height = LowerArmLength
	lower_arm_left_1.mesh = lower_mesh
	lower_arm_right_1.mesh = lower_mesh
	lower_arm_left_2.mesh = lower_mesh
	lower_arm_right_2.mesh = lower_mesh
	lower_arm_left_3.mesh = lower_mesh
	lower_arm_right_3.mesh = lower_mesh
	lower_arm_left_1.position.y = LowerArmLength / 2.0
	lower_arm_left_2.position.y = LowerArmLength / 2.0
	lower_arm_left_3.position.y = LowerArmLength / 2.0
	lower_arm_right_1.position.y = LowerArmLength / 2.0
	lower_arm_right_2.position.y = LowerArmLength / 2.0
	lower_arm_right_3.position.y = LowerArmLength / 2.0

	#TCP
	var tcp_mesh = tcp_flange.mesh as CylinderMesh
	tcp_mesh.top_radius = TCPRadius
	tcp_mesh.bottom_radius = TCPRadius
	tcp_flange.mesh = tcp_mesh
	

func _process(delta: float) -> void:
	if UpdateDims:
		UpdateDims = false
		_update_dimensions()

	if TestCalc:
		TestCalc = false
		var motorPos:Vector3 = delta_calcInverse(tcp_position)
		upper_arm_attach_1.rotation.x = deg_to_rad(90) - motorPos.x
		upper_arm_attach_2.rotation.x = deg_to_rad(90) - motorPos.y
		upper_arm_attach_3.rotation.x = deg_to_rad(90) - motorPos.z
		print(motorPos)

#Derrived from https://hypertriangle.com/~alex/delta-robot-tutorial/
func delta_calcForward(theta1:float,theta2:float,theta3:float) -> Vector3:

	var result =  Vector3.ZERO

	var t = (TCPRadius - UpperRadius) * tan30 / 2

	theta1 = deg_to_rad(theta1)
	theta2 = deg_to_rad(theta2)
	theta3 = deg_to_rad(theta3)

	var y1 = -(t + UpperArmLength * cos(theta1));
	var z1 = -UpperArmLength * sin(theta1);
 
	var y2 = (t + UpperArmLength * cos(theta2)) * sin30
	var x2 = y2 * tan60
	var z2 = -UpperArmLength * sin(theta2)
 
	var y3 = (t + UpperArmLength * cos(theta3)) * sin30
	var x3 = -y3 * tan60
	var z3 = -UpperArmLength * sin(theta3)	 
	var dnm = (y2-y1)*x3-(y3-y1)*x2	 
	var w1 = y1*y1 + z1*z1
	var w2 = x2*x2 + y2*y2 + z2*z2
	var w3 = x3*x3 + y3*y3 + z3*z3
	
	var a1 = (z2-z1)*(y3-y1)-(z3-z1)*(y2-y1)
	var b1 = -((w2-w1)*(y3-y1)-(w3-w1)*(y2-y1))/2.0
 
	#  // y = (a2*z + b2)/dnm;
	var a2 = -(z2-z1)*x3+(z3-z1)*x2
	var b2 = ((w2-w1)*x3 - (w3-w1)*x2)/2.0
 
	#  // a*z^2 + b*z + c = 0
	var a = a1*a1 + a2*a2 + dnm*dnm
	var b = 2*(a1*b1 + a2*(b2-y1*dnm) - z1*dnm*dnm)
	var c = (b2-y1*dnm)*(b2-y1*dnm) + b1*b1 + dnm*dnm*(z1*z1 - LowerArmLength*LowerArmLength)
  
	#  // discriminant
	var d = b*b - 4.0*a*c
	#  if (d < 0) return -1; // non-existing point
 
	result.z = -0.5*(b+sqrt(d))/a
	result.x = (a1*result.z + b1)/dnm
	result.y = (a2*result.z + b2)/dnm
	#  return 0;
	print(result)
	return result

func delta_calcAngleYZ(pos:Vector3) -> float:
	var y1 = -0.5 * 0.57735 * TCPRadius
	pos.y -= 0.5 * 0.57735 * UpperRadius
	#z = a + b*y
	var a = (pos.x*pos.x + pos.y*pos.y + pos.z*pos.z +UpperArmLength*UpperArmLength - LowerArmLength*LowerArmLength - y1*y1)/(2*pos.z)
	var b = (y1-pos.y)/pos.z
	#discriminant
	var d = -(a+b*y1)*(a+b*y1)+UpperArmLength*(b*b*UpperArmLength+UpperArmLength); 
	#if (d < 0) return -1; // non-existing point
	var yj = (y1 - a*b - sqrt(d))/(b*b + 1)
	var zj = a + b*yj;
	return atan2(-zj, (y1 - yj)) * 180.0 / PI


func delta_calcInverse(pos:Vector3 ) -> Vector3:
	var result = Vector3.ZERO
	
	result.x = delta_calcAngleYZ(pos)
	result.y = delta_calcAngleYZ(Vector3(pos.x * cos120 + pos.y * sin120, pos.y * cos120 - pos.x * sin120, pos.z))
	result.z = delta_calcAngleYZ(Vector3(pos.x * cos120 - pos.y * sin120, pos.y * cos120 + pos.x * sin120, pos.z))

	return result


func _on_button_pressed() -> void:
	delta_calcInverse(tcp_position)
