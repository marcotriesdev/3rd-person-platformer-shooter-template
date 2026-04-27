extends Node

#Version 4.3 "

var energy_var = 100

var dof

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_cam_position(cam,player):

	cam.global_position.x = lerp(cam.global_position.x,player.global_position.x,0.2)
	cam.global_position.z = lerp(cam.global_position.z,player.global_position.z,0.2)
	cam.global_position.y = lerp(cam.global_position.y,player.global_position.y,0.05)
	#cam.global_rotation.y = lerp_angle(cam.global_rotation.y,player.global_rotation.y,0.8)
	cam.global_rotation.y = lerp_angle(cam.global_rotation.y,player.global_rotation.y,0.08)
	
func energy_regen(regen):
	
	if energy_var < 100:
		energy_var += regen
	
func energy_label(label,progress):
	
	
	label.text = "ENERGY:  %" + str(round(energy_var))
	progress.value = energy_var
	
func energy_drain(drain):
	
	if energy_var > 0:
		energy_var -= drain
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
