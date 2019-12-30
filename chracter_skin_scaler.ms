function DefineMeshCATHelper sel selectedObjs = (
	selectedObjs[2] = undefined
	if classof sel[1] == CATParent then
	(
		selectedObjs[1] = sel[1]
		selectedObjs[2] = sel[2]
		)
	else 
		(
		selectedObjs[1] = sel[2]
		selectedObjs[2] = sel[1]
			)
	selectedObjs
)

function CreateSkinBonesList skinnedPoly = (
	select skinnedPoly
	max modify mode
	skinMod = skinnedPoly.skin
	bonesListNames = for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
	bonesList = for obj in bonesListNames collect getNodeByname(obj)
	skinOps.SaveEnvelope skinMod (MaxFilePath + "\\"+ skinnedPoly.name + "_weights.env")
	bonesList
)


function DeleteSkinScalePoly skinnedPoly scaleFactor = (
  	select skinnedPoly
	deleteModifier skinnedPoly skinnedPoly.modifiers[1]
	skinnedPolyScale = skinnedPoly.scale
	skinnedPoly.scale = [skinnedPolyScale[1]*scaleFactor, skinnedPolyScale[2]*scaleFactor, skinnedPolyScale[3]*scaleFactor]
	resetXForm skinnedPoly
    collapseStack skinnedPoly
  	)

function ScaleCATHelper helperCAT scaleFactor = (
	helperCAT.CATMode = 0
	helperCATUnits = helperCAT.CATUnits
	helperCAT.CATUnits = helperCATUnits*scaleFactor
)

function CreateNewSkin processingObjsList bonesList = (
	select processingObjsList[2]
	modPanel.addModToSelection (Skin ())
	skinMod = processingObjsList[2].skin
	skinMod.bone_Limit = 4
	for bone_ in bonesList do 
	(
		skinOps.addbone skinMod bone_ 0
		)
	skinOps.loadEnvelope skinMod (MaxFilePath + "\\"+ processingObjsList[2].name + "_weights.env")
	deleteFile (MaxFilePath + "\\"+ processingObjsList[2].name + "_weights.env")
	--processingObjsList[1].CATMode = 1
)

function Run  = (
	selectedObjs = #()
	scaleFactor = 7.0
	
	DefineMeshCATHelper selection selectedObjs
	bonesList = CreateSkinBonesList selectedObjs[2]
	DeleteSkinScalePoly selectedObjs[2] scaleFactor
	ScaleCATHelper selectedObjs[1] scaleFactor
	CreateNewSkin selectedObjs bonesList
	free selectedObjs
	free bonesList
)

Run()