*! OPROBPR.ADO version 4.0.2 by Nicholas Winter 7/20/2004
*! Program to plot predicted values for oprobit/ologit
*! Updated for Stata 8.2
*  Built upon LOGPRED.ADO by Joanne M. Garrett 
*		published 02/20/95 in sg42: STB-26; and subsequent updates.
*  Also draws upon PROBPRED.ADO by Mead Over, October 30, 1996 Version 1.0.1  
*		STB 42 sg42.2 
*
* 2/25/99 Fixed graph title so it won't crash with long variable label
*			fixed calculation of variable means--now drops all missings
*				  before calculating means of any variable
* v1.2.1  re-fixed calculation of means so it doesn't conflict with user-set's
* v2.0	 allows complex plot categories and uses y value labels to label
*				  plot lines if available
* v2.1	 updated to Stata version 6.0
*			added support for weights and for svy based estimation commands
* v2.1.1  fixed bug in parsing command() option
* v3.0	 updated for Stata version 7
* v3.1.1  added support for mlogit and svymlogit
* v4.0.0 - 7/2004 Reworked completely
*        - now it's a post-estimation command
*        - now works with St8a8 graphics
*        - now adds observations to the end of the dataset, rather than creating a new one
*          (useful in case someone wants to add a plot based on the current dataset)
*  4.0.1 fixed -save- option not to save entire dataset
*  4.0.2 updated to deal with version 9's differently-formatted e(b)
********************************************************************************************

// OLD SYNTAX
//	[pw iw fw] [if] [in], [Adjust(string)		///
//		From(string) To(string) INC(string) POly(integer 0)		  ////
//		Xact(varlist) SAVE(string) SAving(string) T1title(string) L1title(string) ///
//		NOModel NOList NOPlot CMD(string) Connect(string) LABels(string) ///
//		Symbol(string) PLot(string) PEn(string)  ///
//		MODeloptions(string) Keys TExt(string) TSize(real 0.8) * ]

program define oprobpr
	version 8.2

	if !inlist("`e(cmd)'","oprobit","ologit","mlogit","svyoprobit","svyologit","svymlogit") error 301
	
	syntax varlist(min=1 max=1 numeric) [if/] [in] , [	///
		save(string)						/// save constructed dataset
		noESAMPLE							/// **don't use e(sample) for calculating variable means
										/// 
		Levels(string) 					/// set levels for covariates
		CATegories(string)					/// specify plot categories
		From(string) To(string) NEWobs(int 25)	/// **range and number of obs for x variable
		LABels(string asis) 				/// specify labels for plotted categories
		GType(string)						/// Type of graph; default=line or area
		stack							/// stack the categories
		NOList							/// suppress listing of predicted probabilities
		NWIDth(int 80)						/// **width for note describing covariates
										///
		plot(string)						/// overlay other twoway plots
		* 								/// other graph options
		]
	
	
	*set up -if- local to include both e(sample) and user if (or not, depending on options)
	
	if "`esample'"!="noesample" local esample (e(sample)==1)		// switch meaning around
	else                        local esample
	if `"`if'"'!="" local if (`if')
	if "`esample'"!="" & `"`if'"'!="" local and &
	if "`esample'"!="" | `"`if'"'!="" local if if `esample' `and' `if'

	local yvar `e(depvar)'
	local xvar `varlist'
	local varlbly : variable label `yvar'
	local vallab  : value label `yvar'
	local varlblx : variable label `xvar'
	
	if `: word count `from' `to'' < 2 {
		sum `xvar' `if' `in' , meanonly
		if "`from'"=="" local from = r(min)
		if "`to'"==""   local to = r(max)
	}

	confirm number `from'
	confirm number `to'
	if `from'>=`to' {
		di in red "from() must be less than to()."
		error 198
	}

	preserve
	
