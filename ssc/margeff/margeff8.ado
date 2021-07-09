capture program drop margeff8
program define margeff8 
*! Marginal effects for categorical dependent variable models
*! This version:  10 February 2006 (3rd update for Stata Journal submission)
*! Author:        Tamas Bartus    (Corvinus University, Budapest)
	version 8


*******************************************************************************
*
* [1] SYNTAX CHECK
*
*******************************************************************************	

	if "`e(cmd)'"=="" 		exit 301

	* Determining what to do
	* if no arguments, replay results, provided the -replace- option was used
	if `"`0'"'=="," | "`0'"=="" {
		if "`e(cmd)'"=="margeff"	local doit = 0
		else						local doit = 1
	}
	* if arguments found, estimate if replay subcmd not found
	else {
		gettoken cmd 0 : 0 , parse(" ,")
		local l = length("`cmd'")
		if substr("replay",1,`l')==`"`cmd'"' {
			local doit = 0
		}
		else if substr("compute",1,`l')=="`cmd'" {
			local doit = 1
		}
		else {
			local 0 `cmd' `0'
			local doit = 1
		}
	}
	if `doit'==1  {
		if `e(df_m)'==0  {
			di as error "There are no independent variables; running -margeff- makes no sense"
			exit
		}
		if "`e(cmd)'"=="margeff" 	exit 301
		syntax  [if] [in] [ , Eform Model(string) *  ]
		if "`eform'"!="" {
			local length : word count `e(depvar)'
			if `length'>1 {
				di as error "The eform option can only be used after single-equation commands"
				exit
			}
		}
		if "`model'"=="" local model = e(cmd)
		sret clear
		SetSMacros `model' `eform' 
		if "`s(type)'"=="0" {
			di as error "-margeff- does not work with `s(error)'`model'; use -mfx- instead"
			exit
		}
		preserve
		Estimate   `0' 
		restore
		sret clear
		Replay new `0' 
	}
	else Replay existing `0'
end


program define SetSMacros , sclass
	version 6
	sret clear
	sret local model "`1'"
	sret local ncons 1
	if "`2'"!="" {
		sret local type 9
		sret local neq  1
		sret local nout 1
		sret local nap  0
		exit
	}
	else if "`1'"=="logit"    | "`1'"=="logistic" | "`1'"=="probit"  | "`1'"=="cloglog" | /*
		*/  "`1'"=="poisson" {
		sret local nout 1
		sret local type 1
		sret local neq  1
		sret local nap  0
		exit
	}
	else if "`1'"=="xtprobit" | "`1'"=="nbreg" | "`1'"=="heckprob"  {
		sret local nout 1
		sret local type 1
		sret local neq  1
		sret local nap  1
		exit
	}
 	else if "`1'"=="oprobit"  | "`1'"=="ologit" {
		qui tab `e(depvar)'	if e(sample)
		local ncons = e(k_cat)-1
		local nout = r(r)
		sret local ncons `ncons'
		sret local neq  1
		sret local nout `nout'
		sret local type 2
		sret local nap `ncons'
		exit
	}
	else if "`1'"=="mlogit" | "`1'"=="gologit"  {
		qui tab `e(depvar)' if e(sample)
		local neq = r(r)-1
		local nout = r(r)
		sret local ncons 1
		sret local neq  `neq'
		sret local nout `nout'
		sret local type 2
		sret local nap  0
		exit
	}
	else if  "`1'"=="biprobit"  | "`1'"=="zip"  | "`1'"=="zinb"       {
		local neq = 2
		local type = 3
		local nout = 1
		if "`1'"=="biprobit" {
			if substr(e(title),1,1)=="B" {
				//local type = 2
				local nout = 4
			}
			else {
				sret local type 0
				sret local error "seemingly unrelated verson of "
				exit
			}
		}

		sret local neq `neq'
		sret local nout `nout'
		sret local type `type'
		if "`1'"=="zip" {
			sret local nap 0
		}
		else sret local nap 1
		exit
	}
	else sret local type 0
end



*******************************************************************************
*
* [2] ESTIMATION
*
*******************************************************************************	


program define Estimate , rclass
	version 8
	syntax [if] [in] ///
		[ , at(string) Count Dummies(string) Eform Model(string) NODiscrete NOOFFset Percent Replace OUTcome(numlist min=1 integer) ]

	if "`at'"!="" {
		capture _at "`at'"
		if _rc!=0 {
			di as error "Invalid at() option"
			exit
		}
	}

	if "`outcome'"!="" {
		local nout : word count `outcome'
		local max  : word `nout' of `outcome'
		if `max'>`s(nout)' 	error 125
	}
	else {
		local nout    = `s(nout)'
		numlist "1/`nout'"
		local outcome = r(numlist)
	}
	if "`nodiscrete'"!=""	local discrete off
	else					local discrete on
	if "`count'"!=""		local count on
	else					local count off


*=======================================
*
*  [2/1]: PROCESSING ESTIMATION RESULTS
*
*=======================================

	tempname b vce coef pder partder me bm Vm
	tempvar touse

	local cmd    = e(cmd)
	* local numobs = e(N)

	qui gen byte `touse' = e(sample) `if' `in'
	qui count if `touse'==1
	local numobs = r(N)

	ProcEst`s(type)' `s(model)'

	mat `b' = r(b)
 	mat `coef' = r(coef)
	mat `vce'  = r(v)
	local Vdim = colsof(`vce')

	if "`dummies'"!="" {
		DumList `b' `dummies'
	}
	if "`s(error)'"!="" {
		di as error "`s(error)'"
		error 198
	}

 
