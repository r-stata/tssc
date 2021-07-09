program xtselmod, rclass
version 12.0:

	syntax varlist (fv ts) [if] [in], INDate(string) CDate(string) Ksmpl(integer) [FIXed(varlist ts fv) /*
	*/ Met(string) MComp(string) fe xbu dum opar lags(numlist max=1 integer) EValopt(varname) qui log(string) exc(string) SHEet(string) /*
	*/ ord(string) down WEIghts(numlist min=5 max=5) Hor(integer 0) UPHor CONDitionals(string) /*
	*/ spec1(varlist ts fv) spec2(varlist ts fv) spec3(varlist ts fv) spec4(varlist ts fv) spec5(varlist ts fv) /*
	*/ spec6(varlist ts fv) spec7(varlist ts fv) spec8(varlist ts fv) spec9(varlist ts fv) spec10(varlist ts fv) *]

******************************************************************************************************************************************
if "`exc'"!="" & "`sheet'"=="" {
	di as err "if excel option is activated, a sheet name must be provided"
	exit 0001
}

******************************************************************************************************************************************
tokenize `varlist'
loc y "`1'"
macro shift 1
loc xvars "`*'"

******************************************************************************************************************************************
if "`lags'"=="" & ("`met'"=="xtabond" | "`met'"=="xtdpdsys") loc lags 1
else if "`lags'"=="" {
	foreach i of loc xvars  {
		local m=regexm("`i'","`y'")
		local lags=`lags'+`m'
	}
}
if "`lags'"=="" loc lags=0 
if `lags'==0 loc ly 
else {
	loc ly L.`y'
	local ly=regexr("`ly'","L.D.","LD.")
	forval i=2/`lags'  {
		loc ly `ly' L`i'.`y'
		local ly=regexr("`ly'","L`i'.D.","L`i'D.")
	}
}
loc xvars : list xvars-ly

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
loc imax=r(imax)
loc tmax=r(tmax)

if "`panvar'"=="." {
	loc panvar _id_
	cap qui gen _id_=1
	if "`tunit'"=="0"|"`tunit'"=="." |"`tunit'"=="per : "" 0" qui xtset _id_ `timevar'
	else qui xtset _id_ `timevar', `tunit'
}
if "`panvar'"=="_id_" & "`met'"=="" loc met reg

if "`tform'"=="q" { 
	loc indate2=quarterly("`indate'","YQ")
	loc cdate2=quarterly("`cdate'","YQ")
}
else if "`tform'"=="m" {
	loc indate2=monthly("`indate'","YM")
	loc cdate2=monthly("`cdate'","YM")
}
else {
	loc indate2=real("`indate'")
	loc cdate2=real("`cdate'")
}

