*! version 2.3.20 SRH 7 Sept 2011
program define gllamm, eclass
    version 7.0
    timer on 1

    if replay() {
                if "`e(cmd)'" ~= "gllamm" {
                        di in red  "gllamm was not the last command"
                        error 301
                }
                Replay `0'
        }
    else {
        Estimate `0'
    }
   timer off 1
end

program define procstr, eclass
    version 6.0
    tempname  bc b Vc Vr V ll esamp
    noi disp "processing constraints"

    scalar `ll' = e(ll)
    local df = e(df_m)
    local dof
    if "`df'"~="."{
        local dof "dof(`df')"
    }
    local k = e(k)
    capture matrix `Vr' = e(Vr)
    capture robclus "`e(robclus)'"
    matrix  `bc' = e(b)
    matrix `Vc' = e(V)
    local y = "`e(depvar)'"
    matrix `b' = `bc'*M_T' + M_a
    matrix colnames `b' = $HG_coln
    matrix coleq `b' = $HG_cole
    * matrix list `b'
    * matrix list `Vc'
    matrix `V' = M_T*`Vc'*M_T'
    * disp  "computed V"
    * matrix list `V'
    estimates post `b' `V' M_C, $HG_obs `dof'
    est local ll =`ll'
    est local k = `k'
    est local depvar "`y'"
    capture est matrix Vr `Vr' 
    capture est local robclus "`robclus'"
    * disp "posted results"
end

program define Replay, eclass
    version 6.0
    syntax [, Level(real $S_level) EFORM ALLC ROBUST CLUSTER(varname) DOTS SCorefil(passthru) noROb noDISplay EVAL]
    tempname M_nffc M_nu Vs

    if "`eval'"==""{ 
        if "`e(pweight)'"~="" {
            local robust robust
        }
        if "`robust'"~=""|"`cluster'"~=""{
            if "`cluster'"~=""{
                local cluster cluster(`cluster')
            }
            gllarob, `cluster' `dots' `scorefil' `rob'
        }
        if ("`robust'"==""|"`rob'"~="")&"`cluster'"==""{
            * disp "reposting model-based standard errors"
            matrix `Vs' = e(Vs)
            estimates repost V =`Vs'
        }
    }
         
    if "`display'"==""{

        local const = e(const)
        local tplv = e(tplv)
        matrix `M_nffc' = e(nffc)
        capture matrix `M_nu' = e(nu)
        * capture matrix list `M_nu'
        if _rc == 0{
            disp " "
            local j = 1
            while `j' <= `tplv'{
                disp in gr "number of level `j' units = " in ye `M_nu'[1,`j']
                local j = `j' + 1
            }
            disp " "
        }
        local cn = e(cn)
        if `cn'>0{
            disp in gr "Condition Number = " in ye `cn'
        }
        else{
            disp in gr "Condition Number could not be computed"
        }
        disp " "


        * matrix list `M_nffc'
        local numeq = colsof(`M_nffc')
        if `M_nffc'[1,1]==0{
            local numeq = `numeq' -1
        }
        if `numeq' > 1{
            local first neq(`numeq')
        }
        else{
            local first first
        }
        local primess
        if `e(prior)' == 1 {
            local primess "with prior "
        }
        if e(ll_0)==.|`M_nffc'[1,1]==0{
            local nohead "noheader"
            if `const'==0{
                disp in gr "gllamm model `primess'"
            }
            else{
                disp in gre "gllamm model `primess'with constraints"
                *matrix dispCns
            }
            disp " "
            if `e(prior)' == 1 {
                disp in gr "log posterior = " in ye e(ll)
                disp in gr "log likelihood = " in ye e(a_ll)   
            }
            else{
                disp in gr "log likelihood = " in ye e(ll)
            }
        }
        if "`eform'"~=""{
            local eform "eform(exp(b))"
        }
        disp " "
        if "`cluster'"~=""|("`robust'"~=""&"`rob'"==""){
            if "`cluster'"~=""{
                disp "Robust standard errors for clustered data: `cluster'"
            }
            else{
                disp "Robust standard errors"
            }
        }

        if `M_nffc'[1,1]>0|`numeq'>0 {
            quietly q born
            if $S_1>15502{ /* version 8 or later */
                _coef_table, level(`level') `first' `eform'
            }
            else{ /* older versions */
                if `const' == 0{
                    noi ml display, level(`level') `nohead' `first' `eform'
                }
                else{
                    matrix dispCns
                    noi estimates display, level(`level') `first' `eform'
                }
            }
        }
        else{
            disp in gr "No fixed effects"
        }
        noi disprand
        if "`allc'"~=""{
            if `const' == 0{
                noi ml display, level(`level') `nohead'
            }
            else{
                noi estimates display, level(`level')
            }
        }
    }   
end

program define Estimate, eclass
    version 6.0
    syntax varlist(min=1) [if] [in] , I(string) [NRf(numlist integer min=1 >=1) /*
    */ Eqs(string) GEqs(string) PEqs(string) /*
    */ noCORrel noCOnstant BMATrix(string) INTER(string) FRLoad(numlist integer min=1 >=1) /*
    */ Family(string) DEnom(varname numeric min=1) Link(string) EXpanded(string) /*
    */ Offset(varname numeric) Basecategory(integer 999) /*
    */ THresh(string) ETHresh(string) COMPosite(varlist numeric min=3) * ]
    *disp in re "`opt'"
    *disp in re "1: `varlist'"
    local origif  `"`if'"'
    local origin  `"`in'"'
    local origvar `"`varlist'"'
    local opt "`options'"
    local 0 "`origvar' `origif' `origin', `opt'"
    syntax varlist(min=1) [if] [in] [, /*
    */ Weightf(string) LV(varname numeric min=1) FV(varname numeric min=1) S(string) /*
    */ NATS IP(string) NIp(numlist integer min=1 >=1) ADapt Constraints(numlist) /*
    */ FRom(string) LONG Gateaux(passthru) LF0(passthru) SEarch(passthru) /*
    */ ROBust CLuster(varname) PWeight(string) ITerate(passthru)/*
    */ DOts noLOg TRace noDISplay noESt EVal Level(real $S_level) INit noDIFficult /*
    */ EFORM ALLC ADOONLY SKIP COPY PRior(passthru) ]  /* does not allow extra options! */
    *disp in re "2: `varlist'"
    *disp in re "i: `i'"
    *disp in re "frload: `frload'"
    *disp in re "display: `display'"
    *disp in re "iterate: `iterate'"

    tempname mat mnip mnbrf
    global HG_error=0

/* deal with adoonly */

    global HG_noC = 0
    global HG_noC1 = 0
    global HG_noC2 = 0
    if "`adoonly'"=="" {
        qui q born
        if $S_1 < 16350 {
            global HG_noC2 = 1
            if $S_1 < 15722 {
                noi di
                noi di in gr "You must have the Stata 8 executable updated on or after " _c
                noi di in ye %d 15722
                noi di in gr "in order to use all internal routines"
                global HG_noC1 = 1
                if $S_1 < 15274 {
                    global HG_noC = 1
                    noi di in gr "Option adoonly assumed."
                    noi di
                }
            }
        }
    }

    if "`adoonly'"!="" {
        global HG_noC =  1   /* link and family */
        global HG_noC1 = 1  /* lnupdate */
        global HG_noC2 = 1  /* don't want to set HG_noC to 0 */
    }


/* deal with trace */

    if "`trace'"!="" { local noi "noisily" }    

/* deal with dots */

    global HG_dots = 0 
    if "`dots'"!="" { 
        global HG_dots = 1
    }   

/* deal with init */

    global HG_init=0
    if "`init'"~="" {
        global HG_init=1
    }

/* deal with if and in */
    marksample touse    

    qui count if `touse'
    if _result(1) <= 1 {
        di in red "insufficient observations"
        exit 2001
    }

 /* deal with varlist */
    tokenize `varlist'
    local y "`1'"

    macro shift   /* `*' is list of dependent variables */
    local indep "`*'"

    local num: word count `indep'  /* number of independent variables */

    markout `touse' `y' `indep'
 
/* deal with Link and Family */
    global HG_lev1=0
    global HG_famil
    global HG_linko
    global HG_link
    matrix M_olog=(0)
    capture matrix drop M_oth
    global HG_mlog=0
    global HG_nolog = 0
    global HG_lv
    global HG_fv
    global HG_smlog=0
    global HG_oth = 0
    local l: word count `family'
    if `l'>1 {
        `noi' qui disp  "more than one family" 
        if "`fv'"==""{
            disp in re "need fv option"
            exit 198
        }
        else{
            confirm variable `fv'
            global HG_fv `fv'
        }
        parse "`family'", parse(" ")
        local n=1
        while "`1'"~=""{
            qui count if `fv'==`n'
            if _result(1)==0{
                disp "family `1' not used"
            }
            fm "`1'"
            if "$S_2"=="gauss"{
                if $HG_lev1==0{
                    global HG_lev1=1
                }
                else if $HG_lev1==2{
                    global HG_lev1=3
                }
            }
            else if "$S_2"=="gamma"{
                if $HG_lev1==0{
                    global HG_lev1=2
                }
                else if $HG_lev1==1{
                    global HG_lev1=3
                }
            }
            global HG_famil "$HG_famil $S_2"
            local n = `n'+1
            mac shift
        }
        
    }

    local k: word count `link'
    local mll = 0
    if `k'>1{
        `noi' qui disp  "more than one link" 
        if "`lv'"==""{
            disp in re "need lv option"
                exit 198
        }
        else{
            confirm variable `lv'
            global HG_lv `lv'
        }
        parse "`link'", parse(" ")
        local n=1
        while "`1'"~=""{
            qui count if $HG_lv==`n'
            if _result(1)==0{
                disp "link `1' not used"
            }
            lnk "`1'"
            if "$S_1"=="sprobit"|"$S_1"=="soprobit"{
                if $HG_lev1 == 2{
                    global HG_lev1 = 3
                }
                else{
                    global HG_lev1 = 1
                }
            }
            if "$S_1"=="ll"{
                global HG_noC = $HG_noC2
            }
/* nominal */
            if "$S_1"=="mlogit"|"$S_1"=="smlogit"{
                if $HG_mlog>0{
                    disp in re "can only have one mlogit link"
                    exit 198
                }
                global HG_mlog=`n'
                if "$S_1"=="smlogit"{
                    if $HG_lev1 == 2{
                        global HG_lev1 = 3
                    }
                    else{
                        global HG_lev1 = 1
                    }
                }
                tempvar first
                sort `touse' $HG_lv `y'
                qui by `touse' $HG_lv `y': gen byte `first' = cond(_n==1,1,0)
                mkmat `y' if `first' == 1 & `touse' & $HG_lv == `n', mat(M_respm)
                if "$S_1"=="smlogit"{global HG_smlog=1}
            }
/* ordinal */
            else if "$S_1"=="ologit"|"$S_1"=="oprobit"|"$S_1"=="ocll"|"$S_1"=="soprobit"{
                global HG_linko "$HG_linko $S_1"
                if $HG_nolog>0{
                    * disp "more than one ordinal response"
                    matrix M_olog = M_olog,`n'
                }
                else{
                    capture matrix drop M_nresp
                    matrix M_olog[1,1] = `n'
                    tempvar first
                    sort `touse' $HG_lv `y'
                    qui by `touse' $HG_lv `y': gen byte `first' = cond(_n==1,1,0)
                }
                mkmat `y' if `first' == 1 & `touse' & $HG_lv == `n', mat(`mat')
                local ll = rowsof(`mat')
                * matrix list `mat'
                * disp "adding `ll' to M_nresp"
                matrix M_nresp = nullmat(M_nresp),`ll'
                if `ll'>`mll'{
                    local mll = `ll'
                }
                global HG_nolog = $HG_nolog + 1
            }
/* other */
                else {
                global HG_link "$HG_link $S_1"
                matrix M_oth = nullmat(M_oth),`n'
                global HG_oth=1
                }
            local n = `n'+1
            mac shift
        }
        if $HG_nolog>0{
            tempname junk
            global HG_lvolo "`junk'"
            qui gen byte $HG_lvolo = 0
            matrix M_resp = J(`mll',$HG_nolog,0)
            local no = 1
            local totresp = 0
            while `no'<=$HG_nolog{
                local olog = M_olog[1,`no']
                qui replace $HG_lvolo = 1 if $HG_lv == `olog'
                mkmat `y' if `first' == 1 & `touse' & $HG_lv == `olog', mat(`mat')
                local ii = 1
                while `ii'<= M_nresp[1,`no']{
                    * disp "M_resp[`ii',`no'] = mat[`ii',1]"
                    matrix M_resp[`ii',`no'] = `mat'[`ii',1]
                    local ii = `ii' + 1
                }
                local totresp = `totresp' + M_nresp[1,`no']
                local no = `no' + 1
            }
        }
        if $HG_mlog>0{
            if $HG_nolog==0{
                tempname junk
                global HG_lvolo "`junk'"
                qui gen byte $HG_lvolo = 0
            }
            qui replace $HG_lvolo = 1 if $HG_lv == $HG_mlog
        }
    }
    else if `k'<=1&`l'<=1{ /* no more than one link and one family given */
        lnkfm "`link'" "`family'"
        global HG_link = "$S_1"
        global HG_famil  = "$S_2"
        if "$HG_link"=="ologit"|"$HG_link"=="oprobit"|"$HG_link"=="ocll"|"$HG_link"=="soprobit"{
        global HG_linko = "$HG_link"
            global HG_nolog = 1
            matrix M_olog[1,1] = 1
        }
        if "$HG_link"=="smlogit"|"$HG_link"=="mlogit"{global HG_mlog=1}
        if "$HG_famil"=="gauss"{global HG_lev1=1}
        if "$HG_famil"=="gamma"{global HG_lev1=2}
        if "$HG_link"=="sprobit"{global HG_lev1=1}
        if "$HG_link"=="soprobit"{global HG_lev1=1}
        if "$HG_link"=="smlogit"{global HG_lev1=1}
        if "$HG_link"=="ll"{global HG_noC = $HG_noC2 }
        if $HG_mlog==0&$HG_nolog==0{global HG_oth = 1}  
    }
    else if `k'==1{
        lnk "`lnk'"
        global HG_link = "$S_1"
        if "$HG_link"=="ologit"|"$HG_link"=="oprobit"|"$HG_link"=="ocll"|"$HG_link"=="soprobit"{
            global HG_nolog = 1
            matrix M_olog[1,1] = 1
            global HG_linko = "$HG_link"
        }
        if "$HG_link"=="smlogit"|"$HG_link"=="mlogit"{global HG_mlog=1}
        if "$HG_link"=="sprobit"{global HG_lev1=1}
        if "$HG_link"=="smlogit"{global HG_lev1=1}
        if "$HG_link"=="soprobit"{global HG_lev1=1}
        if "$HG_link"=="ll"{global HG_noC = $HG_noC2 }
        if $HG_mlog==0&$HG_nolog==0{global HG_oth = 1}
    }
    if `l'==1{
        fm "`family'"
        global HG_famil  = "$S_2"
        if "$HG_famil"=="gauss"{global HG_lev1=1}
        if "$HG_famil"=="gamma"{global HG_lev1=2}
        if $HG_mlog==0&$HG_nolog==0{global HG_oth = 1}
    }
    if ((`k'>1&`l'==0)|(`l'>1&`k'==0))&$HG_oth==1{
        disp in re /*
        */ "both link() and fam() required for multiple links or families"
        exit 198
    }

    markout `touse' $HG_lv $HG_fv


/* deal with noCORrel */
    global HG_cor = 1
    if "`correl'"~=""{
        global HG_cor = 0
    }

/* deal with DEnom */
    global HG_denom
    local f=0
    parse "$HG_famil", parse(" ")
    while "`1'"~=""&`f'==0{
        if "`1'"=="binom"{
            local f=1
        }
        mac shift
    }
    if `f'==1{
        if "`denom'"~=""{
            confirm variable `denom'
            global HG_denom "`denom'"
        }
        else{
            tempvar den
            quietly gen byte `den'=1
            global HG_denom "`den'"
        }
    }
    else{
        if "`denom'"~=""{
            disp in blue/*
              */"option denom(`denom') given but binomial family not used"
        }
    } 
    
    markout `touse' `denom'

/* deal with offset */
    global HG_off
    if "`offset'"~=""{
        global HG_off "`offset'"
        local offset "offset(`offset')"
    }
    
    markout `touse' $HG_off

/* deal with ip */
    global HG_gauss = 1
    global HG_free = 0
    global HG_cip = 1
    global HG_mult = 0
    if "`ip'"~=""{
        if "`ip'"=="g"{
            global HG_gauss = 1
        }
        else if "`ip'"=="l"{
            global HG_gauss = 0
        }
        else if "`ip'"=="f"{
            global HG_free = 1
        }
        else if "`ip'"=="m"{
            global HG_mult = 1
            global HG_gauss = 0
        }
        else if "`ip'"=="fn"{
            global HG_free = 1
            global HG_cip = 0
        }
        else {
            disp in re "ip option `ip' not valid"
            exit 198
        }
    }

    global HG_lzpr lzprobg
    global HG_zip zipg

    * disp in re "HG_mult = " $HG_mult
    if $HG_mult{
        global HG_lzpr lzprobm
    }
    else if $HG_free{
        global HG_lzpr lzprobf
        global HG_zip zipf
    }


/* deal with expanded */
    global HG_ind
    global HG_exp = 0
    global HG_expf = 0
    if "`expanded'"~=""{
        global HG_exp = 1
        if $HG_mlog==0{
            disp in re "expanded option only valid with mlogit link"
            exit 198
        }
        local k: word count `expanded'
        if `k'~=3{
            disp in re "expanded option must have three arguments"
        }
        local exp: word 1 of `expanded'
        confirm variable `exp'
        global HG_mlg `exp'
        local k: word 2 of `expanded'
        * 11/11/06
        confirm variable `k'
        global HG_ind `k'
        local k: word 3 of `expanded'
        if "`k'"=="o"{
            global HG_expf=1
        }
        else{
            if "$HG_link"~="mlogit"&"$HG_link"~="smlogit"{
                disp in re "must use o in expanded option when combining mlogit with other links"
                exit 198
            }
        }
        * 11/11/06
        markout `touse' $HG_mlg $HG_ind
    }
    else{
        if $HG_mlog>0&"$HG_link"~="mlogit"&"$HG_link"~="smlogit"{
            disp in re "must use expanded option when combining mlogit with other links"
            exit 198
        }
        tempvar ind
        gen byte `ind' = 1
        global HG_ind `ind'
        global HG_exp = 0
    }
        

/* deal with composite */
    global HG_comp = 0
    global HG_coall
    if "`composite'"~=""{
        local k: word count `composite'
        global HG_comp = `k' - 2
        local k: word 1 of `composite'
        global HG_mlg `k'
        local k: word 2 of `composite'
        global HG_ind `k'
        local kk = 1
        while `kk'<= $HG_comp {
            local jj = `kk' + 2
            local k: word `jj' of `composite'
            global HG_co`kk' `k'
            global HG_coall $HG_coall `k'
            local kk = `kk' + 1
        }
        global HG_noC = $HG_noC2  /* use ado-code for link if not latest Stata 8 */
    }
        
        

