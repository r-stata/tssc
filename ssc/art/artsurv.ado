*! version 1.1.0 AGB 10dec2013
/*
	History

1.1.0	10dec2013	Sample size and power for non-inferiority designs corrected. Other changes:
						- Point mass at time 0 for distribution functions enabled.
						- Index parameter for the Harrington-Fleming test was dropped in translation
							from STUDYSI.ADO to ARTSURV.ADO. It is now restored and this option fot
							the test method no longer gives an error message.
						- Store expected proportions lost to follow-up and crossing over.
1.0.8	02apr2010	store duration of recruitment and recruitment weights; and,for each arm,
					loss to follow-up probability at maximum follow-up time, expected proportion lost to follow-up
1.0.7	19oct2009	calculate, output and store expected number of events per group
1.0.6	24oct2006	output to artpep via macro
					allow numlist in probabilities times in edf0() etc
1.0.5	06jul2005	no changes here, changes to some help files
1.0.4	20dec2004	syntax change to trend option to allow using <filename> in artsurv.dlg
1.0.3	13dec2004	using <filename> option added to allow filing of probs and hazard ratios
			minor tidying up of nomenclature
			-nohead- option added, to suppress banner heading
			Median was incorrectly forced to be an integer, now real
			Minor change to output to report median survival time, if input
			Fixed bug in reporting recruitment weights when too many specified
1.0.2	12nov2004	Allow edf0(), ldf(), wdf() to be specified for periods
				beyond that given by nperiod().
				Change necessary for -artpep- to work correctly.
			Create default for recrt() and aratios() if unspecified.
1.0.1	26may2004	[First public release]
*/
program define artsurv, rclass
version 10.0
syntax [using/] [, ALpha(real 0.05) ARatios(string) CRover(string) DEtail(int 0) DIstant(int 0) ///
 DOses(string) EDf0(string) FP(int 0) noHEad HRatio(string) INDexsurv(real 1) hr(int 1) LDf(string) ///
 LG(string) MEDian(real 0) METhod(string) N(integer 0) NGroups(integer 2) NI(int 0) ///
 NPeriod(integer 1) Onesided(int 0) POwer(real 0.8) PWehr(string) REcrt(string) REPLACE ///
 TRend(int 0) TUnit(int 1) WDf(string) WG(string)]
local version "survival version 1.1.0, 10 December 2013"
sreturn clear
local artpep "alpha(`alpha') aratios(`aratios') hratio(`hratio') ngroups(`ngroups') ni(`ni') onesided(`onesided') trend(`trend') tunit(`tunit')"

if `"`edf0'"'!="" {
	local artpep "`artpep' edf0(`edf0')"
}

if `"`median'"'!="" {
	local artpep "`artpep' median(`median')"
}

if `"`wdf'"'!="" {
	local artpep "`artpep' wdf(`wdf') wg(`wg')"
		if `"`crover'"'!="" {
			local artpep "`artpep' crover(`crover')"
		}
		if `"`pwehr'"'!="" {
			local artpep "`artpep' pwehr(`pwehr')"
		}
}

if `"`ldf'"'!="" {
	local artpep "`artpep' ldf(`ldf') lg(`lg')"
}

if `"`doses'"'!="" {
	local artpep "`artpep' doses(`doses')"
}

if `"`method'"'!="" {
	local artpep "`artpep' method(`method')"
}

global S_ARTPEP `"`artpep'"'
* Cancel returned errmess macro since can't be handled by Stata 8 dialog system
*local reterr "return local errmess"
local reterr "noi di as err"
if `ngroups'<2 {
	`reterr' "invalid number of groups, must be at least 2"
	exit 198
}
if "`recrt'"=="" {
	local recrt 0,0,0
}
if "`aratios'"=="" {
	local aratios 1
}
if "`edf0'"=="" {
	if `median'>0 { /* define survival prob in period 1 and put into edf0() */
		local s0=exp(-ln(2)/`median')
		local edf0 `s0',1
	}
	else {
		`reterr' "Baseline distribution function edf0() or median() required"
		exit 198
	}
}
if `onesided' & `ngroups'>2 {
	`reterr' "one-sided test not allowed with >2 groups"
	exit 198
}
if `trend'==0 {		/* default */
	local trend ""
}
else {
	local trend "trend"
}
if (`ngroups'==2) {	/* use trend test on 2 groups - more accurate for large alpha values */
	local trend trend
}
if `alpha'<=0 | `alpha'>=1 {
	`reterr' "alpha() out of range"
	exit 198
}
if `n'<=0 & (`power'<=0 | `power'>=1) {
	`reterr' "power() out of range (0,1)"
	exit 198
}
if `ni' {
	if `ngroups'>2 {
		`reterr' "No more than 2 groups are allowed for non-inferiority designs"
		exit 198
	}
	if ("`crover'"~="")|("`pwehr'"~="")|("`wg'"~="")|("`wdf'"~="") {
		`reterr' "Cross-over not allowed for non-inferiority designs"
		exit 198
	}
}
if "`lg'"!=""&"`ldf'"=="" { 
	`reterr' "Loss to follow-up time distribution function required"
	exit 198
}
if "`wg'"!=""&"`wdf'"=="" { 
	`reterr' "Withdrawal time distribution function required"
	exit 198
}
if `tunit'<1 | `tunit'>7 {
	`reterr' "Invalid time-unit code"
	exit 198
}
if `distant'==0 {	/* default means non-distant (i.e. local) alternatives */
	local local ""
	local locmess "(local)"
}
else {
	local local "nolocal"
	local locmess "(distant)"
}

if "`aratios'"!="" {
	local nratio=wordcount("`aratios'")
	if `nratio'>`ngroups' {
		`reterr' "You must give no more than `ngroups' allocation ratios"
		exit 198
	}
	tokenize `aratios'
	local default 1
	forvalues i=1/`nratio' {
		if "``i''"!="1" {
			local default 0
		}
	}
	if `default' {
		local aratios
	}
}
* `Alpha' is value as supplied; `alpha' is for use in calculations
local Alpha `alpha'
if `onesided' {
	local alpha=2*`alpha'
	local sided one
}
else local sided two
local Power `power'	/* as supplied */
if `ni' {
	local trialtype "Non-inferiority"
}
else local trialtype "Superiority"
if "`method'"=="b" | "`method'"=="u" | (`ni' & ("`method'"=="c")) {
	local trialtype "`trialtype' - events at end of trial"
}
else local trialtype "`trialtype' - time-to-event outcome"
tokenize `""One year" "6 months" "One quarter (3 months)" "One month" "One week" "One day" "Unspecified""'
local lperiod ``tunit''
tokenize `""year" "six-month period" "quarter" "month" "week" "day" "time-period unit""'
local lperiod2 ``tunit''
if `n'==0 {
	local ssize 1
}
else local ssize 0
if "`method'"=="" {
	local method l
}
local m1=substr("`method'",1,1)
if "`m1'"=="l" {
	local test "Unweighted logrank test"
	local tstat 1
}
else if "`m1'"=="t" {
	local test "Weighted logrank test: Tarone-Ware"
	local tstat 2
}
else if "`m1'"=="h" {
	local tstat 3
	local index `indexsurv'
	local test "Weighted logrank test: Harrington-Fleming (index `index')"
}
else if "`m1'"=="b" {
	if `ni' {
		local test "Conditional test with fixed marginal totals"
	}
	else {
		local test "Conditional test using Peto's approximation to the odds-ratio"
	}
	local tstat 0
	local condit "condit"
	if `ni' local nvm 1	/* Estimation of variance of difference in proportions 
								 under the null hypothesis */
}
else if "`m1'"=="u" {
	local tstat 0
	local test  "Unconditional binomial test"
	local condit
	if `ni' local nvm 0
	if "`local'"!="" {
		local nol "nolocal"
	}
}
else if `ni' & ("`m1'"=="c") {
	local tstat 0
	local test  "Constrained maximum likelihood"
	local condit
	local nvm 2
	if "`local'"!="" {
		local nol "nolocal"
	}
}
else {
	`reterr' "method(`method') not allowed"
	exit 198
}

