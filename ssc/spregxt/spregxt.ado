*! spregxt V1.0 12/07/2016
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

 program define spregxt , eclass byable(recall) sortpreserve
 version 11.2
 syntax [anything] , nc(str) [ WMFile(str) Model(str) Run(str) NOCONStant fe re be ///
 aux(str) dgmmiv(str) diff(str) dist(str) DLag(int 1) dumcs(str) dumts(str) dn ///
 ENDOG(str) gmm(int 1) HAUSman INDep LMIden WVar(str) level(passthru) INST(str) ///
 INV INV2 iter(int 100) KR(real 0) LAG(int 1) lgmmiv(str) LL(real 0) tobit ti ///
 MFX(str) mhet(str) NWmat(str) NOLog ORDer(int 1) Panels(str) pre(str) RIDge(str) ///
 REST(str) RHOType(str) ROBust spar(str) stand tech(str) vce(passthru) Weights(str) ///
 tolog TESTs PREDict(str) RESid(str) TWOstep zero tvd INLambda(real 0) INRho(real 0) ///
 LMAuto LMCl LMEc LMForm LMHet LMNorm LMSPac LMUnit diag reset ec2sls *]
 di
 if ("`options'" != "") {
 _SPsyntax ,`options'
 if ("`options'" == "coll") {
 local coll "coll"
 }
 if ("`options'" == "igls") {
 local igls "igls"
 }
 if ("`options'" == "cost") {
 local cost "cost"
 }
 if ("`options'" == "hetonly") {
 local hetonly "hetonly"
 }
 if ("`options'" == "nmk") {
 local nmk "nmk"
 }
 if ("`options'" == "list") {
 local list "list"
 }
 if ("`options'" == "nosa") {
 local nosa "nosa"
 }
 if ("`options'" == "te") {
 local te "te"
 }
 if ("`options'" == "pmfx") {
 local pmfx "pmfx"
 }
 if ("`options'" == "mle") {
 local mle "mle"
 }
 }
 local sthlp spregxt
 local varlist `anything'
 gettoken yvar xvar : varlist

 if "`model'"!="" {
 if !inlist("`model'", "ols", "sarxt", "sdmxt", "sar", "sem", "sdm", "sac") {
 if !inlist("`model'", "gwr", "gs2sls", "gs2slsar", "spgmm", "mstar", "mstard") {
di as err "{bf:model()} {cmd:must be:} {bf:sar, sem, sdm, sac, spgmm, mstar, mstard}"
di as err "{bf:model()} {cmd:must be:} {bf:gwr, ols, sarxt, sdmxt, gs2sls, gs2slsar}"
di in smcl _c "{cmd: see:} {help `sthlp'##04:Model Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 }
 if "`yvar'" == "" {
 di as err " {bf:Dependent Variable must be used with {bf:model({it:`model'})}}"
 exit
 }
 if "`xvar'" == "" {
 di as err " {bf:Independent Variables(s) must be used with {bf:model({it:`model'})}}"
 exit
 }
 if !inlist("`model'", "ols") & "`wmfile'"=="" {
di as err " {bf:wmfile( ) {cmd:must be combined with:}}"
di as err " {bf:model({it:sar, sem, sdm, sac, spgmm, gs2sls, gs2slsar, gwr, mstar, mstard, sarxt, sdmxt})}"
di as err " {bf:wmfile( ) {cmd:is not required for} {bf:model({it:ols})}}"
 exit
 }
 if inlist("`model'", "sem", "sac") & "`aux'"!="" {
di as err " {bf:aux(vars)} {cmd:cannot be combined with} {bf:model({it:sem, sac})} "
 exit
 }
 if inlist("`model'", "gwr", "ols", "sarxt", "sdmxt") & "`run'"=="" {
di as err " {bf:run( )} {cmd:must be combined with:} {bf:model({it:ols, gwr, sarxt, sdmxt})}"
di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 }
 if "`run'"!="" {
 if !inlist("`run'", "ols", "xtabond", "xtam", "xtbe", "xtbem", "xtdpd", "xtdpdsys") {
 if !inlist("`run'", "xtdhp", "xtfe", "xtfem", "xtmle", "xtfm", "xtbn", "xtfrontier") {
 if !inlist("`run'", "xtgls", "xthh", "xtmg", "xtpa", "xtmln", "xtpcse", "xtre", "xtrem") {
 if !inlist("`run'", "xtregar", "xtsa", "xtmlem", "xtwem", "xtrc", "xtwh", "xtkmhomo") {
 if !inlist("`run'", "xtkmhet1", "xtkmhet2", "xtparks", "xttobit", "xtmlh") {
di as err "{bf: run( )} {cmd:options:} must be" 
di as err _col(3) "{bf:ols     xtabond   xtam      xtbe      xtbem   xtbn        xtdhp}" 
di as err _col(3) "{bf:xtdpd   xtdpdsys  xtfe      xtfem     xtfm    xtfrontier  xtgls}"
di as err _col(3) "{bf:xthh    xtkmhet1  xtkmhet2  xtkmhomo  xtmg    xtmle       xtmlem}"
di as err _col(3) "{bf:xtmlh   xtmln     xtpa      xtparks   xtpcse  xtrc        xtre}"
di as err _col(3) "{bf:xtrem   xtregar   xtsa      xttobit   xtwem               xtwh}"
di in smcl _c "{cmd: see:} {help `sthlp'##05:run Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 }
 }
 }
 }
 }
 local both : list yvar & xvar
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be included in both LHS and RHS Variables}"
di as txt " LHS: `yvar'"
di as txt " RHS: `xvar'"
 exit
 }
 if "`xvar'" != "" {
 unab RHS : `xvar'
 qui _rmcoll `RHS' , `noconstant' forcedrop
 local both "`r(varlist)'"
 local both : list RHS - both
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be Included more than One in RHS Variables}"
di as txt " RHS : `RHS'"
di as txt " Coll: `both'"
 exit
 }
 local both : list xvar & aux
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be included in both RHS and Auxiliary Variables}"
di as txt " RHS: `xvar'"
di as txt " AUX: `aux'"
 exit
 }
 local both : list xvar & endog
 if "`both'" != "" {
 di as err " {bf:{cmd:`both'} cannot be included in both (RHS) xvar & endog( ) Endogenous Variables}"
 di as txt "   RHS:`xvar'"
 di as txt " Endog: `endog'"
 exit
 }
 local both: list xvar & pre
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both xvar & pre( ) Variables}"
noi di as txt " XVAR: `xvar'"
noi di as txt "  PRE: `pre'"
 exit
 }
 local both: list diff - xvar 
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} must be included in both xvar & diff( ) Variables}"
noi di as txt " XVAR: `xvar'"
noi di as txt " DIFF: `diff'"
 exit
 }
 }
 if "`endog'"!="" | "`inst'"!="" {
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
noi di as err " {bf:{cmd:`both'} cannot be included in both endog( ) Endogenous & inst( ) Instrumental Variables}"
noi di as txt " Endog: `endog'"
noi di as txt "  Inst: `inst'"
 exit
 }
 }
 if "`rest'"!="" {
 if inlist("`model'", "sem", "sac") {
 di as err " {bf:rest(#)} {cmd:not Valid with:}"
 di as err " {bf:model({it:sem, sac})}"
 exit
 }
 }
 if "`hausman'"!="" & "`noconstant'"!="" {
di as err " {bf:noconstant} {cmd:cannot be combined with (Hausman Test)}"
 exit
 }
 local usext `fe' `re' `be'
 if inlist("`model'", "gs2sls", "gs2slsar") & "`usext'"!="" & "`noconstant'"!="" {
di as err " {bf:noconstant} {cmd:cannot be combined with (be, fe, re) in} {bf:model({it:gs2sls, gs2slsar})}"
 exit
 }
 if "`run'"!="" {
 if !inlist("`model'", "gwr", "ols", "sarxt", "sdmxt") & "`run'"!="" {
di as err "{bf:run()} {cmd:valid only with:} {bf:model({it:ols, gwr, sarxt, sdmxt})}"
di in smcl _c "{cmd: see:} {help `sthlp'##05:Run Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 if inlist("`run'", "ols") & "`usext'"!="" {
di as err " {bf:fe, re, be} {cmd:valid only with:} {bf: model({it:gs2sls, gs2slsar})}"
di as err " {bf:fe, re, be} {cmd:valid only with:} {bf: run({it:xtdhp})}"
di as err " {bf:fe, re}     {cmd:valid only with:} {bf: run({it:xtregar})}"
 exit
 }
 if inlist("`run'", "xtfrontier") & "`ti'"!="" & "`tvd'"!="" {
di as err " {bf:ti} & {bf:tvd} cannot be combined togther)"
 exit
 }
 if "`endog'"!="" {
 if !inlist("`model'", "gs2sls", "gs2slsar") & !inlist("`run'", "xtabond", "xtdpdsys"){
di as err " {bf:endog(vars)} {cmd:valid only with:}"
di as err "- {bf:model({it:gs2sls, gs2slsar})} {cmd:and} {bf:run({it:xtabond, xtdpdsys})}"
 exit
 }
 }
 if inlist("`run'", "xtdpd") & "`dgmmiv'"=="" {
di as err " {cmd:option} {bf:dgmmiv({it:varlist})} {cmd:must be combined with:} {bf:run({it:xtdpd})}"
 exit
 } 
 if !inlist("`run'", "xtdpd") & "`dgmmiv'"!="" {
di as err " {cmd:option} {bf:dgmmiv({it:varlist})} {cmd:valid only with:} {bf:run({it:xtdpd})}"
 exit
 }
 if !inlist("`run'", "xtabond") & "`inst'"!="" {
di as err " {bf:inst(vars)} {cmd:valid only with:}"
di as err "- {bf:run({it:xtabond})} {cmd:and} {bf:model({it:gs2sls, gs2slsar})}"
 exit
 }
 if !inlist("`model'", "gs2sls", "gs2slsar") & "`run'"=="" & "`inst'"!="" {
di as err " {bf:inst(vars)} {cmd:valid only with:}"
di as err "- {bf:model({it:gs2sls, gs2slsar})} {cmd:and} {bf:run({it:xtabond})}"
 exit
 }
 if !inlist("`run'", "xtabond") & "`lmiden'"!="" {
di as err " {bf:lmiden} {cmd:valid only with:} {bf:run({it:xtabond})}"
 exit
 }
 if !inlist("`model'", "gs2sls", "gs2slsar") & "`lmiden'"!="" {
di as err " {bf:lmiden} {cmd:valid only with:} {bf:model({it:gs2sls, gs2slsar})}"
 exit
 }
 if !inlist("`run'", "xtabond", "xtdpdsys") & "`pre'"!="" {
di as err " {bf:pre( )} {cmd:valid only with} {bf:run({it:xtabond, xtdpdsys})}"
 exit
 }
 if !inlist("`run'", "xtabond", "xtdpdsys") & "`diff'"!="" {
di as err " {bf:diff( )} {cmd:valid only with} {bf:run({it:xtabond, xtdpdsys})}"
 exit
 }
 if inlist("`run'", "xtbe", "xtfe", "xtre", "xtmg", "xtregar", "xtdhp") & "`noconstant'"!="" {
di as err " {bf:noconstant} {cmd:cannot be used with} {bf:model({it:sem, sac, gs2sls, gs2slsar})} "
di as err " {cmd:and} {bf:run({it:xtbe, xtfe, xtre, xtmg, xtregar, xtdhp})}"
 exit
 }
 local usefront `ti' `tvd'
 if inlist("`run'", "xtfrontier") & "`usefront'"=="" {
di as err " {bf:ti} - (Time-Invariant Model) {cmd:or} {bf:tvd} - (Time-Varying Decay Model)"
di as err " {cmd:must be combined with {bf:run({it:xtfrontier})}}"
 exit
 } 
 if inlist("`run'", "xtabond", "xtdpd", "xtdpdsys", "xtbe", "xtre") {
 if "`wvar'"!="" | "`weights'"!="" {
di as err " {bf:wvar( )} or {bf:weights( )} {cmd:not valid with run:}"
di as err " {bf:({it:xtabond, xtdpd, xtdpdsys, xtbe, xtre})}"
 exit
 }
 }
 }
 if inlist("`model'", "sem", "sac", "gs2sls", "gs2slsar") & "`noconstant'"!="" {
di as err " {bf:noconstant} {cmd:cannot be combined with} {bf:model({it:sem, sac, gs2sls, gs2slsar})} "
di as err " {cmd:and} with: {bf:run({it:xtbe, xtfe, xtre, xtmg, xtregar, xtdhp})}"
 exit
 }
 if "`tests'"!="" {
 local lmspac "lmspac"
 local diag "diag"
 local lmauto "lmauto"
 local lmhet "lmhet"
 local lmnorm "lmnorm"
 local lmec "lmec"
 local lmunit "lmunit"
 local reset "reset"
 local lmform "lmform"
 local lmcl "lmcl"
 if !inlist("`model'", "sar", "sem", "sdm", "sac", "mstar", "mstard", "spgmm") {
 local hausman "hausman"
 }
 if inlist("`model'", "gs2sls", "gs2slsar") {
 local lmiden "lmiden"
 }
 }
 if inlist("`model'", "sem", "sac") & "`robust'"!="" {
di as err "{bf:robust} {cmd:cannot be used with} {bf:model({it:`model'})}"
di as err "{bf:robust} {cmd:valid only with:} {bf:model({it:sar, sdm})}"
di in smcl _c "{cmd: see:} {help `sthlp'##09:Other Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 if !inlist("`model'", "sar", "sdm", "mstar", "mstard", "ols", "sarxt", "sdmxt", "gwr") & "`mhet'"!="" {
di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:model({it:`model'})}"
di as err " {bf:mhet({it:varlist})} {cmd:valid only with} {bf:model({it:sar, sdm, mstar, mstard, ols, sarxt, sdmxt, gwr})} {cmd:and} {bf:run({it:xtmlh})}"
 exit
 }
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") {
 if inlist("`run'", "xtmln") {
 if "`mhet'"!="" {
di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:run({it:`run'})}"
di as err " {bf:mhet({it:varlist})} {cmd:valid only with} {bf:model({it:sar, sdm})} {cmd:and} {bf:run({it:xtmlh})}"
 exit
 }
 }
 if inlist("`run'", "xtmlh") & "`mhet'"=="" {
 di as err " {bf:mhet({it:varlist})} {cmd:must be combined with} {bf:run({it:xtmlh})}"
 exit
 }
 if !inlist("`run'", "xtmlh") & "`mhet'"!="" {
di as err " {bf:mhet({it:varlist})} {cmd:valid only with} {bf:run({it:xtmlh})}"
 exit
 }
 }
 if "`dist'"!="" {
 if !inlist("`dist'", "norm", "exp", "weib") {
di as err " {bf:dist( )} {cmd:must be} {bf:dist({it:norm})} {cmd:for Normal model}"
di as err "  {cmd: or} {bf:dist({it:exp})} {cmd:for Exponential model, or} {bf:dist({it:weib})} {cmd:for Weibull model}"
 exit
 }	
 }
 if inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`mhet'"!="" & inlist("`dist'", "exp", "weib") {
di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:dist({it:`dist'})}"
di as err " {bf:mhet({it:varlist})} {cmd:valid only with} {bf:model({it:sar, sdm, mstar, mstard})} {cmd:and} {bf:dist({it:norm})}"
 exit
 }
 if !inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") & inlist("`dist'", "norm", "exp", "weib") {
di as err " {bf:dist( )} {cmd:valid only with} {bf:model({it:sar, sem, sdm, sac, mstar, mstard})}"
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
di as err "{bf:spar( )} {cmd:valid only with:} {bf:rho}, {bf:lam}"
di in smcl _c "{cmd: see:} {help `sthlp'##09:Other Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 }
 if inlist("`model'", "sem") & "`spar'"=="rho" {
di as err "{bf:spar({it:rho})} {cmd:cannot be used with} {bf:model(`model')}"
di as err "{cmd:{it:notes:}} {bf:model({it:sar, sdm, sac, mstar, mstard)}} {cmd:work with:} {bf:spar({it:rho})} {cmd:for Rho.}"
 exit
 }
 if inlist("`model'", "sar", "sdm", "mstar", "mstard") & "`spar'"=="lam" {
di as err "{bf:spar({it:lam})} {cmd:cannot be used with} {bf:model(`model')}"
di as err "{cmd:{it:notes:}} {bf: model({it:`model'})} {cmd:valid only with:} {bf:spar({it:rho})} {cmd:for Rho.}"
di as err "{cmd:but} {bf:model({it:sem, sac)}} {cmd:work with:} {bf:spar({it:lam})} {cmd:for Lambda.}"
 exit
 }
 if inlist("`model'", "ols", "sarxt", "sdmxt", "spgmm", "gs2sls", "gs2slsar", "gwr") & inlist("`spar'", "rho", "lam") {
di as err " {bf:spar( )} {cmd:cannot be used with} {bf:model(`model')}"
di as err " {bf:spar( )} {cmd:valid only with} {bf:model({it:sar, sdm, sac, mstar, mstard})}"
 exit
 }
 if "`nwmat'"!="" {
 if !inlist("`nwmat'", "1", "2", "3", "4") {
di as err " {bf:nwmat(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 } 
 }
 if "`model'"!="" {
 if !inlist("`model'", "mstar", "mstard") & "`nwmat'"!="" {
di as err " {bf:nwmat(#)} {cmd:valid only with:} {bf:model({it:mstar, mstard})}"
 exit
 }
 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="" {
di as err " {bf:model({it:mstar, mstard})} {cmd:and} {bf:nwmat(#)} {cmd:must be combined}"
di as err " {bf:nwmat(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
 }
 if inlist(`order',1,2,3,4)==0 {
di as err " {bf:order(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
 if inlist(`gmm',1,2,3)==0 {
di as err " {bf:gmm(#)} {cmd:number must be 1, 2, or 3.}"
 exit
 }
 if inlist("`model'", "sar", "sem", "sdm", "sac", "mstar", "mstard", "spgmm") & "`hausman'"!="" {
di as err " {bf:hausman} {cmd:cannot be used with:} {bf:model({it:`model'})}"
 exit
 }
 if "`ridge'"!="" {
 if !inlist("`run'", "ols", "xtam", "xtbem", "xtfem", "xtfm", "xtbn", "xtrem") {
 if !inlist("`run'", "xtwem", "xtmlem", "xtsa", "xtwh", "gwr") {
 if !inlist("`model'", "ols", "gwr", "sarxt", "sdmxt", "spgmm") {
di as err " {bf:ridge( )} {cmd:valid only with:}"
di as err " {bf:run(ols, xtam, xtbem, xtbn, xtfem, xtfm, xtrem, xtsa, xtmlem, xtwem, xtwh)}"
di as err " {bf:model(ols, gwr, sarxt, sdmxt, spgmm)}"
 exit
 }
 }
 }
 if !inlist("`ridge'", "orr", "grr1", "grr2", "grr3") {
di as err " {bf:ridge( )} {cmd:must be} {bf:ridge({it:orr, grr1, grr2, grr3})}"
di in smcl _c "{cmd: see:} {help `sthlp'##06:Ridge Options}"
di in gr _c " (spregxt Help):"
 exit
 }
 if inlist("`ridge'", "grr1", "grr2", "grr3") & `kr'>0 {
 di as err " {bf:kr(#)} {cmd:cannot be combined with:} {bf:ridge({it:grr1, grr2, grr3})}"
 exit
 }
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "yh", "abse", "e2", "yh2", "x", "xi", "x2", "xi2") {
di as err " {bf:weights( )} {cmd:valid only with:} {bf:yh, yh2, abse, e2, x, xi, x2, xi2}"
 di in smcl _c "{cmd: see:} {help `sthlp'##08:Weighted Variable Type Options}"
 di in gr _c " (spregxt Help):"
 exit
 }
 if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
 exit
 }
 }
 if ("`inv'"!="" | "`inv2'"!="" ) & "`stand'"=="" {
 di as err " {bf:inv, inv2} {cmd:and} {bf:stand} {cmd:must be combined}"
 exit
 }
 qui {
tempvar _Lin _LYi _M _MX _MY _WsXi1 _X _Y absE Bo Bw D dcs DE DF1 dumxcs DumE DW DX_ DY_
tempvar E e EE eigw Eo Es Ev Ew Hat ht idv itv LE LEo LYh2 LYi miss P Q SBB Sig2 SLSVar
tempvar SSE SST Time tm U U2 Ue Ue_ML Ue_SP wald Wi WiB Wio Wis WLSVar WS X X0
tempvar Xb Xo XQ Yb Yh Yh_ML Yh2 Yhb Yho Yho2 Yt yvarexp YY YYm YYv Z zeromiss Zo Zw
tempname _MX _MY _WS _WsY1 _WsYi1 _WsXi A B b B1 b1 B12 B1b B1t b2 BB2 Beta BetaSP
tempname BKi BKo Bm Bo BOLS BOLS1 BsKi BsKo BsKoi Bt Bv Bv1 Bx Bx_SP Cov Cov1 Cov2s
tempname CovC D den DF dfab Dim DJ11 DJ20 DJ22 DVE DVNE Dx E E1 EE1 Eg eigw Eo Eom
tempname eVec Ew F f f1 f13 f13d fgs2s fgs2sp fh fhp fp gam gam2 Go GoRY h Hat hjm
tempname IDRmk In IPhi IRW IRWL IRWR J JNT K kb kb1 kb2 kbc1 kbc2 Kk Ko Koi kpw Kr kx
tempname L lf llf lmhs lmiab lmiabp Lms Ls LVR LWi2 LWi21 M M1 M2 maxEig mh minEig MSPX
tempname MSPY n N NC NE NEB Nmiss NT nw olshet olsols olsin Om Om1 Om2 Omega Omega1 Omm
tempname Omm2 P Phi PHM PHM1 PHM2 Pm q Q q1 q2 Qr Qrq R20 r2bu r2bu_a r2h r2h_a r2raw
tempname r2raw_a rdfgs rdfgsr restc Rho rid rLm Rmk Rostar rRo Rs Rso RX RY s S11 S12
tempname S2y sd Sig2 Sig21 Sig2b Sig2n Sig2o Sig2o1 Sig2u Sig2SP Sig2w Sig2wn Sigb Sigo
tempname sigox Sigu Sigw SLS Sn sqN ss SSE SSE1 SSEo SSESP SSEw SSEw1 SST1 SST11 SST2
tempname SST21 SSTm Sw THn THw Ue Ue_MLo Ue_SP Uext v V V1 v1 V1s v2 VaL VaL1 VaL21 VaLv1
tempname Vec vh VM VMo VP VPo VPos VQ VQo VQos Vs vy1 W W1 W2 Wald waldj waldj_df Omm1
tempname waldjp waldl waldl_df waldlp waldm waldm_df waldmp waldp waldr waldr_df waldrp
tempname waldx waldx_df waldxp WB1 WB2 WD1 WD2 We Wfe Wi Wi1 Wio Wis WMTD Wre WMB WCS
tempname WS WS1 WS2 WS3 WS4 WsY1 WW WY WYX X X0 Xfe XMB Xo xq Xre Xx Y Yfe Yh Yh_MLo
tempname Yhxt Yi Yre Yws YYm YYv Z Z0 Z1 Zo Zr Zws ZwZ Zz XFMb Yfm Xfm YwSP ZwSP

 scalar `N'=_N
 scalar `NC'=`nc'
 scalar `NT'=int(_N/`NC')
 local N=`N'
 local NT=`NT'
 local NC=`NC'
 cap drop w1x_*
 cap drop w2x_*
 cap drop w3x_*
 cap drop w4x_*
 cap drop w1y_*
 cap drop w2y_*
 if "`wmfile'" != "" {
 preserve
 use `"`wmfile'"', clear
 summ
 if `NT' !=int(`N'/r(N)) {
noi di 
noi di as err " Cross Section Weight Matrix = " r(N)
noi di as err " Time Series obs             = " `NT'
noi di as err " Sample Size (Number of obs) = " `N'
noi di as txt " {bf:(Cross Sections x Time) must be Equal Sample Size}"
noi di as err " {bf:Spatial Cross Section Weight Matrix Dimension not correct}"
noi di as err " {bf:Check Correct Number Units, Unequal Time Series not Allowed}"
 exit
 }
 mkmat * , matrix(`WB1')
 egen ROWSUM=rowtotal(*)
 count if ROWSUM==0
 local NN=r(N)
 if `NN'==1 {
noi di as err "*** {bf:Spatial Weight Matrix Has (`NN') Location with No Neighbors}"
 }
 else if `NN'>1 {
noi di as err "*** {bf:Spatial Weight Matrix Has (`NN') Locations with No Neighbors}"
 }
 local NROW=rowsof(`WB1')
 local NCOL=colsof(`WB1')
 if `NROW'!=`NCOL' {
noi di as err "*** {bf:Spatial Weight Matrix is not Square}"
 exit
 }
noi di _dup(78) "{bf:{err:=}}"
 if "`stand'"!="" {
noi di as txt "{bf:*** Standardized Weight Matrix (W): (`N'x`N') : NC=`NC' NT=`NT' (Normalized)}"
 matrix `Xo'=J(`NC',1,1)
 matrix `WB2'=`WB1'*`Xo'*`Xo''
 mata: `WD1' = st_matrix("`WB1'")
 mata: `WD2' = st_matrix("`WB2'")
 mata: `_WS'=`WD1':/`WD2'
 mata: `_WS'=st_matrix("`_WS'",`_WS')
 mata: `_WS' = st_matrix("`_WS'")
 if "`inv'"!="" {
noi di as txt "*** Inverse Standardized Weight Matrix (1/W)"
 mata: `_WS'=1:/`_WS'
 mata: _editmissing(`_WS', 0)
 mata: `_WS'=st_matrix("`_WS'",`_WS')
 }
 if "`inv2'"!="" {
noi di as txt "*** Inverse Squared Standardized Weight Matrix (1/W^2)"
 mata: `_WS'=`_WS':*`_WS'
 mata: `_WS'=1:/`_WS'
 mata: _editmissing(`_WS', 0)
 mata: `_WS'=st_matrix("`_WS'",`_WS')
 }
 matrix `WCS'=`_WS'
 }
 else {
noi di as txt "{bf:*** Binary (0/1) Weight Matrix: (`N'x`N') : NC=`NC' NT=`NT' (Non Normalized)}"
 matrix `WCS'=`WB1'
 }
 matrix eigenvalues `eigw' eVec = `WCS'
 matrix `eigw'=vecdiag(diag(`eigw'')#I(`NT'))'
 matrix WMB=`WCS'#I(`NT')
 restore

 mata: `eigw' = st_matrix("`eigw'")
 getmata `eigw' , force replace
noi di _dup(78) "{bf:{err:-}}"
 }
 if "`wmfile'"=="" {
 matrix WMB=I(`N')
 matrix `WCS'=I(`NC')
 }
 if "`varlist'"!="" {
 marksample touse
 cap count 
 local N = r(N)
 local varmiss "`varlist' `aux' `dgmmiv' `diff' `endog' `inst' `lgmmiv' `mhet' `pre' `wvar'"
 _rmcoll `varmiss' , `noconstant' forcedrop
 local varmiss "`r(varlist)'"
 markout `touse' `varmiss' , strok
 mean `varmiss'
 scalar `Nmiss' = e(N)
 if "`zero'"=="" {
 if `N' !=`Nmiss' {
noi di as err "*** {bf:Variables have {bf:(" `N'-`Nmiss' ")} Missing Values}"
noi di as err "*** {bf:You can use {cmd:zero} option to Convert Missing Values to Zero}"
noi di
 foreach var of local varmiss {
 summ `var' , meanonly
 if r(N) < `N' {
noi di as err "*** {bf: `var' has Missing Values}"
 exit
 }
 }
 }
 }
 }
 local NC=`nc'
 local NT=`N'/`NC'
 gen `Time' = _n
 gen `idv'= ceil(_n/`NT')
 gen `itv'= _n-(`idv'-1)*`NT'
 xtset `idv' `itv'
 local NC1=r(imin)
 local NC2=r(imax)
 putmata idv=`idv' , replace 
 putmata itv=`itv' , replace 
 tab `idv'
 local NCNo= r(r)
 scalar `Dim' = `N'
 local MSize= `Dim'
 if `c(matsize)' < `MSize' {
noi di as err " {bf:Current Matrix Size = (`c(matsize)')}"
noi di as err " {bf:{help matsize##|_new:matsize} must be >= Sample Size" " (`MSize')}"
 set matsize `MSize'
noi di as txt " {bf:matsize increased now to = (`c(matsize)')}"
 }
 if "`dumcs'"!="" {
 cap drop `dumcs'*
 tabulate `idv' , generate(`dumcs')
 forvalue i=1/`NC' {
 label variable `dumcs'`i' `"Panel (`i')"'
 }
 }
 if "`dumts'"!= "" {
 cap drop `dumts'*
 tabulate `itv' , generate(`dumts')
 forvalue i=1/`NT' {
 label variable `dumts'`i' `"Year (`i')"'
 }
 }
 if "`nwmat'"!="" {
 local nwmat `nwmat'
 local knw=`nwmat'
 }
 else {
 local nwmat ""
 local knw=1
 }
 matrix WMB_1=WMB
 if "`nwmat'"!="" {
 forvalue i=`nwmat'/`nwmat' {
 matrix WMB_`i'=WMB
 cap drop mstar_W`i'
 gen double mstar_W`i'=`eigw'
 summ `eigw' 
 scalar minEig`i'=1/r(min)
 scalar maxEig`i'=1/r(max)
 }
 order mstar_W* , last
 }

 preserve
 if "`zero'"!="" {
 mvencode * , mv(0) override
 }
 if "`model'"!="" {
 gettoken yvar xvar : varlist
 _rmcoll `xvar' , `noconstant' `coll' forcedrop
 local xvar "`r(varlist)'"
 marksample touse
 markout `touse' `yvar' `xvar' `endog' `inst' `diff' `pre' `mhet' `wvar' `aux' , strok
 if "`tolog'"=="" {
 local _dgmmiv ""
 local _diff ""
 local _endog ""
 local _inst ""
 local _lgmmiv ""
 local _LYi ""
 local _pre ""
 local _SPXvar ""
 local _WsXi ""
 local _WsY1 ""
 local _WsYi ""
 local _xvar ""
 }
 local kaux=0
 local kdiff=0
 local kendog=0
 local kexog=0
 local kinst=0
 local kinstx=0
 local kmhet=0
 local kpre=0
 local SPXvar ""
 local WsXi ""
 local WsY1 ""
 local WsYi ""
 if "`aux'"!="" {
 _rmcoll `aux' , `noconstant' `coll' forcedrop
 local aux "`r(varlist)'"
 local kaux : word count `aux'
 }
 if "`mhet'"!="" {
 _rmcoll `mhet' , `noconstant' `coll' forcedrop
 local mhet "`r(varlist)'"
 local kmhet : word count `mhet'
 }
 if "`endog'"!="" {
 _rmcoll `endog' , `noconstant' `coll' forcedrop
 local endog "`r(varlist)'"
 if "`pre'"!="" {
 local endog: list endog- pre
 }
 local both: list endog & xvar 
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both xvar & endog( ) Variables}"
noi di as txt "  XVAR: `xvar'"
noi di as txt " ENDOG: `endog'"
 exit
 }
 }
 if "`inst'"!="" {
 _rmcoll `inst' , `noconstant' `coll' forcedrop
 local inst "`r(varlist)'"
 }
 if "`pre'"!="" {
 _rmcoll `pre' , `noconstant' `coll' forcedrop
 local pre "`r(varlist)'"
 local xvar: list xvar-pre
 }
 if "`diff'"!="" {
 _rmcoll `diff' , `noconstant' `coll' forcedrop
 local diff "`r(varlist)'"
 }
 if "`dgmmiv'"!="" {
 _rmcoll `dgmmiv' , `noconstant' `coll' forcedrop
 local dgmmiv "`r(varlist)'"
 }
 if "`lgmmiv'"!="" {
 _rmcoll `lgmmiv' , `noconstant' `coll' forcedrop
 local lgmmiv "`r(varlist)'"
 }
 summ `yvar' 
 scalar `MSPY' =r(mean)
 if "`tolog'"!="" {
noi di as err " {cmd:** Variables Have been Transformed to Log Form **}"
noi di _dup(78) "-" 
noi di as err "{bf:** Dependent & Independent Variables}
noi di as txt " {cmd:** `varlist'} "
noi di _dup(78) "-"
 gen double `_Lin'`yvar'=(`yvar')
 foreach var of local xvar {
 gen double `_Lin'`var'=(`var')
 local _xvar "`_xvar' `_Lin'`var'"
 }
 if "`endog'"!="" {
noi di as err "{bf:** Endogenous Variables}
noi di as txt " {cmd:** `endog'} "
noi di _dup(78) "-"
 foreach var of local endog {
 gen double `_Lin'`var'=(`var')
 local _endog "`_endog' `_Lin'`var'"
 }
 }
 if "`inst'"!="" {
noi di as err "{bf:** Instrumenal Variables}
noi di as txt " {cmd:** `inst'} "
noi di _dup(78) "-"
 }
 if "`mhet'"!="" {
noi di as err "{bf:** Multiplicative Heteroscedasticity Variables}"
noi di as txt " {cmd:** `mhet'} "
noi di _dup(78) "-"
 }
 if "`pre'"!="" {
noi di as err "{bf:** Predetermined Variables}"
noi di as txt " {cmd:** `pre'} "
noi di _dup(78) "-"
 foreach var of local pre {
 gen double `_Lin'`var'=(`var')
 local _pre "`_pre' `_Lin'`var'"
 }
 }
 if "`diff'"!="" {
noi di as err "{bf:** Already Differenced Exogenous Variables}"
noi di as txt " {cmd:** `diff'} "
noi di _dup(78) "-"
 foreach var of local diff {
 gen double `_Lin'`var'=(`var')
 local _diff "`_diff' `_Lin'`var'"
 }
 }
 if "`dgmmiv'"!="" {
noi di as err "{bf:** GMM Instruments for Differenced Equation}"
noi di as txt " {cmd:** `dgmmiv'} "
noi di _dup(78) "-"
 foreach var of local dgmmiv {
 gen double `_Lin'`var'=(`var')
 local _dgmmiv "`_dgmmiv' `_Lin'`var'"
 }
 }
 if "`lgmmiv'"!="" {
noi di as err "{bf:** GMM Instruments for Level Equation}"
noi di as txt " {cmd:** `lgmmiv'} "
noi di _dup(78) "-"
 foreach var of local lgmmiv {
 gen double `_Lin'`var'=(`var')
 local _lgmmiv "`_lgmmiv' `_Lin'`var'"
 }
 }
 local vlistlog "`yvar' `xvar' `endog' `inst' `diff' `pre' `dgmmiv' `lgmmiv' `mhet' `wvar'"
 _rmcoll `vlistlog' , `noconstant' forcedrop
 local vlistlog "`r(varlist)'"
 foreach var of local vlistlog {
 gen double `_M'`var'=(`var')
 replace `var'=ln(`var')
 replace `var'=0 if `var'==.
 }
 }
 if "`inst'"!="" {
 local instiv "`inst'"
 }
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
 tsset `Time'
 mkmat `yvar' , matrix(`yvar')
 mkmat `yvar' , matrix(`Y')
 forvalue i=1/`knw' {
 matrix `WYX' = WMB_`i'*`Y'
 mata: w`i'y_`yvar' = st_matrix("`WYX'")
 getmata w`i'y_`yvar' , force replace
 }
 matrix `WS1'= WMB
 if "`order'" > "1" {
 forvalue i=2/`order' {
 local m=`i'-1
 matrix `WS`i''= WMB*`WS`m''
 }
 }
 if inlist("`model'", "gwr", "sarxt", "sar", "sac", "sdm", "sem", "gs2sls", "gs2slsar") {
 mkmat `yvar' , matrix(`WYX')
 matrix `WYX' = `WS1'*`WYX' 
 mata: w1y_`yvar' = st_matrix("`WYX'")
 getmata w1y_`yvar' , force replace
 local WsY1 "w1y_`yvar'"
 if inlist("`model'", "gwr") {
 gen double `yvarexp'=w1y_`yvar'
 }
 else {
 gen double `yvarexp'=`yvar'
 }
 if "`mfx'"!="" & "`tolog'"!="" {
 mkmat `_M'`yvar' , matrix(`WYX')
 matrix `WYX' = `WS1'*`WYX'
 mata: `_WsY1' = st_matrix("`WYX'")
 getmata `_WsY1' , force replace
 }
 local WsYi "`WsY1' `endog'"
 if "`tolog'"!="" {
 local _WsYi "`_WsY1' `_endog'"
 }
 }
 if inlist("`model'", "sac") {
 matrix `WS2'= `WS1'*WMB
 matrix `WYX' = `WS2'*`Y'
 mata: w2y_`yvar' = st_matrix("`WYX'")
 getmata w2y_`yvar' , force replace
 }
 if inlist("`model'", "sdm", "sdmxt", "mstard", "sac", "sem", "gwr") {
 local knw=1
 forvalue i=1/`knw' {
 matrix WMB_`i'=WMB
 foreach var of local xvar {
 mkmat `var' , matrix(`WYX')
 matrix `WYX' = WMB_`i'*`WYX'
 mata: w`i'x_`var' = st_matrix("`WYX'")
 getmata w`i'x_`var' , force replace
 local WsXi "`WsXi' w`i'x_`var'"
 order w`i'x_* , last
 }
 }
 if "`mfx'"!="" & "`tolog'"!="" {
 if inlist("`model'", "sdm", "sdmxt", "mstard") {
 local _WsXi ""
 forvalue i=1/`knw' {
 foreach var of local xvar {
 mkmat `_M'`var' , matrix(`WYX')
 matrix `WYX' = WMB_`i'*`WYX'
 mata: `_WsXi1'`i'`var' = st_matrix("`WYX'")
 getmata `_WsXi1'`i'`var' , force replace
 local _WsXi "`_WsXi' `_WsXi1'`i'`var'"
 }
 }
 }
 }
 }
 if inlist("`model'", "gwr") {
 unab yvar: w1y_`yvar'
 unab xvar: w1x_*
 summ `_WsY1'
 scalar `MSPY' =r(mean)
 }
 if inlist("`model'", "sar", "sem", "sac", "mstar", "spgmm") {
 unab SPXvar: `xvar' `aux'
 if "`mfx'"!="" & "`tolog'"!="" {
 unab _SPXvar: `_xvar' `aux'
 }
 }
 if inlist("`model'", "sdm", "sdmxt", "mstard") {
 unab SPXvar: `xvar' `WsXi' `aux'
 if "`mfx'"!="" & "`tolog'"!="" {
 unab _SPXvar: `_xvar' `_WsXi' `aux'
 }
 }
 if inlist("`model'", "gs2sls", "gs2slsar") {
 forvalue i = 1/`order' {
 foreach var of local xvar {
 mkmat `var' , matrix(`WYX')
 matrix `WYX' = `WS`i''*`WYX'
 mata: w`i'x_`var' = st_matrix("`WYX'")
 getmata w`i'x_`var' , force replace
 local WsXi "`WsXi' w`i'x_`var'"
 }
 }
 unab instx: `xvar' `aux' `WsXi' `inst'
 _rmcoll `instx' , `noconstant' forcedrop
 local instx "`r(varlist)'"
 unab exog: `xvar' `aux'
 local inst : list instx-exog
 local kendog : word count `WsYi'
 local kexog : word count `exog'
 local kinst : word count `inst'
 local kinstx: word count `instx'
 local kx =`kendog'+`kexog'
 local ky =1
 if `kinstx' < `kx' {
