capt program drop clr_kb
program define clr_kb, eclass

version 11.2 

gettoken varl 0: 0, match(leftover)

if "`leftover'" != "(" {
	display as error "syntax error"
	error 198
}

gettoken varu 0: 0, match(leftover)

if "`leftover'" != "(" {
	display as error "syntax error"
	error 198
}

syntax [if] [in] [, noTEST NULL(real 0) LEVel(numlist) noAIS noUNDERSmooth RND(integer 10000) SEed(integer 0) *]

if "`level'" == "" {
	local level 0.5 0.9 0.95 0.99
}

local nlevel = wordcount("`level'")

forval i = 1/`nlevel' {
	local p_level = (real(word("`level'",`i'))+1)/2
	local con_level `con_level' `p_level'
}

tempname ori_level_vector

mat `ori_level_vector' = J(`nlevel',1,0)

forval i = 1/`nlevel' {
	mat `ori_level_vector'[`i',1] = real(word("`level'",`i'))
}

if "`undersmooth'" != "noundersmooth" {
	local txt_smooth "Undersmoothed"
}
else {
	local txt_smooth "Not Undersmoothed"
}

quietly clr_k `varl' `if' `in', lower lev("`con_level'") `ais' `undersmooth' rnd(`rnd') `options'

local lnum_ineq `e(n_ineq)'
local N `e(N)' 

local ldepvar "`e(depvar)'"