* Prepare for saving survival probs and hazard ratios to file
if `"`using'"'!="" {
	if substr(`"`using'"',-4,.)!=".dta" {
		local using `using'.dta
	}
	if "`replace'"=="" {
		confirm new file `"`using'"'
	}
	tempname tmp
	local postvl surv hr
	postfile `tmp' group period `postvl' using `using', `replace'
}

quietly {
	global initrec
	preserve
	drop _all
	set obs `ngroups'
	capture set matsize 400	/* not often needed, but may be if detail is specified. */
	gen byte grp=_n
	sort grp

	_ar `ngroups' `aratios'  /* Setup allocation ratio */
	local allocr "$AR"
	global AR
	if `ni' {
		// Alloc ratio to be used in art2bin //
		local ar21 = cond("`aratios'"=="1", 1, ar[2]/ar[1]) 
	}
	if `tstat'!=0 {
		if "`trend'"!=""|"`doses'"!="" {
			_dose `ngroups' `doses'  /* Setup doses for trend */
			local doses "$DOSE"
			global DOSE
			tempname dose
			mkmat dose if grp>1,matrix(`dose')
		}
	}
	if "`trend'"!=""|"`doses'"!="" {
		local trtest "Linear trend test: doses = "
	}
	else local trtest "Global test"
	expand `nperiod'
	sort grp
	by grp:gen int period=_n
	sort grp period

	* Calculate event survival and hazard functions
	local sp=!`fp'	/* flag for survival probs supplied in edf0() */
	if `sp' {
		local ev "survival"
	}
	else local ev "cumulative event"
	capture _survf esf0, np(`nperiod') gr(1) cpr(`edf0') event(baseline `ev' probability) reverse(`sp')
	local rc=_rc
	if `rc' {
		`reterr' "`s(err)'"
		*return local errcode `rc'
		*exit 0
		exit `rc'
	}
	local m=`nperiod'+1
	replace esf0=esf0[_n-`nperiod'] in `m'/l
	_condsrv esf0 cesf0
	gen double el0=-log(cesf)
	gen double cesf=cesf0
	gen double el=el0
	_hr `ngroups',`hratio'   /* Setup hazard ratio function  */
	local hratios
	forvalues i=1/`ngroups' {
		if `i'>1 {
			local hratios `hratios', `s(hr`i')'
		}
		else local hratios `s(hr`i')'
	}
	if `ni' {
		tempvar hr1 dhr
		sort period grp
		qui by period: gen double `hr1' = hr/hr[1]
		sort grp period
		qui by grp:gen double `dhr'=abs(`hr1'-`hr1'[1])
		local nph 0
		forvalues i=1/`ngroups' {
			summ `dhr' if grp==`i'
			local nph = `nph' + (r(max)>1e-16)
		}
		if `nph' {
			noi di as err "Non-proportional hazards are not allowed for non-inferiority designs"
			exit 198
		}
		local hr21:display %4.2f `hr1'[_N]
		drop `hr1' `dhr'
	}

