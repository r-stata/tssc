*! version 2.0.1 21feb2021 daniel klein
program rioc , rclass byable(recall)
    version 11.2
    
    syntax varlist(numeric min=2 max=2) ///
    [ if ] [ in ] [ fweight ]           ///
    [ ,                                 ///
        Tab                             ///
        Detail                          ///
        STATs(passthru)                 ///
        CII(name)                       /// not documented        
        KAPPA                           ///
        SMALLsample                     ///
        SEZERO                          ///
        ASR /*synonym*/ CHi2  /// retained; not documented        
        Level(cilevel)                  ///
        CFORMAT(passthru)               ///
        PFORMAT(passthru)               ///
        SFORMAT(passthru)               ///
        PERCENT                         /// not documented
        MATCELL(name)                   /// not documented        
    ]
    
    marksample touse
    
    /*
        the notation below follows Copas and Loeber (1990)
        
        we create 0/1 indicator variables from caller's varlist
        note: we flip the coding so that zero indicates 'true'
              and nonzero and nonmissing indicates 'false' to
              create the same table as Copas and Loeber (1990) 
    */
    
    if ("`tab'" == "tab") tempname plbl olbl
    else               local quietly quietly
    
    tempvar prediction outcome
    mk_binary `prediction' `outcome' `touse' `varlist' `plbl' `olbl' , `tab'    
    
    
    tempname F
    `quietly' tabulate `prediction' `outcome' [`weight' `exp'] , matcell(`F')
    
    if ( (r(r)!=2) | (r(c)!=2) ) {
        display as err "table not 2 by 2"
        exit 459
    }
    
        /*
            Copas and Loeber (1990:303) present all formulas assuming 
            that e >= f; "if not, rows and columns are interchanged"
        */
    local a = `F'[1, 1]
    local b = max(`F'[1, 2], `F'[2, 1])
    local c = min(`F'[2, 1], `F'[1, 2])
    local d = `F'[2, 2]
    
    local e = `a' + `b'
    local f = `a' + `c'
    local n = `a' + `b' + `c' + `d'
    
    
    tempname rioc crit sr ll ul z p
    
        // Copas and Loeber (1990) (4)
    scalar `rioc' = (`n'*`a' - `e'*`f') / ( `f'*(`n'-`e') )
    
    scalar `crit' = -invnormal((1-`level'/100)/2)
    
    if ( mi("`smallsample'") ) {
            // Copas and Loeber (1990) (11)
        scalar `sr' = sqrt( `n'*`c'*( `n'*`f'*(`n'-`e')            ///
                    + `c'*(`n'*`e' + `e'*`f' -  2*`n'*`f' - `n'^2) ///
                    + 2*`n'*`c'^2 ) / ( (`n'-`e')^3*`f'^3 ) )
        scalar `z' = `rioc'/`sr'
        scalar `p' = 2*normal(-abs(`z'))
        scalar `ll' = `rioc' - `crit'*`sr'
        scalar `ul' = `rioc' + `crit'*`sr'
    }    
    else {
        tempname alpha beta delta
        
        scalar `alpha' = `e'/`n'
        scalar `beta'  = `f'/`n'
        
            // Copas and Loeber (1990) (20) 
        scalar `delta'  =  ln( ((`a'+.5)*(`d'+.5)) / ((`b'+.5)*(`c'+.5)) )
        
            // Copas and Loeber (1990) (21)
        scalar `sr' = sqrt( ((`e'+1)*(`e'+2)) / (`e'*(`a'+1)*(`b'+1)) ///
                    + ((`n'+1-`e')*(`n'+2-`e')) / ((`n'-`e')*(`c'+1)*(`d'+1)) )
        
        scalar `ll' = exp(`delta' - `crit'*`sr')
        scalar `ul' = exp(`delta' + `crit'*`sr')
        
            // Copas and Loeber (1990= (23)
        foreach phi in ll ul {
            scalar ``phi'' = ( 1+(``phi''-1)*(`alpha'+`beta'-2*`alpha'*`beta') ///
                           - sqrt( (1+(`alpha'+`beta')*(``phi''-1))^2          ///
                                  - 4*`alpha'*`beta'*``phi''*(``phi''-1) ) )   ///
                           / ( 2*(``phi''-1)*`beta'*(1-`alpha') )
        }
        scalar `sr' = .z
        scalar `z'  = .z
        scalar `p'  = .z
    }
    
    if ( ("`sezero'"=="sezero") | ("`asr'"=="asr") | ("`chi2'"=="chi2") ) {
            // Copas and Loeber (1990) (13)
        scalar `sr' = sqrt( (`e'*(`n'-`f')) / (`n'*`f'*(`n'-`e')) )
        scalar `z'  = `rioc'/`sr'
        scalar `p'  = 2*normal(-abs(`z'))
    }
    
    tempname table
    matrix `table' = `rioc'\ `sr'\ `z'\ `p'\ `ll'\ `ul'\ `crit'\ .\ 0
    matrix rownames `table' = b se z pvalue ll ul crit df eform
    matrix colnames `table' = RIOC // Copas and Loeber (1990) call it R
    
    
    if ( ("`detail'"=="detail") | (`"`stats'"'!="") ) {
        Detail `table' `F' `a' `b' `c' `d' `e' `f' `n' , level(`level') ///
            `smallsample' `sezero' `asr' `chi2' `detail' `stats' cii(`cii')
    }
    
    if ("`kappa'" == "kappa") {
        Kappa `table' `F' `e' `f' `n' , level(`level') ///
            `smallsample' `sezero' `asr' `chi2'
    }
    
    if ( c(noisily) ) Display `table' , nobs(`n') level(`level') ///
        `kappa' `sezero' `asr' `chi2' `cformat' `pformat' `sformat' `percent'
    
    
    if ("`matcell'" != "") matrix `matcell' = `F'
    
    return scalar rioc  =  `rioc'
    return scalar level = `level'
    return scalar N     =     `n'
    
    return local cmd      "rioc"
    
    return matrix table = `table'
end

program mk_binary
    syntax namelist(min=5 max=7) [ , TAB ]
    
    gettoken prediction namelist : namelist
    gettoken outcome    namelist : namelist
    gettoken touse      namelist : namelist
    
    foreach varname in `prediction' `outcome' {
        gettoken `varname' namelist : namelist
        quietly generate byte `varname' = (``varname'' == 0) if `touse'
        if ( mi("`tab'") ) continue
        local varlabel : variable label ``varname''
        if ( mi(`"`varlabel'"') ) local varlabel ``varname''
        label variable `varname' `"`varlabel'"'
    }
    
    if ( mi("`tab'") ) exit
    
    gettoken plbl olbl : namelist
    label define `plbl' 0 "True (+)" 1 "False (-)"
    label define `olbl' 0 "True"     1 "False"
    label values `prediction' `plbl'
    label values `outcome'    `olbl'
