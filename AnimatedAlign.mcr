----------------------------------------------------------------------------------------
-- Script Name:		JJTools7_AnimatedAlign.mcr
-- Compatible:		Max 5, 6 and 7
-- Version:			v2.14
-- Started:      	13 June 2001
-- Last Modified: 	29 October 2004
-- Code by:			Jim Jagger jimjagger@hotmail.com
-- 					www.JimJagger.com
----------------------------------------------------------------------------------------
-- 2.0  -- 2001.06.13 -- Second release
-- 2.11 -- 2004.05.06 -- Fixed status bar to be more accurate and changed the align 
--						 transforms.  Added about box test
-- 2.12 -- 2004.07.16 -- Made adjustment to work with link constraints at Jeff Cooperman's
--						 request.  Thanks Jeff! :)
-- 2.13 -- 2004.08.18 -- Now supports Biped Objects
-- 2.14 -- 2004.10.29 -- Fixed a bug with the set range/active range
----------------------------------------------------------------------------------------

macroscript AnimatedAlign
category: "WhaleKit Scripts"
tooltip:"Animated Align"
buttontext:"Anim Align"
icon:#("JJTools", 16)

(
	global AA_floater
	global AA_pos = [407,77]
	
	rollout AA_cont "Animated Align V2.14"
	(
		local sobj,
			  tobj,
			  astart = animationrange.start,
			  aend = animationrange.end
			  
		group "Source/Destination"
		(
			pickbutton source "Pick Source" width:90 align:#center 
			pickbutton target "Pick Destination" width:90 align:#center
		)
		
		group "Frame Range"
		(
			radiobuttons useTimeRange labels:#("Active Range", "Set Range") align:#center default:1
			spinner sframe "Start Time" range:[1,1000000,astart] type:#integer fieldwidth:50 align:#center enabled:false
			spinner eframe "End Time" range:[1,1000000,aend] type:#integer fieldwidth:50 align:#center enabled:false
		)

		group "Increments"
		(
			spinner stepCount "Step Count" range:[1,100,1] type:#integer fieldwidth:30 align:#center
		)
		
		group "PRS"
		(
			checkbox jj_pos "Position Only" checked:false
			--checkbox jj_rot "Rotation" checked:true
			--checkbox jj_scale "Scale" checked:true
		)
		
		group "Animate"
		(
			button AnimAlign "Align" align:#center
			progressbar AnimateAlign "AnimateAlign"
--			button undoshit "Undo" width:35 align:#right pos:[(AnimAlign.pos.x+90), AnimAlign.pos.y]
		)

		on useTimeRange changed state do
		(
			if useTimeRange.state == 2 then
			(
				sframe.enabled = true
				eframe.enabled = true
				--messageBox "Set Range!" title:"JJTools Error" beep:true
			)
			else
			(
				sframe.enabled = false
				eframe.enabled = false
				astart = animationrange.start
				aend = animationrange.end
				--messageBox "Active Range!" title:"JJTools Error" beep:true
			)
			--sframe.enabled
			--useTimeRange.state
		)

		on source picked obj do
		(
			sobj = obj
			source.text = obj.name
		)
		
		on target picked obj do
		(
			tobj = obj
			target.text = obj.name
		)
		
		on sframe changed val do
		(
			astart = val
		)
		
		on eframe changed val do
		(
			aend = val
		)
		
		on undoshit pressed do
		(
			fetchmaxfile()
		)
		
		on AnimAlign pressed do
		(
			--holdmaxfile()
			if astart > aend then
			(
				messageBox "The end time is smaller than start time!\nPlease check your ranges" title:"JJTools Error" beep:true
			)
			else
			(
				try
				(
					undo on
					(
						animate on
						(
							jcount = 0
							setwaitcursor()
							disableSceneRedraw()
							animVal=(((aend-astart) as float)/320.0)
							num = 100.0/(animVal/stepcount.value)
							for i = astart to aend by stepcount.value do
							(
								jcount += 1
								animateAlign.value = num*jcount
								--progressupdate(progressamount)
								slidertime = i
								--tempobject = snapshot tobj
								if jj_pos.checked == true then
								(
									sobj.pos = tobj.transform.pos
								)
								else
								(
									sobj.transform = tobj.transform
								)

								if IsKindOf sobj Biped_Object then
								(
									biped.setTransform sobj #pos tobj.transform.position true
									biped.setTransform sobj #rotation tobj.transform.rotation true
								)
								--delete tempobject
--								sobj.pos = tobj.pos
							)
							enableSceneRedraw()
							animateAlign.value = 0
						)
					)	
				)
				catch
				(  
					messageBox "Animated Align Failed!" title:"JJTools Error" beep:true
					enableSceneRedraw()
				)					
			)
		)
	)
	
	rollout AA_about "About"
	(
		activeXControl ax1 "http://jimjagger.com/JPages/JJTools/JJTools7_AnimatedAlign.htm" height:75 width:130 align:#center 
	)
			
	try
	(
		closerolloutfloater aa_floater
		aa_pos = aa_floater.pos
	)catch()
	aa_floater = newrolloutfloater "Animation Controller 1.0" 170 403
	AA_floater.pos = AA_pos
	addrollout AA_cont AA_floater rolledup:false
	addrollout AA_about AA_floater rolledup:true
)