*=======================================
*
*  [2/1]: DATA MODIFICATION: CONSTANTS AND AT LIST
*
*=======================================

	* ADDING CONSTANTS / CUT-OFFS TO DATA
	local i = 1
	while `i'<=`s(ncons)' {
		tempvar c`i'
		qui gen byte `c`i'' = 1
		local clist `clist' `c`i''
		local i = `i'+1
	}

	PassToS	`clist'

	VarTypes `touse' `count'

	AtOption  `at'

	if "`at'"!="" {
		_at "`at'" "if `touse'==1"
		tempname atmat
		mat `atmat' = r(at)
		foreach var in `s(Tlist)' {
			local pos = colnumb(`atmat',"`var'")
			local value = `atmat'[1,`pos']
			qui replace `var' = `value' if `touse'==1
		}
	}

	 
*=======================================
*
* [2/3]:	PREDICTING INDEX  -  DEFINING CDF and PDF
*
*=======================================

	if "`s(model)'"=="mlogit" {
		local denom 1
	}
   	local i = 1
	while `i'<=`s(neq)' {
		if `s(neq)'>1 {
			local Popt "eq(#`i')"
		}
		tempvar xb`i'
		matrix score `xb`i'' = `b' if `touse' , `Popt'
		if `"`e(offset)'"'!="" {
			if "`nooffset'"=="" {
				qui replace `xb`i'' = `xb`i''+ `e(offset)'
			}
		}
		Mindex `i' `xb`i''
		if "`s(model)'"=="mlogit" {
			local denom "`denom'+exp(`xb`i'')"
		}
		local i = `i'+1
	}
	if "`s(model)'"=="mlogit" {
		local mopt `denom'
	}

	if `s(type)'==9 {
		local exe eform
	}
	else local exe `s(model)'
	
	GenFx_`exe' `s(depvar)' `mopt'

	if "`s(error)'"!="" {
		di as error "-margeff- cannot estimate the requested marginal effects"
		di as error "The problem: `s(error)'"
		exit
	}


*=======================================
*
*  [2/4]: DOING THE CALCULATIONS
*
*=======================================

	local dim  = `s(Ntreat)'*`nout'
	local col  = 0

	local treatlist `s(Treat)'
	local Dvars `s(Dummyvars)'
	local Cvars `s(Countvars)'
	
	local j = 1
	while `j'<=`nout' {
		local out : word `j' of `outcome'
		local eqname : word `out' of `s(eqname)'

		* Loop for variables
		
		local i = 1
		while `i'<=`s(Ntreat)' { 
			local col = `col'+1
			local treat : word `i' of `s(Tlist)'

			local vtype Contin
			if "`discrete'"=="on" {
				local temp : subinstr local Dvars "`treat'" "" ,  count(local change)
				if `change'==1	local vtype Dummy
			}
			if "`count'"=="on" & "`vtype'"=="Contin" {
				local temp : subinstr local Cvars "`treat'" "" ,  count(local change)
				if `change'==1	local vtype Count
			}
			local delta = 1
			if "`vtype'"=="Contin" {
				qui sum `treat' , detail
				if r(p95)==r(p5) {
					local delta = 10^(-6)*(r(max)-r(min))	
				}
				else local delta = 10^(-6)*(r(p95)-r(p5))
			}

			qui GetMargEff_`vtype' `treat' `touse' `numobs' `i' `out' `coef' `Vdim' `delta' `atmat' 

			mat `me'   = r(me)
			mat `pder' = r(pder)
			mat colnames `me'   = `treat'
			mat colnames `pder' = `treat' _cons
			mat rownames `pder' = `treat'
			if `s(nout)'>1 {
				mat coleq `me'   =  `eqname'
				mat coleq `pder' =  `eqname'
				mat roweq `pder' =  `eqname'
			}
			capture mat list `bm'
			if _rc==0 {
				mat `bm' = `bm' , `me'
				mat `partder' = `partder' \ `pder'
			}
			else {
				mat `bm' = `me'
				mat `partder' = `pder'
			}
			local i = `i'+1
		}
		* End of loop for variables

		local j = `j'+1
	}

	mat `Vm' = `partder'*`vce'
	mat `Vm' = `Vm'*`partder''

	return mat   margeff_b `bm'
	return mat   margeff_V `Vm'

	return local margeff_at			`s(at)'
	return local margeff_method		`s(method)'
	return local margeff_discrete	`discrete'
	return local margeff_count		`count'
	return local margeff_cvars		`s(Countvars)'
	return local margeff_dvars		`s(Dummyvars)'
	return local margeff_def		`s(medef)'
	return local margeff_cmd		`cmd'
	return local esample			`touse'

	return scalar margeff_N = `numobs'

end



*******************************************************************************
*
* [3] COLLECTING AND DISPLAYING RESULTS
*
*******************************************************************************	