/* deal with I (turn list around)*/
    if ("`i'"==""){
        disp in red "i() required"
        global HG_error=1
        exit 198

    }

    local tplv: word count `i'
    global HG_tplv = `tplv'+1
    global HG_clus
    local k = `tplv'
    while `k'>=1{
        local clus: word `k' of `i'
        confirm numeric variable `clus'
        markout `touse' `clus', strok
        local k=`k'-1
        global HG_clus "$HG_clus `clus'"
    }


    if "`expanded'"==""&"`composite'"==""{
        tempvar id
        gen long `id'=_n
        global HG_clus "$HG_clus `id'"
    }
    else{
         global HG_clus "$HG_clus $HG_mlg" 
    }

/* deal with weightf */
    tempvar wt
    quietly gen double `wt'=1
    local j = 1
    if "`weightf'"==""{
        while (`j'<=$HG_tplv){
            tempname junk
            global HG_wt`j' "`junk'"
            gen double ${HG_wt`j'}=1
            local j = `j' + 1
        }
        global HG_weigh
    }
    else{
        global HG_weigh "`weightf'"
        local wtvars
        local found = 0
        while (`j'<=$HG_tplv){
            capture confirm variable `weightf'`j'   /* frequency weight */
            if _rc ~= 0 {
                tempname junk
                global HG_wt`j' "`junk'"
                gen double ${HG_wt`j'} = 1 /* can become non-integeger later */
            }
            else{
                tempname junk
                global HG_wt`j' "`junk'"
                gen double ${HG_wt`j'}=`weightf'`j'
                local wtvars `wtvars' `weightf'`j'
                quietly replace `wt'=`wt'*${HG_wt`j'}
                local found = `found' + 1
            }
            local j = `j' + 1
        }
        if `found' == 0 {
            disp in red "weight variables `weightf' not found"
            global HG_error=1
            exit 111
        }
        markout `touse' `wtvars'
    }

/* deal with probability weights */
    local pw
    local wtvars
    if "`pweight'"~=""{
        local robust robust
        tempname wtp
        local pw pweight
        global HG_pwt "`pweight'"
        quietly gen double `wtp' = 1
        local j = 1
        local found = 0
        while (`j'<=$HG_tplv){
            capture confirm variable `pweight'`j'   /* probability weight */
            if _rc == 0 {
                quietly replace `wtp'=`wtp'*`pweight'`j'
                local wtvars `wtvars' `pweight'`j'
                local found = `found' + 1
            }
            local j = `j' + 1
        }
        if `found' == 0 {
            disp in red "probability weight variables not found"
            global HG_error=1
            exit 111
        }
        markout `touse' `wtvars'
    }

