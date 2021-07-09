*! version 2.2.21 SRH 7 Sept 2011
program define gllam_ll
version 7.0
*disp in re "version 7.0"
args todo bo lnf junk1 junk2 what res
* what = 1: update posterior means and standard deviations
* what = 2: posterior probabilities
* what = 3: cluster likelihood contributions*cluster frequency weights
* what = 4: cluster likelihood contributions
* what = 5-7: posterior mean of statistic
/*
noi disp " "
noi disp $HG_SD1[$which]
noi disp $HG_SD2[$which]
noi disp $HG_C21[$which]
noi disp " "
*/

if "`what'"==""{
    local what = 0
}
if `what' == 1 {
    global HG_zip zipg1
    if $HG_free{
        global HG_zip zipf1
    }
}
else if $HG_adapt{
    global HG_zip zipga
}

*matrix list `bo'
if $HG_dots {
    noi disp in gr "." _c
}

/* ----------------------------------------------------------------------------- */
/* set up variables and macros needed */

tempname b mzlc

local toplev = $HG_tplv
local topi = $HG_tpi
local clus $HG_clus

sort `clus'

* reset the the clock and reset znow
local i = 1
matrix M_ip[1,1] = 1 /* in case topi=0 */
while (`i' <= `topi'){
    matrix M_ip[1,`i'] = 1
    local i = `i' + 1
}

/* -------------------------------------------------------------------------------- */
/* set up lprod1 ... lint1 */

local i=1
tempvar extra
quietly gen double `extra'=0
while `i' <= `toplev'{               
    tempvar  lint`i'
    gen double `lint`i'' = 0.0   /* used to integrate, therefore must be zero */
    tempvar lfac`i'
    quietly gen double `lfac`i'' = 0  
    if (`i'>1){
        tempvar  lprod`i'
        quietly gen double `lprod`i'' = .
        tempvar lfac`i'
        quietly gen double `lfac`i'' = 0  
    }
    local i = `i' + 1
}

/* set up names for HG_xb`i' */
local i = 1
while (`i' <= $HG_tpff){
    tempname junk
    global HG_xb`i' "`junk'"
    local i = `i' + 1
}
/* set up names for HG_s`i' */
local i = 1
while (`i'<=$HG_tprf){
    tempname junk
    global HG_s`i' "`junk'"
    local i = `i'+1
}


if $HG_free{
/* set up names for HG_p`lev'`k' */
    local lev = 2
    while `lev'<=$HG_tplv{
        local npar = M_np[1,`lev']
        if `npar'>0{
            local k = 1
            while `k'<=M_nip[1, `lev']{
                * disp in re "creating HG_p`lev'`k'"
                tempname junk
                global HG_p`lev'`k' "`junk'"
                local k = `k' + 1
            }
        }
        local lev = `lev' + 1
    }
}


/* set up names for HG_E`rf'`lev' and  HG_V`rf'`lev' */
if `what'==1{
    local lev = 1
    while `lev'<=$HG_tplv{
        if `lev'<$HG_tplv{
            local maxrf =M_nrfc[2,`lev'+1]
        }
        else{
            local maxrf =M_nrfc[2,$HG_tplv]
        }

        local rf = 1
        while `rf'<`maxrf'{
            * disp in re "creating HG_V`rf'`rf'`lev'"
            tempname junk
            global HG_E`rf'`lev' "`junk'"
            gen double ${HG_E`rf'`lev'}=0
            tempname junk
            global HG_V`rf'`rf'`lev' "`junk'"
            gen double ${HG_V`rf'`rf'`lev'}=0
            local rf2 = `rf' + 1
            while `rf2'<$HG_tprf{ /* lower diagonal elements */
                * disp in re "creating HG_V`rf2'`rf'`lev'"
                tempname junk
                global HG_V`rf2'`rf'`lev' "`junk'"
                gen double ${HG_V`rf2'`rf'`lev'}=0
                local rf2 = `rf2' + 1
            }   
            local rf = `rf' + 1
        }

        local lev = `lev' + 1
    }
}
else if $HG_adapt{
    local llev = 1
    while `llev'<$HG_tplv{
        local lrf = M_nrfc[2,`llev']
        while `lrf'<M_nrfc[2,`llev'+1]{
            tempname junk
            global HG_E`lrf'`llev' "`junk'"
            gen double ${HG_E`lrf'`llev'}=0
            local lrf = `lrf' + 1
        }       
        local llev = `llev' + 1
    }
}

/* set up names for posterior mean of statistic */
if `what'>=5{
    tempvar lpred
    local lev = 1
    while `lev'<=$HG_tplv{
        tempname junk
        global HG_stat`lev' "`junk'"
        gen double ${HG_stat`lev'}=0
        local lev =`lev' + 1
    }
}


qui remcor "`bo'"

if $HP_prior{
    qui calc_prior
}

*noi matrix list `bo'
/*
if `npar'>0{
disp in re "after remcor: HG_p21[$which] = "  $HG_p21[$which]
disp in re "after remcor: HG_p22[$which] = "  $HG_p22[$which]
}
*/

if $HG_error==1{
    disp in re "error in remcor"
    scalar `lnf' = .
    exit
}

if "$HG_post"!=""{ /* for predictions */
    *noi tab $HG_ind
    tempvar mssvls
    * disp in re "`mssvls'"
    qui gen byte `mssvls' = 0 
    qui replace `mssvls' = 1 if ($ML_y1>=.) & $HG_ind>0
    local ffs = 1
    while `ffs' <= $HG_tpff {
        qui replace `mssvls' = 1 if ${HG_xb`ffs'} >=. & $HG_ind>0
        local ffs = `ffs' + 1
    }
    if M_nbrf[1,1]>0{
        qui replace `mssvls' = 1 if $HG_s1>=. & $HG_ind>0
    } 
}

* disp "HG_xb1 after remcor: HG_xb1[$which] = " $HG_xb1[$which]
* disp "HG_s2 after remcor: HG_s2[$which] = " $HG_s2[$which]
* disp "HG_s1 after remcor: HG_s1[$which] = $HG_s1 = " $HG_s1[$which]

