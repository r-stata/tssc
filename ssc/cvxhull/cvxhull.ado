* 1.1		RAR 21 January 2004, with improved coding
* 1.0.1	RAR 12 December 2003, with suggestions from NJC
* 1.0		RAR 22 November 2003 - England won RU World Cup
program cvxhull, sortpreserve
	version 8.0
	syntax varlist(min=2 max=2) [if] [in] ///
	[ , Hulls(numlist int min=0 max=2 >0) MDPlot(int 8) ///
	 GROup(varname) SELect(numlist int min=0 >0 sort) ///
	 MEAns PREfix(string) noREPort noRETain ///
	 SCATopt(string) noGRAph SAVing(string)]

	loc reporting = ("`report'" != "noreport")
	if "`retain'" == "noretain" & "`graph'" == "nograph" {
		di as err "That combination of options is silly: quitting now"
		exit 498
	}

* Nick Cox thinks this parsing is still flakey 
	if `"`saving'"' != "" { //  Check saving filename   
		tokenize `"`saving'"', parse(",")
		args saving comma replace
		if index(`"`saving'"', ".") == 0 loc saving `"`saving'.gph"'
		capture confirm file `saving'
		if _rc == 0 { /* existing file */
			if "`replace'" != "replace" {
				di as err "Invalid save file - did you mean to replace?"
				exit 198
			}
			loc saving `"`saving',replace"'
		}
		else confirm new file `saving' // invalid file - unless new
		loc saving `"saving("`saving'")"'
	}

	if "`hulls'" == "" {
		loc hulls = 1 
		loc hullgap = 1 // Set default values
	}
	else {
		tokenize "`hulls'"
		loc hulls = `1'
		if   "`2'" == ""  loc hullgap = 1
		else              loc hullgap = `2'
	}

	marksample touse // Deal with `if', `in' & missing
	qui count if `touse'
	if r(N) == 0 error 2000

	tempvar sample grp scratch count pts hullno
	qui gen `sample'=`touse' // & remember all points considered
	if "`group'" == "" {     // group variable may be absent, string or numeric
		qui gen `grp' = 1
		loc select "1"
		loc maxgrp = 1
	}
	else {
		qui egen `grp' = group(`group') if `touse', label        
		if "`select'" != "" {
			loc j = 0
			foreach i in `select' {
				loc ++j
			}
			loc maxgrp = `j'  // no of items
		}
		else {
			su `grp', meanonly
			loc maxgrp = r(max)
			loc select "1 / `maxgrp'"
		}
		qui {
			egen `scratch' = eqany(`grp'), values(`select')
			replace `touse' = `touse' * `scratch'
		}
		if `reporting' di as txt "Codes for groups based on " as res "`group'"
		label list `grp'
	}

* Double check, in case group selection has dropped all obs
	qui count if `touse'
	if r(N) == 0 error 2000

	loc retd = 1 + int((`hulls'-1)/`hullgap')  // number of hulls
	loc hull = plural(`retd', "hull")
	loc gs = plural(`maxgrp', "group")
	if `reporting'  di as txt "Up to `retd' `hull' to be saved for `maxgrp' `gs'"

	if "`prefix'" == "" loc prefix "_cvxh"
	capture drop `prefix'*l
	capture drop `prefix'*r
	capture drop `prefix'grp
	capture drop `prefix'hull
	capture drop `prefix'pts
	capture drop `prefix'cnt
	capture drop `prefix'*mindex
	capture drop `prefix'*maxdex
	capture drop `scratch'

	tokenize `varlist'
	args y x 
	sort `grp' `x' `y' // within group, by ascending x then y

	qui {
		gen `count' = 0
		gen `pts' = 0
		gen `hullno' = 0
	}
	tempname gap
	loc gap = `hullgap' -1      // force retain hull 1
	loc maxhull = 0

***** Main loop ******************************************
	tempvar leftpath rightpath onhull  // re-use scratch for points on segment
	qui {
		gen `leftpath' = .    // set up outside loop to use replace
		gen `rightpath' = .   // within loop & save RAM allocation time
		gen `onhull' = 0
		gen `scratch' = 0
	}
	forvalues h = 1 / `hulls' { // b1 : brackets numbered for sanity! 
		qui count if `touse'    // stop when all points peeled
		if r(N) > 0  { // b2
		 	qui {
				replace `leftpath' = .
				replace `rightpath' = .
				replace `onhull' = 0
			}
			loc sp = 1          // Starting point
			loc notstarted = 1
			
			while `sp' <= _N  { // b3 scan all observations
				loc curgrp = `grp'[`sp']
				if !`touse'[`sp']  {
					loc ++sp    // ignore point & increment pointer
				}
				else {          // b4 - point processing ...
					while `grp'[`sp'] == `curgrp'  { // b5 within group
						if `notstarted' { // b6 mark first point of current group
							qui {
								replace `leftpath' = `y' in `sp'
								replace `rightpath' = `y' in `sp'
								replace `onhull' = (_n==`sp')
								replace `scratch' = 0
							} 
							loc leftcur = `sp'
							loc rightcur = `sp'
							loc sp1 = `sp'
							loc curgrp = `grp'[`sp']
							loc mindex = 1   
							loc notstarted = 0
							loc ++sp
						} 
						else  { // 6
							loc j = `leftcur' + 1
							loc maxL = -1
							loc maxD = 0
							loc found = 0 
							while `j'<=_N & `grp'[`j']==`curgrp' { // b7 find next left */
								if `touse'[`j']==1 {                 // b8
									loc d = sqrt( (`y'[`j'] - `y'[`leftcur'])^2 + (`x'[`j'] - `x'[`leftcur'])^2 )
									if float(`d') > 0 {  // b9
										loc cosa = (`y'[`j'] - `y'[`leftcur'])/ `d'
										if float(`cosa') > float(`maxL') { // b10 new leftmost direction
											loc maxL = `cosa'
											loc next = `j'
											qui replace `scratch' = (_n==`j')
											qui replace  `scratch' = 1 in `sp1'
											loc found = 1
										} 
										else {
											if float(`cosa') == float(`maxL') { // collinear
												if float(`d') > float(`maxD')  loc next = `j'
												qui replace `scratch' = 1 in `j'
												loc found = 1 
											}
										}
									} // 9
									else { // 9
										qui replace `onhull' = 1 in `j' // coincident with current point
										loc next = `j'
									} //9
								} // 8
								loc ++j
							} // 7
							qui replace `onhull' = (`onhull' | `scratch') 
							if `found' {
								qui {
									replace `leftpath' = `y' in `next'
									loc ++mindex
									loc leftcur = `next'
								} 
							} 
							
							loc j = `rightcur' + 1
							loc maxR = 1
							loc maxD = 0
							loc found = 0 
							while `j'<=_N & `grp'[`j']==`curgrp' { // b7 find next right
								if `touse'[`j']==1  { //8
									loc d = sqrt( (`y'[`j'] - `y'[`rightcur'])^2 + (`x'[`j'] - `x'[`rightcur'])^2 )
									if float(`d') > 0 { //9
										loc cosa = (`y'[`j'] - `y'[`rightcur']) / `d'
										if float(`cosa') < float(`maxR') { //10
											loc maxR = `cosa'
											loc next = `j'
											qui replace `scratch' = (_n==`j')
											qui replace  `scratch' = 1 in `sp1'
											loc found = 1 
										} 
										else {
											if float(`cosa') == float(`maxR')  { // collinear
												if float(`d') > float(`maxD')  loc next = `j'
												qui replace `scratch' = 1 in `j'
												loc found = 1
											} 
										}
									} //9
									else { //9
										qui replace `onhull' = 1 in `j'  // coincident
										loc next = `j'
									} //9
								} //8
								loc ++j
							} // 7
							qui replace `onhull' = (`onhull' | `scratch') 
							if `found' {
								qui {
									replace `rightpath' = `y' in `next' 
									loc ++mindex
									loc rightcur = `next'
								} 
							} 	
						
* Check if found a hull, or continue						
							loc sp = `leftcur'
							if `rightcur' < `leftcur' loc sp = `rightcur' 
							if `leftcur' == `rightcur'   { // hull closed
								qui {
									replace `hullno' = -`h' in `sp'
									replace `hullno' = `h' in `sp1'
									replace `count' = `mindex' - 1 in `sp1'  // last point double counted
									qui count if `onhull'
									replace `count' = r(N) in `sp'
									replace `pts' = `h' if `onhull'
									replace `touse' = 0 if `onhull'
								} 
								loc notstarted = 1
								while `grp'[`sp'] == `curgrp' {
									loc ++sp
								}
							} 
						} // e6
					} // e5 found end of group

					if `mindex' == 1  { // special case - single point hull
						qui {
							qui count if `onhull'
							replace `count' = r(N) in `sp1'
							replace `hullno' = `h' in `sp1'
                    		loc notstarted = 1
						} 
					} 
				} // e4 end point processing 
			} // e3 end loop over data
				
* Save hull if requested
			loc ++gap
			if `gap' == `hullgap' {
				loc ++maxhull
				qui {
				gen `prefix'`h'l = `leftpath'
				gen `prefix'`h'r = `rightpath'
				} 
				if `maxhull' <= `mdplot' loc hulllist "`prefix'1l-`prefix'`h'r"
				loc gap = 0                // restart count
				if `reporting' di as txt "  hull level `h' calculated and saved"
			} 
		} // e2 do nothing if no data points
	} // e1 exit loop when all hulls marked

***** Optional plot 
	if `"`graph'"' != "nograph" {
		if `reporting' di as txt "Graph will be plotted presently"
* Build and execute graph command ... as a very long macro text!
		loc colours "black black blue blue dkorange dkorange magenta magenta emerald emerald khaki khaki cyan cyan red red"
* Set up point plot and add line plots for each selected group
* RAR's preference for default horizontal y labels
		loc gr `"scatter `y' `x' if `sample',yti("`y'")yla(,angle(0))`saving' `scatopt'"'
		if "`means'" == "means" {
			tempvar ymean xmean
			egen `ymean' = mean(`y') if `select', by(`grp')
			egen `xmean' = mean(`x') if `select', by(`grp')
			loc gr `"`gr'||scatter `ymean' `xmean',ms(T)xti("`x'")"'
		} 
		foreach i of numlist `select' {
			loc gr `"`gr'||line `hulllist' `x' if `grp'==`i',clc(`colours')legend(off)"'
		} 
		`gr' // & execute macro command 
	} 
	
	if "`retain'" != "noretain" {
		qui {
			if "`group'" != "" gen `prefix'grp  = `grp'
			gen `prefix'hull = `hullno'
			gen `prefix'cnt  = `count'
			gen `prefix'pts = `pts'
		} 
	} 
	else {
		capture drop `prefix'*l `prefix'*r 
	}

	if `reporting' di as txt "cvxhull run"

end // of cvxhull

