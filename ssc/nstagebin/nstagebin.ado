*! nstagebin v1.0.1 17jul2014
cap program drop nstagebin
cap mata: mata drop mvnprob()

program def nstagebin, rclass
version 10.0

local ver 1.0.1
local date 17 Jul 2014


/*
	Determine sample size for multi-arm multi-stage trial with binary outcome
	I- and D-outcome can differ and can be either superiority or non-inferiority
	Analysed using absolute difference in proportions
	Account for follow-up period and loss-to-follow-up rate
	Calculate stage-specific pairwise type I error rate and power
	Allow PPV = P(D=1 | I=1) to differ between arms	
	Option to calculate FWER & ESS
	Prob option to calculate P(k arms reaching stage j) when 0 or all effective arms

	Must specify:
		Number of stages and number of arms in each stage
		Significance level and power in each stage
		Accrual rate (number patients/unit time)
		Target differences under H0 and H1
		Control arm event rates
		PPV (if I!=D)
		
	Optional
		Allocation ratio (A=E/C)
		Length of follow-up period
		Attrition/loss-to-follow-up rates
		
	v1.0.1 - add extrat option
*/

// NB: A 'stage' consists of the time between analyses, hence includes the f/u period
//		in which more patients will be recruited in advance of the next stage

syntax, Nstage(int) ACcrate(string) ALpha(string) POwer(string) ARms(string) theta0(string) theta1(string) ///
   Ctrlp(string) [FU(string) Ltfu(string) Extrat(real 0) ppvc(real 999) ppve(real 999) ARAtio(real 1) Tunit(int 1) ///
   NOFwer ESs PRObs seed(int -1) reps(int 250000)] 

local errcount 0

if `nstage' < 1 {
	di as err "nstage must be 1 or more"
	local ++errcount
}

if `ppvc'!=999 & `ppve'==999 {
	di as err "ppve() also needs specifying"
	local ++errcount
}

if `ppvc'==999 & `ppve'!=999 {
	di as err "ppvc() also needs specifying"
	local ++errcount
}

local have_D = (`ppvc'!=999 & `ppve'!=999)		// changed from ppv

if `extrat'<0 {
	di as err "extrat() must be 0 or greater"
	local ++errcount
}

if `aratio'<0 {
	di as err "aratio() must be greater than 0"
	local ++errcount
}


// Set default values if not specified
if "`ltfu'"=="" {
	if `have_D'==0 local ltfu = 0
	else local ltfu = "0 0"
}

if "`fu'"=="" {
	if `have_D'==0 local fu = 0
	else local fu = "0 0"
}

/*	
else {
	if "`ess'"!="" {
		di as err "cannot currently calculate ESS if >0 f/u period"
		exit 198
	}
}
*/


// Rename parameters and tokenize time units
local A = `aratio'		
local J = `nstage'
local Jm1 = `J'-1

tokenize `""year" "6 months" "quarter" "month" "week" "day" "unspecified""'
local lperiod ``tunit''


// Split strings up & check for errors
* Strings with J items
local opts alpha power accrate arms
local nopts: word count `opts'
tokenize `opts'

forvalues i = 1/`nopts' {
	local opt ``i''
	local nopt: word count ``opt''
	
	if `nopt'<`J' {
		di as err "must specify `J' values for `opt'()"
		local ++errcount
	}
	
	if `nopt'>`J' {
		di as err "too many items specified for `opt'() - maximum is `J'"
		local ++errcount
	}
	
	forvalues j = 1/`J' {
		local `opt'S`j': word `j' of ``opt''
		cap confirm number ``opt'S`j''
		if _rc {
			di as err "'``opt'S`j''' found where number expected"
			local ++errcount
		}
	}
}


* String with 1 (I=D) or 2 (I!=D) items
local nval = cond(`have_D'==1, 2, 1)
if `nval'==2 local s `s'

local opts theta0 theta1 ctrlp fu ltfu
local nopts: word count `opts'
tokenize `opts'

forvalues i = 1/`nopts' {
	local opt ``i''
	local nopt: word count ``opt''
	
	
	if `nopt'>`nval' {
		di as err "too many items specified for `opt'() - maximum is `nval'"
		local ++errcount
	}
	
	if `nopt'<`nval' {
		di as err "must specify `nval' value`s' for `opt'()"
		local ++errcount
	}
	
	forvalues j = 1/`nopt' {
		local `opt'O`j': word `j' of ``opt''
		cap confirm number ``opt'O`j''
		if c(rc) {
			di as err "'``opt'O`j''' found where number expected"
			local ++errcount
		}
	}


	if `nval'==1 {
		forvalues j = 1/`J' {
			local `opt'S`j' ``opt'O1'
		}
	}
	
	else {
		forvalues j = 1/`Jm1' {
			local `opt'S`j' ``opt'O1'
		}
		local `opt'S`J' ``opt'O2'
	}
}


