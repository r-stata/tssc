program define r2c, eclass //history and version information at end of file

version 11

syntax [, noDp noOffsetadj DEVonly ESTDisp GNBCons]

preserve

local cmnds poisson zip tpoisson nbreg gnbreg zinb tnbreg glm

local cmnd "`e(cmd)'"

if ("`e(mi)'"=="mi") local cmnd "`e(ecmd_mi)'"

/*exit/stop program conditions*/

if `:list posof "`cmnd'" in cmnds'==0 {

	di "{err}{cmd:r2c} only works as a postestimation command for {cmd:poisson}, {cmd:nbreg}, {cmd:zip}, {cmd:zinb}, " ///	
	"{cmd:tpoisson}, {cmd:tnbreg}, {cmd:gnbreg}, and {cmd:glm}."
	
	exit
}

if `:list posof "`cmnd'" in cmnds'==8 & "`e(varfunct)'"!="Poisson" & "`e(varfunct)'"!="Neg. Binomial" {

	di "{err}{cmd:r2c} only works as a postestimation command for {cmd:glm} with count variance functions (i.e., Poisson and Neg. Binomial)."
	
	exit
}

if "`e(prefix)'"=="svy" & "`e(subpop)'"=="" & regexm("`e(cmdline)'"," if ")==1 {

	di "{err}{cmd:r2c} only allows {it:if} statements with the {cmd:svy} prefix within the {opt subpop(varname)} option (see {manhelp svy R})."
	
	exit
	
}

if "`estdisp'"!="" & "`gnbcons'"!="" {

	di "{err}Only one of {opt estdisp} or {opt gnbcons} can be selected with {cmd:gnbreg}."
	
	exit
	
}


local dp dp

if("`nodp'"!="") local dp ""

local offadj offadj

if("`offsetadj'"!="") local offadj ""

local POI="no"

if(`:list posof "`cmnd'" in cmnds'<4) local POI="yes"

if(`:list posof "`cmnd'" in cmnds'==8 & "`e(varfunct)'"=="Poisson") local POI="yes"

/*MI-based r2c computation*/

