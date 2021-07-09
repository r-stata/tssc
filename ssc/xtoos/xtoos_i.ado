program xtoos_i, rclass
version 13.0:

	syntax varlist (fv ts) [if/] [in], Ous(integer) Ksmpl(integer) [Rsmpl(integer 1) EValopt(varname) /*
	*/Met(string) MComp(string) fe dum lags(numlist integer) HGRaph *]

******************************************************************************************************************************************
if "`dum'"=="dum" & "`fe'"=="fe" {
	di as err "option fe and option dummy variables not allowed"
	exit 250
}
if "`hgraph'"=="hgraph" & "`evalopt'"=="" {
	di as err "when running option hgraph a specific group of individuals must be defined through option evalopt"
	exit 252
}

******************************************************************************************************************************************
tokenize `varlist'
loc yvar "`1'"
macro shift 1
loc rhsvars "`*'"

capture tsset
if _rc>0 {
	di as err "time/panel variables not set, use tsset/xtset ..."
	exit 0003
}
loc panvar=r(panelvar)
loc timevar=r(timevar)
	
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

if "`lags'"=="" & ("`met'"=="xtabond" | "`met'"=="xtdpdsys") {
	if "`if'"!="" qui `met' `yvar' `rhsvars'  if `if'
	else qui `met' `yvar' `rhsvars' 
}
else {
	if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' if `if'
	else qui xtreg `yvar' `lyvar' `rhsvars'
}
fvexpand i.`panvar' if e(sample)
loc idum=r(varlist) 

tempvar sample
qui gen `sample'=e(sample)
qui replace `sample'=. if `sample'==0

*********************************************************************************************************************

loc numid = wordcount("`idum'")

foreach x of loc idum {
	loc k=regexr("`x'",".`panvar'","")
	loc k=regexr("`k'","b","")
	loc k=regexr("`k'","o","")
	loc idumn `idumn' `k'
	}

