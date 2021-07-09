/*------------------------------------------
this program returns estimated parmaters
from an HLM output file.  
right now it only returns the final deviance 
statistic and df.
-------------------------------------------*/

capture program drop hlmstore
program define hlmstore
version 8.2
	syntax using/

macro drop devstat dfstat
tempname fh
local linenum = 0
local dfline = 0
file open `fh' using `"`using'"', read
file read `fh' line
while r(eof)==0 {
	local linenum = `linenum' + 1
	tokenize "`line'"
	if "`1'" == "Deviance" {
		global devstat = `3'
		local dfline = `linenum' + 1
	}
	if `dfline' == `linenum' {
		global dfstat = `6'
	}
	file read `fh' line
}

end
