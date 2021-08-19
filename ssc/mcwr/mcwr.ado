*! version 1.0.0  2021-02-11 dcs mm avr

program define mcwr

    version 12

    gettoken subcmd rest : 0 , parse(", ")

    local subcmd = lower(`"`subcmd'"')
    local lsubcmd = length("`subcmd'")

    if "`subcmd'" == substr("check",1,max(2,`lsubcmd')) {
        _mcwr_check `rest'
    }
    else if "`subcmd'" == substr("switch",1,max(2,`lsubcmd')) {
        _mcwr_switch `rest'
    }
    else if "`subcmd'" == substr("exit",1,max(4,`lsubcmd')) {
        _mcwr_exit `rest'
    }
    else if "`subcmd'" == substr("genvars",1,max(2,`lsubcmd')) {
        _mcwr_genvars `rest'
    }
    else if "`subcmd'" == substr("expectancies",1,max(3,`lsubcmd')) {
        _mcwr_expectancies `rest'
    }
    else if "`subcmd'" == substr("matlist",1,max(5,`lsubcmd')) {
        _mcwr_matlist `rest'
    }
    else if "`subcmd'" == substr("matbrowse",1,max(5,`lsubcmd')) {
        _mcwr_matbrowse `rest'
    }
    else if "`subcmd'" == substr("exampledata",1,max(4,`lsubcmd')) {
        _mcwr_exampledata `rest'
    }
    else if trim("`subcmd'")=="" {
        disp as error `"Subcommand required."'
        exit 198
    }
    else {
        disp as error `"Subcommand '`subcmd'' not recognized."'
        exit 198
    }
    
end

program _mcwr_check , rclass
// checks whether data are consistent ready for calculation
// assumes ji variables, can be changed via option -ij-

    syntax , [ ij SKipexit noEXit]
    
    local minobs 3
    if "`exit'"=="noexit" local minobs 2
    if c(N)<`minobs' {
        disp as error `"Not enough observations."'
        exit 2000
    }
    
    // age
    confirm variable age
    capture {
        assert !mi(age)
        isid age // require unique values
    }
    if _rc {
        disp as error `"Variable 'age' does not exist or does not fulfill requirements."'
        exit 459
    }
    
    mata : st_local("sorted", strofreal(all(sort(st_data(., "age", .), 1):==st_data(., "age", .))) )
    if !`sorted' error 5
    
    if `: word count `skipexit' `exit''==2 {
        disp as error `"Options 'skipexit' and 'noexit' are mutually exclusive."'
        exit 198
    }
    
    local absN = c(N)    // row to check for absorption values
    local trN  = c(N)-1  // last transition obs to be checked
    if "`skipexit'"!="" {
        local absN = .  // do not check absorption row
    }
    if "`exit'"=="noexit" {
        local absN = .  // do not check absorption row
        local trN = c(N)
    }
    
    // 'p??' variables
    mata : _mcwr_statelocals("`ij'")
        
    qui ds age `p_exi' , has(type string)
    if "`r(varlist)'"!="" error 108
    
    tempvar jnk jnk2
    foreach v of varlist `p_exi' {
        capture assert mi(`v') in 1/1
        if _rc {
            disp as error `"Variable '`v'' non-missing for baseline age."'
            exit 459
        }

        capture assert inrange(`v', 0, 1) in 2/`trN'
        if _rc {
            disp as error `"Variable '`v'' outside of [0 1]."'
            exit 459
                // this covers missing values, even though err msg is not ideal
        }
    }
    
    foreach s of local s_frm {
        capture drop `jnk' `jnk2'
        if "`ij'"=="" qui egen `jnk'  = rowtotal(p`s'?)
        if "`ij'"!="" qui egen `jnk'  = rowtotal(p?`s')
        qui gen `jnk2' = reldif(`jnk', 1)
        qui su  `jnk2' in 2/`trN' , meanonly
        if (r(max)>1e-6) {
            disp as error `"Probabilities for from-state `s' do not sum close enough to 1."'
            exit 459
        }
    }
    
        // check absorption row
    if !mi(`absN') {
        foreach v of local p_exi {
            if "`ij'"=="" local toabs = (substr("`v'", 3, 1)=="`s_abs'")
            if "`ij'"!="" local toabs = (substr("`v'", 2, 1)=="`s_abs'")
            if (`toabs' & `v'[`absN']!=1) | (!`toabs' & !mi(`v'[`absN']) ) {
                disp as error `"Problem with absorption row value for variable '`v''."'
                exit 459
            }
            
        }
    }
    
    // r?_?? variables
    mata : _mcwr_rewardslocals("`s_frm' `s_abs'", "`ij'")

    foreach v in `r_exi' {
        capture assert mi(`v') in 1/1
        if _rc {
            disp as error `"Variable '`v'' non-missing for baseline age."'
            exit 459
        }
        
        capture assert !mi(`v') in 2/`trN'
        if _rc {
            disp as error `"Variable '`v'' missing for transition ages."'
            exit 459
        }
        
        // check absorption row
        if !mi(`absN') {
            foreach v of local r_exi {
                if "`ij'"=="" local toabs = (substr("`v'", 5, 1)=="`s_abs'")
                if "`ij'"!="" local toabs = (substr("`v'", 4, 1)=="`s_abs'")
                if (`toabs' & mi(`v'[`absN'])) | (!`toabs' & !mi(`v'[`absN']) ) {
                    disp as error `"Problem with absorption row value for variable '`v''."'
                    exit 459
                }
            }
        }
    }
    
    // returning model information
    qui levelsof age , local(agelist)
    local numages = `trN'
    
    tempvar n
    qui gen `n' = age[_n+1]-age in 1/`trN'
    if !mi(`absN') qui replace `n' = 0 in l
    mata : st_local("ageintervals", invtokens(strofreal(st_data(1::`trN',"`n'",.)')))
    
    return local hasexit     = !mi(`absN')
    return local ageintervals  `ageintervals'
    return local agelist       `agelist'
    return local numages       `numages'
    
    _mcwr_sub_readvll , states(`s_frm' `s_abs')
    if `hasvll' {
        forvalues s=9(-1)1 {
            return local s`s'desc = `"`s`s'desc'"'
        }
    }
    
    local retlist p_exi p_ful p_new /*
               */ s_trn s_frm s_trg s_abs s_omt /*
               */ r_exi r_ful r_new /*
               */ r_trn s_rcv s_nrc
    local numret : word count `retlist'
    forvalues r=`numret'(-1)1 { // reverse return order
        local retval : word `r' of `retlist'
        return local `retval' ``retval''
    }
    
end

program define _mcwr_switch , rclass
// switches between the default (j->i) and the exceptional (i<-j) variable names
    
    syntax , [ ji      /// data are always ji after command conclusion
               NOIsily /// 
             ] 
    
    local ij ""
    local oldorder ji
    
    if "`noisily'"!="" disp as text "Checking data in memory for consistency with ji-format..."
    capture `noisily' _mcwr_check , skipexit // fails if probs do not sum to 1
    
    if _rc {
        if "`noisily'"!="" {
            disp as text "    ...failed."
            disp as text "Checking data in memory for consistency with ij-format..."
        }
        capture `noisily'  _mcwr_check , ij skipexit // fails if probs do not sum to 1
        
        if _rc {
            if "`noisily'"!="" disp as text "    ...failed." _n

            disp as error `"Either data are neither in ji-format nor in ij-format,"'
            disp as error `"or another data requirement is not fulfilled."'
            
            if "`noisily'"=="" {
                disp as error `"Re-run with 'noisily' option for more information:"'
                disp as error `". mcwr switch , noisily"'
            }
            
            exit _rc
        }
        
        local ij ij
        local oldorder ij
    }
    
    if "`noisily'"!="" disp as text "    ...success."
    
    local neworder ij
    if "`oldorder'"=="ij" local neworder ji

    mata : _mcwr_statelocals("`ij'")
    mata : _mcwr_rewardslocals("`s_frm' `s_abs'", "`ij'")
    
    if "`ji'"!="" & "`oldorder'"=="ji" {
        return local newvarnames `p_exi' `r_exi's
        return local oldvarnames `p_exi' `r_exi'
        return local neworder `oldorder'
        return local oldorder `oldorder'
        exit
    }
    
    if "`noisily'"!="" disp as text "Switching format to `neworder'-format."
    mata : _mcwr_revvars("`p_exi' `r_exi'")
    ren (`p_exi' `r_exi') (`revvars')
    
    return local newvarnames `revvars'
    return local oldvarnames `p_exi' `r_exi'
    return local neworder `neworder'
    return local oldorder `oldorder'
    
end

program define _mcwr_exit

    syntax , age(string) [ REWards(numlist min=1 max=1) ]
    
    local 0 `age'
    syntax anything(name=age id=age) , [replace update]
    qui numlist "`age'" , min(1) max(1)
    
    qui su age
    if `age'<r(max) {
        disp as error `"Age in option 'age()' may not be smaller than the maximum age in the data set."'
        exit 125
    }
    local ismaxage = (`age'==r(max))
    
    if `ismaxage' {
        if "`replace'"=="" {
            disp as error `"Age `age' specified in option 'age()' already exists."'
            disp as error `"Use suboption 'replace' to allow modification of any incorrect values."'
            exit 459
        }
        
        _mcwr_check , skipexit
        local p_exi "`r(p_exi)'"
        local r_exi "`r(r_exi)'"
        local s_abs "`r(s_abs)'"

    }
    else {  // `age'>r(max)
        _mcwr_check , noexit
        local p_exi "`r(p_exi)'"
        local r_exi "`r(r_exi)'"
        local s_abs "`r(s_abs)'"
        
        qui insobs 1 , after(`c(N)')
        qui replace age = `age' in l
    }

    foreach v in `p_exi' {
        local frm = substr("`v'",2,1)
        local trg = substr("`v'",3,1)
        if `trg'!=`s_abs' qui replace `v' = . in l
        if `trg'==`s_abs' qui replace `v' = 1 in l
    }
    foreach v in `r_exi' {
        
        if "`rewards'"=="" local rewards 0
        
        local frm = substr("`v'",4,1)
        local trg = substr("`v'",5,1)
        if `trg'!=`s_abs' {
            qui replace `v' = . in l
        }
        else {
            if `ismaxage' {
                if "`update'"!="" | `=mi(`v'[_N])' qui replace `v' = `rewards' in l
            }
            else {
                qui replace `v' = `rewards' in l
            }
        }
    }
    
end

program define _mcwr_genvars , rclass
    
    syntax , [ TIMing(string) nop nor ORDer ]
    
    _mcwr_check
    
    mata : _mcwr_statelocals("")
    mata : _mcwr_rewardslocals("`s_frm' `s_abs'")
    
    preserve  // undo var generation in case unforeseen errors occur
    
    _mcwr_sub_readvll , states(`s_frm' `s_abs')
    if "`p'"!="nop" {
        foreach v in `p_new' {
            local frm = substr("`v'",2,1)
            local trg = substr("`v'",3,1)
            qui gen `v' = 0 in 2/-2
            if `trg'==`s_abs' qui replace `v' = 1 in l
            
            if `hasvll' local frm `s`frm'desc'
            if `hasvll' local trg `s`trg'desc'
            label variable `v' `"Prob `frm'=>`trg'"'
        }
        local vars_existed `p_exi'
        local vars_filled  `p_new'
    }
    
    if "`r'"!="nor" {
        
        if `"`timing'"'=="" {
            disp as error `"Option 'timing()' required."'
            exit 198
        }
        
        local 0 `timing'
        syntax anything(name=fracfrm id=fracfrm) , [add replace]
        if "`r_exi'"!="" {
            if `: word count `add' `replace''!=1 {
                disp as error `"Exactly one of 'add' or 'replace' required."'
                exit 198
            }
        }
        
        capture confirm number `fracfrm'
        if _rc {
            if !inlist("`fracfrm'", "bop", "mid", "eop") {
                disp as error `"Option 'timing' incorrectly specified."'
                exit 198
            }
            if "`fracfrm'"=="bop" local fracfrm 0
            if "`fracfrm'"=="mid" local fracfrm 0.5
            if "`fracfrm'"=="eop" local fracfrm 1
        }
        else {
            if !inrange(`fracfrm', 0, 1) {
                disp as error `"Number in option 'timing()' must be in the range [0 1]."'
                exit 125
            }
        }
    
        local newvars `r_new'
        if "`replace'"!="" {
            local newvars `r_ful'
            capture drop r?_??
        }
        
        tempvar n
        qui gen `n' = age[_n+1]-age in 1/-2
        qui replace `n' = 0 in l
    
        foreach v in `newvars' {
            local rwd = substr("`v'", 2, 1)
            local frm = substr("`v'", 4, 1)
            local trg = substr("`v'", 5, 1)
            
            qui gen `v' = 0 in 2/-2
            // remember that the rewards assignment statemente below critically hinge
            //   on the convention that only rewards for from/target states are allowed / present / used
            // remember that in all cases, rewards are distriuted for the previous period only ([_n-1])

            // `fracfrm' = from-state reward; `fracfrm'=0 => bop;  `fracfrm'=0.5 => mid; `fracfrm'=1 => eop
            if "`rwd'"=="`frm'"   qui replace `v' =          `fracfrm'  * `n'[_n-1] in 2/-2
            if "`rwd'"=="`trg'"   qui replace `v' = `v' + (1-`fracfrm') * `n'[_n-1] in 2/-2
            if "`trg'"=="`s_abs'" qui replace `v' =          `fracfrm'  * `n'[_n-1] in l
            
            if `hasvll' {
                local frm `s`frm'desc'
                local trg `s`trg'desc'
                local rwd `s`rwd'desc'
            }
            label variable `v' `"State `rwd' rw, trn `frm'=>`trg'"'
        }
        local vars_existed `mcwrvars_existed' `r_exi'
        local vars_filled  `mcwrvars_filled' `r_new'
    }
    
    if "`order'"!="" {
        capture ds r*
        if !_rc local rstar r*
        order p* `rstar' , after(age) alpha
    }
    
    return local vars_existed `vars_existed'
    return local vars_filled  `vars_filled'
    
    restore , not
end

program define _mcwr_expectancies , rclass

    syntax , [ INItprop(string) ///
               TIMing(passthru) ///
               keep             /// keeps additional prob/rewards vars in data set
             ]
    
    qui ds
    local origvars = r(varlist)
    
    mata : _mcwr_statelocals("")
    mata : _mwcr_vlldefs("`s_frm'")
    
    if "`initprop'"!="" {
        local numtokens : word count `initprop'
        if `numtokens'>1 {
            if `numtokens'!=`: word count `s_frm'' {
                disp as error `"Number of initial states in option 'initprop' incorrect."'
                exit 9
            }
            foreach t in `initprop' {
                confirm number `t'
            }
            tempname init2
            mata : st_matrix("`init2'", strtoreal(tokens("`initprop'")))
            tempname initprop
            matrix `initprop' = `init2'
                // `initprop' now tempname for matrix; previously local from option -initprop()-
        }
        else {
            confirm matrix `initprop'
            if `=rowsof("`initprop'")'!=1 {
                disp as error `"Matrix '`initprop'' in option 'initprop()' must have a single row only."'
                exit 9
            }
            local cnames : colnames `initprop'
            if !`: list vll_sdesc==cnames' & !`: list s_frm==cnames' {
                disp as error `"Matrix '`initprop'' in option 'initprop()' does not"'
                disp as error `"have the right number of columns or invalid column names."'
                exit 9
            }
            if matmissing(`initprop') {
                disp as error `"Matrix '`initprop'' in option 'initprop()' has missing values."'
                exit 9
            }
        }
        mata : st_local("sumsto1", strofreal(reldif(sum(st_matrix("`initprop'")), 1)<1e-3))
        if !`sumsto1' {
            disp as error `"Elements in option 'initprop()' do not sum to 1."'
            exit 9
        }
    }
    
    preserve  // undo var generation in case unforeseen errors occur
    if `"`timing'"'!="" _mcwr_genvars , `timing' order

    _mcwr_check
    
    mata : _mcwr_statelocals("")
    mata : _mcwr_rewardslocals("`s_frm' `s_abs'")
    
    if "`p_new'`r_new'"!="" {
        disp as error `"Transition probability or rewards variables missing."'
        exit 459
    }
    
    local matlist e P F
    tempname e P F
    local matlist_pass `e' `P' `F'
    foreach s in `s_frm' {
        local matlist      `matlist' R`s'
        tempname R`s'
        local matlist_pass `matlist_pass' `R`s''
    }

    mata : _mcwr_lexp("`s_frm' `s_abs'", "`matlist_pass'")
        // returns matrices in tempnames passed
    
    if "`keep'"=="" keep  `origvars'
    order `origvars'

    local P_last : label MCWR `s_abs'
    if "`P_last'"=="." local P_last `s_abs':-
    
    matrix rownames `e' = `vll_rowstripe_e'
    matrix colnames `e' = `vll_colstripe_e'
    matrix rownames `F' = `vll_stripe_F'
    matrix colnames `F' = `vll_stripe_F'
    matrix rownames `P' = `vll_stripe_F' `P_last'
    matrix colnames `P' = `vll_stripe_F' `P_last'
    local Rlist
    foreach r in `s_frm' {
        matrix rownames `R`r'' = `vll_stripe_F' `P_last'
        matrix colnames `R`r'' = `vll_stripe_F' `P_last'
        local Rlist R`r'
    }
    
    tempname total
    scalar `total' = `e'[rowsof("`e'"), colsof("`e'")]
    
    return clear
    if "`initprop'"!="" return matrix initprop = `initprop'
    forvalues m=`: word count `matlist''(-1)1 {  // nicer to return in inverted seq
        local mat : word `m' of `matlist'
        return matrix `mat' = ``mat'' , copy
    }
    
    return scalar total = `total'
    
    if `c(noisily)' matlist `e'
    
    restore, not
    
end

program define _mcwr_matbrowse

    syntax anything(name=matname id=matname) , [ * ]
    
    if !inlist("`matname'", "e", "P", "F") & !strmatch("`matname'", "R?") {
        disp as error `"Only matrices e, P, F, R# allowed."'
        exit 198
    }

    local usematname r(`matname')
    capture confirm matrix `usematname'
    if _rc {
        local usematname `matname'
        capture confirm matrix `usematname'
        if _rc {
            disp as error `"Matrix `matname' neither found as a regular Stata matrix nor as an r()-results matrix."'
            exit 111
        }
    }

    matbr `usematname' , `options'