if `errcount'>0 exit 198


forvalues j = 1/`J' {
	local jm1 = `j'-1

	*z-values for power and alpha in each stage
	local z_wS`j' = invnormal(`powerS`j'')
	local z_aS`j' = invnormal(`alphaS`j'')
	
	if `j'>1 {
		if `alphaS`j''>=`alphaS`jm1'' {
			di as err "Significance levels not decreasing with stages"
			exit 198
		}
	}
	
	if `armsS`j''<2 {
		di as err "at least 2 arms should be specified in stage `j'"
		exit 198
	}
	
	*recruitment rate in control and active arms in each stage
	local accCS`j' = `accrateS`j''/(1+(`armsS`j''-1)*`A')
	local accXS`j' = `A'*`accCS`j''

}


// Probability of outcome under H0 and H1 for I and D outcomes
* key: I = ineffective arm, E = effective arm
forvalues j = 1/`J' {
	
	local pCS`j' = `ctrlpS`j''
	local p0S`j' = `ctrlpS`j''+`theta0S`j''
	local p1S`j' = `ctrlpS`j''+`theta1S`j''
	
	
	if `pCS`j''<0 | `pCS`j''>1 {
		di as err "values of ctrlp() should be between 0 and 1"
		exit 198
	}
	
	if `p0S`j''<0 | `p0S`j''>1 {
		local minth0 = -`pCS`j''
		local maxth0 = 1-`pCS`j''
		di as err "values of theta0() should be between `minth0' and `maxth0'"
		exit 198
	}

	if `p1S`j''<0 | `p1S`j''>1 {
		local minth1 = -`pCS`j''
		local maxth1 = 1-`pCS`j''
		di as err "values of theta1() should be between `minth1' and `maxth1'"
		exit 198
	}	
	
	* 1-p's -> q's (to simplify later code)
	local qCS`j' = 1-`pCS`j''
	local q0S`j' = 1-`p0S`j''
	local q1S`j' = 1-`p1S`j''
}



// More error checking
* limits on PPV's
if `have_D'==1 {

	local ppvcmin = max((`pCS`J''+`pCS1'-1)/`pCS1', (`p0S`J''+`p0S1'-1)/`p0S1', 0)
	local ppvemin = max((`p1S`J''+`p1S1'-1)/`p1S1', 0)

	local ppvcmax = min(`pCS`J''/`pCS1', `p0S`J''/`p0S1', 1)
	local ppvemax = min(`p1S`J''/`p1S1', 1)


	if `ppvc'>`ppvcmax' {
		*local ppvcmax = round(`ppvcmax', 0.001)
		di as err "ppvc() should be less than " %-9.3f `ppvcmax'
		exit 198
	}
	
	if `ppve'>`ppvemax' {
		*local ppvemax = round(`ppvemax', 0.001)
		di as err "ppve() should be less than " %-9.3f `ppvemax'
		exit 198
	}
	
	if `ppvc'<`ppvcmin' {
		*local ppvcmin = round(`ppvcmin', 0.001)
		di as err "ppvc() should be at least " %-9.3f `ppvcmin'
		exit 198
	}
	
	if `ppve'<`ppvemin' {
		*local ppvemin = round(`ppvemin' , 0.001)
		di as err "ppve() should be at least " %-9.3f `ppvemin'
		exit 198
	}	
}


// Check # arms <= # arms in preceding stage
forvalues j = 2/`J' {
	local jm1 = `j'-1
	if `armsS`j''>`armsS`jm1'' {
		di as err "number of active arms cannot increase throughout trial"
		exit 198
	}
}


// Calculate sample size NEEDED for each analysis
local totCA0 = 0
forvalues j = 1/`J' {
	
	*1. Cumulative number NEEDED in control arm 
	local nCS`j' = round((-`z_aS`j'' + `z_wS`j'')^2*(`A'*`pCS`j''*`qCS`j''+`p1S`j''*`q1S`j'') / ///
		(`A'*(`theta1S`j''-`theta0S`j'')^2))	
		
	*2. Cumulative number NEEDED in each remaining experimental arm
	local nXS`j' = round(`A'*`nCS`j'')	
		
	*3. Total number of patients needed in each analysis
	local nS`j' = `nCS`j'' + (`armsS`j''-1)*`nXS`j''				
		
	*4. V(theta) under H0 and H1
	local v_theta0S`j' = (`A'*`pCS`j''*`qCS`j''+`p0S`j''*`q0S`j'')/(`A'*`nCS`j'')
	local v_theta1S`j' = (`A'*`pCS`j''*`qCS`j''+`p1S`j''*`q1S`j'')/(`A'*`nCS`j'')	
}	

forvalues j = 2/`J' {
	local jm1 = `j'-1
	if `nCS`j''<=`nCS`jm1''	{
		di as err "Design infeasible - fewer patients required for stage `j' than stage `jm1'"
		exit 198
	}
}

// Cumulative number recruited at end of each stage in 
// control arm (totCS`i') and duration of each stage
// Account for attrition rate (ltfu)
local Jm1 = `J'-1

if `J'==1 {
	local mCS1 = round(`nCS1'/(1-`ltfuS1'))
	local durS1 = `mCS1'/`accCS1'+`fuS1'+`extrat'
	local totCS1 = `mCS1'
}

