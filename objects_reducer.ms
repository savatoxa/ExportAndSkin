obj_list = for obj in (selection as array) collect obj
num_obj = obj_list.count
num_obj_float = float(num_obj)
i = 1
while i < num_obj do (
	print ( int((i/num_obj_float)*100) )
	delete obj_list[i]
	i += 2
	)

free obj_list