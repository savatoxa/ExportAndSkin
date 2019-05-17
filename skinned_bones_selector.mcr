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

function selectSkinBones = (
	try(
	max modify mode 
	skinMod = $.skin
	bonesListId = #()
	bonesListNames = for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
	bonesListId = for obj in bonesListNames collect getNodeByname(obj)
	selectmore bonesLIstID
	)catch()
)

	selectSkinBones()

)