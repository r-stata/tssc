*! nstagebinopt v1.0
cap log close
cap program drop nstagebinopt
cap mata: mata drop feas() 
cap mata: mata drop mvnp()
set more off


/*
	nstageoptbinopt
	
	Output admissible designs into a Stata dataset (control alpha and power)
*/

program def nstagebinopt, rclass
version 10.0

syntax, Nstage(int)	///						total number of stages
		ARms(int) ///						total number of arms (inc. control)
		ALpha(real) ///						type I error rate
		POwer(real) ///						pairwise power
		theta0(string) theta1(string) ///	risk differences under H0 and H1
		Ctrlp(string) ///					control event rate
		ARAtio(numlist >=0.1 <=2) ///		allocation ratio
		[ppv(real 999) /// 					P(D=1|I=1)
		Save(string) ///					filename in which to save dataset containing designs
		FWer ///							control FWER at level alpha
		pi(real 0.1) ///					min proportion of max control sample size recruited in each stage (default 0.1)
		p(string) ///						power(s) in alpha function (>2-stages only) ***make numlist or remove?
		Ltfu(string) ///					loss-to-follow-up rates	
		fu(real 0) ///						length of f/u on I outcome
		ACCRate(string) ///					accrual rate in each stage
		acc(real 0.0005) ///				max diff in power and alpha of feasible designs from specified values
		PLot] //							plot expected sample sizes of admissible designs

// Rename macros
local J = `nstage'					// # stages
local Jm1 = `J'-1					// # I-stages
local K = `arms'-1					// # experimental arms
if "`fwer'"!="" local fwerate = `alpha'


// Check for errors
local errcount 0

if `nstage' < 2 {
	di as err "nstage() must be 2 or more"
	local ++errcount
}

if `nstage' > 5 {
	di as err "no more than 5 stages are recommended"
	local ++errcount
}

if `pi'<0 | `pi'>1 {
	di as err "pi() must be between 0 and 1/`J'"
	local ++errcount
}

if `ppv'!=999 {
	if `ppv'<0 | `ppv'>1 {
		di as err "ppv() should be between 0 and 1"
		local ++errcount
	}
}

if `alpha'!=-1 {
	if `alpha'>0.5 | `alpha'<=0.001 {
		di as err "alpha() must be within a plausible range"
		local ++errcount
	}
}

if `power'>=1 | `power'<0.7 {
	di as err "power() must be within a plausible range"
	local ++errcount
}

if `acc'<0 | `acc'>0.01 {
	di as err "acc() must be between 0 and 0.01"
	local ++errcount
}


// Set default ltfu
if "`ltfu'"=="" {
	if `ppv'==999 local ltfu 0
	else local ltfu 0 0 
}

if `fu'==0 & "`accrate'"=="" {
	forvalues j = 1/`J' {
		local accrate `accrate' 100
	}
}



// Split strings up
* Strings with J items
local nopts: word count `accrate'
if `nopts'!=`J' {
	di as err "must specify `J' values for accrate()"
	local ++errcount
}

forvalues j = 1/`J' {
	local accrS`j' : word `j' of `accrate'
	cap confirm number `accrS`j''
	if _rc {
		di as err "`accrS`j'' found where number expected"
		local ++errcount
	}
}	

* Strings with 1 (I=D) or 2 (I!=D) items
local nval = cond(`ppv'!=999, 2, 1)
if `nval'==2 local s `s'

local opts theta0 theta1 ctrlp ltfu
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


// Check p
if "`p'"=="" {
	if `J'>2 {
		if `ppv'==999 local p 0 0.25 0.5
		else local p 0 0.25 0.5 0.75 1
	}
	
	else local p 0
}

else {
	if `J'==2 local p 0
}

numlist "`p'", range(>=0 <=1) sort missingokay min(0)
local p_list `r(numlist)'


local pci `ctrlpS1'
local th0i `theta0S1'
local th1i `theta1S1'
local ltfui `ltfuS1'
local accri `accrS1'

forvalues j = 2/`J' {
	local pci `pci' \ `ctrlpS`j''
	local th0i `th0i' \ `theta0S`j''
	local th1i `th1i' \ `theta1S`j''
	local ltfui `ltfui' \ `ltfuS`j''
	local accri `accri' \ `accrS`j''
}	

