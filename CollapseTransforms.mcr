-- mb_collapse v0.2 - (c) 2003 M. Breidt (martin@breidt.net)
--
-- Macro to be assigned as shortcut, quad menu entry or toolbar icon
--
-- Just select one or more animated objects and invoke macro.
-- This will collapse position, rotation and scale of all selected objects into 
-- keyframes so that afterwards, there will be one keyframe per frame, and the 
-- object's PRS controllers will be default. 
-- Linked objects will be unlinked afterwards with the motion resulting from the 
-- link collapsed into their own motion. Grouped objects will remain in their groups.
-- This macro is in addition to the standard Motion > Trajectories > Collapse Tool 
-- since this does not work well with linked objects, for example.

macroscript mb_collapse category:"WhaleKit Scripts" buttonText:"Collapse Transforms"
toolTip:"Collapse Transformations"
(
	on isEnabled do return $selection.count > 0

	on execute do (
		objlist = $selection as array
		for bake_obj in objlist do (	-- for every select object do
			format "MB Collapse: Collapsing transformation of object %\n" bake_obj.name
			local p = undefined
			local old_prs_ctrl = copy bake_obj.transform.controller		-- store old controller for catch()
			with undo on (
				disableSceneRedraw();	-- not using redraw context for max4 compatibility
				try (
					p = Point()			-- create temp point object
					for i = animationRange.start to animationRange.end do (
						at time i (
							with animate on p.transform = bake_obj.transform
						)
					)
					-- kill old transform controller and assign new, clean one
					bake_obj.transform.controller = transform_script()	
					bake_obj.transform.controller = prs()	
					
					if not (isGroupMember bake_obj) then bake_obj.parent = undefined	-- unlink if not in a group
					for i = animationRange.start to animationRange.end do (
						at time i (
							with animate on	bake_obj.transform = p.transform
						)
					)
					delete p			-- delete temp point obj
					p = undefined
					enableSceneRedraw()
				) catch (
					format "MB Collapse: Fatal error - exiting\n"
					if p!=undefined then delete p
					bake_obj.transform.controller = old_prs_ctrl
					enableSceneRedraw()
				) -- catch 
			) -- with undo on
		) -- for bake_obj in...
		if objlist.count == 0 then (
			format "MB Collapse: No object selected\n"
		)
	) -- on execute
) -- macroscript