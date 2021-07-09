*! Version 1.1.0 - 19 Feb 2013
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm_pe, rclass
	if(c(stata_version) >= 12.1) version 12.1
	else version 11.0

      syntax [anything] [, ape(varlist) cpe(varlist) at(string)]

* Preliminaries (defaults, variables, sample and possible errors)

	local nmod: word count `anything'

	if(`nmod'>2) {
            display as error "Models with more than two components are not allowed"
            exit 198
      }

      if("`ape'"=="" & "`cpe'"=="") {
		display as error "You must specify one option: ape or cpe"
		exit 198
	}
      if("`ape'"!="" & "`cpe'"!="") {
		display as error "You can specify only one option"
		exit 198
	}

	if("`at'"!="") {
		tokenize `at', parse(" =")
		local atvarvals `*'
		local length: word count `atvarvals'

		forvalues i = 2(3)`length' {
			if("``i''"!="="){
				di as error "option at is not well specified"
				exit 198
			}
		}

		forvalues i = 1(3)`length' {
			local atvars "`atvars' ``i''"
		}
		forvalues i = 3(3)`length' {
			local atvals "`atvals' ``i''"
		}

		local length1: word count `atvars'
		local length2: word count `atvals'
		if(`length1'!=`length2'){
			di as error "option at is not well specified"
			exit 198
		}
	}

      tempvar touse Ga Gb XBa XBb g