forval i = 1/`lnum_ineq' {
	tempname ltheta_ineq`i' lse_ineq`i' lais_ineq`i'
	
	local lbdwh`i' `e(bdwh`i')'
	local lgrid_ineq`i' `e(grid`i')'
	local lindep_ineq`i' "`e(indep`i')'"
	local lrange_ineq`i' "`e(range`i')'"
	mat `ltheta_ineq`i'' = e(theta`i')
	mat `lse_ineq`i'' = e(se`i')
	if "`ais'" != "noais" {
		mat `lais_ineq`i'' = e(ais`i')
	}
} 

forval i = 1/`nlevel' {
	local ori_level = `ori_level_vector'[`i',1] * 100 
	local bd_level = (`ori_level_vector'[`i',1] + 1) * 100 / 2 
	while (int(`ori_level') != `ori_level') {
		local ori_level = `ori_level' * 10 
		local bd_level = `bd_level' * 10 
	}
	while (int(`bd_level') != `bd_level') {
		local bd_level = `bd_level' * 10 
	}
	local lbound`ori_level' `e(bd`bd_level')'
	local lcl`ori_level' `e(cl`bd_level')'
		
}


quietly clr_k `varu' `if' `in' , lev("`con_level'") `ais' `undersmooth' rnd(`rnd') `options'

local unum_ineq `e(n_ineq)'
local N `e(N)' 

local udepvar "`e(depvar)'"

forval i = 1/`unum_ineq' {
	tempname utheta_ineq`i' use_ineq`i' uais_ineq`i'
	
	local ubdwh`i' `e(bdwh`i')'
	local ugrid_ineq`i' `e(grid`i')'
	local uindep_ineq`i' "`e(indep`i')'"
	local urange_ineq`i' "`e(range`i')'"
	mat `utheta_ineq`i'' = e(theta`i')
	mat `use_ineq`i'' = e(se`i')
	
	if "`ais'" != "noais" {
		mat `uais_ineq`i'' = e(ais`i')
	}
} 


forval i = 1/`nlevel' {
	local ori_level = `ori_level_vector'[`i',1] * 100 
	local bd_level = (`ori_level_vector'[`i',1] + 1) * 100 / 2 
	while (int(`ori_level') != `ori_level') {
		local ori_level = `ori_level' * 10 
		local bd_level = `bd_level' * 10 
	}
	while (int(`bd_level') != `bd_level') {
		local bd_level = `bd_level' * 10 
	}
	local ubound`ori_level' `e(bd`bd_level')'
	local ucl`ori_level' `e(cl`bd_level')'
		
}

// Additional Grid Search 

if "`test'" != "notest" {
	
	local test ` '
	local i = 1
	
	foreach a of local ldepvar {
		tempvar clrtest_`a'
		gen `clrtest_`a'' = `a' - `null'
		local dummy "(`clrtest_`a'' `lindep_ineq`i'' `lrange_ineq`i'' )"
		local test `test' `dummy'  
		local i = `i' + 1
	}
	
	
	local i = 1
	foreach a of local udepvar {
		tempvar clrtest_`a'
		gen `clrtest_`a'' = `null' - `a'
		local dummy "(`clrtest_`a'' `uindep_ineq`i'' `urange_ineq`i'' )"
		local test `test' `dummy'
		local i = `i' + 1
	}
	
	
	quietly clrtest `test' , met("local") lev("`level'") `ais' `undersmooth' rnd(`rnd') `options'
	
	forval i = 1/`nlevel' {
		local ori_level = `ori_level_vector'[`i',1] * 100 
		while (int(`ori_level') != `ori_level') {
			local ori_level = `ori_level' * 10 
		}
		local test_bound`ori_level' `e(bd`ori_level')'
		local test_cvl`ori_level' `e(cl`ori_level')'
		local test_det`ori_level' `e(det`ori_level')'
		
	}	
	
	
	local sum_ineq = `lnum_ineq' + `unum_ineq' 
	forval i = 1/`sum_ineq' {
		tempname test_theta_ineq`i' test_se_ineq`i' test_ais_ineq`i' 
		
		local tbdwh`i' `e(bdwh`i')'
		mat `test_theta_ineq`i'' = e(theta`i')
		mat `test_se_ineq`i'' = e(se`i')
		if "`ais'" != "noais" {
			mat `test_ais_ineq`i'' = e(ais`i')
		}
	}
	
}


ereturn clear 

ereturn scalar N = `N'
ereturn scalar l_ineq = `lnum_ineq'
ereturn scalar u_ineq = `lnum_ineq'

ereturn local ldepvar = "`ldepvar'" 
ereturn local udepvar = "`udepvar'" 

ereturn local cmd = "clr_pb2"
ereturn local title  = "CLR Intersection Bounds (Local Linear)"
ereturn local level = "`level'"
ereturn local smoothing = "`txt_smooth'"
  
display as text _newline e(title) _col(59) "Number of obs : " as result e(N)


display as text _newline  "< Lower Side >" 

forval i = 1/`lnum_ineq' {
	ereturn scalar l_grid`i' = `lgrid_ineq`i''
	ereturn scalar l_bdwh`i' = `lbdwh`i''
	ereturn local l_indep`i' "`lindep_ineq`i''"
	ereturn local l_range`i' "`lrange_ineq`i''"
	
	if "`ais'" != "noais" {
		ereturn matrix l_ais`i' = `lais_ineq`i''
	}
	
	ereturn matrix l_se`i' = `lse_ineq`i''
	ereturn matrix l_theta`i' = `ltheta_ineq`i''

	display as text "Inequality #`i' : " word(e(ldepvar),`i') " (# of Grid Points : " as result e(l_grid`i') as text ", Independent Variables : " e(l_indep`i') " )"
}
	


display as text "< Upper Side >"

forval i = 1/`unum_ineq' {
	
	ereturn scalar u_grid`i' = `ugrid_ineq`i''
	ereturn scalar u_bdwh`i' = `ubdwh`i''
	ereturn local u_indep`i' "`uindep_ineq`i''"
	ereturn local u_range`i' "`urange_ineq`i''"
	
	if "`ais'" != "noais" {
		ereturn matrix u_ais`i' = `uais_ineq`i''
	}
	
	ereturn matrix u_se`i' = `use_ineq`i''
	ereturn matrix u_theta`i' = `utheta_ineq`i''

	display as text "Inequality #`i' : " word(e(udepvar),`i') " (# of Grid Points : " as result e(u_grid`i') as text ", Independent Variables : " e(u_indep`i') " )"
}
	

if "`ais'" != "noais" {
	display as text _newline "AIS(adaptive inequality selection) is applied" 
}
else { 
	display as text _newline "AIS(adaptive inequality selection) is not applied" 
}

if "`undersmooth'" != "noundersmooth" {
	display as text "Bandwidths are undersmoothed" 
}
else { 
	display as text "Bandwidths are not undersmoothed" 
}
	
display as text _newline  _col(4) "Bonferroni Bounds" _col(38) "{c |}" _col(56) "Value"
display as text "{hline 37}{c +}{hline 45}"

forval i = 1/`nlevel' {
	local ori_level = `ori_level_vector'[`i',1] * 100 
	while (int(`ori_level') != `ori_level') {
		local ori_level = `ori_level' * 10 
	}
	ereturn scalar lbd`ori_level' = `lbound`ori_level''
	ereturn scalar lcl`ori_level' = `lcl`ori_level''
	ereturn scalar ubd`ori_level' = `ubound`ori_level''
	ereturn scalar ucl`ori_level' = `ucl`ori_level''
	
	if `e(lbd`ori_level')' > `e(ubd`ori_level')' {
		display as text `ori_level_vector'[`i',1]*100 "% two-sided confidence interval" _col(38)"{c |}" _col(53) "empty" 
	}
	else display as text `ori_level_vector'[`i',1]*100 "% two-sided confidence interval" _col(38)"{c |}" _col(50) "[ " as result %9.7f e(lbd`ori_level') as text ", " as result %9.7f e(ubd`ori_level') as text " ]"
	
}

display as text "{hline 37}{c BT}{hline 45}"


if "`test'" != "notest" {
	ereturn scalar null = `null'
	
	display as text _newline "< Testing Result >"  _col(58) " Null Hypothesis : " as result e(null)
	
	forval i = 1/`sum_ineq' {
		if "`ais'" != "noais" {
			ereturn matrix t_ais`i' = `test_ais_ineq`i''
		}
		ereturn scalar t_bdwh`i' = `tbdwh`i''
	
		ereturn matrix t_se`i' = `test_se_ineq`i''
		ereturn matrix t_theta`i' = `test_theta_ineq`i''
		
	}
	
	forval i = 1/`nlevel' {
		local ori_level = `ori_level_vector'[`i',1] * 100 
		while (int(`ori_level') != `ori_level') {
			local ori_level = `ori_level' * 10 
		}
		ereturn scalar t_bd`ori_level' = `test_bound`ori_level''
		ereturn scalar t_cvl`ori_level' = `test_cvl`ori_level''
		ereturn scalar t_det`ori_level' = `test_det`ori_level''
	
		if `e(t_det`ori_level')' == 1 {
			display as text "The value " as result e(null) as text " is in the " as result `ori_level_vector'[`i',1]*100 as text " % confidence interval for two-sided bounds"   
		}		
		else {
			display as text "The value " as result e(null) as text " is " as result "NOT" as text " in the " as result `ori_level_vector'[`i',1]*100 as text " % confidence interval for two-sided bounds" 
		}
	}
}  


end 


