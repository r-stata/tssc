*! version 6.0.0 PR 26nov2008
program define xriml, eclass
version 8
if "`*'"=="" | substr("`1'",1,1)=="," { 
	ml display
	exit
}
local hidopts "EXpx(str) ORIgin(str) Zero noTIdy TRace ZCI PARam(str)"
syntax varlist(min=1 max=2) [if] [in] [aweight fweight], DIst(str) [FP(str) /*
 */ CEns(varname numeric) COVArs(str) CV noGRaph noLEAve noOUTofsample /*
 */ CEntile(numlist >0 <100) restrict(string) SE noSCALing LTolerance(real .001) INit(str) /*
 */ SCATter(str asis) plot(str asis) OFFset(varname) `hidopts' *]
local small 1e-6
if "`cens'"=="" global S_cens
else global S_cens `cens'
if "`scaling'"!="noscaling" local showtsf "noi"
else local showtsf "qui"
if "`centile'"=="" local centile "3 97"
tokenize `centile'
local i 0
while "`1'"!="" {
	if "`1'"!="," {
		local ++i
		local c`i' `1'
	}
	mac shift
}
local nc `i'
local dist = lower(substr("`dist'",1,2))
if "`dist'"=="n"|"`dist'"=="no" {
	local dnum 0
	local dist n
}
else {
	local d= 1*("`dist'"=="sl")+2*("`dist'"=="pn")+3*("`dist'"=="en") /*
	 */     +4*("`dist'"=="eg")+7*("`dist'"=="mp")+8*("`dist'"=="me")
	if `d'==0 {
		di as err "invalid distribution `dist'"
		exit 198
	}
	local dnum `d'
}
if "`weight'"!="" & `dnum'!=0 &`dnum'!=1 & `dnum'!=2 & `dnum'!=3 & `dnum'!=4 & `dnum'!=7 & `dnum'!=8 {
	di as err "weights not yet implemented for dist(`dist')"
	exit 198
}
local pars3=(`dnum'>=3)
local pars4=(`dnum'>=5)
if `dnum'>0 {
	local gamma "g"
}
if `pars4' {
	local delta "d"
}
local dupper=upper("`dist'")
local dt0 "Normal"
local dt1 "Shifted Log-Normal"
local dt2 "Power-Normal"
local dt3 "Exponential-Normal"
local dt4 "Exponential-Gamma"
local dt7 "Modulus power-Normal"
local dt8 "Modulus exp-Normal"
if "`expx'"!="" local expx "expx(`expx')"
if "`origin'"!="" local origin "origin(`origin')"
if "`detail'"!="" local detail "noisily"
if "`cv'"!="" local cv "cv"

if "`param'"!="" {
	tokenize `param'
	while "`1'"!="" {
		local fl=lower(substr("`1'",1,2))
		if "`fl'"=="cv" 	local cv "cv"
		else if "`fl'"=="ln" 	local lns "lns"
		else if "`fl'"=="ta" 	local tau "tau"
		else if "`fl'"=="tr" 	local trunc "trunc"
		else {
			di as err "invalid param() option `1'"
			exit 198
		}
		mac shift
	}
}
/*
	Extract base variables for each parameter
*/
_jprxrpa "`covars'" ms`gamma'`delta' "covariates"
local ncl $S_1
forvalues i=1/`ncl' {
	local curve ${S_p`i'}
	local `curve'base "${S_c`i'}" /* basevars */
}
/*
	Parameter initialisation: gamma (& delta) only at present
*/
_jprxrpa "`init'" `gamma'`delta' initializations
local ncl $S_1 /* ncl is at most 2, but following code is general */
forvalues i=1/`ncl' {
	local curve ${S_p`i'}
	local init "${S_c`i'}"
/*
	!! ? Can be initialised with a var or a num
*/
	cap confirm var `init'
	if _rc confirm num `init'
	local `curve'init `init'
}
/*
	Default initial shape params depend on distribution
*/
if "`ginit'"=="" {
	local ginit 0
	if `dnum'==0		{ /* normal */
		local ginit 1
		local gfix "gfix"
	}
	else if `dnum'==2	local ginit 0.5  /* PG  */
	else if `dnum'==3	local ginit 0.01 /* EN  */
	else if `dnum'==4	local ginit 0.25 /* EG  */
	else if `dnum'==7	local ginit 1    /* MPN */
	else if `dnum'==8	local ginit -0.2 /* MEN */
}
if "`dinit'"=="" & `pars4' {
	if `dnum'==7 | `dnum'==8 { /* MPN, MEN */
		local dinit 1
	}
	else local dinit 0
}

