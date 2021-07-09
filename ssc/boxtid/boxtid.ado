*! version 1.5.3 PR 02jul2012
program define boxtid, eclass
// -boxtid- extended to allow factor variables
version 11.0
if replay() {
	if "`e(cmd)'"=="" | "`e(fp_cmd2)'"!="boxtid" {
		error 301
	}
	di in blue "->`e(cmd)'"
	_rslt
	exit
}
gettoken cmd 0 : 0
xfrac_chk `cmd' 
if `s(bad)' {
	di as err "invalid or unrecognised command, `cmd'"
	exit 198
}
/*
	dist=0 (normal), 1 (binomial), 2 (poisson), 3 (cox), 4 (glm),
	5 (xtgee), 6(ereg/weibull).
*/
local dist `s(dist)'
local glm `s(isglm)'
local qreg `s(isqreg)'
local xtgee `s(isxtgee)'
local normal `s(isnorm)'

if `dist'!=7 local minv 2
else local minv 1

syntax varlist(min=`minv' fv) [if] [in] [aw fw pw iw] [, /* 
 */ ADJust(string) ALL noCONStant CENter(string) DEAD(varname) DF(string) DFDefault(int 2) /*
 */ INit(string) ITer(int 100) LTOLerance(real .001) EXPon(varlist) /*
 */ POWers(numlist) TRace ZERo(varlist) * ]
if "`adjust'" != "" {
	if ("`center'" != "") local adjust
	else local center `adjust'
}
frac_cox "`dead'" `dist'
if "`trace'"!="" local trace noi
if "`constant'"=="noconstant" {
	if "`cmd'"=="fit" | "`cmd'"=="cox" {
		di as err "noconstant invalid with `cmd'"
		exit 198
	}
	if "`center'"=="" {
		local center no
		di in bl "[Note: center(no) assumed with `constant']"
	}
	else {
		di in bl "[Note: center(no) advised with `constant']"
	}
	local options "`options' nocons"
}
if "`powers'"=="" local powers 2 -1 -0.5 0 0.5 1 2 3
tempname small
scalar `small'=1e-6
if `dist'!=7 {
	gettoken y xvars : varlist
	local yvar `y'
}
else {
	local yvar _t
	local xvars `varlist'
}
tempvar touse
quietly {
	marksample touse
	markout `touse' `varlist' `dead'
	if `dist'==7 replace `touse'=0 if _st==0
/*
	Deal with weights.
*/
	frac_wgt `"`exp'"' `touse' `"`weight'"'
	local mnlnwt = r(mnlnwt) /* mean log normalized weights */
	local wgt `r(wgt)'
	if "`dead'"!="" local dead "dead(`dead')"

	local nxvars: word count `xvars'
/*
	Centering
*/
	xfrac_adj "`center'" "`xvars'" `touse'
	forvalues i=1/`nxvars' {
		if "`r(adj`i')'"!="" {
			local Cen`i' center(`r(adj`i')')
		}
		local uniq`i'=r(uniq`i')
	}
/*
	Degrees of freedom
*/
	if "`df'"!="" {
		xfrac_dis "`df'" df 1 . "`xvars'"
		forvalues i=1/`nxvars' {
			if "${S_`i'}"!="" {
				local df`i' ${S_`i'}
			}
		}
	}
