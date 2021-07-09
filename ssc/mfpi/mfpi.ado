*! version 3.0.0 PR 19apr2012
program define mfpi, eclass
	version 11.0
	local cmdline : copy local 0
	mata: _parse_colon("hascolon", "rhscmd")
	if !`hascolon' error 198

	_mfpi `"`0'"' `"`rhscmd'"'

	ereturn local cmdline `"mfpi `cmdline'"'
end

program define _mfpi, rclass
version 11.0
args 0 statacmd

gettoken cmd statacmd: statacmd
if substr("`cmd'", -1, .) == "," {
	local cmd = substr("`cmd'", 1, length("`cmd'") - 1)
	local statacmd ,`statacmd'
}
xfrac_chk `cmd'
if `s(bad)' { 
	di as err "invalid or unrecognised command, `cmd'"
	exit 198
}
local dist `s(dist)'
local normal = (`dist'==0)
global MFpdist `dist'

// Determine if constant is needed (used in genf() option)
if !inlist("`cmd'", "stcox", "cox", "clogit") local cons constant

// Parse mfpi options from first argument
/*
	Hidden option `adjbin' adjusts for treatment variable
	in adjustment model. Won't make much difference in randomised controlled
	trials, but may be important in observational data. To be discussed.

	Flexibility (flex()): 1 = least (Royston & Sauerbrei 2004),
	2 = intermediate (same powers for main effect and interaction, determined for interaction), 
	3 = intermediate (allow different powers for main effect and interaction),
	4 = most (allow different powers in each group and for main effect).
*/
syntax [if] [in] [aw fw pw iw] [, ///
  SELect(string) ADDpowers(string) ADJust(varlist fv) ADJBin all ALpha(string) CEnter(passthru) ///
  CENTer(varlist) DEAD(varname) DETail DF(string) FLex(int 1) FP1(varlist) FP2(varlist) ///
  GENF(string) GENDiff(string) LINear(string) OUTcome(string) POWers(string) noSCAling ///
  noCI SHOwmodel TReatment(varname fv) WITH(varname fv) ZERo(string) MFPopts(string) ]

// Process mfpi options
if "`with'" != "" {
	if "`treatment'" != "" {
		di as err "cannot have both treatment() and with() - they are synonyms"
		exit 198
	}
	local treatment `with'
}
else local with `treatment'
fvexpand `with'
if "`r(fvops)'" == "" {
	local with i.`with'
	fvexpand `with'
	if "`r(fvops)'" == "" {
		di as err "treatment() must be a factor or categoric variable"
		exit 198
	}
	di as txt "[treating `treatment' as a factor variable, `with']"
}
// `With' is `with' stripped of its factor prefix
local With = substr("`with'", 1 + strpos("`with'", "."), .)