else {	
	*1st stage
	local mCS1 = round(`nCS1'/(1-`ltfuS1'))
	local durS1 = `mCS1'/`accCS1'+`fuS1'+`extrat'
	local totCS1 = round(`accCS1'*`durS1')
		
	*stages 2 to nstage-1
	forvalues j = 2/`Jm1' {
		local jm1 = `j'-1
		local mCS`j' = round(`nCS`j''/(1-`ltfuS`j'')) - `totCS`jm1''
		local durS`j' = `mCS`j''/`accCS`j''+`fuS`j''+`extrat'
		local totCS`j' = round(`accCS`j''*`durS`j'')+`totCS`jm1''
	}

	*final stage
	local mCS`J' = round(`nCS`J''/(1-`ltfuS`J'')) - `totCS`Jm1''
	local durS`J' = `mCS`J''/`accCS`J''+`fuS`J''+`extrat'	
	local totCS`J' = round(`nCS`J''/(1-`ltfuS`J''))
}

forvalues j = 2/`J' {
	local jm1 = `j'-1
	if `nCS`j''<=`totCS`jm1''*(1-`ltfuS`jm1'') {
		di as err "Stage `j' redundant - sample size obtained in stage `jm1'"
		exit 198
	}
}

	
// Cumulative number in each experimental arm, in all active arms and overall at end of each stage
local totS0 = 0
local totCS0 = 0
local totXS0 = 0

forvalues j = 1/`J' {
	local jm1 = `j'-1
	local totXS`j' = round(`A'*`totCS`j'')
	local totactS`j' = `totCS`j'' + (`armsS`j''-1)*`totXS`j''		// Total in active arms
	local totS`j' = `totS`jm1'' + (`totCS`j''-`totCS`jm1'') + (`armsS`j''-1)*(`totXS`j''-`totXS`jm1'')		// Total recruited
}


// Timing of stage j from baseline
local tS0 = 0
forvalues j = 1/`J' {
	local jm1 = `j'-1
	local tS`j' = `tS`jm1''+`durS`j''
}

	
// Correlation matrix for treatment effects between stages
forvalues j = 1/`J' {
	local jm1 = `j'-1
	forvalues i = 1/`jm1' {
	
		local r0`i'`j' = sqrt(`nCS`i''/`nCS`j'')
		local r1`i'`j' = sqrt(`nCS`i''/`nCS`j'')
		
		if `have_D'==1 & `j'==`J' {
			local r0`i'`j' = [(`ppvc'*`p0S`i''-`p0S`i''*`p0S`j'') + `A'*(`ppvc'*`pCS`i''-`pCS`i''*`pCS`j'')] / ///
				(`A'*`nCS`j''*sqrt(`v_theta0S`i'')*sqrt(`v_theta0S`j''))

			local r1`i'`j' = [(`ppve'*`p1S`i''-`p1S`i''*`p1S`j'') + `A'*(`ppvc'*`pCS`i''-`pCS`i''*`pCS`j'')] / ///
				(`A'*`nCS`j''*sqrt(`v_theta1S`i'')*sqrt(`v_theta1S`j''))	
		}
	}
}			


* correlation matrices under H0 & H1
tempname R0`J' R1`J'

mat `R0`J'' = I(`J')
mat `R1`J'' = I(`J')

forvalues j = 1/`J' {
	local jm1 = `j'-1
	forvalues i = 1/`jm1' {
		matrix def `R0`J''[`i',`j'] = `r0`i'`j''
		matrix def `R0`J''[`j',`i'] = `r0`i'`j''
		
		matrix def `R1`J''[`i',`j'] = `r1`i'`j''
		matrix def `R1`J''[`j',`i'] = `r1`i'`j''
	}
}


// Overall alpha and power at the end of each stage
local rep 5000

local AS1 = `alphaS1'
local WS1 = `powerS1'

forvalues j = 2/`J' {

	tempname zalpha zpower
	local za `z_aS1'
	local zw `z_wS1'
	forvalues k = 2/`j' {
		local za `za' , `z_aS`k''
		local zw `zw' , `z_wS`k''
	}
	matrix `zalpha' = (`za')
	matrix `zpower' = (`zw')
	
	if `j'<`J' {
		tempname R0`j' R1`j'
		matrix `R0`j'' = `R0`J''[1..`j',1..`j']
		matrix `R1`j'' = `R1`J''[1..`j',1..`j']
	}
	
	mata: mvnprob("`zalpha'", "`R0`j''", `rep')
	local AS`j' = r(p)
	mata: mvnprob("`zpower'", "`R1`j''", `rep')
	local WS`j' = r(p)
	
}


// Familywise error rate (FWER), probs and expected sample size (under H0) calculations
if "`probs'`ess'"!="" | "`nofwer'"=="" {
	local K = `armsS1'-1

	* 1 exp. arm -- calculate probs algebraically
	if `K'==1 {
		local expn0 = `totS1'
		local expn1 = `totS1'
		
		forvalues j = 1/`J' {
			local jm1 = `j'-1
			local p0`j'1 = `AS`j''
			local p0`j'0 = 1-`AS`j''
			
			local p1`j'1 = `WS`j''
			local p1`j'0 = 1-`WS`j''
			
			if `j'>1 {
				local expn0 = `expn0'+`p0`jm1'1'*(`totS`j''-`totS`jm1'')
				local expn1 = `expn1'+`p1`jm1'1'*(`totS`j''-`totS`jm1'')
			}
		}
		
		if "`ess'"!="" {
			return scalar ess0 = `expn0'
			return scalar ess1 = `expn1'
		}
	}
	
	else {
	
		if `J'==1 {
			tempname R0`J'
			mat `R0`J'' = (1)
		}
		
		local muz1
		forvalues j = 1/`J' {
			local muz1`j' = (`theta1S`j''-`theta0S`j'')/sqrt(`pCS`j''*(1-`pCS`j'')/`nCS`j'' + ///
								`p1S`j''*(1-`p1S`j'')/(`A'*`nCS`j''))
			local muz1 `muz1' `muz1`j''
		}
		
		if "`probs'"!="" | "`nofwer'"=="" {
		
			if `have_D'==0 nstagebinfwer, nstage(`J') arms(`armsS1') alpha(`alpha') corr(`R0`J'') aratio(`A') ///
								seed(`seed') reps(`reps') muz1(`muz1')
							
			else {
				nstagebinfwer, nstage(`J') arms(`armsS1') alpha(`alpha') corr(`R0`J'') aratio(`A') ///
								seed(`seed') reps(`reps') muz1(`muz1') ineqd 
				local maxfwer = r(maxfwer)
			}
			
			local fwerate = r(fwer)
			local se_fwerate = r(se_fwer)
								
			if "`nofwer'"=="" {
				return scalar fwer = `fwerate'
				return scalar se_fwer = `se_fwerate'
				if `have_D'==1 return scalar maxfwer = `maxfwer'
			}
			
			* only calculate probs under H0 and HK
			if "`probs'"!="" {	
			
				foreach e in 0 `K' {
								
					forvalues j = 1/`J' {
						local jm1 = `j'-1
						
						forvalues k = 0/`K' {
							local p`e'`j'`k' = r(p`e'`j'`k')
						}
					}
				}
			}
		}
		
		
		if "`ess'"!="" {		// accounts for f/u
			forvalues j = 1/`J' {
				local delS`j' = `fuS`j''+`extrat'
				local delay `delay' `delS`j''
				
				local nC `nC' `nCS`j''
				local ltfup `ltfup' `ltfuS`j''
			}		
			
			nstagebiness, nstage(`J') arms(`armsS1') alpha(`alpha') aratio(`A') ctrln(`nC') ///
				fu(`delay') ltfu(`ltfup') accrate(`accrate') muz1(`muz1')
			local expn0 = r(ess0)
			local expn`K' = r(ess1)
			return scalar ess0 = `expn0'
			return scalar ess`K' = `expn`K''
		}
	}			
}