/*
	Assign default df for vars not so far accounted for.
	Give 1 df if 2-3 distinct values, 2 df for 4-5 values,
	dfdefault df for >=6 values.

	Also, initialisations for vars in non-linear part of model.
*/
	local rhs
	local covars
	local nx 0
	local nbase 0
	local i 1
	tokenize `xvars'
	while "``i''"!="" {
		fvexpand ``i''
		if "`r(fvops)'" == "true" {
			local isfactor`i' 1
		}
		else local isfactor`i' 0
		if `isfactor`i'' {
			local df`i' 1
			local ++nbase
			local covars `covars' ``i''
		}
		else {
			frac_mun ``i'' purge
			if "`df`i''"=="" {
				if `uniq`i''<=3      local df`i' 1
				else if `uniq`i''<=5 local df`i'=min(2,`dfdefault')
				else 		     local df`i' `dfdefault'
			}
			if `df`i''==1 {
				local nbase=`nbase'+1
				local covars `covars' ``i''
			}
			else {
				if `uniq`i''<(`df`i''+1) {
					noi di as err "insufficient unique values for ``i''"
					exit 2000
				}
				local ++nx
				local rhs `rhs' ``i''
				local v`nx' ``i''
				local deg`nx'=int(.01+.5*`df`i'')
				local xnz`nx' `touse'
				local ifxnz`nx' "if `touse'"
				local lnx`nx' 1
			}
		}
		local ++i
	}
/*
	Assign centering macros for covars (df=1) and rhs (df>1).
	covars follow rhs vars in cen`i' macros.
*/
	local ix 0
	local ic `nx'
	forvalues i=1/`nxvars' {
		if `df`i''==1 {
			local ic=`ic'+1
			local cen`ic' `Cen`i''
		}
		else {
			local ix=`ix'+1
			local cen`ix' `Cen`i''
		}
		local Cen`i'
	}
/*
	Vars with expon option
*/
	if "`expon'"!="" {
		tokenize `expon'
		while "`1'"!="" {
			frac_in `1' "`rhs'"
			local lnx`s(k)' 0
			mac shift
		}
	}
/*
	Vars with zero option
*/
	if "`zero'"!="" {
		tokenize `zero'
		while "`1'"!="" {
			frac_in `1' "`rhs'"
			local j `s(k)'
			local zero`j' "zero"
			tempvar xnz`j'
			gen byte `xnz`j''=(`v`j''>0 & `touse'==1)
			local ifxnz`j' "if `xnz`j''"
			mac shift
		}
	}
/*
	Put initial values into init`v'.
	(Note: correct for expx(sd) transformation in estimate of power)
*/
	if "`init'"!="" {
		frac_ext "`rhs'" "`init'" init
		forvalues v=1/`nx' {
			local init`v' ${S_`v'}
		}
	}
	forvalues v=1/`nx' {
		local cen
		forvalues l=1/`nx' {
			if `l'!=`v' local cen `cen' `v`l''
		}
		`trace' init `cmd' "`y'" `v`v'' `lnx`v'' "`cen'" ///
		  "`covars'" "`wgt'" `touse' `deg`v'' "`dead'" ///
		  "`zero`v''" "`powers'" "`options'" "`init`v''"
		local pwrs `r(pwrs)'
		local f=r(f)
		initial `deg`v'' `f' "`pwrs'"
		forvalues i=1/`deg`v'' {
			local init`v'`i' ${S_`i'}
		}
	}
	count if `touse'
	local nobs=r(N)
/*
	Determine residual and model df.
*/
	regress `yvar' `covars' `wgt' if `touse'
	local rdf=e(df_r)+("`constant'"=="noconstant")
/*
	Calc deviance=-2(log likelihood) for regression on covars only,
	allowing for possible weights.

	Note that for logit/clogit/logistic with nocons, must regress on zero,
	otherwise get r(102) error.
*/
	if (`glm' | `dist'==1) & "`constant'"=="noconstant" {
		tempvar z0
		gen `z0'=0
	}
	`cmd' `y' `z0' `covars' `wgt' if `touse', `dead' `options'
	if `xtgee' & "`covars'"=="" global S_E_chi2 0
	if `glm' {
		* Note: with Stata 8 scale param is e(phi); was e(delta) in Stata 6
		* Also e(dispersp) has become e(dispers_p).
 		loc scale 1
 		if abs(e(dispers_p)/e(phi)-1)>`small' & /*
		*/ abs(e(dispers)/e(phi)-1)>`small' {
			loc scale = e(phi)
 		}
	}
	frac_dv `normal' "`wgt'" `nobs' `mnlnwt' `dist' /*
	 */ `glm' `xtgee' `qreg' "`scale'"
	local dev0=r(deviance)
/*
	Initial fit for each predictor
*/
	local wvars
	forvalues v=1/`nx' {
		tempvar x`v'
		tempname range`v' tmp
		if `lnx`v'' {
                        fracgen `v`v'' 0 if `touse', name(`tmp') `zero`v'' /*
			 */ noscaling
                        rename `r(names)' `x`v''
		}
		else gen `x`v''=`v`v'' if `touse'