if "`linear'`fp1'`fp2'"=="" {
	di as err "you must specify covariate(s) for interaction with `with'"
	exit 198
}
if "`cmd'" == "mlogit" & "`genf'`gendiff'" != "" {
	if `"`outcome'"' == "" {
		noi di as err "you must specify outcome() with genf() and/or gendiff()"
		exit 198
	}
}
// Store original lists of variables for interaction analysis with linear, FP1, FP2 models
local Linear `linear'
local Fp1 `fp1'
local Fp2 `fp2'
if "`powers'"=="" local powers -2 -1 -0.5 0 0.5 1 2 3
tokenize `powers' `addpowers'
local i 1
while "``i''"!="" {
	local p`i' ``i''
	local ++i
}
local np = `i' - 1
if ("`detail'" != "") local noi noi
local powers powers(`powers' `addpowers')
local items 0	/* overall number of interactions considered */
if "`linear'"!="" {
	// Sort out bound partners
	local lsep "("
	local rsep ")"
	tokenize `linear', parse(" `lsep'`rsep'")
	local linear
	local lparen 0
	local cat
	local ncat 0
	while "`1'"!="" {
		if "`1'"=="`lsep'" {
			if `lparen' {
				noi di as err "unexpected `lsep' in linear()"
				exit 198
			}
			local lparen 1
		}
		else if "`1'"=="`rsep'" {
			if `lparen'==0 {
				noi di as err "unexpected `rsep' in linear()"
				exit 198
			}
			local ++ncat
			fvunab iz`ncat': `cat'
			fvexpand `iz`ncat''
			local isfactor`ncat' = ("`r(fvops)'" == "true")
			local linear `linear' `iz`ncat''
			local ifp`ncat' 0	/* ifp=0 indicates linear term */
			local cat
			local lparen 0
		}
		else {
			if `lparen'==0 {
				local ++ncat
				fvunab iz`ncat': `1'
				fvexpand `iz`ncat''
				local isfactor`ncat' = ("`r(fvops)'" == "true")
				local linear `linear' `iz`ncat''
				local ifp`ncat' 0
			}
			else local cat `cat' `1'
		}
		mac shift
	}
	if `lparen' {
		noi di as err "unexpected `rsep' in linear()"
		exit 198
	}
	local items `ncat'
}

// Check validity of linear items
forvalues i = 1 / `items' {
	if `isfactor`i'' & wordcount("`iz`i''") > 1 {
		noi di as err "not allowed to bind a factor variable to another variable"
		exit 198
	}
	local nz: word count `iz`i''
	forvalues j = 1 / `nz' {
		local zz: word `j' of `iz`i''
		if ("`zz'" == "`With'") | ("`zz'" == "`with'") {
			noi di as err "cannot interact a treatment variable with itself"
			exit 198
		}
	}
}
if "`fp1'"!="" {
	local nfp1: word count `fp1'
	forvalues i = 1/`nfp1' {
		local ++items
		local iz`items': word `i' of `fp1'
		if "`iz`items''" == "`With'" {
			noi di as err "cannot interact a treatment variable with itself"
			exit 198
		}
		local ifp`items' 1
	}
}
if "`fp2'"!="" {
	local nfp2: word count `fp2'
	forvalues i = 1/`nfp2' {
		local ++items
		local iz`items': word `i' of `fp2'
		if "`iz`items''" == "`With'" {
			noi di as err "cannot interact a treatment variable with itself"
			exit 198
		}
		local ifp`items' 2
	}
}

// Parse to extract varlist (as `xlist') from statacmd
local 0 `statacmd'
syntax [anything(name=xlist)] [if] [in] [aw fw pw iw] [, DEAD(str) noCONStant * ]
if !missing("`dead'") local options `options' dead(`dead')
if !missing("`constant'") local options `options' `constant'
/* if ("`xlist'" != "") */ GetVL `xlist'

marksample touse
markout `touse' `yvar' $MFP_cur `with' `linear' `fp1' `fp2' `adjust' `dead'
frac_wgt "`exp'" `touse' "`weight'"
local wgt `r(wgt)'	// [`weight'`exp']
local yvar $MFP_dv
local xvars
forvalues i = 1 / $MFP_n {
	local mfp`i' ${MFP_`i'}
	local w : word count `mfp`i''
	if (`w' > 1) local xvars `xvars' (`mfp`i'')
	else local xvars `xvars' `mfp`i''
}
if ("`all'" == "") local ifuse if `touse'
else local restrict restrict(if `touse')

// Remove `with' variable from xvars, if it was there
local Xvars: list xvars - with
local Xvars: list xvars - With
quietly {
	levelsof `With', local(levels)
	local nlevels : word count `levels'
	if `nlevels' < 2 {
		di as err "`with' must have at least two levels"
		exit 198
	}
	forvalues i = 1 / `nlevels' {
		local level`i' : word `i' of `levels'
	}
	count if `touse'
	local nobs = r(N)
	local nxvar: word count `Xvars'
	if `nxvar' == 0 {
		if ("`select'" != "") & ("`adjust'" != "") noi di as txt "[select() ignored]"
	}
	else {
		if ("`select'" == "") local select 1

		// Find adjustment model for main covariates
		if ("`alpha'" != "") local Alpha alpha(`alpha')

		// Add treatment variable to adjustment model
		if "`adjbin'" != "" {
			local adjbin `with'
			local select `select', `adjbin':1
		}
		// Add adjust variables as linear terms in adjustment model
		if "`adjust'" != "" {
			if ("`df'" != "") local Df df(`df',`adjust':1)
			else local Df df(`adjust':1)
			local select `select', `adjust':1
		}
		else {
			if ("`df'" != "") local Df df(`df')
		}
		// Select adjustment model
		local Select select(`select')
		`noi' xmfp, `Select' `Alpha' `Df' `powers' `center' `scaling' `mfpopts' : ///
		 `cmd' `yvar' `Xvars' `adjust' `adjbin' `wgt' if `touse', `options' 
		if "`showmodel'"!="" {
			noi di as txt _n "Variables in adjustment model" _n "{hline 29}"
			if ("`adjust'" != "") noi di as txt "[`adjust': linear]"
			if ("`adjbin'" != "") noi di as txt "[`adjbin': `with']"
		}

		// Store details of selected adjustment model
		local nxf 0
		forvalues i = 1 / `nxvar' {
			local p `e(fp_k`i')'
			local x `e(fp_x`i')'
			if ("`showmodel'" != "") noi di as txt %10s "`x':" _cont
			if "`p'" != "." {
				if ("`showmodel'" != "") noi di as txt " power(s) = " as res "`p'"
				local ++nxf
				local x`nxf' `x'
				local fp`nxf' `p'
				local n`nxf' `e(fp_n`i')'
				local sel`i' 1
			}
			else {
				local sel`i' 0
				if ("`showmodel'" != "") noi di as txt " not selected"
			}
		}
	}
	local d3 79
	local flexmess = cond(`flex'==1, "(least flexible)", cond(`flex'==4, "(most flexible)", "(intermediate)"))
	noi di as txt _n "Interactions with `with' (" as res `nobs' ///
	 as txt " observations). Flex-`flex' model `flexmess'"
	noi di as txt _n "{hline `d3'}"
	noi di as txt "Var         Main        Interact     idf   Chi2     P     Deviance tdf   AIC"
	noi di as txt "{hline `d3'}"
	forvalues ni = 1 / `items' {
		local z `iz`ni''
		local nz: word count `z'	/* `z' could be a varlist */
		local degree `ifp`ni''		/* 0, 1 or 2; 0=linear */
/*
	Remove members of z from adjustment model varlist
	(note that `adjust' vars, if any, are not counted in nxvar)
*/
		local xvars
		if `nxvar' > 0 {
			local nxf 0
			forvalues j = 1 / `nxvar' {
				if `sel`j'' {
					local ++nxf
					// Check if x`nxf' is in the `z' list
					local in_z_list 0
					forvalues i = 1 / `nz' {
						local zi: word `i' of `z'
						if "`zi'" == "`x`nxf''" {
							local in_z_list 1
							continue, break
						}
					}
					if !`in_z_list' local xvars `xvars' `n`nxf''
				}
			}
		}
/*
	Deal with FP case
*/
		if `degree' > 0 {
			// Determine shift in z, if needed to avoid zeros.
			fracgen `z' 0 if `touse', nogen `scaling'
			local shift = r(shift)
			local scale = r(scale)
			// Local `iz' holds the name of the possibly shifted and scaled covariate
			local iz _`z'
			cap drop `iz'
			gen `iz' = (`z'+`shift')/`scale' `ifuse'
			if `shift' == 0 {
				if `scale' == 1 lab var `iz' "`z'"
				else lab var `iz' "`z'/`scale'"
			}
			else {
				if `scale' == 1 lab var `iz' "`z'+`shift'"
				else lab var `iz' "(`z'+`shift')/`scale'"
			}
/*
	Main-effects model.
	Determine powers for flex 1, 3 and 4 using fracpoly.
	Flex 2 uses main-effect powers from interaction model.
*/
			if `flex'==1 | `flex'==3 | `flex'==4 {
				xfracpoly, degree(`degree') `powers' center(no) `scaling': ///
				 `cmd' `yvar' `iz' `xvars' `adjust' `with' `wgt' if `touse', `options'
				local powmain `e(fp_pwrs)'
				if ("`powmain'" != "1") cap drop `e(fp_xp)'
			}
/*
	Interaction models
*/
			if `flex'==1 {
				// Use powers from main effect for main effect and interaction
				local powint `powmain'
			}
			else if `flex'==2 | `flex'==3 {
				// Determine interaction powers for flex 2 and 3.
				// Force powers to be the same for all levels (= `powint').
				local devbest 1e30
				forvalues j = 1/`np' {
					if `degree'==2 {
						forvalues j2 = `j'/`np' {
							fracgen `iz' `p`j'' `p`j2'' if `touse', replace `center' `scaling'
							`cmd' `yvar' `xvars' `adjust' `with' `with'#c.(`r(names)') `wgt' if `touse', `options'
							local devint = -2*e(ll)
							if `devint' < `devbest' {
								local devbest `devint'
								local powint `p`j'' `p`j2''
							}
						}
					}
					else {
						fracgen `iz' `p`j'', replace `center' `scaling'
						local v `r(names)'
						`cmd' `yvar' `xvars' `adjust' `with' `with'#c.`v' `wgt' if `touse', `options'
						local devint = -2*e(ll)
						if `devint' < `devbest' {
							local devbest `devint'
							local powint `p`j''
						}
					}
				}
				if (`flex' == 2) local powmain `powint'
			}
			else if `flex'==4 {
				local unvi	// names of untransformed z at each level
				forvalues i = 1 / `nlevels' {
					tempvar z`i'
					// `z`i'' is `iz' for level `i' of `with', 0 otherwise
					gen `z`i'' = cond(`With'==`level`i'', `iz', 0) `ifuse'
					local unvi `unvi' `z`i''
				}
				// Use mfp to determine possibly different powers (`powint`i'') at each level.
				if (`degree' == 2) local mfpdf df(1, `unvi':4)
				else local mfpdf df(1, `unvi':2)
				xmfp, select(1) alpha(1) `mfpdf' zero(`unvi') center(no) `scaling' : ///
				 `cmd' `yvar' `unvi' `xvars' `adjust' `with' `wgt' if `touse', `options'
				forvalues i = 1 / `nlevels' {
					local powint`i' `e(fp_k`i')' // estimated power(s) at each level
					local dropn`i' `e(fp_n`i')' // possibly FP-transformed `iz`i''
					local dropx`i' `e(fp_x`i')' // tempvar z`i'
				}
			}
		}
		else {
			// Linear case (includes binary and categorical).
			local powmain Linear
			local powint Linear
		}
		// Fit main-effects model
		if `degree' > 0 {
			fracgen `iz' `powmain' `ifuse', replace noscaling `restrict' `center' // ??? name(`z')
			local v `r(names)'
		}
		else { // Linear
			local v `z'
		}
		`noi' `cmd' `yvar' `xvars' `adjust' `with' `v' `wgt' if `touse', `options'
		local devmain = -2*e(ll)

		// Fit interaction model
		if `degree' > 0 {
			// Macro vi holds names of variables for interaction model;
			// components are vi1,...,vi`degree'
			local vi
			if `flex' <= 3 {
				fracgen `iz' `powint' `ifuse', replace noscaling `restrict' `center' // ??? name(`z')
				local vi `r(names)'
				forvalues j = 1 / `degree' {
					local vi`j' : word `j' of `vi'
				}
			}
			else { // flex = 4
				forvalues j = 1 / `degree' {
					cap drop `iz'`j'
					gen `iz'`j' = .
					local vi`j' `iz'`j'
					local vi `vi' `vi`j''
				}
				forvalues i = 1 / `nlevels' {
					fracgen `z`i'' `powint`i'' `ifuse', zero replace noscaling `restrict' `center'
					forvalues j = 1 / `degree' {
						local zij : word `j' of `r(names)'
						replace `iz'`j' = `zij' if `With' == `level`i'' // !! to be var labelled
						cap drop `zij'
					}
					cap drop `dropn`i''
					cap drop `dropx`i''
				}
			}
		}
		else local vi `z'
		`noi' `cmd' `yvar' `xvars' `adjust' `with' `with'#c.(`vi') `wgt' if `touse', `options'
		local devint = -2*e(ll)

		// Test interaction
		local k = e(k_eq_model)
		if (`k' == 0) | missing(`k') local k 1
		local ndum = `nlevels' - 1
		if `degree' > 0 { // FP
			local dfmain = `degree' + `k' * (`ndum' + `degree')
			local dfint = `k' * `ndum' * `degree' + (`flex'==4) * `ndum' * `degree'
		}
		else { // linear
			local dfmain = `k' * (`ndum' + `nz' )
			local dfint = `k' * `ndum' * `nz'
		}
		local dftot = `dfmain' + `dfint'
		local totaldf`degree' `dftot'
		local chi = `devmain' - `devint'
		local P = chiprob(`dfint', `chi')
/*
		Store details of test statistic for this variable.
		(Note: only details of last variable in list will be finally stored.)
*/
		local dfd`degree' `dfint'
		local chi2`degree' `chi'
		local P`degree' `P'
		local dev`degree' `devint'
		local aic`degree' = `devint'+2*`totaldf`degree''

		if (length("`z'") > 10) local showz = abbrev("`z'", 10)
		else local showz `z'
		if `degree'==0 {
			local term1 "Linear"
			local term2 "Linear"
		}
		else {
			local term1 "FP`degree'(`powmain')"
			if `flex'==4 {
				local starmess "* possibly more than one set of FP powers, shown for each level of `With'"
				local term2 "FP`degree'(`level1':`powint1')*"
			}
			else local term2 "FP`degree'(`powint')"
		}
		noi di as txt %-12s "`showz'" %-12s "`term1'" %-12s "`term2'" as res /*
		 */ %3s "`dfint'" %8.2f `chi' %9.4f `P' %10.3f `devint' %3.0f `totaldf`degree'' %10.3f `aic`degree''
		if `degree' > 0 & `flex' == 4 {
			forvalues i = 2 / `nlevels' {
				noi di as txt _col(25) "FP`degree'(`level`i'':`powint`i'')"
			}
		}
		if "`genf'`gendiff'"!="" {
/*
	Note that correct prediction depends on fitting
	interaction model last in the lines above this.
	Create full-sample versions of FP of z for prediction.
*/
			if "`cmd'" == "mlogit" {
				// Check for valid outcome category
				local eqn `"`e(eqnames)'"'
				if !`: list outcome in eqn' {
					noi di as err "`outcome' is not a valid outcome category for `yvar'"
					exit 198
				}
			}
			if `degree' > 0 {
				// Create FP variables required for prediction, their names in macros FP*
				local Izdrop
				forvalues i = 1 / `nlevels' {
					if `flex' <= 3 {
						if `i' == 1 {
							fracgen `iz' `powint' `ifuse', replace noscaling `restrict' `center' name(Iz`i')
							local Izdrop `r(names)'
						}
					}
					else {
						fracgen `iz' `powint`i'' `ifuse', replace noscaling `restrict' `center' name(Iz`i')
						local Izdrop `Izdrop' `r(names)'
					}
					forvalues j = 1 / `degree' {
						local FP`i'`j' : word `j' of `r(names)'
						if (`i' == 1) local prefix`j' c
					}
				}
				local nterms `degree'
			}
			else {
				// Store quantities for linear covariate(s)
				if `isfactor`ni'' { // linear term is a factor
					local Z = substr("`z'", 1 + strpos("`z'", "."), .)
					levelsof `Z', local(Zlevels)
					local nZ : word count `Zlevels'
					forvalues j = 1 / `nZ' {
						local lev : word `j' of `Zlevels'
						forvalues i = 1 / `nlevels' {
							local FP`i'`j' `lev'.`Z'
							if (`i' == 1) {
								local prefix`j' `lev'
								local vi`j' `Z'
							}
						}
					}
					local nterms `nZ'
				}
				else { // linear term is assumed continuous
					forvalues i = 1 / `nlevels' {
						forvalues j = 1 / `nz' {
							local FP`i'`j' : word `j' of `z'
							if (`i' == 1) {
								local vi`j' `FP`i'`j''
								local prefix`j' c
							}
						}
					}
					local nterms `nz'
				}
			}
			local ned = -invnormal((100 - c(level)) / 200)
			if "`genf'" != "" {
				forvalues i = 1 / `nlevels' {
					local lev `level`i''
					// !! to check next line manually in example
					if ("`cons'" != "") {
						local predict`i' _b[_cons]+_b[`lev'.`With']
					}
					else local predict`i' _b[`lev'.`With']
					forvalues j = 1 / `nterms' {
						local predict`i' `predict`i'' +_b[`lev'.`With'#`prefix`j''.`vi`j'']*`FP`i'`j''
					}
					cap drop `genf'`ni'_`i'
					if "`ci'" != "noci" {
						cap drop `genf'`ni's_`i'
*noi di in red "i=`i' predict=`predict`i''"
						predictnl `genf'`ni'_`i' = `predict`i'' `ifuse', se(`genf'`ni's_`i')
						cap drop `genf'`ni'lb_`i'
						cap drop `genf'`ni'ub_`i'
						gen `genf'`ni'lb_`i' = `genf'`ni'_`i'-`ned'*`genf'`ni's_`i'
						gen `genf'`ni'ub_`i' = `genf'`ni'_`i'+`ned'*`genf'`ni's_`i'
						lab var `genf'`ni'lb_`i' "lower conf limit: `genf'`ni'_`i'"
						lab var `genf'`ni'ub_`i' "upper conf limit: `genf'`ni'_`i'"
					}
					else predictnl `genf'`ni'_`i' = `predict`i'' `ifuse'
				}
			}
			if "`gendiff'"!="" {
				// Predict f(level i) - f(base level)
				forvalues i = 2 / `nlevels' {
					local i1 = `i' - 1
					local lev `level`i''
					local predict`i' _b[`lev'.`With']-_b[`level1'.`With']
					forvalues j = 1 / `nterms' {
						local predict`i' `predict`i'' ///
						 +_b[`lev'.`With'#`prefix`j''.`vi`j'']*`FP`i'`j'' ///
						 -_b[`level1'.`With'#`prefix`j''.`vi`j'']*`FP1`j''
					}
					cap drop `gendiff'`ni'_`i1'
					if "`ci'" != "noci" {
						cap drop `gendiff'`ni's_`i1'
						cap drop `gendiff'`ni'lb_`i1'
						cap drop `gendiff'`ni'ub_`i1'
						predictnl `gendiff'`ni'_`i1' = `predict`i'' `ifuse', se(`gendiff'`ni's_`i1')
						gen `gendiff'`ni'lb_`i1' = `gendiff'`ni'_`i1'-`ned'*`gendiff'`ni's_`i1'
						gen `gendiff'`ni'ub_`i1' = `gendiff'`ni'_`i1'+`ned'*`gendiff'`ni's_`i1'
						lab var `gendiff'`ni'lb_`i1' "lower conf limit: `gendiff'`ni'_`i1'"
						lab var `gendiff'`ni'ub_`i1' "upper conf limit: `gendiff'`ni'_`i1'"
					}
					else predictnl `gendiff'`ni'_`i1' = `predict`i'' `ifuse'
				}
			}
			cap drop `Izdrop'
		}
	}
}
di as txt "{hline `d3'}" ///
 _n "idf = interaction degrees of freedom; tdf = total model degrees of freedom"