// Save results in return
forvalues j = 1/`J' {
	
	*timing & duration of each stage
	return scalar tS`j' = `tS`j''
	*return scalar durS`j' = `durS`j''

	*accrual in each stage to E and C arms
	*return scalar accCS`j' = `accCS`j''
	*return scalar accXS`j' = `accXS`j''
	
	*cumulative total required for analyses in each arm
	return scalar nCS`j' = `nCS`j''
	return scalar nXS`j' = `nXS`j''
	return scalar nS`j' = `nS`j''
	
	*cumulative total recruited to all active arms
	return scalar totactS`j' = `totactS`j''

	*cumulative total recruited
	return scalar totCS`j' = `totCS`j''
	return scalar totXS`j' = `totXS`j''
	return scalar totS`j' = `totS`j''
	
	*stage specific alphas and powers
	return scalar AS`j' = `AS`j''
	return scalar WS`j' = `WS`j''
	
	* correlation matrices
	if `J'>1 {
		if `have_D'==0  return matrix R = `R0`J'', copy
		else {
			return matrix R0 = `R0`J'', copy
			return matrix R1 = `R1`J'', copy
		}
	}
}

/*
local totalpha = `AS`J''
return scalar totalpha = `totalpha'
local totpower = `WS`J''
return scalar totpower = `totpower'
*/
	

// Display results
local title1 "n-stage trial design                 version `ver', `date'"	
local title2 "on Bratton et al. (2013) BMC Med Res Meth 13:139"

local hline = length("`title1'")


local ww 10
local sfl %-`ww's
local sfc %~`ww's
local sfr %`ww's

local wx 14

local nitem 7
*local width = (`nitem'-1)*`ww'+`wx'
local width = `nitem'*`ww'
local ww3 = `ww' * 3
local ww4 = `ww' * 4

if `have_D'==1 local s S

di as text _n "`title1'" _n "{hline `hline'}"
di as text "Sample size for a " as res "`armsS1'" as text "-arm " as res "`nstage'" as txt "-stage trial with binary outcome based"
di as text "`title2'" _n "{hline `hline'}"

