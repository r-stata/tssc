*! version 1.1.2 PR 17apr2018
*! version 1.1.1 AGB 05aug2016
*! version 1.1.0 AGB 12feb2014
*! version 1.0.0 SB 06mar2004.
*! version 1.0.0 PR 23mar2004.
*! Based on Abdel Babiker ssizebi.ado version 1.1  20/4/97
/*
	History
1.1.2	17apr2018	Trivial correction to formatting of allocation ratios
1.1.1	05aug2016	One-sided option for non-inferiority corrected
					(previous version double-adjusted alpha)
1.1.0	12feb2013	Non-inferiority is now correctly implemented (calls art2bin)
*/
program define artbin, rclass
version 8
syntax , PR(string) [ ALpha(real 0.05) ARatios(string) COndit DIstant(int 0)	///
	DOses(string) N(integer 0) NGroups(integer 2) NI(int 0) Onesided(int 0)		///
	POwer(real 0.8) TRend NVMethod(int 0) ap2(real 0) ccorrect(int 0)]
local version "binary version 1.1.1 05aug2016"
local npr: word count `pr'
if `npr'<2 {
	di as err "At least two event probabilities required"
	exit 198
}
if max(`alpha',1-`alpha')>=1 { 
	di as err "alpha() out of range"
	exit 198
}
if max(`power',1-`power')>=1 {
	di as err "power() out of range"
	exit 198
}
if `n'<0 { 
	di as err "n() out of range"
	exit 198
}
if `ni' & ((`npr'>2)|(`ngroups'>2)) {
	di as err "Only two groups allowed for non-inferiority/substantial superiority designs"
	exit 198
}
if `ccorrect' & (`ngroups'>2) {
	di as err "Correction for contituity not allowed in comparison of > 2 groups"
	exit 198
}
if `onesided' & (`ngroups'>2) {
	di as err "One-sided not allowed in comparison of > 2 groups"
	exit 198
}

if `n'==0 {
	local ssize 1
}
else local ssize 0
if `distant'==0 {	/* default means non-distant (i.e. local) alternatives */
	local local ""
	local locmess "(local)"
}
else {
	local local "nolocal"
	local locmess "(distant)"
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
local trialtype "`trialtype' - binary outcome"

if `ni' {
	/* ! Non-inferiority ! */
	local tit2 "Comparison of 2 binomial proportions P1 and P2."
	
	/* Event probability in group 2 under the alternative hypothesis H1 */
	if `ap2'<0 | `ap2'>1 {
		di as err  "Group 2 event probability under the alternative hypothesis must be >0 & <1"
		exit 198
	}
	
	/* Method of estimating event probabilities for the purpose of estimating
		the variance of the difference in proportions under the null hypothesis H0 */
	local nvm = `nvmethod'  
	if `nvm'>3 | `nvm'<1 {
		local nvm 3
	}
	local method1 Sample estimate
	local method2 Fixed marginal totals
	local method3 Constrained maximum likelihood

	if "`aratios'"=="" | "`aratios'"=="1" | "`aratios'"=="1 1" {
		local allocr "Equal group sizes"
		local ar21 1
	}
	else {
		tokenize `aratios'
		forvalues i=1/2 {
 			confirm number ``i''
 			if ``i''<=0 {
				di as err  "Allocation ratio <=0 not alllowed"
				exit 198
			}
		}
		local ar21 = `2'/`1'
	}
	tokenize `pr'
	local p1 `1'
	local margin = `2' - `1'
*	local Margin: display %5.3f `margin'
	frac_ddp `margin' 3
	local Margin `r(ddp)'
	local p2 = cond(`ap2'==0, `p1', `ap2')
	local altp
	local co
	forvalues i=1/2 {
		frac_ddp `p`i'' 3
		local altp `altp'`co' `r(ddp)'
		local co ,
	}
	frac_ddp `p2'-`p1' 3
	local altd `r(ddp)'	// Difference in probabilities under alternative hypothesis //

	if `ssize' {
		qui art2bin `p1' `p2', margin(`margin') ar(`ar21')	///
		alpha(`alpha') power(`power') nvmethod(`nvm')
		local n `r(n)'
	}
	else {
		local n0 = floor(`n'/(1+`ar21'))
		local n1 = floor(`n'*`ar21'/(1+`ar21'))
		qui art2bin `p1' `p2', margin(`margin') n0(`n0')	///
			n1(`n1') alpha(`alpha') `Sided' nvmethod(`nvm')
		local power `r(power)'
	}
	local D = ceil(`n'*(`p1' + `p2'*`ar21')/(1+`ar21'))
}

