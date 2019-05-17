macroScript cometParent
	category:"WhaleKit Scripts"
	toolTip:"cometParent: Links/Parents all selected objects to the LAST selected object."
	Icon:#("Maintoolbar",5)
(

--
-- Version 1.02 - Fixed parenting if the new parent was somewhere in the hierarchy of the
--		new children.  Before it would not work since it might have created a dependency loop.
--		Now it unlinks the new parent if needed
-- Version 1.03 - Fixed bug where nothing selected caused it to crash.
-- Version 1.20 - Fixed MAJOR bug that caused things to be unlinked all the time or 
--			just in general not work.  This is now very stable i think.  It also
--			will keep some semblance of hierarchy, even if reversing parents.
--

/*
 * isAChild() - Returns 0 if the obj is not a child somwhere under parObj, 1 if it is.
 */
fn isAChild obj parObj =
(
    ch = parObj.children;		-- get an array of child objects
	ret = findItem ch obj;		-- see if the obj is in the possible parObjs child list

		-- If it's not a direct child...recurse down each sub child to be sure.
    if (ret == 0 and ch != undefined) then 
	    (
		chc = ch.count;
		for i in 1 to chc do
			(
			ret = isAChild obj ch[i];    -- try each sub child as a possible parent.
			if (ret == 1) then 
			     return ret;
			)
		)
	if (ret > 1) then
	    ret = 1;
	return ret;
)


    oc = selection.count;

    undo on (
	
	    setWaitCursor();

		for i in 1 to (oc-1) do (
try(
				-- see if we see the new parent as a child somewhere of one of the new children
			isC = isAChild selection[oc] selection[i];

				-- And if so relink topmost node under that new child that new 
				-- childs parent, since it will still be a better guestimate 
				-- of hierarchy vs. parenting to world.
			if (isC == 1) then 
				(
				p = selection[oc].parent;
				c = selection[oc];
					-- Now we work our way up until we find the parent.
				while (p != selection[i] and p != undefined) do 
					(
					c = p;
					p = p.parent;
					)
					-- Then we unlink that last aka top child, which is what is causing us to be 
					-- in the hierarchy.  And link that to the master parents parent, which will make us
					-- keep some semblance of hierarchy.
				c.parent = p.parent;
			
				)

) catch ()
			)

			-- now link em
		for i in 1 to (oc-1) do (
try(
			selection[i].parent = selection[oc];
) catch ()
		    )

		if (oc > 0) then
			select selection[oc];	-- leave selection with just parent

		setArrowCursor();

		) -- end undo
		
	
)