di
if `have_D'==0 {
	di as text "Control arm event rate = " %3.2f `ctrlpS1'
	if `fuS1'>0 di as text "Delay in observing outcome = `fuS1' `lperiod's"
	if `ltfuS1'>0 di as text "Attrition rate for outcome = " %3.2f `ltfuS1'
}
if `have_D'==1 {	
	di as text "Control arm I (D) event rate = " %3.2f `ctrlpS1' " (" %3.2f `ctrlpS`J'' ")"
	if `fuS1'>0 | `fuS`J''>0 di as text "Delay in observing I (D) outcome = `fuS1' (`fuS`J'') `lperiod's"
	if `ltfuS1'>0 | `ltfuS`J''>0 di as text "Attrition rate for I (D) outcome = " %3.2f `ltfuS1' " (" %3.2f `ltfuS`J'' ")"
}
di
di as text "Operating characteristics"
di as text "{hline `width'}"
di as text _skip(`ww') `sfr' "Alpha(1S)" `sfr' "Power" `sfr' "theta|H0" ///
 `sfr' "theta|H1"  `sfr' "Length*" `sfr' "Time*" 
di as text "{hline `width'}"
 
forvalues j = 1/`J' {
	di as text %-`ww's "Stage `j'" %`ww'.4f `alphaS`j'' %`ww'.3f `powerS`j'' ///
	%`ww'.3f as txt `theta0S`j'' %`ww'.3f as txt `theta1S`j'' ///
	%`ww'.3f as res `durS`j'' %`ww'.3f as res `tS`j'' 
}


if `J'==1 & "`nofwer'"=="" {
	di as text %-`ww's "FWER (SE)" %`ww'.4f as res `fwerate' ///
		as text "   (" as res %5.4f `se_fwerate' as text ")"
		
	di as text "{hline `width'}"
}
	
if `J'>1 {
	if `armsS1'>2 {
		
		// PWER and FWER 
		if `have_D' {
			di as text %-`ww's "Pairwise" %`ww'.4f as res `alphaS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
			
			if "`nofwer'"=="" di as text %-`ww's "FWER" as res %`ww'.4f `maxfwer'  
		
		/*
			di as text %-`wx's "Pairwise**" %`ww'.4f as res `AS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
			
			if "`nofwer'"=="" di as text %-`wx's "Familywise(SE)**" as res %8.4f `fwerate'  ///
					as text "   (" as res %5.4f `se_fwerate' as text ")"
		*/
		}
		
		else {
			di as text %-`ww's "Pairwise" %`ww'.4f as res `AS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
				
			if "`nofwer'"=="" di as text %-`ww's "FWER (SE)" as res %`ww'.4f `fwerate'  ///
					as text "   (" as res %5.4f `se_fwerate' as text ")"
		}	
			
		di as text "{hline `width'}"
		/*
		// Maximum PWER and FWER if I!=D		
		if `have_D' {
			di as text "Maximum Pairwise Alpha" %`ww'.4f as res `alphaS`J'' _cont 
			if "`nofwer'"=="" di as text _col(41) "Maximum Familywise Alpha" %`ww'.4f as res `maxfwer' _cont
			
			di _n as txt "{hline `width'}"
		}
		*/
	}

	else {
		if `have_D' {
			di as text %-`ww's "Pairwise" %`ww'.4f as res `alphaS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
		
		/*
			di as text %-`wx's "Pairwise**" %`ww'.4f as res `AS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
			di as text %-`wx's "Maximum" %`ww'.4f as res `alphaS`J''
		*/
		}
		
		else {
			di as text %-`ww's "Pairwise" %`ww'.4f as res `AS`J'' %`ww'.3f as res `WS`J'' ///
				_skip(`ww3') %`ww'.3f as res `tS`J''
		}
		
		di as txt "{hline `width'}"			
	}
}
		
	
*di as text "{hline `width'}"
*di as text " KEY: theta = absolute difference in event rates"
di as text " *  Length (duration of each stage) is expressed in " as res "`lperiod'" as text " periods"
*if `have_D' di as text " ** Calculated under global null hypothesis for I and D outcomes"


local ww 9
local sfl %-`ww's
local sfc %~`ww's
local sfr %`ww's

local oddstages = 2* int(`J'/2) != `J'
local evenstages = `J' - `oddstages'
local text 21
local col = `text'+`ww'-length("Overall")+1
local stext %-`text's
local nres 3
local width = `text' + 2*`nres' * `ww'
local dup = int((`nres'*`ww'-length("Stage 1"))/2-1)

di
di as text "Cumulative sample sizes per arm per stage"

