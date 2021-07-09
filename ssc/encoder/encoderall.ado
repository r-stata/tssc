* encoderall (David Tannenbaum, August 2020)
* Program to encode multiple variables and replace originals.
* Like encode, but replaces instead of using generate(name), and operates on multiple variables.
* Ignores non-string variables.
* Also provides an option for the first labeled value to start at 0, rather than at 1.
* This program is dependent on Daniel Klein's 'elabel' package. You can install elabel by typing -ssc install elabel-
* The generated variables are compressed to a more efficient datatype if possible.
* Code for this program is based heavily on the 'rencode' program by Kenneth L. Simons (March 2006) and should be viewed as a revised version of that program.

program define encoderall
	version 10.0
	syntax [varlist] [if] [in], [Label(name) NOExtend NOEXTENDAll SETzero]
	* Parse options
	if "`label'" == "" {
		local labelOption
	}
	else {
		local labelOption label(`label')
	}
	if "`noextendall'" == "noextendall" {
		local noextend = "noextend"
	}
	local noextendToUse `noextend'
	if "`setzero'"=="setzero" {
		* check to see if the 'elabel' program is installed
		capture findfile elabel.ado
		if "`r(fn)'" == "" {
        	display as error "user-written package 'elabel' needs to be installed first;"
        	display as error "use -ssc install elabel- to do that"
        	exit 498
        }
		local setzeroToUse = "setzero"
	}
	* Run the encoder command on each variable in the varlist
	preserve
	local nEncoded = 0
	foreach v of local varlist {
		local typ : type `v'
		if substr("`typ'",1,3)=="str" {
			if "`label'" == "" & "`noextend'" == "noextend" {
				local vLabMaxlen : label `v' maxlength
				if `vLabMaxlen'==0 {
					* No label exists with the same name as the variable. Do not require noextend.
					if "`noextendall'" == "noextendall" {
						display as error "Variable `v' does not have a label, so the noextend option cannot be applied to it."
						display as error "Since you used the noextendall option, the encoderall command is aborting."
						exit 198
					}
					local noextendToUse = ""
				}
				else {
					* A label exists with the same name as the variable. Use noextend.
					local noextendToUse = "noextend"
				}
			}
			capture encoder `v' `if' `in', `labelOption' `noextendToUse' replace `setzeroToUse'
			if _rc == 459 {
				local note = cond("`noextend'"=="",""," probably because noextend was specified and new values occur")
				display as result "Not encoded (error 459`note'): `v'"
				if "`noextendall'" == "noextendall" {
					display as error "Since you used the noextendall option, the encoderall command is aborting."
					exit 459
				}
			}
			else {
				if _rc > 0 {
					display as error "Error while encoding `v':"
					error _rc
				}
				local nEncoded = `nEncoded' + 1
			}
		}
	}
	if `nEncoded'==0 {
		display as result "Nothing to encode."
	}
	else {
		local s = cond(`nEncoded'==1, "", "s")
		display as result "Encoded `nEncoded' variable`s'."
	}
	restore, not
end