if "`e(mi)'"=="mi" {

	tempname combine idsum extra dps 
	
	local devs r(constdev) r(modeldev) r(McF) r(dev_r2a) r(dev_r2)
	
	if("`devonly'"=="") local extras r(expvar) r(constpear) r(modelpear)  r(exp_r2) r(cor_r2) r(pear_r2)
	
	if("`nodp'"=="" & "`POI'"=="no") local dpnm r(constdp) r(modeldp) r(dp_r2)
	
	matrix `combine'=vecdiag(I(5))
	
	matrix `extra'=vecdiag(I(6))
	
	matrix `dps'=vecdiag(I(3))
	
	matrix colnames `combine'=`devs'
	
	if("`devonly'"=="") matrix colnames `extra'=`extras'
	
	if("`nodp'"=="" & "`POI'"=="no") matrix colnames `dps'=`dpnm'
	
	tokenize `devs'
	
	local numbs `e(m_est_mi)'
	
	qui mi describe
	
	local repl `r(ivars)'
	
	if "`e(prefix)'"=="svy" { 
	
		qui mi svyset
		
		local svysets `r(settings)'
		
		qui mi unset
		
		qui svyset `r(settings)'
		
	}
	
	else {
	
		qui mi unset
		
	}
	
	local origcmdline `e(cmdline)'
		
	foreach x of local numbs {
		
		qui {
		
			local cmdadj`x' `origcmdline'
		
			foreach y of local repl {
			
				local cmdadj`x'=regexr("`cmdadj`x''"," `y' "," `y'_`x'_ ") 					
				
			}
		
			`cmdadj`x''
			
			r2c_est, `dp' `offadj' `devonly' `estdisp' `gnbcons'
			
			tempname combine`x'
			
			matrix `combine`x''=vecdiag(I(5))
			
			matrix `combine'=(`combine' \ `combine`x'')
			
			foreach y of local devs {
			
				matrix `combine'[`=`x'+1',`:list posof "`y'" in devs']=`y'
			}
			if "`devonly'"=="" {
			
				tempname extra`x'
				
				matrix `extra`x''=vecdiag(I(6))
				
				matrix `extra'=(`extra' \ `extra`x'')
				
				foreach y of local extras {
				
					matrix `extra'[`=`x'+1',`:list posof "`y'" in extras']=`y'
					
				}
				
			}
			
			if "`nodp'"=="" & "`POI'"=="no" {
			
				tempname dps`x'
				
				matrix `dps`x''=vecdiag(I(3))
				
				matrix `dps'=(`dps' \ `dps`x'')
				
				foreach y of local dpnm {
				
					matrix `dps'[`=`x'+1',`:list posof "`y'" in dpnm']=`y'
					
				}
				
			}
			
		}
		
	}
	
	matrix `combine'=`combine'[2...,1...]
	
	matrix `idsum'=vecdiag(I(`:list sizeof numbs'))
	
	matrix `combine'=`idsum'*`combine'*(1/`:list sizeof numbs')
	
	if "`devonly'"=="" {
	
		matrix `extra'=`extra'[2...,1...]
		
		matrix `extra'=`idsum'*`extra'*(1/`:list sizeof numbs')
		
	}
	
	if "`nodp'"!="" & "`POI'"=="no" {
	
		matrix `dps'=`dps'[2...,1...]
		
		matrix `dps'=`idsum'*`dps'*(1/`:list sizeof numbs')
		
	}
	
	ereturn scalar dev_r2=`combine'[1,5]
	
	ereturn scalar dev_r2a=`combine'[1,4]
	
	ereturn scalar McF=`combine'[1,3]
	
	if "`devonly'"=="" {
	
		ereturn scalar pear_r2=`extra'[1,6]
		
		ereturn scalar cor_r2=`extra'[1,5]	
		
		ereturn scalar exp_r2=`extra'[1,4]
				
	}
	
	ereturn scalar constdev=`combine'[1,1]
	
	ereturn scalar modeldev=`combine'[1,2]
	
	if "`devonly'"=="" {
	
		ereturn scalar modelpear=`extra'[1,3]
		
		ereturn scalar constpear=`extra'[1,2]
		
		ereturn scalar expvar=`extra'[1,1]
						
	}
	
	if "`nodp'"=="" & "`POI'"=="no" {
	
		ereturn scalar dp_r2=`dps'[1,3]	
		
		ereturn scalar modeldp=`dps'[1,2]
		
		ereturn scalar constdp=`dps'[1,1]
						
	}
		
}

/*regular r2c computation*/

else {

	r2c_est, `dp' `offadj' `devonly' `estdisp' `gnbcons'
	
	ereturn scalar McF=r(McF)
	
	ereturn scalar dev_r2a=r(dev_r2a)
	
	ereturn scalar dev_r2=r(dev_r2)	
	
	if "`devonly'"=="" {
	
		ereturn scalar pear_r2=r(pear_r2)
		
		ereturn scalar cor_r2=r(cor_r2)	
		
		ereturn scalar exp_r2=r(exp_r2)
		
	}	
	
	ereturn scalar modeldev=r(modeldev)
	
	ereturn scalar constdev=r(constdev)	
	
	if "`devonly'"=="" {
	
		ereturn scalar modelpear=r(modelpear)
		
		ereturn scalar constpear=r(constpear)
		
		ereturn scalar expvar=r(expvar)
				
	}
	
	if "`nodp'"=="" & "`POI'"=="no" {
	
		ereturn scalar dp_r2=r(dp_r2)
		
		ereturn scalar modeldp=r(modeldp)
		
		ereturn scalar constdp=r(constdp)
		
	}
	
}
	
return clear

Replay, `devonly' `dp'

restore

end

/*r2c computation command*/

program define r2c_est, rclass

syntax [, dp offadj devonly estdisp gnbcons]

estimates store full_r2c

tempvar llmxi predp overallp diff mudiff mu mumean wt alpha keeper dv

local cmnds poisson zip tpoisson nbreg gnbreg zinb tnbreg glm

local cmnd "`e(cmd)'"

if ("`e(mi)'"=="mi") local cmnd "`e(ecmd_mi)'"

qui gen `dv'=`e(depvar)' 

/*generate adjusted "keeper" indicator for estimation sample that can be adjusted for "subpop()" option*/

qui gen `keeper'=e(sample)

/*macros to guide r2c program to appropriate computation*/

local POI="no"

if(`:list posof "`cmnd'" in cmnds'<4) local POI="yes"

if(`:list posof "`cmnd'" in cmnds'==8 & "`e(varfunct)'"=="Poisson") local POI="yes"

local GLM="no"

if(`:list posof "`cmnd'" in cmnds'==8) local GLM="yes"

local NB1="no"

if(`:list posof "`cmnd'" in cmnds'==4 & "`e(dispers)'"=="constant") local NB1="yes"

if(`:list posof "`cmnd'" in cmnds'==7 & "`e(dispers)'"=="constant") local NB1="yes"

local GNB="no"

if(`:list posof "`cmnd'" in cmnds'==5) local GNB="yes"

local ZI="no"

if(`:list posof "`cmnd'" in cmnds'==2 | `:list posof "`cmnd'" in cmnds'==6) local ZI="yes"

local OFST="no"

if("`offadj'"!="" & "`e(offset)'"!="") local OFST="yes"

if("`offadj'"!="" & "`e(offset1)'"!="") local OFST="yes"

local TNC="no"

if(`:list posof "`cmnd'" in cmnds'==3 | `:list posof "`cmnd'" in cmnds'==7) local TNC="yes"

/*incorporate weights*/

qui gen `wt'=1 if `keeper'

if "`e(wexp)'"!="" {

	local wexp "`e(wexp)'"
	
	gettoken eq wgt: wexp, parse(=)
	
	qui replace `wt'= `wgt' if `keeper'
	
	local wtype "`e(wtype)'"
	
	/*generate aweight macro for summing*/
	
	if("`wtype'"=="pweight") local wtype "aweight"
	
}

/*generate aweight macro for summing*/

if("`e(wtype)'"=="") local wtype "aweight"

/*adjust "keeper" for "svy, subpop():" syntax*/

if "`e(prefix)'"=="svy" & "`e(subpop)'"!="" {
 
	if (regexm("`e(subpop)'","if ")==0) replace `keeper'=`e(subpop)' & e(sample)
	
	if regexm("`e(subpop)'","if ")==1 { 
	
		local sub=regexr("`e(subpop)'","if ","")
	
		qui replace `keeper'=`sub' & e(sample)
		
	}
	
}	

/*end setup - begin computations of R2 indexes*/

qui {

	/*generalized negative binomial syntax to extract lnalpha() equation for lnalph macro and generate constraints
	to hold alpha constant*/
	
	if "`GNB'"=="yes" {
	
		local fulls: colfullnames e(b)
		
		local eqs: coleq e(b)
		
		local names: colnames e(b)
		
		tokenize `names'
		
		if `: list sizeof eqs'>`:list posof "lnalpha" in eqs' {
		
			forval x=`:list posof "lnalpha" in eqs'/`=`:list sizeof eqs'-1' {
			
				local coeff`x': word `x' of `fulls'
				
				local var`x': word `x' of `names'
				
				local part`x' _b[`coeff`x'']*`var`x''
				
				if("`estdisp'"=="") constraint `=`x'+900' _b[`coeff`x'']=`=_b[`coeff`x'']'
				
			}
			
		}
		
		if "`:word `:list sizeof eqs' of `names''"=="_cons" {
		
			local part`:list sizeof eqs' _b[`:word `:list sizeof eqs' of `fulls'']
			
			if("`estdisp'"=="") constraint `=`:list sizeof eqs'+900' _b[lnalpha:_cons]=`=_b[lnalpha:_cons]'
			
		}
		
		else if "`:word `:list sizeof eqs' of `names''"!="_cons" {
		
			local part`:list sizeof eqs' _b[`:word `:list sizeof eqs' of `fulls'']*`:word `:list sizeof eqs' of `names''
			
		}
		
		gen `alpha'=0 if `keeper'
		
		forval x=`:list posof "lnalpha" in eqs'/`:list sizeof eqs' {
		
			tempvar piece`x'
			
			gen `piece`x''=`part`x'' if `keeper'
			
			replace `alpha'=`alpha'+`piece`x''
			
		}
		
		replace `alpha'=exp(`alpha') if `keeper'
		
		replace `alpha'=exp(-13) if `=ln(`alpha')'<-13 & `keeper'
		
		replace `alpha'=exp(23) if `=ln(`alpha')'>23 & `keeper'
		
		local spot `:list posof "lnalpha" in eqs'
		
		if(`=`spot'-`:list sizeof eqs'-1'<1) local constr " constraints( `=`spot'+900'/`=`:list sizeof eqs'+900' )"
		
		if(`=`spot'-`:list sizeof eqs'-1'==1) local constr " constraints( `=`spot'+900' )"
		
		if("`gnbcons'"!="") local constr ""
		
		local lneq ``spot''
		
		if `spot'!=`:list sizeof eqs' {
		
			forval x=`=`spot'+1'/`=`:list sizeof eqs'-1' {
			
				local lneq: list lneq | `x'
				
			}
			
		}
		
		local remove "_cons"
		
		local lneq: list lneq-remove
		
		local lnalph " lnalpha(`lneq')"
		
		if("`gnbcons'"!="") local lnalph ""
		
		local DRP `=`:list posof "lnalpha" in eqs'+900'/`=`:list sizeof eqs'+900'
		
	}	
	
	/*negative binomial options macros*/
	
	if "`POI'"=="no" & "`GNB'"=="no" & "`GLM'"=="no" {	
	
		if "`NB1'"=="no" & "`estdisp'"=="" { 
		
			constraint 973 _b[lnalpha:_cons]=`=_b[lnalpha:_cons]'
			
		}
		
		if "`NB1'"=="yes" & "`estdisp'"=="" { 
			
			constraint 973 _b[lndelta:_cons]=`=_b[lndelta:_cons]'
			
		}
		
		local constr " constraints(973)"
		
		if ("`e(cmd)'"=="nbreg" | "`e(cmd)'"=="tnbreg") local nbdisp " d(`e(dispers)')"
		
	}
	
	/*generate zero-inflated macro*/
	
	if "`ZI'"=="yes" {
	
		local inflate " inflate( _cons )"
		
		if("`e(offset2)'"!="" & "`offadj'"!="") local inflate " inflate( _cons , offset( `e(offset2)') )"
		
		if("`e(inflate)'"=="probit") local inflate " `inflate' probit"
		
	}
	
	/*generate lower limit/truncation point macro*/
	
	if ("`TNC'"=="yes") local ll " ll(`e(llopt)')"
	
	/*generate offset variable and macro*/
	
	if "`OFST'"=="yes" {
	
		tempvar offsetvar 
		
		if "`GNB'"=="yes" | "`ZI'"=="yes" {
		
			gen `offsetvar'=`e(offset1)' if `keeper'
			
			local offset " offset(`offsetvar')"
			
		}
		
		else {
		
			gen `offsetvar'=`e(offset)' if `keeper'
			
			local offset " offset(`offsetvar')"
			
		}
		
	}
	
	/*generate glm command macros*/
		
	if "`GLM'"=="yes" { 
	
		if("`POI'"=="yes") local glmfam " family(poisson) link(log)"
		
		if("`POI'"=="no") local glmfam " family(nbinomial `e(a)') link(log)"
		
		if("`POI'"=="no" & "`estdisp'"!="") local glmfam " family(nbinomial ml) link(log)"
		
	}
		
	/*compute constant-only log-likelihood and mean estimate*/
	
	`e(cmd)' `dv' [`e(wtype)'`e(wexp)'] if `keeper', `offset' `ll' `constr' `lnalph' `nbdisp' `inflate' `glmfam'
	
	if("`offadj'"=="") local nooffset " nooffset"
	
	local kind " n"
	
	if("`GLM'"=="yes") local kind " mu"
	
	predict `mumean' if `keeper', `kind' `nooffset'
	
	local llmu=e(ll)
	
	estimates restore full_r2c
	
	/*model log likelihood*/

	local llmod=e(ll)
	
	/*obtain model log likelihood when svy: prefix used*/
	
	if "`e(prefix)'"=="svy" & "`GLM'"=="no" {
	
		local cmdline `e(command)'
		
		gettoken cmdlinens away: cmdline, parse(",") 		
		
		if "`ZI'"=="yes" { 
		
			local fullsvy: coleq e(b)
			
			local namesvy: colnames e(b)
			
			local numlist ""
			
			forval x=1/`:list sizeof fullsvy' {
			
				if word("`fullsvy'",`x')=="inflate" {
					
					local numlist "`numlist' `x'"
				
				}
				
				local inflatesvy ""
				
				foreach x of local numlist {
				
					local inflatesvy "`inflatesvy' `:word `x' of `namesvy''"
					
				}
				
				local inflatesvy `=regexr("`inflate'","_cons","`inflatesvy'")'
				
			}
			
		}
		
		`cmdlinens' [`e(wtype)'`e(wexp)'] if `keeper', `offset' `ll' `constr' `lnalph' `nbdisp' `inflatesvy'
		
		local llmod=e(ll)
		
		estimates restore full_r2c
	}	
	
	/*compute Poisson saturated log-likelihoods*/
	
	if "`POI'"=="yes" {
	
		gen `llmxi'= -`dv'+`dv'*ln(`dv')-lnfactorial(`dv') if `keeper'
		
		if("`TNC'"=="yes") replace `llmxi'= -`dv'+`dv'*ln(`dv')-lnfactorial(`dv') ///
		-ln(poissontail(`dv',`=`e(llopt)'+1')) if `keeper'	
		
		replace `llmxi'=0 if `dv'==0 & missing(`llmxi') & `keeper'
	}
		
	/*compute negative Binomial saturated log-likelihoods*/
	
	if "`POI'"=="no" {
	
		if "`GNB'"=="no" &  "`NB1'"=="no" {
		
			if "`GLM'"=="no" {			
				
				gen `alpha'=exp(_b[lnalpha:_cons]) if `keeper'
			
			}
			
			if "`GLM'"=="yes" {
			
				gen `alpha'=`e(a)'
				
			}
			
			replace `alpha'=exp(-13) if ln(`alpha')<-13	
			
		}
		
		if "`NB1'"=="no" {
		
			gen `llmxi'= ln(nbinomialp(`alpha'^-1,`dv',1/(1+`dv'*`alpha'))) if `keeper'				

			if("`TNC'"=="yes") replace `llmxi'= ln(nbinomialp(`alpha'^-1,`dv',1/(1+`dv'*`alpha'))) ///
			-ln(nbinomialtail(`alpha'^-1,`=`e(llopt)'+1',1/(1+`dv'*`alpha'))) if `keeper'

		}
		
		else if "`NB1'"=="yes" {
		
			gen `alpha'=exp(_b[lndelta:_cons]) if `keeper'
			
			replace `alpha'=exp(-13) if ln(`alpha')<-13 
			
			gen `llmxi'= ln(nbinomialp(`dv'/`alpha',`dv',1/(1+`alpha'))) if `keeper'
			
			if("`TNC'"=="yes") replace `llmxi'= ln(nbinomialp(`dv'/`alpha',`dv',1/(1+`alpha'))) ///
			-ln(nbinomialtail(`dv'/`alpha',`=`e(llopt)'+1',1/(1+`alpha'))) if `keeper'				
		}
		
		replace `llmxi'=0 if `dv'==0 & `keeper' & missing(`llmxi')
		
	}
		
	sum `llmxi' [`wtype'=`wt'], meanonly
	
	local llmx=`r(sum)'	
		
	if("`GLM'"=="no") local numerd=-2*(`llmod'-`llmx')
	
	if("`GLM'"=="yes") local numerd=`e(deviance)'
	
	local denomd=-2*(`llmu'-`llmx')
	
	/*compute DP R2 comparing negative Binomial and Poisson deviances*/
		
	if "`dp'"=="dp" & "`POI'"=="no" {
	
		tempvar llmxpoii 
		
		gen `llmxpoii'=-`dv'+ln(`dv')*`dv'-lnfactorial(`dv') if `keeper'
		
		if("`TNC'"=="yes") replace `llmxpoii'=-`dv'+ln(`dv')*`dv'-lnfactorial(`dv') ///
		-ln(poissontail(`dv',`=`e(llopt)'+1')) if `keeper'

		replace `llmxpoii'=0 if `dv'==0 & `keeper' & missing(`llmxpoii')
		
		sum `llmxpoii' [`wtype'=`wt'] if `keeper', meanonly
		
		local llmxpoi=`r(sum)'
		
		local cmd "poisson"
		
		if "`GLM'"=="yes" { 
		
			local glmfam " family(poisson) link(log)"
			
			local cmd "glm"
			
		}			
		
		if("`ZI'"=="yes") local cmd "zip"
		
		if("`TNC'"=="yes") local cmd "tpoisson"
		
		`cmd' `dv' [`e(wtype)'`e(wexp)'] if `keeper', `offset' `ll' `inflate' `glmfam'
		
		local llmupoi=e(ll)
		
		estimates restore full_r2c
		
		local dpnum=-2*(`llmod'-`llmxpoi')
		
		local dpdenom=-2*(`llmupoi'-`llmxpoi')
		
		local dp_r2=1-`dpnum'/`dpdenom'
		
	}
	
	local dev_r2=`=1-`numerd'/`denomd''
	
	/*compute adjusted deviance R2*/
	
	local npred = `=`e(k)'-`e(k_eq)''
	
	if "`POI'"=="yes" {
	
		local dev_r2a=`=1-(`numerd'+`npred'/2)/`denomd''
		
	}
	
	if "`POI'"=="no" {
	
		local chi2=-2*(`llmu'-`llmod')
		
		local dev_r2a=`=1-(`numerd'+`npred'*(`chi2'/(`e(N)'-`npred'-1)))/`denomd''
		
	}
	
	local McF=`=1-`llmod'/`llmu''
	
	/*begin computation of Pearson R2*/
	
	if "`devonly'"=="" {
	
		tempvar predp overallp		
			
		predict `mu' if `keeper', `kind' `nooffset'

		if "`POI'"=="yes" {
		
			gen `predp'=(`dv'-`mu')^2/`mu' if `keeper'	
			
			gen `overallp'=(`dv'-`mumean')^2/`mumean' if `keeper'
			
		}
		
		if "`POI'"=="no" {	
		
			if "`NB1'"=="no" {
			
				gen `predp'=(`dv'-`mu')^2/(`mu'+`alpha'*`mu'^2) if `keeper'
				
				gen `overallp'=(`dv'-`mumean')^2/(`mumean'+`alpha'*`mumean'^2) if `keeper'
				
			}
			
			if "`NB1'"=="yes" {
			
				gen `predp'=(`dv'-`mu')^2/`mu'	if `keeper'		
				
				gen `overallp'=(`dv'-`mumean')^2/`mumean' if `keeper'
				
			}
			
		}
		
		replace `predp'=0 if `dv'==0 & missing(`predp') & `keeper'
		
		replace `overallp'=0 if `dv'==0 & missing(`overallp') & `keeper'		
		
		sum `predp' [`wtype'=`wt'] if `keeper', meanonly
		
		local numerp=`r(sum)'
		
		sum `overallp' [`wtype'=`wt'] if `keeper', meanonly
		
		local denomp=`r(sum)'
		
		local pear_r2=`=1-`numerp'/`denomp''
		
		corr `dv' `mu' [`wtype'=`wt'] if `keeper'
		
		local correl=`=`r(rho)'^2'
		
		gen `mudiff'= (`mu'-`mumean')^2 if `keeper'
		
		gen `diff' = (`dv'-`mumean')^2 if `keeper'

		sum `mudiff' [`wtype'=`wt'] if `keeper', meanonly
		
		local expd=`r(sum)'
		
		sum `diff' [`wtype'=`wt'] if `keeper', meanonly
		
		local exp_r2=`=`expd'/(`r(sum)')'
		
	}
	
}

