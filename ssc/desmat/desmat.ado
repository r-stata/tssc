*! version 3.2, 17Sep2004, John_Hendrickx@yahoo.com
/*
Direct comments to:

John Hendrickx <John_Hendrickx@yahoo.com>

The latest version of desmat is available at SSC-IDEAS:
http://ideas.uqam.ca/ideas/data/bocbocode.html

Version 3.2, September 17, 2004
-desmat- wouldn't work with as a command prefix with -mclest-
because -mclest- has no dependent variable.
Added -mclest- to the list of commands with no dependent variable
Version 3.1, October 29 2002
Added a "full" contrast, i.e. no restrictions are imposed.
This means that duplicate dummy variables due to interactions
are also not dropped by -desmat-
Version 3.0, March 30, 2001
Version 7 compatibility
Small subprograms for different contrasts integrated into -descl-
Version 2.51, March 9, 2001
Fixed a bug in the detection of "if", "in", "using" if they happened to be
at the end of a segment
Added version 6 wherever this had been omitted
Version 2.5, January 3, 2001
Subroutine "class" renamed to "myclass" for compatibility with Stata version 7
(by Alan McDowell at StataCorp)
Version 2.41, December 15,2000
-desmat- choked on "@" flag using the new [pzat] retrieval method, put
detection of "@" first
Version 2.4, December 12,2000
Used a different method for retrieving the [pzat] characteristic.
local para "``var'[pzat]'" -- won't work with variables with length 8
local para: char `var'[pzat] -- does work
Version 2.3, November 28, 2000
Modified parsing so that -desmat- doesn't look for a dependent variable in
-stcox- or -streg-
Version 2.2, November 15, 2000
Desmat will now automatically encode string variables
Version 2.1, September 21, 2000
In command prefix mode, models weren't estimated quietly if no options at all
were specified
Version 2.0, September 12, 2000
Xi-like functionality: specify the command after a colon and the model will
be quietly estimated, then results presented using desrep.
Showtrms.ado as a separate program, for use after running desmat.
Added "@" prefix to flag continuous variables
Made report of terms dropped due to collinearity optional.
Version 1.2, Jan 19 2000
Desmat didn't deal properly with values that weren't equal to the category's
index number. Fixed the deviation contrast to use the category's value for
the reference category, not its index number.
Fixed the difference and helmert contrasts to use the category's index for
constructing the dummy (the value is used for logic).
Orthpoly can't handle large values properly, high degree polynomials can
contain missing values. Subtracted the first value of the variable as a
workaround.
Version 1.1,  Dec. 20 1999
Desmat will recognize a variable's "pzat" characteristic as the
parameterization for that variable. This will override the default
parameterization for the model (specified as an option after a comma)
but is overriden by a specification of a parameterization for that
specific term
Version 1.02, Oct. 8 1999
Changed default contrast to indicator, first category reference
Changed default reference category to first instead of last
Changed default direction for difference contrast from "backward" to "forward"
Added reverse Helmert contrast (SPSS difference contrast)
Helmert now accepts the same "refcat" options as difference. i.e.
"hel(f)" is a normal helmert contrast, the default
"hel(b)" is a reverse helmert contrast
Switched to the internal Stata function "_rmcoll" for dropping collinear
variables, see "drpdbls"
Version 1.01, Sept. 30 1999
Cosmetic changes to display a 'direct' variables name in an interaction but
not in a main effect
*/