tokenize `varlist'
tempvar y M Z
local lhs `1'
local rhs `2'
marksample touse
markout `touse' `lhs' `rhs' `cens' `mbase' `sbase' `gbase' `dbase'
/*
	Out-of-sample prediction is done automatically for all 
	observed values of x and y, unless -nooutofsample- is specified.
*/
tempvar touse_user
if "`outofsample'" == "nooutofsample" {
	qui gen byte `touse_user' = `touse'
}
else qui gen byte `touse_user' = 1
local if_touse_user "if `touse_user'"

quietly if "`weight'"!="" {
	cap drop __wt
	gen __wt `exp' if `touse'
	if "`weight'"=="aweight" {
		sum __wt, meanonly
		replace __wt=__wt/r(mean)
	}
	global S_wt __wt
	local wtd "Weighted "
}
else global S_wt
/*
	Extract FP model specifications.
*/
_jprxrpa "`fp'" ms`gamma'`delta' "FP model items"
local ncl $S_1 /* could be 0 */
forvalues i=1/`ncl' {
	local curve ${S_p`i'}
	local spec "${S_c`i'}"
	tokenize `spec'
	local first = lower("`1'")
	if "`first'"=="fix" {
		if "`curve'"=="m" | "`curve'"=="s" {
			di as err "invalid `spec'"
			exit 198
		}
		local `curve'fix "`curve'fix"
		mac shift
		if "`*'"!="" {
			cap confirm var `*'
			if _rc confirm num `*'
			local `curve'init `*'
		}
	}
	else {
		if "`rhs'"=="" {
			di as err "no xvar, cannot specify FP model"
			exit 198
		}
		if "`first'"=="powers" mac shift
		`showtsf' fracgen `rhs' `*' `if_touse_user', `scaling' ///
		 name(X`curve') replace `expx' `origin' `zero' adjust(mean)
		local `curve'vars `r(names)'
		local `curve'fixpow `*'
	}
}
/*
	Next 6 stmts set globals for use by _`dist'll.ado.
	Possibly could be made into _dta chars.
*/
global S_trunc = "`trunc'"!=""
global S_cv = "`cv'"!=""
global S_tau = "`tau'"!=""
global S_lns = "`lns'"!=""
global S_gamma `ginit'
global S_delta `dinit'
global S_dist `dist' /* for default use by centcalc and centcal2 */
global S_gfix = "`gfix'"!=""
global S_dfix = "`dfix'"!=""
global S_off `offset'	/* offset for M-curve only */
quietly {
/*
	Calculate and set up initial parameter values for ML fitting
	!! needs thought about how/if to incorporate initialisation for M and S
*/
	tempname s g d mu b f V
	cap eq drop D
	cap eq drop G
	cap eq drop S
	cap eq drop M
	eq M : `lhs' `mvars' `mbase'
	eq S : `svars' `sbase'

	regress `lhs' `mvars' `mbase' if `touse', nohead
	matrix `mu' = get(_b)
	matrix colnames `mu' = M:
	if "`absres'"!="" {
		local scale = e(rmse) /* initialisation of sigma (_cons) */
		if "`cv'"!="" { /* CV parametrization */
			sum `lhs' if `touse'
			local scale = `scale'/r(mean)
		}
		if "`lns'"!="" local scale = ln(`scale')
		matrix `s' = (`scale')
		matrix colnames `s' = S:_cons
	}
	else {
/*
	Initialize S via absolute residuals
*/
		predict `M' `if_touse_user'
		if "`lns'"!="" {
/*
	-1.96... is digamma(0.5), Abramowitz & Stegun p258
*/
			scalar `f' = -0.5*(-1.963510026+ln(2))
			if "`cv'"!="" {
				gen `Z' = ln(abs(`lhs'/`M'-1))+`f'
			}
			else {
				gen `Z' = ln(abs(`lhs'-`M'))+`f'
			}
		}
		else {
			scalar `f' = sqrt(_pi/2)
			if "`cv'"!="" {
				gen `Z' = `f'*abs(`lhs'/`M'-1)
			}
			else {
				gen `Z' = `f'*abs(`lhs'-`M')
			}
		}
		regress `Z' `svars' `sbase' if `touse', nohead
		matrix `s' = get(_b)
		matrix colnames `s' = S:
		drop `M' `Z'
	}
	matrix `mu' = `mu',`s'
	local mods
	if "`gfix'"=="" { /* gamma to be estimated */
		eq G : `gvars' `gbase'
		local gdim: word count `gvars' `gbase'
		if `gdim'>0 {
			forvalues i=1/`gdim' {
				local ginit `ginit',0
			}
		}
		matrix `g' = (`ginit')
		matrix colnames `g' = G:
		matrix `mu' = `mu',`g'
		local mods "(G:`gvars' `gbase')"
	}
	if `pars4' & ("`dfix'"=="") { /* delta to be estimated */
		eq D : `dvars' `dbase'
		local ddim: word count `dvars' `dbase'
		if `ddim'>0 {
			forvalues i=1/`ddim' {
				local dinit `dinit',1
			}
		}
		matrix `d' = (`dinit')
		matrix colnames `d' = D:
		matrix `mu' = `mu',`d'
		local mods "`mods' (D:`dvars' `dbase')"
	}
	* version 6 of ml
	version 6: ml model lf xri_`dist'll (M:`lhs'=`mvars' `mbase') /*
	 */ (S:`svars' `sbase') `mods' if `touse', /*
	 */ title(`wtd'`dt`dnum'' Regression)
	ml init `mu', copy
	ml query
	noi ml maximize
	local dev = -2*e(ll)
	tempname v
	matrix `v' = e(V)

	tempvar S G z
	predict `M' `if_touse_user', equation(M)
	predict `S' `if_touse_user', equation(S)
	if "`gfix'"!="" {
		gen `G' = `ginit' `if_touse_user'
	}
	else {
		predict `G' `if_touse_user', equation(G)
	}
	if `pars4' {
		tempvar D
		if "`dfix'"!="" {
			gen `D' = `dinit' `if_touse_user'
		}
		else {
			predict `D' `if_touse_user', equation(D)
		}
	}
	if "`se'"!="" {
		tempvar se1 se2 se3
		predict `se1' `if_touse_user', equation(M) stdp
		predict `se2' `if_touse_user', equation(S) stdp
		if "`gfix'"=="" {
			predict `se3' `if_touse_user', equation(G) stdp
		}
		if `pars4' & ("`dfix'"=="") {
			tempvar se4
			predict `se4' `if_touse_user', equation(D) stdp
		}
	}
