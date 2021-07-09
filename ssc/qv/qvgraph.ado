program qvgraph
version 11
syntax varlist(fv), [ref(string) LEVel(cilevel) HORIzontal 		///
                    GRPLabel(passthru) MKLabel SAVing(passthru) ///
					SCATteroption(string) RSPikeoption(string) *]
loca fvops="`s(fvops)'"=="true"
	
	qv `varlist', ref(`ref') level(`level')
	
	foreach mtx in qv qvlb qvub	{
		capture mat list e(`mtx')
		if _rc	{
			di as error "e(`mtx') not available"
			exit
		}
	}
	
	tempvar group beta ub lb
	tempname qv qvub qvlb vlbl
	mat `qv'=e(qv)
	mat `qvub'=e(qvub)
	mat `qvlb'=e(qvlb)
	loca n=rowsof(`qv')	
	
	qui {
		gen `ub'=.
		gen `lb'=.
		gen `group'=.
			forval i=1/`n' {
				replace `ub'=`qvub'[`i',1] if _n==`i'
				replace `lb'=`qvlb'[`i',1] if _n==`i'
				replace `group'=`i' if _n==`i'
			}
		}
	qui gen `beta'=(`ub'+`lb')/2
	tempname vlbl
	loca grplabel=substr(subinstr(`"`grplabel'"',`"grplabel("',`""',1), 1, ///
	                    length(subinstr(`"`grplabel'"',`"grplabel("',`""',1))-1)
	
	if `"`grplabel'"'!=""	{		// grplabel specified
		capture label define `vlbl' `grplabel', replace
		if _rc	{
			di as error `"syntax of grplabel() invalid; use "# label [# label]"'
			exit
		}
		qui label list `lbl'
		if `r(k)'!=`n'	{
			di as error "number of labels in grplabel() differ from levels of e(qv)"
			exit
		}
	}
	else if !`fvops' 		 {	// use name of dummy variables
		tempname sigrow
		loca grplabel ""
		forval i=1/`n'	{
			mat `sigrow'=`qv'[`i',....]
			loca rn: rownames `sigrow'
			loca grplabel=`"`grplabel'"' + " " + "`i'" + " " + `"`rn'"'
		}
		label define `vlbl' `grplabel', replace
	}
	else  {									// factor variable
		loca fvar=substr("`varlist'",strpos("`varlist'",".")+1,.)
		loca lblname: value label `fvar'
			if `"`lblname'"'!=""	{		// use value labels
				qui label list `lblname'
				loca lbmin=`r(min)'
				loca lbmax=`r(max)'
				loca grplabel ""
				forval i=`lbmin'/`lbmax'	{
					loca lbl: label `lblname' `i', strict
						if `"`lbl'"'!=""	{
							loca grplabel = `"`grplabel'"' + " " + "`i'" ///
							                + " " + `""`lbl'""'
						}
				}
			}
			else {
				
				 qui levelsof `fvar'			// use values
				 // loca grplabel = "`r(levels)'"
				 loca grplabel=""
				 foreach num in `r(levels)'	{
					loca grplabel=`"`grplabel'"' + " " + "`num'" + " " + "`num'"
				}
			}
		label define `vlbl' `grplabel', replace
	}
		label value `group' `vlbl'
		qui levelsof `group', local(vlist)
	
	
	// graph
	if "`horizontal'"!="" {
			loca sct `"scatter `group' `beta' "'						 // scatter options
			loca rsp `"rspike `ub' `lb' `group', `rspikeoption' hor"'	 // rspike options
			loca opt `"ytitle("") legend(off) ylab(`vlist',val notick)"' // other options
		}
		else {
			loca sct `"scatter `beta' `group' "'						 // scatter options
			loca rsp `"rspike `ub' `lb' `group', `rspikeoption' vert"'	 // rspike options
			loca opt `"xtitle("") legend(off) xlab(`vlist',val notick)"' // other options
		}
	
	if "`mklabel'"==""	{
				twoway (`sct', `scatteroption')(`rsp'),`opt' `options'
		}
		else 	{
				twoway (`sct', mlabel(`group') `scatteroption')(`rsp'),`opt' `options'
		}
	
	// save variables
	if `"`saving'"'!=""	{
		loca 0=regexr(regexr(`"`saving'"', "^saving\(", ""), ".$", "")	 // extract options
		capture syntax name [,replace]
		if _rc	{
			di as error `"use "saving(prefix [,replace])""'
			exit
		}
		
		loca prf=substr("`namelist'",1,6)		// prefix
				
		if "`replace'"=="replace"	{
			capture drop `prf'_g `prf'_b `prf'_u `prf'_l
		}
			
		qui {
			gen `prf'_g=`group'
			gen `prf'_b=`beta'
			gen `prf'_u=`ub'
			gen `prf'_l=`lb'
			label var `prf'_g 		"qv:grouping"
			label var `prf'_b		"qv:point estimates"
			label var `prf'_u		"qv:upper bound"
			label var `prf'_l		"qv:lower bound"
			label define `prf'lbl `grplabel', replace
			label value `prf'_g `prf'lbl
		}
	}
end