end

program Detail
    syntax anything , LEVEL(cilevel) ///
    [ SMALLSAMPLE SEZERO ASR CHI2 DETAIL STATS(passthru) CII(name) ]
    
    tokenize `anything'
    args table F a b c d e f n
    
    if ("`detail'" == "detail") {
            // Farrington and Loeber 1989 (2) (4) (5)
        local Total   `n' (`= `a' + `d'')
        local Chance  (`= `n'^2') (`= (2*`e'*`f'+`n'^2-`e'*`n'-`f'*`n')')
        local Maximum `n' (`= `f'+`n'-`e'')
        
        local dstats Correct:Total Correct:Chance Correct:Maximum
        local cnames `dstats'
    }
    
    if (`"`stats'"' != "") {
        // original table cells; orientation matters
        local b = `F'[1, 2]
        local c = `F'[2, 1]
        local e = `a' + `b'
        local f = `a' + `c'
        get_stats `a' `b' `c' `d' `e' `f' `n' , `stats' `detail'
        local i 0
        foreach sname of local snames {
            local dstats `dstats'  STAT`++i'
            local cnames `cnames' `sname'
        }
    }
    
    local colname : colnames `table'
    
    local ciicol (r(mean)\ r(se)\ .z\ .z\ r(lb)\ r(ub)\ .z\ .\ 0)
    if ( ("`sezero'"=="sezero") | ("`asr'"=="asr") | ("`chi2'"=="chi2") ) ///
        local  ciicol (r(mean)\ .z\ .z\ .z\ r(lb)\ r(ub)\ .z\ .\ 0)
    if ("`smallsample'" == "smallsample")   ///
        local  ciicol (r(mean)\ .z\ .z\ .z\  .z\ .z\ .z\ .\ 0)
    
    foreach s of local dstats {
        local s = substr("`s'", strpos("`s'", ":")+1, .)
        quietly cii ``s'' , level(`level') `cii'
        matrix `table' = `table', `ciicol'
    }
    
    matrix colnames `table' = `colname' `cnames'
end

program get_stats
    syntax anything , STATS(string asis) [ DETAIL ]
    
    tokenize `anything'
    args a  b  c  d  e  f  n
    args A  B  C  D  E  F  N
    args TP FP FN TN R1 C1
    args tp fp fn tn r1 c1
    
    local TPR a / f
    local TNR d / (n-f)
    local PPV a / e
    local NPV d / (n-e)
    local FPR b / (n-f) // not documented
    local FNR c / f     // not documented
    local ALL TPR TNR PPV NPV  // FPR FNR
    
    local shortcuts `ALL' FPR FNR
    
    local i 0
    while (`"`stats'"' != "") {
        gettoken sname stats : stats , parse(" :=")
        gettoken colon stats : stats , parse(" :=")
        if ( !inlist("`colon'", ":", "=") ) {
            local Usname = strupper("`sname'")
            local stats ``Usname'' `colon' `stats'
            if (`"`sname'"' == "all") continue
            if ( !`: list Usname in shortcuts' ) {
                display as err `"`sname' invalid"'
                error_stats
            }
            local sname `Usname'
        }
        gettoken nomin stats : stats , parse(" /") match(junk)
        gettoken slash stats : stats , parse(" /")
        gettoken denom stats : stats , parse(" ;") match(junk)
        
        capture noisily confirm name `sname'        
        if ( _rc ) error_stats
        if ("`slash'" != "/") {
            display as err `"'`slash'' found where / expected"'
            error_stats
        }
        
        foreach nd in nomin denom {
            // note: must substitute the two-letter macros first
            foreach x in tp fp fn tn r1 c1 a b c d e f n {
                local `nd' : subinstr local `nd '"`x'" "``x''" , all
                local x = strupper(`"`x'"')
                local `nd' : subinstr local `nd' "`x'" "``x''" , all
            }
            capture noisily local `nd' = ``nd''
            if ( _rc ) error_stats
            capture noisily numlist "``nd''" , integer range(>0)
            if ( _rc ) error_stats
        }
        
        gettoken semi stats : stats , parse(";")
        if (`"`semi'"'!=";") local stats `semi' `stats'
        
        c_local STAT`++i' `denom' `nomin'
          local snames `snames' `sname'
    }
    
    c_local snames : copy local snames
end

program error_stats
    display as err "above applies to option stats()"
    exit 198
end

program Kappa
    syntax anything [ , LEVEL(cilevel) SMALLSAMPLE SEZERO ASR CHI2 ]
    
    tokenize `anything'
    args table F e f n
        
    tempname po pe kappa
    scalar `po'    = (`F'[1, 1]+`F'[2, 2])/`n'
    scalar `pe'    = (2*`e'*`f'+`n'^2-`e'*`n'-`f'*`n')/`n'^2
    scalar `kappa' = (`po'-`pe') / (1-`pe')
    
    
    // below, we follow Fleiss et al. 1969
    tempname P p1_ p2_ p_1 p_2 tc
    matrix `P'   = `F'/`n'
    scalar `p1_' = `e'/`n'
    scalar `p2_' = (`n'-`e')/`n'
    scalar `p_1' = `f'/`n'
    scalar `p_2' = (`n'-`f')/`n'
    // note that wi_ = (w1_=p_1\ w2_=p_2); w_j = (w_1=p1_, w_2=p2_)
    
    tempname s z p crit ll ul
    
    if ( mi("`smallsample'") ) {
            // Fleiss et al. 1969 [8]
        scalar `s' = sqrt( (                                         ///
                     (`P'[1, 1]*((1-`pe')-(`p_1'+`p1_')*(1-`po'))^2  ///
                   +  `P'[1, 2]*((`p_1'+`p2_')*(1-`po'))^2           ///
                   +  `P'[2, 1]*((`p_2'+`p1_')*(1-`po'))^2           ///
                   +  `P'[2, 2]*((1-`pe')-(`p_2'+`p2_')*(1-`po'))^2) ///
                   - (`po'*`pe' - 2*`pe' + `po')^2  ) / (`n'*(1-`pe')^4) )
        scalar `z'    = `kappa'/`s'
        scalar `p'    = 2*normal(-abs(`z'))
        scalar `crit' = -invnormal((1-`level'/100)/2)
        scalar `ll'   = `kappa'-`crit'*`s'
        scalar `ul'   = `kappa'+`crit'*`s'
        if ( ("`asr'"=="asr") | ("`chi2'"=="chi2") ) ///
                matrix `tc' = (`kappa'\ .z\ .z\ .z\ `ll'\ `ul'\ `crit'\ .\ 0)
        else matrix `tc' = (`kappa'\ `s'\ `z'\ `p'\ `ll'\ `ul'\ `crit'\ .\ 0)
    }
    else matrix `tc' = (`kappa'\ .z\ .z\ .z\ .z\ .z\ .z\ .\ 0)
    
    if ("`sezero'" == "sezero") {
            // Fleiss et al. 1969 [9]
        scalar `s' = sqrt( ///
                     (`p1_'*`p_1'*(1-(`p_1'+`p1_'))^2  ///
                   +  `p1_'*`p_2'*(0-(`p_1'+`p2_'))^2  ///
                   +  `p2_'*`p_1'*(0-(`p_2'+`p1_'))^2  ///
                   +  `p2_'*`p_2'*(1-(`p_2'+`p2_'))^2) ///
                   -  `pe'^2) / ( (1-`pe')*sqrt(`n') )
        scalar `z' = `kappa'/`s'
        scalar `p' = 2*normal(-abs(`z'))
        matrix `tc'[2, 1] = `s'
        matrix `tc'[3, 1] = `z'
        matrix `tc'[4, 1] = `p'
    }
    
    local colnames : colnames `table'
    matrix `table' = `table', `tc'
    matrix colnames `table' = `colnames' Kappa
end

program Display
    syntax name(name=table) , nobs(integer) LEVEL(cilevel) ///
    [ KAPPA SEZERO ASR CHI2 CFORMAT(string) PFORMAT(string) SFORMAT(string) PERCENT ]
    
    tempname rtable
    matrix `rtable' = (`table')'
    local nrows = rowsof(`rtable')
    
    if ("`percent'" == "percent") {
        local cfd %6.2f
        matrix `rtable' = ///
            `rtable'[1..., 1]*100, J(`nrows', 3, .z), ///
            `rtable'[1..., 5..6]*100, `rtable'[1..., 7..9]   
    }
    else local cfd %9.0g
    
    set_fmt cf `cfd' `cformat'
    set_fmt pf %5.3f `pformat'
    set_fmt sf %8.2f `sformat'
    
    if      ( !`--nrows' ) local rspec &-
    else if ( !`--nrows' ) local rspec &--
    else {
        local and : display _dup(`--nrows') "&"
        local sep = cond("`kappa'"=="kappa", "-", "&")
        local rspec &-`and'`sep'-
    }
    
    local cspec & %12s | ///
        w10 `cf' & w9 `cf' o0& w8 `sf' & w6 `pf' & w11 `cf' & w10 `cf' &
    
    display as txt _newline "Relative improvement over chance" ///
                   _col(52) "Number of obs" _col(68) "= " as res %9.0g `nobs'
    
    display as txt "{hline 13}{c TT}{hline 64}"
    if ( (("`asr'"=="asr")|("`chi2'"=="chi2")) & mi("`sezero'") ) ///
    display as txt _col(14) "{c |}" _col(32) "ASR"
    display as txt _col(14) "{c |}"     ///
                   _col(21) "Coef."     ///
                   _col(29) "Std. Err." ///
                   _col(44) "z"         ///
                   _col(49) "P>|z|"     ///
                   _col(`= 61-strlen("`level'")') "[`level'% Conf. Interval]"
    display as txt "{hline 13}{c +}{hline 64}" _continue
    matlist `rtable'[., 1..6] , rspec(`rspec') cspec(`cspec') ///
        names(row) nodotz underscore
end

program set_fmt
    args f w ww
    c_local `f' `w'
    if ( mi("`ww'") ) exit
    if (fmtwidth(`"`ww'"') <= fmtwidth("`w'")) c_local `f' `ww'
    else display as txt "note: invalid `f'ormat(), using default"
end
exit

/* --------------------------------------
2.0.1 21feb2021 make binary indicators byte
                typo in a comment
2.0.0 02feb2021 changed default standard error for kappa
                confindence intervals for kappa
                new option -sezero-
                set se, z, and p to .z for -smallsample-
                -quietly- skips Display routine
                options -asr- and -chi2- no longer documented
                revised help file
1.1.0 29jan2021 support -by- (recall)
                new option -kappa-
                new option -matcell()-; not documented
                add FPR and FNR to stats(); not documented
                modified table header
                revised help file
1.0.0 26jan2021 new options -detail-, -stats()-, -{c s p}format()-
                new option -cii()-; not documented
                new option -percent-; not documented
                additional r(N), r(level), r(cmd)
                split main code into subroutines
                use locals to hold integers
                new immediate command -rioci-
                new help files
0.0.9 23jan2021 posted on Statalist