/*
	Centiles (and standard errors)
*/
	if `pars4' {
		local dd "delta(`D')"
	}
	centcalc `M' `S', centile(`centile') prefix(C) /*
	 */ dist(`dist') gamma(`G') `dd' `cv' `lns' `tau' `trunc'
/*
	Extract names of centile variables
*/
	local C
	forvalues i=1/`nc' {
		local C`i' `s(cvar`i')'
		local C `C' `C`i''
	}
/*
	SEs of centile values.
*/
	local no_x=("`rhs'`covars'"=="")
	if "`se'"!="" {
		forvalues i=1/`nc' {
		    tempvar c`i'se
		    gen `c`i'se'=.
		    noi di as txt _n "Calculating SE of `c`i''th centile ..."
		    if `pars4' {
			_se4 `dnum' ///
			 "`mvars'" "`svars'" "`gvars'" "`dvars'" ///
			 "`mbase'" "`sbase'" "`gbase'" "`dbase'" ///
			 `M' `S' `G' `D' `v' "`cv'" "`tau'" "`lns'" ///
			 "`gfix'" "`dfix'" `c`i'' `c`i'se' `no_x' `touse_user'
		    }
		    else {
			_se3 `dnum' "`mvars'" "`svars'" "`gvars'" ///
			 "`mbase'" "`sbase'" "`gbase'" ///
			 `M' `S' `G' `v' "`cv'" "`tau'" "`lns'" "`gfix'" ///
			 `c`i'' `c`i'se' `no_x' `touse_user'
		    }
		}
	}