matrix pc = (`pci')
matrix th0 = (`th0i')
matrix th1 = (`th1i')
matrix ltfu = (`ltfui')
matrix accr = (`accri')



// Generate feasible design dataset here - specify location and name in command
preserve 
clear

forvalues j = 1/`J' {
	gen a`j' = .
	gen w`j' = .
	gen N`j' = .
}
gen A = .
gen alpha = .
gen fwer = .
if `ppv'==999 gen se_fwer = .
gen power = .
gen nCfix = .
gen p = .


di as text " Finding set of feasible designs..."

* (run p forloop here)
foreach A of numlist `aratio' {

	// If FWER specified, find required PWER (search between FWER/K and FWER)
	qui if "`fwer'"!="" & `K'>1 {
		
		local a = round(`fwerate'/`K',0.0001)
		local min 0
		local max 0

		qui while !`max' {
			
			fwer1stage, arms(`arms') alpha(`a') aratio(`A')

			local fwerhat = r(fwer)
			
			if !`min' & `fwerhat'-`fwerate'>-`acc' {
				local la = `a'
				local min 1
			}
			
			if `fwerhat'-`fwerate'>`acc' {
				local ua = `a'-0.00001
				local max 1
			}
			else local a = `a'+0.00001
		}	
		
		local alpacc = (`ua'-`la')/2
		local alpha = (`ua'+`la')/2
		
	}
	
	else local alpacc = `acc'

	foreach pp in `p_list' {
		mata: feas(`J', `K', `alpha', `power', st_matrix("pc"), st_matrix("th0"), st_matrix("th1"), st_matrix("ltfu"), `A', `pi', `ppv', `pp', `alpacc', `fu', st_matrix("accr"))
	}
}

qui count
if r(N)==0 {
	di as err "No designs"
	exit 198
}


// Design parameters 
format a? w? %9.2f
if `ppv'==999 | "`fwer'"=="" format a`J' %9.3f
else format a`J' %9.0g		// 4 dp enough?
qui tostring a? w?, force u replace

gen sw_alpha = a1
gen sw_power = w1

qui forvalues j = 2/`J' {
	replace sw_alpha = sw_alpha + " " + a`j'
	replace sw_power = sw_power + " " + w`j'
}


// Expected sample sizes (if K>1)
qui {
	noi di as text " Calculating expected sample sizes..."
	
	foreach k in 0 `K' {
		gen ess`k' = .
	}
		
	local ndes = _N
	*gen ok = .
	
	local narms
	local acc
	forvalues j = 1/`J' {
		local narms `narms' `arms'
	}	
	if `ppv'==999 local fup `fu' 
	else local fup `fu' 0
	
	forvalues d = 1/`ndes' {
		local a_set = sw_alpha in `d'
		local w_set = sw_power in `d'
		local A = A in `d'
		
		if "`fwer'"=="" local nofwer nofwer
		
		qui which nstagebin
		if `ppv'==999 cap nstagebin, nstage(`J') acc(`accrate') theta0(`theta0') theta1(`theta1') ctrlp(`ctrlp') ///
			arms(`narms') alpha(`a_set') power(`w_set') aratio(`A') ltfu(`ltfu') fu(`fup') ess `nofwer'
			
		else cap nstagebin, nstage(`J') acc(`accrate') theta0(`theta0') theta1(`theta1') ctrlp(`ctrlp') arms(`narms') ///
			alpha(`a_set') power(`w_set') aratio(`A') ppvc(`ppv') ppve(`ppv') ltfu(`ltfu') fu(`fup') ess `nofwer'
		
		*if _rc==0 {
			forvalues j = 1/`J' {
				local N`j' = r(totS`j')
				replace N`j' = `N`j'' in `d'
			}
		
			if "`fwer'"!="" {
				if `ppv'==999 {
					local fwerhat = r(fwer)
					local se_fwerhat = r(se_fwer)
					replace se_fwer = `se_fwerhat' in `d'
				}
				
				else local fwerhat = r(maxfwer)
				replace fwer = `fwerhat' in `d'
			}

			foreach k in 0 `K' {
				local ess`k' = r(ess`k')
				replace ess`k' = round(`ess`k'') in `d'		// NB: rounding makes it less sensitive to the simulation error
			}
			
			*replace ok = 1 in `d'
		*}
		
		*else replace ok = 0 in `d'
	}