* One-part models

	if(`nmod'==0 | `nmod'==1) {
		if(`nmod'==1) {
			est_expand `"`anything'"'
			local name1: word 1 of `r(names)'
			qui estimates restore `name1'
		}

		if("`e(cmd)'"!="frm") {
			di as error "results for frm not found"
			exit 301
		}

		local _rhs: colnames(e(b))
     		local cons "_cons"
      	local _rhs: list _rhs-cons

            if("`ape'"!="") {
			local rest: list ape-_rhs
			if("`rest'"!="") {
				di as error "ape contains variables not found in list of covariates"
				exit 198
			}
		}
            if("`cpe'"!="") {
			local rest: list cpe-_rhs
			if("`rest'"!="") {
				di as error "cpe contains variables not found in list of covariates"
				exit 198
			}
		}
		if("`at'"!="") {
			local rest: list atvars-_rhs
			if("`rest'"!="") {
				di as error "at contains variables not found in list of covariates"
				exit 198
			}
		}

		qui gen byte `touse'=e(sample)
	      local model=e(model)
	      if("`model'"=="1P" | "`model'"=="2Pfrac") local linkfrac=e(linkfrac)
		if("`model'"=="2Pbin") local linkbin=e(linkbin)
	      if("`model'"=="2Pbin" | "`model'"=="2Pfrac") local inflation=e(inflation)

	      if("`model'"=="1P") {
			display _newline(1) "*** Fractional `linkfrac' regression model ***"
			display _newline(1) "*** Partial effects - dE(Y|X) ***" _newline(1)
		}
            if("`model'"=="2Pbin") {
			display _newline(1) "*** Binary component of two-part model - `linkbin ***' specification ***"
			if(`inflation'==0) display _newline(1) "*** Partial effects - dP(Y>0|X) ***" _newline(1)
			if(`inflation'==1) display _newline(1) "*** Partial effects - dP(Y=1|X) ***" _newline(1)
		}
            if("`model'"=="2Pfrac") {
			display _newline(1) "*** Fractional component of two-part model - `linkfrac' specification ***"
			display _newline(1) "*** Partial effects - dE(Y|X,Y>0) ***" _newline(1)
		}

		if("`ape'"!="" & "`at'"=="") margins if (`touse'), dydx(`ape')
		if("`ape'"!="" & "`at'"!="") margins if (`touse'), dydx(`ape') at(`at')
		if("`cpe'"!="" & "`at'"=="") margins if (`touse'), dydx(`cpe') atmeans
		if("`cpe'"!="" & "`at'"!="") margins if (`touse'), dydx(`cpe') atmeans at(`at')
	}

* Two-part models

	if(`nmod'==2) {
		est_expand `"`anything'"'
		local name1: word 1 of `r(names)'
		local name2: word 2 of `r(names)'
		if("`name1'"=="`name2'") {
			display as error "The two models need to be different"
			exit 198
   		}

		* Component A of two-part model

		qui estimates restore `name1'

		if("`e(cmd)'"!="frm") {
			di as error "results for frm not found"
			exit 301
		}

		local linka=e(linkbin)

		local modela=e(model)
		if("`modela'"!="2Pbin") {
			di as error "`name1' is not a binary component of a two-part model"
			exit 198
		}

		local yobsa=e(depvar)
		local _rhsa: colnames(e(b))
     		local cons "_cons"
      	local _rhsa: list _rhsa-cons

		qui gen byte `touse'=e(sample)

		foreach var of varlist `_rhsa' {
			scalar b`var'a=_coef[`var']
		}
		scalar b0a=_coef[_cons]

            if("`ape'"!="") {
            	if("`at'"=="") {
           			qui predict `Ga' if (`touse')
				qui predict `XBa' if (`touse'), xb
			}

			if("`at'"!="") {
				local i=1
				qui gen `XBa'=b0a if (`touse')

				foreach var of local atvars {
					local valid: list var in _rhsa
					if(`valid'!=0) {
						local atval: word `i' of `atvals'
						qui replace `XBa'=`XBa'+b`var'a*`atval' if (`touse')
					}
					local `++i'
				}

				local _rhsnoat: list _rhsa-atvars
				foreach var of local _rhsnoat {
					qui replace `XBa'=`XBa'+b`var'a*`var' if (`touse')
				}

				if("`linka'"=="cauchit") qui gen `Ga'=0.5+(1/_pi)*atan(`XBa') if (`touse')
				if("`linka'"=="logit") qui gen `Ga'=exp(`XBa')/(1+exp(`XBa')) if (`touse')
				if("`linka'"=="probit") qui gen `Ga'=normal(`XBa') if (`touse')
				if("`linka'"=="loglog") qui gen `Ga'=exp(exp(-`XBa')) if (`touse')
				if("`linka'"=="cloglog") qui gen `Ga'=1-exp(-exp(`XBa')) if (`touse')
			}

			if("`linka'"=="cauchit") qui gen `g'=`g'=1/(_pi*(`XBa'^2+1)) if (`touse')
			if("`linka'"=="logit") qui gen `g'=exp(`XBa')/((1+exp(`XBa'))^2) if (`touse')
			if("`linka'"=="probit") qui gen `g'=normalden(`XBa') if (`touse')
			if("`linka'"=="loglog") qui gen `g'=exp(-`XBa')*exp(-exp(-`XBa')) if (`touse')
			if("`linka'"=="cloglog") qui gen `g'=exp(`XBa')*exp(-exp(`XBa')) if (`touse')

			foreach var of varlist `ape' {
				tempvar bg`var'a
				local valid: list var in _rhsa
				if(`valid' == 0) qui gen `bg`var'a'=0 if (`touse')
				else qui gen `bg`var'a'=b`var'a*`g' if (`touse')
			}
		}

            if("`cpe'"!="") {
			scalar XBm=b0a

         		if("`at'"=="") {
				foreach var of varlist `_rhsa' {
					qui sum `var' if (`touse'), meanonly
					scalar `var'm=r(mean)
					scalar XBm=XBm+b`var'a*`var'm
				}
			}

			if("`at'"!="") {
				local i=1
				scalar XBm=b0a

				foreach var of local atvars {
					local valid: list var in _rhsa
					if(`valid'!=0) {
						local atval: word `i' of `atvals'
						scalar XBm=XBm+b`var'a*`atval'
					}
					local `++i'
				}

				local _rhsnoat: list _rhsa-atvars
				foreach var of local _rhsnoat {
					qui sum `var' if (`touse'), meanonly
					scalar `var'm=r(mean)
					scalar XBm=XBm+b`var'a*`var'm
				}
			}

			if("`linka'"=="cauchit") {
				scalar Ga=0.5+(1/_pi)*atan(XBm)
				scalar g=`g'=1/(_pi*(XBm^2+1))
			}
			if("`linka'"=="logit") {
				scalar Ga=exp(XBm)/(1+exp(XBm))
				scalar g=exp(XBm)/((1+exp(XBm))^2)
			}
			if("`linka'"=="probit") {
				scalar Ga=normal(XBm)
				scalar g=normalden(XBm)
			}
			if("`linka'"=="loglog") {
				scalar Ga=exp(-exp(-XBm))
				scalar g=exp(-XBm)*exp(-exp(-XBm))
			}
			if("`linka'"=="cloglog") {
				scalar Ga=1-exp(-exp(XBm))
				scalar g=exp(XBm)*exp(-exp(XBm))
			}

			foreach var of varlist `cpe' {
				local valid: list var in _rhsa
				if(`valid' == 0) scalar bg`var'a=0
				else scalar bg`var'a=b`var'a*g 
			}
		}

		* Component B of two-part model

		qui estimates restore `name2'

		if("`e(cmd)'"!="frm") {
			di as error "results for frm not found"
			exit 301
		}

		local modelb=e(model)
		if("`modelb'"!="2Pfrac") {
			di as error "`name2' is a not a fractional component of a two-part model"
			exit 198
		}

		local yobsb=e(depvar)
		if("`yobsa'"!="`yobsb'") {
			di as error "The dependent variable is not the same in both components of the two-part model"
			exit 198
		}

		local _rhsb: colnames(e(b))
     		local cons "_cons"
      	local _rhsb: list _rhsb-cons

            if("`ape'"!="") {
			local rest: list ape-_rhsa
			local rest: list rest-_rhsb
			if("`rest'"!="") {
				di as error "ape contains variables not found in list of covariates"
				exit 198
			}
		}
            if("`cpe'"!="") {
			local rest: list cpe-_rhsa
			local rest: list rest-_rhsb
			if("`rest'"!="") {
				di as error "cpe contains variables not found in list of covariates"
				exit 198
			}
		}
		if("`at'"!="") {
			local rest: list atvars-_rhsa
			local rest: list rest-_rhsb
			if("`rest'"!="") {
				di as error "at contains variables not found in list of covariates"
				exit 198
			}
		}
		local linkb=e(linkfrac)

		foreach var of varlist `_rhsb' {
			scalar b`var'b=_coef[`var']
		}
		scalar b0b=_coef[_cons]

            if("`ape'"!="") {
            	if("`at'"=="") {
           			qui predict `Gb' if (`touse')
				qui predict `XBb' if (`touse'), xb
			}

			if("`at'"!="") {
				local i=1
				qui gen `XBb'=b0b if (`touse')

				foreach var of local atvars {
					local valid: list var in _rhsb
					if(`valid'!=0) {
						local atval: word `i' of `atvals'
						qui replace `XBb'=`XBb'+b`var'b*`atval' if (`touse')
					}
					local `++i'
				}

				local _rhsnoat: list _rhsb-atvars
				foreach var of local _rhsnoat {
					qui replace `XBb'=`XBb'+b`var'b*`var' if (`touse')
				}

				if("`linkb'"=="cauchit") qui gen `Gb'=0.5+(1/_pi)*atan(`XBb') if (`touse')
				if("`linkb'"=="logit") qui gen `Gb'=exp(`XBb')/(1+exp(`XBb')) if (`touse')
				if("`linkb'"=="probit") qui gen `Gb'=normal(`XBb') if (`touse')
				if("`linkb'"=="loglog") qui gen `Gb'=exp(exp(-`XBb')) if (`touse')
				if("`linkb'"=="cloglog") qui gen `Gb'=1-exp(-exp(`XBb')) if (`touse')
			}

			if("`linkb'"=="cauchit") qui replace `g'=`g'=1/(_pi*(`XBb'^2+1)) if (`touse')
			if("`linkb'"=="logit") qui replace `g'=exp(`XBb')/((1+exp(`XBb'))^2) if (`touse')
			if("`linkb'"=="probit") qui replace `g'=normalden(`XBb') if (`touse')
			if("`linkb'"=="loglog") qui replace `g'=exp(-`XBb')*exp(-exp(-`XBb')) if (`touse')
			if("`linkb'"=="cloglog") qui replace `g'=exp(`XBb')*exp(-exp(`XBb')) if (`touse')

			foreach var of varlist `ape' {
				tempvar bg`var'b
				local valid: list var in _rhsb
				if(`valid' == 0) qui gen `bg`var'b'=0 if (`touse')
				else qui gen `bg`var'b'=b`var'b*`g' if (`touse')
			}
		}

            if("`cpe'"!="") {
 			scalar XBm=b0b

         		if("`at'"=="") {
				foreach var of varlist `_rhsb' {
					qui sum `var' if (`touse'), meanonly
					scalar `var'm=r(mean)
					scalar XBm=XBm+b`var'b*`var'm
				}
			}
			if("`at'"!="") {
				local i=1

				foreach var of local atvars {
					local valid: list var in _rhsb
					if(`valid'!=0) {
						local atval: word `i' of `atvals'
						scalar XBm=XBm+b`var'b*`atval'
					}
					local `++i'
				}

				local _rhsnoat: list _rhsb-atvars
				foreach var of local _rhsnoat {
					qui sum `var' if (`touse'), meanonly
					scalar `var'm=r(mean)
					scalar XBm=XBm+b`var'b*`var'm
				}
			}

			if("`linkb'"=="cauchit") {
				scalar Gb=0.5+(1/_pi)*atan(XBm)
				scalar g=`g'=1/(_pi*(XBm^2+1))
			}
			if("`linkb'"=="logit") {
				scalar Gb=exp(XBm)/(1+exp(XBm))
				scalar g=exp(XBm)/((1+exp(XBm))^2)
			}
			if("`linkb'"=="probit") {
				scalar Gb=normal(XBm)
				scalar g=normalden(XBm)
			}
			if("`linkb'"=="loglog") {
				scalar Gb=exp(-exp(-XBm))
				scalar g=exp(-XBm)*exp(-exp(-XBm))
			}
			if("`linkb'"=="cloglog") {
				scalar Gb=1-exp(-exp(XBm))
				scalar g=exp(XBm)*exp(-exp(XBm))
			}

			foreach var of varlist `cpe' {
				local valid: list var in _rhsb
				if(`valid' == 0) scalar bg`var'b=0
				else scalar bg`var'b=b`var'b*g 
			}
		}

		* Full two-part model

            display _newline(1) "*** Binary `linka' + Fractional `linkb' two-part model ***"
		if("`ape'"!="") display _newline(1) "*** Average partial effects - dE(Y|X) ***" _newline(1)
		if("`cpe'"!="") display _newline(1) "*** Conditional partial effects - dE(Y|X) ***" _newline(1)

		di in text "{hline 14}{c TT}{hline 14}"
		di in text %13s "Variable" _col(15) "{c |}    dy/dx" 
		di in text "{hline 14}{c +}{hline 14}"

		if("`ape'"!="") {
			foreach var of varlist `ape' {
				tempvar pe
				qui gen `pe'=`Ga'*`bg`var'b'+`Gb'*`bg`var'a' if (`touse')
				qui sum `pe' if (`touse'), meanonly
				scalar pem=r(mean)

				di in text %13s abbrev("`var'",12) _col(15) "{c |}" as result %13.6f pem
			}
		}

		if("`cpe'"!="") {
			foreach var of varlist `cpe' {
				scalar pem=Ga*bg`var'b+Gb*bg`var'a

				di in text %13s abbrev("`var'",12) _col(15) "{c |}" as result %13.6f pem
			}
		}

		di in text "{hline 14}{c BT}{hline 14}"
	}

* Clearing memory

	scalar drop _all
	ereturn clear
	if(`nmod'==2) return clear

end
