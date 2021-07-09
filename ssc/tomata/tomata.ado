*! version 1.0.1  12jun2006
*! -- William Gould, StataCorp
program tomata
	version 9
	syntax [varlist] [if] [in], [noMissing]

	/* ------------------------------------------------------------ */
	local hastouse 0
	if (`"`if'"'!="") {
		local hastouse 1
	}
	if ("`missing'"!="") {
		local hastouse 1
	}
	if (`hastouse') {
		if ("`missing'"!="") {
			marksample touse, strok
		}
		else {
			marksample touse, novarlist
		}
		capture assert `touse' `in'
		if (_rc==0) {
			local hastouse 0
		}
	}

	/* ------------------------------------------------------------ */
	if "`in'"!="" {
		local hasin 1
		process_in "`in'"
		local obs = "(`r(first)',`r(last)')"
	}
	else	local hasin 0

	/* ------------------------------------------------------------ */
	foreach var of local varlist {
		capture confirm numeric var `var'
		local cmd = cond(_rc, "st_sview", "st_view")

		if (`hasin' & `hastouse') {
			mata: `cmd'(`var'=., `obs', "`var'", "`touse'")
		}
		else if (`hasin') {
			mata: `cmd'(`var'=., `obs', "`var'")
		}
		else if (`hastouse') {
			mata: `cmd'(`var'=., ., "`var'", "`touse'")
		}
		else {
			mata: `cmd'(`var'=., ., "`var'")
		}
	}
end

program process_in, rclass
	args in

	gettoken in    rest : in,   parse(" /")
	gettoken first rest : rest, parse(" /")
	gettoken slash rest : rest, parse(" /")
	gettoken last  rest : rest, parse(" /")

	if "`rest'" != "" {
		in_invalid "`in'"
		exit 198
	}
	process_in_obsno "`first'" "`in'"
	local rfirst = r(obs)
	local rlast  = r(obs)

	if ("`slash'") != "" {
		if ("`slash'"!="/") {
			in_invalid "`in'"
		}
		process_in_obsno "`last'" "`in'"
		local rlast = r(obs)
	}
	return local first "`rfirst'"
	return local last  "`rlast'"
end



program process_in_obsno, rclass
	args obsno in

	if ("`obsno'"=="f") {
		local obsno = 1
	}
	else if ("`obsno'"=="l") {
		local obsno = _N
	}

	local obs = real("`obsno'")
	if (`obs' >= .) {
		in_invalid "`in'"
	}

	if (`obs' < 0) {
		local obs = _N - `obs' + 1
	}
	if (`obs' < 1 | `obs' > _N) {
		di as err "Obs. nos. out of range"
		exit 198
	}
	return local obs = `obs'
end
		
program in_invalid
	args in

	di as err "`in' invalid"
	exit 198
end
