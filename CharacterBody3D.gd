extends CharacterBody3D

const JUMP_VELOCITY = 8
@onready var camera = %Camera3D
@onready var pole = $cam_pole
@onready var pole2 = $cam_pole2
@onready var postfx = %WorldEnvironment
@onready var timer = $energy_timer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Variables para controlar la rotación del personaje
@export var speed = 10.0
var initial_speed = speed
const hip_mult = 2.2
const aim_mult = 1.5
var sprint_mult = hip_mult
@export var rotate_clamp = 50
var resetting_view = false

#FOVs

const fov_hip := 78.4
const fov_aim := 50.4
const aim_speed := 0.08

#DOFs
const dof_far_hip := 8.15
const dof_far_aim := 60.0

const dof_transition_far := 319.66

const dof_near_hip := 3.00
const dof_near_aim := 5.77

#aim sensitivity

const analog_aim_sens = 0.04
const analog_hip_sens = 0.08
var analog_sens = analog_hip_sens

const mouse_aim_sens = 0.0045
const mouse_hip_sens = 0.0085
var mouse_sens = mouse_hip_sens

#ENERGY REGEN
const hip_regen = 0.16
const aim_regen = 0.10
@export var regen = hip_regen

#ENERGY DRAIN
const hip_drain = 10
const aim_drain = 5
@export var drain = hip_drain

const JUMP_DRAIN = 15

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func center_view():
	if resetting_view and global_rotation != Vector3.ZERO:
		camera.global_rotation = lerp(camera.global_rotation, Vector3.ZERO,0.2)

	

func rotate_with_joystick():
	#print("resetting view: "+ str(resetting_view))
	var look = Input.get_vector("right_stick -x","right_stick +x","right_stick -y","right_stick +y")
	rotate_y(look.x*-analog_sens)
	
	if Input.is_action_just_pressed("right_stick +y")  or Input.is_action_just_pressed("right_stick -y"):
		resetting_view = false
		
	camera.global_rotation += Vector3(clampf(look.y,-0.5,0.5)*-analog_sens,0,0)
	camera.global_rotation.x = clampf(camera.global_rotation.x, -0.5,0.5)
	
	if Input.is_action_just_pressed("center_view"):
		resetting_view = true

func _input(event):
	
	if event is InputEventMouseMotion:
		var clamped = clamp(event.relative.x,-rotate_clamp,rotate_clamp)
		rotate_y(-clamped * mouse_sens)
		
		camera.rotation.x -= event.relative.y * mouse_sens
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
		

func aim():
	
	if Input.is_action_pressed("aim"):
		
		Global.update_cam_position(camera,pole2)
		camera.fov = lerpf(camera.fov,fov_aim,aim_speed)
		var current_dof_far = postfx.camera_attributes.dof_blur_far_distance
		var current_dof_near = postfx.camera_attributes.dof_blur_near_distance
		postfx.camera_attributes.dof_blur_far_distance = lerpf(current_dof_far,dof_far_aim,aim_speed)
		postfx.camera_attributes.dof_blur_near_distance = lerpf(current_dof_near,dof_near_aim,aim_speed)
		analog_sens = analog_aim_sens
		regen = aim_regen
		drain = aim_drain
		sprint_mult = aim_mult
		mouse_sens = mouse_aim_sens
		
	else:
	
		Global.update_cam_position(camera,pole)
		camera.fov = lerpf(camera.fov,fov_hip,aim_speed)
		var current_dof_far = postfx.camera_attributes.dof_blur_far_distance
		var current_dof_near = postfx.camera_attributes.dof_blur_near_distance
		postfx.camera_attributes.dof_blur_far_distance = lerpf(current_dof_far,dof_far_hip,aim_speed)
		postfx.camera_attributes.dof_blur_near_distance = lerpf(current_dof_near,dof_near_hip,aim_speed)
		analog_sens = analog_hip_sens
		regen = hip_regen
		drain = hip_drain
		sprint_mult = hip_mult
		mouse_sens = mouse_hip_sens
		
func movement(delta):
	
	#RESTORE VALUES FROM SPRINTING
	if Input.is_action_pressed("sprint") == false:
		timer.stop()
	speed = initial_speed
	
	#GRAVITY
	if not is_on_floor():
		velocity.y -= gravity * delta

	# jump duhhh
	if (Input.is_action_just_pressed("ui_accept") and is_on_floor() and Global.energy_var > 0
		or Input.is_action_just_pressed("jump") and is_on_floor() and Global.energy_var > 0
		):
		velocity.y = JUMP_VELOCITY
		Global.energy_drain(JUMP_DRAIN)
		
		
	# SPRINTING
	if Input.is_action_pressed("sprint") and Global.energy_var > 0:
		speed = speed * sprint_mult
	
	#ENERGY DRAIN WHILE SPRINTING
	if Input.is_action_just_pressed("sprint") and Global.energy_var > 0:
		timer.start()


	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _physics_process(delta):
	rotate_with_joystick()
	center_view()
	movement(delta)
	Global.update_cam_position(camera,pole)
	aim()
	Global.dof = dof_transition_far
	
func _process(delta):
	
	Global.energy_regen(regen)

func _menu():
	pass

func _on_energy_timer_timeout():
	if Global.energy_var > 0:
		Global.energy_drain(drain)
