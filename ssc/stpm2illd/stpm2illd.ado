capture program drop stpm2illd
program define stpm2illd
        version 11.1
                
        
syntax newvarlist (min=3 max=4), TRANS1(string) TRANS2(string) TRANS3(string) ///
                 [OBS(int 1000) CI MINT(real 0) MAXT(real 0) TIMEname(string) HAZard HAZNAME(string) ITERATE(int 100) COMBINE]
                 
                            
local newvarlist `varlist'

tokenize `newvarlist'
local i=0
while "`1'"!="" {
  local i=`i'+1
  local newvar`i' `1'
  mac shift 1
}
local newvarlistcount `i'

if "`hazname'"!="" {
	tokenize `hazname'
	local i=0
	while "`1'"!="" {
		local i=`i'+1
		local haz`i' `1'
		mac shift 1
	}
	if `i'<3 {
		di as err "Must specify three variable names for the transition hazards in the hazname option."
	}
}

if "`hazname'"=="" {	
	local haz1 trans1
	local haz2 trans2
	local haz3 trans3		
}

*** Check that haznames don't already exist in the data. ***
if "`hazard'"!="" {
	capture confirm variable h_`haz1'
	if _rc==0 {
		di as err "h_`haz1' already exists in the dataset. Use the hazname option to change the name of the transition hazards." 
        exit
	}
	capture confirm variable h_`haz2'
	if _rc==0 {
		di as err "h_`haz2' already exists in the dataset. Use the hazname option to change the name of the transition hazards."  
        exit
	}
	capture confirm variable h_`haz3'
	if _rc==0 {
		di as err "h_`haz3' already exists in the dataset. Use the hazname option to change the name of the transition hazards."  
        exit
	}
}

*** Check that timename doesn't already exist if option is used. ***
if "`timename'"!=""{	
	capture confirm variable `timename'
	if _rc==0 {
		di as err "`timename' already exists in the dataset" 
        exit
  }
}
      

*** Check that the correct number has been specified in newvarlist. ***
if "`combine'"=="" & `newvarlistcount'==3 {
	di as err "You need to specify four names in newvarlist unless you are using the combine option"
}

if "`combine'"!="" & `newvarlistcount'==4 {
	di as err "You only need to specify three names in newvarlist when using the combine option"
}

*** Set default minumum and maximum times according to _t from stset. ***
if "`mint'"=="0" {
qui sum _t
local mint=r(min)
}
if "`maxt'"=="0" {
qui sum _t
local maxt=r(max)
}


*** Save tvc variables in local macro. ***
local etvc `e(tvc)'

*** Count how many variables have been specified for each transition and store in local macros. ***
forvalues i=1/3 {
  local varcount`i' : word count `trans`i''
  local count`i'=`varcount`i''/2
  local j=0
  tokenize `trans`i''
  while "`1'"!="" {
        local j=`j'+1
    unab 1: `1'
    cap confirm var `2'
    if _rc {
          cap confirm num `2'
      if _rc {
      di in red "invalid at(... `1' `2' ...)"
      exit 198
      }
    }
        local cov`i'`j' `1'
        local covval`i'`j' `2'
        mac shift 2
  }  
}



*** Create a tempfile. ***
tempfile ind
preserve
drop _all
qui set obs `obs'
tempvar t
range `t' `mint' `maxt'
tempvar lnt
qui gen `lnt' = ln(`t')


*** Calculate baseline splines. ***
if "`e(rcsbaseoff)'" == "" {
  capture drop _rcs`i'* _d_rcs`i'*
  if "`e(orthog)'" != "" {
        matrix R = e(R_bh)           
        local rmatrix rmatrix(R)
  }
  qui rcsgen `lnt', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `e(reverse)' `rmatrix'
  
  forvalues i=1/`e(dfbase)' {
    local rcs `rcs' [xb][_rcs`i']*_rcs`i' 
    local d_rcs `d_rcs' [dxb][_d_rcs`i']*_d_rcs`i' 
        
        if `i'!=`e(dfbase)' {
          local rcs `rcs' +
          local d_rcs `d_rcs' +
        }       
  }
}