/*
	_hr leaves behind variables grp period esf hr.
	esf is the empirical survival function, taking the hr into account.
	Also, get hazard ratios in each period (use this in detailed output only)

	Compute survival/failure function for ith group in each period for later display
	
*/
	forvalues i=1/`ngroups' {
		local edf`i'
		local hratios`i'
		forvalues j=1/`nperiod' {
			sum esf if grp==`i' & period==`j'
			if `sp' {
				local esfij=r(mean)
			}
			else local esfij=1-r(mean)
			local edf: display %5.3f `esfij'
			local edf`i' `edf`i'' `edf'
			sum hr if grp==`i' & period==`j'
			local hrij=r(mean)
			local hr: display %6.3f `hrij'
			local hratios`i' `hratios`i'' `hr'
			if `"`using'"'!="" {
				if `j'==1 {
					* post survival probs and hr of 1 at "period 0"
					post `tmp' (`i') (0) (1) (.)
				}
				post `tmp' (`i') (`j') (`esfij') (`hrij')
			}
		}
	}

	* Calculate loss to follow-up survival function
	if "`lg'"=="" {
		gen double lsf=1
	}
	else {
		capture _survf lsf,np(`nperiod') gr(`lg') cpr(`ldf') /*
		 */ event(cumulative probability of loss to follow-up)
                local rc=_rc
		if `rc' {
			`reterr' "`s(err)'"
			*return local errcode `rc'
			*exit 0
			exit `rc'
		}
		replace lsf=1 if lsf==.
	}
	_condsrv lsf clsf
	gen double ll=-log(clsf)

	* Calculate withdrawal survival function and post withdrawal hazard ratio
	gen double pwehr=1
	if "`wg'"=="" {
		gen double wsf=1    /* Survival function for withdrawal time (cont part) */
		gen double wmass0=0 /* Proportion withdrawn at time 0 */
		gen double cwsf=1   /* Conditional surv function for withdr time */
		gen double wl=0     /* Withdrawal rate */
	}
	else {
		capture _survf wsf wmass0,np(`nperiod') gr(`wg') cpr(`wdf') /*
		 */ event(cumulative probability of withdrawal)
                local rc=_rc
		if `rc' {
			`reterr' "`s(err)'"
			*return local errcode `rc'
			*exit 0
			exit `rc'
		}
		replace wsf=1 if wsf==.
		replace wmass0=0 if wmass0==.
		_condsrv wsf cwsf
		gen double wl=-log(cwsf)
		* Set postwithdrawal event hazard ratio
		if "`crover'"!="" {
			local co "crover(`crover')"
		}
		if "`pwehr'"!="" {
			local ph "pwehr(`pwehr')"
		}
		pwh, ngroups(`ngroups') wg(`wg') `co' `ph'
	}
	* Recruitment cdf, weights, rates and proportion not adminstr censored
	if "`recrt'"!="" {
		local rec "recr(`recrt')"
	}
	_recd,np(`nperiod') `rec'
	local R=$recper
	global recper
	by grp:gen double in0=recdf[_N-_n+1]  /* in study at start of period */
	by grp:gen double inwt=recwt[_N-_n+1]
	by grp:gen double inir=recir[_N-_n+1]
	drop recdf recwt recir
	tempname es ls wm0 ws ep lp wp mu V0 V1

	* Obsrved proportion of failure, loss to followup and withdrawal
	if `ni' {
		tempvar k
		expand 2 if grp==2
		sort grp period
		qui by grp period: gen byte `k'=_n
		replace grp = 0 if `k'==2
		sort grp period
		foreach var in cesf el hr esf {
			replace `var' = `var'[_n+`nperiod'] if grp==0
		}
		drop `k'
	}
	_subdf esubdf lsubdf wsubdf
	if `ni' replace grp = 3 if grp==0
	sort grp period
	by grp:gen int last=_n==_N
	mkmat esf if last,matrix(`es')
	mkmat esubdf if last,matrix(`ep')
	mkmat lsf if last,matrix(`ls')
	mkmat lsubdf if last,matrix(`lp')
	mkmat wmass0 if last,matrix(`wm0')
	mkmat wsf if last,matrix(`ws')
	mkmat wsubdf if last,matrix(`wp')

	local ep0	// Event prob at max follow-up (as designed) for display
	local expev // Expected proportion of primary events at study end
	local ep1	// Same as expev formatted for display
	local lp0	// Prob of loss to follow-up at max follow-up (as designed) for display
	local explf // Expected proportion lost to follow-up at study end
	local lp1	// Same as explf formatted for display
	local wp0	// Prob of withdrawal (crossover) at max follow-up (as designed) for display
	local expwd // Expected proportion withdrawn (from allocated trt) at study end
	local wp1	// Same as expwd formatted for display
	
	local co
	local NG = cond(`ni', `ngroups'+1, `ngroups')
	forvalues i=1/`NG' {
		local expev`i' = `ep'[`i',1]
		local explf`i' = `lp'[`i',1]
		local expwd`i' = `wp'[`i',1]
		if ~(`ni' & (`i'==2)) {
			frac_ddp (1-`es'[`i',1]) 3
			local ep0 `ep0'`co' `r(ddp)'
			frac_ddp `expev`i'' 3
			local ep1 `ep1'`co' `r(ddp)'
			frac_ddp `explf`i'' 3
			local lp1 `lp1'`co' `r(ddp)'
			frac_ddp `expwd`i'' 3
			local wp1 `wp1'`co' `r(ddp)'
			local expev `expev' `expev`i''
			local explf `explf' `explf`i''
			local expwd `expwd' `expwd`i''
			local co ","
		}
	}
	local co
	forvalues i=1/`ngroups' {
		frac_ddp (1-`ls'[`i',1]) 3
		local lp0 `lp0'`co' `r(ddp)'
		frac_ddp (1-`ws'[`i',1])*(1-`wm0'[`i',1])+`wm0'[`i',1] 3
		local wp0 `wp0'`co' `r(ddp)'
		local co ","
	}
	if `ni' {
		local expev12 = `expev1'/(1+`ar21') + `expev3'*`ar21'/(1+`ar21')
		drop if grp==3
	}

	if `tstat'==0 {
/*
		if `ni' {
			local Sided
			if `onesided' local Sided onesided
			local margin = `expev2'-`expev1'
			if `n'==0 {
				art2bin `expev1' `expev3', margin(`margin') ar(`ar21')	///
					alpha(`alpha') power(`power') `Sided'
				local n `r(n)'
			}
			else {
				local n0 = floor(`n'/(1+`ar21'))
				local n1 = floor(`n'*`ar21'/(1+`ar21'))
				art2bin `expev1' `expev3', margin(`margin') n0(`n0')	///
					n1(`n1') alpha(`alpha') `Sided'
				local power `r(power)'
			}
			local D = ceil(`n'*`expev12')
		}
		else {
*/
			local pr
			forvalues i=1/`ngroups' {
				local pr "`pr' `expev`i''"
			}
			if "`doses'"!="" {
				local Doses "doses(`doses')"
			}
			if "`aratios'"!="" {
				local Aratios "aratios(`aratios')"
			}
			local ap2
			local nvmethod
			if `ni' {
				local ap2 ap2(`expev3')
				local nvmethod nvm(`nvm')
			}
			artbin, pr(`pr') ngroups(`ngroups') `Aratios' `condit'		///
				alpha(`Alpha') n(`n') power(`Power') `trend' `Doses'	///
				distant(`distant') onesided(`onesided') ni(`ni') `ap2' `nvmethod'
			local `r(allocr)'
			local doses "$dose"
			local power=r(power)
			local n=r(n)
			local D=r(D)
*		}
	}
	else {
		gen double P=ar*esubdf if last
		replace P=sum(P)
		tempname P
		scalar `P'=P[_N]
		_muv `mu' `V0' `V1' `ngroups' `tstat' `index'
		tempname IV0 A q0 a b
		local K=`ngroups'-1
		scalar `b'=1-`power'
		if "`trend'`doses'"=="" {
			mat `IV0'=syminv(`V0')
			mat `A'=`mu''*`IV0'
			mat `A'=`A'*`mu'
			scalar `q0'=`A'[1,1]
			scalar `a'=invchi2(`K',1-`alpha')
			if "`local'"=="" {
				if `n'==0 {
					local n=npnchi2(`K',`a',`b')
					local n=`n'/`q0'
					if `ni' {
						local n = `n'*`P'/(`expev12')
					}
				}
				else {
					if `ni' {
						local nn = `n'*`expev12'/(`P')
					}
					else {
						local nn = `n'
					}
					scalar `b'=nchi2(`K',`nn'*`q0',`a')
				}
			}
			else {
				tempname B a0 a1 q1 eta g psi l
				mat `A'=`IV0'*`V1'
				scalar `a0'=trace(`A')
				mat `B'=`A'*`A'
				scalar `a1'=trace(`B')
				mat `A'=`A'*`IV0'
				mat `A'=`mu''*`A'
				mat `A'=`A'*`mu'
				scalar `q1'=`A'[1,1]
				if `n'==0 {
					* *******************************
					* Solve for n iteratvely
					tempname n0 nl nu b0 sm
					scalar `sm'=0.001
					local i 1
					scalar `n0'=npnchi2(`K',`a',`b')
                                	scalar `n0'=`n0'/`q0'
					_pe2 `a0' `q0' `a1' `q1' `K' `n0' `a' `b0'
					if abs(`b0'-`b')<=`sm' {
						local i 0
					}
					else {
						if `b0'<`b' {
							scalar `nu'=`n0'
							scalar `nl'=`n0'/2
						}
						else {
							scalar `nl'=`n0'
							scalar `nu'=2*`n0'
						}
					}
					while `i' {
						scalar `n0'=(`nl'+`nu')/2
						_pe2 `a0' `q0' `a1' `q1' `K' `n0' `a' `b0'
						if abs(`b0'-`b')<=`sm' {
							local i 0
						}
						else {
							if `b0'<`b' {
								scalar `nu'=`n0'
							}
							else scalar `nl'=`n0'
							local i=`i'*((`nu'-`nl')>1)
						}
					}
					local n=`n0'
					if `ni' {
						local n = `n'*`P'/(`expev12')
					}
					* *******************************
				}
				else {
					if `ni' {
						local nn = `n'*`expev12'/(`P')
					}
					else {
						local nn = `n'
					}
					_pe2 `a0' `q0' `a1' `q1' `K' `nn' `a' `b'
				}
			}
		}
		else {	/* trend test */
			tempname tr q1
			mat `A'=`dose''*`V0'
			mat `A'=`A'*`dose'
			scalar `q0'=`A'[1,1]
			mat `A'=`dose''*`mu'
			scalar `tr'=`A'[1,1]
			if "`local'"=="" {
				scalar `q1'=`q0'
			}
			else {
				mat `A'=`dose''*`V1'
				mat `A'=`A'*`dose'
				scalar `q1'=`A'[1,1]
			}
			scalar `a'=sqrt(`q0')*invnorm(1-`alpha'/2)
			if `n'==0 {
				scalar `a'=`a'+sqrt(`q1')*invnorm(`power')
				local n=(`a'/`tr')^2
				if `ni' {
					local n = `n'*`P'/(`expev12')
				}
			}
			else {
				if `ni' {
					local nn = `n'*`expev12'/(`P')
				}
				else {
					local nn = `n'
				}
				scalar `a'=abs(`tr')*sqrt(`nn')-`a'
				scalar `b'=1-normprob(`a'/sqrt(`q1'))
			}
		}
		if `ni' {
			scalar `P'=`n'*`expev12'
		}
		else {
			scalar `P'=`n'*`P'
		}
		local D=round(`P',1)+(round(`P',1)<`P')
		local n=round(`n',1)+(round(`n',1)<`n')
		local power=1-`b'
	}
}
* Display output.
if `ngroups'==2 {
	local gplist "(groups 1,2)"
}
else if `ngroups'==3 {
	local gplist "(groups 1,2,3)"
}
else local gplist "(groups 1,..,`ngroups')"
local off 42
local maxwidth 78
local skip=`maxwidth'-length("ART - ANALYSIS OF RESOURCES FOR TRIALS")-length("(`version')")
local longstring=`maxwidth'-`off'
if "`head'"=="" {
	di as text _n "{hi:ART} - {hi:A}NALYSIS OF {hi:R}ESOURCES FOR {hi:T}RIALS" /*
	 */ _skip(`skip') "(`version')" _n "{hline `maxwidth'}"
	display as text "A sample size program by Abdel G Babiker, Patrick Royston & Friederike Barthel,"
	display as text "MRC Clinical Trials Unit at UCL, London WC1V 6LJ, UK." _n "{hline `maxwidth'}"
}
di as text "Type of trial" _col(`off') as res "`trialtype'"
if `ni' {
	artformatnos, n(`test') maxlen(`longstring')
}
else {
	artformatnos, n(`test' `locmess') maxlen(`longstring')
}
local nlines=r(lines)
forvalues i=1/`nlines' {
	if `i'==1 {
		di as text "Statistical test assumed" _col(`off') as res "`r(line`i')'"
	}
	else di as text _col(`off') as res " `r(line`i')'"
}
/*
if `ni' {
	local vmethod `nvmethod`nvm''
	di as text "Null variance estimation method" _col(`off') as res "`vmethod'"
}
*/
di as text "Number of groups" _col(`off') as res "`ngroups'"
di as text "Allocation ratio" _col(`off') as res "`allocr'"
if `ngroups'>2 & "`trtest'"!="" {
	di as text "`trtest'" _col(`off') as res "`doses'"
}
di as text _n "Total number of periods" _col(`off') as res `nperiod'
di as text "Length of each period" _col(`off') as res "`lperiod'"
di
if `median'>0 {
	if `median'!=1 {
		local ess s
	}
	di as text "Baseline median survival time" _col(`off') as res "`median' `lperiod2'`ess'"
}
if `sp' {
	local phrase Survival
}
else local phrase Cum. event
forvalues i=1/`ngroups' {
	if `ni' {
		artformatnos, n(`edf1') maxlen(`longstring')
	}
	else {
		artformatnos, n(`edf`i'') maxlen(`longstring')
	}
	local nlines=r(lines)
	forvalues j=1/`nlines' {
		if `j'==1 {
			di as text "`phrase' probs per period (group `i')" _col(`off') as res "`r(line`j')'"
		}
		else di as text _col(`off') as res " `r(line`j')'"
	}
}
di as text "Number of recruitment periods" _col(`off') as res `R'
di as text "Number of follow-up periods" _col(`off') as res `nperiod'-`R'
tokenize "`recrt'", parse(",")
local recm `5'
if "`recm'"=="" {
	local recm 0
}
if "`recm'"=="0" {
	di as text "Method of accrual" _col(`off') as res "Uniform"
}
else di as text "Method of accrual" _col(`off') as res "Exponential, parameter(s) = `recm'"
if `R'>0 {
	* Format recruitment period weights
	artformatnos, n($recwt) maxlen(`longstring')
	local nlines=r(lines)
	forvalues i=1/`nlines' {
		if `i'==1 {
			di as text "Recruitment period-weights" _col(`off') as res "`r(line`i')'"
		}
		else di as text _col(`off') as res " `r(line`i')'"
	}
}
if `ni' {
	di as txt _n "Non-inf margin HR (grp 2 rel to grp 1)" _col(`off') as res "`hr21'"
}
else {
	di as text _n "Hazard ratios as entered `gplist'" _col(`off') as res "`hratios'"
	if `detail' {
		local phrase "Hazard ratios"
		forvalues i=1/`ngroups' {
			artformatnos, n(`hratios`i'') maxlen(`longstring')
			local nlines=r(lines)
			forvalues j=1/`nlines' {
				if `j'==1 {
					di as text "`phrase' per period (group `i')" _col(`off') as res "`r(line`j')'"
				}
				else di as text _col(`off') as res " `r(line`j')'"
			}
		}
	}
}
di as text "Alpha" _col(`off') %5.3f as res `Alpha' " (`sided'-sided)"
if `ssize'==1 {
 	di as text "Power (designed)" _col(`off') %5.3f as res `Power'
 *	return scalar power=`Power'
 	local mess (calculated)
}
if `ssize'==0 {
 	di as text "Power (calculated)" _col(`off') %5.3f as res `power'
* 	return scalar power=`power'
	local mess (designed)
}
di as text _n "Total sample size `mess'" _col(`off') as res `n' 
di as text "Expected total number of events" _col(`off') as res `D'
di as text "{hline `maxwidth'}"
// Compute numbers of events in each group
local sumwt 0
local events
forvalues i = 1 / `ngroups' {
	if "`aratios'" == "" local w`i' 1
	else local w`i' : word `i' of `aratios'
	local sumwt = `sumwt' + `w`i''
}
local ev1 = (`n' * `w1' / `sumwt') * `expev1'
local events = ceil(`ev1')
if `ni' {
	local ev2 = (`n' * `w2' / `sumwt') * `expev3'
	local eee = ceil(`ev2')
	local events `events', `eee'
}
else {
	forvalues i = 2 / `ngroups' {
		local ev`i' = (`n' * `w`i'' / `sumwt') * `expev`i''
		local eee = ceil(`ev`i'')
		local events `events', `eee'
	}
}

if `detail' {
	di as text "Values given below apply to each group at the end of the trial"	///
		_n "{hline `maxwidth'}"
	di as text "Unadjusted event probs `gplist'" _col(`off') as res "`ep0'"
	di as text "Unadjusted loss to follow-up probs" _col(`off') as res "`lp0'"
	if ~`ni' di as text "Unadjusted cross-over probabilities" _col(`off') as res "`wp0'"
	di as text _n "*Expected numbers of events per group" _col(`off') as res "`events'"
	di as text "Expected proportions with event" _col(`off') as res "`ep1'"
	di as text "Expected proportions lost to follow-up" _col(`off') as res "`lp1'"
	if ~`ni' di as text "Expected proportions with cross-over" _col(`off') as res	///
		"`wp1'" _n as text "{hline `maxwidth'}"
	di as text "* Rounded to next whole number of events above the exact expected number"
}
if `"`using'"'!="" {
	postclose `tmp'
	* Transpose file using -reshape-
	use `"`using'"', replace
	quietly reshape wide `postvl', i(period) j(group)
	forvalues j=1/`ngroups' {
		label var surv`j' "group `j' survival probabilities"
		label var hr`j' "group `j' hazard ratios"
	}
	label var period "Periods of `lperiod'"
	save `"`using'"', replace
}

if ~`ni' return local expwdn `expwd'
return local expltf `explf'
foreach i of numlist `ngroups'(-1)1 {
	return scalar ev`i' = `ev`i''
}
return local expev `expev'
return local Events `events'
return scalar events=`D'
if `ssize'==1 {
	return scalar n=`n'
}
else {
	return scalar power=`power'
}
if `ssize'==1 {
	return scalar power=`Power'
}
else {
	return scalar n=`n'
}
return scalar alpha=`alpha'
if ~`ni' return local wdlprob `wp0'
return local ltfprob `lp0'
return local evprob `ep0'
return local recwt $recwt
return local recper `R'
return local allocr `allocr'
return scalar ngroups = `ngroups'

end
* *****************************************************************************
program define _ar
local ngroups "`1'"
macro shift
tempname sar
qui gen double ar=.
if "`1'"=="" {
	qui replace ar=1/`ngroups'
	local allocr "Equal group sizes"
}
else {
	scalar `sar'=0
	local i 1
	while `i'<=_N {
		if "`1'"!="" {
			confirm number `1'
			if `1'<=0 {
				noi di as err "Allocation ratio <=0 not alllowed"
	  			exit 198
			}
			qui replace ar=`1' in `i'
		}
		else {
		  qui replace ar=ar[`i'-1] in `i'
		}
		scalar `sar'=`sar'+ar[`i']
		frac_ddp ar[`i'] 2
		local allocr "`allocr'`co'`r(ddp)'"
		local i=`i'+1
		local co ":"
		macro shift
	}
	qui replace ar=ar/`sar'
}
global AR "`allocr'"
end
* *****************************************************************************
program define _dose
local ngroups "`1'"
macro shift
qui gen double dose=.
if "`1'"=="" {
	qui replace dose=_n-1
	local doses "1,...,`ngroups'"
}
else {
	local i 1
	while `i'<=_N {
		if "`1'"!="" {
			confirm number `1'
			if `1'<0 {
				di as err  "Dose < 0 not alllowed"
				exit 198
			}
			qui replace dose=`1' in `i'
		}
		else qui replace dose=dose[`i'-1] in `i'
		frac_ddp dose[`i'] 2
		local score "`score'`co'`r(ddp)'"
		local i=`i'+1
		local co ","
		macro shift
	}
	local doses "`score'"
	local p=dose[1]
	replace dose=dose-`p'
}
global DOSE "`doses'"
end
* *****************************************************************************

program define _survf, sclass
* Calculates survival function
* !! PR: option "reverse(1)" allows input of survival probs; default reverse(0) is failures probs.
sreturn clear
syntax newvarlist(min=1 max=2), gr(string) cpr(string) np(string) EVent(string) [reverse(int 0)]
local reterr "sreturn local err"

tempname small
scalar `small'=1e-16

gettoken sf mass0: varlist
*!! PR
gen double `sf'=.
if "`mass0'"!="" {
	gen double `mass0'=.
}

local m 0
tokenize `gr'
while "`1'"!="" {
	local ++m
	local g`m' "`1'"
	macro shift
}

tokenize "`cpr'", parse(";")
forvalues i=1/`m' {
	local cpr`i' "`1'"
	macro shift 2
}
forvalues l=1/`m' {
	if "`mass0'"!="" {
		replace `mass0'=0 if grp==`g`l''
	}
	replace `sf'=1 if grp==`g`l''
	tokenize "`cpr`l''",parse(",")
	if "`1'"==""|"`1'"=="," {
		`reterr' "`event' required"
		exit 499
	}
	local cp "`1'"          /* Cumulative probabilities  */
	local cpt "`2'"         /* Cumulative probabilities times */
//	Updated PR 24oct2006 to allow numlists for probabilities times
	if "`cpt'"=="," local cpt "`3'"
	if "`cpt'"=="" local cpt "1(1)`np'"
*	numlist "`cpt'", ascending integer range(>=1)
	numlist "`cpt'", ascending integer range(>=0)
	local cpt `r(numlist)'
	local k : word count `cp'
	local kt : word count `cpt'
	if `kt'<`k' {
		`reterr' "`event' times required"
		exit 499
	}
	tempname s0 s1 s a
	scalar `s0'=1
	scalar `s'=1
	local t 0
	forvalues i=1/`k' {
		local p: word `i' of `cp'
		if `reverse' {
			local oneminusp `p'
			local p=1-`p'
		}
		else local oneminusp=1-`p'
		if `oneminusp'>`s'|`p'>1 {
			`reterr' "Inappropriate `event'"
			exit 499
		}
		local pt: word `i' of `cpt'
		if `pt'>=`small' {
			if `pt'<`t' {
				`reterr' "`event' times must be in increasing order"
				exit 499
			}
			if abs(`pt'-int(`pt'))>`small' {
				`reterr' "`event' times cannot include fractions of periods"
				exit 499
			}
			if `pt'>`np' {
				/* times beyond nperiod are valid! */
			}
		}
		if `pt'<`small' {
			if "`mass0'"=="" {
				`reterr' "Probability mass at 0 not allowed"
				exit 499
			}
			replace `sf'=1 if grp==`g`l''
			replace `mass0'=`p' if grp==`g`l''
			scalar `s0'=`oneminusp'
		}
		else {
			scalar `s1'=`oneminusp'/`s0'
			scalar `a'=`s1'/`s'
/*
			by grp:replace `sf'=(`a')^((_n-`t')/(`pt'-`t')) if _n>`t' & grp==`g`l''
			by grp:replace `sf'=`sf'*`s' if _n>`t' & grp==`g`l''
*/
			by grp:replace `sf'=`s'*(`a'^((_n-`t')/(`pt'-`t'))) if _n>`t' & grp==`g`l''
			scalar `s'=`s1'
			local t "`pt'"
		}
	}
}
end
* ****************************************************************************

program define _condsrv
args sf csf
tempname small
scalar `small'=1e-16
by grp:gen double `csf'=`sf' if _n==1
by grp:replace `csf'=1 if _n>1 & `sf'[_n-1]<`small'
by grp:replace `csf'=`sf'/`sf'[_n-1] if _n>1 & `sf'[_n-1]>=`small'
replace `csf'=`small' if `csf'<`small'
end
* ****************************************************************************

program define _hr, sclass
tempname small
scalar `small'=1e-16
tokenize "`*'", parse(",")
local ngroups "`1'"
macro shift 2
gen double hr=1
local k 0
while "`1'"!="" & `k'<=`ngroups' {
	local ++k
	local h`k' "`1'"
	sreturn local hr`k' `1'
	macro shift 2
}
forvalues l=1/`k' {
	tokenize `h`l''
	local i 1
	while "`1'"!="" {
		by grp:replace hr=`1' if _n==`i' &  grp==`l'
		local r "`1'"
		local t "`i'"
		local ++i
		macro shift
	}
	by grp:replace hr=`r' if _n>`t'&grp==`l'
}
gen double lhr=log(hr)
sort period grp
egen double mlhr=sum(lhr),by(period)
replace mlhr=mlhr/`k'
replace lhr=mlhr if grp>`k'
replace hr=exp(mlhr) if grp>`k'
/* Verify groups do not have identical event time distribution */
sort period grp
by period:replace lhr=abs(hr-hr[1])
summ lhr
if abs(r(max))<`small' {
	noi di as err "Groups have identical event time distibution"
	exit 198
}
drop lhr mlhr
sort grp period
replace cesf=cesf^hr
gen double esf=cesf
by grp:replace esf=esf*esf[_n-1] if _n>1
replace el=el*hr
end
* ****************************************************************************

