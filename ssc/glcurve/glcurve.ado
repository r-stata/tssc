*! 3.3.0 Philippe Van Kerm - Stephen P. Jenkins 24 June 2008
*  - fix behaviour of option -replace- when only one of -pvar()- or -glvar- was specified.
* 3.2.0 Philippe Van Kerm - Stephen P. Jenkins 07 February 2007
*  - Concentration curves with ties in ranking variable do not depend on initial sort order anymore: 'maximal concentration' now imposed
* 3.1.0 Philippe Van Kerm - Stephen P. Jenkins 24 August 2006
*  - fix for TIP curves with varying (observation-specific) poverty lines (cumulation was not incorrect)
*  - minor fix for -replace- options with non existing pvar and glvar
*  - revision of labels (more meaningful labels, identification of TIP curves, etc.)
* 3.0.2 Philippe Van Kerm - Stephen P. Jenkins 15 May 2006
*  -one fix: sort stability issue with ties in weights and sort variable
*  -minor change to help file (label specification)
* 3.0.0 Philippe Van Kerm - Stephen P. Jenkins 26 October 2004 (SJ 4-4: gr0001_1)
* touched by NJC 24 October 2004
* 2.0 Philippe Van Kerm - Stephen P. Jenkins, 19 Feb 2001 (TSJ-1: gr0001)
* 1.2 Stephen P. Jenkins - Philippe Van Kerm, Apr 1999 STB-49 sg107.1
* Syntax: glcurve y [fw aw] [if in], [GLvar(x1) Pvar(x2) SOrtvar(svar)
*            Lorenz RTIP(string) ATIP(string)
*            BY(gvar) SPlit GRaph REPLACE plot(plot) graph_options]

