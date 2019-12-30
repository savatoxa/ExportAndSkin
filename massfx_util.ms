rollout MassFXUtil "MassFX Util" width:236 height:146
(
	radiobuttons rdo1 "" pos:[140,22] width:69 height:48 labels:#("Dynamic", "Kinematic", "Static") default:1 columns:1
	button btn1 "Select by Sim Type" pos:[17,27] width:108 height:41
	button btn2 "Delete MassFX modifier in selection" pos:[17,91] width:201 height:40
	on btn1 pressed do
	(
		max select none
		sel = #()
		for i in geometry where (i.modifiers["MassFX Rigid Body"] != undefined) do
		(if i.modifiers["MassFX Rigid Body"].type == rdo1.state do sel += i)
		select sel
		redrawviews()
	)
	on btn2 pressed do
	(
		for i in selection where i.modifiers["MassFX Rigid Body"] != undefined do deletemodifier i i.modifiers["MassFX Rigid Body"]
		redrawviews()
	)
)
createdialog MassFXUtil