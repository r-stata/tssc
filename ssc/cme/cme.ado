*! version 1.0.3  31Aug2003
program define cme, eclass
    version 8.0

    if replay() {
        if "`e(cmd)'" != "cme" {
            error 301
        }
        Replay `0'
        exit _rc
    }
    capture noisily Estimate `0'
    exit _rc
end

program define Estimate, eclass
    version 8.0
    syntax anything(id="varlist etc.") [fweight pweight] [if] [in], [ noCOnstant   /*
    */ Family(string) DEnom(varname numeric min=1) Link(string)                    /*
    */ Offset(varname numeric) TCovmod(varlist numeric) SImple                     /*
    */ NIp(passthru) noADapt FRom(passthru) ROBust CLuster(varname numeric)        /*
    */ DOts noLOg noDISplay TRace EVal Level(passthru) EFORM ADOONLY               /*
    */ MEVar(numlist min=1 max=1) COMmands INDirect TOTal]

    * get dependent and independent vars before (lab:var1 var2 ...)
    gettoken 0 coverr:anything, parse("(")
    syntax [varlist(min=1)]
    gettoken depvar indeps:varlist  /* first variable (token) is depvar */

    *local gindeps `indeps'
    if "`simple'"~=""{
        local gindeps
    }
    else{
        if "`tcovmod'"~=""{
            local gindeps `tcovmod'
        }
        else{
            local gindeps `indeps'
        }
    }
    local numg: word count `gindeps'
    * disp in re "Covariates for true covariate: `gindeps'"

    * interpret (lab:var1 var2 ...)
    gettoken lab 0:coverr, parse(":")     /* "(lab" into lab and ":var1 var2 ...)" into 0 */
    local lab: subinstr local lab "(" ""  /* remove "(" from lab */
    local 0: subinstr local 0 ")" ""      /* remove ")" from 0 */
    local 0: subinstr local 0 ":" ""      /* remove ":" from 0 */

    marksample touse
    markout `touse' `cluster' `denom' `offset' `gindeps'


    * define replics as var1 var 2... 
    syntax [varlist(min=1)]
    local replics "`varlist'"


    *disp in re "regressio model `depvar' `indeps' `lab'"
    *disp in re "replicate measurements of `lab': `replics'"

    /* check link and family to avoid trouble with mixed responses in gllamm */
    lnkfm "`link'" "`family'"
    local link1 = "$S_1"
    local fami1 = "$S_2"

    if "`fami1'"=="gauss"|"`fami1'"=="gamma"{
        local varpar = 1
    }
    else{
        local varpar = 0
    }

    preserve
    qui keep if `touse'
    *disp in re _N


    if "`commands'"~=""{
        disp
        noi disp "------------------------------ begin do-file ------------------------------"
    }

    * deal with number of replicates and mevar
    local num: word count `replics'
    if `num' < 2{
        if "`mevar'"==""{
            disp in re "More than one replicate measurement required"
            disp in re "to estimate the measurement error variance"
            exit 198
        }
    }

    if "`mevar'"~=""{
        tempname melns1 
        if `mevar'< 0{
            disp in re "Negative measurement error variance not allowed"
            exit 198
        }
        else if `mevar'< 0.0000001{
            disp in re "Cannot estimate the model with zero measurement error variance" 
            disp in re "use glm"
            exit 198
        }
        else{
            scalar `melns1'= ln(`mevar')/2
        }
    }

    /* sort out constant and offset */

    if "`constant'"==""{
        local numc = 1
    }
    else{
        local numc = 0
    }
    if "`link1'"=="ologit"|"`link1'"=="oprobit"|"`link1'"=="ocll"{
        quietly tab `depvar'
        local numc = r(r)-1
        local nocons    
    }
    else{
        local nocons nocons
    }

    local add
    if "`offset'"~=""{
        local add "offset(`offset')"
    }

    /* initial values */
    if "`from'"==""{
        tempname mat initp matg
        local reliab = 0.7

        tempvar junk
        egen `junk' = rmean(`replics')
        qui reg `junk' `gindeps'
        matrix `matg' = e(b)
        
        local mn = `matg'[1,`numg'+1]          /* true covariate mean or cons. */
        if `numg'>0{
            matrix `matg' = `matg'[1,1..`numg']
        }
        local sdr = `e(rmse)'*sqrt(`reliab'*`num') /* true covariate variance */
        if "`mevar'"==""{
            tempname melns1
            scalar `melns1'= ln(`e(rmse)'*sqrt( (1-`reliab')*`num'))
        }

        if substr("`link1'",1,1)~="o"{
            * disp in re "glm `depvar' `indeps' `junk', link(`link1')  fam(`fami1') `constant' "
            qui glm `depvar' `indeps' `junk', link(`link1')  fam(`fami1') `constant' `add'
        }
        else{  /* ordinal links */
            if "`link1'"=="ologit"|"`link1'"=="oprobit"{
                qui `link1' `depvar' `indeps' `junk' `add'
            }
            else { /* ocll */
                qui ologit `depvar' `indeps' `junk' `add'
            }
        }
        *set trace on
        matrix `mat' = e(b)
        local nc= colsof(`mat')

        local ncm2 = `nc' - 1 - `numc'  /* position  of last indepvar */
        local ncm1 = `nc' - `numc'      /* position of cov. effect   */
        if `ncm2'>0 {
            matrix `initp' = `mat'[1,1..`ncm2']   /* betas in outcome model */
        }
        if `numc'>0{
            local ncm1p1 = `ncm1' + 1
            matrix `initp' = nullmat(`initp'), `mat'[1,`ncm1p1'..`nc']  /* beta_0, or _cut */
        } 
        if `varpar'{
            matrix `initp' = nullmat(`initp'),ln(e(phi))/2              /* phi */
        }
        matrix `initp' = nullmat(`initp'), `melns1', `mat'[1,`ncm1'], `sdr' /* sigma, lambda */
        if `numg'>0{
            matrix `initp' = `initp',`matg'  /* gamma */
        }
        matrix `initp' = nullmat(`initp') , `mn'      /* gamma_0 */

        * matrix list `initp'
        local frm "from(`initp')"
        local copy copy
        if "`commands'"~=""{
            noi disp
            noi disp "* starting values"
            local nc = colsof(`initp')
            local ncm1 = `nc' - 1
            local matexp "matrix startv = ("
            forvalues is = 1/ `ncm1'{
                local junk = string(`initp'[1,`is'],"%9.4g")
                local matexp "`matexp' `junk',"
            }
            local junk = string(`initp'[1,`nc'],"%9.4g")
            local matexp "`matexp' `junk')"
            noi disp "`matexp'"
            noi disp "gen _id = _n"
            local cmfrm "from(startv)"
        }
    }
    else{
        local frm "`from'"
        local cmfrm "`from'"
        local copy copy
    }
    * disp in re "cmfrm = `cmfrm'"


    /* prepare data */
    tempvar id var v d1 dmeas 
    *qui gen `id' = _n
    reshlong `depvar' `replics', oth(`indeps' `cluster' `offset' `denom' `gindeps') i(`id') /*
      */ j(`var') r(`v') wt(__blaay2) `commands'

    local glweight
    local cmglwei
    if "`weight'"=="fweight" {
        if "`commands'"~=""{
            noi disp
            noi disp "* deal with frequency weights"
            noi disp "gen _junk `exp'"
            noi disp "replace _wt2 = _wt2*_junk"
            noi disp "drop junk"
        }
        tempvar wt
        qui gen long `wt' `exp'
        qui replace __blaay2 = __blaay2*`wt'
    }
    else if  "`weight'"=="pweight" {
        if "`commands'"~=""{
            noi disp
            noi disp "* deal with probability weights"
            noi disp "gen _pwt2 `exp'"
            local cmglwei "pweight(_pwt)"
        }
        qui gen double __blaby2 `exp' 
        local glweight "pweight(__blaby)"
    }
    local glweight "`glweight' weightf(__blaay)"
    local cmglwei "`cmglwe' weightf(_wt)"

    if "`commands'"~=""{
        noi disp
        noi disp "* create dummy variables and interactions"
        noi disp "gen byte cons = 1"
        noi disp "gen byte _d1 = _var == 1"
        noi disp "gen byte _dmeas = 1-_d1"
        noi disp "gen _type = _d1 + 2*_dmeas /* response type */
    }
    

    qui gen byte `d1' = `var'==1
    qui gen byte `dmeas' = 1-`d1'  /* dummy for replicate measurements */
    qui replace `var' = `d1' + 2*`dmeas'

    if `numg'>0{
        local gind
        foreach x of varlist `gindeps'{
            qui gen `x'_ = `x'
            local gind "`gind' `x'_"
        }
    }
    if "`indeps'"~=""{
        foreach x of varlist `indeps'{
            qui replace `x' = `x'*`d1'
            local cmindeps
            if "`commands'"~=""{
                noi disp "gen _`x'_d1 = `x'*_d1"
                local cmindeps "`cmindeps' _`x'_d1"
            }
        }
    }
    else{
        local cmindeps
    }
    if "`offset'"~=""{
        qui replace `offset' = `offset'*`d1'
        if "`commands'"~=""{
            noi disp "gen _`offset'_d1 = `offset'*_d1"
            local cmoffset "offset(_`offset'_d1)"
        }
        local offset "offset(`offset')"
    }
    rename `v' `depvar'

    if "`constant'"==""&substr("`link1'",1,1)~="o"{
        local discons "`d1'"
        local cmdisc "_d1"
    }
    else{
        local discons
        local cmdisc
    }
    if "`adapt'"==""{
        local adapt adapt
    }
    else{
        local adapt
    }
    if "`cluster'"~=""{
        local clustvar "`cluster'"
        local cluster "cluster(`cluster')"
    }
    else{
        local cluster
    }
    if "`denom'"~=""{
        local denom "denom(`denom')"
    }

    local het
    if `varpar'{
        eq het: `d1' `dmeas'
        local het "s(het)"
    }

    if "`mevar'"~=""{
        if `varpar'{
            constraint define 1 [lns1]`dmeas' = `melns1'
        }
        else{
            constraint define 1 [lns1]_cons = `melns1'
        }
        local constr constr(1) long
    }
    else{
        local constr
    }

    local geqs

    tempvar cons
    gen byte `cons' = 1
    eq f1: `gind' `cons'
    local geqs "geqs(f1)"


    if "`commands'"~=""{
        noi disp 
        noi disp "* define equations"
        noi disp "eq load: _dmeas _d1"
        noi disp "eq f1: `gindeps' cons"
        if `varpar'{
            noi disp "eq het: _d1 _dmeas"
        }
        if "`mevar'"~=""{
            noi disp " "
            noi disp "* constraint for measurement error variance"
            if `varpar'{
                noi disp "constraint define 1 [lns1]_dmeas =" `melns1'
            }
            else{
                noi disp "constraint define 1 [lns1]_cons =" `melns1'
            }
        }

        noi disp " "
        noi disp "* call gllamm"
        noi disp "gllamm _r `cmindeps' `cmdisc', /* "
        noi disp " */ i(_id) `nocons' eqs(load) link(`link1' ident) family(`fami1' gauss) /*"
        noi disp " */ lv(_type) fv(_type) `het' `geqs' `denom' `cmfrm' `copy' `adapt'  /*"
        noi disp " */ `cmglwei' `nip' `cmoffset' `robust' `cluster' `constr' `trace' `dots' `log' "
        noi disp
        noi disp "------------------------------- end do-file ------------------------------"
        restore
        exit 0
    }

    /* call gllamm */
    eq load: `dmeas' `d1'

    local nodis
    if "`trace'"==""{
        local nodis nodisplay
    }
    else{
        disp in gre "calling gllamm:"
        disp " "
    }


    gllamm `depvar' `indeps' `discons', i(`id') `nocons'  eqs(load) link(`link1' ident) /*
      */ family(`fami1' gauss) lv(`var') fv(`var') `het' `geqs' `denom' `frm' `copy' `adapt'   /* 
      */ `glweight' `nip' `nolog' `offset' `robust' `cluster' `constr' `nodis' `trace' `dots' `log'
    tempname b V m
    matrix `b'=e(b)
    matrix `V'=e(V)

    /* rearrange parameters */
    local nzs: word count `indeps'
    local numpar = `nzs'+`numc'+`varpar'+3+`numg'+1
    matrix `m' = I(`numpar')
    * shift factor loading into first position after last beta
    matrix `m'[`nzs'+`numc'+`varpar'+2,`nzs'+`numc'+`varpar'+2]=0
    matrix `m'[`nzs'+`numc'+`varpar'+2,`nzs'+1]=1
    * shift all parameters up to "`nzs'+`numc'+`varpar'+1" one to the right 
    local first = `nzs'+1
    local last = `nzs'+`numc'+`varpar'+1
    forvalues i=`first' / `last'{
        matrix `m'[`i',`i'] = 0
        matrix `m'[`i',`i'+1] = 1
    }

    * matrix list `b'
    * matrix list `m'

    matrix `V' = `m''*`V'*`m'
    matrix `b' =  `b'*`m'

    * matrix list `b'

    /* define column names */
    local coln "`indeps' `lab' _cons _cons _cons"  /* beta, lambda, sigma, tau, gamma1*/
    local numcp = `numc'+`varpar'
    forval i = 1/ `numcp' {
        local coln "`coln' _cons"              /* constants */
    }
    forval i=1/ `numg' {
        local coln "`coln' _cons"              /* gamma */
    }

    /* define equation names */
    local coleq "`depvar'"
    local last = `nzs'+1
    forvalues i = 2/ `last' {
        local coleq "`coleq' `depvar'"
    }
    if substr("`link1'",1,1)~="o"{
        if `numc'==1{
            local coleq "`coleq' `depvar'"
        }
    }
    else{
        forval i = 1/ `numc' {
            local coleq "`coleq' _cut`i'"
        }
    }
    if `varpar'{
        local coleq "`coleq' _lnphi2"
    }

    local coleq "`coleq' lns1 sdT"
    if `numg'>0{
        foreach x in `gindeps' {
            local coleq "`coleq' `x'"
        }
    }
    local coleq "`coleq' gamma0"
    matrix colnames `b'=`coln'
    matrix coleq `b'=`coleq'
    * matrix list `b'

    restore
    ereturn repost b=`b' V=`V', rename esample(`touse')
    tempname M_nu
    matrix `M_nu' = e(nu)
    ereturn local N = `M_nu'[1,2]
    if "`mevar'"~="" {
        ereturn scalar mevar = `mevar'
    }
    ereturn local lab `lab'
    if "`robust'"~=""{
        ereturn local vcetype "Robust"
    }
    if "`cluster'"~=""{
        ereturn local clustvar "`clustvar'"
    }
    ereturn local gindeps "`gindeps'"
    ereturn local cmd "cme"
    if substr("`link1'",1,1)=="o"{
        ereturn local k_cat = `numc'+1
    }
    if `varpar'{
        ereturn local phi = exp(2*[_lnphi2]_cons)
    }
    Replay, `level' `eform' `indirect' `total'
    
end

capture program drop reshlong
program define reshlong
    version 7.0
    syntax varlist(min=1), I(string) J(string) R(string) wt(string) [ OTH(varlist) D(string) names COMMANDS ]

    confirm var `varlist' `oth'
    confirm new var `i'
    confirm new var `j'
    confirm new var `r'
    if "`d'"==""{
        local d i
    }   
    tempvar jvstr cons  
    if "`commands'"~=""{
        noi disp
        noi disp "* collapse data to make gllamm faster"
        noi disp "gen _one = 1"
        noi disp "collapse (sum) _wt2 = _one, by(`varlist' `oth')"
        noi disp "gen _id = _n"
        noi disp
        noi disp "* give response variable and replicate measurements same prefix"
    }

    qui gen `cons' = 1
    qui collapse (sum)  `wt'=`cons', by(`varlist' `oth')
    gen `i' = _n
    local ii = 1
    foreach v of var `varlist' {
        qui rename `v' `r'`ii'
        if "`commands'"~=""{
            noi disp "rename `v' _r`ii'"
        }
        local ii = `ii' + 1
    }
    if "`commands'"~=""{
        noi disp
        noi disp "* reshape data to long"
        noi disp "reshape long _r, i(_id) j(_var)"
    }
    qui reshape long `r', i(`i') j(`j') 
