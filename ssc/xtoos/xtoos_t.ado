program xtoos_t, rclass
version 12.0:

	syntax varlist (fv ts) [if/] [in], INDate(string) CDate(string) [Met(string) MComp(string) /*
	*/fe xbu dum opar lags(numlist max=1 integer) EValopt(varname) ts HGRaph(numlist integer) *]

******************************************************************************************************************************************
if "`dum'"=="dum" & "`fe'"=="fe" {
	di as err "option fe and option dummy variables not allowed"
	exit 250
}
******************************************************************************************************************************************
tokenize `varlist'
loc yvar "`1'"
macro shift 1
loc rhsvars "`*'"

******************************************************************************************************************************************
capture tsset
if _rc>0 {
	di as err "time/panel variables not set, use tsset/xtset ..."
	exit 0003
}
loc panvar=r(panelvar)
loc timevar=r(timevar)
loc tform=r(unit1)
loc tunit=r(unit)

if "`panvar'"=="." {
	loc panvar _id_
	capture qui gen _id_=1
	if "`tunit'"=="0"|"`tunit'"=="." |"`tunit'"=="per : "" 0" qui xtset _id_ `timevar'
	else qui xtset _id_ `timevar', `tunit'
}
if "`tform'"=="q" { 
	loc indate=quarterly("`indate'","YQ")
	loc cdate=quarterly("`cdate'","YQ")
}
else if "`tform'"=="m"  {
	loc indate=monthly("`indate'","YM")
	loc cdate=monthly("`cdate'","YM")
}
else {
	loc indate=real("`indate'")
	loc cdate=real("`cdate'")
}

