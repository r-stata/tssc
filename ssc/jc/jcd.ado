capture program drop jcd
program jcd
	version 13
	syntax anything [if] [in] [, args(string asis)]
	
	gettoken class anything : anything
	
	local r_all : r(macros)
	foreach r_elt of loc r_all {
		local r_`r_elt' = r(`r_elt')
	}
	
	local r_scalars_all : r(scalars)
	foreach r_elt of loc r_scalars_all {
		scalar rs_`r_elt' = r(`r_elt')
	}
	
	local e_all : e(macros)
	foreach e_elt of loc e_all {
		local e_`e_elt' = e(`e_elt')
	}
	
	local e_scalars_all : e(scalars)
	foreach e_elt of loc e_scalars_all {
		scalar es_`e_elt' = e(`e_elt')
	}
	
	javacall de.pbc.stata.PluginLoader start `anything' `if' `in', args(`class' `args')
end