program define desmat
	version 7

	gettoken colon 0 : 0, parse(":")

	if `"`colon'"' == ":" {
		gettoken cmd 0 : 0
		gettoken depvar 0 : 0
		* -stcox-,  -streg-, and -mclest- don't use a dependent variable
		foreach proc in stcox streg mclest {
			if "`cmd'" == "`proc'" {
				local 0 "`depvar' `0'"
				local depvar ""
			}
		}
		/*
		if "`cmd'" ~= "stcox" & "`cmd'" ~= "streg" {
			gettoken depvar 0 : 0
		}
		*/

		* split argument string in segments to take length > 80 into account
		local i 1
		local p=.
		local seg`i' : piece `i' 80 of "`0'"
		while "`seg`i''" ~= "" {
			* find first occurence of keywords as delimiter for the model
			if `p' == . | `p' == 0 {
				local p1=index(" `seg`i'' "," in ")
				if `p1'==0 {local p1=. }
				local p2=index(" `seg`i'' "," if ")
				if `p2'==0 {local p2=. }
				local p3=index(" `seg`i'' "," using ")
				if `p3'==0 {local p3=. }
				local p4=index("`seg`i''","[")
				if `p4'==0 {local p4=. }
				local p5=index("`seg`i''",",")
				if `p5'==0 {local p5=. }
				local p=min(`p1',`p2',`p3',`p4',`p5')
				local pseg `i'
			}
			local i=`i'+1
			local seg`i' : piece `i' 80 of "`0'"
		}
		local nsegs=`i'-1

		if `p' ~= . & `p' > 0 {
			local model=substr("`seg`pseg''",1,`p'-1)
			local 0=substr("`seg`pseg''",`p',.)
			local i 1
			while `i' < `pseg' {
				local model "`seg`i'' `model'"
				local i=`i'+1
			}
			if `nsegs' > `pseg' {
				local i=`pseg'+1
				while `i' <= `nsegs' {
				  local 0 "`0' `seg`i''"
				  local i=`i'+1
				}
			}

			#delimit ;
			syntax [if][in][using][fweight pweight aweight iweight]
			[, VERBOSE DEFCON(string) DESREP(string) * ];
			#delimit cr
			if "`weight'" ~= "" {
				local wgtexp="[`weight'`exp']"
			}
		}
		else {
			local model "`0'"
		}

		if "`verbose'" == "" {
			local how "quietly"
		}

		`how' parsemod `model' ,`defcon'
		`how' `cmd' `depvar' _x_* `if' `in' `wgtexp' , `options'
		desrep `using', `desrep'
	}
	else {
		parsemod `colon'
	}
end

program define parsemod
	version 7.0

	capture drop _x_*
	macro drop term*

	tokenize `"`0'"' , parse(",")
	local model `1'
	* place args 2 and 3 back in 0, parse for options
	local 0 "`2'`3'"
	syntax [, Colinf Defcon(string) * ]
	if "$D_CINF" ~= "" & index("`0' ","colinf ") == 0 {
		local colinf "$D_CINF"
	}
	if "`defcon'" ~= "" {
		global defpara "`defcon'"
	}
	else {
		global defpara "`options'"
		if "$D_CON" ~= "" & "`defpara'" == "" {
			global defpara "$D_CON"
		}
	}

	global ncols 0
	global nodrop 0
	tokenize "`model'"
	local spec `1'
	while "`spec'" ~= "" {
		macro shift
		local model `*'

		* find contrast, if any
		tokenize "`spec'", parse("=")
		local term `1'
		local termpar `3'

		* interaction or main effect?
		if index("`term'","*") ~= 0 {
			intrct * `term' `termpar'
		}
		else if index("`term'",".") ~= 0 {
			intrct . `term' `termpar'
		}
		else {
			myclass `term' `termpar'
		}

		tokenize `model'
		local spec `1'
	}

	* eliminate collinear variables (e.g. from a*b b*c)
	if $nodrop == 1 {
		display "A full contrast was used in this model"
		display "Duplicate dummy variables will therefore not be dropped by desmat"
	}
	else {
		dropdbls ,`colinf'
	}
	quietly compress
	showtrms
	global defpara
end

program define myclass
	version 7
	args var para
	* prefixing a variable with an "@" flags it as continuous
	if substr("`var'",1,1) == "@" {
		local var=substr("`var'",2,.)
		local para "dir"
	}

	* if a parameterization has been specified, use that.
	* Otherwise, use parameterization associated with the variable if defined,
	* or the default parameterization for the model, if specified.
	if "`para'" == "" {local para: char `var'[pzat] }
	if "`para'" == "" {local para $defpara }
	tokenize "`para'", parse ("()")
	local par=lower(substr("`1'",1,3))
	local refcat `3'
	if "`par'" == "dir" {
		global ncols=$ncols+1
		gen _x_$ncols=`var'
		local lbl: variable label `var'
		if "`lbl'" == "" {
			label var _x_$ncols "`var'"
		}
		else {
			label var _x_$ncols "`lbl'"
		}
		char _x_$ncols[pzat] "direct"
		char _x_$ncols[varn] "`var'"
		char _x_$ncols[valn] "`var'"
	}
	else if "`par'" == "ful" {
		* full contrast, i.e. no restrictions imposed
		* check whether the variable is string
		global nodrop 1
		local varnm "`var'"
		local tp: type `var'
		if substr("`tp'",1,3) == "str" {
			tempvar numvar
			encode `var', gen(`numvar')
			local var "`numvar'"
		}

		tempname vallabs
		quietly tab `var', matrow(`vallabs')
		local ncat=_result(2)

		forvalues i = 1/`ncat' {
			global ncols=$ncols+1
			local labx=`vallabs'[`i',1]
			local thislab: label (`var') `labx'

			gen byte  _x_$ncols=(`var'==`labx') if (`var' ~= .)

			label var _x_$ncols "`var'==`labx'"
			char _x_$ncols[pzat] "full"
			char _x_$ncols[varn] "`varnm'"
			char _x_$ncols[valn] "`thislab'"
		}
	}
	else if "`par'" == "orp" {
		* check whether the variable is string
		local varnm "`var'"
		local tp: type `var'
		if substr("`tp'",1,3) == "str" {
			tempvar numvar
			encode `var', gen(`numvar')
			local var "`numvar'"
		}

		tempname vallabs
		tempvar orpvar
		quietly tab `var', matrow(`vallabs')
		local ncat=_result(2)
		if "`refcat'" == "" {local refcat= `ncat'-1}
		if `refcat' < 1 | `refcat' >= `ncat' {local refcat=`ncat'-1}

		local i=$ncols+1
		global ncols=$ncols+`refcat'
		* orthpoly has problems with large numbers.
		* Subtract the lowest value of `var' as a workaround
		gen `orpvar'=`var'-`vallabs'[1,1]
		if `refcat' == 1 {
			orthpoly `orpvar', deg(`refcat') generate(_x_$ncols)
		}
		else {
			orthpoly `orpvar', deg(`refcat') generate(_x_`i'-_x_$ncols)
		}
		local k 0
		while `k' < `refcat' {
			local k=`k'+1
			local ik=`i'-1+`k'
			* normalize variables for comparability with SPSS and desmat.sas
			quietly replace _x_`ik'=_x_`ik'/sqrt(`ncat')
			* repair the variable label
			label var _x_`ik' "deg=`k' orth. poly. for `varnm'"
			char _x_`ik'[pzat] "orp(`refcat')"
			char _x_`ik'[varn] "`varnm'"
			char _x_`ik'[valn] "`varnm'^`k'"
		}
	}
	else if "`par'" == "use" {
		* check whether the variable is string
		local varnm "`var'"
		local tp: type `var'
		if substr("`tp'",1,3) == "str" {
			tempvar numvar
			encode `var', gen(`numvar')
			local var "`numvar'"
		}

		tempname vallabs
		quietly tab `var', matrow(`vallabs')
		local ncat=_result(2)
		tempname X

		* `refcat' refers to contrast matrix
		* test for existence and valid numbers of columns
		capture local i=colsof(`refcat')
		if _rc ~= 0 {
			display "Matrix `refcat' for user defined contrast of `var' not found"
			exit=-1
		}
		if `i' ~= `ncat' {
			display "Matrix `refcat' has `i' columns," _continue
			display " variable `var' has `ncat' categories"
			exit=-1
		}
		local j=rowsof(`refcat')
		if `j' >= `i' {
			display "Matrix `refcat' has `j' rows but only `i' columns, invalid"
			exit=-1
		}
		matrix `X'=`refcat'*`refcat''
		if det(`X') == 0 {
			display "Matrix `refcat' has linear dependencies between rows"
			exit=-1
		}
		local nms: rownames `refcat'

		matrix `X'=`refcat''*inv(`X')

		local i=1
		while `i' <= colsof(`X') {
			global ncols=$ncols+1
			gen _x_$ncols=0
			local j=1
			while `j' <= rowsof(`X') {
				quietly replace _x_$ncols=`X'[`j',`i'] if `var'==`vallabs'[`j',1]
				local j=`j'+1
			}
			* make sure missing values are missing for the dummies as well
			quietly replace _x_$ncols=. if (`var' == .)
			local labx=`vallabs'[`i',1]
			label var _x_$ncols "`varnm'==`labx'"
			char _x_$ncols[valn] "`labx'"
			local nm: word `i' of `nms'
			if "`nm'" ~= "r`i'" {
				label var _x_$ncols "`nm'"
				char _x_$ncols[valn] "`nm'"
			}

			char _x_$ncols[pzat] "use(`refcat')"
			char _x_$ncols[varn] "`varnm'"

			local i=`i'+1
		}
	}
	else if "`par'" == "dev" {
		descl dev `var' `refcat'
	}
	else if "`par'" == "sim" {
		descl sim `var' `refcat'
	}
	else if "`par'" == "hel" {
		descl helm `var' `refcat'
	}
	else if "`par'" == "dif" {
		descl dif `var' `refcat'
	}
	else {
		* indicator contrast, default
		descl ind `var' `refcat'
	}
