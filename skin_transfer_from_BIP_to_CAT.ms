--Replaces BIP_bones in Skinned mesh with CAT_bones.


function createSkinHelpersList = (
	try(
	max modify mode 
	skinMod = $.skin
	bonesListNames = for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
	bonesList = for obj in bonesListNames collect getNodeByname(obj)
	skinOps.SaveEnvelope skinMod (MaxFilePath + "\\"+ $.name + "_weights.env")
	bonesList
	)catch()
) 

/* function createCrySkinHelpersList = (
	max modify mode 
	skinMod = $.crySkin
	bonesListNames = for i=1 to (crySkinOps.GetNumberBones skinMod) collect (crySkinOps.GetBoneName skinMod i 0)
	bonesList = for obj in bonesListNames collect getNodeByname(obj)
	crySkinOps.SaveEnvelope skinMod (MaxFilePath + "\\"+ $.name + "_weights.env")
	bonesList
) */

/* function createBipBonesList helpersBonesList = (
	try (
		allBipBonesList = (for b in geometry where isKindof b.baseobject Biped_Object collect b)
		skinBipBoneslist = #()
		for bone_ in allBipBonesList do
		(
			for helper_ in helpersBonesList do
			(
				if (bone_.name == helper_.name) then
				(
					append skinBipBonesList bone_
				)
			)
		)
	)catch()
	skinBipBonesList
) */

function createCATBonesList helpersBonesList = (
		allCATBonesList = (for b in geometry where isKindof b.baseobject CATBone collect b)
		skinCATBonesList = #()
		for bone_ in allCATBonesList do
		(
			for helper_ in helpersBonesList do
			(
				if (bone_.name == helper_.name) then
				(
					append skinCATBonesList bone_
				)
			)
		)
	skinCATBonesList
)

function replaceSkinWithEmptySkin = (
	try(
	deleteModifier $ $.modifiers[#Skin]
	$.pos = [0,0,0]
	modPanel.addModToSelection (Skin ())
	)catch()
	)
	
function addBonesToSkin bipBonesList = (
	try(
	replaceSkinWithEmptySkin()
	skinMod = $.skin
	for bone_ in bipBonesList do
		(
		skinOps.addbone skinMod bone_ 0
		)
	)catch()
)

function loadEnvelopes = (
	try (
	skinMod = $.skin
	skinOps.loadEnvelope skinMod (MaxFilePath + "\\"+ $.name + "_weights.env")
	)catch()
	)

--createCATBonesList (createSkinHelpersList())

addBonesToSkin (createCATBonesList (createSkinHelpersList()))
loadEnvelopes()
deleteFile (MaxFilePath + "\\"+ $.name + "_weights.env")