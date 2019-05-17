exportClasses = exporterPlugin.classes

exportPath = "D:\\Projects\\FCSZ\\trunk\\Code\\Assets\\Regions\\Base\\Content\\Scenes\\Models\\"

global tmp_selection = #()

/* with animate on
(
for frame = animationRange.start to animationRange.end do
(
	at time frame
		(
		source_obj.pos = distanation_obj.pos
		source_obj.rotation = distanation_obj.rotation
		)
	) */

 function mergeLinkShadow = (
	mergeMAXFile "D:\\Projects\\FCSZ\\trunk\\Art\\3d\Base\\Base_Characters\\Sharacter_Shadow.max" #("Plane_shadow")
	 
	source_obj = getNodeByName "Plane_shadow"
	distanation_obj = getNodeByName "root_motion"
	root_obj = getNodeByName "Dummy_root"
	animationRange = interval 0 animationRange.end
	sliderTime = 0
	 
	at time animationRange.start 
	(
		source_obj.pos = distanation_obj.pos
		source_obj.rotation = distanation_obj.rotation
		)
	source_obj.parent = distanation_obj
) 

function exportSelected = (
	fileName = trimRight maxFileName ".max"
	currentName = exportPath + fileName + ".fbx"
	currentName
	exportFile currentname  selectedOnly: true
	)

function selectShadow = (
	max select none
	select $Plane_shadow
	)
	
/* function selectAll  = (
	max select none
	for obj in list do 
	(
		append tmp_selection obj
		if obj.children != undefined do 
		(
			selectAllChilds obj.children
			)
		)
	) */

rollout exportHelper "export helper" width:120 height:80
(
	button btn_merge "merge shadow" pos:[10,5] width:100 height:20
	button btn_export "export selected" pos:[10,30] width:100 height:20
	button btn_shadow "select shadow" pos:[10,55] width:100 height:20
	
	on btn_merge pressed do
		mergeLinkShadow()
	on btn_export pressed do
		exportSelected()
	on btn_shadow pressed do
		selectShadow()
)

createDialog exportHelper
--selectAll()
