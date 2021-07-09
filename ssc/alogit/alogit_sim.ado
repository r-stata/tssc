*! version 1.0.0 03May2017 Mauricio Caceres Bravo, caceres@nber.org
*! Simple wrapper to simulate data for alogit (inc DSC)

capture program drop alogit_sim
program alogit_sim, rclass
    syntax,              ///
        b0(numlist)      ///
    [                    ///
        N(int 200)       ///
        j(numlist)       ///
        g0(numlist)      ///
        d0(numlist)      ///
        xs(real 1)       ///
        zs(real 1)       ///
        xmu(real 0)      ///
        zmu(real 0)      ///
        CONStant(real 0) ///
        debug            ///
        dsc              ///
        normal           ///
        uniform          ///
        consider         ///
    ]

    if (("`dsc'" != "") & ("`consider'" != "")) {
        di as err "Default-specific consideration models, -dsc-, must use a default good."
        exit 198
    }

    if ("`normal'" == "") & ("`uniform'" == "") local normal normal
    if ("`normal'" != "") & ("`uniform'" != "") {
        di as err "Please specify only one of -normal- or -uniform-"
        exit 198
    }
    if (("`g0'" == "") & ("`d0'" == "")) {
        di as err "Please specify some attention goods via -g0()- or -d0()-"
        exit 198
    }

    * Number of variables
    local kx = `:list sizeof b0'
    local kg = `:list sizeof g0'
    local kz = `:list sizeof d0'

    * Clear data; simulate number of groups, random number of goods
    di "Simulating data:"
    di "    N = `:di trim("`:di %21.0gc `n''")'"

    clear
    qui set obs `n'
    gen ind = _n
    if ("`j'" == "") local j 4 8
    if (`:list sizeof j' == 1) {
        expand `j'
        di "    j = `:di trim("`:di %21.0gc `j''")'"
    }
    else {
        tempvar nj
        gettoken jl jh: j
        qui gen `nj' = floor(`jl') + floor((`jh' - `jl' + 1) * runiform())
        qui expand `nj'
        drop `nj'
        di "    j = `:di trim("`:di %21.0gc `jl''")' to `:di trim("`:di %21.0gc `jh''")'"
    }
    bys ind: gen prod = _n

    if ("`dsc'" == "") {
        di "    method = alogit"
    }
    else {
        di "    method = dsc"
    }
    if ((`kx' > 0) | (`kg' > 0) | (`kz' > 0)) di "Generating variables:"

    * Simulate variables for xb
    local notex ""
    forvalues k = 1 / `kx' {
        gen x`k' = r`normal'`uniform'() * `xs' + `xmu'
        local xb `xb' x`k' * `:word `k' of `b0'' +
        if (`kg' == `kx') {
            tempvar xg`k'
            gen `xg`k'' = x`k'
        }
        local notex `notex' x`k'
    }
    if (`kx' > 0) {
        if ("`normal'`uniform'" == "normal") local add N(`xmu', `:di trim("`:di %9.4g `xs'^2'")')
        else if ("`normal'`uniform'" == "uniform") local add U(`xmu', `:di trim("`:di %9.4g `xmu' + `xs''")')
        di "    utility variables = `notex' ~ `add'"
    }

    * Simulate variables for xg
    if (`kg' != `kx') {
        local noteg ""
        forvalues k = 1 / `kg' {
            local xg`k' xg`k'
            gen `xg`k'' = r`normal'`uniform'() * `xs' + `xmu'
            local noteg `noteg' `xg`k''
        }
        if (`kg' > 0) {
            if ("`normal'`uniform'" == "normal") local add N(`xmu', `:di trim("`:di %9.4g `xs'^2'")')
            else if ("`normal'`uniform'" == "uniform") local add U(`xmu', `:di trim("`:di %9.4g `xmu' + `xs''")')
            di "    attention variables = `noteg' ~ `add'"
        }
    }
    else {
        di "    (using utility variables in attention probability)"
        local noteg `notex'
    }
    forvalues k = 1 / `kg' {
        local xg `xg' `xg`k'' * `:word `k' of `g0'' +
    }

    * Simulate variables for xd
    local notez ""
    forvalues k = 1 / `kz' {
        gen z`k' = r`normal'`uniform'() * `zs' + `zmu'
        local zd `zd' z`k' * `:word `k' of `d0'' +
        local notez `notez' z`k'
    }
    if (`kz' > 0) {
        if ("`normal'`uniform'" == "normal") local add N(`zmu', `:di trim("`:di %9.4g `zs'^2'")')
        else if ("`normal'`uniform'" == "uniform") local add U(`zmu', `:di trim("`:di %9.4g `zmu' + `zs''")')
        di "    extra attention variables = `notez' ~ `add'"
    }

    * Simulate the actual data
    tempvar A IA u maxu
    gen `A'  = `constant' + `xg' `zd' logit(runiform())
    gen `u'  = `xb' -log(-log(runiform()))
    if ("`dsc'" == "") {
        gen byte `IA' = `A' > 0
    }
    else {
        bys ind: gen byte `IA' = `A'[1] > 0
    }
    if ("`consider'" == "") {
        bys ind: gen byte defgood = (_n == 1)
        qui egen `maxu' = max(`u') if `IA', by(ind)
        qui gen byte y  = (`u' == `maxu') & `IA'

        * If no good is paid attention to, `u' == `maxu' is true for all
        * observations (since both are missing) `IA' is false for all
        * observations (no good is being paid attention to). Hence y will
        * be 0 and we force the individual to choose the default good. This
        * works for both the alogit and DSC cases.
        qui bys ind (y defgood): replace y = 1 if (_n == _N)
        di "    default = defgood"
        di "    outcome = y"
    }
    else {
        * For each individual to consider at least some goods
        bys ind: gen byte consider = (_n == 1)
        qui egen `maxu' = max(`u') if (`IA' | consider), by(ind)
        qui gen byte y  = (`u' == `maxu') & (`IA' | consider)
        di "    consider = consider"
        di "    outcome  = y"
    }

    * Return the things
    if ("`b0'" == "") local b0 .
    if ("`g0'" == "") local g0 .
    if ("`d0'" == "") local d0 .
    if ("`debug'" != "") {
        sum `IA'
        gen A = `A'
        gen u = `u'
        di "    utility = u"
        di "    P(attention) = A"
        gen maxu = `maxu'
        di `:di subinstr("`b0'", " ", ", ", .)', ///
           `:di subinstr("`g0'", " ", ", ", .)', ///
           `:di subinstr("`d0'", " ", ", ", .)'
    }
    matrix orig =                             ///
        `:di subinstr("`b0'", " ", ", ", .)', ///
        `:di subinstr("`g0'", " ", ", ", .)', ///
        `:di subinstr("`d0'", " ", ", ", .)'
    return matrix orig = orig
end
