*! version 1.1.0  Ben Jann  28apr2011
program define rrlogit_p
	version 6, missing

	syntax [anything] [if] [in] [, SCores * ]
	if `"`scores'"' != "" {
        global rrlogit_pw "`e(pwarner)'"
        global rrlogit_p1 "`e(pyes)'"
        global rrlogit_p2 "`e(pno)'"
		ml_score `0'
        global rrlogit_pw
        global rrlogit_p1
        global rrlogit_p2
		exit
	}

		/* Step 1:
			place command-unique options in local myopts
			Note that standard options are
			LR:
				Index XB Cooksd Hat
				REsiduals RSTAndard RSTUdent
				STDF STDP STDR CONstant(varname)
			SE:
				Index XB STDP CONstant(varname)
		*/
	local myopts "Pr"

		/* Step 2:
			call _propts, exit if done,
			else collect what was returned.
		*/
	_pred_se "`myopts'" `0'
	if `s(done)' { exit }
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'


		/* Step 3:
			Parse your syntax.
		*/
	syntax [if] [in] [, `myopts' noOFFset]

	if "`pr'"=="" {
		di in gr "(option p assumed; Pr(`e(depvar)'))"
	}
	qui _predict double `vtyp' `varn' `if' `in', `offset' xb
	qui replace `varn' =  invlogit(`varn')
	label var `varn' "Pr(`e(depvar)')"
end
