/* program that ml fits Zipf's law and the Zipf Mandelbrot law in terms of a
right-truncated zeta distribution. 
I used the paretofit.ado written by Stephen P. Jenkins & Philippe Van Kerm
as a blueprint for some code lines and especially the help file (cf. help paretofit).
*/

capture program drop zipffit
program zipffit, eclass byable(recall)
version 12.1
syntax varname [if], [ ///
	ZMand Rank(numlist) 	///
	log												///
	* ]

quietly {
preserve
tempvar touse
mark `touse' `if'
mlopts mlopts, `options'
keep if `touse'
capture drop MLfreqML
capture drop MLrankML

gen MLfreqML=`varlist'

egen MLrankML=rank(-MLfreqML), unique
if "`rank'"!="" {
	keep if MLrankML<=`rank' 
}

if "`log'"=="" {
	local nolog nolog
}
else {
	local nolog
}

sum MLfreqML
local types=r(N)
local tokens=r(sum)
if "`zmand'"=="" {
			local title "ML fit of Zipf distribution (tokens: `tokens' / types: `types')"
			ml model lf zipf (alpha: )
			noisily ml maximize,  ///
			`nolog' title(`title') showeqns ///
			search(on) ///
			`mlopts'
			mat pred=r(table)
			ereturn scalar zalpha=pred[1,1]
			ereturn scalar types=`types'
			ereturn scalar tokens=`tokens'					
}
else {
if "`zmand'"!="" {
			local title "ML fit of Zipf-Mandelbrot distribution (tokens: `tokens' / types: `types')"
			ml model lf zipf_mandelbrot (alpha: ) (beta: )
			noisily ml maximize,  ///
			`nolog' title(`title')  showeqns ///
			search(on) ///
			`mlopts'
			mat pred=r(table)
			ereturn scalar zmalpha=pred[1,1] 
			ereturn scalar zmbeta=pred[1,2] 
			ereturn scalar types=`types'
			ereturn scalar tokens=`tokens'											  				
}
}
restore
}
end
exit
Alexander Koplenig, IDS Mannheim/Germany

Revision history

26 July 2014 	first version
28 July 2014 	cosmetic changes + 
							account for the situation when a variable called "rank" already exists
