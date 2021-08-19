*! 1.0.1 NJC 30 May 2021 
*! 1.0.0 NJC 29 May 2021 
program floatplot 
	version 17.0  
	syntax varname(numeric)                   ///
	[if] [in]                                 ///
	[fweight aweight/]                        ///
	[,                                        ///
	centre(numlist min=1 max=1 int)           ///
	center(numlist min=1 max=1 int)           ///
	HIGHNEGative(numlist min=1 max=1 int)     /// 
	VERTical                                  ///  
    over(varname)                             ///
	BY(str asis)                              /// 
	BARWidth(real 0.5)                        /// 
	FCOLORS(str asis)                         ///
	FCOLOURS(str asis)                        ///
	LCOLORS(str asis)                         ///
	LCOLOURS(str asis)                        ///
	baropts(str asis)                         ///
	PROPortions                               ///
	FREQuencies                               /// 
	FORMAT(str asis)                          ///
	SHOWVALopts(str asis)                     ///
	OFFSET(numlist max=1 >0)                  ///
	textoffset(real 0.35)                     ///
	addplot(str asis) * ] 

	// offset() undocumented: earlier name for textoffset() 
	// addplot() undocumented; possibly not much use 

	// are data suitable?	
	marksample touse 

	if "`by'" != "" { 
		gettoken byvar byopts : by, parse(,) 
		markout `touse' `byvar', strok 
		local byby by(`by')  
	}  

	if "`over'" != "" markout `touse' `over', strok 

	quietly count if `touse'
	if r(N) == 0 error 2000 
	
	// parsing options 
	if "`centre'" != "" & "`center'" != "" { 
		if "`centre'" != "`centre'" { 
			di as err "center(`center') and centre(`centre')  do not agree"
			error 498 
		}
	}
	else if "`centre'`center'" != "" { 
		local centre "`centre'`center'"
	}
	
	if "`centre'" == "" & "`highnegative'" == "" { 
		di as err "must specify centre() or center() or highnegative()"
		error 198 
	}

	if `"`fcolours'"' == "" local fcolours `"`fcolors'"' 
	if `"`fcolours'"' == "" { 
		di as err "must specify fcolors() or fcolours()"
		exit 198 
	}
	
	if `"`lcolours'"' == "" local lcolours `"`lcolors'"' 
	if `"`lcolours'"' == "" {
		local lcolours `"`fcolours'"'   
	}

	if "`showvalopts'" == "none" local showvaloff "*" 
	
	// go for it	
	preserve 

	quietly { 
	
	// if over() not specified, create a fake 
	if "`over'" == "" { 
		tempvar over 
		gen `over' = 1 
		label def `over' 1 "   "
		label val `over' `over'
		label var `over' "all values" 
		local otitle "all values" 
	}
	// otherwise map to integers 1 up 
	else { 
		tempvar work 
		local otitle : var label `over' 
		if `"`otitle'"' == "" local otitle `over' 
		egen `work' = group(`over'), label
		_crcslbl `work' `over'  
		local over `work' 
	} 

	// work towards desired variables 
	tempvar freq grade cumul CENTRE toshow zero TOSHOW shownum showtxt ypos xpos 
	if "`weight'" == "" { 
		contract `varlist' `over' `byvar' if `touse', zero freq(`freq')
	} 
	else if "`weight'" == "fweight" { 
		contract `varlist' `over' `byvar' [`weight'=`exp'] if `touse', zero freq(`freq')
	} 
	else { 
		bysort `varlist' `over' `byvar' : gen double `freq' = sum(`exp') 
		by `varlist' `over' `byvar': replace `freq' = `freq'[_N] 
		by `varlist' `over' `byvar': keep if _n == 1 
		fillin `varlist' `over' `byvar' 
		replace `freq' = 0 if _fillin 
	}  
 
	// ensure grade variable is labelled 1 up 
	egen `grade' = group(`varlist'), label
	
	su `grade', meanonly 
	local max = r(max)
	local maxM1 = `max' - 1 

	bysort `byvar' `over' (`grade') : gen double `cumul' = sum(`freq')

	if "`proportions'" != "" {
		`showvaloff' if "`format'" == "" local format "%3.2f"  
		`showvaloff' by `byvar' `over' : gen `shownum' = `freq'/`cumul'[_N] if `freq' > 0 
        `showvaloff' by `byvar' `over' : gen `showtxt' = string(`shownum', "`format'")

		by `byvar' `over' : replace `cumul' = `cumul'/`cumul'[_N] 
	} 
	else if "`frequencies'" != "" { 
		`showvaloff' if "`format'" == "" local format "%2.0f" 
		`showvaloff' by `byvar' `over' : gen `shownum' = `freq' if `freq' > 0               
		`showvaloff' by `byvar' `over' : gen `showtxt' = string(`shownum', "`format'")   
	} 
	else {
		`showvaloff' if "`format'" == "" local format "%2.0f" 
		`showvaloff' by `byvar' `over' : gen `shownum' = 100 * `freq'/`cumul'[_N] if `freq' > 0               
		`showvaloff' by `byvar' `over' : gen `showtxt' = string(`shownum', "`format'")   

		by `byvar' `over' : replace `cumul' = 100 * `cumul'/`cumul'[_N]
	}

	if "`highnegative'" != "" { 
		by `byvar' `over' : egen `CENTRE' = total((`varlist' == `highnegative') * `cumul') 
	}
	else { 
		tempvar lookup previous 
		by `byvar' `over' : egen `lookup' = mean(cond(`varlist' == `centre', `grade', .)) 
		by `byvar' `over' : egen `previous' = total((`grade' == (`lookup' - 1)) * `cumul') 
		by `byvar' `over' : egen `CENTRE' = total((`grade' == `lookup') * `cumul') 
		replace `CENTRE' = (`CENTRE' + `previous') / 2 
	}

    gen `toshow' = `cumul' - `CENTRE'  
	`showvaloff' gen `ypos' = `toshow' - `shownum'/2
	
	if "`offset'" != "" local textoffset `offset'  
	`showvaloff' gen `xpos' = `over' - (`textoffset') 
    gen `zero' = - `CENTRE' 
	by `byvar' `over' : gen `TOSHOW' = `toshow'[_n + 1]

	levelsof `over', local(levels)

	}  // end quietly 

	// prepare graph call 
	if "`vertical'" == "" local horizontal "horizontal"

	gettoken fcolour fcolours : fcolours 
	gettoken lcolour lcolours : lcolours 
    local call  rbar `zero' `toshow' `over' if `grade' == 1, `horizontal' bfcolor(`"`fcolour'"') blcolor(`"`lcolour'"') barw(`barwidth') `baropts' 
		
    forval j = 1/`maxM1' { 
		gettoken fcolour fcolours : fcolours 
		gettoken lcolour lcolours : lcolours 
		local call `call' || rbar `toshow' `TOSHOW' `over' if `grade' == `j', `horizontal' bfcolor(`"`fcolour'"') blcolor(`"`lcolour'"') barw(`barwidth') `baropts' 
		local label : label (`grade') `j'
		local legend`j' `j' "`label'"
	}
 
	local label : label (`grade') `max' 
	local legend`max' `legend' `max' "`label'" 

	if "`vertical'" == "" { 
		forval j = 1/`max' { 
			local legend `legend' `legend`j'' 
		} 
	} 
	else { 
		forval j = `max'(-1)1 {
			local legend `legend' `legend`j'' 
		}		
	}

	local vtitle : var label `varlist'
	if `"`vtitle'"' == "" local vtitle `varlist'

	if "`by'" == "" local gap = cond("`vertical'" == "", "xsc(titlegap(*5))", "ysc(titlegap(*5))") 

	if "`vertical'" == "" { 
		`showvaloff' local scall scatter `xpos' `ypos', ms(none) mla(`showtxt') mlabpos(0) mlabcolor(black) `showvalopts' 
		twoway `call' legend(order(`legend') row(1) pos(6)) `gap' xtitle(`"`vtitle'"')  ytitle(`"`otitle'"') ///
		yla(`levels', valuelabel ang(h) noticks tlength(0)) xli(0, lc(gs12)) xla(none) `byby' `options' || `scall' || `addplot' 
	} 
	else { 
		`showvaloff' local scall scatter `ypos' `xpos', ms(none) mla(`showtxt') mlabpos(0) mlabcolor(black) `showvalopts' 
		twoway `call' legend(order(`legend') col(1) pos(3)) `gap' ytitle(`"`vtitle'"') xtitle(`"`otitle'"')  ///
		xla(`levels', valuelabel ang(h) noticks tlength(0)) yli(0, lc(gs12)) yla(none) `byby' `options' || `scall' || `addplot' 
	} 

end 

 
