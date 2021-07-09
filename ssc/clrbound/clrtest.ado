capt program drop clrtest
program define clrtest, eclass

version 11.2

syntax anything [if] [in] [, METhod(string) LEVel(numlist) noRSEED SEED(integer 0) *]

ereturn clear

if "`rseed'" != "norseed" {
	set seed `seed' 
}

if "`level'" == "" {
	local level 0.5 0.9 0.95 0.99
}

if "`method'" == "series" {
	quietly clr_s `anything' `if' `in' , lower lev("`level'") `options'
}


else if "`method'" == "local" {
	quietly clr_k `anything' `if' `in' , lower lev("`level'") `options'
}

else{
	quietly clr_p `anything' `if' `in' , lower lev("`level'") `options'
}


local nlevel = wordcount("`level'")

tempname level_vector

mat `level_vector' = J(`nlevel',1,0)

forval i = 1/`nlevel' {
	mat `level_vector'[`i',1] = real(word("`level'",`i'))
}


ereturn local cmd = "clr_test"
ereturn local title  = "CLR Intersection Bounds (Test)"

display as text _newline e(title) _col(59) "Number of obs : " as result e(N)
	
if "`method'" == "series" {

	display as text "Estimation Method : Cubic B-Spline (" e(smoothing) ")" 

	local grid_count = 0
	tokenize `x'

	forval i = 1/`e(n_ineq)' {
		
		display as text "{hline 81}"
		display as text "Inequality #`i' : " word(e(depvar),`i') " (# of Grid Points : " as result e(grid`i') as text ", Independent Variable : " e(indep`i') " )"
		display as text "Numbers of Approximating Functions : " as result e(nf_x`i') 	
		local grid_count = `grid_count' + e(grid`i')
	}

	display as text "{hline 81}" 


	if "`ais'" != "noais" {
		display as text _newline "AIS(adaptive inequality selection) is applied" 
	}
	else { 
		display as text _newline "AIS(adaptive inequality selection) is not applied" 
	}
}

else {

	forval i = 1/`e(n_ineq)' {
		display as text "Inequality #`i' : " word(e(depvar),`i') " (# of Grid Points : " as result e(grid`i') as text ", Independent Variables : " e(indep`i') " )"
	}
		
	if "`ais'" != "noais" {
		display as text _newline "AIS(adaptive inequality selection) is applied" 
	}
	else { 
		display as text _newline "AIS(adaptive inequality selection) is not applied" 
	}
}

display as text _newline "< Testing Result >"  

forval i = 1/`nlevel' {
	
	local ori_level = `level_vector'[`i',1] * 100 
	while (int(`ori_level') != `ori_level') {
		local ori_level = `ori_level' * 10 
	}
	
	if `e(bd`ori_level')' < 0 {
		display as text "The testing value is in the " as result `level_vector'[`i',1]*100 as text "% confidence interval."   
		display as text "In other words, the null hypothesis is " as result "NOT" as text " rejected at the " as result 100-`level_vector'[`i',1]*100 as text "% level." 
		ereturn scalar det`ori_level' = 1
	}		
	else {
		display as text "The testing value is " as result "NOT" as text " in the " as result `level_vector'[`i',1]*100 as text "% confidence interval." 
		display as text "In other words, the null hypothesis is rejected at the " as result 100-`level_vector'[`i',1]*100 as text "% level." 
		ereturn scalar det`ori_level' = 0
	}
}


end
