*! version 2.1.2 PR 31oct2012
program define mfpigen, eclass 
	version 11.0
	local cmdline : copy local 0
	mata: _parse_colon("hascolon", "rhscmd")	// _parse_colon() is stored in _parse_colon.mo
	if !`hascolon' error 198

	_mfpigen `"`0'"' `"`rhscmd'"'
	ereturn local varlist `r(covars)' // covariates in final fitted interaction model

	// ereturn cmdline overwrites e(cmdline) from _mfpigen
	ereturn local cmdline `"mfpigen `cmdline'"'
end

program define _mfpigen, rclass
version 11.0
args 0 statacmd

gettoken cmd statacmd: statacmd
xfrac_chk `cmd'
if `s(bad)' { 
	di as err "invalid or unrecognised command, `cmd'"
	exit 198
}
local dist `s(dist)'
local normal = (`dist'==0)
global MFpdist `dist'

// Parse mfpigen options from first argument
syntax [ , nomfp LINadj(varlist fv) MFPAdj(varlist fv) AGainst(varname) ALpha(passthru) DEAD(varname) df(string) ///
 FPLot(string) OUTcome(string) PLOTopts(string) PValue(real 1) REStrict(string) se SELect(string) SHOWmfp ///
 INTeractions(string) noVERbose FORward(string) * ]

if "`forward'" != "" {
	if "`df'" != "" & "`df'" != "1" {
		di as err "invalid df(`df'), forward() requires df(1)"
		exit 198
	}
	local df 1
	di as txt "[Note: only linear terms considered in main effects and interaction models]"
	confirm number `forward'
	local verbose 0
}
else local verbose = ("`verbose'" != "noverbose")
local mfpopts `options'

if "`mfp'" == "nomfp" {
	if "`select'" != "" {
		di as err "may not specify select(`select') with nomfp"
		exit 198
	}
}
if "`fplot'" != "" {
	if ("`cmd'" == "mlogit") & (`"`outcome'"' == "") {
		noi di as err "you must specify outcome() with fplot()"
		exit 198
	}
	local percent = substr("`fplot'", 1, 1)
	if ("`percent'" == "%") local fplot = substr("`fplot'", 2, .)
	else local percent
	// If fplot() contains parentheses, get its items and expand them
	GetList "`fplot'"
	local nfplot = `r(count)'
	if (`nfplot' > 0 & `r(npar)' > 0) {
		forvalues i = 1 / `nfplot' {
			local fplot`i' `r(item`i')'
			if wordcount("`fplot`i''") != 2 {
				noi di as err "in fplot(), there must be exactly 2 items in each pair of parentheses"
				exit 198
			}
		}
		// Total #combinations of nfplot items is 2 ^ nfplot. Expand to correct fplot.
		local m = 2 ^ `nfplot'
		local fplot
		forvalues i = 1 / `m' {
			local i1 = `i' - 1
			// convert i-1 to string of binary digits, then substitute appropriate members of fplot
			converttobinary `i1', length(`nfplot')
			local bin `r(result)'
			forvalues j = 1 / `nfplot' {
				local index : word `j' of `bin'
				local index = `index' + 1
				local thing : word `index' of `fplot`j''
				local fplot `fplot' `thing' 
			}
		}
	}
}

