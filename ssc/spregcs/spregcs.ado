*! spregcs V1.0 25/01/2016
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

 program define spregcs , eclass 
 version 11.2
 syntax varlist , [WMFile(str) Model(str) Run(str) aux(str) REST(str) cost sig ///
 INLambda(real 0) ORDer(int 1) reset LL(real 0) INV INV2 VHET(str) vce(passthru) ///
 TWOstep dist(str) stand MFX(str) noLOG tobit LMIden LMHet LMSPac ROBust HAUSman ///
 WVar(str) spar(str) iter(int 100) INRho(real 0) KR(real 0) zero level(passthru) ///
 PREDict(str) RESid(str) tech(str) tolog Weights(str) NWmat(str) TESTs LMCl wsxi(str) ///
 RIDge(str) LMForm NOCONStant LMNorm KC(real 0) KF(real 0) HETCov(str) ols coll ///
 sure 2sls 3sls EQ(int 1) first MHET(str) mvreg var2(str) ENDOG(str) usp(str) ///
 TOLerance(real 0.00001) grids INST(str) MLE diag impower(int 2) NOCONEXOG DN HET]

 di
 local sthlp spregcs
 gettoken yvar xvar : varlist
 local both : list yvar & xvar
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both LHS1 and RHS1 Variables}"
 di as txt " LHS1: `yvar'"
 di as txt " RHS1:`xvar'"
 exit
 }
 local both: list yvar & xvar
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both LHS & RHS Variables}"
noi di as txt " LHS: `yvar'"
noi di as txt " RHS:`xvar'"
 exit
 }
 if inlist("`model'", "gwr", "sdm", "durbin", "mstard") & "`xvar'"=="" {
 di as err " {bf:Independent Variable(s) must be used with model(gwr, sdm, durbin, mstard)}"
 exit
 }
 local both : list xvar & aux
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both RHS1 and Auxiliary Variables}"
 di as txt " RHS:`xvar'"
 di as txt " AUX: `aux'"
 exit
 }
 local varlist1 `varlist'
 gettoken yvar xvar  : varlist
 gettoken yvar xvar1 : varlist1
 local xvar1 "`xvar'"
 if "`var2'"!="" {
 local varlist2 `var2'
 gettoken endg xvar2 : varlist2
 local both : list yvar & endg
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both LHS1 and LHS2 Variables}"
 di as txt " LHS1: `yvar'"
 di as txt " LHS2:`varlist2'"
 exit
 }
 local both : list xvar2 & aux
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both RHS2 and Auxiliary Variables}"
 di as txt " RHS2:`xvar2'"
 di as txt "  AUX: `aux'"
 exit
 }
 local both : list xvar1 & endg
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both RHS1 and LHS2 Variables}"
 di as txt " RHS1:`xvar1'"
 di as txt " LHS2: `endg'"
 exit
 }
 }
 local both : list xvar1 & endog
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} incuded in both RHS and Endogenous Variables}"
 di as txt "   RHS:`xvar'"
 di as txt " Endog: `endog'"
 exit
 }
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local nocons "noconstant"
 }
 if "`xvar'" != "" {
 unab RHS : `xvar1'
 qui _rmcoll `RHS' , `nocons' forcedrop
 local both "`r(varlist)'"
 local both : list RHS - both
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be Included more than One in RHS Variables}"
di as txt " RHS : `RHS'"
di as txt " Coll: `both'"
 exit
 }
 }
 local both: list yvar & endog
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both LHS & Endogenous Variables}"
noi di as txt "   LHS: `yvar'"
noi di as txt " Endog: `endog'"
 exit
 }
 local both: list yvar & inst
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both LHS & Instrumental Variables}"
noi di as txt "  LHS: `yvar'"
noi di as txt " Inst: `inst'"
 exit
 }
 local both: list endog & inst
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both Endogenous & Instrumental Variables}"
noi di as txt " Endog: `endog'"
noi di as txt "  Inst: `inst'"
 exit
 }
 if "`nwmat'"!="" {
 if !inlist("`nwmat'", "1", "2", "3", "4") {
 di as err " {bf:nwmat(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 } 
 } 

 if "`coll'"=="" {
 _rmdcoll `varlist' `endog' `exog' 
 }

 if "`model'"!="" {
 if !inlist("`model'", "ols", "lag", "durbin", "ivtobit", "gwr") {
 if !inlist("`model'", "sar", "sem", "sdm", "sac", "sararml", "mstar", "mstard", "gs3slsar") {
 if !inlist("`model'", "sarargs", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "spgmm") {
 di as err "{bf:model()} {cmd:must be:} {bf:sar, sem, sdm, sac, mstar, mstard, spgmm, sararml}"
 di as err "{bf:model()} {cmd:must be:} {bf:lag, durbin, gwr, ols}"
 di as err "{bf:model()} {cmd:must be:} {bf:sarargs, sarariv, ivtobit, gs2sls, gs2slsar, gs3sls, gs3slsar}"
 di in smcl _c "{cmd: see:} {help `sthlp'##04:Model Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 }
 if inlist("`model'", "sararml", "sarargs", "sarariv") {
 if c(version) < 11.2 {
 di as err " {bf:model(sararml, sarargs, sarariv)}"
 di as txt " {bf:Requires Stata Version 11.2 or above)}"
 exit
 }
 }
 if "`run'"!="" {
 if !inlist("`run'", "ols", "qreg", "rreg", "sfa", "tobit") {
 if !inlist("`run'", "2sls", "fuller", "gmm", "kclass", "liml", "melo") {
 di as err "{bf:run( )} {cmd:must be} {bf:(ols, qreg, rreg, sfa, tobit)}"
 di as err "{bf:run( )} {cmd:must be} {bf:(2sls, fuller, gmm, kclass, liml, melo)}"
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 }
 if "`wvar'"!="" {
 if inlist("`model'", "sararml", "sarargs", "sarariv") {
 di as err " {bf:wvar( )} {cmd:not Valid with:} {bf:model({it:sararml, sarargs, sarariv})}"
 exit
 }
 }
 if "`rest'"!="" {
 if inlist("`model'", "sem", "sac", "gs3sls", "gs3slsar", "sararml", "sarargs", "sarariv") {
 di as err " {bf:rest(#)} {cmd:not Valid with:}"
 di as err " {bf:model({it:sem, sac, gs3sls, gs3slsar, sararml, sarargs, sarariv})}"
 exit
 }
 if inlist("`run'", "sfa", "tobit") {
 di as err " {bf:rest(#)} {cmd:not Valid with:} {bf:run({it:`run'})}"
 exit
 }
 }
 if "`hetcov'"!="" {
 if !inlist("`hetcov'", "white", "nwest", "bart", "trunc", "parzen", "quad") {
 if !inlist("`hetcov'", "tukeyn", "tukeym", "dan", "tent") {
 di as err "{bf:hetcov()} {cmd:must be} {bf:({it:bart, dan, nwest, parzen, quad, tent, trunc, tukeym, tukeyn, white})}"
 di in smcl _c "{cmd: see:} {help `sthlp'##03:GMM Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 }
 if !inlist("`model'", "gs3sls", "gs3slsar") & "`eq'"=="" {
 di as err " {bf:eq({it:#})} {cmd:Valid only with:} {bf:model({it:gs3sls, gs3slsar})}"
 exit
 }
 if !inlist("`model'", "gs3sls", "gs3slsar") & "`var2'"!="" {
 di as err " {bf:var2({it:varlist})} {cmd:Valid only with:} {bf:model({it:gs3sls, gs3slsar})}"
 exit
 }
 if inlist("`model'", "gs3sls", "gs3slsar") & "`var2'"=="" {
 di as err " {bf:var2({it:varlist})} {cmd:must be combine with:} {bf:model({it:gs3sls, gs3slsar})}"
 di _dup(78) "{bf:{err:-}}"
 di as err " {bf: if you have system of 2 Equations:}"
 di as err _col(10) "{cmd:Y1 = Y2 X1 X2}"
 di as err _col(10) "{cmd:Y2 = Y1 X3 X4}"
 di as err " {cmd:Variables of Eq.1 are: Dep. & Indep. Variables}"
 di as err " {cmd:Variables of Eq.2 are: Dep. & Indep. Variables [in option var2( )]}"
 di as err " {bf:spregcs y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4)} eq(1)"
 di as err " {bf:spregcs y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4)} eq(2)"
 di _dup(78) "{bf:{err:-}}"
 exit
 }
 if "`noconstant'"!="" & "`xvar'"=="" {
 di as err " {bf:noconstant} {cmd:cannot be used if no Independent Variables Exist}"
 exit
 }
 if "`ridge'"!="" & "`xvar'"=="" {
 di as err " {bf:ridge( )} {cmd:cannot be used if no Independent Variables Exist}"
 exit
 }
 if "`run'"!="" {
 if !inlist("`run'", "kclass") & "`kc'"=="" {
 di as err " {bf:kc({it:#})} {cmd:Theil k-Class Valid only with:} {bf:run({it:kclass})}"
 exit
 }
 if !inlist("`run'", "fuller") & "`kf'"=="" {
 di as err " {bf:kf({it:#})} {cmd:Fuller k-Class Valid only with:} {bf:run({it:fuller})}"
 exit
 }
 if !inlist("`run'", "gmm") & "`hetcov'"!="" {
 di as err " {bf:hetcov( )} {cmd:Valid only with:} {bf:run({it:gmm})}"
 exit
 }
 }
 if !inlist("`model'", "ols") & "`wmfile'"=="" {
 di as err " {bf:wmfile( ) {cmd:must be combined with:}}"
 di as err " {bf:model({it:sar, sem, sdm, sac, gwr, spgmm, gs2sls, gs2slsar, mstar, mstard, lag, durbin})}"
 di as err " {bf:model({it:ols})} {cmd:only not require} {bf:wmfile( )}"
 exit
 }
 if inlist("`model'", "sem", "sac") & "`noconstant'"!="" {
 di as err " {bf:noconstant} {cmd:cannot be combined with} {bf:model({it:sem, sac})}"
 exit
 }
 if inlist("`model'", "sem", "sac") & "`aux'"!="" {
 di as err " {bf:aux(vars)} {cmd:cannot be combined with} {bf:model({it:sem, sac})} "
 exit
 }
 if !inlist("`model'", "ivtobit", "sarariv", "gs2sls", "gs2slsar") & "`endog'"!="" {
 di as err " {bf:endog(vars)} {cmd:Valid only with:} {bf:model({it:ivtobit, sarariv, gs2sls, gs2slsar})}"
 exit
 }
 if inlist("`model'", "sarariv") & "`endog'"=="" {
 di as err " {bf:endog(vars)} {cmd:must be combined with} {bf:model({it:sarariv})}"
 exit
 }
 if !inlist("`model'", "ivtobit", "sarariv", "gs2sls", "gs2slsar") & "`inst'"!="" {
 di as err " {bf:inst(vars)} {cmd:Valid only with:} {bf:model({it:ivtobit, sarariv, gs2sls, gs2slsar})}"
 exit
 }
 if !inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "ivtobit", "gs3slsar") & "`lmiden'"!="" {
 di as err " {bf:lmiden} {cmd:Valid only with:} {bf:model({it:sarariv, gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit})}"
 exit
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "yh", "abse", "e2", "yh2", "x", "xi", "x2", "xi2") {
 di as err " {bf:weights( )} {cmd:Valid only with:} {bf:yh, yh2, abse, e2, x, xi, x2, xi2}"
 di in smcl _c "{cmd: see:} {help `sthlp'##08:Weighted Variable Type Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
 di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
 exit
 }
 if ("`inv'"!="" | "`inv2'"!="" ) & "`stand'"=="" {
 di as err " {bf:inv, inv2} {cmd:and} {bf:stand} {cmd:must be combined}"
 exit
 }
 if inlist("`model'", "gwr", "ols", "lag", "durbin", "gs2sls", "gs2slsar") & "`run'"=="" {
 di as err " {bf:run( )} {cmd:must be combined with:} {bf:model(gs2sls, gs2slsar, gwr, ols, lag, durbin)}"
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 if inlist("`model'", "gs2sls", "gs2slsar") & !inlist("`run'", "2sls", "fuller", "gmm", "kclass", "liml", "melo") {
 di as err " {bf:model(gs2sls, gs2slsar)} {cmd:Valid only with:} {bf:run(2sls, liml, kclass, fuller, gmm, melo)}"
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 if inlist("`model'", "gwr", "ols", "lag", "durbin") & !inlist("`run'", "ols", "tobit", "sfa") {
 di as err " {bf:model(gwr, ols, lag, durbin)} {cmd:work with:} {bf:run(ols, tobit, sfa)}"
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 if !inlist("`model'", "gwr", "ols", "lag", "durbin", "gs2sls", "gs2slsar") & "`run'"!="" {
 di as err " {bf:run( )} {cmd:Valid only with:} {bf:model(ols, lag, gwr, durbin, gs2sls, gs2slsar)}"
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 if "`tests'"!="" {
 local lmspac "lmspac"
 local diag "diag"
 local lmhet "lmhet"
 local lmnorm "lmnorm"
 local reset "reset"
 local lmform "lmform"
 local lmcl "lmcl"
 if inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit") {
 local lmiden "lmiden"
 }
 if inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") {
 local hausman "hausman"
 }
 }
 if !inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") & "`hausman'"!="" {
 di as err " {bf:hausman} {cmd:Valid only with:} {bf:model({it:gs2sls, gs2slsar, ivtobit, sarariv})}"
 exit
 }
 if !inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit", "sarariv") & "`lmiden'"!="" {
 di as err " {bf:lmiden} {cmd:Valid only with:} {bf:model({it:gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit, sarariv})}"
 exit
 }
 if inlist("`model'", "sem", "sac") & "`robust'"!="" {
 di as err "{bf:robust} {cmd:cannot be used with} {bf:model({it:`model'})}"
 di as err "{bf:robust} {cmd:Valid only with:} {bf:model({it:sar, sdm})}"
 di in smcl _c "{cmd: see:} {help `sthlp'##09:Other Options}"
 di in gr _c " (spregcs Help):"
 exit
 } 
 if !inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`mhet'"!="" {
 di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:model({it:sem, sac})}"
 di as err " {bf:mhet({it:varlist})} {cmd:Valid only with} {bf:model({it:sar, sdm, mstar, mstard})}"
 exit
 }
 if "`dist'"!="" {
 if !inlist("`dist'", "norm", "exp", "weib", "hn", "tn") {
 di as err " {bf:dist( )} {cmd:must be:}
 di as err " {bf:dist({it:norm})} {cmd:for Normal model}"
 di as err " {bf:dist({it:exp})} {cmd:for Exponential model}"
 di as err " {bf:dist({it:weib})} {cmd:for Weibull model}"
 di as err " {bf:dist({it:hn})} {cmd:for Half-Normal distribution, run(sfa)}"
 di as err " {bf:dist({it:tn})} {cmd:for Truncated-Normal distribution, run(sfa)}"
 exit
 }	
 }
 if inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`mhet'"!="" & inlist("`dist'", "exp", "weib") {
 di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:dist({it:`dist'})}"
 di as err " {bf:mhet({it:varlist})} {cmd:Valid only with} {bf:model({it:sar, sdm, mstar, mstard})} {cmd:and} {bf:dist({it:norm})}"
 exit
 }
 if !inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") & inlist("`dist'", "norm", "exp", "weib") {
 di as err " {bf:dist( )} {cmd:Valid only with} {bf:model({it:sar, sem, sdm, sac, mstar, mstard})}"
 exit
 }
 if "`mfx'"!="" {
 if !inlist("`mfx'", "lin", "log") {
 di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
 exit
 }
 }
 if "`spar'"!="" {
 if !inlist("`spar'", "rho", "lam") {
 di as err "{bf:spar( )} {cmd:Valid only with:} {bf:rho}, {bf:lam}"
 di in smcl _c "{cmd: see:} {help `sthlp'##09:Other Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 if inlist("`model'", "sem") & "`spar'"=="rho" {
 di as err " {bf:spar({it:lam})} {cmd:cannot be used with} {bf:model(`model')}"
 di as err "{bf:model({it:sar, sdm, sac, mstar, mstard, sararml, sarargs, sarariv})} {cmd:work with:} {bf:spar({it:rho})} {cmd:for Rho}"
 di as err "{bf:model({it:sem, sac, sararml, sarargs, sarariv})} {cmd:valid with:} {bf:spar({it:lam})} {cmd:for Lambda}"
 exit
 } 
 if inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`spar'"=="lam" {
 di as err " {bf:spar({it:lam})} {cmd:cannot be used with} {bf:model(`model')}"
 di as err "{bf:model({it:sar, sdm, sac, mstar, mstard, sararml, sarargs, sarariv})} {cmd:valid with:} {bf:spar({it:rho})} {cmd:for Rho}"
 di as err "{bf:model({it:sem, sac, sararml, sarargs, sarariv})} {cmd:valid with:} {bf:spar({it:lam})} {cmd:for Lambda}"
 exit
 } 
 if !inlist("`model'", "sar", "sem", "sdm", "sac", "mstar", "mstard", "sararml", "sarargs", "sarariv") {
 if inlist("`spar'", "rho", "lam") {
 di as err " {bf:spar( )} {cmd:cannot be used with} {bf:model(`model')}"
 di as err " {bf:spar( )} {cmd:Valid only with} {bf:model({it:sar, sdm, sac, mstar, mstard})}"
 exit
 }
 }
 if "`model'"=="sararml" {
 if "`het'" != "" {
 di as err "{bf:het} {cmd:Valid only with:} {bf: model({it:sarargs, sarariv})}"
 di in smcl _c "{cmd: see:} {help `sthlp'##10:Other Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 }
 if inlist("`model'", "sarargs", "sarariv") & "`grids'"!="" {
 di as err "{bf:grids} {cmd:Valid only with:} {bf: model({it:sararml})}"
 di in smcl _c "{cmd: see:} {help `sthlp'##10:Other Options}"
 di in gr _c " (spregcs Help):"
 exit
 } 
 if !inlist("`model'", "mstar", "mstard") & "`nwmat'"!="" {
 di as err " {bf:nwmat(#)} {cmd:Valid only with:} {bf:model({it:mstar, mstard})}"
 exit
 }
 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="" {
 di as err " {bf:model({it:mstar, mstard})} {cmd:and} {bf:nwmat(#)} {cmd:must be combined}"
 di as err " {bf:nwmat(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
 if inlist(`order',1,2,3,4)==0 {
 di as err " {bf:order(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
 if "`ridge'"!="" {
 if !inlist("`model'", "ols", "lag", "durbin", "spgmm", "gs2sls", "gs2slsar", "gwr") {
 di as err " {bf:ridge( )} {cmd:Valid only with:}"
 di as err " {bf:model(ols, lag, durbin, spgmm, gs2sls, gs2slsar, gwr)}"
 exit
 }
 if !inlist("`ridge'", "orr", "grr1", "grr2", "grr3") {
 di as err " {bf:ridge( )} {cmd:must be} {bf:ridge({it:orr, grr1, grr2, grr3})}"
 di in smcl _c "{cmd: see:} {help `sthlp'##06:Ridge Options}"
 di in gr _c " (spregcs Help):"
 exit
 }
 if inlist("`ridge'", "grr1", "grr2", "grr3") & `kr'>0 {
 di as err " {bf:kr(#)} {cmd:must be not combined with:} {bf:ridge({it:grr1, grr2, grr3})}"
 exit
 }
 }
 }

 qui {
 tempvar _WsY _Ws _WsX _M absE Bw D DE DF DF1 DumE DW DX_ DY_ E e SLSVar WLSVar
 tempvar EE Eo Es Ev Ew Hat ht LE LEo LYh2 P Q SBB Sig2 SSE Ue_SP
 tempvar SST Time tm U U2 Ue Ue_ wald Wis Wi WiB Wio WS Z X0 Zo Zw
 tempvar XQ Yb Yh Yh2 Yhb Yho Yho2 Yt YY YYm YYv Yh_ML Ue_ML Z _y1 _y2
 tempname Xb A B b B1 b1 B12 B1b B1t b2 BB2 Beta BetaSP Bm BOLS Bt Bv Bv1 Bx
 tempname Cov Cov1 Cov2s CovC D den DVE DVNE Dx E E1 EE1 Eg Eo Eom Ew F f1
 tempname f13 f13d gam gam2 Go GoRY h Hat hjm IDRmk IPhi J K L R20 MSPY MSPX
 tempname lf lmhs Ls M M1 M2 mh n NE NEB nw N DF kx kb Nmiss Kr llf S2y Sig2n
 tempname Om Om1 Om2 Omega P Phi Pm q Q Qr q1 q2 Qrq rid Rmk RX RY s eigw
 tempname S11 S12 sd Sig2 Sig2b Sig2o Sig2u Sig2w Sn SSE SST1 SST2 D WW eVec
 tempname v V1 v1 V1s v2 VaL VaL1 VaL21 VaLv1 In Yh_ML Ue_ML Bo olsin olshet
 tempname Vec vh VM VP VQ Vs W W1 W2 Wald We Wi Wi1 Wio WY X X0 V Sig21 restc Rs Rso
 tempname xq Xx Y Yh Yi YYm YYv Z Z0 Z1 Zo Zr Zz WMTD Sw Ue IRW IRWR IRWL WYX Bx_SP
 tempname sqN Kr BOLS1 Sig2o1 Ko Koi SLS Rostar rRo rLm kb kbc1 kb1 kbc2 kb2 Ue_SP
 tempname minEig maxEig waldm waldmp waldm_df waldr waldrp waldr_df Dim LVR Lms Kk
 tempname waldl waldlp waldl_df waldx waldxp waldx_df waldj waldjp waldj_df Yws Zws ZwZ

 local N=_N
 scalar `Dim' = `N'
 local MSize= `Dim'
 if `c(matsize)' < `MSize' {
noi di as err " {bf:Current matrix Size = (`c(matsize)')}"
noi di as err " {bf:{help matsize##|_new:matsize} must be >= Sample Size" " (`MSize')}"
 set matsize `MSize'
noi di as txt " {bf:matsize increased now to = (`c(matsize)')}"
 }
 cap drop w1x_*
 cap drop w2x_*
 cap drop w3x_*
 cap drop w4x_*
 cap drop w1y_*
 cap drop w2y_*
 local SPXvar ""
 local SPXvar1 ""
 local SPXvar2 ""
 local MSPXvar ""
 local MSPXvar1 ""
 local MSPXvar2 ""
 local WsXi ""
 local _WsXi ""
 local _xvar1 ""
 local _xvar2 ""
 local _endog ""
 local _inst ""

 if "`wmfile'" != "" {
 preserve
 use `"`wmfile'"', clear
 summ
 if `N' !=r(N) {
noi di as err "*** {bf:Spatial Weight matrix Has Not the Same Data Sample Size}"
 exit
 }
 mkmat * , matrix(_WB)
 egen ROWSUM=rowtotal(*)
 count if ROWSUM==0
 local NN=r(N)
* Check if each location has at least one neighbor
 if `NN'==1 {
noi di as err "*** {bf:Spatial Weight matrix Has (`NN') Location with No Neighbors}"
 }
 else if `NN'>1 {
noi di as err "*** {bf:Spatial Weight matrix Has (`NN') Locations with No Neighbors}"
 }
 local NROW=rowsof(_WB)
 local NCOL=colsof(_WB)
 if `NROW'!=`NCOL' {
noi di as err "*** {bf:Spatial Weight matrix is not Square}"
 exit
 }
noi di _dup(78) "{bf:{err:=}}"
 if "`stand'"!="" {
noi di as txt "{bf:*** Standardized Weight Matrix: `N'x`N' (Normalized)}"
 matrix `X0'=J(`N',1,1)
 matrix WB=_WB*`X0'*`X0''
 mata: X = st_matrix("_WB")
 mata: Y = st_matrix("WB")
 mata: _WS=X:/Y
 mata: _WS=st_matrix("_WS",_WS)
 mata: _WS = st_matrix("_WS")
 if "`inv'"!="" {
noi di as txt " {bf:*** Inverse Standardized Weight matrix (1/W)}"
 mata: _WS=1:/_WS
 mata: _editmissing(_WS, 0)
 mata: _WS=st_matrix("_WS",_WS)
 }
 if "`inv2'"!="" {
noi di as txt " {bf:*** Inverse Squared Standardized Weight matrix (1/W^2)}"
 mata: _WS=_WS:*_WS
 mata: _WS=1:/_WS
 mata: _editmissing(_WS, 0)
 mata: _WS=st_matrix("_WS",_WS)
 }
 matrix WCS=_WS
 }
 else {
noi di as txt "{bf:*** Binary (0/1) Weight Matrix: `N'x`N' (Non Normalized)}"
 matrix WCS=_WB
 }
 matrix eigenvalues eigw eVec = WCS
 matrix eigw=eigw'
 matrix WMB=WCS
 restore

 mata: `eigw' = st_matrix("eigw")
 getmata `eigw' , force replace
 cap confirm numeric var `eigw'
noi di _dup(78) "{bf:{err:-}}"
 }
 ereturn scalar Nn=_N
 if "`wmfile'"=="" {
 matrix WMB=I(`N')
 matrix _WB=I(`N')
 } 
 cap count 
 local N = r(N)
 count 
 local N = _N
 mean `varlist'
 scalar `Nmiss' = e(N)
 if "`zero'"=="" {
 if `N' !=`Nmiss' {
noi di as err "*** {bf:Observations have {bf:(" `N'-`Nmiss' ")} Missing Values}"
noi di as err "*** {bf:You can use {cmd:zero} option to Convert Missing Values to Zero}"
 exit
 }
 }
 if "`zero'"!="" {
 tempvar zeromiss
 foreach var of local varlist {
 gen double `zeromiss'`var'=`var'
 replace `var'=0 if `var'==.
 }
 }
 if "`mhet'"!="" {
 _rmcoll `mhet' , `nocons' forcedrop
 local mhet "`r(varlist)'"
 }
 if "`aux'"!="" {
 _rmcoll `aux' , `nocons' forcedrop
 local aux "`r(varlist)'"
 }
 if "`endog'"!="" {
 _rmcoll `endog' , `nocons' forcedrop
 local endog "`r(varlist)'"
 }
 if "`inst'"!="" {
 _rmcoll `inst' , `nocons' forcedrop
 local inst "`r(varlist)'"
 }
 if "`var2'"!="" {
 _rmcoll `var2' , `nocons' forcedrop
 local varlist2 "`r(varlist)'"
 gettoken endg xvar2 : varlist2
 }
 summ `yvar' 
 scalar `MSPY' =r(mean)
 if "`tolog'"!="" {
noi di as err " {cmd:** Variables Have been Transformed to Log Form **}"
noi di _dup(78) "-" 
noi di as err "{bf:** Dependent & Independent Variables}
noi di as txt " {cmd:** `varlist'} "
noi di _dup(78) "-" 
 gen double `_y1'=(`yvar')
 foreach var of local xvar1 {
 gen double `_M'`var'=(`var')
 local _xvar1 "`_xvar1' `_M'`var'"
 }
 if "`endog'"!="" {
noi di as err "{bf:** Endogenous Variables}
noi di as txt " {cmd:** `endog'} "
noi di _dup(78) "-"
 foreach var of local endog {
 gen double `_M'`var'=(`var')
 local _endog "`_endog' `_M'`var'"
 }
 }
 if "`inst'"!="" {
noi di as err "{bf:** Instrumental Variables}"
noi di as txt " {cmd:** `inst'} "
noi di _dup(78) "-"
 foreach var of local inst {
 gen double `_M'`var'=(`var')
 local _inst "`_inst' `_M'`var'"
 }
 }
 if "`mhet'"!="" {
noi di as err "{bf:** Multiplicative Heteroscedasticity Variables}"
noi di as txt " {cmd:** `mhet'} "
noi di _dup(78) "-"
 }
 if "`var2'"!="" {
noi di as txt "{bf:** GS3SLS Variables - EQ.(2)}"
noi di as err " {cmd:** `varlist2'} "
noi di _dup(78) "-"
 gen double `_y2'=(`endg')
 foreach var of local xvar2 {
 gen double `_M'`var'=(`var')
 local _xvar2 "`_xvar2' `_M'`var'"
 }
 }
 local vlistlog "`yvar' `xvar1' `endg' `xvar2' `endog' `inst' `mhet' `wvar'"
 _rmcoll `vlistlog' , `nocons' forcedrop
 local vlistlog "`r(varlist)'"
 foreach var of local vlistlog {
 gen double `_Ws'`var'=(`var')
 replace `var'=ln(`var')
 replace `var'=0 if `var'==.
 }
 }
 local varlist1 `varlist'
 local kaux : word count `aux'
 local kmhet : word count `mhet'
 if "`tobit'" != "" {
noi di _dup(60) "-"
 if "`tolog'"!="" {
 local ll=log(`ll')
 if `ll' == . {
 local ll=0
 }
 }
 count if `yvar' <= `ll'
noi di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Lower Limit}}" _col(45) "= " `ll'
noi di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Left-  Censored Observations}}" _col(45) "= " r(N)
noi di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Left-UnCensored Observations}}" _col(45) "= " `N'-r(N)
noi di _dup(60) "-"
 }
 local llt=`ll'
 scalar spat_llt=`llt'
 gen `Time'=_n
 tsset `Time'
 mkmat `yvar' , matrix(`yvar')
 mkmat `yvar' , matrix(`Y')
 if "`nwmat'"!="" {
 local knw=`nwmat'
 forvalue i=`nwmat'/`nwmat' {
 matrix WMB_`i'=WMB
 cap drop mstar_W`i'
 gen double mstar_W`i'=`eigw'
 summ `eigw' 
 scalar minEig`i'=1/r(min)
 scalar maxEig`i'=1/r(max)
 forvalue i=1/`knw' {
 matrix `WYX' = WMB_`i'*`Y'
 mata: w`i'y_`yvar' = st_matrix("`WYX'")
 getmata w`i'y_`yvar' , force replace
 label variable w`i'y_`yvar' `"AR(`i') `yvar' Spatial Lag"'
 order w`i'y_* , last
 }
 }
 order mstar_W* , last
 }
 if inlist("`model'", "sararml", "sarargs", "sarariv") {
 tempfile WPMat
 cap drop _ID
 tempvar id
 svmat _WB , name(__WPMat_)
 gotoup , id(`id')
 replace `id' = _n-1
 replace `id' = _N-1 in 1
 order `id'
 outsheet `id' __WPMat_* using `WPMat'.txt, delimiter(" ") nonames nolabel replace
 gen double _ID=_n-1 
 drop in 1
 spmat dta WPMat __WPMat_* , id(`id') replace
 drop __WPMat_*
 spmat import WPMat using `WPMat'.txt, replace normalize(row)
 spmat export WPMat using `WPMat'.txt, replace
 spmat save WPMat using `WPMat'.spmat, replace
 spmat drop WPMat
 spmat use WPMat using `WPMat'.spmat
 erase `WPMat'.txt
 erase `WPMat'.spmat
 }
 tempname WS1 WS2 WS3 WS4
 matrix `WS1'= WMB
 matrix `WS2'= WMB*`WS1'
 if "`order'">"2" {
 matrix `WS3'= WMB*`WS2'
 matrix `WS4'= WMB*`WS3'
 }

 if "`model'"!="" {
 local y1y2 "`yvar' `endg' `endog'" 
 local ky1y2: word count `y1y2'
 forvalue i = 1/`ky1y2' {
 local var: word `i' of `y1y2'
 mkmat `var' , matrix(`WYX')
 matrix `WYX' = `WS1'*`WYX'
 mata: w1y_`var' = st_matrix("`WYX'")
 getmata w1y_`var' , force replace
 label variable w1y_`var' `"AR(`i') `var' Spatial Lag"'
 local WsY`i' "w1y_`var'"
 local WsYi "`WsYi' `WsY`i''"
 if "`tolog'"!="" {
 mkmat `_Ws'`var' , matrix(`WYX')
 matrix `WYX' = `WS1'*`WYX'
 mata: `_WsY'`i' = st_matrix("`WYX'")
 getmata `_WsY'`i' , force replace
 local _WsY`i' "`_WsY'`i'"
 }
 }
 local WsYi "`WsYi' `endog'"

 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") & "`xvar'"!="" {
 local xvar12 "`xvar1' `xvar2'"
 _rmcoll `xvar12' , `nocons' forcedrop
 local xvar12 "`r(varlist)'"
 forvalue i = 1/`order' {
 foreach var of local xvar12 {
 mkmat `var' , matrix(`WYX')
 matrix `WYX' = `WS`i''*`WYX'
 mata: w`i'x_`var' = st_matrix("`WYX'")
 getmata w`i'x_`var' , force replace
 label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 local WsXi "`WsXi' w`i'x_`var'"
 if "`tolog'"!="" {
 mkmat `_Ws'`var' , matrix(`WYX')
 matrix `WYX' = `WS`i''*`WYX'
 mata: `_WsX'`var' = st_matrix("`WYX'")
 getmata `_WsX'`var' , force replace
 local _WsXi "`_WsXi' `_WsX'`var'"
 }
 }
 }
 unab instx: `xvar12' `aux' `WsXi' `inst'
 _rmcoll `instx' , `nocons' forcedrop
 local instx "`r(varlist)'"
 unab exog: `xvar12' `aux'
 local inst : list instx-exog
 }
 local knw=1
 if inlist("`model'", "sdm", "durbin", "mstard", "sac", "sem", "gwr") & "`xvar'"!="" {
 local nwmat=1
 }
 if inlist("`model'", "sac") & "`xvar'"!="" {
 matrix `WS2'= `WS1'*WMB
 matrix `WYX' = `WS2'*`Y'
 mata: w2y_`yvar' = st_matrix("`WYX'")
 getmata w2y_`yvar' , force replace
 label variable w2y_`yvar' `"AR(2) `yvar' Spatial Lag"'
 }

 if inlist("`model'", "durbin", "mstard", "sac", "sdm", "sem", "gwr") & "`xvar'"!="" {
 local knw=`nwmat'
 forvalue i=1/`knw' {
 matrix WMB_`i'=WMB
 foreach var of local xvar1 {
 mkmat `var' , matrix(`WYX')
 matrix `WYX' = WMB_`i'*`WYX'
 mata: w`i'x_`var' = st_matrix("`WYX'")
 getmata w`i'x_`var' , force replace
 label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 local WsXi "`WsXi' w`i'x_`var'"
 order w`i'x_* , last
 }
 }
 if "`tolog'"!="" {
 forvalue i=1/`knw' {
 foreach var of local xvar1 {
 mkmat `_Ws'`var' , matrix(`WYX')
 matrix `WYX' = WMB_`i'*`WYX'
 mata: `_WsX'`i'`var' = st_matrix("`WYX'")
 getmata `_WsX'`i'`var' , force replace
 local _WsXi "`_WsXi' `_WsX'`i'`var'"
 }
 }
 }
 }
 if inlist("`model'", "gwr") {
 unab yvar: w1y_`yvar'
 unab xvar: w1x_*
 unab SPXvar: `xvar' `aux'
 summ `yvar' 
 scalar `MSPY' =r(mean)
 if "`tolog'"!="" {
 unab MSPXvar: `_xvar1' `aux'
 }
 }
 if inlist("`model'", "sar", "sem", "sac", "mstar", "spgmm", "sararml", "sarargs", "ols") {
 unab SPXvar: `xvar1' `aux'
 if "`tolog'"!="" {
 unab MSPXvar: `_xvar1' `aux'
 }
 }
 if inlist("`model'", "sdm", "durbin", "mstard") {
 unab SPXvar: `xvar1' `WsXi' `aux'
 if "`tolog'"!="" {
 unab MSPXvar: `_xvar1' `_WsXi' `aux'
 }
 }
 if inlist("`model'", "sarariv") {
 unab WsYi: `endog'
 unab SPXvar: `WsYi' `xvar1' `aux'
 unab exog: `xvar1' `aux'
 if "`tolog'"!="" {
 unab MSPXvar: `_endog' `_xvar1' `aux'
 }
 }
 if inlist("`model'", "lag", "gs2sls", "gs2slsar", "ivtobit") {
 local WsY1 "w1y_`yvar'"
 unab WsYi: `WsY1' `endog'
 unab SPXvar: `WsYi' `xvar1' `aux'
 unab exog: `xvar1' `aux'
 if "`tolog'"!="" {
 unab MSPXvar: `_WsY1' `_endog' `_xvar1' `aux'
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 local y1 "`yvar'"
 local y2 "`endg'"
 local WsY1 "w1y_`yvar'"
 local WsY2 "w1y_`endg'"
 unab SPXvar1: `WsY1' `WsY2' `y2' `xvar1' `aux'
 unab SPXvar2: `WsY1' `WsY2' `y1' `xvar2' `aux'
 if "`eq'"=="2" {
 unab WsYi: `WsY1' `WsY2' `y1'
 unab SPXvar: `SPXvar2'
 unab exog: `xvar2' `aux'
 local _Yo "`y2'"
 mkmat `_Yo' , matrix(`Y')
 summ `_Yo' 
 scalar `MSPY' =r(mean)
 }
 else {
 unab WsYi: `WsY1' `WsY2' `y2'
 unab SPXvar: `SPXvar1'
 unab exog: `xvar1' `aux'
 }
 if "`tolog'"!="" {
 unab MSPXvar1: `_WsY1' `_WsY2' `_y2' `_xvar1' `aux'
 unab MSPXvar2: `_WsY1' `_WsY2' `_y1' `_xvar2' `aux'
 if "`eq'"=="2" {
 unab MSPXvar: `MSPXvar2'
 }
 else {
 unab MSPXvar: `MSPXvar1'
 }
 }
 }
 if "`tolog'"!="" {
 mean `MSPXvar'
 matrix `MSPX'=e(b)
 }
 else {
 mean `SPXvar'
 matrix `MSPX'=e(b)
 }

 if inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "ivtobit") {
noi di
 local kendog : word count `WsYi'
 unab exog : `xvar' `aux'
 local inst : list instx-exog
 local kexog : word count `exog'
 local kinst : word count `inst'
 local kinstx: word count `instx'
 local kx =`kendog'+`kexog'
 local ky =1
 if `kinstx' < `kx' {
noi di as err " " "`run'" "{bf: cannot be Estimated} {cmd: - Equation }" "`yvar'" "{cmd: is Underidentified}" 
noi di _dup(65) "-" 
noi di as txt "{bf:** Y  = LHS Dependent Variable}
noi di as txt "   " `ky' " : " "`yvar'"
noi di as txt "{bf:** Yi = RHS Endogenous Variables}
noi di as txt "   " `kendog' " : " "`WsYi'"
noi di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
noi di as txt "   " `kexog' " : " "`xvar' `aux'"
noi di as txt "{bf:** Xj = RHS Excluded Exogenous Variables (Additional Instrumental Variables)}"
noi di as txt "   " `kinst' " : " "`inst'"
noi di as txt "{bf:** Z  = Overall Instrumental Variables}"
noi di as txt "   " `kinstx' " : "  "`instx'"
noi di _dup(70) "-" 
noi di as txt "{bf: Model is Under Identification:}"
noi di as txt _col(7) "Z(" `kinstx' ")" " < Yi + Xi (" `kx' ")
noi di as txt "* since: Z < Yi + Xi : it is recommended to use (OLS)"
noi di as err "  {bf:or let Instrumental Variables > Endogenous Variables}"
noi di _dup(70) "-"
 exit
 }
 }

 local kx : word count `SPXvar'
 gen `X0'=1
 gen `Wi'=1
 gen `Wi1'= 1
 gen `Wis'= 1
 local WiB =1
 local _Yo "`yvar'"
 local _Zo "`SPXvar'"
 local k0=1
 local k =0
 local cns ""
 if "`rest'"!="" {
 ereturn local k_autoCns= 0
 cap cnsreg `_Yo' `_Zo' , `noconstant' constr(`rest') noomitted
 if e(k_autoCns) != 0 {
noi di as err " {bf:Restrections must be Specified First, i,e:}"
noi di as txt " constraint define 1 x1 + x2 = 1"
noi di as txt " constraint define 1 y2 + x1 + x2 = 1"
noi di as txt " make sure that Endogenous or Exogenous Variables Restrections are Specified Correctly"
 exit
 }
 matrix `restc' = e(Cns)
 local krc= colsof(`restc')
 local krc1= `krc'-1
 local krr= rowsof(`restc')
 matrix `Rs' = `restc'[1..`krr', 1..`krc1']
 matrix `Rso'= `restc'[1..`krr', `krc'..`krc']
 local k = `krr'
 local cns "constr(`rest')"
 if inlist("`model'", "gs2sls", "gs2slsar") {
 ereturn matrix Rs=`Rs'
 ereturn matrix Rso=`Rso'
 }
 }
 mkmat `X0' , matrix(`X0')
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local k0=0
 mkmat `_Zo' , matrix(`Z')
 local kb= colsof(`Z')
 local kx= `kb'
 }
 else { 
 mkmat `_Zo' `X0' , matrix(`Z')
 local kb= colsof(`Z')
 local kx= `kb'-1
 }
 if "`xvar'"=="" {
 if `kb'== 1 {
 mkmat `X0' , matrix(`Z')
 local kb= 1
 local kx= 1
 }
 } 
 local kx=`kx'
 local kb=`kb'
 local Jkx=`kx'-`k'
 local Jkb=`kb'-`k'
 local DF=`N'-`Jkb'
 local in=`N'/`DF'
 if "`dn'"!="" {
 local DF=`N'
 local in=1
 }
 local JDF=`DF'
 global spat_kx=`kx'
 ereturn scalar df_m=$spat_kx

 local wgt ""
 if "`wvar'"!="" {
 replace `Wi' = (`wvar')^0.5 
 replace `Wis' = `wvar'
 local wtitle "Weighted Variable Type: (X)      -   Variable: (`wvar')"
 if "`weights'"=="" {
 local wgt " [weight = `Wis'] "
 }
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "x", "xi", "x2", "xi2") {
 cap drop `Wi'
 regress `_Yo' `_Zo' , `nocons'
 predict double `Yho' 
 predict double `Eo' , resid
 regress `Yho' `_Zo' , `nocons'
 predict double `Wi'
 if inlist("`weights'", "yh") {
 replace `Wi' = abs(`Wi')^0.5 
 local wtitle "Weighted Variable Type: (Yh)     -   Variable: Yh Predicted Value"
 }
 if inlist("`weights'", "abse") {
 local wtitle "Weighted Variable Type: (absE)   -   Variable: abs(E) Residual Absolute Value"
 replace `Wi' = abs(`Eo')^0.5 
 }
 if inlist("`weights'", "e2") {
 local wtitle "Weighted Variable Type: (E2)     -   Variable: E^2 Residual Squared"
 replace `Wi' = (`Eo'^2)^0.5 
 }
 if inlist("`weights'", "yh2") {
 cap drop `Wi'
 local wtitle "Weighted Variable Type: (Yh2)    -   Variable: Yh^2 Predicted Value Squared"
 gen double `Yho2' = `Yho'^2 
 regress `Yho2' `_Zo' , `nocons'
 predict double `Wi' , xb
 replace `Wi' = abs(`Wi')^0.5 
 } 
 }
 if inlist("`weights'", "x") {
 local wtitle "Weighted Variable Type: (X)      -   Variable: (`wvar')"
 replace `Wi' = (`wvar')^0.5 
 } 
 if inlist("`weights'", "xi") {
 local wtitle "Weighted Variable Type: (Xi)     -   Variable: (1/`wvar')"
 replace `Wi' = 1/(`wvar'^0.5) 
 } 
 if inlist("`weights'", "x2") {
 local wtitle "Weighted Variable Type: (X2)     -   Variable: (`wvar')^2"
 replace `Wi' = (`wvar')
 } 
 if inlist("`weights'", "xi2") {
 local wtitle "Weighted Variable Type: (Xi2)    -   Variable: (1/`wvar')^2"
 replace `Wi' = 1/(`wvar')
 }
 replace `Wi' = 0 if `Wi'==.
 replace `Wis' =`Wi'^2 
 local wgt " [weight = `Wis'] "
 }

 if "`wvar'"!="" | "`weights'"!="" {
 if inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") {
 local wgt "[aweight=`Wis']"
 }
 summ `Wi' 
 local WiB =r(mean)
 summ `Wis' 
 replace `Wi1'= sqrt(`Wis'/r(mean)) 
 }
 mkmat `Wi' , matrix(`Wi')
 mata: Wi = st_matrix("`Wi'")
 matrix `Wi'= diag(`Wi')
 mkmat `Wi1' , matrix(`Wi1')
 mata: Wi1 = st_matrix("`Wi1'")
 matrix `Wi1' = diag(`Wi1')
 mkmat `Wis' , matrix(`Wis')
 mata: Wis = st_matrix("`Wis'")
 matrix `Omega'=`Wi''*`Wi'
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `Yws'=`Wi'*`Y'
 matrix `Zws'=`Wi'*`Z'
 scalar `Kr'=0
 matrix `Zz'=I(`kb')*0
 gen double `Zo'= `Wi'
 local _Yw "`_Yo'"
 local _Zw "`_Zo'"
 gen `Zw'=.
 local Yw_Zw "`X0' `_Yo' `_Zo'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Zw'
 replace `Zw' = `v'*`Wi'
 gen double `WLSVar'_`i' = `Zw'
 }
 unab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local Zo `1'
 macro shift
 local bXWLS "`*'"
 gettoken _Yw _Zw : bXWLS

 if "`xvar'"!="" {
 if "`ridge'"!="" {
 if inlist("`ridge'", "orr") {
 local rtitle "{bf:Ordinary Ridge Regression}"
 }
 if inlist("`ridge'", "grr1") {
 local rtitle "{bf:Generalized Ridge Regression}"
 }
 if inlist("`ridge'", "grr2") {
 local rtitle "{bf:Iterative Generalized Ridge Regression}"
 }
 if inlist("`ridge'", "grr3") {
 local rtitle "{bf:Adaptive Generalized Ridge Regression}"
 }
 }
 if !inlist("`model'", "spgmm", "sararml", "sarargs", "sarariv", "gs3sls", "gs2slsar", "gs3slsar") {
 if "`ridge'"!="" {
 scalar `Kr'=`kr'
 local Ro1= 0 
 replace `Zo' = `WiB'
 local Zo_Zw "`Zo' `_Zw'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" | "`noconexog'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v' - r(mean)
 }
 }
 unab ZSLSVar : `SLSVar'_*
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 replace `ZoC' = 0
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" | "`noconexog'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 mkmat `_Zw' , matrix(`Zws')
 tabstat `_Zw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 mkmat `_Zw' `Zo' , matrix(`Zws')
 tabstat `_Zw' `ZoC' , statistics( sd ) save
 }
 if inlist("`ridge'", "orr") {
 local rtitle "{bf:Ordinary Ridge Regression}"
 }
 if inlist("`ridge'", "grr1") {
 local rtitle "{bf:Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Zws''*`Zws')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Zws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 }
 if inlist("`ridge'", "grr2") {
 local rtitle "{bf:Iterative Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Zws''*`Zws')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Zws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 forvalue i=1/`iter' { 
 scalar `Ko'=`Kr'
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag(`Zr''*`Zr'*`rid'))
 matrix `Beta'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 tempname Kit`i' Koi
 scalar `Kit`i''=`kx'*`Sig2o1'/`BOLS1'
 scalar `Kr'=`Kit`i''
 if `Kr'==. {
 scalar `Kr'=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= `tolerance') {
 continue, break
 }
 }
 }
 if inlist("`ridge'", "grr3") {
 local rtitle "{bf:Adaptive Generalized Ridge Regression}"
 corr `_Zw' `_Yw'
 matrix `CovC'=r(C)
 matrix `RY' = `CovC'[`kb' ,1..`kx']
 matrix `RX' = `CovC'[1..`kx', 1..`kx']
 matrix symeigen `Vec' `VaL'=`RX'
 matrix `VaL1' =`VaL''
 svmat double `VaL1' , name(`VaL1')
 rename `VaL1'1 `VaL1'
 replace `VaL1'=1/`VaL1' in 1/`kx' 
 mkmat `VaL1' in 1/`kx' , matrix(`VaLv1')
 matrix `VaL21' =diag(`VaLv1')
 matrix `VaL21' = `VaL21'[1..`kx', 1..`kx']
 matrix `Go'=`Vec'*`VaL21'*`Vec''
 matrix `GoRY'=`Go'*`RY''
 matrix `SSE'=1-`RY'*`GoRY'
 matrix `Sig2'=`SSE'/`DF'
 matrix `Qr'=`GoRY''*`GoRY'-`Sig2'*trace(`Go')
 matrix `LVR'=`Vec''*`RY''
 svmat double `LVR' , name(`LVR')
 rename `LVR'1 `LVR'
 scalar `Kr'=0
 forvalue i=1/`iter' { 
 tempname Ko`i'
 scalar `Ko'=`Kr'
 scalar `Ko`i''=`Kr'
 matrix `rid'=I(`kx')
 matrix `rid'=vecdiag(`rid')*`Kr'
 matrix `f1'=`VaL1'+`rid''
 cap drop `f1'*
 cap drop `f13'*
 svmat double `f1' , name(`f1')
 rename `f1'1 `f1'
 gen double `f13'`i'=`f1'^3 in 1/`kx'
 mkmat `f13'`i' in 1/`kx' , matrix(`f13')
 matrix `f13d'=diag(`f13')
 matrix `f13' =`f13d'[1..`kx', 1..`kx']
 matrix `Rmk' =vecdiag(`f13')'
 matrix `IDRmk'=invsym(`f13')
 matrix `Lms'=`LVR''*`IDRmk'
 matrix `Lms'=(`Lms'*diag(`LVR'))'
 cap drop `Lms' `lf'
 svmat double `Lms' , name(`Lms'`i')
 rename `Lms'`i'1 `Lms'`i'
 summ `Lms'`i' in 1/`kx'
 scalar `SLS'=r(sum)
 gen double `lf'`i'=`LVR'/`f1' in 1/`kx'
 mkmat `lf'`i' in 1/`kx' , matrix(`lf'`i')
 matrix `lf'`i' =diag(`lf'`i')
 matrix `lf'`i' = `lf'`i'[1..`kx', 1..`kx']
 matrix `lf'`i' = vecdiag(`lf'`i')'
 matrix `F'=`lf'`i''*`lf'`i'-`Qr'
 scalar `Kk'`i'=`Ko`i''+(0.5*`F'[1,1]/`SLS')
 scalar `Kr'=`Kk'`i'
 if `Kr'==. {
 scalar `Kr'=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= `tolerance') {
 continue, break
 }
 }
 }
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 }
 }
 scalar `llf'=.
 matrix `In'=I(`N')
 if inlist("`model'", "spgmm", "gs2sls", "gs2slsar") {
 tsset `Time'
 ereturn scalar Nn=`N'
 ereturn scalar Kr=`Kr'
 ereturn scalar k=`k'
 ereturn scalar k0=`k0'
 ereturn scalar kx=`kx'
 ereturn scalar kb=`kb'
 ereturn matrix Zz=`Zz'
 ereturn matrix Wi=`Wi'
 }
 matrix `Wi'=e(Wi)

 if inlist("`model'", "gwr", "ols", "lag", "durbin") & inlist("`run'", "ols", "tobit", "sfa") {
 if inlist("`model'", "ols") & "`run'"!="" {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Non Spatial Regression: {cmd:Model(`model') - Run(`run')}}}"
 }
 if inlist("`model'", "lag") & "`run'"!="" {
noi di as txt "{bf:{err:* Spatial Lag Regression (SAR): {cmd:Model(`model') - Run(`run')}}}"
 }
 if inlist("`model'", "durbin") & "`run'"!="" {
noi di as txt "{bf:{err:* Spatial Durbin Regression (SDM): {cmd:Model(`model') - Run(`run')}}}"
 }
 if inlist("`model'", "gwr") & "`run'"!="" {
noi di as txt "{bf:{err:* Spatial Geographically Weighted Regression (GWR): {cmd:Model(`model') - Run(`run')}}}"
 }
noi di _dup(78) "{bf:{err:=}}"
 tsset `Time'

 if inlist("`run'", "ols") {
 if "`rest'"!="" {
 cnsreg `_Yo' `_Zo' `wgt' , `robust' `nocons' `vce' `level' `cns'
 }
 else {
 regress `_Yo' `_Zo' `wgt' , `robust' `nocons' `vce' `level'
 }
 }
 if inlist("`run'", "tobit") {
 tobit `_Yo' `_Zo' `wgt' , `nocons' `vce' iter(`iter') `level' ll(`llt')
 }
 if inlist("`run'", "sfa") {
 frontier `_Yo' `_Zo' `wgt' , `nocons' `vce' `cost' `cns' ///
 iter(`iter') tech(`tech') `level' vhet(`vhet')
 }

 if inlist("`model'", "lag") {
 tempname rRo rRot rRodf rRodfr rRotp
 test _b[w1y_`yvar'] =0
 scalar `rRo'=_b[w1y_`yvar']
 if inlist("`run'", "sfa") {
 scalar `rRot'=r(chi2)
 scalar `rRodf'=r(df)
 scalar `rRotp'=r(p)
 }
 if inlist("`run'", "ols", "tobit") {
 scalar `rRot'=r(F)
 scalar `rRodf'=r(df)
 scalar `rRodfr'=r(df_r)
 scalar `rRotp'=r(p)
 }
 } 
 scalar `llf'=e(ll)
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=`Z'*`B'
 }

 if inlist("`model'", "ivtobit") {
 local itern "iter(`iter')"
 local techn "tech(`tech')"
 local lln "ll(`llt')"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* IV Tobit Spatial Model (IVTobit)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `_Yo' `_Zo'
 if "`twostep'"!="" {
 ivtobit `yvar' `xvar1' `aux' (`WsYi' = `inst') `wgt' , `cns' twostep ///
 `lln' `vce' `first' `robust' `level'
 }
 else {
 ivtobit `yvar' `xvar1' `aux' (`WsYi' = `inst') `wgt' , `cns' mle ///
 `lln' `vce' `first' `robust' `level' `itern' `techn'
 }
 scalar Wald_chi2_exog=e(chi2_exog)
 scalar Wald_chi2_exogdf=e(df_exog)
 scalar Wald_chi2_exogp=e(p_exog)
 scalar `llf'=e(ll)
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `rRo'=`B'[1,1]
 matrix `Yh_ML'=`Z'*`B'
 }

 if inlist("`model'", "sararml", "sarargs", "sarariv") {
 if inlist("`model'", "sararml") {
 cap spreg ml `yvar' `xvar1' , id(_ID)
 if "`e(cmd)'"!="spreg" {
noi di
noi di as err " {bf:model(sararml)} {cmd:requires Stata v11.2 and (sppack) module}"
 exit
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE - Spatial Lag / Autoregressive Error (SARARML-MLE)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `_Yo' `_Zo'
 spreg ml `yvar' `xvar1' `aux' , id(_ID) dlmat(WPMat) elmat(WPMat) `grids' `noconstant'
 }

 if inlist("`model'", "sarargs") {
 cap spreg gs2sls `yvar' `xvar1' , id(_ID)
 if "`e(cmd)'"!="spreg" {
noi di
noi di as err " {bf:model(sarargs)} {cmd:requires Stata v11.2 and (sppack) module}"
 exit
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `_Yo' `_Zo'
 spreg gs2sls `yvar' `xvar1' `aux', id(_ID) dlmat(WPMat) elmat(WPMat) `het' `nocons'
 }

 if inlist("`model'", "sarariv") {
 cap spivreg `yvar' `xvar1' , id(_ID)
 if "`e(cmd)'"!="spivreg" {
noi di
noi di as err " {bf:model(sarariv)} {cmd:requires Stata v11.2 and (sppack) module}"
 exit
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `_Yo' `_Zo'
 local MName "MLESARARIV"
 spivreg `yvar' `xvar1' `aux' (`WsYi' = `inst') , id(_ID) ///
 dlmat(WPMat) elmat(WPMat) `het' impower(`impower') `nocons'
 }
 scalar `llf'=e(ll)
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov'= `Cov'[1..`kb', 1..`kb']
 scalar `rRo'=[rho]_b[_cons]
 scalar `rLm'=[lambda]_b[_cons]
 test [lambda]_b[_cons]=0
noi di as txt _col(2) "Lambda Value =" %8.4f `rLm' _col(31) "Wald Test =" %9.3f r(chi2) _col(54) "P-Value > Chi2(1)" _col(74) %5.3f r(p)
 test [rho]_b[_cons]=0
noi di as txt _col(2) "Rho    Value =" %8.4f `rRo' _col(31) "Wald Test =" %9.3f r(chi2) _col(54) "P-Value > Chi2(1)" _col(74) %5.3f r(p)
 matrix `IRWR' = inv(`In'-`rRo'*WMB)
 matrix `IRWL' = inv(`In'-`rLm'*WMB)
 matrix `Yh_ML'=`Z'*`B'
 cap drop _ID
 cap spmat drop WPMat
noi di _dup(78) "-"
 }

 if inlist("`model'", "spgmm") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Spatial Autoregressive Generalized Method of Moments (SPGMM)}}"
noi di _dup(78) "{bf:{err:=}}"
 ereturn scalar kb=`kb'
 ereturn scalar kx=`kx'
 ereturn scalar DF=`DF'
 ereturn scalar Nn=`N'
 spregcs01 `_Yo' `_Zo' , `noconstant' ll(`llt') `dn' `vce' tolerance(`tolerance') ///
 rest(`rest') `robust' aux(`aux') wit(`Wi') ridge(`ridge') kr(`kr') `tobit' iter(`iter')
 scalar `llf'=e(llf)
 matrix `B'=e(b)
 matrix `Cov'= e(V)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=`Z'*`B'
 if "`ridge'"!="" {
 local rtitle =e(rtitle)
 local Kr =e(Kr)
 }
 } 

 if inlist("`model'", "gs2sls", "gs2slsar") {
 if inlist("`model'", "gs2sls") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Spatial Two Stage Least Squares (GS2SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
noi spregcs02 `yvar' `xvar1' `aux' (`WsYi' = `inst') , run(`run') hetcov(`hetcov') ///
 `dn' rest(`rest') `nocons' `noconexog' kf(`kf') kc(`kc') ridge(`ridge') kr(`kr')
 }

 if inlist("`model'", "gs2slsar") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Spatial Autoregressive Two Stage Least Squares (GS2SLS-AR)}}"
noi di _dup(78) "{bf:{err:=}}"
 local Xvar2sls `xvar1' `aux'
noi spregcs03 `yvar' `xvar1' (`WsYi' = `inst') , aux(`aux') wit(`Wi') ///
 `dn' rest(`rest') `noconstant' `noconexog' kf(`kf') kc(`kc') hetcov(`hetcov') run(`run') ///
 order(`order') ridge(`ridge') kr(`kr') tolerance(`tolerance') iter(`iter')
 }
 matrix `B'=e(b)
 matrix `Cov'= e(V)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=`Z'*`B'
 if "`ridge'"!="" {
 local Kr =e(Kr)
 }
 if inlist("`run'", "gmm") {
 local lmihj=e(lmihj)
 local dfgmm=e(dfgmm)
 local lmihjp=e(lmihjp)
 }
 }

 if inlist("`model'", "gs3sls", "gs3slsar") {
 ereturn scalar kb=`kb'
 ereturn scalar Nn=`N'
noi di _dup(78) "{bf:{err:=}}"
 if inlist("`model'", "gs3sls") {
noi di as txt "{bf:{err:* Generalized Spatial Three Stage Least Squares (GS3SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `yvar' `SPXvar1'
noi yxregeq `endg' `SPXvar2'
noi spregcs04 `yvar' `xvar1' , `noconstant' `vce' aux(`aux') inst(`inst') wit(`Wis') ///
 var2(`var2') order(`order') `ols' `2sls' `3sls' `sure' `mvreg' `first'
 }
 if inlist("`model'", "gs3slsar") {
noi di as txt "{bf:{err:* Generalized Spatial Autoregressive Three Stage Least Squares (GS3SLSAR)}}"
noi di _dup(78) "{bf:{err:=}}"
noi yxregeq `yvar' `SPXvar1'
noi yxregeq `endg' `SPXvar2'
noi spregcs05 `yvar' `xvar1' , `noconstant' `vce' aux(`aux') inst(`inst') wit(`Wis') ///
 var2(`var2') order(`order') `ols' `2sls' `3sls' `sure' `mvreg' `first'
 }
noi di _dup(78) "{bf:{err:=}}"
 tempname XB1 XB2 Eu1 Eu2 X3SLS1 X3SLS2 B3SLS1 B3SLS2 X kb llf R20 DF kbc1 kbc2
 if "`eq'"=="2" {
 scalar `kb'=e(kb2)
 scalar `kbc1'=e(kb1)+1
 scalar `kbc2'=e(kb1)+e(kb2)
 matrix `B'=e(B3SLS2)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov'=`Cov'[`kbc1'..`kbc2', `kbc1'..`kbc2']
 scalar `llf'=e(llf2)
 scalar `R20'=e(r2h2)
 }
 else {
 scalar `kb'=e(kb1)
 matrix `B'=e(B3SLS1)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(llf1)
 scalar `R20'=e(r2h1)
 }
 scalar `DF'=`N'-`kb'
 matrix `Yh_ML'=`Z'*`B'
 }

 if "`lmspac'"!= "" {
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 reg3 (`_Yo' `_Zo' , `nocons') `wgt' , `nocons' `cns' small ols
 } 
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 reg3 (`_Yo' = `WsYi' `exog' , `nocons') `wgt' , `nocons' `cns' inst(`instx') small 2sls
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 reg3 (`_Yo' = `WsYi' `exog' , `nocons') `wgt' , `nocons' `cns' inst(`instx') small 3sls
 }
 matrix `Bx_SP'=e(b)
 predict double `Ue_SP' , resid
 local uspn "usp(`Ue_SP')"
* mkmat `Ue_SP' , matrix(`Ue_SP')
 }
 mlopts mlopts , `vce' iter(`iter') tech(`tech')

 if inlist("`model'", "mstar", "mstard") {
 global spat_kx=`kx'
 ereturn scalar df_m=`kx'
 forvalue i=1/`kx' {
 local var : word `i' of `xvar'
 local COLNAME "`COLNAME'`yvar':`var' " 
 }
 if inlist("`model'", "mstar") {
 local usemstar "Lag"
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 }
 if inlist("`model'", "mstard") {
 local usemstar "Durbin"
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 }
 matrix `Bo'=e(b)
 local rmse=e(rmse)

 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="1" {
 if inlist("`model'", "mstar", "mstard") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "MSTAR1n"
 matrix `olsin'=`Bo',0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs06 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Normal Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR1e"
 ml model lf spregcs07 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) `wgt' , `cns' `mlopts' `nolog' `diparm' `initopt' maximize ///
 title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Exponential Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR1w"
 matrix `olsin'=`Bo',0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs08 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Weibull Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR1h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs09 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Sigma:) `wgt', `cns' `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (1 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Model}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `BetaSP'=e(b)
 scalar `Rostar'=_b[/Rho1]
 test [Rho1]_cons
 matrix `IRWR' = inv(`In'-_b[/Rho1]*WMB_1)
 }

 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="2" {
 if inlist("`model'", "mstar", "mstard") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "MSTAR2n"
 matrix `olsin'=`Bo',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs10 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Normal Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR2e"
 ml model lf spregcs11 (`yvar': `yvar' = `SPXvar' , `noconstant') (Rho1:) (Rho2:) ///
 `wgt' , `cns' `mlopts' `nolog' `diparm' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Exponential Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR2w"
 matrix `olsin'=`Bo',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs12 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Weibull Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR2h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs13 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Sigma:) `wgt' , `cns' `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (2 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Model}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `BetaSP'=e(b)
 scalar `Rostar'=_b[/Rho1]+_b[/Rho2]
 test [Rho1]_cons [Rho2]_cons
 matrix `IRWR' = inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2)
 }

 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="3" {
 if inlist("`model'", "mstar", "mstard") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "MSTAR3n"
 matrix `olsin'=`Bo',0,0,0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs14 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' ///
 `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Normal Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR3e"
 ml model lf spregcs15 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) `wgt' , `cns' `mlopts' `nolog' `diparm' maximize ///
 title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Exponential Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR3w"
 matrix `olsin'=`Bo',0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs16 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' ///
 `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Weibull Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR3h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs17 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt', `cns' `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (3 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Model}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `BetaSP'=e(b)
 scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]
 test [Rho1]_cons [Rho2]_cons [Rho3]_cons
 matrix `IRWR'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3)
 }

 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="4" {
 if inlist("`model'", "mstar", "mstard") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "MSTAR4n"
 matrix `olsin'=`Bo',0,0,0,0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs18 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `cns' `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Normal Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR4e"
 ml model lf spregcs19 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) `wgt' , ///
 `cns' `mlopts' `nolog' `diparm' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Exponential Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR4w"
 matrix `olsin'=`Bo',0,0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs20 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `cns' `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Weibull Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR4h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',0,0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs21 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt', ///
 `cns' `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (4 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Model}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `BetaSP'=e(b)
 scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]+_b[/Rho4]
 test [Rho1]_cons [Rho2]_cons [Rho3]_cons [Rho4]_cons
 matrix `IRWR'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3-_b[/Rho4]*WMB_4)
 }
 scalar `waldm'=e(chi2)
 scalar `waldmp'=e(p)
 scalar `waldm_df'=e(df_m)
 scalar `waldr'=r(chi2)
 scalar `waldrp'=r(p)
 scalar `waldr_df'=r(df)
 ereturn repost b=`BetaSP' , rename
 matrix `B'=e(b)
 matrix `Cov'=e(V)
 matrix `B'=`B'[1,1..`kb']'
 scalar `llf'=e(ll)
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=`Z'*`B'
 }

 if inlist("`model'", "sem", "sar", "sdm", "sac") {
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 matrix `Bo'=e(b)
 local rmse=e(rmse)
 cap macro drop spat_*
 cap drop spat_*
 gen double spat_eigw= `eigw'
 global spat_kx=`kx'
 ereturn scalar df_m=`kx'
 global spat_kx : word count `SPXvar'
 forvalue i=1/$spat_kx {
 local var : word `i' of `SPXvar'
 local MODEL "`MODEL'(`var':) "
 local spat_ARGS "`spat_ARGS' beta`i'" 
 }
 forvalue i=1/$spat_kx {
 local var : word `i' of `SPXvar'
 local COLNAME "`COLNAME'`yvar':`var' " 
 }
 if inlist("`model'", "sem", "sac") {
 local i=1
 foreach var of local xvar {
 gen double spat_w1x_`i' = w1x_`var'
 local ++i
 }
 }

 if inlist("`model'", "sem") {
 if inlist("`model'", "sem") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SEM1n"
 matrix spat_ols=`Bo',`inlambda',`rmse'
 local initopt init(spat_ols, copy)
 local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spregcs22 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Error Normal Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sem") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SEM1e"
 matrix spat_ols=`Bo',`inlambda'
 local initopt init(spat_ols, copy)
 local MODEL "`MODEL'(_cons:) (Lambda:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda"
 ml model lf spregcs23 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Error Exponential Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sem") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SEM1w"
 matrix spat_ols=`Bo',`inlambda',`rmse'
 local initopt init(spat_ols, copy)
 local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spregcs24 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Error Weibull Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 }

 if inlist("`model'", "sar") {
 if inlist("`model'", "sar") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SAR1n"
 matrix `olsin'=`Bo',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs25 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Lag Normal Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sar") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SAR1e"
 matrix `olsin'=`Bo',`inrho'
 local initopt init(`olsin', copy)
 ml model lf spregcs26 (`yvar': `yvar' = `SPXvar' , `noconstant') ///
 (Rho:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' maximize ///
 title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Lag Exponential Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sar") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SAR1w"
 matrix `olsin'=`Bo',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs27 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Lag Weibull Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sar") & "`mhet'"!="" {
 local MName "SAR1h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',`inrho',`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs28 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `cns' `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Lag Multiplicative Heteroscedasticity}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }

 if inlist("`model'", "sdm") {
 if inlist("`model'", "sdm") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SDM1n"
 matrix `olsin'=`Bo',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs29 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Durbin Normal Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sdm") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SDM1e"
 matrix `olsin'=`Bo',0
 local initopt init(`olsin', copy)
 ml model lf spregcs30 (`yvar': `yvar' = `SPXvar' , `noconstant' ) (Rho:) `wgt' , ///
 `cns' `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Durbin Exponential Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sdm") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SDM1w"
 matrix `olsin'=`Bo',`inrho',`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregcs31 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Durbin Weibull Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if "`model'"=="sdm" & "`mhet'"!="" {
 local MName "SDM1h"
 regress `yvar' `mhet' , noconstant
 matrix `olshet'=e(b)
 matrix `olsin'=`Bo',`olshet',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregcs32 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `cns' `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Durbin Multiplicative Heteroscedasticity}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }

 if "`model'"=="sac" {
 if inlist("`model'", "sac") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SAC1n"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix spat_ols=`Bo',`inrho',`inlambda',`rmse'
 local initopt init(spat_ols, copy)
 ml model lf spregcs33 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial AutoCorrelation Normal Model (SAC)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sac") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SAC1e"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda"
 matrix spat_ols=`Bo',`inrho',`inlambda'
 local initopt init(spat_ols, copy) 
 ml model lf spregcs34 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial AutoCorrelation Exponential Model (SAC)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sac") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SAC1w"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix spat_ols=`Bo',`inrho',`inlambda',`rmse'
 local initopt init(spat_ols, copy)
 ml model lf spregcs35 `MODEL' `wgt' , `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial AutoCorrelation Weibull Model (SAC)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 matrix `IRWL' = inv(`In'-_b[/Lambda]*WMB)
 }
 scalar `llf'=e(ll)
 matrix `BetaSP'=e(b)
 matrix `B'=`BetaSP'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=`Z'*`B'
 if inlist("`model'", "sdm") {
 testparm w1x_*
 scalar `waldx'=r(chi2)
 scalar `waldxp'=r(p)
 scalar `waldx_df'=r(df)
 }
 if inlist("`model'", "sac") {
 scalar `rLm'=_b[/Lambda]
 scalar `rRo'=_b[/Rho]
 test ([Rho]_b[_cons]=0) ([Lambda]_cons=0)
 scalar `waldj'=r(chi2)
 scalar `waldjp'=r(p)
 scalar `waldj_df'=r(df)
 }
 if inlist("`model'", "sem", "sac") {
 scalar `rLm'=_b[/Lambda]
 test [Lambda]_cons
 scalar `waldl'=r(chi2)
 scalar `waldlp'=r(p)
 scalar `waldl_df'=r(df)
 }
 if inlist("`model'", "sar", "sdm", "sac") {
 scalar `rRo'=_b[/Rho]
 test [Rho]_b[_cons]
 scalar `waldr'=r(chi2)
 scalar `waldrp'=r(p)
 scalar `waldr_df'=r(df)
 }

 ereturn scalar df_m=$spat_kx
 if inlist("`model'", "sem", "sac") & "`noconstant'"=="" {
 matrix colnames `BetaSP'=`COLNAME'
 } 
 ereturn repost b=`BetaSP' , rename
 matrix `BetaSP'=e(b)
 scalar `waldm'=e(chi2)
 scalar `waldmp'=e(p)
 scalar `waldm_df'=e(df_m)
 ereturn scalar df_m=$spat_kx
 ereturn scalar k_aux=2
 if inlist("`model'", "sem") & !inlist("`dist'", "exp") {
 ereturn scalar k_eq=3
 ereturn scalar k_aux=1
 }
 if inlist("`model'", "sem") & inlist("`dist'", "exp") {
 ereturn scalar k_eq=2
 ereturn scalar k_aux=1
 }
 if inlist("`model'", "sac") & inlist("`dist'", "exp") {
 ereturn scalar k_eq=3
 ereturn scalar k_aux=2
 }
 if inlist("`model'", "sac") & !inlist("`dist'", "exp") {
 ereturn scalar k_eq=4
 ereturn scalar k_aux=2
 }
 }

 if inlist("`model'", "sar","sdm","sac","sararml","sarargs","sarariv","mstar","mstard") {
 matrix `IRW' = `IRWR'
 if inlist("`spar'", "lam") {
 matrix `IRW' = `IRWL'
 }
 matrix `Yh_ML'=`IRW'*`Yh_ML'
 }
 if inlist("`model'", "sem") {
 matrix `Yh_ML'=`Z'*`B'
 }
 if inlist("`model'", "sar", "sdm", "sac") & inlist("`dist'","exp") {
 matrix `Yh_ML'=`Z'*`B'
 }

 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 getmata `Yh_ML' , force replace
 gen double `Ue_ML' =`yvar'-`Yh_ML'
 matrix `Ue_ML'=`Y'-`Yh_ML'
 local N=_N
 matrix Yh_ML=`Yh_ML'
 matrix Ue_ML=`Ue_ML'
 tempvar E Yh Ue_MLo Yh_MLo
 tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 fp Phi Ue_MLo Yh_MLo r2v r2v_a
 tempname f fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho D DJ11 DJ20 DJ22

 local wgt " [weight = `Wis'] "
 if inlist("`model'", "spgmm", "gs2sls", "gs2slsar") {
 }
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local Zo ""
 }
 else { 
 local Zo "`Zo'"
 }
 if inlist("`model'", "ols", "lag", "durbin", "gwr", "gs2sls", "gs2slsar") {
 matrix `E'=`Wi'*Ue_ML
 }
 else {
 matrix `E'=Ue_ML
 }

if !inlist("`model'", "sar, "sem, "sdm", "sac", "mstar", "mstard", "sararml", "sarargs", "sarariv", "ivtobit") {
 matrix `Ue_ML' = `Wi1'*(`Ue_ML')
 matrix `Yh_ML' = `Wi1'*(`Yh_ML')
 }
 matrix `Ue_MLo' = (`Y'-`Z'*`B')
 matrix `Yh_MLo' = (`Z'*`B')
 matrix `U' =`Ue_MLo'
 mata: `Yh_MLo' = st_matrix("`Yh_MLo'")
 mata: `Ue_MLo' = st_matrix("`Ue_MLo'")
 getmata `Yh_MLo' , force replace
 getmata `Ue_MLo' , force replace
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Yh_ML' , force replace
 getmata `Ue_ML' , force replace
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 gen double `Yh'=`Yh_ML' 
 gen double `E' =`Ue_ML' 
 matrix `SSE'=`U''*`U'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 scalar `Sigo'=sqrt(`Sig2o')
 summ `Yh_MLo' `wgt'
 local NUM=r(Var)
 summ `_Yo' `wgt'
 local DEN=r(Var)
 scalar `r2v'=`NUM'/`DEN'
 scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`JDF')
 scalar `fv'=`r2v'/(1-`r2v')*(`N'-`Jkb')/(`Jkx')
 scalar `fvp'=Ftail(`Jkx', `JDF', `fv')
 if "`wvar'"!="" | "`weights'"!="" {
 correlate `Yh_MLo' `_Yo' `wgt'
 }
 else {
 correlate `Yh_ML' `_Yo'
 }
 scalar `r2h'=r(rho)*r(rho)
 scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`JDF')
 scalar `fh'=`r2h'/(1-`r2h')*(`N'-`Jkb')/(`Jkx')
 scalar `fhp'=Ftail(`Jkx', `JDF', `fh')
 matrix `P' =(`Wi1')
 matrix `IPhi'=`P''*`P'
 matrix `Phi'=inv(`P''*`P')
 matrix `J'= J(`N',1,1)
 matrix `DJ11'=(`J'*`J''*`IPhi')
 matrix `DJ20'=(`J''*`IPhi'*`J')
 scalar `DJ22'=`DJ20'[1,1]
 matrix `D'=`DJ11'/`DJ22'
 matrix `SSE'=`U''*`IPhi'*`U'
 matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
 matrix `SST2'=(`Y''*`IPhi'*`Y')
 scalar `SSE1'=`SSE'[1,1]
 scalar `SST11'=`SST1'[1,1]
 scalar `SST21'=`SST2'[1,1]
 scalar `r2bu'=1-`SSE1'/`SST11'
 if `r2bu'< 0 {
 scalar `r2bu'=`r2h'
 }
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`JDF')
 if inlist("`run'", "qreg", "rreg") {
 local R2_P_a=1-((1-`R2_P')*(`N'-1)/`JDF')
 local f_P=`R2_P'/(1-`R2_P')*(`N'-`Jkb')/`Jkx'
 local f_Pp= Ftail(`Jkx', `JDF', `f_P')
 }
 scalar `r2raw'=1-`SSE1'/`SST21'
 scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`JDF')
 scalar `R20'=`r2bu'
 local fr=`r2raw'/(1-`r2raw')*(`N'-`Jkb')/`Jkb'
 local frp= Ftail(`kx', `DF', `fr')
 local f =`R20'/(1-`R20')*(`N'-`Jkb')/`Jkx'
 local fp = Ftail(`Jkx', `JDF', `f')
 local wald =`f'*`Jkx'
 local waldp =chi2tail(`Jkx', abs(`wald'))
 if `llf' == . {
 local llf =-(`N'/2)*log(2*_pi*`Sig2n')-(`N'/2)
 if "`wvar'"!="" | "`weights'"!="" {
 tempname Ew SSEw SSEw1 Sig2wn LWi21 LWi2
 matrix `Ew'=`Wi1'*(`Y'-`Z'*`B')
 matrix `SSEw'=(`Ew''*`Ew')
 scalar `SSEw1'=`SSEw'[1,1]
 scalar `Sig2n'=`SSEw1'/`N'
 scalar `Sig2o'=`SSEw1'/`JDF'
 scalar `Sigo'=sqrt(`Sig2o')
 gen double `LWi2'= 0.5*ln(`Wi1'^2) 
 summ `LWi2' 
 scalar `LWi21'=r(sum)
 local llf =-`N'/2*ln(2*_pi*`Sig2n')+`LWi21'-(`N'/2)
 }
 }
 local Nof =`N'
 local Dof =`JDF'
 matrix `B'=`B''
 if "`noconstant'"!="" | "`noconexog'"!="" {
 matrix colnames `Cov' = `SPXvar'
 matrix rownames `Cov' = `SPXvar'
 matrix colnames `B'   = `SPXvar'
 }
 else { 
 matrix colnames `Cov' = `SPXvar' _cons
 matrix rownames `Cov' = `SPXvar' _cons
 matrix colnames `B'   = `SPXvar' _cons
 }
noi yxregeq `_Yo' `_Zo'
 if "`rest'"!="" {
noi di as err "* Restrictions:"
noi constraint dir 
noi di _dup(78) "-"
 }
 if "`wvar'"!="" | "`weights'"!="" {
noi di as txt "{bf: * " "`wtitle'" " *}"
 noi di as txt "{hline 78}"
 }
 if "`ridge'"!="" {
noi di as txt "{bf: * Ridge k Value}" _col(21) "=" %10.5f `Kr' _col(37) "|" _col(41) "`rtitle'"
noi di as txt "{hline 78}"
 }
noi di as txt _col(2) "Sample Size" _col(21) "=" %12.0f `N'
 if !inlist("`model'", "sem", "sar", "sdm", "sac", "mstar", "mstard") {
 ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
 if "`xvar'"!="" {
 test `SPXvar'
 local f =r(F)
 local fp = Ftail(`kx', `DF', `f')
 local wald =`f'*`kx'
 local waldp =chi2tail(`kx', abs(`wald'))
 }
 }
 if inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`robust'"!="" {
 local wald =`waldm'
 local f =`wald'/`kx'
 scalar `r2bu'=(`f'*`kx')/((`f'*`kx')+(`N'-`kx'))
 if `r2bu'< 0 {
 scalar `r2bu'=`r2h'
 }
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
 local fp = Ftail(`kx', `DF', `f')
 local waldp =chi2tail(`kx', abs(`wald'))
 }
noi di as txt _col(2) "{cmd:Wald Test}" _col(21) "=" %12.4f `wald' _col(37) "|" _col(41) "P-Value > {cmd:Chi2}(" `Jkx' ")" _col(65) "=" %12.4f `waldp'
noi di as txt _col(2) "{cmd:F-Test}" _col(21) "=" %12.4f `f' _col(37) "|" _col(41) "P-Value > {cmd:F}(" `Jkx' " , " `JDF' ")" _col(65) "=" %12.4f `fp'
noi di as txt _col(2) "R2  (R-Squared)" _col(21) "=" %12.4f `r2bu' _col(37) "|" _col(41) "Raw Moments R2" _col(65) "=" %12.4f `r2raw'
 ereturn scalar r2bu =`r2bu'
 ereturn scalar r2bu_a=`r2bu_a'
 ereturn scalar f =`f'
 ereturn scalar fp=`fp'
 ereturn scalar wald =`wald'
 ereturn scalar waldp=`waldp'
noi di as txt _col(2) "R2a (Adjusted R2)" _col(21) "=" %12.4f `r2bu_a' _col(37) "|" _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f `r2raw_a'
noi di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f `Sigo' _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f `llf'
noi di _dup(78) "-"
noi di as txt "- {cmd:R2h}=" %7.4f `r2h' _col(16) "{cmd:R2h Adj}=" %8.4f `r2h_a' _col(34) "{cmd:F-Test} =" %8.2f `fh' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `fhp'
 if `r2v'<1 {
noi di as txt "- {cmd:R2v}=" %7.4f `r2v' _col(16) "{cmd:R2v Adj}=" %8.4f `r2v_a' _col(34) "{cmd:F-Test} =" %8.2f `fv' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `fvp'
 ereturn scalar r2v=`r2v'
 ereturn scalar r2v_a=`r2v_a'
 ereturn scalar fv=`fv'
 ereturn scalar fvp=`fvp'
 }
 ereturn scalar r2raw =`r2raw'
 ereturn scalar r2raw_a=`r2raw_a'
 ereturn scalar llf =`llf'
 ereturn scalar Sig=`Sigo'
 ereturn scalar r2h=`r2h'
 ereturn scalar r2h_a=`r2h_a'
 ereturn scalar fh=`fh'
 ereturn scalar fhp=`fhp'
 if inlist("`model'", "mstar", "mstard") {
noi di _dup(78) "-"
noi di as txt "{bf:- Sum of Rho's} = " %12.7f `Rostar' _col(34) "{bf:Rho's must be < 1 for Stability Condition}" 
 }
 ereturn scalar Kr=`Kr'
 ereturn scalar kaux=`kaux'
 ereturn scalar kmhet=`kmhet'
 ereturn scalar Nn=_N
 ereturn scalar N=_N
 ereturn scalar DF=`DF'
 ereturn scalar JDF=`JDF'
 ereturn scalar Jkx=`Jkx'
 ereturn scalar Jkb=`Jkb'
 ereturn scalar kx=`kx'
 ereturn scalar kb=`kb'
 ereturn scalar R20=`R20'
 if inlist("`model'", "gs2sls", "gs2slsar") & inlist("`run'", "gmm") {
 ereturn scalar lmihj=`lmihj'
 ereturn scalar dfgmm=`dfgmm'
 ereturn scalar lmihjp=`lmihjp'
 }
 if inlist("`model'", "sar", "sem", "sdm", "sac") {
 cap confirm numeric var `eigw'
 summ `eigw'
 ereturn scalar minEig=1/r(min)
 ereturn scalar maxEig=1/r(max)
 }
 if inlist("`model'", "mstar", "mstard") {
 ereturn scalar waldm=`waldm'
 ereturn scalar waldmp=`waldmp'
 ereturn scalar waldm_df=`waldm_df'
 }
 if inlist("`model'", "sar", "sdm", "sac", "mstar", "mstard") {
 ereturn scalar waldr=`waldr'
 ereturn scalar waldrp=`waldrp'
 ereturn scalar waldr_df=`waldr_df'
 }
 if inlist("`model'", "sem", "sac") {
 ereturn scalar waldl=`waldl'
 ereturn scalar waldlp=`waldlp'
 ereturn scalar waldl_df=`waldl_df'
 }
 if inlist("`model'", "sdm") {
 ereturn scalar waldx=`waldx'
 ereturn scalar waldxp=`waldxp'
 ereturn scalar waldx_df=`waldx_df'
 }
 if inlist("`model'", "sac") {
 ereturn scalar waldj=`waldj'
 ereturn scalar waldjp=`waldjp'
 ereturn scalar waldj_df=`waldj_df'
 }
 if !inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") {
* noi ereturn display , `level' `robust'
noi ereturn display , `level' `robust' first neq(1) 
 }
 if inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") {
noi spregcs36 , `level' `robust'
 }

 if "`hausman'"!= "" {
 matrix biv2=e(b)
 matrix viv2=e(V)
 }
 matrix `b'=e(b)
 matrix `V'=e(V)
 matrix `Cov'=e(V)
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']
 matrix `Bx'=`B'[1,1..`kx']'
 if inlist("`model'", "lag") & inlist("`run'", "ols", "tobit") {
noi di as txt _col(3) "Rho Value  =" %8.4f `rRo' _col(29) "F Test =" %10.3f `rRot' _col(50) "P-Value > F(" `rRodf' ", " `rRodfr' ")" _col(73) %5.4f `rRotp'
noi di _dup(78) "-"
 }
 if inlist("`model'", "lag") & inlist("`run'", "sfa") {
noi di as txt _col(3) "Rho Value  =" %8.4f `rRo' _col(30) "Chi2 Test =" %10.3f `rRot' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `rRotp'
noi di _dup(78) "-"
 }
 if inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 test _b[w1y_`yvar']=0
 scalar `Rho'=_b[w1y_`yvar']
