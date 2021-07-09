*! version 1.0, 01Dec2004, John_Hendrickx@yahoo.com

/*
Called by -coldiag2- to print the condition indexes
and variance-decomposition proportions.
Sensitive to linesize, options for compact printing,
and for suppressing variance-decomposition proportions
below a specified 'fuzz' value.
*/

program define prnt_cx
	version 7
	syntax [,Matname(string) w(integer 12) d(integer 2) Space(integer 1) FUzz(real .3) FOrce Char(string)]

	if "`matname'" == "" {
		tempname Y
		capture matrix `Y'=r(cx),r(pi)
		local matname="`Y'"
	}
	* if `matname' is still empty then something went wrong
	if "`matname'" == "" {
		display as error "Use {cmd:print_cx} after coldiag2"
		display as error "Matrix r(cx) and/or matrix r(pi) not found"
		exit
	}

	* get requisite information
	local pgwd: set linesize
	local nrow=rowsof(`matname')
	local ncol=colsof(`matname')
	local vnames: colnames `matname'
	local vnames: subinstr local vnames "CX " ""

	* "fuzz" replacement character, default "."
	if "`char'" == "" {
		local char "."
	}
	else {
		local char=substr("`char'",1,1)
	}

	if "`force'" == "force" {
		* print width must be at least 5, function -abbrev- doesn't go any lower
		local w=max(`w',5)
		local orig_vnames "`vnames'"
		local vnames
		foreach nm of local orig_vnames {
			local el=abbrev("`nm'",`w')
			local vnames="`vnames' `el'"
		}
	}
	else {
		* the longest variable name determines the column width
		local w 0
		foreach nm of local vnames {
			local w=max(`w',length("`nm'"))
		}
	}
	local w=max(`w',`d'+2)
	* width for fuzz characters, shorter to align with decimal point
	local wf=`w'-`d'

	* width of column 1 is determined by the condition number
	* add 2, digits=int(log10(x))+1, plus 1 for the decimal place
	local c1w=int(log10(`matname'[`nrow',1]))+`d'+2

	* position "cond" above "index"
	* start printing in column 3 (allow for 2 digits followed by a space)
	local condpos=`c1w'+3
	if `condpos' > 9 {
		local cond "condition"
	}
	else {
		local cond "condition"
	}
	* number of (sub)tables
	local ntabs=int((`w'+`space')*`ncol'/(`pgwd'-`condpos'))+1
	* number of columns per subtable
	local prtb=int((`pgwd'-`condpos')/(`w'+`space'))

	display _newline as text "Condition Indexes and Variance-Decomposition Proportions" _newline

	* `m' is a placeholder for the first column of `matname'
	* being printed in a particular subtable
	local m 1
	forval k=1/`ntabs' {
		display as text %`condpos's "`cond'"
		display as text _skip(3) %`c1w's "index" _skip(`space') _continue
		forval j=1/`prtb' {
			local n=`m'+`j'-1
			local nm: word `n' of `vnames'
			display as text %`w's "`nm'" _skip(`space') _continue
		}
		display
		forval i=1/`nrow' {
			display as text %-3.0f `i' _continue
			display as result %`c1w'.`d'f `matname'[`i',1] _skip(`space') _continue
			forval j=1/`prtb' {
				local n=`m'+`j'
				if `matname'[`i',`n'] < `fuzz' {
					display as result %`wf's "`char'" _skip(`d') _skip(`space') _continue
				}
				else {
					display as result %`w'.`d'f `matname'[`i',`n'] _skip(`space') _continue
				}
				if `n' > `ncol'-1 {continue, break}
			}
			display
		}
		local m=`m'+`prtb'
		display
	}
	if `fuzz' ~= 0 {
		display as text `"Variance-Decomposition Proportions less than `fuzz' have been printed as "`char'""'
	}

end