*** Find out how many tvc term there are for each transition. ***
forvalues i=1/3 { 
  local p=0
  forvalues j=1/`count`i'' {
    if `"`: list posof `"`cov`i'`j''"' in etvc'"' != "0" {
           
          local p=`p'+1
        }
  }
  local tvcno`i'=`p'
}


*** Store splines in local macros for each transition. ***
forvalues i=1/3 { 

  if "`e(rcsbaseoff)'" == "" {
        local rcs`i' `rcs`i'' `rcs' 
        local d_rcs`i' `d_rcs`i'' `d_rcs'       
  }  
 
  local m=0
  forvalues j=1/`count`i'' {
    local p=`m' 
    if `"`: list posof `"`cov`i'`j''"' in etvc'"' != "0" {
           
          local m=`m'+1
          
          if `m'==1 & "`e(rcsbaseoff)'" == "" {
            local rcs`i' `rcs`i'' +
            local d_rcs`i' `d_rcs`i'' +
          }
            
      local tvcvar`i'`j' `cov`i'`j''
          capture drop _rcs_`tvcvar`i'`j''* _d_rcs_`tvcvar`i'`j''*
          if "`e(orthog)'" != "" {
            matrix R`i'`j' = e(R_`tvcvar`i'`j'')          
            local rmatrix rmatrix(R`i'`j')
          }       
      qui rcsgen `lnt', knots(`e(ln_tvcknots_`tvcvar`i'`j'')') gen(_rcs_`tvcvar`i'`j'') dgen(_d_rcs_`tvcvar`i'`j'') `e(reverse)' `rmatrix'
          
          forvalues l = 1/`e(df_`tvcvar`i'`j'')' {
          
            local rcs`i'`j' `rcs`i'`j'' ([xb][_rcs_`tvcvar`i'`j''`l']*_rcs_`tvcvar`i'`j''`l'*`covval`i'`j'')
            local d_rcs`i'`j' `d_rcs`i'`j'' ([dxb][_d_rcs_`tvcvar`i'`j''`l']*_d_rcs_`tvcvar`i'`j''`l'*`covval`i'`j'')
                
                if `l'!=`e(df_`tvcvar`i'`j'')' {
                  local rcs`i'`j' `rcs`i'`j'' +
                  local d_rcs`i'`j' `d_rcs`i'`j'' +
                }
          }      
        }       

        if `p'!=`m' {
      local rcs`i' `rcs`i'' `rcs`i'`j'' 
      local d_rcs`i' `d_rcs`i'' `d_rcs`i'`j'' 
          if `m'!=`tvcno`i'' {
            local rcs`i' `rcs`i'' +
            local d_rcs`i' `d_rcs`i'' +
          }
    }
  }
  
  *** Add constant to splines macro if nocons option is not specified with stpm2. ***
  if "`e(noconstant)'" == "" {
    local rcs`i' `rcs`i'' + [xb][_cons]   
  }
  
}

*** Store covariates in local macros for each transition. ***
forvalues i=1/3 {
  forvalues j=1/`count`i'' {
    local covs`i' `covs`i'' ([xb][`cov`i'`j'']*`covval`i'`j'') 
        if `j'!=`count`i'' {
          local covs`i' `covs`i'' +
    }
  } 
}

*** Calculate length of interval. ***
local step = `maxt'/(`obs' - 1)

forvalues i=1/3 {  
  local xb`i' `covs`i''+`rcs`i''
}


*** Calculate hazard functions for each transition. ***
forvalues i=1/3 {  
  local h_`haz`i'' (1/`t')*(`d_rcs`i'')*exp(`xb`i'')  
  qui gen h_`haz`i''=(1/`t')*(`d_rcs`i'')*exp(`xb`i'')
}



*** Calculate probability of being alive - state 1. ***
if "`ci'"!="" {
  local ci_`newvar1' ci(prob_`newvar1'_lci prob_`newvar1'_uci)
}
qui predictnl prob_`newvar1' = exp(-exp(`xb1'))*exp(-exp(`xb2')), `ci_`newvar1'' force iterate(`iterate')



*** Calculate probability of being ill - state 2. ***

if "`ci'"!="" {
  local ci_`newvar2' ci(prob_`newvar2'_lci prob_`newvar2'_uci)
}