end

program define lnkfm
    version 6.0
    args link fam

    global S_1  /* link     */
    global S_2  /* family   */


    lnk "`1'"
    fm "`2'"    

    if "$S_1" == "" {
        if "$S_2" == "gauss" { global S_1 "ident" }
        if "$S_2" == "poiss" { global S_1 "log"   }
        if "$S_2" == "binom" { global S_1 "logit" }
        if "$S_2" == "gamma" { global S_1 "recip" }
    }

/*
    if ("$S_1"=="mlogit"|"$S_1"=="smlogit")&"$S_2"~="binom"{
        disp in red "mlogit link must be combined with binomial probability"
        exit 198
    }
*/
    if ("$S_1"=="mlogit"|"$S_1"=="smlogit"|"$S_1"=="ologit"|"$S_1"=="oprobit"|"$S_1"=="soprobit"|"$S_1"=="ocll"){
        global S_2
    }
end

program define fm
    version 6.0
    args fam
    local f = lower(trim("`fam'"))
   local l = length("`f'")

    if "`f'" == substr("gaussian",1,max(`l',3)) { global S_2 "gauss" }
    else if "`f'" == substr("normal",1,max(`l',3))   { global S_2 "gauss" }
    else if "`f'" == substr("poisson",1,max(`l',3))  { global S_2 "poiss" }
    else if "`f'" == substr("binomial",1,max(`l',3)) { global S_2 "binom" }
    else if "`f'" == substr("gamma",1,max(`l',3))    { global S_2 "gamma" }
    else if "`f'" != "" {
        noi di in red "unknown family() `fam'"
        exit 198
    }

    if "$S_2" == "" {
        global S_2 "gauss"
    }
end

program define lnk
    version 6.0
    args link
    local f = lower(trim("`link'"))
    local l = length("`f'")

    if "`f'" == substr("identity",1,max(`l',2)) { global S_1 "ident" }
    else if "`f'" == substr("log",1,max(`l',3))      { global S_1 "log"   }
    else if "`f'" == substr("logit",1,max(`l',4))    { global S_1 "logit" }
    else if "`f'" == substr("mlogit",1,max(`l',3))    { global S_1 "mlogit" }
    else if "`f'" == substr("smlogit",1,max(`l',3))    { global S_1 "smlogit" }
    else if "`f'" == substr("ologit",1,max(`l',3))    { global S_1 "ologit" }
    else if "`f'" == substr("oprobit",1,max(`l',3))    { global S_1 "oprobit" }
    else if "`f'" == substr("probit",1,max(`l',3))   { global S_1 "probit"}
    else if "`f'" == substr("ocll",1,max(`l',3))   { global S_1 "ocll"}
    else if "`f'" == substr("cll",1,max(`l',3))   { global S_1 "cll"}
    else if "`f'" == substr("ll",1,max(`l',2))   { global S_1 "ll"}
    else if "`f'" == substr("sprobit",1,max(`l',3))   { global S_1 "sprobit"}
        else if "`f'" == substr("soprobit",1,max(`l',3))   { global S_1 "soprobit"}
    else if "`f'"==substr("reciprocal",1,max(`l',3)) { global S_1 "recip" }
    else if "`f'" != "" {
        noi di in red "unknown link() `link'"
        exit 198
    }
end

program define Replay, eclass
    version 8.0
    syntax [, Level(int $S_level) EFORM DOTS INDirect TOTal]
    tempname M_nffc  Vs mevar
    matrix `M_nffc' = e(nffc)
    local const = e(const)
    local tplv = e(tplv)
    local lab `e(lab)'
    local k_cat = e(k_cat)
    local phi = e(phi)
    local gindeps "`e(gindeps)'"
    local numg: word count `gindeps'

    if `k_cat'==.{
        local neq = 1
    }
    else{
        local neq = `k_cat'
    }

    scalar `mevar' = e(mevar)

    di as txt _n "gllamm covariate measurement error model" /*
    */  _col(52) as txt "No. of obs" _col(68) "="       /*
    */  _col(70) as res %9.0gc e(N)
    di
    di  
    disp as text "log likelihood = " as res %10.0g `e(ll)'

/*
    local cn = e(cn)
    if `cn'>0{
        disp in gr "Condition Number = " in ye `cn'
    }
    else{
        disp in gr "Condition Number could not be computed"
    }
    disp " "
*/

    if "`eform'"~=""{
        local eform "eform(exp(b))"
    }
    disp " "
    if "`robust'"~=""&"`rob'"==""{
        if "`cluster'"~=""{
            disp as text "Robust standard errors for clustered data: `cluster'"
        }
        else{
            disp as text "Robust standard errors"
        }
    }

    di in text "OUTCOME MODEL"
    noisily ereturn display , level(`level') `eform'  neq(`neq')  /* plus first */ 

    if `phi'~=.{
        noi _diparm _lnphi2, label(res. var.) function(exp(2*@)) /*
        */ derivative(2*exp(2*@)) level(`level')
        di in smcl in gr "{hline 13}{c BT}{hline 64}"
    }
    
    if "`indirect'"~=""&`numg'>0{
        di " "
        di in smcl in gr "{space 6}" "Indirect effects of covariates via true covariate"
        di in smcl in gr "{hline 13}{c TT}{hline 64}"

        tempname b V a b ab eff se p z lower upper
        matrix `b'=e(b)
        matrix `V'=e(V)

        foreach x in `gindeps'{
            local feq: coleq(`b')
            local feq: word 1 of `feq'
            scalar `eff' = [`x']_cons*[`feq']`lab'
            matrix `ab' = `V'["`feq':`lab'","`x':_cons"]
            matrix `a' = `V'["`x':_cons","`x':_cons"]
            matrix `b' = `V'["`feq':`lab'","`feq':`lab'"]
            scalar `se' =  sqrt(2*`eff'* `ab'[1,1] + [`x']_cons^2*`b'[1,1] + /*
            */ ([`feq']`lab'^2)*`a'[1,1] )
            scalar `z' = `eff'/`se'
            scalar `p' = chiprob(1,`z'^2)
            scalar `lower' = `eff' - invnorm(1-(100-`level')/200)*`se'
            scalar `upper' = `eff' + invnorm(1-(100-`level')/200)*`se'
            if "`eform'"~=""{
                scalar `eff' = exp(`eff')
                scalar `se' = `eff'*`se'
                scalar `lower' = exp(`lower')
                scalar `upper' = exp(`upper')
            }
            di in smcl in gr "{ralign 12:`x'}" in gr "{space 1}{c |}" /*
            */ in ye "{space 2}" %9.0g `eff' "{space 2}" %9.0g `se'  /*
            */ "{space 2}" %6.2f `z' "{space 4}"  %5.3f   `p'  /*
            */ "{space 4}" %9.0g `lower' "{space 3}" %9.0g `upper'
        }
        di in smcl in gr "{hline 13}{c BT}{hline 64}"
    }

    if "`total'"~=""&`numg'>0{
        di " "
        di in smcl in gr "{space 6}" "Total effects of covariates"
        di in smcl in gr "{hline 13}{c TT}{hline 64}"

        tempname b V a b ab eff se p z lower upper dir
        matrix `b'=e(b)
        matrix `V'=e(V)

        foreach x in `gindeps'{
            local feq: coleq(`b')
            local feq: word 1 of `feq'

            * indirect effects
            scalar `eff' = [`x']_cons*[`feq']`lab'
            matrix `ab' = `V'["`feq':`lab'","`x':_cons"]
            matrix `a' = `V'["`x':_cons","`x':_cons"]
            matrix `b' = `V'["`feq':`lab'","`feq':`lab'"]
            scalar `se' =  sqrt(2*`eff'* `ab'[1,1] + [`x']_cons^2*`b'[1,1] + /*
            */ ([`feq']`lab'^2)*`a'[1,1] )

            capture scalar `dir' = [`feq']`x'
            if _rc==0{
                scalar `eff' = `eff' + [`feq']`x'            /* a*b + d */
                matrix `a' = `V'["`feq':`x'","`feq':`x'"]    /* d,d     */
                scalar `se' = `se'^2 + `a'[1,1] 
                matrix `a' = `V'["`feq':`x'","`feq':`lab'"]  /* d,b     */
                scalar `se' = `se' +  2*[`x']_cons*`a'[1,1]
                matrix `a' = `V'["`feq':`x'","`x':_cons"]    /* d,a     */
                scalar `se' = `se' +  2*[`feq']`lab'*`a'[1,1]
                scalar `se' = sqrt(`se')
            }

            scalar `z' = `eff'/`se'
            scalar `p' = chiprob(1,`z'^2)
            scalar `lower' = `eff' - invnorm(1-(100-`level')/200)*`se'
            scalar `upper' = `eff' + invnorm(1-(100-`level')/200)*`se'
            if "`eform'"~=""{
                scalar `eff' = exp(`eff')
                scalar `se' = `eff'*`se'
                scalar `lower' = exp(`lower')
                scalar `upper' = exp(`upper')
            }
            di in smcl in gr "{ralign 12:`x'}" in gr "{space 1}{c |}" /*
            */ in ye "{space 2}" %9.0g `eff' "{space 2}" %9.0g `se'  /*
            */ "{space 2}" %6.2f `z' "{space 4}"  %5.3f   `p'  /*
            */ "{space 4}" %9.0g `lower' "{space 3}" %9.0g `upper'
        }
        di in smcl in gr "{hline 13}{c BT}{hline 64}"
    }

    di " "
    di " "
    di in text "TRUE COVARIATE MODEL"
    di in smcl in gr "{hline 13}{c TT}{hline 64}"
    di in smcl in gr "{ralign 12:`lab'}"  "{space 1}{c |}" /*
    */  "{space 2}" "{ralign 9:Coef.}" "{space 3}" "{ralign 9:Std. Err.}"  /*
    */ "{space 2}" "{ralign 5:z}" "{space 1}" "{space 3}"  "{ralign 5:P>|z|}"  /*
    */ "{space 4}" "{ralign 21:[`level'% Conf. Interval]}"
    di in smcl in gr "{hline 13}{c +}{hline 64}"
    di in smcl in ye "{lalign 13:`lab'}" in gr "{c |}"  

    if `numg'>0{
        foreach x in `gindeps'{
            noi _diparm `x', level(`level') label(`x')
        }
    }
    noi _diparm gamma0, level(`level') label(_cons)
    di in smcl in gr "{hline 13}{c +}{hline 64}"
    noi _diparm sdT, label(res. var.) function(@^2) derivative(2*@) level(`level')
    di in smcl in gr "{hline 13}{c BT}{hline 64}"

    di " "
    di " "
    di in text "MEASUREMENT MODEL"
    di in smcl in gr "{hline 13}{c TT}{hline 64}"
    

    if `mevar'==.{ /* measurement error variance not constrained */
        noi _diparm lns1, label(error var.) function(exp(2*@)) /*
        */ derivative(2*exp(2*@)) level(`level')
        noi _diparm lns1 sdT, label(reliability) func(@2^2/(exp(2*@1)+@2^2)) /*
        */ der( -2*exp(2*@1)*(@2/(exp(2*@1)+@2^2))^2  /*
        */ -2*@2*(@2/(exp(2*@1)+@2^2))^2+2*@2/(exp(2*@1)+@2^2) ) /*
        */ level(`level') ci(probit)
    }
    else{  /* measurement error variance constrained */
        local junk = `mevar'
        di in smcl in gr "{ralign 13:error var.}" in gr "{c |}" /*
        */ in ye "{ralign 11:`junk'}" in ye "{space 3}{center 11:-}"     /*
        */ in ye "{center 18:(fixed parameter)}" 
        noi _diparm sdT, label(reliability) function(@^2/(`mevar'+@^2)) /*
        */ derivative(-2*@*(@/(`mevar'+@^2))^2+2*@/(`mevar'+@^2)) /*
        */ level(`level') ci(probit)
    }
    di in smcl in gr "{hline 13}{c BT}{hline 64}"

end