// Parse to extract varlist (as `xlist') from statacmd
local 0 `statacmd'
syntax [anything(name=xlist)] [if] [in] [aw fw pw iw] [, DEAD(str) noCONStant * ]
if !missing("`dead'") local options `options' dead(`dead')
if !missing("`constant'") local options `options' `constant'

// Get variables to be used in interactions (not for adjustment - MFP or linear)
GetVL `xlist'

marksample touse
markout `touse' $MFP_cur `linadj' `mfpadj' `dead'
qui count if `touse'
local nobs = r(N)
frac_wgt "`exp'" `touse' "`weight'"
local wgt `r(wgt)'	// [`weight'`exp']
local nx $MFP_n	// number of clusters, <= number of predictors
local yvar $MFP_dv
local xvars
forvalues i = 1 / `nx' {
	local mfp`i' ${MFP_`i'}
	local w : word count `mfp`i''
	if (`w' > 1) local xvars `xvars' (`mfp`i'')
	else local xvars `xvars' `mfp`i''
	fvexpand `mfp`i''
	local isfactor`i' = ("`r(fvops)'" == "true")
}
// Consider all pairs of variables
if "`yvar'" == "" local y _t
else local y `yvar'
if `verbose' {
	di _n as txt "MFPIGEN - interaction analysis for dependent variable" as res " `y'" ///
	 as txt " (`nobs' observations)"
	di as txt "{hline 78}" _n "variable 1   function 1   variable 2   function 2  dev. diff.  d.f.    P   Sel"
	di as txt "{hline 78}"
}
quietly {
	local nx1 = `nx' - 1
	local stop 0
	if "`forward'" != "" {
		// `stop' is set to 1 when next interaction is not significant at P < `forward'
		local verbose 0
	}
	while !`stop' {
		local displayed 1
		local pmin 1

		// Get interactions and list of involved variables to be adjusted for into strings
		local IntAdj
		local intvarlist
		if "`interactions'" != "" {
			DisInter `interactions'
			local ninter = r(nitems)
			forvalues i = 1 / `ninter' {
				local things = r(nitem`i')
				if `things' != 2 {
					di as err "invalid interactions(), each interaction must have 2 items"
					exit 198
				}
				forvalues j = 1 / 2 {
					local int`i'`j' `r(item`i'`j')'
					if wordcount("`int`i'`j''") > 1 local int`i'`j' (`int`i'`j'')
					local isfac`i'`j' = r(isfactor`i'`j')
					// update list of vars involved in interaction and make their df = 1
					if strpos("`intvarlist'", "`int`i'`j''") == 0 {
						local intvarlist `intvarlist' `int`i'`j''
					}
				}
				if `isfac`i'1' {
					if (`isfac`i'2') local IntAdj `IntAdj' `int`i'1'##`int`i'2'
					else local IntAdj `IntAdj' `int`i'1'##c.(`int`i'2')
				}
				else {
					if (`isfac`i'2') local IntAdj `IntAdj' c.(`int`i'1')##`int`i'2'
					else local IntAdj `IntAdj' c.(`int`i'1')##c.(`int`i'2')
				}
			}
		}
		forvalues a = 1 / `nx1' {
			local v1 `mfp`a''
			// hasint1 flags that v1 is involved in a predefined interaction.
			local hasint1 = strpos("`intvarlist'", "`v1'")
			local nv1: word count `v1'
			local var1 = abbrev("`v1'", 12)
			if (`nv1' > 1) local v1 (`v1')
			local a1 = `a' + 1
			forvalues b = `a1' / `nx' {
				if (`b' == `a1') & (`a' > 1) & `displayed' & `verbose' noi di
				local v2 `mfp`b''
				local nv2: word count `v2'
				local var2 = abbrev("`v2'", 12)
				if (`nv2' > 1) local v2 (`v2')
				// hasint2 flags that v2 is involved in a predefined interaction.
				// It may or may not be the v1 x v2 interaction.
				local hasint2 = strpos("`intvarlist'", "`v2'")
				local displayed 0
/*
	Check if adjusting for v1 x v2 in the interactions() specification.
*/
				local hasint 0
				if `hasint1' & `hasint2' {
					forvalues i = 1 / `ninter' {
						if (("`v1'" == "`int`i'1'") & ("`v2'" == "`int`i'2'")) ///
						 | (("`v1'" == "`int`i'2'") & ("`v2'" == "`int`i'1'")) {
						 	local hasint 1
					 		continue, break
						}
					}
				}
				if `hasint' {
					if `verbose' {
						noi di as res  "`var1'" _col(27) "`var2'" ///
						 _col(49) "[interaction already included]"
						if (`b' == `nx') noi di
					}
					local var1
				}
				else {
					local vars: list xvars - v1
					local vars: list vars - v2
					if ("`select'"=="") local Select
					else local Select `select',
					if "`linadj'`IntAdj'"!="" {
						local Linadj linadj(`linadj' `IntAdj')
/*
						local Select `Select' `linadj' `IntAdj':1,
						if ("`df'" != "") local Df df(`df', `linadj' `IntAdj':1)
						else local Df df(`linadj' `IntAdj':1)
*/
					}
					local Select `Select' `v1' `v2':1
					if "`df'" != "" local Df `df'
					else local Df
					if "`Df'" != "" local Df df(`Df')
					// If select = 0 then don't consider other vars for selection, they are ignored
					if ("`mfp'"=="nomfp") local vl `mfpadj'
					else local vl `vars' `mfpadj'
					if "`showmfp'"!="" {
						if (`"`dead'`options'"'=="") local trail
						else local trail , `dead' `options'
						noi di as txt`"xmfp, select(`Select') `alpha' `Df' `Linadj' `mfpopts':"' ///
						`"`cmd' `yvar' `v1' `v2' `vl' `wgt'`trail'"'
					}
					xmfp, select(`Select') `alpha' `Df' `Linadj' `mfpopts' : ///
					 `cmd' `yvar' `v1' `v2' `vl' if `touse' `wgt', `dead' `options'
					if ("`showmfp'"!="") noisily xmfp
					// Get info on selected model for v1 and v2
					local dev0 = e(fp_dev)
					local model `e(fp_fvl)' `linadj' `IntAdj'
					local nobs = e(N)
					if "`cmd'" == "stpm2" local df_m = e(nxbterms) - e(dfbase) - 1
					else local df_m = e(df_m)
					local df_r = e(df_r)	// does not allow for FP df.
					local nvar = e(fp_nx)
					local nsel -2	// count #vars in selected model, excluding v1 and v2
					forvalues j = 1 / `nvar' {
						if ("`e(Fp_k`j')'" != ".") local ++nsel
					}
					local mcount 0
					forvalues j = 1 / 2 {
						local n`j'
						local nv`j' : word count `v`j''
						local p`j' `e(Fp_k`j')'
						local np`j' : word count `p`j''
						local jjn`j' = cond(`nv`j'' > 1, `nv`j'', `np`j'')
						forvalues k = 1 / `jjn`j'' {
							local jm = `k' + `mcount'
							local vv: word `jm' of `model'
							local n`j' `n`j'' `vv'
						}
						local mcount = `mcount' + `jjn`j''
						if "`p`j''" == "1" {
							local fun`j' "Linear"
							local shift`j' 0
							local scale`j' 1
						}
						else {
							qui fracgen `v`j'' `p`j'', nogen
							local fun`j' FP`np`j''(`p`j'')
							local shift`j' = r(shift)
							local scale`j' = r(scale)
						}
					}
					local xy	// macro to hold names of interaction variable(s)
					if `isfactor`a'' {
						local fun1 Factor
						local xy `n1'
					}
					else {
						if (`jjn1' > 1) local xy c.(`n1')
						else local xy c.`n1'
					}
					if `isfactor`b'' {
						local fun2 Factor
						local xy `xy'#`n2'
					}
					else {
						if (`jjn2' > 1) local xy `xy'#c.(`n2')
						else local xy `xy'#c.`n2'
					}
					`cmd' `yvar' `model' `xy' if `touse' `wgt', `dead' `options'
					local covars `model' `xy'
					if "`cmd'" == "stpm2" local df_m_int = e(nxbterms) - e(dfbase) - 1
					else local df_m_int = e(df_m)
					local dfxy = `df_m_int' - `df_m'
					local d = `dev0' - (-2 * e(ll))
					frac_pv `normal' "`wgt'" `nobs' `d' `dfxy' `df_r'
					local P = r(P)
					if `P' < `pmin' {
						local pmin `P'
						local v1min `v1'
						local v2min `v2'
						local amin `a'
						local bmin `b'
					}
					if `P' <= `pvalue' {
						if `verbose' {
							noi di as res "`var1'" _col(14) "`fun1'" _col(27) "`var2'" ///
							 _col(40) "`fun2'" _col(53) %8.4f `d' %6.0f `dfxy' %9.4f r(P) %3.0f `nsel'
						}
						local var1
						local displayed 1
					}
					// Plot interaction using fplot() values of x1, for last pair of variables
					if ("`percent'`fplot'" != "") & (`a' == `nx1') & (`b' == `nx') {
						local v1 `mfp`nx1''
						local v2 `mfp`nx''
						local secondvl = cond(`nv2' == 1, "`n2'", "`v2'")
						local nfplot: word count `fplot'
						if !inlist("`cmd'", "stcox", "cox", "clogit") local cons constant
						if `isfactor`nx'' & ("`against'" == "") {
							local against = substr("`v2'", 1 + strpos("`v2'", "."), .)
							confirm var `against'
						}
						noi di as txt _n "-> Fitted interaction model"
						if ("`e(cmd)'" == "cox") noi stcox, nohr
						else noi `cmd'
						if ("`against'"=="") local against : word 1 of `v2'
						if `isfactor`nx1'' {
							// Plots for chosen levels of factor variable
							local v1x = substr("`v1'", 1 + strpos("`v1'", "."), .) // name of factor var stripped of prefix
							if "`percent'" == "%" {
								noi di as txt "[note: plotting fit at observed factor levels]"
								levelsof `v1x'
								local fplot `r(levels)'
								local nfplot : word count `fplot'
							}
							local fits
							forvalues f = 1 / `nfplot' {
								local val: word `f' of `fplot'
								count if `touse' & (`v1x' == `val')
								if r(N) == 0 {
									noi di as txt "[no observations with `v1x' = `val', skipped]"
									continue
								}
								cap drop _tmp`i'
								clonevar _tmp`i' = `v1x'
								replace `v1x' = `val'
								cap drop _fit`f'
								xpredict _fit`f' if `touse', with(`v1' `secondvl' `xy') `cons'
								lab var _fit`f' "`v1x' = `val'"
								local fits `fits' _fit`f'
								if "`se'" != "" {
									cap drop _sefit`f'
									xpredict _sefit`f' if `touse', with(`v1' `secondvl' `xy') `cons' stdp
									lab var _sefit`f' "SE(fit) at `v1x' = `val'"
								}
								// Restore first of 2 interacting variables
								drop `v1x'
								rename _tmp`i' `v1x'
							}
						}
						else if `nv1' == 1 {
/*
	First item has just one member, assumed continuous.
	Need mean of v1 so that fracscalar can produce centered FP transformations.
	mfp centers by default.
*/
							sum `v1' if `touse'
							local meanv1 = r(mean)
							if "`percent'" != "" {
								if "`fplot'" == "" {
									noi di as txt "[note: plotting fit at 25 50 75 centiles of `v1']"
									local fplot 25 50 75
									local nfplot : word count `fplot'
								}
								centile `v1' if `touse', centile(`fplot')
								local fplot
								forvalues j = 1 / `nfplot' {
									local c = r(c_`j')
									local fplot `fplot' `c'
								}
							}
							local fits
							forvalues f = 1 / `nfplot' {
								local val: word `f' of `fplot'
								local disp_val = trim("`:di %6.0g `val''")
								// Compute FP transformation of `val' and substitute into appropriate variables
								fracscalar `val', powers(`p1') scale(`scale1') shift(`shift1') center(`meanv1')
								forvalues i = 1 / `np1' {
									local xa: word `i' of `n1'
									cap drop _tmp`i'
									clonevar _tmp`i' = `xa'
									replace `xa' = r(h`i')
								}
								cap drop _fit`f'
								xpredict _fit`f' if `touse', with(`n1' `secondvl' `xy') `cons'
								lab var _fit`f' "`v1' = `disp_val'"
								local fits `fits' _fit`f'
								if "`se'" != "" {
									cap drop _sefit`f'
									xpredict _sefit`f' if `touse', with(`n1' `secondvl' `xy') `cons' stdp
									lab var _sefit`f' "SE(fit) at `v1' = `disp_val'"
								}
								// Restore first of 2 interacting variables
								forvalues i = 1 / `np1' {
									local xa: word `i' of `n1'
									drop `xa'
									rename _tmp`i' `xa'
								}
							}
						}
						else {
							// First item has >1 members. 
							// Values in fplot are listed in variable order.
							local nlist = round(`nfplot' / `nv1')
							if "`percent'" != "" {
								if "`fplot'" == "" {
									noi di as txt "[note: plotting fit at 25 50 75 centiles of `v1']"
									local nlist 3
									forvalues f = 1 / `nlist' {
										local fplot `fplot' 25 50 75
									}
								}
								local vals
								local disp_vals
								forvalues f = 1 / `nlist' {
									forvalues i = 1 / `nv1' {
										local index = (`f' - 1) * `nv1' + `i'
										local val: word `index' of `fplot'
										local xa: word `i' of `v1'
										centile `xa' if `touse', centile(`val')
										local c = r(c_1)
										local vals `vals' `c'
										local disp_val = trim("`:di %6.0g `c''")
										local disp_vals `disp_vals' `disp_val'
									}
								}
								local fplot `vals'
							}
							local fits
							forvalues f = 1 / `nlist' {
								local disp_vals
								forvalues i = 1 / `nv1' {
									local index = (`f' - 1) * `nv1' + `i'
									local val: word `index' of `fplot'
									local disp_val = trim("`:di %6.0g `val''")
									local disp_vals `disp_vals' `disp_val'
									local xa: word `i' of `v1'
									cap drop _tmp`i'
									clonevar _tmp`i' = `xa'
									replace `xa' = `val'
								}
								cap drop _fit`f'
								xpredict _fit`f' if `touse', with(`v1' `secondvl' `xy') `cons'
								lab var _fit`f' "`v1' = `disp_vals'"
								local fits `fits' _fit`f'
								if "`se'" != "" {
									cap drop _sefit`f'
									xpredict _sefit`f' if `touse', with(`v1' `secondvl' `xy') `cons' stdp
									lab var _sefit`f' "SE(fit) at `v1' = `disp_vals'"
								}
								// Restore first of 2 interacting variables
								forvalues i = 1 / `nv1' {
									local xa: word `i' of `v1'
									drop `xa'
									rename _tmp`i' `xa'
								}
							}
						}
						preserve
						bysort `against' : drop if _n > 1
						line `fits' `against' `restrict', sort title("Sliced plot of `against' by `v1'") ytitle(`e(depvar)') `plotopts'
						restore
					}
				}
			}
		}
		if "`forward'" !="" {
			local va `v1min'
			if (`isfactor`amin'' & substr("`v1min'", 1, 2) != "i.") local va i.`v1min'
			local vb `v2min'
			if (`isfactor`bmin'' & substr("`v2min'", 1, 2) != "i.") local vb i.`v2min'
			noi di as txt "Smallest P-value (" as res %9.0g `pmin' as txt " ) is for " as res "`va' # `vb'"
			if `pmin' > `forward' {
				local stop 1
				noi di as txt "Stopping as last-named interaction is not significant at the `forward' level"
				if "`interactions'" == "" noi di as txt "No interactions selected."
				else noi di as txt "Interactions selected = `interactions'"
			}
			else {
				if "`interactions'" == "" local interactions `va' `vb'
				else local interactions `interactions',`va' `vb'
			}
		}
		else local stop 1
	}
}
if `verbose' {
	di as txt "{hline 78}" _n "Sel = number of variables selected in MFP adjustment model"
}
if "`forward'" == "" {
	di as txt "Smallest P-value (" as res %9.0g `pmin' as txt " ) is for " as res "`v1min' # `v2min'"
}
return local covars `covars'
return local interactions `interactions'
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
		error 102
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

