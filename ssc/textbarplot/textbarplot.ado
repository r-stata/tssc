*! 1.0.1 NJC 17 March 2006 
*! 1.0.0 NJC 6 March 2006 
program textbarplot
	version 8.2 
	syntax varlist(min=2 max=2) [if] [in]   ///
	[, Y(varname numeric) SCatter(str asis) ///
	PLOT(str asis) VERTical HORizontal ADDPLOT(str asis) * ] 

	if _caller() >= 9 local of "of" 

	quietly { 
		marksample touse, strok 
		
		if "`vertical'" != "" & "`horizontal'" != "" { 
			di as err "may not specify both vertical or horizontal" 
			exit 198 
		}
	
		if "`y'" != "" { 	
			markout `touse' `y' 
			
			capture assert `y' == floor(`y') if `touse' 
			if _rc { 
				di as err "`y' not integer variable" 
				exit 498 
			}	 
		}	
		
		count if `touse' 
		if r(N) == 0 error 2000 
		
		tokenize `varlist'
		args text bar 

		capture confirm numeric variable `bar' 
		if _rc { 
			di as err "`bar' not numeric"
			exit _rc 
		} 

		capture confirm numeric variable `text' 

		if _rc == 0 { // `text' is numeric 
			if "`y'" == "" { 
				capture assert `text' == floor(`text') if `touse' 
				if _rc { 
					di as err "`text' not integer variable" 
					exit 498 
				}	

				local y "`text'" 
			}
			else {
				tempvar Y obs 
				gen long `Y' = `y' 
				local y "`Y'" 
				
				gen long `obs' = _n 
				levels`of' `obs' if `touse', local(levels) 
				
				tempname lbl 
				foreach l of local levels { 
					local tval : ///
						label (`text') `= `text'[`l']' 
					label def `lbl' ///
						`= `y'[`l']' `"`tval'"', add    
				}
				label val `y' `lbl' 
			}
			
			levels`of' `y', local(levels) 
		}
		else { // `text' is string 
			if "`y'" != "" {
				tempvar Y obs 
				gen long `Y' = `y' 
				local y "`Y'" 
				gen long `obs' = _n 
			}
			else { 
				tempvar y
				gen long `y' = _n if `touse' 
				local obs "`y'" 
			}
			
			levels`of' `obs' if `touse', local(levels) 
			tempname lbl 
			foreach l of local levels { 
				label def `lbl' ///
					`= `y'[`l']' `"`= `text'[`l']'"', add
			}
			label val `y' `lbl' 
		}	
					
		preserve 
		keep if `touse' 
		levels`of' `y', local(levels) 
	}	

	if "`vertical'" == "" { 
		twoway bar `bar' `y', base(0)                       ///
		yla(`levels', valuelabel nogrid noticks ang(h))     ///
		hor ysc(reverse) ytitle("")                         ///
		barw(0.6) legend(off) `options'                     ///
		|| scatter `y' `bar', ytitle("") ms(none) `scatter' ///
		|| `addplot'                                        ///
		|| `plot'                                          
	}
	else { 
		twoway bar `bar' `y', base(0)                       ///
		xla(`levels', valuelabel nogrid noticks ang(v))     ///
		xtitle("") barw(0.6) legend(off) `options'          ///
		|| scatter `bar' `y', xtitle("") ms(none) `scatter' ///
		|| `addplot'                                        ///
		|| `plot'                                          
	}
end 
	
