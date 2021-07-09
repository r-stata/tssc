// qv: quasi-variances (Firth 2003)
	// verson 1.03 27JUN2014
	// Aspen Chen aspenchensoc@gmail.com

capture program drop qv
program qv, eclass
version 11
if !replay()	{
	syntax varlist(fv) [, Ref(string) LEVel(cilevel) plot saving(passthru)]
	
	// retrieve command line & df
	if "`e(mi)'"=="mi"	{
		loca cmdline "`e(cmdline_mi)'"
		loca df=`e(df_r_mi)'
	}
	else	{
		loca cmdline "`e(cmdline)'"
		loca df=e(df_m)
	}
		
	// confirm
	loca fvops = "`s(fvops)'" == "true" 
	if `fvops' {
		// variables in last estimation
		if strpos("`cmdline'", "`varlist'")==0	{
			di as error `""`varlist'" not included in previous estimation"'
			exit
		}
	
		// one variable specified
		if wordcount("`varlist'")>1	{
			di as error "only one variable allowed when factor variables specified"
			exit
		}
		}
	else	{
		// variables in last estimation
		foreach var in `varlist'	{
			if strpos("`cmdline'", "`var'")==0	{
				di as error "`var' not included in previous estimation"
				exit
			}
		}
		
		// dichotomous variables
		foreach var in `varlist'	{
			qui su `var'
			if	`r(min)'!=0 | `r(max)'!=1 {
				di as error "`var' contains values other than 0 or 1"
				exit
			}
			qui tab `var'
			if `r(r)'!=2	{
				di as error "`var' contains values other than 0 or 1"
				exit
			}
		}
	}

	// parse options
		// ref group
		if "`ref'"==""	{
			loca rf="ref_grp"
		}
		else if wordcount("`ref'")!=1	{
			di as error "only one word allowed in option ref()"
			exit
		}
		else loca rf="`ref'"
		
		// ci level
		if	"`level'"==""	{
			loca level=95
		}
			loca cilev=(1-(1-(`level'/100))/2)
				
	// matrices
	tempname b V FLG BE QV _V1 _B1 _V2 _B2 _V1 _B2
		mat `b'=e(b)
		mat `V'=e(V)	
	
	if `fvops'	{
		fvexpand `varlist'
		loca n2=wordcount("`r(varlist)'")					
		loca flist "`r(varlist)'"							
		loca lv_min=word("`flist'",1)						// first level
		loca lv_max=word("`flist'",-1)						// last level
		loca mx_min=colnumb(`b',"`lv_min'")					// order in matrix
		loca mx_max=colnumb(`b',"`lv_max'")					// order in matrix
		mat `BE'=`b'[1,`mx_min'..`mx_max']					// submatrix for coefficients
		mat `QV'=`V'[`mx_min'..`mx_max',`mx_min'..`mx_max']	// submatrix for var-cov
	}
	else {
		loca n1=wordcount("`varlist'")			// # of all vars
		loca n2=wordcount("`varlist'")+1		// # of vars in contrast list
		loca cols=colsof(`b')
		mat `FLG'=J(1,`cols', 0)
		foreach var in `varlist'	{
			loca i=colnumb(`b',"`var'")
			mat `FLG'[1,`i']=1
		}
		mata: _V1 = select(st_matrix(st_local("V")),(st_matrix(st_local("FLG"))))
		mata: _V1 = select(_V1, (st_matrix(st_local("FLG")))')
		mata: st_matrix("`_V1'",_V1)
		mata: _B1 = select(st_matrix(st_local("b")),(st_matrix(st_local("FLG"))))
		mata: st_matrix("`_B1'",_B1)
		
		loca elist: colname `b'	
		foreach var in `elist'	{
			if regexm("`varlist'","`var'")==0	{
				loca elist=subinword("`elist'","`var'","",.) // same order as last estimate
			}
		}
		loca elist=itrim("`elist'")
		mat colname `_V1'=`elist'
		mat rowname `_V1'=`elist'
		
		mat `_V2'=J(`n1',`n1',0)
		mat `_B2'=J(1,`n1',0)
		
		loca i=1
		foreach v1 in `varlist'	{
			loca j=1
				foreach v2 in `varlist'	{
					loca a=colnumb(`_V1',"`v1'")
					loca b=colnumb(`_V1',"`v2'")
					mat `_V2'[`i',`j']=`_V1'[`a',`b']
					loca ++j
				}
			loca c=colnumb(`_V1',"`v1'")
			mat `_B2'[1,`i']=`_B1'[1,`c']
			loca ++i
		}
				
		// extra row & column
		mat `QV'=J(`n2', `n2', 0)
		mat `QV'[2,2]=`_V2'
		mat `BE'=J(1,`n2',0)
		mat `BE'[1,2]=`_B2'
		
		// names
		loca flist "`rf' `varlist'"
		matrix colnames `QV'=`flist'
		matrix rownames `QV'=`flist'
	}
	
	// contrasts
	loca cslist ""
	forvalues x=1/`n2'	{
	loca cslist "`cslist' cs`x'"
	}
	
	tempvar vij `cslist'
	loca num_cs=`n2'*(`n2'-1)/2
	
	qui forvalues x=1/`n2'	{
		gen `cs`x''=0 if _n<=`num_cs'
	}
		
	qui gen `vij'=.	// log(var(Beta_j-Beta_k))
	loca counter=1
	qui forvalues x=1/`n2'	{
		forvalues y=`x'/`n2'	{
			if `x'!=`y'	{
				replace `cs`x''=1 if _n==`counter'
				replace `cs`y''=1 if _n==`counter'
				replace `vij'=ln(`QV'[`x',`x']+`QV'[`y',`y']-2*`QV'[`x',`y']) if _n==`counter'
				loca counter=`counter'+1
			}
		}
	}
	
	// Estimate q_j+q_k
		capture qui glm `vij' `cs1'-`cs`n2'', f(gau) l(glm_exp) irls nocon	// irls
		if _rc	{
			qui glm `vij' `cs1'-`cs`n2'', f(gau) l(glm_exp) ml nocon search	// ml
		}
	
	// Set output matrix
	mat QV=e(b)'
	matrix roweq QV=""
	matrix rownames QV=`flist'
	matrix colnames QV=qv
	mat R=J(`n2', 6, 0)
	qui forvalues x=1/`n2'	{
		mat R[`x',1]=`BE'[1,`x']
		mat R[`x',2]=sqrt(`QV'[`x',`x'])
		mat R[`x',3]=sqrt(QV[`x',1])
		mat R[`x',4]=(QV[`x',1])
		mat R[`x',5]=R[`x',1]-invttail(`df',1-`cilev')*R[`x',3]
		mat R[`x',6]=R[`x',1]+invttail(`df',1-`cilev')*R[`x',3]
	}
		mat qvlb=R[1..`n2',5]
		mat qvub=R[1..`n2',6]
		mat rowname qvlb=`flist'
		mat colname qvlb=lb
		mat rowname qvub=`flist'
		mat colname qvub=ub
	
	// print results
	di _newline(2)
	di "----------------------------------------------------------------------------"
	di _col(2) "Category" _col(20) "Coef." _col(34) "SE" _col(41) "Quasi-SE" _col(55) "lb(QV)" _col(67) "ub(QV)"
	di "----------------------------------------------------------------------------"
	loca counter=1
	qui foreach ctg in `flist'	{
		noi di _col(2) `"`ctg'"' _col(16) %10.4f R[`counter',1] _col(28) %10.4f R[`counter',2] _col(39) %10.4f R[`counter',3] /*
		*/ _col(51) %10.4f R[`counter',5] _col(64) %10.4f R[`counter',6]
		loca ++counter
	}
	di "----------------------------------------------------------------------------"
	di "*lb and ub calculated at the `level'% level"
	
	// plot
	if "`plot'"!=""		{
		tempvar group beta ub lb
		tempname lb
		
		qui gen `group'=_n in 1/`n2'
		loca grplbl ""
		
		qui forval i=1/`n2'	{
			loca lbl=word("`flist'", `i')
			loca grplbl="`grplbl'"+"`i'"+" "+"`lbl'"+" "
		}	
		label define `lb' `grplbl'
		label value `group' `lb'
		
		qui gen double `beta'=.
		qui gen double `ub'=.
		qui gen double `lb'=.
		qui forval i=1/`n2'	{
			replace `beta'=R[`i',1] if _n==`i'
			replace `lb'=R[`i',5] if _n==`i'
			replace `ub'=R[`i',6] if _n==`i'
		}
		
		graph twoway scatter `group' `beta' || rspike `ub' `lb' `group', hor `saving'		///
		legend(off) ytitle("") ylabel(1(1)`n2', valuelab alter angle(horizontal))
	}
	
	// return result
	qui `cmdline' 			// reproduce original estimate
	ereturn mat qvub=qvub	// upper bounds
	ereturn mat qvlb=qvlb	// lower bounds
	ereturn mat qv=QV		// quasi variance matrix
}

else {
	if "`e(cmd)'"!="qv" error 301
}		
end