/*
	Standardized residuals (Z-scores), calculated
	(if appropriate, out of sample) by xri_*ll.ado.
*/
	global ML_y1 `lhs'
	gen `Z' = .
	xri_`dist'll `Z' `M' `S' `G' `D'	// `Z' is a placeholder here (ll)
	replace `Z' = __U

	if "`zci'"!="" {
		tempvar yse zl zu
		gen `yse' = .
		if `pars4' {
			_se4 `dnum' ///
			 "`mvars'" "`svars'" "`gvars'" "`dvars'" ///
			 "`mbase'" "`sbase'" "`gbase'" "`dbase'" ///
			 `M' `S' `G' `D' `v' "`cv'" "`tau'" "`lns'" ///
			 "`gfix'" "`dfix'" `Z' `yse' `no_x' `touse_user'
		}
		else {
			_se3 `dnum' "`mvars'" "`svars'" "`gvars'" ///
			  "`mbase'" "`sbase'" "`gbase'" ///
			  `M' `S' `G' `v' "`cv'" "`tau'" "`lns'" "`gfix'" ///
			  `Z' `yse' `no_x' `touse_user'
		}
		local z = -invnorm((100-c(level))/200)
		gen `zl' = `lhs'-`z'*`yse'
		gen `zu' = `lhs'+`z'*`yse'
		global ML_y1 `zl'
		xri_`dist'll `yse' `M' `S' `G' `D' /* `yse' is a dummy here */
		replace `zl' = __U
		global ML_y1 `zu'
		xri_`dist'll `yse' `M' `S' `G' `D'
		replace `zu' = __U
	}
	drop __U
}
/*
	Graph
*/
if "`graph'"!="nograph" & "`rhs'"!="" {
	qui count if `touse'
	local nobs = r(N)
	if "`saving'"!="" local saving "saving(`saving')"
	local ms "ms(oh)"
	local title `"title("`dt`dnum'' model for `lhs'")"'
	local subtitle `"subtitle("`centile' centiles")"'
	local ytitle `"ytitle("`lhs'")"'
	local xtitle `"xtitle("`rhs'")"'
	scatter `lhs' `rhs' if `touse', `ms' `scatter' || ///
	 line `M' `C' `rhs' if `touse', sort `ytitle' `xtitle' `title' `subtitle' legend(off) `options' || ///
	 `plot'
/*
	gr7 `lhs' `M' `C' `rhs' if `touse', t1title("`t1title'") xlab ylab /*
	 */ t2title("`t2title'") l1("`lhs'") b2("`rhs'") sort `saving' `cs'
*/
}
/*
	Save variables if required, and name/label them.
*/
if "`leave'"=="" {
	local prog "_ml"
	local vn Z`prog'
	cap drop `vn'
	rename `Z' `vn'
	lab var `vn' "`dupper' Z-scores"

	if "`cv'"!="" local cvl " [cv]"
	if "`lns'"!="" local lnsl "ln "

	local a1 m
	local a2 s

	local b1 "location"
	local b2 "`lnsl'scale`cvl'"

	if `pars3' {
		local b3 "shape"
		local a3 g
	}
	if `pars4' {
		local b3 "shape [gamma]"
		local a4 d
		local b4 "shape [delta]"
	}
	local p=2+`pars3'+`pars4'
	forvalues i=1/`p' {
	    local a `a`i''
	    local A = upper("`a'")
	    local b `b`i''
	    local vn `A'`prog'
	    cap drop `vn'
	    rename ``A'' `vn'
	    if "``a'fix'"!="" local add "fixed at ``a'init'"
	    else if "``a'fixpow'"!="" local add "powers ``a'fixpow'"
	    else local add "constant"
	    lab var `vn' "`dupper' `b': `add'"
	    if "`se'"!="" & (`i'<=2 | (`i'==3 & "`gfix'"=="") /*
	     */ | ((`i'==4) & `pars4' & "`dfix'"=="")) {
		local vn se`vn'
		cap drop `vn'
	    	rename `se`i'' `vn'
	    	lab var `vn' "`dupper' se[`b']"
	    }
	}
	forvalues i=1/`nc' {
		local cent `c`i''
		local vn = substr("`C`i''`prog'",1,8)
		cap drop `vn'
		rename `C`i'' `vn'
		lab var `vn' "`dupper' `cent' centile"
		if "`se'"!="" {
			local vn=substr("se`vn'",1,8)
			cap drop `vn'
			rename `c`i'se' `vn'
			lab var `vn' "`dupper' se[`cent' centile]"
		}
	}
	if "`zci'"!="" {
		local vn "Zl`prog'"
		cap drop `vn'
		rename `zl' `vn'
		lab var `vn' "`dupper' Z lower c(level)% conf. limit"
		local vn "Zu`prog'"
		cap drop `vn'
		rename `zu' `vn'
		lab var `vn' "`dupper' Z upper c(level)% conf. limit"
	}
}
di as txt _n "Final deviance = " %9.3f as res `dev' /*
 */ as txt " (" as res e(N) as txt " observations.)"
if "`tidy'"!="notidy" {
	if "`mvars'"!="" drop `mvars'
	if "`svars'"!="" drop `svars'
	if "`gvars'"!="" drop `gvars'
	if "`dvars'"!="" drop `dvars'
}
global S_1 `dev'
ereturn scalar dev=`dev'
ereturn local dist `dist'
ereturn local cmd xriml
end

program define _se3 /* SE for estimated centiles, 2 and 3 parameter models */
version 8
	args dnum	/// distribution number
	vars1		/// covariates for M-curve
	vars2		/// covariates for S-curve
	vars3		/// covariates for G-curve
	base1		/// base vars  for M-curve
	base2		/// base vars  for S-curve
	base3		/// base vars  for G-curve
	M		///
	S		///
	G		///
	V		///
	cv		///
	tau		///
	lns		///
	gfix		///
	centile	///
	cse		///
	no_x		///
	touse_user
	foreach thing in cv tau lns gfix {
		local `thing' = ("``thing''"!="")
	}