program define pwh
syntax, ngroups(int) wg(string) [ crover(string) pwehr(string) ]
sort period grp
/*
	Start by setting HR for all groups except group 1 to design HR for group 1.
	For group 1, set its HR to that for group 2.
*/
by period:gen double defpwehr=hr[1]
by period:replace defpwehr=hr[2] if grp==1
/*
	m is number of groups from wg()
	subject to withdrawal from allocated treatment
*/
local m 0
tokenize `wg'
while "`1'"!="" {
	local ++m
	local wgrp`m' "`1'"
	macro shift
}
/*
	If crover() is specified but not pwehr(), design HR(s) from group
	crossed-over to are allocated to corresponding group from wg().
	Example: wg(2 3) crover(1 2) => group 2 crosses over to HR from group 1,
	group 3 crosses over to HR from group 2.
*/	 
if "`pwehr'"==""&"`crover'"!="" {
	local k 0
	tokenize `crover'
	while "`1'"!="" {
		local k=`k'+1
		by period:replace pwehr=hr[`1'] if grp==`wgrp`k''
		macro shift
	}
}
else {
	if "`pwehr'"!=""&"`crover'"!="" {
		noi dis in bl "Crossover destination (crover) ignored"
	}
	local k 0
	tokenize "`pwehr'", parse(",")
	while "`1'"!=""&`k'<=`ngroups' {
		local ++k
		local h`k' "`1'"
		macro shift 2
	}
	local l 1
	while `l'<=min(`k',`m') {
		sort grp period
		tokenize `h`l''
		local i 1
		while "`1'"!="" {
			by grp:replace pwehr=`1' if _n==`i' & grp==`wgrp`l''
			local r "`1'"
			local t "`i'"
			local ++i
			macro shift
		}
		by grp:replace pwehr=`r' if _n>`t' & grp==`wgrp`l''
		local ++l
	}
}
* Default post withdrawal event hazard ratio
if `k'<`m' {
	local l=`k'+1
	while `l'<=`m' {
		if "`wgrp`l''"=="1" {
			local defpwed 2
		}
		else local defpwed 1
		noi di as text /*
		*/ "Post withdrawal event hr in group `wgrp`l'' not specified." /*
		*/ " Post withdrawal event time" _n  "distribution is assumed" /*
		*/ " to be the same as in group `defpwed'."
		replace pwehr=defpwehr if grp==`wgrp`l''
		local ++l
	}
}
drop defpwehr
sort grp period
end
* ****************************************************************************