noi di
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
 unab WsY1: w1y_`yvar'
 unab WsYi: `WsY1' `endog'
 unab exog: `xvar' `aux'
 unab SPXvar: `WsY1' `endog' `xvar' `aux'
 if "`mfx'"!="" & "`tolog'"!="" {
 unab _SPXvar: `_WsY1' `_endog' `_xvar' `aux'
 }
 }
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") {
 if inlist("`model'", "ols", "gwr") {
 local _WsXi ""
 local WsXi ""
 local _WsY1 ""
 local WsY1 ""
 }
 if inlist("`model'", "sarxt") {
 local _WsXi ""
 local WsXi ""
 }
 if inlist("`model'", "sdmxt") {
 local _WsY1 ""
 local WsY1 ""
 }
 if !inlist("`run'", "xtdpd", "xtdhp", "xtabond", "xtdpdsys") {
 unab SPXvar: `WsY1' `xvar' `WsXi' `aux'
 if "`mfx'"!="" & "`tolog'"!="" {
 unab _SPXvar: `_WsY1' `_xvar' `_WsXi' `aux'
 }
 }
 if inlist("`run'", "xtdpd", "xtdhp", "xtabond", "xtdpdsys") {
 if "`aux'"=="" {
 local aux ""
 local _aux ""
 }
 if "`endog'"=="" {
 local endog ""
 local _endog ""
 }
 if "`lgmmiv'"=="" {
 local lgmmiv ""
 local _lgmmiv ""
 }
 if "`pre'"=="" {
 local pre ""
 local _pre ""
 }
 if !inlist("`model'", "sarxt") {
 local WsY1 ""
 local _WsY1 ""
 }
 if !inlist("`model'", "sdmxt") {
 local WsXi ""
 local _WsXi ""
 }
 if inlist("`run'", "xtdpd") {
 local LYi ""
 local _LYi ""
 }
 if inlist("`run'", "xtdhp") {
 gen double `LYi'= L1.`yvar'
 replace `LYi'=0 if `LYi'==.
 if "`mfx'"!="" & "`tolog'"!="" {
 gen double `_LYi'=L1.`_M'`yvar'
 replace `_LYi'=0 if `_LYi'==.
 }
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
 local lag1 `lag'
 forvalue i=1/`lag1' {
 gen double `LYi'`i' = L`i'.`yvar'
 replace `LYi'`i'=0 if `LYi'`i'==.
 }
 unab LYi: `LYi'*
 if "`mfx'"!="" & "`tolog'"!="" {
 forvalue i=1/`lag1' {
 gen double `_LYi'`i'=L`i'.`_M'`yvar'
 replace `_LYi'`i'=0 if `_LYi'`i'==.
 }
 }
 unab _LYi: `_LYi'*
 }
 unab SPXvar: `LYi' `pre' `WsY1' `endog' `xvar' `WsXi' `lgmmiv' `aux'
 if "`mfx'"!="" & "`tolog'"!="" {
 unab _SPXvar: `_LYi' `_pre' `_WsY1' `_endog' `_xvar' `_WsXi' `_lgmmiv' `aux'
 }
 }
 }
 mean `yvar'
 matrix `Yb'=e(b)'
 if "`mfx'"!="" & "`tolog'"!="" {
 mean `_SPXvar'
 }
 else {
 mean `SPXvar'
 }
 matrix `MSPX'=e(b)
 gen `X0'=1
 gen `Wi'=1
 gen `Wi1'= 1
 gen `Wis'= 1
 gen `WiB'= 1
 gen `Zo'= 1
 local _Yo "`yvar'"
 local _Zo "`SPXvar'"
 local k0=1
 local k =0
 mkmat `X0' , matrix(`X0')
 mkmat `_Yo' , matrix(`Y')
 local cns ""
 local wgt ""
 local wgts ""
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
 if "`noconstant'"!="" {
 local k0=0
 mkmat `_Zo' , matrix(`Z')
 local kb= colsof(`Z')
 local kx= `kb'
 mean `_Zo'
 }
 else { 
 mkmat `_Zo' `X0' , matrix(`Z')
 local kb= colsof(`Z')
 local kx= `kb'-1
 mean `_Zo' `X0'
 }
 matrix `XMB'=e(b)
 local kx: word count `_Zo'
 local kb=`kx'+`k0'
 local Jkx=`kx'-`k'
 local Jkb=`kb'-`k'
 local DF=`N'-`kx'+`k'-`NC'
 if inlist("`run'", "ols") {
 local DF=`N'-`kb'+`k'
 }
 if inlist("`model'", "xtivreg") {
 local DF=`N'-`kb'+`k'-`NC'
 }
 if inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 local DF=`N'-`kx'+`k'-`NC'
 }
 local in=`N'/`DF'
 if "`dn'"!="" {
 local DF=`N'
 local in=1
 }
 local JDF=`DF'
 global spat_kx=`kx'
 global spat_kxw=2*`kx'
 ereturn scalar df_m=$spat_kx
 if "`wvar'"!="" {
 replace `Wi' = (`wvar')^0.5 
 replace `Wis' = `wvar'
 local wtitle "Weighted Variable Type: (X)      -   Variable: (`wvar')"
 if "`weights'"=="" {
 local wgt "[weight = `Wis']"
 }
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "x", "xi", "x2", "xi2") {
 cap drop `Wi'
 regress `_Yo' `_Zo' , `noconstant'
 predict double `Yho' 
 predict double `Eo' , resid
 regress `Yho' `_Zo' , `noconstant'
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
 regress `Yho2' `_Zo' , `noconstant'
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
 }
 if "`wvar'"!="" | "`weights'"!="" {
 replace `Wi' = 0 if `Wi'==.
 replace `Wis' =`Wi'^2 
 summ `Wi' 
 replace `WiB' =r(mean)
 summ `Wis' 
 replace `Wi1'= sqrt(`Wis'/r(mean)) 
 replace `Zo'= `Wi'
 if inlist("`run'", "xtfe", "xtfem", "xtmle", "xtmlm", "xtpa") {
 tempvar WiB Wis
 bys `idv' : egen `WiB'=mean(`Wi')
 bys `idv' : egen `Wis'=mean(`Wi')
 replace `Wi1'= (`Wis') 
 replace `Zo'= `Wi1'
 replace `Wis'= `Wis'^2 
 }
 local wgt "[weight = `Wis']"
 local wgts "[weight = `Wis']"
 if inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") {
 local wgt "[aweight=`Wis']"
 }
 if inlist("`run'", "xtmle", "xtfrontier") {
 local wgts " [iweight = `Wis'] "
 }
 }
 mkmat `Wi' , matrix(`Wi')
 mata: Wi = st_matrix("`Wi'")
 matrix `Wi'= diag(`Wi')
 matrix `Wio'= diag(`X0')
 mkmat `Wi1' , matrix(`Wi1')
 mata: Wi1 = st_matrix("`Wi1'")
 matrix `Wi1' = diag(`Wi1')
 if "`wvar'"!="" {
 local wvarn "wvar(`Wi')"
 }
 else {
 local wvarn ""
 }
 matrix `Omega'=`Wi''*`Wi'
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `Yws'=`Wi'*`Y'
 matrix `Zws'=`Wi'*`Z'
 if inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 putmata `Wi' , replace
 putmata `Wi1' , replace
 putmata `yvar' , replace
 putmata `xvar' , replace 
 }
 scalar `Kr'=`kr'
 matrix `Zz'=I(`kb')*0
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
 if !inlist("`model'", "spgmm") {
 if "`ridge'"!="" {
 _SPRidge `_Yo' `_Zo' , kr(`kr') kx(`kx') kb(`kb') nt(`N') df(`DF') ///
 ridge(`ridge') iter(`iter') `noconstant' `dn' aux(`aux') wvar(`Wi')
 matrix `Zz'=e(Zz)
 local Kr=e(Kr)
 }
 }

 if "`tests'"!="" | "`lmspac'"!= "" {
 if !inlist("`model'", "gs2sls", "gs2slsar") {
 reg3 (`_Yo' `_Zo' , `noconstant') `wgt' , `noconstant' `cns' small ols
 } 
 if inlist("`model'", "gs2sls", "gs2slsar") {
 reg3 (`_Yo' = `WsYi' `exog' , `noconstant') `wgt' , `noconstant' `cns' inst(`instx') small 2sls
 }
 scalar `Sig2SP'=e(rmse_1)^2
 scalar `SSESP'=e(rss_1)
 matrix `Bx_SP'=e(b)
 matrix `YwSP'=`Yws'
 matrix `ZwSP'=`Zws'
 predict double `Ue_SP' , resid
 putmata Ue_SP =`Ue_SP' , replace
 }
 tsset `Time'
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 matrix `olsols'=e(b)
 local rmse=e(rmse)
 if "`mhet'"!="" {
 regress `_Yo' `mhet' , noconstant
 matrix `olshet'=e(b)
 }
 scalar `llf'=.
 matrix `In'=I(`N')
 mlopts mlopts , `vce' iter(`iter') tech(`tech')
 local N = _N
 xtset `idv' `itv'
 ereturn matrix WCS= `WCS' , copy
 if inlist("`model'", "spgmm") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Spatial Panel Autoregressive Generalized Method of Moments (SPGMM)}}"
noi di _dup(78) "{bf:{err:=}}"
 ereturn scalar DF=`DF'
 ereturn scalar k=`k'
 ereturn scalar k0=`k0'
 ereturn scalar kb=`kb'
 ereturn scalar kx=`kx'
 spregxt31 `_Yo' `xvar' , idv(`idv') itv(`itv') gmm(`gmm') `noconstant' iter(`iter') `dn' `vce' ///
 `level' `tobit' ll(`ll') rest(`rest') `robust' aux(`aux') `wvarn' ridge(`ridge') kr(`kr')
 scalar `llf'=e(llf)
 scalar `Kr'=e(Kr)
 matrix `B'=e(b)
 matrix `Cov'= e(V)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 } 

 if inlist("`model'", "gs2sls", "gs2slsar") {
noi di _dup(78) "{bf:{err:=}}"
 if inlist("`model'", "gs2sls") {
noi di as txt "{bf:{err:* Generalized Spatial Panel Two Stage Least Squares (GS2SLS)}}"
 xtivreg `yvar' `exog' (`WsYi' = `inst') , small `vce' `nosa' `be' `fe' `re' `ec2sls' `level'
 }
 if inlist("`model'", "gs2slsar") {
noi di as txt "{bf:{err:* Generalized Spatial Panel Autoregressive Two Stage Least Squares (GS2SLSAR)}}"
 ereturn scalar kb=`kb'
 ereturn scalar DF=`DF'
 local wsxin "wsxi(`WsXi')"
 spregxt32 `yvar' `xvar' , idv(`idv') itv(`itv') gmm(`gmm') order(`order') wsxi(`WsXi') ///
 `level' `nosa' `coll' `be' `fe' `re' `ec2sls' aux(`aux') endog(`endog') inst(`instiv') `vce'
 }
noi di _dup(78) "{bf:{err:=}}"
 scalar `llf'=e(ll)
 matrix `BetaSP'=e(b)
 matrix `B'=`BetaSP'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov'=`Cov'[1..`kb', 1..`kb']
 test _b[w1y_`yvar'] =0
 scalar `rRo'=_b[w1y_`yvar']
 scalar `fgs2s'=r(F)
 scalar `rdfgs'=r(df)
 scalar `rdfgsr'=r(df_r)
 scalar `fgs2sp'=r(p)
 if "`rest'"!="" {
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }

 if "`run'"!="" {
 if !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 tabulate `idv' , generate(`dcs')
 mkmat `dcs'* , matrix(`D')
 matrix `Xo'=J(`NT',1,1)
 matrix `D'=I(`NC')#`Xo'
 matrix `P'=`D'*invsym(`D''*`D')*`D''
 matrix `Q'=I(`N')-`P'
 }
 if inlist("`model'", "ols") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Non Spatial Panel Data Regression: {cmd:Model(`model') - Run(`run')}}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sarxt") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Spatial Panel Lag Regression (SAR): {cmd:Model(`model') - Run(`run')}}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sdmxt") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Spatial Panel Durbin Regression (SDM): {cmd:Model(`model') - Run(`run')}}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "gwr") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Spatial Panel Geographically Weighted Regression (GWR): {cmd:Model(`model') - Run(`run')}}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if !inlist("`model'", "gs2sls", "gs2slsar", "spgmm") & !inlist("`run'", "xtmln", "xtmlh") {
 if !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys", "xtmln", "xtmlh") {
 if inlist("`run'", "ols") {
noi di as txt "{bf:{err:* Ordinary Least Squares (OLS): Restricted - Ridge - Weighted Regression}}"
 matrix `ZwZ'=`Zws''*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Yws'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtbe", "xtfe", "xtre", "xtmle") {
 if inlist("`run'", "xtbe") {
noi di as txt "{bf:{err:* Between-Effects Panel Data Regression}}"
 xtreg `_Yo' `_Zo' , be `vce' `level' `noconstant'
 } 
 if inlist("`run'", "xtfe") {
noi di as txt "{bf:{err:* Fixed-Effects Panel Data Regression}}"
 xtreg `_Yo' `_Zo' `wgts' , fe `vce' `level' `noconstant'
 }
 if inlist("`run'", "xtmle") {
noi di as txt "{bf:{err:* MLE Random-Effects Panel Data Regression}}"
 xtreg `_Yo' `_Zo' `wgts' , mle `vce' `level' `noconstant' iter(`iter')
 }
 if inlist("`run'", "xtre") {
noi di as txt "{bf:{err:* GLS Random-Effects Panel Data Regression}}"
 xtreg `_Yo' `_Zo' , re `vce' `level' `noconstant'
 } 
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(ll)
 predict double `Yh_ML' , xb
 predict double `Ue_ML' , e
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 if "`rest'"!="" {
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 }
 if inlist("`run'", "xtam") {
noi di as txt "{bf:{err:* Amemiya Random-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `B'=inv(`Z''*`Q'*`Z')*`Z''*`Q'*`Y'
 matrix `A'=`Yb'-`XMB'*`B' 
 matrix `DVE'=`Y'-`A'*`X0'-`Z'*`B'
 matrix `VQ'=(`DVE''*`Omega'*`DVE')/(`N'-`NC')
 matrix `VP'=(`DVE''*`P'*`DVE')/`NC'
 matrix `VM'=(`VP'-`VQ')/`NT'
 scalar `VMo'=`VM'[1,1]
 scalar `VPo'=`VP'[1,1]
 scalar `VQo'=`VQ'[1,1]
 scalar `VQos'=sqrt(`VQo')
 scalar `VPos'=sqrt(`VPo')
 scalar `VPo'=(`NT'*`VMo')+`VQo'
 scalar `THw'=1-`VQos'/`VPos'
 matrix `Om1'=`Q'/`VQo'
 matrix `Om2'=`P'/`VPo'
 matrix `Om'=`Om1'+`Om2'
 matrix `Omega1'=`Om'
 matrix `ZwZ'=`Zws''*`Omega1'*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Omega1'*`Yws'
 matrix `Omm1'=`Q'/`VQos'
 matrix `Omm2'=`P'/`VPos'
 matrix `Omm'=`Omm1'+`Omm2'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omega1'=`Wi'*`Omm'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtbem") {
noi di as txt "{bf:{err:* Between-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `Omega1'=`P' 
 matrix `ZwZ'=`Zws''*`Omega1'*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Omega1'*`Yws'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omega1'=`Wi'*`P'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 if `NC' <= `kb' {
 matrix `Sig2'=1
 }
 if `NC' > `kb' {
 matrix `Sig2'=`E''*`E'/(`NC'-`Jkb')
 }
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtbn") {
noi di as txt "{bf:{err:* Balestra-Nerlove Random-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `B'=inv(`Z''*`Q'*`Z')*(`Z''*`Q'*`Y') 
 matrix `A'=`Yb'-`XMB'*`B'
 matrix `DVE'=`Y'-`A'*`X0'-`Z'*`B'
 matrix `NE'=`P'*`DVE'
 matrix `NEB'=`NE''*`X0'/`N'
 matrix `DVNE'=`NE'-(`X0'*`NEB')
 if "`dn'"!="" {
 matrix `Sig2'=(`DVNE''*`DVNE')/`DF'
 }
 else {
 matrix `Sig2'=(`DVNE''*`DVNE')/(`NT'*(`NC'-1))
 }
 matrix `E'=`Q'*(`Y'-`Z'*`B')
 matrix `VQ'=(`E''*`E')/`N'
 matrix `VP'=`NT'*`Sig2'+`VQ'
 scalar `VQo'=`VQ'[1,1]
 scalar `VPo'=`VP'[1,1]
 scalar `VQos'=sqrt(`VQo')
 scalar `VPos'=sqrt(`VPo')
 scalar `THn'=1-`VQos'/`VPos'
 matrix `Om1'=`Q'/`VQo'
 matrix `Om2'=`P'/`VPo'
 matrix `Om'=`Om1'+`Om2'
 matrix `Omega1'=`Om' 
 matrix `ZwZ'=`Zws''*`Omega1'*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Omega1'*`Yws'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omm1'=`Q'/`VQos'
 matrix `Omm2'=`P'/`VPos'
 matrix `Omm'=`Omm1'+`Omm2'
 matrix `Omega1'=`Wi'*`Omm'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }

 if inlist("`run'", "xtfem") {
noi di as txt "{bf:{err:* Fixed-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 tempvar Zoc SLSVar Wio Wfe ws Ys_
 local vlist1 "`_Yo' `_Zo'"
 local vlist1 : list vlist1-aux
 foreach i of local vlist1 {
 bysort `idv': gen double `Ys_'`i' = sum(`i'*`Wis')/sum(`Wis')
 summ `i' [weight=`Wis']
 bysort `idv': replace `Ys_'`i' = (`i' - `Ys_'`i'[_N]) + r(mean)
 }
 gen double `Zoc' = 1
 unab vlist2: `Ys_'*
 tokenize `vlist2'
 local Yfem "`1'"
 macro shift 1
 local Xfem1 "`*'"
 local Xfem "`Xfem1' `aux'"
 mkmat `Yfem' , matrix(`Yfe')
 if "`noconstant'"!="" {
 mkmat `Xfem' , matrix(`Xfe')
 }
 else { 
 mkmat `Xfem' `Zoc' , matrix(`Xfe')
 }
 if "`wvar'"!="" | "`weights'"!="" {
 bysort `idv': gen double `ws' = sum(`Wi')/_N 
 summ `Wi' 
 bysort `idv': gen double `Wio' = `Wi' - `ws'[_N] + r(mean) 
 replace `Zoc' = `Wio'
 mkmat `Wio' , matrix(`Wi')
 matrix `Wio'=diag(`Wi')
 }
 if "`ridge'"!="" {
 local Zo_Zw "`Zoc' `Xfem1'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v' - r(mean)
 }
 }
 unab ZSLSVar : `SLSVar'_* `aux'
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 replace `ZoC' = 0
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 }
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 matrix `Yfe'=`Wi1'*`Yfe'
 matrix `Xfe'=`Wi1'*`Xfe'
 matrix `ZwZ'=`Xfe''*`Xfe'
 matrix `B'=invsym(`Xfe''*`Xfe'+`Zz')*`Xfe''*`Yfe'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Q'*(`Yfe'-`Xfe'*`B')
 matrix `Sig2'=`E''*`E'/(`N'-`Jkx'-`NC')
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtfm") {
noi di as txt "{bf:{err:* Fama-MacBeth Panel Data: Restricted - Ridge - Weighted Regression}}"
 levelsof `itv' , local(levels)
 foreach i of local levels {
 mkmat `_Yo' if `itv'== `i' , matrix(`Yfm')
 if "`noconstant'"!="" {
 mkmat `_Zo' if `itv'== `i' , matrix(`Xfm')
 }
 else { 
 mkmat `_Zo' `X0' if `itv'== `i' , matrix(`Xfm')
 }
 tempvar Wio
 gen double `Wio' = `Wi'*`Wi'
 mkmat `Wio' if `itv'== `i' , matrix(`Wio')
 matrix `Omega1'=diag(`Wio')
 matrix `B'=invsym(`Xfm''*`Omega1'*`Xfm'+`Zz')*`Xfm''*`Omega1'*`Yfm'
 matrix `XFMb' = (nullmat(`XFMb') \ `B'')
 }
 mata: `XFMb'= st_matrix("`XFMb'")
 mata: `B'= mean(`XFMb')
 mata: `B'=st_matrix("`B'",`B')
 matrix `B'=`B''
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtfrontier") {
noi di as txt "{bf:{err:* Frontier Panel Data: Restricted - Weighted Regression}}"
 xtfrontier `_Yo' `_Zo' `wgts' , `noconstant' `vce' ///
 `cost' `ti' `tvd' iter(`iter') tech(`tech') `level' `Cns'
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(ll)
 predict double `Yh_ML' , xb
 mkmat `Yh_ML' , matrix(`Yh_ML')
 matrix `Ue_ML' = `Y'-`Yh_ML'
 if "`te'"!="" {
 cap drop _TE
 cap drop _TE_e
 cap drop _TE_m
 cap drop _TE_l
 cap drop _TE_u
 cap predict double _TE , te
 cap predict double _TE_e , u
 cap predict double _TE_m , m
 cap putmata _TE , replace
 cap putmata _TE_e , replace
 cap putmata _TE_m , replace
 cap frontier_teci _TE 
 if ("`e(user)'" != "xtsf_llti") {
 if ("`e(user)'" != "xtsf_ll") {
 noi di
 noi di as err " Technical Efficiency Confidence Intervals Require Stata {help frontier_teci} Module"
 }
 }
 else {
 cap putmata _TE_l , replace
 cap putmata _TE_u , replace
 }
 } 
 }
 if inlist("`run'", "xthh") {
noi di as txt "{bf:{err:* Hildreth-Houck Random Coefficients Panel Data: Restricted - Weighted Regression}}"
 regress `_Yo' `_Zo' if `idv'==1 `wgts' , `noconstant' `vce' `level'
 matrix `B1' = e(b)
 matrix `V1' = e(V)
 matrix `V1s' = invsym(`V1')
 matrix `Bt' = `V1s'*`B1''
 matrix `B12'= `B1''*`B1' 
 matrix `B1b'= `B1'
 local i = 2
 while `i' <= `NC' {
 regress `_Yo' `_Zo' if `idv'==`i' `wgts' , `noconstant' `vce' `level'
 tempname B`i' V`i' 
 matrix `B`i''= e(b)
 matrix `B1b'= `B1b'+`B`i''
 matrix `BB2' = `B`i'''*`B`i''
 matrix `B12'= `B12'+`BB2'
 matrix `V`i''= e(V)
 matrix `Vs' = invsym(`V`i'')
 matrix `V1s'= `V1s'+`Vs'
 matrix `Vs' = `Vs'*`B`i'''
 matrix `Bt' = `Bt'+`Vs'
 local i = `i' + 1
 }
 matrix `V1s'= invsym(`V1s')
 matrix `Bt' = `V1s'*`Bt'
 local NCi = `NC1'/`NC2'
 matrix `B1b'= `B1b'*`NCi'
 matrix `gam2'= `B1b''* `B1b'
 matrix `gam2'= `gam2'*`NC'
 matrix `gam'= `B12'-`gam2'
 local NCi = 1/(`NC'-1)
 matrix `gam'= `gam'*`NCi'
 matrix `Cov1' = `gam'+`V1'
 matrix `Cov1' = invsym(`Cov1')
 matrix `Cov'= `Cov1'
 matrix `Bt' = `Bt' '
 matrix `B1t'= `B1' - `Bt'
 matrix `Cov2s'= invsym(`V1')
 matrix `Bm' = `B1t'*`Cov2s'
 matrix `Bm' = `Bm'*`B1t''
 local i 2
 while `i' <= `NC' {
 tempname Cov`i'
 matrix `Cov`i''=`gam'+`V`i''
 matrix `Cov`i''=invsym(`Cov`i'')
 matrix `Cov' =`Cov'+`Cov`i'' 
 matrix `B1t' =`B`i''-`Bt'
 matrix `Cov2s'=invsym(`V`i'')
 matrix `Cov2s'=`B1t'*`Cov2s'
 matrix `Cov2s'=`Cov2s'*`B1t''
 matrix `Bm' = `Bm'+`Cov2s'
 local i = `i'+1
 }
 local kk = colsof(`B1')
 local lmconsdf= `kk'*(`NC'-1)
 local lmcons =`Bm'[1,1]
 local lmconsp=chi2tail(`lmconsdf',`lmcons')
 matrix `Cov'=invsym(`Cov')
 local i 1
 while `i' <= `NC' {
 matrix `Cov`i''=`Cov'*`Cov`i''
 local i = `i'+1
 }
 matrix `B'=`Cov1'*`B1''
 local i 2
 while `i' <= `NC' {
 matrix `den'= `Cov`i''*`B`i'''
 matrix `B'=`B'+`den'
 local i = `i'+1
 }
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ')*`Rs''*invsym(`Rs'*invsym(`ZwZ')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }

 if "`run'"=="xtregar" | "`run'"=="xtgls" | "`run'"=="xtkmhomo" | "`run'"=="xtkmhet1" ///
 | "`run'"=="xtkmhet2" | "`run'"=="xtmg" | "`run'"=="xtpa" | "`run'"=="xtparks" ///
 | "`run'"=="xtpcse" | "`run'"=="xtrc" {
 if inlist("`run'", "xtregar") {
noi di as txt "{bf:{err:* Linear AR(1) Panel Data: Restricted - Weighted Regression}}"
 xtregar `_Yo' `_Zo' `wgt' , `fe' `re' `twostep' rhotype(`rhotype') `vce' `level'
 }
 if inlist("`run'", "xtgls") {
noi di as txt "{bf:{err:* Generalized Least Squares Panel Data: Restricted - Weighted Regression}}"
 xtgls `_Yo' `_Zo' `wgts' , `noconstant' `vce' force ///
 `nmk' `igls' panels(`panels') rhotype(`rhotype') iter(`iter')
 }
 if inlist("`run'", "xtkmhomo") {
noi di as txt "{bf:{err:* Kmenta Homoscedastic GLS AR(1) Panel Data: Restricted, and Weighted Regression}}"
 xtgls `_Yo' `_Zo' `wgts' , panels(iid) corr(psar1) `nmk' `igls' force ///
 `noconstant' `vce' `level' iter(`iter')
 }
 if inlist("`run'", "xtkmhet1") {
noi di as txt "{bf:{err:* Kmenta Heteroscedastic GLS AR(1) Panel Data: Restricted - Weighted Regression}}"
 xtgls `_Yo' `_Zo' `wgts' , panels(het) corr(psar1) `nmk' `igls' force ///
 `noconstant' `vce' `level' iter(`iter')
 }
 if inlist("`run'", "xtkmhet2") {
noi di as txt "{bf:{err:* Kmenta Heteroscedastic SAME Common AR(1) for all Panels: Restricted - Weighted Regression}}"
 xtgls `_Yo' `_Zo' `wgts' , panels(het) corr(ar1) `nmk' `igls' force ///
 `noconstant' `vce' `level' iter(`iter')
 }
 if inlist("`run'", "xtmg") {
noi di as txt "{bf:{err:* Heterogeneous Slopes Time Series Panel Data: Restricted - Weighted Regression}}"
 cap xtmg `_Yo' `_Zo' `wgts' , `noconstant' `vce' `level'
 if "`e(cmd)'"!="xtmg" {
noi di
noi di as err " {bf:run(xtmg)} {cmd:option requires xtmg module}"
 exit
 }
 if r(N) == 0 {
noi di
noi di as text " Note: Estimation stopped because not enough panels sample size"
 exit
 }
 }
 if inlist("`run'", "xtpa") {
noi di as txt "{bf:{err:* Population Averaged-Effects Panel Data: Restricted - Weighted Regression}}"
 xtreg `_Yo' `_Zo' `wgts' , pa `vce' `level' `noconstant' iter(`iter')
 }
 if inlist("`run'", "xtparks") {
noi di as txt "{bf:{err:* Parks (FULL) Heteroscedastic Cross-Section GLS AR(1): Restricted - Weighted Regression}}"
 xtgls `_Yo' `_Zo' `wgts' , panels(corr) corr(psar1) `nmk' `igls' force ///
 `noconstant' `vce' `level' iter(`iter')
 }
 if inlist("`run'", "xtpcse") {
noi di as txt "{bf:{err:* Linear Panel-Corrected Standard Error (PCSE): Restricted - Weighted Regression}}"
 xtpcse `_Yo' `_Zo' `wgts' , `noconstant' `corr' `vce' `level' `indep' `hetonly'
 }
 if inlist("`run'", "xtrc") {
noi di as txt "{bf:{err:* Swamy Random-Coefficients Panel Data: Restricted - Weighted Regression}}"
 cap xtrc `_Yo' `_Zo' , `noconstant' `vce' `level'
 if r(N) == 0 {
noi di
noi di as text " Note: Estimation stopped because Panels too small"
 exit
 }
 local lmconsdf= e(df_chi2c)
 local lmcons =e(chi2_c)
 local lmconsp=chi2tail(`lmconsdf',`lmcons')
 }
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(ll)
 predict double `Yh_ML' , xb
 mkmat `Yh_ML' , matrix(`Yh_ML')
 matrix `Ue_ML' = `Y'-`Yh_ML'
 if "`rest'"!="" {
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `B'=`B'+(invsym(`ZwZ')*`Rs''*invsym(`Rs'*invsym(`ZwZ')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')* ///
 `Rs''*invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 }

 if inlist("`run'", "xtrem") {
noi di as txt "{bf:{err:* Fuller-Battese GLS Random-Effects: Restricted - Ridge - Weighted Regression}}"
 tabulate `idv' , generate(`dumxcs')
 regress `_Yo' `_Zo' `dumxcs'* , noconstant
 scalar `Sigw'=e(rmse)
 matrix `B'=invsym(`Z''*`P'*`Z')*(`Z''*`P'*`Y')
 matrix `E'=`P'*(`Y'-`Z'*`B')
 matrix `Sig2b'=`E''*`E'/(`NC'-`Jkb')
 matrix `Sig2u'=(`Sig2b'-`Sigw'^2)/`NT'
 scalar `Sigb'=`Sig2b'[1,1]^0.5
 scalar `Sigu'=`Sig2u'[1,1]^0.5
 if `Sigu'==. {
 scalar `Sigu' = 0
 }
 scalar `Rho'=1-`Sigw'/sqrt(`NT'*`Sigu'^2+`Sigw'^2)
 if `Rho'==. {
 scalar `Rho'=1-(`Sigw'/`Sigb')
 }
 tempvar Wre Ys_ Zoc SLSVar
 unab vlist1: `_Yo' `_Zo'
 local vlist1 : list vlist1-aux
 xtset `idv' `itv'
 foreach i of local vlist1 {
 gen double `Ys_'`i' = `i'
 }
 levelsof `idv' , local(levels)
 foreach j of local levels {
 foreach i of local vlist1 {
 summ `i' if `idv' == `j', meanonly
 replace `Ys_'`i' = `i'-`Rho'*r(mean) if `idv' == `j'
 }
 }
 gen double `Zoc' = 1-`Rho'
 unab vlist2: `Ys_'*
 tokenize `vlist2'
 local Yrem "`1'"
 macro shift 1
 local Xrem1 "`*'"
 local Xrem "`Xrem1' `aux'"
 if "`coll'"=="" {
 _rmcoll `Xrem' , `noconstant' forcedrop
 local Xrem "`r(varlist)'"
 }
 mkmat `Yrem' , matrix(`Yre')
 if "`noconstant'"!="" {
 mkmat `Xrem' , matrix(`Xre')
 }
 else { 
 mkmat `Xrem' `Zoc' , matrix(`Xre')
 }
 if "`wvar'"!="" | "`weights'"!="" {
 tempvar Wio
 bysort `idv': summ `Wi' 
 bysort `idv': gen double `Wio' = `Wi'-`Rho'*r(mean)
 replace `Zoc' = `Wio'
 mkmat `Wio' , matrix(`Wio')
 matrix `Wio' =diag(`Wio')
 }
 if "`ridge'"!="" {
 local Zo_Zw "`Zoc' `Xrem1'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
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
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' `aux' , matrix(`Zr')
 }
 else {
 mkmat `ZSLSVar' `aux' `ZoC' , matrix(`Zr')
 }
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 matrix `Omega1'=`Wio''*`Wio'
 matrix `B'=invsym(`Xre''*`Omega1'*`Xre'+`Zz')*`Xre''*`Omega1'*`Yre'
 matrix `Yre'=`Wio'*`Yre'
 matrix `Xre'=`Wio'*`Xre'
 matrix `ZwZ'=`Xre''*`Xre'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=(`Yre'-`Xre'*`B')
 matrix `Sig2'=`E''*`E'/(`N'-`Jkb')
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')- ///
 `Sig2'*invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xtsa") {
noi di as txt "{bf:{err:* Swamy-Arora Random-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `VQ'=(`Y''*`Q'*`Y'-`Y''*`Q'*`Z'*inv(`Z''*`Q'*`Z')*`Z''*`Q'*`Y')/(`N'-`NC'-`Jkx')
 matrix `VP'=(`Y''*`P'*`Y'-`Y''*`P'*`Z'*inv(`Z''*`P'*`Z')*`Z''*`P'*`Y')/(`N'-`NC'-1)
 matrix `VM'=(`VP'-`VQ')/`NT'
 scalar `VMo'=`VM'[1,1]
 scalar `VPo'=`VP'[1,1]
 scalar `VQo'=`VQ'[1,1]
 scalar `VQos'=sqrt(`VQo')
 scalar `VPos'=sqrt(`VPo')
 scalar `VPo'=(`NT'*`VMo')+`VQo'
 scalar `THw'=1-`VQos'/`VPos'
 matrix `Om1'=`Q'/`VQo'
 matrix `Om2'=`P'/`VPo'
 matrix `Om'=`Om1'+`Om2'
 matrix `Omega1'=`Om'
 matrix `ZwZ'=`Zws''*`Omega1'*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Omega1'*`Yws'
 matrix `Omm1'=`Q'/`VQos'
 matrix `Omm2'=`P'/`VPos'
 matrix `Omm'=`Omm1'+`Omm2'
 matrix `ZwZ'=`Z''*`Omega1'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omega1'=`Wi'*`Omm'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=(`E''*`E')/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Z'*`B')
 }
 if inlist("`run'", "xtmlem") {
noi di as txt "{bf:{err:* Trevor Breusch MLE Random-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `B'=invsym(`Z''*`Z')*`Z''*`Y'
 matrix `JNT'=J(`N',`N',1)
 matrix `JNT'=`JNT'/`N'
 forvalue i = 1/`iter' {
 matrix `Bo'=`B'
 tempvar BKo BKi
 svmat double `Bo' , name(`BKo')
 summ `BKo' 
 scalar `BsKo'=r(sum)
 matrix `E'=(`Y'-`Z'*`B')
 matrix `PHM1'=(`E''*`Q'*`E')
 matrix `PHM2'=(`E''*(`P'-`JNT')*`E')*(`NT'-1)
 scalar `PHM'=`PHM1'[1,1]/`PHM2'[1,1]
 matrix `VQo'=(`E''*(`Q'+`PHM'*(`P'-`JNT'))*`E')/`N'
 scalar `VQo'=`VQo'[1,1]
 scalar `VPo'=`VQo'/`PHM'
 matrix `Om1'=`Q'/`VQo'
 matrix `Om2'=`P'/`VPo'
 matrix `Om'=`Om1'+`Om2'
 matrix `Omega1'=`Om'
 matrix `ZwZ'=`Zws''*`Omega1'*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Omega1'*`Yws'
 matrix `BKi'=`B'
 svmat double `BKi' , name(`BKi')
 summ `BKi' 
 scalar `BsKi'=r(sum)
 scalar `BsKoi'=abs(`BsKi'-`BsKo')
 if (`BsKoi' <= 0.00001) {
 continue, break
 }
 }
 matrix `Bo'=`BKi'
 matrix `B'=`B'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omega1'=`Wi'*`Om'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 if inlist("`run'", "xttobit") {
noi di as txt "{bf:{err:* Tobit Random-Effects Panel Data: Restricted - Weighted Regression}}"
 xttobit `_Yo' `_Zo' `wgts' , `noconstant' `vce' `Cns' `level' ll(`ll') iter(`iter') tech(`tech')
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(ll)
 predict double `Yh_ML' , xb
 mkmat `Yh_ML' , matrix(`Yh_ML')
 matrix `Ue_ML' = `Y'-`Yh_ML'
 } 

 if inlist("`run'", "xtwem") {
noi di as txt "{bf:{err:* Within-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `Omega1'=`Wi''*`Q'*`Wi'
 matrix `B'=inv(`Z''*`Omega1'*`Z'+`Zz')*`Z''*`Omega1'*`Y'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/(`DF'-`NC')
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }

 if inlist("`run'", "xtwh") {
noi di as txt "{bf:{err:* Wallace-Hussain Random-Effects Panel Data: Restricted - Ridge - Weighted Regression}}"
 matrix `B'=invsym(`Z''*`Z')*`Z''*`Y'
 matrix `E'=(`Y'-`Z'*`B')
 matrix `VQ'=(`E''*`Q'*`E')/(`N'-`NC')
 matrix `VP'=(`E''*`P'*`E')/`NC'
 matrix `VM'=(`VP'-`VQ')/`NT'
 scalar `VMo'=`VM'[1,1]
 scalar `VPo'=`VP'[1,1]
 scalar `VQo'=`VQ'[1,1]
 scalar `VQos'=sqrt(`VQo')
 scalar `VPos'=sqrt(`VPo')
 scalar `VPo'=(`NT'*`VMo')+`VQo'
 scalar `THw'=1-`VQos'/`VPos'
 matrix `Om1'=`Q'/`VQo'
 matrix `Om2'=`P'/`VPo'
 matrix `Om'=`Om1'+`Om2'
 matrix `Omega1'=`Wi''*`Om'*`Wi'
 matrix `B'=invsym(`Z''*`Omega1'*`Z'+`Zz')*`Z''*`Omega1'*`Y'
 matrix `Omm1'=`Q'/`VQos'
 matrix `Omm2'=`P'/`VPos'
 matrix `Omm'=`Omm1'+`Omm2'
 matrix `ZwZ'=`Z''*`Omega1'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `Omega1'=`Wi'*`Omm'
 matrix `E'=`Omega1'*(`Y'-`Z'*`B')
 matrix `Sig2'=(`E''*`E')/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 }
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`run'", "xtdpd") {
noi di as txt "{bf:{err:* Arellano-Bond (1991) Linear Dynamic Panel Data: Restricted - Weighted Regression}}"
 xtdpd `_Yo' `_Zo' , `noconstant' `vce' `robust' `twostep' dgmmiv(`dgmmiv') lgmmiv(`lgmmiv')
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 scalar `llf'=e(ll)
 predict double `Yh_ML' , xb
 predict double `Ue_ML' , e
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 if "`rest'"!="" {
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 }
 } 

 if inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 cap preserve
 tempvar Yh_ML Ue_ML
 ereturn scalar kb=`kb'
 ereturn scalar kx=`kx'
 ereturn scalar DF=`DF'
 ereturn scalar Nn=`N'
 if inlist("`run'", "xtdhp") {
noi di as txt "{bf:{err:* Han-Philips (2010) Linear Dynamic Panel Data Regression}}"
 spregxt35 `_Yo' `WsY1' `xvar' `WsXi' , `fe' `re' `be' `mle' aux(`aux') wit(`Wi') ///
 `level' idv(`idv') itv(`itv') iter(`iter')
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov'= e(V)
 matrix `Cov' = `Cov'[1..`kb', 1..`kb'] 
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Yh_ML' , force replace
 getmata `Ue_ML' , force replace
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
 if inlist("`run'", "xtabond") {
noi di as txt "{bf:{err:* Arellano-Bond Linear Dynamic Panel Data Regression}}"
 xtabond `yvar' `WsY1' `xvar' `WsXi' , pre(`pre') endog(`endog') diff(`diff') ///
 inst(`inst') lag(`lag') `noconstant' `vce' `level' `twostep' 
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`run'", "xtdpdsys") {
noi di as txt "{bf:{err:* Arellano-Bover/Blundell-Bond (1995, 1998) System Linear Dynamic Panel Data}}"
 xtdpdsys `yvar' `WsY1' `xvar' `WsXi' , pre(`pre') endog(`endog') diff(`diff') ///
 inst(`inst') lag(`lag') `noconstant' `vce' `level' `twostep' 
noi di _dup(78) "{bf:{err:=}}"
 }
 scalar `dfab'=e(zrank)-e(rank)
 scalar `lmiab'=e(sargan)
 scalar `lmiabp'=chi2tail(`dfab', abs(`lmiab'))
 scalar `sigox'=sqrt(e(sig2))
 scalar `Sig2o'=e(sig2)
 scalar `llf'=e(ll)
 matrix `B'=e(b)
 matrix `Cov'= e(V)
 predict double `Yh_ML' , xb
 predict double `Ue_ML' , e
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 }
 mark `miss'
 if inlist("`run'", "xtdhp") {
 markout `miss' `_Yo' `_Zo' `Yh_ML' `Ue_ML' `Wi1' `Wi'
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
 markout `miss' `_Yo' `_Zo' `Yh_ML' `Ue_ML' `Wi1' `Wi' `inst'
 }
 markout `miss' `_Yo' `_Zo' `Yh_ML' `Ue_ML' `Wi1' `Wi' `inst'
 keep if `miss' == 1
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `_Yo' , matrix(`Y')
 if "`noconstant'"!="" {
 mkmat `_Zo' , matrix(`Z')
 }
 else { 
 mkmat `_Zo' `X0' , matrix(`Z')
 }
 replace `Zo' =1
 summ `_Yo'
 local N = r(N)
 tempvar dcs
 tabulate `idv' , generate(`dcs')
 mkmat `dcs'* , matrix(`D')
 matrix `P'=`D'*invsym(`D''*`D')*`D''
 matrix `Q'=I(`N')-`P'
 mkmat `_Yo' , matrix(`Y')
 if inlist("`run'", "xtdhp") {
 mkmat `_Zo' `Zo' , matrix(`Z')
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
 if "`noconstant'"!="" {
 mkmat `_Zo' , matrix(`Z')
 }
 else { 
 mkmat `_Zo' `Zo' , matrix(`Z')
 }
 }
 if "`rest'"!="" {
 matrix `ZwZ'=`Z''*`Z'
 matrix `B'=`B'+(invsym(`ZwZ')*`Rs''*invsym(`Rs'*invsym(`ZwZ')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Z'*`B')
 }
 if inlist("`run'", "xtdhp") {
 matrix `E'=`Y' - (`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 scalar `Sig21'=`Sig2'[1,1]
 scalar `sigox'=sqrt(`Sig21')
 scalar `Sig2o'=`Sig21'
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Z'*`B')
 }
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Yh_ML' , force replace
 getmata `Ue_ML' , force replace
 }

 if inlist("`run'", "xtmln", "xtmlh") {
 if inlist("`run'", "xtmln") {
 local MName "MLEREMLN"
 regress `_Yo' `_Zo' , `noconstant'
 matrix `olsin'=`olsols',0,0
 local initopt init(`olsin', copy) 
 ereturn scalar NC=`nc'
 xi: ml model d0 spregxt33 (`_Yo': `_Yo' = `_Zo' , `cns' `noconstant') ///
 (Sigu:) (Sige:) , `mlopts' contin `nolog' `diparm' `initopt' maximize ///
 title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Sigu:_cons Sige:_cons"
 test `_Zo'
 scalar `waldm'=r(chi2)
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Random-Effects Spatial Panel Data Regression (Normal Distribution Model)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`run'", "xtmlh") {
 local MName "MLEREMLH"
 tsset `Time'
 matrix `olsin'=`olsols',`olshet',0,0
 local initopt init(`olsin', copy) 
 ereturn scalar NC=`nc'
 xi: ml model d0 spregxt34 (`_Yo': `_Yo' = `_Zo' , `cns' `noconstant') ///
 (Hetero: `mhet', noconst) (Sigu:) (Sige:) , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Sigu:_cons Sige:_cons"
 test `_Zo'
 scalar `waldm'=r(chi2)
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Random-Effects Spatial Panel Data Regression (Normal Distribution Model)}}"
noi di as txt "{bf:{err:* Multiplicative Heteroscedasticity Model}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 scalar `llf'=e(ll)
 matrix `B'=e(b)
 matrix `Cov'= e(V)
 matrix `Beta'=`B'[1,1..`kb']'
 matrix `E'=`Y'-`Z'*`Beta'
 matrix `Sig2'=`E''*`E'/`DF'
 ereturn scalar df_m=$spat_kx
 predict double `Yh_ML' , xb
 mkmat `Yh_ML' , matrix(`Yh_ML')
 matrix `Ue_ML'= `Wi'*`Y'-`Yh_ML'
 local kBML: word count `xvar' `mhet'
 local kBML =`kBML'+2
 local Nof =`N'
 local Dof =`N'-`kBML'
 if "`noconstant'"!="" {
 local MYXvar "`WsY1' `xvar' `WsXi' `mhet' Sigu Sige"
 }
 else { 
 local MYXvar "`WsY1' `xvar' `WsXi' _cons `mhet' Sigu Sige"
 }
 tokenize `MYXvar'
 matrix colnames `Cov' = `*'
 matrix rownames `Cov' = `*'
 matrix colnames `B'   = `*'
 ereturn post `B' `Cov' , depname("`yvar'") obs(`Nof') dof(`Dof')
 matrix `B'=e(b)
 matrix `Cov' = e(V)
 matrix `B'=`B'[1,1..`kb']'
 matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 }
 }

 if inlist("`model'", "mstar", "mstard") {
 global spat_kx=`kx'
 ereturn scalar df_m=`kx'
 forvalue i=1/`kx' {
 local var : word `i' of `_Zo'
 local COLNAME "`COLNAME'`_Yo':`var' " 
 }
 if inlist("`model'", "mstar") {
 local usemstar "Lag"
 }
 if inlist("`model'", "mstard") {
 local usemstar "Durbin"
 global spat_kxw=2*$spat_kx
 }
 if inlist("`model'", "mstar", "mstard") & "`nwmat'"=="1" {
 if inlist("`model'", "mstar", "mstard") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "MSTAR1n"
 matrix `olsin'=`olsols',0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregxt01 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Normal Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR1e"
 matrix `olsin'=`olsols',0
 local initopt init(`olsin', copy)
 ml model lf spregxt02 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) (Rho1:) `wgt' , `cns' ///
 contin `mlopts' `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Exponential Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR1w"
 matrix `olsin'=`olsols',0,`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregxt03 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Weibull Model (1 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR1h"
 matrix `olsin'=`olsols',`olshet',0,`rmse'
 local initopt init(`olsin', copy)  
 ml model lf spregxt04 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho1:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression  (1 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Multiplicative Heteroscedasticity Model}}"
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
 matrix `olsin'=`olsols',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt05 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Normal Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR2e"
 matrix `olsin'=`olsols',0,0
 local initopt init(`olsin', copy)
 ml model lf spregxt06 (`_Yo': `_Yo' = `_Zo' , `noconstant') ///
 (Rho1:) (Rho2:) `wgt' , `cns' contin `mlopts' `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Exponential Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR2w"
 matrix `olsin'=`olsols',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt07 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Weibull Model (2 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR2h"
 matrix `olsin'=`olsols',`olshet',0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt08 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho1:_cons Rho2:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (2 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Multiplicative Heteroscedasticity Model}}"
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
 matrix `olsin'=`olsols',0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt09 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Normal Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR3e"
 matrix `olsin'=`olsols',0,0,0
 local initopt init(`olsin', copy)
 ml model lf spregxt10 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) `wgt' , `cns' contin `mlopts' `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Exponential Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR3w"
 matrix `olsin'=`olsols',0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt11 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Weibull Model (3 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR3h"
 matrix `olsin'=`olsols',`olshet',0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt12 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (3 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Multiplicative Heteroscedasticity Model}}"
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
 matrix `olsin'=`olsols',0,0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt13 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Normal Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "MSTAR4e"
 matrix `olsin'=`olsols',0,0,0,0
 local initopt init(`olsin', copy)
 ml model lf spregxt14 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) `wgt' , `cns' `robust' ///
 contin `mlopts' `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Exponential Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "MSTAR4w"
 matrix `olsin'=`olsols',0,0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt15 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `cns' `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Weibull Model (4 Weight Matrix)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "mstar", "mstard") & "`mhet'"!="" {
 local MName "MSTAR4h"
 matrix `olsin'=`olsols',`olshet',0,0,0,0,`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt16 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (4 Weight Matrix)}}"
noi di as txt "{bf:{err:* (m-STAR) Spatial {cmd:`usemstar'} Panel Multiplicative Heteroscedasticity Model}}"
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
 cap macro drop spat_*
 cap drop spat_*
 gen double spat_eigw= `eigw'
 global spat_kx=`kx'
 ereturn scalar df_m=`kx'
 global spat_kx : word count `_Zo'
 forvalue i=1/$spat_kx {
 local var : word `i' of `xvar'
 local MODEL "`MODEL'(`var':) "
 local spat_ARGS "`spat_ARGS' beta`i'" 
 }
 forvalue i=1/$spat_kx {
 local var : word `i' of `xvar'
 local COLNAME "`COLNAME'`_Yo':`var' " 
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
 matrix `olsin'=`olsols',`inlambda',`rmse'
 local initopt init(`olsin', copy)
 matrix spat_ols=`olsin'[1,1..$spat_kx+2]
 local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spregxt17 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Error Normal Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sem") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SEM1e"
 matrix `olsin'=`olsols',`inlambda'
 local initopt init(`olsin', copy)
 matrix spat_ols=`olsin'[1,1..$spat_kx+1]
 local MODEL "`MODEL'(_cons:) (Lambda:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda"
 ml model lf spregxt18 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Lambda:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Error Exponential Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sem") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SEM1w"
 matrix `olsin'=`olsols',`inlambda',`rmse'
 local initopt init(`olsin', copy)
 matrix spat_ols=`olsin'[1,1..$spat_kx+2]
 local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spregxt19 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Error Weibull Model (SEM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 }
 if inlist("`model'", "sar") {
 if inlist("`model'", "sar") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SAR1n"
 matrix `olsin'=`olsols',`inrho',`rmse'
 local initopt init(`olsin', copy)  
 ml model lf spregxt20 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize search(on) title(`MName') `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Lag Normal Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sar") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SAR1e"
 matrix `olsin'=0,`olsols'
 local initopt init(`olsin', copy)
 ml model lf spregxt21 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) (Rho:) `wgt' , `cns' ///
 contin `mlopts' `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Lag Exponential Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sar") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SAR1w"
 matrix `olsin'=`olsols',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt22 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Lag Weibull Model (SAR)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if "`model'"=="sar" & "`mhet'"!="" {
 local MName "SAR1h"
 matrix `olsin'=`olsols',`olshet',`inrho',`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spregxt23 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Lag Multiplicative Heteroscedasticity}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }
 if inlist("`model'", "sdm") {
 if inlist("`model'", "sdm") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SDM1n"
 matrix `olsin'=`olsols',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt24 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Durbin Normal Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sdm") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SDM1e"
 matrix `olsin'=`olsols',`inrho'
 local initopt init(`olsin', copy)
 ml model lf spregxt25 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho:) `wgt' , `cns' `mlopts' `nolog' `diparm' `initopt' maximize ///
 title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Durbin Exponential Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sdm") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SDM1w"
 matrix `olsin'=`olsols',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt26 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `cns' `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Durbin Weibull Model (SDM)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if "`model'"=="sdm" & "`mhet'"!="" {
 local MName "SDM1h"
 matrix `olsin'=`olsols',`olshet',`inrho',`rmse'
 local initopt init(`olsin', copy)
 ml model lf spregxt27 (`_Yo': `_Yo' = `_Zo' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `robust' ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons `mhet' Rho:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel Durbin Multiplicative Heteroscedasticity}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }
 if "`model'"=="sac" {
 if inlist("`model'", "sac") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
 local MName "SAC1n"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix `olsin'=`olsols',`inrho',`inlambda',`rmse'
 local initopt init(`olsin', copy)
 matrix spat_ols=`olsin'[1,1..$spat_kx+3]
 ml model lf spregxt28 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel AutoCorrelation Normal Model (SAC)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sac") & inlist("`dist'", "exp") & "`mhet'"=="" {
 local MName "SAC1e"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda"
 matrix `olsin'=`olsols',`inrho',`inlambda'
 local initopt init(`olsin', copy) 
 matrix spat_ols=`olsin'[1,1..$spat_kx+2]
 ml model lf spregxt29 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Lambda:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel AutoCorrelation Exponential Model (SAC)}}"
noi di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`model'", "sac") & inlist("`dist'", "weib") & "`mhet'"=="" {
 local MName "SAC1w"
 local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
 global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix `olsin'=`olsols',`inrho',`inlambda',`rmse'
 local initopt init(`olsin', copy)
 matrix spat_ols=`olsin'[1,1..$spat_kx+3]
 ml model lf spregxt30 `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on)
 local COLNAME " `COLNAME'`_Yo':_cons Rho:_cons Lambda:_cons Sigma:_cons"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* MLE Spatial Panel AutoCorrelation Weibull Model (SAC)}}"
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
 if inlist("`model'", "sar", "sdm", "sac", "mstar", "mstard") {
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
 if inlist("`model'", "ols", "sarxt", "sdmxt", "gwr") & inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 }
 if inlist("`model'", "ols", "sarxt", "sdmxt", "gwr") & !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 matrix `Yh_ML'=`Z'*`B'
 }
 tempvar E Yh
 ereturn scalar k_aux=2
 local N=_N
 local Zo "`Zo'"
 if "`noconstant'"!="" {
 local Zo ""
 }
 matrix `Ue_ML'=(`Y'-`Yh_ML')
 if inlist("`run'", "xtbem", "xtfem", "xtmle", "xtrem", "xtwem") {
 matrix `Xo'=J(`NT',1,1)
 matrix `D'=I(`NC')#`Xo'
 matrix `P'=`D'*invsym(`D''*`D')*`D''
 matrix `Q'=I(`N')-`P'
 matrix `Ue_ML'=`Q'*(`Y'-`Yh_ML')
 }
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')
 mkmat `Wi1' , matrix(`Wi1')
 matrix `Wi1' = diag(`Wi1')
 matrix `Ue_ML' = `Wi1'*(`Ue_ML')
 matrix `Yh_ML' = `Wi1'*(`Yh_ML')
 matrix `Ue_MLo' = (`Y'-`Z'*`B')
 matrix `Yh_MLo' = (`Z'*`B')
 if "`cross'"!="" {
 tempvar Yh E Ue_ML Yh_ML Ehat Yhat
 tab `idv'
 local C = r(r)
 local N = r(N)
 summ `idv'
 local cMin= r(min)
 local cMax= r(max)
 local cT = r(N) / `cMax'
 forvalues i = `cMin'/`cMax' {
 regress `_Yo' `_Zo' `wgts' if `idv' == `i' 
 predict double `Yhat'_`i' if `idv' == `i' , xb
 predict double `Ehat'_`i' if `idv' == `i' , resid
 }
 egen `Yh_MLo' = rowtotal(`Yhat'_*)
 egen `Ue_MLo' = rowtotal(`Ehat'_*)
 mkmat `Yh_MLo' , matrix(`Yh_MLo')
 mkmat `Ue_MLo' , matrix(`Ue_MLo')
 }
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 getmata `Yh_ML' , force replace
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Ue_ML' , force replace 
 mata: `Yh_MLo' = st_matrix("`Yh_MLo'")
 getmata `Yh_MLo' , force replace
 mata: `Ue_MLo' = st_matrix("`Ue_MLo'")
 getmata `Ue_MLo' , force replace
 matrix `U' =`Ue_MLo'
 if "`predict'"!="" | "`resid'"!="" {
 mata: `Yhxt'= st_matrix("`Yh_ML'")
 mata: `Uext'= st_matrix("`Ue_ML'")
 }
 matrix `vy1' =`Cov'[`dlag'..`dlag', `dlag'..`dlag']
 scalar `S2y'=`vy1'[1,1]
 matrix `SSE'=`U''*`U'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 scalar `Sigo'=sqrt(`Sig2o')
 if inlist("`run'", "xtfem") {
 correlate `Yh_MLo' `_Yo'
 }
 else {
 correlate `Yh_MLo' `_Yo' `wgt'
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
 scalar `r2raw'=1-`SSE1'/`SST21'
 scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`JDF')
 local fr=`r2raw'/(1-`r2raw')*(`N'-`Jkb')/`Jkb'
 local frp= Ftail(`kx', `DF', `fr')
 scalar `R20'=`r2bu'
 scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`Jkb')/`Jkx'
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 scalar `wald'=`f'*`Jkx'
 scalar `waldp'=chi2tail(`Jkx', abs(`wald'))
 if `llf' == . {
 scalar `llf'=-(`N'/2)*log(2*_pi*`Sig2n')-(`N'/2)
 }
 if "`wvar'"!="" | "`weights'"!="" {
 matrix `Ew'=`Wi'*(`Y'-`Z'*`B')
 matrix `SSEw'=(`Ew''*`Ew')
 scalar `SSEw1'=`SSEw'[1,1]
 scalar `Sig2wn'=`SSEw1'/`N'
 gen double `LWi2'= 0.5*ln(`Wi'^2)
 summ `LWi2'
 scalar `LWi21'=r(sum)
 scalar `llf'=-`N'/2*ln(2*_pi*`Sig2wn')+`LWi21'-(`N'/2)
 }
 local Nof =`N'
 local Dof =`JDF'
 matrix `B'=`B''
 local lyx ""
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") & inlist("`run'", "xtdhp") {
 local lyx "L1.`yvar' "
 }
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") & inlist("`run'", "xtabond", "xtdpdsys") {
 local abx = `lag'
 forvalues i = 1/`abx' {
 local lyx1 "L`i'.`yvar' "
 local lyx "`lyx' `lyx1'"
 }
 }
 tsunab _Xo: `lyx' `pre' `endog' `xvar' `lgmmiv' `aux'
 if inlist("`model'", "sarxt") {
 tsunab _Xo: `lyx' `pre' `WsY1' `endog' `xvar' `lgmmiv' `aux'
 local WsXi ""
 }
 if inlist("`model'", "sdmxt", "sdm") {
 tsunab _Xo: `lyx' `pre' `endog' `xvar' `WsXi' `lgmmiv' `aux'
 local WsY1 ""
 }
noi di as txt "{bf: `_Yo' = `_Xo'}"
noi di as txt "{hline 78}"
 if "`rest'"!="" {
noi di as err  "* Restrictions:"
noi constraint dir
noi di _dup(78) "-"
 }
 if !inlist("`run'", "xtmln", "xtmlh") {
 if "`noconstant'"!="" {
 matrix colnames `Cov' = `_Zo'
 matrix rownames `Cov' = `_Zo'
 matrix colnames `B'   = `_Zo'
 }
 else { 
 matrix colnames `Cov' = `_Zo' _cons
 matrix rownames `Cov' = `_Zo' _cons
 matrix colnames `B'   = `_Zo' _cons
 }
 }
 if "`wvar'"!="" | "`weights'"!="" {
noi di as txt "{bf: * " "`wtitle'" " *}"
noi di _dup(78) "-"
 }
 if "`ridge'"!="" {
noi di as txt "{bf: * Ridge k Value}" _col(21) "=" %10.5f `Kr' _col(37) "|" _col(41) "`rtitle'"
noi di _dup(78) "-"
 }