if ("`starmess'" != "") di as txt "`starmess'"
if "`showmodel'" != "" & "`detail'" == "" {
	if ("`yvar'" != "") local yvar4 " for `yvar'"
	local mess Last-fitted interaction model`yvar4':
	di as txt _n "`mess'"
	if ("`cmd'" == "stcox") `cmd', nohr
	else `cmd'
}
return local if `if'
return local in `in'
return local varlist `varlist'
return local dead `dead'
return local treatment `treatment'
return local with `treatment'
/*
	Store details of interaction test(s) for final variable
	in each list (linear, fp1, fp2)
*/
if "`Linear'"!="" {
	return local Linear `Linear'
	return scalar chi2lin = `chi20'
	return scalar Plin = `P0'
	return scalar devlin = `dev0'
	return scalar aiclin = `aic0'
	return scalar totdflin = `totaldf0'
}
if "`Fp1'"!="" {
	return local Fp1 `Fp1'
	return scalar chi2fp1 = `chi21'
	return scalar Pfp1 = `P1'
	return scalar devfp1 = `dev1'
	return scalar aicfp1 = `aic1'
	return scalar totdffp1 = `totaldf1'
}
if "`Fp2'"!="" {
	return local Fp2 `Fp2'
	return scalar chi2fp2 = `chi22'
	return scalar Pfp2 = `P2'
	return scalar devfp2 = `dev2'
	return scalar aicfp2 = `aic2'
	return scalar totdffp2 = `totaldf2'
}
if ("`gendiff'" != "") char _dta[gendiff] `gendiff'
else char _dta[gendiff]
char _dta[treatment] `With'