program define _wasdist
/*
	Survival distribution adjusted for withdrawal (treatment change) at the
	abscissas generated by x={x1,...xk} for symmetric Guassian quadrature. ie
	the functions are calculated at z1i(=0.5*(1-xi)),z2i(=0.5*(1+xi)); i=1,...k
*/
syntax newvarlist(min=1 max=2), at(string)
tempname small
scalar `small'=1e-16
gettoken sf pdf: varlist
gen double `sf'=.
if "`pdf'"!="" {
	gen double `pdf'=.
}
tempvar safter
* Survival fn if withdrawal occured at time=0
sort grp period
gen double `safter'=cesf0^pwehr
by grp:replace `safter'=`safter'*`safter'[_n-1] if _n>1

tempvar I J a a2 A B B2 tmp ea eb sa
local N=_N
expand `N'
*d
*noi di as err  "expanding in _wasdist on N=`N', vars = " r(k) " resources = " r(k)*r(N)
sort grp period
qui by grp period:gen long `I'=_n	/* !! PR edit */
sort grp `I' period

gen double `a'=0
gen double `a2'=0
qui by grp `I':replace `a'=el0*pwehr[_n-`I'+1] if _n>=`I'
qui by grp `I':replace `a2'=el0*pwehr[_n-`I'] if _n>`I'
qui by grp `I':replace `a2'=el0 if _n==`I'
qui by grp `I':gen double `A'=sum(`a')-`a'
gen double `B'=0
qui by grp `I':replace `B'=el0*(pwehr[_n-`I']-pwehr[_n-`I'+1]) if _n>`I'
qui by grp `I':replace `B'=el0*(1-pwehr[1]) if _n== `I'
qui by grp `I':gen double `B2'=sum(`B')-`B'
qui by grp `I':replace `B'=sum(`B')

tempvar c wlI b1 b2 ehI
qui by grp `I':gen double `wlI'=wl[`I']
qui by grp `I':gen double `ehI'=el0[`I']*(hr[`I']-1) 
qui by grp `I':gen double `c'=cond(`I'==1,1,esf[`I'-1]*wsf[`I'-1])
replace `B'=`B'+`wlI'+`ehI'
replace `B2'=`B2'+`wlI'+`ehI'
gen double `b1'=cond(`wlI'<`small',0,`wlI'/`B')
gen double `b2'=cond(`wlI'<`small',0,`wlI'/`B2')

if "`at'"=="" {
	local at 1
}
local mx : word count `at'
if `mx'==1 {
	gen int IX=1
}
else {
	expand `mx'
	sort grp period `I'
	by grp period `I':gen long IX=_n
}
gen double x=1
expand 2
sort grp period `I' IX
local by "by grp period `I' IX"
`by':gen long JX=_n	/* !! PR edit */
tokenize `at'
forvalues i=1/`mx' {
	`by':replace x=cond(_n==1,0.5*(1-`1'),0.5*(1+`1')) if IX==`i'
	macro shift
}

sort IX JX grp period `I'
local by "by IX JX grp"
tempvar L L2
gen double `L'=`b1'*(exp(-`a'*x)-exp(-(`a'+`B')*x))
qui `by' period:replace `L'=0 if _n>period
gen double `L2'=`b2'*(exp(-(`a2'+`B2')*x)-exp(-`B2')*exp(-`a2'*x))
qui `by' period:replace `L2'=0 if _n>=period
replace `L'=`L'+`L2'
qui `by' period:replace `sf'=sum(`c'*exp(-`A')*`L')
if "`pdf'"!="" {
	replace `L'=`b1'*(`a'*exp(-`a'*x)-(`a'+`B')*exp(-(`a'+`B')*x))
	qui `by' period:replace `L'=0 if _n>period
	replace `L2'=`b2'*((`a2'+`B2')*exp(-(`a2'+`B2')*x)-exp(-`B2')*`a2'*exp(-`a2'*x))
	qui `by' period:replace `L2'=0 if _n>=period
	replace `L'=`L'+`L2'
	qui `by' period:replace `pdf'=sum(`c'*exp(-`A')*`L')
}
qui `by' period:keep if _n==_N
sort IX JX grp period
`by':replace `safter'=exp(-el0*pwehr*x)*cond(_n==1,1,`safter'[_n-1])
`by':replace `c'=cond(_n==1,1,esf[_n-1]*wsf[_n-1])
replace `sf'=`sf'+`c'*exp(-(el+wl)*x)
replace `sf'=(1-wmass0)*`sf'+wmass0*`safter'
if "`pdf'"!="" {
	replace `pdf'=`pdf'+`c'*(el+wl)*exp(-(el+wl)*x)
	replace `pdf'=(1-wmass0)*`pdf'+wmass0*el0*pwehr*`safter'
}
sort grp period IX JX
end
* *****************************************************************************

program define _subdf
* Subdistribution functions for failure and loss to followup.
syntax newvarlist(min=1 max=3)[, at(real 1)]
tokenize `varlist'
local esdf `1'
local lsdf `2'
local wsdf `3'
gen double `esdf'=.
if "`lsdf'"!="" {
	gen double `lsdf'=.
}
if "`wsdf'"!="" {
	gen double `wsdf'=.
}

tempname small x
scalar `small'=1e-16
scalar `x'=`at'

tempvar safter acir
* Survival fn if withdrawal occured at time=0
sort grp period
gen double `safter'=cesf0^pwehr
by grp:replace `safter'=`safter'*`safter'[_n-1] if _n>1

tempvar I J a a2 A B B2 c wlI b1 b2 ehI l EP011 EP012 EP021 EP022 EP111 EP121 pL pJ pI
compress
local N=_N
expand `N'
*d
*noi di as err  "expanding in _subdf on N=`N', vars = " r(k) " resources = " r(k)*r(N)
sort grp period
qui by grp period:gen long `I'=_n
sort grp `I' period

gen double `a'=0
gen double `a2'=0
qui by grp `I':replace `a'=el0*pwehr[_n-`I'+1] if _n>=`I'
qui by grp `I':replace `a2'=el0*pwehr[_n-`I'] if _n>`I'
qui by grp `I':replace `a2'=el0 if _n==`I'
qui by grp `I':gen double `A'=sum(`a')-`a'
gen double `B'=0
qui by grp `I':replace `B'=el0*(pwehr[_n-`I']-pwehr[_n-`I'+1]) if _n>`I'
qui by grp `I':replace `B'=el0*(1-pwehr[1]) if _n== `I'
qui by grp `I':gen double `B2'=sum(`B')-`B'
qui by grp `I':replace `B'=sum(`B')

qui by grp `I':gen double `wlI'=wl[`I']
qui by grp `I':gen double `ehI'=el0[`I']*(hr[`I']-1) 
qui by grp `I':gen double `c'=cond(`I'==1,1,esf[`I'-1]*wsf[`I'-1])
replace `B'=`B'+`wlI'+`ehI'
replace `B2'=`B2'+`wlI'+`ehI'
gen double `b1'=cond(`wlI'<`small',0,`wlI'/`B')
gen double `b2'=cond(`wlI'<`small',0,`wlI'/`B2')
sort grp period `I'

local alpha 1
gen double `l'=ll
local beta 0
while `beta'<=1 {
	local i 1
	while `i'<=2 {
		if `i'==1 {
			local y 1
		}
		else local y=`x'
		local j 1
		while `j'==1|`j'==2 & `beta'==0 {
			if `j'==1 {
				replace `l'=ll
			}
			else replace `l'=ll-inir
			_intgrlf `pJ' `alpha' `beta' `y' `l' `a'
			_intgrlf `pI' `alpha' `beta' `y' `l' `a' `B'
			replace `pJ'=`b1'*(`pJ'-`pI')
			qui by grp period:replace `pJ'=0 if _n>period
			_intgrlf `pL' `alpha' `beta' `y' `l' `a2' `B2'
			_intgrlf `pI' `alpha' `beta' `y' `l' `a2'
			replace `pL'=`b2'*(`pL'-exp(-`B2')*`pI')
			qui by grp period:replace `pL'=0 if _n>=period
			replace `pL'=`pL'+`pJ'
			qui by grp period:gen double `EP`beta'`i'`j''= /*
			 */ sum(`c'*exp(-`A')*`pL')
			local j=`j'+1
		}
		local i=`i'+1
	}
	local beta=`beta'+1
}
if "`lsdf'"!="" {
	tempvar l LP011 LP012 LP021 LP022 LP111 LP121 pL pJ pI
	if "`wsdf'"!="" {
		tempvar WP011 WP012 WP021 WP022 WP111 WP121
	}
	local alpha 0
	gen double `l'=ll
	local beta 0
	while `beta'<=1 {
		local i 1
		while `i'<=2 {
			if `i'==1 {
				local y 1
			}
			else local y=`x'
			local j 1
			while `j'==1|`j'==2&`beta'==0 {
				if `j'==1 {
					replace `l'=ll
				}
				else replace `l'=ll-inir
 				_intgrlf `pJ' `alpha' `beta' `y' `l' `a'
  				_intgrlf `pI' `alpha' `beta' `y' `l' `a' `B'
				replace `pJ'=`b1'*(`pJ'-`pI')
				qui by grp period:replace `pJ'=0 if _n>period
				_intgrlf `pL' `alpha' `beta' `y' `l' `a2' `B2'
				_intgrlf `pI' `alpha' `beta' `y' `l' `a2'
				replace `pL'=`b2'*(`pL'-exp(-`B2')*`pI')
				qui by grp period:replace `pL'=0 if _n>=period
				replace `pL'=`pL'+`pJ'
				qui by grp period:gen double `LP`beta'`i'`j''= /*
        			 */ sum(`c'*exp(-`A')*`pL')
				local j=`j'+1
			}
			local i=`i'+1
		}
		local beta=`beta'+1
	}
}

qui by grp period:keep if _n==_N
sort grp period
qui by grp:replace `c'=cond(_n==1,1,esf[_n-1]*wsf[_n-1])
qui by grp:replace `pL'=cond(_n==1,1,`safter'[_n-1])
tempvar A
gen double `A'=el0*pwehr
local alpha 1
local beta 0
while `beta'<=1 {
	local i 1
  	while `i'<=2 {
  		if `i'==1 {
			local y 1
	  	}
		else local y=`x'
  		local j 1
  		while `j'==1|`j'==2&`beta'==0 {
			if `j'==1 {
				replace `l'=ll
			}
			else replace `l'=ll-inir
			_intgrlf `pI' `alpha' `beta' `y' `l' el wl
			replace `EP`beta'`i'`j''=`EP`beta'`i'`j''+`c'*`pI'
			_intgrlf `pI' `alpha' `beta' `y' `l' `A'
			replace `EP`beta'`i'`j''=(1-wmass0)*`EP`beta'`i'`j''+ /*
	  	         */  wmass0*`pL'*`pI'
			local j=`j'+1
		}
		local i=`i'+1
	}
	local beta=`beta'+1
}

tempvar P F
by grp:gen double `P'=in0*`EP011'
by grp:gen double `F'=(1-$initrec)*inwt
replace `P'=`P'-(`EP012'-`EP011')*`F'/(exp(inir)-1) if inir!=0
replace `P'=`P'-`EP111'*`F' if inir==0
by grp:replace `P'=`P'*cond(_n==1,1,lsf[_n-1])
by grp:replace `esdf'=sum(`P')-`P'

by grp:replace `P'=in0*`EP021'
replace `P'=`P'-(`EP022'-`EP021')*`F'/(exp(inir)-1) if inir!=0
replace `P'=`P'-`EP121'*`F' if inir==0
by grp:replace `P'=`P'*cond(_n==1,1,lsf[_n-1])
replace `esdf'=`esdf'+`P'

if "`lsdf'"!="" {
	local alpha 0
	local beta 0
	while `beta'<=1 {
		local i 1
		while `i'<=2 {
			if `i'==1 {
			  local y 1
			}
			else local y=`x'
			local j 1
			while `j'==1 |`j'==2 & `beta'==0 {
				if `j'==1 {
					replace `l'=ll
				}
				else replace `l'=ll-inir
				_intgrlf `pI' `alpha' `beta' `y' `l' el wl
				if "`wsdf'"!="" {
					gen double `WP`beta'`i'`j''=`pI'
				}
				replace `LP`beta'`i'`j''=`LP`beta'`i'`j''+`c'*`pI'
				qui by grp:replace `pL'=cond(_n==1,1,`safter'[_n-1])
				_intgrlf `pI' `alpha' `beta' `y' `l' `A'
				replace `LP`beta'`i'`j''=(1-wmass0)*`LP`beta'`i'`j''+ wmass0*`pL'*`pI'
				local j=`j'+1
			}
			local i=`i'+1
		}
		local beta=`beta'+1
	}

	tempvar P F
	by grp:gen double `P'=in0*`LP011'
	by grp:gen double `F'=(1-$initrec)*inwt
	replace `P'=`P'-(`LP012'-`LP011')*`F'/(exp(inir)-1) /*
         */ if inir!=0
	replace `P'=`P'-`LP111'*`F' if inir==0
	by grp:replace `P'=`P'*ll*cond(_n==1,1,lsf[_n-1])
	by grp:replace `lsdf'=sum(`P')-`P'
	by grp:replace `P'=in0*`LP021'
	replace `P'=`P'-(`LP022'-`LP021')*`F'/(exp(inir)-1) /*
         */ if inir!=0
	replace `P'=`P'-`LP121'*`F' if inir==0
	by grp:replace `P'=`P'*ll*cond(_n==1,1,lsf[_n-1])
	replace `lsdf'=`lsdf'+`P'

	if "`wsdf'"!="" {
		tempvar P F H
		by grp:gen double `P'=in0*`WP011'
		by grp:gen double `F'=(1-$initrec)*inwt
		replace `P'=`P'-(`WP012'-`WP011')*`F'/(exp(inir)-1) /*
       	         */ if inir!=0
		replace `P'=`P'-`WP111'*`F' if inir==0
		gen double `H'=lsf*esf*wsf
		by grp:replace `P'=`P'*wl*cond(_n==1,1,`H'[_n-1])
		by grp:replace `wsdf'=sum(`P')-`P'
		by grp:replace `P'=in0*`WP021'
		replace `P'=`P'-(`WP022'-`WP021')*`F'/(exp(inir)-1) /*
               	 */ if inir!=0
		replace `P'=`P'-`WP121'*`F' if inir==0
		by grp:replace `P'=`P'*wl*cond(_n==1,1,`H'[_n-1])
		replace `wsdf'=`wsdf'+`P'
		replace `wsdf'=(1-wmass0)*`wsdf'+wmass0
	}
}

end
* ----------------------------------------------------------------------------
program define _intgrlf
/*
_intgrlf R a b x mu varlist:
  calculates (sum(varlist))^a*{integral from 0 to x of
 (y^b)*exp(-(sum(varlist+mu)*y))dy }; a=0 or 1; b=0 or 1
*/
local result "`1'"
local a "`2'"
local b "`3'"
local x "`4'"
local mu "`5'"
macro shift 5
tempvar sv c
gen double `sv'=0
while "`1'"!="" {
	replace `sv'=`sv'+`1'
	macro shift
}
local small 1e-16
gen double `c'=`sv'+`mu'
if `a'==0 {
	replace `sv'=1
}
capture drop `result'
gen double `result'=`sv'*(1-exp(-`c'*`x'))/`c'
replace `result'=`sv'*`x' if `c'<`small'
if `b'==1 {
	replace `result'=(`result'-`sv'*`x'*exp(-`c'*`x'))/`c'
	replace `result'=`sv'*`x'*`x'/2 if `c'<`small'
}
end
* *****************************************************************************

program define _recd
* Setup recruitment time distribution
tempname small
scalar `small'=1e-16
syntax, RECrt(string) [np(integer 1)]
if "`recrt'"=="" {
	local R 0      /* Length of recruitment period  */
	gen double recwt=0      /* Interval weight for recruitment */
}
else {
	tokenize "`recrt'", parse(",")
	local R1 "`1'"
	if "`R1'"=="," {
		local R1 "`np' 0"
	}
	else macro shift
	macro shift
	if "`1'"=="" {
		local recwt 1   /* Interval weight for recruitment */
		local recir 0   /* Rec time dist shape within intervals:
                                     0=uniform; >0=truncated exponential */
	}
	else {
		local recwt "`1'"
		if "`1'"=="," {
			local recwt 1
		}
		else macro shift
		macro shift
		local recir "`1'"
		if "`1'"=="" {
			local recir 0
		}
	}
	tokenize `R1'
	local R "`1'"
	confirm number `R'
	if "`2'"!="" {
		local init "`2'"    /* Initial recruitment at time 0 */
		confirm number `init'
	}
	else local init 0
	gen double recwt=0
	* screen for "*" notation and expand if used. Save wts as global macro recwt.
	global recwt
	local nrecwt=wordcount("`recwt'")
	local nwt 0
	local done 0
	forvalues i=1/`nrecwt' {
		if `done'==0 {
			local this: word `i' of `recwt'
			tokenize `this', parse("*")
			if "`2'"=="*" {
				confirm integer number `1'
				local toadd `1'
				local last `3'
			}
			else {
				local toadd 1
				local last `this'
			}
			confirm number `last'
			local nwt1=`nwt'+`toadd'
			if `nwt1'>`R' & `R'>0 {
				noi di as err "[too many recruitment period-weights specified, truncated at `R']"
				local nwt1 `R'
				local toadd=`R'-`nwt'
				local done 1
			}
			forvalues j=1/`toadd' {
				global recwt $recwt `last'
			}
			local nwt `nwt1'
		}
	}
	* If fewer weights than recruitment periods are specified, fill with last value
	if `nwt'<`R' {
		local i1=`nwt'+1
		forvalues i=`i1'/`R' {
			global recwt $recwt `last'
		}
	}
	local recwt $recwt
	* If length of recruitment is less than number of periods, fill with zero
	if `R'<`np' {
		local i1=`R'+1
		forvalues i=`i1'/`np' {
			global recwt $recwt 0
		}
	}
	tokenize `recwt'
	local i 1
	local last "recwt"           /* In case `R'=0 */
	while `i'<=`R' & "`1'"!="" {
		confirm number `1'  
		by grp:replace recwt=`1' if _n==`i'
		local ++i
		local last "`1'"
		macro shift
	}
	by grp:replace recwt=`last' if _n>=`i' & _n<=`R'

	gen double recir=0
	tokenize `recir'
	local i 1
	local last "recir"           /* In case `R'=0 */
	while `i'<= `R' & "`1'"!="" {
		confirm number `1'  
		by grp:replace recir=`1' if _n==`i'
		local ++i
		local last "`1'"
		macro shift
	}
	by grp:replace recir=`last' if _n>=`i'&_n<=`R'
}