program define Replay , eclass
	version 8
	gettoken first 0 : 0
	syntax [if] [in] [ , Percent Replace  * ]
	tempname at b V bpost Vpost tab
	tempvar touse

	if "`first'"=="new" 		local Class r
	else						local Class e
	if "`e(cmd)'"=="margeff"	local Prefix
	else						local Prefix margeff_

	mat `b'			= `Class'(`Prefix'b)
	mat `V'			= `Class'(`Prefix'V)
 	local depvar	= e(depvar)
  	local cmd		= `Class'(`Prefix'cmd)
	qui gen `touse' = e(sample)
	
	foreach word in cvars dvars  count discrete at method def {
		local `word' = `Class'(margeff_`word')
	}

	* Display form (avoiding double percentages)
	if "`first'"=="existing" {
		if "`percent'"!="" & `"`e(margeff_display)'"'=="percent" {
			local percent
		}
	}
	if "`percent'"!="" {
		mat `b' = 10^2 * `b'
		mat `V' = 10^4 * `V'
		local dispfrom percent
	}
	else	local dispform asis
	mat `bpost' 	= `b'
	mat `Vpost' 	= `V'
 

	tempname ehold 
	_est hold `ehold' 

	if "`method'"=="average" 	local title Average marginal effects  
	else 						local title Marginal effects at `method's
	di
	di as text "`title' on " as res "`def'" as text " after " as res "`cmd'"
	if "`method'"!="average" & "`at'"!="."	{
		di as text "Variables set to specific values:  " _col(40) as res "`at'"
	}
	if "`count'"=="on" 			di as text "Variables treated as counts: " _col(40) as res "`cvars'"	
	if "`discrete'"=="off"		di as text "Dummies treated as continuous vars: " _col(40) as res "`dvars'"	
	di

	ereturn post `bpost' `Vpost' , depname("`depvar'")
	ereturn disp
	_est unhold `ehold'
	
	if  "`replace'"!="" {
		* Saves scalars
		local scalars : e(scalars)
		foreach el in `scalars' {
			tempname s`el'
			scalar `s`el'' = e(`el')
		}
		* Posting results
		mat `bpost' = `b'
		mat `Vpost' = `V'
		ereturn post `bpost' `Vpost' , esample(`touse')
		ereturn local cmd      margeff
		ereturn local depvar   `depvar'
		* Restores scalars
		foreach el in `scalars' {
			eret scalar `el' = `s`el''
		}
	}

	* Returns results
	ereturn mat   margeff_V	=		`V'
	ereturn mat   margeff_b	=		`b'
	foreach word in   cvars dvars  count discrete at method def {
		ereturn local margeff_`word'  ``word''
	}
	ereturn local margeff_display	`dispform'
	ereturn local margeff_cmd		`cmd'
end


*============================================================
*
* [4] MARGINAL EFFECTS + STANDARD ERRORS
*
*============================================================




