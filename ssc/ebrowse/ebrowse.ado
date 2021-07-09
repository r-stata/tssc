*! version 1.01  14apr2010  Markus H. Hahn  /  mhahn@unimelb.edu.au

program define ebrowse
	version 9
	syntax [varlist] [if] [in], [NOLabel]

	if (_caller()>=11) {
		local varlist: list uniq varlist
		local nvars: word count `varlist'
		if (`nvars'==c(k)) { // if (varlist==_all) no ordering
			browse `varlist' `if' `in', `nolabel'
		}
		else {
			preserve
			order `varlist'
			browse `varlist' `if' `in', `nolabel'
			di "{stata clicked:Press <ENTER> or <CLICK> on blue text to continue}" _request(pause_stata)
			restore
		}
	}
	else {
		browse `varlist' `if' `in', `nolabel'
	}
end

