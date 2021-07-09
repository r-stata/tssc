*! Attaullah Shah : attaullah.shah@imsciences.edu.pk: www.FinTechProfessor.com
*! Version 1: May 16, 2020
version 11
prog fillmissing, byable(onecall)
	syntax varlist [if] [in], [with(str) by(varlist)]
	marksample touse, nov

	qui des
	loc N = `r(N)'
	if `N' == 0 {
		di as error "No observation in the dataset"
		exit
	}

	if "`with'" == "" loc with any
	if !inlist("`with'", "previous", "next", "first", "last", "any") & ///
		!inlist("`with'", "mean", "min", "max", "median", "rand", "pattern", "linear") {
		dis as error "Option with() incorrectly specified"
		dis as error "with accepts only these : previous, next, first, last, any"
		dis as error "mean, min, max, median, rand, pattern"
		exit
	}

	if "`by'" != "" & "`_byvars'" != "" {
		dis as error "Options bysort and by() cannot be combined"
		dis as error "Use either bysort or by(varlist)"
		exit
	}

	tempvar initialsort
	qui gen `initialsort' = _n

	local by "`_byvars'`by'"
	tempvar  i byvar

	qui sort `by' `touse'
	qui by `by' `touse' : gen  `i' = _n == 1 
	qui gen `byvar' = sum(`i')  
	qui drop `i'






	foreach current_variable of varlist `varlist' {
		cap confirm numeric variable `current_variable'
		if _rc loc vartype string

		if  "`vartype'" == "string" & inlist("`with'", "mean", "median", "min", "max") {
			dis as error "Variable `current_variable' is a string variable, option with(`with') cannot be used with string variables."
			continue
		}

		if "`vartype'" == "string" loc emptyvalue  """"
		else loc emptyvalue  .

		if "`with'" == "any" {
			qui sort `byvar' `current_variable'
			qui by `byvar' `current_variable': replace `current_variable' = `current_variable'[_n-1] if `current_variable' == `emptyvalue' &  `touse'
			qui qui gsort `byvar' -`current_variable'
			by `byvar' : replace `current_variable' = `current_variable'[_n-1] if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "previous"{
			qui sort `byvar'  
			by `byvar' : replace `current_variable' = `current_variable'[_n-1] if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "next" {
			tempvar n bysn
			qui gen `n' = _n
			qui sort `byvar'
			by `byvar' : replace `current_variable' = `current_variable'[_n+1] if `current_variable' == `emptyvalue' &  `touse'

			qui bys `byvar': gen `bysn' = _n
			qui gsort `byvar' -`bysn'
			by `byvar' :replace `current_variable' = `current_variable'[_n-1] if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "first" {
			qui sort `byvar'
			by `byvar' : replace `current_variable' = `current_variable'[1] if `current_variable' == `emptyvalue' &  `touse'
		}

		else if "`with'" == "last" {
			qui sort `byvar'
			by `byvar' : replace `current_variable' = `current_variable'[_N] if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "min" {
			tempvar stat_current
			bys `byvar' : egen `stat_current' = min(`current_variable') if `touse'
			replace `current_variable' = `stat_current' if `current_variable' == `emptyvalue' &  `touse'
		}

		else if "`with'" == "max" {
			tempvar stat_current
			bys `byvar' : egen `stat_current' = max(`current_variable') if `touse'
			replace `current_variable' = `stat_current' if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "mean" {
			tempvar stat_current
			bys `byvar' : egen `stat_current' = mean(`current_variable') if `touse'
			replace `current_variable' = `stat_current' if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "median" {
			tempvar stat_current
			bys `byvar' : egen `stat_current' = median(`current_variable') if `touse'
			replace `current_variable' = `stat_current' if `current_variable' == `emptyvalue' &  `touse'
		}
		else if "`with'" == "linear" {
		    recast float `current_variable'
		    mata: process_panels_linear("`byvar'", "`current_variable'", "`touse'")
			//tempvar stat_current
			//bys `byvar' : egen `stat_current' = median(`current_variable') if `touse'
			//replace `current_variable' = `stat_current' if `current_variable' == `emptyvalue' &  `touse'
		}


	}
	sort `initialsort'

end

mata
	mata clear
	mata
		void process_panels_linear(string scalar by, string scalar varlist, string scalar touse) {
			real matrix X, ALLX, subX
			st_view(ALLX, ., varlist, touse)
			PANELID= st_data(., by, touse)
			panel =panelsetup(PANELID,1)
			NPanel = rows(panel)
			rows = rows(x)
			for (g=1; g<=NPanel; g++) { 
			ALLX[|panel[g,1],1 \ panel[g,2],1|] =	 linearAverage(ALLX[|panel[g,1],1 \ panel[g,2],1|])
			
			}
		}
		
		real matrix linearAverage(real matrix X) {
			run = 0
			m = 1
			if (X[1] == .) {
				r = 2
				while (X[r] ==.) {
					++r
				}
				X[1] = X[r]
			}
			rows = rows(X)
			for (r = 2; r<=rows; ++r) {
				p = r-1 
				n = r 
				n = max(r\m)
				while (X[n] ==. & n < rows) {
				    
					++n
				}
				m = n
				
				if (X[r] == .) X[r] = mean(X[p]\X[n])	
			}
			
			return(X)
		}
	
end