if $HG_adapt{
    *noi disp " "
    local i = $HG_tprf - 1
    while `i' >= 1 {
        local ip = `i' + 1
        local k = `i' - 1
        while `k' >= 1 {
            local kp = `k' + 1
            * disp in re "replace HG_s`ip' = HG_s`ip' + HG_C`i'`k'*HG_s`kp'"
            qui replace ${HG_s`ip'} = ${HG_s`ip'} + ${HG_C`i'`k'}*${HG_s`kp'}
            local k = `k' - 1
        }
        local i = `i' - 1
    }

    local i = 2
    tempname junk
    global HG_zuoff "`junk'"
    qui gen double $HG_zuoff = 0
    while `i'<=$HG_tprf{
        local im = `i' - 1
        * disp in re "replace HG_zuoff = HG_zuoff + HG_s`i'*HG_MU`im'"
        qui replace $HG_zuoff = $HG_zuoff + ${HG_s`i'}*${HG_MU`im'}

        * disp in re "replace HG_s`i' = HG_SD`im'*HG_s`i'"
        qui replace ${HG_s`i'} = ${HG_SD`im'}*${HG_s`i'}

        local i = `i' + 1
    }
    *dis in re "HG_zuoff[$which] = " $HG_zuoff[$which]
}


local i = `toplev'
while `i' > 1 {
    *noi disp "$HG_zip `i'$
    quietly $HG_zip `i'
    local i = `i' - 1
}


timer on 2
* disp "STARTING LOOP"
/* --------------------------------------------------------------------------------- */
/* recursive loop through r.effs (levels)    */
/* topi nested loops: irf from 1 ro nip(rf) */
/* ip is "clock": (irf) stages of loops      */

local levno = `toplev'
local rf = `topi'
while (`rf' <= `topi') { /* for each r.eff */

/* ----------------------------------------------------------------------------------*/
/* reset ip to 1st point for all lower r.effs... */
/* update znow                                   */  
    * disp "reset ip up to random effect " `rf'
    while (`rf' > 1) {
        local rf = `rf' - 1
        * disp `rf'
        matrix M_ip[1,`rf'] = 1
    }
    while (`levno' > 1){
    /* update znow for all new ips    */
        *noi disp "$HG_zip `levno'$
        $HG_zip `levno'
        local levno = `levno' - 1
    }
/* --------------------------------------------------------------------------------- */
/* set lint1 to lpyz for new znow  */
        
    local rf = 1
    local levno = 1
    local sortlst `clus' /* cluster variables to aggregate over */

    *matrix list M_ip
    timer on 3
    qui lpyz `lint1'
    timer off 3

    * noi disp in re " after lpyz lint1[" $which "] = " `lint1'[$which] " and HG_ind = " $HG_ind[$which]

    if "$HG_post"!=""{/* for presictions */
        qui replace `lint1' = 0 if `mssvls'==1 
    }

    * noi disp in re " after lpyz lint1 = " `lint1'[$which] " and HG_ind = " $HG_ind[$which]
    
    if `what'>=5{
        if $HG_tplv>1{
            matrix score double `lpred' = M_znow
        }
        else{
            qui gen double `lpred' = 0
        }
        if $HG_adapt{ 
            qui replace `lpred' = $HG_xb1 + $HG_zuoff + `lpred' - $HG_offs
        }
        else{
            qui replace `lpred' = $HG_xb1 + `lpred' - $HG_offs
        } 
    timer on 5
        gllas_yu $HG_stat1 `lpred' `res' `what'
        sort `sortlst' /* added Oct 2004 */
    timer off 5
        qui drop `lpred'
    }

    *noi summ `lint1' if `lint1'==-100
    quietly count if `lint1'==.& $HG_ind>0

    * noi disp in re "number missing: " r(N)
    if r(N) > 0{
        * overflow problem
        * disp in re "overflow at level 1 ( " r(N) " missing values)"
        * list $HG_clus if `lint1'==.
        *matrix list `bo'
        *lpyz `lint1'
        if `what'!=3 { /* what = 3 used by robust & need valid ll contributions */
            scalar `lnf' = .
            exit
        }  
    }
    quietly replace `lint1' = `lint1' * $HG_wt1

