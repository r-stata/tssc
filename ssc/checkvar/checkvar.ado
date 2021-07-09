*! version 1.2  07nov2016
program define checkvar, rclass
	syntax varlist [if] [in]
	version 8

	// program drops most obs and vars for efficiency,
	// so first preserve the original data

	preserve
      if "`if'" != "" {
         keep `if'
      }
      if "`in'" != "" {
         keep `in'
      }
	keep `varlist'

	// replace string missing with "." for better display
        
        local all_numeric 1
	foreach v of varlist `varlist' {
		loc type : type `v'
		if substr("`type'",1,3) == "str" {
			quietly replace `v' = "." if `v' == ""
                        local all_numeric 0
		}
	}

	// separate first variable in varlist as "created variable"
	// and remainder as "component variables"

	tokenize `varlist'
	local createdvar `1'
	macro shift
	local componentvars `*'

	// Thanks to Dan Blanchette for this algorithm,
	// and to Nick Cox for the following 3 lines -
	// much more efficient than the way I was doing it.

	tempvar freq
	bysort `varlist': gen `freq' = _N 
	quietly by `varlist': keep if _n == 1 

	// sort by created var, then components within it,
	// and display as a table

	di _newline

	// title line

	di _col(3)	as text "Created Variable: " /// 
			as result "`createdvar'"

	// column header line

	local b = " "
	local c = "14"
	local countvars = "0"
	foreach v of varlist `componentvars' {
		local col = "_col(`c')"
		local y = abbrev("`createdvar'",8)
		local x = abbrev("`v'",8)
		local varnames `"`varnames' `b' `col' `b' %8s "`x'" `b'"'
		local c = `c' + 10
		local countvars = `countvars' + 1
	}
	local c = `c' - 1
	local col = "_col(`c')"
	local hlinelength = (`countvars' * 10)
	di as text _col(3) "{hline 9}{c TT}{hline `hlinelength'}{c TT}{hline 9}"
	di as text	_col(3)  		%8s "`y'" ///
			_col(12) "{c |}"	`varnames' ///
			`col'	   "{c |}"	%9s "Freq"
	di as text _col(3) "{hline 9}{c +}{hline `hlinelength'}{c +}{hline 9}"

	// display each combination of created variable with its
	// unique sets of component vars as separate lines in a table

	// first build a display list of the component-variable combinations
	// (each obs is a unique combination for that value of created var)

	forval i = 1/`=_N' {
		local c = "14"
		foreach v of varlist `componentvars' {
			local col = "_col(`c')"
			local x = "`v'[`i']"
			loc type : type `v'

	// display string values with %8s format, trim leading & trailing blanks, 	
	// and truncate string values to first 8 characters
	// so they don't push over the next column

			if substr("`type'",1,3) == "str" {
				local displaylist "`displaylist' `b' `col' `b' %8s `x'"
				quietly replace `v' = substr(trim(`v'),1,8) in `i' 
			}

	// display numeric values with %8.0g format

			else {
				local displaylist "`displaylist' `b' `col' `b' %8.0g `x'"
			}
			local c = `c' + 10
		}

	// put the created-variable value on the front, and the freq on the end

		local c = `c' - 1
		local col = "_col(`c')"
		local y = "`createdvar'[`i']"
		di _col(3)  as result %8.0g `y' ///
		   _col(12) as text   "{c |}" /// 
				as result `displaylist' ///
		   `col'	as text   "{c |}" ///
				as result %9.0g `freq'[`i']
		local displaylist ""

	// put a dividing line between each new value of the created var
		if `createdvar'[`i'] ~= `createdvar'[`i'+1] & `i'<_N {
			di as text _col(3) "{hline 9}{c +}{hline `hlinelength'}{c +}{hline 9}"
		}
	}

	di as text _col(3) "{hline 9}{c BT}{hline `hlinelength'}{c BT}{hline 9}"
 
     // create a matrix if all numeric variables 
      if `all_numeric' {
        mkmat `varlist' `freq', mat(checkvar)
        matrix colnames checkvar = `varlist' freq
        return matrix checkvar checkvar
      }
 
      return local combos `=_N'

        
end

exit



HISTORY

07nov2016 - fixed an error that prevented "if" and "in" from working
11mar2009 - updated help and sent to Kit for inclusion in SSC archive
29dec2008 - added "if" and "in" options
15jun2004 - shows all unique combinations of the component vars when they are listed
            in the varlist without the created var - this is more than the command is
            intended to do, but people tried to use it this way (a la -groups-)
            and found that it dropped one or more combinations of the component vars.
            saves number of combinations in r(combos), and matrix of combinations
            and their frequencies in r(checkvar), if varlist is numeric.
09dec2003 - made 3 changes suggested by Nick Cox, one a correction, one an efficiency
		enhancement, and one replacing -while- with -forval-
11aug2003 - fixed the problem where displaylist was a string variable and couldn't 
		grow past 244 characters
06Jun2003 - no error checks except built-in (can't think of any more to do) 
		abbreviate varnames to 8 characters
		change string blank to "." so it displays more clearly in table
		display using formats so all labels and values are right justified in column
		truncate string values to first 8 characters so they don't push next column
		 

