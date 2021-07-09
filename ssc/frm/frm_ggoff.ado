*! Version 1.1.2 - 27 May 2014
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm_ggoff, rclass
	if(c(stata_version) >= 12.1) version 12.1
	else version 11.0

      syntax [anything] [, Wald lm lr								///
		DIFficult TECHnique(string) ITERate(integer 1000) from(string)		///
		TOLerance(real 1e-6) LTOLerance(real 1e-7) NRTOLerance(real 1e-5)		///
		NONRTOLerance TRace GRADient showstep HESSian SHOWTOLerance			///
		ml irls fisher(integer 1) search]

* Preliminaries (defaults, variables, sample and possible errors)

	local nmod: word count `anything'

	if(`nmod'>=2) {
            display as error "Only one model at a time can be tested"
            exit 198
      }

	if(`nmod'==1) qui estimates restore `anything'
	capture if(`nmod'==0) qui estimates store keepresults
		
	if("`e(cmd)'"!="frm") {
		di as error "results for frm not found or both components of a two-part model estimated together"
		exit 301
	}

	local model=e(model)
	if("`model'"=="1P" | "`model'"=="2Pfrac") local linkfrac=e(linkfrac)
	if("`model'"=="2Pbin") local linkbin=e(linkbin)
	local inflation=e(inflation)

 	if("`model'"!="2Pbin" & "`lr'"!="") {
		di as error "LR tests are not applicable to fractional models"
		exit 198
	}
 	if("`model'"=="2Pbin" & "`lr'"!="" & ("`irls'"!="" | "`e(opt)'"=="irls")) {
		di as error "LR tests require ml estimation of both models; irls estimation is not allowed"
		exit 198
	}

      if("`wald'"=="" & "`lm'"=="" & "`lr'"=="") local lm "lm"
	if("`lr'"!="") local LLh0=e(ll)

	if("`wald'"!="") {
 		if("`e(vce)'"!="cluster") local vce `e(vce)'
 		if("`e(vce)'"=="cluster") local vce `e(vce)' `e(clustvar)'
	}

	tempvar ybin XB touse G g

      qui gen byte `touse'=e(sample)

	local yobs=e(depvar)
	if("`model'"=="2Pbin" & `inflation'==0) qui gen `ybin'=(`yobs'>0)
	if("`model'"=="2Pbin" & `inflation'==1) qui gen `ybin'=(`yobs'==1)

	local _rhs: colnames(e(b))
      local cons "_cons"
      local _rhs: list _rhs-cons

* Tests - all versions

	if("`model'"=="1P") display _newline(1) "*** Fractional `linkfrac' regression model ***"
      if("`model'"=="2Pbin") display _newline(1) "*** Binary component of two-part model - `linkbin ***' specification ***"
      if("`model'"=="2Pfrac") display _newline(1) "*** Fractional component of two-part model - `linkfrac' specification ***"

	di in text "{hline 13}{c TT}{hline 21}"
	di in text %10s "Version" _col(14) "{c |} Statistic   p-value" 
	di in text "{hline 13}{c +}{hline 21}"

	qui predict `XB' if (`touse'), xb

	if("`model'"=="1P" | "`model'"=="2Pfrac") local link `linkfrac'
	if("`model'"=="2Pbin") local link `linkbin'

	qui predict `G' if (`touse')

	if("`link'"=="cauchit") qui gen `g'=1/(_pi*(`XB'^2+1)) if (`touse')
	if("`link'"=="logit") qui gen `g'=exp(`XB')/((1+exp(`XB'))^2) if (`touse')
	if("`link'"=="probit") qui gen `g'=normalden(`XB') if (`touse')
	if("`link'"=="loglog") qui gen `g'=exp(-`XB')*exp(-exp(-`XB')) if (`touse')
	if("`link'"=="cloglog") qui gen `g'=exp(`XB')*exp(-exp(`XB')) if (`touse')

	if("`lm'"!="") {
		tempvar w uw gw gwx ones

		qui gen `w'=sqrt(`G'*(1-`G')) if (`touse')
		qui replace `w'=1e-10 if `w'<1e-10 

		if("`model'"=="1P" | "`model'"=="2Pfrac") qui gen `uw'=(`yobs'-`G')/`w' if (`touse')
		if("`model'"=="2Pbin") qui gen `uw'=(`ybin'-`G')/`w' if (`touse')

		qui gen `gw'=`g'/`w' if (`touse')
		local gwx `gw'

		foreach var of varlist `_rhs' {
			tempvar XXX`var'
			qui gen `XXX`var''=`var'*`g'/`w' if (`touse')

			local gwx `gwx' `XXX`var''
		}

		if("`model'"=="1P" | "`model'"=="2Pfrac") qui gen `ones'=1 if (`touse')
	}

