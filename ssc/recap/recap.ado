!* Estimation of the size of a population with 3 Source Capture-Recapture 
!* including Goodness of fit-based confidence intervals
!* written by Matthias an der Heiden, RKI Berlin,  AnderHeidenM@rki.de

program define recap
version 9


capture drop Model
qui gen Model = ""
capture drop N_hat
qui gen N_hat =.
capture drop N_lb 
qui gen N_lb =.
capture drop N_ub
qui gen N_ub =.
capture drop x_hat
qui gen x_hat =.
capture drop x_lb
qui gen x_lb =.
capture drop x_ub
qui gen x_ub =.
capture drop DoF
qui gen DoF =.
capture drop Loglikelihood
qui gen Loglikelihood=.
capture drop Gp2
qui gen Gp2 =.
capture drop p_value
qui gen p_value=.
capture drop AIC
qui gen AIC =.
capture drop BIC
qui gen BIC =.

tempvar Gpower2
qui gen `Gpower2' =.

local sig = invchi2(1,.95)

syntax varlist(min=4 max=4) [if] [in]
tokenize `varlist'
local fre `1'
local a `2'
local b `3'
local c `4'
local vars `0'


gsort -`a' -`b' -`c'

qui replace `fre' = .1 if `fre'<.1

tempvar help
qui gen `help' = sum(`fre')
local N_obs = floor(`help'[7])


tempvar AB
gen `AB' = `a' * `b'
tempvar AC
gen `AC' = `a' * `c'
tempvar BC
gen `BC' = `b' * `c'

cons 1 `AB' = 0
cons 2 `AC' = 0
cons 3 `BC' = 0

local num=0
local i=1
while (`i' >= 0) {
	local j=2
	while (`j' >= 0) {
		local k=3
		while (`k' >= 0) {
		if (`i'==1) {
			local ab
		}
		else {
			local ab = 1
		}
		if (`j'==2) {
			local ac
		}
		else {
			local ac = 2
		}
		if (`k'==3) {
			local bc
		}
		else {
			local bc = 3
		}


//		Berechnung der erwarteten Werte
//		-------------------------------

local ++num
qui replace Model = "Model`i'`j'`k'" in `num'

qui poisson `vars' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
qui replace Loglikelihood = e(ll) in `num'
qui replace DoF = e(df_m)  in `num'
local deg = 6 - e(df_m)
local Observations = e(N) 

tempvar pred nfreq hlp1 hlp2

qui predict double `pred'
qui replace x_hat = floor(`pred'[8]) in `num'
qui replace N_hat = `N_obs' + x_hat  in `num'

qui gen double `nfreq' = `fre'
qui replace `nfreq' = `pred' in 8

qui gen double `hlp1' = 2*`nfreq' * log(`nfreq' / `pred') if `nfreq'>0
qui gen double `hlp2' = sum(`hlp1') 
qui replace `Gpower2' = `hlp2'[8] in `num'
drop `hlp1' `hlp2'
qui replace p_value = round(1 - chi2(`deg',`Gpower2'),.01) in `num'
qui replace p_value = 1 if p_value==. in `num'



//		Bestimmung der Konfidenz-Intervalle 


//		1. Bestimmung der oberen Grenze
//		-------------------------------

tempvar tfreq
qui gen double `tfreq' = `nfreq'

if (`tfreq'[8] < 1) {
	qui replace `tfreq' = 1  in 8
}

local Goodness = 0 
local v=0
local z=0

while (abs(`Goodness' - `sig') > .01){

	while (`Goodness' < `sig'){
		qui replace `tfreq' = `tfreq'*(1+10^(-`z')) in 8
		qui poisson `tfreq' `a' `b' `c' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
		tempvar pred hlp1 hlp2 
		qui predict double `pred'
		qui gen double `hlp1' = 2*`tfreq' * log(`tfreq' / `pred') if `tfreq'>0
		qui gen double `hlp2' = sum(`hlp1') 
		local Goodness = `hlp2'[8] - `Gpower2'[`num']
		drop `pred' `hlp1' `hlp2'
		local ++v
	}
//	di as result `v' as text " Iterationen und x= " as result `tfreq'[8]

	while (`Goodness' > `sig'){
		qui replace `tfreq' = `tfreq'*(1-10^(-`z'-.8)) in 8
		qui poisson `tfreq' `a' `b' `c' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
		tempvar pred hlp1 hlp2
		qui predict double `pred'
		qui gen double `hlp1' = 2*`tfreq' * log(`tfreq' / `pred') if `tfreq'>0
		qui gen double `hlp2' = sum(`hlp1') 
		local Goodness = `hlp2'[8]- `Gpower2'[`num']
		drop `pred' `hlp1' `hlp2'
		local ++v
	}