/* deal with cluster */

    if "`cluster'"~=""{
* check that top-level cluster does not vary within cluster?
        local k: word count $HG_clus
        local top: word 1 of $HG_clus
        qui sort `top' `cluster' 
        capture qui by `top' : assert `cluster'[1]==`cluster'[_N] 
        if _rc>0{
            disp in re "`cluster' varies within `top'"
            exit 198
        }
        markout `touse' `cluster'
        local cluster cluster(`cluster')
    }

/* deal with categorical response variables */

    if "$HG_link" == "mlogit"|"$HG_link" == "smlogit"{
        sort `touse' `y'
        tempvar first
        qui by `touse' `y': gen byte `first' = cond(_n==1,1,0)
        mkmat `y' if `first' == 1 & `touse', mat(M_respm)
    }
    else if /*
        */ "$HG_link" == "ologit"|"$HG_link" == "ocll"|"$HG_link" == "oprobit"|"$HG_link"=="soprobit"{
        sort `touse' `y'
        tempvar first
        qui by `touse' `y': gen byte `first' = cond(_n==1,1,0)
        mkmat `y' if `first' == 1 & `touse', mat(M_resp)
        local totresp = rowsof(M_resp)
        matrix M_nresp = (`totresp')
    }

/* deal with base-category */

    if `basecategory'~=999{
        if "$HG_link" ~= "mlogit"&"$HG_link" ~= "smlogit"{
            disp in red  "basecategory ignored because response not nominal"
        }
    }
    if $HG_mlog>0&$HG_expf==0{
        tempname bas
        if `basecategory'==999{
            scalar `bas' = M_respm[1,1]
            matrix `bas' = (`bas')
            local basecat = M_respm[1,1]
            * disp in re "`basecat'"
        }
        else{
            matrix `bas' = (`basecategory')
            local basecat = `basecategory'
        }
        
        local n = rowsof(M_respm)
        local j = 1
        local found = 0
        while `j'<=`n'{
            local el = M_respm[`j',1]
            if `el'==`basecat'{
                local found = 1
            }
            else{
                matrix `bas' = `bas'\ `el'
            }
            local j = `j' + 1
        }
        if `found' == 0 {
            disp in re "basecategory = `basecat' not one of the categories"
            exit 198
        }
        matrix M_respm = `bas'
        local el = M_respm[1,1]
        local basecat basecat(`el') 
    }

 
/* deal with noCOns */

    if "`constant'"~=""{
        if $HG_nolog>0{
            disp in re "noconstant option not allowed for ordinal links:" _n "This is the default because all thresholds estimated"
            exit 198
        }
        local cns
    }
    else{
        if $HG_cip == 0{
            disp in re "are you sure you need a constant with ip(fn) option?"
        }

        local num=`num'+1
        local cns "_cons"
    }
    matrix M_nffc=(`num')

    
    if `num'>0 {
        global HG_fixe (`y': `y'=`indep', `constant')
        local dep
    }
    else{
        global HG_fixe
        local dep "`y'="
    }

/* fixed effects matrix */
    
    global HG_ethr = 0

    if `num' > 0 {
        matrix M_initf=J(1,`num',0)
        matrix coleq M_initf=`y'
        matrix colnames M_initf=`indep' `cns'
    }
    else{
        cap matrix drop M_initf
    }

    if $HG_nolog==0{
        if "`thresh'"~=""{ disp in re "thresh option ignored" }
        if "`ethresh'"~=""{ disp in re "ethresh option ignored" }
    }
    else if $HG_nolog>0{

        if "`ethresh'"~=""{
            if "`thresh'"~=""{
                disp in re "cannot use both ethresh() and thresh() options!
                exit 198
            }
            global HG_ethr = 1
            local thresh `ethresh'
            
        }
        if "`thresh'"~=""{
            local k: word count `thresh'
            if `k'~=$HG_nolog{
                disp in re "number of threshold equations should be " $HG_nolog
                exit 198
            }

        }
        global HG_fixe
        local n = rowsof(M_resp)
        matrix M_nffc[1,1] = `num'-1
        if `num'>1{
            global HG_fixe (`y': `y'=`indep', nocons)
            matrix `mat' = M_initf[1,1..`num'-1]
            local ce: coleq(`mat')
            local cn `indep'
            matrix M_initf=J(1,`num'-1,0)
        }
            else{
                capture matrix drop M_initf
            }       
        local el = M_nffc[1,1]
        local ii = 1
        local nxt = M_nffc[1,1] + 1
        local ntr = 1
        local vars
        local rhs "_cons"
        while `ii'<= $HG_nolog{
            local j = 1
            if "`thresh'"~=""{
                local eqnam: word `ii' of `thresh'
                eq ? "`eqnam'"
                local vars "$S_1"
                markout `touse' `vars'
                local ntr: word count `vars'
                local ntr = `ntr' + 1
                local rhs "`vars' _cons"
            }
            while `j'< M_nresp[1,`ii']{
                * disp "`ii'th ordinal response, level `j'"
                local el = `el' + `ntr'
                matrix M_nffc = M_nffc, `el'
                matrix `mat'=J(1,`ntr',0)
                matrix coleq `mat' =  _cut`ii'`j'
                local cee: coleq(`mat')
                local ce `ce' `cee'
                local cn `cn' `rhs'
                global HG_fixe $HG_fixe (_cut`ii'`j':`vars')
                if `j' == 1 & `ii'==1 & `num' == 1{
                    global HG_fixe (_cut`ii'`j':`y'= `vars')
                }
                local j = `j' + 1
                if $HG_ethr{
                    matrix `mat'[1,`ntr'] =  - 0.5
                }
                else{
                    matrix `mat'[1,`ntr'] =  `j' - (M_nresp[1,`ii']+1)/2
                }
                matrix M_initf = nullmat(M_initf), `mat'
                local nxt = `nxt' + 1
            }
            local ii = `ii' + 1
        }
        matrix colnames M_initf=`cn'
        matrix coleq M_initf=`ce'
            * matrix list M_initf
    }

    if ($HG_mlog>0)&$HG_expf==0{
        global HG_fixe
        local n = rowsof(M_respm)
        matrix `bas'=M_initf
        matrix drop M_initf
        matrix drop M_nffc
        local j = 2
        while `j'<=`n'{
            local  el = M_respm[`j',1]
            matrix coleq `bas' = c`el'
            matrix M_initf = nullmat(M_initf), `bas'
            matrix M_nffc = nullmat(M_nffc), (`j'-1)*`num'
            if `j' == 2{
                global HG_fixe $HG_fixe ( c`el':`y' = `indep', `constant')
            }
            else{ 
                global HG_fixe $HG_fixe ( c`el':`indep', `constant')
            }
            local j = `j' + 1
        }
        local num = `num'*(`n' - 1)     
    }

    * matrix list M_nffc
    * matrix list M_initf


/* display information */
    quietly `noi'{
        disp " "
        disp in gr "General model information"
        *disp in smcl in gr "{hline 78}" _n
        di in gr _dup(78) "-" _n
        disp in gr "dependent variable:" in ye "         `y'"   
        if $HG_oth{
            disp in gr "family:" in ye "                     $HG_famil"
            disp in gr "link:" in  ye "                       $HG_link"
        }
        if "$HG_linko"~=""{
            disp in gr "ordinal responses:" in ye "         $HG_linko"
        }
        if $HG_mlog>0{
            if $HG_smlog==1 {
                disp in gr "nominal responses:" in ye "         smlogit"
            }
            else{
                disp in gr "nominal responses:" in ye "          mlogit"
            }
        }
        if "$HG_denom"~=""{
            if "`denom'"~=""{
                    disp in gr "denominator:" in ye "                `denom'"
            }
            else{
                disp in gr "denominator:" in ye "                1"
            }
        }
        if "`offset'"~=""{
            disp in gr "offset:" in ye "                     $HG_off"
        }
        local m = colsof(M_nffc)
        if `m'==1&M_nffc[1,1]>0{
            local cuts: colnames(M_initf)
            disp in gr "equation for fixed effects " in ye " `cuts'"
        }
        else if `m'==1{
            disp in gr "equation for fixed effects " in ye " none"
        }
        else{
            disp in gr "equations for fixed effects"
            local j = 1
            local nxt = 1
            local prev = 0
            while `j'<=`m'{
                local n = M_nffc[1,`j'] - `prev'
                if `n'>0{
                    local prev = M_nffc[1,`j']
                    matrix `mat' = M_initf[1,`nxt'..`nxt'+`n'-1]
                    local nxt = `nxt' + `n'
                    local ce: coleq(`mat')
                    local ce: word 1 of `ce'
                    local cn: colnames(`mat')
                            disp in gr "                           `ce': " in ye " `cn'"
                }
                local j = `j' + 1
            }
        disp " "
        }
    } /* end qui `noi' */

   
/* deal with inter */

    global HG_inter = 0
    if "`inter'"~=""{
        global HG_inter=1
        local j: word count `inter'
        if `j'~=2{
            disp in red "inter should have two arguments"
            exit 198
        }
        local j: word 1 of `inter'
        capture confirm number `j'
        if _rc>0{
            disp in red "arguments of inter must be numbers"
            exit 198
        }
        global HG_l = `j'
        local j: word 2 of `inter'
        capture confirm number `j'
        if _rc>0{
            disp in red "arguments of inter must be numbers"
            exit 198
        }
        global HG_r = `j'
    }

/* initialise macros */
    quietly `noi' initmacs "`nrf'" "`nip'" "`eqs'" "`geqs'" "`peqs'" "`s'" "`nats'" "`bmatrix'" "`touse'" "`dep'" "`frload'"
    qui count if `touse'
    if _result(1) <= 1 {
        di in red "insufficient observations"
        exit 2001
    }
            
/* deal with noESt */
    if "`est'"~=""{
        exit 0
    }
/* only use observations satisfying if and in and having nonmissing values */
    preserve
    quietly keep if `touse'

/* work out number of units at each level  */

    qui summ `wt' if `touse', meanonly
    local lobs = r(sum)
    tempvar cw f
    qui gen double `cw' = `wt'
    qui gen byte `f' = 1
    matrix M_nu=J(1,$HG_tplv,0)
    matrix M_nu[1,1]=`lobs'
    local sortlst $HG_clus
    local j = 1
    local k = $HG_tplv
    quietly `noi' disp in gr "number of level 1 units = " in ye `lobs' 
    while `j'<$HG_tplv{
        *disp "sort `sortlst'"
        sort `sortlst'
        tokenize "`sortlst'"
        local `k' " "
        local sortlst "`*'"
        *disp "replace cw = cw/wt`j'"
        qui replace `cw' = `cw'/${HG_wt`j'}
        *disp "by `sortlst': replace f=_n==1"
        qui by `sortlst': replace `f' = _n==1
        qui summ `cw' if `f' ==1, meanonly
        local lobs = r(sum)
        quietly `noi' disp in gr "number of level " `j'+1 " units = " in ye `lobs' 
        matrix M_nu[1,`j'+1] = `lobs'
        local j = `j' + 1
        local k = `k' - 1           
    } 

/* use pweights */

    if "`pw'"~=""{
        local j = 1
        while (`j'<=$HG_tplv){
            capture confirm variable `pweight'`j'   /* probability weight */
            if _rc == 0 {
                quietly replace ${HG_wt`j'}=${HG_wt`j'}*`pweight'`j'
            }
            local j = `j' + 1
        }
    }

/* check if weights are integer */

    qui cap summ `y' if `touse' [fweight=`wt'], meanonly
    if _rc>0 {
        global HG_obs
        local ftype pweight
        disp in re "weights are non-integer"
    }
    else {
        local lobs = M_nu[1,1]
        global HG_obs obs(`lobs')
        local ftype fweight
    }
    if "`pweight'"~=""{
        quietly replace `wt' = `wt'*`wtp'
        local ftype pweight 
        
    }

        
/* deal with from */
    if "`from'"~=""{
        capture qui matrix list `from'  /* do not comment out this line! */
        local rc=_rc
        if `rc'>1{
            disp in red "`from' not a matrix"
            exit 111
        }
        tempname amat
        matrix `amat' = `from'
        local from "`amat'"
    }

/* deal with eval */
    if "`eval'"~=""{
        if "`from'"==""{
            disp in re "eval not valid without from option"
            exit 198
        }
    }
    
/* deal with constraints (and from long) */

    global HG_const = 0
    if "`constra'"~=""{
        global HG_const = 1
    if $HG_init==0{
        tempname b V
        matrix `b' = nullmat(M_initf), nullmat(M_initr)
       * noi matrix list `b'
        if "`from'"~=""& "`long'"~=""{
            local nb = colsof(`b')
            local nf = colsof("`from'")
            * disp "nb = " `nb'
            * disp "nf = " `nf'
            if "`gateaux'"~=""{
                local tprf=M_nrfc[2,$HG_tplv]-M_nrfc[2,$HG_tplv-1]
                local nnf = `nf' + `tprf' + 1
                if `nnf'~=`nb'{
                    disp in re "from matrix has `nf' columns and should have " `nb'-`tprf'-1
                    exit 198
                }
                matrix `from' = `from',`b'[1,`nf'+1...]
**
*               local lfix = `M_nffc'[1,colsof(`M_nffc')]
*               matrix `from' = `from'[1,1..`lfix'],`b'[1,`nf'+1..`nf'+`tprf'+1],`from'[1,`lfix'+1...]
*               noi matrix list `from'
            }   
            else{
                capture ml model d0 gllam_ll $HG_fixe $HG_eqs, /*
                 */  noscvars waldtest(0) nopreserve missing  collinear

                * disp  "ml init from, `skip' `copy'"
                        ml init `from', `skip' `copy'
                matrix `from' = ML_b            
            }
            matrix `b' = `from'
            * matrix list `b'
        }
        global HG_coln: colnames(`b')
        global HG_cole: coleq(`b')
        * matrix list `b'
        matrix `V' = `b''*`b'
        estimates post `b' `V'
        matrix `b' = e(b)
        matrix makeCns `constra'
        qui `noi' disp in gr "Constraints:"
        qui `noi' matrix dispCns
        qui `noi' disp " "
        matcproc M_T M_a M_C
        matrix M_inshrt = `b'*M_T
        local n = colsof(M_inshrt)
        qui `noi' disp "estimating `n' parameters"
        local i = 1
        local lst "`y'"
        gen byte __0066 = 1
        while `i'< `n'{
            local lst `lst' "eq`i'"
            local i = `i' + 1
        }
        global HG_eqs
        matrix coleq M_inshrt = `lst'
        matrix colnames M_inshrt = __0066

        *matrix list M_inshrt
        *matrix `b' = M_inshrt*M_T' + M_a
        *matrix list `b'
        if "`gateaux'"~=""{
            local nf = `nf' - (`nb' - `n')
            matrix `from' = M_inshrt[1,1..`nf']
        }
        else if "`from'"~=""&"`long'"~=""{
            matrix `from' = M_inshrt
        }
        }
    }

    if "`from'"~=""{
        local from "from(`from')"
    }
    
/* deal with prior */
    
    global HP_prior = 0

    if "`prior'"!=""{
        if "`noi'"!=""{ local loud "loud" }
        *disp in re "prior loud is `prior' `loud'"
        init_prior, `prior' `loud'
        global HP_sprd = 0
    }
    
    * disp in re "HP_prior: " $HP_prior

/* deal with adapt */
    global HG_adapt=0
    if "`adapt'"~=""{
        if $HG_free==1|($HG_gauss==0&$HG_mult==0){
            disp in re "adapt can only be used with ip(g) or ip(m) option"
            exit 198
        }
        global HG_adapt = 1
    }
    
    /* Nothing to estimate if init option and no fixed effects or level-1 variance */
    if $HG_init==1&M_nffc[1,$HG_tpff]==0&$HG_lev1==0{
        disp in re "Nothing to estimate"
        exit 498
    }

    local fit = 0
    if (M_nffc[1,$HG_tpff]>0|$HG_lev1>0)&$HG_init==0&"`from'"==""&$HG_comp==0{
/* initial values for fixed effects using Stata's commands */
        local lnk $HG_link
        if "$HG_link"=="recip"{
            local lnk pow -1
        }
        qui `noi' disp " "
        qui `noi' disp in gr "Initial values for fixed effects"
        if $HG_const&$HG_init==0 { 
            qui `noi' disp in gr "(Not applying constraints at this point)" 
        }
        qui `noi' disp " "
        if ("$HG_famil"=="gauss")&("$HG_link"=="ident")& "`s'"==""{
            tempvar yn
            if "`offset'"~=""{
                quietly gen double `yn' = `y' - $HG_off
            }
            else{
                gen `yn' = `y'
            }
            quietly `noi' reg `yn' `indep' [`ftype'=`wt'], `constant'
            matrix M_initr[1,1]=ln(_result(9))
            local fit = 1
            qui drop `yn'
        }
        else if ($HG_nolog+$HG_oth+$HG_mlog==1)&("$HG_famil"=="binom"|$HG_nolog==1|/*
          */ $HG_mlog==1)&$HG_exp==0{
            local fit = 1
            local mnd = 1
            if "$HG_denom"~=""{
                qui summ $HG_denom, meanonly
                local mnd = r(mean)
            }
            if `mnd'>1 {
                if $HG_mlog>0 {
                    disp in re "can't have denominator > 1 for mlogit"
                    exit 198
                }
                if ($HG_nolog>0) {
                    disp in re "can't have denominator > 1 for ordinal response"
                    exit 198
                }
                qui `noi' glm `y' `indep' [`ftype'=`wt'], link(`lnk') /*
                                             */ fam(binom `denom') `constant' `offset' `log'
            }
            else{
                if "$HG_link"=="logit"{
                    qui `noi' logit `y' `indep' [`ftype'=`wt'], `constant' `offset' `log'
                }
                else if "$HG_link"=="probit"{
                    qui `noi' probit `y' `indep' [`ftype'=`wt'], `constant' `offset' `log'
                }
                else if "$HG_link"=="cll"{
                    qui `noi' cloglog `y' `indep' [`ftype'=`wt'], `constant' `offset' `log'
                }
                else if "$HG_link"=="ll"{
                    tempvar yn
                    qui gen `yn' = 1-`y'
                    qui `noi' cloglog `yn' `indep' [`ftype'=`wt'], `constant' `offset' `log'
                }
                else if $HG_mlog==1{
                    qui `noi' mlogit `y' `indep' [`ftype'=`wt'] if $HG_ind==1, `constant' `basecat' `log'
                }
                else if "$HG_linko"=="ologit"&"`thresh'"==""{
                    qui `noi' ologit `y' `indep' [`ftype'=`wt'], `offset' `log'
                }
                else if "$HG_linko"=="oprobit"&"`thresh'"==""{
                    qui `noi' oprobit `y' `indep' [`ftype'=`wt'], `offset' `log'
                }
                else if "$HG_linko"=="ocll"|"$HG_link"=="sprobit"|"$HG_linko"=="soprobit"|$HG_nolog>1|"`thresh'"~=""{
                    local fit = 0
                }
                else{
                    qui `noi' glm `y' `indep' [`ftype'=`wt'], link(`lnk') /*
                                             */ fam(binom `denom') `constant' `offset' `log'
                    local fit = 1
                }

            }
        }
        else if ("$HG_famil"=="poiss")&("$HG_link"=="log"){
            qui `noi' poisson `y' `indep' [`ftype'=`wt'], `constant' `offset' `log'
            local fit = 1
        }
        else if ("$HG_famil"=="gamma"& M_nbrf[1,1]==1){
            qui `noi' glm `y' `indep' [`ftype'=`wt'], link(`lnk')/*
                */ fam(gamma) `constant' `offset' `log'
            matrix M_initr[1,1]= -ln($S_E_dc)
            local fit = 1
        }
    }       
    if `fit' == 0 &("`from'"==""|$HG_init==1)& (M_nffc[1,$HG_tpff]>0|$HG_lev1>0) { 
/* fit level 1 model using gllamm */
    /* preserve macros */
        qui `noi' disp in green "(using gllamm for inital values)"
        local eqs "$HG_eqs"
        local tprf = $HG_tprf
        local tplv = $HG_tplv
        local tpi = $HG_tpi
        local const = $HG_const
        local link $HG_link
        local linko $HG_linko
        local lev1 = $HG_lev1
        local ngeqs = $HG_ngeqs
        local sprior = $HP_prior
        tempvar keep
        quietly gen int `keep' = $HG_wt1
        quietly replace $HG_wt1 = `wt'
        matrix `mnip' = M_nip
        matrix `mnbrf' = M_nbrf
                local adapt = $HG_adapt


    /* change global macros */
        local frm
        if $HG_init==0{
            global HG_const = 0
        }
        global HG_ngeqs = 0

        if $HG_init==0{
        /* scale of probit usually not identified without random effects */
            global HG_link
            local k: word count `link'
            local kk = 1
            while `kk' <= `k'{
                local ll: word `kk' of `link'
             
                if "`ll'" == "sprobit"{
                    global HG_link "$HG_link probit"
                }
                else{
                    global HG_link $HG_link `ll'
                }
                local kk = `kk' + 1
            }
            *disp in re "links were `link' and are $HG_link"


            global HG_linko
            local k: word count `linko'
            local kk = 1
            while `kk' <= `k'{
                local ll: word `kk' of `linko'
             
                if "`ll'" == "soprobit"{
                    global HG_linko "$HG_linko oprobit"
                }
                else{
                    global HG_linko "$HG_linko `ll'"
                }
                local kk = `kk' + 1
            }
            *disp in re "ordinal links were `linko' and are $HG_linko"

            if $HG_lev1>0{ /* check if any of the families is the normal or gamma*/
                local found = 0
                local k: word count $HG_famil
                local kk = 1
                while `kk'<= `k'{
                    local ll: word `kk' of $HG_famil
                    if "`ll'"=="gauss"| "`ll'"=="gamma"{
                        local found = 1
                    }
                    local kk = `kk' + 1
                }
                if `found'==0{
                    global HG_lev1 = 0
                    matrix M_nbrf = (0)
                }
            }
        }

        matrix M_nip=(1,1\1,1)
        if $HG_lev1>0{
            global HG_eqs $HG_s1
            global HG_tprf=1
            global HG_tpi=1
            global HP_prior=0
        }
        else{
            global HG_eqs
            global HG_tprf=0
            global HG_tpi=1
        }
        if "`from'"~=""{
            local frm `from'
        }
        
        global HG_adapt = 0

    /* fit model for initial values */
        global HG_tplv=1 /* Level 1 model */
        local opt
        if $HG_init{ /* apply constraints if init option is used */
            if $HG_const==1{
                tempname b V
                matrix `b' = M_initf, M_initr
                
                capture ml model d0 gllam_ll $HG_fixe $HG_eqs, /*
                 */  noscvars waldtest(0) nopreserve missing  collinear
                
                *matrix list `b'
                ml init `b', skip    /* uses parameters needed for model above */
                matrix `b' = ML_b    /* unconstrained param., no random effects */

                global HG_coln: colnames(`b')
                global HG_cole: coleq(`b')
                
                if "`from'"~=""& "`long'"~=""{ /* assumes copy option */
                    local nb = colsof(`b')
                    local nf = colsof(`amat')
                    if `nb'~=`nf'{
                        disp in re "from matrix must be dimension " `nb'
                        exit 189
                    } 
                    disp in gr "(copy option assumed for from matrix)"
                    matrix `b' = `amat'
                    matrix coleq `b' = $HG_cole
                    matrix coln `b' = $HG_coln
                }
                                
                matrix `V' = `b''*`b'
                estimates post `b' `V'
                matrix `b' = e(b)
                matrix makeCns `constra'
                qui `noi' disp in gr "Constraints:"
                qui `noi' matrix dispCns
                qui `noi' disp " "
                matcproc M_T M_a M_C
                matrix M_inshrt = `b'*M_T  /* constrained parameters, no r. effects */
                local n = colsof(M_inshrt)
                qui `noi' disp "estimating `n' parameters"
                if "`from'"~=""&"`long'"==""{
                    local nf = colsof(`amat')
                    if `n'~=`nf'{
                        disp in re "from matrix must be dimension " `n'
                        exit 189
                    }
                    matrix M_inshrt = `amat'
                }
                local i = 1
                local lst "`y'"
                gen byte __0066 = 1
                while `i'< `n'{
                    local lst `lst' "eq`i'"
                    local i = `i' + 1
                }
                global HG_eqs
                matrix coleq M_inshrt = `lst'
                matrix colnames M_inshrt = __0066
                               
                local frm "from(M_inshrt)"

                matrix coleq M_inshrt = `lst'
                matrix colnames M_inshrt = __0066 
                local n = colsof(M_inshrt)
                    global HG_fixe (`y': `y' =__0066, nocons)
                local i = 1
                while `i'< `n'{
                    global HG_fixe $HG_fixe (eq`i': __0066, nocons)
                    local i = `i' + 1
                }
            }
            local opt `options'
        }
        
        *  noi
        qui `noi' hglm_ml `y',  /*
           */  $HG_obs `log' title("fixed effects model") /*
           */ `frm' `trace' skip `difficult' `opt' `copy' `iterate' `eval'
        local fit = 1
        if $HG_init==0 {
            quietly `noi' ml display, level(`level') nohead
        }

        if $HG_init{
            if $HG_error==0{
                if "`eval'"~=""{
                    local robust
                    local cluster
                    local pw
                }
                noi prepare, `robust' `cluster' `pw' `dots' `noi'
                * disp in re "running delmacs"
                delmacs
                restore
                estimates repost, esample(`touse')
                estimate local cmd "gllamm"
                estimate local predict "gllapred"
                * disp in re "running replay"
                noi Replay, level(`level') `eform' `allc' `robust' `cluster' `display' `eval'
                exit 0
            }
        }

        if $HG_lev1>0{
            local num=M_nbrf[1,1]
            matrix `mat'=e(b)
            if $HG_nats{
                matrix `mat'=`mat'[1,"s1:"]
            }
            else{
                matrix `mat'=`mat'[1,"lns1:"]
            }
            local i=1
            while `i'<=`num'{
                matrix M_initr[1,`i']=`mat'[1,`i']
                local i=`i'+1
            }
        }
        if $HG_init{
            delmacs
            restore
            estimates repost, esample(`touse')
            estimate local cmd "gllamm"
            estimate local predict "gllapred"
            exit 0
        }

    /* restore global macros */
        global HG_tplv=`tplv'
        global HG_eqs "`eqs'"
        global HG_tprf=`tprf'
        global HP_prior=`sprior'
        global HG_tpi=`tpi'
        global HG_link "`link'"
        global HG_linko "`linko'"
        global HG_ngeqs = `ngeqs'
        quietly replace $HG_wt1=`keep'
        matrix M_nip=`mnip'
        matrix M_nbrf = `mnbrf'
        global HG_const = `const'
        global HG_lev1 = `lev1'
                global HG_adapt = `adapt'

    }
    if `fit'{
    /* put estimates in `b' */
        local cn: colnames(M_initf)
        local ce: coleq(M_initf)
        matrix M_initf=e(b)
        capture matrix colnames M_initf = `cn'
        capture matrix coleq M_initf = `ce'
        local num=M_nffc[1,$HG_tpff]
        if `num'>0 {
            local nn=colsof(M_initf)
            if `nn'<`num'{
                disp in re "variables have been dropped, can't continue"
                exit 198
            }
            matrix M_initf=M_initf[1,1..`num']
            * matrix list M_initf
        }
        if $HG_const==1{
            matrix `b' = nullmat(M_initf), nullmat(M_initr)
            matrix M_inshrt = `b'*M_T
        }
        if $HG_error==1{
            exit
        }
    }
/* estimation */

    *qui `noi' disp in smcl in gr "{hline 78}" _n
    qui `noi' di in gr _dup(78) "-" _n
    qui `noi' dis
    qui `noi' dis "start running on $S_DATE at $S_TIME"

* check this:
    *local skip
    if $HG_const==1{
        matrix coleq M_inshrt = `lst'
        matrix colnames M_inshrt = __0066 
        local n = colsof(M_inshrt)
            global HG_fixe (`y': `y' =__0066, nocons)
        local i = 1
        while `i'< `n'{
            global HG_fixe $HG_fixe (eq`i': __0066, nocons)
            local i = `i' + 1
        }
    }

    * disp "`trace' `options' "
        * disp "$HG_obs `log' `from'"
    * disp "`search' `lf0' `gateaux' `skip' `difficult' `eval' "

/* means and sds for adapt */
    if $HG_adapt{
        local rf = 1
        while `rf'<=$HG_tprf{
            tempname junk
            global HG_MU`rf' "`junk'"
            tempname junk
            global HG_SD`rf' "`junk'"
            gen double ${HG_MU`rf'}=0
            gen double ${HG_SD`rf'}=1
            local rf2 = `rf' + 1
            while `rf2' < $HG_tprf {
                tempname junk
                global HG_C`rf2'`rf' "`junk'"
                gen double ${HG_C`rf2'`rf'}=0
                local rf2 = `rf2' + 1
            }
            local rf = `rf' + 1
        }

    }

    * noi capture noi
    capture noi hglm_ml `y', `trace' `options' /*
        */ $HG_obs `log' title("gllamm model") `from' `iterate'/*
        */ `search' `lf0' `gateaux' `skip' `copy' `difficult' `eval' 
    if _rc>0{ global HG_error=1 }
        
    qui `noi' dis "finish running on $S_DATE at $S_TIME"
    qui `noi' dis "  "
    if $HG_error==0{
        if "`eval'"~=""{ /* do not want to compute robust standard errors */
            local robust
            local cluster
            local pw
        }
        noi prepare, `robust' `cluster' `pw' `dots' `noi'
        * disp "running delmacs"
        delmacs
        * disp "restore"
        restore
        estimates repost, esample(`touse')
        estimate local cmd "gllamm"
        estimate local predict "gllapred"
        * disp "running replay"
        noi Replay, level(`level') `eform' `allc' `robust' `cluster' `display' `eval'
    }   
end

program define prepare
syntax [, ROBUST CLUSTER(varname) PWEIGHT DOTS NOISILY]
* disp "options are: `robust' `cluster' `pweight' `dots' `noisily'"
    tempname b v X U
    matrix `b' = e(b)
    local n = colsof(`b')
    matrix M_Vs = e(V)
    capture matrix `v' = inv(M_Vs)
    if _rc==0{
        matrix symeigen `X' `U' = `v'
        global HG_cn = sqrt(`U'[1,1]/`U'[1,`n'])
    }
    else{
        global HG_cn = -1
    }
    if $HG_const {
        matrix M_Vs  = M_T*M_Vs*M_T'
    }

/* deal with robust */

    if "`robust'"~=""|"`cluster'"~=""|"`pweight'"~=""{
        if "`cluster'"~=""{
            global HG_rbcls "`cluster'"
            *disp "HG_rbcls is $HG_rbcls"
            local cluster cluster(`cluster')
        }
        * disp "calling gllarob"
        qui `noisily' gllarob, first macs `cluster' `dots'
    }
    * disp "HG_const = " $HG_const
    * disp "running remcor"

    qui remcor `b'

    if $HG_const {
    * disp "running procstr"
        qui procstr
    }
end

program define hglm_ml
    version 6.0
    syntax  varlist(min=1)[, TITLE(passthru) LF0(numlist) noLOg TRace /*
    */ OBS(passthru) FROM(string) SEarch(integer 0) Gateaux(numlist min=3 max=3) skip copy/*
    */ noDIFficult EVal ITerate(numlist) *]

    *disp in re "running hglm_ml"
    *disp in re "iterate: `iterate'"

    if "`log'"=="" { 
        local log "noisily" 
    }
    else{
        local log
    }   

    if "`trace'"~="" {
        local noi "noisily" 
    }

    parse "`varlist'", parse(" ")
    local y "`1'"

        tempvar mysamp
        tempname b f V M_init M_initr a lnf mlnf ip deriv

    local adapt = $HG_adapt

    if "`from'"~=""{
        matrix `M_init'=`from'
        if "`eval'"~=""|`adapt'==1{

            *noi disp "$HG_fixe $HG_eqs"
            ml model d0 gllam_ll $HG_fixe $HG_eqs, /*
             */  noscvars waldtest(0) nopreserve missing  collinear

            *disp  "ml init M_init, `skip' `copy'"
            ml init `M_init', `skip' `copy'
            matrix ML_g=ML_b

            if `adapt'==0{
                qui `noi' capture ml maximize, search(off) /*
                */  iterate(0) novce nooutput nowarn /* `options' */
                disp in gr "log-likelihood = " in ye e(ll)
                exit 0
            }
            else{
                matrix `M_init' = ML_b
                global ML_y1 `y'
                noi gllam_ll 1 "`M_init'" "`lnf'" "junk" "junk" 1
            }
            * matrix list `M_init'
        }
        if "`gateaux'"~=""&$HG_free==0{
            disp in re "option gateaux not allowed (ignored) for fixed integration points"
        }
        else if "`gateaux'"~=""&$HG_free==1{
            qui `noi' disp in gr "Gateaux derivative"
            if $HG_tplv>2{
                disp "searching for additional point at level " $HG_tplv
            }
            local ll=$HG_tplv-1
            local tprf=M_nrfc[2,$HG_tplv]-M_nrfc[2,`ll']  /* number of locations */
            capture local mf = colsof(M_initf)
            if _rc>0 {local mf = 0}
            capture local mr = colsof(M_initr)
            if _rc>0 {local mr = 0}
            if $HG_const{
                local nreq = colsof(M_inshrt) - `tprf' - 1
                local cn: colnames(M_inshrt)
                local ce: coleq(M_inshrt)
            }
            else{
                local nreq = `mf'+`mr'-`tprf'-1
            }

            if `nreq'~=colsof(`M_init'){
                disp in re "initial value vector should have length `nreq'"
                matrix list `from'
                global HG_error=1
                exit 198
            }

            *set trace on
            local l = `mr' - `tprf'-1 /* length of previous M_initr */
            local locp = $HG_befB - `mf' 
            local beg = `locp'-`tprf'  /* position of first new mass-point parameter */
            * matrix list M_initr
            matrix `a' = M_initr[1,`beg'..`locp']  /* new mass-point parameters */
            * noi disp "new mass-point par"
            * matrix list `a'

            if $HG_cip==0{  /* new point is one before last since last has no prob. par. */
                local locp = `locp' - `tprf'
            }

            local befB = $HG_befB - `tprf' - 1  /* befB for previous parameter vector */
            global HG_befB
            if `nreq' > `befB' {
                matrix `M_init' = `M_init'[1,1..`befB'],`a',`M_init'[1,`befB'+1...]
            } 
            else {
                matrix `M_init' = `M_init'[1,1..`befB'],`a'
            }
            * matrix list `M_init'
            local locp = `mf' + `locp'
            *disp "position of new p-parameter = " `locp'
            local nreq = `locp' - `tprf' -1
            *disp "position of first new location parameter = " `nreq'+1

            if $HG_cip==0{
                                * new point must be one before last since new probability tiny
                local jl = 1
                while `jl'<=`tprf'{
                    matrix `M_init'[1,`locp'+`jl']=`M_init'[1,`nreq'+`jl']
                    local jl = `jl' + 1
                }
            }
            *matrix list `M_init'


            tokenize "`gateaux'"
            local min = `1'
            local max = `2'
            local num = `3'
            local stp = (`max'-`min')/(`num'-1)
            matrix `M_init'[1,`locp']=-6 /* mass of new masspoint */
            scalar `mlnf'=0
            matrix `ip'=M_ip
            matrix `ip'[1,1]=1
            *recursive loop
            matrix `ip'[1,`tprf']=1
            local k = `nreq' + `tprf' 
            matrix `M_init'[1,`k']=`min'
            local nxtrf = `tprf'+1
            matrix `ip'[1,`nxtrf']=`num'
            local rf = `tprf'
            while `rf' <= `tprf'{
                *reset ip up to random effect `rf'
                while (`rf'>1) {
                    local rf = `rf'-1
                    matrix `ip'[1,`rf'] = 1
                    local k = `nreq' + `rf'
                    matrix `M_init'[1,`k']=`min'
                }
                * update lowest digit
                local rf = 1 
                while `ip'[1,`rf'] <= `num'{
                    local k = `nreq' + `rf'
                    matrix `M_init'[1,`k'] = `min' + (`ip'[1,`rf']-1)*`stp'
                    * matrix list `M_init'
                    global ML_y1 `y'
                    gllam_ll 0 "`M_init'" "`lnf'"
                    noi di in gr "." _c
                    * noisily disp "likelihood=" `lnf'
                    if (`lnf'>`mlnf'|`mlnf'==0)&`lnf'~=.{ 
                        scalar `mlnf'=`lnf'
                        matrix M_initr=`M_init'
                    }
                    matrix `ip'[1,`rf'] = `ip'[1,`rf'] + 1
                }
                matrix `ip'[1,`rf'] = `num' /* lowest digit has reached the top */
                while `ip'[1,`rf']==`num'&`rf'<=`tprf'{
                    local rf = `rf' + 1
                }
                * rf is first r.eff that is not complete or rf>nrf
                if `rf'<=`tprf'{
                    matrix `ip'[1,`rf'] = `ip'[1,`rf'] + 1
                    local k = `nreq' + `rf'
                    matrix `M_init'[1,`k'] = `min' + (`ip'[1,`rf']-1)*`stp'
                }
            }
            if "`lf0'"~=""{
                local junk: word 2 of `lf0'
                * disp in re "junk = " `junk'
                * disp in re "mlnf - lf0 is " `mlnf' " - " `junk'
                scalar `deriv' = `mlnf'-`junk'
                disp " "
                disp in ye "maximum gateaux derivative is " `deriv'
                * matrix list `M_initr'
                if `deriv'<0.00001{
                    disp in re "maximum gateaux derivative less than 0.00001"
                    global HG_error=1
                    exit
                }
            }
            else{
                disp in ye "no gateaux derivarives could be calculated without lf0() option"
                matrix list `M_initr'
            }

            matrix `M_init' = M_initr
* starting log odds for new location
            matrix `M_init'[1,`locp']=-3
            if $HG_const{
                matrix colnames `M_init' = `cn'
                matrix coleq `M_init' = `ce'
            }
            * matrix list `M_init'
        } /* end if gateaux */      
    } /* end if from */
    else{ /* no from() */
        if "`gateaux'"~=""{ 
            disp in red "gateaux can't be used without option from()"
            exit 198
        }
        if "`eval'"~=""{
            disp in red "eval option only allowed with from()"
            exit 198
        }
        capture matrix `M_init'=M_initf
        if $HG_tprf|$HG_lev1>1{
            matrix `M_initr'=M_initr
            local max=3
            local min=0
            scalar `mlnf' = 0
            local f1= M_nbrf[1,1]+1
            local l=colsof(M_initr)
            local m=1
            if `search'>1{
                if $HG_const==1{
                    disp in re "search option does not work yet with constraints"
                    exit 198
                }
                else{
                    qui `noi' disp in gr /*
                    */ "searching for initial values for random effects"
                    qui `noi' disp "likelihood:"
                }
            }
            while `m'<=`search'{ /* begin search */
                * matrix list M_initr
                matrix `a'=`M_init',M_initr
                *matrix list `a'
                global ML_y1 `y'
                noisily gllam_ll 0 "`a'" "`lnf'"

                    qui `noi' disp in ye %10.0g `lnf' " " _c
                            if mod(`m',6)==0 {qui `noi' disp }

                *qui `noi' disp "likelihood=" `lnf'
                if (`lnf'>`mlnf'|`m'==1)&`lnf'~=. { 
                    scalar `mlnf'=`lnf'
                    matrix `M_initr'=M_initr
                }
                local k=`f1'
                while `k'<=`l'{
                    matrix M_initr[1,`k']=`min' + (`max'-`min')*uniform()
                    local k=`k'+1
                }
                local m = `m' + 1
            } /* end search */
            matrix `M_init' = nullmat(`M_init'),`M_initr'
        }
        if $HG_const{
            matrix `M_init' = M_inshrt
        }
    }
    if "`difficult'"~=""{
        local difficu /* erase macro */
    }
    else{
        local difficu "difficult" /* default */
    }
    * disp "$HG_fixe $HG_eqs, init(`M_init',`skip') "
    * disp "`lf0' `obs' `trace' `difficu' `options'"
    *matrix list `M_init'
    if "`lf0'"~="" { local lf0 "lf0(`lf0')" }

    * matrix list `M_init'

    if `adapt'{
        tempname pa1
        tempname pa2
        tempname ad1
        tempname ad2 ad0

        * global HG_adapt=0
        global ML_y1 `y'
        if "`from'"==""{
            noi gllam_ll 1 "`M_init'" "`lnf'" "junk" "junk" 1
        }
        scalar `ad2' = `lnf'
    
        scalar `ad1' = 0
        local i = 2

        qui `log' di in gr _n "Running adaptive quadrature"
        qui `noi' di in gr _dup(78) "-" _n "Iteration 0 of adaptive quadrature:"
        *qui `noi' di in smcl in gr "{hline 78}" _n "Iteration 0 of adaptive quadrature:"
        qui `noi' di in gr "Initial parameters:" _n
        qui `noi' mat list `M_init', noheader noblank format(%9.0g)

/* first calculation of adaptive quadrature points ==> ad2 */ 

        global HG_adapt=1
        qui `noi' disp in gr _n "Updated log likelihood:"
        qui `noi' disp in ye %10.0g `ad2' " " _c
        while abs((`ad1'-`ad2')/`ad2')>1e-8&`i'<120&`ad2'~=.{
                scalar `ad1' = `ad2'
                noi gllam_ll 1 "`M_init'" "`ad2'" "junk" "junk" 1
                qui `noi' disp in ye %10.0g `ad2' " " _c
                        if mod(`i',6)==0 {qui `noi' disp }
            local i = `i' + 1
        }
        if `i'>=120{
            disp in re "Convergence not achieved: try with more quadrature points"
            global HG_error=1
            exit 
        }
        if `ad2'==.{
            disp in re "Log-likelihood cannot be computed"
            global HG_error=1
            exit
        }
    
        qui `noi' di in gr _n _col(52) "log likelihood = " in ye %10.0g /*
        */ scalar(`ad2')
        
        if "`noi'"==""{
            qui `log' di in gr "Iteration 0:    log likelihood = " in ye %10.0g /*
            */ scalar(`ad2')
        }

        if "`eval'"~=""{
            qui `noi' di in gr _dup(78) "-"
            *qui `noi' di in smcl in gr "{hline 78}" 
            di in gr "log likelihood = " in ye %10.0g /*
                */ scalar(`ad2') _n
                
            qui `noi' capture ml maximize, search(off) /*
            */  iterate(0) novce nooutput nowarn  /* `options' */
            
            *delmacs
                *exit 1
            exit 0
        }
        
        if "`iterate'"~=""{
        local iter=`iterate'
        }
        else{
            local iter=150
        }
        

        global HG_adapt=1


/* loop, update parameters then adaptive quadrature */

        capture `log' ml model d0 gllam_ll $HG_fixe $HG_eqs, /*
         */  noscvars `lf0' `obs' `title' /*
         */ waldtest(0) nopreserve missing  collinear   

        if `iter'==0{
            qui `noi' di in gr _dup(78) "-"
            disp in green "Adaptive quadrature has not converged"
            
            ml init `M_init', `skip' `copy'
            
            capture ml maximize, search(off) `difficu' /*
            */ `trace' iterate(0) nolog /*
            */   nooutput noclear  /* `options' */
            exit 0        
        }

        local it = 0
        scalar `ad0' = `ad2'*1.2
        scalar `pa2' = 0
        local only1 iteronly1
        local fst = 0

        while abs((`ad0'-`ad2')/`ad0')>1e-6&`it'<`iter'{
            scalar `ad0' = `ad2'
            local it = `it' + 1
            qui `noi' di in gr _dup(78) "-" _n "Iteration `it' of adaptive quadrature:"
            *qui `noi' di in smcl in gr "{hline 78}" _n "Iteration `it' of adaptive quadrature:"
            qui `noi' disp in gr "Updated parameters:" _n

/* update parameters ==> pa2 */
            
            ml init `M_init', `skip' `copy'
            *ml report

            * noi capture noi
            capture ml maximize, search(off) `difficu' /*
            */ `trace' iterate(1)  nolog /* 
            */   nooutput noclear `only1'  hessian gradient /* `options' */
            * 

            local rc = _rc
            if `rc' == 198&`fst'==0{ 
                local only1
                *noi capture noi
                capture ml maximize, search(off) `difficu' /*
                    */ `trace' iterate(1) nolog   /*
                    */  nooutput noclear `only1'  /* `options' technique(bfgs)  */
                local rc = _rc
                local fst = 1
            }
            if `rc'>1 {
                di in red "(error occurred in ML computation)"
                di in red "(use trace option and check correctness " /*
                            */ "of initial model)"
                global HG_error=1
                exit `rc'
                        }

            qui `noi' mat list $ML_b, noheader noblank format(%9.0g)
            qui `noi' di /* blank line */

                        scalar `pa1' = `pa2'
                        scalar `pa2' = e(ll)
                        matrix `M_init'=e(b)

/* update adaptive quadrature ==> ad2 */

            local j = 2
            scalar `ad1' = `pa2'

            qui `noi' disp in gr "Updated log likelihood: "
            qui `noi' disp in ye %10.0g `ad1' " " _c

            while (abs((`ad1'-`ad2')/`ad2')>1e-8)&`j'<120&`ad2'~=.{
                    global ML_y1 `y'
                    scalar `ad1' = `ad2'
                    noi gllam_ll 1 "`M_init'" "`ad2'" "junk" "junk" 1
                    qui `noi' disp in ye %10.0g `ad2' " " _c
                    if mod(`j',6)==0 { qui `noi' disp }                                     
                    local j = `j' + 1
            }
            if `ad2'==.{
                disp in re "Log-likelihood cannot be computed"
                global HG_error=1
                exit
            }
            qui `noi' di in gr _n _col(52) "log likelihood = " in ye %10.0g /*
            */ scalar(`ad2')

            if "`noi'"==""{
            qui `log' di in gr "Iteration " `it' ":    log likelihood = " in ye %10.0g /*
            */ scalar(`ad2')
            }

            *qui `noi' disp in gr "log-likelihood is " in ye `ad2' in gre /* 
            */ " and was " in ye `ad0' in gre ", relative change: " /*
            */  in ye abs((`ad2'-`ad0')/`ad0')  
        }
        qui `noi' di in gr _dup(78) "-" _n
        *qui `noi' di in smcl in gr "{hline 78}" _n 

        *tempname v
        *capture matrix `v'=e(V)
        *capture matrix `v' = inv(`v')
        *if _rc>0{
            if `it'==`iter'&((`ad0'-`ad2')/`ad0')>1e-6 {
                disp in green "Adaptive quadrature did not converge in `iter' iterations"
                exit 0
            }
            qui `log' disp in gr _n _n "Adaptive quadrature has converged, running Newton-Raphson" _c
            ml init `M_init', skip copy
            capture `log' ml maximize, search(off) `difficu' /*
                */ `trace' nooutput iterate(`iter') /* `options' */
                    local rc = _rc
                if `rc'>1 {
                   di in red "(error occurred in ML computation)"
                   di in red "(use trace option and check correctness " /*
                   */ "of initial model)"
                   global HG_error=1
                   exit `rc'
                }
        *}
    }
    else{ /* not adaptive */
        if "`iterate'"~=""{
            local iter "iterate(`iterate')"
        }
        else{
            local iter
        }
        capture `log' ml model d0 gllam_ll $HG_fixe $HG_eqs, /*
         */ maximize search(off) /*
         */ init(`M_init', `skip' `copy') noscvars `lf0' `obs' `title' `trace' /*
         */ waldtest(0) nopreserve missing `difficu' collinear `iter'/* `options' */
             * technique(bfgs) gtol(1e-4)
    }

    local rc = _rc
    if `rc'>1 {
        di in red "(error occurred in ML computation)"
        di in red "(use trace option and check correctness " /*
        */ "of initial model)"
        global HG_error=1
        exit `rc'
    }
    if `rc'==1 {
        di in red /*
        */ "(Maximization aborted)"
        delmacs
        global HG_error=1
        exit 1
    }
    else if $HG_error==1{
        disp in red "some error has occurred"
        exit
    }
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

program define delmacs, eclass
    version 6.0
/* deletes all global macros and matrices and store some results in e()*/
    tempname var
    if "$HG_tplv"==""{
        * macros already gone
        exit
    }
    local nrfold = M_nrfc[2,1]
    local lev = 2
    while (`lev'<=$HG_tplv){
        local i2 = M_nrfc[2,`lev']
        local i1 = `nrfold'+1
        local i = `i1'
        local nrfold = M_nrfc[2,`lev']
        local n = M_nrfc[1,`lev']
        local n = M_nip[2,`n']
        capture est matrix zps`n' M_zps`n'
        while `i' <= `i2'{
            local n = M_nip[2,`i']
            capture est matrix zlc`n' M_zlc`n'
            capture est matrix zps`n' M_zps`n'
            local i = `i' + 1
        }
        local lev = `lev' + 1
    }


    if $HG_free==0&$HG_init==0{
        est matrix chol CHmat
    }
    if $HG_free{
        est matrix mnp M_np
    }
    est matrix nrfc M_nrfc
    est matrix nffc M_nffc
    est matrix nbrf M_nbrf
    est matrix nu M_nu
    capture est matrix Vs M_Vs
    capture est matrix mresp M_resp
    capture est matrix mrespm M_respm
    capture est matrix frld M_frld
    if $HG_ngeqs>0{
        est matrix mngeqs M_ngeqs
    }
    matrix drop M_ip
    est matrix nip M_nip
    capture est matrix mb M_b
    matrix drop M_znow
    capture matrix drop M_initf
    capture matrix drop M_initr
    capture matrix drop M_chol
    capture est matrix mb M_b
    est matrix olog M_olog
    capture est matrix moth M_oth
    if $HG_const == 1{
        capture drop __0066
        est matrix a M_a
        * est matrix C M_C
        est matrix T M_T
        est local coln $HG_coln
        est local cole $HG_cole
        global HG_coln
        global HG_cole
    }

    /* globals defined in gllam_ll */
    local i=1
    while (`i'<=$HG_tpff){
        global HG_xb`i'
        local i= `i'+1
    }
    local i = 1
    while (`i'<=$HG_tprf){
        global HG_s`i'
        local i= `i'+1
    }
    local i = 1
    while (`i'<=$HG_tplv){
        global HG_wt`i'
        local i = `i' + 1
    }
    if $HG_adapt{
        macro drop HG_zuoff
        macro drop HG_SD*
        macro drop HG_MU*
        macro drop HG_E*
        macro drop HG_V*
        macro drop HG_C* 
    }
    
    macro drop HG_zip
    macro drop HG_lzpr
    est local nats=$HG_nats
    global HG_nats
    est local noC=$HG_noC
    global HG_noC
    est local noC1=$HG_noC1
    global HG_noC1
    global HG_noC2
    est local adapt=$HG_adapt
    global HG_adapt
    est local const = $HG_const
    global HG_const
    global HG_fixe
    est local inter = $HG_inter
    global HG_inter
    global HG_dots
    est local ngeqs = $HG_ngeqs
    global HG_ngeqs
    est local nolog = $HG_nolog
    if $HG_nolog>0{ 
        est local k_eform = 1 /* controls how many eqns are exponentiated */
    }
    else{
        est local k_eform = $HG_tpff
    }
    global HG_nolog
    est local ethr = $HG_ethr
    global HG_ethr
    est local mlog = $HG_mlog
    global HG_mlog
    est local smlog = $HG_smlog
    global HG_smlog
    global HG_lvolo
    est local oth = $HG_oth
    global HG_oth
    est local lev1 = $HG_lev1
    global HG_lev1
    est local bmat = $HG_bmat
    global HG_bmat
    est local tplv = $HG_tplv
    global HG_tplv 
    est local tprf = $HG_tprf
    global HG_tprf
    est local prior = $HP_prior
    if $HP_prior == 1{
            local a_ll = `e(ll)' - $HP_res
            est local a_ll = `a_ll'
            est local lpr = $HP_res
            global HP_res

            if $HP_invga==1{
                est local invga $HP_invga
                est local shape $shape
                est local rate $rate
                global HP_invga
                global shape
                global rate
            }
            if $HP_invwi==1{
                est local invwi $HP_invwi
                est local df $df
                est matrix scale scale
                global HP_invwi
                global df
            } 
            if $HP_foldt==1{
                est local foldt $HP_foldt
                est local df $df
                est local scale $scale
                est local location $location
                global HP_foldt
                global df
                global scale
                global location
            }
            if $HP_logno==1{
                est local logno $HP_logno
                est local meanlog $meanlong
                est local sdlog $sdlog
                global HP_logno
                global meanlog
                global sdlog
            }
            if $HP_gamma==1{
                est local gamma $HP_gamma
                est local scale $HP_scale
                est local var $HP_var
                est local shape $HP_shape
                global HP_gamma
                global HP_scale
                global HP_var
                global HP_shape
            }
            if $HP_corre==1{
                est local corre $HP_corre
                est local alpha $alpha
                est local beta $beta
                global HP_corre
                global alpha
                global beta
            }
            if $HP_boxco==1{
                est local boxdo $HP_boxco
                est local scale $scale
                est local lambda $lambda
                global HP_boxco
                global scale
                global lambda
            }
            if $HP_spect==1{
                est local spect $HP_spect
                est local alpha $alpha
                est local beta $beta
                global HP_spect
                global alpha
                global beta
            }
            if $HP_wisha==1{
                est local wisha $HP_wisha
                est local df $df
                est matrix scale scale
                global HP_wisha
                global df
            }
    
    }
    global HP_prior
    est local tpi = $HG_tpi
    global HG_tpi
    est local tpff = $HG_tpff
    global HG_tpff
    est local clus "$HG_clus"
    global HG_clus
    est local weight "$HG_weigh"
    global HG_weigh
    est local pweight "$HG_pwt"
    global HG_pwt
    global which   
    global HG_gauss 
    est local free = $HG_free 
    global HG_free
    est local mult = $HG_mult
    global HG_mult 
    est local cip = $HG_cip
    est local famil "$HG_famil"
    global HG_famil 
    est local link "$HG_link"
    global HG_link 
    est local linko "$HG_linko"
    global HG_linko
    capture est local exp $HG_exp
    global HG_exp
    capture est local expf $HG_expf
    global HG_expf
    est local lv "$HG_lv"
    global HG_lv
    est local fv "$HG_fv"
    global HG_fv
    global HG_nump
    global HG_eqs
    global HG_obs
    est local offset "$HG_off"
    global HG_off
    est local denom "$HG_denom"
    global HG_denom
    est local cor = $HG_cor
    global HG_cor
    est local s1 "$HG_s1"
    global HG_s1
    capture est local init $HG_init
    global HG_init
    capture est local ind "$HG_ind"
    global HG_ind
    capture est local comp $HG_comp
    global HG_comp
    capture est local coall "$HG_coall"
    global HG_coall
    capture est local cn = $HG_cn
    global HG_cn
    capture est local robclus "$HG_rbcls"
    global HG_rbcls
    global HG_befB
    global HG_cip
end

program define initmacs
version 6.0
/* defines all global macros */
args nrf nip eqs geqs peqs s nats bmatrix touse dep frload

tempname mat

disp "  "
disp in gr "Random effects information for" in ye " $HG_tplv" in gr " level model"
*disp in smcl in gr "{hline 78}" _n
di in gr _dup(78) "-" _n

/* deal with nrf */
    matrix M_nrfc=J(2,$HG_tplv,1)
    if "`nrf'"==""|$HG_free|$HG_mult{
        local k=1
        while (`k'<=$HG_tplv){
            matrix M_nrfc[1,`k']=`k'
            matrix M_nrfc[2,`k']=`k'
            local k=`k'+1
        }
    }
    if "`nrf'"~=""{
        local greater = 0
        local k: word count `nrf'
        if `k'~=$HG_tplv-1 {
            if $HG_tplv==1{
                disp in red "option nrf is meaningless for 1-level model"
            }
            else{
                disp in red "option nrf() does not contain " $HG_tplv-1 " argument(s)"
            }
            exit 198
        }
        parse "`nrf'", parse(" ")
        local k=2
        while (`k'<=$HG_tplv){
            matrix M_nrfc[2,`k']=`1'
            if `1'>1{
                local greater=1
            }
            local k=`k'+1
            mac shift
        }
        /* make cumulative */
        local k=2
        while (`k'<=$HG_tplv){
            matrix M_nrfc[2,`k']=M_nrfc[2,`k'-1]+M_nrfc[2,`k']
            if $HG_free==0&$HG_mult==0{matrix M_nrfc[1,`k']=M_nrfc[2,`k']}
            local k=`k'+1
        }
        if `greater'>0{
            if "`eqs'"==""{
                disp in re "eqs() option required"
                exit 198
            }
        }
    }
    * matrix list M_nrfc
    global HG_tprf=M_nrfc[2,$HG_tplv] /* number of random effects */
    global HG_tpi=M_nrfc[1,$HG_tplv] /* number of integration loops + 1 */
    if $HG_tplv==$HG_tprf{
        if $HG_cor==0{
            disp "option nocorrel ignored because no multiple r. effects per level"
        }
    }


/* deal with nip and set up zloc and zps */

    if "`nip'"~=""{
        local k: word count `nip'
        if `k'==1{
           if `nip' == 1{
            matrix M_nip=J(2,$HG_tprf,1)
            if $HG_free {
                if $HG_cip==1 {
                    global HG_init=1
                }
            }
            else{
                disp in re "(co)variances of latent variables will not be identified with nip(1)"
                ghquad 1
            }
           }
        }

        if `k'>1 | $HG_tpi == 2 {
            if `k'~=$HG_tpi-1{
                disp in red "option nip() has `k' arguments, need 1 or " $HG_tpi-1
                exit 198
            }
            matrix M_nip=J(2,$HG_tprf,1)
            local i=1
            while `i'<$HG_tpi{
                local k: word `i' of `nip'
                local l = `i' + 1
                matrix M_nip[1,`l']= `k'
                if $HG_mult{
                    * disp in re "k = `k'"
                    local n = M_nrfc[2,`l'] - M_nrfc[2,`l'-1]
                    if `n'>1 {
                        mint `n' `k'
                        matrix M_nip[1,`l'] = $S_1
                    }
                    else{
                        local kk = (`k' + 1)/2
                        if int(`kk')~=`kk'{
                            disp in re "arguments in nip() option must be odd with ip(m)" 
                            exit 198
                        }
                        ghquad `kk'
                        matrix M_nip[1,`l']= `kk'
                    }
                }
                else if $HG_free==0{
                    if $HG_gauss{
                        ghquad `k'
                    }
                    else{
                        lebesque `k'
                    }
                }
                local i = `i' + 1
            } /* end i */
        } 
        else{ /* one argument given for more than one loop */
            matrix M_nip=J(2,$HG_tprf,`nip')
            matrix M_nip[1,1] = 1
            if $HG_mult{
                local l = 2
                while `l' <= $HG_tpi{
                    local n = M_nrfc[2,`l'] - M_nrfc[2,`l'-1]
                    if `n'>1{
                        mint `n' `nip'
                        matrix M_nip[1,`l'] = $S_1
                    }
                    else{
                        local kk = (`nip' + 1)/2
                        if int(`kk')~=`kk'{
                            disp in re "arguments in nip() option must be odd with ip(m)" 
                            exit 198
                        }
                        ghquad `kk'
                        matrix M_nip[1,`l']= `kk'
                    }
                    local l = `l' + 1
                }
            }
            else if $HG_free==0{
                if $HG_gauss{
                    ghquad `nip'
                }
                else{
                    lebesque `nip'
                }
            }   
        }
    }
    else{ /* no nip argument given */
        matrix M_nip=J(2,$HG_tprf,8)
        matrix M_nip[1,1] = 1
        if $HG_mult{
            local l = 2
            while `l' <= $HG_tpi{
                local n = M_nrfc[2,`l'] - M_nrfc[2,`l'-1]
                if `n'>1{
                    sphern `n'
                    matrix M_nip[1,`l'] = $S_1
                }
                else{
                    matrix M_nip[1,`l'] = 8
                    ghquad 8    
                }
                local l = `l' + 1
            }
        }
        else if $HG_free==0{
            if $HG_gauss{
                ghquad 8
            }
            else{
                lebesque 8
            }
        }
    }

    local i = M_nrfc[2,1]+1
    while `i'<= $HG_tprf{
        if $HG_free{
            matrix M_nip[2,`i'] = `i'
        }
        else{
            matrix M_nip[2,`i'] = M_nip[1,`i']
        }
        local i = `i' + 1
    }           

    * noi matrix list M_nip
    capture matrix drop M_initr
    
    *matrix M_zlc8 = J(1,8,1)
    *matrix M_zps8 = J(1,8,ln(1/8))
    
/* deal with Eqs */
    matrix M_frld = J(1,$HG_tprf,0)
    local depv `dep'
    matrix M_nbrf=(0)
    global HG_eqs
    global HG_nats = 0
    local lns1 lns1
    local log log
    if $HG_lev1>0{
        if "`nats'"~=""{
            global HG_nats = 1
            local lns1 s1
            local log
        }
        disp in gr "***level 1 equation:"
        if "`s'"~=""{
            eq ? "`s'"
            local vars "$S_1"
            markout `touse' `vars'
            global HG_eqs "$HG_eqs (`lns1': `depv' `vars',nocons)"
            global HG_s1 "(`lns1': `depv' `vars',nocons)"

        }
        else{
            local vars "_cons"
            global HG_eqs "$HG_eqs (`lns1': `depv')"
            global HG_s1 "(`lns1': `depv')"
        }
        local depv
        disp " "
        if $HG_lev1==1{disp in gr "   `log' standard deviation"}
        else if $HG_lev1==2{disp in gr "   `log' coefficient of variation"}
        else if $HG_lev1==3{disp in gr "   `log'(sqrt(phi))"}
        disp in ye "   `lns1': `vars'"
        local num: word count `vars'
        matrix M_nbrf=(`num')
        matrix `mat'=J(1,`num',-1)
        matrix colnames `mat'=`vars'
        matrix coleq `mat'=`lns1'
        matrix M_initr=nullmat(M_initr),`mat'
    }
    else{
        matrix M_nbrf=(0)
        if "`s'"~=""{
            disp in re "s() option ignored because families do not include dispersion parameters"
        }
        if "`nats'"~=""{
            disp in re "nats option ignored because families do not include dispersion parameters"
        }
    }

    matrix M_np = J(1,$HG_tpi,0)
    if "`peqs'" ~= ""{
        local k: word count `peqs'
        if $HG_free == 0 {
            disp in re "peqs() argument meaningless for quadrature estimation, ignored"
        }
        else if `k'~=$HG_tpi-1{
            disp in red `k' " equations specified for prior probabilities: `peqs', need" $HG_tpi - 1
            exit 198
        }
        global HG_noC1 = $HG_noC2
    }

    if "`eqs'"~=""{
        local k: word count `eqs'
        if `k'~=$HG_tprf-1{
            disp in red `k' " equations specified: `eqs', need " $HG_tprf-1
            exit 198
        }
        * check that they are equations and find number of variables in each: nbrf
        local lev=2
        local l=1
        local ic=0
        while (`lev'<=$HG_tplv){
            disp " "
            local m=$HG_tplv-`lev'+1
            local clusnam: word `m' of $HG_clus
            disp " "
            disp in gr "***level `lev' (" in ye "`clusnam'" in gr ") equation(s):"
            if $HG_init==1{
                di in gr "(init option: parameters will not be estimated)"
                di " "
            }
            local clusnam=substr("`clusnam'",1,3)
            local lv = `lev'-1
            local clusnam "`clusnam'`lv'_"
            local i1=M_nrfc[2, `lev'-1]
            local j1=M_nrfc[2, `lev']
            local nrf=`j1'-`i1'
            disp "   (`nrf' random effect(s))"
            disp "  "
            local rfl = 1
/* MASS POINTS */
            if $HG_free {
                tempname pmat
                if $HG_cor==0{
                    disp "option nocorrel irrelevant for free masses"
                }
                local k = 1
                local nloc = M_nip[1, `lev']
                if $HG_cip{ local nloc = `nloc' - 1}
* new
                local pnum = 0
                local pvars _cons
                matrix `pmat' = J(1,1,0)
                if "`peqs'"~=""{
                    local levm = `lev' - 1
                    local peqn: word `levm' of `peqs'
                    eq ? "`peqn'"
                    local pvars "$S_1"
                    markout `touse' `pvars'
                    local pnum: word count `pvars'
                    matrix M_np[1,`lev'] = `pnum' + 1
                    matrix `pmat' = J(1, `pnum', 0)
                }
                matrix colnames `pmat' = `pvars'
* end new

                while `k' <= `nloc'{
                    disp " "
                    disp in gre "class `k'"
                    local j = `i1'
                    while `j'< `j1'{
                        local eqnam: word `j' of `eqs'
                        eq ? "`eqnam'"
                        local vars "$S_1"
                        markout `touse' `vars'
                        local num: word count `vars'

                        local ex = 0
                        if "`frload'"~=""{
                            local nex: word count `frload'
                            local iex = 1
                            while `iex'<=`nex'{
                                local aex: word `iex' of `frload'
                                if `aex' == `j'{
                                    local ex = 1
                                }
                                local iex = `iex' + 1
                            }
                            if `ex'{
                                matrix M_frld[1,`j'+1] = 1
                                local num = `num' + 1
                            }   
                        }


                        matrix `mat'=(`num')
                        matrix M_nbrf=M_nbrf,`mat'
                        if (`num'>1){
                            parse "`vars'", parse(" ")
                            local vars1 "`1'"
                            if `k'==1{
                                if `ex'==0{
                                    mac shift
                                }
                                local vars2 "`*'"
                                local eqnaml "`clusnam'`rfl'l"
                                eq "`eqnaml': `vars2'"
                                eq ? "`eqnaml'"
                                disp " "
                                disp in gr "   lambdas for random effect " in ye `j'
                                disp in ye "   `eqnaml': `vars2'"
                                global HG_eqs "$HG_eqs (`eqnaml': `depv' `vars2', nocons)"
                                local depv 
                                local num=`num'-1
                                * initial loading on masspoints
                                local lod = 1.1 + (`j'-1)*(-1)^(`j')/5
                                matrix `mat'=J(1,`num',`lod')
                                matrix colnames `mat'= `vars2'
                                matrix coleq `mat'=`eqnaml'
                                matrix M_initr = nullmat(M_initr), `mat'    
                            }

                        }
                        else{local vars1 `vars'}
                        disp " "
                        disp in gr "   location for random effect " in ye `j'
                        local eqnam "z`lev'_`j'_`k'"
                        if `nrf'==1{
                            local eqnam "z`lev'_1_`k'"
                        }
                        eq "`eqnam'":`vars1'
                        eq ? "`eqnam'"
                        disp in ye "   `eqnam': `vars1'"
                        global HG_eqs "$HG_eqs (`eqnam': `depv' `vars1', nocons)"
                        local depv
                        markout `touse' `vars1'
                        * initial locations of mass points
                        *local val = int((`k'+1)/2)*(-1)^`k'/10
                        local val = int((`k'+1)/2)*(-1)^`k'
                        matrix `mat'=(`val')
                        matrix colnames `mat'=`vars1'
                        matrix coleq `mat'=`eqnam'
                        matrix M_initr=nullmat(M_initr),`mat'
                        local j = `j' + 1
                        local rfl = `rfl' + 1
                    }
                    if `k'< M_nip[1, `lev']{
                        local eqnam "p`lev'_`k'"
                        eq "`eqnam'":
                        eq ? "`eqnam'"
                        disp " "
                        disp in gr "   log odds for level " in ye `lev'

                        if `pnum'>0{
                            disp in ye "   `eqnam': `pvars' _cons"
                            global HG_eqs "$HG_eqs (`eqnam':`pvars')"
                            matrix coleq `pmat'=`eqnam'
                            matrix M_initr=nullmat(M_initr),`pmat'
                        }
                        else{
                            disp in ye "   `eqnam': _cons"
                            global HG_eqs "$HG_eqs (`eqnam': `depv')"
                            local depv  
                            * initial log odds for masspoints
                        }
                        * set constant
                        matrix `mat'=(-.4)
                        matrix colnames `mat'=_cons
                        matrix coleq `mat'=`eqnam'
                        matrix M_initr=nullmat(M_initr),`mat'
                    }
                local k = `k' + 1
                }
                * matrix list M_initr
                * disp "$HG_eqs"
            }
/* STD DEVS */
            else{
                local j = `i1'
                while (`j'<`j1'){
                    local eqnam: word `l' of `eqs'
                    eq ? "`eqnam'"
                    local vars "$S_1"
                    local num: word count `vars'
                    local ex = 0
                    if "`frload'"~=""{
                        local nex: word count `frload'
                        local iex = 1
                        while `iex'<=`nex'{
                            local aex: word `iex' of `frload'
                            if `aex' == `j'{
                                local ex = 1
                            }
                            local iex = `iex' + 1
                        }
                        if `ex'{
                            matrix M_frld[1,`j'+1] = 1
                            local num = `num' + 1
                        }   
                    }
                    matrix `mat'=(`num')
                    matrix M_nbrf=M_nbrf,`mat'
                    markout `touse' `vars'
                    if "`vars'"==""{ local vars "_cons"}
                    if `num'>1{
                        * vars1 is variable of first loading (fix at one)
                        parse "`vars'", parse(" ")
                        local vars1 "`1'"
                        if `ex'==0{
                            mac shift
                        }
                        local vars "`*'"
                        local eqnaml "`clusnam'`rfl'l"
                        eq "`eqnaml'": `vars'
                        eq ? "`eqnaml'"
                        disp " "
                        disp in gr "   lambdas for random effect " in ye `j'
                        disp in ye "   `eqnaml': `vars'"
                        global HG_eqs "$HG_eqs (`eqnaml': `depv' `vars', nocons)"
                        local depv
                        * initial values of loadings
                        local lod = 1.1 + (`j'-1)*(-1)^(`j')/5 /*different loading for diff r.eff*/
                        matrix `mat'=J(1,`num'-1,`lod')
                        matrix colnames `mat'=`vars'
                        matrix coleq `mat'=`eqnaml'
                        matrix M_initr=nullmat(M_initr),`mat'
                    }
                    else{
                        local vars1 `vars'
                    }
                    * variance
                    local eqnam "`clusnam'`rfl'"
                    eq "`eqnam'": `vars1'
                    if `nrf'==1|$HG_cor==0{
                        disp in gr "   standard deviation for random effect " in ye `j'
                    }
                    else{
                        disp " "
                        disp in gr /*
                        */"   diagonal element of cholesky decomp. of covariance matrix"
                    }
                    disp in ye "   `eqnam' : `vars1'"
                    global HG_eqs "$HG_eqs (`eqnam': `depv' `vars1', nocons)"
                    local depv
                    * initial value of standard deviation
                    matrix `mat' = (0.5)
                    matrix colnames `mat' = `vars1'
                    matrix coleq `mat' = `eqnam'
                    matrix M_initr=nullmat(M_initr),`mat'
                    local l=`l'+1
                    local j=`j'+1
                    local rfl = `rfl' + 1
                }
                if `nrf' > 1&$HG_cor==1{
                    /* generate equations for covariance parameters */
                    disp " "
                    disp  in gr "   off-diagonal elements"
                    local ii=2
                    *local num = $HG_tplv-`lev'+1
                    *local eqnam: word `num' of $HG_clus
                    *local eqnam = substr("`eqnam'",1,4)
                    while (`ii'<=`nrf'){
                        local jj=1
                        while (`jj'<`ii'){
                            local eqnaml "`clusnam'`ii'_`jj'"
                            eq "`eqnaml'":
                            eq ? "`eqnaml'"
                            disp in ye "   `eqnaml': _cons"
                            global HG_eqs "$HG_eqs (`eqnaml':)"
                            matrix `mat'=(0)
                            matrix colnames `mat'=_cons
                            matrix coleq `mat'=`eqnaml'
                            matrix M_initr=nullmat(M_initr),`mat'
                            local jj =  `jj' + 1
                        }
                        local ii=`ii'+1
                    }
                }
            } /* end else $HG_free */
        local lev=`lev'+1
        } /* lev loop */
        
    } /* endif equ given */
    else{
    /* random intercepts */
        if M_nrfc[1,$HG_tplv]~=$HG_tplv{
            "must specify equations for random effects"
            exit 198
        }
        local k=$HG_tprf-1
        matrix `mat'=J(1,`k',1)
        matrix M_nbrf=M_nbrf,`mat'
        local lev=2
        disp " "
        while (`lev'<=$HG_tplv){
            local l=$HG_tplv-`lev'+1
            local clusnam: word `l' of $HG_clus
            disp " "
            disp in gr "***level `lev' (" in ye "`clusnam'" in gr ") equation(s):"
            if $HG_init==1{
                di in gr "(init option: parameters will not be estimated)"
                di " "
            }
            local clusnam = substr("`clusnam'",1,4)
            local lv = `lev' - 1
            local clusnam "`clusnam'`lv'"
/*MASS POINTS */
            if ($HG_free){
                local k = 1
                local nloc = M_nip[1, `lev']
                if $HG_cip{ local nloc = `nloc' - 1}

* new
                local pnum = 0
                local pvars _cons
                tempname pmat
                matrix `pmat' = J(1,1,0)
                if "`peqs'"~=""{
                    local levm = `lev' - 1
                    local peqn: word `levm' of `peqs'
                    eq ? "`peqn'"
                    local pvars "$S_1"
                    markout `touse' `pvars'
                    local pnum: word count `pvars'
                    matrix M_np[1,`lev'] = `pnum' + 1
                    matrix `pmat' = J(1, `pnum', 0)
                }
                matrix colnames `pmat' = `pvars'
* end new
                while `k' <= `nloc'{
                    disp " "
                    disp in gre "class `k'"
                    local j = 1

                    local eqnam "z`lev'_1_`k'"
                    disp in gr "   location for random effect"
                    disp in ye "   `eqnam': _cons"
                    global HG_eqs "$HG_eqs (`eqnam': `depv')"
                    local depv
                    * initial locations of mass points
                    *local val = int((`k'+1)/2)*(-1)^`k'/10
                    local val = int((`k'+1)/2)*(-1)^`k'
                    matrix `mat'=(`val')
                    matrix colnames `mat'=_cons
                    matrix coleq `mat'=`eqnam'
                    matrix M_initr=nullmat(M_initr),`mat'

                    if `k'<M_nip[1, `lev']{
                        local eqnam "p`lev'_`k'"
                        disp in gr "   log odds for random effect"

                        if `pnum'>0{
                            disp in ye "   `eqnam': `pvars' _cons"
                            global HG_eqs "$HG_eqs (`eqnam':`pvars')"
                            matrix coleq `pmat'=`eqnam'
                            matrix M_initr=nullmat(M_initr),`pmat'
                        }
                        else{
                            disp in ye "   `eqnam': _cons"
                            global HG_eqs "$HG_eqs (`eqnam':)"
                            * initial log odds for masspoints
                        }
                        * set constant
                        matrix `mat'=(-.4)
                        matrix colnames `mat'=_cons
                        matrix coleq `mat'=`eqnam'
                        matrix M_initr=nullmat(M_initr),`mat'
                    }
                    local k = `k' + 1
                }
            }
/* ST. DEVS */
            else{
                local eqnam "`clusnam'"
                disp " "
                disp in gr "   standard deviation of random effect"
                disp in ye "   `eqnam': _cons"
                global HG_eqs "$HG_eqs (`eqnam':`depv')"
                local depv
                * initial value for sd
                matrix `mat'=(0.5)
                matrix colnames `mat'=_cons
                matrix coleq `mat'=`eqnam'
                matrix M_initr=nullmat(M_initr),`mat'
                local cons `cons'1
            }
            local lev=`lev'+1
        }
    }
    disp " "

    matrix `mat' = nullmat(M_initr), nullmat(M_initf)  /* M_initr may not exist */
    global HG_befB = colsof(`mat')
/* deal with Bmatrix */

    global HG_bmat = 0
    if "`bmatrix'"~=""{
        if $HG_tprf<2{
            disp in re "bmatrix can only be used for more than 1 random effect"
            exit 198
        }
        * capture matrix list `bmatrix'
        if _rc>0{
            disp in re "bmatrix is not a matrix"
            exit 198
        }
        local bn = colsof(`bmatrix')
        if rowsof(`bmatrix')~=`bn'{
            disp in re "bmatrix must be square"
            exit 198
        }
        if `bn'~=$HG_tprf-1{
            disp in re "number of rows and columns of B matrix must be " $HG_tprf-1
            exit 198
        }
        matrix M_b=`bmatrix'
        global HG_bmat = 1
        disp in gr "B-matrix:"
        local i = 1
        while `i' <= `bn'{
            local j = 1
            while `j'<= `bn'{
                if M_b[`i',`j']>0{
                    local eqnam b`i'_`j'
                    disp " "
                    disp in ye "   `eqnam': _cons"
                    global HG_eqs "$HG_eqs (`eqnam':)"
                    * initial value for sd
                    matrix `mat'=(0.5)
                    matrix colnames `mat'=_cons
                    matrix coleq `mat'=`eqnam'
                    matrix M_initr=nullmat(M_initr),`mat'
                    local cons `cons'1
                }
                local j = `j' + 1
            }
            local i = `i' + 1
        }
        disp " "    
    } 

/* total number of fixed linear predictors */      
    global HG_tpff = colsof(M_nffc)

/* deal with geqs */
    global HG_ngeqs = 0
    if "`geqs'"~=""{
        * M_ngeqs: first row says which random effect, second how many terms
        local num: word count `geqs'
        global HG_ngeqs = `num'
        matrix M_ngeqs=J(3,`num',0)
        local nxt = M_nffc[1,$HG_tpff] + colsof(M_initr) + 1
        disp in gr "Regressions of random effects on covariates:"
        tokenize `geqs'
        local i = 1
        while "`1'"~="" {
            local k = substr("`1'",2,1)
            local k = `k' + 1
            if `k'>$HG_tprf {
                disp in red "eq `1' refers to a random effects that does not exist"
                exit 198
            }
            local j = 1
            while `j'<=`i'{
                    if M_ngeqs[1,`j']==`k' {
                    disp in red "more than one geq given for random effect" `k'-1
                    exit 198
                }
                local j = `j' + 1
            }
            eq ? "`1'"
            local vars "$S_1"
            local num: word count `vars'
            matrix `mat'=J(1,`num',0)
            matrix colnames `mat'=`vars'
            matrix coleq `mat'=`1'
            matrix M_initr=nullmat(M_initr),`mat'
            markout `touse' `vars'
            disp in gr "   equation for random effect " in ye `k'-1
            disp in ye "   `1': `vars'"
            global HG_eqs "$HG_eqs (`1': `vars', nocons)"
            matrix M_ngeqs[1,`i']=`k'
            matrix M_ngeqs[2,`i']=`num'
            matrix M_ngeqs[3,`i']=`nxt'
            local nxt = `nxt' + `num'
            local i = `i' + 1
            mac shift
        }
    disp " "
    }

    global which =  15
        
/* the "clock" ip and znow*/
    local k = $HG_tprf+2
    matrix M_ip =  J(1,`k',1)
    local k = $HG_tprf - 1
    matrix M_znow =J(1,`k',1)

end



program define mint
args n k
    if `k' == 5 {
        multn `n'
    }
    else if `k' == 7 {
        sphern `n'
    }
    else if `n'==2&(`k' == 9|`k' == 11|`k' == 15){
        int2k `k'
    }
    else{
        disp in re "nip must be 5 or 7 if dim >2 and 5, 7, 9, 11 or 15 if dim=2"
        exit 198
    }
end

program define sphern
version 6.0
/* degree 7 rule for n>=3 used by Naylor and Smith */
args n
    if `n' == 2 {
        spher2
    }
    else if `n' == 3{
        spher3
    }
    else if `n' == 6{
        spher6
    }
/*
    else if `n' == 4{
        spher4
    }
*/
    else{
    tempname r s t B C D r1 r2 A1 A2 x X y a norm im

    local num =2*( 2^`n' + 2*`n'^2)

* generate U_n: 7-1 page 295
    scalar `r' = sqrt(2)
    scalar `s' = sqrt(2/`n')
    scalar `t' = 1
    scalar `B' = ln(8-`n') - ln(`n') - ln(`n'+2) - ln(`n'+4) + ln(2) - lngamma(`n'/2)
    scalar `C' = -`n'*ln(2) + 3*ln(`n') - ln(`n') - ln(`n'+2) - ln(`n'+4) + ln(2) - lngamma(`n'/2)
    scalar `D' = ln(4) - ln(`n') - ln(`n'+2) - ln(`n'+4) + ln(2) - lngamma(`n'/2)
    scalar `r2' = sqrt( (`n' + 2 - sqrt(2*(`n'+2)))/2 )
    scalar `r1' = sqrt( (`n' + 2 + sqrt(2*(`n'+2)))/2 )
    scalar `A2' = ln( ( `n' + 2 + sqrt(2*(`n'+2)) )/(4*(`n'+2)) )+ lngamma(`n'/2)
    scalar `A1' = ln( ( `n' + 2 - sqrt(2*(`n'+2)) )/(4*(`n'+2)) )+ lngamma(`n'/2)


* Do r and B    
    matrix `x' = J(1,`n',0)
    local ir = 1
    while `ir' <= `n'{
        local j = 1
        while `j' <= 2 {
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix `X' = nullmat(`X')\ `x'
            matrix `y' = nullmat(`y'),`B'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }

* Do t and D    
    matrix `x' = J(1,`n',0)
    local it1 = 1
    while `it1' <= `n'{
        local j1 = 1
        while `j1' <= 2{
            matrix `x'[1,`it1'] = (-1)^`j1'*`t'
            local it2 = `it1' + 1
            while `it2' <= `n'{
                local j2 = 1
                while `j2' <= 2{
                    * disp "it1 = `it1' and it2 = `it2'"
                    matrix `x'[1,`it2'] = (-1)^`j2'*`t'
                    matrix `X' = `X'\ `x'
                    matrix `y' = `y', `D'
                    matrix `x'[1,`it2'] = 0
                    local j2 = `j2' + 1
                }
                local it2 = `it2' + 1
            }
            matrix `x'[1,`it1'] = 0
            local j1 = `j1' + 1

        }
        local it1 = `it1' + 1
    }

