/* ********************************************************************************************************************************
                             Sample size for noninferiority of proportions
Let p0 and p1 be the prop of failure in in the control and treatmenet group.
Null hypothesis H0: d=p1-p0>=mrg; Alternative hypothesis H1: d<mrg; 
where mrg is the hypothesised margin for the difference in failure proportions
For the non-nferiority design, mrg > 0 is the noninferiority margin.
For the classical superiority design, mrg = 0 and for a substantial superiority design mrg < 0
Although the hypotheses are stated as one-sided, the recommended analysis is to use two sided tests
since the direction of the difference is almost always unknown apriori and one would normally use a two-sided CI for the difference.

Design			Margin		Proportions
------			------		-----------
Non-ineriority		> 0		Failure
Non-ineriority		< 0		Success
Classical Superiority	= 0		Failure/Success
Substantial Superiority	< 0		Failure
Substantial Superiority	> 0		Success

The sample size is the solution of

 {[za*Sqrt(var(Dhat|H0))+zb*Sqrt(var(Dhat|H1))]^2}/[(d-mrg)^2] = 1 --------------[1]

var(Dhat|H1) is estimated using the unconstrained sample estimates p0hat and p1hat of p0 and p1,
 the observed proportions of failure in the two treatment groups, which converge to p0*(1-p0)/n0+p1*(1-p1)/n1
There are several methods for estimating Var(Dhat|H0) based on P0*(1-P0)/n0+P1*(1-P1)/n1
Method 1 sets P0=p0 and P1=p1, ie uses same sample estimates as in var(Dhat|H1).
Other methods use limits of constrained estimates P0 and P1 such that P1-P0 = mrg. Two of these are

Method 2: P1 = (n0*p0hat+n1*p1hat+n0*mrg)/(n0+n1) = (p0hat+r*p1hat+mrg)/(1+r), and
          P0 = (n0*p0hat+n1*p1hat-n0*mrg)/(n0+n1) = (p0hat+r*p1hat-r*mrg)/(1+r), 
where r=n1/n0 is the allocation ratio These estimates are under fixed marginal totals 
(see Dunnett & Gent, Biometrics 1977). In the limit p0hat and p1hat are replaced by p0 and p1. 
For these estimates to lie between 0 and 1, we must have
max(-mrg, r*mrg) < p0+r*p1 < 1+r+min(-mrg, r*mrg).

3)Uses constrained ML to estimate p0 and p1, with constraints: P1-P0=mrg; 0<P0<1 and 0<P1<1. This is based approximately on the
  score test (see Farrington & Manning, Stat in Med 1990)

Continuity corrected sample size is estimated by inflating the uncorrected sample size n0 obtained from [1]
by cif (the continuity-corrected inflation factor) given by
  (1 + sqrt(1+2*(1+r)/(N*r*abs(d-mrg))^2)/4
See Fleiss, Levin, and M. C. Paik (2003): Statistical Methods for Rates and Proportions.

For given sample size N, the programme estimates power. For continuity corrected power, the designed sample size n is first deflated by a factor of
 [1 - (a/n)*(1-a/(4*n))], provided that n > a/(4*n), where a = (1+r)/(r*abs(d-mrg)).

Syntax art2bin p0 p1 [, margin(#) n0(#) n1(#) ar(#) alpha(#) power(#) nvmethod(#) onesided]
******************************************************************************************************************************** */