*drop if ok==0

}

/* 
	Optimal designs
	 - K>1 only 

qui if `K'>1 {
	noi di as text "Finding set of optimal designs..."
	gen opt = ""
	forvalues k = 0/`K' {
		egen miness`k' = min(ess`k')
		replace opt = opt+"`k' " if ess`k'==miness`k'
	}
	drop miness*
}
*/

/*
	Admissible designs
	 - if K=1 minimise qE(N|H0)+(1-q)max(N)
	 - otherwise minimise qE(N|H0)+(1-q)E(N|HK)
*/
di as text " Finding set of admissible designs..."

qui {	
	
	// Size of shortest stage
	gen N0 = 0
	forvalues j = 1/`J' {
		local jm1 = `j'-1
		gen dN`j' = N`j'-N`jm1'
	}
	egen min_n = rowmin(dN*)
	drop dN* N0
	
	
	/* Admissible designs
			if >1, choose one with: lowest ESS, lowest MSS, longest stage duration
	*/
	gen min_q = .
	gen max_q = .
	forvalues q = 0(0.01)1.001 {
		cap drop min_loss q loss
		
		if `K'==1 {
			*replace ess0 = round(ess0)				
			gen loss = (1-`q')*ess0+`q'*N`J'
		}
		else gen loss = (1-`q')*ess0+`q'*ess`K'
		
		egen min_loss = min(loss)
		gen q = `q' if loss==min_loss
		count if q==float(`q')

		if r(N)>1 {
			egen min_ess0 = min(ess0) if q==float(`q')
			replace q = . if ess0!=min_ess0
			
			if `K'==1 {
				egen min_max = min(N`J') if q==float(`q')
				replace q = . if N`J'!=min_max
				drop min_max
			}
			
			else {
				egen min_ess`K' = min(ess`K') if q==float(`q')
				replace q = . if ess`K'!=min_ess`K'
				drop min_ess`K'
			}
			
			egen max_dN = max(min_n) if q==float(`q')
			replace q = . if min_n!=max_dN
			
			drop min_ess0 max_dN 
		}	
		replace min_q = q if min_q==. 
		replace max_q = q if (max_q<q & q!=.) | max_q==.
	}

	drop min_loss q loss

	keep if max_q!=.
*	else keep if max_q!=. | opt!=""
	format min_q max_q %9.2f
	tostring min_q max_q, replace force u
	gen q_range = "["+min_q+","+max_q+"]"
	drop min_q max_q

	
	// Stagewise sample sizes
	tostring N?, force u replace

	gen sw_N = N1

	qui forvalues j = 2/`J' {
		replace sw_N = sw_N + " " + N`j'
	}
	*drop a? w? N? min_n
	drop min_n

	sort q_range
	format alpha power %9.4f
	format ess* %9.0f
	if `J'>2 order q_range p sw_alpha sw_power sw_N ess* alpha power
	else order q_range sw_alpha sw_power sw_N ess* alpha power
}

label var sw_alpha "Stagewise sig. levels"
label var sw_power "Stagewise powers"
label var sw_N "Stagewise sample size"
label var ess0 "Expected sample size under H0"
label var ess`K' "Expected sample size under H`K'"
label var alpha "Pairwise type I error rate"
label var power "Pairwise power"
label var A "Allocation ratio"
label var nCfix "Fixed sample size for control"
if "`fwer'"!="" {
	label var fwer "Maximum FWER"
	format fwer %9.4f
}

*drop nfix 
if "`fwer'"!="" drop alpha power
else drop power


// Output designs
if "`fwer'"!="" & `K'>1 local ncol 8
else local ncol 7
local ww1 11
local ww2 9

local sr1 %`ww1's
local sr2 %`ww2's

local totww = (`ncol'-1)*`ww2'+`ww1'

di as text "{hline `totww'}"
di as text `sr1' "q-range" `sr2' "Stage" `sr2' "Sig."  `sr2' "Power" `sr2' "Alloc." ///
				`sr2' "E(N|H0)" _cont
if `arms'>2 di as text `sr2' "E(N|H`K')" _cont
else di as text `sr2' "max(N)" _cont
if "`fwer'"!="" & `K'>1 di as text  `sr2' "FWER" _cont

di _n as text `sr1' "" `sr2' "" `sr2' "level" `sr2' "" `sr2' "ratio" _cont
if  "`fwer'"!="" & `ppv'==999 & `K'>1 di as text `sr2' "" `sr2' "" `sr2' "(SE)" _cont
di _n as text "{hline `totww'}"

