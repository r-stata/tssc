*! version 1.0  29jun2014
program group_twoway, rclass
	
	version 12
	
	syntax varlist(min=2 max=2) , GENerate(name)
	confirm new variable `generate'
	local vertex1 : word 1 of `varlist'
	local vertex2  : word 2 of `varlist'

	tempvar edge vertexnum vertex ID_vertex ID_min ID_min_aux ID_min_aux2 dif_aux aux_n	
	tempfile aux aux2
	
	preserve
	keep `vertex1' `vertex2' // not necessary, just to make processing quickquer
	duplicates drop
	
	*To account for the possibility that the same vertex is in both the vertex1	and vertex2 list we "reshape" the edge list to long format.  
	gen `edge'=_n	
	expand 2
	sort `edge'
	gen 	`vertex'=`vertex1' if mod(_n,2)==1
	replace `vertex'=`vertex2' if mod(_n,2)==0
	drop `vertex1' `vertex2'

	*creating numeric ID for the vertexes, and making sure `ID_vertex'>`edge' for everi ID and edge number
	egen `ID_vertex'=group(`vertex')
	replace `ID_vertex'=`ID_vertex'+_N	
	
	*grouping:
	gen `ID_min'=`edge'	
	local x = 1
	local l = 0 // counts number of iterations
	while `x'==1 {
		cap drop `ID_min_aux'
		cap drop `ID_min_aux2'
		cap drop `dif_aux'

		egen `ID_min_aux'=min(`ID_min') , by(`vertex')
		replace `ID_min'=`ID_min_aux'
		egen `ID_min_aux2'=min(`ID_min') , by(`edge')
		replace `ID_min'=`ID_min_aux2'	
		
		display `l'
		local `l++'
		
		*loop stops when `ID_min'==`ID_min_aux' for all observations
		egen `dif_aux'=max(`ID_min'!=`ID_min_aux')	
		local x = `dif_aux'		
	}
	
	
	duplicates drop `vertex', force
	egen `generate'=group(`ID_min')
	rename `vertex' `vertex1'
	save `aux'	
	
	restore
	gen `aux_n'=_n
	merge m:1 `vertex1' using `aux' , nogen keep(master match)
	sort `aux_n' 
	end
	
	
