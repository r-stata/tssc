*! 1.0.7 NJC 22 January 2007
* 1.0.6 NJC 21 February 2006
* 1.0.5 NJC 27 September 2005 
* 1.0.4 NJC 17 February 2005 
* 1.0.3 NJC 27 October 2004 
* 1.0.2 NJC 24 May 2004 
* 1.0.1 NJC 26 February 2004 
* 1.0.0 NJC 22 February 2004 
program tableplot, sort 
	version 8

	gettoken plottype 0 : 0 
	local plotlist "rbar rcap rcapsym rspike" 
	if !`: list plottype in plotlist' { 
		di ///
		"{p}{txt}syntax is {inp:tableplot} {it:plottype varlist} " /// 
		"... e.g. {inp: tableplot rspike }{txt:{it:toshow rowvar colvar}} ...{p_end}" 
		exit 198 
	}

	syntax varlist(min=3 max=3) [if] [in]                      ///
	[, MISSing yasis xasis HORizontal Height(numlist max=1 >0) ///
	scatter(str asis) PLOT(str asis) MSymbol(str)              ///
	SHOWval SHOWval2(str asis) BY(str asis) ADDPLOT(str asis) * ]

	if "`missing'" != "" local novarlist "novarlist" 
	marksample touse, strok `novarlist' 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize `varlist' 
	args toshow row col

	if `"`by'"' != "" { 
		gettoken by1 by2 : by, parse(",") 
		if "`xasis'" == "" local noti "noixtick" 
		if "`yasis'" == "" local noti "`noti' noiytick" 
		if `"`by2'"' != "" local by `"by(`by' `noti' legend(off))"'  
		else local by `"by(`by', `noti' legend(off))"' 
	} 	

	capture bysort `touse' `by1' `row' `col' : ///
		assert `toshow'[1] == `toshow'[_N] 
	if _rc { 
		di as err "`toshow' not unique in each cell" 
		exit 498 
	} 	

	tempvar tag show  

	quietly { 
		local xtitle : variable label `col' 
		if `"`xtitle'"' === "" local xtitle "`col'" 
		local ytitle : variable label `row' 
		if `"`ytitle'"' === "" local ytitle "`row'" 
	
		if "`yasis'" == "" {
			tempvar y 
			// map to integers 1 ... and carry labels
			egen `y' = axis(`row') if `touse', `missing' reverse 
			local row "`y'"
			local noyticks "noticks" 
		}
		capture levels `row', local(ylevels) 
		
		if "`xasis'" == "" {
			tempvar x
			// map to integers 1 ... and carry labels
			egen `x' = axis(`col') if `touse', `missing'  
			local col "`x'"
			local noxticks "noticks" 
		}
		capture levels `col', local(xlevels) 
		
		su `toshow' if `touse',  meanonly
		local max = max(r(max), abs(r(min)))
		if "`height'" == "" local height = cond(r(min) < 0, 0.5, 0.8) 
		if "`horizontal'" != "" { 
			gen `show' = `col' + `height' * `toshow' / `max' 
		}	
		else gen `show' = `row' + `height' * `toshow' / `max' 
		
		bysort `touse' `varlist' `by1' : ///
			gen byte `tag' = `touse' * (_n == 1)
	
		local what `"`:variable label `toshow''"' 
		if `"`what'"' == "" local what "`toshow'" 

		if "`plottype'" == "rbar" local opt "barw(0.5)" 
		local how = cond("`msymbol'" != "", "`msymbol'", "none") 

		if "`showval'`showval2'" != "" { 
			local goptions `options'
			local 0 , `showval2' 
			syntax [, format(str) offset(real 0.1) * ] 
			local opts `options' 
			local options `goptions' 
			tempvar row2 
			gen `row2' = `row' - (`offset') 
			if "`format'" != "" { 
				tempvar Toshow 
				gen `Toshow' = string(`toshow', "`format'") 
				local toshow `Toshow' 
			}

			local showval "scatter `row2' `col' if `tag', ms(none) mla(`toshow')"
			if "`horizontal'" != "" { 
				local showval `"`showval' mlabpos(11) `opts'"' 
			} 	
			else local showval `"`showval' mlabpos(0) `opts'"' 
		} 	
	}
	
	if `"`by'"' == "" { 
		local notwithby "subtitle(`what', place(w) size(medsmall))" 
	}	

	if "`horizontal'" != "" {
		twoway scatter `row' `col' if `tag',                    ///
		ms(none) xla(`xlevels', `noyticks' nogrid val)          ///
                || scatter `row' `show' if `tag',                       ///
		ms(`how') yla(`ylevels', `noxticks' nogrid ang(h) val)  ///
		|| `showval'                                            ///
		|| `plottype' `show' `col' `row' if `tag', horizontal   ///
		xla(`xlevels', `noxticks' grid val) xti("`xtitle'")     ///
		`notwithby'                                             /// 
		yti("`ytitle'") `opt' `by' legend(off) `options'        ///
		|| `plot'                                               ///
		|| `addplot'
		// blank 
	} 
	else { 
		twoway scatter `row' `show' `col' if `tag',              ///
		ms(none `how') yla(`ylevels', `noyticks' ang(h) val)     ///
		|| `showval'                                             /// 
		|| `plottype' `show' `row' `col' if `tag',               ///
		xla(`xlevels', `noxticks' val) xti("`xtitle'")           ///
		`notwithby'                                              /// 
		yti("`ytitle'") `opt' `by' legend(off) `options'         ///
		|| `plot'                                                ///
		|| `addplot' 
		// blank 
	} 	
end

