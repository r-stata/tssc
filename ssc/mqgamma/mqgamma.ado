!version 2.0.0  02Jun2014
program define mqgamma, eclass
	version 13.1

	local cmdline `"teffects `0'"'
        local cmdline: list retokenize cmdline

	gettoken proc rest : 0, parse(" ,")
        local replay = (("`proc'"==""|"`proc'"==",") & "`e(cmd)'"== "mqgamma")

	if (`replay') {
		Display `0'
		exit
	}


	syntax varlist(numeric min=1) 		///
		[if] [in] 			///
		,				///
		treat(varname)			///
		[				///
		Quantile(numlist >0 <1 sort)	///
		fail(varname)			///
		lns(varlist)			///
		AEQuations			///
		from(string)			///
		*				///
		]

	_get_diopts diopts rest, `options' winitial(identity)
	
	 _teffects_gmmopts, `rest'
        local gmmopts `s(gmmopts)'
        local rest `s(rest)'

	if "`rest'" != "" {
		di in red "option `rest' invalid"
		exit 498
	}

	gettoken depvar shape : varlist
	marksample touse 
	markout `touse' `lns'	`treat' `fail'

	// check that treat variable is 0 or 1
	tempvar check1
	quietly generate byte `check1' = cond(`treat'==0, 1, `treat'==1)
	quietly count if `check1' != 1
	if (r(N)>0) {
		display in red "`treat' has observations that are not 0 or 1."
		exit 498
	}

	drop `check1'
	if ("`fail'" != "") {
		quietly generate byte `check1' = cond(`fail'==0, 1, `fail'==1)
		quietly count if `check1' != 1
		if (r(N)>0) {
			display in red "`fail' has observations that "	///
				"are not 0 or 1."
			exit 498
		}
	}

	tempvar cons
	quietly generate double `cons' = 1
	local shapenames `shape' _cons
	local shape `shape' `cons'

	local lnsnames `lns' _cons
	local lns `lns' `cons'

	if "`quantile'" == "" {
		local quantile .5
		local qnames q50
		local qparms q50_0:_cons q50_1:_cons
		local qeqs  q50eq0 q50eq1
		local nq = 2
	}
	else {
		local nq : word count `quantile'
		local nq = `nq'*2
		foreach q of local quantile {
			local centile = 100*`q'
			local qname   : subinstr local centile "." "_"
			local qnames  `qnames' q`qname'
			local qparms  `qparms' q`qname'_0:_cons q`qname'_1:_cons
			local qeqs    `qeqs' q`qname'eq0 q`qname'eq1
		}
	}

	local meqs zeq0 lnseq0 zeq1 lnseq1 `qeqs'
	mata: QTEG_eqnames("z_0:",   "`shapenames'", "z0parms",   "nz0")
	mata: QTEG_eqnames("z_1:",   "`shapenames'", "z1parms",   "nz1")
	mata: QTEG_eqnames("lns_0:", "`lnsnames'", "lns0parms", "nlns0")
	mata: QTEG_eqnames("lns_1:", "`lnsnames'", "lns1parms", "nlns1")

	local parameters  `qparms' `z0parms' `lns0parms' `z1parms' `lns1parms'

	local np = `nz0' + `nz1' + `nlns0' + `nlns1' + `nq' 

	if "`from'" != "" {
		local from "from(`from')"
	}
	else {
		tempname b0
		matrix `b0' = J(1, `np', .15)
		local from "from(`b0')"
	}


	gmm gmm_mqg, 							///
		equations(`meqs')					///
		parameters(`parameters')				///
		onestep quickderivatives 				///
		instruments(zeq0: `shape', noconstant) 			///
		instruments(lnseq0: `lns', noconstant) 			///
		instruments(`qeqs' : ) 					///
		instruments(zeq1: `shape', noconstant) 			///
		instruments(lnseq1: `lns', noconstant) 			///
		depvar(`depvar')					///
		shapevars(`shape') 					///
		z0parms(`z0parms')					///
		z1parms(`z1parms')					///
		lns0parms(`lns0parms')					///
		lns1parms(`lns1parms')					///
		qparms(`qparms')					///
		qnames(`qnames')					///
		quantile(`quantile')					///
		lnsvars(`lns')	 					///
		fail(`fail')						///
		treat(`treat') 						///
		np(`np')						///
		`from'							///
		`gmmopts'						///
		touse(`touse')						///
		iterlogonly

	tempname b V Q

	matrix  `b' = e(b)
	matrix  `V' = e(V)
	local    N  = e(N)
	scalar `Q'  = e(Q)
	local converged = e(converged)


	ereturn post `b' `V', depname(`depvar') obs(`N') 	///
		esample(`touse') 
	
	ereturn local cmdline "`cmdline'"
	ereturn local quantile "`quantile'"
	ereturn local predict "mqgamma_p"		// !!
	ereturn local title   "Gamma marginal quantile estimation"
	ereturn local vce     "robust"
	ereturn local vcetype "Robust"

	ereturn scalar converged  = `converged'
	ereturn scalar      k_eq  = `nq'
	ereturn scalar   k_quant  = `nq'

	ereturn local cmd         "mqgamma"

	Display , `aequations' `diopts'

end

program define Display
	version 13.1 

	syntax , [ AEQuations * ]
	_get_diopts diopts, `options'

	if "`aequations'" != "" {
		local neq = e(k_quant) + 4
	}
	else {
		local neq = e(k_quant)
	}

	di as txt _n "`e(title)'"       ///
                "{col 49}Number of obs {col 68}=" as res %10.0f e(N)


	_coef_table, neq(`neq') `diopts'

end

mata:
void QTEG_eqnames(string scalar eqname,		///
	string scalar plist, 			///
	string scalar mname,			///
	string scalar npmacro			///
	)
	{

	real   scalar	i, p
	string vector	pnames
	string scalar 	nlist

	vnames = tokens(plist)
	p      = cols(vnames)
	for(i=1; i<=p; i++) {
		nlist = nlist + eqname + vnames[1,i] + " "
	}
	st_local(mname, nlist)
	st_local(npmacro, strofreal(p))

	
}

end
