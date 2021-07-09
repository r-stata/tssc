*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.1.0 09 November 2019
*! HIY 1.1.1 16 April 2020 (Fixed the bug that made the program fail when the numeraire is the only variable in varlist1)
program define lclogitwtp2, rclass sortpreserve
	version 13.1	
	if ("`e(cmd)'" != "lclogitml2")&("`e(cmd)'" != "lclogit2") error 301
	
	syntax, [INCOME(varname) COST(varname) NONLCom *] 

	tempname B B_row B_new B_rand b_fix WTP_rand WTP_fix B_5 B_10 B_15 B_20 B_fix
	
	** Check whether specified options are valid **
	if ("`income'" == "") & ("`cost'" == "") {
		display as error "either income() or cost() must be specified."
		exit 198
	}
	
	if ("`income'" != "") & ("`cost'" != "") {
		display as error "income() and cost() cannot be specified at the same time."
		exit 184
	}
	
	if ("`nonlcom'" != "") & ("`options'" != "") {
		display as error "option nonlcom cannot be combined with nlcom options (e.g. `options')."
		exit 184
	}	
	
	** call income() or cost() as money henceforth **
	if ("`income'" != "") local money `income'
	if ("`cost'" != "") local money `cost'	
	
	** check if income(varname) or cost(varname) has been correctly specified **
	local MU_rand = 0
	local MU_fix  = 0
	
	capture di _b[Class1:`money']
	if (_rc == 0) local MU_rand = 1 
	
	capture di _b[Fix:`money']
	if (_rc == 0) local MU_fix = 1
	
	if (`MU_fix' != 1 & `MU_rand' != 1) {
		display as error "no estimated coefficient on variable `money'."
		exit 197		
	}	

	** notes for irrelevant options **
	if ("`e(cmd)'" == "lclogit2" & "`nonlcom'" != "") {
		display as text "NOTES: lclogit2 results are active. option nonlcom is irrelevant." 
	}
	
	if ("`e(cmd)'" == "lclogit2" & "`options'" != "") {
		display as text "NOTES: lclogit2 results are active. nlcom options (e.g. `options') are irrelevant." 
	}	
	
	** notes for suspcious signs of marginal utility **
	if (`MU_rand' == 1) {
		forvalues c = 1/`=e(nclasses)' {
			local sign_note = 0
			if ("`income'" != "") {
				capture assert _b[Class`c':`money'] >= 0
				if (_rc != 0) local sign_note = 1 
			}
			if ("`cost'" != "") {
				capture assert _b[Class`c':`money'] <= 0
				if (_rc != 0) local sign_note = 1 
			}			
		}
		if (`sign_note' == 1 & "`income'" != "") {
			display as text "NOTES: at least one coef. on `income' is negative. check if option income() is appropriate given your model." 
		}
		if (`sign_note' == 1 & "`cost'" != "") {
			display as text "NOTES: at least one coef. on `cost' is positive. check if option cost() is appropriate given your model." 		
		}		
	}
	if (`MU_fix' == 1) {
		local sign_note = 0
		if ("`income'" != "") {
			capture assert _b[Fix:`money'] >= 0
			if (_rc != 0) local sign_note = 1 
		}
		if ("`cost'" != "") {
			capture assert _b[Fix:`money'] <= 0
			if (_rc != 0) local sign_note = 1 
		}			
		if (`sign_note' == 1 & "`income'" != "") {
			display as text "NOTES: the coef. on `income' is negative. check if option income() is appropriate given your model." 
		}
		if (`sign_note' == 1 & "`cost'" != "") {
			display as text "NOTES: the coef. on `cost' is positive. check if option cost() is appropriate given your model." 		
		}		
	}	
		
	** macros for the marginal utility of money **
	forvalues c = 1/`=e(nclasses)' {
		if (`MU_rand' == 1) {
			if ("`income'" != "") local MU_`c' _b[Class`c':`money']
			if ("`cost'" != "")   local MU_`c' (-1 * _b[Class`c':`money'])			
		}		
		if (`MU_fix' == 1) {
			if ("`income'" != "") local MU_`c' _b[Fix:`money']
			if ("`cost'" != "")   local MU_`c' (-1 * _b[Fix:`money'])			
		}		
	}
	
	** exclude money from the list of indepdendent variables **
	local indepvars_rand `e(indepvars_rand)'
	local indepvars_rand: list indepvars_rand - money
	local sizeof_rand: list sizeof indepvars_rand
	
	local indepvars_fix `e(indepvars_fix)'
	local indepvars_fix: list indepvars_fix - money
	local sizeof_fix: list sizeof indepvars_fix 
	
	if (`sizeof_rand' == 0 & `sizeof_fix' == 0) {
		display as error "`money' is the only independent variable in the model."
		exit 197
	}
	
	** collect class-specific WTP into matrices ** 
	forvalues c = 1/`=e(nclasses)' {
		capture matrix drop `B_row'
		if (`sizeof_rand' > 0) {
			foreach v in `indepvars_rand' {
				matrix `B_new' = _b[Class`c':`v'] / `MU_`c''
				matrix rownames `B_new' = Class`c'
				matrix colnames `B_new' = "WTP:`v'"
				matrix `B_row' = nullmat(`B_row'), `B_new'
			}
		}
		if (`MU_rand' == 1) { 
			if (`sizeof_fix' > 0) {		
				foreach v in `indepvars_fix' {
					matrix `B_new' = _b[Fix:`v'] / `MU_`c'' 
					matrix rownames `B_new' = Class`c'
					matrix colnames `B_new' = "WTP:`v'"
					matrix `B_row' = nullmat(`B_row'), `B_new'			
				}
			}
		}
		matrix `B_rand' = nullmat(`B_rand') \ `B_row'
	}

	if (`MU_fix' == 1) { 
		capture matrix drop `B_row'
		if (`sizeof_fix' > 0) {		
			foreach v in `indepvars_fix' {
				matrix `B_new' = _b[Fix:`v'] / `MU_1' 
				matrix rownames `B_new' = Fix
				matrix colnames `B_new' = "WTP:`v'"
				matrix `B_row' = nullmat(`B_row'), `B_new'			
			}
			matrix `b_fix' = `B_row'			
		}
	}	
	
	** store the WTP coefficients in a r() matrix **
	matrix `WTP_rand' = `B_rand'
	return matrix WTP_rand = `B_rand'
	if (`MU_fix' == 1 & `sizeof_fix' > 0) {
		matrix `WTP_fix'  = `b_fix'
		return matrix WTP_fix = `b_fix' 
	}
	
	** display WTP coefficients in a table format **
	di as gr ""	
	di as gr "Willingness-to-pay (WTP) coefficients"
	di as gr ""
	local _int = int(`e(nclasses)'/5)
	if `e(nclasses)'>20 {
		capture matrix list `WTP_fix'
		if (_rc != 0) {
			di as g "Note: Results for models with more than 20 classes can be displayed using matrix r(WTP_rand)."
			matlist `WTP_rand', format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined)   
		}
		if (_rc == 0) {
			di as g "Note: Results for models with more than 20 classes can be displayed using matrices r(WTP_rand) and r(WTP_fix)."
			matlist `WTP_rand', format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined)  		
			matlist `WTP_fix', format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined) 
		}
	}
	else {
		capture matrix list `WTP_fix'
		if (_rc == 0) {
			forvalues c = 1/`=e(nclasses)' {
				matrix `B_fix' = nullmat(`B_fix') \ `WTP_fix'
			}	
			matrix `B' = `WTP_rand', `B_fix'
		}
		else matrix `B' = `WTP_rand'
		matrix coleq `B' = :
		forvalues i = 1/`=`_int'+1' {
			if (`=`i'*5' <= `e(nclasses)') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`=`i'*5',1...]
			else if (`=`i'*5' != `=`e(nclasses)'+5') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`e(nclasses)',1...]		
			if (`=`i'*5' != `=`e(nclasses)'+5') matlist `B_`=`i'*5''', format(%7.3f) rowtitle(WTP for) ///
																			border(top bottom) noblank	
		}		
	}	
	
	** use delta methods for statistical inferences on WTP coefficients **
	if ("`e(cmd)'" == "lclogitml2") & ("`nonlcom'" == "") {	
		forvalues c = 1/`=e(nclasses)' {
			if (`sizeof_rand' > 0) {
				foreach v in `indepvars_rand' {
					local nlcom_list `nlcom_list' (C`c'_`v': _b[Class`c':`v'] / `MU_`c'')
				}
			}
			if (`MU_rand' == 1) { 
				if (`sizeof_fix' > 0) {		
					foreach v in `indepvars_fix' {
						local nlcom_list `nlcom_list' (C`c'_`v': _b[Fix:`v'] / `MU_`c'')			
					}
				}
			}
		}
		
		if (`MU_fix' == 1) { 
			if (`sizeof_fix' > 0) {		
				foreach v in `indepvars_fix' {
					local nlcom_list `nlcom_list' (Fix_`v': _b[Fix:`v'] / `MU_1')			
				}
			}
		}
		di ""
		di as gr "Please wait: -nlcom- is calculating standard errors for the WTP coefficients." 
		if ("`options'" == "") nlcom `nlcom_list'
		else nlcom `nlcom_list', `options'
	}
end