program define GetMargEff_Contin , rclass
	version 8
	args treat touse numobs id out mat Vdim	delta  
	tempvar hat0 hat1
	tempname row pder
	mat `pder' = J(1,`Vdim',0)

	nobreak {

		gen double `hat0' = 0
		local dmin = 10^6
		
	* CALCULATING THE CDF + DENSITIES
	* CORRECTION FOR SMALL CHANGE TERM
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			if `beta'<`dmin' & `beta'!=0  {
				local dmin = `beta'
			}
			tempvar save`q'	phi0`q'
			gen double `save`q'' = `s(xb`q')'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi0`q'' = 0
			}
			else {
				replace `hat0' = `hat0' + `s(dens`out'`q')'*`beta'	
				gen double `phi0`q'' = `s(dens`out'`q')' `s(`treat')'
			}
		}
		local delta = `delta'/abs(`dmin')
	*  SETTING DUMMIES TO 1 / INCREASING VALUE OF CONTINUOUS VARS
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			replace `s(xb`q')' = `s(xb`q')'+`beta'*`delta'
		}
	* CALCULATING DENSITIES
		forval q = 1 / `s(neq)' {
			tempvar phi1`q'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi1`q'' = 0
			}
			else gen double `phi1`q'' = `s(dens`out'`q')' `s(`treat')'
		}
	* CALCULATING STANDARD ERRORS
	* RESTORING INDEX
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			tempvar part`q'
			gen double `part`q'' = (`phi1`q''-`phi0`q'')/`delta'
			if "``s(`treat')'"!="" {
				replace `part`q'' = 0 if `part`q''==. & `touse'==1
			}
			replace `s(xb`q')' = `save`q''
		* The i-th row of the part. deriv. matrix
			su `phi1`q'' 
			local add = r(mean)
			tempname row`q'
			mat vecaccum `row`q'' = `part`q'' `s(rhs)'  if `touse' , noconstant
			mat list `row`q''
			mat `row`q'' = `row`q'' / `numobs'
			mat `row`q''[1,`id'] = `row`q''[1,`id'] + `add'
			if `q'==1 {
				mat `pder' = `row`q''
			}
			else mat `pder' = `pder' , `row`q''
		}
		
	} /* end of nobreak */

	* MARGINAL EFFECT / RETURNING RESULTS
	sum `hat0' `s(`treat')' 
	return scalar me = r(mean)
	return scalar sd = r(sd)
	return scalar min = r(min)
	return scalar max = r(max)
	return matrix pder `pder'
end


program define GetMargEff_Dummy , rclass
	version 8
	args treat touse numobs id out mat Vdim	delta atmat
	tempvar hat0 hat1
	tempname row pder
	mat `pder' = J(1,`Vdim',0)

	nobreak {

	* BACKUP FOR LINEAR PREDICTION
	* SETTING DUMMIES TO ZERO
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			tempvar save`q'
			gen double `save`q'' = `s(xb`q')'
			if "`s(method)'"=="average"		replace `s(xb`q')' = `s(xb`q')'-`beta'*(`treat'==1)
			else {
				local pos = colnumb(`atmat',"`treat'")
				local value = `atmat'[1,`pos']
				replace `s(xb`q')' = `s(xb`q')'-`beta'*`value'
			}
		}
	* CALCULATING THE CDF + DENSITIES
		gen double `hat0' = `s(cumu`out'1)'
		forval q = 1 / `s(neq)' {
			tempvar phi0`q'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi0`q'' = 0
			}
			else gen double `phi0`q'' = `s(dens`out'`q')' `s(`treat')'
		}
	*  SETTING DUMMIES TO 1
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			replace `s(xb`q')' = `s(xb`q')'+`beta'
		}
	* CALCULATING THE CDF + DENSITIES
		gen double `hat1' = `s(cumu`out'1)'
		forval q = 1 / `s(neq)' {
			tempvar phi1`q'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi1`q'' = 0
			}
			else gen double `phi1`q'' = `s(dens`out'`q')' `s(`treat')'
		}
	* CALCULATING STANDARD ERRORS
	* RESTORING INDEX
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			tempvar part`q'
			gen double `part`q'' = (`phi1`q''-`phi0`q'')
			if "``s(`treat')'"!="" {
				replace `part`q'' = 0 if `part`q''==. & `touse'==1
			}
			replace `s(xb`q')' = `save`q''
		* The i-th row of the part. deriv. matrix
			su `phi1`q'' 
			local add = r(mean)
			tempname row`q'
			mat vecaccum `row`q'' = `part`q'' `s(rhs)'  if `touse' , noconstant
			mat list `row`q''
			mat `row`q'' = `row`q'' / `numobs'
			mat `row`q''[1,`id'] = `add'
			if `q'==1 {
				mat `pder' = `row`q''
			}
			else mat `pder' = `pder' , `row`q''
		}
		
	} /* end of nobreak */

	* MARGINAL EFFECT / RETURNING RESULTS
	replace `hat1' = (`hat1'-`hat0')
	sum `hat1' `s(`treat')' `weight'
	return scalar me = r(mean)
	return scalar sd = r(sd)
	return scalar min = r(min)
	return scalar max = r(max)
	return matrix pder `pder'
end


program define GetMargEff_Count , rclass
	version 8
	args treat touse numobs id out mat Vdim	delta atmat 
	tempvar hat0 hat1
	tempname row pder
	mat `pder' = J(1,`Vdim',0)

	nobreak {

	* BACKUP FOR LINEAR PREDICTION
		forval q = 1 / `s(neq)' {
			tempvar save`q'
			gen double `save`q'' = `s(xb`q')'
		}
	* CALCULATING THE CDF + DENSITIES
		gen double `hat0' = `s(cumu`out'1)'
		forval q = 1 / `s(neq)' {
			tempvar phi0`q'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi0`q'' = 0
			}
			else gen double `phi0`q'' = `s(dens`out'`q')' `s(`treat')'
		}
	*  INCREASING VALUE OF COUNT VARS
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			replace `s(xb`q')' = `s(xb`q')'+`beta'*`delta'
		}
	* CALCULATING THE CDF + DENSITIES
		gen double `hat1' = `s(cumu`out'1)'
		forval q = 1 / `s(neq)' {
			tempvar phi1`q'
			if "`s(dens`out'`q')'"=="" {
				gen byte `phi1`q'' = 0
			}
			else gen double `phi1`q'' = `s(dens`out'`q')' `s(`treat')'
		}
	* CALCULATING STANDARD ERRORS
	* RESTORING INDEX
		forval q = 1 / `s(neq)' {
			local beta = `mat'[`id',`q']
			tempvar part`q'
			gen double `part`q'' = (`phi1`q''-`phi0`q'')/(`delta')
			if "``s(`treat')'"!="" {
				replace `part`q'' = 0 if `part`q''==. & `touse'==1
			}
			replace `s(xb`q')' = `save`q''
		* The i-th row of the part. deriv. matrix
			su `phi1`q'' `w'
			local add = r(mean)
			tempname row`q'
			mat vecaccum `row`q'' = `part`q'' `s(rhs)'  if `touse' , noconstant
			mat list `row`q''
			mat `row`q'' = `row`q'' / `numobs'
			mat `row`q''[1,`id'] = `row`q''[1,`id'] + `add'
			if `q'==1 {
				mat `pder' = `row`q''
			}
			else mat `pder' = `pder' , `row`q''
		}
		
	} /* end of nobreak */

	* MARGINAL EFFECT / RETURNING RESULTS
	replace `hat1' = (`hat1'-`hat0')/(`delta')
	sum `hat1' `s(`treat')' 
	return scalar me = r(mean)
	return scalar sd = r(sd)
	return scalar min = r(min)
	return scalar max = r(max)
	return matrix pder `pder'
end


*============================================================
*
* [5] PROGRAMS PREDICTING CDF, DENSITY, AND DERIVATIVES
*
*============================================================


program define GenFx_eform , sclass
	EqLabel `1'
	sret local medef E(exp[xb])
	sret local depname `s(depvar)'
	sret local eqname  `1'
	sret local cumu11  exp(`s(xb1)')
	sret local dens11  exp(`s(xb1)')
end


program define GenFx_probit , sclass
	version 8
	args depvar rho
	if "`rho'"=="" {
		local rho 1
	}
	sret local cumu11 "normprob(`rho'*`s(xb1)')"
	sret local dens11 " `rho'*normd(`rho'*`s(xb1)') "
	EqLabel `depvar'
	sret local medef "Prob(`depvar'==`s(cat)')"
	sret local depname `depvar'
	sret local eqname `depvar'
end


program define GenFx_xtprobit , sclass
	if e(predict)=="xtbin_p" {
		local rho = sqrt(1-`e(rho)')
		GenFx_probit `*' `rho'
	}
	else {
		sret local error "the population-averaged version of xtprobit not supported"
		exit
	}
end


program define GenFx_heckprob , sclass
	version 8
	local depvar : word 1 of `0'
	GenFx_probit `depvar'
end


program define GenFx_logit , sclass
	version 8
	args depvar 
	local cumu11 "1/(1+exp(-`s(xb1)'))"
	sret local cumu11 `cumu11'
	sret local dens11 "(`cumu11')*(1-`cumu11')"
	EqLabel `depvar'
	sret local medef Prob(`depvar'==`s(cat)')
	sret local depname `depvar'
	sret local eqname `depvar'