noi di as txt _col(2) "Sample Size" _col(21) "=" %12.0f `N' _col(37) "|" _col(41) "Cross Sections Number" _col(65) "=" _col(73) %5.0f `NCNo'
 if !inlist("`model'", "sem", "sar", "sdm", "sac", "mstar", "mstard") {
 if !inlist("`run'", "xtmln", "xtmlh", "xtdhp", "xtabond", "xtdpdsys") {
 ereturn post `B' `Cov' , depname("`yvar'") obs(`Nof') dof(`Dof')
 if !inlist("`model'", "ols") {
 test `_Zo'
 scalar `f'=r(F)
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 scalar `wald'=`f'*`Jkx'
 scalar `waldp'=chi2tail(`Jkx', abs(`wald'))
 }
 }
 }

 if (inlist("`model'","sar","sdm","mstar","mstard") | inlist("`run'","xtmln","xtmlh")) & "`robust'"!="" {
 scalar `wald'=`waldm'
 scalar `f'=`wald'/`Jkx'
 scalar `r2bu'=(`f'*`Jkx')/((`f'*`Jkx')+(`N'-`Jkx'))
 if `r2bu'< 0 {
 scalar `r2bu'=`r2h'
 }
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`JDF')
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 scalar `waldp'=chi2tail(`Jkx', abs(`wald'))
 }
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") & inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 test `lyx' `pre' `WsY1' `endog' `xvar' `WsXi' `lgmmiv' `aux'
 scalar `wald'=r(chi2)
 scalar `f'=`wald'/r(df)
 scalar `r2bu'=(`f'*r(df))/((`f'*r(df))+(`N'-r(df)))
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/(`N'-r(df)))
 scalar `fp'= Ftail(r(df), `JDF'-r(df), `f')
 scalar `waldp'=chi2tail(r(df), abs(`wald'))
 scalar `Sigo'=`sigox'
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
noi di as txt "- {cmd:R2h}=" %7.4f `r2h' _col(17) "{cmd:R2h Adj}=" %7.4f `r2h_a' _col(34) "{cmd:F-Test} =" %8.2f `fh' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `fhp'
noi di as txt "- {cmd:R2r}=" %7.4f `r2raw' _col(17) "{cmd:R2r Adj}=" %7.4f `r2raw_a' _col(34) "{cmd:F-Test} =" %8.2f `fr' _col(51) "P-Value > F(" `Jkb' " , " `JDF' ")" _col(72) %5.4f `frp'
 ereturn scalar r2raw =`r2raw'
 ereturn scalar r2raw_a=`r2raw_a'
 ereturn scalar llf =`llf'
 ereturn scalar sig=`Sigo'
 ereturn scalar r2h =`r2h'
 ereturn scalar r2h_a=`r2h_a'
 ereturn scalar fh =`fh'
 ereturn scalar fhp=`fhp'
 if inlist("`run'", "xtrc", "xthh") {
noi di _dup(78) "-"
noi di as txt "- Parameter Constancy Test LM Test" _col(37) "=" %10.4f `lmcons' _col(51) "P-Value > Chi2(`lmconsdf')" _col(72) %5.4f `lmconsp'
 }
 if inlist("`model'", "mstar", "mstard") {
noi di _dup(78) "-"
noi di as txt "{bf:- Sum of Rho's} = " %12.7f `Rostar' _col(34) "{bf:Rho's must be < 1 for Stability Condition}" 
 }
 matrix `B'=e(b)'
 ereturn matrix Bxx=`B'
 ereturn scalar DF=`DF'
 ereturn scalar JDF=`JDF'
 ereturn scalar Jkb=`Jkb'
 ereturn scalar Jkx=`Jkx'
 ereturn scalar kaux=`kaux'
 ereturn scalar kb=`kb'
 ereturn scalar kendog=`kendog'
 ereturn scalar kexog=`kexog'
 ereturn scalar kinst=`kinst'
 ereturn scalar kinstx=`kinstx'
 ereturn scalar kmhet=`kmhet'
 ereturn scalar Kr=`Kr'
 ereturn scalar kx=`kx'
 ereturn scalar llf=`llf'
 ereturn scalar R20=`R20'
 ereturn scalar S2y=`S2y'
 ereturn scalar Sig2n=`Sig2n'
 ereturn scalar Sig2o=`Sig2o'
 ereturn scalar SSEo=`SSEo'
 if inlist("`model'", "sar", "sem", "sdm", "sac") {
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
 if !inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") & !inlist("`run'", "xtmln", "xtmlh"){
noi ereturn display , `level'
 }
 if inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") | inlist("`run'", "xtmln", "xtmlh") {
noi spregxt36 , `level' `robust'
 }
 if inlist("`model'", "ols", "gwr", "sarxt", "sdmxt") & inlist("`run'", "xtmln", "xtmlh"){
noi ereturn display , `level'
 }
 if "`hausman'"!= "" {
 matrix biv2=e(b)
 matrix viv2=e(V)
 }
 matrix `b'=e(b)
 matrix `V'=e(V)
 matrix `Bx' =`b'[1..1, 1..`kx']'

 if inlist("`model'", "gs2sls", "gs2slsar") {
noi di as txt "{bf:* Y  = LHS Dependent Variable:}" _col(33) " " 1 " = " "`_Yo'"
noi di as txt "{bf:* Yi = RHS Endogenous Variables:}"_col(33) " " `kendog' " = " "`WsYi'"
noi di as txt "{bf:* Xi = RHS Exogenous Vars:}"_col(33) " " `kexog' " = " "`xvar' `aux'"
noi di as txt "{bf:* Z  = Overall Instrumental Variables:}"
noi di as txt "   " `kinstx' " : " "`instx'"
 }
 if inlist("`model'", "sarxt") & !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys", "xtmln", "xtmlh") {
 test _b[w1y_`yvar'] =0
 scalar `rRo'=_b[w1y_`yvar']
 scalar `fgs2s'=r(F)
 scalar `rdfgs'=r(df)
 scalar `rdfgsr'=r(df_r)
 scalar `fgs2sp'=r(p)
