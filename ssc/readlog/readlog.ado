program define readlog
*! 1.0.0 6 June 2000 Jan Brogger

	version 6.0
	syntax , logfil(string)  [all(string) start(string) stop(string) spaces del]

	preserve
	drop _all
	tempvar log
	infix str `log'  1-80 using `"`logfil'"'
	format `log' %-80s
	keep if ~missing(`log') 

	tempvar ln
	gen `ln'=_n
	local to=`ln'[1]
	local from=`ln'[_N]
	local intxt=0
	local lin_n=1

	if (("`start'" ~= "" & "`stop'"=="") | ("`stop'" ~= "" & "`start'"=="")) {
		display "Must specify both start and stop, not only one of them."
		exit(1)
	}

	while (`lin_n' <= `from') {				/*go through all the lines */

		local lin_s = `log'[`lin_n']
		if (`intxt'==0) {						/* start intxt=0, looking for starttext */
			if (`"`start'"' ~= "" & index(`"`lin_s'"',`"`start'"')>0) {		/* start starttext found */
				local intxt=1

				if (`"`spaces'"' ~= "" & length(`"`lin_s'"')>1) {
					spaces , s(`"`lin_s'"') 
					local lin_s=`"`r(s)'"'
				}
				display `"`lin_s'"'
			}									/* end starttext found */

			if (index(`"`lin_s'"',`"`all'"')>0) {		/* echo all lines with all in it */

				if (`"`spaces'"' ~= "" & length(`"`lin_s'"')>1) {
					spaces , s(`"`lin_s'"') 
					local lin_s=`"`r(s)'"'
				}

				display `"`lin_s'"'
			}									

		}									/* end intxt=0 */
		else {								/* start intxt=1, looking for stoptext */
			if (`"`stop'"' ~= "" & index(`"`lin_s'"',`"`stop'"')>0) {		/* start stoptext found */
				local intxt=0
			}									/* end stoptext found */
			else {

				if (`"`spaces'"' ~= "" & length(`"`lin_s'"')>1) {
					spaces , s(`"`lin_s'"') 
					local lin_s=`"`r(s)'"'
				}

				display `"`lin_s'"'			/* stoptext not found, echo line */
			}
		}									/* end intxt=0 */

		local lin_n = `lin_n'+1
	} 									/*while */

	if (`"`del'"' ~= `""') {
		erase `"`logfil'"'
	}

	restore
end