end


program define GenFx_logistic
	GenFx_logit `*'
end


program define GenFx_cloglog , sclass
	local depvar "`1'"
	local cumu11 " 1-exp(-exp(`s(xb1)')) "
	local dens11 " -(1-`cumu11')*exp(`s(xb1)') "
	sret local cumu11 `cumu11'
	sret local dens11 `dens11'
	EqLabel `s(depvar)'
	sret local medef "Prob(`s(depvar)'==`s(cat)')"
	sret local depname `depvar'
	sret local eqname `depvar'
end


program define GenFx_oprobit
	version 8
	tempname b 
	mat `b' = e(b)
	local check = colnumb(`b',"_cut1")
	if `check'!=.	GenFx_oprobit8 `0'
	else			GenFx_oprobit9 `0'
end

program define GenFx_oprobit8 , sclass
	version 8
	args depvar
	tempname matcat
	mat `matcat' = e(cat)
	local kcat = e(k_cat)
	sret local cumu11 "(1-normprob(`s(xb1)'-_b[_cut1]))"
	sret local dens11 "-normd(`s(xb1)'-_b[_cut1])"
	local cat = `matcat'[1,1]
	EqLabel `s(depvar)' `cat'
	forval i = 2(1)`s(nout)' {
		local j = `i'-1
		di _b[_cut`j']
		sret local cumu`i'1 "(normprob(_b[_cut`i']-`s(xb1)')-normprob(_b[_cut`j']-`s(xb1)'))"
		sret local dens`i'1 "(normd(_b[_cut`j']-`s(xb1)')-normd(_b[_cut`i']-`s(xb1)'))"
		local cat = `matcat'[1,`i']
		EqLabel `e(depvar)' `cat'
	}
	local j = `s(nout)'-1
	sret local cumu`s(nout)'1 "normprob(`s(xb1)'-_b[_cut`j'])"
	sret local dens`s(nout)'1 "normd(`s(xb1)'-_b[_cut`j'])"
	local cat = `matcat'[1,`s(nout)']
	EqLabel `depvar' `cat'
	sret local medef Prob(`depvar')
	sret local depname `depvar'
end


program define GenFx_ologit
	version 8
	tempname b 
	mat `b' = e(b)
	local check = colnumb(`b',"_cut1")
	if `check'!=.	GenFx_ologit8 `0'
	else			GenFx_ologit9 `0'
end


program define GenFx_ologit8 , sclass
	version 8
	args depvar
	tempname matcat b
	mat `matcat' = e(cat)
	sret local cumu11 "1/(1+exp(-_b[_cut1]+`s(xb1)'))"
	sret local dens11 "-exp(_b[_cut1]-`s(xb1)')/((1+exp(_b[_cut1]-`s(xb1)'))^2)"
	local cat = `matcat'[1,1]
	EqLabel `depvar' `cat'
	forval i = 2(1)`s(nout)' {
		local j = `i'-1
		sret local cumu`i'1 "(1/(1+exp(_b[_cut`i']+`s(xb1)'))-1/(1+exp(-_b[_cut`j']+`s(xb1)')))"
		sret local dens`i'1 "(exp(_b[_cut`j']-`s(xb1)')/((1+exp(_b[_cut`j']-`s(xb1)'))^2)-exp(_b[_cut`i']-`s(xb1)')/((1+exp(_b[_cut`i']-`s(xb1)'))^2))"
		local cat = `matcat'[1,`i']
		EqLabel `depvar' `cat'
	}
	local j = `s(nout)'-1
	sret local cumu`s(nout)'1 "1/(1+exp(_b[_cut`j']-`s(xb1)'))"
	sret local dens`s(nout)'1 "exp(`s(xb1)'-_b[_cut`j'])/((1+exp(`s(xb1)'-_b[_cut`j']))^2)"
	local cat = `matcat'[1,`s(nout)']
	EqLabel `depvar' `cat'
	sret local medef Prob(`depvar')
	sret local depname `depvar'
end


program define GenFx_gologit , sclass
	version 8
	args depvar
	tempvar group
	qui egen `group' = group(`s(depvar)')
	forval i = 1(1)`s(nout)' {
		local j = `i'-1
		if `i'==1 {
			sret local cumu`i'1 " 1/(1+exp(`s(xb`i')')) "
			sret local dens`i'`i' " -exp(-`s(xb`i')')/((1+exp(-`s(xb`i')'))^2) "
		}
		if `i'>1 & `i'<`s(nout)' {
			sret local cumu`i'1 " 1/(1+exp(`s(xb`i')'))-1/(1+exp(`s(xb`j')'))"
			sret local dens`i'`j' " exp(-`s(xb`j')')/((1+exp(-`s(xb`j')'))^2)"
			sret local dens`i'`i' "-exp(-`s(xb`i')')/((1+exp(-`s(xb`i')'))^2)"
		}
		if `i'==`s(nout)' {
			sret local cumu`i'1 "1/(1+exp(-`s(xb`j')'))"
			sret local dens`i'`j' " exp(`s(xb`j')')/((1+exp(`s(xb`j')'))^2)"
		}
		qui sum `depvar' if `group'==`i'
		local cat = r(mean)
		EqLabel `depvar' `cat'
	}
	sret local medef Prob(`depvar')
	sret local depname `depvar'
end


program define GenFx_mlogit , sclass
	version 8
	args depvar denom
	tempname matcat
	mat `matcat' = e(cat)
	local base = e(ibasecat)

	**** CDF ********
	forval i = 1/`s(nout)' {
		local j = `i'-(`i'>`base')
		if `i'==`base'	local prob`i' "(1/(`denom'))"
		else local prob`i' "(exp(`s(xb`j')')/(`denom'))"
		sret local cumu`i'1 "`prob`i''"
	}
	
	******* Densities *******
	forval i = 1/`s(nout)' {
		local j = `i'-(`i'>`base')
		forval q = 1/`s(neq)' {
			if `i'==`base' {
				sret local dens`i'`q' "(-exp(`s(xb`q')')/(`denom')^2)"
			}
			else {
				if `q'==`j' {
					* sret local dens`i'`q' "((`prob`j'')*(1-(`prob`j'')))"
					sret local dens`i'`q' "(exp(`s(xb`j')')/(`denom')-exp(`s(xb`j')')^2/(`denom')^2)"
				}
				else {
					* sret local dens`i'`q' "-((`prob`j'')*(`prob`q''))"
					sret local dens`i'`q' "(-exp(`s(xb`j')')*exp(`s(xb`q')')/(`denom')^2)"
				}
			}
		}
		local cat = `matcat'[1,`i']
		EqLabel `depvar' `cat'
	}
	sret local medef Prob(`depvar')
	sret local depname `depvar'
end


program define GenFx_poisson , sclass
	version 8
	GenFx_eform	`*'
	sret local medef E(`s(depname)')
end


program define GenFx_nbreg , sclass
	version 8
	GenFx_poisson `*'
end


program define GenFx_zip , sclass
	version 8
	args depvar
	local mu "exp(`s(xb1)')"
	if "`e(inflate)'"=="logit" {
		local cuminf "1/(1+exp(-`s(xb2)'))"
		local deninf "(`cuminf')*(1-`cuminf')"
	}
	else {
		local cuminf "normprob(`s(xb2)')"
		local deninf "normd(`s(xb2)')"
	}
	sret local cumu11 "`mu'*(1-`cuminf')"
	sret local dens11 "`mu'*(1-`cuminf')"
	sret local dens12 "-`mu'*`deninf'"
	sret local depname `depvar'
	sret local medef Prob(`depvar')
end

program define GenFx_zinb, sclass
	version 8
	GenFx_zip `*'
end


program define GenFx_biprobit , sclass
	version 8
	args v1 v2 bit
	local rho = e(rho)
	local srh = sqrt(1-`rho'^2)
	forval k = 1/4 {
		local A
		local C 
		local B 
		if `k'<3  			local A -
		if `k'==1 | `k'==3 	local B -
		if `k'==2 | `k'==3 	local C -
		sret local cumu`k'1  binorm(`A'`s(xb1)',`B'`s(xb2)',`C'`rho')
		sret local dens`k'1  (`A'normd(`A'`s(xb1)')*normprob((`B'`s(xb2)'-`C'`rho'*`A'`s(xb1)')/`srh'))
		sret local dens`k'2  (`B'normd(`B'`s(xb2)')*normprob((`A'`s(xb1)'-`C'`rho'*`B'`s(xb2)')/`srh'))
	}
	sret local eqname "p00 p01 p10 p11"
	sret local medef "Prob(`v1',`v2')"
