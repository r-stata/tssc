*! -table1_mc- version 3.2 Mark Chatfield    2020-04-29
* give error message if by() variable name will cause trouble
* give error message if by() variable takes value 919, and quite a few other changes relating to 919 = total
* _columna called _columna_ earlier (and same for b), so no longer need to be renamed later (around line 851)
* line 130 ... added  local total ""  if no by() variable
* error 498  in place of  exit  everywhere

* -table1_mc- version 3.1 Mark Chatfield    2018-06-27
* N_* and m_* were incorrect for categorical variables when catrowperc option used. Now fixed.
* Added to help file and give error messages: by() variable must be either (i) string, or (ii) numeric and contain only non-negative integers, whether or not a value label is attached"
* Reference to Susan Donath's newly released baselinetable command updated
* Reference to tabxml added in Remarks section

* -table1_mc- version 3.0 Mark Chatfield    2017-11-29
* added -table1_mc_dta2docx- command to package for Stata 15 users to get output into a .docx file
* added catrowperc option
* deleted extra space in front of small percentages and p-values near end of file so it looks pretty in Word, courier font. Won't look as good in Excel now.
* "Level" no longer appears in output
* starred out:  qui replace perc="<1" if _freq!=0 & real(perc)==0
* format N_ %8.0g  added x3   so that N is always printed as an integer	for continuous vars when continuous var with dps is the last var
* N_ = 0 now instead of .
* if N=0 for a conts var for a group, program no longer shows error (as ranksum/kwallis would break if just one group)
* bin now works even if variable is only ever zero
* footnote now flexible and returned in r(Dapa)
* nformat option added, and default now includes commas for large numbers such as 1,000,000

* -table1_mc- version 2.0 Mark Chatfield    2017-05-23
* I generalised what was the plusminus option (± symbol was not working in Stata v13+ with Phil's)
* I stopped production of e.g. ", mean (SD)" after cont variable in column 1
* option percent_n  so my colleague Gurmeet can have:  perc (n)  -rather than-   n (perc)  
* option percsign introduced ... so can have "%" (default) " %" or "" 
* inserted spaces before a percentage < 10% so decimal points line up nicely in Excel/Word (unless got 100%). Can turn off with nospacelowpercent option.
* option pairwise123 to produce pvalues: p12 p13 p23
* N_ and m_ now produced for each group, and listed
* option slashN ...  report n/N instead of n
* option table(before|after) to add total column
* vartype contln for log normally distributed variables added
* option gurmeet to set Gurmeet Singh's preferences

*Phil Clayton added two more options since I started fiddling with his -table1- 2013-06-04 v1.1 command. 
* I've incorporated the code for the v1.2 addition cformat (and renamed it percformat)
* but not the v1.3 addition cmissing (which I didn't like)
* 2014-10-15	v1.3	Added cmissing option for missing continous data
* 2014-08-23	v1.2	Added cformat option (default format for cat & bin vars)

 
* produces a "table 1" for publications, describing baseline characteristics
*   and optionally comparing them between groups


capture program drop table1_mc
program define table1_mc, sclass
	version 14.2 // mc change from 12
	syntax [if] [in] [fweight], ///
		[by(varname)]		/// optional grouping variable
		vars(string)		/// varname vartype [varformat], vars delimited by \
		[ONEcol]			/// only use 1 column to report categorical vars
		[Format(string)]	/// default format for contn / conts variables
		[PERCFormat(string)] /// default format for cat/cate/bin/bine variables
		[NFormat(string)] /// format for n and N; default is nformat(%12.0fc)
		[iqrmiddle(string asis)] /// what appears after q1 and before q3; iqrmiddle("-") is default; consider iqrmiddle(", ")
		[sdleft(string asis)] /// what is entered after mean and before SD; sdleft(" (") is default; consider sdleft(" ±") 
		[sdright(string asis)] 	///	what is entered after SD; sdright(")") is default; consider sdright("")
		[gsdleft(string asis)] /// what is entered after geometric mean and before GSD; gsdleft(" (×/") is default 
		[gsdright(string asis)] ///	what is entered after GSD; gsdright(")") is default		
		[percent]			/// report categorical vars just as % (no N)
		[MISsing]			/// don't exclude missing values
		[pdp(integer 3)]	/// max number of decimal places in p-value
		[test]				/// include column specifying which test was used
		[SAVing(string asis)] /// optional Excel file to save output		
		[clear]				/// keep the resulting table in memory
		[percent_n]			///
		[percsign(string asis)]  /// default is percsign("%"); consider percsign("")
		[NOSPACElowpercent] /// Report e.g. (3%) rather than ( 3%)
		[extraspace]        /// helps alignment of p-values and ( 3%) in docx if non-monospaced datafont (e.g. Calibri - the default) used with table1_mc_dta2docx
		[pairwise123]		///
		[slashN]			///  report n/N instead of n
		[total(string)]		///  include a total column before/after presenting by group
		[gurmeet]			/// equivalent to specifying:  percformat(%5.1f) percent_n percsign("") sdleft(" [±") sdright("]") gsdleft(" [x/ ") gsdright("]") onecol
		[catrowperc]		//  report row percentages rather than column percentages for cat/cate variables
		
*display ustrunescape("\u02e3\u002f")
*di ustrunescape("\u00d7\u002f")
*di ustrunescape("\u22c7") // Unicode Division Times character looks ok when copy into an email, just not in results window. "Courier New" does not support this character but other fonts e.g. "DejaVu Sans"
*di ustrunescape("\u00b1")


*give error message if by() variable name will cause trouble
if (substr("`by'",1,2) == "N_" | substr("`by'",1,2) == "m_" | inlist("`by'", "N", "m") | inlist("`by'", "_", "_c","_co","_col","_colu","_colum","_column","_columna","_columnb")) {
	di in re "by() variable cannot start with the prefix N_ or m_, or be named N, m, _, _c, _co, _col, _colu, _colum, _column, _columna, _columnb. Please rename that variable."
	error 498
}
		
if `"`gurmeet'"' == "gurmeet" {
	local percformat "%5.1f"
	local percent_n "percent_n"
	local percsign = `""""'
	local iqrmiddle `"",""'
	local sdleft `"" [±""'
	local sdright `""]""'
	local gsdleft `"" [×/""'
	local gsdright `""]""'
	local onecol "onecol"
	local extraspace "extraspace"
}