tempvar srecwt
by grp:gen double `srecwt'=sum(recwt)
local sc=`srecwt'[_N]         /* Sum of wts in last grp. Same for all groups */
if `R'<`small'|`sc'<`small' {
	local init 1
	capture drop recir
	gen double recir=0
	gen double recdf=1
}
else {
	replace recwt=recwt/`sc'
	by grp:gen double recdf=`init'+(1-`init')*`srecwt'/`sc' if _n<=`R'
	by grp:replace recdf=1 if _n>=`R'
}
global initrec=`init'
global recper=`R'
end
* ****************************************************************************

program define _muv
* Calculate mean and covariance matrix of logrank O-E
args mu V0 V1 ng test index
tempname small
scalar `small'=1e-16
* Guassian quadratures
local NQ "5"
local XQ "0.1488743384 0.4333953941 0.6794095662 0.8650633666 0.9739065285"
local WQ "0.2955242247 0.2692667193 0.2190863625 0.1494513491 0.0666713443"
by grp:gen double tmp=cond(_n==1,1,lsf[_n-1])
_wasdist sf pdf,at(`XQ')
gen double r1=pdf/sf
sort x period grp
qui by x period:gen double hr1=r1/r1[1]
sort grp period IX JX

gen double w=1
tokenize `WQ'
forvalues i=1/`NQ' {
	replace w=`1' if IX==`i'
	macro shift
}
replace lsf=tmp*exp(-ll*x)
replace tmp=(1-$initrec)*inwt
gen double instudy=in0-tmp*x if abs(inir)<=`small'
replace instudy=in0-tmp*(exp(inir*x)-1)/(exp(inir)-1) if abs(inir)>`small'