********************
* Get list of variables in model, strip cutpoints and the plotting var (xvar)
********************
	local covlist : colnames e(b)
	
	if inlist("`e(cmd)'","oprobit","ologit") &  ///
		(_caller() < 9)				local cutstr _cut1
	else								local cutstr _cons

	local cutpos : list posof "`cutstr'" in covlist
	forval i=1/`=`cutpos'-1' {
		local xx `xx' `: word `i' of `covlist''
	}
	local covlist `xx'
noi di `"covlist: [`covlist']"'
	local covlist : list covlist - xvar
	local numcov : word count `covlist'

	tempname yvals
	matrix `yvals' = e(cat)'
	local ncat `e(k_cat)'

*Get value label if exists and if user didn't override
	if `"`labels'"'=="" & "`vallab'"!="" {
		forval i=1/`ncat' {
			local cur = `yvals'[`i',1]
			local ylab`i' : label `vallab' `cur'
		}
	}

	local newN = _N+`newobs'
	local N1 = _N+1
	qui set obs `newN'
	local newin `N1'/l
	local oldin 1/`=_N'

	foreach var of local covlist {
		sum `var' `if' `in' , meanonly
		qui replace `var' = `r(mean)' in `newin'
	}
	qui replace `xvar' = ((_n-`N1')/(`newN'-`N1')) * ((`to')-(`from')) + `from' in `newin'

	*collapse `covlist' `if' `in'
	*qui expand `newobs'
	*range `xvar' `from' `to'
	*la var `xvar' `"`varlblx'"'
	
	if `"`levels'"'!="" {
		tokenize `"`levels'"', parse(",")			// here we are re-arranging to make sure complex
		local levels							// calcluations come AFTER setting other covariates
		while `"`1'"'!="" {
			if `"`1'"'!="," {						// skip comma
				local val = substr(`"`1'"',index(`"`1'"',"=")+1,.)
				capture confirm number `val'
				if _rc local complex `"`complex',`1'"'
				else local simple `"`simple',`1'"'
			}	
			macro shift
		}
		local levels `"`simple'`complex'"'
		local levels : subinstr local levels "," ", " , all	// cleaned up for pretty display below
		gettoken junk levels : levels , parse(",")			// strip off leading comma


		tokenize `"`levels'"', parse(",")
		while `"`1'"'!="" {
			if `"`1'"'!="," {
				capture replace `1' in `newin'
				if _rc {
					di as error `"error setting level for covariate: [`1']"'
					exit 198
				}
			}
			macro shift
		}
	}	

*Generate predict string
	forval i=1/`ncat' {
		local prst `prst' _Cat_`i'
	}

*Do predictions
	qui predict `prst' in `newin'

*Parse plot() -- use specification of what to plot ========needs error trapping!
*	  This assigns: `nplot'	: number of categories to plot
*						 `ncompx'  : number of complex categories
*						 `pvar`i'' : name of variable containing category i
*						 `pnm`i''  : category number (ito y var) in plot cat i

	if "`categories'"=="" {						  /* no user specified */
		local nplot `ncat'
		local ncompx 0
		forval i=1(1)`ncat' {
			local pvar`i' "_Cat_`i'"
			local pnm`i' "`i'"
			la var `pvar`i'' "Category `i'"
		}
	}
	else {											/* user-specified plot() */
		local nplot 0							  /* number of cats to plot */
		local ncompx 0							 /* number of complex ones */
		tokenize "`categories'", parse(",")
		while "`1'"!="" {
			if "`1'"!="," {						/* have a non-comma */
				local nplot=`nplot'+1
				local plus=index("`1'","+")
				if `plus'==0 {					 /* its a simple category -- add check */
					local pvar`nplot' "_Cat_`1'"
					local pnm`nplot' "`1'"
					la var _Cat_`1' "Category `1'"
				}
				else {								/* complex category, eg: p(1+2+3) */
					local ncompx=`ncompx'+1
					local formula "0"
					local compnm
					while `plus'!=0 {
						local cur=substr("`1'",1,`plus'-1)	/* get first cat number */
						local formula "`formula' + _Cat_`cur'"
						local compnm "`compnm'&`cur'"
						local 1=substr("`1'",`plus'+1,.)
						local plus=index("`1'","+")
					}
					local formula "`formula' + _Cat_`1'"		/* add on final one */
					local compnm=substr("`compnm'&`1'",2,.)  /* add last and cut leading */
					local pvar`nplot' "_Comp_`ncompx'"
					local pnm`nplot' "`compnm'"
					quietly gen _Comp_`ncompx'=`formula' in `newin'
					local nm=substr("`formula'",5,.)
					la var _Comp_`ncompx' "`nm'"
				}
			}
			macro shift
		}
	}

