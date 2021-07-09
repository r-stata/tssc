*!TITLE: PARAMED - causal mediation analysis using parametric regression models	
*!AUTHORS: Hanhua Liu and Richard Emsley, Centre for Biostatistics, The University of Manchester
*!
*!	verson 1.5 HL/RAE 24 April 2013
*!		bug fix - stata's standard calculation of p and confidence interval based on e(b) and e(V)
*!				  (e.g. at 95%, [b-1.96*se, b+1.96*se]) does not work for non-linear cases
*!				  (e.g. loglinear at 95%, [exp(log(b)-1.96*se), exp(log(b)+1.96*se)]), so revert
*!				  back to manual calculation as already done in paramed.mata
*!		affected files - paramed.ado, paramedbs.ado; other files only updated with new version info
*!	
*!	version 1.4 HL/RAE 14 March 2013
*!		replay feature - after running paramed, issuing just paramed to reprint/replay the results;
*!		affected files - paramed.ado, paramed.sthlp; other files only updated with new version info
*!
*!	version 1.3 HL/RAE 17 February 2013
*!		return values - instead of returning e(effects), now returns standard e(b) and e(V),
*!						and display the results in standard Stata format;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!
*!	version 1.2 HL/RAE 11 February 2013
*!		syntax change - interaction is now default behaviour, 'nointer' is required syntax for no interaction;
*!		results - now use indicative name for the interaction variable rather than _000001;
*!		bootstrap - changed default number of repetitions from 200 to 1000;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!	
*!	version 1.1 HL/RAE	15 January 2013
*!		updated to save and install files to Stata's PLUS folder
*!
*!  version 1.0 HL/RAE  1 October 2012
*!		final version for submitting to SSC
*!	
*!	version 0.3d HL/RAE 25 October 2011
*!		syntax change - removed nc, introduced minimal abbreviation, 
*!						simplified input for interaction/casecontrol (no need ture/false), output
*!		return values - returns individual effects to allow bootstrap
*!		bootstrap - changed original program to paramedbs, this program is a wrapper which can handle bootstrap option
*!		
*!	version 0.3c HL/RAE 22 October 2011
*!		changed program name - Stata Journal recently published a command mediation, program name changes to paramed
*!		include s_e (standard error) in all outputs
*!	
*!	version 0.3b HL/RAE 24 September 2011
*!	
*!	version 0.3a HL/RAE 17 September 2011 - mediation.ado