local ndes = _N

forvalues d = 1/`ndes' {
	
	if "`fwer'"!="" {
		local fwerate = fwer in `d'
		if `ppv'==999 local se_fwerate = se_fwer in `d'
	}

	local ess0 = ess0 in `d'
	if `arms'>2 local ess`K' = ess`K' in `d'
	local A = A in `d'
	local q_range = q_range in `d'
	
	forvalues j = 1/`J' {
		local a`j' = a`j' in `d'
		local w`j' = w`j' in `d'
		local N`j' = N`j' in `d'
	}
	
	forvalues j = 1/`J' {		
		if `j'==1 {
			di as res `sr1' "`q_range'" %`ww2'.0f `j' `sr2' "`a`j''" `sr2' "`w`j''" %`ww2'.2f `A' ///
				%`ww2'.0f `ess0' _cont
				
			if `arms'>2 di as res %`ww2'.0f `ess`K'' _cont
			else di as res %`ww2'.0f `N`J'' _cont
			
			if "`fwer'"!="" & `K'>1 di as res _cont %`ww2'.4f `fwerate' _cont
		}
		else {
			di _n as res `sr1' "" %`ww2'.0f `j' `sr2' "`a`j''" `sr2' "`w`j''" _cont
			if `j'==2 & "`fwer'"!="" & `ppv'==999 & `K'>1 di `sr2' "" `sr2' "" `sr2' "" as text "  (" ///
				as res %5.4f `se_fwerate' as text ")" _cont
		}
	}
	noi di _n as text "{hline `totww'}"
}


if `K'==1 {
	di as txt " Note: each design minimises the loss function q*max(N)+(1-q)*E(N|H0) for"
	di as txt "       weights q specified in q-range."
	*di as txt " q=0 corresponds to minimax design & q=1 corresponds to null-optimal design"
}

else {
	label var ess`K' "Expected sample size under H`K'"
	di as txt " Note: each design minimises the loss function (1-q)E(N|H0)+qE(N|H`K') for values"
	di as txt "       of q specified in q_range. Hk is the hypothesis that k of the experimental"
	di as txt "       arms are effective."
	*di as txt " q=0 corresponds to alternative-optimal design & q=1 corresponds to null-optimal design"
}

drop a? w? N?


// Save designs if filename specified
if `K'==1 drop *fwer*
if "`save'"!="" qui sav "`save'.dta", replace


