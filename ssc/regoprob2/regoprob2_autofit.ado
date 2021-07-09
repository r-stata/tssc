*********************************************************************************
* Authors: Christian Pfarr, christian.pfarr@uni-bayreuth.de						*
*		   Andreas Schmid, andreas.schmid@uni-bayreuth.de						*
*		   Udo Schneider, udo.schneider@uni-bayreuth.de							*
*																				*
*			Version 1.0 from 15. April 2010										*
*																				*
*	This is used when regoprob2 is called with the autofit option				*
*	(Automated model fitting). 													*
*	This routine recursively calls regoprob2									*
*	until a final model is found.  Should not be called with if, in,			*
*	or weights if using svy.													*
*	The svyprefix command is not currently used but may be in a future			*
*	version of the program.														*
*																				*
*********************************************************************************
program regoprob2_autofit

	if `c(stata_version)' < 9 {
		version 8.2
	}
	else {
		version 11
	}
	
	syntax varlist(min=2) [if] [in][, AUTOfit AUTOfit2(real .05) *]
		
        local step = 0
        if `"`weight'"' != "" {
                local wgt "[`weight'`exp']"
        }
	
	// Set level of significance for tests
	if "`autofit2'"!="" {
		local autofit = `autofit2'
	}
	else local autofit = .05
	if `autofit' <= 0 | `autofit' >= 1 {
		display as error "The significance value specified for autofit"
		display as error "must be between 0 and 1, e.g. .01, .05, .10"
		exit 198
	}

	// Formatting macros
	local smcl "in smcl "
	local dash "{c -}"
	local vline "{c |}"
	local plussgn "{c +}"
	local topt "{c TT}"
	local bottomt "{c BT}"
	
	// Start with an unconstrained model
	quietly local pl2 npl


	while "`stop'"=="" {
		quietly regoprob2 `varlist' `if' `in' , `pl2' `options' 
	
	
	// Won't get this far if there has been a fatal error in
	// regoprob2
	

		if `step'==0 {
			tempname fullmodel
			_estimates hold `fullmodel', copy
			di
			di `smcl' _dup(78) as text "`dash'"
			di as text "Testing the parallel lines assumption " ///
				"using the " as result "`autofit'" as text ///
				" level of significance..."
			di
		}


		local step = `step' + 1
		local plvars `e(plvars)'
		local nplvars `e(nplvars)'
		local xvars `e(xvars)'
		local Numeqs = e(k_cat)-1
		local Numpl: word count `plvars'
		local Numx: word count `xvars'


		// Stop if all Xs have been pl constrained
		if `Numpl'==`Numx' {
			di as text "Step" _col(7) "`step': " _col(11) ///
				as result "All explanatory variables " ///
				as text "meet the pl assumption"
		}
		if `Numpl'==`Numx' continue, break

		local eqs "test [#1"
		forval i = 2/`Numeqs' {
			local eqs `eqs'=#`i'
		}
		local eqs `eqs']:


		* local maxp = 0
		tempname maxp
		scalar `maxp' = 0
		local qualifier = 0
		local leader ""
		foreach nplvar of varlist `nplvars' {
			quietly `eqs'`nplvar'
			if `r(p)' > `maxp' & `r(p)' >= `autofit' & `r(p)' < . {
				local leader `nplvar'
				scalar `maxp' = `r(p)'
				local qualifier = 1
			}
		}
		// Stop if no more eligible variables
		if `qualifier'==0 {
			di as text "Step" _col(7) "`step': " _col(11) ///
				as text "Constraints for parallel lines " ///
				as result "are not imposed for "
			foreach nplvar of varlist `nplvars' {
				quietly `eqs'`nplvar'
				di as result _col(11) "`nplvar' " ///
					as text "(P Value = " ///
					as result %7.5f `r(p)' ///
					as text ")"
			}
			local stop "stop"
		}


		else {
			local plvars `plvars' `leader'
			local pl2 pl2(`plvars')
			di as text "Step" _col(7) "`step': " _col(11) ///
				as text "Constraints for parallel lines " ///
				as result "imposed for " ///
				as result "`leader' " ///
				as text "(P Value = " ///
				as result %6.4f `maxp' ///
				as text ")"
		}
	}


	// Do Wald test of final model versus unconstrained model
	// if any vars have been constrained to meet parallel lines assumption
	if "`plvars'"!="" {
		tempname finalmodel
		_estimates hold `finalmodel', restore
		_estimates unhold `fullmodel'
		local eqs "test [#1"
		forval i = 2/`Numeqs' {
			local eqs `eqs'=#`i'
		}
		local eqs `eqs']:`plvars'
		di 
		di as text ///
			"Wald test of parallel lines assumption for the final model:"
		`eqs'
		di
		di as text ///
			"An insignificant test statistic indicates that the final model"
		di as result "does not violate " ///
			as text "the parallel lines assumption"
		_estimates unhold `finalmodel'
	}


	// Print out final model
	if "`plvars'"=="" {
		local plparm "npl"
	}
	else local plparm pl(`plvars')

	di
	di as text "If you re-estimate this exact same model with " ///
		as result "regoprob2" as text ", without "
	di as text "the option " ///
		as result " autofit " ///
		as text "you can save time by using the parameter"
	di
	di as result "`plparm'"
	di
	di  `smcl' _dup(78) as text "`dash'"
	
end