end




*============================================================
*
* [6] SUBROUTINES THAT PROCESS ESTIMATION RESULTS
*
*============================================================

	
program define PassToS , sclass
	version 8
	local rhs `*'
	local Tlist `r(treat)'
	local ntreat : word count `Tlist'
	sret local depvar `r(depvar)'
	sret local rhs `Tlist' `rhs'
	sret local Tlist `r(treat)'
	sret local Ntreat `ntreat'
end


program define ProcEst1 , rclass
	version 8
	tempname b v coef
	local depvar = e(depvar)
	mat `b' = e(b)
	mat `v' = e(V)
	if "`s(model)'"=="heckprob" {
		local dim = colnumb(`b',"_cons")
	}
	else local dim = colsof(`b')-`s(nap)'
	mat `v' = `v'[1..`dim',1..`dim']
	mat `b' = `b'[1,1..`dim']
	local dim = `dim'-1 /* -1 is the constant */
	mat `coef' = `b'[1,1..`dim']
	local treat : colnames(`coef')
	mat `coef' = `coef''
	return local treat `treat'
	return local depvar `e(depvar)'
	return matrix b `b'
	return matrix coef `coef'
	return matrix v `v'
end

 	
program define ProcEst2 , rclass
	version 8
	tempname b v coef temp
	mat `b' = e(b)
	mat `v' = e(V)
	if substr("`s(model)'",1,1)=="o" {
		local dim = colsof(`b')-`s(ncons)'
		mat `b' = `b'[1,1..`dim']
	}
	else if "`s(model)'"=="biprobit" {
		local dim = colsof(`b')-1
		mat `b' = `b'[1,1..`dim']
		mat `v' = `v'[1..`dim',1..`dim']
		*local dim = `dim'-2
	}
	else local dim = colsof(`b')/(`s(nout)'-1)-1
	forval i = 1/`s(neq)' {
		local p = (`i'-1)*(`dim'+1)+1
		local q = `p'+`dim'-1
		mat `temp' = `b'[1,`p'..`q']
		if `i'==1 {
			mat `coef' = `temp'
			local treat : colnames(`temp')
		}
		else	mat `coef' = `coef' \ `temp'
	}
	mat `coef' = `coef''
	return local depvar `e(depvar)'
	return local treat `treat'
	return matrix b `b'
	return matrix coef `coef'
	return matrix v `v'
end


program define ProcEst3 , rclass
	version 8
	local depvar = e(depvar)
	local v1 : word 1 of `depvar'
	local v2 : word 2 of `depvar'
	if "`v2'"=="" {
		if "`s(model)'"=="zip" | "`s(model)'"=="zinb" {
			local v2 "inflate"
		}
		else local v2 "select"
		local depvar "`depvar' `v2'"
	}	
	tempname b v b1 b2 b3 v11 v12 v21 v22 bnew vnew 
	mat `b' = e(b)
	mat `v' = e(V)
	local dim = colnumb(`b',"_cons")-1
	mat `b1' = `b'[1,1..`dim']
	mat `b2' = `b'[1,"`v2':"]
	mat `b3' = `b1'*0
	mat `v11' = `v'["`v1':","`v1':"]
	mat `v12' = `v'["`v1':","`v2':"]
	mat `v22' = `v'["`v2':","`v2':"]
	local e1 : colnames(`b1')
	local e2 : colnames(`b2')
	local n1 = colsof(`v11')
	local n2 = colsof(`v12')

	* RESHAPING THE VECTOR OF COEFFICIENTS
	local j = 1
	while `j'<=`n2' {
		local x : word `j' of `e2'
		if "`x'"!="_cons" {
			* Does the first eq contains `x' from the second eq?
			capture display _b[`v1':`x']
			 if _rc==0 {
				local dest = colnumb("`v11'","`x'")
				mat subst `b3'[1,`dest'] =  _b[`v2':`x']
			}
			else  {
				local addname `addname' `x'
				local beta = _b[`v2':`x']
				local addbeta `addbeta' `beta'
				local dim = `dim'+1
			}
		}
		local j = `j'+1
	}
	local treat `e1' `addname'
	local ntreat : word count `treat'
	mat `bnew' = J(2,`dim',0)
	mat input `b2' = (`addbeta')
	local nadd = colsof(`b2')
	mat `b3' = `b3', `b2'
	mat subst `bnew'[1,1] = `b1'
	mat subst `bnew'[2,1] = `b3'
	mat `bnew' = `bnew''
	
	* RESHAPING THE VARIANCE-COVARIANCE MATRIX

	* increasing dimension of Eq#2 parts & changing the ordering of cols therein
	local i = 1
	local moves = 0
	while `i'<=`ntreat' {
		local var : word `i' of `treat'
		local beta = `bnew'[`i',2]
		if `beta'==0  {
			local dest = (`i'-1)*(`moves'>0)  /* dest=0 as long as var contained only in Eq#2 */
			Ins0Vec `v22' `dest' `var'
			mat `v22' = `v22''
			Ins0Vec `v22' `dest' `var'
			mat `v22' = `v22''
			Ins0Vec `v12' `dest' `var'
		}
		else if `i'<`n1'  {	   /* - no modification needed if var is only in Eq#2 */
			local orig = colnumb(`v22',"`var'")
			MoveVec `v22' `orig' `i'
			mat `v22' = `v22''
			MoveVec `v22' `orig' `i'
			mat `v22' = `v22''
			MoveVec `v12' `orig' `i'
			local moves = `moves'+1
		}
		local i = `i'+1
	}
*	* Adding row zeros to matrices containing Eq#2 parts 
	
	mat `v21' = `v12''
	local i = `n1'-1
	while `i'<`ntreat' {
		local var : word `i' of `treat'
		Ins0Vec `v21' `i' `var'
		Ins0Vec `v11' `i' `var'
		mat `v11' = `v11''
		Ins0Vec `v11' `i' `var'
		mat `v11' = `v11''
		local i = `i'+1
	}

	* RETURNING RESULTS
	
	mat `v12' = `v21''
	mat `vnew' = ( `v11' , `v12' ) \ ( `v21' , `v22' )
   	return local depvar `v1' `v2'
	return local treat `treat'
	return matrix b `b'
	return matrix coef `bnew'
	return matrix v `vnew'
end


program define ProcEst9
	ProcEst1  `*'
end

program define MoveVec
	version 8
	args touse orig dest sym
	if `orig'==`dest' {
		exit
	}
	tempname mat col m1 m2 m3
	mat `mat' = `touse'
	local nrow = rowsof(`mat')
	local ncol = colsof(`mat')
	mat `col' = `mat'[1..`nrow',`orig']
	local pc1 = `dest'-1
	local pc2 = `orig'-1
	local pc3 = `orig'+1
	if `orig'<`dest' {
		local pc1 = `orig'-1
		local pc2 = `orig'+1
		local pc3 = `dest'+1
	}
	if `orig'==`ncol' & `dest'==1 {
		mat `m1' = `mat'[1..`nrow',1..`pc2']
		mat `mat' = `col', `m1'
	}
	else if `dest'==`ncol' & `orig'==1 {
		mat `m1' = `mat'[1..`nrow',2..`ncol']
		mat `mat' = `m1' , `col'
	}
	else if `orig'<`ncol' & `dest'==1 {
		mat `m2' = `mat'[1..`nrow',`dest'..`pc2']
		mat `m3' = `mat'[1..`nrow',`pc3'..`ncol']
		mat `mat' = `col', `m2', `m3'
	}
	else if `dest'<`ncol' & `orig'==1 {
		mat `m2' = `mat'[1..`nrow',`pc2'..`dest']
		mat `m3' = `mat'[1..`nrow',`pc3'..`ncol']
		mat `mat' =  `m2', `col',`m3'
	}
	else if `orig'==`ncol' & `dest'>1 {
		mat `m1' = `mat'[1..`nrow',1..`pc1']
		mat `m2' = `mat'[1..`nrow',`dest'..`pc2']
		mat `mat' =  `m1', `col', `m2'
	}
	else if `dest'==`ncol' & `orig'>1 {
		mat `m1' = `mat'[1..`nrow',1..`pc1']
		mat `m2' = `mat'[1..`nrow',`pc2'..`dest']
		mat `mat' =  `m1', `m2', `col'
	}
	else if `orig'>`dest' {
		mat `m1' = `mat'[1..`nrow',1..`pc1'] 
		mat `m2' = `mat'[1..`nrow',`dest'..`pc2']
		mat `m3' = `mat'[1..`nrow',`pc3'..`ncol']
		mat `mat' =  `m1' , `col' , `m2' , `m3' 
	}
	else {
		mat `m1' = `mat'[1..`nrow',1..`pc1'] 
		mat `m2' = `mat'[1..`nrow',`pc2'..`dest']
		mat `m3' = `mat'[1..`nrow',`pc3'..`ncol']
		mat `mat' =  `m1' ,  `m2' , `col', `m3' 
	}
	mat `touse' = `mat'
end

program define Ins0Vec
	version 8
	args touse pos name sym
	tempname mat col m1 m2
	mat `mat' = `touse'
	local nrow = rowsof(`mat')
	local ncol = colsof(`mat')
   	local sym = ("`sym'"!="")
	local row = 1+`sym'
	mat `col' = `mat'[1..`nrow',1]*0
	mat coln `col' = `name'
	if `pos'==0 {
		mat `mat' = `col', `mat'
	}
	else if `pos'==`ncol' {
		mat `mat' = `mat' , `col'
	}
	else {
		local pos2 = `pos'+1
		mat `m1'  = `mat'[1..`nrow',1..`pos']
		mat `m2'  = `mat'[1..`nrow',`pos2'..`ncol']
		mat `mat' = `m1' , `col' , `m2'
	}
	mat `touse' = `mat'
end



*============================================================
*
* [7] OTHER SUBROUTINES
*
*============================================================


program define VarTypes , sclass
	version 8
	args touse count
	local cvars `s(Tlist)'
	foreach var in `cvars' {
		capture assert `var'==1 | `var'==0 if `touse'
		if _rc==0 {
			local cvars : subinstr local cvars "`var'" ""
			local dummies  `dummies' `var'
		}
	}
	if "`count'"=="on" {
		foreach var in `cvars' {
			capture assert `var'==int(`var')	if `touse'
			if _rc==0	local counts `counts' `var'
		}
	}
	sret local Countvars  `counts'
	sret local Dummyvars  `dummies'
	sret local Continvars `cvars'
end


program define AtOption , sclass
	version 8
	if "`0'"=="" {
		sret local at
		sret local method	average
		exit
	}
	local at `0'
	* Searching for occurences of mean, median, zero
	local count = 0
	foreach word in mean median zero {
		local new :  subinstr local at "`word'" " " ,  count(local flag)
		if `flag'==1	local method `word'
		local count = `count'+`flag'
	}
	if `count'==0	local method mean
	* List of variables set to other values	than mean/median/zero
	local user
	local at :  subinstr local at "=" " " , all 
	while "`at'"!="" {
		gettoken name at : at 
		capture confirm var `name'
		if _rc==0	local user `user' `name'
	}
	sret local at		`user'
	sret local method	`method'
end


program define Mrhs , sclass
	version 8
	local id "`1'"
	mac shift
	sret local rhs`id' `*'
end


program define Mindex , sclass
	version 8
	sret local xb`1' `2'
end

program define EqLabel , sclass
	args depvar cat
	if "`cat'"=="" {
		qui sum `depvar' if `depvar'!=0
		local cat = r(mean)
	}
	local label : label (`depvar') `cat'
	if "`label'"=="" {
		local label "p`cat'"
	}
	else {
		local cat `label'
		local label = substr("`label'",1,8)
	}
	local eqlab "`s(eqname)' `label'"
	sret local eqname `eqlab'
	sret local cat `cat'
end


program define DumList , sclass
	version 8
	* Saving existing s() macros
	foreach word in nout type neq ncons nap model {
		local `word' `s(`word')'
	}
	gettoken b 0 : 0
	local xvars : colnames `b'

	* Step 1: Recognizing lists of dummies as tokens
	
	tokenize "`0'" , p(" \ ")
	local args `0' 
	local N = 1
	local doit = 1
	while `doit'==1 {
		*local check : subinstr local `"`args'"' "\" , all
		if  "`args'"==""	local doit=0
		*if "`check'"=="" | "`args'"==""	local doit=0
		else {
			local pos = index("`args'","\")
			if `pos'==0	local pos = length("`args'")
			local tokens`N' = substr("`args'",1,`pos')
			local tokens`N'  : subinstr local tokens`N' "\" " " , all
			local args = substr("`args'",`pos'+1,length("`args'"))
			local N = `N'+1
		}
	}

	local N = `N'-1

	* Step 2: Unabbreviating lists of dummies & eliminating dropped vars
	forval i = 1/`N' {
		tsunab list`i' : `tokens`i''
		local list`i' : list list`i' & xvars
	}

	* Step 3: Generating if conditions

	forval i = 1/`N' {
		local n : word count `list`i''
		if `n'>1 {
			forval j = 1/`n' {
				local treat : word `j' of `list`i''
				local newlist : subinstr local list`i' "`treat'" " " , all
				local newlist : subinstr local newlist " " "!=1 & " , all
				local newlist if `newlist'!=1
				local newlist : subinstr local newlist "& !=1 & !=1" " " , all
				local newlist : subinstr local newlist "!=1 & !=1" " " , all
				local newlist : subinstr local newlist "if   &" "if" , all
				sret local `treat' `newlist'
			}
		}
	}

	* Restores s() macros

	foreach word in nout type neq ncons nap model {
		sret local `word' ``word''
	}

end