else {
	// Superiority //
	preserve
	drop _all
	local ngroups=max(`ngroups',`npr')
	qui set obs `ngroups'
	tempname PI pibar
	qui gen double `PI'=.
	tokenize `pr'
	frac_ddp "`1'" 3
	local altp `r(ddp)'
	forvalues i=1/`npr' {
		confirm number `1'
		if max(`1',1-`1')>=1 { 
			di as err "Event probabilities out of range"
			exit 198
		}	
		qui replace `PI'=`1' in `i'
		if `i'>1 {
			frac_ddp `1' 3
			local altp `altp', `r(ddp)'
		}
		macro shift
	}
	summ `PI',meanonly
	scalar `pibar'=r(mean)
	if r(max)<=r(min) {
		di as err "At least two distinct alternative event probabilities required"
		exit 198
	}
	/*
		If the number of given alternative probabilities is less than the number of
		treatment groups, assume each of the remaining equals the mean of the given
		event probabilities. This minimises the non-centrality parameter and thus
		gives  conservative estimates of power and sample size.
	*/
	if `npr'<`ngroups' {
		local i=`npr'+1
		qui replace `PI'=`pibar' in `i'/l
		frac_ddp `pibar' 3
		while `i'<=`ngroups' {
			local altp `altp', `r(ddp)'
			local ++i
		}
	}
	tempname AR sar
	qui gen double `AR'=.
	if "`aratios'"=="" | "`aratios'"=="1 1" | "`aratios'"=="1 1 1" {
		qui replace `AR'=1/`ngroups'
		local allocr "Equal group sizes"
	}
	else {
		scalar `sar'=0
		tokenize `aratios'
		frac_ddp `1' 2
		local allocr `r(ddp)'
		local i 1
		while `i'<=_N {
			if "`1'"!="" {
				confirm number `1'
				if `1'<=0 {
					di as err  "Allocation ratio <=0 not alllowed"
					exit 198
				}
			
				qui replace `AR'=`1' in `i'
			}
			else qui replace `AR'=`AR'[`i'-1] in `i'
			scalar `sar'=`sar'+`AR'[`i']
			if `i'>1 {
				frac_ddp `AR'[`i'] 2
				local allocr `allocr':`r(ddp)'
			}
			local ++i
			macro shift
		}
		qui replace `AR'=`AR'/`sar'
	}
	summ `PI' [w=`AR'],meanonly
	scalar `pibar'=r(mean)

	tempname DOSE
	if "`trend'"!=""|"`doses'"!="" {
		local trtest "Linear trend test: doses are"
		qui gen double `DOSE'=.
		if "`doses'"=="" {
			qui replace `DOSE'=_n-1
			local doses "1,...,`ngroups'"
		}
		else {
			parse "`doses'",parse(" ")
			frac_ddp "`1'" 2
			local score `r(ddp)'
			local i 1
			while `i'<=_N {
				if "`1'"!="" {
					confirm number `1'
					if `1'<0 {
						di as err  "Dose < 0 not alllowed"
						exit 198
					}
					qui replace `DOSE'=`1' in `i'
				}
				else qui replace `DOSE'=`DOSE'[`i'-1] in `i'
				if `i'>1 {
					frac_ddp `DOSE'[`i'] 2
					local score `score', `r(ddp)'
				}
				local ++i
				macro shift
			}
			local doses "`score'"
		}
		sum `DOSE' [w=`AR'],meanonly
		qui replace `DOSE'=`DOSE'-r(mean)
	}
	tempname b MU q0 a D
	local K=`ngroups'-1
	scalar `b'=1-`power'
	if "`condit'"=="" {
		local test0 "Unconditional"
		local tit2 "Unconditional comparison of `ngroups' binomial proportions"
		qui gen double `MU'=`PI'-`pibar'
		tempname s
		scalar `s'=`pibar'*(1-`pibar')
		if "`trtest'"=="" {
			local test1 "Chisquare test"
			_sp `MU' `MU' `AR', out(`q0')
			scalar `q0'=`q0'/`s'
			scalar `a'=invchi2(`K',1-`alpha')
			if "`local'"=="" {
				if `n'==0 {
					local n=npnchi2(`K',`a',`b')/`q0'
					local D=`n'*`pibar'
				}
				else scalar `b'=nchi2(`K',`n'*`q0',`a')
			}
			else {
				tempname S sbar W  a0 a1 q1 eta g psi l
				qui gen double `S'=`PI'*(1-`PI')
				sum `S' [w=`AR'],meanonly
				scalar `sbar'=r(mean)
				sum `S',meanonly
				scalar `a0'=(r(sum)-`sbar')/`s'
				_sp `MU' `MU' `S' `AR', out(`q1')
				scalar `q1'=`q1'/`s'^2
				qui gen double `W'=1-2*`AR'
				_sp `S' `S' `W', out(`a1')
				scalar `a1'=(`a1'+`sbar'^2)/`s'^2
				if `n'==0 {
					* *******************************
					* Solve for n iteratvely
					tempname n0 nl nu b0 sm
					scalar `sm'=0.001
					local i 1
					scalar `n0'=npnchi2(`K',`a',`b')/`q0'
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
					* *******************************
				}
				else _pe2 `a0' `q0' `a1' `q1' `K' `n' `a' `b'
			}
		}
		else {
			local test1 "`trtest'`doses'"
			tempname tr q1
			_sp `MU' `DOSE' `AR', out(`tr')
			_sp `DOSE' `DOSE' `AR', out(`q0')
			scalar `q0'=`q0'*`s'
			if "`local'"=="" {
				scalar `q1'=`q0'
			}
			else {
				tempname S W 
				qui gen double `S'=`PI'*(1-`PI')
				_sp `DOSE' `DOSE' `S' `AR', out(`q1')
			}
			scalar `a'=sqrt(`q0')*invnorm(1-`alpha'/2)
			if `n'==0 {
				scalar `a'=`a'+sqrt(`q1')*invnorm(`power')
				local n=(`a'/`tr')^2
			}
			else {
				scalar `a'=abs(`tr')*sqrt(`n')-`a'
				scalar `b'=1-normprob(`a'/sqrt(`q1'))
			}
		}
		local D=`n'*`pibar'
	}
	else {
		local test0 "Conditional"
		local tit2 "Conditional test using Peto's approximation to the odds ratio"
		tempname LOR l d v
		scalar `v'=`pibar'*(1-`pibar')
		qui gen double `LOR'=log(`PI')-log(1-`PI')-log(`PI'[1])+log(1-`PI'[1])
		qui replace `LOR'=0 in 1
		sum `LOR' [w=`AR'],meanonly
		qui replace `LOR'=`LOR'-r(mean)
		if "`trtest'"=="" {
			local test1 "Chisquare test"
			_sp `LOR' `LOR' `AR', out(`q0')
			scalar `a'=invchi2(`K',1-`alpha')
			if `n'==0 {
				scalar `l'=npnchi2(`K',`a',`b')
				scalar `d'=`l'
				scalar `l'=sqrt(`l'*(`l'-4*`q0'*`v'))
				scalar `d'=(`d'+`l')/(2*`q0'*(1-`pibar'))
				local n=`d'/`pibar'
			}
			else {
				scalar `d'=`n'*`pibar'
				scalar `l'=`d'*(`n'-`d')*`q0'/(`n'-1)
				scalar `b'=nchi2(`K',`l',`a')
			}
		}
		else {
			local test1 "`trtest'`doses'"
			tempname tr
			_sp `DOSE' `LOR' `AR', out(`tr')
			_sp `DOSE' `DOSE' `AR', out(`q0')
			scalar `a'=invnorm(1-`alpha'/2)
			if `n'==0 {
				scalar `a'=sqrt(`q0')*(`a'+invnorm(`power'))
				scalar `l'=(`a'/`tr')^2
				scalar `d'=`l'
				scalar `l'=sqrt(`l'*(`l'-4*`v'))
				scalar `d'=(`d'+`l')/(2*(1-`pibar'))
				local n=`d'/`pibar'
			}
			else {
				scalar `d'=`n'*`pibar'
				scalar `l'=`d'*(`n'-`d')/(`n'-1)
				scalar `a'=abs(`tr')*sqrt(`l'/`q0')-`a'
				scalar `b'=1-normprob(`a')
			}
		}
		local D=`d'
	}
	local n=round(`n',1)+(round(`n',1)<`n')
	local D=int(`D'+1)
	local power=1-`b'
}

if `ngroups'==2 {
	local gplist "(groups 1, 2)"
}
else local gplist "(groups 1,..,`ngroups')"
local off 40
local longstring 38
local maxwidth 78
di as text _n "{hi:ART} - {hi:A}NALYSIS OF {hi:R}ESOURCES FOR {hi:T}RIALS" /*
 */ " (`version')" _n "{hline `maxwidth'}"
