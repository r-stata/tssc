*! Version 1.1.2 - 27 May 2014
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm_ptest, rclass
	if(c(stata_version) >= 12.1) version 12.1
	else version 11.0

      syntax, mod1(string) mod2(string) [Wald lm]

* Preliminaries (defaults, variables, sample and possible errors)

	if("`mod1'"=="" | "`mod2'"=="") {
            display as error "Two models must be specified"
            exit 198
      }

	local nmod1: word count `mod1'
	local nmod2: word count `mod2'

	if(`nmod1'>2 | `nmod2'>2) {
            display as error "Each model can only have one or two parts"
            exit 198
      }
	if(`nmod1'==1 & `nmod2'==1 & "`mod1'"=="`mod2'") {
            display as error "The two models are identical"
            exit 198
      }

	if(`nmod1'==2) {
		est_expand `"`mod1'"'
		local name1a: word 1 of `r(names)'
		local name1b: word 2 of `r(names)'
		if("`name1a'"=="`name1b'") {
			display as error "The two components in mod1 are identical"
			exit 198
   		}
	}
	if(`nmod2'==2) {
		est_expand `"`mod2'"'
		local name2a: word 1 of `r(names)'
		local name2b: word 2 of `r(names)'
		if("`name2a'"=="`name2b'") {
			display as error "The two components in mod2 are identical"
			exit 198
   		}
	}
	if(`nmod1'==2 & `nmod2'==2 & (("`name1a'"=="`name2a'" & "`name1b'"=="`name2b'") | ("`name1a'"=="`name2b'" & "`name1b'"=="`name2a'"))) {
            display as error "The two models are identical"
            exit 198
      }

	if("`wald'"=="" & "`lm'"=="") local wald "wald"

	tempvar G1 G2 gx1 gx2 yt1 yt2 ones touse

* Models

	forvalues i=1/2 {
		tempvar ybin XB XBa XBb Ga Gb g ga gb gab gba

		if(`nmod`i''==1) {
			qui estimates restore `mod`i''

			if("`e(cmd)'"!="frm") {
				di as error "results for frm not found"
				exit 301
			}

			local model`i'=e(model)

			local yobs`i'=e(depvar)
			local _rhs`i': colnames(e(b))
     			local cons "_cons"
      		local _rhs`i': list _rhs`i'-cons

    			if(`i'==1) qui gen byte `touse'=e(sample)
			scalar N`i'=e(N)

			if("`model`i''"=="1P" | "`model`i''"=="2Pfrac") local link`i'=e(linkfrac)
			if("`model`i''"=="2Pbin") {
				local link`i'=e(linkbin)
				local inflation`i'=e(inflation)
				if(`inflation`i''==0) qui gen `ybin'=(`yobs`i''>0) if (`touse')
				if(`inflation`i''==1) qui gen `ybin'=(`yobs`i''==1) if (`touse')
			}

			qui predict `G`i'' if (`touse')
			qui predict `XB' if (`touse'), xb

			if("`link`i''"=="cauchit") qui gen `g'=1/(_pi*(`XB'^2+1)) if (`touse')
			if("`link`i''"=="logit") qui gen `g'=exp(`XB')/((1+exp(`XB'))^2) if (`touse')
			if("`link`i''"=="probit") qui gen `g'=normalden(`XB') if (`touse')
			if("`link`i''"=="loglog") qui gen `g'=exp(-`XB')*exp(-exp(-`XB')) if (`touse')
			if("`link`i''"=="cloglog") qui gen `g'=exp(`XB')*exp(-exp(`XB')) if (`touse')

			if("`model`i''"=="2Pbin") qui gen `yt`i''=`ybin'-`G`i'' if (`touse')
			else qui gen `yt`i''=`yobs`i''-`G`i'' if (`touse')

			local gx`i' `g'
			foreach var of varlist `_rhs`i'' {
				tempvar XXX`var'
				qui gen `XXX`var''=`var'*`g' if (`touse')
				local gx`i' `gx`i'' `XXX`var''
				}

			if("`model`i''"=="1P") local alt`i' "Fractional `link`i'' model (`mod`i'' model)"
			if("`model`i''"=="2Pbin") local alt`i' "Binary `link`i'' (`mod`i'' model) component of a two-part model"
			if("`model`i''"=="2Pfrac") local alt`i' "Fractional `link`i'' (`mod`i'' model) component of a two-part model"
		}
		if(`nmod`i''==2) {
			* Sample

			if(`i'==1) {
				local tname1a `name1a'
				qui estimates restore `tname1a'
				if("`e(cmd)'"!="frm") {
					di as error "results for frm not found"
					exit 301
				}
				local modela=e(model)
    				if("`modela'"=="2Pbin") qui gen byte `touse'=e(sample)

				local tname1b `name1b'
				qui estimates restore `tname1b'
				if("`e(cmd)'"!="frm") {
					di as error "results for frm not found"
					exit 301
				}
				local modelb=e(model)
				if("`modela'"=="`modelb'") {
					di as error "The two-part model in mod1 has two binary components or two fractional components"
					exit 198
				}
    				if("`modelb'"=="2Pbin") qui gen byte `touse'=e(sample)
			}

			* Component A of two-part model

			local tname`i'a `name`i'a'
			qui estimates restore `tname`i'a'

			if("`e(cmd)'"!="frm") {
				di as error "results for frm not found"
				exit 301
			}

			local model`i'a=e(model)
			if("`model`i'a'"=="1P") {
				di as error "One-part model not allowed in mod`i'"
				exit 198
			}

			local yobsa=e(depvar)
			local _rhs`i'a: colnames(e(b))
     			local cons "_cons"
      		local _rhs`i'a: list _rhs`i'a-cons

			if("`model`i'a'"=="2Pfrac") local link`i'a=e(linkfrac)
			if("`model`i'a'"=="2Pbin") {
				local link`i'a=e(linkbin)
				local inflation`i'=e(inflation)
			}

			if("`model`i'a'"=="2Pbin") scalar N`i'=e(N)

			qui predict `Ga' if (`touse')
			qui predict `XBa' if (`touse'), xb

			if("`link`i'a'"=="cauchit") qui gen `ga'=1/(_pi*(`XBa'^2+1)) if (`touse')
			if("`link`i'a'"=="logit") qui gen `ga'=exp(`XBa')/((1+exp(`XBa'))^2) if (`touse')
			if("`link`i'a'"=="probit") qui gen `ga'=normalden(`XBa') if (`touse')
			if("`link`i'a'"=="loglog") qui gen `ga'=exp(-`XBa')*exp(-exp(-`XBa')) if (`touse')
			if("`link`i'a'"=="cloglog") qui gen `ga'=exp(`XBa')*exp(-exp(`XBa')) if (`touse')

			* Component B of two-part model

			local tname`i'b `name`i'b'
			qui estimates restore `tname`i'b'
			if("`e(cmd)'"!="frm") {
				di as error "results for frm not found"
				exit 301
			}

			local model`i'b=e(model)
			if("`model`i'b'"=="1P") {
				di as error "One-part model not allowed in mod`i'"
				exit 198
			}
			if("`model`i'a'"=="`model`i'b'") {
				di as error "The two-part model in mod`i' has two binary components or two fractional components"
				exit 198
			}

			local yobsb=e(depvar)
			if("`yobsa'"!="`yobsb'") {
				di as error "The dependent variable is not the same in both components of mod`i'"
				exit 198
			}
			else local yobs`i' `yobsa'

			local _rhs`i'b: colnames(e(b))
     			local cons "_cons"
      		local _rhs`i'b: list _rhs`i'b-cons

			if("`model`i'b'"=="2Pfrac") local link`i'b=e(linkfrac)
			if("`model`i'b'"=="2Pbin") {
				local link`i'b=e(linkbin)
				local inflation`i'=e(inflation)
			}

			if("`model`i'b'"=="2Pbin") scalar N`i'=e(N)

			qui predict `Gb' if (`touse')
			qui predict `XBb' if (`touse'), xb

			if("`link`i'b'"=="cauchit") qui gen `gb'=1/(_pi*(`XBb'^2+1)) if (`touse')
			if("`link`i'b'"=="logit") qui gen `gb'=exp(`XBb')/((1+exp(`XBb'))^2) if (`touse')
			if("`link`i'b'"=="probit") qui gen `gb'=normalden(`XBb') if (`touse')
			if("`link`i'b'"=="loglog") qui gen `gb'=exp(-`XBb')*exp(-exp(-`XBb')) if (`touse')
			if("`link`i'b'"=="cloglog") qui gen `gb'=exp(`XBb')*exp(-exp(`XBb')) if (`touse')

			* Two-part model

			qui gen `G`i''=`Ga'*`Gb' if (`touse')
			qui gen `gab'=`ga'*`Gb' if (`touse')
			qui gen `gba'=`gb'*`Ga' if (`touse')

			qui gen `yt`i''=`yobs`i''-`G`i'' if (`touse')

			local gx`i' `gab'
			foreach var of varlist `_rhs`i'a' {
				tempvar XXX`var'
				qui gen `XXX`var''=`var'*`gab' if (`touse')
				local gx`i' `gx`i'' `XXX`var''
				}

			local gx`i' `gx`i'' `gba'
			foreach var of varlist `_rhs`i'b' {
				tempvar XXX`var'
				qui gen `XXX`var''=`var'*`gba' if (`touse')
				local gx`i' `gx`i'' `XXX`var''
				}

			if("`model`i'a'"=="2Pbin") local alt`i' "Binary `link`i'a' (model `name`i'a') + Fractional `link`i'b' (model `name`i'b') two-part model"
			else local alt`i' "Binary `link`i'b' (model `name`i'b') + Fractional `link`i'a' (model `name`i'a') two-part model"
		}
	}

* Other possible errors

	if(`nmod1'==1 & `nmod2'==1) {
		if("`model1'"!="`model2'") {
			di as error "Models mod1 and mod2 cannot be compared"
			exit 198
		}

		if("`link1'"=="`link2'") {
			local nested1: list _rhs1-_rhs2
			local nested2: list _rhs2-_rhs1
			if("`nested1'"=="" & "`nested2'"!="") {
				di as error "mod1 is nested in mod2 - use frm_reset (RESET test) or frm_ggoff (GGOFF tests) instead"
				exit 198
			}
			if("`nested1'"!="" & "`nested2'"=="") {
				di as error "mod2 is nested in mod1 - use frm_reset (RESET test) or frm_ggoff (GGOFF tests) instead"
				exit 198
			}
			if("`nested1'"=="" & "`nested2'"=="") {
				di as error "The two models are identical"
				exit 198
			}
		}
	}
	if((`nmod1'==2 & `nmod2'==1 & "`model2'"!="1P") | (`nmod1'==1 & `nmod2'==2 & "`model1'"!="1P")) {
		di as error "Models mod1 and mod2 cannot be compared"
		exit 198
	}
	if(`nmod1'==2 & `nmod2'==2) {
		if("`model1a'"=="`model2a'" & "`link1a'"=="`link2a'"  & "`link1b'"=="`link2b'") {
			local nested1: list _rhs1a-_rhs2a
			local nested2: list _rhs2a-_rhs1a
			local nested3: list _rhs1b-_rhs2b
			local nested4: list _rhs2b-_rhs1b
			if("`nested1'"=="" & "`nested3'"=="" & ("`nested2'"!="" | "`nested4'"!="")) {
				di as error "mod1 is nested in mod2 - use instead frm_reset (RESET test) or frm_ggoff (GGOFF tests) for the relevant(s) component(s) of the two-part model"
				exit 198
			}
			if("`nested2'"=="" & "`nested4'"=="" & ("`nested1'"!="" | "`nested3'"!="")) {
				di as error "mod2 is nested in mod1 - use instead frm_reset (RESET test) or frm_ggoff (GGOFF tests) for the relevant(s) component(s) of the two-part model"
				exit 198
			}
			if("`nested1'"=="" & "`nested2'"=="" & "`nested3'"=="" | "`nested4'"=="")) {
				di as error "The two models are identical"
				exit 198
			}
		}
		if("`model1a'"=="`model2b'" & "`link1a'"=="`link2b'" & "`link1b'"=="`link2a'") {
			local nested1: list _rhs1a-_rhs2b
			local nested2: list _rhs2b-_rhs1a
			local nested3: list _rhs1b-_rhs2a
			local nested4: list _rhs2a-_rhs1b
			if("`nested1'"=="" & "`nested3'"=="" & ("`nested2'"!="" | "`nested4'"!="")) {
				di as error "mod1 is nested in mod2 - use instead frm_reset (RESET test) or frm_ggoff (GGOFF tests) for the relevant(s) component(s) of the two-part model"
				exit 198
			}
			if("`nested2'"=="" & "`nested4'"=="" & ("`nested1'"!="" | "`nested3'"!="")) {
				di as error "mod2 is nested in mod1 - use instead frm_reset (RESET test) or frm_ggoff (GGOFF tests) for the relevant(s) component(s) of the two-part model"
				exit 198
			}
			if("`nested1'"=="" & "`nested2'"=="" & "`nested3'"=="" | "`nested4'"=="")) {
				di as error "The two models are identical"
				exit 198
			}
		}
	}
	if(N1!=N2) {
		di as error "The sample size is not the same for mod1 and mod2"
		exit 198
	}
	if("`yobs1'"!="`yobs2'") {
		di as error "The dependent variable is not the same in mod1 and mod2"
		exit 198
	}

* Tests

	if("`lm'"!="" & "`model1'"!="2Pbin") qui gen `ones'=1

	forvalues i=1/2 {

		tempvar testvar

		display _newline(1)
		if(`i'==1) {
			di in text "H0: `alt1'"
			di in text "H1: `alt2'"
		}
		if(`i'==2) {
			di in text "H0: `alt2'"
			di in text "H1: `alt1'"
		}

		di in text "{hline 11}{c TT}{hline 21}"
		di in text %10s "Version" _col(12) "{c |} Statistic   p-value" 
		di in text "{hline 11}{c +}{hline 21}"

		if(`i'==1) qui gen `testvar'=`G2'-`G1' if (`touse')
		if(`i'==2) qui gen `testvar'=`G1'-`G2' if (`touse')

		if("`wald'"!="") {
			qui regress `yt`i'' `gx`i'' `testvar' if (`touse'), nocons robust
			qui test `testvar'
			
			if(_b[`testvar']<0) scalar tratio=-sqrt(r(F))
			if(_b[`testvar']>=0) scalar tratio=sqrt(r(F))

			di in text %10s "t" _col(12) "{c |}" as result %10.3f tratio _col(25) %8.4f r(p)

			return scalar t`i'=tratio
			return scalar t`i'p=r(p)
		}
 
		if("`lm'"!="") {
			tempvar w uw gwx gwz r uwr

			qui gen `w'=sqrt(`G`i''*(1-`G`i'')) if (`touse')
			qui replace `w'=1e-10 if `w'<1e-10 & (`touse')

			qui gen `uw'=(`yt`i'')/`w' if (`touse')

			local gwx
			foreach var of varlist `gx`i'' {
				tempvar XXX`var'
				qui gen `XXX`var''=`var'/`w' if (`touse')
				local gwx `gwx' `XXX`var''
			}

			qui gen `gwz'=`testvar'/`w' if (`touse')

			if(`nmod1'==1 & `nmod2'==1 & "`model1'"=="2Pbin" & "`model2'"=="2Pbin") {
				qui regress `uw' `gwx' `gwz' if (`touse'), nocons

				scalar LM=e(mss)
				scalar LMp=chi2tail(1,LM)
			}
			else {
				qui regress `gwz' `gwx' if (`touse'), nocons
				qui predict `r' if (`touse'), resid
				qui gen `uwr'=`r'*`uw' if (`touse')

				qui regress `ones' `uwr' if (`touse'), nocons

				scalar LM=e(N)-e(rss)
				scalar LMp=chi2tail(1,LM)
			}

			di in text %10s "LM" _col(12) "{c |}" as result %10.3f LM _col(25) %8.4f LMp

			return scalar LM`i'=LM
			return scalar LM`i'p=LMp
		}

		di in text "{hline 11}{c BT}{hline 21}"
	}

* Clearing memory

	scalar drop _all
	ereturn clear

end