program define paramedbs, eclass
	version 10.0	

	syntax varname(numeric), avar(varname numeric) mvar(varname numeric)	///
			[cvars(varlist numeric)] a0(real) a1(real) m(real) ///
			yreg(string) mreg(string) [NOINTERaction	///
			CASEcontrol FULLoutput c(numlist)]
				
	local yvar `varlist'

	//[if] [in] not included in the syntax, so `touse' is 1 for all observations
	marksample touse	
		
	//validate yreg and mreg
	local yregtypes linear logistic loglinear poisson negbin
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198
	} 
	else {
		local yreg : word `nyreg' of `yregtypes'
	}
	
	local mregtypes linear logistic
	local nmreg : list posof "`mreg'" in mregtypes
	if !`nmreg' {
		display as error "Error: mreg must be chosen from: `mregtypes'."
		error 198		
	}
	else {
		local mreg : word `nmreg' of `mregtypes'
	}
	
	//validate cvars and nc
	local cvar `cvars'
//	local ncvars = wordcount("`cvar'")
	local nc : word count `cvar'

	//full output or reduced output
	if "`fulloutput'" != "" {
		local output full
	}
	else {
		local output reduced
	}

	if "`nointeraction'" == "" {
		local interaction true	//redefine a local macro with the same name `interaction'
		
		local inter_var_names "_`avar'_X_`mvar' _`mvar'_X_`avar' _`avar_X_`mvar'_001 _`avar'_X_`mvar'_010 _`avar'_X_`mvar'_100 _`mvar'_X_`avar'_001 _`mvar'_X_`avar'_010 _`mvar'_X_`avar'_100"
		foreach name of local inter_var_names {
			capture confirm new variable `name'
			if !_rc {
				local inter `name'
				continue, break
			}
		}
		//all the 8 suggested names have been used by existing variables, give an error message
		if _rc {
			display as error "{p 0 0 5 0}The command needs to create an interaction variable "
			display as error "with one of the following names: `inter_var_names', "
			display as error "but these variables have already been defined.{p_end}"
			error 110
		}
		gen `inter' = `avar'*`mvar'

	}
	else {
		local interaction false
	}

	//casecontrol or not
	if "`casecontrol'" !="" {
		local casecontrol true
	}
	else {
		local casecontrol false
	}
	
	//validate c
	local n 0
	if "`c'"=="" {
		if ("`output'"=="full") & ("`cvar'"!="") {
			display as error "{p 0 7 5 0}Error: when the output mode is full, fixed values must be provided " 
			display as error "via c(numlist) for the covariates `cvar' at which compute conditional effects.{p_end}"
			error 198
		}
	}
	else {
		foreach val of numlist `c' {
			local ++n
		}
		
		if "`cvar'"=="" {
			display as error "Warning: c values are ignored when no covariates are included via cvars(varlist)."
		}
		else {
			if `n'!=`nc' {
				display as error "Error: the number of c values (`n') does not match the number of covariates (`nc')."
				error 198
			}
		}
	//	display "the number of c is: `n'"
		
		if "`output'"=="reduced" & "`c'"!="" {
			display as error "Warning: c values are ignored when output is in `output' mode."
		}
	}
	
		
	
	****************************************
	//block 1: for yreg=linear, mreg=linear
	//block 1.1: regressions
	if (("`yreg'"=="linear") & ("`mreg'"=="linear")) {
		if (("`interaction'"=="false") & ("`cvar'"!="")) {
			regress `yvar' `avar' `mvar' `cvar'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			regress `mvar' `avar' `cvar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="false") & ("`cvar'"=="")) {
			regress `yvar' `avar' `mvar' //if !`interaction' //& `cvar'==""
			matrix out1 = e(V)
			matrix beta1 = e(b)
			regress `mvar' `avar' //if !`interaction' //& `cvar'==""
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="true") & ("`cvar'"!="")) {
			regress `yvar' `avar' `mvar' `inter' `cvar'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			regress `mvar' `avar' `cvar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="true") & ("`cvar'"=="")) {
			regress `yvar' `avar' `mvar' `inter' //if `interaction' //& `cvar'==""
			matrix out1 = e(V)
			matrix beta1 = e(b)
			regress `mvar' `avar' //if `interaction' //& `cvar'==""
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
	}	
	//end of block 1.1: regressions
	
	//block 2: yreg=linear mreg=logistic
	if (("`yreg'"=="linear") & ("`mreg'"=="logistic")) {
		if (("`interaction'"=="false") & ("`cvar'"!="")) {
			regress `yvar' `avar' `mvar' `cvar'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			logit `mvar' `avar' `cvar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="false") & ("`cvar'"=="")) {
			regress `yvar' `avar' `mvar'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			logit `mvar' `avar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="true") & ("`cvar'"!="")) {		
			regress `yvar' `avar' `mvar' `inter' `cvar'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			logit `mvar' `avar' `cvar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
		if (("`interaction'"=="true") & ("`cvar'"=="")) {
			regress `yvar' `avar' `mvar' `inter'
			matrix out1 = e(V)
			matrix beta1 = e(b)
			logit `mvar' `avar'
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
	}	
	//end of block 2

	//block 3: yreg=logistic/loglinear/poisson/negbin, mreg=logistic
	if ((("`yreg'"=="logistic") | ("`yreg'"=="loglinear") | ("`yreg'"=="poisson") | ("`yreg'"=="negbin")) & ("`mreg'"=="logistic")) {
		if ("`interaction'"=="true") & ("`cvar'"!="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `inter' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `inter' `cvar', family(binomial) link(log)	
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `inter' `cvar'	
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `inter' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				logit `mvar' `avar' `cvar'
			} 
			if ("`casecontrol'"=="true") {
				logit `mvar' `avar' `cvar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}

		if ("`interaction'"=="true") & ("`cvar'"=="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `inter'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `inter', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `inter'	
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `inter'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				logit `mvar' `avar'
			} 
			if ("`casecontrol'"=="true") {
				logit `mvar' `avar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}

		if ("`interaction'"=="false") & ("`cvar'"!="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `cvar', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `cvar'	
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				logit `mvar' `avar' `cvar'
			} 
			if ("`casecontrol'"=="true") {
				logit `mvar' `avar' `cvar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}

		if ("`interaction'"=="false") & ("`cvar'"=="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `cvar'		
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				logit `mvar' `avar'
			} 
			if ("`casecontrol'"=="true") {
				logit `mvar' `avar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
	}	
	//end of block 3


	//block 4: yreg=logistic/loglinear/poisson/negbin, mreg=linear
	if ((("`yreg'"=="logistic") | ("`yreg'"=="loglinear") | ("`yreg'"=="poisson") | ("`yreg'"=="negbin")) & ("`mreg'"=="linear")) {
		if ("`interaction'"=="true") & ("`cvar'"!="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `inter' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `inter' `cvar', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `inter' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `inter' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				reg `mvar' `avar' `cvar'
			} 
			if ("`casecontrol'"=="true") {
				reg `mvar' `avar' `cvar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
			scalar rmse = e(rmse)			
		}

		if ("`interaction'"=="true") & ("`cvar'"=="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `inter'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `inter', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `inter'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {
				nbreg `yvar' `avar' `mvar' `inter'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				reg `mvar' `avar'
			} 
			if ("`casecontrol'"=="true") {
				reg `mvar' `avar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
			scalar rmse = e(rmse)			
		}

		if ("`interaction'"=="false") & ("`cvar'"!="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar' `cvar', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)
			}
			if ("`yreg'"=="negbin") {	
				nbreg `yvar' `avar' `mvar' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				reg `mvar' `avar' `cvar'
			} 
			if ("`casecontrol'"=="true") {
				reg `mvar' `avar' `cvar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}

		if ("`interaction'"=="false") & ("`cvar'"=="") {
			if ("`yreg'"=="logistic") {
				logit `yvar' `avar' `mvar'
			
				matrix out1 = e(V)
				matrix beta1 = e(b)	
			}
			if ("`yreg'"=="loglinear") {
				glm `yvar' `avar' `mvar', family(binomial) link(log)
				matrix out1 = e(V)
				matrix beta1 = e(b)	
			}
			if ("`yreg'"=="poisson") {
				poisson `yvar' `avar' `mvar' `cvar'
				matrix out1 = e(V)
				matrix beta1 = e(b)	
			}
			
			
			if ("`yreg'"=="negbin") {	
				nbreg `yvar' `avar' `mvar' `cvar'
				matrix tmp = e(V)
				matrix out1 = tmp[1..rowsof(tmp)-1,1..colsof(tmp)-1]
				matrix beta1 = e(b)
			}
			
			if ("`casecontrol'"!="true") {
				reg `mvar' `avar'
			} 
			if ("`casecontrol'"=="true") {
				reg `mvar' `avar' if `yvar'==0
			}
			matrix out2 = e(V)
			matrix beta2 = e(b)
		}
		
	}	
	//end of block 4
	
	
	mata: paramed("`cvar'", `a0', `a1', `m', `nc', "`yreg'", "`mreg'", "`interaction'", "`output'", "`c'")
	
	local allnames `""cde=nde" "cde" "nde" "nie" "pnde" "pnie" "tnde" "tnie" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "marginal cde" "marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional total effect" "total effect" "proportion mediated""'
	local shortnames `"cde cde nde nie pnde pnie tnde tnie ccde cpnde cpnie ctnde ctnie mcde mpnde mpnie mtnde mtnie mte cte te pm"'
	
	local newrownames
	local ne 0
	scalar nrow = rowsof(results) - 1
	foreach eff in `rownames' {
		local ++ne
		local pos : list posof `"`eff'"' in allnames
		local short : word `pos' of `shortnames'
	//	local newrownames `newrownames' `"`eff'"'
		local newrownames `newrownames' `"`short'"'
		if `ne'==nrow continue, break		
	}

	tempname b V
	matrix `b' = results[1..nrow, 1]'
	matrix colnames `b' = `newrownames'
	matrix `V' = J(nrow, nrow, 0)
	matrix rownames `V' = `newrownames'
	matrix colnames `V' = `newrownames'	
	forvalues i=1/`ne' {	
		mat `V'[`i',`i'] = results[`i',2]^2
	}
	ereturn post `b' `V', esample(`touse')
	
	local ne 0
	scalar nrow = rowsof(results) - 1	
	foreach eff in `rownames' {
		local ++ne
		local pos : list posof `"`eff'"' in allnames
		local short : word `pos' of `shortnames'

		ereturn scalar `short' = results[`ne',1]
		if `ne'==nrow continue, break	
	}

	tempname tempmat
	matrix define `tempmat' = results[1..nrow, 1...]

	/*Display final results; 
	  The following variables are passed from mata:
	*/
//	matrix rownames results = `rownames'
//	matrix colnames results = `colnames'	//Estimate s_e p-value "95% CI lower" "95% CI upper"

//	set linesize 100	//to accommodate all 5 columns
	
	matrix colnames `tempmat' = Estimate Std_Err P>|z| [95%_Conf Interval]
	matrix rownames `tempmat' = `newrownames'
	local cspec "cspec(& b %12s | %10.0g & %10.0g & %6.3f & %10.0g & %10.0g &)"
	local rowspec = substr("`rspec'", length("rspec(")+1, nrow+2)	//get rspec passed from mata, remove last row
	matlist `tempmat', `cspec' rspec(`"`rowspec'"') underscore
//	mat list `tempmat', noheader format(%10.0g)	
	
		ereturn matrix effects = `tempmat'
	
	if ("`interaction'"=="true") {
		drop `inter'
	}
end paramedbs
