*! version 2.0 April 15, 2008 @ 21:12:35
*! Author: Roger Harbord, University of Bristol
	
	/* predictions from metandi using gllapred */

program define metandi_p, eclass sortpreserve
	syntax newvarlist(min=1 max=2) [if] [in] [, u sdu ustd mu Linpred COoksd]

	capture assert e(cmd) == "metandi"
	if _rc !=0 {
		di as error "Last estimation command was not metandi"
		error 301
		}

	if `: word count `u' `sdu' `ustd' `mu' `linpred' `cooksd'' > 1 {
		di as err "Only one option can be specified"
		error 198 // invalid syntax
		}

	local metandiopts "`u'`sdu'`ustd'"
	if "`metandiopts'`mu'`linpred'`cooksd'" == "" {
		di as txt "(option mu assumed; posterior predicted Se & Sp)"
		local mu mu
		}
	local allopts "`metandiopts'`mu'`linpred'`cooksd'"

	if e(method) == "xtmelogit" &  "`cooksd'" != "" {
		di as error "cooksd available only if option gllamm used with metandi"
		exit 198
		}
	
	// parse the newvarlist, allow <var_sens var_spec> or <stub>
	tokenize `varlist'
	if "`cooksd'" != "" { // only 1 newvar needed
		if "`2'" != "" {
			di as error "Only one newvar required for Cook's distance"
			exit 198 // invalid syntax
			}
		else local var1 `1'
		}
	else {                                    // other options need 2 newvars
		if "`2'" != "" {  // 2 vars given
			local var1 `1'
			local var0 `2'
			}
		else {           // 1 var given; treat as stub
			local var1 `1'1
			local var0 `1'0
			}
		}
	confirm new var `var1' `var0'

	tokenize `typlist'
	local typ `1'  // ignore second type

	
	tempvar touse
	mark `touse' // don't use marksample as varlist is a newvarname
	
	tokenize `e(tpfpfntn)'
	local true1  `1'
	local false0 `2'
	local false1 `3'
	local true0  `4'

	/** end parsing **/

	preserve
	qui ds
	local vars `r(varlist)'
	local method `e(method)'
	tempvar esamp
	gen byte `esamp' = e(sample)
	tempname metandi
	_estimates hold `metandi', restore
	_estimates unhold _metandi
	
	/** reshape data to long format  **/
	qui {
		gen long _metandi_i = _n
		gen long _metandi_n1 = `true1' + `false1' 
		gen long _metandi_n0 = `true0' + `false0' 
		gen long _metandi_true1 = `true1' 
		gen long _metandi_true0 = `true0'

		/* d1 is diseased (sensitivity) d0 is nondiseased (specificity) */
		reshape long _metandi_n _metandi_true, i(_metandi_i) j(_metandi_d1)
		sort _metandi_i _metandi_d1
		gen byte _metandi_d0 = 1 - _metandi_d1 

		} // end quietly

	ereturn repost, esample(`esamp')

	if "`method'" == "gllamm" {

		if "`metandiopts'" == "" {
			if "`cooksd'" != "" ///
			  di as txt "(Cook's distance may take a few seconds...)"
			qui gllapred _metandi_p if `touse', `mu' `linpred' `cooksd'
			qui recast `typ' _metandi_p, force
			}

		if "`u'`sdu'`ustd'" != "" {
			if "`u'`sdu'" != "" qui gllapred _metandi_p if `touse', u
			else                qui gllapred _metandi_p if `touse', ustd
			qui {
				if "`u'`ustd'" != "" {
					gen `typ' _metandi_p = _metandi_pm1 if _metandi_d1 
					replace    _metandi_p = _metandi_pm2 if _metandi_d0
					}
				else { // sdu
					gen `typ' _metandi_p = _metandi_ps1 if _metandi_d1
					replace    _metandi_p = _metandi_ps2 if _metandi_d0
					}
				drop _metandi_pm1 _metandi_pm2 _metandi_ps1 _metandi_ps2
				}
			}
		}   // endif e(method) == "gllamm"

	
	else { // xtmelogit


		if "`mu'" != "" {
			predict `typ' _metandi_p if `touse', mu  // gives mean = n * p
			qui replace _metandi_p = _metandi_p / _metandi_n
			}

		if "`u'" != "" {
			tempvar u1 u0
			predict `typ' `u1' `u0' if `touse', reffects
			gen `typ' _metandi_p = _metandi_d1 * `u1' + _metandi_d0 * `u0'
			}

		if "`sdu'" != "" {
			tempvar sdu1 sdu0
			predict `typ' `sdu1' `sdu0' if `touse', reses
			gen `typ' _metandi_p = _metandi_d1 * `sdu1' + _metandi_d0 * `sdu0'
			}

		if "`ustd'" != "" {
			tempvar u1 u0 sdu1 sdu0
			predict `typ' `u1' `u0' if `touse', reffects
			predict `typ' `sdu1' `sdu0' if `touse', reses
			gen `typ' _metandi_p =  ///
			  _metandi_d1 * `u1' / sqrt(exp(2 * [lns1_1_1]_b[_cons]) - `sdu1'^2) + ///
			  _metandi_d0 * `u0' / sqrt(exp(2 * [lns1_1_2]_b[_cons]) - `sdu0'^2)
			}

		if "`linpred'" != "" {
			tempvar u1 u0
			predict `typ' `u1' `u0' if `touse', reffects
			gen `typ' _metandi_p = _metandi_d1 * ( _b[_metandi_d1] + `u1')  ///
			  /* */              + _metandi_d0 * ( _b[_metandi_d0] + `u0')
			}

		} // end xtmelogit
	

	drop _metandi_d0 _metandi_n _metandi_true
	qui gen byte `esamp' = e(sample)
	qui reshape wide _metandi_p, i(_metandi_i) j(_metandi_d1)
	ereturn repost, esample(`esamp')
	rename _metandi_p1 `var1'
	if  "`cooksd'" != "" { // only 1 newvar
		label var `var1' "`allopts'"
		}
	else { // not cooksd so 2 newvars
		label var `var1' "Se: `allopts'"
		rename _metandi_p0 `var0'
		label var `var0' "Sp: `allopts'"
		}
	drop _metandi_*
	order `vars' `var1' `var0' // move added vars to end
	
	restore, not // cancel restore
	_estimates hold _metandi
   drop _metandi // already stored in e(sample) for metandi results

end
