capture program drop npredcent
program npredcent, byable(recall, noheader)    /* Program to predict and center a variable on its mean */
	version 9.0
	syntax varlist [if] , REPlace(name) [contextvars(string)] [center(string)] [logit] [stackname(name)] [effects(string)] [NOStacks] [STAckid(varname)]
	
	// version 11?
	// syntax varlist(fv) [if] , REPlace(name) [contextvars(string)] [center(string)] [logit] [stackname(name)] [effects(string)] [NOStacks] [STAckid(varname)]
		

	//display in smcl
	//display as text
	//display " " _byn1() "-" _byn2()

	//display "*`nostacks'*"
	
	
	// set default centring
	if ("`center'"=="") {
		local center = "mean"
	}
	
	marksample touse
	tempvar NN MM
	
	quietly count if `touse'
	if (r(N)==0) {
		exit
	}
	
	/*
		it now should work without vallist, without errors
		it simply doesn't get labels
	*/
	
	
	capture confirm variable genstacks_item
	if !_rc {
		// action if exists
		quietly levelsof genstacks_item if `touse' 
		quietly capture vallist genstacks_item if genstacks_item == `r(levels)'
		local partyname = ""
		
		// did it break anything?
		//local partyname = substr(strtoname("`r(list)'",1),1,10)
		
	}
	else {
		if ("`nostacks'" != "") {
			local partyname = " "
		}
		else {
			if ("`stackid'"!="") {
				quietly levelsof `stackid' if `touse' 
				local partyname = ""
				// did it break anything?
				local partyname = strtoname("Stack `r(levels)'",1)
			}
			else {
				quietly levelsof genstacks_stack if `touse' 
				local partyname = ""
				// did it break anything?
				local partyname = strtoname("Stack `r(levels)'",1)
			}
		}
	}

	display "there"
	
	
	if (_by()==1) {
	// if ("`groupnum'"!="") {
		local groupnum = _byindex()
		local partyname = "_`groupnum'_`partyname'"
	}
	
	display "{bf:`partyname':}"
	
	local storemodel = "" 
	
	if ("`effects'"!="") {
		local storemodel = "eststo `partyname':"
	}
	
	/*
	// trying to make things faster:
	preserve
	noisily display "dropping unused..."
	keep if `touse'	
	//
	*/
	
	if ("`logit'"=="logit") {
		`storemodel' logit `varlist' if `touse'	
	}
	else {
		//display "`storemodel' reg `varlist' if `touse'"
		`storemodel' reg `varlist' if `touse'	
		//display "*done."
	}
	local con = _b[_cons]
	
	predict NN if `touse'	
	
	if ("`center'"=="no") {
		replace `replace'=NN if `touse'	
		drop NN
	}
	else {
		egen MM=mean(NN) if `touse'	
		
		if ("`logit'"=="logit" & "`center'"=="constant") {
			gen exponNN = logit(NN)
			replace `replace'=invlogit(exponNN-`con') if `touse'	
			capture drop exponNN
		}
		else if ("`logit'"=="logit") {
			gen exponNN = logit(NN)
			egen exponMM = mean(exponNN)
			replace `replace'=invlogit(exponNN-exponMM) if `touse'	
			capture drop exponNN exponMM
		}
		else if ("`center'"=="constant") {
			replace `replace'=NN-`con' if `touse'	
		}
		else {
			replace `replace'=NN-MM if `touse'	
		}
		drop MM NN
	}
	
	
	/*
	//
	local filename : display "tmp" _byn1() ".dta"
	save `filename', replace
	noisily display "restoring and appending tempfile..."
	restore
	drop if `touse'
	append using `filename'
	noisily display "done."
	erase `filename'
	//
	*/