noi di as txt _col(3) "Rho Value  =" %8.4f `Rho' _col(30) "F Test =" %10.3f r(F) _col(52) "P-Value > F(" r(df) ", " r(df_r) ")" _col(73) %5.4f r(p)
noi di _dup(78) "-"
 }
 if inlist("`model'", "ivtobit") {
noi di as txt _col(3) "Exogeneity Wald LM Test =" _col(35) %10.4f Wald_chi2_exog _col(52) "P-Value > Chi2(" Wald_chi2_exogdf ")" _col(73) %5.4f Wald_chi2_exogp
noi di _dup(78) "-"
 ereturn scalar lmwexog=Wald_chi2_exog
 ereturn scalar lmwexogdf=Wald_chi2_exogdf
 ereturn scalar lmwexogp= Wald_chi2_exogp
 }
 if inlist("`model'", "gs2sls", "gs2slsar") & inlist("`run'", "gmm") {
noi di as txt _col(3) "Hansen Over Identification J Test =" _col(35) %10.4f e(lmihj) _col(52) "P-Value > Chi2(" `dfgmm' ")" _col(73) %5.4f `lmihjp'
noi di _dup(78) "-"
 ereturn scalar lmihj=`lmihj'
 ereturn scalar dfgmm=`dfgmm'
 ereturn scalar lmihjp=`lmihjp'
 }

 if inlist("`model'", "gs2sls", "gs2slsar", "ivtobit", "sarariv") {
noi di as txt "{bf:* Y  = LHS Dependent Variable:}" _col(33) " " 1 " = " "`yvar'"
noi di as txt "{bf:* Yi = RHS Endogenous Variables:}"_col(33) " " `kendog' " = " "`WsYi'"
noi di as txt "{bf:* Xi = RHS Exogenous Variables:}"_col(33) " " `kexog' " = " "`exog'"
noi di as txt "{bf:*  Z = Overall Instrumental Variables:}"
noi di as txt "   " `kinstx' " : " "`instx'"
noi di _dup(78) "-"
 }
 if "`model'"!="" {
 if "`predict'"!= "" {
 putmata `predict'=`Yh_ML' , replace
 }
 if "`resid'"!= "" {
 putmata `resid'=`Ue_ML' , replace
 }
 }
 ereturn matrix Y=`Y'
 ereturn matrix Z=`Z'
 ereturn matrix Wi=`Wi'
 ereturn matrix Wis=`Wis'
 ereturn matrix Bxx=`B'
 ereturn matrix Yh_ML=`Yh_ML'
 ereturn matrix Ue_MLo =`Ue_MLo'
 ereturn matrix Yh_MLo=`Yh_MLo'
 ereturn matrix Ue_ML =`Ue_ML'
 if "`lmspac'"!= "" {
 ereturn matrix Bx_SP =`Bx_SP'
 }
 ereturn local _Yo="`_Yo'"
 ereturn local _Zo="`_Zo'"
 ereturn local _Yw="`_Yw'"
 ereturn local _Zw="`_Zw'"
 ereturn local Zo="`Zo'"
 if inlist("`model'", "sarariv","ivtobit","gs2sls","gs2slsar","gs3sls","gs3slsar","sdm","durbin","mstard") {
 ereturn local WsXi="`WsXi'"
 }
 local usetext `lmspac' `diag' `lmhet' `lmnorm' ///
 `reset' `lmform' `lmcl' `hausman' `lmiden' `tests'
 if "`model'"!="" & "`usetext'"!="" {
 local modeln "model(`model')"
 local runn "run(`run')"
 local ordern "order(`order')"
 local nwmatn "nwmat(`nwmat')"
 local endogn "endog(`endog')"
 local instn "inst(`inst')"
 local exogn "exog(`exog')"
 local auxn "aux(`aux')"
 local var2n "var2(`var2')"
 local wsxin "wsxi(`WsXi')"
 local wsyin "wsyi(`WsYi')"
 local win "wit(`Wi')"
 local itern " iter(`iter') "
 local techn " tech(`tech') "