end

program define descl
	version 7
	args par var refcat

	* check whether the variable is string
	local varnm "`var'"
	local tp: type `var'
	if substr("`tp'",1,3) == "str" {
		tempvar numvar
		encode `var', gen(`numvar')
		local var "`numvar'"
	}

	tempname vallabs
	quietly tab `var', matrow(`vallabs')
	local ncat=_result(2)

	if "`par'" == "dif" | "`par'" == "helm"  {
		local refcat=lower(substr("`refcat'",1,1))
		if "`refcat'" == "b" {
			local refcat=1
			local reflab="B"  /* backward difference */
		}
		else {
			local refcat=`ncat'
			local reflab="F"  /* forward difference, default */
		}
	}
	else {
		if "`refcat'" == "" {local refcat 1}
		if `refcat' < 1 {local refcat 1}
		if `refcat' > `ncat' {local refcat `ncat'}
		local reflab=`vallabs'[`refcat',1]
	}

	forvalues i = 1/`ncat' {
		if `i' ~= `refcat' {
			global ncols=$ncols+1
			local labx=`vallabs'[`i',1]
			local thislab: label (`var') `labx'

			* generate the design vectors here
			if "`par'" == "ind" {
				gen byte  _x_$ncols=(`var'==`labx')
			}
			else if "`par'" == "sim" {
				gen _x_$ncols=(`var'==`labx')
				quietly replace  _x_$ncols=_x_$ncols-1/`ncat'
			}
			else if "`par'" == "dev" {
				gen byte _x_$ncols=(`var'==`labx')-(`var'==`reflab')
			}
			else if "`par'" == "helm" {
				if "`reflab'"=="B" {
					* reverse helmert (SPSS difference)
					* `i'=2 to `ncat'
					gen _x_$ncols=0
					quietly {
						replace _x_$ncols=(   -1 +`i')/(       `i'  ) if (`var'==`labx')
						replace _x_$ncols=        -1  /(       `i'  ) if (`var'< `labx')
					}
				}
				else {
					* "normal" helmert contrast
					* `i'=1 to `ncat'-1
					gen _x_$ncols=0
					quietly {
						replace _x_$ncols=(`ncat'-`i')/(`ncat'-`i'+1) if (`var'==`labx')
						replace _x_$ncols=        -1  /(`ncat'-`i'+1) if (`var'> `labx')
					}
				}
			}
			else if "`par'" == "dif" {
				if "`reflab'"=="B" {
					* backward difference, each category versus previous
					* `i'=2 to `ncat'
					local i=`i'-1
					gen _x_$ncols=`i'/`ncat'
					quietly replace _x_$ncols=(`i'-`ncat')/`ncat' if (`var'< `labx')
				}
				else {
					* forward difference, each category versus next (SPSS repeated)
					* `i'=1 to `ncat'-1
					gen _x_$ncols=-`i'/`ncat'
					quietly replace _x_$ncols=(`ncat'-`i')/`ncat' if (`var'<=`labx')
				}
			}

			* make sure missing values are missing for the dummies as well
			quietly replace _x_$ncols=. if (`var' == .)
			label var _x_$ncols "`var'==`labx'"
			char _x_$ncols[pzat] "`par'(`reflab')"
			char _x_$ncols[varn] "`varnm'"
			char _x_$ncols[valn] "`thislab'"
		}
	}
end

program define intrct
	version 7
	args tp term termpar
	local frst=$ncols+1

	tokenize "`term'", parse("`tp'")
	local main "`1'"
	macro shift 2 /* for the separator (`tp') */
	local term `*'

	while "`main'" ~= "" {
		tokenize "`termpar'", parse("`tp'")
		local cntrst `1'
		macro shift 2 /* for the separator (`tp') */
		local termpar `*'

		local pnt=$ncols+1
		myclass `main' `cntrst'

		local i=`frst'
		local lst=$ncols
		while `i' < `pnt' {
			local lbl1: variable label _x_`i'
			local pzat1="`_x_`i'[pzat]'"
			local varn1="`_x_`i'[varn]'"
			local valn1="`_x_`i'[valn]'"
			local j=`pnt'
			while `j' <= `lst' {
				global ncols=$ncols+1
				gen _x_$ncols=_x_`i'*_x_`j'
				local lbl2: variable label _x_`j'
				local pzat2="`_x_`j'[pzat]'"
				local varn2="`_x_`j'[varn]'"
				local valn2="`_x_`j'[valn]'"
				label var _x_$ncols "`lbl1'.`lbl2'"
				char _x_$ncols[pzat] "`pzat1'.`pzat2'"
				char _x_$ncols[varn] "`varn1'.`varn2'"
				char _x_$ncols[valn] "`valn1'.`valn2'"
				local j=`j'+1
			}
			local i=`i'+1
		}

		if "`tp'" == "." {
			if `pnt' > `frst' {
				* drop everything but the highest term generated
				drop _x_`frst'-_x_`lst'

				local i=`lst'+1
				while `i' <= $ncols {
				  local j=`i'-(`lst'-`frst'+1)
				  rename _x_`i' _x_`j'
				  local i=`i'+1
				}
				global ncols=$ncols-(`lst'-`frst'+1)
			}
		}

		* get the name of the next variable in the interaction
		tokenize "`term'", parse("`tp'")
		local main "`1'"
		macro shift 2 /* for the separator (`tp') */
		local term `*'

	} /* end of main while loop */
end

program define dropdbls
	version 7.0

	syntax [, Colinf ]

	* returns r(varlist), a noncollinear set
	quietly _rmcoll _x_*

	* do nothing if the noncollinear set equals the present set
	local nkeep: word count `r(varlist)'
	if `nkeep' == $ncols {
		exit
	}

	if "`colinf'" ~= "" {
		#delimit ;
		display _newline
		"Note: collinear variables are usually duplicates and no cause for alarm"
		_newline;
		#delimit cr
	}
	local i 1
	local lstx 0
	tokenize "`r(varlist)'"
	while "`1'" ~= "" {
		local indx=substr("`1'",4,.)

		* drop collinear variables
		local j=`lstx'+1
		while `j' < `indx' {
			if "`colinf'" ~= "" {
				local varn="`_x_`j'[varn]'"
				local valn="`_x_`j'[valn]'"
				display "`varn' (`valn') dropped due to collinearity"
			}
			drop _x_`j'
			local j=`j'+1
		}

		* renumber the noncollinear set
		if `i' ~= `indx' {
			rename `1' _x_`i'
		}

		macro shift
		local lstx=`indx'
		local i=`i'+1
	}

	* in case collinear variables are at the end of the old set
	local indx=`indx'+1
	while `indx' <= $ncols {
		if "`colinf'" ~= "" {
			local varn="`_x_`indx'[varn]'"
			local valn="`_x_`indx'[valn]'"
			display "`varn' (`valn') dropped due to collinearity"
		}
		drop _x_`indx'
		local indx=`indx'+1
	}

	* update ncols
	global ncols=`i'-1
end
