*! version 1.1 18May2015

// 19/5/2015 PCL: tidied up numeric integration & added some error checks.

program define stpm2cif
	version 11.1

	syntax newvarlist (min=2 max=10), CAUSE1(string) CAUSE2(string) ///
			[CAUSE3(string) CAUSE4(string) CAUSE5(string) ///
			CAUSE6(string) CAUSE7(string) CAUSE8(string) ///
			CAUSE9(string) CAUSE10(string) OBS(int 1000) CI MINT(string) ///
			MAXT(real -99) TIMEname(string) HAZard CONTMORT CONTHAZ ITERATE(int 100)]
		 
local newvarlist `varlist'
tokenize `newvarlist'
local i=0
while "`1'"!="" {
	local i=`i'+1
	local newvar`i' `1'
	mac shift 1
}

// Check that timename doesn't already exist if option is used.***
if "`timename'"!=""{
	capture confirm variable `timename'
	if _rc==0 {
		di as err "`timename' already exists in the dataset" 
	exit
  }
}	
else {
	capture drop _newt
}

// Count how many causes of death have been specified.
local n=2	
forvalues i=3/10 {
	if "`cause`i''"!="" {
		local n=`n'+1
	}
}

// check variables do no already exist
forvalues i = 1/`n' {
	capture confirm var CIF_`newvar`i''
	if _rc == 0 {
		di as error "Variables CIF_`newvar`i'' already exists"
		exit 198
	}
	if "`ci'" != "" {
		capture confirm var CIF_`newvar`i''_lci
		if _rc == 0 {
			di as error "Variables CIF_`newvar`i''_lci already exists"
			exit 198
		}
		capture confirm var CIF_`newvar`i''_uci
		if _rc == 0 {
			di as error "Variables CIF_`newvar`i''_uci already exists"
			exit 198
		}		
	}		
}

// Set default time according to _t from stset.
if "`mint'" != "" {
	di as text "Warning: The mint() option is now redundant"
}
if "`maxt'"=="-99" {
	qui sum _t
	local maxt=r(max)
}

//Save tvc variables in local macro.***
local etvc `e(tvc)'

//Count how many variables have been specified for each cause and store in local macros.
forvalues i=1/`n' {
	local varcount`i' : word count `cause`i''
	local count`i'=`varcount`i''/2
	local j=0
	tokenize `cause`i''
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

//Create a tempfile.
tempfile ind
preserve
drop _all
qui set obs `obs'
tempvar t

//Calculate length of interval.***
local step = `maxt'/(`obs')

range `t' `step' `maxt'
tempvar lnt
qui gen double `lnt' = ln(`t')

//Calculate baseline splines.
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

//Find out how many tvc term there are for each cause
forvalues i=1/`n' { 
	local p=0
	forvalues j=1/`count`i'' {
		if `"`: list posof `"`cov`i'`j''"' in etvc'"' != "0" {
			local p=`p'+1
		}
	}
	local tvcno`i'=`p'
}

//Store splines in local macros for each cause of death
forvalues i=1/`n' { 
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
			qui rcsgen `lnt', knots(`e(ln_tvcknots_`tvcvar`i'`j'')') gen(_rcs_`tvcvar`i'`j'') ///
				dgen(_d_rcs_`tvcvar`i'`j'') `e(reverse)' `rmatrix'
			forvalues l = 1/`e(df_`tvcvar`i'`j'')' {
				local rcs`i'`j' `rcs`i'`j'' ([xb][_rcs_`tvcvar`i'`j''`l']*_rcs_`tvcvar`i'`j''`l' *`covval`i'`j'')
				local d_rcs`i'`j' `d_rcs`i'`j'' ([dxb][_d_rcs_`tvcvar`i'`j''`l']*_d_rcs_`tvcvar`i'`j''`l' *`covval`i'`j'')
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
  
 //Add constant to splines macro if nocons option is not specified with stpm2.***
	if "`e(noconstant)'" == "" {
		local rcs`i' `rcs`i'' + [xb][_cons]   
	}
}

//Store covariates in local macros for each cause of death.***
forvalues i=1/`n' {
	forvalues j=1/`count`i'' {
		local covs`i' `covs`i'' ([xb][`cov`i'`j'']*`covval`i'`j'') 
		if `j'!=`count`i'' {
			local covs`i' `covs`i'' +
		}
	} 
}


