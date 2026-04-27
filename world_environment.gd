@tool

extends WorldEnvironment

func _enter_tree():
	if Engine.is_editor_hint():
		print("koño")
		if camera_attributes:
			camera_attributes.dof_blur_far_enabled = false
			camera_attributes.dof_blur_near_enabled = false
