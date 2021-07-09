program define stddiff, rclass
	version 13.0
	* Ahmed Bayoumi
	* version 0.2
	syntax varlist(fv) [if] [in] , BY(varname numeric) [ ///
		COHensd  ///  report cohensd as calculated by esize
		HEDgesg ///  report hedgesg as calculated by esize 
		abs /// report absolute values
	]
	tempname sds  output 
	qui inspect `by' `if' `in' // check that by has only 2 levels
	if (r(N_unique)!=2){
		di as error "`by' can only have 2 categories"
		error 420
	}

	foreach v in `varlist'{
		fvexpand(`v')
		capture assert r(fvops)=="true"
		if(_rc==0){
			_ms_parse_parts 1.`v'
			local v=r(name)
			_stddiff  `v' `if' `in', by(`by') `opts' `cohensd' `hedgesg' categorical	// for each, call stddiff program
		}
		else{
			_stddiff  `v' `if' `in', by(`by') `opts' `cohensd' `hedgesg' continuous `abs' // for each, call stddiff program

		}
		matrix `sds'= nullmat(`sds') \ r(sds)
		matrix `output' = nullmat(`output') \ r(output)
		local llist ="`llist' " + r(llist)
	}
	
	stddiff_display, output(`output') llist(`llist') by("`by'")

	matrix rownames `sds' = `vlist'	
	matrix rownames `output' = `llist'
	matrix colnames `sds'=Std_Diff
	matrix colnames `output' = Mean_or_N SD_or_% Mean_or_N SD_or_% Std_Diff Var_type
	matrix coleq `output'= `by'=`l1' `by'=`l1' `by'=`l2' `by'=`l2'  .
	
	return matrix stddiff=`sds'
	return matrix output = `output'
end program	

	
program define stddiff_display
	syntax [if] [in], output(name) llist(string) by(string)
//	di as text "Standardized Differences" _n
	tempname rt
	qui tab `by' `if' `in', matrow(`rt')
	mata: st_local("isvallab",st_varvaluelabel("`by'"))
	if("`isvallab'"==""){
		mata: st_local("rstring",invtokens(strofreal(st_matrix("`rt'")')))
	}
	else{
		mata: st_local("rstring",invtokens(st_vlmap(st_varvaluelabel("`by'"),st_matrix("`rt'")')))
	}

	local l1=word("`rstring'",1)
	local l2=word("`rstring'",2)

	di as text _n "{hline 13}{c TT}{hline 25}{c TT}{hline 25}{c TT}{hline 12}" _n /*
		*/ _col(14) "{c |}" "{rcenter 25:`=abbrev("`by'=`l1'",24)' }" /*
		*/ _col(40) "{c |}" "{rcenter 25:`=abbrev("`by'=`l2'",24)' }" /*
		*/ _col(66) "{c |}" _n /*
		*/ _col(14) "{c |}{ralign 10:Mean or N} {ralign 13:SD or (%)} " /*
		*/  		"{c |}{ralign 10:Mean or N} {ralign 13:SD or (%)} " /*
		*/  "{c |}{ralign 10:Std Diff}" _n /*
		*/ "{hline 13}{c +}{hline 25}{c +}{hline 25}{c +}{hline 12}"  

	forv r=1/`=rowsof(`output')'{
		if!(`r'==1 & word("`llist'",1)=="." ) & ! (word("`llist'",`r')=="." & word("`llist'",`r'+1)==".") ///
		& !(`r'==rowsof(`output') & word("`llist'",`r')=="." ){
			di as text  %12s  abbrev(subinstr(word("`llist'",`r'),".","",.),12) as text _col(14) "{c |} "  _c
			if(`output'[`r',1]!=.z) {
				di as result %9.4g `output'[`r',1] "  "  _c
			}
			if(`output'[`r',2]!=.z) {
				if(`output'[`r',6]==1){
					di as result %12.5g `output'[`r',2] " {c |} "  _c
				}
				else{
					di as result _skip(6) "(" %4.1f `output'[`r',2]	") {c |} "  _c
				}
			}
			else{
				di as result _col(40) as text "{c |} "  _c
			}
			if(`output'[`r',3]!=.z) {
				di as result %9.4g `output'[`r',3] "  "  _c
			}

			
			if(`output'[`r',4]!=.z) {
				if(`output'[`r',6]==1){
					di as result %12.5g `output'[`r',4] " {c |} "  _c
				}
				else{
					di as result _skip(6) "(" %4.1f `output'[`r',4]	") {c |} "  _c
				}
			}
			else{
				di as text _col(66)   "{c |}"  _c
			}
			
			if(`output'[`r',5]!=.z) {
				di as result %10.5f `output'[`r',5] 
			}
			else{
				di "" 
			}
		}
	}
	di as text "{hline 13}{c BT}{hline 25}{c BT}{hline 25}{c BT}{hline 12}"  

end program	