* Tests - each version

	forvalues i=1/3 {
		if(`i'==3 | (`i'==1  & "`link'"!="loglog") | (`i'==2 & "`link'"!="cloglog")) {

			tempvar z1 z2 df

			if(`i'==1) local test GOFF1
			if(`i'==2) local test GOFF2
			if(`i'==3) local test GGOFF

			if(`i'==1 | `i'==2 | (`i'==3 & ("`link'"=="loglog" | "`link'"=="cloglog"))) local df=1
			else local df=2

			if(`i'==1 | `i'==3) qui gen `z1'=`G'*log(`G')/`g' if (`touse')
			if(`i'==2 | `i'==3) qui gen `z2'=(1-`G')*log(1-`G')/`g' if (`touse')

			if("`wald'"!="" | "`lr'"!="") {
				if(`i'==1) local wlrvars `z1'
				if(`i'==2) local wlrvars `z2'
				if(`i'==3) {
					if("`link'"!="loglog" & "`link'"!="cloglog") local wlrvars `z1' `z2'
					if("`link'"=="loglog") local wlrvars `z2'
					if("`link'"=="cloglog") local wlrvars `z1'
				}

      			if("`link'"=="cauchit") local link "frm_cauchit"

				if("`model'"=="1P") qui frm `yobs' `_rhs' `wlrvars' if (`touse'), 			///
					model(`model') linkfrac(`linkfrac') vcefrac(`vce')					///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
            			tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'
				if("`model'"=="2Pfrac") qui frm `yobs' `_rhs' `wlrvars' if (`touse'), 			///
					model(`model') linkfrac(`linkfrac') vcefrac(`vce') inflation(`inflation')	///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
            			tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'
				if("`model'"=="2Pbin") qui frm `ybin' `_rhs' `wlrvars' if (`touse'), 			///
					model(`model') linkbin(`linkbin') vcebin(`vce') inflation(`inflation')	///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
            			tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'

      			if("`link'"=="frm_cauchit") local link "cauchit"

				if(e(converged)==1 | "`irls'"!="") {
					if("`wald'"!="") {
						qui test `wlrvars'
						di in text %10s "`test' (Wald)" _col(14) "{c |}" as result %10.3f r(chi2) _col(27) %8.4f r(p)
						return scalar `test'_W=r(chi2)
						return scalar `test'_Wp=r(p)
					}
					if("`lr'"!="") {

						scalar LR=2*(e(ll)-`LLh0')
						scalar LRp=chi2tail(`df',LR)
						di in text %10s "`test' (LR)" _col(14) "{c |}" as result %10.3f LR _col(27) %8.4f LRp
						return scalar `test'_LR=LR
						return scalar `test'_LRp=LRp
					}
				}
				else {
					if("`wald'"!="") di in text %10s "`test' (Wald)" _col(14) "{c |}" _col(23) as result "na" _col(33) %8.4f "na"
					if("`lr'"!="") di in text %10s "`test' (LR)" _col(14) "{c |}" _col(23) as result "na" _col(33) %8.4f "na"
				}
			}

			if("`lm'"!="") {
				tempvar gwz gwz1 gwz2 r1 uwr1 r2 uwr2

				if(`i'==1 | `i'==3) qui gen `gwz1'=`g'*`z1'/`w' if (`touse')
				if(`i'==2 | `i'==3) qui gen `gwz2'=`g'*`z2'/`w' if (`touse')

				if("`model'"=="2Pbin") {
					if(`i'==1) local gwz `gwz1'
					if(`i'==2) local gwz `gwz2'
					if(`i'==3) {
						if("`link'"!="loglog" & "`link'"!="cloglog") local gwz `gwz1' `gwz2'
						if("`link'"=="loglog") local gwz `gwz2'
						if("`link'"=="cloglog") local gwz `gwz1'
					}

					local lmvars `gwz'

					qui regress `uw' `gwx' `lmvars' if (`touse'), nocons
					scalar LM=e(mss)
				}

				if("`model'"=="1P" | "`model'"=="2Pfrac") {
					if(`i'==1 | (`i'==3 & "`link'"!="loglog")) {
						qui regress `gwz1' `gwx' if (`touse'), nocons
						qui predict `r1' if (`touse'), resid
						qui gen `uwr1'=`r1'*`uw' if (`touse')

						local lmvars `uwr1'
					}
					if(`i'==2 | (`i'==3 & "`link'"!="cloglog")) {
						qui regress `gwz2' `gwx' if (`touse'), nocons
						qui predict `r2' if (`touse'), resid
						qui gen `uwr2'=`r2'*`uw' if (`touse')

						if(`i'==2) local lmvars `uwr2'
						if(`i'==3) local lmvars `lmvars' `uwr2'
					}

					qui regress `ones' `lmvars' if (`touse'), nocons
					scalar LM=e(N)-e(rss)
				}

				scalar LMp=chi2tail(`df',LM)
				di in text %10s "`test' (LM)" _col(14) "{c |}" as result %10.3f LM _col(27) %8.4f LMp

				return scalar `test'_LM=LM
				return scalar `test'_LMp=LMp
			}
		}
		*else {
		*	if(`i'==1 | `i'==2) di in text %10s "`test'" _col(14) "{c |}" _col(23) as result "na" _col(33) %8.4f "na"
		*	if(`i'==3) di in text %10s "`test'" _col(14) "{c |}" _col(23) as result "na" _col(33) %8.4f "na"
		*}
	}

	di in text "{hline 13}{c BT}{hline 21}"

* Managing memory

	if(`nmod'==0) qui estimates restore keepresults
	if(`nmod'==1) qui estimates restore `anything'
	scalar drop _all

end