loc h=`cdate2'-`indate2'+1
if `hor'>0 {
	loc h = `hor'
}
******************************************************************************************************************************************
******************************************************************************************************************************************
if "`spec1'"=="" {

	tokenize `xvars'
	loc nx = wordcount("`xvars'")

	tuples `xvars', asis conditionals(`conditionals')

	if `ntuples'>_N {
		if `panvar'==_id_ loc add=(`ntuples'-_N)
		else loc add=(`ntuples'-_N)/`imax'
		tsappend, add("`add'")
	}

	foreach x in R2_ad AIC BIC Uth_TS Uth_CS _Total_ {
		qui capture drop `x'
		qui gen `x' = .
	}
	qui capture drop _Model_
	qui gen _Model_ = ""

	if "`log'"!="" {
		capture log close
		log using "`log'.smcl", replace 
	}	

	forval i = 1/`ntuples' {
		tempvar yp eu
		if "`met'"=="" {
			if "`dum'"=="dum" {
				`qui' xtreg `y' `ly' `fixed' `tuple`i'' i.`panvar' `if' `in', `options'
			}
			else {
				`qui' xtreg `y' `ly' `fixed' `tuple`i'' `if' `in', `fe' `options'
			}
		}
		else if "`dum'"=="dum" {
			`qui' `met' `y' `ly' `fixed' `tuple`i'' i.`panvar' `if' `in' ,`options'
		}	
		else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
			`qui' `met' `y' `fixed' `tuple`i'' `if' `in' , `fe' `options' lags(`lags')
		}	
		else {
			`qui' `met' `y' `ly' `fixed' `tuple`i'' `if' `in', `fe' `options' 
		}	
		if "`met'"=="" & "`xbu'"=="xbu" {
			qui predict `eu', u
			qui predict `yp'
			qui replace `yp'=`yp'+`eu'
		}
		else if "`xbu'"=="xbu" {
			qui predictu `eu'
			qui predict `yp'
			qui replace `yp'=`yp'+`eu'
		}
		else {
			qui predict `yp'
		}
		scalar r2_ad = e(r2_a)
		if r2_ad==. {
			qui corr `y' `yp' if e(sample)
			scalar r2_ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(df_m)-2)
			if "`met'"=="xtgls" {
				scalar r2_ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(n_cf)-1)
			}
		}
		qui replace R2_ad = r2_ad in `i'
		
		capture `qui' estat ic
		if _rc!=0 {
			if "`dum'"=="dum" {
				qui reg `y' `ly' `fixed' `tuple`i'' i.`panvar' `if' `in' 
			}
			else {
				qui reg `y' `ly' `fixed' `tuple`i'' `if' `in'
			}
			`qui' estat ic
		}
		qui mata: st_store(`i', "AIC", st_matrix("r(S)")[1,5])
		qui mata: st_store(`i', "BIC", st_matrix("r(S)")[1,6])
		
		`qui' xtoos_t `y' `ly' `fixed' `tuple`i'' `if' `in', ind(`indate') cd(`cdate') m(`met') mc(`mcomp') `fe' `xbu' `dum' `opar' lags(`lags') ev(`evalopt') `options'
		matrix Ut = r(ev_hor)
		if "`uphor'"=="uphor" {
			forval n=1/4 {
				matrix Uth`n' = Ut[1..`h',`n']
			}
			matrix Ih = J(1,`h',1)
			matrix Nh = Ih*Uth4
			scalar nh=Nh[1,1]
			forval n=1/`h' {
				matrix Uth1[`n',1]=Uth1[`n',1]^2
				matrix Uth2[`n',1]=Uth2[`n',1]^2
			}
			matrix Uths1 = (1/nh)*Uth4'*Uth1
			matrix Uths2 = (1/nh)*Uth4'*Uth2
			scalar uthts = sqrt(Uths1[1,1])/sqrt(Uths2[1,1])
		}
		else scalar uthts = Ut[`h',3]
		qui replace Uth_TS = uthts in `i'
		
		if "`panvar'"=="_id_" | "`ts'"=="ts" qui replace Uth_CS = 0 in `i'
		else {
			`qui' xtoos_i `y' `ly' `fixed' `tuple`i'' `if' `in', k(`ksmpl') r(0) o(`ksmpl') m(`met') mc(`mcomp') `fe' `dum' lags(`lags') ev(`evalopt') `options'
			if "`evalopt'"=="" qui mata: st_store(`i', "Uth_CS", st_matrix("r(ordered)")[1,9])
			else qui mata: st_store(`i', "Uth_CS", st_matrix("r(specific)")[1,9])
		}
		qui replace _Model_ = "`tuple`i''" in `i'
	}

	capture drop R2n
	capture drop R2_ad_r
	capture gen R2n=-R2_ad
	capture gen R2_ad_r = .
	sort R2n
	forval i=1/`ntuples' {
		capture qui replace R2_ad_r=`i' in `i'		
	}

	foreach x of varlist AIC BIC Uth_TS Uth_CS {
		capture drop `x'_r
		capture gen `x'_r = .
		sort `x'
		forval i=1/`ntuples' {
			capture qui replace `x'_r=`i' in `i'		
		}
	}
	if "`panvar'"=="_id_" | "`ts'"=="ts" qui replace Uth_CS_r=0 in 1/`ntuples'

	if "`weights'"!="" {
		tokenize `weights'
		qui replace _Total_=`1'*R2_ad_r+`2'*AIC_r+`3'*BIC_r+`4'*Uth_TS_r+`5'*Uth_CS_r
	}
	else qui replace _Total_=R2_ad_r+AIC_r+BIC_r+Uth_TS_r+Uth_CS_r

	if "`ord'"!="" & "`down'"=="" sort `ord'
	else if "`down'"=="down" {
		tempvar `ord'n
		qui gen ``ord'n'=-`ord'
		sort ``ord'n'
	}
	else sort _Total_

	label var _Total_ Total
	label var _Model_ Model

	l _Model_ R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ in 1/`ntuples'

	if "`exc'"!="" export excel _Model_ R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ in 1/`ntuples' using "`exc'.xlsx", firstrow(variables) sheet("`sheet'") sheetmodify

	if "`log'"!="" log close

	sort `panvar' `timevar'

	qui drop _Model_ R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ R2n
	
	qui drop if `timevar'>`tmax'

	if "`panvar'"=="_id_" {
		qui drop _id_	
		qui tsset `timevar'
	}
}
*************************************************************************************************************************************

else {

	loc s=0
	forval i=1/10 {
		if "`spec`i''"!="" loc s = `s'+1
	}

	foreach x in R2_ad AIC BIC Uth_TS Uth_CS _Total_ {
		qui capture drop `x'
		qui gen `x' = .
	}
	qui cap drop _Model_
	qui gen _Model_ = ""

	if "`log'"!="" {
		capture log close
		log using "`log'.smcl", replace 
	}	

	forval i = 1/`s' {
		tempvar yp eu
		if "`met'"=="" {
			if "`dum'"=="dum" {
				`qui' xtreg `y' `ly' `fixed' `spec`i'' i.`panvar' `if' `in', `options'
			}
			else {
				`qui' xtreg `y' `ly' `fixed' `spec`i'' `if' `in', `fe' `options'
			}
		}
		else if "`dum'"=="dum" {
			`qui' `met' `y' `ly' `fixed' `spec`i'' i.`panvar' `if' `in' ,`options'
		}	
		else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
			`qui' `met' `y' `fixed' `spec`i'' `if' `in' , `fe' `options' lags(`lags')
		}	
		else {
			`qui' `met' `y' `ly' `fixed' `spec`i'' `if' `in', `fe' `options' 
		}	
		if "`met'"=="" & "`xbu'"=="xbu" {
			qui predict `eu', u
			qui predict `yp'
			qui replace `yp'=`yp'+`eu'
		}
		else if "`xbu'"=="xbu" {
			qui predictu `eu'
			qui predict `yp'
			qui replace `yp'=`yp'+`eu'
		}
		else {
			qui predict `yp'
		}
		scalar r2_ad = e(r2_a)
		if r2_ad==. {
			qui corr `y' `yp' if e(sample)
			scalar r2_ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(df_m)-2)
			if "`met'"=="xtgls" {
				scalar r2_ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(n_cf)-1)
			}
		}
		qui replace R2_ad = r2_ad in `i'
		
		capture `qui' estat ic
		if _rc!=0 {
			if "`dum'"=="dum" {
				qui reg `y' `ly' `fixed' `spec`i'' i.`panvar' `if' `in' 
			}
			else {
				qui reg `y' `ly' `fixed' `spec`i'' `if' `in'
			}
			`qui' estat ic
		}
		qui mata: st_store(`i', "AIC", st_matrix("r(S)")[1,5])
		qui mata: st_store(`i', "BIC", st_matrix("r(S)")[1,6])
		
		`qui' xtoos_t `y' `ly' `fixed' `spec`i'' `if' `in', ind(`indate') cd(`cdate') m(`met') mc(`mcomp') `fe' `xbu' `dum' `opar' lags(`lags') ev(`evalopt') `options'
		matrix Ut = r(ev_hor)
		if "`uphor'"=="uphor" {
			forval n=1/4 {
				matrix Uth`n' = Ut[1..`h',`n']
			}
			matrix Ih = J(1,`h',1)
			matrix Nh = Ih*Uth4
			scalar nh=Nh[1,1]
			forval n=1/`h' {
				matrix Uth1[`n',1]=Uth1[`n',1]^2
				matrix Uth2[`n',1]=Uth2[`n',1]^2
			}
			matrix Uths1 = (1/nh)*Uth4'*Uth1
			matrix Uths2 = (1/nh)*Uth4'*Uth2
			scalar uthts = sqrt(Uths1[1,1])/sqrt(Uths2[1,1])
		}
		else scalar uthts = Ut[`h',3]
		qui replace Uth_TS = uthts in `i'
		
		if "`panvar'"=="_id_" | "`ts'"=="ts" qui replace Uth_CS = 0 in `i'
		else {
			`qui' xtoos_i `y' `ly' `fixed' `spec`i'' `if' `in', k(`ksmpl') r(0) o(`ksmpl') m(`met') mc(`mcomp') `fe' `dum' lags(`lags') ev(`evalopt') `options'
			if "`evalopt'"=="" qui mata: st_store(`i', "Uth_CS", st_matrix("r(ordered)")[1,9])
			else qui mata: st_store(`i', "Uth_CS", st_matrix("r(specific)")[1,9])
		}
		qui replace _Model_ = "Specification `i'" in `i'
	}

	capture drop R2n
	capture drop R2_ad_r
	capture gen R2n=-R2_ad
	capture gen R2_ad_r = .
	sort R2n
	forval i=1/`s' {
		capture qui replace R2_ad_r=`i' in `i'		
	}

	foreach x of varlist AIC BIC Uth_TS Uth_CS {
		capture drop `x'_r
		capture gen `x'_r = .
		sort `x'
		forval i=1/`s' {
			capture qui replace `x'_r=`i' in `i'		
		}
	}
	if "`panvar'"=="_id_" | "`ts'"=="ts" qui replace Uth_CS_r=0 in 1/`s'

	if "`weights'"!="" {
		tokenize `weights'
		qui replace _Total_=`1'*R2_ad_r+`2'*AIC_r+`3'*BIC_r+`4'*Uth_TS_r+`5'*Uth_CS_r
	}
	else qui replace _Total_=R2_ad_r+AIC_r+BIC_r+Uth_TS_r+Uth_CS_r

	if "`ord'"!="" & "`down'"=="" sort `ord'
	else if "`down'"=="down" {
		tempvar `ord'n
		qui gen ``ord'n'=-`ord'
		sort ``ord'n'
	}
	else sort _Total_

	label var _Total_ Total
	label var _Model_ Model

	l _Model_ R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ in 1/`s'

	if "`exc'"!="" export excel Model R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ in 1/`s' using "`exc'.xlsx", firstrow(variables) sheet("`sheet'") sheetmodify

	if "`log'"!="" log close

	sort `panvar' `timevar'

	qui drop _Model_ R2_ad AIC BIC Uth_TS Uth_CS R2_ad_r AIC_r BIC_r Uth_TS_r Uth_CS_r _Total_ R2n
	
	qui drop if `timevar'>`tmax'
	
	if "`panvar'"=="_id_" {
		qui drop _id_
		qui tsset `timevar'
	}

}
	
end
