macroScript skinnedBonesSelector
category: "WhaleKit Scripts" 
tooltip: "skinBonesSelector" 
buttontext:"SBS"
(

function selectCrySkinBones = (
	try(
	max modify mode 
	skinMod = $.crySkin
	bonesListId = #()
	bonesListNames = for i=1 to (crySkinOps.GetNumberBones skinMod) collect (crySkinOps.GetBoneNameByListID skinMod i 0)
	bonesListId = for obj in bonesListNames collect getNodeByname(obj)
	selectmore bonesLIstID
	)catch()
)

skinnedMeshesWithBones = #()

function selectSkinBones meshObj = (
	max modify mode 
	select meshObj
	skinMod = meshObj.skin
	bonesListId = #()
	meshAndBones = #()
	append meshAndBones meshObj
	bonesListNames = for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
	bonesListId = for obj in bonesListNames collect getNodeByname(obj)
	for  bone_ in bonesLIstID do 
		(
			append meshAndBones bone_
		)
	
	meshAndBones		
)

 objList = for obj in (selection as array) collect obj

for obj in objList do 
	(
		append skinnedMeshesWithBones (selectSkinBones obj)
	)	

max select none
	
for obj in skinnedMeshesWithBones do 
	(
		selectmore obj
	)

)