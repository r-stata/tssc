capture program drop margeff
program define margeff
*! Obtain partial effects after estimation
*! Version 2.2.0  (20 August 2009)    (Revision of Stata Journal submission)
*! Author:        Tamas Bartus        (Corvinus University, Budapest)
	version 9.2 


*******************************************************************************
*
* [1] DETERMINING WHAT TO DO
*
*******************************************************************************	


	if "`1'"=="?" {
		gettoken tmp 0 : 0
		if `"`0'"'==""  SendVersion
		else `0'
		exit
	}

	if "`e(cmd)'"=="" 		exit 301

// Determining what to do
// if no arguments specified: replay results, provided the -replace- option was used
	if `"`0'"'=="," | `"`0'"'=="" {
		if "`e(cmd)'"=="margeff"	local doit = 0
		else						local doit = 1
	}
// if something specified: estimate, provided replay subcmd not found
	else {
		gettoken cmd 0 : 0 , parse(" ,")
		local l = length("`cmd'")
		if substr("replay",1,`l')==`"`cmd'"' {
			if "`e(cmd)'"=="margeff" & "`e(margeff_cmd)'"=="" {
				di as red "It is impossible to replay marginal effects"
				error 301
			}
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
		preserve
		CheckSupport `0'
		Estimate   `0' 
		Replay `0' 
		restore
		sret clear
	}
	else {
		Replay  `0'
	}
end



program define CheckSupport , sclass
	version 8.2
	syntax [if] [in] [fweight pweight iweight /] [ , Model(string) Link(string) eform * ]

	sret local model 
	if "`e(cmd)'"=="margeff" 	exit 301
	local cmd	= e(cmd)
	
	// Taking care of xt commands
	if substr(`"`cmd'"',1,2)=="xt" {
		local family xt
		local cmd = substr("`cmd'",3,length("`cmd'")-2)
	}
	else local family
	
	if ("`cmd'"=="glm" | "`family'`cmd'"=="xtgee") & "`link'"=="" & "`model'"=="" {
		if "`family'"=="xt" local elink = e(link)
		else local elink = e(linkt)
		local elink = lower("`elink'")
		if "`elink'"=="logit"						local model logit
		else if "`elink'"=="probit"					local model probit
		else if "`elink'"=="complementary log-log" 	local model cloglog
		else if "`elink'"=="cloglog"				local model cloglog
		else if "`elink'"=="log"					local link log
		else if "`elink'"=="log-log"				local link loglog
		else if "`elink'"=="log complement"			local link logc
		else if "`elink'"=="neg. binomial" 			local link nbinomial
		else if "`elink'"=="nbinomial"				local link nbinomial
		else if "`elink'"=="power"					local link power `e(power)'
		else if "`elink'"=="odds power" 			local link opower `e(power)'
		else if "`elink'"=="odds p"					local link opower `e(power)'
	}
	if "`eform'"!="" local link log
	if `"`link'"'!="" {
		local allow_link log loglog	logc nbinomial power opower
		gettoken model power : link
		local temp : subinstr local allow_link  "`model'" "" , count(local c) word
		if `c'==0 {
			di as error "margeff does not support the link -`model'-"
			error 198
		}
		local subcmd link
	}
 	else {
		if `"`model'"'=="" local model `cmd'
		local allow_normal   probit logit logistic cloglog probit poisson nbreg
		local allow_ordered  oprobit ologit 
		local allow_multieq  gologit2 mlogit heckprob biprobit zip zinb
		local allow_select   heckman tobit truncreg cnreg
		foreach word in normal ordered multieq select {
			local temp : subinstr local allow_`word'  "`model'" "" , count(local c) word
			local subcmd `word'
			if `c'==1 {
				continue , break
			}
		}
		if `c'==0 {
			di as error "margeff does not support `family'`model'; please use -mfx- instead"
			error 198
		}
	}
	sret local model `model'
	sret local family  `family'
	sret local link  `link'
	sret local subcmd `subcmd'
end


*******************************************************************************
*
* [2] ESTIMATION + REPLAYING
*
*******************************************************************************	


program define Estimate , eclass
	version 8.2
	syntax [if] [in] [fweight pweight iweight /] ///
		[ , at(string) Model(string) Link(string) ///
			Dummies(string)  noOFFset   noWght CONStant ///
			OUTcome(string) Percent Replace ///
			eform dx(string) count * ]