* Treat normal as boxcox

	if `dnum'==0 local dnum 2

* Put names of covariates into xn*

	local small 1e-6

	local npar 0 // npar counts the covariates, including _cons's
	forvalues p=1/3 { // parameter no.: 1=m, 2=s, 3=g
		local no_gpar = `gfix' & (`p'==3)
		if `no_gpar' local n3 0
		else local n`p' 1
/*
	Put names of the FP and base covariates into xn*
*/
		if "`vars`p''`base`p''"!="" {
			tokenize `vars`p'' `base`p''
			while "`1'"!="" {
				local ++n`p'
				local ++npar
				local xn`npar' "`1'"
				mac shift
			}
		}
		if !`no_gpar' local ++npar // add one for _cons
	}
/*
	Calc derivatives wrt params.
*/
	tempvar h1 h2 h3 A B
	cap confirm var `centile'
	if _rc {
		tempname uq
		scalar `uq'=invnorm(`centile'/100)
	}
	else local uq `centile' /* uq contains Z-scores (zci option) */
	if `lns' {	/* log S parameterization */
		tempvar s
		gen `s' = exp(`S')
	}
	else local s `S'
	if `dnum'==1 { /* SLN */
	    gen `A' = exp(`G'*`uq')
	    gen `h1' = 1
	    if `cv' {
		gen `h2' = cond(abs(`G')<`small', `M'*`uq', /* 
		*/ `M'*(`A'-1)/`G' )
	    }
	    else gen `h2' = cond(abs(`G')<`small', `uq', (`A'-1)/`G' )
	    if !`gfix' {
		if `cv' {
			gen `h3' = cond(abs(`G')<`small', /*
			 */ 0.5*`s'*`M'*`uq'^2, /*
			 */ (`A'*(`uq'-1/`G')+1/`G')*`s'*`M'/`G' )
		}
		else {
			gen `h3' = cond(abs(`G')<`small', /*
			 */ 0.5*`s'*`uq'^2, /*
			 */ (`A'*(`uq'-1/`G')+1/`G')*`s'/`G' )
		}
	    }
	}
	else if `dnum'==2 {	/* PN */
	    if `tau' {		/* tau parameterization */
		tempvar t	/* lambda */
		if `cv' {
		    gen `t' = 1-`G'/`s'
		}
		else gen `t' = 1-`G'*`M'/`s'
	    }
	    else local t `G'
	    if `cv' {
	    	gen `B' = `uq'*`s'
	    }
	    else gen `B' = `uq'*`s'/`M'
	    gen `A' = (1+`t'*`B')^(1/`t')
	    gen `h1' = cond(abs(`t')<`small', (1-`B')*exp(`B'), /*
		*/ `A'*(1-`B'/`A'^`t'))
	    if `cv' {
		gen `h2' = cond(abs(`t')<`small', `M'*`uq'*exp(`B'), /*
		*/ `M'*`uq'*`A'^(1-`t'))
	    }
	    else {
		gen `h2' = cond(abs(`t')<`small', `uq'*exp(`B'), /*
		*/ `uq'*`A'^(1-`t'))
	    }
	    if !`gfix' {
		gen `h3' = cond(abs(`t')<`small', -0.5*`M'*`B'^2*exp(`B'), /*
		 */ `M'*`A'*(`B'/`A'^`t'-log(`A'))/`t')
	    }
	}
	else if `dnum'==3 { /* EN */
	    gen `A' = 1+`G'*`uq'
	    gen `h1' = 1
	    if `cv' {
		    gen `h2' = cond(abs(`G')<`small', `M'*`uq', /*
		    */ `M'*log(`A')/`G' )
	    }
	    else gen `h2' = cond(abs(`G')<`small', `uq', log(`A')/`G' )
	    if !`gfix' {
		if `cv' {
			gen `h3' = cond(abs(`G')<`small', /*
			 */ -0.5*`s'*`M'*`uq'^2, /*
			 */ (1-1/`A'-log(`A'))*`s'*`M'/`G'^2 )
		}
		else {
			gen `h3' = cond(abs(`G')<`small', /*
			 */ -0.5*`s'*`uq'^2, /*
			 */ (1-1/`A'-log(`A'))*`s'/`G'^2 )
		}
	    }
	}
* Calc SE of centile, element-by-element
	tempname xx h hbeta hVh se
	matrix `hbeta' = J(1,`npar',0)
	local pp = 3-`gfix'
	local n = _N
	forvalues i = 1 / `n' {
		if `touse_user'[`i'] == 1 {
* multiply centile derivs by data for each parameter
			local k 0
			forvalues param=1/`pp' {
				scalar `h' = `h`param''[`i']
				local np `n`param''
				forvalues j=1/`np' {
					local ++k
					if `j'<`np' {
						scalar `xx'=`xn`k''[`i']
					}
					else scalar `xx'=1
					matrix `hbeta'[1,`k'] =`h'*`xx'
				}	
			}
			matrix `hVh' = `hbeta'*`V'
			matrix `hVh' = `hVh'*`hbeta''
			scalar `se'=sqrt(`hVh'[1,1])
			if `no_x' continue, break
			qui replace `cse'=`se' in `i'
		}
	}
	if `no_x' qui replace `cse' = `se' if `touse_user'