******************************************************************************************************************************************
if "`lags'"=="" & ("`met'"=="xtabond" | "`met'"=="xtdpdsys") loc lags 1
else if "`lags'"=="" {
	foreach i of loc rhsvars  {
		local m=regexm("`i'","`yvar'")
		local lags=`lags'+`m'
	}
}
if `lags'==0 loc lyvar 
else {
	loc lyvar L.`yvar'
	local lyvar=regexr("`lyvar'","L.D.","LD.")
	forval i=2/`lags'  {
		loc lyvar `lyvar' L`i'.`yvar'
		local lyvar=regexr("`lyvar'","L`i'.D.","L`i'D.")
	}
}

******************************************************************************************************************************************

if "`met'"=="xtabond" | "`met'"=="xtdpdsys" {
	if "`if'"!="" qui `met' `yvar' `rhsvars' if `timevar'<=`indate' & `if', lags(`lags')
	else qui `met' `yvar' `rhsvars' if `timevar'<=`indate', lags(`lags')
}
else {
	if "`if'"!="" qui reg `yvar' `lyvar' `rhsvars' if `timevar'<=`indate' & `if'
	else qui reg `yvar' `lyvar' `rhsvars' if `timevar'<=`indate'
}
tempvar sample
qui gen `sample'=e(sample)
qui replace `sample'=l.`sample' if `timevar'>`indate' & `timevar'<=`cdate'

*********************************************************************************************************************

loc ousd = `cdate'-`indate'
matrix R0 = J(`ousd',4,.)
matrix I0 = J(1,`ousd',1)

*********************************************************************************************************************

forvalues k=1/`ousd' {	
	
	loc j=`ousd'-`k'+1
	matrix R`j' = J(`j',4,.)
	
	************************************************************
	tempvar y y_f y_ar1 res res2 ym_in ym_ous ydev2_in ydev2_ous samplein x_c i_c

	if "`met'"=="" {
		if "`dum'"=="dum" {
			if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `timevar'<`indate'+`k' & `sample'==1, `options'
			else qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `timevar'<`indate'+`k' & `sample'==1, `options'
		}
		else {
			if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' if `if' & `timevar'<`indate'+`k' & `sample'==1, `fe' `options'
			else qui xtreg `yvar' `lyvar' `rhsvars' if `timevar'<`indate'+`k' & `sample'==1, `fe' `options'
		}
	}
	else if "`dum'"=="dum" {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `timevar'<`indate'+`k' & `sample'==1,`options'
		else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `timevar'<`indate'+`k' & `sample'==1, `options'
	}	
	else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") {
		if "`if'"!="" qui `met' `yvar' `rhsvars' if `if' & `timevar'<`indate'+`k' & `sample'==1, `fe' `options' lags(`lags')
		else qui `met' `yvar' `rhsvars' if `timevar'<`indate'+`k' & `sample'==1, `fe' `options' lags(`lags')
	}	
	else {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `timevar'<`indate'+`k' & `sample'==1, `fe' `options' 
		else qui `met' `yvar' `lyvar' `rhsvars' if `timevar'<`indate'+`k' & `sample'==1, `fe' `options' 
	}	
	
	qui gen `samplein'=e(sample)

	loc allxvars : colfullnames e(b)
	loc xvars : list allxvars-lyvar
	
	fvexpand i.`panvar' if `samplein'==1
	loc dumi=r(varlist)	

	if "`xbu'"=="xbu" {
		capture qui predict `i_c', u
		if _rc!=0 qui predictu `i_c'
		qui replace `i_c'=l.`i_c' if `i_c'==.
		}
	else gen `i_c'=0

	qui gen `x_c'=`i_c'
	foreach x of loc xvars {
		qui replace `x_c'=`x_c'+_b[`x']*`x'
	}
	
	if "`dum'"=="dum" & "`opar'"=="opar" {
		foreach i of loc dumi {
			qui replace `i_c'=`i_c'+_b[`i']*`i'
		}
		qui sum `i_c' if `samplein'==1
		qui replace `x_c'=`x_c'+r(mean)-`i_c'
	}

	if `lags'==0 {
		qui gen `y_f'=`x_c'
	}	
	else {
		loc b_lyvar 
		qui gen `y_f'=`yvar'
		qui replace `y_f'=. if `timevar'>=`indate'+`k'
		forval p=1/`lags'  {
			loc b_lyvar `b_lyvar' +_b[L`p'.`yvar']*L`p'.`y_f'
		}
		qui replace `y_f'=`x_c' `b_lyvar' if `y_f'==.

	}
	qui gen `res'=`yvar'-`y_f'
	qui gen `res2'=`res'^2
		
	if "`evalopt'"=="" qui sum `res2' if `samplein'==0 & `sample'==1 & `timevar'>=`indate'+`k'
	else qui sum `res2' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'>=`indate'+`k'
	scalar rss_ous=r(mean)
	scalar rmse_ous=sqrt(rss_ous)
	matrix R0[`k',1]=rss_ous
	matrix R0[`k',4]=r(N)
	
	forvalues t=1/`j' {
		if "`evalopt'"=="" qui sum `res2' if `samplein'==0 & `sample'==1 & `timevar'==`indate'+`t'+`k'-1
		else qui sum `res2' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'==`indate'+`t'+`k'-1
		scalar rss_ous`t'=r(mean)
		scalar rmse_ous`t'=sqrt(rss_ous`t')
		matrix R`j'[`t',1]=rss_ous`t'
		matrix R`j'[`t',4]=r(N)
	}	
	if "`hgraph'"!="" {
		loc t=`indate'+`k'-1
		cap qui drop _yf`t'
		qui gen _yf`t'=`y_f'
		qui replace _yf`t'=. if `timevar'<`indate'+`k'-1
		loc p=`t'
		if "`tform'"=="q" loc p = string(year(dofq(`t')))+"q"+string(quarter(dofq(`t')))
		else if "`tform'"=="m" loc p = string(year(dofm(`t')))+"m"+string(month(dofm(`t')))
		label var _yf`t' "pred`p'"
	}
	
	*************************************************************************************
	qui gen `y'=`yvar'
	qui replace `y'=. if `timevar'>=`indate'+`k'

	if "`mcomp'"=="" {
		qui replace `y'=l.`y' if `timevar'>=`indate'+`k'
	}
	else if ("`mcomp'"=="xtabond" | "`mcomp'"=="xtdpdsys") {
		if "`if'"!="" qui `mcomp' `y' if `if' & `timevar'<`indate'+`k' & `samplein'==1
		else qui `mcomp' `y' if `timevar'<`indate'+`k' & `samplein'==1
		qui predict `y_ar1'
	}
	else {
		if "`if'"!="" qui `mcomp' `y' L.`y' if `if' & `timevar'<`indate'+`k' & `samplein'==1
		else qui `mcomp' `y' L.`y' if `timevar'<`indate'+`k' & `samplein'==1
		qui predict `y_ar1'
	}
	
	
	if "`mcomp'"!="" {
		forvalues t = `indate'(1)`cdate' {
			qui replace `y_ar1'=_b[L.`y']*L.`y_ar1'+_b[_cons] if `timevar'==`t'+1 & `y_ar1'==.
		}
	}	

	if "`mcomp'"=="" qui replace `res'=`yvar'-`y'
	else qui replace `res'=`yvar'-`y_ar1'
	qui replace `res2'=`res'^2
		
	if "`evalopt'"=="" qui sum `res2' if `samplein'==0 & `sample'==1 & `timevar'>=`indate'+`k'
	else qui sum `res2' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'>=`indate'+`k'
	scalar rss_ar1_ous=r(mean)
	scalar rmse_ar1_ous=sqrt(rss_ar1_ous)
	matrix R0[`k',2]=rss_ar1_ous

	forvalues t=1/`j' {
		if "`evalopt'"=="" qui sum `res2' if `samplein'==0 & `sample'==1 & `timevar'==`indate'+`t'+`k'-1
		else qui sum `res2' if `samplein'==0 & `sample'==1 & `evalopt'==1 & `timevar'==`indate'+`t'+`k'-1
		scalar rss_ar1_ous`t'=r(mean)
		scalar rmse_ar1_ous`t'=sqrt(rss_ar1_ous`t')
		matrix R`j'[`t',2]=rss_ar1_ous`t'
		matrix R`j'[`t',3]=rmse_ous`t'/rmse_ar1_ous`t'
	}	
	*************************************************************************************
		
	matrix R0[`k',3]=rmse_ous/rmse_ar1_ous

	}
*********************************************************************************************************************
matrix RF = J(`ousd',4,1)

forvalues i=1/`ousd' {
	loc k=`ousd'-`i'+1
	matrix RF`i' = J(`k',4,.)
	forvalues h=1/`k' {
		loc j=`ousd'-`h'+1
			forvalues l=1/4 {
				matrix RF`i'[`h',`l']=R`j'[`i',`l']
			}	
	}	
	matrix I`i' = J(1,`k',1)
	matrix RFS`i' = J(1,4,.)
	matrix RFS`i' = (1/`k')*I`i'*RF`i'
	matrix RFS`i'[1,4]=RFS`i'[1,4]*`k'
	forvalues j=1/4 {
		matrix RF[`i',`j'] = RFS`i'[1,`j']
	}
	forvalues u=1/`ousd' {
		matrix RF[`u',3] = sqrt(RF[`u',1])/sqrt(RF[`u',2])
	}
}

