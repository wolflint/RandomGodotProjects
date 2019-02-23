extends RigidBody2D

# Member variables
const STATE_WALKING = 0
const STATE_DYING = 1

var state = STATE_WALKING

var direction = -1
var anim = ""

onready var rc_left = $raycast_left
onready var rc_right = $raycast_right

var WALK_SPEED = 50

var bullet_class = preload("res://scripts/bullet.gd")


func _die():
	queue_free()


func _pre_explode():
	#make sure nothing collides against this
	$shape1.queue_free()
	$shape2.queue_free()
	$shape3.queue_free()
	
	# Stay there
	mode = MODE_STATIC
	$sound_explode.play()


func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var new_anim = anim

	if state == STATE_DYING:
		new_anim = "explode"
	elif state == STATE_WALKING:
		new_anim = "walk"
		
		var wall_side = 0.0
		
		for i in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(i)
			var dp = s.get_contact_local_normal(i)
			
			if cc:
				if cc is bullet_class and not cc.disabled:
#					set_collision_layer_bit(1, false)
#					set_collision_layer_bit(3, true)
					set_collision_mask_bit(0, false)
					mode = MODE_RIGID
					state = STATE_DYING
					#lv = s.get_contact_local_normal(i) * 400
					s.set_angular_velocity(sign(dp.x) * 10.0)
					$sprite.modulate = Color(1, 1, 1, 0.9)
#					s.set_angular_velocity(sign(dp.x) * 33.0)
					set_friction(1)
					cc.disable()
					$sound_hit.play()
					break
			
			if dp.x > 0.9:
				wall_side = 1.0
			elif dp.x < -0.9:
				wall_side = -1.0
		
		if wall_side != 0 and wall_side != direction:
			direction = -direction
			$sprite.scale.x = -direction
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			$sprite.scale.x = -direction
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			$sprite.scale.x = -direction
		
		lv.x = direction * WALK_SPEED
	
	if anim != new_anim:
		anim = new_anim
		$anim.play(anim)
	
	s.set_linear_velocity(lv)
