/* This programs uses Monte Carlo Simulation to compute the Multi-nomial
Clustering Statistic proposed by Rysman and Greenstein (Economic Letters 2003) 
P-value for Two sided test BUG FIX by CESARE RIGHI 02-01-2017 */

/* 1) Copy the file to your ado directory
2) Make sure the filename extension is .ado not .txt!!
3) syntax is "mtad [varlist], m(varname) n(iterations) wide
   "mtad y, m(market) [if choice data is a single categorical variable]
   "mtad y1 y2 y3..., m(market) wide [if choice data is a series of dummy vars]
*/

program define mtad, rclass
version 9

syntax [varlist] [if], Mkt(varname) [PRobs(numlist >0 <1) NIter(integer 50) wide]

quietly {	

	preserve
	** Step 0: SET UP THE DATA
	capture keep `if'

	keep `varlist' `mkt'

	if "`wide'" == "wide" {
		tab `mkt'
		if r(N)>r(r) {
			noi disp "Wide data must have 1 obs per market"
			exit
		}

	 	local numVals = wordcount("`varlist'")
		if (`numVals' < 2) {
			noi disp "Must specify at least two choices"
			exit
		}

		local i = 1
		foreach X in `varlist' {
			rename `X' choice`i'
			local i = `i' + 1
		}
	}

	else {
		if (wordcount("`varlist'") >1) {
			noi disp "Choice data must be a single categorical variable"
			exit
		}
		rename `varlist' tmp
		tab tmp, gen(choice)	
		local numVals = r(r)
		collapse (sum) choice*, by(`mkt')
	}
	
	** Step 1: BASELINE PROBABILITIES
	* User provided 
	if "`probs'" != "" {
		if "`wide'" != "wide" {
			noi disp "List of probabilities allowed only for wide format data"
			exit
		}
	
		if (wordcount("`probs'") != `numVals') {
			noi disp "Must specify a probability for each choice:" `numVals'
			exit
		}
	
		scalar checksum = 0
		local i=1
		foreach num of numlist `probs' {
			local lnPchoice`i' = log(`num')
			scalar checksum = checksum + `num'
			local i = `i' + 1
		}

		if checksum != 1 {
			noi disp "Probablities must sum to 1"
			exit   
		}
		
		egen ttl = rowtotal(choice*)
	}
	
	* Global Means 
	else {
		egen ttl = rowtotal(choice*)
		sum ttl
		local denom = r(sum)
	
		foreach V of varlist choice* {
			sum `V'
			local lnP`V' = log(r(sum)/`denom')
		}
	}
	
	** Step 2 : RANDOM CHOICE LIKELIHOOD
	gen logLm = lnfact(ttl)
	foreach V of varlist choice* {
		replace logLm = logLm - lnfact(`V') + `V'*`lnP`V''
	}

	** Step 3 : MONTE CARLO SIMULATION
	sum ttl
	local rMax = r(max)

	local i = 1
	local tmp = 0
	g cut0 = 0
	foreach V of varlist choice* {
		g cut`i' = `tmp' + exp(`lnP`V'')
		local tmp = `tmp' + exp(`lnP`V'')
		local i = `i' + 1
	}

	local i = 0
	while `i' < `niter' {
		foreach V of varlist choice* {
			g tmp`V' = 0
		}

		local j = 1
		while `j' <= `rMax' {
			g rnds = uniform()

			local m = 0
			local n = 1
			foreach V of varlist choice* {
				replace tmp`V' = tmp`V' + 1 if ((cut`m' < rnds) & (cut`n' >= rnds) & (ttl >=`j'))	
				local m = `m'+1
				local n = `n'+1
			}		
			drop rnds 
			
			local j=`j'+1
		}

		gen tmplogLm = lnfact(ttl)
		foreach V of varlist choice* {
			replace tmplogLm = tmplogLm - lnfact(tmp`V') + tmp`V'*`lnP`V''
		}
		
		sum tmplogLm
		g iter`i' = r(mean) if (_n==1)
		drop tmp*
		
		if (mod(`i',50) == 0 & `i'>0) {
			noi display "Iteration `i'..."
		}

		local i = `i' + 1
	}

	** Step 4 : Output
	sum logLm
	return scalar logl = r(mean)
	return scalar N = r(N)

	egen tmp1 = rmean(iter*)
	sum tmp1
	return scalar elogl = r(mean)

	egen tmp2 = rsd(iter*)
	sum tmp2
    return scalar sd = r(mean)

	local z = (return(logl)-return(elogl))/return(sd)
	local p = 2*(1-normal(abs(`z')))

	noi display " "	
	noi display as result "Observed Likelihood:" %8.3f return(logl) 
	noi display as result "Expected Likelihood:" %8.3f return(elogl)
	noi display as result "Standard Deviation:" %8.3f return(sd)
	noi display as result "z = " %5.3f `z' "     P>|z| = " %5.2f `p'
	noi display " "
	
	if (`z' < 0 & `p' < 0.05) {
		noi display as result "Result: Agglomeration" 
		return local mtad = "Agglomeration"
	}

	if (`z' > 0 & `p' < 0.05) {
		noi display as result "Result: Dispersion" 
		return local mtad = "Dispersion"
	}

	noi display as result "Random choice simulated using " `i' " draws"

	restore
}
end