end
capture program drop genyhats
program define genyhats, sortpreserve
	version 9.0
	syntax anything(id="yhat specification") [if] , DEPvar(varname) [CONtextvars(varlist)] [STAckid(varname)] [LOGit] [REPlace] [NOStacks] [YPRefix(string)] [ADJust(string)] [NOADJUSTopt] [OUTput] [EFFects(string)] [EFMt(string)] [DEMean(varname)] [DPRefix(string)]
	// [NOCENTERopt] [CENter(string)] [centre(string)] [NOCENTREopt]
	
	display in smcl
	display as text
	
	display "{pstd}{text}"
	
	// make sense of all the centring syntax options...

	/*
	if ("`nocenteropt'`nocentreopt'" != "`nocenteropt'" & "`nocenteropt'"!="") {
		display "Options {bf:nocenter} and {bf:nocentre} cannot be specified simultaneously."
		exit
	}
	else {
		local noc = "`nocenteropt'`nocentreopt'" // will pick up the only one specified
	}
	if ("`center'`centre'" != "`center'" & "`center'"!="") {
		display "Options {bf:center()} and {bf:centre()} cannot be specified simultaneously."
		exit
	}
	else {
		local cen = "`center'`centre'" // will pick up the only one specified
	}
	*/
	
	// now: "adjust"
	local cen = "`adjust'"
	local noc = "`noadjustopt'"
		
	if ("`noc'`cen'" != "`cen'" & "`cen'"!="") {
		display "Adjustment cannot be simultaneously enabled and disabled."
		exit
	}
	else {
		if ("`noc'"!="") {
			local centring = "center(no)"
		}
		else {
			if ("`cen'" != "mean" & "`cen'" != "constant" & "`cen'" != "no"  & "`cen'" != "") {
				display "Valid adjustment options are {bf:mean}, {bf:constant} or {bf:no}."
				exit
			}
			local centring = "center(`cen')"
		}
	}
	
	local yyprefix = "y_"
	if ("`yprefix'" != "") {
		local yyprefix = "`yprefix'"
	}
	
	if ("`nostacks'" != "") {
		local stkid = ""
	}
	else {
		if ("`stackid'" == "") {
			capture confirm variable genstacks_stack
			if !_rc {
					// action if exists
					local stkid = "genstacks_stack"
			}
			else {
					// action if not
					local stkid = ""
					local nostacks = "nostacks"
			}
			//local stkid = "genstacks_stack"
		}
		else {
			local stkid = "`stackid'"
		}
	}
	
	
	if ("`contextvars'" == "") {
		if ("`nostacks'" != "") {
			gen _stk_temp = 1
			local stackvars = "_stk_temp"
		}
		else {
			local stackvars = "`stkid'"
		}
	}
	else {
		local stackvars = "`contextvars' `stkid'"
	}	
	
	if ("`depvar'" == "") {
		local dvar = "ptv"
	}
	else {
		local dvar = "`depvar'"
	}	
	
	
	display "Y-hats will be separately generated for combinations of {result:`stackvars'}."
	display ""
	
	local pipedsyntax = 0
	
	if (strpos("`anything'",":")!=0 | strpos("`anything'","||")!=0) {
		local pipedsyntax = 1
	} 
	else {
		local vars
		foreach var of varlist `anything' {
				local vars `vars' `var'
		}
		local anything `vars'
	}
	while ("`anything'" != "")  {
		
		if (`pipedsyntax'==1) {
		
			gettoken string anything : anything, parse("||") // put into 'string' all up to "\" or to end of anything
			
			//display "{pstd}{text}"

			//display "Processing {bf:`string'}:{break}"
			if (strpos("`string'",":")==0) {
				// no colon
				local indepvars `string'
				foreach var of varlist `indepvars' {
					local yhat = "`yyprefix'`var'"
					continue, break
				}
			}
			else {
				// colon
				gettoken yhat colonvars: string, parse(": ")
				gettoken colon indepvars: colonvars, parse(": ")
			}

		}
		else {
			//display "Unpiped syntax detected."
			gettoken string anything : anything
			
			local stringname=strtoname("`string'")
			local yhat = "`yyprefix'`stringname'"
			
			local indepvars = "`string'"		
		}
		
		display "{pstd}{text}"
		display "Generating {bf:`yhat'} from {bf:`indepvars'}:"
		
		//display "---"
		//display "**V `yhat' => `vars' **"
		
		// NOW EXPLICIT DEPVAR OPTION: NOT NEEDED
		//gettoken depvar indepvars : vars  // parse into depvar and indeps
		
		//capture confirm variable `indepvars'  // make sure there is at least one indep
		
		/*
		* BODY 
		*/
	
			capture quietly generate `yhat' = 0
			capture replace `yhat' = .
			
			/*
			// must make this work
			//capture replace `yhat' = .
			*/

			local eff = ""

			if ("`effects'"!="") {
				eststo clear
				local eff= "effects(`effects')"

			}
			display "Predicting {result:`dvar'} on {result:`indepvars'}, saving Y-hats in {result:`yhat'}..."
			// quietly:
			local outmode = "quietly:"
			if ("`output'"=="output") {
				local outmode = ""
			}
			
			local con = ""
			if ("`contextvars'"!="") {
				local con = "contextvars(`contextvars')"
			}

			local stid = ""
			if ("`stackid'"!="") {
				local stid = "stackid(`stackid')"
			}
			
			//display "`outmode' bysort `stackvars': npredcent `dvar' `indepvars' `if', replace(`yhat') `logit' `stid' `centring' `eff' `con' `nostacks'"
			`outmode' bysort `stackvars': npredcent `dvar' `indepvars' `if', replace(`yhat') `logit' `stid' `centring' `eff' `con' `nostacks'
			
			if ("`effects'"!="") {
				local usefile = ""
				if ("`effects'"!="window") {
					local usefile = "using `yhat'.`effects'"
				}
				else {
						display "{p_end}"
				}
				if ("`logit'"=="logit") {
					local cellfmt = "z(fmt(3) star)"
					if ("`efmt'"!="") {
						local cellfmt = "`efmt'"
					}
					esttab `usefile', cells("`cellfmt'") pr2(%8.3f) mtitles replace compress wide onecell plain label
				}
				else {
					local cellfmt = "z(fmt(3) star)"
					if ("`efmt'"!="") {
						local cellfmt = "`efmt'"
					}
					if ("`efmt'"=="beta") {
						esttab `usefile', beta(%8.3f) not constant star ar2(%8.3f) mtitles replace compress wide onecell plain label
					}
					else {
						esttab `usefile', cells("`cellfmt'") ar2(%8.3f) constant mtitles replace compress wide onecell plain label
					}
				}
				//esttab , se ar2 b(3) wide nostar label mtitles replace compress plain
			}
			
			
			display "done."
			
			if ("`demean'"!="") {
				if ("`dprefix'"!="") {
					local dpref = "`dprefix'"
				}
				else {
					local dpref = "mean_"
				}
				
				if ("`logit'"=="logit") {
					gen log`yhat'=.
					replace log`yhat'=logit(`yhat')
					bysort `demean': egen log`dpref'`yhat'=mean(log`yhat')
					replace `yhat'=invlogit(log`yhat'-log`dpref'`yhat')
					gen `dpref'`yhat'=invlogit(log`dpref'`yhat')
					//capture drop log`dpref'`yhat' log`yhat'				
				}
				else {
					bysort `demean': egen `dpref'`yhat'=mean(`yhat')
					replace `yhat'=`yhat'-`dpref'`yhat'
				}
				

			}
			
			
			if ("`replace'"=="replace") {
				display " As requested, dropping {result:`indepvars'}...{break}"
				drop `indepvars'	
			}
			
			//display "{p_end}"
			display ""
			
		/*
		* END BODY
		*/
		
		if (`pipedsyntax'==1) {
			if ("`anything'" != "") gettoken string anything : anything  // move past "\" (dk how to avoid requiring a space after "\")
		}
	}
	
	display ""
	capture drop _stk_temp
	
end	
