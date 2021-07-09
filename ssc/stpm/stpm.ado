*! version 1.3.2 PR 12jul2007
* stpm with orthogonalised spline basis
program define stpm, eclass sortpreserve
version 8.1
local trim0 = trim(`"`0'"')
if `"`trim0'"'=="" | `"`trim0'"'=="," {
	if "`e(cmd2)'"!="stpm" {
		error 301
	}
	if e(nomodel)==0 {
		ml display
	}
	di as txt "Deviance = " %9.3f as res e(dev) as txt " (" as res e(n) as txt " observations.)"
	exit
}
st_is 2 analysis
syntax [varlist(default=none)] [if] [in], SCale(string) [ all BKnots(string) noCONStant ///
 CLuster(varname) DF(int 0) EBASis(string) Index(string) Knots(string) LBASis(string) noLOg ///
 LEft(varname) MLmaxopts(string asis) OBASis(string) OFFset(varname) noORTHog PREfix(string) ///
 Q(string) ROBust SBASis(string) STPMDF(int 0) STratify(varlist) SUff(string) SPline(varlist) ///
 TEChnique(passthru) THeta(string) Unique ]

if `stpmdf'>0 {
	local df `stpmdf'
}
if `df'==1 {	/* orthog not applicable */
	local orthog noorthog
}

if "`orthog'"=="noorthog" {
	local orthog
}
else {
	local orthog orthog
	if `df'>1 & "`q'"=="" & "`sbasis'"!="" {
		di as err "q() required with sbasis() unless noorthog was specified"
		exit 198
	}
	if `df'>1 & "`q'"=="" & "`spline'"!="" {
		di as err "q() required with spline() unless noorthog was specified"
		exit 198
	}
	if "`q'"!="" {
		confirm matrix `q'
	}
}
* key st chars

local id: char _dta[st_id]
local wt: char _dta[st_w]      /* weight = exp */

local time _t
local dead _d
if `df'>0 & "`spline'"!="" {
	di as txt "[df() ignored since spline() specified]"
}
if "`stratify'"!="" {
	local nstrat: word count `stratify'
}
local Scale `scale'
local scale=lower("`scale'")
local l=length("`scale'")
if "`scale'"==substr("hazard",1,`l') {
	local scale 0/* ln cumulative hazard scale */
}
else if "`scale'"==substr("normal",1,`l') {
	local scale 1/* cumulative Normal scale */
}
else if "`scale'"==substr("odds",1,`l') {
	local scale 2/* log odds scale */
}
else {
	di as err "invalid scale(`Scale')"
	exit 198
}
if "`scale'"!="2" & "`theta'"!="" {
	di as txt "[theta ignored, only applies to scale(odds)]"
	local theta
}
local th_est 0
if "`theta'"!="" {
	if lower(substr("`theta'",1,3))=="est" {
		local th_est 1
	}
	else {
		confirm num `theta'
	}
}
global S_H=("`scale'"=="0")
global S_L=("`scale'"=="2")
/*
	If sbasis is specified, then the spline basis is provided in it and
	knots and boundary knots are not needed. The model dimension (df) is
	derived from sbasis. obasis() is needed too if df>1.
*/
local hasbas=("`sbasis'"!="")
if `hasbas' {
	if `df'>1 | "`knots'"!="" | "`bknots'"!="" {
		di as err "df(), knots() and bknots() invalid with sbasis()"
		exit 198
	}
	local df: word count `sbasis'
	if `df'>1 {
		local obdf: word count `obasis'
		if (`df'-`obdf')!=1 {
			`d' di as err "invalid obasis()"
			exit 198
		}
	}
}
else {
	if "`knots'"!="" {
		if `df'>0 {
			di as err "cannot specify both df() and knots()"
			exit 198
		}
		local knots=trim("`knots'")
		local kf=lower(substr("`knots'",1,1))
		if "`kf'"=="%" | "`kf'"=="u" | "`kf'"=="l" {
			local knots=substr("`knots'",2,.)
			if "`kf'"=="%" {
				local pct `knots'
				local nk: word count `knots'
			}
			else if "`kf'"=="u" {     /* U[a,b] knots distribution */
				tokenize `knots'
				confirm integer number `1'
				confirm number `2'
				confirm number `3'
				local nk `1'
				local a=`2'/100
				local b=`3'/100
				local pct
				local i 1
				while `i'<=`nk' {
					local P=100*(`a'+(`b'-`a')*uniform())
					frac_ddp `P' 2
					local pct `pct' `r(ddp)'
					local i=`i'+1
				}
				listsort "`pct'"
				local pct `s(list)'
				}
				else if "`kf'"=="l" {     /* convenience log transformation */
				local nk: word count `knots'
				tokenize `knots'
				local knots
				local i 1
				while `i'<=`nk' {
					local knot=ln(``i'')
					noisily confirm number `knot'
					frac_ddp `knot' 6
					local knots `knots' `r(ddp)'
					local i=`i'+1
				}
			}
		}
		else {
			local nk: word count `knots'
		}
		local df=1+`nk'
	}
	else if (`df'<1 | `df'>6) & "`spline'"=="" {
		di as err "option df(#) required, # must be between 1 and 6"
		exit 198
	}
}
if "`suff'"=="" {
	local suff _np
}
if "`prefix'"=="" {
	local prefix "I__"
}
local All `all'
if "`all'" == "" { 
	local all `"`if' `in'"'
}
else	local all
quietly {
	marksample touse
	markout `touse' `varlist' `left' `stratify' `offset' `spline'
	replace `touse'=0 if _st==0   /* exclude obs excluded by -stset- */
	tempvar S Sadj Z Zhat t dZdy lnt0 lint
	gen double `t'=ln(`time') `all'
	if "`left'"!="" {
		confirm var `left'
		count if `touse'==1 & `left'!=. & `left'>`time'
		if r(N)>0 {
			noi di as err "`left'>`time' in some observations"
			exit 198
		}
	}
	count if `touse'
	local nobs=r(N)
	count if `touse' & `dead'==1
	local events=r(N)
	local d dead(`dead')
	tempname coef dev dof
	sum _t0 if `touse'
	if r(max)>0 {
		/* late entry */
		if "`left'"!="" {
			noi di as err "cannot have both interval censoring and late entry"
			exit 198
		}
		gen double `lnt0'=cond(_t0>0, ln(_t0), .) `all'
		local late 1
	}
	else local late 0
	* For robust starting values, fit Cox model, centre linear predictor and refit
	tempvar coxindex
	stcox `varlist' if `touse'
	predict `coxindex', xb
	sum `coxindex'
	replace `coxindex'=`coxindex'-r(mean)
	stcox `coxindex' if `touse', basechazard(`S') /* basesurv fails with late entry */
	replace `S'=exp(-`S')
	predict double `Sadj' if `touse', hr
	replace `Sadj'=`S'^`Sadj' if `touse'
	if $S_H {
		local fname "log cumulative hazard"
		gen double `Z'=ln(-ln(`Sadj'))
	}
	else if $S_L {
		local fname "log odds of failure"
		gen double `Z'=ln((1-`Sadj')/`Sadj')
	}
	else {
		local fname "Normal quantile"
		gen double `Z'=invnorm((`nobs'*(1-`Sadj')-3/8)/(`nobs'+1/4))
	}
	if "`offset'"!="" {
		replace `Z'=`Z'-`offset'
		global S_offset `offset'
	}
	else global S_offset
	if `hasbas' | "`spline'"!="" {
		local v `sbasis'
		if `df'>1 {
			local o `obasis'
		}
		else local o
		if "`orthog'"=="orthog" & `df'>1 {
			tempname Q
			matrix `Q'=`q'
			local hasQ  q(`Q')
		}
	}
	else {
		cap drop `prefix'b`index'*
		if `df'==1 {
			local v `prefix'b`index'_0
			gen double `v'=`t'
		}
		else {
			local kk
			if "`bknots'"!="" {
				local k0: word 1 of `bknots'
				local kN: word 2 of `bknots'
				conf num `k0'
				conf num `kN'
				if "`k0'"=="" | "`kN'"=="" | `k0'>=`kN' {
					noi di as err "invalid bknots()"
					exit 198
				}
			}
			else {
				sum `t' if `dead'==1, meanonly
				local k0=r(min)
				local kN=r(max)
			}
			if "`knots'"!="" & "`pct'"=="" {
				tokenize `knots'
				local i 1
				while "``i''"!="" {
					local kk `kk' ``i''
					local i=`i'+1
				}
			}
			else {
				if "`pct'"=="" {
					if      `df'==2 {
						local pct 50
					}
					else if `df'==3 {
						local pct 33 67
					}
					else if `df'==4 {
						local pct 25 50 75
					}
					else if `df'==5 {
						local pct 20 40 60 80
					}
					else if `df'==6 {
						local pct 17 33 50 67 83
					}
				}
				if "`unique'"!="" {
					tempvar tun
					sort `time'
					gen double `tun'=`t'
					by `time': replace `tun'=. if _n>1
					local tuse `tun'
				}
				else local tuse `t'
				listsort "`pct'"
				local pct `s(list)'
				_pctile `tuse' if `dead'==1, p(`pct')
				local nq: word count `pct'
				local i 1
				while `i'<=`nq' {
					local k=r(r`i')
					local kk `kk' `k'
					local i=`i'+1
				}
				if "`unique'"!="" {
					drop `tun'
				}
			}
			* Create basis functions
			frac_spl `t' `kk' if `touse', `orthog' name(`prefix'b`index') deg(3) bknots(`k0' `kN') `All'
			local k `r(knots)'
			local v `r(names)'
			if "`orthog'"=="orthog" {
				tempname Q
				matrix `Q'=r(Q)
				local hasQ  q(`Q')
			}
			cap drop `prefix'c`index'*
			* First derivatives of basis functions
			frac_s3b `t', k(`k') bknots(`k0' `kN') name(`prefix'c`index') `hasQ'
			local o `r(names)'
		}
	}
	tempname init xbinit
	if "`spline'"=="" {
		local spvars `v'
	}
	if "`varlist'"!="" {
		_rmcoll `varlist' if `touse', `constant'
		local vl `r(varlist)'
	}
	else local vl
	if "`varlist'"!="`vl'" {
		noi di as txt "[Note: collinearity detected, variable(s) removed from model]"

	}
	regress `Z' `spvars' `vl' if `dead'==1 `wt', `constant'
	matrix `coef'=e(b)
	if `df'>1 {
		* check for non-monotonicity of fitted spline by predicting spline
		* and looking for negative first differences
		tempvar spfit diff
		local spvar `prefix'b`index'
		gen double `spfit'=0
		local df1=`df'-1
		forvalues j=0/`df1' {
			cap replace `spfit'=`spfit'+_b[`spvar'_`j']*`spvar'_`j'
		}
		sort `touse' `t'
		gen double `diff'=`spfit'-`spfit'[_n-1]
		sum `diff' if `touse'
		if r(min)<0 {
			di as text "[Warning: initially estimated spline is non-monotonic]"
			* replace spline basis fns with zero and re-estimate remaining coeffs.
			forvalues j=1/`df1'{
				tempvar ib`j'
				gen double `ib`j''=`spvar'_`j'
				replace `spvar'_`j'=0 if `touse'
			}
			regress `Z' `spvars' `vl' if `dead'==1 `wt', `constant'
			matrix `coef'=e(b)
			* restore spline basis fns
			forval j=1/`df1' {
				replace `spvar'_`j'=`ib`j''
				drop `ib`j''
			}
		}
		drop `spfit' `diff'
	}
	if "`spline'"=="" {
		if "`stratify'"!="" {
			local j 1
			while `j'<=`df' {
				local bin 0
				local i 2
				while `i'<=`nstrat' {
					local bin "`bin',0"
					local i=`i'+1
				}
				local b=`coef'[1,`j']   /* spline coefficient */
				local bin `bin',`b'
				if `j'==1 {
					local sinit `bin'
				}
				else local sinit `sinit',`bin'
				local j=`j'+1
			}
			matrix `init'=(`sinit')
			if "`vl'"!="" {
				local x1: word 1 of `vl'
				matrix `xbinit'=`coef'[1,"`x1'"...]
			}
			else matrix `xbinit'=`coef'[1,"_cons"]
			matrix `init'=`init',`xbinit'
		}
		else matrix `init'=`coef'
	}
	else {	/* spline function given from outside */
		matrix `init'=`coef'
		local v: word 1 of `spline'/* fitted spline */
		local o: word 2 of `spline'/* first deriv */
	}
	if "`theta'"!="" & `th_est'==1 {      /* initial value for ln(theta) is 0 */
		matrix `init'=`init',0
	}
