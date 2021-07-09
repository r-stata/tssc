capture program drop iop
*! version 2.6 18dec2015 F. Chavez Juarez & Isidro Soloaga
program define iop , rclass 
version 9.2
syntax varlist [if] [in] [fweight iweight] ///
			[, Type(string) Detail Shapley(str) SGRoups(str) Oaxaca(str) Logit NOloglin ///
			/*OLD OPTIONS:*/ BOOTstrap(integer 0) DECOMPosition GRoups(varlist max=1)  PRopt(str) BOOTOPT(str) PROBIT]

tempfile iop_orgdb
qui: save `iop_orgdb', replace


marksample touse

// CHECK IF THE OLD SYNTAX IS USED
if("`decomposition'"!="" | "`groups'"!="" | "`propt'"!="" | "`probit'"!=""){
	display as error "{hline 50}"
	display as error "WARNING: You are using the old syntax of iop." 
	display as text "It still works to ensure backward compatability,"_n "but we encourage you to change to the new syntax."
	display as text "Read the {help iop:help file} for more details"
	display as error "{hline 50}" _n _n
	
	// Load different option: 
		
	
	iop_old `varlist', boot(`bootstrap') `decomposition' groups(`groups') propt(`probt') bootopt(`bootopt') `probit'
	exit
	}
	
// DEFINE DEPENDENT AND INDEPENDENT VARIABLES
tokenize `varlist'
local depvar `1'
macro shift
local indepvars `*'	

// CHECK IF THE USER WANTS TO SEE THE DETAILS
if("`detail'"!=""){
	local noisily="noisily"
	}

// CHECK IF THE USER PREFERS LOGIT TO PROBIT

if("`logit'"!=""){
	local LDepModel="logit"
	di as text "Note: logit was used instead of probit"
	}
	else{
	local LDepModel="probit"
	}



// ANALYZE THE DEPENDENT VARIABLE
	// Check that the variable is numeric
	capture confirm numeric variable `depvar'
	if _rc { // This is not a numeric variable
		di as error "ERROR: your dependent variable is not numeric"
		exit
		}
	
	
	if("`type'"==""){
		// Find the type of the varible
		tempvar check
		gen `check'=`depvar'
		qui: compress `check'
		local type: type `check'
		if("`type'"=="byte"){	//dummy or ordered
			capture tab `check'
			if(r(r)==2){
				local type="dichotomous (dummy)"
				local case=1
				}
			else{
				local type="ordered"
				local case=2
			}
			
		}
		else{	// continuous
			local type="continuous"
			local case=3
		}
		
		di as text "I assume the variable to be: " as result "`type'" 
		di as text "If this is not correct, use option {help iop##type:type}" _n
		}
		else{ // user provided information on the type
			if("`type'"=="c" | "`type'"=="C"){ //continuous
				local type="continuous"
				local case=3
				}
			else if("`type'"=="d" | "`type'"=="D"){ //dummy
				local type="dummy"
				local case=1
				}
			else if("`type'"=="o" | "`type'"=="O"){ //ordered
				local type="ordered"
				local case=2
				}
			else{
				di as error "ERROR in option {help iop##type:type}. I don't understand your input" _n "The following values are admitted:" 
				di as error _col(5) "c" _col(10) "continuous variables"
				di as error _col(5) "d" _col(10) "dummy/dichotomous variables"
				di as error _col(5) "o" _col(10) "ordered variables"
				exit 
				}
					

		}
		
	// CHECK THE WEIGHT AND NORMALIZE IF IWEIGHT
	if("`weight'"=="iweight" & "`exp'"!="= _iop_wvar"){
		local wvar=strltrim(subinstr("`exp'","=","",1))
		qui: sum `wvar'
		gen _iop_wvar=`wvar'/(r(mean))
		qui: sum _iop_wvar
		local exp="=_iop_wvar"
		
	}
		

// RUN MAIN ANALYSIS ACCORDING TO THE DEPENDENT VARIABLE
tempvar yhat
local depvarl=abbrev("`depvar'",12)