end

program define _se4 /* SE for estimated centiles, MPN and MEN models */
version 8
	args dnum	/// distribution number
	vars1		/// covariates for M-curve
	vars2		/// covariates for S-curve
	vars3		/// covariates for G-curve
	vars4		/// covariates for D-curve
	base1		/// base vars  for M-curve
	base2		/// base vars  for S-curve
	base3		/// base vars  for G-curve
	base4		/// base vars  for D-curve
	M		///
	S		///
	G		///
	D		///
	V		/// VCE matrix of parameters
	cv		///
	tau		///
	lns		///
	gfix		///
	dfix		///
	centile	///
	cse		/// to hold SE, assumed to exist
	no_x		///
	touse_user
	foreach thing in cv tau lns gfix dfix {
		local `thing' = ("``thing''"!="")
	}

	local small 1e-6

	local npar 0 // npar counts the covariates, including _cons's
	forvalues p=1/4 { // parameter no.: 1=m, 2=s, 3=g, 4=d
		local no_gpar = `gfix' & (`p'==3)
		local no_dpar = `dfix' & (`p'==4)
		if `no_gpar' | `no_dpar' local n`p' 0
		else local n`p' 1
		if "`vars`p''`base`p''"!="" {
/*
	Put names of the FP and base covariates into xn*
*/
			tokenize `vars`p'' `base`p''
			while "`1'"!="" {
				local n`p'=`n`p''+1
				local npar=`npar'+1
				local xn`npar' "`1'"
				mac shift
			}
		}
/*
	Add one param for _cons
*/
		if !`no_gpar' & !`no_dpar' local ++npar
	}