noi di as txt _col(3) "Rho Value  =" %8.4f `rRo' _col(29) "F Test =" %10.3f `fgs2s' as txt _col(50) "P-Value > F(" `rdfgs' ", " `rdfgsr' ")" _col(73) %5.4f `fgs2sp'
noi di _dup(78) "-"
 }
 if inlist("`model'", "sarxt") & inlist("`run'", "xtdhp", "xtabond", "xtdpdsys", "xtmln", "xtmlh") {
 test _b[w1y_`yvar'] =0
 scalar `rRo'=_b[w1y_`yvar']
 scalar `fgs2s'=r(chi2)
 scalar `rdfgs'=r(df)
 scalar `fgs2sp'=r(p)
noi di as txt _col(3) "Rho Value  =" %8.4f `rRo' _col(30) "Chi2 Test =" %10.3f `fgs2s' as txt _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `fgs2sp'
noi di _dup(78) "-"
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
noi di as txt "{bf:{err:* Over Identification Restrictions Test}}"
noi di as txt _col(3) "{bf:Ho: Over Identification Restrictions are Valid}"
noi di as txt "- Sargan Over Identification LM Test   =" _col(37) %10.3f `lmiab' _col(54) "P-Value > Chi2(" `dfab' ")" _col(73) %5.4f `lmiabp'
noi di _dup(78) "-"
 }
 if inlist("`model'", "gs2sls", "gs2slsar") {
noi di _dup(78) "-"
noi di as txt _col(3) "Rho Value  =" %8.4f `rRo' _col(29) "F Test =" %10.3f `fgs2s' as txt _col(50) "P-Value > F(" `rdfgs' ", " `rdfgsr' ")" _col(73) %5.4f `fgs2sp'
noi di _dup(78) "-"
 }

 local usetext `lmspac' `diag' `lmauto' `lmhet' `lmnorm' `lmec' `lmunit' ///
 `reset' `lmform' `lmcl' `hausman' `lmiden' `tests'
 if "`model'"!="" & "`usetext'"!="" {
 ereturn matrix WCS= `WCS' , copy
 if "`lmspac'"!= "" {
 ereturn matrix Bx_SP= `Bx_SP'
 ereturn matrix ZwSP=`ZwSP'
 ereturn matrix YwSP=`YwSP'
 ereturn scalar Sig2SP=`Sig2SP'
 ereturn scalar SSESP=`SSESP'
 }
 local auxn "aux(`aux')"
 local dlagn "dlag(`dlag')"
 local ehatn "ehat(`Ue_ML')"
 local ehaton "ehato(`Ue_MLo')"
 local endogn "endog(`endog')"
 local exogn "exog(`exog')"
 local idvn "idv(`idv')"
 local instn "inst(`inst')"
 local instxn "instx(`instx')"
 local itern "iter(`iter')"
 local itvn "itv(`itv')"
 local lagn "lag(`lag')"
 local leveln "level(`level')"
 local lln "ll(`ll')"
 local modeln "model(`model')"
 local nwmatn "nwmat(`nwmat')"
 local ordern "order(`order')"
 local runn "run(`run')"
 local techn "tech(`tech')"
 local wsyin "wsyi(`WsYi')"
 local wsxin "wsxi(`WsXi')"
 local yhatn "yhat(`Yh_ML')"
 local yhaton "yhato(`Yh_MLo')"
 local yvarexpn "yvarexp(`yvarexp')"
 local spxvn "spxv(`pre' `endog' `xvar' `lgmmiv' `aux')"