/* --------------------------------------------------------------------------------- */
/* update lint for all completed levels up to */
/* highest completed level, reset lower lints */
/* to zero (for models including a random effect) */

    while (M_ip[1,`rf'] == M_nip[1,`rf'] & `rf' <= `topi'){
    * digit equals its max => increment next digit  
        if (`rf' == M_nrfc[1,`levno'] & `levno' < `toplev'){
        * done last r.eff of current level
            * disp "********** level " `levno' " complete ************"

            * next level
            local lprev = `levno'
            local levno = `levno' + 1 
 
            /* change sortlst */  
            local prvsort `sortlst'
            local l = `toplev' - `levno' + 2
            tokenize "`sortlst'"
            * take away var. of level to sum over           
            local `l' " "                 
            local sortlst "`*'"
/*------------------------------------------------------------------------------------ */
/* change lprod`levno' and  */
/* update lint`levno'       */

            if "`f`levno''"==""{ /* first term for lint`levno' */
                local f`levno'=1
                * disp "first term for level `levno'"
            }
            else{   
                local f`levno'=0
                * disp "next term for level `levno'"
            }
timer on 4 
if $HG_noC1 {
    lnupdate `levno' `lint`levno'' `lint`lprev'' `lprod`levno'' /*
        */ `lfac`levno'' `lfac`lprev'' `extra' /*
        */ `lnf' "`prvsort'" "`sortlst'" `f`levno'' `what'
}
else {
    _gllamm_lnu, levno(`levno') lintlv(`lint`levno'') /*
        */ lintprv(`lint`lprev'') lprodlv(`lprod`levno'') /*
    */ lfaclv(`lfac`levno'') lfacprv(`lfac`lprev'') extra(`extra') /* 
        */ lnf(`lnf')  prvsort(`prvsort') sortlst(`sortlst') /*
    */ first(`f`levno'') what(`what')
}
timer off 4

            local f`lprev'

*args levno lintlv lintprv lprodlv lfaclv lfacprv extra lnf prevsort sortlst first
/* ------------------------------------------------------------------------------------------- */   
        } /* next digit */
        local rf = `rf' + 1
    }
    * rf is first r.eff that is not complete
    * increase clock in lowest incomplete digit
    * disp "update rf = " `rf'
    matrix M_ip[1,`rf'] = M_ip[1,`rf'] + 1
}
timer off 2
*quietly{ 
    *now rf too high
    *!! disp "********** level " `toplev' " complete ************"
    * noi disp "lint" `toplev' "[" $which "] = " `lint`toplev''[$which]
    if(`toplev'>1){
        if `what'==1{
            local rf = 1
            while `rf'< $HG_tprf{
                * disp in re "setting HG_MU`rf' and HG_SD`rf'"
                * disp in re "by `sortlst': replace HG_MU`rf' = HG_E`rf'`toplev'/lint`toplev'[_N]"
                qui by `sortlst': replace ${HG_MU`rf'} = ${HG_E`rf'`toplev'}/`lint`toplev''[_N]
                qui by `sortlst': replace ${HG_SD`rf'} = ${HG_V`rf'`rf'`toplev'}/`lint`toplev''[_N] - ${HG_MU`rf'}^2
                qui replace ${HG_SD`rf'} = cond(${HG_SD`rf'}>0,sqrt(${HG_SD`rf'}),0) 
                *noi disp " "
                *noi disp "HG_MU`rf'[$which] = " ${HG_MU`rf'}[$which]
                *summ ${HG_MU`rf'}
                *noi disp "HG_SD`rf'[$which] = " ${HG_SD`rf'}[$which]
                *summ ${HG_SD`rf'}
                local rf2 =  1
                while `rf2' < `rf'{ /* must use MU's that are already calculated */
                    qui by `sortlst': replace ${HG_C`rf'`rf2'} = ${HG_V`rf'`rf2'`toplev'}/`lint`toplev''[_N] - (${HG_MU`rf2'}*${HG_MU`rf'}) 
                    *noi disp "HG_C`rf'`rf2'[$which] = " ${HG_C`rf'`rf2'}[$which]
                    *summ  ${HG_C`rf'`rf2'}
                    local rf2 = `rf2' + 1
                }
                local rf = `rf' + 1
            }
            if $HG_adapt==1{ /* have recalculated means and covariances and need diff. ones for adaptive */
                prepadpt
            }
        }
        else if `what'>=5{
            if $HG_post{
                qui by `sortlst': replace ${HG_stat`toplev'} = ${HG_stat`toplev'}/`lint`toplev''[_N]
            }
        }
        else if `what'==2{
            local i = 1
            while `i'<= M_nip[1,2] {
                qui by `sortlst': replace ${HG_p`i'} = ${HG_p`i'}/`lint`toplev''[_N]
                local i = `i' + 1
            }
        }
        *a disp "taking log of lint" `toplev' " = " `lint`toplev''[$which]
        *a disp "subtracting " `lfac`toplev''[$which]

        ** begin junk (conditional log-likelihood for capture-recapture)
/*
        qui replace `lint`toplev'' = exp(ln(`lint`toplev'')-`lfac`toplev'')
        qui summ `lint`toplev'', meanonly
        qui replace `lint`toplev'' = ${HG_wt`toplev'}*(ln(`lint`toplev'') - ln(r(sum)))
*/      
        ** end junk
        
        quietly replace `lint`toplev'' = (ln(`lint`toplev'')-`lfac`toplev'')* ${HG_wt`toplev'}
    }
    * noi display "lint" `toplev' "[" $which "] = " `lint`toplev''[$which]
    if `what'==3{
        if `toplev'==1{ /* by sorlst won't work for composite link */
            qui replace `res' = `lint`toplev''
        }
        else{
            qui by `sortlst': replace `res' = `lint`toplev''[_N]
        }
        if $HP_prior {
            qui replace `res' = `res' + $HP_res/ M_nu[1,$HG_tplv]
        }
    }
    else if `what'==4{
        if `toplev'==1{ /* by sorlst won't work for composite link */
            qui replace `res' = `lint`toplev''/ ${HG_wt`toplev'}
        }
        else{
            qui by `sortlst': replace `res' = `lint`toplev''[_N]/ ${HG_wt`toplev'}
        }
        if $HP_prior {
            qui replace `res' = `res' + $HP_res / M_nu[1,$HG_tplv]
        }
    }
    else if `what'>=5{
        qui replace `res' = ${HG_stat`toplev'}
    }
    qui by `sortlst': replace  `extra' = cond(_n==_N,1,0)
    *mlsum `lnf' = `lint`toplev'' if `extra' == 1 /* can only use this when program called by ML */
    *noi summ `lint`toplev'' if `extra' == 1
    *list $HG_clus `lint`toplev'' if `extra' ==1 & `lint`toplev''< -300

    qui count if `extra' == 1
    local n = r(N)
    summarize `lint`toplev'', meanonly
    if `n' > r(N) {
        * noi disp "there are " r(N) " values of likelihood, should be " `n'
        * noi list $HG_clus if `extra' == 1& `lint`toplev''==.
        * noi matrix list `bo'
        * noi disp "lnf equal to missing in last step"
        scalar `lnf' = .
        exit
    }
    scalar `lnf' = r(sum)
    if $HP_prior{
        if $HP_sprd == 1 & `what'== 0 {
            scalar `lnf' = `lnf' + $HP_res / M_nu[1,$HG_tplv]
        }
        else{
            * disp in re $HP_res
            scalar `lnf' = `lnf' + $HP_res
        }
    }
    * display in re "total lnf = " `lnf'
    * capture drop lint`toplev'
    * gen double lint`toplev' = `lint`toplev''
*} /* qui */
end

program define prepadpt
*qui replace $HG_C21 = 0
*qui replace $HG_MU1 = 0
*qui replace $HG_MU2 = 0
*qui replace $HG_SD1 = 1
*qui replace $HG_SD2 = 1
*qui replace $HG_C31 = 0
*qui replace $HG_C32 = 0
*disp in re " "

    local tplv = $HG_tplv

    local i = $HG_tprf - 1
    while `i' >= 1 {
        * disp in re " "
        qui replace ${HG_MU`i'} = 0 if ${HG_MU`i'} ==.
        *qui replace ${HG_SD`i'} = 1e-05 if ${HG_SD`i'} < 1e-25 | ${HG_SD`i'} ==.
        qui replace ${HG_SD`i'} = 1e-05 if ${HG_SD`i'} < 1e-05 | ${HG_SD`i'} ==.
* variance 
        * disp in re "HG_V`i'`i'`tplv' = HG_SD`i'^2"
        qui replace ${HG_V`i'`i'`tplv'} = ${HG_SD`i'}^2
        local j =  $HG_tprf - 1
        while `j' > `i'{ 
            * disp in re "HG_V`i'`i'`tplv' = HG_V`i'`i'`tplv' -  HG_C`j'`i'*HG_V`j'`i'`tplv' " 
            ** new
            qui replace ${HG_C`j'`i'} = 0 if ${HG_V`i'`i'`tplv'} - ${HG_C`j'`i'}*${HG_V`j'`i'`tplv'} < 0
            qui replace ${HG_V`i'`i'`tplv'} = ${HG_V`i'`i'`tplv'} - ${HG_C`j'`i'}*${HG_V`j'`i'`tplv'}
            
            qui replace ${HG_MU`i'} = ${HG_MU`i'} - ${HG_C`j'`i'}*${HG_MU`j'}
            * disp in re "HG_MU`i' = HG_MU`i' - HG_C`j'`i'*HG_MU`j' = " in ye ${HG_MU`i'}[$which]
            * noi summ ${HG_MU`i'}
            local j = `j' - 1
        }

        * disp in re "negative variances"
        * noi summ ${HG_V`i'`i'`tplv'} if ${HG_V`i'`i'`tplv'} <0 
        * noi list $HG_clus ${HG_V`i'`i'`tplv'} if ${HG_V`i'`i'`tplv'} <0
        * qui replace ${HG_V`i'`i'`tplv'} = 1e-10 if ${HG_V`i'`i'`tplv'} <0
        qui replace ${HG_SD`i'} = sqrt(${HG_V`i'`i'`tplv'})
        *disp in re "HG_MU`i' = " in ye in ye ${HG_MU`i'}[$which]
        *disp in re "HG_SD`i' = " in ye ${HG_SD`i'}[$which]
        * noi summ ${HG_SD`i'}

* covariances and betas
        local k = `i' - 1
        while `k' >= 1 {
            qui replace ${HG_V`i'`k'`tplv'} = ${HG_C`i'`k'} 
            * disp in re "HG_V`i'`k'`tplv' = HG_C`k'`i'"
            local j =  $HG_tprf - 1
            while `j' > `i'{ 
                *disp in re "HG_V`i'`k'`tplv' = HG_V`i'`k'`tplv' - HG_C`j'`i'*HG_V`j'`k'`tplv'"

                qui replace ${HG_V`i'`k'`tplv'} = ${HG_V`i'`k'`tplv'} - ${HG_C`j'`i'}*${HG_V`j'`k'`tplv'}
                local j = `j' - 1
            }
            qui replace ${HG_C`i'`k'} = ${HG_V`i'`k'`tplv'}/${HG_V`i'`i'`tplv'}
            * noi summ ${HG_C`i'`k'}
            *disp in re "HG_C`i'`k' = " in ye ${HG_C`i'`k'}[$which]
            local k = `k' - 1
        }

        local i = `i' - 1
    }
*qui replace $HG_C21 = 0
/*
qui replace $HG_MU2 = .57022599
qui replace $HG_SD2 = .83303331
qui replace $HG_MU1 = -.55565732
qui replace $HG_SD1 = .65728191
*/
end

program define lnupdate
version 7.0
args levno lintlv lintprv lprodlv lfaclv lfacprv extra lnf prvsort sortlst first what
tempvar lpkpl
quietly{
    * disp in re "!!! update level " `levno'
    * noi matrix list M_znow

    /* set previous lint to ln(lint) */
    local lprev = `levno' - 1
    if(`levno' > 2){
        *!! disp " replace lint" `lprev' " by ln(lint" `lprev' ")"
        quietly count if `lintprv' < 1e-308
        if r(N) > 0{
            /* overflow problem */
            * noi disp "overflow at level " `lprev'
            scalar `lnf' = .
            exit
        }
        if `what'==1{
            local rf = 1
            while `rf'< M_nrfc[2,`lprev']{
                * disp "by `prvsort': replace HG_E`rf'`lprev' = HG_E`rf'`lprev'/lintprv[_N]"
                    qui by `prvsort': replace ${HG_E`rf'`lprev'} = ${HG_E`rf'`lprev'}/`lintprv'[_N]
                * disp in re "by `prvsort': replace HG_V`rf'`rf'`lprev' = HG_V`rf'`rf'`lprev'/lintprv[_N]"
                qui by `prvsort': replace ${HG_V`rf'`rf'`lprev'} = ${HG_V`rf'`rf'`lprev'}/`lintprv'[_N]
                local rf2 = `rf' + 1
                while `rf2' < $HG_tprf{
                    * disp in re "by `prvsort': replace HG_V`rf2'`rf'`lprev' = HG_V`rf2'`rf'`lprev'/lintprv[_N]"
                    qui by `prvsort': replace ${HG_V`rf2'`rf'`lprev'} = ${HG_V`rf2'`rf'`lprev'}/`lintprv'[_N]
                    local rf2 = `rf2' + 1
                }
                local rf = `rf' + 1
            }

        }
        if `what'>=5{
            if $HG_post{
                qui by `prvsort': replace ${HG_stat`lprev'} = ${HG_stat`lprev'}/`lintprv'[_N]
            }
        }
        quietly replace `lintprv' = ln(`lintprv')
        quietly replace `lintprv' = (`lintprv'-`lfacprv')*${HG_wt`lprev'}
    }

    /* sum previous lprod within cluster at current level */
    *!! disp " "
    * noi disp "by `sortlst': replace lprod" `levno' "=cond(_n==N, sum(lint" `lprev' "))"
    * noi summ `lintprv'
    quietly by `sortlst': replace `lprodlv' = cond(_n==_N,sum(`lintprv'),.)
    * noi disp " "
    * noi disp "lprod" `levno' " = " `lprodlv'[$which]
    * noi disp "lintprv[" $which "]= " `lintprv'[$which]

    /* accumulate terms for integral */

    /* get lpkpl: log of product of r.effs at level */
    qui $HG_lzpr `levno' `lpkpl'
    * noi disp "exp(lprod`leno'+lpkpl) = " exp(`lpkpl'[$which]+`lprodlv'[$which])

    if `first' { /* first term for lint`levno' */
        quietly replace `extra' = 0
        quietly replace `lfaclv' = -`lprodlv' - `lpkpl'
        *a noi disp " "
        * noi disp "lfac`levno' = " `lfaclv'[$which]
        * noi disp "lintlv = 1"
                qui replace `lintlv' = 1
    }
    else{
        local max = 500
        quietly replace `extra' = cond(`lprodlv'+ `lpkpl'+`lfaclv'>`max', /*
                    */ -(`lprodlv'+`lpkpl'+`lfaclv')+`max',0)
        * noi disp "extra = " `extra'[$which]
        quietly replace `lfaclv'=`lfaclv'+`extra'
        * noi disp "lfac`levno' = " `lfaclv'[$which]

        /* increment lint at current level using lprod at previous level */
        * noi disp "increase lint" `levno' " by exp(lprodlv + lpkpl +lfaclv)"
        quietly replace `lintlv' = exp(`extra')*`lintlv' + exp(`lprodlv'+ `lpkpl'+`lfaclv')
        * noi disp "increase by " exp(`lprodlv'[$which]+`lpkpl'[$which]+`lfaclv'[$which]) " to "  `lintlv'[$which]
    }


/* posterior means and variances*/
    if `what'==1{
        local rf = 1
        while `rf'< M_nrfc[2,`levno'] {
            * noi disp "update `rf' `levno'"
            quietly by `sortlst': replace ${HG_E`rf'`levno'}=/*
            */ exp(`extra'[_N])*${HG_E`rf'`levno'}+ ${HG_E`rf'`lprev'}*exp(`lprodlv'[_N]+`lpkpl'+`lfaclv'[_N])
            * noi disp "HG_E" `rf' `levno' "[" $which "] = "  ${HG_E`rf'`levno'}[$which]
            quietly by `sortlst': replace ${HG_V`rf'`rf'`levno'}=/*
            */ exp(`extra'[_N])*${HG_V`rf'`rf'`levno'}+ ${HG_V`rf'`rf'`lprev'}*exp(`lprodlv'[_N]+`lpkpl'+`lfaclv'[_N])
            *noi disp "HG_V" `rf' `rf' `levno' "[" $which "] = "  ${HG_V`rf'`rf'`levno'}[$which]
            local rf2 = `rf' + 1
            while `rf2' < $HG_tprf {
                * noi disp "HG_V`rf2'`rf'`levno' is ${HG_V`rf2'`rf'`levno'}"
                quietly by `sortlst': replace ${HG_V`rf2'`rf'`levno'}=/*
                */ exp(`extra'[_N])*${HG_V`rf2'`rf'`levno'}+ ${HG_V`rf2'`rf'`lprev'}*exp(`lprodlv'[_N]+`lpkpl'+`lfaclv'[_N])    
                * noi disp "HG_V" `rf2' `rf' `levno' "[" $which "] = "  ${HG_V`rf2'`rf'`levno'}[$which]
                local rf2 = `rf2' + 1
            }
            local rf = `rf' + 1
        }

    }
    if `what'>=5{
        if $HG_post{
            * disp in re "sortlist: `sortlst'"
            *sort `sortlst' /* removed oct 2004 */
            quietly by `sortlst': replace ${HG_stat`levno'}=/*
            */ exp(`extra'[_N])*${HG_stat`levno'}+ /*
            */ ${HG_stat`lprev'}*exp(`lprodlv'[_N]+`lpkpl'+`lfaclv'[_N])
        }
        else{
            *disp in re "HG_stat`levno'[1] = " ${HG_stat`levno'}[1] " + " ${HG_stat`lprev'}[1] " * " exp(`lpkpl')
            qui replace ${HG_stat`levno'} = ${HG_stat`levno'} + ${HG_stat`lprev'}*exp(`lpkpl')
        }
    }

    else if `what'==2{
        * noi matrix list M_ip
        local i = M_ip[1,2]
        local j = 1
        while `j'<`i'{
            quietly by `sortlst': replace ${HG_p`j'} = exp(`extra'[_N])*${HG_p`j'}
            local j = `j' + 1
        }
        quietly by `sortlst': replace ${HG_p`i'} = exp(`lprodlv'[_N]+`lpkpl'+`lfaclv'[_N])
    }
    /* reset previous lint to zero */
    if `levno'>2{
        if `what'==1{
            local rf = 1
            while `rf'<M_nrfc[2,`lprev']{
                * disp in re "replace HG_V`rf'`rf'`lprev' = 0"
                    qui replace ${HG_E`rf'`lprev'} = 0
                qui replace ${HG_V`rf'`rf'`lprev'} = 0
                local rf2 = `rf' + 1
                while `rf2' < $HG_tprf{
                    * disp in re "replace HG_V`rf2'`rf'`lprev' = 0"
                    qui replace ${HG_V`rf2'`rf'`lprev'} = 0
                    local rf2 = `rf2' + 1
                }
                local rf = `rf' + 1
            }
    
        }
        *!! disp "setting lint" `lprev' " to zero"
        quietly replace `lintprv' = 0
        quietly replace `lfacprv' = 0
        *!!!!new
        if `what'>=5{
            *disp in re "setting HG_stat" `lprev' " to zero"
            quietly replace ${HG_stat`lprev'} = 0
        }
    }
 } /* qui */
end

program define zipf
    version 7.0
    * updates znow 
    * matrix list M_ip
    args levno

    * disp "in zip, levno is " `levno'
    local i = M_nrfc[2,`levno'-1] + 1

    *!! disp "update" 
    *  same class for all random effects
    local k = M_nrfc[1,`levno']
    local k = M_ip[1,`k']
    local last = M_nrfc[2,`levno']
    while `i' <= `last'{
        local npt = M_nip[2,`i']
        local im = `i' - 1
        * disp "     "`im' "th z to " `which' "th location"
        * disp " using M_zlc`npt' "
        matrix M_znow[1,`im'] = M_zlc`npt'[1,`k']
        local i = `i' + 1
    }
end

program define zipf1
    version 7.0
    * updates znow 
    * matrix list M_ip
    args levno
    tempname mzlc

    * disp "in zip, levno is " `levno'
    local i = M_nrfc[2,`levno'-1] + 1

    *!! disp "update" 
    *  same class for all random effects
    local k = M_nrfc[1,`levno']
    local k = M_ip[1,`k']
    local last = M_nrfc[2,`levno']
    while `i' <= `last'{
        local npt = M_nip[2,`i']
        local im = `i' - 1
        * disp "     "`im' "th z to " `which' "th location"
        * disp " using M_zlc`npt' "
        matrix M_znow[1,`im'] = M_zlc`npt'[1,`k']
        local i = `i' + 1
    }
    local llev = `levno' - 1
    local im = M_nrfc[2,`llev']
    while `im' < `last'{
* change HG_E and HG_V
        scalar `mzlc' = M_znow[1,`im']
        qui replace ${HG_E`im'`llev'} = ${HG_MU`im'} + ${HG_SD`im'}*`mzlc'
        local im2 = $HG_tprf - 1
        while `im2' > `im'{
            scalar `mzlc' = M_znow[1,`im2']
            * disp in re "replace HG_E`im'`llev' = HG_E`im'`llev' + HG_C`im2'`im'*(HG_MU`im2' + HG_SD`im2'*`mzlc')"
            qui replace ${HG_E`im'`llev'} = ${HG_E`im'`llev'} + ${HG_C`im2'`im'}*(${HG_MU`im2'} + ${HG_SD`im2'}*`mzlc')
            local im2 = `im2' - 1
        }   
        * noi disp "HG_E`im'`llev'[$which] = " ${HG_E`im'`llev'}[$which]
        qui replace ${HG_V`im'`im'`llev'} = ${HG_E`im'`llev'}^2

        local im = `im' + 1
    }
    local im = M_nrfc[2,`llev']
    while `im' < `last'{
* covariances with same level and higher level effects
        local llev2 = `llev'
        local im2 = `im' + 1
        while `llev2'<$HG_tplv{
            while `im2' < M_nrfc[2,`llev2' + 1]{
                qui replace ${HG_V`im2'`im'`llev'} = ${HG_E`im'`llev'}*${HG_E`im2'`llev2'}
                * disp in re "HG_V`im2'`im'`llev' = HG_E`im'`llev'*HG_E`im2'`llev2' = " in ye ${HG_V`im2'`im'`llev'}[$which]
                local im2 = `im2' + 1
            }   
            local llev2 = `llev2' + 1
        }               
        local im = `im' + 1
    }
end

program define zipg
    version 7.0
    * updates znow 
    * matrix list M_ip
    args levno

    * disp "in zip, levno is " `levno'
    local i = M_nrfc[2,`levno'-1] + 1

    *!! disp "update" 
    if $HG_mult{
        *local npt = M_nip[2,`i']
        local npt = M_nip[2,`levno']
        local k = M_nrfc[1,`levno']
        local k = M_ip[1,`k']
        local f = M_nrfc[2,`levno'-1]
    }

    local last = M_nrfc[2,`levno']
    while `i' <= `last'{
        local im = `i' - 1

        if $HG_mult{
            matrix M_znow[1,`im'] = M_zlc`npt'[`i'-`f',`k']
        }
        else{
            local npt = M_nip[2,`i']
            local which = M_ip[1,`i']
            * disp "     "`im' "th z to " `which' "th location"
            * disp " using M_zlc`npt' "
            matrix M_znow[1,`im'] = M_zlc`npt'[1,`which']
        }

        *!! disp M_znow[1,`im'] 
        local i = `i' + 1
    }
end


program define zipga
    version 7.0
    * updates znow 
    * matrix list M_ip
    args levno
    tempname mzlc

    * disp "in zip, levno is " `levno'
    local llev = `levno' - 1
    local i = M_nrfc[2,`llev'] + 1

    *!! disp "update" 
    if $HG_mult{
        *local npt = M_nip[2,`i']
        local npt = M_nip[2,`levno']
        local k = M_nrfc[1,`levno']
        local k = M_ip[1,`k']
        local f = M_nrfc[2,`levno'-1]
    }
    local last = M_nrfc[2,`levno']

    while `i' <= `last'{
        *local npt = M_nip[2,`i']
        local im = `i' - 1

        if $HG_mult{
            matrix M_znow[1,`im'] = M_zlc`npt'[`i'-`f',`k']
        }
        else{
            local npt = M_nip[2,`i']
            local which = M_ip[1,`i']
            * disp "     "`im' "th z to " `which' "th location"
            * disp " using M_zlc`npt' "
            matrix M_znow[1,`im'] = M_zlc`npt'[1,`which']
        }
        local i = `i' + 1
    }
    local im = M_nrfc[2,`llev']
    while `im' < `last'{

* change HG_E
        scalar `mzlc' = M_znow[1,`im']
        qui replace ${HG_E`im'`llev'} = ${HG_MU`im'} + ${HG_SD`im'}*`mzlc'
        *local im2 = M_nrfc[2,`llev']

        local im2 = $HG_tprf - 1
        while `im2' > `im'{
            scalar `mzlc' = M_znow[1,`im2']
            * disp in re "replace HG_E`im'`llev' = HG_E`im'`llev' + HG_C`im2'`im'*(HG_MU`im2' + HG_SD`im2'*`mzlc')"
            qui replace ${HG_E`im'`llev'} = ${HG_E`im'`llev'} + ${HG_C`im2'`im'}*(${HG_MU`im2'} + ${HG_SD`im2'}*`mzlc')
            local im2 = `im2' - 1
        }                       
        * noi disp "HG_E`im'`llev'[$which] = " ${HG_E`im'`llev'}[$which]

        *!! disp M_znow[1,`im'] 
        local im = `im' + 1
    }
end


program define zipg1
    version 7.0
    * updates znow 
    * matrix list M_ip
    args levno
    tempname mzlc

    * noi disp "in zip, levno is " `levno'
    local llev = `levno' - 1
    local i = M_nrfc[2,`llev'] + 1

    *!! disp "update" 
    if $HG_mult{
        *local npt = M_nip[2,`i']
        local npt = M_nip[2,`levno']
        local k = M_nrfc[1,`levno']
        local k = M_ip[1,`k']
        local f = M_nrfc[2,`levno'-1]
    }
    local last = M_nrfc[2,`levno']

    while `i' <= `last'{
        local im = `i' - 1
        *local npt = M_nip[2,`i']
        if $HG_mult{
            * disp in re "M_znow[1,`im'] = M_zlc`npt'[`i'-`f',`k']"
            matrix M_znow[1,`im'] = M_zlc`npt'[`i'-`f',`k']
        }
        else{
            local npt = M_nip[2,`i']
            local which = M_ip[1,`i']
            * disp "     "`im' "th z to " `which' "th location"
            * disp " using M_zlc`npt' "
            matrix M_znow[1,`im'] = M_zlc`npt'[1,`which']
        }

        local i = `i' + 1
    }
    local im = M_nrfc[2,`llev']
    while `im' < `last'{
* change HG_E and HG_V
        scalar `mzlc' = M_znow[1,`im']
        qui replace ${HG_E`im'`llev'} = ${HG_MU`im'} + ${HG_SD`im'}*`mzlc'
        local im2 = $HG_tprf - 1
        while `im2' > `im'{
            scalar `mzlc' = M_znow[1,`im2']
            * disp in re "replace HG_E`im'`llev' = HG_E`im'`llev' + HG_C`im2'`im'*(HG_MU`im2' + HG_SD`im2'*`mzlc')"
            qui replace ${HG_E`im'`llev'} = ${HG_E`im'`llev'} + ${HG_C`im2'`im'}*(${HG_MU`im2'} + ${HG_SD`im2'}*`mzlc')
            local im2 = `im2' - 1
        }   
        * noi disp "HG_E`im'`llev'[$which] = " ${HG_E`im'`llev'}[$which]
        qui replace ${HG_V`im'`im'`llev'} = ${HG_E`im'`llev'}^2

        local im = `im' + 1
    }
    local im = M_nrfc[2,`llev']
    while `im' < `last'{
* covariances with same level and higher level effects
        local llev2 = `llev'
        local im2 = `im' + 1
        while `llev2'<$HG_tplv{
            while `im2' < M_nrfc[2,`llev2' + 1]{
                qui replace ${HG_V`im2'`im'`llev'} = ${HG_E`im'`llev'}*${HG_E`im2'`llev2'}
                * disp in re "HG_V`im2'`im'`llev' = HG_E`im'`llev'*HG_E`im2'`llev2' = " in ye ${HG_V`im2'`im'`llev'}[$which]
                local im2 = `im2' + 1
            }   
            local llev2 = `llev2' + 1
        }               
        local im = `im' + 1
    }
end


program define lzprobf
    version 7.0
    * for free masses
    * returns product of pk needed for integration at level lev for current ip
    args levno lpkpl
    tempname mzps mznow
    * disp in re "in zprob, levno is " `levno'

    local i=M_nrfc[1,`levno'-1] + 1 

    *!! disp "-----------lpkpl: sum of log of" 

    local npt = M_nip[2,`i']
    * disp "     prob for " `i' "th r.eff: " `which' "th weight"
    * disp " using M_zps`npt' "

    local which = M_ip[1,`i']
    if M_np[1,`levno']>0{
        qui gen double `lpkpl' = ${HG_p`npt'`which'}
    }
    else{
        qui gen double `lpkpl' =  M_zps`npt'[1,`which']
    }

    * disp in re "lpkpl[$which] = " `lpkpl'[$which]
end

program define lzprobg
    version 7.0
    * product gaussian quadrature
    * returns product of pk needed for integration at level lev for current ip
    args levno lpkpl
    tempname mzps mznow
    * disp in re "in zprob, levno is " `levno'
    qui gen double `lpkpl' = 0
    local lv = `levno' - 1
    local i=M_nrfc[1,`lv'] + 1 

    *!! disp "-----------lpkpl: sum of log of" 
    local last = M_nrfc[1,`levno'] 
    while `i' <= `last'{
        local npt = M_nip[2,`i']
        * disp "     prob for " `i' "th r.eff: " `which' "th weight"
        * disp " using M_zps`npt' "

        local which = M_ip[1,`i']
        local im = `i' - 1
        scalar `mzps' = M_zps`npt'[1,`which']
        qui replace `lpkpl' = `lpkpl'+ `mzps'
        if $HG_adapt{
            scalar `mznow' = M_znow[1,`im']
            *qui replace `lpkpl' = `lpkpl' + ln(${HG_SD`im'}) + `mznow'^2/2 - (${HG_MU`im'} + ${HG_SD`im'}*`mznow')^2/2
            qui replace `lpkpl' = `lpkpl' + ln(${HG_SD`im'}) + `mznow'^2/2 - (${HG_E`im'`lv'})^2/2
        }
        local i=`i'+1
    }
    * disp in re "lpkpl[$which] = " `lpkpl'[$which]
end

program define lzprobm
    version 7.0
    * mult version
    * returns product of pk needed for integration at level lev for current ip
    args levno lpkpl
    tempname mzps mznow
    * disp in re "in zprob, levno is " `levno'

    local lv = `levno' - 1
    local i=M_nrfc[1,`lv'] + 1 

    *!! disp "-----------lpkpl: sum of log of" 

    local npt = M_nip[2,`i']
    * disp "     prob for " `i' "th r.eff: " `which' "th weight"
    * disp " using M_zps`npt' "

    local which = M_ip[1,`i']
    scalar `mzps' = M_zps`npt'[1,`which']
    qui gen double `lpkpl' = `mzps'

    if $HG_adapt{
        local i=M_nrfc[2,`lv'] + 1 
        local last = M_nrfc[2,`levno']
        while `i' <= `last'{
            local im = `i' - 1
            scalar `mznow' = M_znow[1,`im']
            qui replace `lpkpl' = `lpkpl' + ln(${HG_SD`im'}) + `mznow'^2/2 - (${HG_E`im'`lv'})^2/2
            *disp in re "HG_E`im'`lv'[$which] = " ${HG_E`im'`lv'}[$which]
            local i = `i' + 1
        }
    }
    *disp in re "lpkpl[$which] = " `lpkpl'[$which]
end


program define lpyz
    version 7.0
* returns log of prob of obs. given znow
    args lpyz

    * disp "-----------------called lpyz"

    tempvar zu xb mu /* linear predictor and zu: r.eff*design matrix for r.eff */

/* ----------------------------------------------------------------------------- */
*quietly{
    

    if $HG_tprf>1{

        matrix score double `zu' = M_znow
        if $HG_adapt{ 
            qui replace `zu' = $HG_zuoff + `zu'
            *qui replace `zu' = $HG_E11*$HG_s2 + $HG_E21*$HG_s3 
        }

        
    }
    else{
        qui gen double `zu' = 0
    }

    * matrix list M_znow
    * disp "ML_y1: $ML_y1 " $ML_y1[$which]
    * matrix list M_ip
    disp " xb1 = " $HG_xb1[$which]
    disp " zu = " `zu'[$which]


    if $HG_mlog>0{
        nominal `lpyz' `zu'
    }

    if $HG_oth{
        local myand
        if "$HG_lv"~=""&($HG_nolog>0|$HG_mlog>0){
            local myand $HG_lvolo~=1
        }
        quietly gen double `mu' = 0
        *if $HG_noC|$HG_comp>0 {
    if $HG_noC {
            link "$HG_link" `mu' $HG_xb1 `zu' $HG_s1
            if $HG_comp>0 {
                compos `mu' "`myand'"
            }
            *disp " mu = " `mu'[$which]
            if $HG_comp>0{
                if "`myand'"~=""{
                    local myand `myand' & $HG_ind>0
                }
                else{
                    local myand $HG_ind>0
                }
            }
            family "$HG_famil" `lpyz' `mu' "`myand'"
        }

        else {
            if $HG_lev1 != 0 {
                local s1opt "st($HG_s1)"
            }
            if "$HG_denom" != "" {
                local denopt "denom($HG_denom)"
            }
            if "$HG_fv" != "" {
                local fvopt "fv($HG_fv)"
            }
            if "$HG_lv" != "" {
                local lvopt "lv($HG_lv)"
                local othopt "oth(M_oth)"
            }
            if "`myand'" != "" {
                local ifopt "if `myand'"
            }
            if $HG_comp > 0 { /* only got here if new Stata 8 */
                local comp "comp($HG_comp)"
                local cclus "cluster($HG_clus)"
            }
            noi _gllamm_fl `lpyz' `mu' `ifopt', `s1opt' /*
            */ link($HG_link) family($HG_famil) `denopt' `fvopt' /*
            */ `lvopt' xb($HG_xb1) zu(`zu') /*
            */ y($ML_y1) `othopt' `comp' `cclus'
        }
        disp  " mu = " `mu'[$which]
    }

    if $HG_nolog>0{
        if $HG_noC {
            ordinal `lpyz' `zu'
        }
        else {
            if $HG_lev1 != 0 {
                local stopt st($HG_s1)
            }
            if "$HG_lv"!="" {
                local lvopt lv($HG_lv)
            }
            local j 1
            while `j'<=$HG_tpff {
                local xbeta `xbeta' ${HG_xb`j'}
                local j = `j' + 1
            }
            _gllamm_ord `lpyz', y($ML_y1) xb(`xbeta') /*
            */ zu(`zu') link($HG_linko) nlog($HG_nolog) /*
            */ olog(M_olog) nresp(M_nresp) resp(M_resp) /*
            */ `stopt' `lvopt'
        }
    }

*} /* qui */
end

program define compos
    version 7.0
    args mu und
    
    tempvar junk mu2
    local ifs
    if "`und'"~=""{
        local ifs if `und'
    }
    gen double `junk'=0
    gen double `mu2'=.
    local i = 1
    *disp in re "in compos: HG_clus is: $HG_clus"
    while `i'<= $HG_comp{
        *disp in re "in compos: variable HG_co`i' is: ${HG_co`i'}" 
        replace `junk' = `mu'*${HG_co`i'}
        qui by $HG_clus: replace `junk' = sum(`junk')
        qui by $HG_clus: replace `mu2' = `junk'[_N] if $HG_ind==`i'
        local i = `i' + 1
    }
    qui replace `mu' = `mu2' `ifs'
end

program define nominal
    version 7.0
    args lpyz zu
    tempvar mu

    if $HG_smlog{
        local s $HG_s1
    }
    else{
        local s = 1
    }
    local and
    if "$HG_lv"~=""{
        local and & $HG_lv == $HG_mlog
        local mlif if $HG_lv == $HG_mlog
    }
    disp "mlogit link `mlif'"
    if $HG_exp==1&$HG_expf==0{
        qui gen double `mu' = exp(`zu'/`s') if $ML_y1==M_respm[1,1] `and'
        local n=rowsof(M_respm)
        local i=2
        while `i'<=`n'{
            local prev = `i' - 1 
            * disp "xb`prev':" ${HG_xb`prev'}[$which]
            qui replace `mu' = exp((${HG_xb`prev'} + `zu')/`s') if $ML_y1==M_respm[`i',1] `and'
            local i = `i' + 1
        }

        sort $HG_clus $HG_ind
        qui by $HG_clus: replace `lpyz'=cond(_n==_N,sum(`mu'),.) `mlif'
        qui replace `lpyz' = ln(`mu'/`lpyz') `mlif'
/*  skip sort
    qui by $HG_clus: replace `lpyz' = sum(`mu') `mlif'
    qui by $HG_clus: replace `lpyz' = cond($HG_ind>0,ln(`mu'/`lpyz'[_N]),.) `mlif'

*/
    }
    else if $HG_exp==1&$HG_expf==1{
        qui gen double `mu' = exp(($HG_xb1 + `zu')/`s') `mlif'
        sort $HG_clus $HG_ind
        * disp "sort $HG_clus $HG_ind"
        qui by $HG_clus: replace `lpyz'=cond(_n==_N,sum(`mu'),.) `mlif'
        * disp "denom = " `lpyz'[$which]
        qui replace `lpyz' = ln(`mu'/`lpyz') `mlif' 
    }
    else{
        tempvar den tmp
        local n=rowsof(M_respm)
        local i = 2
        qui gen double `mu' = 1 if $ML_y1==M_respm[1,1] `mlif'
        qui gen double `den' = 1
        qui gen double `tmp' = 0
        while `i'<= `n'{
            local prev = `i' - 1 
            qui replace `tmp' = exp((${HG_xb`prev'} + `zu')/`s') `mlif'
            qui replace `mu' =  `tmp' if $ML_y1==M_respm[`i',1] `mlif'
            replace `den' = `den' + `tmp' `mlif'
            local i = `i' + 1
        }
        replace `lpyz' = ln(`mu'/`den') `mlif'
    }
end

program define ordinal
    version 7.0
    args lpyz zu
    local no = 1
    local xbind = 2
    tempvar mu p1 p2
    qui gen double `p1' = 0
    qui gen double `p2' = 0
    qui gen double `mu' = 0

    while `no' <= $HG_nolog{
        local olog = M_olog[1,`no']
        local lnk: word `no' of $HG_linko

        if "`lnk'"=="ologit"{
            local func logitl
        }
        else if "`lnk'"=="oprobit"{
            local func probitl
        }
        else if "`lnk'"=="ocll"{
            local func cll
        }
        else if "`lnk'"=="soprobit"{
            local func sprobitl
        }
        local and
        if "$HG_lv"~=""&$HG_nolog>0{
            local and & $HG_lv == `olog'
        }
        * disp "ordinal link is `lnk', and = `and'"
        local n=M_nresp[1,`no']

        * disp  "HG_xb1: " $HG_xb1
        * disp  "xbind = " `xbind'
        * disp  ${HG_xb`xbind'}[$which]

        qui replace `mu' = $HG_xb1+`zu'-${HG_xb`xbind'}
        `func' `mu' `p1'
        qui replace `lpyz' = ln(1-`p1') /*
            */ if $ML_y1==M_resp[1,`no'] `and'
        qui replace `p2' = `p1'
        local i = 2
        while `i' < `n'{
            local nxt = `xbind' + `i' - 1 

            * disp "nxt = " `nxt'
            * disp ${HG_xb`nxt'}[$which]

            qui replace `mu' = $HG_xb1+`zu'-${HG_xb`nxt'}
            `func' `mu' `p2'

            * disp "p1 and p2: "  `p1'[$which] " " `p2'[$which]

            qui replace `lpyz' = ln(`p1' -`p2') /*
                */ if $ML_y1==M_resp[`i',`no'] `and'
            qui replace `p1' = `p2'
            local i = `i' + 1
        }
        local xbind = `xbind' + `n' -1
        qui replace `lpyz' = ln(`p2') /*
            */ if $ML_y1==M_resp[`n',`no'] `and'
        local no = `no' + 1
    } /* next ordinal response */
    *tab $ML_y1 if `lpyz'==. `and'
    qui replace `lpyz' = -100 if `lpyz'==. `and'
end

program define logitl
    version 7.0
    args mu p
    qui replace `p' = 1/(1+exp(-`mu'))
end

program define cll
    version 7.0
    args mu p
    qui replace `p' = 1-exp(-exp(`mu'))
end

program define probitl
    version 7.0
    args mu p
    qui replace `p' = normprob(`mu')
end

program define sprobitl
    version 7.0
    args mu p
    qui replace `p' = normprob(`mu'/$HG_s1)
end


program define link
    version 7.0
* returns mu for requested link
    args which mu xb zu s1
    * disp " in link, which is `which' "

    tokenize "`which'"
    local i=1
    local ifs
    while "`1'"~=""{
        if "$HG_lv" ~= ""{
            local oth =  M_oth[1,`i']
            local ifs if $HG_lv==`oth'
        }
        * disp "`1' link `ifs'"
        
        if ("`1'" == "logit"){
            quietly replace `mu' = 1/(1+exp(-`xb'-`zu')) `ifs'
        }
        else if ("`1'" == "probit"){
            * disp "doing probit "
            quietly replace `mu' = normprob((`xb'+`zu')) `ifs'
        }
        else if ("`1'" == "sprobit"){
            quietly replace `mu' = normprob((`xb'+`zu')/`s1') `ifs'
        }
        else if ("`1'" == "log"){
            * disp "doing log "
            quietly replace `mu' = exp(`xb'+`zu') `ifs'
        }
        else if ("`1'" == "recip"){
            * disp "doing recip "
            quietly replace `mu' = 1/(`xb'+`zu') `ifs'
        }
        else if ("`1'" == "cll"){
            * disp "doing cll "
            quietly replace `mu' = 1 - exp(-exp(`xb'+`zu')) `ifs'
        }
        else if ("`1'" == "ll"){
            quietly replace `mu' = exp(-exp(`xb'+`zu')) `ifs'
        }
        else if ("`1'" == "ident"){
            quietly replace `mu' = `xb'+`zu' `ifs'
        }
        local i = `i' + 1
        mac shift
    }

end

program define family
    version 7.0
    args which lpyz mu und

    tokenize "`which'"
    local i=1
    * disp "in family, und = `und'"
    if "$HG_fv" == ""{
        local ifs
        if "`und'"~=""{local und if `und'}
    }
    else{
        if "`und'"~=""{local und & `und'}
    }
    while "`1'"~=""{
        if "$HG_fv" ~=""{
            local ifs if $HG_fv == `i'
        }
        if ("`1'" == "binom"){
            famb `lpyz' `mu' "`ifs'" "`und'"
        }
        else if ("`1'" == "poiss"){
            famp `lpyz' `mu' "`ifs'" "`und'"
        }
        else if ("`1'" == "gauss") {
            *disp in re "famg lpyz mu $HG_s1 `ifs' `und'"
            famg `lpyz' `mu' $HG_s1 "`ifs'" "`und'"  /* get log of conditional prob. */
        }
        else if ("`1'" == "gamma"){
            famga `lpyz' `mu' $HG_s1 "`ifs'" "`und'"
        }
        else{
            disp in re "unknown family in gllam_ll"
            exit 198
        }
        local i = `i' + 1
        mac shift
    }
end
    
program define famg
    version 7.0
* returns log of normal density conditional on r.effs
    args lpyz mu s1 if and
    * disp "running famg `if' `and'"
    * disp "s1 = " `s1'[$which] ", mu = " `mu'[$which] " and Y = " $ML_y1[$which]
        quietly replace `lpyz' = /*
        */ -(ln(2*_pi*`s1'^2) + (($ML_y1-`mu')/`s1')^2)/2 `if' `and'
end

program define famb
    version 7.0
* returns log of binomial density conditional on r.effs
* $HG_denom is denominator
    args lpyz mu if and
    * disp "running famb `if' `and'"
    * disp "mu = " `mu'[$which] " and Y = " $ML_y1[$which]
    qui replace `lpyz' = cond($ML_y1>0,$ML_y1*ln(`mu'),0)                 /*
        */ + cond($HG_denom-$ML_y1>0,($HG_denom-$ML_y1)*ln(1-`mu'),0) /* 
        */ + cond($HG_denom>1,lngamma($HG_denom+1)-lngamma($ML_y1+1)  /*
        */ -  lngamma($HG_denom-$ML_y1+1),0) `if' `and'
    *tab $ML_y1 `if' `and' & `lpyz'==.
    qui replace `lpyz' = cond(`lpyz'==.,-100,`lpyz') `if' `and'
    * disp "done famb"
end

program define famp
    version 7.0
* returns log of poisson density conditional on r.effs
    args lpyz mu if and
    *!! disp "running famp `if'"
    * disp in re "if and: `if' `and'"
    quietly replace `lpyz' = /*
        */ $ML_y1*(ln(`mu'))-`mu'-lngamma($ML_y1+1) `if' `and'
    * qui replace `lpyz' = cond(`lpyz'==.,-100,`lpyz') `if' `and'
    * disp "done famp"
end

program define famga
    version 7.0
* returns log of gamma density conditional on r.effs
    args lpyz mu s1 if and
    *!! disp "running famg `if'"
    *!! disp "mu = " `mu'[$which]
    *!! disp "s1 = " `s1'[$which]
    qui replace `mu' = 0.0001 if `mu' <= 0
    tempvar nu
    qui gen double `nu' = `s1'^(-2)
        quietly replace `lpyz' = /*
        */ `nu'*(ln(`nu')-ln(`mu')) - lngamma(`nu')/*
        */ + (`nu'-1)*ln($ML_y1) - `nu'*$ML_y1/`mu' `if' `and'
end

program define timer
version 7.0
end