/*
	Standardize useable values of x`v' to [0,1].
*/
		sum `x`v'' `ifxnz`v''
		scalar `range`v''=r(max)-r(min)
		replace `x`v''=(`x`v''-r(mean))/`range`v'' `ifxnz`v''
		forvalues i=1/`deg`v'' {
			tempname g`v'`i'
			scalar `g`v'`i''=`init`v'`i''*`range`v''
			tempvar w`v'`i' z`v'`i'
			gen double `w`v'`i''= /*
			 */ cond(`xnz`v'',exp(`g`v'`i''*`x`v''),0) if `touse'
			sum `w`v'`i''
			if r(min)==r(max) | r(N)<`nobs' {
				noi di as err "boxtid fit failed, derived variable has zero variance"
				exit 498
			}
			gen double `z`v'`i''=.
			local wvars `wvars' `w`v'`i''
		}
	}
/*
	Initial fit of whole model
*/
	`cmd' `y' `wvars' `covars' `wgt', `dead' `options'
	frac_dv `normal' "`wgt'" `nobs' `mnlnwt' `dist' /*
	 */ `glm' `xtgee' `qreg' "`scale'"
	local devnow=r(deviance)
	noi di as txt _n "Iteration 0:  Deviance = " as res %9.0g `devnow'
	forvalues v=1/`nx' {
		forvalues i=1/`deg`v'' {
			tempname b`v'`i'
			scalar `b`v'`i''=_b[`w`v'`i'']
		}
	}
/*
	Iterate
*/
	tempname gold ratio bz

	local devinit `devnow'
	local devprev `devnow'
	local devcon `ltolerance' /* deviance convergence criterion */
	local converg 1
	local totalit 0
	local done 0
	local j 1
	while `j'<=`iter' & !`done' {
	    local v 0
	    while `v'<`nx' & !`done' {
		    local ++v
/*
	First loop: update g2 conditional on g1
	(g1 uses w1 & z1, g2 uses w2 & z2)
*/
		    forvalues i=1/`deg`v'' {
			local devpr2 `devnow'
			replace `z`v'`i''=`w`v'`i''*`x`v''
			`cmd' `y' `wvars' `z`v'`i'' `covars' `wgt', /*
			 */ `dead' `options'
			scalar `gold'=`g`v'`i''
			cap scalar `bz'=_b[`z`v'`i'']
			if _rc scalar `bz'=`b`v'`i''
			scalar `ratio'=`bz'/`b`v'`i''
			local dun 0
			local s 1
			while !`dun' & `s'>-2 {
				if `s'<0 noi di as txt "(step sign changed)"
				local gf 1
				while !`dun' & `gf'<=1e6 {
					scalar `g`v'`i''=`gold'+`s'*`ratio'/`gf'
					replace `w`v'`i''=cond(`xnz`v'', /*
					 */ exp(`g`v'`i''*`x`v''),0) if `touse'
					count if `w`v'`i''!=.
					if r(N)<`nobs' {
						local gf=`gf'*10
						noi di as txt "(invalid transformation attempt, step length divided by 10)"
					}
					else {
						`cmd' `y' `wvars' `covars' `wgt', /*
						 */ `dead' `options'
						frac_dv `normal' "`wgt'" `nobs' `mnlnwt' /*
						 */ `dist' `glm' `xtgee' `qreg' "`scale'"
						local devdiff=(r(deviance)-`devpr2')
						if `devdiff'<0 { /* accept new parameters */
							local devnow=r(deviance)
							forvalues i2=1/`deg`v'' {
								scalar `b`v'`i2''=_b[`w`v'`i2'']
							}
							local dun 1
						}
						else {
							local gf=`gf'*10
							noi di as txt "(unprofitable step attempted, step length divided by 10)"
						}
					}
				}
				local s=`s'-2
			}
			if "`trace'"!="" {
			    noi di as txt "`v`v''(`i')" %4.0f `j2' /*
			     */ _col(16) as res %9.0g /*
			     */ `g`v'`i''/`range`v'' /*
			     */ _col(28) %12.6f r(deviance) /*
			     */ _col(44) %9.6f `devdiff'
			}
			local devpr2 `devnow'
			local totalit=`totalit'+1
		    }	/* i loop (term within variable) */
	    }
	    if `nx'>1 local devdiff=(`devnow'-`devprev')
	    if "`devdiff'"=="" local devdiff 0
	    if `devdiff'>10 {
		local done 1
		local converg 0
	    }
	    else if `devdiff'>-`devcon' {
		local done 1
	    }
	    if "`trace'"!="" noi di
	    noi di as txt "Iteration `j':  Deviance = " as res %9.0g `devnow' /*
	     */ as txt " (change = " as res %9.0g `devdiff' as txt ")"
	    local devprev `devnow'
	    local j=`j'+1
	}
	if !`done' | (`devnow'>`devinit') local converg 0
/*
	Tests for linearity for each nonlinear term
	(could make this an option)
*/
	local terms: word count `wvars'
	local mdf=2*`terms'	/* model df for power terms + Taylor terms */
	forvalues v=1/`nx' {
/*
	Replace wv with power terms for all but v'th predictor.
	Delete terms recursively from wvars.
*/
		local wv `wvars'
		forvalues i=1/`deg`v'' {
			frac_str `w`v'`i'' `wv'
			local wv `s(new)'
		}
		`cmd' `y' `v`v'' `wv' `covars' `wgt' if `touse', /*
		 */ `dead' `options'
		frac_dv `normal' "`wgt'" `nobs' `mnlnwt' `dist' /*
		 */ `glm' `xtgee' `qreg' "`scale'"
		local lin`v'=_b[`v`v'']
		local se`v'=_se[`v`v'']
		local gain`v'=r(deviance)-`devnow'
		if `gain`v''>0 {
			local d `gain`v''
			local n1=2*`deg`v''-1
			local n2=`rdf'-`mdf'
			frac_pv `normal' "`wgt'" `nobs' `d' `n1' `n2'
			local P`v'=r(P)
		}
		else {
			local gain`v' 0
			local P`v' 1
		}
	}
/*
	Final model.
	Approximation to SE(k): see Snedecor and Cochran 1967 p 470.
*/
	local zvars
	forvalues v=1/`nx' {
		forvalues i=1/`deg`v'' {
			tempname sek`v'`i'
			scalar `sek`v'`i''=.
			local zvars `zvars' `z`v'`i''
		}
	}
	`cmd' `y' `wvars' `zvars' `covars' `wgt', `dead' `options'
	local xp
	local pwrs
	local rc 0
	local zvars
	local fvl
	forvalues v=1/`nx' {
		local xp`v'
		local pwrs`v'
		frac_mun `v`v''
		local vn `s(name)'
		gen byte `vn'_1=.   /* reserves name `vn'_1 */
		forvalues i=1/`deg`v'' {
			cap scalar `sek`v'`i''=(_se[`z`v'`i'']/ /*
			 */ abs(`b`v'`i''))/`range`v''
			if _rc scalar `sek`v'`i''=.
/*
	Rescale auxiliary variables to give their se=se(power param)
*/
*			replace `z`v'`i''=`z`v'`i''*_se[`z`v'`i'']/`sek`v'`i''
			replace `z`v'`i''=`z`v'`i''*abs(`b`v'`i'')*`range`v''
			local k=`g`v'`i''/`range`v''
			local pwrs`v' `pwrs`v'' `k'
			if `lnx`v'' {
				frac_ddp `k' 6
				local K `r(ddp)'
				local e
			}
			else {
				local K 1
				local e "expx(`k')"
			}
			noi fracgen `v`v'' `K' `K' if e(sample),`all' `e' /*
			 */ `cen`v'' replace index(`i') `zero`v'' name(`vn')
			local xx1: word 1 of `r(names)'
			local xx2: word 2 of `r(names)'
			count if `xx1'!=.
			if r(N)<`nobs' {
				local rc 2001
			}
			local xp`v' `xp`v'' `xx1'
