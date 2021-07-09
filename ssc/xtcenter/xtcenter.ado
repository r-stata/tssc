/**
*
*	author: Eldin Dzubur (University of Southern California)
*	module name: xtcenter
*	version: 13
*	dependencies: sorted dataset by id variable
* 					
*	description: This program centers and parses multi-level variance for use with melogit and mixed
*	commands. The program takes one variable exactly and one id variable in options. The program will
*	automatically center continuous variables, but will only center binary variables if option=interaction
*	is specified. 
*	
*	Citation: Curran, P. J., & Bauer, D. J. (2011). The disaggregation of within-person and between-person effects in longitudinal models of change. Annual review of psychology, 62, 583.
*   
**/

program xtcenter, sortpreserve
version 13
syntax varlist(min=1 max=1 numeric fv) [,i(varlist max=1) INTeraction REPlace]
quietly capture xtset
if ("`r(panelvar)'" != "" | "`i'" != "") {
	local id = "`r(panelvar)'"
	if "`id'" == "" {
		local id = "`i'"
	}
	sort `id', stable
	quietly sum `varlist'
	local sdr = r(sd)
	if `sdr' == 0 {
		display "This variable has no variance. Centering is not possible."
	}
	else if "`s(fvops)'" == "true" {
		fvexpand `varlist'
		local count = 0
		foreach i in `r(varlist)' {
			local count = `count' + 1
		}
		if `count' == 2 {
			fvrevar `varlist', list
			local varname = "`r(varlist)'"
			by `id': egen double `varname'_zmax = count(`varname')
			by `id': egen double `varname'_ztot = sum(`varname')
			capture gen double `varname'_zbari = `varname'_ztot/`varname'_zmax
			if _rc == 0 | "`replace'" == "replace" {
					drop `varname'_zbari 
					gen double `varname'_zbari = `varname'_ztot/`varname'_zmax
				}
				else {
					local zbari = "true"
					if "`interaction'" == "" {
						display "`varname'_zbari already exists."
					}
				}
			egen double `varname'_gmaxs = count(`varname')
			egen double `varname'_gtot = sum(`varname')
			gen double `varname'_grand = `varname'_gtot/`varname'_gmaxs
			if "`interaction'" == "interaction"{
				capture gen double `varname'_zbari_cent = `varname'_zbari - `varname'_grand
				if _rc == 0 | "`replace'" == "replace" {
					drop `varname'_zbari_cent
					gen double `varname'_zbari_cent = `varname'_zbari - `varname'_grand
				}
				else {
					display "`varname'_zbari_cent already exists."
				}
			}
			drop `varname'_gmaxs `varname'_gtot `varname'_grand
			drop `varname'_zmax
			drop `varname'_ztot
			capture gen double `varname'_zti = `varname' //- `varlist'_zbari
			if _rc == 0 | "`replace'" == "replace" {
				drop `varname'_zti 
				gen double `varname'_zti = `varname' //- `varlist'_zbari
				}
				else {
					local zti = "true"
					if "`interaction'" == "" { 
						display "`varname'_zti already exists."
					}
				}
			label variable `varname'_zti "`varname', prompt-level observation"
			label variable `varname'_zbari "`varname', person level proportion"
			if "`interaction'" == "interaction"{
				capture gen double `varname'_zti_cent = `varname' - `varname'_zbari
				if _rc == 0 | "`replace'" == "replace" {
					drop `varname'_zti_cent 
					gen double `varname'_zti_cent = `varname' - `varname'_zbari
				}
				else {
					display "`varname'_zti_cent already exists."
				}
				if "`zti'" == "" {
					drop `varname'_zti
				}
				if "`zbari'" == "" {
					drop `varname'_zbari
				}
				label variable `varname'_zti_cent "`varname', prompt level proportion, person-centered"
				label variable `varname'_zbari_cent "`varname', person level proportion, grand-mean centered"
			}
		}
		else {
			display "This program does not yet support multinomial models."
		}
	}

	else {
		local varname = "`varlist'"
		capture by `id': egen double `varname'_zbari = mean(`varlist')
		if _rc == 0 | "`replace'" == "replace" {
			drop `varname'_zbari 
			by `id': egen double `varname'_zbari = mean(`varlist')
			capture gen double `varname'_zti = `varname' - `varname'_zbari
			if _rc == 0 | "`replace'" == "replace" {
				drop `varname'_zti
				gen double `varname'_zti = `varname' - `varname'_zbari
				egen double `varname'_mean = mean(`varname')
				replace `varname'_zbari = `varname'_zbari - `varname'_mean
				label variable `varname'_zti "`varname', prompt level observation, person centered"
				label variable `varname'_zbari "`varname', person level observation, grand-mean centered"
				drop `varname'_mean
			}
			else {
				display "`varname'_zti already exists."
			}
		}
		else {
			display "`varname'_zbari already exists. Cannot compute _zti."
		}
	}
}
else {
	display "No ID or panel variable via xtset specified."
}
end