matrix N = R0[1...,4]
matrix n0=I0*N
scalar n=n0[1,1]
matrix R = (1/n)*N'*R0
forvalues i=1/`ousd' {
	matrix R0[`i',1] = sqrt(R0[`i',1])
	matrix R0[`i',2] = sqrt(R0[`i',2])
}
matrix R[1,1]=sqrt(R[1,1])
matrix R[1,2]=sqrt(R[1,2])
matrix R[1,3]=R[1,1]/R[1,2]
matrix R[1,4]=n0[1,1]

matrix N = RF[1...,4]
matrix n0=I0*N
scalar n=n0[1,1]
matrix RFS = (1/n)*N'*RF
forvalues i=1/`ousd' {
	matrix RF[`i',1] = sqrt(RF[`i',1])
	matrix RF[`i',2] = sqrt(RF[`i',2])
}
matrix RFS[1,1]=sqrt(RFS[1,1])
matrix RFS[1,2]=sqrt(RFS[1,2])
matrix RFS[1,3]=RFS[1,1]/RFS[1,2]
matrix RFS[1,4]=n0[1,1]

forvalues i=1/`ousd' {
	loc j=`indate'+`i'-1
	if "`tform'"=="q" loc j = string(year(dofq(`j')))+"q"+string(quarter(dofq(`j')))
	else if "`tform'"=="m" loc j = string(year(dofm(`j')))+"m"+string(month(dofm(`j')))
	loc rowsR0 `rowsR0' `j'
	loc rowsRF `rowsRF' `i'
}

matrix rownames R0 = `rowsR0'
matrix rownames R = Summary

matrix rownames RF = `rowsRF'
matrix rownames RFS = Summary

matrix R = R0\R
matrix RFS = RF\RFS

matrix colnames R = RMSE_oos RMSE_Alt_oos UTheil N
matrix colnames RFS = RMSE_oos RMSE_Alt_oos UTheil N

matlist R, title("Out of sample evaluation according to last in-sample date") lines(rowt)
matlist RFS, title("Out of sample evaluation according to forecasting horizon") lines(rowt)

return matrix ev_last R
return matrix ev_hor RFS

if "`hgraph'"!="" {
	tempvar dgr 
	qui gen `dgr'=.
	foreach i of loc hgraph {
		qui replace `dgr'=1 if `panvar'==`i'
	}
	loc ygraph 
	loc ousd1=`ousd'-1
	forvalues i=0/`ousd1' {
		loc hi = `indate'+`i'
		loc ygraph `ygraph' _yf`hi'
	}
	xtline `yvar' `ygraph' if `timevar'<=`cdate' & `dgr'==1 & `sample'==1, i(`panvar') t(`timevar') xline(`indate')
	qui drop `ygraph'
}
end


***************************************************************************************************************************
** Subprogram PREDICTU 
	program predictu
	syntax newvarname(gen)

	cap xtset
	loc panvar=r(panelvar)

	tempvar x_cm y ymi
	loc allvars : colfullnames e(b)
	loc c _cons
	loc allvars : list allvars-c
	loc y=e(depvar)
	qui egen `ymi'=mean(`y') if e(sample), by (`panvar') 
	qui replace `varlist'=0
	gen `x_cm'=0

	foreach x of loc allvars {
		fvrevar `x'
		loc z=r(varlist)
		tempvar `z'mi
		qui egen ``z'mi'=mean(`z') if e(sample), by (`panvar')
		qui replace ``z'mi'=l.``z'mi' if ``z'mi'==.
		qui replace `x_cm'=`x_cm'+_b[`x']*``z'mi'
	}
	qui replace `varlist'=`ymi'-`x_cm'-_b[_cons]

end 
***************************************************************************************************************************