/*
	Rename auxiliary ("zero") variable.
*/
			rename `xx2' `vn'p`i'
			local zp`v' `zp`v'' `vn'p`i'
			lab var `vn'p`i' "boxtid auxil p`i'(`v`v'')"
			local zvars `zvars' `vn'p`i'
		}
		local xp `xp' `xp`v''
		local h`v' `xp`v'' `zp`v''
		local fvl `fvl' `h`v''
		local pwrs `pwrs' `pwrs`v''
	}
}
/*
	Center covariates if necessary, and create final var list (`fvl')
*/
forvalues i=1/`nbase' {
	local j=`i'+`nx'
	local v: word `i' of `covars'
	if "`cen`j''"!="" {
		frac_mun `v'
		local n `s(name)'
		fracgen `v' 1 if e(sample),`all' replace noscaling `cen`j'' /*
		 */ name(`n')
		local v `r(names)'
	}
	local fvl `fvl' `v'
}
if `rc'==0 qui `cmd' `y' `fvl' `wgt', `dead' `options'
di as txt _n "[Total iterations: `totalit']"
/*
	New code in v 1.1.6 for consistency with mfracpol
	(Differs from code in fracpoly because of multiple
	transformed predictors--offset to nbase is `nx' not 1)
*/
forvalues i=1/`nbase' {
	local j=`i'+`nx'
	ereturn local fp_x`j': word `i' of `covars'
	ereturn local fp_k`j' 1
	ereturn local fp_a`j'
}
/*
	End of new code in v 1.1.6 for consistency with mfracpol
*/