* Logrank weight
if `test'==2 {
	egen double lrwt=sum(ar*lsf*sf),by(x period)
	replace lrwt=sqrt(instudy*lrwt)
}
else if `test'==3 {
	egen double lrwt=sum(ar*lsf*sf),by(x period)
	drop tmp
	egen double tmp=sum(ar*lsf),by(x period)
	replace lrwt=(lrwt/tmp)^`index'
}
else gen double lrwt=1

* hr-weighted proportion at risk under null and alternative hypothesis
egen double atrisk0=sum(ar*lsf*sf),by(x period)
replace atrisk0=ar*lsf*sf/atrisk0
egen double atrisk1=sum(ar*lsf*sf*hr1),by(x period)
replace atrisk1=ar*lsf*sf*hr1/atrisk1

* Event sub-pdf
egen double subpdf=sum(ar*lsf*pdf),by(x period)
replace subpdf=instudy*subpdf

* (Test statistic mean)/(Total sample size)
egen double mu=sum(w*lrwt*(atrisk1-atrisk0)*subpdf),by(grp)
replace mu=mu/2

* Variance of (Test statistic)/sqrt(Total sample size)
expand `ng'
sort x period grp
by x period grp:gen int K=_n
sort x period K grp
by x period K:gen double atriskK0=atrisk0[K]
by x period K:gen double atriskK1=atrisk1[K]
egen double V0=sum(w*lrwt^2*atriskK0*((grp==K)-atrisk0)*subpdf),by(K grp)
replace V0=V0/2
egen double V1=sum(w*lrwt^2*atriskK1*((grp==K)-atrisk1)*subpdf),by(K grp)
replace V1=V1/2

