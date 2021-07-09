*! 1.1 LES 04apr2003 -first try
*! 1.2 NJC 05apr2003 -no longer over-writes original log!; implements macval(); kills continued lines 
*! 1.3 LES 06may2003 -SMCL compatibility; changed syntax; better long line support; kills entertainment dots 
*! 1.4 LES 08sep2005 -option to remove "log headers" added
*! 1.5 LES 25mar2010 - upgrade to Stata v 11: kills four lines at beginning of log starting with name: line,
*                      no longer kills di lines with period in first word but not first position e.g. 1. blah
program cleanlog
	version 11
	syntax using, Saving(string) [REPLACE NOHEADers]
	tempname in out
	file open `in' `using', read
	file open `out' using "`saving'", write `replace'
	file read `in' line
	while !r(eof) {
		if "`noheaders'" != "" {
			local w1 : word 1 of `line'
			local head = match("`w1'", "*name:*")
			if "`head'"=="1" {
				file read `in' line
				file read `in' line
				file read `in' line
				file read `in' line
			}
		}		
		local w1 : word 1 of `line'
		local dot = match("`w1'", ".*")
		if "`dot'"=="1" {
			file read `in' line2
			local w1 : word 1 of `line2'
			local right_arrow = match("`w1'", "*>*")
			if "`right_arrow'"=="0" {
				local line "`line2'"
			}
		}
		else {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
		}
	}
end