*generate plot string, connect string & empty symbol variables
	forval i=1/`nplot' {
		local graphlist `"`graphlist' `pvar`i''"'
		local plst "`plst' `pvar`i''"
		*if "`connect'"=="" local cst "`cst's"
		*local mlabvarlist  "`mlabvarlist' _S`i'"
		*quietly gen  _S`i'=""
	}

	if `"`labels'"'!="" {								/* user symbols */
		local i 1
		tokenize `"`labels'"'
		while `"`1'"'!="" {
			if `"`1'"'=="."  local 1 " " 
			*quietly replace _S`i'=`"`1'"' if inlist(_n,1,_N)
			la var `pvar`i'' `"`1'"'
			local i=`i'+1
			macro shift
		}
	}
	else {												 /* no user symbols */
		if `ncompx'==0 {									 /* all simple  */
			if "`vallab'"!="" {								/* is y lab */
				local i 1
				while `i'<=`nplot' {
					*qui replace _S`i'="`ylab`pnm`i'''" if inlist(_n,1,_N)
					la var `pvar`i'' "`ylab`pnm`i'''"
					local i=`i'+1
				}
			}
			else {												  /* no y lab */
				local i 1
				while `i'<=`nplot' {
					*quietly replace _S`i'="Cat `pnm`i''" if inlist(_n,1,_N)
					la var `pvar`i'' "Category `pnm`i''"
					local i=`i'+1
				}
			}
		}
		else {												  /* not all simple */
				local i 1
				while `i'<=`nplot' {
					if substr("`pvar`i''",1,3)=="Cat" {		  /* simple  */
						*quietly replace _S`i'="Cat `pnm`i''" if inlist(_n,1,_N)
						la var `pvar`i'' "Category `pnm`i''"
					}
					else {
						*quietly replace _S`i'="C`pnm`i''" if inlist(_n,1,_N)
						la var `pvar`i'' "Sum of Categories `pnm`i''"
					}
					local i=`i'+1
				}
		}
	}

	if `nplot'>10 {
		di in r "Can't plot more than 10 categories. " 
		di in r "Specify fewer or combine some using plot()."
		error 198
	}

	if "`stack'"=="stack" {
		tempvar prev
		qui {
			gen double `prev'=0
			foreach var in `plst' {
				replace `var' = `var' + `prev' in `newin'
				replace `prev' = `var' in `newin'
			}
		}
		forval i=`: word count `graphlist''(-1)1 {				// reverse order of plot 
			local ngl "`ngl' `: word `i' of `graphlist''"		// categories for area plot
			local gl_ord "`gl_ord' `i'"						// create order() option for legend
		}
		local graphlist `ngl'
		local gl_ord order(`gl_ord')
	}
	
*Plot and list results

	if `"`gtype'"'=="" {
		if "`stack'"!="" local gtype area
		else             local gtype scatter
	}

	local mtype = cond("`esample'"!="","estimation sample","overall")
	local ntext "All covariates set at at `mtype' mean"
	if `"`levels'"'!="" local ntext `ntext' except:`levels'
	local note_p1 : piece 1 `nwidth' of `"`ntext'"'
	local note_text `""`note_p1'""'
	local i 1
	while `"`note_p`i''"'!="" {
		local i=`i'+1
		local note_p`i' : piece `i' `nwidth' of `"`ntext'"'
		local note_text `"`note_text' "`note_p`i''""'
	}

	local g_options ///
		title(Predicted Probabilities: `varlbly' (`yvar'))	///
		ytitle("Probabilities")							///
		xlabel(minmax)									///
		msymbol(`: di _dup(`nplot') "i "')					///
		connect(`: di _dup(`nplot') "l "')					///
		legend(on `gl_ord')								///
		ylabel(0 .5 1 , angle(0) format(%02.1f) )			///
		note(`note_text')

	local plot : subinstr local plot "@@@" "`oldin'" , all

	graph twoway `gtype' `graphlist' `xvar' in `newin' , sort `g_options' `options' || `plot'

	if "`nolist'"==""  {
		di "  "
		di as text "Probabilities"
		di
		di as text "  Outcome Variable:	  " as res "`yvar' " cond("`varlbly'"=="","","-- ") "`varlbly'"
		di as text "  Independent Variable: " as res "`xvar' " cond("`varlblx'"=="","","-- ") "`varlblx'"
		if `numcov'>0 {
			di "{p 2 28 2}{txt}Covariates: {res}`covlist'{p_end}"
		}
		if `"`levels'"'!="" {
			di `"{p 2 28 2}{txt}All variables set at estimation sample mean except:{res}`levels'{p_end}"'
		}
		else di as text "  All variables set at estimation sample mean"
		di "{txt}  Total Observations: {res}`e(N)'"
		list `xvar' `plst' in `newin'
	}

	if "`save'" ~= "" {
		qui keep in `newin'
		save `save'
	}

end

*end&
