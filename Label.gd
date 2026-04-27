extends Label

@onready var progress = get_parent().get_node("ProgressBar")
@onready var animation = $"../../AnimationPlayer"
@onready var x = $"../X"
@onready var debug = $active_menu
@onready var world2 = $"../../.."
@onready var world = %WorldEnvironment
var xbutton = false
var exit = false
var settings = false

@onready var label_exit = $"../../options/exit_label"

@onready var label_setting = $"../../options/settings_label"

@onready var gui_array = [x,label_exit,label_setting]
var current_gui := 0

var sizemult := 1.5 
# Called when the node enters the scene tree for the first time.
func _ready():
	animation.speed_scale = 3.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Global.energy_label(self,progress)
	
	debug.text = str(current_gui)
	


	if get_tree().paused:
		world.camera_attributes.dof_blur_far_transition = lerpf(world.camera_attributes.dof_blur_far_transition,
																-1,0.05)
		world.camera_attributes.exposure_multiplier = lerpf(world.camera_attributes.exposure_multiplier,1.0,
																0.3)
		if Input.is_action_just_pressed("enter"):
			match current_gui:
				0:
					x.visible = !x.visible 
					get_tree().paused = !get_tree().paused
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					animation.play("close_menu")		
				1:
					get_tree().quit()
				2: 
					pass	
					
				
		if Input.is_action_just_pressed("ui_up") && current_gui>0:
			current_gui -= 1
			var i := 0
			for e in gui_array:
				
				if i != current_gui:
					e.add_theme_font_size_override("font_size",81)
				i += 1 
			gui_array[current_gui].add_theme_font_size_override("font_size",89)
		if Input.is_action_just_pressed("ui_down")&& current_gui<gui_array.size()-1:
			current_gui += 1			
			var i := 0
			for e in gui_array:
				
				if i != current_gui:
					e.add_theme_font_size_override("font_size",81)
				i += 1 
			gui_array[current_gui].add_theme_font_size_override("font_size",89)
	else:
		world.camera_attributes.dof_blur_far_transition = lerpf(world.camera_attributes.dof_blur_far_transition,
																Global.dof,0.3)
		world.camera_attributes.exposure_multiplier = lerpf(world.camera_attributes.exposure_multiplier,1.4,
																0.3)
		pass
		
	if Input.is_action_just_pressed("pause"):

		x.visible = !x.visible 
		get_tree().paused = !get_tree().paused
	
		if !get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			animation.play("close_menu")		
		
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			animation.play("open_menu")

	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		if xbutton:
			animation.play("close_menu")
			x.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
		if exit:
			get_tree().quit()
		if settings:
			pass
	
	
func _on_x_mouse_entered():
	xbutton = true
	x.add_theme_font_size_override("font_size",89)
	


func _on_x_mouse_exited():
	xbutton = false
	x.add_theme_font_size_override("font_size",81)	
	


func _on_exit_label_mouse_entered():
	exit = true
	label_exit.add_theme_font_size_override("font_size",89)

func _on_exit_label_mouse_exited():
	exit = false
	label_exit.add_theme_font_size_override("font_size",81)

func _on_settings_label_mouse_entered():
	settings = true
	label_setting.add_theme_font_size_override("font_size",89)


func _on_settings_label_mouse_exited():
	settings = false
	label_setting.add_theme_font_size_override("font_size",81)