forvalues m = 1(2)`evenstages' {
	local mp1 = `m'+1
	di as text _col(`col') _dup(`dup') "{c -}" "Stage `m'" _dup(`dup') "{c -}"	///
		"  " _dup(`dup') "{c -}" "Stage `mp1'" _dup(`dup') "{c -}"
	di as text _skip(`text') `sfr' "Overall" `sfr' "Control" `sfr' "Exper." ///
		`sfr' "Overall" `sfr' "Control" `sfr' "Exper." _n "{hline `width'}"
	di as text `stext' "Number of active arms"  %`ww'.0f `armsS`m'' %`ww'.0f 1 %`ww'.0f `armsS`m''-1 ///
		%`ww'.0f `armsS`mp1'' %`ww'.0f 1 %`ww'.0f `armsS`mp1''-1
	di as text `stext' "Accrual rate*" %`ww'.1f `accrateS`m'' %`ww'.1f `accCS`m'' %`ww'.1f `accXS`m''*(`armsS`m''-1) ///
		%`ww'.1f `accrateS`mp1'' %`ww'.1f `accCS`mp1'' %`ww'.1f `accXS`mp1''*(`armsS`mp1''-1)
	if `armsS1'>2 di as res "Active arms"
	di as text `stext' "Patients for analysis" as res %`ww'.0f `nS`m'' %`ww'.0f `nCS`m'' %`ww'.0f `nXS`m'' ///
		%`ww'.0f `nS`mp1'' %`ww'.0f `nCS`mp1'' %`ww'.0f `nXS`mp1''
	di as text `stext' "Patients recruited**" as res %`ww'.0f `totactS`m'' %`ww'.0f `totCS`m'' %`ww'.0f `totXS`m'' ///
		%`ww'.0f `totactS`mp1'' %`ww'.0f `totCS`mp1'' %`ww'.0f `totXS`mp1''
	if `armsS1'>2 {
		di as res "All arms"
		di as text `stext' "Patients recruited**" as res %`ww'.0f `totS`m'' %`ww's "" %`ww's "" ///
			%`ww'.0f `totS`mp1'' %`ww's "" %`ww's ""
	}
	di as text "{hline `width'}"
}

if `oddstages' {
	local width2 = `text' + `nres' * `ww'
	local m = `nstage' 
	di as text _col(`col') _dup(`dup') "{c -}" "Stage `m'" _dup(`dup') "{c -}"
	di as text _skip(`text') `sfr' "Overall" `sfr' "Control" `sfr' "Exper." _n "{hline `width2'}"
	di as text `stext' "Number of active arms" `sfr' %`ww'.0f `armsS`m'' %`ww'.0f 1 %`ww'.0f `armsS`m''-1 
	di as text `stext' "Accrual rate*" %`ww'.1f `accrateS`m'' %`ww'.1f `accCS`m'' ///
		%`ww'.1f `accXS`m''*(`armsS`m''-1)
	if `armsS1'>2 di as res "Active arms"
	di as text `stext' "Patients for analysis" as res %`ww'.0f `nS`m'' %`ww'.0f `nCS`m'' %`ww'.0f `nXS`m''
	di as text `stext' "Patients recruited**" as res %`ww'.0f `totactS`m'' %`ww'.0f `totCS`m'' %`ww'.0f `totXS`m''
	if `armsS1'>2 {
		di as res "All arms"
		di as text `stext' "Patients recruited**" as res %`ww'.0f `totS`m'' %`ww's "" %`ww's ""
	}
	di as text "{hline `width2'}"
}

di as text " *  Accrual rates are specified in number of patients per " as res "`lperiod'"
if `J'==1 di as text " ** Accounts for loss-to-follow-up rate"
else di as text " ** Accounts for loss-to-follow-up rate and includes those recruited during follow-up periods"
di

if "`ess'"!="" {
	foreach e in 0 `K' {
		local Kme = `K'-`e'
		di as text "Expected sample size | `e' effective arms = " as res %-9.0f `expn`e''
	}
}
	


if "`probs'"!="" {
	di
	local width3 = `ww'*(`armsS1'+1)
	
	foreach e in 0 `K' {
		local Kme = `K'-`e'
	
		di as text "Prob. of k experimental arms passing each stage: `e' effective arms"
		di as text _dup(`width3') "{c -}"
		
		di as text `sfl' "k(# arms)" _cont
		forvalues k = 0/`K' {
			di as text %`ww'.0f `k' _cont
		}
		di
		di as text _dup(`width3') "{c -}"
		
		forvalues j = 1/`J' {
			di as text `sfl' "Stage `j'" _cont
			forvalues k = 0/`K' {
				di as res %`ww'.3f `p`e'`j'`k'' _cont
			}
			di
		}
		di as text _dup(`width3') "{c -}"

	}
}


end



****************************************************************************************************


* nstagebinfwer subroutine v1.0
cap program drop nstagebinfwer

program def nstagebinfwer, rclass
version 10


/*
	Calculate familywise error rate (FWER) under global null
	of a multi-arm multi-stage trial

*/

syntax, nstage(int) arms(int) alpha(string) corr(name) aratio(real) ///
	muz1(string) [reps(int 250000) seed(int -1) ineqd]
	
	
if `seed'>0 set seed `seed'
	
local J = `nstage'		// # stages
local Jm1 = `J'-1
local K = `arms'-1	 	// # E arms
local A = `aratio'		// Allocation ratio
mat def S = `corr'		// correlation between stages under H0


// Stagewise sig. levels 
forvalues j = 1/`J' {
	local alpha`j' : word `j' of `alpha'
}


