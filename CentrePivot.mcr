----------------------------------------------------------------------------------------
-- Script Name:		JJTools7_CentrePivot.mcr
-- Compatible:		Max 5, 6 and 7
-- Version:			v2.1
-- Started:      	18 May 2004
-- Last Modified: 	29 October 2004
-- Code by:			Jim Jagger jimjagger@hotmail.com
-- 					www.JimJagger.com
----------------------------------------------------------------------------------------
-- v2.1  -- 2004.06.02 -- Re-release
----------------------------------------------------------------------------------------

macroscript CentrePivot
category:"WhaleKit Scripts"
tooltip:"Centre pivot of selected objects"
buttontext:"Centre Pivot"
icon:#("JJTools", 18)

(
	on isEnabled return (selection.count >= 1)
	on Execute do
	(
		try
		(
			--loop through selected objects and set pivot point to object's centre
			for i in selection do (i.pivot = ((i.max + i.min)/2))
		)
		catch
		(
			messageBox "The object's pivot point could not be centered!" title:"JJTools Error" beep:true
		)
	)
)