end

program define _mcwr_matlist

    syntax anything(name=matname id=matname) , [ LINes(passthru) * ]
    
    if !inlist("`matname'", "e", "P", "F") & !strmatch("`matname'", "R?") {
        disp as error `"Only matrices e, P, F, R# allowed."'
        exit 198
    }
    
    local usematname r(`matname')
    capture confirm matrix `usematname'
    if _rc {
        local usematname `matname'
        capture confirm matrix `usematname'
        if _rc {
            disp as error `"Matrix `matname' neither found as a regular Stata matrix nor as an r()-results matrix."'
            exit 111
        }
    }
    
    if `"`lines'"'=="" local lines `"lines(eq)"'
    
    matlist `usematname' , `lines' `options'

end

program define _mcwr_exampledata

    syntax anything(name=snipnum id=snipnum)
    
    numlist "`snipnum'" ,  min(1) max(1) range(>0) int
    local snipnum = r(numlist)
    
    local snip1desc "data loaded: no r-vars, abs row ok, 3 transient states"
    local snip2desc "data loaded: life table, 1-year (e_0=80.16)"  // e0 = 80.16
    local snip3desc "data loaded: life table, 5-year (e_0=80.16)"
    local snip4desc "data loaded: no r-vars, abs row ok, 2 transient states only"
    local snip5desc "data loaded: full set of r-vars, abs row ok, 2 transient states only"
    local snip6desc "data loaded: 1y ltb data set in rewards format, but ax column"
    local snip7desc "data loaded: 5y ltb data set in rewards format, but ax column"
    local snip8desc "data loaded: 1y ltb data set in rewards format, incl mid r-vars"
    local snip9desc "data loaded: 5y ltb data set in rewards format, incl mid r-vars"
    
    if `c(changed)' {
        disp as error `"Clear your data in memory before using {cmd:mcwr} example data."'
        exit 4
    }
    
    quietly {
        if inrange(`snipnum', 1, 3) {

            if `snipnum'==1 local fname mcwr_ret_3s_1y
            if `snipnum'==2 local fname mcwr_ltb_1s_1y
            if `snipnum'==3 local fname mcwr_ltb_1s_5y
            
            qui findfile `fname'.dta
            qui use "`r(fn)'"
        }
        else if `snipnum'==4 {
            _mcwr_exampledata 1
            
            replace p11 = p11 + p12
            drop p12
            drop p2?
            
        }
        else if `snipnum'==5 {
            _mcwr_exampledata 4
            
            mcwr genvars , timing(mid) nop
        }
        else if inlist(`snipnum', 6, 7) {
            
            _mcwr_exampledata `=`snipnum'-4'
            
            expand 2 in 1
            sort age
            foreach v of varlist p11-ax {
                replace `v' = . in 1
            }
            
            replace age = age[_n+1] in 1/-2
            replace age = age + 1 in l
            
            replace p11 = . in l
            label values age .
        }
        else if inlist(`snipnum', 8, 9) {
            
            _mcwr_exampledata `=`snipnum'-2'
            
            mcwr genvars , timing(mid)
        }
    }
    
    disp as text "(mcwr example data set loaded)"
    mata : st_updata(0)
    
end

*** --------------------------------- SUBROUTINES -----------------------------------------

program _mcwr_sub_readvll
// reads vll MCWR and does corresponding c_locals s#desc, #=1-9
// does not do any consistency checks
    
    syntax , states(numlist >=1 <=9 int sort)
    
    capture label list MCWR
    if _rc {
        c_local hasvll 0
        exit
    }
    
    c_local hasvll 1
    foreach s of local states {
        c_local s`s'desc `: label MCWR `s''
    }
    
