extends CharacterBody3D

var speed
const WALK_SPEED = 7.0
const Sprint_SPEED = 9.0
const JUMP_VELOCITY = 6.5
const SENSITIVITY = 0.003
const JUMPCOUNTER = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
var jumps = JUMPCOUNTER


const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var bullet = load("res://Bullet.tscn")
var instance



@onready var head = $head
@onready var camera = $head/Camera3D
@onready var gun_anim = $"head/Camera3D/Assault Rifle/AnimationPlayer"
@onready var gun_barrel = $"head/Camera3D/Assault Rifle/RayCast3D"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	jumpreset()

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1



	if Input.is_action_just_pressed("Sprint"):
		speed = Sprint_SPEED
	else:
		speed = WALK_SPEED
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)



	var velocity_clamped = clamp(velocity.length(), 0.5, Sprint_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
	
	
	
	move_and_slide()
	
func jumpreset():
	if is_on_floor():
		jumps = JUMPCOUNTER
	
	