*********************************************************************************************************************
loc kn =round(`numid'/`ous')
matrix R0 = J(`kn',10,.)
matrix I1 = J(1,`kn',1)


*********************************************************************************************************************
if `rsmpl'>=1 {
	matrix RS = J(`rsmpl',10,.)
	matrix I2 = J(1,`rsmpl',1)
	
	forvalues r=1/`rsmpl' {
		loc idumn2 "`idumn'"
		loc rndid ""
		loc rndidk ""

		forvalues k=1/`kn' {	
			if `k'<`kn' {
				foreach i of loc rndid {
					loc rndidk `rndidk' ``i''
				}
				loc idumn2 : list idumn2-rndidk
				loc numid2 = wordcount("`idumn2'") 
				tokenize `idumn2'
				loc rndid ""
				loc rndidk ""
				matrix A = `numid2'*matuniform(1,`ous')
					
				forvalues i=1/`ous' {
					loc x= A[1,`i']
					loc j=round(`x')
					loc rndid `rndid' `j'
					}
						
				loc zero 0
				loc rndid : list uniq rndid 
				loc rndid : list rndid-zero 
				loc nrndid = wordcount("`rndid'")
					
				while `nrndid'<`ous' {
					loc dif=`ous'-`nrndid'
					matrix A = `numid2'*matuniform(1,`dif')
					forvalues i=1/`dif' {
						loc x= A[1,`i']
						loc j=round(`x')
						loc rndid `rndid' `j'
					}
						
					loc rndid : list uniq rndid 
					loc rndid : list rndid-zero 
					loc nrndid = wordcount("`rndid'")
				} 
				************************************************************
				tempvar samplein
				qui gen `samplein'=`sample'
				
				foreach i of loc rndid {
					qui replace `samplein'=0 if `panvar'==``i''
				}
			}
			************************************************************
			else if `k'==`kn' {
				foreach i of loc rndid {
					loc rndidk `rndidk' ``i''
				}
				loc idumn2 : list idumn2-rndidk
				loc numid2 = wordcount("`idumn2'") 

			************************************************************
				tempvar samplein
				qui gen `samplein'=`sample'
				
				foreach i of loc idumn2 {
					qui replace `samplein'=0 if `panvar'==`i'
				}
			}
			**********************************************************
			************************************************************
			tempvar y_f res res2 y ymt ym_in ym_ous ydev2_in ydev2_ous y_ar1 i_c
			fvset base first `panvar'

			if "`met'"=="" {
				if "`dum'"=="dum" {
					if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
					else qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
				}
				else {
					if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
					else qui xtreg `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
				}
			}
			else if "`dum'"=="dum" {
				if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
				else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
			}
			else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
				if "`if'"!="" qui `met' `yvar' `rhsvars' if `if' & `samplein'==1, `fe' `options' lags(`lags')
				else qui `met' `yvar' `rhsvars' if `samplein'==1, `fe' `options' lags(`lags')
			}
			else {
				if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
				else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
			}
						
			qui predict `y_f'
					
			if "`dum'"=="dum" {
				loc allxvars : colfullnames e(b)
				loc dumi : list allxvars-rhsvars
				
				qui gen `i_c'=-_b[_cons]
				foreach i of loc dumi {
					qui replace `i_c'=`i_c'+_b[`i']*`i'
				}
				qui sum `i_c' if `samplein'==1
				qui replace `y_f'=`y_f'+r(mean) if `samplein'==0
			}
	
			qui gen `y'=`yvar'
			qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
			qui gen `ydev2_in'=(`yvar'-`ym_in')^2
			qui sum `ydev2_in' if `samplein'==1 & `sample'==1
			scalar tss_in=r(mean)
				
			qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
			qui gen `ydev2_ous'=(`yvar'-`ym_ous')^2
			qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
			scalar tss_ous=r(mean)

			qui gen `res'=`yvar'-`y_f'
			qui gen `res2'=`res'^2
			qui sum `res2' if `samplein'==1 & `sample'==1
			scalar rss_in=r(mean)
			matrix R0[`k',1]=rss_in
				
			qui sum `res2' if `samplein'==0 & `sample'==1
			scalar rss_ous=r(mean)
			matrix R0[`k',2]=rss_ous
				
			matrix R0[`k',3]=tss_in
			matrix R0[`k',4]=tss_ous
			matrix R0[`k',10]=r(N)

			*************************************************************************************
			************************************************************
			if "`mcomp'"=="" {
				if "`if'"!="" qui egen `ymt'=mean(`y') if `if' & `samplein'==1, by(`timevar')
				else qui egen `ymt'=mean(`y') if `samplein'==1, by(`timevar')
				qui egen `y_ar1'=mean(`ymt'), by(`timevar')
			}
			else if ("`mcomp'"=="xtabond" | "`mcomp'"=="xtdpdsys") {
				if "`if'"!="" qui `mcomp' `yvar' if `if' & `samplein'==1
				else qui `mcomp' `yvar' if `samplein'==1
				qui predict `y_ar1'
			}
			else {
				if "`if'"!="" qui `mcomp' `yvar' L.`yvar' if `if' & `samplein'==1
				else qui `mcomp' `yvar' L.`yvar' if `samplein'==1
				qui predict `y_ar1'
			}
				
			qui drop `ym_in'
			qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
			qui replace `ydev2_in'=(`yvar'-`ym_in')^2
			qui sum `ydev2_in' if `samplein'==1 & `sample'==1
			scalar tss_ar1_in=r(mean)
				
			qui drop `ym_ous'
			qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
			qui replace `ydev2_ous'=(`yvar'-`ym_ous')^2
			qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
			scalar tss_ar1_ous=r(mean)

			qui replace `res'=`yvar'-`y_ar1'
			qui replace `res2'=`res'^2
			qui sum `res2' if `samplein'==1 & `sample'==1
			scalar rss_ar1_in=r(mean)
			matrix R0[`k',5]=rss_ar1_in
				
			qui sum `res2' if `samplein'==0 & `sample'==1
			scalar rss_ar1_ous=r(mean)
			matrix R0[`k',6]=rss_ar1_ous

			matrix R0[`k',7]=tss_ar1_in
			matrix R0[`k',8]=tss_ar1_ous
								
			*************************************************************************************
				
			matrix R0[`k',9]=sqrt(rss_ous)/sqrt(rss_ar1_ous)

			}
		*********************************************************************************************************************
		matrix N = R0[1...,10]
		matrix n0=I1*N
		scalar n=n0[1,1]
		matrix R`r' = (1/n)*N'*R0
		
		forvalues s=1/10 {
			matrix RS[`r',`s']=R`r'[1...,`s']
		}
		*********************************************************************************************************************

	}
	matrix N = RS[1...,10]
	matrix n0=I2*N
	scalar n=n0[1,1]
	matrix R = (1/n)*N'*RS
	
	matrix R[1,3] = 1-R[1,1]/R[1,3]
	matrix R[1,4] = 1-R[1,2]/R[1,4]
	matrix R[1,1] = sqrt(R[1,1])
	matrix R[1,2] = sqrt(R[1,2])
	
	matrix R[1,7] = 1-R[1,5]/R[1,7]
	matrix R[1,8] = 1-R[1,6]/R[1,8]
	matrix R[1,5] = sqrt(R[1,5])
	matrix R[1,6] = sqrt(R[1,6])

	matrix R[1,9]=R[1,2]/R[1,6]

	matrix colnames R = RMSE_in RMSE_oos R2_in R2_oos RMSE_Alt_in RMSE_Alt_oos R2_Alt_in R2_Alt_oos Utheil_Alt N
	matrix rownames R = Summary
	matlist R, title("Out of sample evaluation: Random sampling") lines(rowt)
	return matrix random R
}
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
tokenize `idumn'
loc kn =round(`numid'/`ksmpl')
loc ln = `kn'*`ksmpl'

if `ksmpl'>=1 {
	matrix R0 = J(`kn',10,.)
	matrix I1 = J(1,`kn',1)

	forvalues k=`ksmpl'(`ksmpl')`ln' {	
	
		loc j=`k'-`ksmpl'
		loc ki=`k'/`ksmpl'
 
		tempvar samplein
		qui gen `samplein'=`sample'

		if `k'==`ksmpl' {
			loc j=1
			qui replace `samplein'=0 if `panvar'>=``j'' & `panvar'<=``k''
			}
		else if `k'==`ln' {
			qui replace `samplein'=0 if `panvar'>``j'' & `panvar'<=``numid''
			}
		else {	
			qui replace `samplein'=0 if `panvar'>``j'' & `panvar'<=``k''
			}
		
		************************************************************
		tempvar y_f res res2 y ymt ym_in ym_ous ydev2_in ydev2_ous y_ar1 i_c
		fvset base first `panvar'

		if "`met'"=="" {
			if "`dum'"=="dum" {
				if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
				else qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
			}
			else {
				if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
				else qui xtreg `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
			}
		}
		else if "`dum'"=="dum" {
			if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
			else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
		}
		else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
			if "`if'"!="" qui `met' `yvar' `rhsvars' if `if' & `samplein'==1, `fe' `options' lags(`lags')
			else qui `met' `yvar' `rhsvars' if `samplein'==1, `fe' `options' lags(`lags')
		}
		else {
			if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
			else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
		}
	
		qui predict `y_f'
					
		if "`dum'"=="dum" {
			loc allxvars : colfullnames e(b)
			loc dumi : list allxvars-rhsvars
				
			qui gen `i_c'=-_b[_cons]
			foreach i of loc dumi {
				qui replace `i_c'=`i_c'+_b[`i']*`i'
			}
			qui sum `i_c' if `samplein'==1
			qui replace `y_f'=`y_f'+r(mean) if `samplein'==0
		}
			
		qui gen `y'=`yvar'
		qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
		qui gen `ydev2_in'=(`yvar'-`ym_in')^2
		qui sum `ydev2_in' if `samplein'==1 & `sample'==1
		scalar tss_in=r(mean)
			
		qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
		qui gen `ydev2_ous'=(`yvar'-`ym_ous')^2
		qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
		scalar tss_ous=r(mean)

		qui gen `res'=`yvar'-`y_f'
		qui gen `res2'=`res'^2
		qui sum `res2' if `samplein'==1 & `sample'==1
		scalar rss_in=r(mean)
		matrix R0[`ki',1]=rss_in
			
		qui sum `res2' if `samplein'==0 & `sample'==1
		scalar rss_ous=r(mean)
		matrix R0[`ki',2]=rss_ous
			
		matrix R0[`ki',3]=tss_in
		matrix R0[`ki',4]=tss_ous

		matrix R0[`ki',10]=r(N)

		*************************************************************************************
		if "`mcomp'"=="" {
			if "`if'"!="" qui egen `ymt'=mean(`y') if `if' & `samplein'==1, by(`timevar')
			else qui egen `ymt'=mean(`y') if `samplein'==1, by(`timevar')
			qui egen `y_ar1'=mean(`ymt'), by(`timevar')
		}
		else if ("`mcomp'"=="xtabond" | "`mcomp'"=="xtdpdsys") {
			if "`if'"!="" qui `mcomp' `yvar' if `if' & `samplein'==1
			else qui `mcomp' `yvar' if `samplein'==1
			qui predict `y_ar1'
		}
		else {
			if "`if'"!="" qui `mcomp' `yvar' L.`yvar' if `if' & `samplein'==1
			else qui `mcomp' `yvar' L.`yvar' if `samplein'==1
			qui predict `y_ar1'
		}

		qui drop `ym_in'
		qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
		qui replace `ydev2_in'=(`yvar'-`ym_in')^2
		qui sum `ydev2_in' if `samplein'==1 & `sample'==1
		scalar tss_ar1_in=r(mean)
			
		qui drop `ym_ous'
		qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
		qui replace `ydev2_ous'=(`yvar'-`ym_ous')^2
		qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
		scalar tss_ar1_ous=r(mean)

		qui replace `res'=`yvar'-`y_ar1'
		qui replace `res2'=`res'^2
		qui sum `res2' if `samplein'==1 & `sample'==1
		scalar rss_ar1_in=r(mean)
		matrix R0[`ki',5]=rss_ar1_in
			
		qui sum `res2' if `samplein'==0 & `sample'==1
		scalar rss_ar1_ous=r(mean)
		matrix R0[`ki',6]=rss_ar1_ous

		matrix R0[`ki',7]=tss_ar1_in
		matrix R0[`ki',8]=tss_ar1_ous
							
		*************************************************************************************
			
		matrix R0[`ki',9]=sqrt(rss_ous)/sqrt(rss_ar1_ous)
		}

	*********************************************************************************************************************

	matrix N = R0[1...,10]
	matrix n0=I1*N
	scalar n=n0[1,1]
	matrix R = (1/n)*N'*R0
	
	matrix R[1,3] = 1-R[1,1]/R[1,3]
	matrix R[1,4] = 1-R[1,2]/R[1,4]
	matrix R[1,1] = sqrt(R[1,1])
	matrix R[1,2] = sqrt(R[1,2])
	
	matrix R[1,7] = 1-R[1,5]/R[1,7]
	matrix R[1,8] = 1-R[1,6]/R[1,8]
	matrix R[1,5] = sqrt(R[1,5])
	matrix R[1,6] = sqrt(R[1,6])

	matrix R[1,9]=R[1,2]/R[1,6]

	matrix colnames R = RMSE_in RMSE_oos R2_in R2_oos RMSE_Alt_in RMSE_Alt_oos R2_Alt_in R2_Alt_oos Utheil_Alt N
	matrix rownames R = Summary
	matlist R, title("Out of sample evaluation: Ordered partition") lines(rowt)
	return matrix ordered R

}

*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************

if "`evalopt'"!="" {
	matrix R0 = J(1,10,.)

	tempvar samplein
	qui gen `samplein'=`sample'
	qui replace `samplein'=0 if `evalopt'==1
		
	************************************************************
	tempvar y_f res res2 ymt ym_in ym_ous ydev2_in ydev2_ous y_ar1 i_c
	fvset base first `panvar'

	if "`met'"=="" {
		if "`dum'"=="dum" {
			if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
			else qui xtreg `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
		}
		else {
			if "`if'"!="" qui xtreg `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
			else qui xtreg `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
		}
	}
	else if "`dum'"=="dum" {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `if' & `samplein'==1, `options'
		else qui `met' `yvar' `lyvar' `rhsvars' i.`panvar' if `samplein'==1, `options'
	}
	else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
		if "`if'"!="" qui `met' `yvar' `rhsvars' if `if' & `samplein'==1, `fe' `options' lags(`lags')
		else qui `met' `yvar' `rhsvars' if `samplein'==1, `fe' `options' lags(`lags')
	}
	else {
		if "`if'"!="" qui `met' `yvar' `lyvar' `rhsvars' if `if' & `samplein'==1, `fe' `options'
		else qui `met' `yvar' `lyvar' `rhsvars' if `samplein'==1, `fe' `options'
	}
			
	qui predict `y_f'
					
	if "`dum'"=="dum" {
		loc allxvars : colfullnames e(b)
		loc dumi : list allxvars-rhsvars
				
		qui gen `i_c'=-_b[_cons]
		foreach i of loc dumi {
			qui replace `i_c'=`i_c'+_b[`i']*`i'
		}
		qui sum `i_c' if `samplein'==1
		qui replace `y_f'=`y_f'+r(mean) if `samplein'==0
	}
			
	qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
	qui gen `ydev2_in'=(`yvar'-`ym_in')^2
	qui sum `ydev2_in' if `samplein'==1 & `sample'==1
	scalar tss_in=r(mean)
			
	qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
	qui gen `ydev2_ous'=(`yvar'-`ym_ous')^2
	qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
	scalar tss_ous=r(mean)

	qui gen `res'=`yvar'-`y_f'
	qui gen `res2'=`res'^2
	qui sum `res2' if `samplein'==1 & `sample'==1
	scalar rss_in=r(mean)
	matrix R0[1,1]=sqrt(rss_in)
			
	qui sum `res2' if `samplein'==0 & `sample'==1
	scalar rss_ous=r(mean)
	matrix R0[1,2]=sqrt(rss_ous)
			
	matrix R0[1,3]=1-rss_in/tss_in
	matrix R0[1,4]=1-rss_ous/tss_ous

	matrix R0[1,10]=r(N)

	*************************************************************************************
	if "`mcomp'"=="" {
		if "`if'"!="" qui egen `ymt'=mean(`y') if `if' & `samplein'==1, by(`timevar')
		else qui egen `ymt'=mean(`y') if `samplein'==1, by(`timevar')
		qui egen `y_ar1'=mean(`ymt'), by(`timevar')
	}

	else if ("`mcomp'"=="xtabond" | "`mcomp'"=="xtdpdsys") {
		if "`if'"!="" qui `mcomp' `yvar' if `if' & `samplein'==1
		else qui `mcomp' `yvar' if `samplein'==1
		qui predict `y_ar1'
	}
	else {
		if "`if'"!="" qui `mcomp' `yvar' L.`yvar' if `if' & `samplein'==1
		else qui `mcomp' `yvar' L.`yvar' if `samplein'==1
		qui predict `y_ar1'
	}
			
	qui drop `ym_in'
	qui egen `ym_in'=mean(`y') if `samplein'==1 & `sample'==1
	qui replace `ydev2_in'=(`yvar'-`ym_in')^2
	qui sum `ydev2_in' if `samplein'==1 & `sample'==1
	scalar tss_ar1_in=r(mean)
			
	qui drop `ym_ous'
	qui egen `ym_ous'=mean(`y') if `samplein'==0 & `sample'==1
	qui replace `ydev2_ous'=(`yvar'-`ym_ous')^2
	qui sum `ydev2_ous' if `samplein'==0 & `sample'==1
	scalar tss_ar1_ous=r(mean)

	qui replace `res'=`yvar'-`y_ar1'
	qui replace `res2'=`res'^2
	qui sum `res2' if `samplein'==1 & `sample'==1
	scalar rss_ar1_in=r(mean)
	matrix R0[1,5]=sqrt(rss_ar1_in)
			
	qui sum `res2' if `samplein'==0 & `sample'==1
	scalar rss_ar1_ous=r(mean)
	matrix R0[1,6]=sqrt(rss_ar1_ous)

	matrix R0[1,7]=1-rss_ar1_in/tss_ar1_in
	matrix R0[1,8]=1-rss_ar1_ous/tss_ar1_ous
							
	*************************************************************************************
			
	matrix R0[1,9]=sqrt(rss_ous)/sqrt(rss_ar1_ous) 
	

	matrix colnames R0 = RMSE_in RMSE_oos R2_in R2_oos RMSE_Alt_in RMSE_Alt_oos R2_Alt_in R2_Alt_oos Utheil_Alt N
	matrix rownames R0 = Summary
	matlist R0, title("Out of sample evaluation: Specific individuals: `evalopt'") lines(rowt)
	return matrix specific R0
	
	if "`hgraph'"=="hgraph" {
		cap drop _yf
		cap drop _yar1
		qui gen _yf=`y_f'
		qui gen _yar1=`y_ar1'
		label var _yf "pred`_evalopt'"
		if "`mcomp'"=="" label var _yar1 "naive"
		else label var _yar1 "AR1"

		xtline `yvar' _yf _yar1 if `evalopt'==1 & `sample'==1, i(`panvar') t(`timevar') 
		qui drop  _yf _yar1
	}

}

end
