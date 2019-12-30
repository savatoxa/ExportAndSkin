exportClasses = exporterPlugin.classes

-- source folder
global projPath = "d:\\Animation\\WarFace\\vehicles\\"
--global projPath = "d:\\Animation\\WarFace\\vehicles\\military"
--folder for export, we will create export folder here like ..\A\B\export
global exportPath = "D:\\Animation\\WarFace"
global exportFolderName = "\\export"


global diffuseTextureMask = "_diff"
global textureFolderNames = #("textures", "texture")


-- gets list of project directories
function getListDirs root = (
	listDirs = getDirectories (root + "\\*")
	for dir in listDirs do
	(
		join listDirs (getDirectories (dir + "\\*"))
		)
	listDirs
)


-- creates paths for directories in new "export" folder, this directories hierarchy is similar to the project directories hierarchy
-- uses path list of project directories
function createExportDirPaths projDirPaths = (
	exportPathLen = exportPath.count + 1
	exportDirPaths = #()
	for path_ in projDirPaths do 
	(
		append exportDirPaths (exportPath + exportFolderName + (substring path_ exportPathLen -1))
		)
		exportDirPaths
	)

-- creates folders for FBX files. One folder per MAX file.
function createFbxExportDirPaths filesList = (
	exportPathLen = exportPath.count + 1
	exportDirPaths = #()
	for i = 1 to filesList.count do 
	(
			append exportDirPaths ( trimRight  (exportPath + exportFolderName + (substring filesList[i] exportPathLen -1))  ".max" )
		)
		exportDirPaths
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


-- creates path for FBX file exported from max file by given filePath 
function createExportFbxFilesPath filePath = (
	exportPathLen = exportPath.count + 1
	exportFilePath = (trimRight  (exportPath + exportFolderName + (substring filePath exportPathLen -1))  ".max" ) + "\\"
	)
	
--gets  list of root dummies in scene
function getRootDummies = (
	groups = for obj in helpers where isGroupHead obj collect obj
	while groups.count > 0 do
	(
		ungroup groups[groups.count] ; groups.count = groups.count-1
	)
	rootDummies = #()
	for obj in helpers where obj.parent == undefined do append rootDummies obj
	rootDummies
	)

-- gets geometry first level childs of specified dummy and ads this dummy to set 
function getExportObjects dummy_ = (
	exportObjects = #()
	if (dummy_ != undefined and dummy_.children != undefined) then
	(
		for obj in dummy_.children do
		(
			if (superClassOf obj == GeometryClass) then 
			(
				if obj.name[1] != "$" then
					(
					append exportObjects obj
					)
				)
			)
		if exportObjects.count != 0 then (append exportObjects dummy_)
	)
	exportObjects
	)

-- creates array of arrays of objects that would be exported. Every sub array corresponds to one root dummy in scene. 
function createExportObjectsSet dummyList = (
	print dummyList
	ExportObjectsSet = #()
	if (dummyList != undefined and dummyList.count != 0) then
	(
		for dummy_ in dummyList do (append ExportObjectsSet  (getExportObjects dummy_))
		)
	ExportObjectsSet
	)
	
-- exports max files to FBX files by given list of max files paths
function exportFiles sourceFiles = (
	for i = 1 to sourceFiles.count do 
	(
			loadMAXFile sourceFiles[i] useFileUnits:true quiet:true
			exportObjectsSet = createExportObjectsSet (getRootDummies())
			savePath = createExportFbxFilesPath sourceFiles[i]
			for exportChunk in exportObjectsSet do
				(
				if exportChunk.count != 0 then
					(
					max select none
					for j = 1 to exportChunk.count - 1 do
					(
					recreateMultiMaterial exportChunk[j]
						)
					fileName = exportChunk[exportChunk.count].name
					select exportChunk
					currentname = savePath + fileName + ".fbx"
					exportFile currentname #noPrompt selectedOnly: true
					)
				)

		)
	)

-- creates new directories by specified list of paths
function createExportDirs dirsList= (
	for path_ in dirsList do
	(
		makeDir path_ 
		)
	)


-- changes material shader to blinn type and puts bump texture to diffuse texture slot
fn recreateMultiMaterial obja =
(
	try (
               mata = obja.material
               if mata != undefined and classof mata == Multimaterial do
                              (
                                            for i=1 to mata.materialList.count do
                                                           (
                                                                          submata = mata.materialList[i]
																		  if submata.shaderType != 1 then
																		  (
                                                                          submata.shadertype = 1 -- Shadertype 1 is Blinn ()
                                                                          submata.diffusemap = submata.bumpmap
																		  )
                                                           )
                              )
				if  mata != undefined and classof mata == Standardmaterial do
				(
					if mata.shaderType != 1 then 
					(
					mata.shadertype = 1
					mata.diffusemap = mata.bumpmap
					)
				)
			)catch ()
)



-- copies diffuse *.tif textures from source textures (texture) folders to corresponding textures (texture) folders in export folder
function copyTextures sourceDirsList exportDirsList = (
	for i = 1 to sourceDirsList.count do
	(
		FiltDir = filterString sourceDirsList[i] "\\"
		if (FiltDir[FiltDir.count] == textureFolderNames[1] or FiltDir[FiltDir.count] == textureFolderNames[2]) then
		(
			filesList = #()
			join filesList (getFiles (sourceDirsList[i] + "*.tif"))
			for file in filesList do
			(
				filtFile = filterString file "\\"
				fileName = filtFile[filtFile.count]
				if (findString fileName diffuseTextureMask) != undefined then
				(
					copyFile file (exportDirsList[i] + fileName)
					)
				)
			)
		)
	)


	
sourceDirsPaths = getListDirs projPath
exportDirsPaths = createExportDirPaths sourceDirsPaths
maxFilesPaths = createMaxFilesPaths sourceDirsPaths
FbxExportDirsPaths = createFbxExportDirPaths maxFilesPaths

copyTextures 	sourceDirsPaths exportDirsPaths	
createExportDirs exportDirsPaths
createExportDirs FbxExportDirsPaths
exportFiles maxFilesPaths



--print sourceDirsPaths
--print exportDirsPaths

--print FbxExportDirsPaths
--print AdditionalExportDirPaths

/* for i = 1 to sourceDirsPaths.count do
(
	print "__"
	print sourceDirsPaths[i]
	) */
	print exportDirsPaths[i]