********************************************************************************
**************  -mixmcm-: Mixed-Markov Chain model via EM algorithm ************
********************************************************************************
*** Author : Legrand D. F. Saint-Cyr and Laurent Piet
*** SMART-LERECO, INRA, AGROCAMPUS OUEST, F-35000 Rennes, France
***	legrand.saint-cyr@inra.fr
*** version 1.0.1 
*** Last modified: 14.11.2018
********************************************************************************
********************************************************************************

capture program drop mixmcm
program mixmcm

	version 13
	if replay() {
		if (`"`e(cmd)'"' != "mixmcm") error 301
		Replay `0'  
	}
	else Estimate `0' 
end

* ------------------------------------------------------------------------------
* 1. mixmcm subroutines
* ------------------------------------------------------------------------------

	* --------------------------------------------------------------------------
	* 1.1 Mixture of mlogit routine
	* --------------------------------------------------------------------------
capture program drop my_mixmlogit
program my_mixmlogit

/*define temporary variables*/
	tempvar _ll _dens 
	forvalues s=1/$ncomponents {
		local compdepvar `compdepvar' _proba_`s' 	
		tempvar _pr_`s' _den_`s' _weight_`s' _pr_in_`s' sumprod_`s'
		foreach j in $istates {	
			foreach k in $fstates {
				tempvar _p_`s'_`j'_`k'
			}
		}					
	}
/*Combine weights*/
	forvalues s=1/$ncomponents {
		local w $fullwexp
		gettoken subw wvar: w, parse(" ")	
		if "$fullwexp" != "" {
			generate double `_weight_`s'' = _proba_`s'*`wvar' 
		}
		else {
			generate double `_weight_`s'' = _proba_`s'	
		}
	}
/*Estimate entry probabilities*/
	capture drop _share_tot
	generate double _share_tot=0
	capture drop `_dens'
	generate double `_dens' = 0
	scalar ncparam_$ncomponents = 0
	if "$entry" != "" {
		forvalues s=1/$ncomponents {
			generate double `_pr_in_`s'' = 1			
			mlogit _entry $entry_indepvars if _frst == 1 [iw=`_weight_`s''], robust iterate(20)
			if ($ncomponents != 1 & e(converged) == 0) continue, break 	
			scalar ncparam_$ncomponents = ncparam_$ncomponents + e(k)
			matrix b_`s' = e(b)
			matrix V_`s' = e(V)			
			foreach j in $istates {
				capture drop _p_`s'_`j'
				quietly predict double _p_`s'_`j' if _frst == 1 & e(sample), outcome(`j')
				quietly replace `_pr_in_`s''=_p_`s'_`j' if _entry == `j' 
				quietly by $id: replace `_pr_in_`s''=`_pr_in_`s''[_n-1] if _frst != 1
			}
			quietly replace `_pr_in_`s'' = 1 if `_pr_in_`s''==.	
		}
	}
/*Estimate transition probabilities*/	
	forvalues s=1/$ncomponents {
		capture drop `_pr_`s''
		generate double `_pr_`s'' = 1 
		foreach j in $istates {
			mlogit _entry_`j' L.($indepvars) [iw=`_weight_`s''], robust baseoutcome(`j') iterate(20) $constant
			if ($ncomponents != 1 & e(converged) == 0) continue, break 
			scalar ncparam_$ncomponents = ncparam_$ncomponents + e(k)
			matrix b_`s'_`j' = e(b)
			matrix V_`s'_`j' = e(V)
			foreach k in $fstates  {
				if Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {
					capture drop `_p_`s'_`j'_`k''				
					quietly predict double `_p_`s'_`j'_`k'' if e(sample), outcome(`k') 
					quietly replace `_pr_`s''=`_p_`s'_`j'_`k'' if _entry_`j' == `k' 
				}
			}
		}		
		if ($ncomponents != 1 & e(converged) == 0) continue, break
		capture drop `sumprod_`s''
		by $id: generate double `sumprod_`s'' = exp(sum(ln(`_pr_`s'')))
		capture drop `_den_`s''
		by $id: generate double `_den_`s'' = `sumprod_`s''[_N]
	} 
