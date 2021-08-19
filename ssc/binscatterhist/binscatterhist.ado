*! version 2.2 01jan2020  Matteo Pinna, matteo.pinna@gess.ethz.ch

* Versions:
* version 1.1 partly fixes the display of multiple graphs, sets default values for xmin and ymin, add twoway general options to the histograms and solves some bugs in the error messages
* version 1.2 changes the command name, the default width to 100% and default color style of the bars
* version 1.3 varies the method of scatterpoints retrieving to avoid intermediate files and makes the program an rclass program, adding the possibility to ereturn the values from the reg/areg used to get residuals
* version 1.4 adds some warnings and fixes some issues in the help file
* version 2.0 adds an option to report automatically coefficient (s.e.) and/or sample size with or without p-value stars. Uses reghdfe as default, but option areg can be alternatively specified. Furthermore, allows for clustered or robust standard errors for the coefficient report, modifying therefore the sample for residualization and for estimation.
* version 2.1 fixes a compatibility problem with older STATA versions, of the new options coefficient and sample (stata <16) and transparency of colors (stata<15)
* version 2.2 fixes an issue with color compatibility and adds rounding option for coefficient reporting

/*
This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.  
The full legal text as well as a human-readable summary can be accessed at http://creativecommons.org/licenses/by-nc-sa/4.0/
*/

* Any feedback on issues and possible new features is very welcome.

* This program is based on the original binscatter by Michael Stepner (2013): "BINSCATTER: Stata module to generate binned scatterplots" - https://EconPapers.repec.org/RePEc:boc:bocode:s457709 and uses Ben Jann (2014): "ADDPLOT: Stata module to add twoway plot objects to an existing twoway graph," Statistical Software Components S457917, Boston College Department of Economics, revised 28 Jan 2015 <https://ideas.repec.org/c/boc/bocode/s457917.html>
program define binscatterhist, rclass sortpreserve

