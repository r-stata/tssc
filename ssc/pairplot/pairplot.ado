*! 1.0.11 NJC 21 July 2006 
*! 1.0.10 NJC 13 July 2005 
* 1.0.9 NJC 19 December 2004 
* 1.0.8 NJC 4 August 2004 
* 1.0.7 NJC 21 July 2004 
* 1.0.6 NJC 7 June 2004 
* 1.0.5 NJC 4 June 2004 
* 1.0.4 NJC 30 Oct 2003 
* 1.0.3 NJC 12 Feb 2003 
* 1.0.2 NJC 6 Feb 2003 
* 1.0.1 NJC 4 Feb 2003 
* 1.0.0 NJC 30 Jan 2003 
* vplplot 1.5.1 NJC 20 Sept 2001 
program pairplot, sortpreserve 
	version 8
	syntax varlist(min=2 max=3 ts) [if] [in] [ , diff ratio base(numlist) ///
		mean gmean sort(str) LEGend(str asis)  MSymbol(str)        ///
		VERTical HORizontal Y2options(str asis) SORTLABel(varname) /// 
	        BLSTYle(str) BLColor(str) BLWidth(str) BLPattern(str asis) ///
	        LSTYle(str) LColor(str) LWidth(str) LPattern(str asis) ///
		TRSCale(str asis) PLOT(str asis) ADDPLOT(str asis) * ]  		
	
	tokenize `varlist'
	args y1 y2 xvar

	// original y1 and y2; -trscale()- maps to transformed variables 
	args oy1 oy2 

	local nopts = ("`mean'" != "") + ("`gmean'" != "") /// 
		+ ("`xvar'" != "") + ("`sort'" != "") 
	
	if `nopts' > 1 { 
		di as err "invalid syntax" 
		exit 198
	} 	

	if "`diff'" != "" & "`ratio'" != "" { 
		di as err "may not combine diff and ratio options" 
		exit 198 
	} 	
	
	if "`trscale'" != "" { 
		if !index("`trscale'","@") { 
			di as err "trscale() does not contain @" 
			exit 198 
		}
	} 	

	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000
	else local nuse = r(N) 

	if "`gmean'" != "" { 
		capture assert `y1' > 0 & `y2' > 0 if `touse'
		if _rc { 
			di as err "non-positive values encountered" 
			exit 411 
		} 	
	} 		
	
	if "`diff'`ratio'" != "" { 
		if "`base'" == "" local base = cond("`diff'" != "", 0, 1) 
		tempvar basevar
		if "`legend'" == "" local legend "off" 
		if "`msymbol'" == "" local msymbol "Oh i"   
		local sy2 "ms(i)" 
	}
	else {
		if "`msymbol'" != "" {
                        tokenize `msymbol'
                        local sy2 = cond("`2'" != "", "ms(`2')", "ms(Th)") 
                }
                else  {                         
                        local msymbol "Oh Th" 
                        local sy2 "ms(Th)" 
                }

		if "`horizontal'" != "" { 
			local Y1 : variable label `y1' 
			if `"`Y1'"' == "" local Y1 "`y1'" 
			local Y2 : variable label `y2' 
			if `"`Y2'"' == "" local Y2 "`y2'" 
			local lgnd `"order(3 "`Y1'" 2 "`Y2'")"' 
		} 	
		else local lgnd "order(2 3)" 
		local lgnd "legend(`lgnd')" 
	}	

	if "`sort'" != "" gsort - `touse' `sort'

	qui if "`trscale'" != "" {
		foreach y of var `y1' `y2' { 
			local try : subinstr local trscale "@" "`y'", all 
			tempvar t 
			gen `t' = `try' 
			local lbl `"`: variable label `y''"' 
			if `"`lbl'"' != "" label var `t' `"`lbl'"' 
			else label var `t' "`y'" 
			local ty "`ty' `t'" 
		} 	
		tokenize `ty' 
		args y1 y2 
		local trscale : subinstr local trscale "@" "", all 
		local note ", `trscale' scale" 
	} 	

	qui if "`xvar'" == "" {
		tempvar xvar 
		
		if "`mean'" != "" { 
			gen `xvar' = (`y1' + `y2') / 2 if `touse' 
		} 	
		else if "`gmean'" != "" { 
			gen `xvar' = sqrt(`y1' * `y2') if `touse'
		} 	
        	else { 
			gen `xvar' = _n if `touse' 
			count if `touse' 
			// more than about 20 identifiers looks a mess
			if r(N) <= 20 { 
				capture { 
					levels `xvar' if `touse' 
					local xlabel "xla(`r(levels)')" 
					local ylabel "yla(`r(levels)')" 
				}	
			} 	
		} 	
		
		if "`mean'" != "" {
			label var `xvar' "mean of `oy1' and `oy2'`note'" 
		} 	
		else if "`gmean'" != "" { 
			label var `xvar' "geometric mean of `oy1' and `oy2'`note'" 
		} 
		else if "`sort'" != "" {
			if "`sortlabel'" != "" { 
				tempname sortlbl 
				local label : value label `sortlabel' 
				if "`label'" != "" {  
					forval i = 1/`nuse' { 
						label def `sortlbl' `i' ///
				"`: label `label' `=`sortlabel'[`i']''", modify 
					} 
				}
				else { 
					forval i = 1/`nuse' { 
						label def `sortlbl' `i' ///
						"`=`sortlabel'[`i']'", modify 
					} 
				} 	
				label val `xvar' `sortlbl' 
				local varlbl `"`: variable label `sortlabel''"' 
				if `"`varlbl'"' == "" local varlbl "`sortlabel'"
				label var `xvar' `sortlabel' 
				if "`horizontal'" != "" { 
					local ylabel "yla(1/`nuse', valuelabel ang(h))" 
				} 	
				else local xlabel "xla(1/`nuse', valuelabel)" 
			} 	
			else { 
				if !index("`sort'","-") unab sort : `sort' 
				label var `xvar' "rank on `sort'" 
			} 	
		} 
		else label var `xvar' "observation number" 
	} 	

	qui if "`diff'" != "" { 
		tempvar diff  
		gen `diff' = `y1' - `y2'
		label var `diff' "`oy1' - `oy2'`note'"
		local vtitle "`oy1' - `oy2'`note'" 
		local y1 `diff'
	        gen `basevar' = `base' 
		local y2 `basevar' 
        } 
	else qui if "`ratio'" != "" { 
		tempvar ratio  
		gen `ratio' = `y1' / `y2' 
		label var `ratio' "`oy1' / `oy2'`note'"
		local vtitle "`oy1' / `oy2'`note'" 
		local y1 `ratio' 
	        gen `basevar' = `base' 
		local y2 `basevar'
	} 	

	if `"`vtitle'"' == "" local vtitle "`oy1' and `oy2'`note'"
	
	foreach o in blstyle blcolor blwidth blpattern lstyle lcolor lwidth lpattern { 
		if `"``o''"' != "" local rspikeopts "`rspikeopts' `o'(``o'')"
	}

	if "`horizontal'" != "" {
		twoway rspike `y1' `y2' `xvar' if `touse', horiz `rspikeopts'  ///
		|| scatter  `xvar' `y2' if `touse', `sy2' `y2options'  ///
                || scatter  `xvar' `y1' if `touse', ///
	        `lgnd' legend(`legend') ms(`msymbol') xtitle(`vtitle') `ylabel' `options' ///
		|| `plot' ///
		|| `addplot' 
	} 
	else { 
		twoway rspike `y1' `y2' `xvar' if `touse', `rspikeopts'  ///
	        || scatter  `y1' `y2' `xvar' if `touse', `lgnd' legend(`legend') ///
		ytitle(`vtitle') ms(`msymbol') `xlabel' `options' ///
		|| `plot' ///
		|| `addplot' 
	} 	
end

/* 

Cole, T.J. 2000.  Sympercents: symmetric percentage differences on
the 100 log_e scale simplify the presentation of log transformed
data.  Statistics in medicine 19: 3109--3125. 
 
Clearly, 100 * (x_2 - x_1) / x_1 and 100 * (x_1 - x_2) / x_2
differ in magnitude as well as sign unless x_1 = x_2.  
 
However, 100 * (ln x_2 - ln x_1) has an attractive symmetry
property: only the sign changes if x_1 and x_2 are interchanged.
(This resembles the symmetry property of the difference 
x_1 - x_2.) 
 
What is more, it is, in effect, a symmetric percent difference
(which Cole calls a sympercent, with suggested symbol s%). This
fact arises from the equivalence in the limit of delta(ln x)
and (delta x) / x. 
 
*/ 