program glcurve, sort
	version 8.0
	syntax varname [if] [in] [fweight aweight] ///
		[, GLvar(string) Pvar(string) SOrtvar(varname) ///
		Lorenz RTIP(string) ATIP(string) ///
		BY(varname numeric) SPlit NOGRaph REPLACE PLOT(string asis) * ]

	tempvar inc cumwy cumw maxw badinc wi gl p
	tempname byname

	local graph = cond("`nograph'" != "", "", "graph")

	if "`by'" != "" {
		if "`graph'" != "" & "`split'" == "" {
			di as err "{p}split must be used to combine by()" ///
			" with a graph; nograph option assumed{p_end}"
			local graph
		}
	}
	else {
		if "`split'" != "" {
			di as err "{p}split must be combined with by(); " ///
			" split ignored{p_end}"
			local split
		}
	}

	/* this code modified in v3.0.3 to avoid problems with non-existing variables */
	if ("`replace'" != "") {
		if ("`pvar'" != "") {
			cap confirm new variable `pvar'
			if (_rc!=0) {
				drop `pvar'
			}
		}
		if ("`glvar'" != "") {
			if (("`split'" != "") & ("`by'" != "")) {
				local prefix "`glvar'"
				cap drop `prefix'_*
			}
			else {
				cap confirm new variable `glvar'
				if (_rc!=0) {
					drop `glvar'
				}
			}
		}
	}

	if "`weight'" == "" qui gen byte `wi' = 1
	else qui gen `wi' `exp'

	marksample touse
	markout `touse' `sortvar' `by'

	if "`split'" == "" {
		if "`glvar'" != "" {
			confirm new variable `glvar'
			di as txt "new variable `glvar' created"
		}
		else tempvar glvar
	}
	else qui {
		if "`glvar'" == "" {
			tab `by' `by' if  `touse', matrow(`byname')
			local nv = rowsof(`byname')
			forval i = 1/`nv' {
				tempvar newvar`i'
			}
		}
		else {
			tab `by' `by' if  `touse', matrow(`byname')
			local prefix "`glvar'"
			local nv = rowsof(`byname')
			forval i = 1/`nv' {
				local suffix = `byname'[`i',1]
				local newvar`i' "`prefix'_`suffix'"
				confirm new variable `newvar`i''
   				noi di as txt "new variable `newvar`i'' created"
			}
		}
	}

	if "`pvar'" != "" {
		confirm new variable `pvar'
		di as txt "new variable `pvar' created"
	}
	else tempvar pvar

	qui gen `inc' = `varlist' if `touse'

	qui if "`atip'" != "" {
		if "`rtip'" != "" {
			di as err "cannot use options atip() and rtip() together"
			exit 198
		}
		if "`lorenz'" != ""{
			di as err "cannot use option atip() with lorenz"
			exit 198
		}
		replace `inc' = max(0,`atip' - `varlist') if `touse'
		/* if "`sortvar'" == "" local sortvar "`varlist'" : incorrect if obs.-specific atip */
		tempvar incratio
		gen double `incratio' = (`varlist'/`atip')
		if "`sortvar'" == "" local sortvar "`incratio'"
	}

	qui if "`rtip'" != "" {
		if "`lorenz'" != ""{
			di as err "cannot use option rtip() with lorenz"
			exit 198
		}
		replace `inc' = max(0,(`rtip' - `varlist')/`rtip') if `touse'
		/* if "`sortvar'" == "" local sortvar "`varlist'" : incorrect if obs.-specific rtip */
		tempvar incratio
		gen double `incratio' = (`varlist'/`rtip')
		if "`sortvar'" == "" local sortvar "`incratio'"
	}

	quietly {
		count if `inc' < 0 & `touse'
		if r(N) > 0 {
			noi di as txt _n "warning: `inc' has `r(N)' values < 0;" ///
			"used in calculations"
		}

		if "`by'" == "" {
			tempvar placebo
			gen byte `placebo' = 1
			local by "`placebo'"
		}

		if "`sortvar'" == "" local sortvar `inc'
		sort `by' `sortvar' `inc' , stable /* `inc' included in v3.2.0 to stabilize concentration curves */
		by `by' : gen double `cumwy' = sum(`wi' * `inc') if `touse'
		by `by' : gen double `cumw' = sum(`wi') if `touse'
*		by `by': gen double `cumw' = sum(`wi') if `touse'
		egen `maxw' = max(`cumw'), by(`by')
		gen double `pvar' = `cumw'/`maxw' if `touse'
		label variable `pvar' "Cumulative population proportion"

		/* get the appropriate curve label */
		if "`lorenz'" != "" loc curvelabel "Lorenz"
		else if "`atip'" != ""  loc curvelabel "Absolute TIP"
		else if "`rtip'" != ""  loc curvelabel "Relative TIP"
		else loc curvelabel "Gen. Lorenz"

		if "`split'" == "" {
			gen `glvar' = `cumwy'/`maxw' if `touse'
			label var `glvar' "`curvelabel' (`varlist')"
			if "`lorenz'" != ""{
				su `inc' [`weight' `exp'] if `touse', meanonly
				replace `glvar' = `glvar' / r(mean)
			}
			if "`graph'" != "" {
				twoway scatter `glvar' `pvar' if `touse', ///
				ms(i i) c(l l) `options'  || `plot'
			}
		}
		else {
			local lname : value label `by'
			forval i = 1/`nv' {
				local bylevel = `byname'[`i',1]
				bysort `by' (`sortvar'): ge `newvar`i'' = `cumwy'/`maxw' ///
					if `touse' & `by' ==  `byname'[`i',1]
				if ("`lname'" != "") {
				 label var `newvar`i'' "`curvelabel' (`varlist') [`by'==`: label `lname' `= `byname'[`i',1]'']"
				}
				else label var `newvar`i'' "`curvelabel' (`varlist') [`by'==`= `byname'[`i',1]']"
				if "`lorenz'" != "" {
					su `inc' [`weight' `exp'] if `touse' & `by' == `byname'[`i',1], meanonly
					replace `newvar`i'' = `newvar`i'' / r(mean)
				}
				local listvar "`listvar' `newvar`i''"
				/*local legtext `"`legtext' `i' "`varlist'[`= `byname'[`i',1]']" "' */
				if ("`lname'" != "") {
				  local legtext `"`legtext' `i' "`: label `lname' `= `byname'[`i',1]''" "'
				  }
				else local legtext `"`legtext' `i' "`by'==`= `byname'[`i',1]'" "'
			}
			if "`graph'" != "" {
				if `nv' > 1 {
					local yti `"yti("`curvelabel' `varlist' (by `by')")"'
				}
				twoway scatter `listvar' `pvar' if `touse', ///
				ms(i ..) c(l ..) `yti' legend(order(`legtext')) `options'  || `plot'
			}
		}
	}
end