sort K grp period
by K grp:keep if _n==_N
keep grp K mu V0 V1 ar esubdf lsubdf wsubdf
* Update reshape to version 7 and later
/*
reshape gr K 1-`ng'
reshape vars mu V0 V1
reshape cons grp ar esubdf lsubdf wsubdf
reshape wide
*/
reshape wide mu V0 V1, i(grp ar esubdf lsubdf wsubdf) j(K)
sort grp
forvalues i=2/`ng' {
	local v0 "`v0' V0`i'"
	local v1 "`v1' V1`i'"
}
mkmat mu1 if grp>1,matrix(`mu')
mkmat `v0' if grp>1,matrix(`V0')
mkmat `v1' if grp>1,matrix(`V1')
keep grp ar esubdf lsubdf wsubdf
end
* *****************************************************************************

program define _pe2
* Calculate beta=P(type II error)
args a0 q0 a1 q1 k n a b
tempname b0 b1 f l
scalar `b0'=`a0'+`n'*`q0'
scalar `b1'=`a1'+2*`n'*`q1'
scalar `l'=`b0'^2-`k'*`b1'
scalar `f'=sqrt(`l'*(`l'+`k'*`b1'))
scalar `l'=(`l'+`f')/`b1'
scalar `f'=`a'*(`k'+`l')/`b0'
scalar `b'=nchi2(`k',`l',`f')
end
