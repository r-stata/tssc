*! xtfixedcoeftvcu version 1.0.0
*! Estimates panel data fixed-coefficient model where 
*! these coefficients vary over time and cross-sectional units 
*! Diallo Ibrahima Amadou 
*! All comments are welcome, 06Jan2016

   



capture program drop xtfixedcoeftvcu
program xtfixedcoeftvcu, eclass byable(recall) sortpreserve
	version 13.1
    local options "Level(cilevel)"
    if replay() {
                 if "`e(cmd)'" != "xtfixedcoeftvcu" {
                                                     error 301
                 }
                 syntax [, `options'] 
    }
	else {
		  syntax varlist(ts) [if] [in] [, forcereg maxnbiter(integer 500000) ptoler(real 1e-5) vtoler(real 1e-5) nrtoler(real 1e-5) ignrtoler ///
		                                  noDISPLOGS difficult technique(string asis) vce(string)  `options' ] 
		  marksample touse
		  quietly count if `touse'
		  if r(N) == 0 {
						di as err "No observations."
						exit 2000
		  }
		  tempvar mycountidj
		  quietly tsset
          local panelvar = r(panelvar)
          local timevar  = r(timevar)
          if "`forcereg'" == "" {
                                 quietly _xtstrbal `panelvar' `timevar' `touse'
                                 if r(strbal) == "no" {
                                                       di as error "The xtfixedcoeftvcu command requires strongly balanced data"
                                                       di as error "Or use the forcereg option"
                                                       exit 498
                                 }
          }
          else {
                quietly {
                         tsset
                         local ivar "`r(panelvar)'"
                         bysort `touse' `ivar': gen long `mycountidj' = _N
                         sum `mycountidj' if `touse', meanonly
                         tempvar  mc
                         gen `mc' = .
                         replace `mc' = 1 if `mycountidj' == r(max) & `touse'
                         markout `touse' `mc'
                }
          }
		  _vce_parse `touse' , optlist(Robust) : , vce(`vce')
		  local monvcefac   "`r(vce)'"		  
          gettoken first rest : varlist
          quietly tsset
		  _rmcoll `rest' if `touse', forcedrop
          local rest `r(varlist)'
          quietly tsset
          local pvarvh "`r(panelvar)'"
          local timevarkda  "`r(timevar)'"
		  local nombreiter "`maxnbiter'"
		  local nombreptol "`ptoler'"
		  local nombrevtol "`vtoler'"
		  local nombrenrtol "`nrtoler'"
		  if `"`ignrtoler'"' == "" {
									local varinrtol "off"
		  }
		  else {
				local varinrtol "on"
		  }
		  if `"`displogs'"' == "" {
								   local dislogzv "on" 
		  }
		  else {
				local dislogzv "off"
		  }
		  if `"`difficult'"' == "" {
									local singhmethodhm "m-marquardt"
		  }
		  else {
				local singhmethodhm "hybrid"
		  }
		  if `"`technique'"' == "" {
									local mestechq "nr"
		  }
		  else {
				local mestechq "`technique'"
		  }
		  if `"`monvcefac'"' == "robust" {
										  local vcetypemari "robust"
		  }
		  else {
				local vcetypemari "oim"
		  }
 	      ereturn clear
		  return clear
	      mata: _mz_creatematshm( "`first'", "`rest'", "`pvarvh'", "`timevarkda'", "`touse'", `nombreiter', `nombreptol', `nombrevtol', ///
		                          `nombrenrtol', "`varinrtol'", "`dislogzv'", "`singhmethodhm'", "`mestechq'", "`vcetypemari'" )
	}
	local sch = cond(!replay() , 0, 1) 
	DisplayFixedCoefs, level(`level') sch(`sch') 
	ereturn local  cmdline "xtfixedcoeftvcu `0'"
	
	
end





program define DisplayFixedCoefs, eclass sortpreserve
    syntax [, Level(cilevel) SCHwitch(integer 0) ] 
	tempname nng nnp tefi
	tempvar touse
    if `schwitch' == 1 {
                        local ivar "`e(ivar)'"
						scalar `nnp'  = e(N)
						scalar `nng'  = e(N_g)
						scalar `tefi' = e(T)
						local yy "`e(depvar)'"
						gen `touse' = e(sample)
						quietly tsset
						local tvars  "`r(timevar)'"
						local xxvrs "`e(xvars)'"
    }
    else {
		  local ivar "`r(ivar)'"
		  scalar `nnp'  = r(myN)
		  scalar `nng'  = r(myN_g)
          scalar `tefi' = r(myT)
		  local yy "`r(depvar)'"
		  local xxvrs "`r(xvars)'"
		  local tvars "`r(tvar)'"
		  local touse = r(touse)
	}
	tempname matzbcoefs matzvcov mmW mmpvW rr2
	tempvar lcxb
	matrix define `matzbcoefs' = e(b)
	matrix define `matzvcov'   = e(V)
	mata: _mz_modjingolcrr( "`yy'", "`xxvrs'", "`ivar'", "`tvars'", "`touse'", "`matzbcoefs'" )
	scalar `rr2' = r(myrrtwo)
	local sonnbk: word count xxvrs
	local sonng = `nng'
	mata: _mz_waldtesthm("`matzbcoefs'", "`matzvcov'", `sonnbk', `sonng')
	scalar `mmW'   = r(myW)
	scalar `mmpvW' = r(mypvW)
	local k1 = r(mykrel)
	tempvar Ti
    sort `ivar'
    quietly {
             preserve
             keep if `touse'
             by `ivar': gen long `Ti' = _N if _n ==_N
             summ `Ti'
             restore
    }
    local g_min "`r(min)'"
    local g_avg "`r(mean)'"
    local g_max "`r(max)'"
	display
    di _n in gr "Panel Data Fixed-Coefficient Estim. Results"                     _col(49) in gr "Number of obs" _col(68) "=" _col(72) in ye %9.0f `nnp'
    di in gr "Group variable: " in ye abbrev("`ivar'",12)                       in gr _col(49) "Number of groups" _col(68) "=" _col(72) in ye %9.0g `nng'
    di in gr "Wald chi2(" as res `k1' as txt ")" _col(15) "= " as res %9.2f `mmW' in gr _col(49) "Obs per group: min = " _col(72) in ye %9.0g `g_min'
    di in gr "Prob > chi2" _col(15) "=" as res %10.3f `mmpvW'                     in gr _col(49) "               avg = " _col(72) in ye %9.0g `g_avg'
	di in gr _col(49) "               max = " _col(72) in ye %9.0g `g_max'
    di in gr _col(49) "R-squared          =      " in ye %6.4f `rr2'
	ereturn display, level(`level')
	display
	di in gr "Legend:"
	display
	di in gr "DepVar means the dependent variable. Here    it  is" 
	di in gr "`yy'" "."
	display
	di in gr "ConstantCoefs specifies the coefficients that   are"
	di in gr "constant. It is the betabar" "."
	display
	di in gr "GroupSpecCoefs indicates the coefficients that vary"
	di in gr "over cross-sectional units. It is the alpha" "."
	display
	di in gr "TimeSpecCoefs designates the coefficients that vary"
	di in gr "over Time. It is the lambda" "."
	quietly {
			 levelsof `ivar' if `touse', local(levsfhivar)
			 levelsof `tvars' if `touse', local(levsfhtvars)
	}
	ereturn local depvar "`yy'"
	ereturn local xvars "`xxvrs'"
	ereturn local effecpvar "`levsfhivar'"
	ereturn local effectvar "`levsfhtvars'"
    ereturn scalar chi2   = `mmW'
    ereturn scalar chi2_p = `mmpvW'	
    ereturn scalar N      = `nnp'
	ereturn scalar T      = `tefi'
	ereturn scalar N_g    = `nng'
    ereturn scalar g_avg = `g_avg'
    ereturn scalar g_min = `g_min'
    ereturn scalar g_max = `g_max'
	ereturn scalar r2 = `rr2'
	ereturn local ivar "`ivar'"
	ereturn local tvar "`tvars'"
    ereturn local predict xtfixedcoeftvcu_p
    ereturn local cmd "xtfixedcoeftvcu" 
    
end






mata:





function mzfixedcoefseval(transmorphic M, real scalar todo, real rowvector b, fvb, Sb, Hb)
{
	real colvector y1, p1, p2, p3  
	y1 = moptimize_util_depvar(M, 1)
	p1 = moptimize_util_xb(M, b, 1)
	p2 = moptimize_util_xb(M, b, 2)
	p3 = moptimize_util_xb(M, b, 3)
	fvb = (y1 :- p1 :- p2 :- p3):^2	
}





void _mz_creatematshm( string scalar first, string scalar rest, string scalar panelvar, string scalar timevar, string scalar touse, ///
					   real scalar mesnbiter, real scalar mesptol, real scalar mesvtol, real scalar mesnrtol, string scalar mesignonrtol, /// 
					   string scalar mesdislog, string scalar messinghmeths, string rowvector tekinikan, string scalar vcetypeouram )
{
	real matrix x0, ptyx, info, yxm, ovyx, TX, XTILDE, xonevar, xtwovar, XINFMTX, semixiftwo, semixifone, xthreevar, idenmat, alphank0, /*
	*/ alphank1, indenmatxtd, alphank3, zeromatxtd, alphank4, zeromatxtp, alphank2, matrixCC, xonevarcst, xtwovarcst, RLxtwo, xthreevarcst, /*
	*/ RLxthree
	real colvector y0, pvar, tvar, TY, DepVar, smallc0, constmatxt, betacst, p1pred1, alphacst, rsxtwo, alphastar, p2pred1, lambdacst, rsxthree, /*
	*/ lambdastar, p3pred1
	real rowvector s
	real scalar NN, NT, TT, k1, k, p1pred2, p2pred2, p3pred2 
	string rowvector lvx, namesxone, namesxtwo, namesxthree 
	string scalar lvy, lvp, lvtm, nameeqone, nameeqtwo, nameeqthree
	
	lvy = tokens(first); lvx = tokens(rest); lvp = tokens(panelvar); lvtm = tokens(timevar);  
	st_view(y0,., lvy, touse); st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse); st_view(tvar,., lvtm, touse);
	ptyx = (pvar, tvar, y0, x0)
    info = panelsetup(ptyx, 1, 2, 0); s = panelstats(info);
    NN = s[1]; NT = s[2] ; TT = s[4];
	yxm = ptyx[.,(3..cols(ptyx))]
	k1 = cols(yxm)
    ovyx = J(NT,k1, missingof(yxm))
	for (i=1; i<=NN; i++) {
						   ovyx[|(i-1)*TT+1,1\i*TT,.|] = panelsubmatrix(yxm, i, info)
	}
	TX = ovyx[., (2..cols(ovyx))]
    TY = ovyx[., 1]
	k = cols(TX)
	XTILDE = J(NT,NN*k, 0) 
	for (i=1; i<=NN; i++) {
						   XTILDE[|(i-1)*TT+1, (i-1)*k+1 \ i*TT, i*k|] = panelsubmatrix(TX, i, info)
	}
	xtwovar = XTILDE
	xonevar = TX
	DepVar = TY
	XINFMTX = J(NT,TT*k,0)
	semixiftwo = J(TT,TT*k,0)
	for (i=1; i<=NN; i++) {
						   semixifone = panelsubmatrix(TX, i, info)
						   for (j=1; j<=TT; j++) {
												  semixiftwo[|j,(j-1)*k+1\j,j*k|] = semixifone[j,.]
						   }
						   XINFMTX[|(i-1)*TT+1, 1 \ i*TT, .|] = semixiftwo
    }
	xthreevar     = XINFMTX
	namesxone     = lvx
	namesxtwo     = J(1, NN, namesxone)
	namesxthree   = J(1,TT, namesxone)
	nameeqone     = "ConstantCoefs"
	nameeqtwo     = "GroupSpecCoefs"
	nameeqthree   = "TimeSpecCoefs" 
	idenmat       = I(k)
	alphank0      = J(1,NN, idenmat)
	smallc0       = J(k,1,0)
	alphank1      = J(k,k+1,0)
	constmatxt    = J(k,1,0)
	constmatxt[1] = 1 
	indenmatxtd   = I(k)
	alphank3      = J(1,TT,indenmatxtd)
	zeromatxtd    = J(k,k+1+NN*k+1,0)
	alphank4      =(zeromatxtd,alphank3,constmatxt)
	zeromatxtp    = J(k,TT*k+1,0)
	alphank2      = (alphank1, alphank0, constmatxt,zeromatxtp)
	matrixCC      = ((alphank2\alphank4),(smallc0\smallc0))
    xonevarcst    = (xonevar,J(rows(xonevar),1,1))
	betacst       = qrinv(xonevarcst'xonevarcst)*xonevarcst'DepVar
	p1pred1       = xonevarcst*betacst
	p1pred2       = mean(p1pred1)
	xtwovarcst    = (xtwovar,J(rows(xtwovar),1,1))
	alphacst      = qrinv(xtwovarcst'xtwovarcst)*xtwovarcst'DepVar
	RLxtwo        = (alphank0, constmatxt)
	rsxtwo        = smallc0
	alphastar     = alphacst - qrinv(xtwovarcst'xtwovarcst)*RLxtwo'*qrinv(RLxtwo*qrinv(xtwovarcst'xtwovarcst)*RLxtwo')*(RLxtwo*alphacst - rsxtwo)
	p2pred1       = xtwovarcst*alphastar
	p2pred2       = mean(p2pred1)
	xthreevarcst  = (xthreevar,J(rows(xthreevar),1,1))
	lambdacst     = qrinv(xthreevarcst'xthreevarcst)*xthreevarcst'DepVar
	RLxthree      = (alphank3,constmatxt)
	rsxthree      = smallc0
	lambdastar    = lambdacst - qrinv(xthreevarcst'xthreevarcst)*RLxthree'*qrinv(RLxthree*qrinv(xthreevarcst'xthreevarcst)*RLxthree')*(RLxthree*lambdacst - rsxthree)
	p3pred1       = xthreevarcst*lambdastar
	p3pred2       = mean(p3pred1)
 	M = moptimize_init()
	moptimize_init_evaluator(M, &mzfixedcoefseval())
	if (mesdislog == "off") {
							 moptimize_init_tracelevel(M, "none")
	}
	moptimize_init_conv_ptol(M, mesptol)
	moptimize_init_conv_vtol(M, mesvtol)
	moptimize_init_conv_nrtol(M, mesnrtol)
	moptimize_init_eq_coefs(M, 1, p1pred2) 
	moptimize_init_eq_coefs(M, 2, p2pred2)
	moptimize_init_eq_coefs(M, 3, p3pred2)  
	moptimize_init_conv_maxiter(M, mesnbiter)   
	moptimize_init_which(M, "min")
	moptimize_init_evaluatortype(M, "gf0")
	moptimize_init_technique(M, tekinikan) 
	moptimize_init_depvar(M, 1, DepVar) 
	moptimize_init_eq_indepvars(M, 1, xonevar)
	moptimize_init_eq_name(M, 1, nameeqone)
	moptimize_init_eq_colnames(M, 1, namesxone)
	moptimize_init_eq_indepvars(M, 2, xtwovar)
	moptimize_init_eq_name(M, 2, nameeqtwo)
	moptimize_init_eq_colnames(M, 2, namesxtwo)
	moptimize_init_eq_indepvars(M, 3, xthreevar)
	moptimize_init_eq_name(M, 3, nameeqthree)
	moptimize_init_eq_colnames(M, 3, namesxthree)
	moptimize_init_conv_ignorenrtol(M, mesignonrtol)
	moptimize_init_constraints(M, matrixCC)
	moptimize_init_touse(M, touse)
	moptimize_init_vcetype(M, vcetypeouram)
	moptimize_init_singularHmethod(M, messinghmeths)
	moptimize_init_valueid(M, "Residual SS")
	moptimize(M)
    moptimize_result_post(M)
    st_numscalar("r(myN)", NT)
    st_numscalar("r(myN_g)", NN)
	st_numscalar("r(myT)", TT)
    st_global("r(depvar)", first)
    st_global("r(ivar)", panelvar)
	st_global("r(tvar)", timevar)
	st_global("r(xvars)", rest)
	st_global("r(touse)", touse)

	
	
}





void _mz_modjingolcrr( string scalar first, string scalar rest, string scalar panelvar, string scalar timevar, string scalar touse, string scalar matbin )
{
	real matrix x0, ptyx, info, yxm, ovyx, TX, XTILDE, xonevar, xtwovar, XINFMTX, semixiftwo, semixifone, xthreevar, xonevarcst, xtwovarcst, xthreevarcst, /*
	*/ matfcorrhaw, coefcorhom1 
	real colvector y0, pvar, tvar, TY, DepVar, betacst, p1pred1, alphastar, p2pred1, lambdastar, p3pred1, matbcrit2, pallpred
	real rowvector s, matbcrit
	real scalar NN, NT, TT, k1, k, coefcorhom2, coefcorhom3 
	string rowvector lvx 
	string scalar lvy, lvp, lvtm
	
	lvy = tokens(first); lvx = tokens(rest); lvp = tokens(panelvar); lvtm = tokens(timevar);  
	st_view(y0,., lvy, touse); st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse); st_view(tvar,., lvtm, touse);
	ptyx = (pvar, tvar, y0, x0)
    info = panelsetup(ptyx, 1, 2, 0); s = panelstats(info);
    NN = s[1]; NT = s[2] ; TT = s[4];
	yxm = ptyx[.,(3..cols(ptyx))]
	k1 = cols(yxm)
    ovyx = J(NT,k1, missingof(yxm))
	for (i=1; i<=NN; i++) {
						   ovyx[|(i-1)*TT+1,1\i*TT,.|] = panelsubmatrix(yxm, i, info)
	}
	TX = ovyx[., (2..cols(ovyx))]
    TY = ovyx[., 1]
	k = cols(TX)
	XTILDE = J(NT,NN*k, 0) 
	for (i=1; i<=NN; i++) {
						   XTILDE[|(i-1)*TT+1, (i-1)*k+1 \ i*TT, i*k|] = panelsubmatrix(TX, i, info)
	}
	xtwovar = XTILDE
	xonevar = TX
	DepVar = TY
	XINFMTX = J(NT,TT*k,0)
	semixiftwo = J(TT,TT*k,0)
	for (i=1; i<=NN; i++) {
						   semixifone = panelsubmatrix(TX, i, info)
						   for (j=1; j<=TT; j++) {
												  semixiftwo[|j,(j-1)*k+1\j,j*k|] = semixifone[j,.]
						   }
						   XINFMTX[|(i-1)*TT+1, 1 \ i*TT, .|] = semixiftwo
    }
	matbcrit      = st_matrix(matbin)
	matbcrit2     = matbcrit'
	xthreevar     = XINFMTX
    xonevarcst    = (xonevar,J(rows(xonevar),1,1))
	betacst       = matbcrit2[|1 \ k+1|]
	p1pred1       = xonevarcst*betacst
	xtwovarcst    = (xtwovar,J(rows(xtwovar),1,1))
	alphastar     = matbcrit2[|k+2 \ NN*k+1+k+1|]
	p2pred1       = xtwovarcst*alphastar
	xthreevarcst  = (xthreevar,J(rows(xthreevar),1,1))
	lambdastar    = matbcrit2[|NN*k+1+k+1+1 \ .|]
	p3pred1       = xthreevarcst*lambdastar
	pallpred      = p1pred1 + p2pred1 + p3pred1
	matfcorrhaw   = (pallpred, DepVar)
	coefcorhom1   = correlation(matfcorrhaw)
	coefcorhom2   = coefcorhom1[2, 1]
	coefcorhom3   = (coefcorhom2)^2
	st_numscalar("r(myrrtwo)", coefcorhom3)
	
	
	
}






void _mz_waldtesthm( string scalar matbin, string scalar matvin, real scalar park, real scalar parnn )
{
	real matrix matvcrit, R, matvcritb, matvcritc
	real rowvector matbcrit, chosera, matbcritb
	real scalar k, W, pvW, kdeux
	real colvector r, choserb
	
	matbcrit = st_matrix(matbin)
    matvcrit = st_matrix(matvin)
	k = cols(matbcrit)
	chosera = J(1,k, 1)
	chosera[park+1] = 0
	chosera[parnn*park+1+park+1] = 0
	chosera[k] = 0
	matbcritb = select(matbcrit, chosera)
	matvcritb  = select(matvcrit, chosera)
	choserb = chosera'
	matvcritc  = select(matvcritb, choserb)
	kdeux = cols(matbcritb)
	R = I(kdeux)
	r = J(kdeux,1,0)
	W = (R*matbcritb' - r)'*qrinv(R*matvcritc*R')*(R*matbcritb' - r)
	pvW = chi2tail(k, W)
    st_numscalar("r(myW)", W)
    st_numscalar("r(mypvW)", pvW)
	st_numscalar("r(mykrel)", kdeux)


}





end