qui predictnl prob_`newvar2' = sum(`step'*((`h_`haz2''*exp(-exp(`xb1'))*exp(-exp(`xb2')))/(exp(-exp(`xb3')))))*(exp(-exp(`xb3'))), ///
							`ci_`newvar2'' force iterate(`iterate')

							

*** Calculate probability of being dead - state 3. ***
if "`combine'"=="" {
	if "`ci'"!="" {
		local ci_`newvar3' ci(prob_`newvar3'_lci prob_`newvar3'_uci)
	}
	
	qui predictnl prob_`newvar3' = sum(`step'*(`h_`haz1''*exp(-exp(`xb1'))*exp(-exp(`xb2')))), `ci_`newvar3'' force iterate(`iterate')
}

*** Calculate probability of being ill then dead - state 4. ***
if "`combine'"=="" {
	if "`ci'"!="" {
		local ci_`newvar4' ci(prob_`newvar4'_lci prob_`newvar4'_uci)
	}

	qui predictnl prob_`newvar4' = 1-(exp(-exp(`xb1'))*exp(-exp(`xb2')))-(sum(`step'*(`h_`haz1''*exp(-exp(`xb1'))*exp(-exp(`xb2'))))) ///
								-sum(`step'*((`h_`haz2''*exp(-exp(`xb1'))*exp(-exp(`xb2')))/(exp(-exp(`xb3')))))*(exp(-exp(`xb3'))), ///
								`ci_`newvar4'' force iterate(`iterate')
}


*** If combine option is specified then create one probability for death. ***
if "`combine'"!="" {
	if "`ci'"!="" {
		local ci_`newvar3' ci(prob_`newvar3'_lci prob_`newvar3'_uci)
	}
	qui predictnl prob_`newvar3'=1-(exp(-exp(`xb1'))*exp(-exp(`xb2')))-sum(`step'*((`h_`haz2''*exp(-exp(`xb1'))* ///
	                             exp(-exp(`xb2')))/(exp(-exp(`xb3')))))*(exp(-exp(`xb3'))), ///
								`ci_`newvar3'' force iterate(`iterate')
}								
								
*** Create a local macro for variables we want to keep. ***
if "`combine'"=="" {
	if "`hazard'"=="" {
		if "`ci'"=="" {
			local probs prob_`newvar1' prob_`newvar2' prob_`newvar3' prob_`newvar4'
		}
		if "`ci'"!="" {
			local probs prob_`newvar1' prob_`newvar1'_lci prob_`newvar1'_uci prob_`newvar2' prob_`newvar2'_lci prob_`newvar2'_uci
			local probs `probs' prob_`newvar3' prob_`newvar3'_lci prob_`newvar3'_uci prob_`newvar4' prob_`newvar4'_lci prob_`newvar4'_uci
		}
	}

	if "`hazard'"!="" {
		if "`ci'"=="" {
			local probs prob_`newvar1' prob_`newvar2' prob_`newvar3' prob_`newvar4' h_`haz1' h_`haz2' h_`haz3' 
		}
		if "`ci'"!="" {
			local probs prob_`newvar1' prob_`newvar1'_lci prob_`newvar1'_uci prob_`newvar2' prob_`newvar2'_lci prob_`newvar2'_uci
			local probs `probs' prob_`newvar3' prob_`newvar3'_lci prob_`newvar3'_uci prob_`newvar4' prob_`newvar4'_lci prob_`newvar4'_uci
			local probs `probs' h_`haz1' h_`haz2' h_`haz3' 
		}
	}
}

if "`combine'"!="" {
	if "`hazard'"=="" {
		if "`ci'"=="" {
			local probs prob_`newvar1' prob_`newvar2' prob_`newvar3'
		}
		if "`ci'"!="" {
			local probs prob_`newvar1' prob_`newvar1'_lci prob_`newvar1'_uci prob_`newvar2' prob_`newvar2'_lci prob_`newvar2'_uci
			local probs `probs' prob_`newvar3' prob_`newvar3'_lci prob_`newvar3'_uci 
		}
	}

	if "`hazard'"!="" {
		if "`ci'"=="" {
			local probs prob_`newvar1' prob_`newvar2' prob_`newvar3' h_`haz1' h_`haz2' h_`haz3' 
		}
		if "`ci'"!="" {
			local probs prob_`newvar1' prob_`newvar1'_lci prob_`newvar1'_uci prob_`newvar2' prob_`newvar2'_lci prob_`newvar2'_uci
			local probs `probs' prob_`newvar3' prob_`newvar3'_lci prob_`newvar3'_uci 
			local probs `probs' h_`haz1' h_`haz2' h_`haz3'
		}
	}
}



*** Change label for time if timename option specified. ***
if "`timename'"!="" {
  gen `timename'=`t'
  keep `timename' `probs' 
}

if "`timename'"=="" {
  gen _newt=`t'
  keep _newt `probs'
}


*** Restore original dataset and merge with tempfile. *** 
qui save `ind'
restore
qui merge 1:1 _n using `ind', nogenerate

end 


