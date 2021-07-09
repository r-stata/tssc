*! spechist v1.2.1
*! 29 September 2015
*! Alfonso Sanchez-Penalver

capture program drop spechist
program define spechist, rclass
	version 8.0, missing
	
	syntax varname(numeric) [if] [in] [fweight] , MEthod(string) [			///
		METDisplay(string) bin(passthru) Width(passthru) Discrete nodraw	///
		COPTions(string asis) name(passthru) saving(passthru) *]
	
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 error 2000
	
	* Even though they shouldn't, just making sure that they can pass the
	* methods separated by commas, semicolons, or colons.
	local method = subinstr("`method'", ",", "",.)
	local method = subinstr("`method'", ";", "",.)
	local method = subinstr("`method'", ":", "",.)
	
	* Setup a local with the number of methods passed, another with a list of
	* valid methods, and the last one with the list of methods that would have
	* to be used with the all option.
	local nm : word count `method'
	local valid "sqrt sturges rice doane scott freedman wand stata all"
	local all = subinstr("`valid'","all","",.)
	
	* Checking that each method passed is valid and that all is passed alone
	foreach m in `method' {
		if !strpos("`valid'","`m'")	{
			di as error "method {bf:`m'} not allowed."
			exit 198
		}
		
		if "`m'" == "all" & `nm' > 1 {
			di as error "methods {bf:`method'} may not be combined."
			exit 198
		}
	}
	
	* If all is passed, set method to the list of all methods, and word count
	* again for further checking
	if "`method'" == "all" {
		local method "`all'"
		local nm : word count `method'
	}
	
	* Setup a list of valid methods display, to check if the string passed is
	* is a valid method. Re-using the valid local from before because it's no
	* longer used.
	local valid ""title", "subtitle", "note", "caption", "none""
	
	* Checking the validity of method display
	if "`metdisplay'" != "" & !inlist("`metdisplay'",`valid')	{
		di as error "{bf:`metdisplay'} is not a valid display method."
		exit 198
	}
	
	* Set the display method to title if no method is passed
	if "`metdisplay'" == ""													///
		local metdisplay "subtitle"
	
	* Graph combination options are only valid if we have more than one method
	if "`coptions'" != "" & `nm' == 1 {
		di as error "option {bf:coptions()} is only valid if you specify"
		di as error "more than one method or {it:all} in the {bf:methods()}"
		di as error "option."
		exit 198
	}
	
	* nodraw should be passed when only one method is specified.
	if "`draw'" != "" & `nm' > 1 {
		di as error "Option {bf:nodraw} cannot be used when you specify"
		di as error "more than one method in the {bf:methods()} option."
		di as error "If you want to avoid drawing the combined histogram"
		di as error "you should specify that in the {bf:coptions()} option."
		exit 198
	}
	
	* name() should be passed when only one method is specified.
	if "`name'" != "" & `nm' > 1 {
		di as error "option {bf:name()} cannot be used when you specify"
		di as error "more than one method in the {bf:methods()} option."
		di as error "If you want to specify a name for the combined histogram"
		di as error "you should do so in the {bf:coptions()} option."
		exit 198
	}
	
	* saving() should be passed when only one method is specified.
	if "`saving'" != "" & `nm' > 1 {
		di as error "option {bf:saving()} cannot be used when you specify"
		di as error "more than one method in the {bf:methods()} option."
		di as error "If you want to save the combined histogram, you should"
		di as error "use this option in the {bf:coptions()} option."
		exit 198
	}
	
	* bin is not allowed
	if "`bin'" != "" {
		di as error "option {bf:bin()} not allowed."
		exit 198
	}
	
	* width is not allowed
	if "`width'" != "" {
		di as error "option {bf:width()} not allowed."
		exit 198
	}
	
	* discrete is not allowed
	if "`discrete'" != "" {
		di as error "option {bf:discrete} not allowed."
		exit 198
	}
	
	* Get values to determine width and bin in the different methods
	quietly summarize `varlist' if `touse' [`weight' `exp'], detail
	local n = r(N)
	local iqr = r(p75) - r(p25)
	local s = r(sd)
	local sk = r(skewness)
	
	* Setting up options that depend on whether it is one histogram or more
	if `nm' > 1 															///
		local options `options' save nodraw
	else 																	///
		local options `options' `name' `draw' `saving'
	
	* Generate the histogram(s). We use a local to capture the names of all the
	* histograms generated. It will only be used if more than one are actually
	* generated, but it is filled in any case.
	local cmb
	foreach m in `method' {
		if "`m'" == "sqrt" {
			sqrthist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				me(`metdisplay') `options'
			
			local cmb `cmb' sq
		}
		else if "`m'" == "sturges" {
			sturhist `varlist' if `touse' [`weight' `exp'], obs(`n')		///
				me(`metdisplay') `options'
			
			local cmb `cmb' stu
		}
		else if "`m'" == "rice" {
			ricehist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				me(`metdisplay') `options'
			
			local cmb `cmb' ri
		}
		else if "`m'" == "doane" {
			doanehist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				sk(`sk') me(`metdisplay') `options'
			
			local cmb `cmb' do
		}
		else if "`m'" == "scott" {
			scotthist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				sd(`s') me(`metdisplay') `options'
			
			local cmb `cmb' sc
		}
		else if "`m'" == "freedman" {
			freedhist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				iqr(`iqr') me(`metdisplay') `options'
			
			local cmb `cmb' fr
		}
		else if "`m'" == "wand" {
			wandhist `varlist' if `touse' [`weight' `exp'], obs(`n') 		///
				sd(`s') iqr(`iqr') me(`metdisplay') `options'
			
			local cmb `cmb' wa
		}
		else {
			sthist `varlist' if `touse' [`weight' `exp'], me(`metdisplay')	///
				`options'
			
			local cmb `cmb' sta
		}
		
		local obs = r(N)
		local st = r(start)
		return scalar `m'_min = r(min)
		return scalar `m'_max = r(max)
		return scalar `m'_bin = r(bin)
		return scalar `m'_width = r(width)
		return scalar `m'_area = r(area)
		matrix u = r(bins)
		return matrix `m'_bins = u
	}
	
	* If more than one histogram was generated, combine them into one graph
	if `nm' > 1 															///
		graph combine `cmb', `coptions'
	
	* Return common elements
	return scalar N = `obs'
	return scalar start = `st'
end



********************************************************************************
*							General Subroutines								   *
********************************************************************************

** Program to generate method display
capture program drop genmetdisp
program define genmetdisp, rclass
	version 8.0
	args method display text
	
	* Have to check if there is any actual text or are all suboptions
	if "`text'" != "" {
		if strpos("`text'",",") == 1 										///
			local method "`method'`text'"
		else																///
			local method "`method': `text'"
	}
	return local disp "`display'("`method'")"
end

** Program to generate the matrix that holds the bins
capture program drop binmatrix
program define binmatrix, rclass
	version 8.0
	args min width bin
	
	* The idea is to generate a vector with enough cells to put the bin limits
	* and then loop to add to the lower bounds the width and generate the other
	* bounds.
	
	scalar bound = `min'
	local rows = `bin' + 1
	matrix bins = J(`rows',1,.)
	matrix bins[1,1] = `min'
	forval i = 2/`rows' {
		scalar bound = bound + `width'
		matrix bins[`i',1] = bound
	}
	return matrix bins = bins
end

********************************************************************************
*					    Specific Histograms Subroutines						   *
********************************************************************************

** DOANE
capture program drop doanehist
program define doanehist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) sk(real)		///
		me(string) [SAve TItle(string) SUBtitle(string) note(string)		///
		CAPtion(string) START(numlist max=1) *]
		
	marksample touse
	if "`save'" != ""														///
		local options `options' name(do, replace)
	
	local sg1 = sqrt(6 * (`obs' - 2) / ((`obs' + 1) * (`obs' + 3)))
	local w = ceil(1 + ln(`obs')/ln(2) + ln(1 + abs(`sk')/`sg1')/ln(2))
	local n = "Doane (1976)"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], bin(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	* Generate the histogram
	histogram `varlist' if `touse' [`weight' `exp'], bin(`w') 				///
		`n' `ot' `options'
	di as text "{hline}"
end

** FREEDMAN
capture program drop freedhist
program define freedhist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) iqr(real)	///
		me(string) [SAve TItle(string) SUBtitle(string) note(string)		///
		CAPtion(string) START(numlist max=1) *]
		
	marksample touse
	if "`save'" != ""														///
		local options `options' name(fr, replace)
	
	local w = 2 * `iqr' * `obs'^(-1/3)
	local n = "Freedman and Diaconis (1981)"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], width(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], width(`w') 			///
		`n' `ot' `options'
	di as text "{hline}"
end

** RICE
capture program drop ricehist
program define ricehist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) me(string)	///
		[SAve TItle(string) SUBtitle(string) note(string) CAPtion(string)	///
		START(numlist max=1) *]
		
	marksample touse
	if "`save'" != ""														///
		local options `options' name(ri, replace)
	
	local w = ceil(2 * `obs'^(1/3))
	local n = "Rice University"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], bin(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], bin(`w')				///
		`n' `ot' `options'
	di as text "{hline}"
end

** SCOTT
capture program drop scotthist
program define scotthist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) sd(real)		///
		me(string) [SAve TItle(string) SUBtitle(string) note(string)		///
		CAPtion(string) START(numlist max=1) *]
	
	marksample touse
	if "`save'" != ""														///
		local options `options' name(sc, replace)
	
	local w = 3.5 * `sd' * `obs'^(-1/3)
	local n = "Scott (1979)"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], width(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], width(`w')				///
		`n' `ot' `options'
	di as text "{hline}"
end

** SQRT
capture program drop sqrthist
program define sqrthist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) me(string)	///
		[SAve TItle(string) SUBtitle(string) note(string) CAPtion(string)	///
		START(numlist max=1) *]
	
	marksample touse
	if "`save'" != ""														///
		local options `options' name(sq, replace)
	
	local w = min(50, ceil(`obs'^(1/2)))
	local n = "Square Root"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], bin(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], bin(`w')				///
		`n' `ot' `options'
	di as text "{hline}"
end

** STATA
capture program drop sthist
program define sthist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , me(string) [SAve			///
		TItle(string) SUBtitle(string) note(string) CAPtion(string)			///
		START(numlist max=1) *]
	
	marksample touse
	if "`save'" != ""														///
		local options `options' name(sta, replace)
	
	local n = "Stata"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], return		///
		`twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], `n' `ot' `options'
	di as text "{hline}"
