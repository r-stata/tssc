*! version 2.0.2  04aug2007  Ben Jann
*  based on official kdensity.ado, version 2.6.2  02mar2005
program define kdens , rclass
    version 9.2

    syntax varname(numeric) [if] [in] [fw aw pw] [,     ///
     Generate(namelist max=2)       /// _kdens opts
     Replace                        ///
     N(passthru)                    ///
     N2(passthru)                   ///
     AT(varname numeric)            ///
     RAnge(passthru)                ///
     Kernel(passthru)               ///
     exact                          ///
     CI CI2(namelist max=2)         ///
     vce(passthru)                  ///
     VARiance(passthru)             ///
     USmooth USmooth2(passthru)     ///
     Level(cilevel)                 ///
     bw(passthru)                   ///
     ADJust(passthru)               ///
     Adaptive Adaptive2(passthru)   ///
     LL(passthru)                   ///
     UL(passthru)                   ///
     REFLection                     ///
     lc                             ///
     noFIXED                        /// undocumented: see _kdens.ado
     NORmal                         /// graph opts
     STUdent(int 0)                 ///
     HISTogram HISTogram2(int 0)    ///
     noGRaph                        ///
     * ///
     ]

    _get_gropts , graphopts(`options') ///
     getallowed(CIOPts STOPts NORMOPts HISTOPts plot addplot)
    local options `"`s(graphopts)'"'
    local histopts `"`s(histopts)'"'
    local normopts `"`s(normopts)'"'
    local stopts `"`s(stopts)'"'
    local ciopts `"`s(ciopts)'"'
    _check4gropts histopts, opt(`histopts')
    _check4gropts normopts, opt(`normopts')
    _check4gropts stopts, opt(`stopts')
    _check4gropts ciopts, opt(`ciopts')
    if `"`histopts'"' != "" | `histogram2'>0 {
        local histogram histogram
    }
    if `"`normopts'"' != "" {
        local normal normal
    }
    if `"`stopts'"' != "" & `student' < 1 {
        di as err "option student() is required by stopts() option"
        exit 198
    }
    if `"`ciopts'"' != "" {
        local ci ci
    }
    local plot `"`s(plot)'"'
    local addplot `"`s(addplot)'"'


    local ix `"`varlist'"'
    local xttl: variable label `ix'
    if `"`xttl'"'=="" {
        local xttl "`ix'"
    }

    marksample use
    qui count if `use'
    if r(N)==0 {
        error 2000
    }

    if `"`at'"'!="" {
        local m `"`at'"'
        local at `"at(`at')"'
        gettoken d: generate
    }
    else {
        gettoken d m: generate
    }
    if `"`m'"'=="" {
        tempvar m
    }
    if `"`d'"'=="" {
        tempvar d
    }
    if `"`ci2'"'!="" {
        if `:word count `ci2''==1 {
            local ci_lo `"`ci2'_lo"'
            local ci_up `"`ci2'_up"'
        }
        else gettoken ci_lo ci_up: ci2
    }
    else if "`ci'"!="" {
        if `"`generate'"'!="" {
            local ci_lo `"`d'_lo"'
            local ci_up `"`d'_up"'
        }
        else {
            tempvar ci_lo ci_up
        }
        local ci2 `"`ci_lo' `ci_up'"'
    }
    if `"`ci2'"'!="" {
        local ci2 `"ci2(`ci2')"'
    }
    if `"`at'"'!="" {
        local generate `"generate(`d')"'
    }
    else {
        local generate `"generate(`d' `m')"'
    }

    if `"`normal'"' != "" | `student' > 0 {
        local wgt `weight'
        local wgt: subinstr local wgt "pw" "aw"
        quietly summ `ix' [`wgt'`exp'] if `use'
        local ixmean = r(mean)
        local ixsd   = r(sd)
    }

    return clear
    _kdens `ix' if `use' [`weight'`exp'], `generate'                    ///
     `replace' `n' `n2' `at' `range' `kernel' `exact' `ci2' `vce'       ///
     `variance' `usmooth' `usmooth2' level(`level') `bw' `adjust'       ///
     `adaptive' `adaptive2' `ll' `ul' `reflection' `lc' `fixed'
    return add

    if `"`at'"'=="" {
        label var `m' `"`xttl'"'
    }
    label var `d' `"Kernel estimate"'

    if `"`graph'"'==`""' {
        local i 1
        if "`histogram'"!="" {
            if `histogram2'>0 local HISTbin "bin(`histogram2')"
            local HISTgraph                                 ///
                (histogram `ix' if `use' [`weight'`exp'],   ///
                legend(label(`i++' "Histogram"))            ///
                `HISTbin' `histopts'                        ///
            )
        }
        if `"`ci2'"'!="" {
            local CI2graph                                  ///
                (rarea `ci_lo' `ci_up' `m',                 ///
                psty(ci) legend(label(`i++' "`level'% CI")) ///
                sort `ciopts'                               ///
            )
        }
        if `"`normal'"' != "" | `student' > 0 {
            sum `m', mean
            if `"`normal'"' != `""' {
                local Ngraph                            ///
                (function normden(x,`ixmean',`ixsd'),   ///
                    range(`r(min)' `r(max)')            ///
                    yvarlabel("Normal density")         ///
                    `normopts'                          ///
                )
            }
            if `student' > 0 {
                local Tgraph                    ///
                (function                       ///
                    tden =                      ///
                    tden(`student',             ///
                        (x-`ixmean')/`ixsd'     ///
                    )/`ixsd'                    ///
                ,                               ///
                    range(`r(min)' `r(max)')    ///
                    yvarlabel(                  ///
                `"t density, df = `student'"'   ///
                    )                           ///
                    `stopts'                    ///
                )
            }
        }
        graph twoway                    ///
        `HISTgraph'                     ///
        `CI2graph'                      ///
        (line `d' `m',                  ///
            ytitle(`"Density"')         ///
            xtitle(`"`xttl'"')          ///
            sort `options'              ///
        )                               ///
        `Ngraph'                        ///
        `Tgraph'                        ///
        || `plot' || `addplot'          ///
        // blank
    }

    label var `d' `"density: `xttl'"'
    if `"`ci2'"'!="" {
        label var `ci_lo' `"density: `xttl' (lower bound)"'
        label var `ci_up' `"density: `xttl' (upper bound)"'
    }
end