noi spregcs37 `_Yo' `xvar' , `modeln' `runn' `ordern' `lmspac' `lmhet' `wsxin' `wsyin' ///
 `lmnorm' `tests' `lmiden' `endogn' `hausman' `reset' `diag' `lmcl' `tolog' `exogn' `win' ///
 `noconstant' `auxn' `instn' `lmform' `itern' `techn' `var2n' `nwmatn' `tobit' `sig' `uspn'
 }

 if "`model'"!="" & inlist("`mfx'", "lin", "log") {
 tempname XMB XYMB YMB YMB1 SumW TRW TRWS TRWS1 NSumW NTRWS InDirect Direct Total BsZ
 tempname spmfxb spmfxe InDirectES DirectES TotalES Betaes mfxb mfxe mfxlin mfxlog
noi di 
noi di _dup(78) "{bf:{err:=}}"
 tempvar ZSLS 
 tempname mfxbox mfxb mfxb1 mfxe mfxlin mfxlog XMB XYMB YMB YMB1 XMB1 XMB2 _Yoz _Zoz
 unab varlist: `_Zo'
 foreach var of local varlist {
 summ `var' `wgt'
 gen double `ZSLS'_`var' = r(sd)
 }
 tsunab ZSLS : `ZSLS'_*
 tokenize `ZSLS'
 summ `_Yo' `wgt'
 scalar `_Yoz' = r(sd)
 mkmat `ZSLS' in 1/1 , matrix(`_Zoz')
 matrix `BsZ' =vecdiag(`Bx'*`_Zoz')'/`_Yoz'
 matrix `XMB'=`MSPX''
 scalar `YMB1'=`MSPY'
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: X = st_matrix("`XMB'")
 mata: Y = st_matrix("`YMB'")
 if inlist("`mfx'", "lin") {
 mata: `XYMB'=X:/Y
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 }
 if inlist("`mfx'", "log") {
 mata: `XYMB'=Y:/X
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 }
 if inlist("`model'","sar","sdm","sac","mstar","mstard","sararml","sarargs","sarariv") {
 scalar `SumW'=0
 local N = `N'
 forvalue i = 1/`N' {
 forvalue j = 1/`N' {
 scalar `SumW'=`SumW'+(`IRW'[`i',`j'])
 scalar j=`j'+1
 }
 }
 matrix `TRW'=trace(`IRW')
 scalar `TRWS1'=`TRW'[1,1]
 scalar `NSumW'=`N'/`SumW'
 scalar `NTRWS'=`N'/`TRWS1'
 matrix `Total'= `Bx'*`NTRWS'
 matrix `Direct'= `Bx'*`NSumW'
 matrix `InDirect'= `Total' - `Direct'
 matrix `spmfxb' =`Bx',`Total',`Direct',`InDirect',`XMB'
 matrix `Betaes' = vecdiag(`Bx'*`XYMB'')'
 matrix `TotalES'=vecdiag(`Total'*`XYMB'')'
 matrix `DirectES'=vecdiag(`Direct'*`XYMB'')'
 matrix `InDirectES'=vecdiag(`InDirect'*`XYMB'')'
 matrix `spmfxe' =`Betaes',`TotalES',`DirectES',`InDirectES',`XMB'
 matrix roweq `spmfxb' = "`yvar'"
 matrix roweq `spmfxe' = "`yvar'"
 matrix rownames `spmfxb'= `SPXvar'
 matrix rownames `spmfxe'= `SPXvar'
 if inlist("`mfx'", "lin") {
 matrix colnames `spmfxb'= Beta(B) Total Direct InDirect Mean
 matrix colnames `spmfxe'= Beta(Es) Total Direct InDirect Mean
noi matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
noi matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
 ereturn matrix mfxlinb=`spmfxb'
 ereturn matrix mfxline=`spmfxe'
 }
 if inlist("`mfx'", "log") {
 matrix colnames `spmfxb'= Beta(Es) Total Direct InDirect Mean
 matrix colnames `spmfxe'= Beta(B) Total Direct InDirect Mean
noi matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
noi matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
 ereturn matrix mfxlogb=`spmfxb'
 ereturn matrix mfxloge=`spmfxe'
 }
 }
 if !inlist("`model'","sar","sdm","sac","mstar","mstard","sararml","sarargs", "sarariv") {
 if inlist("`mfx'", "lin") {
 matrix `mfxb' =`Bx'
 matrix `mfxe'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlin' =`mfxb',`mfxe',`BsZ',`XMB'
 matrix roweq `mfxlin' = "`yvar'"
 matrix rownames `mfxlin' = `SPXvar'
 matrix colnames `mfxlin' = Margin Elasticity St_Beta Mean
noi matlist `mfxlin' , title({bf:* {err:Marginal Effect - Elasticity - Standardized Beta} {bf:(Model= {err:`model'})}: {err:Linear} *}) twidth(14) border(all) lines(columns) rowtitle(Variable) format(%12.4f)
 ereturn matrix mfxlin=`mfxlin'
 }
 if inlist("`mfx'", "log") {
 matrix `mfxe'=`Bx'
 matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlog' =`mfxe',`mfxb',`BsZ',`XMB'
 matrix roweq `mfxlog' = "`yvar'"
 matrix rownames `mfxlog' = `SPXvar'
 matrix colnames `mfxlog' = Elasticity Margin St_Beta Mean
noi matlist `mfxlog' , title({bf:* {err:Elasticity - Marginal Effect - Standardized Beta} {bf:(Model= {err:`model'})}: {err:Log-Log} *}) twidth(14) border(all) lines(columns) rowtitle(Variable) format(%12.4f)
 ereturn matrix mfxlog=`mfxlog'
 }
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1'
 }

 if "`model'"!="" & "`run'"=="" {
 if "`predict'"!= "" {
 getmata `predict' , replace
 label variable `predict' `"Yh_`model' - Prediction"'
 }
 if "`resid'"!= "" {
 getmata `resid' , replace
 label variable `resid' `"Ue_`model' - Residual"'
 }
 }
 if "`model'"!="" & "`run'"!="" {
 if "`predict'"!="" {
 getmata `predict' , replace
 label variable `predict' `"Yh_`model'_`run' - Prediction"'
 }
 if "`resid'"!="" {
 getmata `resid' , replace
 label variable `resid' `"Ue_`model'_`run' - Residual"'
 }
 } 

 if !inlist("`model'", "mstar", "mstard") & "`nwmat'"=="" {
 cap drop spat_*
 }
 if inlist("`model'", "mstar", "mstard") {
 cap matrix drop Ue_ML Yh_ML Bx Y X eigw WCS eVec
 }
 sort `Time'
 cap mata: mata drop *
 cap matrix drop Yh_ML
 cap matrix drop Ue_ML
 cap matrix drop _WB WCS
 ereturn local cmd "spregcs"
 if "`tolog'"!="" {
 foreach var of local vlistlog {
 replace `var'= `_Ws'`var' 
 }
 }
 }
 }
 end 

 prog def gotoup , rclass
 version 7.0
 syntax [if] [in] [ , id(str) ]
 cap drop `id'
 local gindlab `"id `varlist' `if' `in'"'
 unab existvar: *
 marksample touse , novarlist strok
 tempvar idsort
 gen double long `idsort'=_n
 if `"`varlist'"'=="" {
 tempvar varlist
 gen byte `varlist'=1
 }
 sort `touse' `varlist' `idsort'
 tempvar top
 by `touse' `varlist':gen byte `top'=`touse'&(_n==1)
 expand 2*`top'
 drop `top'
 sort `touse' `varlist' `idsort'
 if `"`id'"'=="" {tempvar id}
 by `touse' `varlist' `idsort':gen byte `id'=_n==2
 lab var `id' `"`gindlab'"'
 gsort `touse' `idsort' -`id'
 foreach i of var `existvar' {
 local nobv=1
 foreach Y of var `varlist' {
 if "`i'"=="`Y'" { local nobv=0}
 }
 replace `i'=. if `id'
 }
 gsort `idsort' -`id'
 end

 program define yxregeq
 version 10.0
 syntax varlist 
 tempvar `varlist'
 gettoken yvar xvar : varlist
 local LEN=length("`yvar'")
 local LEN=`LEN'+3
noi di "{p 2 `LEN' 5}" as res "{bf:`yvar'}" as txt " = " "
 local kx : word count `xvar'
 local i=1
 while `i'<=`kx' {
 local X : word `i' of `xvar'
 if `i'<`kx' {
noi di " " as res " {bf:`X'}" _c
noi di as txt " + " _c
 }
 if `i'==`kx' {
noi di " " as res "{bf:`X'}"
 }
 local i=`i'+1
 }
noi di "{p_end}"
noi di as txt "{hline 78}"
 end