end

*** --------------------------------- MATA ------------------------------------------------

version 12

mata:
mata set matastrict on

void _mcwr_statelocals(|string scalar ij) {
// does various c_locals related to p?? variables and model state lists
// performs several consistency checks
// arg ij : one of '', 'ij' ; if 'ij', assumes (i<-j) variables
    
    real   matrix    m_jnk
    string rowvector vnames, pnames,
                     p_exi, p_ful, p_new
    real   rowvector s_trn, s_frm, s_trg, s_omt
    real   scalar    s_abs, s_jnk, i
    
    if (args()==0 | ij=="") {
        ij = ""
    } else {
        if (ij!="ij")
            exit(_error("arg 'ij' incorrectly specified"))  // gives error 3498
    }

    vnames = st_varname(1..st_nvar())
    
    pnames =          select(vnames, regexm(vnames, "^p[^0-9].$"))
    pnames = (pnames, select(vnames, regexm(vnames, "^p.[^0-9]$")))
    if (length(pnames)>0)
        exit(_error("3-char 'p??' variables must have '??' as numeric digits." ))
    
    pnames = select(vnames, regexm(vnames, "^p[0-9][0-9]$"))
    
    if (length(pnames)==0)
        exit(_error("no 'p??' variables in data set." ))
    
    if (any(substr(pnames, 2, 1):=="0") | any(substr(pnames, 3, 1):=="0"))
        exit(_error("State encoding in 'p??' variables must be 1-9. 0 is not allowed." ))

    s_trn = strtoreal(substr(pnames, 2, 2))
    
    if (ij=="") {  // default ji variables : sort pji in order j-i
        s_trn = sort(s_trn', 1)'
        s_frm = uniqrows(floor(s_trn/10)')'
        s_trg = uniqrows(mod(s_trn, 10)' )'
    }
    else {  // ij variables : sort pij in order j-i
        _transpose(s_trn)
        m_jnk = sort( (floor(s_trn/10), mod(s_trn, 10) ) , (2,1))
        s_trn = (m_jnk[.,1]*10 + m_jnk[.,2])'
        s_trg = uniqrows(floor(s_trn/10)')'  // uniqrows() sorts
        s_frm = uniqrows(mod(s_trn, 10)' )'
    }

    s_abs = max(s_trg)
    s_jnk = max(s_frm)
    
    if (s_jnk>=s_abs)
        exit(_error("Largest target state (" + strofreal(s_abs) + 
                    ") not bigger than largest from-state (" + strofreal(s_jnk) + ")." ))
    
    s_omt = J(1,0,.)
    for (i=1;i<max((s_abs, s_jnk));i++) {
        if (!any(i:==(s_frm , s_trg)))
            s_omt = (s_omt , i)
    }

    // require that all target states (except for the absorbing state) must also exist as a from-state
    for (i=1;i<length(s_trg);i++) {
        if (sum(s_trg[i]:==s_frm)!=1)
            exit(_error("Transitions are incomplete. Some from-states are not in the data set."))
            // it does not make sense to specify a target state and have no out-transitions from that state.
            // Hence, I require that all from-states exist in the data set, and that their probs sum to one.
    }

    // lists of existing, full, and new trans vars,
    p_exi = "p" :+ strofreal(s_trn)
    m_jnk = ds_twocomb(s_frm', (s_frm, s_abs)')
    if (ij=="ij")
        m_jnk = m_jnk[.,(2,1)]
    p_ful = ( "p" :+ strofreal(m_jnk[.,1]) :+ strofreal(m_jnk[.,2]) )'

    p_new = J(1, 0, "")
    for (i=1;i<=length(p_ful);i++) {
        if (!any(p_exi:==p_ful[i]))
            p_new = (p_new, p_ful[i])
    }

    st_local("p_exi", invtokens(p_exi))
    st_local("p_ful", invtokens(p_ful))
    st_local("p_new", invtokens(p_new))
    
    st_local("s_trn", invtokens(strofreal(s_trn)))
    st_local("s_frm", invtokens(strofreal(s_frm)))
    st_local("s_trg", invtokens(strofreal(s_trg)))
    st_local("s_abs",           strofreal(s_abs) )
    st_local("s_omt", invtokens(strofreal(s_omt)))
        // p_exi : p-variables, existing
        // p_ful : p-variables, full model-implied list
        // p_new : p-variables that are model-implied but not existing
        
        // s_trn : transitions   that occur in existing p-variables
        // s_frm : from-states   that occur in existing p-variables
        // s_trg : target-states that occur in existing p-variables
        // s_abs : absorbing state (scalar)
        // s_omt : does not occur in the data set, will be omitted from analysis

}

void _mcwr_rewardslocals(transmorphic vector s_all, |string scalar ij) {
// does various c_locals related to r?_?? variables
// performs several consistency checks
// arg s_all : sorted list of all model states, including the absorbing state
//             can be passed in Mata vector form (1,2,3) or in Stata local form "1 2 3"
// arg ij    : one of '', 'ij' ; if 'ij', assumes (i<-j) variables

    real   matrix    m_jnk, m_jnk2
    string rowvector vnames, rnames,
                     r_exi, r_ful, r_new
    
    real   rowvector r_trn, r_all, s_frm,
                     s_rcv, s_nrc
    real   scalar    s_abs, i
    
    if (args()==0 | ij=="") {
        ij = ""
    } else {
        if (ij!="ij")
            exit(_error("arg 'ij' incorrectly specified"))  // gives error 3498
    }

    if (eltype(s_all)=="string")
        s_all = strtoreal(tokens(s_all))
    s_frm = s_all[1..length(s_all)-1]
    s_abs = s_all[length(s_all)]
    
    vnames = st_varname(1..st_nvar())
    
    rnames =          select(vnames, regexm(vnames, "^r[^0-9]_..$"))
    rnames = (rnames, select(vnames, regexm(vnames, "^r._[^0-9].$")))
    rnames = (rnames, select(vnames, regexm(vnames, "^r._.[^0-9]$")))
    if (length(rnames)>0)
        exit(_error("5-char 'r?_??' variables must have all '?' as numeric digits." ))
    
    rnames = select(vnames, regexm(vnames, "^r[0-9]_[0-9][0-9]$"))

    if (length(rnames)>0) {
        m_jnk = strtoreal(substr(rnames', (2, 4, 5), (1, 1, 1)))

        if (any(m_jnk:==0))
            exit(_error("State encoding in 'r?_??' variables must be 1-9. 0 is not allowed." ))
        
        r_trn = uniqrows(strtoreal(substr(rnames, 4, 2))')'
        if (ij=="") {  // default ji variables : sort unique rr_ji in order j-i
            r_trn = sort(r_trn', 1)'
        } else {       // ij variables         : sort unique rr_ij in order j-i
            _transpose(r_trn)
            m_jnk2 = sort( (floor(r_trn/10), mod(r_trn, 10) ) , (2,1))
            r_trn  = (m_jnk2[.,1]*10 + m_jnk2[.,2])'
        }

        // lists of existing, full, and new rewards vars,
        r_all = uniqrows(vec(m_jnk))  // all states mentioned in rewards vars must be in s_all
        for (i=1;i<=length(r_all);i++)
            if (!sum(r_all[i]:==s_all)==1)
                exit(_error("Some 'r?_??' variables are inconsistent with the set of 'p??' variables." ))

        if (ij=="") {  // default ji variables : sort rr_ji in order r-j-i
            r_exi = sort(rnames', 1)'
        } else {       // ij variables         : sort rr_ij in order r-j-i
            m_jnk = sort( m_jnk , (1,3,2))
            r_exi = ( "r" :+ strofreal(m_jnk[.,1]) :+ "_" :+ strofreal(m_jnk[.,2]*10 + m_jnk[.,3]) )'
        }

        // check that rewards only go to from or target states
        if ( any(rowsum(m_jnk[.,1]:==m_jnk[.,(2,3)]):==0) )
            exit(_error("Some 'r?_??' variables reward states other than from/target states." ))
    }
    
    m_jnk = ds_twocomb(s_frm', s_all')
    m_jnk = ds_twocomb(s_frm', m_jnk) // first col is reward receiving state
    if (ij=="ij")
        m_jnk = m_jnk[.,(1,3,2)]
    
    m_jnk = select(m_jnk, (rowsum(m_jnk[.,1]:==m_jnk[.,(2,3)])):>=1 )
    r_ful = ( "r" :+ strofreal(m_jnk[.,1]) :+ "_" :+ strofreal(m_jnk[.,2]*10 + m_jnk[.,3]) )'

    if (length(rnames)==0) {
        r_new = r_ful
        s_nrc = s_frm
    } else {
        r_new = J(1, 0, "")
        for (i=1;i<=length(r_ful);i++) {
            if (!any(r_exi:==r_ful[i]))
                r_new = (r_new, r_ful[i])
        }

        // rewards (non-)receiving states
        s_rcv = uniqrows(strtoreal(substr(rnames, 2, 1))')'
        s_nrc = J(1,0,.)
        for (i=1;i<=length(s_frm);i++)
            if (sum(s_frm[i]:==s_rcv)!=1)
                s_nrc = (s_nrc , r_all[i])
    }
    
    st_local("r_exi", invtokens(r_exi))
    st_local("r_ful", invtokens(r_ful))
    st_local("r_new", invtokens(r_new))
    
    st_local("r_trn", invtokens(strofreal(r_trn)))
    st_local("s_rcv", invtokens(strofreal(s_rcv)))
    st_local("s_nrc", invtokens(strofreal(s_nrc)))
        // r_exi : r-variables, existing
        // r_ful : r-variables, full model-implied list
        // r_new : r-variables that are model-implied but not existing
        
        // r_trn : transitions   that occur in existing r-variables
        // s_rcv : rewards     receiving states
        // s_nrc : rewards non-receiving states
        
        // all lists are sorted
        // sorted means w.r.t to ji/ij convention, with the from-states index being slower than the to-states index
        // rewards index is moving the slowest

}

void _mcwr_revvars(string scalar vlist) {
// reverses (switches) states in a varlist, e.g. converts "r1_21 r4_13" to "r1_12 r4_31"
//   always switches that last two chars of an input token
// defines local revvars
// doesn't do any checks on input list
    
    string rowvector vars, revvars
    real vector vlen
    
    if (strlen(strtrim(vlist))==0)
        return
    
    vars = tokens(vlist)
    vlen = strlen(vars)
    
    revvars = substr(vars, 1, vlen:-2) :+ substr(vars, vlen, 1) :+ substr(vars, vlen:-1, 1)
        // works for pure lists of p-/r-vars and for mixtures thereof
        
    st_local("revvars", invtokens(revvars))
    
}

void _mcwr_lexp(transmorphic vector s_all, string vector matnames) {
// calculates lexp, P, F, R`r'
// returns matrices in tempnames passed
// arg s_all : see _mcwr_rewardslocals()
    
    pointer(real matrix) rowvector Rvec
    real   rowvector s_frm
    real   scalar    s_abs, tau, om, iidx, jidx, i, j, r
    real   matrix    data, lexp, P, X, F, init
    string rowvector vars

    if (length(matnames)==1)
        matnames = tokens(matnames)

    if (eltype(s_all)=="string")
        s_all = strtoreal(tokens(s_all))
    s_frm = s_all[1..length(s_all)-1]
    s_abs = s_all[length(s_all)]
    tau = length(s_frm)
    om  = c("N") - 1  // omega as defined in paper
    
    // j is from state, always!
    // good to remember this rule, especially b/c of complications of ji/ij conventions in -mcwr- and paper
    // example variables in code are always in the default ji-format

    P = J(tau*om+1, tau*om+1, 0)
    jidx = 1
    for (j=1;j<=tau;j++) {
        vars = "p" :+ strofreal((J(1,tau,s_frm[j]*10) + s_frm))
        data = st_data(2::om, vars, .)
        iidx = 1
        for (i=1;i<=tau;i++) {
            P[|iidx,jidx \ iidx+om-1,jidx+om-1|] = ds_gdiag(data[.,i], -1)
            iidx = iidx + om
        }
        jidx = jidx + om
    }
    vars = "p" :+ strofreal( (10*s_frm) :+ s_abs)
    data = st_data(2::om+1, vars, .)
    P[|iidx,1 \ iidx,jidx|] = (vec(data)' , 1)
    
    F = luinv(I(tau*om)-P[|1,1 \ tau*om,tau*om|])  // TODO: check for invertibility first!!

    Rvec = J(1, tau, NULL)
    for (r=1;r<=tau;r++) {
        // algo makes use of the fact that rewards only occur for from- or target states
        //   other submatrices are always zero => no nested i/j loop
        
        X = J(tau*om+1, tau*om+1, 0)
        vars = "r" + strofreal(s_frm[r]) + "_" :+ strofreal((J(1,tau,s_frm*10) :+ s_frm[r])) // e.g. r2_12, r2_22, r2_42
        data = st_data(2::om, vars, .)
        iidx = om * (r-1) + 1
        jidx = 1
        for (j=1;j<=tau;j++) {
            X[|iidx,jidx \ iidx+om-1,jidx+om-1|] = ds_gdiag(data[.,j], -1)
            jidx = jidx + om
        }

        vars = "r" + strofreal(s_frm[r]) + "_" :+ strofreal((J(1,tau,s_frm[r]*10) + s_frm)) // e.g. r2_21, r2_22, r2_24
        data = st_data(2::om, vars, .)
        jidx = om * (r-1) + 1
        iidx = 1
        for (i=1;i<=tau;i++) {
            X[|iidx,jidx \ iidx+om-1,jidx+om-1|] = ds_gdiag(data[.,i], -1)
            iidx = iidx + om
        }
        
        vars = "r" + strofreal(s_frm[r]) + "_" + strofreal(s_frm[r]*10 + s_abs) // e.g. r2_25
        data = st_data(2::om+1, vars, .)
        X[|tau*om+1,1 \ tau*om+1,tau*om+1|] = ((e(r, tau) # data') , 0)
        Rvec[r] = &(X*1)
    }

    lexp = J(0,tau,.)
    for (r=1;r<=tau;r++) {
        lexp = (lexp \ (F' * (colsum(P:*(*Rvec[r]))')[1::tau*om])[range(1, 1+(tau-1)*om, om)]' )
    }

    if (tau>1) {
        lexp = (lexp \ colsum(lexp))
        lexp = (lexp , J(rows(lexp), 1, .))
        
        if (st_local("initprop")!="") {
            init = st_matrix(st_local("initprop"))
            lexp[.,tau+1] = rowsum(lexp[.,1..tau] :* init)
        }
    }

    Rvec = (&lexp, &P, &F, Rvec)
    for (i=1;i<=length(Rvec);i++) {
        st_matrix(matnames[i], *Rvec[i])
    }
}

void _mwcr_vlldefs(transmorphic vector s_frm) {
// does all c_locals related to vll MCWR

    real   scalar      om, tau
    real   rowvector   idxvec
    string rowvector   sdesc, agedesc
    transmorphic matrix jnk
    
    if (eltype(s_frm)=="string")
        s_frm = strtoreal(tokens(s_frm))
    om  = c("N") - 1
    
    tau = length(s_frm)
    
    sdesc   = strtoname(st_vlmap("MCWR", s_frm))
    idxvec = selectindex(sdesc:=="")
    if (length(idxvec)>0)
        sdesc[idxvec] = strofreal(s_frm[idxvec])
    
    agedesc = strofreal(st_data(., "age", .)[1::om])'
    jnk = ds_twocomb(sdesc', agedesc')
    
    st_local("vll_stripe_F"   , invtokens((jnk[.,1] :+ ":" :+ jnk[.,2])'))
    if (tau==1) {
        st_local("vll_rowstripe_e", invtokens("e" :+ agedesc[1] :+ "-" :+ (sdesc) ) )
        st_local("vll_colstripe_e", invtokens(("init-" :+ sdesc)))
    } else {
        st_local("vll_rowstripe_e", invtokens("e" :+ agedesc[1] :+ "-" :+ (sdesc, "total") ) )
        st_local("vll_colstripe_e", invtokens(("init-" :+ sdesc, "weighted")))
    }
    st_local("vll_sdesc", invtokens(sdesc)) // no problem with spaces b/c labels have been converted to Stata names
}

end




program define matbr , nclass


version 10.0

syntax anything(name=matname)      ///
       [ , Format(string)           /// 
           Mata                ///
           norestore        ///
           noSHow ]         /// 

assert `: word count `matname''==1
if `"`format'"'!="" confirm numeric format `format'

tempname mname

if "`mata'"!="" {
    tempname matamat
    capture mata: st_matrix("`matamat'",`matname')  // distinguish b/w matamat and matname: I don't want to overwrite existing Stata matrices
    if _rc {
        disp as error `"could not retrieve matrix `matname' from Mata."'
        exit 111
    }
    matrix `mname' = `matamat'  // make statements below safe in case we have a e() or r() matrix
}
else {
    confirm matrix `matname'
    matrix `mname' = `matname'
}


if "`restore'"!="norestore" preserve
clear

tempname myr
_return hold `myr'

capture svmat double `mname' , names(eqcol)
* restore , not
* exit 999
if _rc {
    local cfnames : colfullnames `mname'
    tokenstats `cfnames'
    local numcols `r(numtokens)'
    if `r(lenlong)'<32 {
        mata : st_local("cfnames_abr", invtokens(strtoname(tokens("`cfnames'"))))
        matrix colnames `mname' = `cfnames_abr'
        svmat double `mname' , names(col)
    }
    else {
        local cnames  : colnames `mname'  // abbreviate eqs and coefnames to 15 chars each, sep by "__" ; TODO: make the truncation rule a little more elaborate
        mata : st_local("cnames_" , invtokens(strtoname(tokens("`cnames'"))))
        local eqnames : coleq  `mname'
        mata : st_local("eqnames_" , invtokens(strtoname(tokens("`eqnames'"))))
        foreach curcname of local cnames_ {
            local cnames_abr `cnames_abr' `=substr("`curcname'", 1, 14)'
        }
        foreach cureqname of local eqnames_ {
            local eqnames_abr `eqnames_abr' `=substr("`cureqname'", 1, 14)'
        }
        forvalues i=1/`numcols' {
            local cfnames_abr `cfnames_abr' `: word `i' of `eqnames_abr''__`: word `i' of `cnames_abr'' 
        }
        local dups : list dups cfnames_abr
        if "`dups'"=="" {
            matrix colnames `mname' = `cfnames_abr'
            svmat double `mname' , names(eqcol)
        }
        else {
            forvalues i=1/`numcols' {
                local cnames `cnames' c`i'
            }
            disp as text `"Cannot convert matrix column names to variable names"'
            qui svmat double `mname' , names(c)
        }
    }
    
}
if "`format'"!="" format _all `format'

// generate variable that holds matrix rownames

capture confirm new variable rownames
if _rc {
    disp as error `"matrix must not have a column called 'rownames'"'
    _return restore `myr'
    exit 198
}

local rnames : rowfullnames `mname' , quoted
    // 04dec2017: -quoted- option important as rownames can contain blanks
tokenstats `rnames'
local lenlong   `r(lenlong)'
local numtokens `r(numtokens)'
qui gen str`lenlong' rownames = ""

forvalues i=1/`numtokens' {
    qui replace rownames = `"`: word `i' of `rnames''"' in `i'
}

order rownames

_return restore `myr'

if "`show'"!="noshow" browse

if "`restore'"!="norestore" {
    disp _n "hit enter to continue..." _r(jnk)
    restore
}

end




program define tokenstats, rclass

    version 10

    syntax anything(name=tokenlist) 

    local longest  ""
    local shortest ""
    local lenlong  ""
    local lenshort ""
    foreach curtoken of local tokenlist {
        local curlen : length local curtoken
        if "`lenlong'"=="" {  // first token
            local longest  `"`curtoken'"'
            local shortest `"`curtoken'"'
            local lenlong  `curlen'
            local lenshort `curlen'
        }
        else {
            if `curlen'>`lenlong' {
                local longest  `"`curtoken'"'
                local lenlong `curlen'
            }
            if `curlen'<`lenshort' {
                local shortest  `"`curtoken'"'
                local lenshort  `curlen'
            }
        }
    }

    // RETURN RESULTS TO R()
    if `"`tokenlist'"'!="" {
        local numtokens : word count `tokenlist'

        return scalar lenshort = `lenshort'
        return scalar lenlong  = `lenlong'
        return scalar numtokens = `numtokens'

        return local shortest `"`shortest'"'
        return local longest  `"`longest'"'
    }

end



mata:
mata set matastrict on

matrix ds_twocomb(matrix v1, matrix v2) {
// forms all permutations of rows of v1 and rows of v2
// with the row index of v1 being slower than the one of v2
// e.g. v1 = (1 2  v2 = (2
//            3 5        3)
//            2 0)
// will return
//      (1 2 2
//       1 2 3
//       3 5 2
//       3 5 3
//       2 0 2
//       2 0 3)
//
// note: if you pass the vectors as row vectors, the result will probably not be
//       what you expected, e.g. passing (1 2) and (3 4) will return (1 2 3 4)
// note: inputs may also be string matrices

    if (eltype(v1)!=eltype(v2)) {
        exit(_error(3250,"ds_twocomb.mata: Input args must be of the same element type."))
    }
    if ( !any(eltype(v1):==("real","string")) ) {
        exit(_error(3250,"ds_twocomb.mata: Args must be either real or string."))
    }

    real scalar r1, r2, c1
    
    r1 = rows(v1)
    r2 = rows(v2)
    c1 = cols(v1)

    return( (colshape(J(1, r2, v1), c1) , J(r1, 1, v2) ) )

}

end



version 10

mata:
mata set matastrict on

real matrix ds_gdiag(real vector vecin, real scalar pos) {
// 26nov2015
// creates a square matrix with the elems of vecin on subdiagonal pos and 
//   zeroes elsewhere;
// negative (positive) values of pos refer to subdiagonals below (above)
//   the main diagonal

    real scalar n
    
    n = length(vecin)
    
    if (pos==0) {
        return(diag(vecin))
    } else if (pos<0) {
        return(J(-pos, n-pos, 0) \ diag(vecin) , J(n , -pos, 0))
    } else if (pos>0) {
        return( J(n+pos , pos, 0) , (diag(vecin) \ J(pos , n, 0) ) )
    }
}
end


