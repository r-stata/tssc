* ==========================================================
* cibar: creating bargraphs with confidence-intervals
* Author: Alexander Staudt 
* Version 1.1.7, 2019-06-23
* ==========================================================
*! version 1.1.7, Alexander Staudt, 23jun2019

*program drop _all
program define cibar
version 13.0
syntax anything(name=var) [if] [aw fw iw pw], [over(passthru) over1(string) over2(string) over3(string) ///
	VCE(passthru) Level(cilevel) ///
	NOISily ///
	BAROPts(string asis) BARColor(string asis) BARGap(integer 0) Gap(integer 67) ///
	CIopts(string asis) GRaphopts(string asis) ///
	BARLabel(string) BLFmt(string) BLPosition(string) BLOrientation(string) BLSize(string) BLcolor(string) BLGap(real 0)] ///
	
	preserve 
	
	mark touse `if'
	quietly keep if touse == 1
	
	* define grouping variables in one single call of "over()" via over(passthru).
	* for compatibility reasons, also keep old syntax using over1() valid.
	* over(passthru) however takes precedence over over1() etc.
	
	* test which over-option was specified
	capture confirm existence `over'
	scalar _rc_over = _rc
	
	capture confirm existence `over1'
	scalar _rc_over1 = _rc
	
	* use over(passthru) if specified, otherwise over1(). 
	* if both are specified, display message that over(passthru) will be used
	if _rc_over == 6 & _rc_over1 == 6 {
		display as error "option {bf:over()} required"
		exit 198
	}
	else if _rc_over == 6 & _rc_over1 == 0 {
		local bylist = "`over1' `over2' `over3'"
		local overs = wordcount("`bylist'")
		
		local over_list = "over(`bylist')"
	}
	else if _rc_over == 0 & _rc_over1 == 6 {
		local bylist = subinstr("`over'", "over(", "", .)
		local bylist = subinstr("`bylist'", ")", "", .)
		local overs = wordcount("`bylist'")
		
		local over_list = "`over'"
	}
	else {
		display as result "Note: grouping variables specified via {bf:over()}, hence ignoring {bf:over1()} (and {bf:over2()}, {bf:over3()} if specified)."
		
		local bylist = subinstr("`over'", "over(", "", .)
		local bylist = subinstr("`bylist'", ")", "", .)
		local overs = wordcount("`bylist'")
		
		local over_list = "`over'"
	}
	
	* make sure only up to three grouping variables are used for computations,
	* discard any additionally specified grouping variables 
	if `overs' > 3 {
		display as result "Note: cibar only supports up to three grouping variables. Any additional grouping variable will be ignored."
		local bylist = word("`bylist'", 1) + " " + word("`bylist'", 2) + " " + word("`bylist'", 3)
		local overs = wordcount("`bylist'")
		local over_list = "over(`bylist')"
	}
	
	* over1, over2, over3 still required for plotting.
	local over1 = word("`bylist'", 1)
	local over2 = word("`bylist'", 2)
	local over3 = word("`bylist'", 3)
	
	local bg = `bargap'/100
	local gap = (`gap'/100) - 1
	
	capture confirm existence `baropts'
	if _rc == 6 local baropts = "fintensity(inten100)"
	if _rc == 0 local baropts = "fintensity(inten100)" + " " + `"`baropts'"'
	
	capture confirm existence `ciopts'
	if _rc == 6 local ciopts = "lcolor(gs8)"
	if _rc == 0 local ciopts = "lcolor(gs8)" + " " + `"`ciopts'"'
	
	* set defaults for barlabels
	if "`blfmt'" == "" {
		local blfmt = "%9.2f"
	}

	if "`blposition'" == "" {
		local blposition = "n"
	}
	
	if "`blorientation'" == "" {
		local blorientation = "horizontal"
	}
	
	if "`blsize'" == "" {
		local blsize = "medsmall"
	}
	
	if "`blcolor'" == "" {
		local blcolor = "black"
	}
	
	* add options into one local macro
	local opts = `"placement("`blposition'")"' + `"orientation("`blorientation'")"' + " " + `"size("`blsize'")"' + " " + `"color("`blcolor'")"' 
	
	* get mean and confidence intervals
	*di `level'
	// show numeric results
	// add vce-option
	capture confirm existence `noisily'
	if _rc == 6 {
		qui mean `var' [`weight'`exp'], `over_list' level(`level') `vce'
	}
	else {
		mean `var' [`weight'`exp'], `over_list' level(`level') `vce'
	}
	
	* save results in matrices
	matrix define results = r(table)
	matrix define mean = results[1, 1..colsof(results)]'
	matrix define ll = results[5, 1..colsof(results)]'
	matrix define ul = results[6, 1..colsof(results)]'
	
	* get mean and grouping variables
	collapse (mean) mean = `var' [`weight'`exp'], by(`bylist')
	
	* make sure to have non-missing combinations before adding resaults from mean
	foreach x in `bylist' {
		qui drop if `x' == .
	}
	
	* add mean, lower bound, upper bound to dataset
	qui svmat mean
	qui svmat ll
	qui svmat ul
	
	* rename variable
	qui rename ll1 lb
	qui rename ul1 ub
	
	local mean = "mean of `var'"

	if `overs' == 2 {
		capture confirm existence `over2'
		if _rc == 6 {
			local over2 = "`over3'"
			display as txt "You specified over3() but not over2(). The value of over3() is used in over2() instead."
		}
	}
	
	forvalues x = 1/`overs' {
		qui tab `over`x''
		local llevels`x' = `r(r)'
		qui levelsof(`over`x''), local(levels`x')
		*di "`levels`x''"
	}
	
	forvalues x = 1/`overs' {
		* Variablenkodierungen vereinheitlichen
		qui gen over`x'_n = .
		tokenize "`levels`x''"
		forvalues y = 1/`llevels`x'' {
			qui replace over`x'_n = `y' if `over`x'' == ``y''
		}
	}

	forvalues x = 1/`overs' {
		* over`x'_n-Variablen labeln
		tokenize "`levels`x''"
		forvalues y = 1/`llevels`x'' {
			local ltext : label (`over`x'') ``y''
			label define vlabel`x' `y' "`ltext'", add
			if `y' == `llevels`x'' label val over`x'_n vlabel`x'
		}
	}
	
	forvalues x = 1/`overs' {
		qui levelsof(over`x'_n), local(levels`x'_n)
		*di "`levels`x'_n'"
	}

	* ======================================================
	* Bei einer over-Angabe
	* ======================================================
	if `overs' == 1 {
		qui keep if over1_n < .
		
		qui tab over1_n
		qui gen g1 = over1_n
		qui replace g1 = g1 * (1 + `bg')
		
		qui sum g1
		local smin = `r(min)' - .75
		local smax = `r(max)' + .75	
		*di "smin = `smin' smax = `smax'"
		
		local xlabel1 = "xlabel(`smin'" + " " + `"" ""' + " " + "`smax'" + " " + `"" ""' + ", noticks)"
	} 
	* ======================================================
	* Bei zwei over-Angaben
	* ======================================================
	if `overs' == 2 {	
		qui keep if over1_n < . & over2_n < .			
		
		* Hinzufügen fehlender Variablen:
		*di `llevels1'
		*di `llevels2'
		forvalues x1 = 1/`llevels1' {
			forvalues x2 = 1/`llevels2' {
				qui tab mean if over1_n == `x1' & over2_n == `x2'
				if `r(r)' == 0 {
					local obsv = _N+1
					qui set obs `obsv'
					qui replace over1_n = `x1' in `obsv'
					qui replace over2_n = `x2' in `obsv'	
				}
			}
		}
		sort over2_n over1_n		
		
		* over1_bg Positionswerte der Balken anpassen (bzgl. bargap)
		qui gen over1_bg = .
		tokenize "`levels1_n'"
		forvalues x = 1/`llevels1' {
			qui replace over1_bg = over1_n + (``x'' - 1) * (`bg') if over1_n == ``x''
		}
		
		* g1: Werte der Balken (zur Anordnung im Graphen)
		qui gen g1 = .
		tokenize "`levels2_n'"
		forvalues j = 1/`llevels2' {
			qui replace g1 = over1_bg + (`llevels1' + 1 + `gap' + `bg') * (`j' - 1) if over2_n == ``j''
		}

		* Beschriftung der x-Achse			
		* 1. Beschriftungsposition sowie Abstand zwischen den Balkenblöcken bestimmen		
		forvalues x = 1/`llevels2' {
			qui sum g1 if over2_n == `x'
			local pos_`x' = `r(mean)'
			local diff = `llevels2' + 1 + `gap' + `bg'
			if `x' == `llevels2' {
				local smin = 0
				local smax = `r(max)' + 1
			}
		}
		* xlabel-Option mit Beschriftung der Balkengruppen erstellen
		tokenize "`levels2_n'"
		forvalues j = 1/`llevels2' {
			*di "j = `j'"
			*di "token j = ``j''"
			local g11_`j' = `pos_`j''
			
			local l`j' : label (over2_n) `j'
			
			if `j' == 1 local xlabel1 = "xlabel(`smin'" + " " + `"" ""' + " " + "`g11_`j''" + " " + `""`l`j''""'
			else if `j' < `llevels2' local xlabel1 = `"`xlabel1'"' + " " + "`g11_`j''" + " " + `""`l`j''""'
			else local xlabel1 = `"`xlabel1'"' + " " + "`g11_`j''" + " " + `""`l`j''""' + " " + "`smax'" + " " + `"" ""' + " " + ", noticks)"
		}
		*di `"`xlabel1'"'
		*macro dir
	}

	* ======================================================
	* Bei 3 over-Angaben	
	* ======================================================
	if `overs' == 3 {
		qui keep if over1_n < . & over2_n < . & over3_n < .
		
		* sortiere nach Gruppen
		sort over3_n over2_n over1_n
		
		* Hinzufügen fehlender Variablen:
		* Prüfe für jede mögliche Ausprägung (over1*over2*over3), ob diese vorhanden ist
		* Falls Ausprägung nicht vorhanden: erstellen der Beobachtung mit "set obs" und "replace obs" etc.
		* Zusätzlich Schleifen über over1, over2, over3
		* Anschließend neue Gruppe mit unterschiedlichen Ausprägungen erstellen
		
		forvalues x1 = 1/`llevels1' {
			forvalues x2 = 1/`llevels2' {
				forvalues x3 = 1/`llevels3' {
					qui tab mean if over1_n == `x1' & over2_n == `x2' & over3_n == `x3'
					if `r(r)' == 0 {
						local obsv = _N+1
						qui set obs `obsv'
						qui replace over1_n = `x1' in `obsv'
						qui replace over2_n = `x2' in `obsv'
						qui replace over3_n = `x3' in `obsv'
					}
				}
			}
		}
		sort over3_n over2_n over1_n

		* erzeuge neue Gruppe, die die verschiedenen Ausprägungen zweier Gruppen enthält
		qui egen g2 = group(over3_n over2_n)
		qui tab g2
		local llg2 = `r(r)' // Anzahl Balkengruppen
		qui levelsof(g2), local(lg2)

		sort g2 `over1'
				
		* neue Balkennummern
		qui gen c = _n
		qui gen over1_n2 = mod(c,`llevels1')
		qui replace over1_n2 = `llevels1' if over1_n2 == 0

		* over1_bg Positionswerte der Balken anpassen (bzgl. bargap)
		qui gen over1_bg = .
		tokenize "`levels1_n'"
		forvalues x = 1/`llevels1' {
			qui replace over1_bg = over1_n2 + (``x'' - 1) * (`bg') if over1_n2 == ``x''
		}		
				
		* g1: Werte der Balken (zur Anordnung im Graphen)
		qui gen g1 = .
		*di "lg2 = `lg2'"
		tokenize "`lg2'"
		forvalues j = 1/`llg2' {
			qui replace g1 = over1_bg + (`j' - 1) * (`llevels1' + 1 + `gap' + `bg') if g2 == ``j''
				
		}
		
		forvalues x = 1/`llevels2' {
			qui replace g1 = g1 + (-`gap' + 1) * (`x' - 1) if over3_n == `x'
		}
		
		* Beschriftung der x-Achse
		// 1. over2
		* over2: 1. Beschriftungsposition sowie Abstand zwischen den Balkenblöcken bestimmen				
		forvalues x = 1/`llg2' {
			qui sum g1 if g2 == `x'		
			local diff = `llevels1' + 1 + `gap' + `bg'
			local pos_`x' = `r(mean)'
			if `x' == `llg2' {
				local smin = 0
				local smax = `r(max)' + 1
			}	
		}
			
		* Balkengruppen (label)
		* label ermitteln und für g2 erweitern
		tokenize "`levels3_n'"
		forvalues x1 = 1/`llevels3' { // Anzahl Hauptblöcke
			tokenize "`levels2_n'"
			forvalues x2 = 1/`llevels2' { // Anzahl Untergruppen pro Gruppe

				local l`x2' : label (over2_n) ``x2''
				
				local y = `x2' + (`x1' - 1) * `llevels2'
				local llx = "`y'" + " " + `""`l`x2''""'
				
				if `x1' == 1 & `x2' == 1 local vlab = `"`llx'"'
				else local vlab = `"`vlab'"' + " " + `"`llx'"'
			}
		}
		*di `"`vlab'"'
		qui label define g2lab `vlab'
		qui label val g2 g2lab			
	
		* x-Werte ermitteln, für die labels auf der x-Achse erscheinen sollen.
		* labels für over2-Gruppe
		*di "`lg2'"
		tokenize "`lg2'"		
		*di "lg2 = `lg2'"
		forvalues x = 1/`llg2' {
			local g11_`x' = `pos_`x''
			local l`x' : label (g2) ``x''
			*macro dir
			if `x' == 1 local xlabel1 = "xlabel(`smin'" + " " + `"" ""' + " " + "`g11_`x''" + " " + `""`l`x''""'
			else if `x' < `llg2' local xlabel1 = `"`xlabel1'"' + " " + "`g11_`x''" + " " + `""`l`x''""'			
			else local xlabel1 = `"`xlabel1'"' + " " + "`g11_`x''" + " " + `""`l`x''""' + " " + "`smax'" + " " + `"" ""' + " "
		}
		
		// 2. over3
		* labels für over3-Gruppe
		forvalues x1 = 1/`llevels3' {
			qui tab g1 if over3_n == `x1'
			local llg1 = `r(r)'
			forvalues x2 = 1/`llg2' { // erstelle label-Position (x-Achse) für bestimmte over3-Ausprägung
				qui sum g1 if over3_n == `x1'			
			}
			local g12_`x1' = `r(mean)'
			*di `g12_`x1''
			local l2`x1' : label (over3_n) `x1'
			*di `"`l2`x1''"'
			if `x1' == 1 local l_3 = "`g12_`x1''" + " " + `"`"" " " " "`l2`x1''""'"'
			else local l_3 = `"`l_3'"' + " " + "`g12_`x1''" + " " + `"`"" " " " "`l2`x1''""'"'
			*di `"`l_3'"'
			if `x1' == `llevels3' {
				local xlabel1 = `"`xlabel1'"' + " " + `"`l_3'"' + ", noticks)"
				*di `"`xlabel1'"'
			}
			
		}	
	}
	
	* ======================================================
	* Säulen erstellen
	* ======================================================
	tokenize "`levels1_n'"
	*di "`levels1'"
	*di "`llevels1'"
	qui gen rcap = "rcap lb ub g1, `ciopts'"
	forvalues j = 1/`llevels1' {
		qui gen bar`j' = "bar mean g1 if over1_n==`j', `baropts'" 
	}
	* add bar colors
	qui des bar*, varlist
	local nbars = wordcount("`r(varlist)'")
	local ncolors = wordcount("`barcolor'")
	
	* check if number of defined colors is larger than number of defined bars (per group)
	if `ncolors' > `nbars' {
		local ncolors = `nbars'
	}
	* add colors to bars
	if `ncolors' > 0 {
		qui gen bcolors = "`barcolor'"
		qui split bcolors, gen(bcol)
	
		forvalues j = 1/`ncolors' {
			qui replace bar`j' = bar`j' + "color(" + bcol`j' + ")"
		}
	}
	
	* concatenate string
	qui egen bars1 = concat(bar* rcap), punct(") (")
	qui replace bars1 = "(" + bars1 + ")"
	local bars1 = bars1[1]
	
	* ======================================================
	* Bar labels hinzufügen
	* ======================================================
	* prepare bar labels
	qui gen bl_mean = mean
	qui replace bl_mean = 0 if mean == .
	
	* define bar labels
	qui gen mlab = ""
	local n = _N
	forvalues x = 1/`n' {
		if bl_mean[`x'] == 0 {
			local mean_mlab = "0"
			local s_mean_mlab = ""
		}
		else {
			local mean_mlab = strofreal(bl_mean[`x'] + `blgap')
			local s_mean_mlab = strofreal(bl_mean[`x'], `"`blfmt'"')
		}
		qui replace mlab in `x' = "text(" + `"`mean_mlab'"' + " " + strofreal(g1) + " " + `"""' + `"`s_mean_mlab'"' + `"""' + ", " + `"`opts'"' + ") "
	}
	
	* add bar labels if barlabel(on) is specified by the user
	if "`barlabel'" == "on" {
		local n = _N
		local bltext = mlab[1]
		forvalues x = 2/`n' {
			local bltext = `"`bltext'"' + mlab[`x'] 
		}
	}
	
	* ======================================================
	* Legendeneinträge
	* ======================================================
	*local vlabel1 : value label `over1'	
	tokenize "`levels1_n'"
	forvalues j = 1/`llevels1' {
		
		local l`j' : label (over1_n) `j'
		
		if `j' == 1 {
			local legend1 = `"`j' "`l`j''""'
		}
		else {
			local legend1 = `"`legend1'"' + " " + `"`j' "`l`j''""'
		}
	}
	*di `"legend1 = `legend1'"'
	local legende = `"legend(order(`legend1'))"'
		
	capture confirm existence `graphopts'
	if _rc == 6 local graphopts = `"`legende' xtitle("") ytitle("`mean'") plotregion(margin(bargraph)) ylabel(, format(%9.3g))"'
	if _rc == 0 local graphopts = `"`legende' xtitle("") ytitle("`mean'") plotregion(margin(bargraph)) ylabel(, format(%9.3g))"' + " " + `"`graphopts'"'	

	* ======================================================
	* draw graph
	* ======================================================
	*twoway (bar mean group) (rcap ub lb group), `xlabel1' `graphopts'
	*di `"`bars1'"'
	twoway `bars1', `xlabel1' `graphopts' `bltext'
	end