end

** STURGES
capture program drop sturhist
program define sturhist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) me(string)	///
		[SAve TItle(string) SUBtitle(string) note(string) CAPtion(string)	///
		START(numlist max=1) *]
	
	marksample touse
	if "`save'" != ""														///
		local options `options' name(stu, replace)
	
	local w = ceil(ln(`obs')/ln(2) + 1)
	local n = "Sturges (1926)"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], bin(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], bin(`w')				///
		`n' `ot' `options'
	di as text "{hline}"
end

** WAND
capture program drop wandhist
program define wandhist, rclass
	version 8.0
	syntax varname(numeric) [if] [in] [fweight] , obs(integer) sd(real)		///
		iqr(real) me(string) [SAve TItle(string) SUBtitle(string)			///
		note(string) CAPtion(string) START(numlist max=1) *]
	
	marksample touse
	if "`save'" != "" ///
		local options `options' name(wa, replace)
	
	local w = (24 * _pi^(1/2) / `obs')^(1/3) * min(`sd', `iqr' / 1.349)
	local n = "Wand (1997)"
	di as text "`n':"
	
	* Generating the string that will have all textboxes that are not
	* carrying the method
	local ot = ""
	if "`title'" != "" & "`me'" != "title"									///
		local ot "title("`title'") "
	if "`subtitle'" != "" & "`me'" != "subtitle"							///
		local ot "`ot'subtitle("`subtitle'") "
	if "`note'" != "" & "`me'" != "note"									///
		local ot "`ot'note("`note'") "
	if "`caption'" != "" & "`me'" != "caption"								///
		local ot "`ot'caption("`caption'")"
	
	* Generate the string that has the textbox that carries the method (if any)
	if "`me'" != "none" {
		local t ""
		if "`me'" == "title"												///
			local t "`title'"
		else if "`me'" == "subtitle"										///
			local t "`subtitle'"
		else if "`me'" == "note"											///
			local t "`note'"
		else if "`me'" == "caption"											///
			local t "`caption'"
		genmetdisp "`n'" "`me'" "`t'"
		local n = r(disp)
	}
	else																	///
		local n ""
	
	
	local twoopts ""
	if "`start'" != "" {
		local twoopts `twoopts' start(`start')
		local options `options' start(`start')
	}
	
	* Call twoway__histogram_gen to get info
	twoway__histogram_gen `varlist' if `touse' [`weight' `exp'], width(`w')	///
		return `twoopts' `density' `fraction' `frequency'

	* Return the necessary information
	return scalar N = r(N)
	return scalar bin = r(bin)
	return scalar width = r(width)
	return scalar start = r(start)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar area = r(area)
	
	* Call the program to get the actual bins
	binmatrix r(min) r(width) r(bin)
	* Return the matrix with the bins
	matrix u = r(bins)
	return matrix bins = u
	
	histogram `varlist' if `touse' [`weight' `exp'], width(`w')				///
		`n' `ot' `options'
	di as text "{hline}"
end

** Version 1.2.1 fixes a bug with start() option
** Version 1.2.0 added functionality of returning bin width and values