*version 0.01  14Sep2012
cap prog drop art2bin
program define art2bin, rclass
	gettoken p0 0 : 0, parse(" ,")
	gettoken p1 0    : 0, parse(" ,")

	confirm number `p0'
	confirm number `p1'

	local dalpha = 1 - $S_level/100
	local dpower 0.8
	local ss 0
	syntax [, MARgin(real 0) n(int 0) n0(int 0) n1(int 0) ARatio(string)		///
                  Alpha(real `dalpha')  Power(real `dpower') NVMethod(int 0)	///
				  ONESided CCorrect eventtype(string) VERsion(string)]

	if "`version'"=="" local version "binary version 1.1.1 05aug2016"

	if `alpha'<=0 | `alpha'>=1 { 
		di in red "alpha() out of range"
		exit 198
	}

	if `p0'<=0 | `p0'>=1 {
		di in red "Control event probability out of range"
		exit 198
	}
	if `p1'<=0 | `p1'>=1 {
		di in red "Intervention event probability out of range"
		exit 198
	}

	local nar 0
	local ar0 0
	local ar1 0
	tokenize "`aratio'", parse(" :,")
	while "`1'" ~= "" {
		if ("`1'"~=":")&("`1'"~=",") {
			cap confirm integer number `1'
			if _rc {
				di as err  "Non-integer allocation ratio not alllowed"
				exit 198
			}
			if `1'<=0 {
				di as err  "Allocation ratio <=0 not alllowed"
				exit 198
			}
			local ar`nar' `1'
			local ++nar
		}
		macro shift
	}
	if (`nar'==0)|(`nar'==1 & `ar0'==1)|(`nar'==2 & `ar0'==1 & `ar1'==1) {
		local allocr "Equal group sizes"
		local ar10 1
	}
	else if `nar'==1 {
		local allocr "1:`ar0'"
		local ar10 `ar0'
	}
	else if `nar'==2 {
		local allocr "`ar0':`ar1'"
		local ar10 = `ar1'/`ar0'
	}
	else {
		di as err  "Invalid allocation ratio"
		exit 198
	}

	if `n'<0 | `n0'<0 | `n1'<0 { 
		di in red "Sample size n() out of range"
		exit 198
	}
	if `n'==0 {
		if `n0' == 0 & `n1' == 0 {
			local ss 1		// Calculate sample size
		}
		else if `n1' == 0 {
			local n1 = `n0'*`ar10'
		}
		else if `n0' == 0 {
			local n0 = `n1'/`ar10'
		}
		else {
			local allocr "`n0':`n1'"
			local ar10 = `n1'/`n0'
		}
	}
	else {
		if `n0' == 0 & `n1' == 0 {
			local n0 = `n'/(1+`ar10')
			local n1 = `n'-`n0'
		}
		else if `n1' == 0 {
			local n1 = `n'-`n0'
			local allocr "`n0':`n1'"
			local ar10 = `n1'/`n0'
		}
		else if `n0' == 0 {
			local n0= `n'-`n1'
			local allocr "`n0':`n1'"
			local ar10 = `n1'/`n0'
		}
		else {
			cap assert `n0'+`n1' == `n'
			if _rc {
				di as err  "Invalid sample size"
				exit 198
			}
			local allocr "`n0':`n1'"
			local ar10 = `n1'/`n0'
		}
	}

	local et = substr("`eventtype'", 1, 1)
	if ("`et'"=="")|("`et'"=="f")|("`et'"=="F") {
		local eventtype failure
	}
	else if ("`et'"=="s")|("`et'"=="S") {
		local eventtype success
	}
	else {
		di in red `"Event type must be either "failure" or "success""'
		exit 198
	}

	local fail = "`eventtype'"=="failure"
	if `margin'==0 {
		local studytype "superiority"
	}
	else if ((`margin'>0)&(`fail')) | ((`margin'<0)&(~`fail')) {
		local studytype "non-inferiority"
	}
	else {
		local studytype "substatial superiority"
	}

	local mrg = `margin'

	// Method for estimating event probabilities under null hypothesis //
	local method1 Sample estimate
	local method2 Fixed marginal totals
	local method3 Constrained maximum likelihood

	// Estimating event probabilities and variance of the test stat //
	// under the null hypothesis //
	local nvm = `nvmethod'
	if `nvm'>3 | `nvm'<1 {
		local nvm 3
	}
	if `nvm' == 1 {
		local p0null = `p0'
		local p1null = `p1'
	}
	if `nvm' == 2 {								// Fixed marginal totals
		local p0null = (`p0'+`ar10'*`p1'-`ar10'*`mrg')/(1+`ar10')
		local p1null = (`p0'+`ar10'*`p1'+`mrg')/(1+`ar10')
		cap assert (`p0null'>0) & (`p0null'<1) & (`p1null'>0) & (`p1null'<1)
		if _rc {
		  local erm Event probabilities and/or non-inferiority/superiority margin are
		  local erm `erm' incompatible with the requested fixed marginal totals mrthod
		  di in red "`erm'"
		  exit 198
		}
	}
	else if `nvm' == 3 {							// Constrained ML
		local a = 1+`ar10'
		local b = `mrg'*(`ar10'+2)-1-`ar10'-`p0'-`ar10'*`p1'
		local c = (`mrg'-1-`ar10'-2*`p0')*`mrg'+`p0'+`ar10'*`p1'
		local d = `p0'*`mrg'*(1-`mrg')
		local v = (`b'/(3*`a'))^3-(`b'*`c')/(6*`a'^2)+`d'/(2*`a')
		local u = sign(`v')*sqrt((`b'/(3*`a'))^2-`c'/(3*`a'))
		local w = (_pi+acos(`v'/`u'^3))/3
		local p0null = 2*`u'*cos(`w')-`b'/(3*`a')
		local p1null = `p0null' + `mrg'

		// Check that MLE solution makes sense - may not be necessary  //
		_inrange01 `p0null' `p1null'
		if r(res)==0 {
		  cubic, c3(`a') c2(`b') c1(`c') c0(`d')
		  local nr = r(nroots)
		  foreach i of numlist 1/`nr' {
		    local x`i'0 = r(X`i')
		    local x`i'1 = `x0'+`mrg'
		  }
		  local r 0
		  foreach i of numlist 1/`nr' {
		    _inrange01 `x`i'0' `x`i'1'
		    if r(res)>0 {
		      local j = `i'
		      local r = `r'+1
		    }
		  }
		  if `r' == 0 {
		    di in red "Consrained ML equation for event probabilities under the null hypothesis has no solution"
		    exit 198
		  }
		  else if `r'>1 {
		    di in red "Consrained ML equation for event probabilities under the null hypothesis has more than one solution"
		    exit 198
		  }
		  else {
		    local p0null = `x`j'0'
		    local p1null = `p0null+`mrg'
		  }
		}
	}

	local D = abs(`p1'-`p0'-`mrg')
	local za = invnormal(1-`alpha'/2)
*	local Alpha = 1 - `alpha'/2
	local sided two
	if "`onesided'" ~= "" { 
		local za = invnormal(1-`alpha')
		local sided one
	}
	local zb = invnormal(`power')
	local snull = sqrt(`p0null'*(1-`p0null')+`p1null'*(1-`p1null')/`ar10')
	local salt  = sqrt(`p0'*(1-`p0')+`p1'*(1-`p1')/`ar10')

	local cc = "`ccorrect'"~=""
	if `ss' {
		local m = ((`za'*`snull'+`zb'*`salt')/`D')^2
		if `cc' {
		  _cc, n(`m') ad(`D') r(`ar10')
		  local m = r(n)
		}
		local n0 = ceil(`m')
		local n1 = ceil(`ar10'*`m')
		local n = `n0'+`n1'
		local Power `power'
		dis as txt "Total sample size = " as res `n'                                                                           
		return scalar n = `n'
		return scalar n0 = `n0'
		return scalar n1 = `n1'
	}
	else {
		if `cc' {
		  _cc, n(`n0') ad(`D') r(`ar10') deflate(1)
		  local n0 = r(n)
		}
		local Power = normal(((`D'*sqrt(`n0') - `za'*`snull'))/`salt')
		dis as txt "Power = " as res `Power'
		return scalar power = `Power'
	}

end
***********************************************************************************************************************************

cap prog drop _inrange01
program define _inrange01, rclass
	local x 1
	while "`1'"~="" {
		local x = `x'*(`1'>0)*(`1'<1)
		macro shift
	}
	return scalar res = `x'
end
***********************************************************************************************************************************
cap prog drop _cc
program _cc, rclass
  syntax , n(real) ADiff(real) [Ratio(real 1) DEFlate(real 0)]
  local a = (`ratio'+1)/(`adiff'*`ratio')
  if `deflate' {
    local n = ((2*`n'-`a')^2)/(4*`n')
  }
  else {
    local cf=((1+sqrt(1+2*`a'/`n'))^2)/4
    local n=`n'*(`cf')
  }
  return scalar n=`n'
end