* Do s and C
    matrix `x' = J(1,`n',`s')
    matrix `im' = J(1,`n'+1,0)
    matrix `im'[1,1] = 1

    local pm = `n'+1
    while `pm' <= `n'+1{
        /* set previous digits to 0 */
        while `pm'>1{
            matrix `x'[1,`pm'-1] = `s'
            matrix `im'[1,`pm'] = 0
            local pm = `pm' - 1
        }
        matrix `X' = `X'\ `x'
        matrix `y' = `y', `C'
        * matrix list `im'

        local pm = 1
        while `im'[1,`pm'] == 1{
            local pm = `pm' + 1
        }
        * disp "pm = " `pm'
        /* pm is first incomplete digit */
        if `pm'<= `n' + 1{
            matrix `im'[1,`pm'] = 1
            matrix `x'[1,`pm'-1] = -`s'
            local pm = `pm' - 1
        }
    }

    *matrix list `X'
    *matrix list `y'
    matrix M_zlc`num' = `X'*`r1'\ `X'*`r2'
    matrix M_zlc`num' = M_zlc`num''
    matrix `a'= J(1,`num'/2,`A1'),J(1,`num'/2,`A2')
    matrix M_zps`num' = `y',`y'
    matrix M_zps`num' = M_zps`num'+`a'
    global S_1 = `num'
    } /* end else */
end


program define spher2
version 6.0
*p. 324, 7-1
    tempname r s t A B C x
    capture matrix drop M_zlc12
    capture matrix drop M_zps12

    scalar `r' = sqrt(6)
    scalar `s' = sqrt((9-3*sqrt(5))/4)
    scalar `t' = sqrt((9+3*sqrt(5))/4)
    scalar `A' = ln(1/36)
    scalar `B' = ln(5 + 2*sqrt(5)) - ln(45)
    scalar `C' = ln(5 - 2*sqrt(5)) - ln(45)

*r
    matrix `x' = J(1,2,0)
    local ir = 1
    while `ir' <= 2{
        local j = 1
        while `j' <= 2{
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix M_zlc12 = nullmat(M_zlc12)\ `x'
            matrix M_zps12 = nullmat(M_zps12), `A'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }

*t
    matrix `x' = J(1,2,`t')
    matrix M_zlc12 = M_zlc12\ `x'
    matrix M_zps12 = M_zps12, `C'
    local m = 1 /* number of - */
    while `m' <= 2{
        local i = 1 /* pos of first - */
        while `i'<= 2{
            matrix `x'[1,`i'] = -`t'
            local j = `i' + 1
            if `m'>1{
                while `j' <= 2 {
                    matrix `x'[1,`j'] = -`t'
                    matrix M_zlc12 = M_zlc12\ `x'
                    matrix M_zps12 = M_zps12, `C'
                    matrix `x'[1,`j'] = `t'
                    local j = `j' + 1
                }
            }
            else{
                matrix M_zlc12 = M_zlc12\ `x'
                matrix M_zps12 = M_zps12, `C'
            }
            matrix `x'[1, `i'] = `t'
            local i = `i' + 1
        }
        local m = `m' + 1
    }