if `"`nformat'"' == "" local nformat "%12.0fc"		
		
if `"`percsign'"' == "" local percsign `""%""'

if `"`iqrmiddle'"' == "" local iqrmiddle `""-""'

if `"`sdleft'"' == "" local sdleft `"" (""'
if `"`sdright'"' == "" local sdright `"")""'
local meanSD : display "mean"`sdleft'"SD"`sdright'

if `"`gsdleft'"' == "" local gsdleft `"" (×/""'
if `"`gsdright'"' == "" local gsdright `"")""'
local gmeanSD : display "geometric mean"`gsdleft'"geometric SD"`gsdright'
		
	marksample touse
	
	* table will be stored in temporary file called resultstable
	tempfile resultstable
	* order of rows in table
	local sortorder=1

	* group variable in numeric format
	tempvar groupnum
	if "`by'"=="" {
		gen byte `groupnum'=1 // 1 placeholder group
		local total ""
	}
	else {
		capture confirm numeric variable `by'
		if !_rc qui clonevar `groupnum'=`by'
		else qui encode `by', gen(`groupnum')
	}
	
	*give error message if numeric by() variable has some values less than 0
	qui su `groupnum'
	if `r(min)' < 0 {
		di in re "by() variable must be either (i) string, or (ii) numeric and contain only non-negative integers, whether or not a value label is attached"
		error 498	
	}
	
	*give error message if numeric by() variable takes the value 919
	qui count if `groupnum' == 919 & `touse'
	if `r(N)' > 0 {
		di in re "by() variable not allowed to take the value 919 due to my poor coding. Please recode to any other non-negative integer."
		error 498	
	}
	
	qui levelsof `groupnum' if `touse', local(levels)

	* give error message if numeric by() variable not all integers
	foreach l of local levels {
		capture confirm integer number `l'
		if _rc!=0 {
			di in re "by() variable must be either (i) string, or (ii) numeric and contain only non-negative integers, whether or not a value label is attached"
			error 498
		}
	}
	
	* determine number of groups and issue error if <2
	local groupcount: word count `levels'
	if `groupcount'<2 & "`by'"!="" {
		di in re "by() variable must have at least 2 levels"
		error 498
	}
	tokenize `levels'
    local level1 `1'
	local level2 `2'
	local level3 `3'
	
	* group variable needed for some calculations so becomes placeholder if
	* not specified by user
	if "`by'"=="" local group `groupnum' // mc notes `group' is not referenced anywhere

	* N
	preserve
	qui keep if `touse'
	qui drop if missing(`by')
	if "`total'" != "" { 
		qui expand 2, gen(_copy)
		qui replace `groupnum' = 919 if _copy == 1   // 919 chosen as unlikely valid value of `by'
	}
	contract `groupnum' [`weight'`exp'] 
	gen factor="N"
	gen factor_sep="N" // for subsequent neat output
	qui gen n= "N=" + string(_freq, "`nformat'") // mc modified
	*qui drop _freq   // mc
	rename _freq N_
	qui reshape wide n N_, i(factor) j(`groupnum')
	rename n* `groupnum'*
	gen sort1=`sortorder++'
	qui save `resultstable', replace
	restore

	* step through the variables
	gettoken arg rest : vars, parse("\")
	while `"`arg'"' != "" {
		if `"`arg'"' != "\" {
			local varname   : word 1 of `arg'
			local vartype   : word 2 of `arg'
			local varformat : word 3 of `arg'
			local varformat2 : word 4 of `arg'			

			* check that input is valid
			* does variable exist?
			confirm variable `varname'
			
			* is vartype supported?
			if !inlist("`vartype'", "contn", "contln", "conts", "cat", "cate", "bin", "bine") {
				di in re "-`varname' `vartype'- not allowed in vars() option"
				di in re "Variables must be classified as contn, contln, conts, cat, cate, bin or bine"
				error 498
			}
			
			* obtain variable label, or just varname if variable has no label
			local varlab: variable label `varname'
			if "`varlab'"=="" local varlab `varname'
	
			* continuous, normally distributed variable
			if "`vartype'"=="contn" {
				preserve
				qui keep if `touse'
				qui drop if missing(`by')
				
				* significance test
				if `groupcount'>1 {
					qui anova `varname' `groupnum' [`weight'`exp']
					local p=1-F(e(df_m), e(df_r), e(F))
				}
				if "`pairwise123'" == "pairwise123" {
					qui anova `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2'
					local p12=1-F(e(df_m), e(df_r), e(F))
					qui anova `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3'
					local p23=1-F(e(df_m), e(df_r), e(F))
					qui anova `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3'
					local p13=1-F(e(df_m), e(df_r), e(F))					
				}

				* default format is specified in the format option, 
				* or if that's blank, it's just the variable's display format
				if "`varformat'"=="" {
					if "`format'"=="" local varformat: format `varname'
					else local varformat `format'
				}
				
				* collapse to table1 format      (mc changed a lot of this)
				if "`total'" != "" { 
					qui expand 2, gen(_copy)
					qui replace `groupnum' = 919 if _copy == 1
				}
				collapse (mean) mean=`varname' (sd) sd=`varname' (count) N_=`varname' ///
					[`weight'`exp'], by(`groupnum')
				format N_ %8.0g	
				
				qui gen _columna_ =string(mean, "`varformat'")
				if "`varformat2'"!="" local varformat "`varformat2'"
				qui gen sd_ =string(sd, "`varformat'")																
				qui gen _columnb_ = `sdleft' + sd_ + `sdright'
				qui replace _columna_ = "" if mean ==.
				qui replace _columnb_ = "" if mean ==.
				qui gen mean_sd = _columna_  + _columnb_ 
				
				label var _columna_ "columna"
				label var _columnb_ "columnb"
				label var N_ "N" // makes no difference unless make it string here

				qui gen factor="`varlab', `meanSD'"
				qui replace factor="`varlab'" // mc
				qui clonevar factor_sep=factor
				
				keep factor* `groupnum' mean_sd _columna_ _columnb_ N_
				qui reshape wide mean_sd _columna_ _columnb_ N_, i(factor) j(`groupnum')
				rename mean_sd* `groupnum'*
				
				* add p-value, test and sort variable, then save
				if `groupcount'>1 qui gen p=`p'
				if "`pairwise123'" == "pairwise123" {
					qui gen p12=`p12'
					qui gen p23=`p23'
					qui gen p13=`p13'
				}	
				if "`test'"=="test" & `groupcount'>1 {
					if `groupcount'==2 gen test="Two sample t test"
					else gen test="ANOVA"
				}
				gen sort1=`sortorder++'
				qui append using `resultstable'
				qui save `resultstable', replace
				restore
			}

			* continuous, log normally distributed variable
			if "`vartype'"=="contln" {
				preserve
				qui keep if `touse'
				qui drop if missing(`by')
				qui drop if `varname' <=0  // as log transformation will give missing value
				tempvar lvarname
				*qui replace `varname' = log(`varname')
				qui gen `lvarname' = log(`varname')
				
				* significance test
				if `groupcount'>1 {
					qui anova `lvarname' `groupnum' [`weight'`exp']
					local p=1-F(e(df_m), e(df_r), e(F))
				}
				if "`pairwise123'" == "pairwise123" {
					qui anova `lvarname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2'
					local p12=1-F(e(df_m), e(df_r), e(F))
					qui anova `lvarname' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3'
					local p23=1-F(e(df_m), e(df_r), e(F))
					qui anova `lvarname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3'
					local p13=1-F(e(df_m), e(df_r), e(F))					
				}

				* default format is specified in the format option, 
				* or if that's blank, it's just the variable's display format
				if "`varformat'"=="" {
					if "`format'"=="" local varformat: format `varname'
					else local varformat `format'
				}
				
				* collapse to table1 format      (mc changed a lot of this)
				if "`total'" != "" { 
					qui expand 2, gen(_copy)
					qui replace `groupnum' = 919 if _copy == 1
				}
				collapse (mean) mean=`lvarname' (sd) sd=`lvarname' (count) N_=`lvarname' ///
					[`weight'`exp'], by(`groupnum')
				format N_ %8.0g	
				
				qui replace mean = exp(mean)
				qui replace sd = exp(sd)
				qui gen _columna_ =string(mean, "`varformat'")
				if "`varformat2'"!="" local varformat "`varformat2'"
				qui gen sd_ =string(sd, "`varformat'")																
				qui gen _columnb_ = `gsdleft' + sd_ + `gsdright'
				qui replace _columna_ = "" if mean ==.
				qui replace _columnb_ = "" if mean ==.
				qui gen mean_sd = _columna_  + _columnb_ 
				
				label var _columna_ "columna"
				label var _columnb_ "columnb"
				label var N_ "N" // makes no difference unless make it string here

				qui gen factor="`varlab', `gmeanSD'"
				qui replace factor="`varlab'" // mc
				qui clonevar factor_sep=factor
				
				keep factor* `groupnum' mean_sd _columna_ _columnb_ N_
				qui reshape wide mean_sd _columna_ _columnb_ N_, i(factor) j(`groupnum')
				rename mean_sd* `groupnum'*
				
				* add p-value, test and sort variable, then save
				if `groupcount'>1 qui gen p=`p'
				if "`pairwise123'" == "pairwise123" {
					qui gen p12=`p12'
					qui gen p23=`p23'
					qui gen p13=`p13'
				}	
				if "`test'"=="test" & `groupcount'>1 {
					if `groupcount'==2 gen test="Two sample t test, logged data"
					else gen test="ANOVA, logged data"
				}
				gen sort1=`sortorder++'
				qui append using `resultstable'
				qui save `resultstable', replace
				restore
			}
						
			* continuous, skewed variable
			if "`vartype'"=="conts" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum')

				* need to expand by frequency weight since ranksum & kwallis
				* don't allow frequency weights
				if "`weight'"=="fweight" qui expand `exp'
				
				* significance tests
				if `groupcount'>1 {
					if `groupcount'==2 {
						* rank-sum for 2 groups
						cap ranksum `varname', by(`groupnum')
						if _rc == 0 qui ranksum `varname', by(`groupnum')
						local p=2*normal(-abs(r(z)))
					}
					else {
						* Kruskal-Wallis for >2 groups
						cap kwallis `varname', by(`groupnum')
						if _rc == 0 qui kwallis `varname', by(`groupnum')
						local p=chi2tail(r(df), r(chi2_adj))
					}
				}
				if "`pairwise123'" == "pairwise123" {
					cap ranksum `varname' if `groupnum' == `level1' | `groupnum' == `level2', by(`groupnum')					
					if _rc == 0 qui ranksum `varname' if `groupnum' == `level1' | `groupnum' == `level2', by(`groupnum')
					local p12=2*normal(-abs(r(z)))	
					cap ranksum `varname' if `groupnum' == `level2' | `groupnum' == `level3', by(`groupnum')
					if _rc == 0 qui ranksum `varname' if `groupnum' == `level2' | `groupnum' == `level3', by(`groupnum')
					local p23=2*normal(-abs(r(z)))					
					cap ranksum `varname' if `groupnum' == `level1' | `groupnum' == `level3', by(`groupnum')
					if _rc == 0 qui ranksum `varname' if `groupnum' == `level1' | `groupnum' == `level3', by(`groupnum')
					local p13=2*normal(-abs(r(z)))					
				}
				
				* display format
				if "`varformat'"=="" {
					if "`format'"=="" local varformat: format `varname'
					else local varformat `format'
				}

				* collapse to table1 format          (mc changed a lot of this)
				if "`total'" != "" { 
					qui expand 2, gen(_copy)
					qui replace `groupnum' = 919 if _copy == 1
				}				
				collapse (p50) p50=`varname' (p25) p25=`varname' ///
					(p75) p75=`varname' (count) N_=`varname' , by(`groupnum')
				format N_ %8.0g	
				
				qui gen _columna_ =string(p50, "`varformat'")
				if "`varformat2'"!="" local varformat "`varformat2'"
				qui gen _columnb_ = "(" + string(p25, "`varformat'") + `iqrmiddle' + string(p75, "`varformat'") + ")"
				qui gen median_iqr = _columna_ + " " + _columnb_
				qui replace _columna_ = "" if p50 ==.
				qui replace _columnb_ = "" if p50 ==.
				qui replace median_iqr = "" if p50 ==.

				label var _columna_ "columna"
				label var _columnb_ "columnb"
				label var N_ "N" // makes no difference unless make it string here
				
				qui gen factor="`varlab', median (IQR)"
				qui replace factor="`varlab'" // mc
				qui clonevar factor_sep=factor
				keep factor* `groupnum' median_iqr _columna_ _columnb_ N_
				qui reshape wide median_iqr _columna_ _columnb_ N_, i(factor) j(`groupnum')
				rename median_iqr* `groupnum'*

				* add p-value, test and sort variable, then save
				if `groupcount'>1 qui gen p=`p'
				if "`pairwise123'" == "pairwise123" {
					qui gen p12=`p12'
					qui gen p23=`p23'
					qui gen p13=`p13'
				}				
				if "`test'"=="test" & `groupcount'>1 {
					if `groupcount'==2 gen test="Wilcoxon rank-sum"
					else gen test="Kruskal-Wallis"
				}
				gen sort1=`sortorder++'
				qui append using `resultstable'
				qui save `resultstable', replace
				restore
			}
			
			* categorical variable
			if "`vartype'"=="cat" | "`vartype'"=="cate" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum')
				if "`missing'"!="missing" qui drop if missing(`varname')

				* categories should be numeric
				tempvar varnum
				capture confirm numeric variable `varname'
				if !_rc qui clonevar `varnum'=`varname'
				else qui encode `varname', gen(`varnum')
				
				* significance test
				if `groupcount'>1 {
					if "`vartype'"=="cat" {
						qui tab `varnum' `groupnum' [`weight'`exp'], chi2
						local p=r(p)
						if "`pairwise123'" == "pairwise123" {
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2', chi2
						local p12=r(p)
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3', chi2
						local p23=r(p)
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3', chi2
						local p13=r(p)						
						}												
					}
					else {
						qui tab `varnum' `groupnum' [`weight'`exp'], exact
						local p=r(p_exact)
						if "`pairwise123'" == "pairwise123" {
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2', exact
						local p12=r(p_exact)
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3', exact
						local p23=r(p_exact)
						qui tab `varnum' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3', exact
						local p13=r(p_exact)								
						}						
					}				
				}

				
								
				* collapse to table1 format
				if "`total'" != "" { 
					qui expand 2, gen(_copy)
					qui replace `groupnum' = 919 if _copy == 1
				}				
				qui contract `varnum' `groupnum' [`weight'`exp'], zero
				qui egen tot=total(_freq), by(`groupnum')
				
				if "`catrowperc'" != "" {
					tempvar tot_alt coltot
					qui egen `tot_alt' = total(_freq), by(`varnum')
					if "`total'" != "" qui replace `tot_alt' = `tot_alt'/2
					qui gen `coltot' = tot
					qui replace tot = `tot_alt'
				}
				
				* default format is 0 decimal places if <100 cases, otherwise 1 dp
				* (for categorical variables, format is for % not the frequency)
				* however this default can be overridden by the percformat() option
				if "`varformat'"=="" {
					if "`percformat'"=="" {
						sum tot, meanonly
						if r(max)<100 local varformat "%3.0f"
						else local varformat "%5.1f"
					}
					else local varformat `percformat'
				}				

				* finish restructuring to table1 format
				qui gen perc=string(100*_freq/tot, "`varformat'")
				if `"`nospacelowpercent'"' == "" & `"`extraspace'"' == "" 	qui replace perc= " " + perc if 100*_freq/tot < 10 & perc!="10" & perc!="10.0" & perc!="10.00" // mc
				if `"`nospacelowpercent'"' == "" & `"`extraspace'"' != "" 	qui replace perc= "  " + perc if 100*_freq/tot < 10 & perc!="10" & perc!="10.0" & perc!="10.00" // mc
				*could put more spaces before perc!="100" but I won't
				*qui replace perc="<1" if _freq!=0 & real(perc)==0
				qui replace perc= perc + `percsign' // mc
				
				qui gen n_ = string(_freq, "`nformat'") // mc wrote this & next 15 lines
				if `"`slashN'"' == "slashN" qui replace n_ = n_ + "/" + string(tot, "`nformat'") 
				
				if "`percent_n'"=="" & "`percent'"=="" {
					qui gen _columna_ = n_
					qui gen _columnb_ = "(" + perc + ")" 
				}				
				else qui gen _columna_ = perc
				if "`percent_n'"=="percent_n" & "`percent'"=="" qui gen _columnb_ = "(" + n_ + ")" 
				if "`percent'"=="percent" qui gen _columnb_ = ""
				
				qui gen n_perc = _columna_ + " " + _columnb_
				
				label var _columna_ "columna"
				label var _columnb_ "columnb"
				
				if "`catrowperc'" != "" {
					qui replace tot = `coltot'
					drop `coltot'
				}	
				rename tot N_
				label var N_ "N" // makes no difference unless make it string here				
				
				drop _freq perc n_ // mc now keeping tot, but dropping newly created n_
				qui reshape wide n_perc _columna_ _columnb_ N_, i(`varnum') j(`groupnum')				
				rename n_perc* `groupnum'*
				
				* add factor and level variables, unless onecol option specified
				* in which case just add factor variable (with levels included)
				if "`onecol'"=="" {
					qui gen factor="`varlab'" if _n==1
					qui gen factor_sep="`varlab'" // allows neat sepby
					qui gen level=""
					qui levelsof `varnum', local(levels)
					foreach level of local levels {
						qui replace level="`: label (`varnum') `level''" ///
							if `varnum'==`level'
					}
					qui replace level="Missing" if `varnum'==. // mc
				}
				else {
					* add new observation to contain name of variable and
					* p-value
					qui set obs `=_N + 1'
					tempvar reorder
					qui gen `reorder'=1 in L
					sort `reorder' `varnum'
					drop `reorder'
					
					foreach v of var N_* {					
						qui replace `v' = `v'[_n+1] if _n==1
					}
					qui gen factor="`varlab'" if _n==1
					qui gen factor_sep="`varlab'" // allows neat sepby
					qui levelsof `varnum', local(levels)
					foreach level of local levels {
						qui replace factor="   `: label (`varnum') `level''" ///
							if `varnum'==`level'
					}
					qui replace factor="   Missing" if `varnum'==. & _n!=1 // mc
				}

				* add p-value, test and sort variables, then save
				qui gen cat_not_top_row = 1 if _n!=1
				if `groupcount'>1 qui gen p=`p' if _n==1
				foreach v of var N_* {					
					qui replace `v' = . if _n!=1 // N now only appears on P-value line
				}				
				if "`pairwise123'" == "pairwise123" {
					qui gen p12=`p12' if _n==1
					qui gen p23=`p23' if _n==1
					qui gen p13=`p13' if _n==1
				}				
				if "`test'"=="test" & `groupcount'>1 {
					if "`vartype'"=="cat" qui gen test="Pearson's chi-squared" if _n==1
					else qui gen test="Fisher's exact" if _n==1
				}
				gen sort1=`sortorder++'
				qui gen sort2=_n
				qui drop `varnum'
				qui append using `resultstable'
				qui save `resultstable', replace
				restore
			}
	
			* binary variable
			if "`vartype'"=="bin" | "`vartype'"=="bine" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum') | missing(`varname')

				* categories should be numeric 0/1	
				capture assert `varname'==0 | `varname'==1
				if _rc {
					di in red "bin variable `varname' must be 0 (negative) or 1 (positive)"
					exit 198
				}
					
				* significance test
					if "`vartype'"=="bin" {
						qui tab `varname' `groupnum' [`weight'`exp'], chi2
						local p=r(p)
						if "`pairwise123'" == "pairwise123" {
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2', chi2
						local p12=r(p)
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3', chi2
						local p23=r(p)
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3', chi2
						local p13=r(p)						
						}												
					}
					else {
						qui tab `varname' `groupnum' [`weight'`exp'], exact
						local p=r(p_exact)
						if "`pairwise123'" == "pairwise123" {
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level2', exact
						local p12=r(p_exact)
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level2' | `groupnum' == `level3', exact
						local p23=r(p_exact)
						qui tab `varname' `groupnum' [`weight'`exp'] if `groupnum' == `level1' | `groupnum' == `level3', exact
						local p13=r(p_exact)								
						}						
					}				
								
				* collapse to table1 format
				if "`total'" != "" { 
					qui expand 2, gen(_copy)
					qui replace `groupnum' = 919 if _copy == 1
				}				
				qui contract `varname' `groupnum' [`weight'`exp'], zero
				qui egen tot=total(_freq), by(`groupnum')
				
				* default format is 0 decimal places if <100 cases, otherwise 1 dp
				* (for categorical variables, format is for % not the frequency)
				if "`varformat'"=="" {
					if "`percformat'"=="" {
						sum tot, meanonly
						if r(max)<100 local varformat "%3.0f"
						else local varformat "%5.1f"
					}
					else local varformat `percformat'
				}
				
				* finish restructuring to table1 format
				qui count if `varname'==1
				if r(N) > 0 qui keep if `varname'==1
				if r(N) == 0 qui replace _freq = 0 if _freq > 0
				
				qui gen perc=string(100*_freq/tot, "`varformat'")
				if "`nospacelowpercent'" == ""  qui replace perc= " " + perc if 100*_freq/tot < 10 & perc!="10" & perc!="10.0" & perc!="10.00" // mc
				*qui replace perc="<1" if _freq!=0 & real(perc)==0
				qui replace perc= perc + `percsign' // mc				
				
				qui gen n_ = string(_freq, "`nformat'") // mc wrote this & next 15 lines
				if `"`slashN'"' == "slashN" qui replace n_ = n_ + "/" + string(tot, "`nformat'") 
				
				if "`percent_n'"=="" & "`percent'"=="" {
					qui gen _columna_ = n_
					qui gen _columnb_ = "(" + perc + ")" 
				}				
				else qui gen _columna_ = perc
				if "`percent_n'"=="percent_n" & "`percent'"=="" qui gen _columnb_ = "(" + n_ + ")" 
				if "`percent'"=="percent" qui gen _columnb_ = ""
				
				qui gen n_perc = _columna_ + " " + _columnb_
				
				label var _columna_ "columna"
				label var _columnb_ "columnb"
				rename tot N_
				label var N_ "N" // makes no difference unless make it string here
				
				drop _freq perc n_ // mc now keeping tot, but dropping newly created n_
				qui reshape wide n_perc _columna_ _columnb_ N_, i(`varname') j(`groupnum')
				qui drop `varname'
				qui gen factor="`varlab'" if _n==1
				qui clonevar factor_sep=factor
				rename n_perc* `groupnum'*

				* add p-value, test and sort variables, then save
				if `groupcount'>1 qui gen p=`p'
				if "`pairwise123'" == "pairwise123" {
					qui gen p12=`p12'
					qui gen p23=`p23'
					qui gen p13=`p13'
				}				
				if "`test'"=="test" & `groupcount'>1 {
					if "`vartype'"=="bin" qui gen test="Pearson's chi-squared"
					else qui gen test="Fisher's exact"
				}
				gen sort1=`sortorder++'
				qui append using `resultstable'
				qui save `resultstable', replace
				restore
			}			
		}
		gettoken arg rest : rest, parse("\")
    }
	
	* get value labels for group if available
	local vallab: value label `groupnum'
	if "`vallab'"!="" {
		tempfile labels
		qui label save `vallab' using `labels'
	}

	* levels of group variable, for subsequent labelling
	qui levelsof `groupnum' if `touse', local(levels)

	* load results table
	preserve
	qui use `resultstable', clear

	
	* restore value labels if available
	capture do `labels'
	
	if "`total'" != "" { 
		if "`vallab'"=="" local vallab "beatles"	
		label define `vallab' 919 `"Total"', modify
		local levels "`levels' 919" 
	}
	
	* label each group variable
	foreach level of local levels {
		if "`vallab'"=="" {
			lab var `groupnum'`level' "`by' = `level'"
		}
		else {
			local lab: label `vallab' `level'
			lab var `groupnum'`level' "`lab'"
		}
	}

	*generate n missing
	foreach i of local levels {
		cap gen cat_not_top_row = .
		qui recode N_`i' .=0 if cat_not_top_row !=1 // so have N=0 for cat and bin vars rather than N=.
		qui su N_`i'
		qui gen m_`i' = `r(max)' - N_`i'
		label var m_`i' "`i' m"  // only important if -clear- option specified
	}
	
	* label other variables
	lab var factor "Factor "
	capture lab var level "Level"
	capture lab var test "Test"
	if `groupcount'==1 lab var `groupnum'1 "Total"
	capture lab var _columna_919 "T _columna_"
	capture lab var _columnb_919 "T _columnb_"
	capture lab var N_919 "T N_" // only important if -clear- option specified
	capture lab var m_919 "T m_" // only important if -clear- option specified
	
	* format p-values
	if `groupcount'>1 {
		qui gen pvalue=string(p, "%4.2f") if !missing(p)
		qui replace pvalue=string(p, "%`=`pdp'+2'.`pdp'f") if p<0.10
		local pmin=10^-`pdp'
		qui replace pvalue="<" + string(`pmin', "%`=`pdp'+2'.`pdp'f") if p<`pmin'
		qui replace pvalue=" " + pvalue if p>=`pmin' & pvalue != ""
		lab var pvalue "p-value"
	}
	if "`pairwise123'" == "pairwise123" {
		foreach p of var p12 p23 p13 {
			qui gen `p's=string(`p', "%4.2f") if !missing(`p')
			qui replace `p's=string(`p', "%`=`pdp'+2'.`pdp'f") if `p'<0.10
			qui replace `p's="<" + string(`pmin', "%`=`pdp'+2'.`pdp'f") if `p'<`pmin'
			qui replace `p's=" " + `p's if `p'>=`pmin' & `p's != ""
			lab var `p's "`p'"
		}	
	}
	
	* create a row containing variable labels - for nicer output
	qui count
	local newN=r(N) + 1
	qui set obs `newN'
	qui desc, varlist
	foreach var of varlist `r(varlist)' {
		if "`var'" != "level" capture replace `var'="`: var lab `var''" in `newN'  // mc notes this works only for string vars
	}
	qui replace sort1=0 in `newN'


	* sort rows and drop unneeded variables
	sort sort*
	drop sort*
	capture drop p
	capture drop p12 p23 p13
	
	* left-justify the strings apart from p-value
	qui desc, varlist
	foreach var in `r(varlist)' {
		format `var' %-`=substr("`: format `var''", 2, .)'
	}
	*capture format %`=`pdp'+3's pvalue // mc thinks this works in Stata, but doesn't automatically carryover into Excel
	*capture format %`=`pdp'+3's p12s p23s p13s 
	capture format %`=`pdp'+3's _columna_*

	
	
	* clean up variables in preparation for display
	order N_*, seq // otherwise N_1 N_T N_2 can occur if N_2 = 0 for last variable
	order `groupnum'*, seq
	order factor `groupnum'* N_* m_*
	capture order factor `groupnum'* pvalue // won't have p-value if no group var ... mc swapped in `groupnum' for `by'
	capture order test, after(pvalue) // won't have test if no group var
	capture order p12s p23s p13s, after(pvalue) // mc
	capture order level, after(factor) // won't have level if no cat vars

	
	* rename placeholder group variable if by() option not used
	* otherwise rename group variables using the specified group var (only
	*   important if using the "clear" option)
	if `groupcount'==1 rename `groupnum'1 Total
	else rename `groupnum'* `by'*
 
	
	if "`by'" !="" rename `by'* `by'_*
	capture rename *_919 *_T // not doing _columna_ or b
	capture rename _*_919 _*_T // needed (strangely) for doing _columna_ or b
	*rename _columna* _columna_*
	*rename _columnb* _columnb_*
	
	if "`total'" == "before" {
		tokenize `levels'
        local first `1'
		cap order `by'_T, before(`by'_`first') // if no `by' it won't do it
		order N_T, before(N_`first')
		order m_T, before(m_`first')
		order _columna_T _columnb_T, before(_columna_`first')
	}	

	*below new 2020
	if "`total'" == "after" {
		tokenize `levels'
        local first `1'
		cap order `by'_T, before(pvalue) // if no `by' it won't do it
		order N_T, before(m_`first')
		order m_T, before(_columna_`first')
		order _columna_T _columnb_T, last
	}	
	
	* list N and missing (except this will be 0 for cat vars if missing option specified)
	format `nformat' N_* m_*
	capture su cat_not_top_row
	if _rc == 0 list factor N_* m_* if factor != "Factor " & factor != "N" & cat_not_top_row !=1 , sepby(factor_sep) noobs table ab(20) // mc ... and `by'?
	else list factor N_* m_* if factor != "Factor " & factor != "N", sepby(factor_sep) noobs table ab(20) // mc ... and `by'?
	display "   N_ ... #records used below,   m_ ... #records not used"
	display " "
	cap drop cat_not_top_row
	qui replace factor = "" if factor == "N"
	qui replace factor = " " if factor == "Factor "
	
	* finally, display the table itself
	qui ds factor_sep _* N_* m_*, not
	list `r(varlist)', sepby(factor_sep) noobs noheader table
	drop factor_sep
	
	if regexm("`vars' ", " bin ") == 1 | regexm("`vars' ", " bine ") == 1 local ybin "1"
	if regexm("`vars' ", " cat ") == 1 | regexm("`vars' ", " cate ") == 1 local ycat "1" 
	if "`ycat'" == "1" | "`ybin'" == "1" local ycatbin "1"
	local n "n"
	if "`slashN'" == "slashN" local n "`n'/total"
	local percentage "%"
	if "`catrowperc'" != "" & "`ycat'" == "1" {
		local percentage2 "`percentage'"
		local percentage2 "column `percentage'"
		if "`percent_n'" == "percent_n" & "`percent'"=="" local percfootnote2 "`percentage2' (`n')" 
		if "`percent_n'" != "percent_n" & "`percent'"=="" local percfootnote2 "`n' (`percentage2')" 
		if "`percent'"=="percent" local percfootnote2 "`percentage2'" 
		local percentage "row `percentage'"
	}
	if "`percent_n'" == "percent_n" & "`percent'"=="" local percfootnote "`percentage' (`n')" 
	if "`percent_n'" != "percent_n" & "`percent'"=="" local percfootnote "`n' (`percentage')" 
	if "`percent'"=="percent" local percfootnote "`percentage'" 
	*if "`ycat'" == "1" | "`ybin'" == "1" local ycat "`percfootnote'"
	if regexm("`vars' ", " contn ") == 1  local ycontn "1"
	if regexm("`vars' ", " contln ") == 1  local ycontln "1" 
	if regexm("`vars' ", " conts ") == 1  local yconts "1"
	if "`ycontn'" == "1" & "`ycontln'" == "1" & "`yconts'" == "1" local ycont "`meanSD' or `gmeanSD' or median (IQR)"
	if "`ycontn'" == "1" & "`ycontln'" == "1" & "`yconts'" == "" local ycont "`meanSD' or `gmeanSD'"
	if "`ycontn'" == "1" & "`ycontln'" == "" & "`yconts'" == "1" local ycont "`meanSD' or median (IQR)"
	if "`ycontn'" == "" & "`ycontln'" == "1" & "`yconts'" == "1" local ycont "`gmeanSD' or median (IQR)"
	if "`ycontn'" == "1" & "`ycontln'" == "" & "`yconts'" == "" local ycont "`meanSD'"
	if "`ycontn'" == "" & "`ycontln'" == "1" & "`yconts'" == "" local ycont "`gmeanSD'"
	if "`ycontn'" == "" & "`ycontln'" == "" & "`yconts'" == "1" local ycont "median (IQR)"
	if "`ycont'" != "" & "`ycatbin'" !="" local ymix "`ycont' for continuous measures, and `percfootnote' for categorical measures"
	if "`ycont'" != "" & "`ycatbin'" =="" local ymix "`ycont'"
	if "`ycont'" == "" & "`ycatbin'" !="" local ymix "`percfootnote'"
	if "`catrowperc'" != "" & "`ycat'" == "1" & "`ybin'" == "1" local ymix "`ymix' and `percfootnote2' for binary measures"
	local Dapa "Data are presented as `ymix'."
	display "`Dapa'"
	sreturn local Dapa "`Dapa'"	
	display " "
	

		
	*Excel/Word appear to want an extra space for some fonts (not courier)
	if `"`extraspace'"' != "" {
		qui cap replace pvalue=" " + pvalue if substr(pvalue,1,1) != "<"
		
		if "`pairwise123'" == "pairwise123" {
			foreach p of var  p12 p23 p13 {
				qui cap replace `p'=" " + `p' if substr(`p',1,1) != "<"
			}	
		}
	}
	
	/*
	if "`by'"!="" {
		foreach col of var `by'_* {
			qui cap replace `col'=" " + `col' if substr(`col',1,1) == " "   // starred out 28/7/17
		}
	}
	*/
	
	qui ds N_* m_*
	foreach v of varlist `r(varlist)' {
		qui gen z`v' = string(`v', "`nformat'") if !missing(`v'), after(`v')
		qui drop `v'
		qui rename z`v' `v'
		*qui replace `v' = "`v'" if factor == " "
 	}

	*get nice labels in row 1 for N_* m_*
	local levels "`levels' T"
	foreach l of local levels {
		qui cap replace N_`l' = `by'_`l' if factor == " "
		qui cap replace m_`l' = `by'_`l' if factor == " "
		qui cap replace _columna_`l' = `by'_`l' if factor == " "
		qui cap replace _columnb_`l' = `by'_`l' if factor == " "		
	}
	if `groupcount'==1 {
		qui replace N_1 = Total if factor == " "
		qui replace m_1 = Total if factor == " "
		qui replace _columna_1 = Total if factor == " "
		qui replace _columnb_1 = Total if factor == " "
	}	
	
	* if -saving- was specified then we'll save the table as an Excel spreadsheet
	if `"`saving'"'!="" export excel using `saving'  // mc removed lonely , `replace'

	* restore original data unless told not to
	if "`clear'"=="clear" restore, not
	else restore
end