global S_1 `nobs'
global S_2 `devnow'

ereturn local fp_xp `xp'
ereturn local fp_pwrs `pwrs'
ereturn local fp_x `rhs'
ereturn scalar fp_dev=`devnow'
ereturn scalar fp_cnvg=`converg'

forvalues v=1/`nx' {
	ereturn local fp_x`v' `v`v''	/* name of v`th predictor */
	ereturn local fp_k`v' `pwrs`v''	/* powers for v'th predictor */
	ereturn scalar fp_g`v'=`gain`v''	/* gain for v'th predictor */
	ereturn scalar fp_P`v'=`P`v''	/* P-value for nonlinearity */
	ereturn scalar fp_l`v'=`lin`v''	/* linear coefficient */
	ereturn scalar fp_sl`v'=`se`v''	/* SE of linear coefficient */
	ereturn scalar fp_a`v'=`deg`v''	/* #auxiliaries for this var */
	local S
	forvalues i=1/`deg`v'' {
		local s=`sek`v'`i''
		local S `S' `s'
	}
	ereturn local fp_s`v' `S'		/* se(powers) for v'th predictor */
	ereturn local fp_n`v' `h`v''		/* transformed elements for var `v', including auxiliaries */
}
ereturn local fp_base `covars'
ereturn local fp_depv `y'
ereturn scalar fp_dist=`dist'
ereturn local fp_fvl `fvl'
ereturn local fp_wgt "`weight'"
ereturn local fp_exp "`exp'"
ereturn scalar fp_nobs=`nobs'
ereturn local fp_sfac `scalfac'
ereturn scalar fp_nx=`nx'+`nbase'
ereturn local fp_opts `dead' `options'
ereturn local fp_t1t "Box-Tidwell model"
ereturn local fp_cmd fracpoly
ereturn local fp_cmd2 boxtid

if `rc'==0 _rslt
else error `rc'
end

program define _rslt
version 8
local VV : di "version " string(_caller()) ", missing:"
di as txt _n "Box-Tidwell regression model"