* s
    matrix `x' = J(1,2,`s')
    matrix M_zps12 = M_zps12, `B'
    matrix M_zlc12 = M_zlc12\ `x'

    local m = 1 /* number of - */
    while `m' <= 2{
        local i = 1 /* pos of first - */
        while `i'<= 2{
            matrix `x'[1,`i'] = -`s'
            local j = `i' + 1
            if `m'>1{
                while `j' <= 2 {
                    matrix `x'[1,`j'] = -`s'
                    matrix M_zlc12 = M_zlc12\ `x'
                    matrix M_zps12 = M_zps12, `B'
                    matrix `x'[1,`j'] = `s'
                    local j = `j' + 1
                }
            }
            else{
                matrix M_zlc12 = M_zlc12\ `x'
                matrix M_zps12 = M_zps12, `B'
            }
            matrix `x'[1, `i'] = `s'
            local i = `i' + 1
        }
        local m = `m' + 1
    }
    matrix M_zlc12 = M_zlc12'
    global S_1 = 12
end

program define spher3
    version 6.0
* Stroud (1971) p. 327, E_3^{r^2} 7-1
    args n
    tempname r s t A B C D x im
    local num = 27
    capture matrix drop M_zlc27
    capture matrix drop M_zps27

    scalar `r' = sqrt((15 + sqrt(15))/2)
    scalar `s' = sqrt(6 - sqrt(15))
    scalar `t' = sqrt(9 + 2*sqrt(15))
    scalar `A' = ln(720 + 8*sqrt(15)) - ln(2205)
    scalar `B' = ln(270 - 46*sqrt(15)) - ln(15435)
    scalar `C' = ln(162 + 41*sqrt(15)) - ln(6174)
    scalar `D' = ln(783 - 202*sqrt(15)) - ln(24696)

    local n = 3
* D
    matrix `x' = J(1,`n',`t')
    matrix `im' = J(1,`n'+1,0)
    matrix `im'[1,1] = 1

    local pm = `n'+1
    while `pm' <= `n'+1{
        /* set previous digits to 0 */
        while `pm'>1{
            matrix `x'[1,`pm'-1] = `t'
            matrix `im'[1,`pm'] = 0
            local pm = `pm' - 1
        }
        matrix M_zlc`num' = nullmat(M_zlc`num')\ `x'
        matrix M_zps`num' = nullmat(M_zps`num'), `D'
        * matrix list `im'

        local pm = 1
        while `im'[1,`pm'] == 1{
            local pm = `pm' + 1
        }
        * disp "pm = " `pm'
        /* pm is first incomplete digit */
        if `pm'<= `n' + 1{
            matrix `im'[1,`pm'] = 1
            matrix `x'[1,`pm'-1] = -`t'
            local pm = `pm' - 1
        }
    }

* B
    matrix `x' = J(1,`n',0)
    local ir = 1
    while `ir' <= `n'{
        local j = 1
        while `j' <= 2{
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix M_zlc`num' = M_zlc`num'\ `x'
            matrix M_zps`num' = M_zps`num',`B'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }

* C
    matrix `x' = J(1,`n',0)
    local is1 = 1
    while `is1' <= `n'{
        local j1 = 1
        while `j1' <= 2{
            matrix `x'[1,`is1'] = (-1)^`j1'*`s'
            local is2 = `is1' + 1
            while `is2' <= `n'{
                local j2 = 1
                while `j2' <= 2{
                    * disp "is1 = `is1' and is2 = `is2'"
                    matrix `x'[1,`is2'] = (-1)^`j2'*`s'
                    matrix M_zlc`num' = M_zlc`num'\ `x'
                    matrix M_zps`num' = M_zps`num',`C'
                    matrix `x'[1,`is2'] = 0
                    local j2 = `j2' + 1
                }
                local is2 = `is2' + 1
            }
            matrix `x'[1,`is1'] = 0
            local j1 = `j1' + 1

        }
        local is1 = `is1' + 1
    }
