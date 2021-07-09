*! strgroup 1.0.2 07aug2010 by Julian Reif
* 1.0.2: Added byable option
* 1.0.1: Improved plugin memory management. Recompiled plugin using optimization flags.

program strgroup, byable(recall, noheader)

	* We are using version 2.0 of Stata's plugin interface, which requires Stata 9
	version 9.2
	
	syntax varname [if] [in], GENerate(name) THRESHold(real) [first NORMalize(string) noCLEAN force]
	
	* Make sure we exclude missing string values - they can cause problems with normalization otherwise
	marksample touse, strok
	
	*********************************************
	**		Error check the user inputs		   **
	*********************************************	
	
	if _byindex()==1 confirm new var `generate'
	confirm string var `varlist'
	
	* Check normalization input
	local normalize `"`=lower("`normalize'")'"'
	if !inlist(`"`normalize'"',"","longer","shorter","none") {
		di as error `"Normalization '`normalize'' not allowed"'
		exit 198
	}
	if inlist("`normalize'","","shorter") local normalize = 0
	if "`normalize'"=="longer" local normalize = 1
	if "`normalize'"=="none" local normalize = 2
	
	* Does user want relative or absolute comparisons
	if "`normalize'"== "none" {
		cap confirm integer number `threshold'
		if _rc {
			di as error "{cmd:threshold(}{it:#}{cmd:)} must be an integer when specifying {cmd:normalize(none)}"
			exit 198			
		}
	}
	else local absolute = 0
	
	* Threshold value must be positive
	if `threshold' <= 0 {
		di as error "{cmd:threshold(}{it:#}{cmd:)} must be greater than 0"
		exit 198
	}

	* Display a warning if string values are not unique
	cap isid `varlist'
	if _rc di in yellow "{it:`varlist'} contains duplicate values. Remove them to speed up calculations."

	if _byindex()==1 qui gen long `generate' = .
	
	* Perform a full trim
	if "`clean'"!="noclean" {
		tempvar cleaned_v
		qui gen `cleaned_v' = trim(`varlist')
		local `varlist' `cleaned_v'
	}
	
	
	**********************************************
	**			Account for "first" option      **
	**********************************************
	/*
	If user specifies first, the plugin will be called 27 times (once for each letter of the alphabet, and once more
	for miscellaneous). We need to create unique touse variables for each of those calls (so that the plugin knows
	which observations to analyze.)
	*/
	if "`first'" != "" {	
		local char_num = 1
		foreach char in other a b c d e f g h i j k l m n o p q r s t u v w x y z {

			*Create new touse variable and set it equal to the original
			tempvar touse_`char_num'
			qui gen byte `touse_`char_num'' = `touse'

			*Subset down to strings not starting with an alphabetic letter
			if "`char'" == "other" qui replace `touse_1' = 0 if (substr(`varlist',1,1) >= "A" & substr(`varlist',1,1) <= "Z") | (substr(`varlist',1,1) >= "a" & substr(`varlist',1,1) <= "z")

			*Else subset down to one of the alphabetic letters
			else qui replace `touse_`char_num'' = 0 if substr(`varlist',1,1) != "`char'" & substr(`varlist',1,1) != "`=upper("`char'")'"

			local char_num = `char_num'+1
		}
	}

	*********************************************
	**      Run the strgroup plugin			   **
	*********************************************

	* Case 1: first is not specified. Use the original touse variable
	if "`first'" == "" {
		qui count if `touse'
		local num_records = `r(N)'
		if `num_records' > 10000 & "`force'"=="" {
			di as error "You are running {cmd:strgroup} on more than `num_records' observations.  You must specifiy {cmd:force} if you really want to do this."
			exit 198
		}	
		* Determine what group number we are currently on (will be nonzero if using the by() option)
		qui summ `generate'
		if "`r(max)'" != "" local group_num = `r(max)'
		else local group_num = 0		
		cap noi plugin call strgroup_plugin `varlist' `generate' if `touse', "`threshold'" "`num_records'" "`group_num'" 0 `normalize'
		if _rc {
			di as error "Plugin error " _rc
			exit 198
		}
	}

	* Case 2: first is specified. We need to reference specific touse variables. In addition, we need to manually track group numbers between the different calls to the plugin.
	else {
		forval char_num = 1/27 {
			qui count if `touse_`char_num''
			local num_records = `r(N)'
			if `num_records' > 10000 & "`force'"=="" {
				di as error "You are running {cmd:strgroup} on `num_records' observations.  You must specifiy {cmd:force} if you really want to do this."
				exit 198
			}				
			
			* Determine what group number we are currently on
			qui summ `generate'
			if "`r(max)'" != "" local group_num = `r(max)'
			else local group_num = 0
			cap noi plugin call strgroup_plugin `varlist' `generate' if `touse_`char_num'', "`threshold'" "`num_records'" "`group_num'" 0 `normalize'
			if _rc {
				di as error "Plugin error " _rc
				exit 198
			}			
		}
	}

end

program strgroup_plugin, plugin using( "strgroup.plugin" )

*** END **