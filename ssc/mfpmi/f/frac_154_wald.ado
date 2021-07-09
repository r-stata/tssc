*! version 1.0.2 PR 09ap2015
program define frac_154_wald, eclass
	version 9.0
/*
	Now uses mim rather than micombine, PR 09apr2015
	Support for -svy- added 14sep2006.
	Modified for wald testing, PR 28mar2006.
	Version 1.5.4 of old fracpoly (12Jul98).
	Now used as slave routine for fracpoly.ado and mfracpol.ado.
*/
	if replay() {
		if "`e(cmd)'" == "" | "`e(fp_cmd2)'" != "fracpoly" {
			error 301
		}
		syntax [, COMpare *]
		if `"`e(cmd2)'"' != "" {
			di in blue `"->`e(cmd2)'"'
			`e(cmd2)', `options'
		}
		else {
			di in blue `"->`e(cmd)'"'
			`e(cmd)', `options'
		}
		fraccomp, `compare'
		exit
	}
	// Note that syntax is "mim <cmd> <stuff> ...". mim invokes mim, storebv:
	gettoken micmb 0 : 0
	if "`micmb'"!="mim" {
		local cmd `micmb'
		local micmb
	}
	else {
		local micmb mim, storebv:
		gettoken cmd 0 : 0, parse(" ,")
	}
	frac_chk `cmd' 
	if `s(bad)' {
		di in red "invalid or unrecognised command, `cmd'"
		exit 198
	}
	/*
		dist=0 (normal), 1 (binomial), 2 (poisson), 3 (cox), 4 (glm),
		5 (xtgee), 6 (ereg/weibull), 7 (stcox/streg).
	*/
	local dist `s(dist)'
	local glm `s(isglm)'
	local qreg `s(isqreg)'
	local xtgee `s(isxtgee)'
	local normal `s(isnorm)'

	if `dist' != 7 {
		gettoken lhs 0 : 0, parse(" ,")
	}
	gettoken star 0 : 0, parse(" ,")
	local star "`lhs' `star'"
	/*
		Look for fixpowers
	*/
	local done 0
	gettoken nxt : 0, parse(" ,")
	while !`done' {
		local done 1 
		if "`nxt'"!="" & "`nxt'"!="," { 
			cap confirm num `nxt'
			if _rc==0 { 
				local fixpowe `fixpowe' `nxt'
				local done 0 
				gettoken nxt 0 : 0, parse(" ,")
				gettoken nxt   : 0, parse(" ,")
			}
		}
	}
	local 0 `"`star' `0'"'
	local search = ("`fixpowe'"=="")
	if `search' {
		local srchopt ADDpowers(str) POwers(numlist) DEGree(int 2) LOg COMpare
	}

	if `dist' != 7 {
		local minv 2
	}
	else local minv 1

	syntax varlist(min=`minv') [if] [in] [aw fw pw iw] [, /*
		*/ ALL DEAD(str) CATzero EXPx(str) ORIgin(str) ZERo /*
		*/ noCONStant noSCAling ADJust(str) NAme(str) `srchopt' /*
		*/ SVYalone svy(string) * ]
	local small 1e-6

	frac_cox "`dead'" `dist'
	local cz="`catzero'"!=""
	if `cz' local zero zero
	if `search' {
		if `degree'<1 | `degree'>9 {
			di in red "invalid degree()"
			exit 198
		}
		local df=2*`degree'
		local odddf=(2*int(`df'/2)<`df')
	}
	else 	local df 1

	local lin=("`fixpowe'"=="1") & ("zero'"=="") & ("catzero'"=="")

	if "`constant'"=="noconstant" {
		if "`cmd'"=="fit" | "`cmd'"=="cox" | "`cmd'"=="stcox" | /*
			*/ "`cmd'"=="streg" {
			di in red "noconstant invalid with `cmd'"
			exit 198
		}
		local options "`options' nocons"
	}

	if "`svyalone'"!="" local svy svy:
	else if `"`svy'"'!="" local svy svy, `svy':

	/*
	 	Read powers to be searched into a variable, `p'
	*/
	if `search' {
		if "`powers'"=="" local powers "-2,-1,-.5,0,.5,1,2,3"
		local pwrs "`powers' `addpowe'"
		frac_pq "`pwrs'" 1 1
		local np `r(np)'
		if `np'<1 {
			di in red "no powers given"
			exit 2002
		}
		local pwrs "`r(powers)'"
		local i 1
		while `i'<=`np' {
			local p`i' `r(p`i')'
			local i=`i'+1
		}
	}
	ereturn clear 			/* do we want to do this ?? */
	tokenize `varlist'
	if `dist' != 7 {
		local y `1'
		local rhs `2'
		mac shift 2
	}
	else {
		local y  _t
		local rhs `1'
		mac shift
	}
	local base `*'
	tempvar touse x lnx
	
	quietly {
		mark `touse' [`weight' `exp'] `if' `in'
		markout `touse' `rhs' `y' `base' `dead'
		lab var `touse' "fracpoly sample"
		if "`dead'"!="" {
			local options "`options' dead(`dead')"
		}
	/*
		Deal with weights.
	*/
		frac_wgt `"`exp'"' `touse' `"`weight'"'
		local mnlnwt = r(mnlnwt) /* mean log normalized weights */
		local wgt `r(wgt)'
		gen double `x'=`rhs' if `touse'
		gen double `lnx'=.
		frac_xo `x' `lnx' `lin' "`expx'" "`origin'" /*
			*/ "`zero'" "`scaling'" `rhs' `touse'
		local nobs = r(N)
		if r(shifted)==0 {
			local zeta `r(zeta)'
			local shift 0
		}
		else 	local shift `r(zeta)'
		local kx `"`r(expxest)'"'
		local scalfac `r(scale)'
		if `cz' {
			tempvar catz
			gen byte `catz'=`x'<=0
		}
	}
	/*
		Store coefficients for linear fit on untransformed x
	*/
	if `dist' != 7 {
		local yvar `y'
	}
	qui `svy'`cmd' `yvar' `rhs' `base' `wgt' if `touse', `options'
	cap local b0=_b[_cons]
	if _rc local b0 0
	cap local b1=_b[`rhs']
	if _rc {
		di in red "could not fit linear model for `rhs'"
		exit 2001
	}
	/*
		Determine residual and model df.
	*/
	qui reg `y' `base' `wgt' if `touse'
	local rdf=e(df_r)+("`constant'"=="noconstant")
	if `search' {
		local m `degree'
		if "`log'"!="" {
			di _n in gr "Model #      Wald stat" _cont
			if `normal' di in gr "  Res S.D. " _cont
			local i 1
			while `i'<=`m' {
				di in gr " Power " `i' _cont
				local i=`i'+1
			}
			di _n
		}
	/*
		Go!
	*/
		local i 1
		while `i'<=`np' {
			local pi `p`i''
			tempvar x`i'
			qui gen double `x`i''=cond(`pi'==0, `lnx', /*
		 	*/ cond(`pi'==1, `x', cond(`x'==0,0,`x'^`pi')))
			local i=`i'+1
		}
		local i 0
		while `i'<`m' {
			local j`i' 0
			local i=`i'+1
			tempvar xp`i'
			qui gen double `xp`i''=.
			local j=`i'+`i'-1
			local wald`j' 0 /* min Wald stat for df=j */
			local j=`j'+1
			local wald`j' 0
		}
		local j`m' 1
		local i `m'
		local kount 0  /* no. of models processed */
		local deg `j`m''
		local done 0
		while !`done' {
			if `i'<`m' {
				local ji `j`i''
				qui replace `xp`i''=`x`ji''
				local l `i'
				while `l'<`m' {
					local l=`l'+1
					local j`l' `ji'
					local l1=`l'-1
					qui replace `xp`l''=`xp`l1''*`lnx'
				}
				if "`log'"=="" di "." _cont
			}
			else qui replace `xp`m''=`x`j`m'''
	/*
		Test for any power being 1 (i.e. odd-df model)
	*/
			local one 0
			local l 0
			while `l'<`m' {
				local l=`l'+1
				if "`p`j`l'''"=="1" local one 1
			}
			if !`odddf' | (`deg'<`m') | `one' {
				local dfi=2*`deg'-`one'
				local i 1
				local xlist
				while `i'<=`m' {
					if `j`i''>0 { 
						local xlist "`xlist' `xp`i''" 
					}
					local i=`i'+1
				}
				local kount=`kount'+1
				qui `micmb' `svy'`cmd' `yvar' `xlist' `catz' `base' `wgt' /*
					*/ if `touse', `options'
				capture frac_wald `xlist'
				if c(rc) {
					// can happen if a variable is omitted from `xlist' due to collinearity
					if `normal' local rsd .
					local wald .
				}
				else {
					local wald = r(wald)
					if `normal' local rsd=e(rmse)
				}
				if (`wald' < .) & (`wald' > `wald`dfi'') {
					local wald`dfi' `wald'
					if `normal' local rsd`dfi' `rsd'
					local i 1
					local pm`dfi'
					while `i'<=`m' {
						if `j`i''>0 {
							local pm `p`j`i'''
							local pm`dfi' /*
							 */" `pm`dfi'' `pm'"
						}
						local i=`i'+1
					}
				}
				if "`log'"!="" {
					di in ye %5.0f `kount' /*
				 	*/ _col(10) %12.3f `wald' _cont
					if `normal' { 
						di "   " %8.0g `rsd' _cont
					}
					local i `m'
					while `i'>0 {
						if `j`i''==0 {
							di _skip(6) ". " _cont
						}
						else /*
						*/ di in ye %8.1f `p`j`i''' _cont
						local i=`i'-1
					}
					di
				}
				if `deg'==1 {
					local fppow `p`j`m'''
					local fpwald`j`m'' "`fppow' `wald'"
				}
			}
	/*
		Increment the first possible index (of loop i) among indices of
		loops m, m-1, m-2, ..., 1
	*/
			local i `m'
	/*
		Finish after all indices have achieved their upper limits (np).
	*/
			while `j`i''==`np' {
				local i=`i'-1
			}
			if `i'==0 local done 1
			else {
				if `j`i''==0 local deg = `m'-`i'+1
				local j`i'=`j`i''+1
			}
		}
	/*
		Update the results for even df to include odd df
	*/
		local i 2
		while `i'<=`df' {
			local j=`i'-1
			if `wald`j''>`wald`i'' {
				local wald`i' `wald`j''
				if `normal' local rsd`i' `rsd`j''
				local pm`i' "`pm`j''"
			}
			local i=`i'+2
		}
		if "`log'"=="" di
	}
	/*
		Create FP transformation(s) of xvar for final model
	*/
	if `search' local pwrs `pm`df''
	else local pwrs `fixpowe'
	if "`expx'"!=""   local e "expx(`expx')"
	if "`origin'"!="" local o "origin(`origin')"
	if "`adjust'"!="" local a "adjust(`adjust')"
	if "`name'"!=""   local n "name(`name')"
	if !`lin' | (`lin' & "`e'`o'`a'"!="") {
		fracgen `rhs' `pwrs' if `touse', `all' sayesamp replace /*
	 	*/ `zero' `catzero' `scaling' `a' `e' `o' `n'
		local xp `r(names)'
		if "`adjust'"!="" {
			local j 1
			local Np: word count `pwrs'
			while `j'<=`Np' {
				local a`j'=r(adj`j')
				local j=`j'+1
			}
		}
	}
	else local xp `rhs'
	/*
		Fit final model with permanent e(sample)=`touse' filter
	*/
	`micmb' `svy'`cmd' `yvar' `xp' `base' `wgt' if `touse', `options'
	if !`search' {
	/*
		Fixed-powers model.
		Note that `wald1' is stored in e(fp_dlin), deviance for a
		linear model, even when `fixpowe' is not 1; similarly 
		for `rsd1'.
	*/
		frac_wald `xp'
		local wald1 = r(wald)
		if `normal' local rsd1=e(rmse)
		local pm1 `fixpowe'
	}
	di in gr "Wald stat:" in ye %9.2f `wald`df'' in gr ". " _cont
	local wald `wald`df''
	if `search' {
		di in gr "Best powers of " in ye "`rhs'" in gr " among " /*
	 	*/ in ye `kount' in gr " models fit: " in ye "`pwrs'" _cont
		di in gr "." _cont
	}
	di
	ereturn scalar fp_d0 = 0
	cap ereturn scalar fp_s0 = `rsd0'
	ereturn scalar fp_dlin = `wald1'
	if `normal' {
		ereturn scalar fp_slin = `rsd1'
	}
	local i 2
	local j 1
	while `i'<=`df' {
		ereturn scalar fp_d`j' = `wald`i''
		ereturn local fp_p`j' `pm`i''		/* PR bug fix */
		if `normal' {
			ereturn scalar fp_s`j' = `rsd`i''
		}
		local i=`i'+2
		local j=`j'+1
	}
	/*
		New code in v 1.4.7 for consistency with mfracpol
	*/
	ereturn local fp_x1 `rhs'
	ereturn local fp_k1 `pwrs'
	local nbase: word count `base'
	local i 0
	while `i'<`nbase' {
		local i=`i'+1
		local j=`i'+1
		ereturn local fp_x`j' : word `i' of `base'
		ereturn local fp_k`j' 1
	}
	/*
		End of new code in v 1.4.7 for consistency with mfracpol
	*/
	if `search' {
		local i `np'
		while `i'>0 {
			ereturn local fp_bt`i' `fpdev`i''
			local i=`i'-1
		}
	}
	if "`adjust'"!="" {
		local j 1
		while `j'<=`Np' {
			ereturn scalar fp_a`j'=`a`j''
			local j=`j'+1
		}
	}
	ereturn scalar fp_wald = `wald'
	ereturn scalar fp_catz = `cz'
	ereturn scalar fp_nx = `nbase'+1
	ereturn scalar fp_df = `df'
	ereturn scalar fp_rdf = `rdf'
	ereturn scalar fp_N = `nobs'
	ereturn local  fp_opts `options'
	ereturn local  fp_t1t "Fractional Polynomial"
	ereturn local  fp_pwrs `pwrs'
	ereturn local  fp_wgt "`weight'"
	ereturn local  fp_wexp "`exp'"
	ereturn local  fp_xp `xp'
	ereturn local  fp_base `base'
	ereturn local  fp_rhs `rhs'
	ereturn local  fp_depv `y'
	ereturn local  fp_fvl `xp' `base'
	ereturn scalar fp_dist = `dist'

	ereturn scalar f_b0 = `b0'
	ereturn scalar f_b1 = `b1'

	ereturn local  fp_fprp "no"
	ereturn scalar fp_srch = `search'
	ereturn scalar fp_sfac = `scalfac'
	ereturn scalar fp_shft = `shift'
	ereturn local  fp_xpx `kx'

	ereturn local  fp_cmd "fracpoly"
	ereturn local  fp_cmd2 "fracpoly"

	fraccomp, `compare'
end

program define fraccomp /* report model comparisons */
	syntax [, COMpare]
	if "`compare'"=="" | e(fp_srch)==0 exit
	local normal=(e(fp_dist)==0)
	local cz = e(fp_catz)
	if `cz' local catz " + 0"
	local dash "     {hline 2}"
	local ddup=63+15*`normal'
	di in gr _n "Fractional polynomial model comparisons:"
	di in smcl in gr "{hline `ddup'}"
	di in gr abbrev("`e(fp_rhs)'",12) _col(18) "df       Wald stat    " _cont
	if `normal' di in gr " Res. SD     " _cont
	di in gr " Gain   P(term) Powers" 
	di in smcl in gr "{hline `ddup'}"

	di in gr "Not in model" in ye _col(18) " 0" /*
		*/ _col(22) %13.3f e(fp_d0) _cont
	if `normal' di in ye _skip(5) %8.0g e(fp_s0) _cont
	di in smcl in gr _skip(3) "`dash'`dash'"
	local i 1
	while `i'<=e(fp_df) {
		local m=1+int((`i'-1)/2)
		local idf=`i'+`cz'
		if `i'==1 {
			di in gr "Linear`catz'" _col(18) in ye /*
				*/ %2.0f `idf' _col(22) _cont
			local wald = e(fp_dlin)
			local rsd = e(fp_slin)
			local d=-(e(fp_d0)-`wald')
			local n1=1+`cz'
			local n2=e(fp_rdf)-1-`cz'
			local pwr 1
		}
		else {
			di in gr "m = `m'`catz'" _col(18) in ye /*
				*/ %2.0f `idf' _col(22) _cont
			local wald = e(fp_d`m')
			local rsd = e(fp_s`m')
			local d=-(`waldlast'-`wald')
			local n1 = cond(`m'==1, 1, 2)
			local n2=e(fp_rdf)-2*`m'-`cz'
			*local pwr ${S_E_p`m'}
			local pwr `e(fp_p`m')'
		}
		frac_pv `normal' "`e(fp_wgt)'" `e(fp_N)' `d' `n1' `n2'
		local P = r(P)
/*
		if `i'==1 global S_E_Plin `P'
		else global S_E_P`m' `P'
*/
		di in ye %13.3f `wald' _cont
		if `normal' {
			di in ye _skip(5) %8.0g `rsd' _cont
		}
		di in ye _skip(3) %7.3f -(e(fp_dlin)-`wald') /*
	 	*/ %9.3f `P' _skip(2) "`pwr'"
		local waldlast `wald'
		local i = `i' + cond(`i'==1,1,2)
	}
	di in smcl in gr "{hline `ddup'}"
	if `cz' { 
		di in bl /*
*/ "[Note:`catz' indicates dummy variable for `e(fp_rhs)'=0 included in model]"
	}
end