//Calculate overall survival function.***
forvalues i=1/`n' {
	local xb`i' `covs`i''+`rcs`i''
	local surv_all `surv_all' exp(-exp(`xb`i''))*
	if "`ci'" != "" {
		local g`newvar`i'' g(_d`newvar`i'')
	}
}

gen tothaz = 0
gen totcif = 0

//Calculate hazard function.***
forvalues i=1/`n' {
	local h_`newvar`i'' (1/`t')*(`d_rcs`i'')*exp(`xb`i'')
//Predict integral for each cause of death.***
	tempvar f_`newvar`i''
	qui predictnl `f_`newvar`i''' = `surv_all'`h_`newvar`i''', `g`newvar`i''' force iterate(`iterate')

//Calculate cumulative incidence for each cause of death.***
*********************
	//qui gen CIF_`newvar`i'' = sum(`step'*`f_`newvar`i''')
	qui gen h_`newvar`i'' = (1/`t')*(`d_rcs`i'')*exp(`xb`i'')
	if "`ci'" != "" {
		unab d`newvar`i'': _d`newvar`i''*
		foreach var in `d`newvar`i''' {
			local add = subinstr("`var'","_d`newvar`i''","",1)
			local d`newvar`i''coeffnum `d`newvar`i''coeffnum' `add'
		}
	}
	mata: genci("`newvar`i''")

	
	
	if "`hazard'"!="" {
		local CIF `CIF' CIF_`newvar`i'' h_`newvar`i''
	}
	if "`hazard'"=="" {
		local CIF `CIF' CIF_`newvar`i'' 
	}
	qui replace totcif = totcif + CIF_`newvar`i''	
	qui replace tothaz = tothaz + h_`newvar`i''
}

if "`ci'" != "" {
	forvalues i=1/`n' {

		qui gen CIF_`newvar`i''_uci = CIF_`newvar`i'' + 1.96*sqrt(`newvar`i''_var)
		qui gen CIF_`newvar`i''_lci = CIF_`newvar`i'' - 1.96*sqrt(`newvar`i''_var)
		
//Store confidence intervals in local macro.***	
		local CI `CI' CIF_`newvar`i''_lci CIF_`newvar`i''_uci 
	}	
}

forvalues i=1/`n' {  
	if "`contmort'"!="" {
		qui gen contmort_`newvar`i''=CIF_`newvar`i''/totcif
		local cmort `cmort' contmort_`newvar`i''
	}
	if "`conthaz'"!="" {
		qui gen conthaz_`newvar`i''=h_`newvar`i''/tothaz
		local chaz `chaz' conthaz_`newvar`i''
	}
}

//Change label for time if timename option specified.***
if "`timename'"!="" {
	gen `timename'=`t'
	keep `timename' `CIF' `CI' `chaz' `cmort'
}

if "`timename'"=="" {
	gen _newt=`t'
	keep _newt `CIF' `CI' `chaz' `cmort'
}
	
//Restore original dataset and merge with tempfile.***	
qui save `ind'
restore
qui merge 1:1 _n using `ind', nogenerate

end	


***Mata command used to generate CIF and confidence intervals.***
set matastrict off
mata:
  void genci(string scalar name)
  {
	f = st_data(.,st_local("f_"+name))
	
	
	if(st_local("ci") != "") {
		gname = st_data(.,tokens(st_local("d"+name)))
		V = st_matrix("e(V)")
	}
//	CIF_name = st_data(.,"CIF_"+name)
	
	
	L = lowertriangle(J(strtoreal(st_local("obs")),
						strtoreal(st_local("obs")),
						strtoreal(st_local("step"))),
						0.5*strtoreal(st_local("step")))
	L[1,1] = strtoreal(st_local("step"))

	(void) st_addvar("double","CIF_"+name)
	st_store(., "CIF_"+name, L*f)

	if(st_local("ci") != "") {
		(void) st_addvar("double",name+"_var") 
		Vindex = strtoreal(tokens(st_local("d"+name+"coeffnum")))
		st_store(.,name+"_var", diagonal(L*gname*V[Vindex,Vindex]*gname'*L'))
	}
  }
end