/*Compute type membership probabilities*/	
	if e(converged) != 0 | $ncomponents == 1  { 
		if "$membership" == "" | $ncomponents == 1 {
			scalar ncparam_$ncomponents = ncparam_$ncomponents + ($ncomponents-1)
			forvalues s=1/$ncomponents {		
				summarize _proba_`s' if _lst == 1 //non-parametric mixing distribution
				scalar _share_`s' = round(r(mean),0.01)
				if "$entry_indepvars" != "" replace `_dens' = `_dens' + (_share_`s'*`_pr_in_`s''*`_den_`s'') 
				else replace `_dens' = `_dens' + (_share_`s'*`_den_`s'') 
			}
		}		
		else {	
			fmlogit `compdepvar' [`w'], eta("$compvarlist") iterate(20) //parametric mixing distribution
			scalar ncparam_$ncomponents = ncparam_$ncomponents + e(k)			
			matrix b = e(b)
			matrix V = e(V)
			local outcome _proba_
			if (e(converged) == 0) continue, break						
			forvalues s=1/$ncomponents {
				if `s' != 1 {
					capture drop _share_`s'
					predict double _share_`s' if _lst == 1, pr outcome(`outcome'`s')
					by $id : replace _share_`s' = _share_`s'[_N] if _share_`s' == .
					if "$entry_indepvars" != "" replace `_dens' = `_dens' + (_share_`s'*`_pr_in_`s''*`_den_`s'') 
					else replace `_dens' = `_dens' + (_share_`s'*`_den_`s'')			
					replace _share_tot = _share_tot + _share_`s' 
				}
			}
			capture drop _share_1
			generate double _share_1 = 1-_share_tot
			if "$entry_indepvars" != "" replace `_dens' = `_dens' + (_share_1*`_pr_in_1'*`_den_1') 	
			else replace `_dens' = `_dens' + (_share_1*`_den_1')
		}
		forvalues s=1/$ncomponents {
			if "$entry_indepvars" != "" replace _proba_`s' = (_share_`s'*`_pr_in_`s''*`_den_`s'')/`_dens' 
			else replace _proba_`s' = (_share_`s'*`_den_`s'')/`_dens'
		}
		generate double `_ll' = ln(`_dens') //observed log-likelihood
		if ("`wvar'" != "") {
			quietly replace `_ll' = `_ll'*`wvar'
		}
		summarize `_ll' if _lst == 1  
		scalar ll = r(sum)
	}
end
	* --------------------------------------------------------------------------
	* 1.2 Parse ncomponents option routine
	* --------------------------------------------------------------------------
capture program drop parse_ncomponents_opt
program parse_ncomponents_opt, sclass
    
    syntax [, selcrit(string) graph(string asis) save(string asis) force] 
    sreturn local selcr `selcrit'
	sreturn local graph `graph'
    sreturn local save `save'
    sreturn local force `force'	
end
	* --------------------------------------------------------------------------
	* 1.3 Parse emiterate option routine
	* --------------------------------------------------------------------------
capture program drop parse_emiterate_opt
program parse_emiterate_opt, sclass
    
    syntax  [, lr(string asis) sr(string asis) seed(string) emlog] 
    sreturn local lr `lr'
    sreturn local sr `sr'	
    sreturn local seed `seed'
	sreturn local emlog `emlog'	
end
* ------------------------------------------------------------------------------
* 2. mixmcm program 
* ------------------------------------------------------------------------------
capture program drop Estimate
program Estimate, eclass sortpreserve

		syntax 	varlist(min=1) [if] [in] [fweight pweight], 	///			
				ID(varname)										///			
				TIMEvar(varname)								///			 
				[ENTRY(varlist min=1)]							///			
				[EXITcode(string)]								///											
				[NComponents(string asis)]						///				
				[MEMBERShip(varlist min=1)]						///			
				[EMITERate(string asis)] 						///			
				[noCONStant]									///			
				[CONSTraints(string)]									  	
				
	* ------------------------------------------------------------------------------
	* 2.1 Preserve original database and check syntax
	* ------------------------------------------------------------------------------
	preserve
	marksample touse, novarlist
	quietly keep if `touse'==1
	gettoken depvar indepvars:varlist 

		* --------------------------------------------------------------------------
		* 2.1.1. Confirm or transform _depvar to numeric variables
		* --------------------------------------------------------------------------
	quietly levelsof `depvar', local(depvls) 
	capture confirm numeric variable `depvar'
	if _rc == 0 {
		local _rc_depvar = 0
		gen _depvar=`depvar'
		capture confirm number _depvar
		if _rc == 0 {
			capture confirm int _depvar
			if _rc != 0 {
				display as error "invalid variable _depvar: numeric dependent variable must be a positive integer."
				exit 498
			}
			qui count if _depvar < 0
			if r(N) > 0 {
				display as error "invalid variable _depvar: numeric depvar must be a positive integer."
				exit 498		
			}
		}
	}
	else {
		local _rc_depvar = 1
		tempname _depvar
		encode `depvar' if `depvar' != "." & `depvar' != "`exitcode'", generate(_depvar) 
		quietly replace _depvar=0 if `depvar' == "`exitcode'"
	}
	quietly levelsof _depvar, local(new_depvls)  
	local nfstates = wordcount(`"`new_depvls'"')

		* --------------------------------------------------------------------------
		* 2.1.2. Confirm `timevar' to numeric variables
		* --------------------------------------------------------------------------
	capture confirm numeric variable `timevar' 
	if _rc == 0 {
		capture confirm int variable `timevar'
		if _rc != 0 {
			display as error "invalid variable timevar: numeric `timevar' must be a positive integer."
			exit 498
		}
		quietly count if `timevar' < 0
		if r(N) > 0 {
			display as error "invalid variable `timevar': numeric timevar must be a positive integer."
			exit 498		
		}	
	}
	else {
		display as error "invalid variable `timevar': timevar must be numeric."
		exit 498
	}
		* --------------------------------------------------------------------------
		* 2.1.3. Check entry-exit options
		* --------------------------------------------------------------------------
	if "`entry'" != "" {
		gettoken entry_depvar entry_indepvars:entry 
		capture confirm numeric variable `entry_depvar'
		if _rc != 0 {	
			tempname _edepvar
			encode `entry_depvar' if `entry_depvar' !=".", generate(`_edepvar')
		}
		else local _edepvar `entry_depvar'
	}
	if "`exitcode'" != "" {
		if `_rc_depvar' == 1 {
			quietly replace _depvar = 0 if `depvar' == "`exitcode'"	
		}
		local w = 0
		foreach word in `depvls' {
			if "`word'" != "`exitcode'" {
				local instates `instates' `word'
				local i=`i'+1
				local istates `istates' `i'
				local state_`i' `word'
			}
			else local w = `w' + 1		
		}
		local fstates `istates' 0
		local state_0 `exitcode'
		if `w' == 0 {
			display as error "exitcode (`exitcode') not found."	
			exit 111		
		}
		local nistates = `nfstates'-1	
	}
	else {
		local nistates = `nfstates'
		local istates `new_depvls'
		local fstates `new_depvls'
		foreach word in `depvls' {
			local instates `instates' `word'
			local i=`i'+1
			local state_`i' `word'
		}	
	}
		* --------------------------------------------------------------------------
		* 2.1.4. Check ncomponents options
		* --------------------------------------------------------------------------
	if `"`ncomponents'"' != "" { 
		gettoken mainopts subopts: ncomponents, parse(",")
		foreach mainopt of local mainopts {
			capture confirm integer number `mainopt'
			if _rc != 0 {
				display as error "option nptimal() incorrectly specified: number of components must be integer and >= 1."
				exit 198
			}
		}
		if "`mainopts'" == "" {
			dis as text "option ncomponents() incorrectly specified: number of components must be specified."
			exit 198
		}
		if (`=wordcount("`mainopts'")' == 1) {
			if "`subopts'" != "" {
				dis as error "Optimal number of component specified: ncomponents suboptions not allowed."	
				exit 498
			}
			if (`=word("`mainopts'",1)' == 1) {
				foreach mixmcmopt in emiterate membership {
					if "``mixmcmopt''" != "" {
						display as error "Option `mixmcmopt'() not allowed: inconsistence with simple Markov chain model." 
						exit 198
					}
				}
			}
			local minnc = `=word("`mainopts'",1)'
			local maxnc = `=word("`mainopts'",1)'
		}	
		if (`=wordcount("`mainopts'")' > 2) {
			display as text "option ncomponents() incorrectly specified: only minimum (#1) and maximum (#2) number of components must be specified."
			exit 198
		}		
		if (`=wordcount("`mainopts'")' == 2) {
			local minnc = word("`mainopts'",1)
			local maxnc = word("`mainopts'",2)	
			if (`minnc' >= `maxnc') {
				display as error "option ncomponents() incorrectly specified: minimum number of components (#1) must be smaller than maximum number of components (#2)."
				exit 198
			}
			if `"`subopts'"' != "" {
				parse_ncomponents_opt `subopts'
				local selcr `s(selcr)'
				local graph_options `s(graph)'			
				local save_options `s(save)'
				local force `s(force)'
				if ("`selcr'" != "") {
					if "`selcr'" != "bic" & "`selcr'" != "aic" & "`selcr'" != "caic" & "`selcr'" != "aic3" {
						display as error "Selection criterion (`selcr') not allowed."	
						exit 498
					}			
				}
				if ("`graph_options'" != "") {
					gettoken criteria twoway_options: graph_options, parse(",")
					if "`criteria'" == "" {
						display as error "option ncomponents() incorrectly specified: an information critera must be specified in graph options."
						exit 198				
					}
					foreach criterion of local criteria {
						if "`criterion'" != "bic" & "`criterion'" != "aic" & "`criterion'" != "caic" & "`criterion'" != "aic3" {
							display as error "Information criterion (`criterion') not available."	
							exit 498
						}
						quietly generate double `criterion'=1
					}
					twoway line `criteria', `twoway_options' nodraw
					quietly drop `criteria'					
				}
				if ("`save_options'" != "") {
					gettoken filename rsaveopts: save_options, parse(",")
					gettoken comma rsaveopts: rsaveopts
					foreach option of local rsaveopts {
						if "`option'" != "replace" & "`option'" != "detail"  {
							display as error "Unrecognized option (`option')."	
							exit 498
						}
						if "`option'" == "replace" local replacefile replace
						if "`option'" == "detail" local detail "yes" 
					}
				}
			}
			if "`selcr'" == "" local selcr caic //the default			
		}
	}
		* --------------------------------------------------------------------------
		* 2.1.5. Check emiterate options
		* --------------------------------------------------------------------------
	if "`emiterate'" != "" {  
		parse_emiterate_opt ,`emiterate'
		if ("`s(lr)'" != "") {
			local lrem "`s(lr)'"
			gettoken nlr_opts eps_opt: lrem, parse(",")	
			local nlr = `=word("`nlr_opts'",1)'
			local nlri = `=word("`nlr_opts'",2)'	
			gettoken comma eps: eps_opt	
			if "`eps'" != "" {
				capture confirm number `eps'
				if `eps' < 0 | _rc != 0  {
					display as error "option emiterate() incorrectly specified: convergence criterion for long-run EM iterations must be >= 0."
					exit 198
				}
			}
		}
		if ("`s(sr)'" != "") {
			local nsr = word("`s(sr)'",1) 
			local nsri = word("`s(sr)'",2)
		}
		foreach emoption in nlr nlri nsr nsri {
			if "``emoption''" != "" {	
				confirm integer number ``emoption''
				local _rc`emoption' = _rc		
				if `_rc`emoption' != 0' | ``emoption'' < 1   {
					display as error "option emiterate() incorrectly specified: `emoption'() suboption must be an integer and >= 1."
					exit 198
				}
			}
		}
		if (`=wordcount("`nlr_opts'")' > 2) | (`=wordcount("`s(sr)'")' > 2) {
			display as error "option emiterate() incorrectly specified: too much arguments in lr() or sr() suboption."
			exit 198			
		}
		local o_seed=c(seed)
		if "`s(seed)'" != "" {
			local seed `s(seed)'
			capture confirm integer number `seed'
			if (`=wordcount("`s(seed)'")' > 1) | (`seed' < 0) | (`seed' > 2147483647) | _rc != 0 {
				display as error "option emiterate() incorrectly specified: seed must be between 0 and 2^31-1 (2,147,483,647)."
				exit 198			
			}	
		}
		local emlog `s(emlog)'	
	} 
	if "`minnc'" == "" local minnc = 2 	//default value 
	if "`maxnc'" == "" local maxnc = 2 	//default value

		* --------------------------------------------------------------------------
		* 2.1.6. Check membership option
		* --------------------------------------------------------------------------
	if "`membership'" != "" {
		local compvarlist `membership'
		foreach v of local compvarlist {
			quietly generate _unvar = 1
			quietly bysort `id': replace _unvar = 0 if `v'[_n] != `v'[_n-1] & _n != 1
			quietly tabulate _unvar		
			if r(r) != 1 {
				display as error "invalid variable `v': variables in membership() must not vary within the same id(`id')."
				exit 498
			}
			drop _unvar
		}
	}
	*-------------------------------------------------------------------------------
	* 2.2. Check data consistency
	* ------------------------------------------------------------------------------
	tempvar _bpanel _cpanel 
	quietly levelsof `timevar', local(timelevels)
	local nlevels=wordcount(`"`timelevels'"')
	if `nlevels' < 2 {
		display as error "Not a panel data: data must be panel for mixmcm estimation."	
		exit 498
	}
	if `nlevels' >= 2 quietly by `id': keep if _N >= 2
	sort `id' `timevar'
	quietly by `id':generate `_bpanel' = 1 if `nlevels' == _N 
	quietly count if `_bpanel' != 1 
	if r(N) == 0 display as result "Balanced panel with time occurence: "`nlevels' _newline
	if r(N) != 0 {
		quietly generate `_cpanel' = 1
		forvalues i=1/`=`nlevels'-1' {
			local word_`i' = word("`levels'",`i')	
			local nextword_`i' = word("`levels'",`=`i'+1')
			foreach w in `levels' {
				if `w' == `word_`i'' {
					quietly by `id':replace `_cpanel' = 0 if `timevar'[_n-1] == `word_`i'' & `timevar'[_n] != `nextword_`i'' 
				}
			}			
		}
		quietly count if `_cpanel' == 0 
		if r(N) != 0 {
			display as error "Unbalanced panel data with different time intervals: equal time spaces are required for mixmcm estimation."
			exit 498
		}
		else {
			display as text "(Warning: unbalanced panel data)" _newline
		}	
	}
	* ------------------------------------------------------------------------------
	* 2.3. Parse constraints defined by users
	* ------------------------------------------------------------------------------
	local nCns = wordcount(`"`constraints'"') // number of constraints
	matrix Cns_tpm = J(`nistates',`nfstates',.)
	matrix rownames Cns_tpm = `istates'
	matrix colnames Cns_tpm = `fstates'
	if "`constraints'" != "" {
		forvalues i=1/`nCns' {
			constraint get `i'
			local nconst = 0
			local constr_`i' `r(contents)'
			gettoken _cstr _rcstr : constr_`i', parse("=")
			local w = 0
			while `=wordcount("`_cstr'")' > 0 {
				local w = `w' + 1 
				gettoken wcstr_`w' _cstr : _cstr, parse(_)
			}
			if `w'>5 | "`wcstr_1'" != "p" | "`wcstr_2'" != "_" | "`wcstr_4'" != "_" {
				display as error "Invalide constraint `i'."
				exit 498
			}
			if "`=substr("`_rcstr'",-1,.)'" != "0" {			
				display as error "Invalide constraint: transition probabilities must only be constrained to 0."
				exit 498
			}	
			foreach j in `istates' {
				if "`=rtrim("`wcstr_3'")'" == "`state_`j''"  {
					foreach k in `fstates' {
						if "`=rtrim("`wcstr_5'")'" == "`state_`k''" {
							matrix Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] = 0
							local nconst = `nconst' + 1
						}
					}		
				}
			}
			if ("`constr_`i''" == "" | `nconst' == 0)  {
				display as error "Invalide constraint `i'."
				exit 498		
			}
		}
	}
	* ------------------------------------------------------------------------------
	* 2.4. Define initial categories and count transitions
	* ------------------------------------------------------------------------------
	local nbparam = (wordcount(`"`indepvars'"')+1)*`maxnc'
	matrix ctgc_tab = J(`nistates',`nfstates',0)
	matrix rownames ctgc_tab = `istates'
	matrix colnames ctgc_tab = `fstates'
	if "`entry'" != "" {
		quietly generate _entry =.
		matrix entry=J(1,`nfstates',.)
		matrix rownames entry= `entry_depvar'
		matrix colnames entry = `fstates'
		foreach j in `istates' {
			quietly replace _entry =`j' if `_edepvar' == `j'
			quietly by `id': replace _entry = _entry[_n-1] if _entry[_n-1] !=.
			quietly summarize `id' if _entry ==`j' 
			matrix entry[1,`j'] = r(N)
		}	
	}
	foreach j in `istates' {
		quietly generate int _entry_`j' =.
		foreach k in `fstates' {
			quietly by `id':replace _entry_`j' = `k' if _depvar[_n] == `k' & _depvar[_n-1] == `j'
			quietly summarize `id' if _entry_`j' == `k' 
			matrix ctgc_tab[rownumb(ctgc_tab,"`j'"), colnumb(ctgc_tab,"`k'")] = r(N)
			if ctgc_tab[rownumb(ctgc_tab,"`j'"), colnumb(ctgc_tab,"`k'")] < `nbparam' & Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {
				display as error "Cannot estimate probabilities to move from state '`state_`j''' to state '`state_`k''' for `maxnc' components: no sufficient observation"
				exit 148
			}			
			if Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] == 0 {
				quietly by `id':replace _entry_`j' = . if _entry_`j' == `k' 
			}			
		}
		quietly levelsof _entry_`j', local(levels)
		local nlevels_`j' = wordcount(`"`levels'"')	
		if `nlevels_`j'' < 2 {
			display as error "Cannot estimate probabilities to move out of '`state_`j''' state : too few classes"
			exit 148
		}	
	}
	if "`entry'" != ""  matrix ctgc = ctgc_tab\entry
	quietly xtset `id' `timevar' 
	quietly by `id':generate byte _frst = 1 if _n == 1   
	quietly by `id':generate byte _lst = 1 if _n == _N   
	quietly tempfile mmcm_dataset
	quietly save `mmcm_dataset', replace //dataset to be used in the EM iterations 

	* ------------------------------------------------------------------------------
	* 2.5. Parameters estimation
	* ------------------------------------------------------------------------------
	local fullwexp "`weight'`exp'"
	gettoken subw wvar: exp, parse(" ")	
	if ("`fullwexp'" != "") {
		quietly summarize `wvar'
		scalar N = r(sum) 
		quietly summarize `wvar' if _lst == 1 
		scalar Ni = r(sum)
	}
	else {
		scalar N = _N
		quietly count if _lst == 1
		scalar Ni = r(N)			
	}		
	local bestnc = `minnc'
	tempvar _p _pr _component _ll _dens 
	forvalues ncomponents=`minnc'/`maxnc' {
		foreach arg in id ncomponents istates fstates indepvars compvarlist membership fullwexp constant entry entry_indepvars  {
			global `arg' ``arg''
		}
		quietly use `mmcm_dataset', clear	
		forvalues s=1/`ncomponents' {
			tempvar _pr_`s' _den_`s' _weight_`s' _pr_in_`s' sumprod_`s'
			forvalues j=1/`nistates' {
				forvalues k=1/`nfstates' {
					tempvar _p_`s'_`j'_`k'				
				}
			}
		}	
		* --------------------------------------------------------------------------
		* 2.5.1. Estimate a simple (n=1 component) Markov chain model 
		* --------------------------------------------------------------------------
		if `ncomponents' == 1 {
			display as result "Estimating a homogeneous discrete-state Markov chain model" _newline	
			capture drop _proba_1  
			quietly generate int _proba_1 = 1 	
			quietly my_mixmlogit 
			if "`entry'" != "" {
				matrix b_entry_`ncomponents'_1 = b_1 
				matrix V_entry_`ncomponents'_1 = V_1
				matrix varb_entry_`ncomponents'_1 = vecdiag(V_entry_`ncomponents'_1)
			}
			foreach j in `istates' {
				matrix b_`ncomponents'_1_`j' = b_1_`j' 
				matrix V_`ncomponents'_1_`j' = V_1_`j'
				matrix varb_`ncomponents'_1_`j' = vecdiag(V_`ncomponents'_1_`j')													
			}
			scalar bestll_lrem_`ncomponents' = ll	
		}
		* --------------------------------------------------------------------------
		*  2.5.2. Estimate mixture of (n >= 2 components) Markov chain model 
		* --------------------------------------------------------------------------	
		if `ncomponents' > 1 {
			display _newline as result "Estimating a `ncomponents'-components mixture of discrete-state Markov chain model" _newline
		
			*-----------------------------------------------------------------------
			* 2.5.2.1. Run EM algorithm several times to obtain optimal parameters 
			* ----------------------------------------------------------------------
			local lremconvs = 0 //scalar to increment when long run EM converged 
			if "`seed'" == "" local seed = 123456 		//default value
			set seed `seed' 							//specify the starting seed   			
			if "`nlr'" == "" local nlr = 5 				//default value
			if "`nlri'" == "" local nlri = 100 			//default value
			if "`eps'" == "" local eps = 0.0000001 		//default value				
			if "`nsr'" == "" local nsr = 5 				//default value
			if "`nsri'" == "" local nsri = 5 			//default value
			display as result "Searching for initial values ..."
			forvalues emi=1/`nlr' {
				local sremconvs = 0 //scalar to increment when short-run EM converged
	 
				*-------------------------------------------------------------------
				* 2.5.2.1.1. Perform short-run EMs to obtain initial values 
				* ------------------------------------------------------------------					
				forvalues sremi=1/`nsr' {
					quietly use `mmcm_dataset', clear
					quietly by `id':generate double `_p' = runiform() if _lst == 1  //make a random draw for each agent 
					quietly by `id':egen double `_pr' = sum(`_p')		
					quietly generate int `_component' = 1 if `_pr' <= 1/`ncomponents' 
					forvalues s=2/`ncomponents' {
						quietly replace `_component' = `s' if `_pr'>(`s'-1)*(round(1/`ncomponents'),0.01) & `_pr'<=`s'*(round(1/`ncomponents'),0.01) 
					}				
					quietly generate double `_dens' = 0
					if "`entry'" != "" {
						forvalues s=1/`ncomponents' {
							quietly generate double `_pr_in_`s'' = 1
							quietly mlogit _entry `entry_indepvars' if `_component'==`s' & _frst == 1 [`fullwexp'], robust iterate(10)
							foreach j in `istates' {
								quietly predict double _p_`s'_`j' if _frst == 1 & e(sample), outcome(`j')
								quietly replace `_pr_in_`s''=_p_`s'_`j' if _entry == `j' 
								quietly by `id': replace `_pr_in_`s''=`_pr_in_`s''[_n-1] if _frst != 1
							}
							quietly replace `_pr_in_`s'' = 1 if `_pr_in_`s''==.
						}
					}				
					forvalues s=1/`ncomponents' {
						local compdepvar `compdepvar' _proba_`s'
						quietly generate double `_pr_`s'' = 1		
						foreach j in `istates' {
							quietly mlogit _entry_`j' L.(`indepvars') if `_component'==`s' [`fullwexp'], robust baseoutcome(`j') iterate(10) `constant'
							foreach k in `fstates'  {
								if Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {
									quietly predict double _p_`s'_`j'_`k' if e(sample), outcome(`k') 
									quietly replace `_pr_`s''=_p_`s'_`j'_`k' if `_component' == `s' & _entry_`j' == `k' 
								}
							}
						}
						by `id': generate double `sumprod_`s''=exp(sum(ln(`_pr_`s''))) // compute product of transition probability over t period
						by `id': generate double `_den_`s'' = `sumprod_`s''[_N]
					}	
					forvalues s=1/`ncomponents' {
						quietly summarize `id' if `_component' == `s' & _lst == 1
						local N_`id'=r(N)
						quietly count if _lst == 1
						scalar _share_`s' = `N_`id''/r(N)
					}		
					forvalues s=1/`ncomponents' { 
						if "`entry_indepvars'" != "" quietly replace `_dens' = `_dens' + (_share_`s'*`_pr_in_`s''*`_den_`s'') 
						else quietly replace `_dens' = `_dens' + (_share_`s'*`_den_`s'')
					}				
					forvalues s=1/`ncomponents' {
						if "`entry_indepvars'" != "" quietly generate double _proba_`s' = (_share_`s'*`_pr_in_`s''*`_den_`s'')/`_dens' 
						else quietly generate double _proba_`s' = (_share_`s'*`_den_`s'')/`_dens'
					}
					local i = 0
					while `i' < `nsri' {	
						quietly my_mixmlogit
						local i =`i'+1	
					}
					if e(converged) != 0  {
						local sremconvs = `sremconvs'+1							
						if `sremconvs' == 1 {
							scalar sremll = ll
						}
						if (`sremconvs' == 1) | (ll > sremll) {
							scalar sremll = ll
							quietly tempfile bestsrem_dataset
							quietly save `bestsrem_dataset', replace 
						}
					}
				}			
				*------------------------------------------------------------------------------
				* 2.5.2.1.2. Perform Long-run EMs using optimal parameters from the short-run EMs  
				* -----------------------------------------------------------------------------		
				if `sremconvs' != 0 {
					if ("`emlog'" != "") display _newline as text _dup(1) "Long-run EM iterations: round "  as result `emi' _newline
					quietly use `bestsrem_dataset', clear
					local i = 0
					while `i' < `nlri' {
						quietly my_mixmlogit 
						if e(converged) != 0  {
							scalar ll_`i' = ll
							if ("`emlog'" != "") display as text "Interation `i':" as text _col(20) "log-likelihood = " as result ll_`i'
							if `i' > 1 {
								if (-(round(ll_`i',0.001)-round(ll_`=`i'-1',0.001))/round(ll_`=`i'-1',0.001)) <= `eps' {									
									continue, break
								}
							}
						}
						else continue, break
						local i = `i'+1
					}
					if `i' == `nlri' {
						local converged = 0
						display as text "(Warning: EM not converged)" _newline
					}
					else local converged = 1
					if e(converged) != 0  {
						local lremconvs = `lremconvs'+1
						if `lremconvs' == 1 {
							scalar bestll_lrem_`ncomponents' = ll
						}
						if (`lremconvs' == 1) | (ll > bestll_lrem_`ncomponents') {
							scalar bestll_lrem_`ncomponents' = ll
							scalar converged_`ncomponents' = `converged'
							if "`membership'" != "" { 
								matrix b_proba_`ncomponents' = b //save parameters for the long-run EM leading to the highest log-likelihood value
								matrix V_proba_`ncomponents' = V
								matrix varb_proba_`ncomponents' = vecdiag(V_proba_`ncomponents')
							}
							forvalues s=1/`ncomponents' {
								quietly summarize _proba_`s' if _lst == 1 
								scalar meanproba_`s' = r(mean)
								scalar sdproba_`s' = r(sd)
								if "`entry'" != "" {
									matrix b_entry_`ncomponents'_`s' = b_`s'
									matrix V_entry_`ncomponents'_`s' = V_`s'
									matrix varb_entry_`ncomponents'_`s' =  vecdiag(V_entry_`ncomponents'_`s')
								}
								foreach j in `istates' {
									matrix b_`ncomponents'_`s'_`j' = b_`s'_`j'
									matrix V_`ncomponents'_`s'_`j' = V_`s'_`j'
									matrix varb_`ncomponents'_`s'_`j' = vecdiag(V_`ncomponents'_`s'_`j')										
								}						
							}
						}
					}
					else {
						if ("`emlog'" != "") display as text "(Warning: bad initial values)" _newline
					}				
				}
			}
			if  `lremconvs' == 0 {
				display as error "Specified number of EM iterations has been reached."	
				display as error "Cannot find initial values within `nlr' long-run EM iterations."
				exit 498
			}
			matrix pi_`ncomponents' = J(4,`ncomponents',.)		
			forvalues s=1/`ncomponents' {
				local pi_`ncomponents'_colname `pi_`ncomponents'_colname' pi_`s'
				matrix pi_`ncomponents'[1,`s'] = meanproba_`s'
				matrix pi_`ncomponents'[2,`s'] = sdproba_`s'
				matrix pi_`ncomponents'[3,`s'] = meanproba_`s'-1.96*sdproba_`s'
				matrix pi_`ncomponents'[4,`s'] = meanproba_`s'+1.96*sdproba_`s'			
			}
			matrix colnames pi_`ncomponents' = `pi_`ncomponents'_colname'
		}	
		*------------------------------------------------------------------------------
		* 2.5.3. Compute information criteria, select optimal number of components and save parameters 
		* -----------------------------------------------------------------------------	
		scalar aic_`ncomponents' = -2*bestll_lrem_`ncomponents'+(2*ncparam_`ncomponents')
		scalar aic3_`ncomponents' = -2*bestll_lrem_`ncomponents'+(3*ncparam_`ncomponents')
		scalar bic_`ncomponents' = -2*bestll_lrem_`ncomponents'+(log(N)*ncparam_`ncomponents')
		scalar caic_`ncomponents' = -2*bestll_lrem_`ncomponents'+(log(N)+1)*(ncparam_`ncomponents')
		if `minnc' != `maxnc'  {
			scalar selcr_`ncomponents' = `selcr'_`ncomponents' 
			if (`ncomponents' > `minnc') {
				if (selcr_`ncomponents' < selcr_`=`ncomponents'-1') {
					local bestnc = `ncomponents'
				}
				else {
					if ("`force'" == "") continue, break
				}
			}	
		}
		if "`entry'" != "" {
			local b_entry_colnames: colnames b_entry_`bestnc'_1
			if `=strpos(`"`b_entry_colnames'"',"_cons")' != 0 local _cons2 _cons	
			local ncol_b_entry = colsof(b_entry_`bestnc'_1)
			forvalues s=1/`bestnc' {
				foreach j in `istates' {		
					foreach v in `entry_indepvars' `_cons2' {
						matrix b_entry_`bestnc'_`v'_`s'_`j' = b_entry_`bestnc'_`s'[1,"`j':`v'"]
						matrix varb_entry_`bestnc'_`v'_`s'_`j' = varb_entry_`bestnc'_`s'[1,"`j':`v'"]
						scalar b_entry_`bestnc'_`v'_`s'_`j' = b_entry_`bestnc'_`v'_`s'_`j'[1,1]
						scalar seb_entry_`bestnc'_`v'_`s'_`j' = sqrt(varb_entry_`bestnc'_`v'_`s'_`j'[1,1])
					}
				}
			}		
		}
		forvalues s=1/`bestnc' {			
			foreach j in `istates' {
				foreach k in `fstates' {
					if Cns_tpm[`j',`k'] != 0 {
						foreach v in `indepvars' {
							matrix b_`bestnc'_`v'_`s'_`j'_`k' = b_`bestnc'_`s'_`j'[1,"`k':L.`v'"]
							scalar b_`bestnc'_`v'_`s'_`j'_`k' = b_`bestnc'_`v'_`s'_`j'_`k'[1,1]
							matrix varb_`bestnc'_`v'_`s'_`j'_`k' = varb_`bestnc'_`s'_`j'[1,"`k':L.`v'"]
							scalar seb_`bestnc'_`v'_`s'_`j'_`k' = sqrt(varb_`bestnc'_`v'_`s'_`j'_`k'[1,1])
						}
						if "`constant'" == ""  {
							matrix b_`bestnc'__cons_`s'_`j'_`k' = b_`bestnc'_`s'_`j'[1,"`k':_cons"]
							scalar b_`bestnc'__cons_`s'_`j'_`k' = b_`bestnc'__cons_`s'_`j'_`k'[1,1]
							matrix varb_`bestnc'__cons_`s'_`j'_`k' = varb_`bestnc'_`s'_`j'[1,"`k':_cons"]
							scalar seb_`bestnc'__cons_`s'_`j'_`k' = sqrt(varb_`bestnc'__cons_`s'_`j'_`k'[1,1])
						}
					}
				}
			}
		}
		if "`membership'" != "" {
			if `ncomponents' != 1 {
				local b_proba_colnames: colnames b_proba_`ncomponents'
				if `=strpos(`"`b_proba_colnames'"',"_cons")' != 0 local _cons3 _cons		
				if `bestnc' != 1 {
					local ncol_b_proba = colsof(b_proba_`bestnc')
					forvalues s=1/`bestnc' {
						if `s' != 1 {
							foreach v in `compvarlist' `_cons3' {
								matrix b_`bestnc'_`v'_`s' = b_proba_`bestnc'[1,"eta__proba_`s':`v'"]
								mat varb_`bestnc'_`v'_`s' = varb_proba_`bestnc'[1,"eta__proba_`s':`v'"]
								scalar b_`bestnc'_`v'_`s' = b_`bestnc'_`v'_`s'[1,1]
								scalar seb_`bestnc'_`v'_`s' = sqrt(varb_`bestnc'_`v'_`s'[1,1])
							}
						}
					}		
				}
			}
		}
		local lastnc = `ncomponents'
	}
	* ------------------------------------------------------------------------------
	* 2.6. Output results
	* ------------------------------------------------------------------------------	
	if "`constant'" == "" local _cons1 cons1 //local to replace the constant term in the spacification of transitions probabilities
	if "`_cons2'" != "" local _cons2 cons2	//local to replace the constant term  in the spacification of entry probabilities 
	if "`_cons3'" != "" local _cons3 cons3 //local to replace the constant term  in the spacification of type membership probabilities
	if `minnc' != `lastnc'  {
		if "`membership'" != ""  {
			local b_proba_colnames: colnames b_proba_`lastnc'
		}
		forvalues s=1/`lastnc'  {
			if  "`membership'" != "" {
				foreach v in `compvarlist' `_cons3' {
					if `s' != 1 local colname_b_proba `colname_b_proba' proba`s'_`v'
				}
			}
			foreach j in `istates' {	
				if "`entry'" != "" {
					foreach v in `entry_indepvars' `_cons2' {
						local entry_colnames `entry_colnames' comp`s'_entry_`state_`j''_`v'
					}
				}		
				foreach k in `fstates' {	
					foreach v in `indepvars' `_cons1' {
						local colnames `colnames' comp`s'_`state_`j''_`state_`k''_`v'
					}
				}
			}
		}
		if "`membership'" != "" local ncols_b_proba = colsof(b_proba_`lastnc')
		local colname_vpi: colnames pi_`lastnc'
		local ncols = `=wordcount("`indepvars' `_cons1'")'*`nistates'*`nfstates'*`lastnc'
		forvalues ncomponents=`minnc'/`lastnc' {
			if "`membership'" != "" matrix b_pr_`ncomponents' = J(2,`ncols_b_proba',.)
			if "`membership'" != "" matrix colnames b_pr_`ncomponents' = `colname_b_proba'
			if "`membership'" != "" matrix coleq b_pr_`ncomponents' =  `coleq_b_proba'	
			matrix vpi_`ncomponents' = J(2,`lastnc',.)
			matrix colnames vpi_`ncomponents' = `colname_vpi'
			if (`ncomponents' == `minnc' & "`membership'" != "") matrix b_proba = vpi_`ncomponents',b_pr_`ncomponents' 
			matrix b_`ncomponents' = J(2,`ncols',0)
			matrix colnames b_`ncomponents' = `colnames'
			if "`entry'" != "" matrix b_entry_`ncomponents' = J(2,`=wordcount("`entry_indepvars' `_cons2'")'*`nistates'*`lastnc',.)
			if "`entry'" != "" matrix colnames b_entry_`ncomponents' = `entry_colnames'
			local l = 0
			forvalues s=1/`ncomponents' {	
				foreach j in `istates' {
					if "`entry'" != "" {
						foreach v in `entry_indepvars' {
							matrix b_entry_`ncomponents'[rownumb(b_entry_`ncomponents',"r1"), colnumb(b_entry_`ncomponents',"comp`s'_entry_`state_`j''_`v'")] = b_entry_`ncomponents'_`s'[1,"`j':`v'"]
							matrix b_entry_`ncomponents'[rownumb(b_entry_`ncomponents',"r2"), colnumb(b_entry_`ncomponents',"comp`s'_entry_`state_`j''_`v'")] = varb_entry_`ncomponents'_`s'[1,"`j':`v'"]
						}
						if "`_cons2'" != "" {
							matrix b_entry_`ncomponents'[rownumb(b_entry_`ncomponents',"r1"), colnumb(b_entry_`ncomponents',"comp`s'_entry_`state_`j''_cons2")] = b_entry_`ncomponents'_`s'[1,"`j':_cons"]
							matrix b_entry_`ncomponents'[rownumb(b_entry_`ncomponents',"r2"), colnumb(b_entry_`ncomponents',"comp`s'_entry_`state_`j''_cons2")] = varb_entry_`ncomponents'_`s'[1,"`j':_cons"]					
						}
					}
					foreach k in `fstates' {
						foreach v in `indepvars' {
							local l = `l'+1	
							if Cns_tpm[`j',`k'] != 0 {
								matrix b_`ncomponents'[1,`l'] = b_`ncomponents'_`s'_`j'[1,"`k':L.`v'"]	
								matrix b_`ncomponents'[2,`l'] = varb_`ncomponents'_`s'_`j'[1,"`k':L.`v'"]	
							}
						}
						if "`constant'" == "" {
							local l = `l'+1	
							if Cns_tpm[`j',`k'] != 0 {
								matrix b_`ncomponents'[1,`l'] = b_`ncomponents'_`s'_`j'[1,"`k':_cons"]	
								matrix b_`ncomponents'[2,`l'] = varb_`ncomponents'_`s'_`j'[1,"`k':_cons"]	
							}
						}
					}
				}
			}
			if `ncomponents' != 1 {
				forvalues p=1/`=colsof(pi_`ncomponents')' {
					matrix vpi_`ncomponents'[1,`p'] = pi_`ncomponents'[1,`p']
					matrix vpi_`ncomponents'[2,`p'] = pi_`ncomponents'[2,`p']
				}
				if "`membership'" != "" {
					forvalues vp=1/`= colsof(b_proba_`ncomponents')' {
						matrix b_pr_`ncomponents'[1,`vp'] = b_proba_`ncomponents'[1,`vp']
						matrix b_pr_`ncomponents'[2,`vp'] = varb_proba_`ncomponents'[1,`vp']
					}
				}
			}
		}
		forvalues ncomponents = `minnc'/`lastnc' {		
			matrix IC_`ncomponents' = J(2,7,.)	
			matrix colnames IC_`ncomponents' = ncomponents LL nparameters aic bic caic aic3	
			matrix IC_`ncomponents'[1,1] = `ncomponents'
			matrix IC_`ncomponents'[2,1] = `ncomponents'
			matrix IC_`ncomponents'[1,2] = bestll_lrem_`ncomponents'
			matrix IC_`ncomponents'[1,3] = ncparam_`ncomponents'
			matrix IC_`ncomponents'[1,4] = aic_`ncomponents'
			matrix IC_`ncomponents'[1,5] = bic_`ncomponents'
			matrix IC_`ncomponents'[1,6] = caic_`ncomponents'
			matrix IC_`ncomponents'[1,7] = aic3_`ncomponents'
			if "`detail'" != "" {
				if "`entry'" != "" matrix IC_b_`ncomponents' = IC_`ncomponents',b_entry_`ncomponents',b_`ncomponents',vpi_`ncomponents'
				else matrix IC_b_`ncomponents' = IC_`ncomponents',b_`ncomponents',vpi_`ncomponents'
				if "`membership'" != "" matrix IC_b_`ncomponents' = IC_b_`ncomponents',b_pr_`ncomponents'
				if (`ncomponents' == `minnc') matrix  IC_b = IC_b_`minnc'
				else matrix IC_b = IC_b\IC_b_`ncomponents'
			}
		}	
		if ("`save_options'" != "") {
			clear 
			if ("`detail'" == "") {
				forvalues ncomponents = `minnc'/`lastnc' {
					if (`ncomponents' == `minnc') matrix  IC = IC_`ncomponents'[1,1..7]		
					if (`ncomponents' > `minnc')  matrix  IC = IC\IC_`ncomponents'[1,1..7]
				}
				quietly svmat double IC, names(col) 
			}
			else {
				matrix ic_b=IC_b[1...,2...]
				local colname_ICtable: colnames ic_b 
				quietly svmat double IC_b, names(col)
				quietly bysort ncomponents: generate obs=_n
				quietly reshape wide `colname_ICtable', i(ncomponents) j(obs)
				foreach v in `colname_ICtable' {
					quietly rename `v'1 `v'
					quietly rename `v'2 `v'1
				}
				foreach v in `indepvars' `_cons1' `entry_indepvars' `_cons2'   {
					if `=strpos(`"`varlist1'"',"`v'")' == 0 local varlist1 `varlist1' @`v' @`v'1
					if `=strpos(`"`varlist2'"',"`v'")' == 0 local varlist2 `varlist2' `v' `v'1
					if `=strpos(`"`indepvarlist'"',"`v'")' == 0 local indepvarlist `indepvarlist' `v' 
				}
				quietly generate obs=_n
				quietly reshape long `varlist1', i(obs) j(comp) string	
				if "`membership'" != "" {
				quietly replace obs=_n
					foreach v in `compvarlist' `_cons3' {
						local varlist3 `varlist3' @`v' @`v'1
						local varlist4 `varlist4' `v' `v'1
					}
					quietly reshape long `varlist3', i(obs) j(proba) string
				}
				quietly split comp, p(_)
				quietly rename comp2 ist
				quietly rename comp3 fst
				quietly generate component = .
				if "`membership'" != "" quietly split proba, p(_)
				if "`membership'" != "" quietly generate membership = .
				forvalues s=1/`lastnc' {
					quietly rename pi_`s'1 var_pi_`s'
					quietly replace component = `s' if comp1 == "comp`s'"
					quietly drop if ncomponents == `s' & component > `s'
					if "`membership'" != "" quietly replace membership = `s' if proba1 == "proba`s'" & ncomponents != 1
					if "`membership'" != "" & (`s' != 1) quietly drop if ncomponents == `s' & membership > `s'
				}
				if "`membership'" != "" drop membership proba proba1			
				quietly replace obs=_n
				quietly reshape long pi_ var_pi_, i(obs) j(pi)
				quietly drop if  pi != component
				quietly replace pi_ = 1 if ncomponents == 1
				quietly drop LL1 nparameters1 aic1 bic1 caic1 aic31 comp comp1 obs pi
				order ncomponents LL nparameters aic bic caic aic3 component ist fst `varlist2' `varlist4' pi_ var_pi_
				foreach v in LL nparameters aic bic caic aic3 `varlist2' `varlist4' pi_ var_pi_ {
					label var `v' "`v'"
				}
				label var ncomponents "Number of components"
				label var component "component Number"
				label var ist "initial state"
				label var fst "final state"
				label var nparameters "Number of parameters"
				label var pi_ "type share"
				label var var_pi_ "type share variance"
				foreach v in `indepvarlist' `compvarlist' `_cons3' {
					quietly rename `v' b_`v'
					quietly replace `v'1 = sqrt(`v'1)
					quietly rename `v'1 se_`v'
				}
				foreach v in `_cons2' `_cons3' {
					if "`v'" != ""  {
						quietly replace b_cons1 = b_`v' if b_`v' !=.
						quietly replace se_cons1 = se_`v' if se_`v' !=.
						drop b_`v' se_`v'
					}
				}
				order b_cons1 se_cons1 pi_ var_pi_, last
				quietly duplicates drop
			}
			quietly save "`filename'", `replacefile' //save as dataset		
		}
		if `"`graph_options'"' != "" {
			foreach criterion of local criteria {
				local l_`criterion' "(line `criterion' ncomponents)"
			}
			twoway `l_aic' `l_bic' `l_caic' `l_aic3' `twoway_options' //display graphic of selected infromation criteria	
		}	
	}
	if "`constant'" == "" local _cons1 cons //local to indicate the constant term in the spacification of transitions probabilities
	if "`_cons2'" != "" local _cons2 cons	//local to indicate the constant term  in the spacification of entry probabilities 
	if "`_cons3'" != "" local _cons3 cons 	//local to indicate the constant term  in the spacification of type membership probabilities
	forvalues s=1/`bestnc' {
		foreach j in `istates' {
			foreach k in `fstates' {
				foreach v in `indepvars' `_cons1' {
					if (Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] == .) local coln_`s'_`j' `coln_`s'_`j'' p_`s'_`j'_`k'_`v'	
				}	
			}
			foreach k in `fstates' {	
				if Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {
					matrix A_`s'_`j'_`k'= b_`bestnc'_`s'_`j'[1,"`k':"]
					local vcolnames_`s'_`j'_`k' : colnames A_`s'_`j'_`k'
				}		
				else {
					foreach v in `indepvars'  {
						local vcolnames_`s'_`j'_`k' `vcolnames_`s'_`j'_`k'' L.`v'
					}
					if "`constant'" == "" local vcolnames_`s'_`j'_`k' `vcolnames_`s'_`j'_`k'' _cons			
				}
				local vcolnames_`s'_`j' `vcolnames_`s'_`j'' `vcolnames_`s'_`j'_`k''
				foreach v in `indepvars' `_cons1' {
					local vcoleq_`s'_`j' `vcoleq_`s'_`j'' p_`s'_`state_`j''_`state_`k''
					local fullcoln_`s'_`j' `fullcoln_`s'_`j'' p_`s'_`j'_`k'_`v'
				}
			}
			if "`entry'" != "" {
				foreach v in `entry_indepvars' `_cons2' {
					local vcoleq_entry_`s'_`j' `vcoleq_entry_`s'_`j''  p_entry_`s'_`state_`j''
					local fullcoln_entry_`s'_`j' `fullcoln_entry_`s'_`j'' p_entry_`s'_`j'_`v'
				}
				local fullcoln_entry_`s' `fullcoln_entry_`s'' `fullcoln_entry_`s'_`j''	
				local vcoleq_entry_`s' `vcoleq_entry_`s''  `vcoleq_entry_`s'_`j''			
			}
			local fullcoln_`s' `fullcoln_`s'' `fullcoln_`s'_`j''
			local vcolnames_`s' `vcolnames_`s'' `vcolnames_`s'_`j'' 
			local vcoleq_`s' `vcoleq_`s'' `vcoleq_`s'_`j''
		}
		local fullcoln `fullcoln' `fullcoln_entry_`s'' `fullcoln_`s''
		local vcolnames `vcolnames' `b_entry_colnames' `vcolnames_`s''	
		local vcoleq `vcoleq' `vcoleq_entry_`s'' `vcoleq_`s'' 
	}
	foreach M in b V {
		forvalues s=1/`bestnc' {
			foreach j in `istates'  {
				matrix coleq `M'_`bestnc'_`s'_`j' = _:	
				if ("`M'"=="V") matrix roweq `M'_`bestnc'_`s'_`j' = _:
				matrix colnames `M'_`bestnc'_`s'_`j' = `coln_`s'_`j''
				if ("`M'"=="V") matrix rownames V_`bestnc'_`s'_`j' = `coln_`s'_`j''
			}
			if "`entry'" != "" {
				matrix coleq `M'_entry_`bestnc'_`s' = _:	
				if ("`M'" == "V") matrix roweq V_entry_`bestnc'_`s' = _:
				matrix colnames `M'_entry_`bestnc'_`s' = `fullcoln_entry_`s''
				if ("`M'" == "V") matrix rownames V_entry_`bestnc'_`s' = `fullcoln_entry_`s''
			}		
		}
	}
	if "`entry'" != "" local ncols = `bestnc'*(`nistates'*(`nfstates'*`=wordcount("`indepvars' `_cons1'")'+`=wordcount("`entry_indepvars' `_cons2'")'))
	else local ncols = `bestnc'*`nistates'*`nfstates'*`=wordcount("`indepvars' `_cons1'")'
	matrix b_tpm=J(1,`ncols',0) 		//full coefficient matrix
	matrix colnames b_tpm = `fullcoln'
	matrix V_tpm=J(`ncols',`ncols',0) 	//full covariance matrix 
	matrix colnames V_tpm = `fullcoln'
	matrix rownames V_tpm = `fullcoln'
	forvalues s=1/`bestnc' {
		foreach j in `istates'  {
			if "`entry'" != "" {
				foreach v1 in `entry_indepvars' `_cons2' {
					matrix b_tpm[rownumb(b_tpm,"r1"), colnumb(b_tpm,"p_entry_`s'_`j'_`v1'")] = b_entry_`bestnc'_`s'["y1","p_entry_`s'_`j'_`v1'"]				
					foreach v2 in `entry_indepvars' `_cons2' {
						matrix V_tpm[rownumb(V_tpm,"p_entry_`s'_`j'_`v1'"), colnumb(V_tpm,"p_entry_`s'_`j'_`v2'")] = V_entry_`bestnc'_`s'["p_entry_`s'_`j'_`v1'","p_entry_`s'_`j'_`v2'"]
					}
				}
			}
			foreach k in `fstates'  {
				if Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {
					foreach v3 in `indepvars' `_cons1' {
						matrix b_tpm[rownumb(b_tpm,"r1"), colnumb(b_tpm,"p_`s'_`j'_`k'_`v3'")] = b_`bestnc'_`s'_`j'["y1","p_`s'_`j'_`k'_`v3'"]				
						foreach v4 in `indepvars' `_cons1' {
							matrix V_tpm[rownumb(V_tpm,"p_`s'_`j'_`k'_`v3'"), colnumb(V_tpm,"p_`s'_`j'_`k'_`v4'")]=V_`bestnc'_`s'_`j'["p_`s'_`j'_`k'_`v4'","p_`s'_`j'_`k'_`v3'"]
						}
					}
				}
			}			
		}
	}
	matrix colnames b_tpm = `vcolnames'	
	matrix colnames V_tpm = `vcolnames'	
	matrix coleq b_tpm = `vcoleq'
	matrix coleq V_tpm = `vcoleq'
	matrix rownames V_tpm = `vcolnames'
	matrix roweq V_tpm = `vcoleq'	
	if (`bestnc' != 1) {
		matrix rownames pi_`bestnc' = Mean SD
		matrix vpi = pi_`bestnc'[1..2,1..`bestnc'] 
	}
	* ------------------------------------------------------------------------------
	* 2.7. Store and display results
	* ------------------------------------------------------------------------------
	ereturn clear
	foreach k in `fstates' {
		local states `states' `state_`k''
		global state_`k' `state_`k''
	}
	ereturn local seed `seed'
	if `minnc' != `lastnc' {
		ereturn local selcrit `selcr'
	}	
	if "`weight'" != ""   {
		ereturn local wexp `exp'
		ereturn local wtype `weight'	
	}
	if "`membership'" != "" { 
		ereturn local mpf "fmlogit"
		if ("`compvarlist'" != "") ereturn local compvars `compvarlist'
	}
	ereturn local entry_indepvars `entry_indepvars'
	ereturn local entry_var `entry_depvar'
	ereturn local indepvars `indepvars'
	ereturn local exitcode `exitcode'
	ereturn local states `states'
	ereturn local depvar `depvar'
	ereturn local id `id'
	ereturn local cmdline `0'
	if (`bestnc' == 1) ereturn local title "Homogeneous discrete-state Markov chain model"
	if (`bestnc' >= 2) ereturn local title "`bestnc'-component mixture of discrete-state discrete-time Markov chain models"
	ereturn local cmd "mixmcm"
	ereturn scalar N_components = `bestnc'
	if `minnc' != `lastnc' {
		ereturn scalar min_components = `minnc'
		ereturn scalar max_components = `lastnc'
	}
	ereturn scalar ll = bestll_lrem_`bestnc'
	ereturn scalar N = N	
	ereturn scalar N_id = Ni	
	ereturn scalar k = ncparam_`bestnc'
	ereturn scalar aic = aic_`bestnc'
	ereturn scalar aic3 = aic3_`bestnc'
	ereturn scalar bic = bic_`bestnc'
	ereturn scalar caic = caic_`bestnc'
	if (`bestnc' != 1) ereturn scalar converged = converged_`bestnc'
	ereturn matrix Cns_tpm = Cns_tpm
	if (`bestnc' != 1) {
		ereturn matrix pi = vpi
		if "`membership'" != "" {	
			ereturn matrix V_proba = V_proba_`bestnc'
			ereturn matrix b_proba = b_proba_`bestnc'		
		}
	}
	ereturn matrix V_tpm = V_tpm
	ereturn matrix b_tpm = b_tpm
	Replay 		// Display estimation results 
	restore 	// restore the original dataset 
end

* ------------------------------------------------------------------------------
* 3. Draw table of results
* ------------------------------------------------------------------------------
capture program drop Replay	
program Replay	

	local bestnc = e(N_components)
	local minnc = e(min_components)
	local lastnc = e(max_components)
	if `minnc' != `lastnc' {
		if (`bestnc' == 1) display as result _newline "Homogeneous discrete-state Markov chain model."
		else display as result _newline "`bestnc'-components mixture of discrete-state Markov chain model."
		local selcr = e(selcrit)
	}
	matrix Cns_tpm = e(Cns_tpm)
	display as text _newline "log-likelihood = " as result `e(ll)' _col(57) as text "Number of obs" _col(72) as text "= " as result N
	display as text "" _col(57) as text "Number of id" _col(72) as text "= " as result Ni
	display as text " "		
	display as text "{hline 13}{c TT}{hline 64}"	
	display as text _col(14)"{c |} 		"  _col(27)"Robust"												
	display as text _col(14)"{c |}	coef." _col(27)"Std. Err." 	_col(41)"z"	_col(49)"p>|z|"	_col(58)"[95% Conf.  Interval]"
	forvalues s=1/`bestnc' {
		if `bestnc' >= 2 {
			display as text "{hline 13}{c BT}{hline 64}"		
			display as result "Component `s'"
		}
		if "`e(entry_var)'" != "" {	
			local b_entry_colnames: colnames b_entry_`bestnc'_`s'
			if `=strpos(`"`b_entry_colnames'"',"_cons")' != 0 local _cons1 _cons
			display as text "{hline 13}{c BT}{hline 64}"					
			display as result "Entry probabilities"
			display as text "{hline 13}{c TT}{hline 64}"																					
			foreach j in $istates {	
				if "`j'" == "`=word("$istates",1)'" {
					display as result "{ralign 12: ${state_`j'}}" _col(14) as text "{c |} (baseoutcome)"
					display as text "{hline 13}{c +}{hline 64}"	
				}
				else {
					display as result "${state_`j'}" _col(14) as text "{c |}" 
					foreach v in $entry_indepvars `_cons1' {
						local abname = abbrev("`v'",12)
						if seb_entry_`bestnc'_`v'_`s'_`j' != 0 {
							display as text "{ralign 12:`abname'}" _col(14)"{c |} " as result %9.0g b_entry_`bestnc'_`v'_`s'_`j' _col(27)%9.0g seb_entry_`bestnc'_`v'_`s'_`j' ///
											_col(35)%9.2f `=b_entry_`bestnc'_`v'_`s'_`j'/seb_entry_`bestnc'_`v'_`s'_`j'' _col(45)%9.3f `=2*(1-normal(abs(`=b_entry_`bestnc'_`v'_`s'_`j'/seb_entry_`bestnc'_`v'_`s'_`j'')))'  ///
											_col(58)%9.0g `=b_entry_`bestnc'_`v'_`s'_`j'-1.96*seb_entry_`bestnc'_`v'_`s'_`j'' _col(70)%9.0g `=b_entry_`bestnc'_`v'_`s'_`j'+1.96*seb_entry_`bestnc'_`v'_`s'_`j''
						}
						if seb_entry_`bestnc'_`v'_`s'_`j' == 0 {
							display as text "{ralign 12:`abname'}" _col(14)"{c |} " as result "0 (omitted)"
						}
					}
				}
			}
		}
		display as text "{hline 13}{c BT}{hline 64}"					
		display as result "Transition probabilities"
		display as text "{hline 13}{c TT}{hline 64}"							
		foreach j in $istates {
			local b_tpm_colname: colnames b_`bestnc'_`s'_`j'
			if `=strpos(`"`b_tpm_colname'"',"_cons")' != 0 local _cons _cons				
			if ("`j'" != "`=word("$istates",1)'") display as text "{hline 13}{c +}{hline 64}"																						
			display as result "{ralign 12: ${state_`j'}}" _col(14) as text "{c |} initial state"
			display as text "{hline 13}{c +}{hline 64}"																			
			foreach k in $fstates {
				if "`k'" != "`j'" & Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] != 0 {	
					display as result "${state_`k'}" _col(14) as text "{c |}" 
					foreach v in `e(indepvars)' `_cons'{
						local abname = abbrev("`v'",12)
						display as text "{ralign 12:`abname'}" _col(14)"{c |} " as result %9.0g b_`bestnc'_`v'_`s'_`j'_`k' _col(27)%9.0g seb_`bestnc'_`v'_`s'_`j'_`k' ///
						_col(35)%9.2f `=b_`bestnc'_`v'_`s'_`j'_`k'/seb_`bestnc'_`v'_`s'_`j'_`k'' _col(45)%9.3f `=2*(1-normal(abs(`=b_`bestnc'_`v'_`s'_`j'_`k'/seb_`bestnc'_`v'_`s'_`j'_`k'')))'  ///
						_col(58)%9.0g `=b_`bestnc'_`v'_`s'_`j'_`k'-1.96*seb_`bestnc'_`v'_`s'_`j'_`k'' _col(70)%9.0g `=b_`bestnc'_`v'_`s'_`j'_`k'+1.96*seb_`bestnc'_`v'_`s'_`j'_`k''
					}
				}
				if "`k'" != "`j'" & Cns_tpm[rownumb(Cns_tpm,"`j'"), colnumb(Cns_tpm,"`k'")] == 0 {
					display as result "${state_`k'}" _col(14) as text "{c |}" 
					foreach v in `e(indepvars)' `_cons'{
						local abname = abbrev("`v'",12)
						display as text "{ralign 12:`abname'}" _col(14)"{c |} " as result "0 (omitted)"
					}
				}
			}
		}
	}
	display as text "{hline 13}{c BT}{hline 64}"	
	if (`bestnc' != 1)	{
		display _newline
		display as result "Type shares"
		display as text "{hline 13}{c TT}{hline 23}"	
		display as text _col(14)"{c |}	Mean" _col(27)"Std. Dev." 
		display as text "{hline 13}{c +}{hline 23}"		
		forvalues s=1/`bestnc' {
			display as text "{ralign 12:pi`s'}" _col(14)"{c |} " as result %9.0g pi_`bestnc'[1,`s'] _col(27)%9.0g pi_`bestnc'[2,`s'] 
		}
		display as text "{hline 13}{c BT}{hline 23}"			
		if "`e(mpf)'" != "" {
			display _newline
			display as result "Membership probabilities"
			local b_proba_colname: colnames e(b_proba)
			if `=strpos(`"`b_proba_colname'"',"_cons")' != 0 local _cons2 _cons	
			display as text "{hline 13}{c TT}{hline 64}"	
			display as text _col(14)"{c |} 		"  _col(27)"Robust"												
			display as text _col(14)"{c |}	coef." _col(27)"Std. Err." 	_col(41)"z"	_col(49)"p>|z|"	_col(58)"[95% Conf.  Interval]"
			forvalues s = 1/`bestnc' {
				if `s' == 1 {
					display as text "{hline 13}{c +}{hline 64}"	
					display as result "{ralign 12: proba1}" _col(14) as text "{c |} (baseoutcome)"
				}
				else {
					display as text "{hline 13}{c +}{hline 64}"	
					display as result "proba`s'" _col(14) as text "{c |}" 
					foreach v in `e(compvars)' `_cons2' {
						local abname = abbrev("`v'",12)
						display as text "{ralign 12:`abname'}" _col(14)"{c |} " as result %9.0g b_`bestnc'_`v'_`s' _col(27)%9.0g seb_`bestnc'_`v'_`s' ///
										_col(35)%9.2f `=b_`bestnc'_`v'_`s'/seb_`bestnc'_`v'_`s'' _col(45)%9.3f `=2*(1-normal(abs(`=b_`bestnc'_`v'_`s'/seb_`bestnc'_`v'_`s'')))'  ///
										_col(58)%9.0g `=b_`bestnc'_`v'_`s'-1.96*seb_`bestnc'_`v'_`s'' _col(70)%9.0g `=b_`bestnc'_`v'_`s'+1.96*seb_`bestnc'_`v'_`s''
					}
				}
			}
			display as text "{hline 13}{c BT}{hline 64}"	
		}
		display as text "Model estimated via expectation-maximization (EM) algorithm."			
	}
	if `minnc' != `lastnc' {
		display as text _newline "`=strupper("`selcr'")' values are used to identify the optimal number of components."
	}
end
* ------------------------------------------------------------------------------
* 4. Program (mixmcm) end
* ------------------------------------------------------------------------------
