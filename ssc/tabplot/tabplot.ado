*! 2.8.0 NJC 2 July 2019 
* 2.7.2 NJC 30 June 2017 
* 2.7.1 NJC 12 February 2017 
* 2.7.0 NJC 6 April 2016 
* 2.6.1 NJC 19 October 2012 
* 2.6.0 NJC 10 October 2011 
* 2.5.2 NJC 21 September 2011 
* 2.5.1 NJC 10 September 2011 
* 2.5.0 NJC 21 April 2011 
* 2.4.4 NJC 1 March 2011 
* 2.4.3 NJC 13 December 2010 
* 2.4.2 NJC 11 June 2010 
* 2.4.1 NJC 4 December 2009 
* 2.4.0 NJC 20 November 2009 
* 2.3.0 NJC 28 August 2009 
* 2.2.0 NJC 6 July 2009 
* 2.1.2 NJC 22 January 2007 
* 2.1.1 NJC 21 February 2006 
* 2.1.0 NJC 26 September 2005 
* 2.0.6 NJC 15 June 2005 
* 2.0.5 NJC 17 February 2005 
* 2.0.4 NJC 27 October 2004 
* 2.0.3 NJC 11 May 2004 
* 2.0.2 NJC 22 February 2004 
* 2.0.0 NJC 16 February 2004 
* 1.0.1 NJC 26 February 1999
program tabplot, sort 
	version 8

	forval i = 1/20 {
		local baropts `baropts' bar`i'(str asis)
	}

	syntax varlist(min=1 max=2) [if] [in]                    ///
	[fweight aweight iweight/]                               ///
	[, PERCent(varlist) PERCent2 FRaction(varlist) FRaction2 ///
	PERMille(varlist) PERMille2                              ///
	MISSing yasis xasis HORizontal Height(real 0.8)          ///
        YREVerse XREVerse                                        /// 
	SHOWval SHOWval2(str asis)                               ///
        YSCale(passthru) XSCale(passthru)                        ///
	BY(str asis) recast(passthru) BARWidth(real 0.5)         ///
        SEParate(str) SEPerate(str)                              ///
	MAXimum(numlist max=1) MINimum(numlist max=1)            ///
       `baropts' barall(str asis)                                ///
	frame(numlist max=1) frameopts(str asis)                 /// 
        PLOT(str asis) ADDPLOT(str asis) * ]

	if "`seperate'" != "" & "`separate'" == "" {  
		di in gr "(note:  separate is spelled sep" in ye "a" ///
		in gr "rate)"
		local separate "`seperate'" 
	} 

	if "`missing'" != "" local novarlist "novarlist" 
	marksample touse, strok `novarlist' 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	local pc "`percent'" 
	local pc2 "`percent2'" 
	local pm "`permille'" 
	local pm2 "`permille2'" 
	
	local nopts = ("`pc'" != "") + ("`pc2'" != "") ///
		+ ("`fraction'" != "" ) + ("`fraction2'" != "") + ("`pm'" != "") + ("`pm2'" != "") 
	if `nopts' > 1 {
		if "`fraction'`fraction2'" != "" local what "fraction" 
		if "`pc'`pc2'" != "" local what = cond("`what'" == "", "percent", "and percent") 
		if "`pm'`pm2'" != "" local what = cond("`what'" == "", "per mille", "and per mille") 
		di as err "`what' options may not be combined"
		exit 198
	}

	local pvars `pc' `fraction' `permille' 
	local prop = cond("`fraction'`fraction2'" != "", "prop", "") 

	if "`pc2'" != ""            local what "percent" 
	else if "`fraction2'" != "" local what "fraction" 
	else if "`pm2'" != ""       local what "per mille" 
	else if "`pc'" != ""        local what "percent given `pc'" 
	else if "`fraction'" != ""  local what "fraction given `fraction'" 	
	else if "`pm'" != ""        local what "per mille given `permille'" 
	else if "`exp'" != "" { 
		capture unab wexp : `exp' 
		if _rc local what "`exp'" 
		else local what "`wexp'" 
	}
	else local what "frequency" 

	if "`xasis'" != "" & "`xreverse'" != "" { 
		di as err "must choose between xasis and xreverse options" 
		exit 198 
	} 

	if "`yasis'" != "" & "`yreverse'" != "" { 
		di as err "must choose between yasis and yreverse options" 
		exit 198 
	} 

	// ad hoc code if user specifies xsc(reverse) or ysc(reverse) 
	// better advised to use xreverse or yreverse 
	if index(`"`yscale'"', "rev") & !index(`"`yscale'"', "norev") {  
		local ysign "-" 
	} 	
	else local ysign "+" 
		
	if index(`"`xscale'"', "rev") & !index(`"`xscale'"', "norev") {  
		local xsign "-"  
	} 
	else local xsign "+"
	
	if `"`by'"' != "" { 
                parseby `by' 
	}	

	if "`maximum'" != "" & "`minimum'" != "" { 
		if `minimum' > `maximum' { 
			di as err "maximum() and minimum() are inconsistent" 
			exit 498 
		}
	}		
			
	tempvar toshow tag show
	
	quietly { 
		if "`pc2'" != "" | "`fraction2'" != "" | "`pm2'" != "" {
			local total = cond("`pc2'`pm2'" != "", 100, 1)
			if "`weight'" == "" { 
				egen `toshow' = pc(`total') if `touse', ///
					`prop'
			} 
			else egen `toshow' = pc(`exp') if `touse', ///
					`prop' 
		} 
		else if "`pvars'" != "" {
			local total = cond("`pc'`pm'" != "", 100, 1)
			if "`weight'" == "" { 
				egen `toshow' = pc(`total') if `touse', ///
					`prop' by(`pvars') 
			}
			else egen `toshow' = pc(`exp') if `touse', ///
					`prop' by(`pvars') 
		} 	
		else {
			if "`weight'" == "" gen `toshow' = `touse' 
			else gen `toshow' = `touse' * (`exp') 
			if "`weight'" == "aweight" { 
				count if `touse' 
				local N = r(N) 
				su `toshow', meanonly 
				replace `toshow' = `toshow' * `N' / r(sum)
			}	
		} 	
		
		bysort `varlist' `byvars' : replace `toshow' = sum(`toshow')
		by `varlist' `byvars' : replace `toshow' = `toshow'[_N]
		if "`pm'`pm2'" != "" replace `toshow' = 10 * `toshow' 

		/// row is y coordinate 
		/// col is x coordinate 
		local nvars : word count `varlist' 
		if `nvars' == 1 { 
			if "`horizontal'" == "" { 
				tempvar row 
				gen byte `row' = 1 
				local ytitle 
				local col "`varlist'" 
				local xtitle : variable label `col' 
				if `"`xtitle'"' === "" local xtitle "`col'" 
				local one yla(none) ysc(r(1 .)) 
			} 
			else { 
				local row "`varlist'" 
				tempvar col 
				gen byte `col' = 1 
				local xtitle
 				local ytitle : variable label `row' 
				if `"`ytitle'"' === "" local ytitle "`row'" 
				local one xla(none) xsc(r(1 .)) 
			}  
		} 
		else { 
			tokenize `varlist' 
			args row col                        
			local ytitle : variable label `row' 
			if `"`ytitle'"' === "" local ytitle "`row'" 
			local xtitle : variable label `col' 
			if `"`xtitle'"' === "" local xtitle "`col'" 
		}
	
		if "`yasis'" == "" {
			if "`yreverse'" == "" local yreverse "reverse" 
			else local yreverse 
			tempvar y 
			// map to integers 1 ... and carry labels
			axis `row' if `touse', gen(`y') `missing' `yreverse'  
			local row "`y'"
			local noyti "noticks" 
		}
		capture levels `row', local(ylevels) 
		
		if "`xasis'" == "" {
			if "`xreverse'" != "" local xreverse "reverse" 
			tempvar x
			// map to integers 1 ... and carry labels
			axis `col' if `touse', gen(`x') `missing' `xreverse' 
			local col "`x'"
			local noxti "noticks" 
		}
		capture levels `col', local(xlevels) 

		gen `show' = `toshow' 
		if "`maximum'" != "" replace `show' = min(`maximum', `show') 
		if "`minimum'" != "" replace `show' = 0 if `show' < `minimum'
		su `show', meanonly
		if -r(min) > r(max) { 
			local biggest = r(min)
			local text "minimum"
		}
		else { 
			local biggest = r(max)
			local text "maximum"  
		}

		if `biggest' == 0 { 
			di as err "all bars zero height?"
			exit 498 
		}

		if "`frame'" != "" { 
			if `frame' > 0 	local BIGGEST = max(`biggest', `frame')
			else if `frame' < 0 local BIGGEST = min(`biggest', `frame') 
			tempvar FRAME 
		} 
		else local BIGGEST = `biggest' 

		if "`horizontal'" != "" { 
			if "`frame'" != "" gen `FRAME' = `col' `xsign' `height' * `frame' / abs(`BIGGEST') 
			replace `show' = `col' `xsign' `height' * `show' / abs(`BIGGEST')
		}	
		else { 
			if "`frame'" != "" gen `FRAME' = `row' `ysign' `height' * `frame' / abs(`BIGGEST') 
			replace `show' = `row' `ysign' `height' * `show' / abs(`BIGGEST') 
		}
		
		bysort `touse' `varlist' `byvars' : ///
			gen byte `tag' = `touse' * (_n == 1)
	}

	qui if "`separate'" != "" { 
		if strpos("`separate'", "@") { 
			local separate : subinstr local separate "@" "`toshow'", all 
		} 

		capture separate `show' if `tag', by(`separate') 

		if _rc { 
			di as err "separate() option: " _c 
			error _rc 
		} 

		local sepvars `r(varlist)' 
		local J : word count `sepvars' 
		local Jm1 = `J' - 1 
		tokenize `sepvars' 

		if `J' == 1 local separate 
	}	 	

	qui if "`showval'`showval2'" != "" { 
		local goptions `options'
		local 0 `showval2' 
		capture syntax varname [, format(str) ///
		offset(numlist max=1) zoffset(numlist max=1) * ] 
		if _rc == 0 { 
			local toshow `varlist'  
			local varspec 1 
		}
		else { 
			gettoken comma 0: 0, parse(",") 
			if "`comma'" == "," local 0 `showval2' 
	 		else local 0 , `showval2' 
			syntax [, format(str) ///
			offset(numlist max=1) zoffset(numlist max=1) * ] 
			local varspec 0 
		}

		if "`offset'`zoffset'" == "" local offset 0.1 
		else if "`offset'" != "" & "`zoffset'" != "" { 
			di as err "choose between offset() and zoffset()" 
			exit 198
		}

		local opts `options' 
		local options `goptions' 

		tempvar row2 col2 
		gen `col2' = `col' 
		if "`zoffset'" != "" {  
			gen `row2' = `row' - (`zoffset')
		}
		else {
			if "`horizontal'" == "" { 
				gen `row2' = min(`show', `row') - (`offset') 
			}
			else { 
				gen `row2' = `row' - (`offset') 
				replace `col2' = min(`show', `col') 
			}
		}

		if "`format'" == "" { 
			if `varspec' local format : format `toshow' 
			else if "`percent'`percent2'" != "" local format %2.1f 
			else if "`fraction'`fraction2'" != "" local format %4.3f 		
			else if "`pm'`pm2'" != "" local format %3.0f 		
		}

		if "`format'" != "" { 
			capture confirm numeric variable `toshow' 
			if _rc format `toshow' `format' 
			else { 
				tempvar Toshow 
				gen `Toshow' = string(`toshow', "`format'") 
				local toshow `Toshow' 
			} 
		}

		if "`horizontal'" != "" { 
			su `col', meanonly
			local min = r(min) - 0.1 
			local where mlabpos(11) xsc(r(`min' .)) 
		}
		else { 
			su `row', meanonly 
			local min = r(min) - 0.02
			local pos = cond(`nvars' == 1, 12, 0) 
			local where mlabpos(`pos') ysc(r(`min' .)) 
		} 
		local showval scatter `row2' `col2' if `tag', ms(none) mla(`toshow') mlabcolor(black) `where' `opts'
	} 
	else {
 		if "`percent'`percent2'" != "" local format %2.1f 
		else if "`fraction'`fraction2'" != "" local format %4.3f 
		else if "`pm'`pm2'" != "" local format %3.0f 		

		local biggest = trim("`: di `format' `biggest''")
		if "`frame'" != "" local note "note(`text': `biggest'; frame: `frame')"  
		else local note "note(`text': `biggest')"
 	}

	if `"`by'"' == "" { 
		local notwithby "subtitle(`what', place(w) size(medsmall)) legend(off) `note'" 
	}	
	else {
	        if `"`bynote'"' != "" local note `"note(`bynote')"' 
		if "`xasis'" == "" local noti "noixtick" 
		if "`yasis'" == "" local noti "`noti' noiytick" 
		if "`byvars'" != "" local by `"by(`byvars', `note' `noti' `byopts' legend(off) )"' 
	}	

	if "`recast'" == "" local bw "barwidth(`barwidth')" 
 
	if "`horizontal'" != "" { 
		if "`separate'" != "" { 
			forval j = 1/`Jm1' { 
				local barcall `barcall' || rbar ``j'' `col' `row' if `tag',       ///
				horizontal `one' `notwithby' `recast' `bw' `yscale' `xscale'      ///
                                pstyle(p`j'bar) `barall' `bar`j''  
			} 
			local barcall `barcall' || rbar ``J'' `col' `row' if `tag',  ///
			horizontal xti("`xtitle'")                                   ///
			xla(`xlevels', val grid angle(-.001) labgap(2) `noxti')      ///
			`one' `notwithby' `recast' yti("`ytitle'") `bw'              ///
			`yscale' `xscale' `by' pstyle(p`J'bar) `barall' `bar`J'' 
		}

		else local barcall || rbar `show' `col' `row' if `tag',       ///
		horizontal xti("`xtitle'")                               ///
		xla(`xlevels', val grid angle(-.001) labgap(2) `noxti')  ///
		`one' `notwithby' `recast' yti("`ytitle'") `bw'          ///
		`yscale' `xscale' `by' pstyle(p1bar) 

		if "`frame'" != "" local framecall rbar `FRAME' `col' `row' if `tag', horizontal `bw' bfcolor(none) `frameopts' 

		twoway scatter `row' `col' if `tag',                     ///
		ms(none) yla(`ylevels', `noyti' nogrid ang(h) val)       ///
		|| `showval'                                             /// 
                || `framecall'                                           /// 
		`barcall' `options'                                      ///
		|| `plot'                                                ///
		|| `addplot' 
		// blank 
	} 
	else { 
		if "`separate'" != "" { 
			forval j = 1/`Jm1' { 
				local barcall `barcall' || rbar ``j'' `row' `col' if `tag',  ///
				`one' `notwithby' `recast' `yscale' `xscale' `bw'            ///
				pstyle(p`j'bar) `barall' `bar`j''
			} 
			local barcall `barcall' || rbar ``J'' `row' `col' if `tag',  ///
			xla(`xlevels', `noxti' val)  xti("`xtitle'")                 ///
			`one' `notwithby' `recast' yti("`ytitle'") `bw'              ///
			`yscale' `xscale' `by' pstyle(p`J'bar) `barall' `bar`J'' 
		}

		else local barcall || rbar `show' `row' `col' if `tag',       ///
		xla(`xlevels', `noxti' val) xti("`xtitle'")              ///
		`one' `notwithby' `recast' yti("`ytitle'") `bw'          ///
		`yscale' `xscale' `by' pstyle(p1bar)

		if "`frame'" != "" local framecall rbar `FRAME' `row' `col' if `tag', `bw' bfcolor(none) `frameopts' 

		twoway scatter `row' `col' if `tag',                     ///
		ms(none) yla(`ylevels', `noyti' ang(h) val)              ///
		|| `showval'                                             /// 
                || `framecall'                                           /// 
		`barcall' `options'                                      ///
		|| `plot'                                                ///
		|| `addplot' 
		// blank 
	} 	
end

* axis 1.0.3 NJC 15 Oct 2012 
* axis 1.0.2 NJC 10 Oct 2011 
* axis 1.0.1 NJC 9 Sept 2011 
* axis 1.0.0 NJC 21 April 2011 
* _gaxis 1.0.0 NJC 6 February 2004 
program axis, sort
	version 8
	syntax varlist [if] [in] [, Missing REVerse Generate(str)]

	quietly {
		marksample touse, strok novarlist 
		if "`missing'" == "" markout `touse' `varlist', strok
		local g "`generate'"
		bysort `touse' `varlist' : gen `g' = _n == 1 if `touse'  
		replace `g' = sum(`g') if `touse'   

		tempvar order 
		gen long `order' = _n 
	} 	

	su `g', meanonly 
	if "`reverse'" != "" { 
		replace `g' = r(max) - `g' + 1 
		su `g', meanonly 
	} 

	local lbl `g' 

	forval i = 1/`r(max)' { 
		su `order' if `g' == `i', meanonly 
		if "`: value label `varlist''" != "" { 
			local vlbl : label (`varlist') `=`varlist'[r(min)]' 
		}
		else local vlbl = `varlist'[r(min)] 
		label def `lbl' `i' `"`vlbl'"', modify 
	}
		 	
	label val `g' `lbl' 
end

* 1.0.0 NJC 2 April 2016 
program parseby 
	syntax varlist [, note(str asis) * ] 
	c_local byvars `varlist' 
        c_local bynote `"`note'"' 
	c_local byopts `options' 
end 