if "`level'" != "" local level level(`level')
if "`e(cmd2)'"=="stpm" `VV' ml display, `level' `options'
else if "`e(cmd)'"=="stpm2" `VV' stpm2, `level' `options'
else if "`e(cmd2)'"=="stcox" `VV' `e(cmd2)', `level' nohr `options'
else `VV' `e(cmd)', `level' `options'

di as txt "{hline 13}{c TT}{hline 64}"
local nx: word count `e(fp_x)'
forvalues v=1/`nx' { 
	local var: word `v' of `e(fp_x)'
	local var=abbrev("`var'",12)
	local skip=13-length("`var'")

	cap local b1=e(fp_l`v')
	if _rc local b1 .
	cap local seb1=e(fp_sl`v')
	if _rc local seb1 .
	cap local pnlin=e(fp_P`v')
	if _rc local pnlin .

	frac_ddp e(fp_g`v') 3
	local nlindev `r(ddp)'

	di as txt "`var'" _skip(`skip') "{c |}" /*
	 */ as res _col(17) %9.0g `b1' _col(28) %9.0g `seb1' /*
	 */ %9.2f `b1'/`seb1' /*
	 */ as txt _col(47) "Nonlin. dev. " as res "`nlindev'" /*
	 */ as txt _col(68) "(P = " as res %5.3f `pnlin' as txt ")"

	local deg: word count `e(fp_k`v')'
	forvalues i=1/`deg' {
		local k: word `i' of `e(fp_k`v')'
		local s: word `i' of `e(fp_s`v')'
		if "`k'"=="" local k .
		if "`s'"=="" local s .
		di as txt _col(11) "p`i' {c |}" _col(17) as res %9.0g `k' /*
		 */ _col(28) %9.0g `s' 	// _col(41) %5.2f `k'/`s'
	}
}
di as txt "{hline 13}{c BT}{hline 64}"
di as txt "Deviance:" as res %9.3f e(fp_dev) as txt "."
if e(fp_cnvg)==0 {
	di as err "divergence, or only partial convergence achieved"
	exit 430
}
end

program define init, rclass
	args cmd y vv lnx adj covars wgt touse deg dead zero powers options init
	local wi: word count `init'	/* initial powers can be null */
	if `wi'>0 {
		if `wi'!=`deg' {
			noi di as err /*
			 */ "incorrect number of initial values for `vv'"
			exit 198
		}
	}
	if !`lnx' 		local isexpx expx(sd)
	if "`covars'`adj'"!="" 	local cov covars(`covars' `cen')
	if "`init'"=="" {
		tempname vn /* creates temporary name */
		xfrac_154 `cmd' `y' `vv' `covars' `adj' `wgt' if `touse', /*
		 */ degree(`deg') `dead' `zero' `isexpx' powers(`powers') `options' /*
		 */ name(`vn')
		cap drop `e(fp_xp)' /* remove var(s) with funny names */
		if !`lnx' local xpx=`e(fp_xpx)' /* factor if expx used */
		else local xpx 1
		if `deg'==1 {
			local dev=`e(fp_d1)'
			local pwr `e(fp_k1)'
* Beginning of code taken from previous subroutine "sorted".
			local mx 1
			local mp1 `e(fp_p1)'
			local i 1
			while "`e(fp_bt`i')'"!="" {
				local p`i': word 1 of `e(fp_bt`i')'
				local d`i': word 2 of `e(fp_bt`i')'
				local s`i'=(`p`i'')^2
				if `p`i''==`mp1' local m1 `i'
				if `d`i''>`d`mx'' local mx `i'
				local ++i
			}
			local np=`i'-1
/*
	find 2nd smallest deviance
*/
			local m2 `mx'
			forvalues i=1/`np'{
				if `d`i''<`d`m2'' & `i'!=`m1' {
					local m2 `i'
				}
			}
/*
	find 3rd smallest deviance
*/
			local m3 `mx'
			forvalues i=1/`np'{
				if `d`i''<`d`m3''&`i'!=`m1'&`i'!=`m2' {
					local m3 `i'
				}
			}
/*
	form matrices and do quadratic regression
*/
			tempname X Y XTX XTXi XTY B
			matrix `X' = (1,`p`m1'',`s`m1''\1,`p`m2'',`s`m2''\1,`p`m3'',`s`m3'')
			matrix `Y' = (`d`m1'' \ `d`m2'' \ `d`m3'')
			matrix `XTX' = `X''*`X'
			matrix `XTXi' = syminv(`XTX')
			matrix `XTY' = `X''*`Y'
			matrix `B' = `XTXi'*`XTY'
/*
	find initial value
*/
			local pwrs = -0.5*`B'[2,1]/`B'[3,1]
* End of code taken from previous subroutine "sorted".
			if abs(`pwrs')<.05 {
				local pwrs=sign(`pwrs')*.05
			}
			xfrac_154 `cmd' `y' `vv' `pwrs' `covars' `adj' `wgt' /*
			 */ if `touse', /*
			 */ `dead' `zero' `isexpx' `options' name(`vn')
			cap drop `e(fp_xp)'
			local devsrt=e(fp_dlin)
			local pwrsrt `e(fp_k1)'
			if `devsrt'>`dev' {
				local pwrs `pwr'
			}
			else local pwrs `pwrsrt'
		}
		else local pwrs `e(fp_pwrs)'
		tokenize `pwrs'
		local pwrs
		while "`1'"!="" {
			if abs(`1')<.05 local 1 .05
			local pwrs `pwrs' `1'
			mac shift
		}
	}
	else {
/*
	Find initial power values in string `init'
*/
		local pwrs
		forvalues i=1/`deg' {
			local p: word `i' of `init'
			cap confirm num `p'
			if _rc {
				noi di as err "invalid init() for var `vv'"
				exit 198
			}
			local pwrs `pwrs' `p'
		}
		local xpx 1
	}
	if `lnx' local xpx 1
	return local pwrs `pwrs'	/* initialised powers */
	return scalar f = `xpx'		/* factor from expx transf */
end

program define initial
* initialize powers
	args deg f pwrs
	forvalues i=1/`deg' {
		local p: word `i' of `pwrs'
		if abs(`p')<.001 local p=sign(`p')*.001
		if `i'==1 {
			local p1 `p'
			local padd 0
		}
		else {
			if abs(`p'-`p1')<.001 { /* tiebreak */
				local padd=`padd'+0.22
				local p=`p'+`padd'
			}
			else {
				local p1 `p'
				local padd 0
			}
		}
		if `f'!=1 global S_`i'=`p'*`f'
		else global S_`i' `p'
	}
end

* version 1.0.0 PR 26Feb1999.
program define frac_str, sclass
version 6
gettoken target 0 : 0
if "`target'"=="" { error 198 }
tokenize `0'
local found 0
while "`1'"!="" {
	if "`1'"=="`target'" { local found = `found'+1 }
	else local new "`new' `1'"
	mac shift
}
sret local new `new'
sret local found `found'
end

* version 1.1.0 PR 26Feb1999.
program define frac_ext
version 6
/*
	Extract values (e.g. powers, initial values) for individual variables.
	1 = x-variables, 2 = value_string, 3 = name (e.g. init),
	4 (optional) = separator.
	Example: fracext "rhs'" "`init'" init \
*/
local rhs "`1'"
local target "`2'"
local tname "`3'"
local sep "`4'"
if "`sep'"=="" { local sep "," }

unabbrev `rhs'
local rhs `s(varlist)'
local nx: word count `rhs'
local j 0
while `j'<`nx' {
	local j=`j'+1
	local n`j': word `j' of `rhs'
}
quietly {
	tokenize "`target'", parse("`sep'")
	local ncl 0 /* # of comma-delimited clusters */
	while "`1'"!="" {
		if "`1'"=="`sep'" { mac shift }
		local ncl=`ncl'+1
		local clust`ncl' "`1'"
		mac shift
	}
	if "`clust`ncl''"=="" { local ncl=`ncl'-1 }
	if `ncl'>`nx' {
		noi di in red "too many sets of `tname'() values specified"
		exit 198
	}
/*
	Disentangle each varlist:string cluster
*/
	local i 1
	while `i'<=`ncl' {
		tokenize "`clust`i''", parse("=:")
		if "`2'"!=":" & "`2'"!="=" {
			if `i'>1 {
				noi di in red /*
				 */ "invalid `tname'() value `clust`i''" /*
				 */ ", must be first item"
				exit 198
			}
			local 2 ":"
			local 3 `1'
			local j 0
			local 1
			while `j'<`nx' {
				local j=`j'+1
				local 1 `1' `n`j''
			}
		}
		local arg3 `3'

		unabbrev `1'
		tokenize `s(varlist)'
		while "`1'"!="" {
			frac_in `1' "`rhs'"
			local val`s(k)' `arg3'
			mac shift
		}
		local i = `i'+1
	}
* transfer values to $S_*
	local j 0
	while `j'<`nx' {
		local j=`j'+1
		global S_`j' `val`j''
	}
}
end
