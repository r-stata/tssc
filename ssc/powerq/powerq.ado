*! powerQ v1.10  June 2008

capture program drop powerq
program define powerq, rclass byable(recall) sortpreserve
version 8.0
syntax varlist(min=2 max=4 default=none numeric) [if] [in] ,method(string) [REPlicates(real 1000) ALPHA(real 0.1) TAU2(real 0.17989) graph ]

marksample touse
tokenize `varlist' 


* Checks if there is only one method specified
if "`method'"!="hedges" & "`method'"!="gardiner" & "`method'"!="simulation" & "`method'"!="jackson" {
	  di in re "Please, specify only one method of the following: jackson, gardiner, hedges, simulation" 
		exit 
	  }
 

*check what kind of data are provided:

if "`4'"=="" {
	di "You have provided effect size (in log scale) and relative standard error"
	
	* check if other method other than Jackson is asked

	if "`method'"!="jackson" {
		
		di as error "Only Jackson's method can be used with these kind of data" 
		exit	
	
	}
}






* check if alpha level is 0<alpha<1
capture confirm ex `alpha'
if !_rc { 
	if ((`alpha'>0 & `alpha'<1) | `alpha'==999) {
	}
	else {
		di in red "alpha level must be larger than 0 and smaller than 1 or different than 999"
		exit
	}
} 



preserve
qui keep if `touse'
local N = _N



 

*/ Gets the MH common odds ratio
if "`4'"=="" {
	metan `1' `2' , eform notable nograph
}

else {
	metan `1' `2' `3' `4', or notable nograph
}

local theta1 = r(ES)
local pQ=r(p_het)
local Q=r(het)
local df=r(df)


*. if alpha==999 then set alpha to pQ

if `alpha'==999 {
	* check if Q is significant (>=0.10)
	if `pQ'>=0.1 {
		local alpha1=0.1
		local alpha=0.1
	}
	else {
		local alpha1=`pQ'
		local alpha=0.1	
	}
}

else {
	local alpha1=`alpha'
}


* if tau2 has value of 999 then use the tau2 of the meta-analysis
if `tau2'==999 {

	if "`4'"=="" {
		metan `1' `2' , eform random notable nograph
	}

	else {
		metan `1' `2' `3' `4', or random notable nograph
	}
	
	local tau2 =r(tau2)
}




*/ gets the chi-squared critical level

local critical_value = invchi2tail(`df',`alpha1')


*/ Caculates power by the method of Hedges and Pigott (2001)

if "`method'"=="hedges" {
	local final_power = (1 - nchi2(`df',`Q', `critical_value'))*100	
	local methodT="Hedges & Pigott (2001)"
}


*/ Caculates power by the method of Jackson (2006)


if "`method'"=="jackson" {

tempvar weights S1 S2 S3 

if "`4'"!="" {
	* check for zero counts if 2x2 table is given

	forval k=1/`N' {
		forval i=1/4 {
		*	list ``i'' in `k'
			if ``i''==0 in `k' {
				forval j=1/4 {
					qui replace ``j''=``j''+0.5 in `k'
				}
			}
		}
	*list `1' `2' `3' `4'
	}

 
	qui gene `weights' = ((1/`1')+(1/`2')+(1/`3')+(1/`4'))^-1
}