return local adjust `adjust'
return local z `z'
if "`z'"!="" {
	return local powmain `powmain'
	if `flex'==4 {
		forvalues i = 1 / `nlevels' {
			return local powint`i' `powint`i''
		}
	}
	else return local powint `powint'
}
return scalar nxvar = `nxvar'		
if `nxvar' > 0 {
	// save FP adjustment model details
	forvalues i = 1/`nxf' {
		return local x`i' `x`i''
		return local power`i' `fp`i''
	}
	return scalar nxf = `nxf'
}
end

program define ChkDepvar
	args xlist colon spec

	gettoken depvar spec : spec, parse("()") match(par)
	if ("`par'"!="") {
		di as err "invalid syntax"
		exit 198
	}
	fvunab depvar : `depvar'
	gettoken depvar rest : depvar
	global MFP_dv $MFP_dv `depvar'
	c_local `xlist' `rest' `spec'
end

program define GetVL /* [y1 [y2]] xvarlist [(xvarlist)] ... */
	macro drop MFP_*

	local xlist `0'
	if $MFpdist != 7 {
		ChkDepvar xlist : `"`xlist'"'
		if $MFpdist == 8 { /* intreg */ 
			ChkDepvar xlist : `"`xlist'"'
		}
	}
	if (`"`xlist'"'=="") {
		*error 102
		global MFP_n 0
		exit
	}
	gettoken xvar xlist : xlist, parse("()") match(par)
	while (`"`xvar'"'!="" & `"`xvar'"'!="[]") {
		fvunab xvar : `xvar'
		local nvar : word count `xvar'
		if ("`par'"!="" | `nvar'==1) {
			global MFP_n = $MFP_n + 1
			global MFP_$MFP_n "`xvar'"
			global MFP_cur "$MFP_cur `xvar'"
		}
		else {
			tokenize `xvar'
			forvalues i=1/`nvar' {
				global MFP_n = $MFP_n + 1
				global MFP_$MFP_n "``i''"
				global MFP_cur "$MFP_cur ``i''"
			}
		}
		gettoken xvar xlist : xlist, parse("()") match(par)
		if ("`par'"=="(" & `"`xvar'"'=="") {
			di as err "empty () found"
			exit 198
		}
	}
end
exit

History
-------
3.0.0 19apr2012 Major rewrite to support factor variables. Adjust() option takes over function of adjvars() option.
2.0.1 11mar2010 Changes made to mfpi_10 to preserve variables in final fitted model, allowing -predict- to work.
                Also, -showmodel- presents the final fitted model. Various new variables appropriately labelled.
1.0.4 26oct2009 fix problems with determining primary equation name
1.0.3 04sep2009 Rename with() option to TReatment() and adjust() option to center()
