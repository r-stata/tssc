*! Version 1.1.2 - 27 May 2014
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm, eclass
	if(c(stata_version) >= 12.1) version 12.1
	else version 11.0

      syntax varlist(min=1 numeric) [if] [in] [, Model(string) LINKBin(string) LINKFrac(string) ///
		VCEBin(string) VCEFrac(string) INFlation(integer 0) y2P(string)				///
		DROPBin(varlist) DROPFrac(varlist)									///
		DIFficult TECHnique(string) ITERate(integer 5000) from(string)				///
		TOLerance(real 1e-6) LTOLerance(real 1e-7) NRTOLerance(real 1e-5)				///
		NONRTOLerance TRace GRADient showstep HESSian SHOWTOLerance					///
		ml irls fisher(integer 1) search]

* Preliminaries (defaults, variables, sample and possible errors)

      if("`model'"=="") local model "1P"

      if("`model'"!="1P" & "`model'"!="2Pbin" & "`model'"!="2Pfrac" & "`model'"!="2P") {
            display as error "Option `model' not allowed for model"
            exit 198
      }

      if(("`model'"=="1P" | "`model'"=="2Pfrac") & "`linkbin'"!="") {
            display as error "Option linkbin not allowed for fractional model"
            exit 198
      }
      if("`model'"=="2Pbin" & "`linkfrac'"!="") {
            display as error "Option linkfrac not allowed for binary model"
            exit 198
      }

      if(("`model'"=="1P" | "`model'"=="2Pfrac") & "`vcebin'"!="") {
            display as error "Option vcebin not allowed for fractional model"
            exit 198
      }
      if("`model'"=="2Pbin" & "`vcefrac'"!="") {
            display as error "Option vcefrac not allowed for binary model"
            exit 198
      }

      if("`model'"!="2P" & "`y2P'"!="") {
            display as error "Option y2P not allowed"
            exit 198
      }
	if("`model'"!="2P" & "`dropbin'"!="") {
            display as error "Option dropbin not allowed"
            exit 198
      }
	if("`model'"!="2P" & "`dropfrac'"!="") {
            display as error "Option dropfrac not allowed"
            exit 198
      }

      tempvar y _rhs ybin yhat yhatl yhat2Pbin yhat2Pfrac yobs touse2Pfrac tousef
      gettoken y _rhs: varlist

	qui count if (`y'<0 | `y'>1)
      if(r(N)!=0) {
		display as error "The dependent variable has values outside the unit interval"
	      exit 198
	}

      if("`model'"=="2Pbin" | "`model'"=="2Pfrac" | "`model'"=="2P") {
            if(`inflation'!=0 & `inflation'!=1) {
                   display as error "Option `inflation' not allowed for inflation"
                   exit 198
            }
		qui count if `y'==`inflation'
            if(r(N)==0) {
			display as error "The dependent variable has no `inflation' values"
	            exit 198
		}
      }

	if("`vcebin'"=="") local vcebin eim
	if("`vcefrac'"=="") local vcefrac robust

      marksample touse

* Estimation

	if("`model'"=="1P") {
      	if("`linkfrac'"=="") local linkfrac "logit"
      	if("`linkfrac'"=="cauchit") local linkfrac "frm_cauchit"

		display _newline(1) "*** Fractional `linkfrac' regression model ***"

		if("`irls'"!="") glm `y' `_rhs' if (`touse'), family(binomial) link(`linkfrac') vce(`vcefrac')				///
			iterate(`iterate') ltolerance(`ltolerance') `trace' `irls'
 		else {
	            if("`nonrtolerance'"=="") glm `y' `_rhs' if (`touse'), family(binomial) link(`linkfrac') vce(`vcefrac')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')						///          
            		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')					///
				`trace' `gradient' `showstep' `hessian' `showtolerance'								///
				`ml' fisher(`fisher') `search'
      	      if("`nonrtolerance'"!="") glm `y' `_rhs' if (`touse'), family(binomial) link(`linkfrac') vce(`vcefrac')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')						///          
            		tolerance(`tolerance') ltolerance(`ltolerance')										///
				`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'						///
				`ml' fisher(`fisher') `search'
		}
       	if("`linkfrac'"=="frm_cauchit") local linkfrac "cauchit"
      }

      if("`model'"=="2Pbin" | "`model'"=="2P") {
      	if("`linkbin'"=="") local linkbin "logit"
       	if("`linkbin'"=="cauchit") local linkbin "frm_cauchit"
            if(`inflation'==0) qui gen `ybin'=(`y'>0)
            if(`inflation'==1) qui gen `ybin'=(`y'==1)

		if("`model'"=="2P") local _rhsb: list _rhs-dropbin
		else local _rhsb `_rhs'

            display _newline(1) "*** Binary component of two-part model - `linkbin' specification ***"

		if("`irls'"!="") glm `ybin' `_rhsb' if (`touse'), family(binomial) link(`linkbin') vce(`vcebin')				///
			iterate(`iterate') ltolerance(`ltolerance') `trace' `irls'
 		else {
			if("`nonrtolerance'"=="") glm `ybin' `_rhsb' if (`touse'), family(binomial) link(`linkbin') vce(`vcebin')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')						///
            		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')					///
				`trace' `gradient' `showstep' `hessian' `showtolerance'								///
				`ml' fisher(`fisher') `search'
			if("`nonrtolerance'"!="") glm `ybin' `_rhsb' if (`touse'), family(binomial) link(`linkbin') vce(`vcebin')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')						///
            		tolerance(`tolerance') ltolerance(`ltolerance')										///
				`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'						///
				`ml' fisher(`fisher') `search'
 		}

		if("`model'"=="2P") qui predict `yhat2Pbin' if (`touse')

	     	if("`linkbin'"=="frm_cauchit") local linkbin "cauchit"
      }

      if("`model'"=="2Pfrac" | "`model'"=="2P") {
      	if("`linkfrac'"=="") local linkfrac "logit"
      	if("`linkfrac'"=="cauchit") local linkfrac "frm_cauchit"
            if(`inflation'==0) gen byte `touse2Pfrac'=(`y'>0)&(`touse')
            if(`inflation'==1) gen byte `touse2Pfrac'=(`y'<1)&(`touse')

		if("`model'"=="2P") local _rhsf: list _rhs-dropfrac
		else local _rhsf `_rhs'

            display _newline(1) "*** Fractional component of two-part model - `linkfrac' specification ***"

 		if("`irls'"!="") glm `y' `_rhsf' if (`touse2Pfrac'), family(binomial) link(`linkfrac') vce(`vcefrac')				///
			iterate(`iterate') ltolerance(`ltolerance') `trace' `irls'
 		else {
          	 	if("`nonrtolerance'"=="")  glm `y' `_rhsf' if (`touse2Pfrac'), family(binomial) link(`linkfrac') vce(`vcefrac')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')							///          
            		tolerance(`tolerance') ltolerance(`ltolerance') nrtolerance(`nrtolerance')						///
				`trace' `gradient' `showstep' `hessian' `showtolerance'									///
				`ml' fisher(`fisher') `search'
      	      if("`nonrtolerance'"!="")  glm `y' `_rhsf' if (`touse2Pfrac'), family(binomial) link(`linkfrac') vce(`vcefrac')	///
				`difficult' technique(`technique') iterate(`iterate') from(`from')							///          
            		tolerance(`tolerance') ltolerance(`ltolerance')											///
				`nonrtolerance' `trace' `gradient' `showstep' `hessian' `showtolerance'							///
				`ml' fisher(`fisher') `search'
		}

		if("`model'"=="2P") qui predict `yhat2Pfrac' if (`touse')

       	if("`linkfrac'"=="frm_cauchit") local linkfrac "cauchit"
      }

* R-squared

	if("`model'"=="2Pfrac") gen byte `tousef'=`touse2Pfrac'
	else gen byte `tousef'=`touse'

      if("`model'"=="2P") {
		qui gen `yhat'=`yhat2Pbin'*`yhat2Pfrac'
      	if("`y2P'"!="") {
			gen `y2P'=`yhat'
			label var `y2P' "Fitted values"
		}
	}
	else qui predict `yhat' if (`tousef')

	if("`model'"=="2Pbin") qui gen `yobs'=`ybin'
	else qui gen `yobs'=`y'

      qui cor `yobs' `yhat' if (`tousef')
      qui scalar R2=r(rho)^2

      if("`model'"=="2P") display _newline(1) "*** Two-part model - binary `linkbin' + fractional `linkfrac' ***"
      display _newline(1) "R2-type measure: " R2

* Storing estimates

	ereturn local cmd "frm"
	ereturn local cmdline "frm `0'"
	ereturn local model "`model'"
	if("`model'"=="1P" | "`model'"=="2Pfrac") ereturn local linkfrac "`linkfrac'"
	if("`model'"=="2Pbin") ereturn local linkbin "`linkbin'"
	if("`model'"=="2Pbin") ereturn local depvar "`y'"
	if("`model'"=="2Pbin" | "`model'"=="2Pfrac") ereturn scalar inflation=`inflation'
      ereturn scalar R2=R2

* Clearing memory

	scalar drop _all
	if("`model'"=="2P") ereturn clear

end
