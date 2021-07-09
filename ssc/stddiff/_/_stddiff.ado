program define _stddiff, rclass
	version 13.0
	syntax varlist  [if] [in], by(varname) [continuous categorical cohensd hedgesg abs]
	tempname m1 m2 v1 v2 s1 s2 res table output r
	if("`continuous'"=="" & "`categorical'"==""){
		local continuous="continuous"
	}
	if("`continuous'"=="continuous" ){
		foreach v of varlist `varlist'{
			qui tabstat `v' `if' `in', by(`by') stat(mean n v sd) save
			mat `s1'=r(Stat1)
			mat `s2'=r(Stat2)
			scalar `v1'=`s1'[3,1]
			scalar `v2'=`s2'[3,1]
			scalar `m1'=`s1'[1,1]
			scalar `m2'=`s2'[1,1]
			
			if( "`hedgesg'"=="hedgesg"){
				qui esize twosample `v' `if' `in' , by(`by') `hedgesg'
				local sd=r(g)
			}
			else if("`cohensd'"=="cohensd"){
				qui esize twosample `v' `if' `in', by(`by') `cohensd'
				local sd=r(d)
			}
			else{
				local sd= (`m1'-`m2') /  sqrt((`v1'+`v2' )/2)
			}
		mat `res'=nullmat(`res') \ `sd'
		if("`abs'"=="abs") local sd=abs(`sd')
		mat `output' = nullmat(`output') \ `m1', `s1'[4,1], `m2', `s2'[4,1], `sd' , 1
		local vlist "`vlist' `v'"
		local llist "`llist' `v'"
		}
	}
	else{ // categorical varaibles
		foreach v of varlist `varlist'{
			qui tab `v' `by' `if' `in', matcell(`table') matrow(`r')
			mata: matasd(st_matrix("`table'"))
			mat `res'=nullmat(`res') \ r(std)
			mat `output'=nullmat(`output') \ J(2,6,.z) \ (r(output) , J(rowsof(r(output)),1,2)) \ J(1,6,.z) 
			local vv="`v' " *rowsof(r(output))
			local vlist "`vlist' `vv'" 
			mata: st_local("isvallab",st_varvaluelabel("`v'"))
			if("`isvallab'"==""){
				mata: st_local("rstring",invtokens(strofreal(st_matrix("`r'")')))
			}
			else{
				mata: st_local("rstring",invtokens(st_vlmap(st_varvaluelabel("`v'"),st_matrix("`r'")')))
			}
			local llist = "`llist' . `v' `rstring' ."
		}
	}
	return matrix sds = `res'
	return matrix output = `output'
	return local vlist = "`vlist'"
	return local llist = "`llist'"
end program