// CHECKING AND PROCESSING OPTIONS


	foreach w in model family link subcmd {
		local `w' `s(`w')'
	}
	
	if `e(df_m)'==0  {
		di as error "There are no independent variables; running -margeff- makes no sense"
		exit 301
	}	
	if "`model'"=="cnreg" & `"`at'"'!="" {
		di as error "Only average partial effects can be calculated after cnreg"
		di as error "Option -at()- will be ignored"
		local at
	}

	if `"`dummies'"'!="" {
		DumList  `dummies'
		if "`s(error)'"!="" {
			di as error "`s(error)'"
			error 198
		}
	}
	
	* Weights
	if "`wght'"=="nowght" | "`e(wtype)'"=="" {
		local weight
	}
	else {
		local weight [iweight`e(wexp)']
		local weight : subinstr local weight "= " "="
	}

	if "`e(offset)'"!="" & "`offset'"=="" {
		tempvar offsetvar
		qui gen double `offsetvar' = `e(offset)'
		local offset offset(`offsetvar')
	}
	else local offset
	
// Setting key S macros

	SetSMacros_`subcmd' `model' `outcome'`power'
	if "`outcome'"!="" {
		CheckOut `outcome'
	}
	else {
		numlist "1/`s(nout)'"
	}
 	local outcome = r(numlist)


	
//  MARKING SAMPLE, GETTING E RESULTS, TEMPNAMES

	tempvar touse mark
	mark `mark' `if' `in' `weight'
	qui gen byte `touse' = e(sample) if `mark'==1
	qui count if `touse'==1

	local numobs = r(N)
	local depvar = e(depvar)
	local cmd    = e(cmd)

	tempname bold vold	// estimation results
	tempname bnew vnew	// marginal effects
	tempname atmat 		// vector of evaluation points
	tempname dxmat		// matrix of changes
	tempname at_dx		// matrix of at values and changes
	tempname matcell	// temporary matrix - checking whether a variable is dummy or not


//	Variables for which marginal effects should be computed

	mat `bold' = e(b)
	mat `vold' = e(V)

 	local ncol     = colsof(`bold')
 	local colnames : colnames `bold'
	local varlist  : list uniq colnames
	local varlist  : subinstr local varlist "_cons" "" , all word count(local hascons)   
	local varlist  : subinstr local varlist "_se" "" , all word    // this should eliminate anc parameters as well
	local nvar     : word count `varlist'

	if `"`at'"'!="" {
		local method at
		AtList , at(`at') varlist(`varlist')
		local atvarlist = r(atvarlist)
		local atnumlist = r(atnumlist)
		local atstat    = r(atstat)
		if "`atstat'"=="p50" {
			if `"`weight'"'!="" & "`wtype'"=="pweight" {
				di as error "Warning: pweights will be ignored during the calculation of medians"
				local weight
			}
		}
		if "`offset'"!="" {
			if "`atstat'"=="mean" {
				qui su `offsetvar' if `touse' `weight'
				local mean = r(mean)
			}
			else if "`atstat'"=="p50" {
				qui su `offsetvar' if `touse' `weight' , detail
				local mean = r(p50)
			}
			else local mean = 0
			local offset offset(`mean')
		}
	}
	else {
		local method av
		local atstat mean
	//	if "`offset'"!="" local offset offset(`offsetvar')
	}

	
//	Constructing the matrices of values at which marginal effects be computed
//	Making dx & at specification complete

	mat `atmat' = J(1,`nvar',0)
	mat `dxmat' = J(2,`nvar',.)
	mat colnames `dxmat' = `varlist'
	mat colnames `atmat' = `varlist'
	tempname dx1 dx2

	
	forval x = 1/`nvar' {
		local var : word `x' of `varlist'
		local value = 0
		// Atvalues
		if `"`at'"'!="" {
		    local pos : list posof `"`var'"' in atvarlist
		    if `pos'!=0 {
			  local value : word `pos' of `atnumlist'
		    }
		    else if "`atstat'"!="zero" {
			  if "`atstat'"=="p50" qui su `var' if `touse' , detail
			  else qui su `var' if `touse' `weight'
			  local value = r(`atstat')
		    }
		}	// end of  if `"`at'"'!="" ....
		// From and To values of discrete change
		capture assert `var'==0 | `var'==1 if `touse'
		if  _rc==0 {	  // dummy found
 			scalar `dx1' = 1-`value'
			scalar `dx2' = 0-`value'
		}
		else {
			CalcUnit `var' `touse'
			scalar `dx1' = r(unit)
			scalar `dx2' = -`dx1'
		}		
		* Filling in elements of atmat and dxmat matrices

		mat `atmat'[1,`x'] = `value'
		mat `dxmat'[1,`x'] = `dx1'
		mat `dxmat'[2,`x'] = `dx2'
		

	}  // end of forvalue loop


//	Getting estimation results + removing anciliary parameters
//	Specifying xmean matrices with the help of atmat

	ProcessEstMat_`s(type)'	`ncol' `bold' `vold' `method'
	mat `vold' = r(v)
	forval x = 1/`s(neq)' {
		tempname bold`x' 
		mat `bold`x'' = r(bold`x')
		local boldlist  `boldlist' `bold`x''
		// At values
		tempname xmean`x'
		MakeXMeanMat_`s(type)'  `x' `bold`x'' `atmat'
		mat `xmean`x'' = r(xmean)
		local xmeanlist  `xmeanlist' `xmean`x''
		if "`method'"=="av"  {
			tempvar xbvar`x'
			qui gen double `xbvar`x'' = .
			local xbvarlist `xbvarlist' `xbvar`x''
		}
 	}

//	Defining some locals needed during calculations

	local neq = `s(neq)'
	local exe `s(model)'
	if "`s(model)'"=="gologit2" {
		local exe o`e(link)'
	}
	if "`method'"=="av" {
		local tempcmd tempvar
		local gencmd  qui gen double
		local gencond if `touse'==1
		local xlist xlist(`xbvarlist')
		local margeff_type Average partial effects
	}
	else {
		local tempcmd tempname
		local gencmd  scalar
		local gencond
		local xlist xlist(`xmeanlist') 
		local margeff_type Partial effects at fixed values
	}
	if "`family'"=="xt" {
		if e(predict)=="xtbin_p" {
		    local genfxopt = sqrt(1-`e(rho)')
		}
		else local genfxopt = 1
	}
	else local genfxopt = 1
	tempname xmat bnew

	qui replace `touse'=1
 
// Calculation of partial effects and standard errors

	foreach out in `outcome' {
		forval i = 1/`nvar' {
			local var   : word `i' of `varlist'

			
//  Setting mean / vars to zero if dummy found + Taking care of the dummies() option
				local deltamat	`dxmat'
				local xmatlist  `xmeanlist'
				
//	Prediction after variable under treatment increased then decreased by predefined value
			forval r = 1/2 {
				`tempcmd' hat`r'
				local dx`r' = `deltamat'[`r',`i']
				GenXB_`s(type)' `var' `touse' `weight' , 	 ///
					 method(`method') change(`dx`r'') blist(`boldlist') `xlist' outcome(`out') `dlist' `offset'
				GenFx_`exe'  `out'  `genfxopt'
				`gencmd'  `hat`r'' = `s(cdf)'	`gencond'
				forval eq = 1/`neq' {
					`tempcmd'  phi`r'`eq'
					`gencmd'  `phi`r'`eq'' = `s(dens`eq')'	`gencond'
				}
			}		

//	Partial effect
			tempname me 
			CalcME_B_`method' `hat1' `hat2' `dx1' `dx2' `touse'	`weight'
			mat `me' = r(me)
			mat colnames `me' = `var'
			EqLabel `out' `touse'
			if `: word count `outcome''>1 {
				mat coleq `me' = "`s(lab)'"
			}
			else local category  `s(cat)'	// needed for labeling output
			mat `bnew' = nullmat(`bnew') , `me'

//	Derivatives of partial effect with respect to coefficients
			tempname pder add vec
			forval eq = 1/`neq' {
				local xmat : word `eq' of `xmatlist'
				CalcME_SE_`method' `var' `phi1`eq'' `phi2`eq'' `dx1' `dx2'  `xmat'  `touse'	`weight'
 				mat `vec' = r(vec)
				if "`s(type)'"=="ordered" {
					if `eq'==1	mat `pder' = `vec'
					else		mat `pder' = `pder'+`vec'
				}
				else			mat `pder' = nullmat(`pder') , `vec'
			}
			mat `vnew' = nullmat(`vnew') \ `pder'

		}	 // end of variable loop

		if `hascons'==1 & "`constant'"!="" {
			tempname consder
			GenXB_`s(type)' `touse' `weight' ,  cons  method(`method') blist(`boldlist') `xlist' outcome(`out')  `offset'
			GenFx_`exe'  `out' `genfxopt'
			scalar `hat' = `s(cdf)' 
			CalcME_B_`method'  `hat' 0 1 0 `touse' `weight'
			mat `me' = r(me)
			mat colnames `me' = _cons
			if `: word count `outcome''>1 {
				EqLabel `out' `touse'
				mat coleq `me' = "`s(lab)'"
			}
			mat `bnew' = `bnew' , `me'
			forval eq = 1/`neq' {
				tempname phi`eq'
				scalar  `phi`eq'' = `s(dens`eq')' 
				local xmat : word `eq' of `xmatlist'
				mat `vec' = `xmat'*0
				local pos = colsof(`xmat')
				mat `vec'[1,`pos'] = `phi`eq''
				if "`s(type)'"=="ordered" {
					if `eq'==1	mat `consder' = `vec'
					else		mat `consder' = `consder'+`vec'
				}
				else mat `consder' = nullmat(`consder') , `vec'
			}
			mat `vnew' = nullmat(`vnew') \ `consder'
		}

	}	 // end of outcome loop


 
// matrix of standard errors
 	*	mat coleq `vold' = _
	*	mat roweq `vold' = _

	mat `vnew' = (`vnew'*`vold')*`vnew''
	local rownames : colnames `bnew'
	local roweq    : coleq    `bnew' , quoted
	mat rownames `vnew' = `rownames'
	mat colnames `vnew' = `rownames'
	mat roweq    `vnew' = `roweq'
	mat coleq    `vnew' = `roweq'

	mat rownames `dxmat' = plus minus

// Returning results

	local title `s(title)'
//	if "`category'"!="" & `s(catdepv)'==1  local title `title' == `category'


	if "`percent'"!="" {
		mat `bnew' = 10^2 * `bnew'
		mat `vnew' = 10^4 * `vnew'
	}

	if "`replace'"!="" {
		tempname bpost vpost
		* Saves scalars
		local scalars : e(scalars)
		foreach el in `scalars' {
			tempname s`el'
			scalar `s`el'' = e(`el')
		}
		mat `bpost' = `bnew'
		mat `vpost' = `vnew'
		ereturn post `bpost' `vpost' , depname("variable") obs(`numobs') esample(`touse')
		* Restores scalars
		foreach el in `scalars' {
			eret scalar `el' = `s`el''
		}
		ereturn local cmd	margeff
	}

	ereturn mat margeff_dx	`dxmat'
	ereturn mat margeff_at	`atmat'
	ereturn mat margeff_V 	`vnew'
	ereturn mat margeff_b 	`bnew'

*	ereturn local margeff_def  `title'
	ereturn local margeff_depname	`s(title)'	
	ereturn local margeff_cmd		`e(cmd)'
	ereturn local margeff_title	`margeff_type'

end


program define Replay , eclass
	version 8
	syntax [if] [in] [fweight pweight iweight /] [, Level(integer `c(level)') * ]

	di 
	di as text "`e(margeff_title)' after " as res "`e(margeff_cmd)'"
	di as text _col(7) as text "y  = " as res "`e(margeff_depname)' "
	di

	tempname ehold b v
	mat `b' = e(margeff_b)
	mat `v' = e(margeff_V)
	
	nobreak	{
		_est hold `ehold'
		ereturn post `b' `v' , depname("variable")
		ereturn disp , level(`level')
	}
	_est unhold `ehold'	
end



*============================================================
*
* [3] SETTING KEY S MACROS 	--- SetSMacros_ subroutines
*
*============================================================


program define SetSMacros_normal , sclass
// probit logit logistic cloglog  xtprobit poisson   nbreg
	version 8
	local depvar = e(depvar)
	local depvar : word 1 of `depvar'
	if "`1'"=="poisson" | "`1'"=="nbreg"  {
		sret local title E(`depvar') (expected number of counts)
		sret local catdepv = 0
	}
	else {
		sret local title probability of `depvar'
		sret local title Pr(`depvar')
		sret local catdepv = 1
	}
	SMacReturn normal `depvar'  `1' 1 1
end


program define SetSMacros_link , sclass
	version 8
	args link power
	local depvar = e(depvar)
	local depvar : word 1 of `depvar'
	if "`power'"!="" {
		capture confirm number `power'
		if _rc!=0 {
			di as error "A number must be specified in the link(power #) option"
			error 198
		}
		sret local power `power'
	}
	sret local catdepv = 0
	local fnc = e(linkf)
	if `"`fnc'"'!="" local title : subinstr local fnc "u" "`depvar'" , all 
	local title "`1'(`depvar')"
	sret local title "`title'"
	SMacReturn normal `depvar'  `1' 1 1
end


program define SetSMacros_ordered , sclass
// oprobit ologit 
	version 8
	local depvar = e(depvar)
	local nout = e(k_cat)
	local neq = `nout'-1
	if "`2'"!="" local depvar `depvar'=`2'
	sret local title Pr(`depvar')
	sret local catdepv = 1
	SMacReturn ordered `depvar' `1' `nout' `neq'
end


program define SetSMacros_multieq , sclass
//   mlogit gologit2 heckprob biprobit zip zinb
	version 8
	local depvar = e(depvar)
	gettoken depvar depv2 : depvar
	local nout = 1
	local neq = 2
	local type multieq
	// Modification of default settings
	if "`1'"=="heckprob" {
		local neq = 1
		sret local title probability of `depvar'
		sret local title Pr(`depvar')
		sret local catdepv = 1
	}
	else if "`1'"=="biprobit" {
		sret local title joint probabilities of `depvar' and `depv2'
		if "`2'"=="" sret local title Pr(`depvar',`depv2')
		else {
			local prob : word `2' of p00 p01 p10 p11
			local v1 = substr("`prob'",2,1)
			local v2 = substr("`prob'",3,1)
			sret local title Pr(`depvar'=`v1',`depv2'=`v2')
		}
		if substr(e(title),1,1)=="B" {
			local nout = 4
			local type	multieq
			sret local title Pr(`depvar'=`v1',`depv2'=`v2')
		}
		else {
			local nout = 4
			local type multieq
			sret local title Pr(`depvar'!=0,`depv2'!=0)
		}
	}
	else if  "`1'"=="zip" |  "`1'"=="zinb"  {
		sret local title E(`depvar') (expected number of counts)
		sret local catdepv = 0
	}
	else {
		if "`e(k_cat)'"!="" local nout = e(k_cat)
		else local nout = e(k_out)
		local neq = `nout'-1
		if "`2'"!="" local depvar `depvar'=`2'
		sret local title probability of `depvar'
		sret local title Pr(`depvar')
		sret local catdepv = 1
	}
	SMacReturn `type' `depvar' `1' `nout' `neq'
end


program define SetSMacros_select , sclass
// heckman tobit cnreg intreg truncreg
	version 8
	local depvar = e(depvar)
	local depvar : word 1 of `depvar'
	sret local title E(`depvar'|`depvar' observed)
	if "`1'"=="heckman" | "`1'"=="heckprob"  {
		SMacReturn multieq `depvar'  `1' 1 2
	}
	else {
		SMacReturn normal  `depvar'  `1' 1 1
	}
end


program define SMacReturn , sclass
	version 8
	sret local type    `1'
	sret local depvar  `2'
	sret local model   `3'
	sret local nout  = `4'
	sret local neq   = `5'
end



*============================================================
*
*	[4] VECTORS OF COEFFICIENTS AND AT VALUES FOR EACH EQUATION
*	ProcessEstMat_ subroutines
*	MakeXMeanMat_ subroutines
*
*============================================================



program define ProcessEstMat_normal	, rclass
	version 8.2
	args ncol b v at
	tempname bold1 
	local eqlist : coleq `b' , quoted
	local eqlist : list uniq eqlist
	if `"`eqlist'"'!="_" {		// take first eq
		local eqname : word 1 of `eqlist'
		mat `b' = `b'[1,"`eqname':"]
		mat `v' = `v'["`eqname':","`eqname':"]
	}
	// Taking care of constant or noconstant option in est model
	local pos = colnumb(`b',"_cons")
	if `pos'!=. {
		mat `b' = `b'[1,1..`pos']
		mat `v' = `v'[1..`pos',1..`pos']
	}
	return mat bold1 = `b'
	return mat v = `v'
end


program define ProcessEstMat_multieq	, rclass
	version 8.2
	args ncol b v at
	local eqlist : coleq `b' , quoted
	local eqlist : list uniq eqlist
	tempname vce
	local nvar = 0	// counter for n of cols containing var and constant
	forval eq = 1/`s(neq)' {
		local eqname : word `eq' of `eqlist'
		tempname bold`eq' 
		mat `bold`eq''  = `b'[1,"`eqname':"]
		local ncol = colsof(`bold`eq'')
		// Taking care of constant or noconstant option in est model
		local nvar = `nvar'+`ncol'
		return mat bold`eq' = `bold`eq''
	}
	mat `vce' = `v'[1..`nvar',1..`nvar']
	return mat v = `vce'
end


program define ProcessEstMat_ordered , rclass
	version 8
	args ncol b v method
	tempname coef bcut
	local ncol = colsof(`b')
	local ncons = e(k_cat)-1
	local nvar = e(df_m)
	mat `coef' = `b'[1,1..`nvar']
	mat `bcut' = J(1,`ncons',0)
	mat coleq    `coef' = _
	mat colnames `bcut' = _cons
	forval eq = 1/`s(neq)' {
		tempname bold`eq'
		mat `bold`eq'' = `bcut'
		local pos = `nvar'+`eq'
		local cut = `b'[1,`pos']
		if "`method'"=="av" local cut = -1*`cut'
		mat `bold`eq''[1,`eq'] = `cut'
		mat `bold`eq''  = `coef', `bold`eq''
		return mat bold`eq' = `bold`eq''
	}
	return mat v = `v'
end


program define ProcessEstMat_difficult	, rclass
	version 8
	di as error "Subroutine ProcessEstMat_difficult not implemented yet"
	error 198
end


program define MakeXMeanMat_normal , rclass
	version 8.2
	args eq b at
	tempname xmean 
	// Taking care of constant or noconstant option in est model
	local pos = colnumb(`b',"_cons")
	if `pos'!=. {
		tempname  one
		mat `one' = J(1,1,1)
		mat colnames `one' = _cons
		mat `xmean' = `at' , `one'
	}
	else mat `xmean' = `at'
	return add  // preserves matrices created by ProcessEstMat program
	return mat xmean = `xmean'
end


program define MakeXMeanMat_multieq	, rclass
	version 8
	args eq b at
	local ncol = colsof(`b')
	local colnames : colnames `b'
	tempname xmean
	mat `xmean' = `b'*.
	mat colnames `xmean' = `colnames'
	forval col = 1/`ncol' {
		local name : word `col' of `colnames'
		if "`name'"=="_cons"	local value = 1
		else {
			local pos = colnumb(`at',"`name'")
			local value = `at'[1,`pos']
		}
		mat `xmean'[1,`col'] = `value'	
	}
	return add  // preserves matrices created by ProcessEstMat program
	return mat xmean = `xmean'
end


program define MakeXMeanMat_ordered , rclass
	args eq b at
	local ncol = colsof(`b')
	local colnames : colnames `b'
	tempname xmean
	mat `xmean' = `b'*.
	mat colnames `xmean' = `colnames'
	forval col = 1/`ncol' {
		local name : word `col' of `colnames'
		if "`name'"=="_cons"  {
			local cons = `b'[1,`col']
			local value = cond(`cons'==0,0,-1)
		}
		else {
			local value = `at'[1,`col']
		}
		mat `xmean'[1,`col'] = `value'	
	}
 	return add  // preserves matrices created by ProcessEstMat program
	return mat xmean = `xmean'
end

		   
program define MakeXMeanMat_difficult	, rclass
	version 8
	di as error "Subroutine MakeXMeanMat_difficult not implemented yet"
	error 198
end


*============================================================
*
*	[5]  LINEAR PREDICTION  --- GenXB_ subroutines
*
*============================================================


program define GenXB_normal  , rclass
	version 8.2
	syntax varlist [fweight pweight iweight /] [ , method(string) change(real 0) blist(string) xlist(string) offset(string) cons * ]
	if `"`weight'"'!=""			local weight w(`exp')
	if `"`offset'"'!=""			local offset offset(`offset')
	gettoken treat touse : varlist
	return clear
	tempname b x xb
	mat `b' = `blist'
	if "`method'"=="at" {
		GenXB_Mat `treat' `touse'  , b(`b') x(`xlist') change(`change') `weight' `offset' `cons'
		scalar `xb' = r(xb)
		return scalar xb1 = `xb'
	}
	else {
		GenXB_Var `treat' `touse' `xlist' , b(`b') change(`change')  `weight' `offset' `cons'  `options'
		return local xb1 `xlist'
	}
end


program define GenXB_multieq , rclass
	version 8.2
	syntax varlist [iweight /] [ ,  method(string) change(real 0)  blist(string) xlist(string) offset(string) cons * ]
	if `"`weight'"'!=""			local weight w(`exp')
	if `"`offset'"'!=""			local offset offset(`offset')
	gettoken treat touse : varlist
	return clear
	tempname b x xb
	local neq : word count `blist'
	forval eq = 1/`neq' {
		local bvec : word `eq' of `blist'
		local xvec : word `eq' of `xlist'
		mat `b' = `bvec'
		if "`method'"=="at" {
			GenXB_Mat `treat' `touse'  , b(`b') x(`xvec') change(`change') `weight' `offset' `cons'
			scalar `xb' = r(xb)
			return scalar xb`eq'= `xb'
		}
		else {
			GenXB_Var `treat' `touse' `xvec' , b(`b') change(`change') `weight' `offset' `cons' `options' eq(`eq')
			return local xb`eq'  `xvec'
		}
	}
end

program define GenXB_ordered
	GenXB_multieq `0'
end

program define GenXB_select
	GenXB_multieq `0'
end

  
program define GenXB_Mat , rclass
	version 8
	syntax varlist [ , change(real 0) b(string) x(string) offset(string) cons w(varname) * ]
	tempname xb mat	
	if "`cons'"!="" {
		local ncol = colsof(`b')
		scalar `xb' = `b'[1,`ncol']
		return scalar xb = `xb'
		exit
	}
	gettoken treat touse  : varlist
	// Taking care of dummies option
	mat `mat'=`x''
	if "`s(D_`treat')'"!=""	{
		local dvarlist `s(D_`treat')'
		local dvarlist : subinstr local dvarlist "`treat'" "" , all word
		foreach dvar in `dvarlist' {
			local pos = rownumb(`mat', "`dvar'" )
			if `pos'<=rowsof(`mat') & `pos'>0 mat `mat'[`pos',1]=0
		}
	}
	mat `mat' = `b'*`mat'
	scalar `xb' = `mat'[1,1]
	if "`offset'"!=""  {
		scalar `xb' = `xb' + `offset'
	}
	local beta = colnumb(`b',"`treat'")
	if   `beta'!=. 	local beta = `b'[1,`beta']
	else local beta = 0
	scalar `xb' = `xb' + `change'*`beta'
	return scalar xb = `xb'
end


program define GenXB_Var , rclass
	version 8
	syntax varlist [ , change(real 0) b(string) x(string) offset(varname) cons w(varname) eq(integer 0)  * ]
	gettoken treat rest  : varlist
	gettoken touse xbvar : rest
	capture assert `treat'==0 | `treat'==1 if `touse'
	local isdummy = (_rc==0)
	tempvar  xb
	tempname mat coef
	// Baseline probability
	if "`cons'"!="" {
		local pos = colsof(`b')
		if "`s(type)'"=="ordered" & `eq'<`s(neq)' {
			local pos = `pos'-(`s(neq)'-`eq')
			di "Pos-(s(neq)-eq = `pos'-(`s(neq)'-`eq')"	 `pos'-(`s(neq)'-`eq')
		}
		local beta = `b'[1,`pos']
		qui gen double `xb' = `beta' if `touse'
		return local xb `xb'
		exit
	}
	// Preparing the matrix for calculating the linear prediction
	mat `coef' = `b'
	// Taking care of dummies option
	if "`s(D_`treat')'"!=""	{
		local dvarlist `s(D_`treat')'
		local dvarlist : subinstr local dvarlist "`treat'" "" , all word
		foreach dvar in `dvarlist' {
			local pos = colnumb(`coef', "`dvar'" )
			if `pos'<=colsof(`coef') & `pos'>0 mat `coef'[1,`pos']=0
		}
	}

	if "`offset'"!="" {
		tempname add
		mat `add' = J(1,1,1)
		mat colnames `add' = `offset'
		mat `coef' = `add' , `coef'
	}
	// Linear prediction
	mat score double `xb' = `coef'  if `touse'==1 , forcezero
	// Manipulating the linear prediction
	local beta = colnumb(`b',"`treat'")
	if   `beta'!=.	local beta = `b'[1,`beta']
	else local beta = 0
	if `isdummy'==1 {
		if `change'==1	 qui replace `xb' = `xb' + `beta'  if `touse'==1 & `treat'==0
		else 			 qui replace `xb' = `xb' - `beta'  if `touse'==1 & `treat'==1
	}
	else {
		qui replace `xb' = `xb' + `change'*`beta'  if `touse'==1
	}
	qui replace `xbvar' = `xb'
	return add
	*return local xb `xb'
end


*============================================================
*
* [6] CalcME_  SUBROUTINES CALCULATING PARTIAL EFFECTS AND STANDARD ERRORS
*
*============================================================


program define CalcME_B_at , rclass
	args hat1 hat0 x1 x0
	tempname me
	scalar `me' = (`hat1' - `hat0')/(`x1'-`x0')
	return scalar me = `me'
end


program define CalcME_B_av , rclass
	args hat1 hat0 x1 x0 touse weight
	tempvar me
	tempname b mean
	qui gen double `me' = (`hat1' - `hat0')/(`x1'-`x0') if `touse'==1
	qui su `me' if `touse'==1 `weight'
	scalar `mean' = r(mean)
	return scalar me = `mean'
end


program define CalcME_SE_at	, rclass
	args var phi1 phi0 x1 x0 xmat
	tempname vec add
	mat `vec' = `xmat'*(`phi1'-`phi0')/(`x1'-`x0')
	local pos = colnumb(`xmat',"`var'")
	if `pos'!=. {
		scalar `add' = `vec'[1,`pos']
		scalar `add' = `add'+(`x1'*`phi1'-`x0'*`phi0')/(`x1'-`x0')
		mat `vec'[1,`pos'] = `add'
	}
	return mat vec = `vec'
end


program define CalcME_SE_av	, rclass
	args var phi1 phi0 x1 x0 xmat  markvar  weight
	tempname vec add cons
	tempvar phivar addvar
	local xvars : colnames `xmat'
	local xvars : subinstr local xvars "_cons" "" , word all
	local ncol = colsof(`xmat')
	local pos : word count `xvars'
 	qui gen double `phivar' = (`phi1'-`phi0')/(`x1'-`x0') if `markvar'
	mat vecaccum `vec' = `phivar' `xvars' if `markvar' , nocons
	qui count if `markvar'==1
	local numobs = r(N)
	mat `vec' = `vec' / `numobs'
	// Adding constants	
	CalcMean `phivar' if `markvar' `weight'
	local pos = colnumb(`xmat',"_cons")
	if `pos'!=. {
		mat `cons' = `xmat'[1,`pos'..`ncol']
		mat `cons' = `cons'*r(mean)
		mat colnames `cons' = _cons
		mat `vec' = `vec' , `cons'
	}
	// Taking care of diagonal elements
	local pos : list posof "`var'" in xvars
	if `pos'!=0 {
		scalar `add' = `vec'[1,`pos']
		qui gen double `addvar' = (`x1'*`phi1'-`x0'*`phi0')/(`x1'-`x0')
		CalcMean `addvar' if `markvar' `weight'
		scalar `add' = `add'+ r(mean)
		mat `vec'[1,`pos'] = `add'
	}
	return mat vec = `vec'
end


program define CalcMean , rclass
	version 8
	syntax varlist [if/] [fw pw iw aw /] [ , n(integer 0) ]
	tempvar varsum wgtsum 
	tempname mean
 	if "`exp'"=="" {
		qui gen double `varsum' = sum(`varlist'*`if')
		scalar `mean' = `varsum'[_N]		
		if `n'==0 {
			qui count if `if'==1
			scalar `mean' = `mean'/r(N)
		}
		else scalar `mean' = `mean'/`n'
	}
	else {
		qui gen double `varsum' = sum(`varlist'*`exp'*`if')
		qui gen double `wgtsum' = sum(`exp'*`if')
		scalar `mean' = `varsum'[_N]/`wgtsum'[_N]
	}
	return scalar mean = `mean'
end


*============================================================
*
* [7] CDF AND DENSITY --- GenFx_ subroutines
*
*============================================================


program define GenFx_log , sclass
	sret local cdf  exp(`2'*`r(xb1)')
	sret local dens1  `2'*exp(`2'*`r(xb1)')
*	sret local title "exp(xb) (xb: linear prediction)"
end


program define GenFx_loglog , sclass
	sret local cdf  exp(-exp(-`r(xb1)'))
	sret local dens1   exp(-exp(-`r(xb1)'))*exp(-`r(xb1)')
*	sret local title "exp(-exp(-xb)) (xb: linear prediction)"
end

program define GenFx_logc , sclass
	sret local cdf  	1-exp(`r(xb1)')
	sret local dens1	-exp(`r(xb1)')
*	sret local title "1-exp(xb) (xb: linear prediction)"
end

	  
program define GenFx_nbinomial , sclass
	sret local cdf		`cdf'
	sret local dens1	(`cdf')*(1+`cdf')
*	sret local title "exp(xb)/(1-exp(xb)) (xb: linear prediction)"
end



program define GenFx_power , sclass
	local power = 1/`s(power)'
	sret local cdf			(`r(xb1)')^`power'
	sret local dens1	`power'*(`r(xb1)')^(`power'-1)
*	sret local title "(xb)^(1/`s(power)') (xb: linear prediction)"
end



program define GenFx_opower , sclass
	local power = 1/`s(power)'
	local xb			(1+`power'*`r(xb1)')^(1/`power')
	sret local cdf		(`xb')/(1+(`xb'))
	sret local dens1	(1/(1+(`xb'))^2)*(1+`power'*`r(xb1)')^((1/`power')-1)
*	sret local title "1/(1+(1+xb/`s(power)')^(-`s(power)') (xb: linear prediction)"
end



program define GenFx_probit , sclass
    sret local cdf		normprob(`2'*`r(xb1)')
    sret local dens1	`2'*normd(`2'*`r(xb1)')
end


program define GenFx_heckprob , sclass
	local depvar = e(depvar)
	local depvar : word 1 of `depvar'
	//GenFx_probit `depvar' `e(rho)'
	GenFx_probit `depvar' 1
end


program define GenFx_logit , sclass
	sret local cdf	 invlogit(`2'*`r(xb1)')
	sret local dens1 `2'*(invlogit(`2'*`r(xb1)'))*(1-invlogit(`2'*`r(xb1)'))
end


program define GenFx_logistic
	GenFx_logit `0'
end


program define GenFx_cloglog , sclass
	sret local cdf		invcloglog(`2'*`r(xb1)')
	sret local dens1	-`2'*(1-invcloglog(`2'*`r(xb1)'))*exp(`2'*`r(xb1)')
end

 
program define GenFx_oprobit , sclass
	args out
	local ncat = e(k_cat)
	if `out'>`ncat' {
		di as error "Requested outcome larger than number of categories"
		error 198
	}
	local neq = cond("`e(cmd)'"=="ologit2", `s(neq)', `s(neq)')
	forval i = 1/`neq' {
		sret local dens`i' 0
	}
	local low = `out'-1
 	if `out'==1 {
		sret local cdf			1-normprob(`r(xb1)')
		sret local dens1		-normd(`r(xb1)')
		exit
	}
 	else if `out'==`ncat' {
		sret local cdf			normprob(`r(xb`low')')
		sret local dens`low'	normd(`r(xb`low')')
		exit
	}
	else {
		sret local cdf			normprob(`r(xb`low')')-normprob(`r(xb`out')')
		sret local dens`low'	normd(`r(xb`low')')
		sret local dens`out'	-normd(`r(xb`out')')
	}
end


program define GenFx_ologit , sclass
	args out depvar	
	local ncat = e(k_cat)
	if `out'>`ncat' {
		di as error "Requested outcome larger than number of categories"
		error 198
	}
	local neq = cond("`e(cmd)'"=="gologit2", `s(neq)', `s(neq)')
	forval i = 1/`neq' {
		sret local dens`i' 0
	}
	local low = `out'-1
	if `out'==1 {
		sret local cdf		 1-invlogit(`r(xb1)')
		sret local dens1	 -invlogit(`r(xb1)')*(1-invlogit(`r(xb1)'))
		exit
	}
	else if `out'==`ncat' {
		sret local cdf		 invlogit(`r(xb`low')')
		sret local dens`low' invlogit(`r(xb`low')')*(1-invlogit(`r(xb`low')'))
		exit
	}
	else {
		sret local cdf		 invlogit(`r(xb`low')')-invlogit(`r(xb`out')')
		sret local dens`low' invlogit(`r(xb`low')')*(1-invlogit(`r(xb`low')'))
		sret local dens`out' - invlogit(`r(xb`out')')*(1-invlogit(`r(xb`out')'))
	}
end



program define GenFx_ocloglog , sclass
	args out 
	if `out'>`s(nout)' {
		di as error "Requested outcome larger than number of categories"
		error 198
	}
	local neq = cond("`e(cmd)'"=="ologit2", `s(neq)', `s(neq)')
	forval i = 1/`neq' {
		sret local dens`i' 0
	}
	local low = `out'-1
	if `out'==1 {
		sret local cdf			1-invcloglog(`r(xb1)')
		sret local dens1		(1-invcloglog(`r(xb1)'))*exp(`r(xb1)')
		exit
	}
	else if `out'==`s(nout)' {
		sret local cdf			invcloglog(`r(xb`low')')
		sret local dens`low'	-(1-invcloglog(`r(xb`low')'))*exp(`r(xb`low')')
		exit
	}
	else {
		sret local cdf			invcloglog(`r(xb`low')')-invcloglog(`r(xb`out')')
		sret local dens`low'	-(1-invcloglog(`r(xb`low')'))*exp(`r(xb`low')')
		sret local dens`out'	(1-invcloglog(`r(xb`out')'))*exp(`r(xb`out')')
	}
end



program define GenFx_ologlog , sclass
	args out
	if `out'>`s(nout)' {
		di as error "Requested outcome larger than number of categories"
		error 198
	}
	local neq = cond("`e(cmd)'"=="ologit2", `s(neq)', `s(neq)')
	forval i = 1/`neq' {
		sret local dens`i' 0
	}
	local low = `out'-1
	if `out'==1 {
		sret local cdf			invcloglog(-`r(xb1)')
		sret local dens1		-(1-invcloglog(-`r(xb1)'))*exp(-`r(xb1)')
		exit
	}
	else if `out'==`s(nout)' {
		sret local cdf			1-invcloglog(-`r(xb`low')')
		sret local dens`low'	(1-invcloglog(-`r(xb`low')'))*exp(-`r(xb`low')')
		exit
	}
	else {
		sret local cdf			invcloglog(-`r(xb`out')')-invcloglog(-`r(xb`low')')
		sret local dens`low'	(1-invcloglog(-`r(xb`low')'))*exp(-`r(xb`low')')
		sret local dens`out'	-(1-invcloglog(-`r(xb`out')'))*exp(-`r(xb`out')')
	}
end


program define GenFx_ocauchit , sclass
	args out
	if `out'>`s(nout)' {
		di as error "Requested outcome larger than number of categories"
		error 198
	}
	local neq = cond("`e(cmd)'"=="ologit2", `s(neq)', `s(neq)')
	forval i = 1/`neq' {
		sret local dens`i' 0
	}
	local low = `out'-1
	if `out'==1 {
		sret local cdf		 .5+(1/_pi)*atan(-(`r(xb1)'))
		sret local dens1	 -(1/_pi)/(1+(`r(xb1)')^2)
		exit
	}
	else if `out'==`s(nout)' {
		sret local cdf		 (1-.5-(1/_pi)*atan(-`r(xb`low')'))
		sret local dens`low' (1/_pi)/(1+(`r(xb`low')')^2)
		exit
	}
	else {
		sret local cdf		 (1/_pi)*atan(`r(xb`low')')-(1/_pi)*atan(`r(xb`out')')
		sret local dens`low' (1/_pi)/(1+(`r(xb`low')')^2)
		sret local dens`out' -(1/_pi)/(1+(`r(xb`out')')^2)
	}
end



program define GenFx_mlogit , sclass
	args  out
	if "`e(ibasecat)'"!=""	local base  = e(ibasecat)
	else local base = e(ibaseout)
	local i = `out'-(`out'>`base')
	// denominator
	local denom 1
	forval eq = 1/`s(neq)' {
		local denom `denom'+exp(`r(xb`eq')')
	}
	if `out'==`base'	sret local cdf "(1/(`denom'))"
	else 			sret local cdf (exp(`r(xb`i')')/(`denom'))
	forval eq = 1/`s(neq)' {
		if `out'==`base' {
			sret local dens`eq' "(-exp(`r(xb`eq')')/(`denom')^2)"
		}
		else {
			if `i'==`eq' {
				sret local dens`eq' "(exp(`r(xb`i')')/(`denom')-exp(`r(xb`i')')^2/(`denom')^2)"
			}
			else  {
				sret local dens`eq' "(-exp(`r(xb`i')')*exp(`r(xb`eq')')/(`denom')^2)"
			}
		}	
	}
end



program define GenFx_poisson , sclass
	GenFx_log `0'
end



program define GenFx_nbreg , sclass
	GenFx_log `0'
end



program define GenFx_zip , sclass
	version 8
	local mu "exp(`r(xb1)')"
	if "`e(inflate)'"=="logit" {
		local cuminf 1/(1+exp(-`r(xb2)'))
		local deninf (`cuminf')*(1-`cuminf')
	}
	else {
		local cuminf normprob(`r(xb2)')
		local deninf normd(`r(xb2)')
	}
	sret local cdf   `mu'*(1-`cuminf')
	sret local dens1 `mu'*(1-`cuminf')
	sret local dens2 -`mu'*`deninf'
end



program define GenFx_zinb, sclass
	GenFx_zip `0'
end



program define GenFx_biprobit , sclass
	args out
	local rho = e(rho)
	local srh = sqrt(1-`rho'^2)
	local A
	local C 
	local B 
	if `out'<3  local A -
	if `out'==1 | `out'==3 	local B -
	if `out'==2 | `out'==3 	local C -
	sret local cdf  binorm(`A'`r(xb1)',`B'`r(xb2)',`C'`rho')
	sret local dens1  (`A'normd(`A'`r(xb1)')*normprob((`B'`r(xb2)'-`C'`rho'*`A'`r(xb1)')/`srh'))
	sret local dens2  (`B'normd(`B'`r(xb2)')*normprob((`A'`r(xb1)'-`C'`rho'*`B'`r(xb2)')/`srh'))
end


******* SELECTION MODELS  **************


program define GenFx_truncreg , sclass
	version 8
	args v1
	local sig = `e(sigma)'
	local ul = e(ulopt)
	local ll = e(llopt)
	if `ll'==. local vll = -10000
	else local vll  (`ll'-`r(xb1)')/`sig'
	if `ul'==. local vul = 10000
	else local vul  (`ul'-`r(xb1)')/`sig'
	local mills  "(normd(`vll')-normd(`vul'))/(normprob(`vul')-normprob(`vll')) "
	sret local cdf "`r(xb1)'+`sig'*`mills'"
	sret local dens1 "1+`mills'-(`mills')^2"
end

program define GenFx_heckman , sclass
	local sig = `e(sigma)'*`e(rho)'
	local mills  normd(`r(xb2)')/normprob(`r(xb2)')
	sret local cdf		(`r(xb1)'+`sig'*`mills')
	sret local dens1 1
	sret local dens2 -`sig'*(`r(xb2)'*(`mills')+(`mills')^2 )
end


program define GenFx_tobit , sclass
	// handling version 8 and 9 incompatibility
	capture di _b[sigma:_cons]
	if _rc==0  local sig = _b[sigma:_cons]
	else local sig = _b[_se]
	local ul = e(ulopt)
	local ll = e(llopt)
	if `ul'==. local ul = 0
	if `ll'==. local ll = 0
	if `ll'==0 local vll = -10000
	else local vll  (`ll'-`r(xb1)')/`sig'
	if `ul'==0 local vul = 10000
	else local vul  (`ul'-`r(xb1)')/`sig'
	GenFx_Censor , depvar(`depvar') ul(`ul') vul(`vul') ll(`ll') vll(`vll') sig(`sig')
end


program define GenFx_cnreg , sclass
	local depvar = e(depvar)
	local censor = e(censored)
	// handling version 8 and 9 incompatibility
	capture di _b[sigma:_cons]
	if _rc==0  local sig = _b[sigma:_cons]
	else local sig = _b[_se]
	local  ll "((`censor'==-1)*`depvar')"
	local  ul "((`censor'==1)*`depvar')"
	local vll "((`censor'==-1)*( `ll'-`r(xb1)')/`sig'+(1-`censor')*(-10000))"
	local vul "((`censor'==-1)*(`ull'-`r(xb1)')/`sig'+(1-`censor')*( 10000))"
	GenFx_Censor , depvar(`left' `right') ul(`ul') vul(`vul') ll(`ll') vll(`vll') sig(`sig')
end


program define GenFx_intreg , sclass
	args left right
	local sig = e(sigma)
	local censor "(`left'!=`right')"
	local  ll "(`censor'*`left')"
	local  ul "(`censor'*`right')"
	local vll "(`censor'*( `ll'-`r(xb1)')/`sig'+(1-`censor')*(-10000))"
	local vul "(`censor'*(`ull'-`r(xb1)')/`sig'+(1-`censor')*( 10000))"
	GenFx_Censor , depvar(`left' `right') ul(`ul') vul(`vul') ll(`ll') vll(`vll') sig(`sig')
end

 
program define GenFx_Censor , sclass
// Source: Long Regression models.... p.213.
	version 8
	syntax [, depvar(string) ll(string) ul(string) vll(string) vul(string) sig(real 0)]
	local cumu11 "`ll'*normprob(`vll')+`ul'*normprob(-`vul')"
	local cumu11 "`cumu11' + (normprob(`vul')-normprob(`vll'))*`r(xb1)'"
	local cumu11 "`cumu11' + `sig'*(normd(`vll')-normd(`vul'))"
	sret local cdf (`cumu11')
	sret local dens1 "normprob(`vul')-normprob(`vll')"
end




*============================================================
*
* [8] ALL OTHER SUBROUTINES
*
*============================================================


program define CheckOut , rclass
	version 8
		local nout : word count `0'
		if `nout'>1 {
			di as error "Only one number can be specified in the outcome() option"
			error 198
		}
		capture confirm integer number `0'
		if _rc!=0 {
			di as red "the outcome() option must contain an integer number"
			error 198
		}
		if `0'<1 {
			di as red "the number specified in the outcome() option must be positive"
			error 198
		}
			
		local outcome = `0'
		if  `s(nout)'==1 {
			di as text "outcome() option ignored because `s(model)' is a single-outcome model"
			di
			local outcome 1
		}
		else {
			if `outcome'>`s(nout)' {
				di as error "Invalid outcome() option"
				error 125
			}
		}
	return local numlist = `outcome'
end


program define AtList , rclass
	version 8
	syntax  , at(string asis) varlist(varlist)
	if "`s(dummies)'"!="" local dumlist = s(dummies)
	// Searching for mean median zero
	local at : subinstr local at "=" " " , all
	gettoken first : at
	if `"`first'"'=="mean" | `"`first'"'=="median" | `"`first'"'=="zero" {
		if `"`first'"'=="median"	return local atstat p50
		else return local atstat `first'
		gettoken first at : at
	}
	else return local atstat mean
	// Parsing var = value part
		while `"`at'"'!="" {
			gettoken varname at : at
			capture confirm  var `varname'
			if _rc!=0 {
				di as error "Invalid at() option: "`varname' must be a numeric variable"
				error 198
			}
			local test : subinstr local varlist "`varname'" "" , count(local c)	all
			if `c'!=1 {
				di as error "Invalid at() option: "`varname' is not (or appears twice) among the explanatory variables"
				error 198
			}
			gettoken value at : at
			if "`value'"=="=" | "`value'"=="==" {
				gettoken value at : at
			}
			capture confirm number `value'
			if _rc!=0 {
				di as error "Invalid at() option: `value' (which follows `varname') must be a number"
				error 198
			}
			// Accumulating list
			local atvarlist `atvarlist' `varname'
			local atnumlist `atnumlist' `value'
		}
		if "`: word count `atvarlist' '"!="`: word count `atnumlist' '" {
			di as error "Invalid at() option: Number of variables not equal to number of values"
			error 198
		}
		return local atvarlist `atvarlist'
		return local atnumlist `atnumlist'
end


program define DumList , sclass
	tempname b
	mat `b' = e(b)
	local xvars : colnames `b'
	local xvars : list uniq xvars

	// Step 1: Recognizing lists of dummies as tokens
	tokenize "`0'" , p(" \ ")
	local list `0' 
	local n = 1
	while `"`list'"'!="" {
		gettoken token list : list
		if "`token'"=="\" {
			if "`tokens`n''"!="" local ++n
		}
		else {
			local tokens`n' `tokens`n'' `token'
		}
	}
	// Step 2: Unabbreviating lists of dummies & eliminating dropped vars
	forval i = 1/`n' {
		capt tsunab list`i' : `tokens`i''
		if _rc!=0 {
			sret local error "Invalid dummies() option: `tokens`i'' not among the regressors"
			exit
		}
		local list`i' : list list`i' & xvars
	}
	// Step 3: Adding the lists to s(D_) locals
	//  Again a loop - reason: tsunab overwrites s macros!
	forval i = 1/`n' {
		foreach var in `list`i'' {
			sret local D_`var'  `list`i''
			local dummies `dummies' `var'
		}
	}
	local dummies : list uniq dummies
	sret local dummies `dummies'
end


program define CalcUnit , rclass
	version 8
	args var touse
	// This part determining unit of measurement is taken from codebook.ado
	tempvar p
	scalar `p' = 1
	capture assert float(`var') == float(round(`var',1)) if `touse'
	if _rc == 0 {
		while _rc == 0 {
			scalar `p' = `p'*10
			capture assert float(`var') == float(round(`var',`p')) if `touse'
		}
		scalar `p' = `p'/10
	}
	else {
		while _rc {
			scalar `p' = `p'/10
			capture assert float(`var') == float(round(`var',`p')) if `touse'
		}
	}
	return scalar unit = `p'
end

 
		
program define EqLabel , sclass
	version 8
	args out touse
	if "`s(model)'"=="biprobit" {
		local label : word `out' of  p00 p01 p10 p11
		sret local name "`label'"
		sret local cat  "`label'"
		exit
	}
	if "`out'"=="" {
		di as error "Error when calling subroutine EqLabel: option out() not specified"
		error 198
	}
	local depvar = e(depvar)
	if `: word count `depvar''>1 {
		local depvar : word 1 of `e(depvar)'
	}
	tempname mat
	qui tab `depvar' if `touse' , matrow(`mat')
	local cat = `mat'[`out',1]
	local label : label (`depvar') `cat'
	if `"`label'"'=="" {
		local label "p`cat'"
	}
	sret local cat  "`cat'"
	sret local lab "`label'"
end



program define SendVersion , sclass
	version 8
	sret local margeff_version = 218
end
	
