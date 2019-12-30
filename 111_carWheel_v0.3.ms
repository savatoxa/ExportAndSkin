-- carWheel - (c)2004 - andrei kletskov (111) - http://andklv.narod.ru

-- (version 0.3, 5 may 2009) - setup scheme below had incorrect z axis of wheel; wheel autodiameter fixed; wheel steering slightly touched.
-- (version 0.2, 22 december 2004)
-- set-up was simplified:
-- now you need to specify only "car body" object for backward movement and steering (instead of 3 helper objects)
-- now you do not need to pick-up "wheel object" - selected object (or several selected objects) will be animated
-- initial animation range is set automatically to scene animation range
-- added automatic wheel diameter detection (if a wheel has a parent the diameter will be calculated in z_axis of parent, else in world's z_axis)
-- added button for automatic "car_body" detection (in general case car body is a parent of a wheel)
-- steering was reworked: another key planting principle; backward movement is also considered in steering
-- steer adjustment interpretation was changed - if step time is small (like 1) the wheel steering will be very subtle, this parameter will help to make it stronger 
-- objects set-up scheme:	
--			_________
--			|	|	|
--			|	z	|
--			--------- wheel
-- 		___________________
--		|				  |
--		|		y		  |
--		|		|__		  |	=======================> 
--		|			x	  |					forward movement direction
-- 		|				  |
--      ------------------- car body
--

-- (version 0.1, 20 december 2004)
-- carWheel will help you to animate wheels for your vehicles, it supports backward movement and wheel steering
-- commom workflow: 
-- create car body with z_axis looking up and x_axis looking towards forward movement
-- create wheel(s) with z_axis alignrd to car's y_axis
-- link wheels to car body
-- create animation path for car body and assign path constraint with follow option (you can also animate car body manually)
-- run the script, pick wheel, define start time, end time and step (step means interval at which keys will be created)
-- click "animate wheel" - whe wheel will be animated with rotation around its z_axis
-- enabling "backward" option will allow you to animate wheel rotation for car's backward movement too.
-- in this case you will need to specify forward movement vector by creating two helper objects (rear_object and front_object) 
-- rear_object normally must be placed at car body pivot point and front_object must be shifted along x_axis of car body
-- helper objects must be linked to car body
-- you can also enable "calculate steering" option - this will create steering animation (normally for car's front wheels)
-- in this case you will need to create 3 helper objects: rear_object and front_object as described above and left_object
-- left_object must define a vector perpendicular to forward movement direction (normally rear_object cloned and shifted along y_axis of car_body)
-- "invert" options will invert rotations if they will go in incorrect direction
-- "steer adjustment" will adjust steering amount: greater values will decrease impact of steering, decimal values will increase it
-- you will also need to specify the diameter of your wheel (you can use standart measure utility for this)
(
global_wheel = undefined
global_front_object = undefined

rollout ak_about "About" width:115 height:100
(
	label lbl3 "(c) 2004, 2009" pos:[5,5] width:100 height:20
	label lbl4 "Andrei Kletskov (111)" pos:[5,20] width:110 height:20
	label lbl5 "http://andklv.narod.ru" pos:[5,35] width:110 height:20
	label lbl6 "andklv@mail.ru" pos:[5,50] width:100 height:16
)


rollout aa "carWheel v0.3" width:115 height:240
(
	button auto_diameter "A" pos:[99,27] width:16 height:16
	button pbtn_wheel "check selection" pos:[1,1] width:114 height:23
	spinner spn_diameter "Diameter:" pos:[1,27] width:98 height:16 range:[0,1000000000000000000,5]
	label lbl1 "Start:     End:      Step:" pos:[4,45] width:109 height:16
	spinner spn_start_time "" pos:[1,60] width:38 height:16 range:[-100000000,100000000,animationRange.start] type:#integer 
	spinner spn_end_time "" pos:[39,60] width:38 height:16 range: [-100000000,100000000,animationRange.end] type:#integer
	spinner spn_step_time "" pos:[77,60] width:38 height:16 range:[0,100000000,1] type:#integer 
	checkbox chk_calculate_rotation "calculate rotation" pos:[2,77] width:110 height:15 checked:true
	checkbox chk_invert_rotation "invert rotation" pos:[10,92] width:101 height:15 enabled:true
	checkbox chk_count_backward "count backward" pos:[2,107] width:104 height:15
	checkbox chk_calculate_steering "calculate steering" pos:[2,122] width:102 height:15
	checkbox chk_invert_steering "invert steering" pos:[10,137] width:102 height:15 enabled:false
	spinner spn_steer_adjustment "steer adjustm.:" pos:[18,152] width:97 height:16 range:[-100000000,100000000,5] enabled:false type:#integer
	button auto_car_body "A" pos:[95,170] width:20 height:20 enabled: false
	pickButton btn_front_object "> pick car body <" pos:[1,170] width:94 height:20 enabled:false
	button btn_animate "Animate Wheel!" pos:[1,195] width:114 height:28
	
	fn Check_wheels =
	(
		if selection[1] == undefined then 
		(
			messagebox "You must select at least one wheel"
			return false 
		)
		else
		(
			if selection[2] != undefined then pbtn_wheel.caption = "=== selection ===" else pbtn_wheel.caption = selection[1].name
			global_wheel = selection
			return true
		)
	)
	
	on auto_car_body pressed do
	(
		if Check_wheels() == true then
		(
			if global_wheel[1].parent != undefined then 
			(
				global_front_object = global_wheel[1].parent
				btn_front_object.caption = global_front_object.name
			)
			else btn_front_object.caption = "undefined"
		)
	)
	
	on auto_diameter pressed do
	(
		if Check_wheels() == true then
		(
			obj = global_wheel[1]
			addModifier obj (edit_mesh())
			--if obj.parent == undefined then 
			(
				min_v = max_v = in coordsys world (getvert obj 1).z
				for v = 1 to getNumVerts obj do
				(
					vv = in coordsys world (getvert obj v).z
					if vv > max_v then max_v = vv
					if vv < min_v then min_v = vv
				)
			)
			/*
			else
			(
				car_obj = obj.parent
				min_v = max_v = in coordsys car_obj (getvert obj 1).z
				for v = 1 to getNumVerts obj do
				(
					vv = in coordsys car_obj (getvert obj v).z
					if vv > max_v then max_v = vv
					if vv < min_v then min_v = vv
				)
			)
			*/
			l = length([0,0,max_v] - [0,0,min_v])
			spn_diameter.value = l
			deleteModifier obj 1
		)
	)
	
	on pbtn_wheel pressed do Check_wheels()
	
	on btn_front_object picked obj do
	(
		btn_front_object.caption = obj.name
		global_front_object = obj
	)
	
	on chk_calculate_rotation changed st do chk_invert_rotation.enabled = st
	
	on chk_calculate_steering changed st do
	(
		if st == true then chk_invert_steering.enabled = spn_steer_adjustment.enabled = true
		if st == false then chk_invert_steering.enabled = spn_steer_adjustment.enabled = false
		if st == true then btn_front_object.enabled = auto_car_body.enabled = true
		if st == false and chk_count_backward.checked == true then btn_front_object.enabled = auto_car_body.enabled = true
		if st == false and chk_count_backward.checked == false then btn_front_object.enabled = auto_car_body.enabled = false
	)
	
	on chk_count_backward changed st do
	(
		if st == true then btn_front_object.enabled = auto_car_body.enabled = true
		if st == false and chk_calculate_steering.checked == true then btn_front_object.enabled = auto_car_body.enabled = true
		if st == false and chk_calculate_steering.checked == false then btn_front_object.enabled = auto_car_body.enabled = false
	)

	on btn_animate pressed do
	(
		try
		(	

		if Check_wheels() do
		(
		
		for wheel_object in global_wheel do
		(
		prev_key = 0
		start_time = spn_start_time.value
		end_time = spn_end_time.value
		step_time = spn_step_time.value
		diameter = spn_diameter.value
		
		count_rotation = chk_calculate_rotation.state
		invert_rot = chk_invert_rotation.state
		
		count_direction = chk_calculate_steering.state
		invert_direction_steer = chk_invert_steering.state
		steer_rot_angle_fix = spn_steer_adjustment.value
		
		count_backward = chk_count_backward.state

		car_body = global_front_object
			undo on
			(
				animate on
				(
					for i in start_time to end_time by step_time do
					(
						rot_dir = 1
						st_rot_dir = 1
						new_wheel_pos = at time i  wheel_object.pos
						old_wheel_pos = at time  (i - step_time) wheel_object.pos
						my_distance = distance new_wheel_pos old_wheel_pos
						dir_dir = normalize (new_wheel_pos - old_wheel_pos )
						if count_backward == true  then
						(
							car_dir = at time i (in coordsys world (car_body.transform.rotation as matrix3).row1)
							if (length (car_dir - dir_dir) > sqrt(2)) then rot_dir = st_rot_dir = -1
						)
						if invert_rot == true then rot_dir = rot_dir * (-1)
						rot_angle = (360 * my_distance)/(pi*diameter)
						if count_rotation == true then 
						(
							addnewkey wheel_object.rotation.controller.Y_Rotation.controller i #select
							key_index = getkeyindex wheel_object.rotation.controller.Y_Rotation.controller i
							wheel_object.rotation.controller.Y_Rotation.controller.keys[key_index].value = prev_key + rot_angle * rot_dir 
							prev_key = wheel_object.rotation.controller.Y_Rotation.controller.keys[key_index].value			
						)
						if count_direction == true then
						(
							rot_steer = 1
							car_dir = at time i (in coordsys world (car_body.transform.rotation as matrix3).row1)
							fut_dir
							fut_dir = at time (i + step_time /*+ steer_rot_angle_fix*/) (in coordsys world (car_body.transform.rotation as matrix3).row1)
							left_dir = at time i (in coordsys world (car_body.transform.rotation as matrix3).row2)
							if (length(left_dir - fut_dir) > sqrt(2)) then rot_steer = -1
							if invert_direction_steer == true then rot_steer = rot_steer * (-1)
							steer_rot_angle = (asin(length (fut_dir - car_dir) / 2))*2*steer_rot_angle_fix
							if count_backward == true  then steer_rot_angle = steer_rot_angle * st_rot_dir 
							addnewkey wheel_object.rotation.controller.Z_Rotation.controller i #select
							steer_key_index = getkeyindex wheel_object.rotation.controller.Z_Rotation.controller i
							wheel_object.rotation.controller.Z_Rotation.controller.keys[steer_key_index].value = steer_rot_angle * rot_steer	
						)
					) -- end for
				) -- end animate on
			) -- end undo on
		) -- end for wheel_object in global_wheel do
		) -- end if check_wheels() do
		) -- end try
		catch messagebox "Something wrong! Check options!"
	) -- end on btn_animate pressed
) -- end rollout

rf = newRolloutFloater "111_CW" 130 279
addRollout aa  rf  
addRollout ak_about rf
ak_about.open = 0
)