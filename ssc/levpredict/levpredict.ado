*! levpredict  1.0.0  CFBaum
*! following Cameron/Trivedi, MUS p.103

// Duan, N, 1983, Smearing estimate: A nonparametric retransformation method. JASA 78:605-610.

program levpredict, rclass
	version 9.2
	syntax newvarname [,Duan PRint]
	
// retrieve command and depvar from last model
	local cmd `e(cmd)'
	local depvar `e(depvar)'

	if "`cmd'" == "mean" {
		di as err _n "levpredict cannot be used after mean"
		error 198
	}
// ensure exp(depvar) is strictly positive
	tempvar checkdv
	qui g double `checkdv' = (exp(`depvar') != .) if e(sample) 
	su `checkdv', meanonly
	if r(min) == 0 {
		di as err _n "Error: exp(`depvar') is not strictly positive in the estimation sample."
		di as err "levpredict must be run after estimating a model with a log dependent variable."
		error 198
	}
	tempvar logpred
	qui predict double `logpred' if e(sample), xb 
	
	if "`duan'" == "" {
// standard approach, assuming normal errors
		qui g double `varlist' = exp(`logpred') * exp(0.5 * e(rmse)^2)
	}
	else {
// Duan (1983) approach, assuming iid but not normality	
		tempvar logres res
		qui predict double `logres' if e(sample), res
		qui g double `res' = exp(`logres')
		su `res', meanonly
		qui g double `varlist' = exp(`logpred') * r(mean)
	}
	if "`print'" != "" {
		di _n "Prediction of exp(`depvar') from command: `cmd' created as variable: `varlist'"
// compute prediction ignoring residual term
		tempvar blpred bpred
		tempname bpredhat 
		qui predict double `blpred' if e(sample), xb
		qui g double `bpred' = exp(`blpred')
		su `bpred', meanonly
		scalar `bpredhat' = r(mean)
		su `varlist', meanonly
		if "`duan'" == "duan" {
			di "using method of Duan, assuming i.i.d. errors"
		}
		di _n "Mean level prediction ignoring E[exp(U_i)] = " `bpredhat'
		di _n "Bias in mean level prediction: " `bpredhat' - `r(mean)'
	}
	end
	
