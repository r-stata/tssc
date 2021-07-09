*! Version 1.1.2 - 27 May 2014
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm_reset, rclass
	if(c(stata_version) >= 12.1) version 12.1
	else version 11.0

      syntax [anything] [, Lastpower(integer 3) Wald lm lr					///
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

	if(`lastpower'<2) {
		display as error "Lastpower cannot be lower than 2"
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

	tempvar ybin XB touse

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

	di in text "{hline 11}{c TT}{hline 21}"
	di in text %10s "Version" _col(12) "{c |} Statistic   p-value" 
	di in text "{hline 11}{c +}{hline 21}"

	qui predict `XB' if (`touse'), xb

	if("`lm'"!="") {
		if("`model'"=="1P" | "`model'"=="2Pfrac") local link `linkfrac'
		if("`model'"=="2Pbin") local link `linkbin'

		tempvar G g w uw gw gwx ones

		qui predict `G' if (`touse')

		if("`link'"=="cauchit") qui gen `g'=1/(_pi*(`XB'^2+1)) if (`touse')
		if("`link'"=="logit") qui gen `g'=exp(`XB')/((1+exp(`XB'))^2) if (`touse')
		if("`link'"=="probit") qui gen `g'=normalden(`XB') if (`touse')
		if("`link'"=="loglog") qui gen `g'=exp(-`XB')*exp(-exp(-`XB')) if (`touse')
		if("`link'"=="cloglog") qui gen `g'=exp(`XB')*exp(-exp(`XB')) if (`touse')

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

	forvalues i=2/`lastpower' {
		tempvar XB`i'
		qui gen `XB`i''=`XB'^`i' if (`touse')

		if("`wald'"!="" | "`lr'"!="") {
			if(`i'==2) local resetvars `XB`i''
			if(`i'!=2) local resetvars `resetvars' `XB`i''

       		if("`linkbin'"=="cauchit") local linkbin "frm_cauchit"
       		if("`linkfrac'"=="cauchit") local linkfrac "frm_cauchit"

			if("`model'"=="1P") qui frm `yobs' `_rhs' `resetvars' if (`touse'), 				///
					model(`model') linkfrac(`linkfrac') vcefrac(`vce')					///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
      	      		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'
			if("`model'"=="2Pfrac") qui frm `yobs' `_rhs' `resetvars' if (`touse'), 			///
					model(`model') linkfrac(`linkfrac') vcefrac(`vce') inflation(`inflation')	///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
      	      		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'
			if("`model'"=="2Pbin") qui frm `ybin' `_rhs' `resetvars' if (`touse'), 			  	///
					model(`model') linkbin(`linkbin') vcebin(`vce') inflation(`inflation')		///
					`difficult' technique(`technique') iterate (`iterate') from(`from')		///          
      	      		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')	///
					`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'		///
					`ml' `irls' fisher(`fisher') `search'

      		if("`link'"=="frm_cauchit") local link "cauchit"

			if(e(converged)==1 | "`irls'"!="") {
				if("`wald'"!="") {
					qui test `resetvars'
					di in text %10s "Wald (`i')" _col(12) "{c |}" as result %10.3f r(chi2) _col(25) %8.4f r(p)
					return scalar W`i'=r(chi2)
					return scalar W`i'p=r(p)
				}
				if("`lr'"!="") {
					scalar LR=2*(e(ll)-`LLh0')
					scalar LRp=chi2tail(`i'-1,LR)
					di in text %10s "LR (`i')" _col(12) "{c |}" as result %10.3f LR _col(25) %8.4f LRp
					return scalar LR`i'=LR
					return scalar LR`i'p=LRp
				}
			}
			else {
				if("`wald'"!="") di in text %10s "Wald (`i')" _col(12) "{c |}" _col(21) as result "na" _col(31) %8.4f "na"
				if("`lr'"!="") di in text %10s "LR (`i')" _col(12) "{c |}" _col(21) as result "na" _col(31) %8.4f "na"
			}
		}

		if("`lm'"!="") {
			tempvar gwz r uwr

			qui gen `gwz'=`g'*`XB`i''/`w' if (`touse')

			if("`model'"=="2Pbin") {
				if(`i'==2) local lmvars `gwz'
				if(`i'!=2) local lmvars `lmvars' `gwz'

				qui regress `uw' `gwx' `lmvars' if (`touse'), nocons
				scalar LM=e(mss)
			}

			if("`model'"=="1P" | "`model'"=="2Pfrac") {
				qui regress `gwz' `gwx' if (`touse'), nocons
				qui predict `r' if (`touse'), resid
				qui gen `uwr'=`r'*`uw' if (`touse')

				if(`i'==2) local lmvars `uwr'
				if(`i'!=2) local lmvars `lmvars' `uwr'

				qui regress `ones' `lmvars' if (`touse'), nocons
				scalar LM=e(N)-e(rss)
			}

			scalar LMp=chi2tail(`i'-1,LM)
			di in text %10s "LM (`i')" _col(12) "{c |}" as result %10.3f LM _col(25) %8.4f LMp
			return scalar LM`i'=LM
			return scalar LM`i'p=LMp
		}
	}

	di in text "{hline 11}{c BT}{hline 21}"

* Managing memory

	if(`nmod'==0) qui estimates restore keepresults
	if(`nmod'==1) qui estimates restore `anything'
	scalar drop _all

end