display as text "A sample size program by Abdel Babiker, Patrick Royston & Friederike Barthel,"
display as text "MRC Clinical Trials Unit at UCL, London WC1V 6LJ, UK." _n "{hline `maxwidth'}"
di as text "Type of trial" _col(`off') as res "`trialtype'"
artformatnos, n(`tit2') maxlen(`longstring')
local nlines=r(lines)
forvalues i=1/`nlines' {
	if `i'==1 {
		di as text "Statistical test assumed" _col(`off') as res "`r(line`i')'"
	}
	else di as text _col(`off') as res " `r(line`i')'"
}
if `ni' {
	di as txt "Null hypothesis H0:" _col(`off') as res "P2-P1 = `Margin'"
	di as txt "Alternative hypothesis H1:" _col(`off') as res "P2-P1 = `altd'"
	local vmethod `method`nvm''
	di as text "Null variance estimation method" _col(`off') as res "`vmethod'"
}
di as text "Number of groups" _col(`off') as res "`ngroups'"
di as text "Allocation ratio" _col(`off') as res "`allocr'"
if `ngroups'>2 & "`trtest'"!="" {
	di as text "`trtest'" _col(`off') as res "`doses'"
}
di as text _n "Anticipated event probabilities" _col(`off') as res "`altp'"
di as text _n "Alpha" _col(`off') %5.3f as res `Alpha' " (`sided'-sided)"
if `ssize'==1 {
 	di as text "Power (designed)" _col(`off') %5.3f as res `Power'
	return scalar power=`Power'
 	local mess (calculated)
}
if `ssize'==0 {
 	di as text "Power (calculated)" _col(`off') %5.3f as res `power'
 	return scalar power=`power'
 	local mess (designed)
}
di as text _n "Total sample size `mess'" _col(`off') as res `n' 
di as text "Expected total number of events" _col(`off') as res `D'
di as text "{hline `maxwidth'}"
if `ni' {
	return local nvmrthod  "`vmethod'"
}
else {
	return local tests "`test0' `test1'"
}
return local altp "`altp'"
return local allocr "`allocr'"
return scalar alpha=`alpha'
return scalar n=`n'
return scalar D=`D'
end
* *****************************************************************************

program define _sp
* Calculate sum of products.
syntax varlist(min=1) [, OUt(string)]
tokenize `varlist'
tempvar SP
qui gen double `SP'=`1'
macro shift
while "`1'"!="" {
	qui replace `SP'=`SP'*`1'
	macro shift
}
summ `SP',meanonly
scalar `out'=r(sum)
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