local stata_version=c(version)

	version 12.1
	syntax varlist(min=2 numeric) [if] [in] [aweight fweight], [by(varname) ///
		Nquantiles(integer 20) GENxq(name) discrete xq(varname numeric) MEDians ///
		CONTROLs(varlist numeric ts fv) absorb(varlist) noAddmean REGtype(string) ///
		LINEtype(string) rd(numlist ascending) reportreg ///
		COLors(string) MColors(string) LColors(string) Msymbols(string) ///
		savegraph(string) savedata(string) replace ///
		nofastxtile randvar(varname numeric) randcut(real 1) randn(integer -1) ///
		/* LEGACY OPTIONS */ nbins(integer 20) create_xq x_q(varname numeric) symbols(string) method(string) unique(string) ///
		/* standard errors */ CLUSTer(varname) vce(string) ///
		/* coefficient display */ COEFficient(string) sample stars(string) ///
		/* histogram options */ HISTogram(string) XMin(string) YMin(string) xhistbarheight(string) yhistbarheight(string) xhistbarwidth(string) yhistbarwidth(string) xhistbins(string) yhistbins(string) ///
		/* histogram esthetic options */ xcolor(string) xcfcolor(string) xfintensity(string) xlcolor(string) xlwidth(string) xlpattern(string) xlalign(string) xlstyle(string) xbstyle(string) xpstyle(string) ycolor(string) ycfcolor(string) yfintensity(string) ylcolor(string) ylwidth(string) ylpattern(string) ylalign(string) ylstyle(string) ybstyle(string) ypstyle(string) ///
		*]
		
	set more off

	* Parse varlist into y-vars and x-var
	local x_var=word("`varlist'",-1)
	local y_vars=regexr("`varlist'"," `x_var'$","")
	local ynum=wordcount("`y_vars'")
	
	* Create convenient weight local
	if ("`weight'"!="") local wt [`weight'`exp']
	
	***** Begin legacy option compatibility code
	
	if (`nbins'!=20) {
		if (`nquantiles'!=20) {
			di as error "Cannot specify both nquantiles() and nbins(): both are the same option, nbins is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option nbins() has been renamed nquantiles(), and is supported only for backward compatibility."
		local nquantiles=`nbins'
	}
	
	if ("`create_xq'"!="") {
		if ("`genxq'"!="") {
			di as error "Cannot specify both genxq() and create_xq: both are the same option, create_xq is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option create_xq has been renamed genxq(), and is supported only for backward compatibility."
		local genxq="q_"+word("`varlist'",-1)
	}
	
	if ("`x_q'"!="") {
		if ("`xq'"!="") {
			di as error "Cannot specify both xq() and x_q(): both are the same option, x_q() is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option x_q() has been renamed xq(), and is supported only for backward compatibility."
		local xq `x_q'
	}
	
	if ("`symbols'"!="") {
		if ("`msymbols'"!="") {
			di as error "Cannot specify both msymbols() and symbols(): both are the same option, symbols() is supported only for backward compatibility."
			exit
		}
		di as text "NOTE: legacy option symbols() has been renamed msymbols(), and is supported only for backward compatibility."
		local msymbols `symbols'
	}
	
	if ("`linetype'"=="noline") {
		di as text "NOTE: legacy line type 'noline' has been renamed 'none', and is supported only for backward compatibility."
		local linetype none
	}
	
	if ("`method'"!="") {
		di as text "NOTE: method() is no longer a recognized option, and will be ignored. binscatter now always uses the fastest method without a need for two instances."
	}
	
	if ("`unique'"!="") {
		di as text "NOTE: unique() is no longer a recognized option, and will be ignored. binscatter now considers the x-variable discrete if it has fewer unique values than nquantiles()."
	}
	
	if ("`histogram'"!="") & ("`histogram'"!="`x_var' `y_vars'") & ("`histogram'"!="`y_vars' `x_var'") & ("`histogram'"!="`x_var'") & ("`histogram'"!="`y_vars'") {
	di as error "Option histogram() must include either one or both variables graphed in the binscatter."
	}

	if ("`histogram'"=="") & (("`xmin'"!="") | ("`ymin'"!="") | (("`xmin'"!="") & ("`ymin'"!=""))) {
	di as error "Options ymin() and/or xmin() are only allowed together with histogram()."
	}

	if ("`histogram'"=="") & (("`xhistbarheight'"!="") | ("`xhistbarwidth'"!="") | ("`xhistbins'"!="") | ("`yhistbarheight'"!="") | ("`yhistbarwidth'"!="") | ("`yhistbins'"!="")) {
	di as error "Options *histbarwidth() and/or *histbarheight() and/or *histbins() are only allowed together with histogram()."
	}
	
	if ("`regtype'"!="") & ("`regtype'"!="reghdfe") & ("`regtype'"!="areg") {
	di as error "Option regtype() can only be areg or reghdfe - reghdfe is the default."
	}	
	
	if ("`cluster'"!="") & ("`vce'"!="") {
	di as error "Options cluster() and vce() cannot be specified together."
	}	
	
	if ("`linetype'"=="none") & (("`coefficient'"!="") | ("`sample'"!="")) {
	di as error "Coefficient and sample size are estimated through the line fitting."
	}	
	
	if ("`vce'"!="") & ("`vce'"!="robust") {
	di as error "Use vce(robust) for robust s.e. or cluster(varname) for clustered s.e."
	}	
	
	if ("`stars'"!="") & ("`stars'"!="nostars") & ("`stars'"!="1") & ("`stars'"!="2") & ("`stars'"!="3") & ("`stars'"!="4") {
	di as error "Option stars() can only be: nostars, 1, 2, 3, 4."
	}
	
	***** End legacy option capatibility code

	*** Perform checks

	* addplot check
	capt which addplot
	if _rc !=0 {
	di as error "Binscatterhist requires addplot to be installed. Addplot can be installed by typing ssc install addplot"
	}

	if ("`regtype'"=="") | ("`regtype'"=="reghdfe"){
	* reghdfe check
	capt which reghdfe
		if _rc !=0 {
		di as error "Binscatterhist requires reghdfe to be installed. Reghdfe can be installed by typing ssc install reghdfe"
		}
	}
	
	* Set default linetype and check valid
	if ("`linetype'"=="") local linetype lfit
	else if !inlist("`linetype'","connect","lfit","qfit","none") {
		di as error "linetype() must either be connect, lfit, qfit, or none"
		exit
	}
	
	* Check that nofastxtile isn't combined with fastxtile-only options
	if "`fastxtile'"=="nofastxtile" & ("`randvar'"!="" | `randcut'!=1 | `randn'!=-1) {
		di as error "Cannot combine randvar, randcut or randn with nofastxtile"
		exit
	}

	* Misc checks
	if ("`genxq'"!="" & ("`xq'"!="" | "`discrete'"!="")) | ("`xq'"!="" & "`discrete'"!="") {
		di as error "Cannot specify more than one of genxq(), xq(), and discrete simultaneously."
		exit
	}
	if ("`genxq'"!="") confirm new variable `genxq'
	if ("`xq'"!="") {
		capture assert `xq'==int(`xq') & `xq'>0
		if _rc!=0 {
			di as error "xq() must contain only positive integers."
			exit
		}
		
		if ("`controls'`absorb'"!="") di as text "warning: xq() is specified in combination with controls() or absorb(). note that binning takes places after residualization, so the xq variable should contain bins of the residuals."
	}
	if `nquantiles'!=20 & ("`xq'"!="" | "`discrete'"!="") {
		di as error "Cannot specify nquantiles in combination with discrete or an xq variable."
		exit
	}
	if "`reportreg'"!="" & !inlist("`linetype'","lfit","qfit") {
		di as error "Cannot specify 'reportreg' when no fit line is being created."
		exit
	}
	if "`replace'"=="" {
		if `"`savegraph'"'!="" {
			if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") confirm new file `"`savegraph'"'
			else confirm new file `"`savegraph'.gph"'
		}
		if `"`savedata'"'!="" {
			confirm new file `"`savedata'.csv"'
			confirm new file `"`savedata'.do"'
		}
	}

	* Mark sample (reflects the if/in conditions, and includes only nonmissing observations) - the sample must also exclude singletons if a reghdfe is run
		if `"`absorb'"'!="" {
			if ("`regtype'"=="")|("`regtype'"=="reghdfe") {
			cap qui reghdfe `y_vars', absorb(`absorb')
			tempvar singleton_dropped
			cap qui gen `singleton_dropped'=1 if e(sample)
			}			
		}
	marksample touse
	markout `touse' `by' `xq' `controls' `absorb' `addvce' `addresid' `singleton_dropped', strok
	qui count if `touse'
	local samplesize=r(N)
	local touse_first=_N-`samplesize'+1
	local touse_last=_N
	
	* Check number of unique byvals & create local storing byvals
	if "`by'"!="" {
		local byvarname `by'
	
		capture confirm numeric variable `by'
		if _rc {
			* by-variable is string => generate a numeric version
			tempvar by
			tempname bylabel
			egen `by'=group(`byvarname'), lname(`bylabel')
		}
		
		local bylabel `:value label `by'' /*catch value labels for numeric by-vars too*/ 
		
		tempname byvalmatrix
		qui tab `by' if `touse', nofreq matrow(`byvalmatrix')
		
		local bynum=r(r)
		forvalues i=1/`bynum' {
			local byvals `byvals' `=`byvalmatrix'[`i',1]'
		}
	}
	else local bynum=1
	
	******  Standard errors  ******
		
		if ("`cluster'"!="") {
		local addcluster="cluster(`cluster')"
		}
		if ("`vce'"!="") {
		local addvce="vce(`vce')"
		}

	******  Create residuals  ******
	
	if (`"`controls'`absorb'"'!="") quietly {
	
		* Parse absorb to define the type of regression to be used
		if `"`absorb'"'!="" {
		local absorb "absorb(`absorb')"
			if ("`regtype'"=="")|("`regtype'"=="reghdfe") {
			local regtype "reghdfe"
			local addresid="resid"
			}
			if ("`regtype'"=="areg") {
			local regtype "areg"
			}
		}
		else {
			local regtype "reg"
		}
	
		* Generate residuals
		
		local firstloop=1
		foreach var of varlist `x_var' `y_vars' {
			tempvar residvar
			`regtype' `var' `controls' `wt' if `touse', `absorb' `addcluster' `addvce' `addresid'
			predict `residvar' if e(sample), residuals
			if ("`addmean'"!="noaddmean") {
				summarize `var' `wt' if `touse', meanonly
				replace `residvar'=`residvar'+r(mean)
			}
			
			label variable `residvar' "`var'"
			if `firstloop'==1 {
				local x_r `residvar'
				local firstloop=0
			}
			else local y_vars_r `y_vars_r' `residvar'
		}
		
	}
	else { 	/*absorb and controls both empty, no need for regression*/
		local x_r `x_var'
		local y_vars_r `y_vars'
	}

	****** Regressions for fit lines ******
	
	if ("`reportreg'"=="") local reg_verbosity "quietly"

	if inlist("`linetype'","lfit","qfit") `reg_verbosity' {

		* If doing a quadratic fit, generate a quadratic term in x
		if "`linetype'"=="qfit" {
			tempvar x_r2
			gen `x_r2'=`x_r'^2
		}
		
		* Create matrices to hold regression results
		tempname e_b_temp
		forvalues i=1/`ynum' {
			tempname y`i'_coefs
		}
		
		* LOOP over by-vars
		local counter_by=1
		if ("`by'"=="") local noby="noby"
		foreach byval in `byvals' `noby' {
		
			* LOOP over rd intervals
			tokenize  "`rd'"
			local counter_rd=1	
				
			while ("`1'"!="" | `counter_rd'==1) {
			
				* display text headers
				if "`reportreg'"!="" {
					di "{txt}{hline}"
					if ("`by'"!="") {
						if ("`bylabel'"=="") di "-> `byvarname' = `byval'"
						else {
							di "-> `byvarname' = `: label `bylabel' `byval''"
						}
					}
					if ("`rd'"!="") {
						if (`counter_rd'==1) di "RD: `x_var'<=`1'"
						else if ("`2'"!="") di "RD: `x_var'>`1' & `x_var'<=`2'"
						else di "RD: `x_var'>`1'"
					}
				}
				
				* set conditions on reg
				local conds `touse'
				
				if ("`by'"!="" ) local conds `conds' & `by'==`byval'
				
				if ("`rd'"!="") {
					if (`counter_rd'==1) local conds `conds' & `x_r'<=`1'
					else if ("`2'"!="") local conds `conds' & `x_r'>`1' & `x_r'<=`2'
					else local conds `conds' & `x_r'>`1'
				}

				* LOOP over y-vars
				local counter_depvar=1
				foreach depvar of varlist `y_vars_r' {
				
					* display text headers
					if (`ynum'>1) {
						if ("`controls'`absorb'"!="") local depvar_name : var label `depvar'
						else local depvar_name `depvar'
						di as text "{bf:y_var = `depvar_name'}"
					}
					
					* perform regression
					if ("`reg_verbosity'"=="quietly") capture reg `depvar' `x_r2' `x_r' `wt' if `conds', `addcluster' `addvce'
					else capture noisily reg `depvar' `x_r2' `x_r' `wt' if `conds', `addcluster' `addvce'
					
					* store results
					if (_rc==0) matrix e_b_temp=e(b)
					else if (_rc==2000) {
						if ("`reg_verbosity'"=="quietly") di as error "no observations for one of the fit lines. add 'reportreg' for more info."
						
						if ("`linetype'"=="lfit") matrix e_b_temp=.,.
						else /*("`linetype'"=="qfit")*/ matrix e_b_temp=.,.,.
					}
					else {
						error _rc
						exit _rc
					}
					
					* relabel matrix row			
					if ("`by'"!="") matrix roweq e_b_temp = "by`counter_by'"
					if ("`rd'"!="") matrix rownames e_b_temp = "rd`counter_rd'"
					else matrix rownames e_b_temp = "="
					
					* save to y_var matrix
					if (`counter_by'==1 & `counter_rd'==1) matrix `y`counter_depvar'_coefs'=e_b_temp
					else matrix `y`counter_depvar'_coefs'=`y`counter_depvar'_coefs' \ e_b_temp
					
					* increment depvar counter
					local ++counter_depvar
				}
			
				* increment rd counter
				if (`counter_rd'!=1) mac shift
				local ++counter_rd
				
			}
			
			* increment by counter
			local ++counter_by
			
		}
	
		* relabel matrix column names
		forvalues i=1/`ynum' {
			if ("`linetype'"=="lfit") matrix colnames `y`i'_coefs' = "`x_var'" "_cons"
			else if ("`linetype'"=="qfit") matrix colnames `y`i'_coefs' = "`x_var'^2" "`x_var'" "_cons"
		}
	
	}

	******* Define the bins *******
	
	* Specify and/or create the xq var, as necessary
	if "`xq'"=="" {

		if !(`touse_first'==1 & word("`:sortedby'",1)=="`x_r'") sort `touse' `x_r'
	
		if "`discrete'"=="" { /* xq() and discrete are not specified */
			
			* Check whether the number of unique values > nquantiles, or <= nquantiles
			capture mata: characterize_unique_vals_sorted("`x_r'",`touse_first',`touse_last',`nquantiles')
			
			if (_rc==0) { /* number of unique values <= nquantiles, set to discrete */
				local discrete discrete
				if ("`genxq'"!="") di as text `"note: the x-variable has fewer unique values than the number of bins specified (`nquantiles').  It will therefore be treated as discrete, and genxq() will be ignored"'

				local xq `x_r'
				local nquantiles=r(r)
				if ("`by'"=="") {
					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else if (_rc==134) { /* number of unique values > nquantiles, perform binning */
				if ("`genxq'"!="") local xq `genxq'
				else tempvar xq
	
				if ("`fastxtile'"!="nofastxtile") fastxtile `xq' = `x_r' `wt' in `touse_first'/`touse_last', nq(`nquantiles') randvar(`randvar') randcut(`randcut') randn(`randn')
				else xtile `xq' = `x_r' `wt' in `touse_first'/`touse_last', nq(`nquantiles')

				if ("`by'"=="") {
					mata: characterize_unique_vals_sorted("`xq'",`touse_first',`touse_last',`nquantiles')
					if (r(r)!=`nquantiles') {
						di as text "warning: nquantiles(`nquantiles') was specified, but only `r(r)' were generated. see help file under nquantiles() for explanation."
						local nquantiles=r(r)
					}

					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else {
				error _rc
			}

		}
		
		else { /* discrete is specified, xq() & genxq() are not */
		
			if ("`controls'`absorb'"!="") di as text "warning: discrete is specified in combination with controls() or absorb(). note that binning takes places after residualization, so the residualized x-variable may contain many more unique values."

			capture mata: characterize_unique_vals_sorted("`x_r'",`touse_first',`touse_last',`=`samplesize'/2')
		
			if (_rc==0) {
				local xq `x_r'
				local nquantiles=r(r)
				if ("`by'"=="") {
					tempname xq_boundaries xq_values
					matrix `xq_boundaries'=r(boundaries)		
					matrix `xq_values'=r(values)
				}
			}
			else if (_rc==134) {
				di as error "discrete specified, but number of unique values is > (sample size/2)"
				exit 134
			}
			else {
				error _rc
			}
		}
	}
	else {

		if !(`touse_first'==1 & word("`:sortedby'",1)=="`xq'") sort `touse' `xq'
		
		* set nquantiles & boundaries
		mata: characterize_unique_vals_sorted("`xq'",`touse_first',`touse_last',`=`samplesize'/2')
		
		if (_rc==0) {
			local nquantiles=r(r)
			if ("`by'"=="") {
				tempname xq_boundaries xq_values
				matrix `xq_boundaries'=r(boundaries)		
				matrix `xq_values'=r(values)
			}
		}
		else if (_rc==134) {
			di as error "discrete specified, but number of unique values is > (sample size/2)"
			exit 134
		}
		else {
			error _rc
		}
	}

	********** Compute scatter points **********

	if ("`by'"!="") {
		sort `touse' `by' `xq'
		tempname by_boundaries
		mata: characterize_unique_vals_sorted("`by'",`touse_first',`touse_last',`bynum')
		matrix `by_boundaries'=r(boundaries)
	}

	forvalues b=1/`bynum' {
		if ("`by'"!="") {
			mata: characterize_unique_vals_sorted("`xq'",`=`by_boundaries'[`b',1]',`=`by_boundaries'[`b',2]',`nquantiles')
			tempname xq_boundaries xq_values
			matrix `xq_boundaries'=r(boundaries)
			matrix `xq_values'=r(values)
		}
		/* otherwise xq_boundaries and xq_values are defined above in the binning code block */

		* Define x-means
		tempname xbin_means
		if ("`discrete'"=="discrete") {
			matrix `xbin_means'=`xq_values'
		}
		else {
			means_in_boundaries `x_r' `wt', bounds(`xq_boundaries') `medians'
			matrix `xbin_means'=r(means)
		}

		* LOOP over y-vars to define y-means
		local counter_depvar=0
		foreach depvar of varlist `y_vars_r' {
			local ++counter_depvar

			means_in_boundaries `depvar' `wt', bounds(`xq_boundaries') `medians'

			* store to matrix
			if (`b'==1) {
				tempname y`counter_depvar'_scatterpts
				matrix `y`counter_depvar'_scatterpts' = `xbin_means',r(means)
			}
			else {
				* make matrices conformable before right appending			
				local rowdiff=rowsof(`y`counter_depvar'_scatterpts')-rowsof(`xbin_means')
				if (`rowdiff'==0) matrix `y`counter_depvar'_scatterpts' = `y`counter_depvar'_scatterpts',`xbin_means',r(means)
				else if (`rowdiff'>0)  matrix `y`counter_depvar'_scatterpts' = `y`counter_depvar'_scatterpts', ( (`xbin_means',r(means)) \ J(`rowdiff',2,.) )
				else /*(`rowdiff'<0)*/ matrix `y`counter_depvar'_scatterpts' = ( `y`counter_depvar'_scatterpts' \ J(-`rowdiff',colsof(`y`counter_depvar'_scatterpts'),.) ) ,`xbin_means',r(means)
			}
		}
	}

	*********** Perform Graphing ***********

	* If rd is specified, prepare xline parameters
	if "`rd'"!="" {
		foreach xval in "`rd'" {
			local xlines `xlines' xline(`xval', lpattern(dash) lcolor(gs8))
		}
	}

	* Fill colors if missing
	if `"`colors'"'=="" local colors ///
		navy maroon forest_green dkorange teal cranberry lavender ///
		khaki sienna emidblue emerald brown erose gold bluishgray ///
		/* lime magenta cyan pink blue */
	if `"`mcolors'"'=="" {
		if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect") local mcolors `: word 1 of `colors''
		else local mcolors `colors'
	}
	if `"`lcolors'"'=="" {
		if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect") local lcolors `: word 2 of `colors''
		else local lcolors `colors'
	}
	local num_mcolor=wordcount(`"`mcolors'"')
	local num_lcolor=wordcount(`"`lcolors'"')


	* Prepare connect & msymbol options
	if ("`linetype'"=="connect") local connect "c(l)"
	if "`msymbols'"!="" {
		local symbol_prefix "msymbol("
		local symbol_suffix ")"
	}
	
	*** Prepare scatters
	
	* c indexes which color is to be used
	local c=0
	
	local counter_series=0
	
	* LOOP over by-vars
	local counter_by=0
	if ("`by'"=="") local noby="noby"
	foreach byval in `byvals' `noby' {
		local ++counter_by
		
		local xind=`counter_by'*2-1
		local yind=`counter_by'*2

		* LOOP over y-vars
		local counter_depvar=0
		foreach depvar of varlist `y_vars' {
			local ++counter_depvar
			local ++c
			
			* LOOP over rows (each row contains a coordinate pair)
			local row=1
			local xval=`y`counter_depvar'_scatterpts'[`row',`xind']
			local yval=`y`counter_depvar'_scatterpts'[`row',`yind']
			
			if !missing(`xval',`yval') {
				local ++counter_series
				local scatters `scatters' (scatteri
				if ("`savedata'"!="") {
					if ("`by'"=="") local savedata_scatters `savedata_scatters' (scatter `depvar' `x_var'
					else local savedata_scatters `savedata_scatters' (scatter `depvar'_by`counter_by' `x_var'_by`counter_by'
				}
			}
			else {
				* skip the rest of this loop iteration
				continue
			}
			
			while (`xval'!=. & `yval'!=.) {
				local scatters `scatters' `yval' `xval'
			
				local ++row
				local xval=`y`counter_depvar'_scatterpts'[`row',`xind']
				local yval=`y`counter_depvar'_scatterpts'[`row',`yind']
			}
			
			* Add options
			local scatter_options `connect' mcolor(`: word `c' of `mcolors'') lcolor(`: word `c' of `lcolors'') `symbol_prefix'`: word `c' of `msymbols''`symbol_suffix'
			local scatters `scatters', `scatter_options')
			if ("`savedata'"!="") local savedata_scatters `savedata_scatters', `scatter_options')
		

			* Add legend
			if "`by'"=="" {
				if (`ynum'==1) local legend_labels off
				else local legend_labels `legend_labels' lab(`counter_series' `depvar')
			}
			else {
				if ("`bylabel'"=="") local byvalname=`byval'
				else {
					local byvalname `: label `bylabel' `byval''
				}
			
				if (`ynum'==1) local legend_labels `legend_labels' lab(`counter_series' `byvarname'=`byvalname')
				else local legend_labels `legend_labels' lab(`counter_series' `depvar': `byvarname'=`byvalname')
			}
			if ("`by'"!="" | `ynum'>1) local order `order' `counter_series'
			
		}
		
	}
	
	*** Fit lines
		
	if inlist(`"`linetype'"',"lfit","qfit") {
	
		* c indexes which color is to be used
		local c=0
		
		local rdnum=wordcount("`rd'")+1
		
		tempname fitline_bounds
		if ("`rd'"=="") matrix `fitline_bounds'=.,.
		else matrix `fitline_bounds'=.,`=subinstr("`rd'"," ",",",.)',.

		* LOOP over by-vars
		local counter_by=0
		if ("`by'"=="") local noby="noby"
		foreach byval in `byvals' `noby' {
			local ++counter_by
			
			** Set the column for the x-coords in the scatterpts matrix
			local xind=`counter_by'*2-1
			
			* Set the row to start seeking from
			*     note: each time we seek a coeff, it should be from row (rd_num)(counter_by-1)+counter_rd
			local row0=( `rdnum' ) * (`counter_by' - 1)
			
			
			* LOOP over y-vars
			local counter_depvar=0
			foreach depvar of varlist `y_vars_r' {
				local ++counter_depvar
				local ++c
				
				* Find lower and upper bounds for the fit line
				matrix `fitline_bounds'[1,1]=`y`counter_depvar'_scatterpts'[1,`xind']
				
				local fitline_ub_rindex=`nquantiles'
				local fitline_ub=.
				while `fitline_ub'==. {
					local fitline_ub=`y`counter_depvar'_scatterpts'[`fitline_ub_rindex',`xind']
					local --fitline_ub_rindex
				}
				matrix `fitline_bounds'[1,`rdnum'+1]=`fitline_ub'
		
				* LOOP over rd intervals
				forvalues counter_rd=1/`rdnum' {
					
					if (`"`linetype'"'=="lfit") {
						local coef_quad=0
						local coef_lin=`y`counter_depvar'_coefs'[`row0'+`counter_rd',1]
						local coef_cons=`y`counter_depvar'_coefs'[`row0'+`counter_rd',2]
					}
					else if (`"`linetype'"'=="qfit") {
						local coef_quad=`y`counter_depvar'_coefs'[`row0'+`counter_rd',1]
						local coef_lin=`y`counter_depvar'_coefs'[`row0'+`counter_rd',2]
						local coef_cons=`y`counter_depvar'_coefs'[`row0'+`counter_rd',3]
					}
					
					if !missing(`coef_quad',`coef_lin',`coef_cons') {
						local leftbound=`fitline_bounds'[1,`counter_rd']
						local rightbound=`fitline_bounds'[1,`counter_rd'+1]
					
						local fits `fits' (function `coef_quad'*x^2+`coef_lin'*x+`coef_cons', range(`leftbound' `rightbound') lcolor(`: word `c' of `lcolors''))
					}
				}
			}
		}

	}
	
	* Prepare y-axis title
	if (`ynum'==1) local ytitle `y_vars'
	else if (`ynum'==2) local ytitle : subinstr local y_vars " " " and "
	else local ytitle : subinstr local y_vars " " "; ", all

	* Save data
	if ("`savedata'"!="") {
	
		*** Save a CSV containing the scatter points
		tempname savedatafile
		file open `savedatafile' using `"`savedata'.csv"', write text `replace'
		
		* LOOP over rows
		forvalues row=0/`nquantiles' {
		
			*** Put the x-variable at the left
			* LOOP over by-vals
			forvalues counter_by=1/`bynum' {
			
				if (`row'==0) { /* write variable names */
					if "`by'"!="" local bynlabel _by`counter_by'
					file write `savedatafile' "`x_var'`bynlabel',"
				}
				else { /* write data values */
					if (`row'<=`=rowsof(`y1_scatterpts')') file write `savedatafile' (`y1_scatterpts'[`row',`counter_by'*2-1]) ","
					else file write `savedatafile' ".,"
				}
			}
			
			*** Now y-variables at the right
			
			* LOOP over y-vars
			local counter_depvar=0
			foreach depvar of varlist `y_vars' {
				local ++counter_depvar

				* LOOP over by-vals
				forvalues counter_by=1/`bynum' {
				
				
					if (`row'==0) { /* write variable names */
						if "`by'"!="" local bynlabel _by`counter_by'
						file write `savedatafile' "`depvar'`bynlabel'"
					}
					else { /* write data values */
						if (`row'<=`=rowsof(`y`counter_depvar'_scatterpts')') file write `savedatafile' (`y`counter_depvar'_scatterpts'[`row',`counter_by'*2])
						else file write `savedatafile' "."
					}
					
					* unless this is the last variable in the dataset, add a comma
					if !(`counter_depvar'==`ynum' & `counter_by'==`bynum') file write `savedatafile' ","
					
				} /* end by-val loop */
				
			} /* end y-var loop */
			
			file write `savedatafile' _n
			
		} /* end row loop */

		file close `savedatafile'
		di as text `"(file `savedata'.csv written containing saved data)"'
		
		
		
		*** Save a do-file with the commands to generate a nicely labeled dataset and re-create the binscatter graph
		
		file open `savedatafile' using `"`savedata'.do"', write text `replace'
		
		file write `savedatafile' `"insheet using `savedata'.csv"' _n _n
		
		if "`by'"!="" {
			foreach var of varlist `x_var' `y_vars' {
				local counter_by=0
				foreach byval in `byvals' {
					local ++counter_by
					if ("`bylabel'"=="") local byvalname=`byval'
					else {
						local byvalname `: label `bylabel' `byval''
					}
					file write `savedatafile' `"label variable `var'_by`counter_by' "`var'; `byvarname'==`byvalname'""' _n
				}
			}
			file write `savedatafile' _n
		}
		
		file write `savedatafile' `"`savedata_graphcmd'"' _n
		
		file close `savedatafile'
		di as text `"(file `savedata'.do written containing commands to process saved data)"'
		
	}
	
	**** Save parameters, used both for histogram and coefficient report
	* Save parameters from variables of interest
	tempname t_min_`x_var' t_max_`x_var' t_r_`x_var' t_min_`y_vars' t_max_`y_vars' t_r_`y_vars'
	cap sum `x_var' if `touse'==1
	scalar `t_min_`x_var''=r(min) 
	scalar `t_max_`x_var''=r(max) 
	scalar `t_r_`x_var''=abs(r(min)-r(max))
	cap sum `y_vars' if `touse'==1
	scalar `t_min_`y_vars''=r(min) 
	scalar `t_max_`y_vars''=r(max) 
	scalar `t_r_`y_vars''=abs(r(min)-r(max))
	
	* Save parameters from binscatter
	
	mata: st_numscalar("max_b_x", max(st_matrix("`y1_scatterpts'")[,1]))
	mata: st_numscalar("min_b_x", min(st_matrix("`y1_scatterpts'")[,1]))
	mata: st_numscalar("max_b_y", max(st_matrix("`y1_scatterpts'")[,2]))
	mata: st_numscalar("min_b_y", min(st_matrix("`y1_scatterpts'")[,2]))

	tempname t_minb_`x_var' t_maxb_`x_var' t_rb_`x_var' t_minb_`y_vars' t_maxb_`y_vars' t_rb_`y_vars'
	scalar `t_minb_`x_var''=min_b_x
	scalar `t_maxb_`x_var''=max_b_x
	scalar `t_rb_`x_var''=abs(`t_minb_`x_var''-`t_maxb_`x_var'')
	cap sum `y_vars'
	scalar `t_minb_`y_vars''=min_b_y 
	scalar `t_maxb_`y_vars''=max_b_y
	scalar `t_rb_`y_vars''=abs(`t_minb_`y_vars''-`t_maxb_`y_vars'')
		
		
	****** Add histogram ******
	if ("`histogram'"!="") {
	
	* Default positioning for graphs
	if ("`xmin'"=="") {
	local xmin=`t_minb_`x_var''-(1/8)*`t_rb_`x_var''+(1/100)*`t_rb_`x_var''	 
	}		
	if ("`ymin'"=="") {
	local ymin=`t_minb_`y_vars''-(1/8)*`t_rb_`y_vars''+(1/100)*`t_rb_`y_vars''	 
	}		

	* default options for histograms
	* formerly xhistbarheight(real 10) yhistbarheight(real 10) xhistbarwidth(real 50) yhistbarwidth(real 50) xhistbins(real 20) yhistbins(real 20)
	if ("`xhistbarheight'"=="") {
	local xhistbarheight=10
	}	
	if ("`yhistbarheight'"=="") {
	local yhistbarheight=10
	}	
	if ("`xhistbarwidth'"=="") {
	local xhistbarwidth=100
	}	
	if ("`yhistbarwidth'"=="") {
	local yhistbarwidth=100
	}	
	if ("`xhistbins'"=="") {
	local xhistbins=20
	}	
	if ("`yhistbins'"=="") {
	local yhistbins=20
	}	
	* depending on which stata installed
	if `stata_version'>=15 {
		if ("`xcolor'"=="") {
		local xcolor_default="color(teal%50)"
		}
		if ("`ycolor'"=="") {
		local ycolor_default="color(maroon%50)"
		}
	}
	if `stata_version'<15 {
		if ("`xcolor'"=="") {
		local xcolor_default="color(teal)"
		}
		if ("`ycolor'"=="") {
		local ycolor_default="color(maroon)"
		}
	}
	* adjustment in case no option specified (color not included as a default)
	if ("`xcolor'"!="") {
	local xcolor="color(`xcolor')"
	}
	if ("`xcfcolor'"!="") {
	local xcfcolor="cfcolor(`xcfcolor')"
	local xcolor_default=""
	}
	if ("`xfintensity'"!="") {
	local xfintensity="fintensity(`xfintensity')"
	local xcolor_default=""
	}
	if ("`xlcolor'"!="") {
	local xlcolor="lcolor(`xlcolor')"
	local xcolor_default=""
	}
	if ("`xlwidth'"!="") {
	local xlwidth="lwidth(`xlwidth')"
	local xcolor_default=""
	}
	if ("`xlpattern'"!="") {
	local xlpattern="lpattern(`xlpattern')"
	local xcolor_default=""
	}
	if ("`xlalign'"!="") {
	local xlalign="lalign(`xlalign')"
	local xcolor_default=""
	}
	if ("`xlstyle'"!="") {
	local xlstyle="lstyle(`xlstyle')"
	local xcolor_default=""
	}
	if ("`xpstyle'"!="") {
	local xpstyle="pstyle(`xpstyle')"
	local xcolor_default=""
	}
	if ("`xbstyle'"!="") {
	local xbstyle="bstyle(`xbstyle')"
	local xcolor_default=""
	}     
 	if ("`ycolor'"!="") {
	local ycolor="color(`ycolor')"
	}
	if ("`ycfcolor'"!="") {
	local ycfcolor="cfcolor(`ycfcolor')"
	local ycolor_default=""
	}
	if ("`yfintensity'"!="") {
	local yfintensity="fintensity(`yfintensity')"
	local ycolor_default=""
	}
	if ("`ylcolor'"!="") {
	local ylcolor="lcolor(`ylcolor')"
	local ycolor_default=""
	}
	if ("`ylwidth'"!="") {
	local ylwidth="lwidth(`ylwidth')"
	local ycolor_default=""
	}
	if ("`ylpattern'"!="") {
	local ylpattern="lpattern(`ylpattern')"
	local ycolor_default=""
	}
	if ("`ylalign'"!="") {
	local ylalign="lalign(`ylalign')"
	local ycolor_default=""
	}
	if ("`ylstyle'"!="") {
	local ylstyle="lstyle(`ylstyle')"
	local ycolor_default=""
	}
	if ("`ypstyle'"!="") {
	local ypstyle="pstyle(`ypstyle')"
	local ycolor_default=""
	}      
	if ("`ybstyle'"!="") {
	local ybstyle="bstyle(`ybstyle')"
	local ycolor_default=""
	}     
	
	* Generate histogram of vars, within the binscatter graph boundaries
	tempname bin_`x_var' bin_`y_vars'
	scalar `bin_`x_var''=round(`t_r_`x_var''/`t_rb_`x_var''*`xhistbins') /* we need to set a number of bins so that after cutting the edges to fit in the interval of the binscatter, 20 or the desired number of bins are left, so we have bin(z) where z equal to the range of the variable time * desired amount of bins / range of binscatter */
	scalar `bin_`y_vars''=round(`t_r_`y_vars''/`t_rb_`y_vars''*`yhistbins') /* we need to set a number of bins so that after cutting the edges to fit in the interval of the binscatter, 20 or the desired number of bins are left, so we have bin(z) where z equal to the range of the variable time * desired amount of bins / range of binscatter */
	tempvar t_d_`x_var' t_b_`x_var' t_d_`y_vars' t_b_`y_vars'
	local temporanea1=`bin_`x_var''
	local temporanea2=`bin_`y_vars''
	cap twoway__histogram_gen `x_var' if `touse'==1 ,  bin(`temporanea1') gen(`t_d_`x_var'' `t_b_`x_var'') /* save density and bins number and width as two columns */
	cap twoway__histogram_gen `y_vars' if `touse'==1,  bin(`temporanea2') gen(`t_d_`y_vars'' `t_b_`y_vars'') /* save density and bins number and width as two columns */
	macro drop temporanea1 temporanea2
	
	* Save parameters from histogram	
	tempname t_minh_`x_var' t_maxh_`x_var' t_rh_`x_var' t_minh_`y_vars' t_maxh_`y_vars' t_rh_`y_vars'
	cap sum `t_d_`x_var''
	scalar `t_minh_`x_var''=r(min) 
	scalar `t_maxh_`x_var''=r(max) 
	scalar `t_rh_`x_var''=abs(r(min)-r(max))
	cap sum `t_d_`y_vars''
	scalar `t_minh_`y_vars''=r(min) 
	scalar `t_maxh_`y_vars''=r(max) 
	scalar `t_rh_`y_vars''=abs(r(min)-r(max))	
	
	* Rescale the histogram	
	tempname rc_`x_var' rc_`y_vars'
	scalar `rc_`x_var''=(`t_maxh_`x_var''*100)/(`xhistbarheight'*`t_rb_`y_vars'') /* we want the maximum value of the distribution divided by some value so that the result is 1/10, or desired quantity, this part will ensure that the distribution occupies only 1/10 of the height of the graph. */
	scalar `rc_`y_vars''=(`t_maxh_`y_vars''*100)/(`yhistbarheight'*`t_rb_`x_var'') /* we want the maximum value of the distribution divided by some value so that the result is 1/10, or desired quantity, this part will ensure that the distribution occupies only 1/10 of the height of the graph. */
	cap replace `t_d_`x_var''=(`t_d_`x_var''/`rc_`x_var'')+(`ymin') /* The height will be e.g. 10% of the graph roughly, the sum of the min is so that the 10% starts at the bottom of the axis */
	cap replace `t_d_`y_vars''=(`t_d_`y_vars''/`rc_`y_vars'')+(`xmin') /* The height will be e.g. 10% of the graph roughly, the sum of the min is so that the 10% starts at the bottom of the axis */
	cap replace `t_b_`x_var''=. if `t_b_`x_var''<`t_minb_`x_var'' | `t_b_`x_var''>`t_maxb_`x_var'' /* don't plot points outisderange from binscatter */
	cap replace `t_b_`y_vars''=. if `t_b_`y_vars''<`t_minb_`y_vars'' | `t_b_`y_vars''>`t_maxb_`y_vars'' /* don't plot points outisderange from binscatter */	
	
	* Adjust width of bars in percentage: e.g. 100% they touch each other
	tempname barw_`x_var' barw_`y_vars'
	scalar `barw_`x_var''=(`t_rb_`x_var''/`xhistbins')*(`xhistbarwidth'/100)
	scalar `barw_`y_vars''=(`t_rb_`y_vars''/`xhistbins')*(`yhistbarwidth'/100)

	}
	
	****** Coefficient, s.e., p-value and sample report ******	
	if "`coefficient'"!="" | "`sample'"!="" {
		* P-value
		mat eb=e(b)
		mat eV=e(V)
		local tstatistic = eb[1,1]/sqrt(eV[1,1])
		local pvalue=2*ttail(e(df_r),abs(`tstatistic'))
			if "`stars'"=="nostars" | "`stars'"=="nostar"{
			local addstars=""
			}	
			if "`stars'"=="1"|"`stars'"==""{
				if `pvalue'<=0.05 & `pvalue'>0.01{
				local addstars="*"
				}
				if `pvalue'<=0.01{
				local addstars="**"
				}
			}
			if "`stars'"=="2"{
				if `pvalue'<=0.10 & `pvalue'>0.05{
				local addstars="+"
				}
				if `pvalue'<=0.05 & `pvalue'>0.01{
				local addstars="*"
				}
				if `pvalue'<=0.01{
				local addstars="**"
				}
			}	
			if "`stars'"=="3"{
				if `pvalue'<=0.10 & `pvalue'>0.05{
				local addstars="+"
				}
				if `pvalue'<=0.05 & `pvalue'>0.01{
				local addstars="*"
				}
				if `pvalue'<=0.01 & `pvalue'>0.001{
				local addstars="**"
				}
				if `pvalue'<=0.001{
				local addstars="***"
				}
			}
			if "`stars'"=="4"{
				if `pvalue'<=0.05 & `pvalue'>0.01{
				local addstars="*"
				}
				if `pvalue'<=0.01 & `pvalue'>0.001{
				local addstars="**"
				}
				if `pvalue'<=0.001{
				local addstars="***"
				}
			}	
			
		* Coef and sample
		if ("`coefficient'"=="") local rounding=0.01
		if ("`coefficient'"!="") local rounding=`coefficient'
			if eb[1,1]>0 {
			local xmin_coef=`t_maxb_`x_var'' -(1/6)*`t_rb_`x_var''
			local ymin_coef=`t_minb_`y_vars''+(1/16)*`t_rb_`y_vars''
			tempvar nsize
			local beta=round(eb[1,1],`rounding')
			local standerr=round(sqrt(eV[1,1]),`rounding')
			cap egen `nsize'=total(e(sample))
			local sampsize=`nsize'[1]
			}
			if eb[1,1]<0 {
			local xmin_coef=`t_minb_`x_var'' +(1/6)*`t_rb_`x_var''
			local ymin_coef=`t_minb_`y_vars''+(1/16)*`t_rb_`y_vars''
			tempvar nsize
			local beta=round(eb[1,1],`rounding')
			local standerr=round(sqrt(eV[1,1]),`rounding')
			cap egen `nsize'=total(e(sample))
			local sampsize=`nsize'[1]
			}
		
		* Label
		if "`coefficient'"!="" & "`sample'"=="sample" {
		local coefficient_report=`"text(`ymin_coef' `xmin_coef' "Coef = `beta'`addstars'  (`standerr')" "N = `sampsize'", size(3) box fcolor(none) margin(vsmall))"'
		}
		if "`coefficient'"!="" & "`sample'"=="" {
		local coefficient_report=`"text(`ymin_coef' `xmin_coef' "Coef = `beta'`addstars'  (`standerr')", size(3) box fcolor(none) margin(vsmall))"'
		}
		if "`coefficient'"=="" & "`sample'"=="sample" {
		local coefficient_report=`"text(`ymin_coef' `xmin_coef' "N = `sampsize'", size(3) box fcolor(none) margin(vsmall))"'
		}
	}
	*
	
	* Display the graph
	if ("`histogram'"!="") {
	local graphcmd twoway `scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options' nodraw `coefficient_report'
	if ("`savedata'"!="") local savedata_graphcmd twoway `savedata_scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options' `coefficient_report'
	}
	if ("`histogram'"=="") {
	local graphcmd twoway `scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options' `coefficient_report'
	if ("`savedata'"!="") local savedata_graphcmd twoway `savedata_scatters' `fits', graphregion(fcolor(white)) `xlines' xtitle(`x_var') ytitle(`ytitle') legend(`legend_labels' order(`order')) `options' `coefficient_report'
	}
	`graphcmd'
	
	if ("`histogram'"!="") {
	local temp_barwidth1=`barw_`x_var''
	local temp_barwidth2=`barw_`y_vars''
		if ("`histogram'"=="`x_var'") {
		addplot: bar `t_d_`x_var'' `t_b_`x_var'', barwidth(`temp_barwidth1') base(`ymin') /* general options */ `xcolor' `xcfcolor' `xfintensity' `xlcolor' `xlwidth' `xlpattern' `xlalign' `xlstyle' `xbstyle' `xpstyle' `xbstyle' `xcolor_default'/* add histogram */ 
		}
		if ("`histogram'"=="`y_vars'") {
		addplot: bar `t_d_`y_vars'' `t_b_`y_vars'', horizontal base(`xmin') barwidth(`temp_barwidth2') /* general options */ `ycolor' `ycfcolor' `yfintensity' `ylcolor' `ylwidth' `ylpattern' `ylalign' `ylstyle' `ybstyle' `ypstyle' `ybstyle' `ycolor_default'/* add histogram */
		}
		if ("`histogram'"=="`x_var' `y_vars'") | ("`histogram'"=="`y_vars' `x_var'") {
		qui addplot: bar `t_d_`x_var'' `t_b_`x_var'', barwidth(`temp_barwidth1') base(`ymin') /* general options */ `xcolor' `xcfcolor' `xfintensity' `xlcolor' `xlwidth' `xlpattern' `xlalign' `xlstyle' `xbstyle' `xpstyle' `xbstyle' `xcolor_default'/* add histogram */
		addplot: bar `t_d_`y_vars'' `t_b_`y_vars'', horizontal base(`xmin') barwidth(`temp_barwidth2') /* general options */ `ycolor' `ycfcolor' `yfintensity' `ylcolor' `ylwidth' `ylpattern' `ylalign' `ylstyle' `ybstyle' `ypstyle' `ybstyle' `ycolor_default'/* add histogram */
		}
	}
	
	* Save graph
	if `"`savegraph'"'!="" {
		* check file extension using a regular expression
		if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension=regexs(0)
		
		if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
		else graph export `"`savegraph'"', `replace'
	}
	
	*** Return items	
	return scalar N = `samplesize'
	
	return local graphcmd `"`graphcmd'"'
	if inlist("`linetype'","lfit","qfit") {
		forvalues yi=`ynum'(-1)1 {
			return matrix y`yi'_coefs=`y`yi'_coefs'
		}
	}
	
	if ("`rd'"!="") {
		tempname rdintervals
		matrix `rdintervals' = (. \ `=subinstr("`rd'"," ","\",.)' ) , ( `=subinstr("`rd'"," ","\",.)' \ .)

		forvalues i=1/`=rowsof(`rdintervals')' {
			local rdintervals_labels `rdintervals_labels' rd`i'
		}
		matrix rownames `rdintervals' = `rdintervals_labels'
		matrix colnames `rdintervals' = gt lt_eq
		return matrix rdintervals=`rdintervals'
	}
	
	if ("`by'"!="" & "`by'"=="`byvarname'") { /* if a numeric by-variable was specified */
		forvalues i=1/`=rowsof(`byvalmatrix')' {
			local byvalmatrix_labels `byvalmatrix_labels' by`i'
		}
		matrix rownames `byvalmatrix' = `byvalmatrix_labels'
		matrix colnames `byvalmatrix' = `by'
		return matrix byvalues=`byvalmatrix'
	}
	
	
end

**********************************

* Helper programs

program define means_in_boundaries, rclass
	version 12.1

	syntax varname(numeric) [aweight fweight], BOUNDsmat(name) [MEDians]
	
	* Create convenient weight local
	if ("`weight'"!="") local wt [`weight'`exp']
	
	local r=rowsof(`boundsmat')
	matrix means=J(`r',1,.)
	
	if ("`medians'"!="medians") {
		forvalues i=1/`r' {
			sum `varlist' in `=`boundsmat'[`i',1]'/`=`boundsmat'[`i',2]' `wt', meanonly
			matrix means[`i',1]=r(mean)
		}
	}
	else {
		forvalues i=1/`r' {
			_pctile `varlist' in `=`boundsmat'[`i',1]'/`=`boundsmat'[`i',2]' `wt', percentiles(50)
			matrix means[`i',1]=r(r1)
		}
	}
	
	return clear
	return matrix means=means

end

*** copy of: version 1.21  8oct2013  Michael Stepner, stepner@mit.edu
program define fastxtile, rclass
	version 11

	* Parse weights, if any
	_parsewt "aweight fweight pweight" `0' 
	local 0  "`s(newcmd)'" /* command minus weight statement */
	local wt "`s(weight)'"  /* contains [weight=exp] or nothing */

	* Extract parameters
	syntax newvarname=/exp [if] [in] [,Nquantiles(integer 2) Cutpoints(varname numeric) ALTdef ///
		CUTValues(numlist ascending) randvar(varname numeric) randcut(real 1) randn(integer -1)]

	* Mark observations which will be placed in quantiles
	marksample touse, novarlist
	markout `touse' `exp'
	qui count if `touse'
	local popsize=r(N)

	if "`cutpoints'"=="" & "`cutvalues'"=="" { /***** NQUANTILES *****/
		if `"`wt'"'!="" & "`altdef'"!="" {
			di as error "altdef option cannot be used with weights"
			exit 198
		}
		
		if `randn'!=-1 {
			if `randcut'!=1 {
				di as error "cannot specify both randcut() and randn()"
				exit 198
			}
			else if `randn'<1 {
				di as error "randn() must be a positive integer"
				exit 198
			}
			else if `randn'>`popsize' {
				di as text "randn() is larger than the population. using the full population."
				local randvar=""
			}
			else {
				local randcut=`randn'/`popsize'
				
				if "`randvar'"!="" {
					qui sum `randvar', meanonly
					if r(min)<0 | r(max)>1 {
						di as error "with randn(), the randvar specified must be in [0,1] and ought to be uniformly distributed"
						exit 198
					}
				}
			}
		}

		* Check if need to gen a temporary uniform random var
		if "`randvar'"=="" {
			if (`randcut'<1 & `randcut'>0) { 
				tempvar randvar
				gen `randvar'=runiform()
			}
			* randcut sanity check
			else if `randcut'!=1 {
				di as error "if randcut() is specified without randvar(), a uniform r.v. will be generated and randcut() must be in (0,1)"
				exit 198
			}
		}

		* Mark observations used to calculate quantile boundaries
		if ("`randvar'"!="") {
			tempvar randsample
			mark `randsample' `wt' if `touse' & `randvar'<=`randcut'
		}
		else {
			local randsample `touse'
		}

		* Error checks
		qui count if `randsample'
		local samplesize=r(N)
		if (`nquantiles' > r(N) + 1) {
			if ("`randvar'"=="") di as error "nquantiles() must be less than or equal to the number of observations [`r(N)'] plus one"
			else di as error "nquantiles() must be less than or equal to the number of sampled observations [`r(N)'] plus one"
			exit 198
		}
		else if (`nquantiles' < 2) {
			di as error "nquantiles() must be greater than or equal to 2"
			exit 198
		}

		* Compute quantile boundaries
		_pctile `exp' if `randsample' `wt', nq(`nquantiles') `altdef'

		* Store quantile boundaries in list
		forvalues i=1/`=`nquantiles'-1' {
			local cutvallist `cutvallist' r(r`i')
		}
	}
	else if "`cutpoints'"!="" { /***** CUTPOINTS *****/
	
		* Parameter checks
		if "`cutvalues'"!="" {
			di as error "cannot specify both cutpoints() and cutvalues()"
			exit 198
		}		
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutpoints() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}

		tempname cutvals
		qui tab `cutpoints', matrow(`cutvals')
		
		if r(r)==0 {
			di as error "cutpoints() all missing"
			exit 2000
		}
		else {
			local nquantiles = r(r) + 1
			
			forvalues i=1/`r(r)' {
				local cutvallist `cutvallist' `cutvals'[`i',1]
			}
		}
	}
	else { /***** CUTVALUES *****/
		if "`wt'"!="" | "`randvar'"!="" | "`ALTdef'"!="" | `randcut'!=1 | `nquantiles'!=2 | `randn'!=-1 {
			di as error "cutvalues() cannot be used with nquantiles(), altdef, randvar(), randcut(), randn() or weights"
			exit 198
		}
		
		* parse numlist
		numlist "`cutvalues'"
		local cutvallist `"`r(numlist)'"'
		local nquantiles=wordcount(`"`r(numlist)'"')+1
	}

	* Pick data type for quantile variable
	if (`nquantiles'<=100) local qtype byte
	else if (`nquantiles'<=32,740) local qtype int
	else local qtype long

	* Create quantile variable
	local cutvalcommalist : subinstr local cutvallist " " ",", all
	qui gen `qtype' `varlist'=1+irecode(`exp',`cutvalcommalist') if `touse'
	label var `varlist' "`nquantiles' quantiles of `exp'"
	
	* Return values
	if ("`samplesize'"!="") return scalar n = `samplesize'
	else return scalar n = .
	
	return scalar N = `popsize'
	
	tokenize `"`cutvallist'"'
	forvalues i=`=`nquantiles'-1'(-1)1 {
		return scalar r`i' = ``i''
	}

end


version 12.1
set matastrict on

mata:

void characterize_unique_vals_sorted(string scalar var, real scalar first, real scalar last, real scalar maxuq) {
	// Inputs: a numeric variable, a starting & ending obs #, and a maximum number of unique values
	// Requires: the data to be sorted on the specified variable within the observation boundaries given
	//				(no check is made that this requirement is satisfied)
	// Returns: the number of unique values found
	//			the unique values found
	//			the observation boundaries of each unique value in the dataset
	
	
	// initialize returned results
	real scalar Nunique
	Nunique=0

	real matrix values
	values=J(maxuq,1,.)
	
	real matrix boundaries
	boundaries=J(maxuq,2,.)

	// initialize computations
	real scalar var_index
	var_index=st_varindex(var)
	
	real scalar curvalue
	real scalar prevvalue
	
	// perform computations
	real scalar obs
	for (obs=first; obs<=last; obs++) {
		curvalue=_st_data(obs,var_index)
		
		if (curvalue!=prevvalue) {
			Nunique++
			if (Nunique<=maxuq) {
				prevvalue=curvalue
				values[Nunique,1]=curvalue
				boundaries[Nunique,1]=obs
				if (Nunique>1) boundaries[Nunique-1,2]=obs-1
			}
			else {
				exit(error(134))
			}
			
		}
	}
	boundaries[Nunique,2]=last
	
	// return results
	stata("return clear")
	
	st_numscalar("r(r)",Nunique)
	st_matrix("r(values)",values[1..Nunique,.])
	st_matrix("r(boundaries)",boundaries[1..Nunique,.])

}

end