else {
	qui gen `weights'=(1/(`2'^2))
	list `weights'
}

qui egen `S1' = sum(`weights')
qui egen `S2' = sum(`weights'^2)
qui egen `S3' = sum(`weights'^3)
local EQ = (`N'-1)+((`S1')-(`S2'/`S1'))*`tau2'
local VQ = 2*(`N'-1)+4*(`S1'-(`S2'/`S1'))*`tau2'+2*(`S2'-((2)*(`S3'/`S1'))+((`S2'/`S1')^2))*(`tau2'^2)

local r = (`EQ'^2)/(`VQ')
local lambda = `EQ'/`VQ'

local x=`lambda'*`critical_value'

local final_power=(1- gammap(`r',`x'))*100
local methodT="Jackson (2006)"

}	

*/ Caculates power by Simulation

if "`method'"=="simulation" {

	tempvar Ncases Ncontrols lnor_new pc logor or_new pc Ntotal pA a_s b_s c_s d_s
	qui gene `pc' = (`3')/(`3'+`4')
	qui gene `Ntotal' = `1'+`2'+`3'+`4'
	qui gene `Ncases' = `1'+`2'
	qui gene `Ncontrols' = `3'+`4'

	local power_simulation = 0
	local studies = _N
	local N = _N
	local lnor = ln(`theta1')
	local sd = sqrt(`tau2')

	forvalues i = 1/`replicates' {

		cap drop `a_s' `b_s' `c_s' `d_s' `or_new' `pA' `lnor_new'

	
		drawnorm `lnor_new' , n(`studies')  means(`lnor')  sds(`sd')
		qui gene `or_new' = exp(`lnor_new')


		qui gene `pA' = (((`pc')/(1-`pc'))*(`or_new'))
		qui replace `pA' = `pA'/(1+`pA')
		qui genbinomial `a_s', p(`pA') n(`Ncases')
		qui gene `b_s' = `Ncases' - `a_s'
		qui genbinomial `c_s', p(`pc') n(`Ncontrols')
		qui gene `d_s' = `Ncontrols'-`c_s'
		qui metan `a_s' `b_s' `c_s' `d_s', or random notable nograph
		local pQ_simu=r(p_het)		

	
		if `pQ_simu'<`alpha1' {
			local power_simulation = `power_simulation'+1
		}
	}
	
	local final_power = (`power_simulation'/`replicates')*100
	local methodT="Simulation"
}
	


if "`method'"=="gardiner" {

	*/ Creates a number of temporary variables 
	local methodT="Gardiner's Method (1999)"
	tempvar r2_i r1_i m1_i f_i g_i a_i V_i b_i c_i d_i total w_i vi wk1 wk2 logor SE

	*/ Calculates the observed marginals based on table 2 (Gardiner et al., 1999)

	qui gene `r1_i' = `1'+`2'
	qui gene `r2_i' = `3'+`4'
	qui gene `m1_i' = `1'+`3'

	*/ Obtains the values of fi and gi to get the expect counts of a

	qui gene `f_i' = (`theta1'*(`r1_i'+`m1_i'))+(`r2_i'-`m1_i')
	qui gene `g_i' = 4*(`theta1')*(`theta1'-1)*`r1_i'*`m1_i'

	*/ Equations that will generate all expected cell counts (ai, bi, ci and di)

	qui gene `a_i' = ((`f_i')- (sqrt(`f_i'^2-(`g_i'))))/(2*(`theta1'-1))
	qui gene `total' = `1'+`2'+`3'+`4'
	qui gene `b_i' = `r1_i'-`a_i'
	qui gene `c_i' = `m1_i'-`a_i'
	qui gene `d_i' = `total'-`a_i'-`b_i'-`c_i'

	*/ Calculates the variance, SE and weights for the logor under null hypothesis based on expected cell counts

	qui gene `V_i'  = (`a_i'^-1)+(`b_i'^-1)+(`c_i'^-1)+(`d_i'^-1)
	qui gene `SE' = sqrt(`V_i')
	qui gene `w_i' = `V_i'^-1
	qui summarize `w_i' 
	local wi = r(sum)
	qui gene `logor' = ln((`1'*`4')/(`2'*`3'))


	*/ Creates a local to store the power

	local power = 0



	/* Runs n simulations by drawing independent standard normal variables ~N(0,1)
	 Calculations are based on equation 8 of Gardiner's paper.
	Equation 8 was partitioned in two smaller parts: _wk1_power and _wk2_power */
	forvalues i = 1/`replicates' {
		qui set obs `N'
		drawnorm Z`i'

		*/ Equation 8 (part 1)
		qui gene _wk1_power = ((Z`i'*`SE')+(`logor'))*((Z`i'*`SE')+(`logor'))*`w_i'
		qui summarize _wk1_power 
		local wk1_power = r(sum)

		*/ Equation 8 (part 2)              
		qui gene _wk2_power = ((Z`i'*`SE')+(`logor'))*(`w_i')
		qui summarize _wk2_power 
		local wk2_power = ((r(sum))^2)

		*/ Equation 8 (complete)
		local wk_f_power = ((`wk1_power') - ((`wk2_power')/(`wi')))

		*/ Counts if the observed value of the statistic is greater than the critical level

		if `wk_f_power'>`critical_value' {
			local power = `power'+1
		}
	
		drop _wk1_power _wk2_power Z`i'
	}


	*/ calculate power of Q
	local final_power = (`power'/`replicates')*100
}

/*-------------- Returns a scalar and prints the output on screen--------------*/
return scalar Q=`Q'
return scalar df=`df'
return scalar p_Q=`pQ'
return scalar power = `final_power'



di as text " "
di as text " "
di as text "Statistical Power for the Q-test - " "`methodT'" 
di as text " "
di as text "{hline 32}
di as text " Cochran's Q        =  " as res %5.2f  `Q' 
di as text " Degrees of freedom = " as res %6.0f  `df' 
di as text " p-value for Q      = " as res %5.4f  `pQ'
di as text " Power              =  " as res %4.2f  `final_power' as text "%"



*/ Presents the number of simulation only for the Gardiner's method and the simulation approach


if ("`method'"=="gardiner" | "`method'"=="simulation") { 
	di as text " Simulations        = " as res `replicates' 
}


di as text " Alpha level        = " as res %6.4f `alpha1' 
di as text "{hline 52}

*/ formula for Ho==no heterogeneity
local beta=1-(`final_power'/100)
di as text "Probability that there is heterogeneity: " 
forval priori = 1/99 {
	local prior=`priori'/100
		
	if (`pQ'<`alpha')	{
		local nomi1=`alpha1'
		local denomi1=(`alpha1'+((1-`beta')*((1-`prior')/`prior')))
	}
	else {
		local nomi1=1-`alpha1'
		local denomi1=((1-`alpha1')+(`beta'*((1-`prior')/`prior')))
	}

	local priorH=100-`priori'
	scalar probHeter`priorH'=1-(`nomi1'/`denomi1')


/* EXTENDED OUTPUT
di as text "prior = " as res %4.2f priori as text "%" as text " >> probability = " as res %4.2f probHeter*100  as text "%"	
*/	
	return scalar probHeter`priorH' = probHeter`priorH'*100
}

foreach num of numlist 1 10(10)90 99 {
di as text "prior = " as res %4.2f `num' as text "%" as text " >> probability = " as res %4.2f probHeter`num'*100  as text "%"		
}
di as text "{hline 52}



/*------------- here starts the graph -----------------------*/

capture confirm ex `graph'
if !_rc {

	* local to carry the graph command
	local cmd=" "

	* create temp variables
	tempvar _temp1 _temp2 _auc
	* count how many obs there are
	local n=_N+1

	*set more if we need to

	if (_N<99) {
		qui set obs 99
	}
	forval i=1/2 {
		qui gen _temp`i'=.
	

		forval j = 1/99 {
			if (`i'==2) {
				qui replace _temp`i'=`j'/100 in `j'
			}	
			else {
				qui replace _temp`i'=probHeter`j' in `j'
			}
		}
	}	 
	forval i=1/2 {
		local cmd="`cmd'"+" " + "_temp`i'"
	}

	line `cmd', ylabel(0(0.1)1) xtitle("Prior probability of heterogeneity") ytitle("Posterior probability of heterogeneity ") 

	if (_N==99) {
		qui drop in `n'/99
	}

}


restore
end
