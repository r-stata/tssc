/*This ado file executes non-linear regressions where the error term is 
distributed in the GB2 family tree

Author--Jacob Orchard
v 1.2
Update--6/1/2016*/




program gb2reg, eclass
version 13.0
	if replay() {
		display "Replay not implemented"
	}
	else {
		set more off
		syntax varlist(min=1) [if] [in] [, QINFinite LNormal sigma(varlist) p(varlist) q(varlist)  INITial(numlist) vce(passthru) CONSTraints(passthru) DIFficult TECHnique(passthru) ITERate(passthru) nolog TRace GRADient showstep HESSian SHOWTOLerance TOLerance(passthru) LTOLerance(passthru) NRTOLerance(passthru)] 
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		if "`sigma;" != ""{
			local sigmavars `sigma'
			}
		if "`p;" != ""{
			local pvars `p'
			}
		if "`q;" != ""{
			local qvars `q'
			}
		local nregs: word count `regs'
		local nsigma: word count `sigmavars'
		local np: word count `pvars'
		local nq: word count `qvars'
		
		marksample touse 
		*Defines titles used when running the program
	    local gb2title "ML fit of GB2 distribution"
		local ggtitle "ML fit of Generalized Gamma distribution"
	    local lntitle "ML fit of Log-Normal distribution"

	*GB2 type regressions work only on positive data. Gets rid of non-positive 
	*entries and issues a warning.
	quietly{ 
		  count if `depvar' < 0 & `touse'
		  local n =  r(N) 
		  if `n' > 0 {
			noi di " "
			noi di as txt " {res:`depvar'} has `n' values < 0;" _c
			noi di as text " not used in calculations"
			}

		  count if `depvar' == 0 & `touse'
		  local n =  r(N) 
		  if `n' > 0 {
			noi di " "
			noi di as txt " {res:`depvar'} has `n' values = 0;" _c
			noi di as text " not used in calculations"
			}

	  replace `touse' = 0 if `depvar' <= 0
	}
	if "`initial'" != ""{
			*Warns users specifying inital values if too few inital values are specified.
			local initiallen: word count `initial'
			if ("`qinfinite'" == "" & "`lnormal'" == "" & `initiallen' != `nregs'+`nsigma'+ `np' + `nq' +4) {
				di as err "initial does not have the correct amount of numbers."
				di as err "You must have {res:`initiallen'} starting guesses in initial for the model you specified."
				exit 503
			}
			if ("`qinfinite'" != "" & "`lnormal'" == "" & `initiallen' != `nregs'+`nsigma'+ `np'+3) {
				di as err "initial does not have the correct amount of numbers."
				di as err "You must have {res:`initiallen'} starting guesses in initial for the model you specified."
				exit 503
			}	
			if ( "`lnormal'" != "" & `initiallen' != `nregs'+`nsigma'+2) {
				di as err "initial does not have the correct amount of numbers."
				di as err "You must have {res:`initiallen'} starting guesses in initial for the model you specified."
				exit 503
			}
		if "`lnormal'" == ""{
		
			 if "`qinfinite'" == "" {
				local evaluator llf_gb2
				ml model lf `evaluator' (delta: `depvar' = `regs')  (sigma: `sigmavars')  (p: `pvars') (q: `qvars') if `touse',  search(on) maximize initial(`initial') `vce' `constraints' `technique'  `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance' title(`gb2title')
			}
			else {
				local evaluator llf_gg
				ml model lf `evaluator' (delta: `depvar' = `regs')  (sigma: `sigmavars')  (p: `pvars') if `touse', search(on) maximize initial(`initial')  `vce' `constraints' `technique'  `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'	title(`ggtitle')		
			}
		}
		else {
			local evaluator llf_ln
			ml model lf `evaluator' (delta: `depvar' = `regs') (sigma: `sigmavars')  if `touse', search(on) maximize initial(`initial') `vce' `constraints' `technique' `difficult' `iterate' `log'  `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'			title(`lntitle')

		}
		
		ml display, showeqns
		qui ereturn list
	}
			
		
	else{
		
		if "`lnormal'" == ""{
		
			 if "`qinfinite'" == "" {
				local evaluator llf_gb2
				ml model lf `evaluator' (delta: `depvar' = `regs')  (sigma: `sigmavars')  (p: `pvars') (q: `qvars') if `touse', search(on) maximize `vce' `constraints' `technique'  `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance' title(`gb2title')
			}
			else {
				local evaluator llf_gg
				ml model lf `evaluator' (delta: `depvar' = `regs')  (sigma: `sigmavars')  (p: `pvars') if `touse', search(on) maximize `vce' `constraints' `technique'  `difficult' `iterate' `log' `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'	 title(`ggtitle')		
			}
		}
		else {
			local evaluator llf_ln
			ml model lf `evaluator' (delta: `depvar' = `regs') (sigma: `sigmavars')  if `touse', search(on) maximize `vce' `constraints' `technique' `difficult' `iterate' `log'  `trace' `gradient' `showstep' `hessian' `showtolerance' `tolerance' `ltolerance' `nrtolerance'		title(`lntitle')	

		}
		
		ml display, showeqns
		qui ereturn list
	}
	}
end
