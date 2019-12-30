-- source folder
--global projPath = "d:\\Animation\\WarFace\\nevada"
global projPath = "d:\\Animation\\WarFace\\vehicles\\military"



-- gets list of project directories
function getListDirs root = (
	listDirs = getDirectories (root + "\\*")
	for dir in listDirs do
	(
		join listDirs (getDirectories (dir + "\\*"))
		)
	listDirs
)



-- creates paths for max files that must be exported
function createMaxFilesPaths dirsList = (
	filesList = #()
	for path_ in dirsList do 
	(
		join filesList (getFiles (path_ + "*.max"))
		)
	filesList
	)

	

-- changes material shader to blinn type 
function MatShaderChange =
(
		for obja in geometry where  (classof obja == PolyMeshObject or classof obja == Editable_Poly) do
		(	
			print obja
               mata = obja.material
               if mata != undefined and classof mata == Multimaterial then
                              (
                                            for i=1 to mata.materialList.count do
                                                           (
															submata = mata.materialList[i]
															submata.shadertype = 1 -- Shadertype 1 is Blinn ()
                                                           )
                              )
				else 	
							  (
								  mata.shadertype = 1
								  )
			)
)	


function modifyFiles sourceFiles = (
	for i = 1 to sourceFiles.count do 
	(
			loadMAXFile sourceFiles[i] useFileUnits:true quiet:true
			MatShaderChange()
			saveMAxFile sourceFiles[i]
			resetMaxFile
		)
	)
	
sourceDirsPaths = getListDirs projPath
maxFilesPaths = createMaxFilesPaths sourceDirsPaths
modifyFiles maxFilesPaths 

--MatShaderChange()

/* for i = 1 to sourceDirsPaths.count do
(
	print "__"
	print sourceDirsPaths[i]
	print exportDirsPaths[i]
	) */