// DICHOTOMOUS  
if(`case'==1){
		quietly{
	// Run probit model
		sum `depvar'
		tempvar useddepvar
		gen `useddepvar'=`depvar'>r(mean)
		replace `useddepvar'=. if `depvar'==.
		`noisily' `LDepModel' `useddepvar' `indepvars' if `touse' [`weight'`exp']
		local N=e(N)
		predict `yhat' if `touse'
		
		iop_dirun `yhat' if `touse' [`weight'`exp']
		
		local result_pdb	=	r(DI)
		local result_ws	=	r(DI)*r(avg)*4
	
	// Run the bootstrap if needed
		if(`bootstrap' & `bootstrap'>0){
			noisily di as text "Bootstrapping..." _continue
			
				forvalues i=1/`bootstrap'{
				preserve
				qui: keep if `touse'
				bsample, `bootopt'
					iop `depvar' `indepvars' if `touse' [`weight'`exp'], `logit'
							
					if(`i'==1){
						mat define estimates=(r(pdb),r(ws))
						}
					else{
						mat define estimates=(estimates \r(pdb),r(ws))
						}
					
					
					restore	
			
				}	// end loop through iterations of bootstrap
					
					matrix colnames estimates = "_est_ws"  "_est_pdb" 
					matrix list estimates
					svmat estimates, names(matcol)
					local stats="ws pdb"
					foreach stat of local stats{
						sum estimates_est_`stat'
						local BS_sd_`stat'=r(sd)
						}
						
					
					drop estimates_est_*
				noisily di as result "done!" _n	
			}
		
	
	// Save results in rclass variables
		return scalar pdb=`result_pdb'
		return scalar ws=`result_ws'
		local IOP=`result_pdb'
		if(`bootstrap'){
			return scalar pdbSD=`BS_sd_pdb'
			return scalar wsSD=`BS_sd_ws'
			return scalar bootN=`bootstrap'
		}
		matrix define iop = (`result_pdb' \ `result_ws')
		matrix colname iop= "IOP"
		matrix rownames iop = "pdb" "ws"
		matrix list iop
		return matrix iop = iop
		
	} // end quietly
	
	// Display the results
		di as text "{hline 70}"
		di as result _col(5) "Inequality of opportunity in {it:`depvar'}"
		di as text "{hline 34}{c +}{hline 35}"
		di as text "Method" _col(35)"{c |}"  %12s "Absolute" _col(50) %9s "Relative"
		di as text "{hline 34}{c +}{hline 35}"
		//di as text "Observations" 				_col(31) "{c |}" as result %9.0f r(N)
		//di as text "Boostrap iterations" _col(26) "{c |}" as result %9.3g `bootstrap'
		di as text "{help iop##pdb:PdB} (Dissimilarity index)" 	_col(35) "{c |}" as result %12.6g `result_pdb' _col(50) as result %12s "not defined"
		if(`bootstrap'){
			di as text "  Bootstrap std. err." 			_col(35) "{c |}" as result  "(" %10.6f `BS_sd_pdb' ")" 
		}
		di as text "{help iop##ws:ws} (adapted DI)" 			_col(35) "{c |}" as result %12.6g `result_ws' _col(50) as result %12s "not defined"
		if(`bootstrap'){
			di as text "  Bootstrap std. err." 			_col(35) "{c |}" as result  "(" %10.6f `BS_sd_ws' ")" 
		}
		di as text "{hline 70}"
		di as text "Observations: "  _col(24) as result %9.0f `N'
		if(`bootstrap'){
			di as text "Bootstrap replications:" _col(24)	as result %9.0f `bootstrap'
		}
			
} // end case==1 (dummy)
else if(`case'==2){ // ordered
	quietly{
	levelsof(`depvar') if `touse', local(levels)
	tokenize `levels'
	macro shift
	local levels="`*'"	
	di "`levels'"
	
	tempvar useddepvar
	gen `useddepvar'=.
	matrix input results=()
	local max=0
	local runner=0
	foreach t of local levels{
		local runner=`runner'+1
		replace `useddepvar'=`depvar'>=`t' if `touse'
		replace `useddepvar'=. if `depvar'==. & `touse'
		`noisily' di "Threshold: `depvar' < `t'"
		`noisily' `LDepModel' `useddepvar' `indepvars' if `touse' [`weight'`exp']
				
		tempvar yhat_`runner'
		
		predict `yhat_`runner'' if `touse'
		
		iop_dirun `yhat_`runner'' if `touse' [`weight'`exp']
		
		local max=max(`max',r(DI))
		local result_pdb_`runner'	=	r(DI)
		local result_ws_`runner'	=	r(DI)*r(avg)*4
		matrix define results=(results \ `result_pdb_`runner'',`result_ws_`runner'')
		
		}
	di "the matrix:"	
	matrix list results
	
	
	if(`bootstrap'){
		di as error "BOOTSTRAP not implemented for ordered variables. This would be to heavy. " _n "Please dichotomize the variable and use the bootstrap only on one threshold"
	}
	
	}
	// Display the results
		di as text "{hline 50}"
		di as result _col(5) "Inequality of opportunity in {it:`depvarl'} "
		di as text "{hline 50}"
		
		//di as text "Boostrap iterations" _col(26) "{c |}" as result %9.3g `bootstrap'
		
		di as text "Threshold" _col(20) "{c |}"  _col(25) "{help iop##pdb:PdB}" _col(36) "{help iop##ws:ws}"
		di as text "{hline 50}"
		local r=0
		foreach t of local levels{
			local r=`r'+1
			di as text "`depvarl' < `t'" _col(20) "{c |}"  _col(22) as result %9.6f results[`r',1] _col(33) as result %9.6f results[`r',2]
		}
		di as text "{hline 50}"
		di as text "Only absolute estimates are reported"
		di as text "Observations: "  as result %9.0f r(N)
	
	// Save result is rclass values
	return matrix iop=results
	return scalar pdb_max=`max'

} // end case==2 (ordered)
else if(`case'==3){ //CONTINOUS 
	quietly{
		tempvar loglin
		
		if("`nologlin'"!="nologlin"){
			gen `loglin' = ln(`depvar')
			}
		else{
			gen `loglin'=`depvar'
		}
		
		
		
		`noisily' reg `loglin' `indepvars' if `touse' [`weight'`exp']
		
		local res_var=e(r2)
		local N=e(N)
		predict `yhat' if `touse'
		
		if("`nologlin'"!="nologlin"){
			replace `yhat'=exp(`yhat')
			}
		
		iop_mld `yhat' if `touse' [`weight'`exp']
		local res_FGa=r(mld)
		iop_mld `depvar' if `touse' [`weight'`exp']
		local res_FGorg=r(mld)
		local res_FGr=`res_FGa'/`res_FGorg'
		
		
		
	
	if(`bootstrap' & `bootstrap'>0){
			noisily di as text "Bootstrapping..." _continue
			
				forvalues i=1/`bootstrap'{
				preserve
				qui: keep if `touse'
				bsample, `bootopt'
					iop `depvar' `indepvars' if `touse' [`weight'`exp']
					return list
					
				
					if(`i'==1){
						mat define estimates=(r(fg2r),r(fg1r),r(fg1a))
						}
					else{
						mat define estimates=(estimates \r(fg2r),r(fg1r),r(fg1a))
						}
					
					
					restore	
			
				}	// end loop through iterations of bootstrap
					
					matrix colnames estimates = "_est_fg2r"  "_est_fg1r" "_est_fg1a"
					matrix list estimates
					svmat estimates, names(matcol)
					local stats="fg2r fg1r fg1a"
					foreach stat of local stats{
						sum estimates_est_`stat'
						local BS_sd_`stat'=r(sd)
						}
						
					
					drop estimates_est_*
				noisily di as result "done!" _n	
			}
			
		}
	
	// Display the results
	di as text "{hline 70}"
	di as result _col(5) "Inequality of opportunity in {it:`depvar'} "
	di as text "{hline 34}{c +}{hline 35}"
	di as text "Method" _col(35)"{c |}"  %12s "Absolute" _col(50) %9s "Relative"
	di as text "{hline 34}{c +}{hline 35}"
	//di as text "Observations" 				_col(31) "{c |}" as result %12.0f `N'
	//di as text "Boostrap iterations" _col(26) "{c |}" as result %9.3g `bootstrap'
	
	di as text "{help iop##fg1:Ferreira-Gignoux (with scale)}" 			_col(35) "{c |}" as result %12.6f `res_FGa' _col(50) as result %9.6f `res_FGr'
	if(`bootstrap'){
		di as text "  Bootstrap std. err." 			_col(35) "{c |}" as result  "(" %10.6f `BS_sd_fg1a' ")" _col(50) as result "(" %9.6f `BS_sd_fg1a' ")"
		}
	di as text "{help iop##fg2:Ferreira-Gignoux (without scale)}" 		_col(35) "{c |}" as result %12s "not defined" _col(50) as result %9.6f `res_var'
		if(`bootstrap'){
		di as text "  Bootstrap std. err." 			_col(35) "{c |}"  _col(50) as result "(" %9.6f `BS_sd_fg2r' ")"
		}
	di as text "{hline 70}"
	di as text "Observations: "  _col(24) as result %9.0f `N'
	if(`bootstrap'){
		di as text "Bootstrap replications:" _col(24)	as result %9.0f `bootstrap'
	}
	
	// Save results in rclass values
	return scalar fg1a=`res_FGa'
	return scalar fg1r=`res_FGr'
	return scalar fg2r=`res_var'
	return scalar N=`N'
	if(`bootstrap'){
			return scalar fg1aSD=`BS_sd_fg1a'
			return scalar fg1rSD=`BS_sd_fg1r'
			return scalar fg2rSD=`BS_sd_fg2r'
			return scalar bootN=`bootstrap'
	}
	matrix input results = (`res_FGa',`res_FGr' \ . , `res_var')
	matrix rownames results="FG1" "FG2"
	matrix colnames results="absolute" "relative"
	return matrix iop=results
	
	
} // end case==3 (continuous)

if("`shapley'"!=""){
	
	display _n _n as text"{help iop##optshapley:Decomposition (Shapley method)}" _n "{hline 30}
	//CHECK FIRST IF THE REQUESTED STATISTIC TO DECOMPOSE IS OK
	if((`case'==1 & inlist("`shapley'","ws","pdb")) | (`case'==2 & "`shapley'"=="pdb_max") | (`case'==3 & inlist("`shapley'","fg1a","fg1r","fg2r"))){
		preserve
		
		iop_shapley  [`weight'`exp'] if `touse',stat(`shapley') indepvars(`indepvars') depvars(`depvar') gr(`sgroups') nologlin(`nologlin')
		capture drop _iop_wvar
		di as text "Variable" _col(21) "Value" _col(32) "In percentage" _n "{hline 45}"
		local runner=1
		matrix define shapley_norm=e(shapley)
		
		matrix define shapley_rel_norm=e(shapley_rel)
		
		if("`sgroups'"!=""){
			local numgroups = colsof(shapley_norm) // get the number of groups
			forvalues runner = 1/`numgroups'{
				di as text "Group `runner'" _col(20) as result %9.6f shapley_norm[1,`runner'] _col(35) as result %5.2f 100*shapley_rel_norm[1,`runner'] "%"
				local runner=`runner'+1
				}
		}
		else{
			foreach var of local indepvars{
				di as text "`var'" _col(20) as result %9.6f shapley_norm[1,`runner'] _col(35) as result %5.2f 100*shapley_rel_norm[1,`runner'] "%"
				local runner=`runner'+1
				}
			}
		di as text "{hline 45}"
		di as text "TOTAL" _col(20) as result %9.6f e(total)  _col(35) "100.00%
		di as text "{hline 45}"
			if("`sgroups'"!=""){
				di as text "The groups are defined as follows:"
				tokenize "`sgroups'", parse(",")
				gl stop=0
				local g=1
				while($stop==0){
					local group`g' `1'
					
					macro shift
					if("`1'"==","){ // ANOTHER "," more groups are expected
						local g=`g'+1
						macro shift
					} //end if
					else{
						gl stop=1
					} // end else
				} // end while
				
				forvalues runner=1/`numgroups'{
					display "Group `runner': `group`runner''"
				}	
				
			}
		
		
		}
		else{
		local col1=25
		local col2=35
		di as error "ERROR: The argument in the shapley option is not correct" 
		di as error "No decomposition has been performed. The correct option is:" _n _n
		di as error "Variable type"   			_col(`col1') "Argument" _col(`col2')	 "Decomposed statistic" _n "{hline 80}"
		
		di as error "Continuous (with scale)" 	_col(`col1') "fg1a"		_col(`col2')	"Mean-log deviation [Ferreira-Gignoux (2011)]"
		di as error "Continuous (no scale)"		_col(`col1') "fg2r"		_col(`col2')	"R squared [Ferreira-Gignoux (2011b)]"
		di as error "Dummy"						_col(`col1') "pdb"		_col(`col2')	"Dissimilarity index [Paes de Barros (2008)]"
		di as error "Dummy"						_col(`col1') "ws"		_col(`col2')	"Adapted dissim. idx [Wendelspiess Chavez Juarez (2013)]"
		di as error "Ordered"					_col(`col1') "pdb_max"	_col(`col2')	"Highest dissim. idx [Paes de Barros (2008)]"
		di as error "{hline 80}"
		}
		matrix define shapley = e(shapley)
		return matrix shapley=shapley
		return matrix shapley_rel=shapley_rel_norm

	}

if("`oaxaca'"!=""){
	display _n _n as text"{help iop##optgroup:Oaxaca-like decomposition}" _n "{hline 30}
	if(wordcount("`oaxaca'")!=2){
		di as error "ERROR: you have to specify the oaxaca option with two arguments"
		di as error "See the {help iop##optgroup:help file} for details on the syntax"
		exit 
		}
	
	tokenize `oaxaca'
	local groupvar="`1'"	
	local stat="`2'"
	
	capture confirm numeric variable `groupvar'
	if(_rc==0 & ((`case'==1 & inlist("`stat'","ws","pdb")) | (`case'==3 & inlist("`stat'","fg1a")))){
		quietly{
		levelsof(`groupvar'), local(levels)
		local G=0
		foreach l of local levels{
		local G=`G'+1
			if(`case'==1){
				`LDepModel' `depvar' `indepvars' if `touse' & `groupvar'==`l' [`weight'`exp']
				}
			else{
				tempvar loglin2
				if("`nologlin'"!="nologlin"){
					
					gen `loglin2' = ln(`depvar')
					}
				else{
					gen `loglin2'=`depvar'
					
				}
				
				reg `loglin2' `indepvars' if `touse' & `groupvar'==`l' [`weight'`exp']
				
				
			}
			/*tempvar yhat_gr`i'
			predict `yhat_gr`i''*/
			predict _yhat_gr`G'
			
			if("`nologlin'"!="nologlin"){
				replace _yhat_gr`G'=exp(_yhat_gr`G')
			}
			
		} // end foreach level
		
		sum _yhat_gr*
		// Create the indices for each combination
		matrix define oaxaca=I(`G')
		forvalues i=1/`G'{
			local j=0
			foreach l of local levels{
			local j=`j'+1
			di as text "comb: `i'-`j'"
				if(`case'==1){
					iop_dirun _yhat_gr`i' if `touse' & `groupvar'==`l' [`weight'`exp']
					if("`stat'"=="ws"){
						local value=r(DI)*r(avg)*4
						}
						else{
						local value=r(DI)
						}
					}
				else{
					iop_mld _yhat_gr`i' if `touse' & `groupvar'==`l' [`weight'`exp']
					local value=r(mld)
				}
				di as result "  `value'"
				matrix oaxaca[`j',`i']=`value'
			} // end loop of j
		} //end loop of i	
		}
		
		drop _yhat_gr*
		
		
		// OUTPUT
		di as text "Group variable:" _col(20) as result "`groupvar'"
		di as text "Statistic:"	_col(20) as result "`stat'"
		local vallabel:value label `groupvar'
	
		matrix rownames oaxaca=`levels'
		matrix colnames oaxaca=`levels'
		
		// Table title
		di as text _n _col(20) "Coefficients of"
		di  as text "Distribution" _col(14) "{c |}" _continue
		local c=17
		foreach col of local levels{
			local varlab:value label `groupvar'
			if("`varlab'"!=""){
				local valuelabel:label `varlab' `col'
				local valuelabel=abbrev("`valuelabel'",7)
				}
				else{
				local valuelabel="`col'"
				}
			di _col(`c') "`valuelabel'" _continue
			local c=`c'+10
		}
		local c=`c'-14
		di as text _n "{hline 13}" _col(14) "{c +}" "{hline `c'}" _continue
		local i=0
		foreach row of local levels{
			if("`vallabel'"!=""){
				local rowlabel:label `vallabel' `row'
				local rowlabel="`rowlabel'"
				}
				else{
				local rowlabel="`row'"
				}
				local rowlabel=abbrev("`rowlabel'",13)
			
			di as text _n "`rowlabel'" _col(14) "{c |}" _continue
			local i=`i'+1
			local j=0
			local c=17
			foreach col of local levels{
				local j=`j'+1
				if(`i'==`j' & `G'>2){
					di _col(`c') %6.5f as text oaxaca[`i',`j'] _continue
					}
				else{
					di _col(`c') %6.5f as result oaxaca[`i',`j'] _continue
					}
				local c=`c'+10
			}
			
			}
		
		return matrix oaxaca=oaxaca
		
		}
		else{
		local col1=25
		local col2=35
		di as error "ERROR: The argument in the oaxaca option is not correct" 
		di as error "No decomposition has been performed. The correct option is:" _n _n
		di as error "Variable type"   			_col(`col1') "Argument" _col(`col2')	 "Decomposed statistic" _n "{hline 80}"
		
		di as error "Continuous (with scale)" 	_col(`col1') "fg1a"		_col(`col2')	"Mean-log deviation [Ferreira-Gignoux (2011)]"
		//di as error "Continuous (no scale)"		_col(`col1') "fg2r"		_col(`col2')	"R squared [Ferreira-Gignoux (2011b)]"
		di as error "Dummy"						_col(`col1') "pdb"		_col(`col2')	"Dissimilarity index [Paes de Barros (2008)]"
		di as error "Dummy"						_col(`col1') "ws"		_col(`col2')	"Adapted dissim. idx [Wendelspiess-Soloaga (2013)]"
		//di as error "Ordered"					_col(`col1') "pdb_max"	_col(`col2')	"Highest dissim. idx [Paes de Barros (2008)]"
		di as error "{hline 80}"
		di as error "Note: The option 'oaxaca' is not available for ordered variables. Consult the {help iop##optgroup:help file} for details"
		}
	}
	di _n _n
	drop _all
	use `iop_orgdb', clear
	
end 

**************************************************************************************
********************** AUXILIARY PROGRAMS ********************************************
**************************************************************************************

capture program drop iop_dirun
program define iop_dirun, rclass
version 9.0
syntax varlist(max=1) [if] [in] [iweight fweight] 
preserve
marksample touse2
keep if `touse2'

	sum `varlist' [`weight'`exp'], mean
	local pmean=r(mean)
	local N=r(N)

	tempvar diff
	gen `diff'=abs(`varlist'-`pmean')

	qui: sum `diff' [`weight'`exp']
	local sum=r(sum)

	
	local DI=`sum'/(2*`pmean'*`N')
	return scalar DI=`DI'
	return scalar N=`N'
	return scalar avg=`pmean'

	restore
end

capture program drop iop_mld
	program define iop_mld, rclass
	version 9.0
	syntax varlist(max=1) [if] [in] [iweight fweight]
	preserve
	quietly{
	marksample touse2
	keep if `touse2'
	
	sum `varlist' [`weight'`exp']
	local mean=r(mean)
	tempvar mld
	gen `mld'=ln(r(mean)/`varlist')
	sum `mld' [`weight'`exp']
	local MLD=r(mean)
	return scalar mld=r(mean)
	}
end


capture program drop iop_old
program define iop_old , rclass 
version 9.2
syntax varlist [if] [in] [, BOOTstrap(integer 0) DECOMPosition GRoups(varlist max=1)  PRopt(str) BOOTOPT(str) PROBIT*]
marksample touse
quietly{

tokenize `varlist'
local depvar `1'
macro shift
local xvars `*'

// BOOTSTRAP
	if(`bootstrap' & `bootstrap'>0){
			
			forvalues i=1/`bootstrap'{
				preserve
				qui: keep if `touse'
				bsample, `bootopt'
			
					probit `varlist', `propt'
					predict _phat, pr
					iop_dirun _phat
					local DI=r(DI)
					if(`i'==1){
						mat define estimates=(`DI')
						}
					else{
						mat define estimates=(estimates \ `DI')
						}
					local DIrounded=round(`DI', 0.0001)
					
					restore	
			
				}	// end loop through iterations of bootstrap
					svmat estimates, names(_est)
					qui: sum _est1
					local SD=r(sd)

					drop _est1
			}	// end of bootstrap

			
// DECOMPOSITION
if("`decomposition'"=="decomposition"){
	 preserve
	 qui: keep if `touse'
	 local DIdecomptot=0
	 qui:probit `varlist', `propt' 
	 foreach var of local xvars{
		sum `var'
		gen _tmp_`var'=`var'
		replace `var'=r(mean)
		}
	 
	 
	 foreach var of local xvars{
					
			replace `var'=_tmp_`var'
			predict _est_`var', pr
			sum `var'
			replace `var'=r(mean)
			
			// compute the index
			iop_dirun _est_`var'
			local DI_`var'=r(DI)
			local DIdecomptot=`DIdecomptot'+`DI_`var''
					
		
		}	
		
		
		
		restore
		
}
// PERFORM THE DECOMPOSITION WITH A BASE OUTCOME
if("`groups'"!="" ){
		preserve
		keep if `touse'
		
		// Run the probit for each of the 
		levelsof `groups', local(grouplevels)
		foreach level of local grouplevels{
			`LDepModel' `varlist' if `groups'==`level', `propt' 
			est store prob_`level'
			predict _P_`level'
			}
		
		foreach beta of local grouplevels{
			foreach dist of local grouplevels{
				iop_dirun _P_`beta' if `groups'==`dist'
				local DI_b`beta'_d`dist'=r(DI)
				return scalar DI_b`beta'_d`dist'=r(DI)
			}
		}
			
	
	
		restore
	}





// Perform the main probit estimation and compute the point estimate of the DI
	preserve
	qui: keep if `touse'
	if("`probit'"=="probit"){
		noisily: probit `varlist', `propt'
		}
		else{
		probit `varlist', `propt'
		}
	
	predict _phat, pr
	iop_dirun _phat
	local DI=r(DI)
	local N=r(N)
	local DIrounded=round(`DI', 0.0001)
	restore	
	


}

if(`bootstrap'>0){
	local CIupper=`DI'+1.96*`SD'
	local CIlower=`DI'-1.96*`SD'
}

// GENERATE THE OUTPUT 
	di as text "{hline 70}"
	di as result "    Inequality of opportunity in {it:`depvar'} "
	di as text "{hline 25}{c +}{hline 44}"
	*di as text "Dependent variable" _col(26) "{c |}" as result "  `depvar'"
	*di as text "Independent variable" _col(26) "{c |}" as result "  `xvars'"
	di as text "Observations" _col(26) "{c |}" as result %9.3g `N'
	di as text "Boostrap iterations" _col(26) "{c |}" as result %9.3g `bootstrap'
	di as text "Dissimilarity index (DI)" _col(26) "{c |}" as result %9.3g `DIrounded'
	if(`bootstrap'>0){
		di as text "Bootstrap std. err. of DI" _col(26) "{c |}" as result %9.3g `SD'
		di as text "Confidence interval" _col(26) "{c |} [ " as result %4.3f `CIlower' as text " , " as result  %4.3f `CIupper' as text "]"
	}
	di as text "{hline 25}{c +}{hline 44}"
	if("`decomposition'"=="decomposition"){
		di as result "    Decomposition"
		di as text "{hline 70}"
			foreach var of local xvars{
		di as text "`var'" _col(26) "{c |}" as result %9.3g `DI_`var''
		}
		di as text "{hline 70}"
			}
			
	// OUTPUT OF GROUP-DECOMPOSITION EFFECTS
	if("`groups'"!=""){
		di ""
		di as result "Group decomposition by {it:`groups'}: "
		di as text  _col(20) "Coefficients"
		di as text _continue  "Distribution" 
		di as text _continue _col(15) "{c |}" 
		local xpos=25
		foreach val of local grouplevels{
			di as text _continue _col(`xpos') "`val'"
			local xpos=`xpos'+10
			}
			local width=`xpos'-10
			local smallwidth=`width'-15
		di as text _newline _continue "{hline 14}{c +}{hline `smallwidth'}"
		foreach dist of local grouplevels{
		di as text _newline _continue _col(10) "`dist'"
		di as text _continue _col(15) "{c |}"
			local xpos=20
				foreach beta of local grouplevels{
					di as result _continue _col(`xpos') %4.3f `DI_b`beta'_d`dist''
					local xpos=`xpos'+10
					}
		}
		di ""
		di ""
		di ""
		
		
		}


// STORE IMPORTANT RESULTS FOR FURTHER USE
	return scalar DI=`DI'
	return scalar N=`N'
	return scalar biter=`bootstrap'
	return local depvar="`depvar'"
	return local indepvar="`xvars'"
	if(`bootstrap'>0){
		return scalar ub=`CIupper'
		return scalar lb=`CIlower'
	}
	if("`decomposition'"=="decomposition"){
		foreach var of local xvars{
		return scalar DI_`var'=`DI_`var''
		}
		}
	 
end

*******************************************************************************************

capture program drop iop_shapley
program define iop_shapley , eclass 
version 9.2
syntax [anything] [iweight fweight] [if] [in], stat(str) Indepvars(str) Depvars(str) [GRoup(str) NOloglin(str)]

marksample touse2
tempfile orgshapley
quietly{
save `orgshapley', replace
keep if `touse2'
tempfile usedb
save `usedb'




if("`group'"!=""){ // this is the algorithm for the group specific shapley value
	
	gl stop=0
	local g=1
	
	tokenize "`group'", parse(",")
	
	while($stop==0){
		local group`g' `1'
		
		macro shift
		if("`1'"==","){ // ANOTHER "," more groups are expected
			local g=`g'+1
			macro shift
		} //end if
		else{
			gl stop=1
		} // end else
	} // end while
	
	
	if(`g'<=12 & c(version)<12){ // for stata version <12, adapt matsize 
		local newmatsize=max(2^`g'+200,c(matsize))
		capture set matsize `newmatsize'
		}
	if(`g'>12){
		local runs=2^`K'
		noisily di as error "Too many groups defined (`runs' needed)"
		noisily di as error "A maximum of 12 groups is allowed"
		exit
	}
	
	preserve
			drop _all
			set obs 2
			forvalues j=1/`g'{
				gen _group`j'=1 in 1/1
				replace _group`j'=0 in 2/2
				}
			fillin _group*
			
			local allvars ""
			forvalues j=1/`g'{
				foreach var of local group`j'{
					gen `var'=_group`j'
					local allvars "`allvars' `var'"
				}
			}
			
			drop _fillin
			gen result=.
			mkmat * , matrix(combinations) 
			matrix list combinations
			restore
	

		local numcomb=rowsof(combinations)
		local numcols=colsof(combinations)

		
		matrix combinations[1,`numcols']=0
			
		forvalues i=2/`numcomb'{
		local thisvars=""
			foreach var of local allvars{
				
				matrix mymat=combinations[`i',"`var'"]
				local test=mymat[1,1]
				
				if(`test'==1){
					
					local thisvars "`thisvars' `var'"
					
					}
				}
			di "`thisvars'"
			
			//noisily di "iop `depvars' `thisvars' [`weight'`exp'], `nologlin'
			iop `depvars' `thisvars' [`weight'`exp'], `nologlin'
			matrix combinations[`i',`numcols']=r(`stat')
			
		}
		matrix list combinations
		preserve
		drop _all
		matrix list combinations
		svmat combinations,names(col) 


}
else{ // no groups

local K=wordcount("`indepvars'")


if(`K'<=12 & c(version)<12){
	local newmatsize=max(2^`K'+200,c(matsize))
	capture set matsize `newmatsize'
	
}

if(2^`K'<=c(matsize)){

		preserve
			drop _all
			set obs 2
	
			foreach var of local indepvars {
				gen `var'=1 in 1/1
				replace `var'=0 in 2/2
				}
			fillin `indepvars'	
			

			drop _fillin
			gen result=.
			mkmat `indepvars' result , matrix(combinations) 
			matrix list combinations
		restore

		local numcomb=rowsof(combinations)
		local numcols=colsof(combinations)

		//di as error "(542)I have to perform `numcomb' regressions"
		matrix combinations[1,`numcols']=0
		forvalues i=2/`numcomb'{
		local thisvars=""
			foreach var of local indepvars{
				matrix mymat=combinations[`i',"`var'"]
				local test=mymat[1,1]
				
				if(`test'==1){
					local thisvars="`thisvars' `var'"
					}
				}
			//di "`thisvars'"
			
			iop `depvars' `thisvars' [`weight'`exp'] ,`nologlin'
			matrix combinations[`i',`numcols']=r(`stat')
			
		}
		preserve
		drop _all
		matrix list combinations
		svmat combinations,names(col) 
}
}

/* Start computing the shapley value*/
sum result
 
local full=r(max)
if("`group'"!=""){
	foreach var of varlist _group*{
		local IVlist "`IVlist' `var'"
		}
	egen t=rowtotal(_group*)
	sum t
	local Kgroup=r(max)
	replace t=t-1
	
	gen _weight = round(exp(lnfactorial(abs(t))),1) * round(exp(lnfactorial(`Kgroup'-abs(t)-1)),1)
	drop t
	tempvar flo
	keep _group* _weight result
	save `flo', replace
	matrix newshapley=[.]
	foreach var of local IVlist{
		local i=subinstr("`IVlist'","`var'","",1)
		reshape wide result _weight, i(`i') j(`var')
		gen _diff = result1-result0
		sum _diff [iweight = _weight1]
		use `flo',clear
		
		matrix newshapley = (newshapley \ r(mean))
	}
	matrix newshapley = newshapley[2...,1]
	matrix list newshapley
	matrix shapley=newshapley'
	matrix shapley_rel=shapley/`full'
	
	

} // end if group
else{


	
	
egen t=rowtotal(`indepvars')
replace t=t-1
gen _weight = round(exp(lnfactorial(abs(t))),1) * round(exp(lnfactorial(`K'-abs(t)-1)),1)
drop t


tempvar flo
save `flo', replace

matrix newshapley=[.]
foreach var of local indepvars{
	local i=subinstr("`indepvars'","`var'","",1)
	reshape wide result _weight, i(`i') j(`var')
	gen _diff = result1-result0
	sum _diff [iweight = _weight1]
	use `flo',clear
	
	matrix newshapley = (newshapley \ r(mean))
}
matrix newshapley = newshapley[2...,1]

	matrix shapley=newshapley'
	matrix shapley_rel=shapley/`full'
	
}
matrix result=(shapley\shapley_rel)




ereturn matrix shapley shapley
ereturn matrix shapley_rel shapley_rel

ereturn scalar total=`full'



	use `orgshapley', clear
	capture drop _iop_wvar
} //end quietly
end

********************
*!
*!--------------------- VERSION HISTORY -------------------
*! Version 2.6: Bugfix: the previous version did not log-linearlise the dependent variable as suggested in 
*!				Ferreira & Gignoux (2011). Now it does it by default. The new option 'nologlin' allows the 
*!				the user to avoid this transformation (Thanks to Paul Hufe for the hint)
*! Version 2.5: Bugfix with option iweight. Small corrections and encoding adaptions in the help file.
*! Version 2.4: We added the option to group circumstance variables in the shapley decomposition.
*! Version 2.3: We added the option 'logit' and 'bootstrap' and harmonized the layout of the output. 
*! Version 2.2: Minor change in the help file to be more consistent with explanation.
*! Version 2.1: Small bugfix and minor changes in the output to improve readability.
*! Version 2.0: added methods for continuous variables and translation invariant version of DI. 
*!            Decomposition now based on shapley value. Possibility to include fweight and iweights. 
*! Version 1.0: only dichotomous outcome variables


