program xtselvar, rclass
version 12.0:

	syntax varlist (fv ts) [if] [in], INDate(string) CDate(string) Ksmpl(integer) [FIXed(varlist fv ts) /* 
	*/ Met(string) MComp(string) fe xbu dum opar lags(numlist max=1 integer) EValopt(varname) qui log(string) exc(string) SHEet(string) /*
	*/ ord(string) down Hor(integer 0) UPHor WEIghts(numlist min=5 max=5) GRoups(integer 0) ncomp(integer 1) /*
	*/ pca1(varlist fv ts) pca2(varlist fv ts) pca3(varlist fv ts) pca4(varlist fv ts) pca5(varlist fv ts) /*
	*/ pca6(varlist fv ts) pca7(varlist fv ts) pca8(varlist fv ts) pca9(varlist fv ts) pca10(varlist fv ts) *]

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

if "`panvar'"=="." {
	loc panvar _id_
	capture qui gen _id_=1
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
if `groups'>0 {
	cap drop _*comp
	forval i=1/`groups' {
		qui pca `pca`i''
		if `ncomp'>1 {
			forval j=1/`ncomp' {
				loc comps`i' `comps`i'' _`i'_`j'comp
			}
		qui predict "`comps`i''"
		loc comps `comps' `comps`i''
		}
		else {
			qui predict _`i'_1comp
			loc comps `comps' _`i'_1comp
		}
	}
}
******************************************************************************************************************************************

tokenize `xvars'
loc nx = wordcount("`xvars'")

matrix RS1 = J(`nx',13,.)

if "`log'"!="" {
	capture log close
	log using "`log'.smcl", replace 
}	

forvalues x=1/`nx' {
	tempvar yp eu
	if "`met'"=="" {
		if "`dum'"=="dum" {
			`qui' xtreg `y' `ly' `fixed' `comps' ``x'' i.`panvar' `if' `in', `options'
		}
		else {
			`qui' xtreg `y' `ly' `fixed' `comps' ``x'' `if' `in', `fe' `options'
		}
	}
	else if "`dum'"=="dum" {
		`qui' `met' `y' `ly' `fixed' `comps' ``x'' i.`panvar' `if' `in' ,`options'
	}	
	else if ("`met'"=="xtabond" | "`met'"=="xtdpdsys") & "`lags'"!=""  {
		`qui' `met' `y' `fixed' `comps' ``x'' `if' `in' , `fe' `options' lags(`lags')
	}	
	else {
		`qui' `met' `y' `ly' `fixed' `comps' ``x'' `if' `in', `fe' `options' 
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
	scalar R2ad = e(r2_a)
	if R2ad==. {
		qui corr `y' `yp' if e(sample)
		scalar R2ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(df_m)-2)
		if "`met'"=="xtgls" {
			scalar R2ad=1-(1-r(rho)^2)*(e(N)-1)/(e(N)-e(n_cf)-1)
		}
	}
	matrix RS1[`x',1] = _b[``x'']
	matrix RS1[`x',2] = _b[``x'']/_se[``x'']
	matrix RS1[`x',3] = R2ad
	
	capture `qui' estat ic
	if _rc!=0 {
		if "`dum'"=="dum" {
			qui reg `y' `ly' `fixed' `comps' ``x'' i.`panvar' `if' `in' 
		}
		else {
			qui reg `y' `ly' `fixed' `comps' ``x'' `if' `in'
		}
		`qui' estat ic
	}
	matrix AIC = r(S)
	matrix RS1[`x',4] = AIC[1,5]
	matrix RS1[`x',5] = AIC[1,6]
	
	`qui' xtoos_t `y' `ly' `fixed' `comps' ``x'' `if' `in', ind(`indate') cd(`cdate') m(`met') mc(`mcomp') `fe' `xbu' `dum' `opar' lags(`lags') ev(`evalopt') `options'
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
		matrix RS1[`x',6] = sqrt(Uths1[1,1])/sqrt(Uths2[1,1])
	}
	else matrix RS1[`x',6] = Ut[`h',3]
	
	if "`panvar'"=="_id_" | "`ts'"=="ts" matrix RS1[`x',7] = 0
	else {
		`qui' xtoos_i `y' `ly' `fixed' `comps' ``x'' `if' `in', k(`ksmpl') r(0) o(`ksmpl') m(`met') mc(`mcomp') `fe' `dum' lags(`lags') ev(`evalopt') `options'
		if "`evalopt'"=="" matrix Ui = r(ordered)
		else matrix Ui = r(specific)
		matrix RS1[`x',7] = Ui[1,9]
	}
	
}

cap drop _*comp

matrix colnames RS1 = coef tstat R2_ad AIC BIC Uth_TS Uth_CS R2_r AIC_r BIC_r Uth_TS_r Uth_CS_r Total
matrix rownames RS1 = `xvars'

matsort RS1 3 down
forval i=1/`nx'{
	matrix RS1[`i',8] = `i'
}
forval c=4/7 {
	loc n=`c'+5
	matsort RS1 `c' "up"
	forval i=1/`nx'{
		matrix RS1[`i',`n'] = `i'
	}
}
forval i=1/`nx'{
	if "`panvar'"=="_id_" | "`ts'"=="ts" matrix RS1[`i',12] = 0
	if "`weights'"!="" {
		tokenize `weights'
		matrix RS1[`i',13] = `1'*RS1[`i',8]+`2'*RS1[`i',9]+`3'*RS1[`i',10]+`4'*RS1[`i',11]+`5'*RS1[`i',12]
	}
	else matrix RS1[`i',13] = RS1[`i',8]+RS1[`i',9]+RS1[`i',10]+RS1[`i',11]+RS1[`i',12]
}

if "`ord'"!="" {
	local crit coef tstat R2_ad AIC BIC Uth_TS Uth_CS R2_r AIC_r BIC_r Uth_TS_r Uth_CS_r Total

	local num = 0
	forval j = 1/`=wordcount("`crit'")' {
	   if word("`crit'", `j') == "`ord'" local num = `j'
	}
	if "`down'"=="" matsort RS1 `num' "up"
	else matsort RS1 `num' "down"
}
else matsort RS1 13 "up"
matlist RS1

if "`log'"!="" log close

if "`exc'"!="" {
	qui putexcel set "`exc'.xlsx", sheet("`sheet'") modify
	if (c(stata_version) <= 15) qui putexcel A1=matrix(RS1, names)
	else qui putexcel A1=matrix(RS1), names
}
return matrix summary RS1

if "`panvar'"=="_id_" {
	qui drop _id_
	qui tsset `timevar'
}

end