// Set sign for tests
forvalues j = 1/`J' {
	
	local muz1`j' : word `j' of `muz1'
	if `muz1`j''<0 local sign`j' = 1
	else local sign`j' = -1
}	


// Correlation matrix between arms ( = A/A+1)
matrix A = I(`K')

forvalues j = 1/`K' {
	forvalues k = 1/`K' {
		if `j'!=`k' mat def A[`j',`k'] = `A'/(`A'+1)
	}
}


// Generate correlated standard normal RVs

preserve
drop _all
forvalues k = 0/`K' {
	local X`k' x1`k'
	local sd 1

	forvalues j = 2/`J' {
		local X`k' `X`k'' x`j'`k'
		local sd `sd' \ 1
	}
		
	qui drawnorm `X`k'', corr(S) sd(`sd') n(`reps') double
}


forvalues j = 1/`J' {	
	forvalues k = 1/`K' {
		gen double z`j'`k' = sqrt(`A'/(`A'+1))*x`j'0+sqrt(1/(`A'+1))*x`j'`k'
	}
}



// Arm k pass stage j when e arms are effective K-e are ineffective
// (first e of K arms effective, arms e+1,...,K ineffective)
forvalues e = 0/`K' {
	
	forvalues k = 1/`K' {
		scalar pass`e'0`k'=1
		
		forvalues j = 1/`J' {
			local jm1 = `j'-1
			if `k'<=`e' gen byte pass`e'`j'`k' = (`sign`j''*(z`j'`k'+`muz1`j'')<invnormal(`alpha`j'') & pass`e'`jm1'`k'==1)
			if `k'>`e' gen byte pass`e'`j'`k' = (`sign`j''*z`j'`k'<invnormal(`alpha`j'') & pass`e'`jm1'`k'==1)
		}
	}

	// Number of arms passing stage j under global H0 and under H1
	forvalues j = 1/`J' {
		egen byte npass`e'`j' = rowtotal(pass`e'`j'*)
	}


	// Probability of k arms passing stage j
	forvalues j = 1/`J' {	
		forvalues k = 0/`K' {
		
			qui count if npass`e'`j'==`k'
			local p`e'`j'`k' = r(N)/`reps'
			return scalar p`e'`j'`k' = `p`e'`j'`k''
		}
	}
}


// Pairwise type I error rate
local sum = 0
forvalues k = 1/`K' {
	qui count if pass0`J'`k'==1
	local sum = `sum'+r(N)
}

local pwer = `sum'/(`K'*`reps')
return scalar pwer = `pwer'


// FWER
qui count if npass0`J'>0
local fwer = r(N)/`reps'
local se_fwer = sqrt(`fwer'*(1-`fwer')/`reps')
*local ll_fwer = `fwer'-invnormal(0.975)*`se_fwer'
*local ul_fwer = `fwer'+invnormal(0.975)*`se_fwer'

return scalar fwer = `fwer'
return scalar se_fwer = `se_fwer'
*return scalar ll_fwer = `ll_fwer'
*return scalar ul_fwer = `ul_fwer'


restore

// Maximum FWER if I not equal D
if "`ineqd'"!="" {

	local z = invnormal(1-`alpha`J'')
	
	// Vector of z values
	local z1ma `z'
	forvalues k = 2/`K' {
		local z1ma `z1ma', `z'
	}

	tempname Z
	matrix `Z' = (`z1ma')

	tempname A
	mat `A' = A
	local rep = 5000
	mata: mvnprob("`Z'", "`A'", `rep')
	local maxfwer = 1-r(p)
	return scalar maxfwer = `maxfwer'
}


end



***********************************************************************************************




* nstagebiness subroutine v1.0
cap program drop nstagebiness

program def nstagebiness, rclass
version 10


/*
	Calculate expected sample size (ESS) of 
	a multi-arm multi-stage trial with binary outcome
	
*/

syntax, nstage(int) arms(int) alpha(string) aratio(real) ctrln(string) ///
	fu(string) ltfu(string) accrate(string) muz1(string)

local J = `nstage'		// # stages
local K = `arms'-1		// # E arms
local A = `aratio'

local Jm1 = `J'-1
local Km1 = `K'-1


// Split strings
forvalues j = 1/`J' {
	local alpha`j': word `j' of `alpha'
	local nC`j': word `j' of `ctrln'
	local r`j': word `j' of `accrate'
	local fu`j': word `j' of `fu'			// NB: need to specify fu and ltfu for each stage
	local ltfu`j': word `j' of `ltfu'
	local muz1`j': word `j' of `muz1'
	if `muz1`j''<0 local sign`j' = 1
	else local sign`j' = -1
}


// Control accrual rates per stage & per # active E arms
local rC1`K' = `r1'/(`A'*`K'+1)

forvalues j = 2/`Jm1' {
	forvalues k = 1/`K' {
		local rC`j'`k' = `r`j''/(1+`k'*`A')
	}
}


// Total control sample size at end of each stage per # active arms
forvalues k = 1/`K' {

	local NC1`k' = round(`nC1'/(1-`ltfu1')+`rC1`K''*`fu1')
	*local N1`k' = round((`k'*`A'+1)*`NC1`k'')

	forvalues j = 2/`Jm1' {
		local NC`j'`k' = round(`nC`j''/(1-`ltfu`j'')+`rC`j'`k''*`fu`j'')
		*local N`j'`k' = round((`k'*`A'+1)*`NC`j'`k'')
	}

	local NC`J'`k' = round(`nC`J''/(1-`ltfu`J''))
	*local N`J'`k' = round((`k'*`A'+1)*`NC`J'`k'')	<- why *ed?
}