/*
	Use betas as initial values for ml
*/
	global S_dead `dead'
	global S_df `df'
	global S_sbasis `v'
	global S_obasis `o'
	global S_left ""
	global S_sb_t0 ""
	if "`left'"!="" {
		cap drop ML_ic
/*
	ML_ic:  -1 for interval censored obs (_d=1) with left boundary 0
				+1 for interval censored obs (_d=1) with left boundary >0

				 0 for point event-time or right-censored observation

*/
		gen byte ML_ic=0 if `touse'
		replace  ML_ic=1 if reldif(`left',`time')>5e-7 & `left'!=. & ML_ic!=.
		local intlate "(ML_ic==1 & _d==0)"
		replace  ML_ic=0 if `intlate' & `left'==0 /* treat as right-censored */
		count if `intlate'
		if r(N)>0 {
/*
	Conflict between interval- and right-censoring (left>0, _d=0).
	Such observations are treated as right-censored with late entry at `left'.

	However, DON'T change _t0 itself since that would conflict with original -stset-.

*/
			noi di in bl "[Note: " r(N) " non-zero left() observations" /*
			 */ " for which _d=0 treated as late entry]"
			if `late'==0 {
				gen double `lnt0'=ln(`left') if `intlate'
				local late 1
			}
			else {
				replace `lnt0'=ln(`left') if `intlate'
			}
			replace ML_ic=0 if `intlate'
		}
		replace ML_ic=-1 if ML_ic==1 & `left'==0
/*
	Check if any genuine interval censored obs remain
*/
		count if abs(ML_ic)==1
		if r(N)>0 {
			if "`lbasis'"=="" {
				gen double `lint'=ln(`left') if ML_ic==1
				cap drop `prefix'b`index'l*
				if `df'==1 {
					local v0 `prefix'b`index'l_0
					gen double `v0'=`lint'
					global S_left `v0'
				}
				else {
					* !! need to check if `hasQ' is always available
					frac_spl `lint' `k' if `touse', `orthog' name(`prefix'b`index'l) /*
					 */ deg(3) bknots(`k0' `kN') `hasQ' `All'
					global S_left `r(names)'
				}
				drop `lint'
			}
			else global S_left `lbasis'
		}
	}
	if `late' {
/*
	Note that dealing with late entry must following dealing with interval censoring,
	since interval censoring with _d=0 actually means late entry.
*/
		if "`ebasis'"=="" {
			cap drop `prefix'b`index't*
			if `df'==1 {
				local v0 `prefix'b`index't_0
				gen double `v0'=`lnt0'
				global S_sb_t0 `v0'
			}
			else {
				frac_spl `lnt0' `k' if `touse', `orthog' name(`prefix'b`index't) /*
				 */ deg(3) bknots(`k0' `kN') `hasQ' `All'
				global S_sb_t0 `r(names)'
			}
		}
		else global S_sb_t0 `ebasis'
	}
	local nomodel 0
	if "`varlist'"=="" & "`constant'"=="noconstant" {
		local xbeq
		if "`spline'"!="" & `th_est'==0 {
			local nomodel 1	 /* no params to estimate */

		}
	}
	else {
		local xbeq "(xb:`varlist', `constant')"
	}
	local speq
	if "`spline'"=="" {
/*
	Define one equation per spline term in `t'
*/
		global S_spline 0
		local speq (s0:`time'=`stratify')
		local i 1
		while `i'<`df' {
			local speq `speq' (s`i':`stratify')
			local i=`i'+1
		}
	}
	else {
		global S_spline 1
	}
	if "`theta'"=="" {
		global S_theta ""
	}
	else {
		if `th_est' {
			global S_theta .
			local thetaeq (lntheta:)
		}
		else global S_theta `theta'
	}
	if `nomodel' {
/*
	Compute likelihood only, no estimation needed.
*/
		tempvar ll xb
		gen double `ll'=0 if `touse'
		gen double `xb'=0 if `touse'
		mlsurvlf `ll' `xb'
		sum `ll' if `touse' `wt', meanonly
		scalar `dev'=-2*r(sum)
		scalar `dof'=0
	}
	else {
		ml model lf mlsurvlf `speq' `xbeq' `thetaeq' if `touse' `wt', `technique' cluster(`cluster') `robust'
/*
	Initial values
*/
		ml init `init', copy
		ml query
		noisily ml maximize, `mlmaxopts' `log' noout
		capture test [xb]
		if _rc==0 {
			ereturn scalar chi2 = r(chi2)
			ereturn scalar p = r(p)
			ereturn scalar df_m = r(df)
		}
		scalar `dev'=-2*e(ll)
		scalar `dof'=e(k)
		if "`left'"!="" {
			drop ML_ic
		}
		cap drop _ML*
		noisily ml display	/* !! PR bug fix */
	}
}
di as txt "Deviance = " %9.3f as res `dev' as txt " (" as res `nobs' as txt " observations.)"
if `scale'==0 {
	local cscale cumhazard
}
else if `scale'==1 {
	local cscale normal
}
else if `scale'==2 {
	local cscale cumodds
}
ereturn scalar df=`df'
ereturn scalar dev=`dev'
ereturn scalar aic=`dev'+2*`dof'
ereturn scalar bic=`dev'+ln(`events')*`dof'
ereturn scalar n=`nobs'
ereturn scalar k=`dof'
ereturn scalar ll=-`dev'/2
ereturn scalar scale=`scale'
ereturn scalar nomodel=`nomodel'
if "`theta'"!="" {
	if `th_est' {
		ereturn scalar theta=exp([lntheta]_b[_cons])
	}
	else ereturn scalar theta=`theta'
}
else ereturn scalar theta=1
if "`orthog'"=="orthog" & "`spline'"=="" {
	ereturn matrix Q `Q'
}
ereturn local cscale `cscale'
ereturn local knots `kk'
ereturn local bknots `k0' `kN'
ereturn local pct `pct'
ereturn local fvl `vl'
ereturn local strat `stratify'
ereturn local left `left'
ereturn local sbasis `v'
ereturn local obasis `o'
ereturn local lbasis $S_left
ereturn local ebasis $S_sb_t0
ereturn local offset `offset'
ereturn local orthog `orthog'
ereturn local predict "stpm_p"
ereturn local cmd2 stpm
end

*! version 1.0.0 PR 16Feb2001.
program define listsort, sclass
version 6
gettoken p 0 : 0, parse(" ,")
if `"`p'"'=="" {
	exit
}
sret clear
syntax , [ Reverse Lexicographic ]
local lex="`lexicog'"!=""
if "`reverse'"!="" {
	local comp <
}
else local comp >
local np: word count `p'
local i 1
while `i'<=`np' {
	local p`i': word `i' of `p'
	if !`lex' {
		confirm number `p`i''
	}
	local i=`i'+1
}
* Apply shell sort (Kernighan & Ritchie p 58)
local gap=int(`np'/2)
while `gap'>0 {
	local i `gap'
	while `i'<`np' {
		local j=`i'-`gap'
		while `j'>=0 {
			local j1=`j'+1
			local j2=`j'+`gap'+1
			if `lex' {
				local swap=(`"`p`j1''"' `comp' `"`p`j2''"')
			}
			else local swap=(`p`j1'' `comp' `p`j2'')

			if `swap' {
				local temp `p`j1''
				local p`j1' `p`j2''
				local p`j2' `temp'
			}
			local j=`j'-`gap'
		}
		local i=`i'+1
	}
	local gap=int(`gap'/2)
}
local p
local i 1
while `i'<=`np' {
	sret local i`i' `p`i''
	local p `p' `p`i''
	local i=`i'+1
}
sret local list `p'
end
