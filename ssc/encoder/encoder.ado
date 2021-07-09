* encoder (David Tannenbaum, August 2020)
* Program to encode variable and replace original as desired.
* Like encode, but can specify replace option instead of generate(name). 
* Also provides an option for the first labeled value to start at 0, rather than at 1.
* This program also compresses the generated variable to a more efficient datatype if possible.
* This program is dependent on Daniel Klein's 'elabel' package. You can install elabel by typing -ssc install elabel-
* Code for this program is based heavily on the 'rencode' program by Kenneth L. Simons (March 2006) and should be viewed as a revised version of that program.

program define encoder
	version 10.0
	syntax varname [if] [in], [generate(name) Label(name) NOExtend REPLACE SETzero]
	* check to see if the 'elabel' program is installed
	capture findfile elabel.ado
	if "`r(fn)'" == "" {
         di as txt "user-written package 'elabel' needs to be installed first;"
         di as txt "use -ssc install elabel- to do that"
         exit 498
    }
	* parse options
	if "`replace'" == "" & "`generate'" == "" {
		display as error "Use the replace option to overwrite the original variable, or use the generate(name) option to create a new variable."
		error 197
	}
	if "`replace'" == "replace" & "`generate'" != "" {
		display as error "Specify only one of generate(name) or replace options.  Replace will overwrite the original variable."
		error 197
	}
	if "`replace'" == "replace" {
		tempvar toGenerate
		local generate `toGenerate'
		if "`label'" == "" {
			local label `varlist'
		}
		local varlabel: variable label `varlist'
	}
	if "`label'" == "" {
		local labelOption
	}
	else {
		local labelOption label(`label')
	}
	* run the encode command
	encode `varlist' `if' `in', generate(`generate') `labelOption' `noextend'
	quietly compress `generate'
	* if setting first label to zero
	if "`setzero'" == "setzero" {
		replace `generate' = `generate' - 1
		elabel define (`generate') (= #-1) (= @), replace
	}
	* if replacing the original variable
	if "`replace'" == "replace" {
		move `generate' `varlist'
		nobreak {
			drop `varlist'
			rename `generate' `varlist'
			label values `varlist' `label'
			if "`varlabel'"!="" {
				label variable `varlist' `"`varlabel'"'
			}
		}
	}
end