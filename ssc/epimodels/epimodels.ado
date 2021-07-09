program define epimodels
	version 16.0
	`0'
end

program define simulate
	version 16.0
	gettoken model 0 : 0
	local cmd = "epi_"+strlower(`"`model'"')
	`cmd' `0'
end

program define fitdlgsir
	version 16.0
	syntax , beta(real) gamma(real) ///
	         betak(real) gammak(real) ///
			 vsusceptible(string) vinfected(string) vrecovered(string) ///
			 format(string)
			 
	if (`betak'==1) local pb "beta(`beta')"
	else local pb "beta(.) beta0(`beta')"

	if (`gammak'==1) local pg "gamma(`gamma')"
	else local pg "gamma(.) gamma0(`gamma')"
	
	capture confirm number `vsusceptible'
	if !_rc local ss "susceptible(`vsusceptible')"
	else local ss "vsusceptible(`vsusceptible') susceptible(`=`vsusceptible'[1]')"
	
	capture confirm number `vinfected'
	if !_rc local si "infected(`vinfected')"
	else local si "vinfected(`vinfected') infected(`=`vinfected'[1]')"
	
	capture confirm number `vrecovered'
	if !_rc local sr "recovered(`vrecovered')"
	else local sr "vrecovered(`vrecovered') recovered(`=`vrecovered'[1]')"
	
	epimodels fit SIR , `pb' `pg' `ss' `si' `sr' format(`format')

end

program define fitdlgseir
	version 16.0
	syntax , beta(real) betak(real) ///
	         gamma(real) gammak(real) ///
			 sigma(real) sigmak(real) ///
			 mu(real) muk(real) ///
			 nu(real) nuk(real) ///
			 vsusceptible(string) vexposed(string) ///
			 vinfected(string) vrecovered(string) ///
			 format(string)
			 
	if (`betak'==1) local pb "beta(`beta')"
	else local pb "beta(.) beta0(`beta')"

	if (`gammak'==1) local pg "gamma(`gamma')"
	else local pg "gamma(.) gamma0(`gamma')"
	
	if (`sigmak'==1) local ps "sigma(`sigma')"
	else local ps "sigma(.) sigma0(`sigma')"
	
	if (`muk'==1) local pm "mu(`mu')"
	else local pm "mu(.) mu0(`mu')"
	
	if (`nuk'==1) local pn "nu(`nu')"
	else local pn "nu(.) nu0(`nu')"
	
	capture confirm number `vsusceptible'
	if !_rc {
	  local ss "susceptible(`vsusceptible')"
	}
	else {
	  local ss "vsusceptible(`vsusceptible') susceptible(`=`vsusceptible'[1]')"
	}
	
	capture confirm number `vexposed'
	if !_rc {
	  local se "exposed(`vexposed')"
	}
	else {
	  local se "vexposed(`vexposed') exposed(`=`vexposed'[1]')"
	}
	
	capture confirm number `vinfected'
	if !_rc {
	  local si "infected(`vinfected')"
	}
	else {
	  local si "vinfected(`vinfected') infected(`=`vinfected'[1]')"
	}
	
	capture confirm number `vrecovered'
	if !_rc {
	  local sr "recovered(`vrecovered')"
	}
	else {
	  local sr "vrecovered(`vrecovered') recovered(`=`vrecovered'[1]')"
	}
	
	epimodels fit SEIR , `pb' `pg' `ps' `pm' `pn' `ss' `se' `si' `sr' format(`format')

end

program define fit, rclass

	version 16.0
	
	syntax anything, [*]
	
	local anything=strupper(`"`anything'"')
	mata epi_getmodelmeta("")
	assert(strpos(" `models_known' "," `anything' ")>0)
	local modelname=strlower("epi_`anything'")
	mata epi_getmodelmeta("`modelname'")
	
	local syntax_params ""
	foreach p in `model_params' {
	    local syntax_params `"`syntax_params' `p'(numlist max=1 missingok) `p'0(real 0.50)"'
	}
	
	local syntax_stocks ""
	foreach s in `model_stocks' {
	    local syntax_stocks `"`syntax_stocks' `s'(real 0.0000) v`s'(varname numeric)"'
	}
	
	syntax anything, [ `syntax_params' `syntax_stocks' format(string)]		
	
	if (`"`format'"'=="") local format "%10.5f"
	
	local allparamsknown=1
	foreach p in `model_params' {
	  if (`"``p''"'=="") local `p'="."	  
	  local `p'1=``p''
	  if missing(``p'') local allparamsknown=0
	}

	local totalpop=0
	local stockvarlist=""
	local stockok=0
	local c=1
	local fit=""
	
	foreach s in `model_stocks' {
	  local vn : word `c' of `model_vars'
	  local vname=`"`v`s''"'
	  if (`"`vname'"'=="") {
	    local vname="."
	  }
	  else {
	    confirm numeric variable `v`s''
	    local stockok=1
		local fit "`fit'`vn'" // generate the fit parameter based on the actual variables supplied
		
		// check initial conditions
		local inivalue=`v`s''[1]
		if (`inivalue'!=``s'') {
		    display in yellow "Warning! Initial value for `s'==``s'' is ignored because it is different from the value `inivalue' in the specified time series `v`s''."
		}
		local `s'=`inivalue'
	  }
	  
	  local totalpop=`totalpop'+``s''
	  local initial_conditions = `"`initial_conditions' `s'(``s'')"'
  
	  local stockvarlist `"`stockvarlist' `vname'"'
	  local c=`c'+1
	}

	if (`stockok'==0) {
	    display as error "Error! At least one population variable must be specified!"
		error 112
	}
	
	if (`totalpop'<=0) {
	    display as error "Error! Total population must be more than zero at t0!"
	    error 112
	}
	
	local iterations=0
	
    mata epi_searchparams()
	
	local modeltitle `"`anything' model estimation"'
	local twid = 17
	local cwid = 10
	local lmarg = 2
	
	local twidth = `twid' + (`cwid'+1) + (17+1)
	local titlepos = `lmarg' + floor((`twidth'-strlen(`"`modeltitle'"'))/2)
	if (`titlepos' < `lmarg') local titlepos=`lmarg'	
	local titleoffset=`"_col(`=`titlepos'+1')"'
	
	display ""
    display `titleoffset' "`modeltitle'"
    tempname tab
	.`tab' = ._tab.new, col(3) lmarg(`lmarg') commas
	.`tab'.width    `twid' | `cwid'  17
	.`tab'.titlefmt . %`cwid's %17s
	.`tab'.numfmt   . `format' .
	.`tab'.sep, top
	.`tab'.titles "Parameter" "Value " "Source   "
	.`tab'.sep, mid
	
	local greekstr=""
	foreach p in `model_params' {
	  return scalar `p' = ``p'1'
	  local greekstr `"`greekstr' {&`p'}=``p'1';"'
	  mata st_local("g", epi_greek("`p'"))
	  local src=cond(missing(``p''),"Estimated","Supplied")
	  .`tab'.row `"`p' (`g')"' ``p'1' `"`src'"'
	  if (missing(``p'')) local estimated `"`estimated' `p'"'
	}
	.`tab'.sep, bottom

	return local iniconditions `"`initial_conditions'"'
	return local finparameters `"`finalparams'"'	
	return local estimated `"`estimated'"'
    return local finparamstr `"`greekstr'"'
	return local datavars `"`stockvarlist'"'
	return local modelvars `"`model_vars'"'
	return local modelname `"`anything'"'
	return local modelcmd `"`modelname'"'
	
end	

program define homepage
    view browse www.radyakin.org/stata/epimodels/
end

// END OF FILE