program define fracscalar, rclass
version 10.0
/*
	Return FP transformation of scalar or local argument.
	`powers' contains FP powers in any order.
*/
	syntax anything(name = x id = "value"), Powers(numlist) ///
	 [ SHift(real 0) SCale(real 1) EXpx(string) CEnter(string) ]
	tempname small fp h hlast lnx plast xs
	cap scalar `xs' = (`x' + `shift') / `scale'
	if c(rc) {
		di as err "`x' invalid value"
		exit 198
	}
	if (`xs' <= 0) & ("`powers'" != "1") {
		di as err "after applying {opt shift()}, number must be positive - it equals " `x' + `shift'
		exit 198
	}
	local adjust `center'
	listsort3 "`powers'"
	local np `s(np)'
	forvalues j = 1 / `np' {
		local i `s(index`j')'
		local p`j' : word `i' of `powers'
	}
	scalar `small' = 1e-6
	local replace local
	local gen local
	if "`expx'" != "" {
		confirm number `expx'
		scalar `xs' = exp(`expx' * `xs')
	}
	scalar `lnx' = log(`xs')
	scalar `h' = .
	scalar `hlast' = 1
	scalar `plast' = 0
	if "`adjust'" != "" {
		confirm number `adjust'
		tempname adj
		scalar `adj' = (`adjust' + `shift') / `scale'
		if "`expx'" != "" scalar `adj' = exp(`expx' * `adj')
		tempname a alast lna
		scalar `lna' = log(`adj')
		scalar `a' = .
		scalar `alast' = 1
	}
	else {
		tempname a
		scalar `a' = 0
	}
	forvalues j = 1 / `np' {
		scalar `h' = cond(abs(`p`j'' - `plast') < `small', `lnx' * `hlast', ///
		        cond(abs(`p`j'') < `small', `lnx', ///
		        cond(abs(`p`j'' - 1) < `small', `xs', ///
		        cond(`xs' == 0, 0, `xs' ^ `p`j'') )))
		if "`adjust'" != "" {
			scalar `a' = cond(abs(`p`j'' - `plast') < `small', ///
			    `lna' * `alast', ///
			    cond(abs(`p`j'') < `small', `lna', ///
			    cond(abs(`p`j'' - 1) < `small', `adj', ///
			    cond(`adj' <= 0, 0, `adj' ^ `p`j'') )))
			scalar `alast' = `a'
		}
		return scalar h`j' = `h' - `a'
		scalar `hlast' = `h'
		scalar `plast' = `p`j''
	}
end

program define listsort3, sclass sortpreserve
version 9.2
gettoken p 0 : 0, parse(" ,")
if `"`p'"'=="" exit
sret clear
syntax , [ Reverse Lexicographic ]
local lex="`lexicographic'"!=""
if "`reverse'"!="" local comp <
else local comp >
/*
	Need to ensure that we always get the same ranking of
	amounts of missingness. To do this, add (i-1)/(#missings)
	to each amount.
*/
local np: word count `p'
tempvar c rank
qui gen `c'=.
forvalues i=1/`np' {
	local pi: word `i' of `p'
	if !`lex' confirm number `pi'
	qui replace `c'=`pi'+(`i'-1)/`np' in `i'
}
qui egen long `rank'=rank(`c')
forvalues i=1/`np' {
/*
	Find original position (antirank) of each rank
*/
	local j 0
	while `j'<`np' {
		local ++j
		if `i'==`rank'[`j'] {
			local index`i' `j'
			local j `np'
		}
	}
}
forvalues i=1/`np' {
	sret local index`i' `index`i''
	local index `index' `index`i''
}
sret local index `index'
sret local np `np'
end

program define GetList, rclass
	local xlist `0'
	local count 0
	local npar 0
	gettoken xvar xlist : xlist, parse("()") match(par)
	local result
	while (`"`xvar'"'!="") {
		local nvar : word count `xvar'
		if ("`par'"!="" | `nvar'==1) {
			local ++count
			if ("`par'"!="") local ++npar
			local item`count' "`xvar'"
			local current "`current' `xvar'"
		}
		else {
			tokenize `xvar'
			forvalues i = 1 / `nvar' {
				local ++count
				local item`count' "``i''"
				local current "`current' ``i''"
			}
		}
		gettoken xvar xlist : xlist, parse("()") match(par)
		if ("`par'"=="(" & `"`xvar'"'=="") {
			di as err "empty () found"
			exit 198
		}
	}
	if (`npar' > 0) & (`npar' != `count') {
		noi di as err "either all items or no items in fplot() must be enclosed in parentheses"
		exit 198
	}
	forvalues i = 1 / `count' {
		return local item`i' `item`i''
	}
	return local count `count'
	return local npar `npar'
end

program define converttobinary, rclass
syntax anything [, Length(int 0) ]
// Convert integer `anything' to a binary string
confirm integer number `anything'
if (`anything' == 0) {
	local result 0
	local count 1
}
else {
	local count 0
	while (`anything' > 0) {
		local rem = mod(`anything', 2)
		local result `rem' `result'
		local anything = int(`anything' / 2)
		local ++count
	}
}
if (`length' > 0) {
	// Pad front of string with zeroes
	local todo = `length' - `count'
	forvalues i = 1 / `todo' {
		local result 0 `result'
	}
}
*di as txt "result = " as res "`result'"
return local result `result'
end

program define DisInter, rclass
version 11.0
tokenize `"`*'"', parse(",")
local nitem 0
while "`1'"!="" {
	if "`1'"!="," {
		local ++nitem
		local Item`nitem' `1'
	}
	mac shift
}
forvalues i = 1 / `nitem' {
	// Sort out bound partners
	local lsep "("
	local rsep ")"
	tokenize `Item`i'', parse("# `lsep'`rsep'")
	local linear
	local lparen 0
	local cat
	local ncat 0
	while "`1'"!="" {
		if "`1'"=="#" mac shift
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
			fvunab item`ncat' : `cat'
			fvexpand `item`ncat''
			local isfactor`ncat' = ("`r(fvops)'" == "true")
			local haspar`ncat' 1
			local cat
			local lparen 0
		}
		else {
			if `lparen'==0 {
				fvunab one: `1'
				local none : word count `one'
				forvalues j = 1 / `none' {
					local thing : word `j' of `one'
					local ++ncat
					fvunab item`ncat': `thing'
					fvexpand `item`ncat''
					local isfactor`ncat' = ("`r(fvops)'" == "true")
					local haspar`ncat' 0
				}
			}
			else local cat `cat' `1'
		}
		mac shift
	}
	if `lparen' {
		noi di as err "unexpected `rsep' in linear()"
		exit 198
	}
	forvalues j = 1 / `ncat' {
		return local item`i'`j' `item`j''
		return scalar isfactor`i'`j' = `isfactor`j''
		return scalar haspar`i'`j' = `haspar`j''
	}
	return scalar nitem`i' = `ncat'
}
return scalar nitems = `nitem' 
end