// Return matrix of sample sizes
* required control sample sizes, n
local nC `nC1'
qui forvalues j = 2/`J' {
	local nC `nC' \ `nC`j''
}
matrix nC = (`nC')
return matrix nC = nC		// <- why return?

* total sample sizes, N
local Km1 = `K'-1
forvalues j = 1/`J' {
	local NC`j' `NC`j'1'
	
	forvalues k = 2/`Km1' {
		local NC`j' `NC`j'' , `NC`j'`k''
	}
	
	if `j'<`J' local NC`j' `NC`j'' , `NC`j'`K'' \
	else local NC`j' `NC`j'' , `NC`j'`K''
	
	local NC `NC' `NC`j''
}

matrix NC = (`NC')
return matrix NC = NC		// <- why return?


// Correlation matrix between stages for first J-1 stages
matrix S = I(`Jm1')

qui forvalues j = 1/`Jm1' {
	local jm1 = `j'-1
	mat def S[`j',`j'] = 1
	
	forvalues i = 1/`jm1' {
		mat def S[`i',`j'] = sqrt(`nC`i''/`nC`j'')
		mat def S[`j',`i'] = S[`i',`j']
	}
}


// Correlation matrix between arms - not needed
matrix A = I(`K')

qui forvalues j = 1/`K' {
	mat def A[`j',`j'] = 1
	
	forvalues k = 1/`K' {
		if `j'!=`k' mat def A[`j',`k'] = `A'/(`A'+1)
	}
}


// Generate correlated standard normal RVs - DO NOT NEED TO SIMULATE FINAL STAGE
preserve
drop _all
forvalues k = 0/`K' {		

	local X`k' x1`k'
	local sd 1

	forvalues j = 2/`Jm1' {

		local X`k' `X`k'' x`j'`k'
		local sd `sd' \ 1
	}
		
	cap drawnorm `X`k'', corr(S) sd(`sd') n(250000) double
}

forvalues j = 1/`Jm1' {	
	forvalues k = 1/`K' {
		gen double z`j'`k' = sqrt(`A'/(`A'+1))*x`j'0 + sqrt(1/(`A'+1))*x`j'`k'
	}
}


// Pass - under global H0 and H1
qui foreach h in 0 1 {
	forvalues k = 1/`K' {
		scalar pass`h'0`k' = 1

		forvalues j = 1/`Jm1' {
			local jm1 = `j'-1
			
			if `h'==0 gen byte pass`h'`j'`k' = (`sign`j''*z`j'`k'<invnormal(`alpha`j'') & pass`h'`jm1'`k'==1)
			else gen byte pass`h'`j'`k' = (`sign`j''*(z`j'`k'+`muz1`j'')<invnormal(`alpha`j'') & pass`h'`jm1'`k'==1)
		}
	}
	
	// # arms passing each stage
	forvalues j = 1/`Jm1' {
		egen byte npass`h'`j' = rowtotal(pass`h'`j'*)
	}	


	// Calculate ESS under H_h
	local ess`h' = (`A'*`K'+1)*`NC1`K''		// stage 1

	if `J'>1 {
		forvalues k = 1/`K' {				// stage 2
			count if npass`h'1 == `k' 
			local ess`h' = `ess`h''+(`A'*`k'+1)*(`NC2`k''-`NC1`k'')*r(N)/_N
		}
	}

	forvalues j = 3/`J' {				// stages 3...J
		local jm1 = `j'-1
		local jm2 = `j'-2
		
		forvalues k = 1/`K' {				
			forvalues l = 1/`k' {
			
				count if npass`h'`jm1'==`l' & npass`h'`jm2'==`k'
				local ess`h' = `ess`h''+(`A'*`l'+1)*(`NC`j'`l''-`NC`jm1'`k'')*r(N)/_N
			}
		}
	}
	return scalar ess`h' = `ess`h''

}


restore
end



***********************************************************************************************



mata:
void mvnprob(string scalar xx, string scalar vv, real scalar reps)
{
/*
	Assumes Hammersley sequences are to be generated, without antithetics.
*/
	real vector opt
	x = st_matrix(xx)	// row or col vector of args at which probability is required
	V = st_matrix(vv)	// variance-covariance matrix
	opt = (2, reps, 1, 0)	// 2 for Hammersley
	p = ghk( x, V, opt, rank=.)
	st_numscalar("r(p)", p)
}
end