* A
    matrix M_zps`num' = M_zps`num',`A'
    matrix `x' = J(1,`n',0)
    matrix M_zlc`num' = M_zlc`num'\ `x'
    matrix M_zlc`num' = M_zlc`num''
    global S_1 = `num'
end


program define spher4
    version 6.0
* Stroud (1971) p. 329, E_4^{r^2} 7-1
    args n
    tempname r s t A B C D x im
    local num = 49
    capture matrix drop M_zlc`num'
    capture matrix drop M_zps`num'

    scalar `s' = sqrt(3 - sqrt(3))
    scalar `r' = 2*`s'
    scalar `t' = sqrt(6 + 2*sqrt(3))
    scalar `A' = -ln(4)
    scalar `B' = ln(9 + 5*sqrt(3)) - ln(576)
    scalar `C' = ln(9 + -5*sqrt(3)) - ln(576)

    local n = 4
* C and t
    matrix `x' = J(1,`n',0)
    local is1 = 1
    while `is1' <= `n'{
        local j1 = 1
        while `j1' <= 2{
            matrix `x'[1,`is1'] = (-1)^`j1'*`t'
            local is2 = `is1' + 1
            while `is2' <= `n'{
                local j2 = 1
                while `j2' <= 2{
                    * disp "is1 = `is1' and is2 = `is2'"
                    matrix `x'[1,`is2'] = (-1)^`j2'*`t'
                    matrix M_zlc`num' = nullmat(M_zlc`num')\ `x'
                    matrix M_zps`num' = nullmat(M_zps`num'),`C'
                    matrix `x'[1,`is2'] = 0
                    local j2 = `j2' + 1
                }
                local is2 = `is2' + 1
            }
            matrix `x'[1,`is1'] = 0
            local j1 = `j1' + 1

        }
        local is1 = `is1' + 1
    }

