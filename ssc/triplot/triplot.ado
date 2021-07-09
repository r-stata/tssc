*! 2.2.2 NJC 6 Feb 2009
* 2.2.1 NJC 6 Feb 2009
* 2.2.0 NJC 27 Jan 2009
* 2.1.3 NJC 19 March 2007
* 2.1.2 NJC 4 December 2004 
* 2.1.1 NJC 17 August 2004 
* 2.1.0 NJC 14 August 2004 
* 2.0.1 NJC 5 August 2004 
* 2.0.0 NJC 27 January 2004 
* 1.2.3 NJC 28 June 2000 
* 1.2.2 NJC 24 November 1999
* 1.2.1 NJC 28 March 1999
* 1.1.0 NJC 6 May 1998
program triplot, sortpreserve  
	version 9 
	syntax varlist(min=3 max=3 numeric) [if] [in]        ///
	[, max(numlist max=1 >0)  SEParate(varname)          ///
	centre(numlist min=3 max=3 >0)                       ///
	center(numlist min=3 max=3 >0)                       ///
	LAbel(str) grid(str asis)                            ///
	VERTices(real 1) frame(str asis) Y Y2(str)           ///  
	ltext(str) rtext(str) btext(str)                     ///
	bltext(str) brtext(str) ttext(str)                   /// 
	text(str asis) by(str) * ] 
	
	// # to use 
	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000
	
	// default maximum; check 0 <= values <= maximum 
	if "`max'" == "" local max 1 

	tokenize `varlist'
	args a b c 
	foreach v of local varlist { 
		capture assert `v' >= 0 & `v' <= `max' if `touse'
		if _rc {
			di as err "`v' has values outside [0, `max']"
			exit 198
		}
	}

	// labels 
	if "`label'" != "nolabels" { 
		if "`label'" == "" {
			if `max' == 1000 local label "0 200 400 600 800 1000"
			else if `max' == 100 local label "0 20 40 60 80 100" 
			else local label "0 .2 .4 .6 .8 1"
		}	
		else { 
			local abb = substr("sixths",1,length("`label'")) 
			if lower("`label'") == "`abb'" { 
				local label "0 1/6 1/3 1/2 2/3 5/6 1" 
				local sixths "sixths"
			}
			else { 	
				numlist "`label'", miss
				local label "`r(numlist)'" 
			} 
		} 	
	}	
	else local label 
	
	// graph geometry constants 
	local htfact = sqrt(3)/2                    /* sin _pi/3 = 60 deg */
	local xL 0                                /* triangle coordinates */
	local xR 1 
	local xT = (`xL' + `xR') / 2
	local width = `xR' - `xL'
	local height = `width' * `htfact'
	local yB 0
	local yT = `yB' + `height'
	local yM = `yB' + `height' / 2            /* position of var text */

	tempvar left right bot yvar xvar  

	quietly {
		// scale if necessary 
		gen `left' = `a'
		gen `right' = `b'
		gen `bot' = `c' 
	    
		if "`center'`centre'" != "" {
			tempvar left2 right2 bot2
			tokenize "`center'`centre'" 
			args A B C 
			gen `left2' = ///
	(`left' / `A') / ((`left' / `A') + (`right' / `B') + (`bot' / `C'))
			gen `right2' = /// 
	(`right' / `B') / ((`left' / `A') + (`right' / `B') + (`bot' / `C'))
			gen `bot2' = /// 
	(`bot' / `C') / ((`left' / `A') + (`right' / `B') + (`bot' / `C'))
			local left "`left2'"
			local right "`right2'" 
			local bot "`bot2'" 
			local A = `A' / `max'
			local B = `B' / `max'
			local C = `C' / `max'
		} 
		else if `max' != 1 {
			replace `left' = `left' / `max' 
			replace `right' = `right' / `max' 
			replace `bot' = `bot' / `max' 
	        }

		// text on sides and at vertices 
		local ypos = `yM' + 1/24
		local xpos = `xL' + 5 * `width' / 24    

		if `"`ltext'"' == "" {
			local ltext : variable label `a'
			if `"`ltext'"' == "" local ltext "`a'"
		}	
		local text_call `ypos' `xpos' (9) `"`ltext'"' 
		
		local xpos = `xT' + 7 * `width' / 24  

	        if `"`rtext'"' == "" {
			local rtext : variable label `b'
			if `"`rtext'"' == "" local rtext "`b'" 
		} 	
	        local text_call `text_call' `ypos' `xpos' (3) `"`rtext'"'
 
		local ypos = cond(`"`by'"' != "", -1/12, -1/24)

	    	if `"`btext'"' == "" {
			local btext : variable label `c'
			if `"`btext'"' == "" local btext "`c'" 
		} 	
		local text_call `text_call' `ypos' `xT' (6) `"`btext'"' 

		local text_call `text_call' 0 `xL' (9) `"`bltext'"'    ///
                                            `yT' `xT' (12) `"`ttext'"' ///
                                            0 `xR' (3) `"`brtext'"' 

		local top = cond("`ttext'" != "", 0.95, 0.9) 
	        
		// triangular frame
		if `vertices' == 1 {
			local frame_call `yB' `xL' `yT' `xT' `yB' `xR' `yB' `xL'
		}
		else {
			local v = `vertices' / 2
			local yV = `yB' + `v' * (`yT' - `yB')
			local yV2 = `yT' - `v' * (`yT' - `yB')
			local xV = `xL' + `v' * `width' / 2
			local xV2 = `xT' - `v' * `width' / 2
			local xV3 = `xT' + `v' * `width' / 2
			local xV4 = `xR' - `v' * `width' / 2
			local xV5 = `xR' - `v' * `width' 
			local xV6 = `xL' + `v' * `width' 
			
			local frame_call `yB' `xL' `yV' `xV' .  . `yV2' `xV2' `yT' `xT' `yV2' `xV3' ///
				.  . `yV' `xV4' `yB' `xR' `yB' `xV5'  . `yB' `xV6' `yB' `xL' 
		}

		// y ? 
		//   1 on bottom side (y = `yB') 
		//   2 in middle 
		//   3 on left side
		//   4 missing (no connect) 
		//   5 on right side
		//   6 = 2 
		
		if "`y'" == "y" | "`y2'" != "" {

			if "`centre'`centre'" == "" { 
				local yY2 = `yB' + (`yT' + `yB') / 3
				local yY3 = (`yT' + `yB') / 2
				local yY5 = (`yT' + `yB') / 2
				local xY1 = `xT'
				local xY2 = `xT'
				local xY3 = (`xL' + `xT') / 2
				local xY5 = (`xR' + `xT') / 2
			}
			else {
				local yAA = (1 / `A') / ((1 / `A') + (1 / `B') + (1 / `C'))
				local yBB = (1 / `B') / ((1 / `A') + (1 / `B') + (1 / `C'))
				local yY2 = `yB' + `height' * `yAA' 
				local yY3 = ///  
		`yB' + `height' * (1 / `A') / ((1 / `A') + (1 / `C'))
				local yY5 = ///  
		`yT' - `height' * (1 / `B') / ((1 / `A') + (1 / `B'))  
				local xY1 = ///
		`xR' - `width' * (1 / `C') / ((1 / `B') + (1 / `C'))  
				local xY2 = `xL' + `width' * (`yBB' + (`yAA' / 2) 
				local xY3 = ///
		`xL' + (`width' / 2) * (1 / `A') / ((1 / `A') + (1 / `C'))  
				local xY5 = ///
		`xT' + (`width' / 2) * (1 / `B') / ((1 / `A') + (1 / `B'))  
			} 

			local y_yx `yB' `xY1' `yY2' `xY2' `yY3' `xY3' . . `yY5' `xY5' `yY2' `xY2' 
			local y_call || scatteri `y_yx', recast(line) lc(black) lp(shortdash) cmiss(n) `y2'    
		}

		// labels: we put missings in gaps to stop connection 

		foreach l of local label { 
			local L `"`l'"' 
			if "`sixths'" != "" local l = `l'
			else local l = `l' / `max' 
			
			if "`centre'`center'" == "" { 
				local l_label `l_label' `= `yB' + `height' * `l'' `= `xL' + (`width' / 2) * `l'' `"`L'"' 
				local r_label `r_label' `= `yT' - `height' * `l'' `= `xT' + (`width' / 2) * `l'' `"`L'"' 
				local b_label `b_label' `yB' `= `xR' - `width' * `l'' `"`L'"'  
			
				if `l' > 0 & `l' < 1 { 
					local l_label `l_label' `= `yB' + `height' * `l'' `= `xT' + (`width' / 2) * (1 - `l')' 
					local r_label `r_label' `yB'  `= `xL' + `width' * `l'' 
					local b_label `b_label' `= `yT' - `height' * `l'' `= `xL' + (`width' / 2) * (1 - `l')' 
				} 	
			} 
			else { 
				local ll = (`l' / `A') / ((`l' / `A') + (1 - `l') / `C') 
				local lr = (`l' / `B') / ((`l' / `B') + (1 - `l') / `A') 
				local lb = (`l' / `C') / ((`l' / `C') + (1 - `l') / `B') 
				local lL = ((1 - `l') / `B') / ((`l' / `A') + (1 - `l') / `B') 
				local lR = ((1 - `l') / `C') / ((`l' / `B') + (1 - `l') / `C') 
				local lB = ((1 - `l') / `A') / ((`l' / `C') + (1 - `l') / `A') 
	
				local l_label `l_label' `= `yB' + `height' * `ll'' `= `xL' + (`width' / 2) * `ll'' `"`L'"' 
				local r_label `r_label' `= `yT' - `height' * `lr'' `= `xT' + (`width' / 2) * `lr'' `"`L'"'
				local b_label `b_label' `yB' `= `xR' - `width' * `lb'' `"`L'"'  
			
				if `l' > 0 & `l' < 1 { 
					local l_label `l_label' `= `yB' + `height' * (1 - `lL')' `= `xT' + (`width' / 2) * `lL'' 
					local r_label `r_label' `yB'  `= `xL' + `width' * (1 - `lR')' 
					local b_label `b_label' `= `yB' + `height' * `lB'' `= `xL' + (`width' / 2) * `lB'' 
				} 	
			} 
	
			local l_label `l_label' . .  
			local r_label `r_label' . .  
			local b_label `b_label' . .  
		}	

		// x, y coordinates to show on scatter 
		gen `yvar' = `yB' + `height' * `left' if `touse' 
		gen `xvar' = `xL' + `width' * (`right' + `left' / 2) if `touse' 

		if "`separate'" != "" { 
			separate `yvar', by(`separate') veryshortlabel 
			local yvar "`r(varlist)'" 
		} 

		local nvars : word count `yvar' 
		if "`separate'" != "" { 
			if "`label'" == "" local start = 3 + ("`y'" != "") 
			else local start = 6 + ("`y'" != "") 
			numlist "`start'(1)`= `start' + `nvars''"
			local legend "legend(pos(1) ring(0) col(1) order(`r(numlist)'))" 
		}	 
		else local legend "legend(off)" 

		if `"`by'"' != "" { 
			gettoken byvar byopts : by, parse(",") 
			gettoken comma byopts : byopts, parse(",") 
			local byby by(`byvar', `legend' note("")  `byopts')  ///
			ysc(lcolor(none)) xsc(lcolor(none)) yla(none) xla(none) 
		}
		
	}	
	// end of quietly


	// graph 
	if "`label'" == "" { 
		twoway scatteri `frame_call', recast(line) lc(black)      ///
		cmiss(n) lp(solid) `frame'                                ///
		|| scatteri `text_call', ms(none) mlabc(black) `text'     /// 
		`y_call'                                                  ///  
		|| scatter `yvar' `xvar'                                  ///
		, ms(Oh) plotregion(style(none))                          ///
                yscale(ra(.,`top')) yscale(off) yla(, nogrid)             ///
		xscale(ra(-0.1,1.1)) xscale(off)                          ///
		`byby' `legend' `options'   
	} 
	else twoway scatteri `l_label', recast(connect) lc(black)         ///
		cmiss(n) lp(dot) ms(none) mlabp(10) mlabc(black) `grid'   ///
	|| scatteri `r_label', recast(connect) lc(black) cmiss(n)         ///
		lp(dot) ms(none) mlabp(2)  mlabc(black) `grid'            ///
	|| scatteri `b_label', recast(connect) lc(black) cmiss(n)         /// 
		lp(dot) ms(none) mlabp(6)  mlabc(black) `grid'            ///
	|| scatteri `frame_call', recast(line) lc(black) cmiss(n)         ///
		lp(solid) `frame'                                         ///
	|| scatteri `text_call', ms(none) mlabc(black) `text'             /// 
	`y_call'                                                          ///  
	|| scatter `yvar' `xvar'                                          ///
	, ms(Oh) plotregion(style(none))                                  ///
        yscale(ra(.,`top')) yscale(off) yla(, nogrid)                     ///
	xscale(ra(-0.1,1.1)) xscale(off) yla(, nogrid)                    ///
	`byby' `legend' `options'   
end

