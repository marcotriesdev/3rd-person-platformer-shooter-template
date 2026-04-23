extends CharacterBody3D

const JUMP_VELOCITY = 8
@onready var camera = %Camera3D
@onready var pole = $cam_pole
@onready var timer = $energy_timer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Variables para controlar la rotación del personaje
@export var speed = 10.0
var initial_speed = speed
@export var rotate_clamp = 50
var resetting_view = false

#ENERGY REGEN
@export var regen = 0.5
@export var drain = 5

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("listo")

func center_view():
	if resetting_view and global_rotation != Vector3.ZERO:
		camera.global_rotation = lerp(camera.global_rotation, Vector3.ZERO,0.2)

	

func rotate_with_joystick():
	print("resetting view: "+ str(resetting_view))
	var look = Input.get_vector("right_stick -x","right_stick +x","right_stick -y","right_stick +y")
	rotate_y(look.x*-0.1)
	
	if Input.is_action_just_pressed("right_stick +y")  or Input.is_action_just_pressed("right_stick -y"):
		resetting_view = false
		
	camera.global_rotation += Vector3(clampf(look.y,-0.5,0.5)*-0.08,0,0)
	camera.global_rotation.x = clampf(camera.global_rotation.x, -0.5,0.5)
	
	if Input.is_action_just_pressed("center_view"):
		resetting_view = true

func _input(event):
	
	if event is InputEventMouseMotion:
		var clamped = clamp(event.relative.x,-rotate_clamp,rotate_clamp)
		rotate_y(-clamped * 0.01)

func movement(delta):
	
	#RESTORE VALUES FROM SPRINTING
	if Input.is_action_pressed("sprint") == false:
		timer.stop()
	speed = initial_speed
	
	#GRAVITY
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# SPRINTING
	if Input.is_action_pressed("sprint") and Global.energy_var > 0:
		speed = speed * 2.2
	
	#ENERGY DRAIN WHILE SPRINTING
	if Input.is_action_just_pressed("sprint") and Global.energy_var > 0:
		timer.start()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	
func _process(delta):
	
	Global.energy_regen(regen)

func _menu():
	pass

func _on_energy_timer_timeout():
	if Global.energy_var > 0:
		Global.energy_drain(drain)