noi spregxt37 `_Yo' `_Zo' , `idvn' `itvn' `auxn' `be' `diag' `dn' `inv' `inv2' ///
 `ehatn' `ehaton' `endogn' `exogn' `fe' `hausman' `instn' `instxn' `itern' `mle' ///
 `lagn' `leveln' `lln' `lmauto' `lmcl' `lmec' `lmform' `lmhet' `lmiden' ///
 `lmnorm' `lmspac' `lmunit' `spxvn' `modeln' `noconstant' `nolog' `nosa' `stand' ///
 `nwmatn' `ordern' `re' `reset' `runn' `techn' `tests' `tobit' `tolog' `ec2sls' ///
 `wvarn' `wsyin' `wsxin' `yhatn' `yhaton' `yvarexpn'
 }

 if "`model'"!="" & inlist("`mfx'", "lin", "log") {
 tempname XMB XYMB YMB YMB1 SumW TRW TRWS TRWS1 NSumW NTRWS InDirect Direct Total BsZ
 tempname spmfxb spmfxe InDirectES DirectES TotalES Betaes mfxb mfxe mfxlin mfxlog MVx
 tempname mfxb1 XMB XYMB YMB YMB1 XMB1 XMB2 _Yoz _Zoz
noi di 
noi di _dup(78) "{bf:{err:=}}"
 tempvar ZSLS 
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
 }
 if inlist("`mfx'", "log") {
 mata: `XYMB'=Y:/X
 }
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 if inlist("`model'", "sar", "sdm", "sac", "mstar", "mstard") {
 mata: `SumW' = st_matrix("`IRW'")
 mata: `SumW'= sum(`SumW')
 mata: st_numscalar("`SumW'", `SumW') 
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
 matrix rownames `spmfxb'= `_Zo'
 matrix rownames `spmfxe'= `_Zo'
 if inlist("`mfx'", "lin") {
 matrix colnames `spmfxb'= Beta(B) Total Direct InDirect Mean
 matrix colnames `spmfxe'= Beta(Es) Total Direct InDirect Mean
noi matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
noi matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
 }
 if inlist("`mfx'", "log") {
 matrix colnames `spmfxb'= Beta(Es) Total Direct InDirect Mean
 matrix colnames `spmfxe'= Beta(B) Total Direct InDirect Mean
noi matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
noi matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1'
noi di
 if "`pmfx'"!="" {
 matrix `MVx'=`V'[1..`kx', 1..`kx']
 ereturn matrix MVx=`MVx'
 ereturn matrix MBx1 =`Total'
 ereturn matrix MBx2 =`Direct'
 ereturn matrix MBx3 =`InDirect'
noi _SPMFX , nof(`Nof') dof(`Dof') level(`level')
 }
 }
 if !inlist("`model'", "sar", "sdm", "sac", "mstar", "mstard") {
 if !inlist("`model'","sdmxt") {
 local WsXi ""
 }
 if inlist("`model'","sem") {
 local WsY1 ""
 }
 if inlist("`mfx'", "lin") {
 matrix `mfxb' =`Bx'
 matrix `mfxe'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlin' =`mfxb',`mfxe',`BsZ',`XMB'
 matrix rownames `mfxlin' = `lyx' `pre' `WsY1' `endog' `xvar' `WsXi' `lgmmiv' `aux'
 matrix colnames `mfxlin' = Margin Elasticity St_Beta Mean
noi matlist `mfxlin' , title({bf:* {err:Marginal Effect - Elasticity - Standardized Beta} {bf:(Model= {err:`model'})}: {err:Linear} *}) twidth(14) border(all) lines(columns) rowtitle(Variable) format(%12.4f)
 }
 if inlist("`mfx'", "log") {
 matrix `mfxe'=`Bx'
 matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlog' =`mfxe',`mfxb',`BsZ',`XMB'
 matrix rownames `mfxlog' = `lyx' `pre' `WsY1' `endog' `xvar' `WsXi' `lgmmiv' `aux'
 matrix colnames `mfxlog' = Elasticity Margin St_Beta Mean
noi matlist `mfxlog' , title({bf:* {err:Elasticity - Marginal Effect - Standardized Beta} {bf:(Model= {err:`model'})}: {err:Log-Log} *}) twidth(14) border(all) lines(columns) rowtitle(Variable) format(%12.4f)
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1'
 }
 }

 restore
 local RUN ""
 if "`run'"!="" {
 local RUN "_`run'"
 }
 if "`predict'"!="" {
 getmata `predict'=`Yhxt' , force replace
 label variable `predict' `"Yh_`model'`RUN' - Prediction"'
 }
 if "`resid'"!="" {
 getmata `resid'=`Uext' , force replace
 label variable `resid' `"U_`model'`RUN' - Residual"'
 }
 if inlist("`run'", "xtfrontier") & "`te'"!= "" {
 cap getmata _TE , force replace
 cap getmata _TE_e , force replace
 cap getmata _TE_m , force replace
 cap getmata _TE_l , force replace
 cap getmata _TE_u , force replace
 cap label variable _TE `"* Technical Efficiency E{exp(-su)|e}"'
 cap label variable _TE_e `"* Minus Log TE E(u|e)"'
 cap label variable _TE_m `"* Minus Log TE M(u|e)"'
 cap label variable _TE_l `"* Lower Bound Technical Efficiency"'
 cap label variable _TE_u `"* Upper Bound Technical Efficiency"'
 }
 if "`list'"!= "" {
 _SPList , model(`model') knw(`knw') yvar(`yvar') xvar(`xvar') order(`order')  
 }
 if !inlist("`model'", "mstar", "mstard") & "`nwmat'"=="" {
 cap matrix drop _all
 cap drop spat_*
 }
 if inlist("`model'", "mstar", "mstard") {
 cap matrix drop eVec
 }
 cap mata: mata clear
 cap mata: mata drop *
 ereturn local cmd "spregxt"
 }
 }
 end

 program define _SPsyntax , sclass
 syntax [, coll igls nmk hetonly cost list nosa te pmfx mle] 
 end

 program define _SPMFX , eclass
 syntax , nof(str) dof(str) [level(str)]
 tempname MBx1 MBx2 MBx3 MVx1 MVx2 MVx3
 local SPT1 "*** (1) Total Marginal Effect ***"
 local SPT2 "*** (2) Direct Marginal Effect ***"
 local SPT3 "*** (3) InDirect Marginal Effect ***"
 local SPD1 "Total"
 local SPD2 "Direct"
 local SPD3 "InDirect"
 forvalue i=1/3 {
 matrix `MVx`i''=e(MVx)
 matrix `MBx`i''=e(MBx`i')'
 }
noi di _dup(78) "-"
noi di as txt "{bf:{err:*** P-Value: Total, Direct, and InDirect Marginal Effect ***}}"
noi di _dup(78) "-"
 forvalue i=1/3 {
noi di
noi di as txt "{bf:{err:`SPT`i''}}"
 ereturn post `MBx`i'' `MVx`i'' , depname("`SPD`i''") obs(`nof') dof(`dof')
noi ereturn display , `level'
 }
 end

 program define _SPRidge , eclass
 version 11.2
 syntax varlist , kx(str) kb(str) nt(str) df(str) RIDge(str) ///
 [ dn KR(str) iter(str) NOCONStant aux(str) wvar(str)]
 qui {
 tempvar X0 Zo SLSVar WLSVar VaL1 LVR Lms lf Wi WiB
 tempname sqN WMTD Beta BOLS BOLS1 Sig2o Sig2o1 Ko rid Zz CovC RY RX Vec VaL Zr Yws Zws VaLv1
 tempname Kr sd VaL1 VaL21 Go GoRY SSE Sig2 Qr LVR f1 SLS f13 f13d Rmk IDRmk Lms lf F Kk Koi
 preserve
 gettoken _Yo _Zo : varlist
 scalar `Kr' =`kr'
 local kx =`kx'
 local kb =`kb'
 local N =`nt'
 local DF =`df'
 local Ro1= 0
 gen `X0' = 1
 gen double `Wi'=`wvar'
 gen double `Zo'= `X0'
 if "`wvar'"!="" {
 local Yw_Zw "`X0' `_Yo' `_Zo'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v: word `i' of `Yw_Zw'
 replace `v' = `v'*`Wi'
 }
 }
 local _Yw "`_Yo'"
 local _Zw : list _Zo-aux
 summ `Wi' 
 gen double `WiB' =r(mean)
 replace `Zo' = `WiB'
 local Zo_Zw "`Zo' `_Zw'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v'  - r(mean)
 }
 }
 unab ZSLSVar : `SLSVar'_* `aux' 
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 replace `ZoC' = 0
 local _Zw "`_Zw' `aux'"
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
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
 if (`Koi' <= 0.00001) {
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
cap matrix `IDRmk'=invsym(`f13')
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
 if (`Koi' <= 0.00001) {
 continue, break
 }
 }
 }
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 ereturn scalar Kr=`Kr'
 ereturn matrix Zz=`Zz'
 restore
 }
 end

 program define _SPList , eclass
 version 11.2
 syntax , model(str) knw(str) xvar(str) yvar(str) order(str)
 qui {
 if inlist("`model'", "gwr", "sarxt", "sar", "sac", "sdm", "sem", "gs2sls", "gs2slsar") {
 getmata w1y_`yvar' , force replace
 label variable w1y_`yvar' `"AR(1) `yvar' Spatial Lag"'
 }
 if inlist("`model'", "sac") {
 getmata w2y_`yvar' , force replace
 label variable w2y_`yvar' `"AR(2) `yvar' Spatial Lag"'
 }
 if inlist("`model'", "mstar", "mstard") {
 forvalue i=1/`knw' {
 getmata w`i'y_`yvar' , force replace
 label variable w`i'y_`yvar' `"AR(`i') `yvar' Spatial Lag"'
 order w`i'y_* , last
 }
 }
 if inlist("`model'", "sdm", "sdmxt", "mstard", "sac", "sem", "gwr") {
 forvalue i=1/`knw' {
 foreach var of local xvar {
 getmata w`i'x_`var' , force replace
 label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 order w`i'x_* , last
 }
 }
 }
 if inlist("`model'", "gs2sls", "gs2slsar") {
 forvalue i = 1/`order' {
 foreach var of local xvar {
 getmata w`i'x_`var' , force replace
 label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 order w`i'x_* , last
 }
 }
 }
 }
 end