// Draw plot of ESS vs MSS
qui if "`plot'"!="" {
	if `K'==1 {

		tempvar mss
		gen `mss' = word(sw_N,`J')
		destring `mss', replace

		tw ///
			(scatter ess `mss', c(l) ms(O) mfc(white)), ///
			xtitle(Maximum sample size) ///
			ytitle(Expected sample size under H{sub:0}) ///
			xline(`n_fix', lp(dash) lw(medthin) lc(gs10)) 
	}
	
	else {
		tw ///
			(scatter ess0 ess`K', c(l) ms(O) mfc(white)), ///
			xtitle(Expected sample size | H{sub:`K'}) ///
			ytitle(Expected sample size | H{sub:0})	
	}
}

restore

end		


// Start of Mata commands
mata:

void feas(J, K, alpha, power, pc, th0, th1, ltfu, A, pi, ppv, p, acc, fu, accr)
{
	Jm1 = J-1
	
	/* Event rates under H0 and H1 in E arm */
	p0 = pc:+th0
	p1 = pc:+th1
	
	FU = J(J,1,fu)
	FU[J]=0

	
	
	/* Accrual rate in control arm */
	/*accr0 = accr:/(1+A)*/

	/* Fixed sample size */
	nCfix = round((invnormal(1-alpha)+invnormal(power))^2 * 
					(A*pc[J]*(1-pc[J])+p1[J]*(1-p1[J]))/(A*(1-ltfu[J])*(th1[J]-th0[J])^2))
	/*nEfix = round(A*nCfix)
	nfix = nCfix+K*nEfix*/

	count = 0
	min_loss = 1E6
	opt_ess = 1E6
	opt_mss = 1E6
	reps = 2000

	/* Stage 1 alpha */
	if (ppv==999) min_alpha = round(floor(1000*alpha)/1000,0.001)
	else min_alpha = alpha
		
	a1 = 0.5
	while (a1 >= min_alpha ) {
		
		/* Power in intermediate stages */
		wI = power
		while ( wI <= 0.991 ) {
		
			/* Calculate S1 sample size */
			nc1 = round((invnormal(1-a1)+invnormal(wI))^2 *  
					(A*pc[1]*(1-pc[1])+p1[1]*(1-p1[1]))/(A*(th1[1]-th0[1])^2))

			
			/* Upper bound for final stage power */
			min_w = wI^(J-1)
			maxwD = min((wI, ceil(100*power/min_w)/100))
			maxwD = maxwD + 0.001

			/* Final stage power */
			wD = power
			while ( wD <= maxwD ) {
				
				/* Upper bound for final stage alpha */
				if (ppv==999) maxaJ=2*alpha		
				else maxaJ = alpha
				
				/* Final stage alpha */
				aJ = min_alpha
				while ( aJ <= maxaJ ) {	
											
					a = J(J,1,0)
					w = J(J,1,0)
					nc = J(J,1,0)
					/*NC = J(J,1,0)
					maxN = J(J,1,0)*/
					
					/* Stagewise alpha and power vectors */
					a[1] = a1
					a[J] = aJ
					
					min_a = 1
					err_a = 0
					
					for (j=1 ; j<=J ; j++) {

						jm1 = j-1
						if ((j>1) & (j<J)) {
							a[j] = round((a[1]/(j^p))*(J-j)/(J-1)+a[J]*(j-1)/(J-1),0.01)	
						}
												
						if (j<J) w[j] = wI
						else w[j] = wD
						
						min_a = min_a*a[j]
						if (j>1) {
							if (a[j]>=a[jm1]) ++err_a
						}
					}
					
					if (err_a>0) {
						aJ = aJ+0.001
						continue
					}
					
					if (min_a > alpha) {
						aJ = aJ+0.001
						continue 
					}

					/* Sample size in each stage */
					z_a = invnormal(a)
					z_w = invnormal(w)
					nc = round((z_w:-z_a):^2:*(A:*pc:*(1:-pc):+p1:*(1:-p1)):/(A:*(th1:-th0):^2))

					/*NC = round(nc:/(1:-ltfu)+FU:*r0) /* need to incorporate f/u */
					maxN = NC:+K*round(A:*NC)*/
				
					/* Number of controls and total recruited in each stage */
					/*dNC = J(J,1,0)		
					dN = J(J,1,0)*/
					
					dnc = J(J,1,0)
						
					for (j=1 ; j<=J ; j++) {
						jm1 = j-1
						
						/*if (j==1) dNC[1] = NC[1]
						else dNC[j] = (NC[j]-NC[jm1])
						
						if (j==1) dN[1] = maxN[1]
						else dN[j] = (maxN[j]-maxN[jm1])*/
						
						if (j==1) dnc[1] = nc[1]
						else dnc[j] = nc[j]-nc[jm1]
					}

					if (sum((dnc:/nc[J]):<pi) == 0) {
						
						/* Calculate pairwise alpha */
						/* 2-stages */
						if (J==2) {
						
							if (ppv==999) rho0 = sqrt(nc[1]/nc[2])
							
							else {
								v_th0 = (A:*pc:*(1:-pc):+p0:*(1:-p0)):/(A:*nc)
								
								rho0 = ((ppv*p0[1]-p0[1]*p0[2])+A*(ppv*pc[1]-pc[1]*pc[2])) /
											(A*nc[2]*sqrt(v_th0[1])*sqrt(v_th0[2]))
							}	
							
							if (ppv==999) a_hat = binormal(z_a[1],z_a[2],rho0)
							else a_hat = a[J]
						}
						
						/* >2-stages */
						else {
							
							rho0 = J(J,J,1)
							
							if (ppv!=999) v_th0 = (A:*pc:*(1:-pc):+p0:*(1:-p0)):/(A:*nc)
						
							for (j=1 ; j<=J ; j++) {
								jm1 = j-1
								
								for(i=1 ; i<=jm1 ; i++) {

									if (j<J) rho0[i,j] = sqrt(nc[i]/nc[j])
									
									else {
										if (ppv==999) rho0[i,j] = sqrt(nc[i]/nc[j])
										
										else rho0[i,j] = ((ppv*p0[i]-p0[i]*p0[j])+A*(ppv*pc[i]-pc[i]*pc[j])) /
														(A*nc[j]*sqrt(v_th0[i])*sqrt(v_th0[j]))
									}
									
									rho0[j,i] = rho0[i,j]
								}
							}
						
							if (ppv==999) a_hat = mvnp(z_a, rho0, reps)
							else a_hat = a[J]
						}
						
						
						/* Continue with alpha-feasible designs */
						if (abs(a_hat-alpha)<acc) {

							/* Calculate pairwise power*/
							/* 2-stages */
							if (J==2) {
							
								if (ppv==999) rho1 = rho0
								
								else {
									v_th1 = (A:*pc:*(1:-pc):+p1:*(1:-p1)):/(A:*nc)
									
									rho1 = ((ppv*p1[1]-p1[1]*p1[2])+A*(ppv*pc[1]-pc[1]*pc[2])) /
												(A*nc[2]*sqrt(v_th1[1])*sqrt(v_th1[2]))
								}	
								
								w_hat = binormal(z_w[1],z_w[2],rho1)
							}
							
							/* >2-stages */
							else {
								
								rho1 = rho0
							
								if (ppv!=999) {
									v_th1 = (A:*pc:*(1:-pc):+p1:*(1:-p1)):/(A:*nc)

									for (i=1 ; i<=J-1 ; i++) {	
										rho1[i,J] = ((ppv*p1[i]-p1[i]*p1[J])+A*(ppv*pc[i]-pc[i]*pc[J])) /
																(A*nc[J]*sqrt(v_th1[i])*sqrt(v_th1[J]))
										
										rho1[J,i] = rho1[i,J]
									}
								}
								
								w_hat = mvnp(z_w, rho1, reps)
							}
						
						
							/* Continue with near-feasible designs */
							if (abs(w_hat-power)<0.0005) {

								/*
								/* Calculate expected sample size if K=1 */
								if (K==1) {
									/* 2-stages */
									if (J==2) ess = dN[1]+a[1]*dN[2]								
										
									
									/* >2-stages */
									else {
										sw_a = J(1,J,1)
										sw_a[2] = a[1]
										sw_a[3] = binormal(z_a[1], z_a[2], rho0[1,2])
										
										for (j=4 ; j<=J ; j++) {
											jm1 = j-1
											sw_a[j] = mvnp(z_a[(1..jm1)] , rho0[(1..jm1),(1..jm1)] , reps)
										}
										
										ess = sw_a*dN	
									}
								}
								*/
								
								/* Store results in dataset:
										- stagewise alphas, power and max sample sizes
										- ESS
										- pairwise alpha and power
								*/
								
								st_addobs(1)
								i = st_nobs()
								
								for (j=1 ; j<=J ; j++) {
									st_store(i, 3*(j-1) + 1, a[j])
									st_store(i, 3*(j-1) + 2, w[j])
									/*st_store(i, 3*(j-1) + 3, maxN[j])*/
								}							
								
								/*if (K==1) st_store(i, "ess", ess)*/
								st_store(i, "A", A)
								st_store(i, "alpha", a_hat)
								st_store(i, "power", w_hat)
								st_store(i, "p", p)
								st_store(i, "nCfix", nCfix)
							}
						}
					}
										
					aJ = aJ+0.001
				}
				
				wD = wD+0.01
			}

			wI = wI+0.01
		}
		
		a1 = a1-0.01		
	}
} 


real scalar mvnp(Z, R, reps)
{
/*
	Assumes Hammersley sequences are to be generated, without antithetics.
*/
	real vector opt
	opt = (2, reps, 1, 0)	// 2 for Hammersley
	p = ghk( Z, R, opt, rank=.)
	return(p)
}
end