//	di as result `v' as text " Iterationen und x= " as result `tfreq'[8]

	local ++z
}

qui replace x_ub = ceil(`tfreq'[8]) in `num'
drop `tfreq'

//	di .
//	di as text "x_ub `i'`j'`k' = " as result x_ub[`num']

qui replace N_ub = `N_obs' + x_ub  in `num'


//		2. Bestimmung der unteren Grenze
//		--------------------------------

tempvar tfreq
qui gen double `tfreq' = `nfreq'
qui replace `tfreq' = 0 in 8
qui poisson `tfreq' `a' `b' `c' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
tempvar pred hlp1 hlp2
qui predict double `pred'
qui gen double `hlp1' = 2*`tfreq' * log(`tfreq' / `pred') if `tfreq'>0
qui gen double `hlp2' = sum(`hlp1') 
local Goodness = `hlp2'[8] - `Gpower2'[`num']

if (`Goodness' > `sig' & `nfreq'[8] > 1) {
	qui replace `tfreq' = `nfreq'
	local Goodness = 0
	local v=0
	local z=0
	while (abs(`Goodness' - `sig') > .01){
		while (`Goodness' < `sig'){
			qui replace `tfreq' = `tfreq'*(1-10^(-max(`z',log(2)/log(100)))) in 8
			qui poisson `tfreq' `a' `b' `c' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
			tempvar pred hlp1 hlp2
			qui predict double `pred'
			qui gen double `hlp1' = 2*`tfreq' * log(`tfreq' / `pred') if `tfreq'>0
			qui gen double `hlp2' = sum(`hlp1') 
			local Goodness = `hlp2'[8] - `Gpower2'[`num']
//	di as result `v' as text " Iterationen und x= " as result `tfreq'[8] as text " und Goodness = " ///
//	as res `Goodness' as text " wobei " as result `tpred'[8]
			drop `pred' `hlp1' `hlp2'
			local ++v
		}
		while (`Goodness' > `sig'){
			qui replace `tfreq' = `tfreq'*(1+10^(-`z'-.8)) in 8
			qui poisson `tfreq' `a' `b' `c' `AB' `AC' `BC'  `if' `in', const(`ab' `ac' `bc')
			tempvar pred hlp1 hlp2
			qui predict double `pred'
			qui gen double `hlp1' = 2*`tfreq' * log(`tfreq' / `pred') if `tfreq'>0
			qui gen double `hlp2' = sum(`hlp1') 
			local Goodness = `hlp2'[8]- `Gpower2'[`num']
			drop `pred' `hlp1' `hlp2'
			local ++v
		}

//	di as result `v' as text " Iterationen und x= " as result `tfreq'[8] 

		local ++z
	}
}

qui replace x_lb = floor(`tfreq'[8]) in `num'

//	di as text "x_lb `i'`j'`k' = " as result x_lb[`num']

qui replace N_lb = `N_obs' + x_lb  in `num'


di as text "." _c

			local k = `k'-3
		}
		local j = `j'-2
	}
	local i = `i'-1
}


//		Ergebnisse

//	qui replace sAIC= 2* (Loglikelihood+DoF)
//	qui replace sBIC= 2* Loglikelihood+DoF * log(`Observations')
//	qui replace BIC= round(sBIC[1]-sBIC,.01)
//	qui replace AIC= round(sAIC[1]-sAIC,.01)

qui replace AIC= -round( 2*(-Loglikelihood[1]+DoF[1]) - 2* (-Loglikelihood+DoF),.01)
qui replace BIC= -round(-2* Loglikelihood[1]+ DoF[1] * log(`Observations')  ///
                          + 2* Loglikelihood - DoF * log(`Observations'),.01)

qui replace Gp2= round(`Gpower2',.01)
qui replace p_value=1 in 1

gsort DoF -Model 
l Model DoF Gp2 p_value AIC BIC x_hat N_hat N_lb N_ub  in 1/8, sep(0) noobs

gsort -`a' -`b' -`c'


end