/*
	Calc first derivatives w.r.t. params.
*/
	tempvar h1 h2 h3 h4 A B DD zq s
	cap confirm var `centile'
	if _rc {
		tempname uq
		scalar `uq' = invnorm(`centile'/100)
	}
	else local uq `centile' // uq contains Z-scores (zci option)
	gen `DD' = 1+`D'*abs(`uq')
	gen `zq' = sign(`uq')*(`DD'^(1/`D')-1)
	if `lns' {	// log S parameterization
		gen `s' = exp(`S')
	}
	else gen `s' = `S'
	if `cv' replace `s' = `s'*`M'  // `s' is sigma, not cv

	if `dnum'==7 { // MPN
	    if `tau' { // tau parameterization
		tempvar t // lambda
		gen `t' = 1-`G'*`M'/`s'
	    }
	    else local t `G'
	    gen `B' = `zq'*`s'/`M'
	    gen `A' = cond(abs(`t')<`small', exp(`B'), (1+`t'*`B')^(1/`t'))
	    gen `h1' = cond(abs(`t')<`small', `A'*(1-`B'), `A'*(1-`B'/`A'^`t'))
	    if `cv' gen `h2' = `M'*`zq'*`A'^(1-`t')
	    else gen `h2' = `zq'*`A'^(1-`t')
	    if !`gfix' {
		gen `h3' = cond(abs(`t')<`small', -0.5*`M'*`A'*`B'^2, /*
		 */ (`M'*`A'/`t')*(`B'/`A'^`t'-log(`A')) )
	    }
	    if !`dfix' {
		gen `h4' = (`zq'+sign(`uq'))*(`s'/`D')*`A'^(1-`t')* /*
		 */ (abs(`uq')/`DD'-log(`DD')/`D')
	    }
	}
	else if `dnum'==8 { // MEN
	    gen `A' = 1+`G'*`zq'
	    gen `h1' = 1
	    if `cv' {
	        gen `h2' = cond(abs(`G')<`small', `M'*`zq', `M'*log(`A')/`G' )
	    }
	    else gen `h2' = cond(abs(`G')<`small', `zq', log(`A')/`G' )
	    if !`gfix' {
		gen `h3' = cond(abs(`G')<`small', /*
		 */ -0.5*`s'*`zq'^2, (1-1/`A'-log(`A'))*`s'/`G'^2 )
	    }
	    if !`dfix' {
		gen `h4' = (`zq'+sign(`uq'))*(`s'/(`D'*`A'))* /*
		 */ (abs(`uq')/`DD'-log(`DD')/`D')
	    }
	}
* Calc SE of centile, element-by-element
	tempname xx h hbeta hVh se
	matrix `hbeta' = J(1,`npar',0)
	local pp = 4-`gfix'-`dfix'
	local n = _N
	forvalues i = 1 / `n' {
		if `touse_user'[`i'] == 1 {
* multiply centile derivs by data for each parameter
			local k 0
			forvalues param=1/`pp' {
				scalar `h'=`h`param''[`i']
				local np `n`param''
				forvalues j=1/`np' {
					local ++k
					if `j'<`np' {
						scalar `xx' = `xn`k''[`i']
					}
					else scalar `xx' = 1
					matrix `hbeta'[1,`k'] = `h'*`xx'
				}	
			}
			matrix `hVh' = `hbeta'*`V'
			matrix `hVh' = `hVh'*`hbeta''
			scalar `se' = sqrt(`hVh'[1,1])
			if `no_x' continue, break
			qui replace `cse' = `se' in `i'
		}
	}
	if `no_x' qui replace `cse' = `se' `if_touse_user'
end

*! v 1.0.1 PR 01Jun95.
program define _jprxrpa // parses "clusters"
version 8
args stuff /// string to be parsed
prefixs /// string of permitted one-character prefixes
items /// items in error message if #clusters > #prefixes

local nprefix = length("`prefixs'")
forvalues i=1/`nprefix' {
	local p`i'=substr("`prefixs'",`i',1)
	global S_p`i'
	global S_c`i'
}
tokenize "`stuff'", parse(",")
global S_1 0 /* # of comma-delimited clusters */
while "`1'"!="" {
	if "`1'"=="," mac shift
	global S_1 = $S_1+1
	local clust$S_1 "`1'"
	mac shift
}
if "`clust${S_1}'"=="" global S_1 = $S_1-1
if $S_1>`nprefix' {
	noi di as err "too many `items' specified"
	exit 198
}
/*
	Disentangle each prefix:string cluster
*/
forvalues i=1/$S_1 {
	parse "`clust`i''", parse("=:")
	local prefix = lower(substr("`1'",1,1))
	local j 1
	local found 0
	while (`j'<=`nprefix') & !`found' {
		if "`prefix'"=="`p`j''" {
			global S_p`i' `prefix'
			global S_c`i' "`3'"
			local found 1
		}
		local ++j
	}
	if !`found' {
		noi di as err "invalid `clust`i''"
		exit 198
	}
}
end