* B and s
    matrix `x' = J(1,`n',`s')
    matrix `im' = J(1,`n'+1,0)
    matrix `im'[1,1] = 1

    local pm = `n'+1
    while `pm' <= `n'+1{
        /* set previous digits to 0 */
        while `pm'>1{
            matrix `x'[1,`pm'-1] = `s'
            matrix `im'[1,`pm'] = 0
            local pm = `pm' - 1
        }
        matrix M_zlc`num' = nullmat(M_zlc`num')\ `x'
        matrix M_zps`num' = nullmat(M_zps`num'), `B'
        * matrix list `im'

        local pm = 1
        while `im'[1,`pm'] == 1{
            local pm = `pm' + 1
        }
        * disp "pm = " `pm'
        /* pm is first incomplete digit */
        if `pm'<= `n' + 1{
            matrix `im'[1,`pm'] = 1
            matrix `x'[1,`pm'-1] = -`s'
            local pm = `pm' - 1
        }
    }

* B and r
    matrix `x' = J(1,`n',0)
    local ir = 1
    while `ir' <= `n'{
        local j = 1
        while `j' <= 2{
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix M_zlc`num' = M_zlc`num'\ `x'
            matrix M_zps`num' = M_zps`num',`B'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }
* A
    matrix M_zps`num' = M_zps`num',`A'
    matrix `x' = J(1,`n',0)
    matrix M_zlc`num' = M_zlc`num'\ `x'
    matrix M_zlc`num' = M_zlc`num''
    global S_1 = `num'
end


capture program drop spher6
program define spher6
* Stroud 7-1 (p. 318)
    tempname r s t B C D A x X y a norm im

    local n = 6
    local num = 2^`n' + 2*`n'^2 + 1

    capture matrix drop M_zlc`num'
    capture matrix drop M_zps`num'
/*
    scalar `r' = sqrt( (3*(8-`n')-(`n'-2)*sqrt(3*(8-`n')))/(2*(5-`n')) )
    scalar `s' = sqrt( (3*`n' - 2*sqrt(3*(8-`n')))/(2*(3*`n' - 8)) )
    scalar `t' = sqrt( (6+sqrt(3*(8-`n')))/2 )
    scalar `B' = (8-`n')/( 8*`r'^6) *2/exp(lngamma(`n'/2))
    scalar `C' = 1 /( 2^(`n'+3)*`s'^6) *2/exp(lngamma(`n'/2))
    scalar `D' = 1/(16*`t'^6) *2/exp(lngamma(`n'/2))
    scalar `A' = 2/exp(lngamma(`n'/2)) - 2*`n'*`B' - 2^`n'*`C' - 2*`n'*(`n'-1)*`D'
    disp in re "r = " `r' " s = " `s' " t = " `t' 
    disp in re "A = " `A' " B = " `B' " C = " `C' " D = " `D'
*/

* - - +
    scalar `r' = sqrt( (3*(8-`n')-(`n'-2)*sqrt(3*(8-`n')))/(5-`n') )
    scalar `s' = sqrt( (3*`n' - 2*sqrt(3*(8-`n')))/(3*`n' - 8) )
    scalar `t' = sqrt( 6+sqrt(3*(8-`n')) )
    scalar `B' = ln(8-`n') - ln(8) - 6*( ln(`r') - ln(2)/2 ) + ln(2) - lngamma(`n'/2)
    scalar `C' = -(`n'+ 3)*ln(2)-6*( ln(`s') - ln(2)/2 ) + ln(2) - lngamma(`n'/2)
    scalar `D' = -ln(16) - 6*( ln(`t') - ln(2)/2 ) + ln(2) - lngamma(`n'/2)
    scalar `A' = ln(   2/exp(lngamma(`n'/2)) - 2*`n'*exp(`B') - 2^`n'*exp(`C') - 2*`n'*(`n'-1)*exp(`D') )
    *disp in re "r = " `r' " s = " `s' " t = " `t' 
    *disp in re "A = " `A' " B = " `B' " C = " `C' " D = " `D'



* A
    matrix `X' = J(1,`n',0)
    matrix `y' = (`A')

* Do r and B    
    matrix `x' = J(1,`n',0)
    local ir = 1
    while `ir' <= `n'{
        local j = 1
        while `j' <= 2 {
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix `X' = nullmat(`X')\ `x'
            matrix `y' = nullmat(`y'),`B'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }

* Do t and D    
    matrix `x' = J(1,`n',0)
    local it1 = 1
    while `it1' <= `n'{
        local j1 = 1
        while `j1' <= 2{
            matrix `x'[1,`it1'] = (-1)^`j1'*`t'
            local it2 = `it1' + 1
            while `it2' <= `n'{
                local j2 = 1
                while `j2' <= 2{
                    * disp "it1 = `it1' and it2 = `it2'"
                    matrix `x'[1,`it2'] = (-1)^`j2'*`t'
                    matrix `X' = `X'\ `x'
                    matrix `y' = `y', `D'
                    matrix `x'[1,`it2'] = 0
                    local j2 = `j2' + 1
                }
                local it2 = `it2' + 1
            }
            matrix `x'[1,`it1'] = 0
            local j1 = `j1' + 1

        }
        local it1 = `it1' + 1
    }

* Do s and C
    matrix `x' = J(1,`n',`s')
    matrix `im' = J(1,`n'+1,0)
    matrix `im'[1,1] = 1

    local pm = `n'+1
    while `pm' <= `n'+1{
        /* set previous digits to 0 */
        while `pm'>1{
            matrix `x'[1,`pm'-1] = `s'
            matrix `im'[1,`pm'] = 0
            local pm = `pm' - 1
        }
        matrix `X' = `X'\ `x'
        matrix `y' = `y', `C'
        * matrix list `im'

        local pm = 1
        while `im'[1,`pm'] == 1{
            local pm = `pm' + 1
        }
        * disp "pm = " `pm'
        /* pm is first incomplete digit */
        if `pm'<= `n' + 1{
            matrix `im'[1,`pm'] = 1
            matrix `x'[1,`pm'-1] = -`s'
            local pm = `pm' - 1
        }
    }

    matrix M_zlc`num' = `X'
    matrix M_zps`num' = `y'
    matrix M_zlc`num' = M_zlc`num''
    global S_1 = `num'
end


program define fsrs
    version 6.0
    args r s x n
    if abs(`s')<1e-10&abs(`r')<1e-10{
        matrix `x' = (0,0)
        scalar `n' = 1
    }
    else if abs(`s')<1e-10{
        matrix `x' = (`r',0\ -`r',0\ 0,`r'\ 0,-`r')
        scalar `n' = 4
    }
    else if abs(`r'-`s')<1e-10{
        matrix `x' = (`r',`s'\ -`r',`s'\ `r',-`s'\ -`r',-`s')
        scalar `n' = 4
    }
    else{
        matrix `x' = (`r',`s'\ -`r',`s'\ `r',-`s'\ -`r',-`s'\ `s',`r'\ -`s',`r'\ `s',-`r'\ -`s',-`r')
        scalar `n' = 8
    }
end

program define int2k
    version 6.0
    args k
    if `k' == 9{
        *E_2^{r^2}: 9-1
        local l = 4
        local num = 20
        tempname r1 r2 r3 r4 s1 s2 s3 s4 B1 B2 B3 B4
/*
        scalar `r1' = 1.538189001320852*sqrt(2)
        scalar `r2' = 1.224744871391589*sqrt(2)
        scalar `r3' = 0.4817165220011443*sqrt(2)
        scalar `r4' = 2.607349811958554*sqrt(2)
        scalar `s4' = 0.9663217712794149*sqrt(2)
        scalar `s1' = 0
        scalar `s2' = `r2'
        scalar `s3' = `r3'
        scalar `B1' = ln(0.1237222328857347) - ln(_pi)
        scalar `B2' = ln(0.06544984694978697) - ln(_pi)
        scalar `B3' = ln(0.5935280476180875) - ln(_pi)
        scalar `B4' = ln(0.001349017971918148) - ln(_pi)
*/
        scalar `r3' = 1.538189001320852*sqrt(2)
        scalar `r2' = 1.224744871391589*sqrt(2)
        scalar `r4' = 0.4817165220011443*sqrt(2)
        scalar `r1' = 2.607349811958554*sqrt(2)
        scalar `s1' = 0.9663217712794149*sqrt(2)
        scalar `s3' = 0
        scalar `s2' = `r2'
        scalar `s4' = `r4'
        scalar `B3' = ln(0.1237222328857347) - ln(_pi)
        scalar `B2' = ln(0.06544984694978697) - ln(_pi)
        scalar `B4' = ln(0.5935280476180875) - ln(_pi)
        scalar `B1' = ln(0.001349017971918148) - ln(_pi)
    }
    if `k' == 11{
        *E_2^{r^2}: 11-1
        local l = 5
        local num = 28
        tempname r1 r2 r3 r4 r5 s1 s2 s3 s4 s5 B1 B2 B3 B4 B5
/*
        scalar `r1' = 2.757816396257008*sqrt(2)
        scalar `r2' = 1.732050807568877*sqrt(2)
        scalar `r3' = 0.6280515301597559*sqrt(2)
        scalar `r4' = 1.224744871391589*sqrt(2)
        scalar `r5' = 0.7071067811865475*sqrt(2)
        scalar `s4' = 2.121320343559643*sqrt(2)
        scalar `s5' = 1.224744871391589*sqrt(2)
        scalar `s1' = 0
        scalar `s2' = 0
        scalar `s3' = 0
        scalar `B1' = ln(0.0008176645817675417) - ln(_pi)
        scalar `B2' = ln(0.04363323129985824) - ln(_pi)
        scalar `B3' = ln(0.5373255214498174) - ln(_pi)
        scalar `B4' = ln(0.003636102608321520) - ln(_pi)
        scalar `B5' = ln(0.09817477042468103) - ln(_pi)
*/
        scalar `r1' = 2.757816396257008*sqrt(2)
        scalar `r3' = 1.732050807568877*sqrt(2)
        scalar `r5' = 0.6280515301597559*sqrt(2)
        scalar `r2' = 1.224744871391589*sqrt(2)
        scalar `r4' = 0.7071067811865475*sqrt(2)
        scalar `s2' = 2.121320343559643*sqrt(2)
        scalar `s4' = 1.224744871391589*sqrt(2)
        scalar `s1' = 0
        scalar `s3' = 0
        scalar `s5' = 0
        scalar `B1' = ln(0.0008176645817675417) - ln(_pi)
        scalar `B3' = ln(0.04363323129985824) - ln(_pi)
        scalar `B5' = ln(0.5373255214498174) - ln(_pi)
        scalar `B2' = ln(0.003636102608321520) - ln(_pi)
        scalar `B4' = ln(0.09817477042468103) - ln(_pi)
    }
    if `k' == 15{
        *E_2^{r^2}: 15-1
        local l = 9
        local num = 44
        tempname r1 r2 r3 r4 r5 r6 r7 r8 r9 s1 s2 s3 s4 s5 s6 s7 s8 s9 B1 B2 B3 B4 B5 B6 B7 B8 B9
/*
        scalar `r1' = 3.538388728121807*sqrt(2)
        scalar `r2' = 2.359676416877929*sqrt(2)
        scalar `r3' = 1.312801844620926*sqrt(2)
        scalar `r4' = 0.5389559482114205*sqrt(2)
        scalar `r5' = 2.300279949805658*sqrt(2)
        scalar `r6' = 1.581138830084189*sqrt(2)
        scalar `r7' = 0.8418504335819279*sqrt(2)
        scalar `r8' = 2.685533581755341*sqrt(2)
        scalar `r9' = 1.740847514397403*sqrt(2)
        scalar `s8' = 1.112384431771456*sqrt(2)
        scalar `s9' = 0.7210826504868960*sqrt(2)
        scalar `s1' = 0
        scalar `s2' = 0
        scalar `s3' = 0
        scalar `s4' = 0
        scalar `s5' = `r5'
        scalar `s6' = `r6'
        scalar `s7' = `r7'
        scalar `B1' = ln(0.000008006483569659628) - ln(_pi)
        scalar `B2' = ln(0.003604577420838264) - ln(_pi)
        scalar `B3' = ln(0.1187609330759137) - ln(_pi)
        scalar `B4' = ln(0.4372488543791402) - ln(_pi)
        scalar `B5' = ln(0.00003671735075832989) - ln(_pi)
        scalar `B6' = ln(0.005654866776461627) - ln(_pi)
        scalar `B7' = ln(0.1777774268424240) - ln(_pi)
        scalar `B8' = ln(0.0002735449647853290) - ln(_pi)
        scalar `B9' = ln(0.02087984556938594) - ln(_pi)
*/
        scalar `r1' = 3.538388728121807*sqrt(2)
        scalar `r4' = 2.359676416877929*sqrt(2)
        scalar `r7' = 1.312801844620926*sqrt(2)
        scalar `r9' = 0.5389559482114205*sqrt(2)
        scalar `r2' = 2.300279949805658*sqrt(2)
        scalar `r5' = 1.581138830084189*sqrt(2)
        scalar `r8' = 0.8418504335819279*sqrt(2)
        scalar `r3' = 2.685533581755341*sqrt(2)
        scalar `r6' = 1.740847514397403*sqrt(2)
        scalar `s3' = 1.112384431771456*sqrt(2)
        scalar `s6' = 0.7210826504868960*sqrt(2)
        scalar `s1' = 0
        scalar `s4' = 0
        scalar `s7' = 0
        scalar `s9' = 0
        scalar `s2' = `r2'
        scalar `s5' = `r5'
        scalar `s8' = `r8'
        scalar `B1' = ln(0.000008006483569659628) - ln(_pi)
        scalar `B4' = ln(0.003604577420838264) - ln(_pi)
        scalar `B7' = ln(0.1187609330759137) - ln(_pi)
        scalar `B9' = ln(0.4372488543791402) - ln(_pi)
        scalar `B2' = ln(0.00003671735075832989) - ln(_pi)
        scalar `B5' = ln(0.005654866776461627) - ln(_pi)
        scalar `B8' = ln(0.1777774268424240) - ln(_pi)
        scalar `B3' = ln(0.0002735449647853290) - ln(_pi)
        scalar `B6' = ln(0.02087984556938594) - ln(_pi)
    }
    tempname x n
    capture matrix drop M_zlc`num'
    local i = 1
    while `i'<=`l'{
        fsrs `r`i'' `s`i'' `x' `n'
        * matrix list `x'
        matrix M_zlc`num' = nullmat(M_zlc`num')\ `x'
        matrix `x' = J(1,`n',`B`i'')
        matrix M_zps`num' = nullmat(M_zps`num'), `x'
        local i = `i' + 1
    }
    matrix M_zlc`num' = M_zlc`num''
    global S_1 = `num'
end

program define multn
version 6.0
* Stroud (1971) p. 317, 5-2
    args n
    tempname r s A B C x
    local num = 2*`n'^2 + 1

    capture matrix drop M_zlc`num'
    capture matrix drop M_zps`num'

    scalar `r' = sqrt((`n'+2))
    scalar `s' = sqrt((`n'+2)/2)
    scalar `A' = ln(2) - ln(`n'+2)
    scalar `B' = ln(4-`n')-ln(2) -2*ln(`n'+2)
    scalar `C' = -2*ln(`n'+2)

    matrix M_zps`num' = (`A')
    matrix `x' = J(1,`n',0)
    matrix M_zlc`num' = `x'
    local ir = 1
    while `ir' <= `n'{
        local j = 1
        while `j' <= 2{
            matrix `x'[1,`ir'] = (-1)^`j'*`r'
            matrix M_zlc`num' = M_zlc`num'\ `x'
            matrix M_zps`num' = M_zps`num',`B'
            matrix `x'[1,`ir'] = 0
            local j = `j' + 1
        }
        local ir = `ir' + 1
    }

    local is1 = 1
    while `is1' <= `n'{
        local j1 = 1
        while `j1' <= 2{
            matrix `x'[1,`is1'] = (-1)^`j1'*`s'
            local is2 = `is1' + 1
            while `is2' <= `n'{
                local j2 = 1
                while `j2' <= 2{
                    * disp "is1 = `is1' and is2 = `is2'"
                    matrix `x'[1,`is2'] = (-1)^`j2'*`s'
                    matrix M_zlc`num' = M_zlc`num'\ `x'
                    matrix M_zps`num' = M_zps`num',`C'
                    matrix `x'[1,`is2'] = 0
                    local j2 = `j2' + 1
                }
                local is2 = `is2' + 1
            }
            matrix `x'[1,`is1'] = 0
            local j1 = `j1' + 1

        }
        local is1 = `is1' + 1
    }
    matrix M_zlc`num' = M_zlc`num''
    global S_1 = `num'
end

program define ghquad 
* stolen from rfprobit (Bill Sribney)
    version 4.0
    local n `1'
    tempname xx ww a b
    local i 1
    local m = int((`n' + 1)/2)
    matrix M_zlc`n' = J(1,`m',0)
    matrix M_zps`n' = M_zlc`n'
    while `i' <= `m' {
        if `i' == 1 {
            scalar `xx' = sqrt(2*`n'+1)-1.85575*(2*`n'+1)^(-1/6)
        }
        else if `i' == 2 { scalar `xx' = `xx'-1.14*`n'^0.426/`xx' }
        else if `i' == 3 { scalar `xx' = 1.86*`xx'-0.86*M_zlc`n'[1,1] }
        else if `i' == 4 { scalar `xx' = 1.91*`xx'-0.91*M_zlc`n'[1,2] }
        else { 
            local im2 = `i' -2
            scalar `xx' = 2*`xx'-M_zlc`n'[1,`im2']
        }
        hermite `n' `xx' `ww'
        matrix M_zlc`n'[1,`i'] = `xx'
        matrix M_zps`n'[1,`i'] = ln(`ww') - ln(_pi)/2
        local i = `i' + 1
    }
    if mod(`n', 2) == 1 { matrix M_zlc`n'[1,`m'] = 0}
/* start in tails */
    matrix `b' = (1,1)
    matrix M_zps`n' = M_zps`n'#`b'
    matrix M_zps`n' = M_zps`n'[1,1..`n']
    matrix `b' = (1,-1)
    matrix M_zlc`n' = M_zlc`n'#`b'
    matrix M_zlc`n' = M_zlc`n'[1,1..`n']

/* other alternative (start in centre) */
/*
    matrix `b' = J(1,`n',0)
    local i = 1
    while ( `i'<=`n'){
        matrix `b'[1, `i'] = M_zlc`n'[1, `n'+1-`i']
        local i = `i' + 1
    }
    matrix M_zlc`n' = `b'
    local i = 1
    while ( `i'<=`n'){
        matrix `b'[1, `i'] = M_zps`n'[1, `n'+1-`i']
        local i = `i' + 1
    }
    matrix M_zps`n' = `b'
*/
/* end other alternative */
    matrix M_zlc`n' = M_zlc`n'* sqrt(2)
