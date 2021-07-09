*! version 1.0.3  17may2019  Ben Jann

program robbox, eclass
    version 11
    if replay() {
        if `"`e(cmd)'"'!="robbox" {
            di as err "last robbox results not found"
            exit 301
        }
        Replay `0'
        exit
    }
    Estimate `0'
    ereturn local cmdline `"robbox `0'"'
    Replay, `table' `graph' `label' `postoutsides' `flag' `generate' `replace' `gropts'
end

program Replay
    syntax [, TABle NOGRaph GRaph noLABel POSTOUTsides flag FLAG2(passthru) ///
        GENerate GENerate2(passthru) replace * ]
    if "`table'"!="" {
        Display
        local nograph nograph
    }
    if "`postoutsides'"!="" {
        Postoutsides
        local nograph nograph
    }
    if `"`flag'`flag2'"'!="" {
        Flag, vlist(`e(depvar)') `flag2' `replace'
        local nograph nograph
    }
    if `"`generate'`generate2'"'!="" {
        Generate, `generate2' `replace' `label'
        local nograph nograph
    }
    if "`graph'"!="" | "`nograph'"=="" {
        Graph, `options' `label'
    }
end

program Display
    // header
    di as txt _n "`e(title)'" _c
    di as txt _col(46) "Number of obs  = " as res %10.0g e(N)
    if `"`e(alpha)'"'!="" {
        di as txt _col(46) "Alpha          = " as res %10.0g e(alpha)
    }
    if `"`e(bp)'"'!="" {
        di as txt _col(46) "Breakdown      = " as res %10.0g e(bp)
    }
    if `"`e(delta)'"'!="" {
        di as txt _col(46) "Delta          = " as res %10.0g e(delta)
    }
    // over() legend
    if `"`e(over)'"'!="" {
        _svy_summarize_legend
        if e(N_vars)==1 {
            local rowti rowtitle(`e(depvar)')
        }
    }
    else di ""
    // table
    tempname tmp tmp1 
    matrix `tmp' = e(b)'
    mat coln `tmp' = "_:median"
    mat `tmp1' = e(box)'
    mat coln `tmp1' = "lower:hinge" "upper:hinge"
    matrix `tmp' = `tmp', `tmp1'
    mat `tmp1' = e(whiskers)'
    mat coln `tmp1' = "lower:whisker" "upper:whisker"
    matrix `tmp' = `tmp', `tmp1'
    mat `tmp1' = e(N_out)'
    mat coleq `tmp1' = "number of outside values"
    matrix `tmp' = `tmp', `tmp1'
    mat `tmp1' = e(_N)'
    mat coln `tmp1' = "mumber:of_obs"
    matrix `tmp' = `tmp', `tmp1'
    matlist `tmp', twidth(16) lines(oneline) border(rows) keepcoleq nohalf ///
        underscore showcoleq(rcombined) noblank  `rowti'
end

program Graph
    // syntax
    syntax [, noOUTsides VERTical HORizontal ///
        sort SORT2(numlist max=1 int >0) DEScending ///
        BOXWidth(numlist max=1) OVERGap(numlist max=1) ///
        noLABel LABels(str asis) LLABels(str asis) MEDMarker ///
        PLOTopts(str) MEDopts(str) BOXopts(str) WHISKopts(str) OUTopts(str) ///
        PCYCle(numlist max=1 integer >0) addplot(str asis) * ]
    if "`sort2'"!=""      local sort sort
    if "`boxwidth'"=="" local boxwidth 50
    if "`overgap'"=="" local overgap 10
    if "`pcycle'"=="" local pcycle 15
    local orientation `vertical' `horizontal'
    if `:list sizeof orientation'>1 {
        di as err "only one of vertical and horizontal allowed"
    }
    if "`orientation'"=="" local orientation vertical
    // sort results
    if "`sort'"!="" {
        tempname ecurrent
        _estimates hold `ecurrent', copy restore
        Sort "`descending'" "`sort2'"
    }
    // generate boxplot variables
    local nvars = e(N_vars)
    local nover = e(N_over)
    local n = `nvars' * `nover'
    if `n'>_N {
        preserve
        set obs `n'
    }
    tempvar gid id med lbox ubox lav uav nobs
    qui Generate, `label' generate(`gid' `id' `med' `lbox' `ubox' `lav' `uav' `nobs')
    // prepare plotting positions and collect labels
    local over `e(over)'
    if "`over'"=="" | ("`over'"!="" & `nvars'==1) { // no groups
        local ng `n'
        local nj 1
        local AT `id'
        local tmp `gid'
        local gid `id'
        local id `tmp'
        local llab off
        local barwidth = 1/`nj'*(`boxwidth'/100)
        local range .5 `ng'.5
    }
    else {
        local gw = 1 - `overgap'/100
        local ng = e(k_eq)
        local nj = `n' / `ng'
        tempvar AT
        qui gen `AT' = `gid' - (.5*`gw') + ((`id'-1)*2+1) * ((1*`gw')/(2*`nj')) in 1/`n'
        local key 2
        local llab
        forv i = 1/`nj' {
            gettoken lbl llabels : llabels
            if `"`lbl'"'=="" {
                local lbl: label `id' `i'
            }
            local llab `llab' `key' `"`lbl'"'
            local key = `key' + 3
        }
        local llab order(`llab')
        local barwidth = (1*`gw')/`nj'*(`boxwidth'/100)
        local range `=1-.5*`gw'' `=`ng'+.5*`gw''
    }
    local clab
    forv i = 1/`ng' {
        gettoken lbl labels : labels
        if `"`lbl'"'=="" {
            local lbl: label `gid' `i'
        }
        local clab `clab' `i' `"`lbl'"'
    }
    // generate outlier variables
    if "`outsides'"=="" {
        local vlist "`e(depvar)'"
        local flags
        local flagats
        forv i=1/`nvars' {
            tempname flag flagat
            local flags `flags' `flag'
            local flagats `flagats' `flagat'
        }
        qui Flag, flag(`flags') vlist(`vlist')
        local i 0
        foreach flag of local flags {
            local ++i
            local flagat: word `i' of `flagats'
            if "`over'"=="" {
                qui gen byte `flagat' = `i' if `flag'==1
            }
            else {
                qui gen byte `flagat' = .
                local j 0
                foreach o in `e(over_namelist)' {
                    local ++j
                    local at `j'
                    if `nj'>1 {
                        local at = `at' - (.5*`gw') + ((`i'-1)*2+1) * ((1*`gw')/(2*`nj'))
                    }
                    qui replace `flagat' = `at' if `flag'==1 & `over'==`o'
                }
            }
        }
    }
    // compile plot command
    // - collect numbered options
    forv i = 1/`nj' {
        Collectnumopts `i', `options' // returns options, plot#opts, med#opts, etc.
    }
    // - median, box, and whiskers
    if "`medmarker'"!="" {
        if "`orientation'"=="horizontal" local medplot scatter `AT' `med'
        else                             local medplot scatter `med' `AT'
    }
    else {
        tempname AT0 AT1
        qui gen `AT0' = `AT' - `barwidth'/2
        qui gen `AT1' = `AT' + `barwidth'/2
        local medplot pcspike `med' `AT0' `med' `AT1'
        local medorient `orientation'
    }
    local barwidth barwidth(`barwidth')
    local plots
    forv i = 1/`nj' {
        local p = mod(`i'-1, `pcycle') + 1
        local plots `plots'/*
            */ (rcap `lav'  `uav'  `AT' if `id'==`i', pstyle(p`p') /*
                */ `plotopts' `plot`i'opts' `orientation' `whiskopts' `whisk`i'opts')/*
            */ (rbar `lbox'  `ubox' `AT' if `id'==`i', pstyle(p`p') fintensity(50) /*
                */ `plotopts' `plot`i'opts' `barwidth' `orientation' `boxopts' `box`i'opts') /*
            */ (`medplot' if `id'==`i' & `nobs'!=0, pstyle(p`p') /*
                */ `plotopts' `plot`i'opts' `medorient' `medopts' `med`i'opts')
    }
    // - outside values
    if "`outsides'"=="" {
        local i 0
        local j 1
        foreach flag of local flags {
            local ++i
            local flagat: word `i' of `flagats'
            local v: word `i' of `vlist'
            if "`orientation'"=="horizontal" local xy `flagat' `v'
            else                             local xy `v' `flagat'
            local p = mod(`j'-1, `pcycle') + 1
            local plots `plots' (scatter `xy' if `flag'==1, pstyle(p`p') /*
                 */ `plotopts' `plot`j'opts' `outopts' `out`j'opts')
            if `nj'>1 {
                local ++j
            }
        }
    }
    // - addpot
    if `"`addplot'"'!="" {
        local plots `plots' || `addplot' ||
    }
    // - global options
    local grid
    forv i = 1/`=`ng'-1' {
        local grid `grid' `i'.5
    }
    if "`orientation'"=="horizontal" {
        local axisopts ylabel(`clab', angle(0) nogrid) yti("") ///
            ytick(`grid', notick) yscale(range(`range') reverse)
    }
    else {
        local axisopts xlabel(`clab', nogrid) xti("") xtick(`grid', notick) ///
            xscale(range(`range'))
    }
    // draw graph
    twoway `plots', `axisopts' legend(`llab' all) `options'
end

program Sort, eclass
    args descending index
    if "`index'"=="" local index 0
    tempname B
    mata: robbox_sort("`B'", `index', "`descending'"!="")
end

program Collectnumopts
    _parse comma i 0 : 0
    syntax [, PLOT`i'opts(str) MED`i'opts(str) BOX`i'opts(str) ///
        WHISK`i'opts(str) OUT`i'opts(str) * ]
    c_local plot`i'opts `"`plot`i'opts'"'
    c_local med`i'opts `"`med`i'opts'"'
    c_local box`i'opts `"`box`i'opts'"'
    c_local whisk`i'opts `"`whisk`i'opts'"'
    c_local out`i'opts `"`out`i'opts'"'
    c_local options `options'
end

program Generate
    syntax [, noLABel checkonly GENerate2(str) replace ]
    local generate `"`generate2'"'
    // variables names
    if `"`generate'"'=="" local generate _box_*
    if `:list sizeof generate'==1 ///
        & substr(`"`generate'"',-1,1)=="*" ///
        & strlen(`"`generate'"')>1 {
        local prefix = substr(`"`generate'"', 1, strlen(`"`generate'"')-1)
        local generate
        foreach v in gid id med lbox ubox lav uav N {
            local generate `generate' `prefix'`v'
        }
    }
    else {
        if `:list sizeof generate'!=8 {
            di as err "generate() must either contain 8 names" ///
                " or a prefix specified as {it:prefix}{bf:*}"
            exit 198
        }
        local tmp: list uniq generate
        if `:list sizeof tmp'!=8 {
            di as err "generate(): variable names must be unique"
            exit 198
        }
    }
    confirm names `generate'
    // check variables
    if "`replace'"=="" {
        confirm new variable `generate'
    }
    if `"`checkonly'"'!="" exit
    if "`replace'"!="" {
        local i 0
        foreach v of local generate {
            local ++i
            capt confirm new variable `v'
            if _rc drop `v'
            if `i'>2 continue
            capt label drop `v' // gid and id only
        }
    }
    // generate variables
    gettoken gid  tmp : generate
    gettoken id   tmp : tmp
    gettoken med  tmp : tmp
    gettoken lbox tmp : tmp
    gettoken ubox tmp : tmp
    gettoken lav  tmp : tmp
    gettoken uav  tmp : tmp
    gettoken nobs     : tmp
    // - IDs
    local n   = e(N_vars) * e(N_over)
    local neq = e(k_eq)
    local nj  = `n' / `neq'
    qui gen     `gid'= ceil(_n/`nj') in 1/`n'
    qui gen     `id' = 1 in 1/`n'
    qui replace `id' = cond(`gid'==`gid'[_n-1], `id'+`id'[_n-1], `id') in 1/`n'
    // - main data
    tempname tmp
    mat `tmp' = e(b)', e(box)', e(whiskers)', e(_N)'
    mat coln `tmp' = `med' `lbox' `ubox' `lav' `uav' `nobs'
    svmat `c(type)' `tmp', names(col)
    // - compress
    qui compress `generate'
    // value labels for IDs
    if (`"`e(over)'"'!="" & e(N_vars)==1) {
        if "`label'"=="" local lbls `"`e(over_labels)'"'
        else             local lbls `"`e(over_namelist)'"'
        local i 0
        foreach lbl of local lbls {
            local ++i
            lab def `id' `i' `"`lbl'"', add
        }
        lab def `gid' 1 "_", add
    }
    else {
        local lbls `"`e(depvar)'"'
        local i 0
        foreach lbl of local lbls {
            local ++i
            if "`label'"=="" {
                local vlab: var lab `lbl'
                if `"`vlab'"'!="" {
                    local lbl `"`vlab'"'
                }
            }
            lab def `id' `i' `"`lbl'"', add
        }
        if `"`e(over)'"'!="" {
            if "`label'"=="" local lbls `"`e(over_labels)'"'
            else             local lbls `"`e(over_namelist)'"'
            local i 0
            foreach lbl of local lbls {
                local ++i
                lab def `gid' `i' `"`lbl'"', add
            }
        }
        else {
            lab def `gid' 1 "_", add
        }
    }
    lab val `gid' `gid', nofix 
    lab val `id' `id', nofix 
    // variable labels and display
    lab var `gid' "Group (equation) ID"
    lab var `id'  "Within-group (coefficient) ID"
    lab var `med' "Median"
    lab var `lbox' "Lower hinge (box)"
    lab var `ubox' "Upper hinge (box)"
    lab var `lav'  "Lower adjacent value (whisker)"
    lab var `uav'  "Upper adjacent value (whisker)"
    lab var `nobs' "Number of observations"
    display _n as txt "Generated boxplot variables:" _c
    describe `generate'
end

program Flag
    syntax [, checkonly vlist(str) FLAG2(str) replace ]
    local generate `"`flag2'"'
    local nvars: list sizeof vlist
    // variables names
    if `"`generate'"'=="" local generate _flag_*
    if `:list sizeof generate'==1 ///
        & substr(`"`generate'"',-1,1)=="*" ///
        & strlen(`"`generate'"')>1 {
        local prefix = substr(`"`generate'"', 1, strlen(`"`generate'"')-1)
        local generate
        foreach v of local vlist {
            local generate `generate' `prefix'`v'
        }
    }
    else {
        if `:list sizeof generate'!=`nvars' {
            di as err "flag() must either contain `nvars' name(s)" ///
                 " or a prefix specified as {it:prefix}{bf:*}"
            exit 198
        }
    }
    confirm names `generate'
    local tmp: list uniq generate
    if `:list sizeof tmp'!=`nvars' {
        di as err "flag(): variable names must be unique"
        exit 198
    }
    // check variables
    if "`replace'"=="" {
        confirm new variable `generate'
    }
    if `"`checkonly'"'!="" exit
    if "`replace'"!="" {
        foreach v of local generate {
            capt confirm new variable `v'
            if _rc drop `v'
        }
    }
    // generate variables
    local varlist `vlist'
    foreach vnew of local generate {
        gettoken v varlist : varlist
        qui gen byte `vnew' = .
        lab var `vnew' "`v' outside value"
    }
    tempname lav uav
    local i 0
    if `"`e(over)'"'!="" {
        local over `e(over)'
        local overvals `e(over_namelist)'
        foreach o of local overvals {
            local varlist `vlist'
            foreach vnew of local generate {
                gettoken v varlist : varlist
                local ++i
                scalar `lav' = el(e(whiskers), 1, `i')
                scalar `uav' = el(e(whiskers), 2, `i')
                qui replace `vnew' = (`v'<`lav') | (`v'>`uav') ///
                    if `over'==`o' & `v'<. & e(sample)
            }
        }
    }
    else {
        local varlist `vlist'
        foreach vnew of local generate {
            gettoken v varlist : varlist
            local ++i
            scalar `lav' = el(e(whiskers), 1, `i')
            scalar `uav' = el(e(whiskers), 2, `i')
            qui replace `vnew' = (`v'<`lav') | (`v'>`uav') if `v'<. & e(sample)
        }
    }
    display _n as txt "Generated flags:" _c
    describe `generate'
end

program Postoutsides, eclass
    tempname out tmp
    local vlist "`e(depvar)'"
    local nvars: list sizeof vlist
    local flags
    forv i=1/`nvars' {
        tempname flag 
        local flags `flags' `flag'
    }
    qui Flag, flag(`flags') vlist(`vlist')
    local over `e(over)'
    if "`over'"=="" {
        foreach flag of local flags {
            gettoken v vlist : vlist
            capt mkmat `v' if `flag'==1, matrix(`tmp')
            if _rc==2000 continue
            else         error _rc
            mat rown `tmp' = "`v'"
            mat `out' = nullmat(`out'), `tmp''
        }
    }
    else {
        local overvals `e(over_namelist)'
        if `nvars'==1 {
            foreach o of local overvals {
                capt mkmat `vlist' if `flag'==1 & `over'==`o', matrix(`tmp')
                if _rc==2000 continue
                else         error _rc
                mat rown `tmp' = "`o'"
                mat `out' = nullmat(`out'), `tmp''
            }
        }
        else {
            foreach o of local overvals {
                local varlist `vlist'
                foreach flag of local flags {
                    gettoken v varlist : varlist
                    capt mkmat `v' if `flag'==1 & `over'==`o', matrix(`tmp')
                    if _rc==2000 continue
                    else         error _rc
                    mat rown `tmp' = "`o':`v'"
                    mat `out' = nullmat(`out'), `tmp''
                }
            }
        }
    }
    capt confirm matrix `out'
    if _rc {
        di as txt "no outside values; did not create matrix {bf:e(outsides)}"
        exit
    }
    mat rown `out' = "y1" // same as in e(b)
    eret matrix outsides = `out'
    di as txt "outside values added in matrix {bf:e(outsides)}"
end

program Estimate, eclass
    // syntax
    syntax varlist(numeric) [if] [in] [pw iw fw] [, over(varname numeric) cw ///
        STandard ADJusted general alpha(numlist max=1 >0 <25) ///
        bp(numlist max=1 >0 <25) delta(numlist max=1 >0) ///
        noTABle noGRaph noLABel POSTOUTsides ///
        flag FLAG2(passthru) GENerate GENerate2(passthru) replace * ]
    // - passthru options
    if `"`generate'`generate2'"'!="" & "`replace'"=="" {
        Generate, checkonly `generate2' 
    }
    if `"`flag'`flag2'"'!="" & "`replace'"=="" {
        Flag, checkonly vlist(`varlist') `flag2' 
    }
    if "`table'"=="" c_local table table
    if "`graph'"=="" c_local graph graph
    else             c_local graph nograph
    c_local label `label'
    c_local flag `flag' `flag2'
    c_local postoutsides `postoutsides'
    c_local generate `generate' `generate2'
    c_local replace `replace'
    c_local gropts `"`options'"'
    // - other options
    local method `standard' `adjusted' `general' 
    if `:list sizeof method'>1 {
        di as err "only one of standard, adjusted, and general allowed"
        exit 198
    }
    if "`method'"=="" local method "general"
    if "`method'"=="adjusted" {
        if "`alpha'"!="" {
            di as err "{bf:alpha()} not allowed with {bf:`method'}"
            exit 198
        }
    }
    else {
        tempname ALPHA
        if "`alpha'"!="" {
            scalar `ALPHA' = `alpha'
        }
        else {
            scalar `ALPHA' = 200 * (1 - normal(invnormal(.75) + ///
                             1.5 * (invnormal(.75)-invnormal(.25))))
        }
    }
    if "`method'"!="general" {
        if "`bp'"!="" {
            di as err "{bf:bp()} not allowed with {bf:`method'}"
            exit 198
        }
        if "`delta'"!="" {
            di as err "{bf:delta()} not allowed with {bf:`method'}"
            exit 198
        }
    }
    else {
        if "`bp'"==""     local bp 10
        if "`delta'"==""  local delta 0.1
    }
    
    // sample
    if "`cw'"!="" marksample touse
    else {
        marksample touse, novarlist
        tempvar touse1
        qui gen byte `touse1' = 0
        foreach v of local varlist {
            qui replace `touse1' = 1 if `touse' & `v'<.
        }
        qui replace `touse' = 0 if `touse1'==0
    }
    markout `touse' `over'
    _nobs `touse' [`weight'`exp'], min(1)
    local N = r(N)

    // prepare containers for results
    local nvars: list sizeof varlist
    tempname b box whisk whisk0 Nout _N
    mat `box'       = J(2,`nvars', .)
    mat coln `box'  = `varlist'
    mat `b'         = `box'[1,1...]
    mat `_N'        = `b'
    mat `whisk'     = `box'
    mat `whisk0'    = `box'
    mat `Nout'      = `box' \ `b'
    mat rown `Nout' = "lower" "upper" "total"
    if "`method'"=="adjusted" {
        tempname mc
        mat `mc' = `b'
    }
    else if "`method'"=="general" {
        tempname g h
        mat `g' = `b'
        mat `h' = `b'
    }
    
    // handle over()
    if "`over'"!="" {
        capt assert ((`over'==floor(`over')) & (`over'>=0)) if `touse'
        if _rc {
            di as err "variable in over() must be integer and nonnegative"
            exit 452
        }
        qui levelsof `over' if `touse', local(overvals)
        local N_over: list sizeof overvals
        local over_labels
        foreach overval of local overvals {
            local over_labels `"`over_labels' `"`: label (`over') `overval''"'"'
        }
        local over_labels: list clean over_labels
        local rmat b box whisk whisk0 Nout _N
        if "`method'"=="adjusted" local rmat `rmat' mc
        if "`method'"=="general"  local rmat `rmat' g h
        tempname tmp
        foreach mat of local rmat {
            matrix rename ``mat'' `tmp'
            foreach overval in `overvals' {
                mat coleq `tmp' = "`overval'"
                mat ``mat'' = nullmat(``mat''), `tmp'
            }
            mat drop `tmp'
        }
    }
    else {
        local total total
        local N_over 1
    }
    
    // compute results
    local i = 0
    local j = 0
    foreach overval in `overvals' `total' {
        local ++j
        if `"`overval'"'=="total" local ovr 1
        else                      local ovr `over'==`overval'
        foreach v of local varlist {
            local ++i
            _Estimate `v' if `touse' & `ovr' [`weight'`exp'], ///
                method(`method') alpha(`ALPHA') bp(`bp') delta(`delta')
            mat `_N'[1,`i']   = r(N)
            mat `b'[1,`i']      = r(p50)
            mat `box'[1,`i']    = r(p25) \ r(p75)
            mat `whisk'[1,`i']  = r(lav) \ r(uav)
            mat `whisk0'[1,`i'] = r(lb)  \ r(ub)
            mat `Nout'[1,`i']   = r(lout) \ r(uout) \ r(tout)
            if "`method'"=="adjusted" {
                mat `mc'[1,`i'] = r(mc)
            }
            else if "`method'"=="general" {
                mat `g'[1,`i'] = r(g)
                mat `h'[1,`i'] = r(h)
            }
        }
    }
    
    // flip labels if over() and only one variable
    if "`over'"!="" & `nvars'==1 {
        local colnm: coleq `b'
        foreach mat of local rmat {
            matrix coleq ``mat'' = ""
            matrix coln ``mat'' = `colnm'
        }
        local k_eq = 1
    }
    else {
        local k_eq = `N_over'
    }
    
    // post results
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    eret local cmd "robbox"
    local title "box plot"
    if "`method'"=="general"       eret local title "Generalized box plot"
    else if "`method'"=="adjusted" eret local title "Adjusted box plot"
    else                           eret local title "Standard box plot"
    eret local method "`method'"
    eret local depvar "`varlist'"
    eret local over_labels `"`over_labels'"'
    eret local over_namelist `"`overvals'"'
    eret local over "`over'"
    eret scalar N_vars = `nvars'
    eret scalar N_over = `N_over'
    eret scalar k_eq = `k_eq'
    eret matrix _N = `_N'
    if "`method'"=="adjusted" {
        eret matrix medcouple = `mc'
    }
    else if "`method'"=="general" {
        eret matrix h = `h'
        eret matrix g = `g'
    }
    eret matrix N_out = `Nout'
    eret matrix whiskers0 = `whisk0'
    eret matrix whiskers = `whisk'
    eret matrix box = `box'
    if "`ALPHA'"!="" eret scalar alpha = `ALPHA'
    if "`bp'"!=""    eret scalar bp    = `bp'
    if "`delta'"!="" eret scalar delta = `delta'
    Return_clear // clear r()
end
program Return_clear, rclass
    local x
end

program _Estimate, rclass
    // syntax
    syntax varname(numeric) if [pw iw fw/] [, method(str) alpha(str) bp(str) delta(str) ]
    
    // weights and number of obs
    if "`weight'"!="" {
        local wgt [`weight' = `exp']
        if "`weight'"=="iweight" local pcwgt [aw = `exp']
        else                     local pcwgt `wgt'
    }
    if "`weight'"!="fweight" {
        qui count `if' & `varlist'<.
        local N = r(N)
    }
    else {
        su `varlist' `wgt' `if', meanonly
        local N = r(N)
    }
    if `N'==0 {
        return scalar N = `N'
        return scalar p50  = 0  // (because e(b) cannot have missings)
        exit
    }

    // compute quartiles
    if "`method'"=="general" local percentiles 10 25 50 75 90
    else                     local percentiles 25 50 75
    _pctile `varlist' `pcwgt' `if', percentiles(`percentiles')
    local i 0
    foreach p of local percentiles {
        local ++i
        tempname p`p'
        scalar `p`p'' = r(r`i')
    }
    
    // compute minimum lower bound and maximum upper bound of whiskers
    tempname lb ub
    if "`method'"=="standard" {
        tempname c
        scalar `c' = (invnormal(1-`alpha'/200) - invnormal(.75)) ///
                   / (invnormal(.75) - invnormal(.25))
        scalar `lb' = `p25' - `c' * (`p75'-`p25')
        scalar `ub' = `p75' + `c' * (`p75'-`p25')
    }
    else if "`method'"=="adjusted" {
        tempname MC
        quietly robstat `varlist' `if' `wgt', statistic(MC) nose
        scalar `MC' = _b[MC]
        if `MC'>=0 {
            scalar `lb' = `p25' - 1.5 * exp(-4*`MC') * (`p75'-`p25')
            scalar `ub' = `p75' + 1.5 * exp(3*`MC') * (`p75'-`p25')
        }
        else {
            scalar `lb' = `p25' - 1.5 * exp(-3*`MC') * (`p75'-`p25')
            scalar `ub' = `p75' + 1.5 * exp(4*`MC') * (`p75'-`p25')
        }
    }
    else if "`method'"=="general" {
        tempvar v
        tempname scale rmin rscale qmed qscale g h lb0 ub0
        // step 1: transform the data
        // - (a) standardize, so that delta in (b) is relative to the scale
        scalar `scale' = (`p75' - `p25') / (0.6817766                      ///
            + 0.0534282 * abs((`p90' + `p10' - 2*`p50') / (`p90' - `p10')) /// 
            + 0.1794771 * ((`p90' - `p10') / (`p75' - `p25'))              /// 
            - 0.0059595 * ((`p90' - `p10') / (`p75' - `p25'))^2)           //
            // note: sk = (p90+p10-2*p50)/(p90-p10), kurt = (p90-p10)/(p75-p25)
            // why not simply use scale = (p75-p25) as in paper?
        qui gen `v' = (`varlist' - `p50') / `scale' `if'
        // - (b) shift to positive domain and fit into (0,1)
        su `v' `if', mean
        scalar `rmin'   = r(min)
        scalar `rscale' = 2 * `delta' + r(max) - `rmin'
            // note: rscale is equal to min+max from shifted data
        qui replace `v' = (`v' - `rmin' + `delta') / `rscale' `if'
            // note: resulting data will be in [d, 1-d] with 
            //       d = `delta' / (2*`delta' + range/`scale')
            //       were range = max-min of the original data
        // - (c) transform to quantiles of the standard normal
        qui replace `v' = invnormal(`v') `if'
        // - (d) standardize the quantiles
        _pctile `v' `pcwgt' `if', percentiles(25 50 75)
        scalar `qmed'   = r(r2)
        scalar `qscale' = ((r(r3) - r(r1)) / (invnormal(0.75)-invnormal(0.25)))
        qui replace `v' = (`v' - `qmed') / `qscale'
        // step 2: fit the g and h distribution
        local plo = `bp'
        local pup = 100 - `bp'
        _pctile `v' `pcwgt' `if', percentiles(`plo' `pup')
        scalar `g' = ln(-r(r2)/r(r1)) / invnormal(`pup'/100)
            // note: (r(r2)-med)/(med-r(r1)) = -r(r2)/r(r1) because med = 0
        scalar `h' = 2 / invnormal(`pup'/100)^2 * ln(-`g' * ((r(r1) * r(r2)) / (r(r1) + r(r2))))
        // step 3: get outlier limits (alpha quantiles) of the fitted g-and-h
        tempname xi_lo xi_up
        scalar `lb0' = (1/`g') * (exp(`g' * invnormal(`alpha'/200)) - 1) * ///
                                 exp(`h' * invnormal(`alpha'/200)^2 / 2)
        scalar `ub0' = (1/`g') * (exp(`g' * invnormal(1-`alpha'/200)) - 1) * ///
                                 exp(`h' * invnormal(1-`alpha'/200)^2 / 2)
        // step 4: back-transform the limits to the original scale
        scalar `lb' = `p50' + `scale' * ///
            ((normal(`lb0'*`qscale' + `qmed') * `rscale') + `rmin' - `delta')
        scalar `ub' = `p50' + `scale' * ///
            ((normal(`ub0'*`qscale' + `qmed') * `rscale') + `rmin' - `delta')
        // step 5: make sure the limits are not inside the box
        scalar `lb' = min(`p25', `lb')
        scalar `ub' = max(`p75', `ub')
    }

    // compute lower and upper adjacent values (empirical endpoints if whiskers)
    tempname lav uav
    summarize `varlist' `if' & `varlist'>=`lb' & `varlist'<=`ub', mean
    scalar `lav' = min(`p25', r(min))
    scalar `uav' = max(`p75', r(max))
    
    // count outside values
    if "`weight'"!="fweight" {
        qui count `if' & `varlist'<`lav' & `varlist'<.
        local lout = r(N)
        qui count `if' & `varlist'>`uav' & `varlist'<.
        local uout = r(N)
    }
    else {
        su `varlist' `wgt' `if' & `varlist'<`lav', meanonly
        local lout = r(N)
        su `varlist' `wgt' `if' & `varlist'>`uav', meanonly
        local uout = r(N)
    }
    
    // return results
    return scalar N    = `N'
    return scalar p25  = `p25'
    return scalar p50  = `p50'
    return scalar p75  = `p75'
    return scalar lb   = `lb'
    return scalar ub   = `ub'
    return scalar lav  = `lav'
    return scalar uav  = `uav'
    return scalar lout = `lout'
    return scalar uout = `uout'
    return scalar tout = `lout' + `uout'
    if "`method'"=="adjusted" {
        return scalar mc = `MC'
    }
    else if "`method'"=="general" {
        return scalar g = `g'
        return scalar h = `h'
    }
end

version 11
mata:
mata set matastrict on

// sort results; note that only the results used for graphing will be sorted
void robbox_sort(string scalar B, real scalar index, real scalar des)
{
    real scalar      over, nvars, nover, i
    real colvector   p, p1, b, b1, N
    string scalar    ename
    string rowvector tmp
    string matrix    cstripe
    
    over = st_global("e(over)")!=""
    nvars = st_numscalar("e(N_vars)")
    if (over) {
        b = st_matrix("e(b)")'
        if (nvars==1) {
            p = p1 = order(b, 1)
            if (des) p = p1 = revorder(p)
        }
        else {
            if (index>nvars) {
                display("{txt}(specified sort index larger than number of variables;"
                    + " will sort by average)")
                index = 0
            }
            nover = st_numscalar("e(N_over)")
            N = st_matrix("e(_N)")'
            b1 = J(nover, 1, .)
            for (i=1; i<=nover; i++) {
                if (index==0) b1[i] = mean(select(b[|(i-1)*nvars+1 \ i*nvars|],
                                              N[|(i-1)*nvars+1 \ i*nvars|]:!=0))
                else b1[i] = b[(i-1)*nvars + index]
            }
            p1 = order(b1, 1)
            if (des) p1 = revorder(p1)
            p = J(rows(b), 1, .)
            for (i=1; i<=nover; i++) {
                p[|(i-1)*nvars+1 \ i*nvars|] = (p1[i]-1)*nvars+1::p1[i]*nvars
            }
        }
        tmp = tokens(st_global("e(over_namelist)"))
        st_global("e(over_namelist)", invtokens(tmp[p1]))
        tmp = ("`"+`"""') :+ tokens(st_global("e(over_labels)")) :+ (`"""'+"'")
        st_global("e(over_labels)", invtokens(tmp[p1]))
    }
    else {
        b = st_matrix("e(b)")'
        p = p1 = order(b, 1)
        if (des) p = p1 = revorder(p)
        tmp = tokens(st_global("e(depvar)"))[p1]
        st_global("e(depvar)", invtokens(tmp[p1]))
    }
    cstripe = st_matrixcolstripe("e(b)")[p,]
    st_matrix(B, b[p]')
    st_matrixcolstripe(B, cstripe)
    stata("ereturn repost b = " + B + ", rename")
    tmp = ("box", "whiskers", "_N")
    for (i=1; i<=length(tmp); i++) {
        ename = "e(" + tmp[i] + ")"
        st_replacematrix(ename, st_matrix(ename)[,p])
        st_matrixcolstripe(ename, cstripe)
    }
}

end

exit