return clear

if "`dp'"=="dp" & "`POI'"=="no" {

	return scalar constdp=`dpdenom'
	
	return scalar modeldp=`dpnum'
	
	return scalar dp_r2=`dp_r2'
	
}

if "`devonly'"=="" {

	return scalar expvar=`expd'
	
	return scalar constpear=`denomp'
	
	return scalar modelpear=`numerp'
	
}
return scalar constdev=`denomd'

return scalar modeldev=`numerd'

if "`devonly'"=="" {

	return scalar exp_r2=`exp_r2'
	
	return scalar cor_r2=`correl'
	
	return scalar pear_r2=`pear_r2'
}

return scalar McF=`McF'

return scalar dev_r2a=`dev_r2a'

return scalar dev_r2=`dev_r2'

constraint drop 973 `DRP'

end

/*display results*/

program define Replay

syntax[, devonly dp]

local cmnds poisson zip tpoisson nbreg gnbreg zinb tnbreg glm

local POI="no"

if(`:list posof "`e(cmd)'" in cmnds'<4) local POI="yes"

if(`:list posof "`e(cmd)'" in cmnds'==8 & "`e(varfunct)'"=="Poisson") local POI="yes"

local ZI="no"

if(`:list posof "`e(cmd)'" in cmnds'==2 | `:list posof "`e(cmd)'" in cmnds'==6) local ZI="yes"

local TNC="no"

if(`:list posof "`e(cmd)'" in cmnds'==3 | `:list posof "`e(cmd)'" in cmnds'==7) local TNC="yes"

di "{txt}"
di "{c TLC}{hline 70}{c TRC}"
di "{txt}{c |}Deviance{col 15}Adj. Dev.{col 30}Model{col 45}Cons. Only{col 60}McFadden's{col 72}{c |}"
di "{txt}{c |}R2{col 15}R2{col 30}Deviance{col 45}Deviance{col 60}R2{col 72}{c |}"
di "{c LT}{hline 70}{c RT}"
di "{c |}{res}" %-6.5g e(dev_r2) "{col 15}" %-6.5g e(dev_r2a)  "{col 30}" %-10.0gc e(modeldev) "{col 45}" %-10.0gc e(constdev) ///
"{col 60}" %-6.5g e(McF) "{txt}{col 72}{c |}"

if "`devonly'"=="" {

	di "{c LT}{hline 70}{c RT}"
	di "{txt}{c |}Pearson{col 15}Model{col 30}Cons. Only{col 45}Correlation{col 60}Explained{col 72}{c |}"
	di "{txt}{c |}R2{col 15}Pearson Dev.{col 30}Pearson Dev.{col 45}R2{col 60}Variance R2{col 72}{c |}"
	di "{c LT}{hline 70}{c RT}"
	di "{c |}{res}" %-6.5g e(pear_r2) "{col 15}" %-10.0gc e(modelpear)  "{col 30}" %-10.0gc e(constpear) "{col 45}" ///
	%-6.5g e(cor_r2) "{col 60}" %-6.5g e(exp_r2) "{txt}{col 72}{c |}"
	
}

if "`dp'"=="dp" & "`POI'"=="no" {

	di "{txt}{c LT}{hline 70}{c RT}"
	di "{txt}{c |}DP{col 15}DP Model{col 30}DP Cons. Only{col 72}{c |}"
	di "{txt}{c |}R2{col 15}Deviance{col 30}Deviance{col 72}{c |}"
	di "{c LT}{hline 70}{c RT}"	
	di "{c |}{res}" %-6.5g e(dp_r2) "{col 15}" %-10.0gc e(modeldp) "{col 30}" %-10.0gc e(constdp) "{txt}{col 72}{c |}" 
	
}

if("`ZI'"=="yes") local adj " Zero-inflated"

if("`TNC'"=="yes") local adj " Truncated (at `e(llopt)')"

di "{c BLC}{hline 70}{c BRC}"

if "`dp'"=="dp" & "`POI'"=="no" {

	di "{txt}Note: The DP R2 can be compared with a Deviance R2 from a`adj' Poisson regression." 
}

end

/* programming notes and history

- r2c version 1.1 - date - Jan. 31, 2013

basic version

- r2c version 1.2 - date - Apr. 3, 2013

//notable changes\\
a] estimation combined into single program (no sub-programs r2c.devcompute or r2c.pearcompute); all global macros changed to locals
; all "sum" commands changed to "sum, meanonly" when r(sum) sought - simplified constant-only log likelihood computation syntax
b] fixed incompatability with "svy:" prefix and incorporates subpops
c] incorporates multiple imputation estimates - r2c_est and Replay command added to facilitate
d] removed summarize option - added "devonly" option
e] backwards compatable to Stata 11 (when tpoisson and tnbreg introduced)
f] added McFadden's R2 (not automatically computed in many models)
g] added estdisp option to obtain neg. Binomial constant-only model with overdispersion parameter estimated from data
h] added gnbcons option to compare full negative binomial model to estimated constant-only lnalpha, constant-only model 
(as opposed to full specification lnalpha, constant-only model)
i] adds computed fit indexes into e() as opposed to r() - eclass program

*/
