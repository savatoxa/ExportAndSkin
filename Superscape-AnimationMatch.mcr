macroScript AnimationMatch category:"Superscape" tooltip:"Animation Match" buttontext:"Animation Match"
(
	global warnNoSource
	global srcPrefix
	global dstPrefix
	global rootSuffix
	global startFrame
	global endFrame
	global frameStep
	global obeyKeys
	global alwaysSetPositionKeys

	global srcCoordSys
	global dstCoordSys

	-- Fill defaults
	if warnNoSource == undefined do warnNoSource = true
	if srcPrefix == undefined do srcPrefix = "Bip01"
	if dstPrefix == undefined do dstPrefix = "Player01"
	if rootSuffix == undefined do rootSuffix = "_Pelvis"
	if startFrame == undefined do startFrame = 0
	if endFrame == undefined do endFrame = 100
	if frameStep == undefined do frameStep = 2
	if obeyKeys == undefined do obeyKeys = true
	if alwaysSetPositionKeys == undefined do alwaysSetPositionKeys = false

	-- Compares two strings treating spaces equal to underscores
	fn cmpNames str1 str2 =
	(
		if str1.count != str2.count do return false

		for i in 1 to str1.count do
		(
			ch1 = str1[i]
			if ch1 == " " do ch1 = "_"
			ch2 = str2[i]
			if ch2 == " " do ch2 = "_"
			if ch1 != ch2 do return false
		)
		return true
	)

	-- Finds source object by destination
	fn getSource obj =
	(
		if not cmpNames (substring obj.name 1 dstPrefix.count) dstPrefix do return undefined
		return execute ("$'" + srcPrefix + (substring obj.name (dstPrefix.count + 1) -1) + "'")
	)

	-- Checks if the given object is a biped's root
	fn isBipedCM obj = (classof obj == biped_object and isProperty obj.controller #vertical)

	-- Checks if the given object is a root node.
	fn isRoot obj = (rootSuffix.count > 0 and cmpNames (substring obj.name (dstPrefix.count + 1) -1) rootSuffix)

	-- Checks if this keyframe sequence has a key at the given time
	fn hasKey keys time =
	(
		for key in keys do
		(
			if key.time == time do return true
		)
		return false
	)

	-- Checks if this object is keyed at the given time
	fn isKeyed obj time =
	(
		if isBipedCM obj do
		(
			ctl = obj.transform.controller
			if hasKey ctl.vertical.controller.keys time do return true
			if hasKey ctl.horizontal.controller.keys time do return true
			if hasKey ctl.turning.controller.keys time do return true
		)

		if isProperty obj #pos and hasKey obj.pos.controller.keys time do return true
		if isProperty obj #rotation and hasKey obj.rotation.controller.keys time do return true
		return hasKey obj.controller.keys time
	)

	-- Finds all objects in between the given nodes.  Any of the nodes may be
	-- undefined.  Returned nodes are not guaranteed to be in any
	-- particular order.  node1 and node2 are not included in the returned array.
	fn findRoute node1 node2 =
	(
		n1 = node1
		n2 = node2

		path1 = #()
		path2 = #()

		while n1 != undefined do
		(
			insertItem n1 path1 1
			n1 = n1.parent
		)

		while n2 != undefined do
		(
			insertItem n2 path2 1
			n2 = n2.parent
		)

		shortest = path1.count
		if shortest > path2.count do shortest = path2.count

		while path1.count > 0 and path2.count > 0 and path1[1] == path2[1] do
		(
			deleteItem path1 1
			deleteItem path2 1
		)

		join path1 path2

		exclude = findItem path1 node1
		if exclude != 0 do deleteItem path1 exclude
		exclude = findItem path1 node2
		if exclude != 0 do deleteItem path1 exclude

		return path1
	)

	-- Checks if a position key is required for obj to maintain its position
	-- relative to parentObj.
	-- obj must be defined.
	-- parentObj may be undefined if complete chain of parents is to be considered.
	fn isChainKeyed route time =
	(
		for obj in route do
		(
			if isKeyed obj time do
			(
				return true
			)
		)
		return false
	)

	fn getRelativePosition obj parentObj =
	(
		if parentObj != undefined then
		(
			measureBox = dummy name:"Temporary_Position_Measure_Dummy"
			coordsys world measureBox.pos = obj.transform.pos
			pos = coordsys parentObj measureBox.pos -- - parentObj.transform.pos
			delete measureBox
		)
		else
			pos = obj.transform.pos

		return pos
	)

	fn getRelativeRotation obj parentObj =
	(
		if parentObj != undefined then
			rot = obj.transform.rotation * inverse parentObj.transform.rotation
		else
			rot = obj.transform.rotation
		return inverse rot
	)

	-- Copy position from source to destination
	fn match atTime obeyKeysLocal =
	(
		for obj in selection do
		(
			src = getSource obj

			if src == undefined do
			(
				if warnNoSource do
				(
					if not queryBox ("No source found for \"" + obj.name + "\".  Continue ?") do return false
				)
				continue
			)

			if isRoot obj then
			(
				srcParent = srcCoordSys
				dstParent = dstCoordSys
			)
			else
			(
				dstParent = obj.parent
				if dstParent != undefined then
					srcParent = getSource dstParent
				else
					srcParent = undefined
			)

			if obeyKeysLocal do
			(
				route = findRoute srcParent src
				append route src
				if not isChainKeyed route atTime do continue
			)

			if isRoot obj or alwaysSetPositionKeys do
			(
				newPos = getRelativePosition src srcParent
				if dstParent != undefined then
					coordsys dstParent obj.pos = newPos
				else
					coordsys world obj.pos = newPos
			)

			newRot = getRelativeRotation src srcParent
			currentRot = getRelativeRotation obj dstParent
			deltaRot = newRot * inverse currentRot
			if dstParent != undefined then
				coordsys dstParent rotate obj deltaRot
			else
				coordsys world rotate obj deltaRot
		)

		return true
	)

	-- Matches animation in the given time range
	fn matchRange =
	(
		success = true

		if obeyKeys then step = 1 else step = frameStep

		with animate on
		(
			for i in startFrame to (endFrame - 1) by step do at time i
			(
				if not match i obeyKeys do return ()
			)
			at time endFrame match endFrame obeyKeys
		)
	)

	rollout namesRollout "Names"
	(
		group "Biped"
		(
			editText edtSrcPrefix "Prefix" text:srcPrefix
			label lab1 "Parent: " across:3 align:#left
			pickButton btnSrcParent message:"Pick an object for source coordinate system"
			button btnSrcReset "Reset" align:#right
		)

		group "Skeleton"
		(
			editText edtDstPrefix "Prefix" text:dstPrefix
			label lab2 "Parent: " across:3 align:#left
			pickButton btnDstParent message:"Pick an object for destination coordinate system"
			button btnDstReset "Reset" align:#right
		)

		editText editRootSuffix "Root node suffix" text:rootSuffix

		on edtSrcPrefix entered txt do srcPrefix = txt

		on edtDstPrefix entered txt do dstPrefix = txt

		on editRootSuffix entered txt do rootSuffix = txt

		on btnSrcParent picked obj do
		(
			srcCoordSys = obj
			btnSrcParent.text = obj.name
		)

		on btnSrcReset pressed do
		(
			srcCoordSys = undefined
			btnSrcParent.text = "World"
		)

		on btnDstParent picked obj do
		(
			dstCoordSys = obj
			btnDstParent.text = obj.name
		)

		on btnDstReset pressed do
		(
			dstCoordSys = undefined
			btnDstParent.text = "World"
		)

		on namesRollout open do
		(
			if srcCoordSys == undefined then btnSrcParent.text = "World" else btnSrcParent.text = srcCoordSys.name
			if dstCoordSys == undefined then btnDstParent.text = "World" else btnDstParent.text = dstCoordSys.name
		)
	)

	rollout rangeRollout "Range"
	(
		spinner spnStartFrame "Start" range:[0,1000000,startFrame] type:#integer
		spinner spnEndFrame "End" range:[1,1000000,endFrame] type:#integer
		checkbox chkObeyKeys "Auto detect keys" checked:obeyKeys
		spinner spnFrameStep "Step" range:[0,30,frameStep] type:#integer
		checkbox chkSetPositionKeys "Always set position keys" checked:alwaysSetPositionKeys

		on spnStartFrame changed val do
		(
			startFrame = val
			if endFrame <= val do spnEndFrame.value = endFrame = val + 1
		)

		on spnEndFrame changed val do
		(
			endFrame = val
			if startFrame >= val do spnStartFrame.value = startFrame = val - 1
		)

		on spnFrameStep changed val do frameStep = val

		on chkObeyKeys changed val do
		(
			obeyKeys = val
			spnFrameStep.enabled = not obeyKeys
		)

		on rangeRollout open do spnFrameStep.enabled = not obeyKeys

		on chkSetPositionKeys changed val do alwaysSetPositionKeys = val
	)

	rollout matchRollout "Match animation"
	(
		button btnMatchRange "Match range" offset:[10,0]
		button btnMatch "Match frame" offset:[10,0]
		imgTag img1 bitmap:(openBitMap (getDir #image + "\green.bmp")) pos:[20, btnMatchRange.pos.y - 2]
		imgTag img2 bitmap:(openBitMap (getDir #image + "\blue.bmp")) pos:[20, btnMatch.pos.y - 2]

		on btnMatchRange pressed do with undo "Match Animation Range" on matchRange ()

		on btnMatch pressed do
			with undo "Match Animation Frame" on
			with animate on
				match sliderTime false
	)

	--
	-- Bake biped object position
	--

	fn bakeBiped bip =
	(
		if bip.parent == undefined do
		(
			messageBox ("\"" + srcPrefix + "\" is not linked to anything")
			return ()
		)

		times = #()
		positions = #()
		rotations = #()

		if obeyKeys then step = 1 else step = frameStep

		for i in startFrame to endFrame - 1 by step do
		(
			if not obeyKeys or isKeyed bip i do at time i
			(
				append times i
				append positions bip.transform.pos
				append rotations bip.transform.rotation
			)
		)
		if not obeyKeys or isKeyed bip endFrame do at time endFrame
		(
			append times endFrame
			append positions bip.transform.pos
			append rotations bip.transform.rotation
		)

		bip.parent = undefined

		for i in 1 to times.count do at time times[i] with animate on
		(
			biped.setTransform bip #pos positions[i]
			biped.setTransform bip #rotation rotations[i]
		)
	)

	rollout bakeRollout "Bake biped"
	(
		pickButton btnBake "Bake..." filter:isBipedCM message:"Pick a biped to bake"
		on btnBake picked obj do with undo "Bake Biped" on bakeBiped obj
	)

	--
	-- Renamer
	--

-- 	headNames = #("_Neck", "_Head")
-- 	armNames = #("_Clavicle", "_UpperArm", "_ForeArm", "_Hand", "_Thumb")
-- 	legNames = #("_Thigh", "_Calf", "_Foot", "_Thumb")
--
-- 	fn renameChain obj side names =
-- 	(
-- 		for i in 1 to names.count do
-- 		(
-- 			obj.name = dstPrefix + side + names[i]
-- 			if obj.children.count != 1 do return i
-- 			obj = obj.children[1]
-- 		)
-- 	)
--
-- 	rollout renamerRollout "Rename skeleton"
-- 	(
-- 		pickButton btnNeck "Neck..."								 message:"Pick a neck"
-- 		pickButton btnLArm "Left arm..."	 across:2  message:"Pick a left clavicle"
-- 		pickButton btnRArm "Right arm..." 					 message:"Pick a right clavicle"
-- 		pickButton btnSpine "Spine..."							 message:"Pick a spine"
-- 		pickButton btnPelvis "Pelvis..."						 message:"Pick a pelvis"
-- 		pickButton btnLLeg "Left leg..."	 across:2  message:"Pick a left thigh"
-- 		pickButton btnRLeg "Right leg..." 					 message:"Pick a right thigh"
--
-- 		on btnNeck picked obj do with undo "Rename Neck" on renameChain obj "" headNames
-- 		on btnLArm picked obj do with undo "Rename Left Arm" on renameChain obj "_L" armNames
-- 		on btnRArm picked obj do with undo "Rename Right Arm" on renameChain obj "_R" armNames
-- 		on btnSpine picked obj do with undo "Rename Spine" on obj.name = dstPrefix + "_Spine"
-- 		on btnPelvis picked obj do with undo "Rename Pelvis" on obj.name = dstPrefix + rootSuffix
-- 		on btnLLeg picked obj do with undo "Rename Left Leg" on renameChain obj "_L" legNames
-- 		on btnRLeg picked obj do with undo "Rename Right Leg" on renameChain obj "_R" legNames
-- 	)

	--
	-- Generator
	--

	-- Finds maximum link length in a subtree
	fn maxLength obj len =
	(
		for c in obj.children do
		(
			l = length (c.transform.pos - obj.transform.pos)
			if l > len do len = l
			len = maxLength c len
		)
		return len
	)

	fn createSkeleton parent obj len =
	(
		if not cmpNames (substring obj.name 1 srcPrefix.count) srcPrefix do
		(
			if warnNoSource do
			(
				if not queryBox ("\"" + obj.name + "\" is named incorrectly and will be ignored.	Continue ?") do return false
			)
			return true
		)

		l = (maxLength obj len) / 4

		in parent in coordsys local current = dummy name:(dstPrefix + (substring obj.name (srcPrefix.count + 1) -1)) boxsize:[l, l, l] pos:obj.objecttransform.pos rotation:(inverse obj.objecttransform.rotation)

		for o in obj.children do
		(
			if not createSkeleton current o (length (o.transform.pos - obj.transform.pos)) do return false
		)

		return true
	)

	rollout generatorRollout "Skeleton generator"
	(
		pickButton btnGen "Generate..." message:"Pick a root of hierarchy to copy"
		on btnGen picked obj do with undo "Generate Skeleton" on createSkeleton undefined obj 0
	)

	fn setPosition type =
	(
		for o in selection do
		(
			o.pos.controller = case type of
			(
				1: linear_position()
				2: bezier_position()
				3: position_xyz()
				4: swerve_spline_position()
			)
		)
	)

	fn setRotation type =
	(
		for o in selection do
		(
			o.rotation.controller = case type of
			(
				1: linear_rotation()
				2: tcb_rotation()
				3: euler_xyz()
				4: swerve_spline_rotation()
				5: swervestudioalignconstraint()
			)
		)
	)

	fn setScale type =
	(
	    for o in selection do
	    (
	        o.scale.controller = case type of
	        (
	            1: linear_scale()
	            2: bezier_scale()
	            3: scalexyz()
	            4: swerve_spline_scale()
	        )
	    )
	)

	rollout controllerTypeRollout "Controller type"
	(
		group "Position"
		(
			dropdownlist posCtl items:#("Linear", "Bezier", "Position XYZ", "Swerve Spline")
			button applyPos "Apply"
		)
		group "Rotation"
		(
			dropdownlist rotCtl items:#("Linear", "TCB", "Euler XYZ", "Swerve Spline", "Swerve Align Constraint")
			button applyRot "Apply"
		)
		group "Scale"
		(
			dropdownlist scaleCtl items:#("Linear", "Bezier", "Scale XYZ", "Swerve Spline")
			button applyScale "Apply"
		)
		on applyPos pressed do setPosition posCtl.selection
		on applyRot pressed do setRotation rotCtl.selection
		on applyScale pressed do setScale scaleCtl.selection
	)

	rollout version "Version"
	(
		label ver "Animation Match v1.16"
		label copy "© 2006 Superscape"
	)

	floater = newRolloutFloater "Animation match utility" 175 510

	addRollout namesRollout floater
	addRollout rangeRollout floater
	addRollout matchRollout floater
	addRollout bakeRollout floater rolledUp:true
-- 	addRollout renamerRollout floater rolledUp:true
	addRollout controllerTypeRollout floater rolledUp:true
	addRollout generatorRollout floater rolledUp:true
	addRollout version floater rolledUp:true
)