end


program define hermite  /* integer n, scalar x, scalar w */
* stolen from rfprobit (Bill Sribney)
    version 4.0
    local n "`1'"
    local x "`2'"
    local w "`3'"
    local last = `n' + 2
    tempname i p
    matrix `p' = J(1,`last',0)
    scalar `i' = 1
    while `i' <= 10 {
        matrix `p'[1,1]=0
        matrix `p'[1,2] = _pi^(-0.25)
        local k = 3
        while `k'<=`last'{
            matrix `p'[1,`k'] = `x'*sqrt(2/(`k'-2))*`p'[1,`k'-1] /*
            */  - sqrt((`k'-3)/(`k'-2))*`p'[1,`k'-2]
            local k = `k' + 1
        }
        scalar `w' = sqrt(2*`n')*`p'[1,`last'-1]
        scalar `x' = `x' - `p'[1,`last']/`w'
        if abs(`p'[1,`last']/`w') < 3e-14 {
            scalar `w' = 2/(`w'*`w')
            exit
        }
        scalar `i' = `i' + 1
    }
    di in red "hermite did not converge"
    exit 499
end


program define lebesque
    version 5.0
    local n `1'
    tempname pt a b
    scalar `a' = 1/`n'
    matrix M_zps`n' = J(1,`n',`a')
    local i = 1
    local m = int((`n' + 1)/2)
    matrix M_zlc`n' = J(1,`m',0)
    while(`i'<=`m'){
        scalar `pt' = `i'/`n' -1/(2*`n')
        matrix M_zlc`n'[1,`i']=invnorm(`pt')
        local i = `i' + 1
    }
/* start in tails */
    matrix `b' = (1,-1)
    matrix M_zlc`n' = M_zlc`n'#`b'
    matrix M_zlc`n' = M_zlc`n'[1,1..`n']
/* other alternative: left to right */
/*
    while ( `i'<=`n'){
        matrix M_zlc`n'[1, `i'] = -M_zlc`n'[1, `n'+1-`i']
        local i = `i' + 1
    }
*/
end

program define disprand
version 6.0
* displays additional information about random effects 
* disp "running disprand "
disp " "
if "e(tplv)" == ""{
    * estimates not found
    exit
}
tempname var b se cor mn0 mm0
matrix `b' = e(b)
local names: colnames(`b')
tempname M_nrfc M_nip M_nbrf M_nffc M_b V M_frld

matrix `V' = e(V)
matrix `M_nrfc' = e(nrfc)
matrix `M_nip' = e(nip)
matrix `M_nbrf' = e(nbrf)
matrix `M_nffc' = e(nffc)
matrix `M_frld' = e(frld)
local ngeqs = e(ngeqs)
local bmat = e(bmat)
if `bmat' ==1{matrix `M_b' = e(mb)}
local bmat = e(bmat)
local iscor = e(cor)
local nxt = `M_nffc'[1,colsof(`M_nffc')]+1
local free = e(free)
local tplv = e(tplv)
local lev1 = e(lev1)
local tprf = e(tprf)
local cip = e(cip)
local nats = e(nats)
if `free'{
    tempname M_np
    matrix `M_np' = e(mnp)
}

local nrfold = `M_nrfc'[2,1]
if `M_nbrf'[1,1]>0{
    if `lev1' == 1 {disp in gr "Variance at level 1"}
    else if `lev1' == 2 {disp in gr "Squared Coefficient of Variation"}
    else if `lev1' == 3 {disp in gr "Dispersion at level 1"}
    *disp in smcl in gr "{hline 78}" _n
    di in gr _dup(78) "-" _n
    if `M_nbrf'[1,1]==1{
        if `nats'{
            scalar `var' = `b'[1, `nxt']^2
            scalar `se' = 2*sqrt(`var'*`V'[`nxt',`nxt'])
            disp in gr "  " in ye `var' " (" `se' ")"
        }
        else{
            scalar `var' = exp(2*`b'[1, `nxt'])
            scalar `se' = 2*`var'*sqrt(`V'[`nxt',`nxt'])
            disp in gr "  " in ye `var' " (" `se' ")"
        }
        local nxt = `nxt' + 1
    }
    else{
        local log "log " 
        if `nats'{
            local log
        }
        disp " "
        if `lev1'==1{disp in gr "    equation for `log'standard deviation: "}
        else if `lev1'==2{disp in gr "    equation for `log'coefficient of variation"}
        else if `lev1'==3{disp in gr "    equation for `log'(sqrt(phi))"}
        disp " "
        local i = 1
        while `i' <= `M_nbrf'[1,1]{
            scalar `var' = `b'[1,`nxt']
            scalar `se' = sqrt(`V'[`nxt',`nxt'])
            local nna: word `nxt' of `names'
            disp in gr "    `nna': " in ye `var' " (" `se' ")"
            local i = `i' + 1
            local nxt = `nxt' + 1 
        }
    }
}

if `tplv' > 1{
local lev = 2
if `free' == 1{
    disp " "
    disp in gr "Probabilities and locations of random effects"
}
else{
    disp " "
    disp in gr "Variances and covariances of random effects"
}
*disp in smcl in gr "{hline 78}" _n
di in gr _dup(78) "-" _n
*disp in gr "-----------------------------------------------------------------------------"
while (`lev' <= `tplv'){
    local nip = `M_nip'[1,`lev']
    local sof = `M_nrfc'[2,`lev'-1]  /* `M_nrfc'[1,`lev'-1] */
    disp " "
    local cl = `tplv' - `lev' + 1
    local cl: word `cl' of `e(clus)'
    disp in gr "***level `lev' (" in ye "`cl'" in gr ")"
    if `free' == 1{
        tempname M_zps`lev'
        matrix `M_zps`lev'' = e(zps`lev')
    }
    local i2 = `M_nrfc'[2,`lev']
    local i1 = `nrfold'+1
    local num = `i2' -`i1' + 1 /* number of random effects */
    if `free'==0{
        * get standard errors of variances from those of cholesky decomp.
        *disp "sechol `lev' `num' `nxt'"
        qui sechol `lev' `num' `nxt' 
    }
    local k = 1
    local i = `i1'
    local ii = 1
    local nrfold = `M_nrfc'[2,`lev']
    while `i'<= `i2'{
        local n=`M_nip'[2,`i']
        if `free'==1{
            tempname M_zlc`n'
            matrix `M_zlc`n'' = e(zlc`n')
            local j = 2
            local zz=string(`M_zlc`n''[1,1],"%7.0gc")
            local mm "`zz'"
            scalar `mn0' = `M_zlc`n''[1,1]*exp(`M_zps`lev''[1,1])
            while `j'<=`nip'{
                scalar `mn0' = `mn0' + `M_zlc`n''[1,`j']*exp(`M_zps`lev''[1,`j'])
                local zz=string(`M_zlc`n''[1,`j'],"%7.0gc")
                local mm "`mm'" ", " "`zz'"
                local j = `j' + 1
            }
            disp " "
            disp in gr "    loc`ii': " in ye "`mm'"
        }
        local j = `i1'
        local jj =  1
        while (`j'<=`i'){
            if `free'==1{
                local m = `M_nip'[2,`j']
                capture tempname M_zlc`m'
                matrix `M_zlc`m'' = e(zlc`m')
                scalar `mm0'=0
                local mm = 1
                while `mm'<=`nip'{
                    scalar `mm0' = `mm0' + `M_zlc`m''[1,`mm']*exp(`M_zps`lev''[1,`mm'])
                    local mm = `mm' + 1
                }

                local l = 1
                scalar `var' = 0
                while `l'<=`nip'{       
                    scalar `var' = `var' + /*
                    */ (`M_zlc`n''[1,`l']-`mn0')*(`M_zlc`m''[1,`l']-`mm0')*exp(`M_zps`lev''[1,`l'])
                    local l = `l' + 1
                }
                if `i' == `j'{
                    disp in gr "  var(`ii'): " in ye `var'
                    local nb = `M_nbrf'[1,`ii'+`sof']
                    if `nb'>1{
                        disp " "
                        disp in gr "    loadings for random effect " `ii'
                        local load = `nxt' + `nb' - 1
                        if `M_frld'[1,`j']==0{
                            local nna: word `load' of `names'
                            disp in gr "    `nna': " in ye  1 " (fixed)"
                        }

                        *disp in gr "    coefficient of"
                        local load = 1
                        while `load'<=`nb'-1{
                            local nna: word `nxt' of `names'
                            scalar `var'=`b'[1,`nxt']
                            scalar `se' = sqrt(`V'[`nxt',`nxt'])
                            disp in gr "    `nna': " in ye  `var' " (" `se' ")"
                            local nxt = `nxt' + 1
                            local load = `load' + 1
                        }
                        disp " "
                    }
                    local nxt = `nxt' + 1 /* skip location parameter */
                    * disp "increased nxt to" `nxt'
                    if `i'==`i2'{
                        local l = 2
                        local zz=string(exp(`M_zps`lev''[1,1]),"%6.0gc")
                        if `nip'>1{ 
                            local mm "0`zz'"
                        }
                        else{
                            local mm "1"
                        }

                        while `l'<=`nip'{
                            local zz=string(exp(`M_zps`lev''[1,`l']),"%6.0gc")
                            local mm "`mm'" ", " "0`zz'"
                            local l = `l' + 1
                        }
                        disp in gr "    prob: " in ye "`mm'"

    *new
                    *** display log odds with standard errors
                        local npar = `M_np'[1,`lev']
                        if `npar' == 0 { local npar = 1}
                        if `npar'>1{
                            disp " "
                            disp in gr "    log odds parameters"
                        }
                        local l = 1
                        while `l'< `nip'{
                            if `npar'>1{
                                if `l'>1 {
                                    disp " "
                                }
                                disp in gr "    class `l'"
                            }
                            local load = 1
                            local ncur = `nxt' + (`l' - 1)*`num' + (`l' - 1)*`npar' - 1
                            while `load'<=`npar'{
                                local ncur = `ncur' + 1
                                * disp "nxt = `nxt', nb = `nb', num = `num' and ncur = `ncur'"
                                local nna: word `ncur' of `names'
                                scalar `var'=`b'[1,`ncur']
                                scalar `se' = sqrt(`V'[`ncur',`ncur'])
                                if `npar'>1{
                                    disp in gr "    `nna': " in ye  `var' " (" `se' ")"
                                }
                                local load = `load' + 1
                            }
                            local l = `l' + 1
                        }
                        local nxt = `ncur' + 1
                    }
* end new
                }
                else{
                    disp in gr "cov(`ii',`jj'): " in ye `var'
                }
            }
            else{/* free=0 */
                * disp "k= " `k' ", i= " `i' ", j= " `j' ", ii= " `ii' ", jj= " `jj'

                scalar `var' = M_cov[`ii', `jj']
                scalar `se' = sqrt(M_se[`k', `k'])
                if `i' == `j'{
                    disp " "
                    disp in gr "    var(`ii'): " in ye `var' " (" `se' ")"
                    local nb = `M_nbrf'[1,`ii'+`sof']
                    if `nb'>1{
                        disp " "
                        disp in gr "    loadings for random effect " `ii'
                        local load = `nxt' + `nb' -1
                        if `M_frld'[1,`j']==0{
                            local nna: word `load' of `names'
                            disp in gr "    `nna': " in ye  1 " (fixed)"
                        }

                        * disp in gr "    coefficient of"
                        local load = 1
                        while `load'<=`nb'-1{
                            local nna: word `nxt' of `names'
                            * disp "nxt = " `nxt'
                            scalar `var'=`b'[1,`nxt']
                            scalar `se' = sqrt(`V'[`nxt',`nxt'])
                            disp in gr "    `nna': " in ye `var' " (" `se' ")"
                            local nxt = `nxt' + 1
                            local load = `load' + 1
                        }
                        disp " "
                    }
                    * skip variance parameter
                    local nxt = `nxt' + 1
                }
                else{
                    if `iscor'==0{
                        disp in gr "    cov(`ii',`jj'): " in ye "fixed at 0"
                    }
                    else{
                        scalar `cor' = `var'/sqrt(M_cov[`ii',`ii']*M_cov[`jj',`jj'])
                        disp in gr "    cov(`ii',`jj'): " in ye `var' " (" `se' ")" /*
                            */ " cor(`ii',`jj'): " `cor'
                        *local nxt = `nxt' + 1
                    }
                }
            }

            local j = `j' + 1
            local jj = `jj' + 1
            local k = `k' + 1
        }
        local i = `i' + 1
        local ii = `ii' + 1
    }
local lev = `lev' + 1
/* skip off-diagonal cholesky parameters */
if `iscor'~=0&`free'==0{local nxt = `nxt' + `num'*(`num'-1)/2} /* -1? */
*disp "next nxt is " `nxt'
/*
if `free'{
    local nxt = `nxt'+(`nip'-1)*(`num'+1)
    if `cip'==0{
        local nxt = `nxt'+`num'
    }
    local nxt = `nxt' - 1
}
*/
*disp "next nxt is " `nxt'
}
if `tprf'>1&`bmat'==1{
    disp " "
    disp in gr "B-matrix:"
    *disp in smcl in gr "{hline 78}" _n
    di in gr _dup(78) "-" _n
    disp " "
    disp " "
    * disp "nxt = " `nxt'
    local i = 1
    while `i'<`tprf'{
        local j = 1
        while `j' < `tprf'{
            if `M_b'[`i',`j']>0{
                scalar `var' =`b'[1,`nxt']
                scalar `se' = sqrt(`V'[`nxt',`nxt'])
                disp in gr "    B(`i',`j'): " in ye `var' " (" `se' ")"
                local nxt = `nxt' + 1
            }
            local j = `j' + 1
        }
        local i = `i' + 1
    }
}
if `ngeqs'>0{
    disp " "
    disp in gr "Regressions of latent variables on covariates"
    *disp in smcl in gr "{hline 78}" _n
    di in gr _dup(78) "-" _n
    disp " "
    tempname mngeqs
    matrix `mngeqs' = e(mngeqs)
    local i = 1
    while `i'<=`ngeqs'{
        local k = `mngeqs'[1,`i']
        local n = `mngeqs'[2,`i']
        disp in gr "    random effect " in ye `k'-1 in gr " has " in ye `n' in gr " covariates:"
        local nxt2 = `nxt'+`n'-1
        local j = 1
        while `j' <= `n'{
            local nna: word `nxt' of `names'
            scalar `var'=`b'[1,`nxt']
            scalar `se' = sqrt(`V'[`nxt',`nxt'])
            disp in gr "    `nna': " in ye  `var' " (" `se' ")"
            local nxt = `nxt' + 1
            local j = `j' + 1
        }
        local i = `i' + 1
    }
}
*disp in smcl in gr "{hline 78}" _n
di in gr _dup(78) "-" _n
disp " "
} /* endif toplv >1 */
end

program define sechol
    version 6.0
    args lev num nxt
    * num is number of random effects
    local l = `num'*(`num' + 1)/2 
    *disp "lev = `lev' num = `num' nxt = `nxt' l= `l'"
    tempname b V C L zero a H M_nbrf M_nrfc ind

    matrix `M_nbrf' = e(nbrf)
    matrix `M_nrfc' = e(nrfc)
    local iscor = e(cor)
    matrix `b' = e(b)
    matrix `V' = e(V)
    local sof = `M_nrfc'[2,`lev'-1] /* was `M_nrfc'[1,`lev'-1] */
    local i = 1
    local k = 1
    matrix `C' = J(`l',`l',0)
    matrix `L' = J(`num',`num',0)
    matrix `ind' = `L'
    * get L matrix
    while `i' <= `num'{
        * skip loading parameters
        local nb = `M_nbrf'[1,`i'+`sof']
        local nxt = `nxt' + `nb' -1
        disp "nxt = " `nxt' 
        matrix `L'[`i',`i'] = `b'[1, `nxt']
        * matrix list `L'
        matrix `ind'[`i',`i'] = `nxt'
        local nxt = `nxt' + 1
        local i = `i' + 1
    }
    local i = 2
    while `i' <= `num'&`iscor'==1{
        local j = 1
        while `j' < `i'{
            matrix `L'[`i',`j'] = `b'[1, `nxt']
            matrix `ind'[`i',`j'] = `nxt'
            local nxt = `nxt' + 1
            local j = `j' + 1
        }
        local i = `i' + 1
    }
    * disp "L and ind"
    * matrix list `L'
    * matrix list `ind'
    * get C matrix
    local ll1 = 1
    local i = 1
    while `i' <= `num'{
    local j = 1
    while `j' <= `i'{
        local nxt1 = `ind'[`i', `j']
        local ll2 = 1
        local ii = 1
        while `ii' <= `num'{
        local jj = 1
        while `jj' <= `ii'{
            local nxt2 = `ind'[`ii', `jj']
            disp "ll1 = " `ll1' " ll2 = " `ll2' " nxt1 = " `nxt1' " nxt2 = " `nxt2'
            if `iscor' == 1{
                matrix `C'[`ll1', `ll2'] = `V'[`nxt1',`nxt2']
                matrix `C'[`ll2', `ll1'] = `C'[`ll1', `ll2']
            }
            else if `i'==`j'&`ii'==`jj'{
                matrix `C'[`ll1', `ll2'] = `V'[`nxt1',`nxt2']
                matrix `C'[`ll2', `ll1'] = `C'[`ll1', `ll2']
            }
            local ll2 = `ll2' + 1
            local jj = `jj' + 1
        }
        local ii = `ii' + 1
        }
        local ll1 = `ll1' + 1
        local j = `j' + 1
    }
    local i = `i' + 1
    }

    * disp "C"
    * matrix list `C'
    matrix `zero' = J(`num', `num', 0)
    local k = 1
    local i = 1
    local n = `num' * (`num' + 1)/2
    matrix `H' = J(`n',`n',0)
    while `i' <= `num' {
        local j =  1
        while `j' <= `i'{
            * derivative of LL' with respect to i,j th element of L
            mat `a' = `zero'
            mat `a'[`i',`j'] = 1
            mat `a' = `a'*(`L')'
            mat `a' = `a' + (`a')' 
            disp "a"
            * matrix list `a'
            local ii = 1
            local kk = 1
            while `ii'<=`num'{
                local jj = 1
                while `jj' <= `ii'{
                    matrix `H'[`kk',`k'] = `a'[`ii',`jj']
                    local jj = `jj' + 1
                    local kk = `kk' + 1
                }
                local ii= `ii' + 1
            }
            local j = `j' + 1
            local k = `k' + 1
        }
        local i = `i' + 1
    }
    * disp "H"
    * matrix list `H'
    matrix M_se = `H'*`C'*(`H')'
    matrix M_cov = `L'*(`L')'
    * matrix list M_se
    * matrix list M_cov
    
end

program define timer
version 6.0
end
