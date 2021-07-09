/*

store_array.ado

*!version 1.0.1 07mar2013

*/

capture program drop es_store_array
program es_store_array
	version 12
	syntax , str(string) arrname(string) clsname(string)
	
	tokenize `str',parse("*")
	local i=1
	local j=1
	while "``i''"!=""{
		local dlg .`clsname'
		`dlg'.`arrname'[`j']="``i''"
		*disp "``i''"
		local i=`i'+2
		local ++j
	}
	*disp "end"
end
