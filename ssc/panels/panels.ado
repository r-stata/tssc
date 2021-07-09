*! version 1.0.2  31aug2013  Ben Jann
*! - missing option added
*! version 1.0.1  23oct2009  Ben Jann

prog panels
    version 8
    local caller : di _caller()
    capt _on_colon_parse `0'
    if _rc==0 {
        local 0 `"`s(before)'"'
        local estcom `"`s(after)'"'
        syntax varlist [if] [in] [fw aw iw pw] [, Missing ///
            Generate(name) Noisily NOISE FILLin ///
            ISConstant(passthru) Check(passthru) noWarn * ]
        if "`generate'"=="" {
            tempvar generate
        }
        if "`fillin'"!="" {
            tempvar fillin2
            local fillinopt fillin2(`fillin2')
        }
        if "`noisily'`noise'"=="" {
            local nonoisily nonoisily
        }
        _panels `varlist' `if' `in' [`weight'`exp'], `missing' ///
            generate(`generate') `fillinopt' `nonoisily' ///
            `isconstant' `check' `warn' `options'
        ExpandIfqualifier `generate' `estcom'
        version `caller': `estcom'
        if `"`isconstant'`check'"'=="" & "`warn'"=="" {
            di _n as txt "(variables assumed constant within panels;" ///
                " use {helpb panels:isconstant()} to verify)"
        }
        if "`fillin'"!="" {
            drop `generate'
            rename `fillin2' `generate'
        }
    }
    else {
        _panels `0'
    }
end

program ExpandIfqualifier
    gettoken generate 0 : 0
    syntax anything(equalok) [if/] [in] [using] [fw aw pw iw] [, * ]
    local estcom `"`macval(anything)' if (`generate'<.)"'
    if `"`macval(if)'"'!="" {
        local estcom `"`macval(estcom)' & (`macval(if)')"'
    }
    if `"`macval(in)'"'!="" {
        local estcom `"`macval(estcom)' `macval(in)'"'
    }
    if `"`macval(using)'"'!="" {
        local estcom `"`macval(estcom)' `macval(using)'"'
    }
    if `"`macval(weight)'"'!="" {
        local estcom `"`macval(estcom)' [`macval(weight)'`macval(exp)']"'
    }
    if `"`macval(options)'"'!="" {
        local estcom `"`macval(estcom)', `macval(options)'"'
    }
    c_local estcom `"`macval(estcom)'"'
end

prog _panels, sort rclass
    syntax varlist [if] [in] [fw aw iw pw] [, Missing ///
        Generate(name) id(name) Replace ISConstant(varlist) Check(varlist) ///
        noWarn FILLin fillin2(name) noNoisily noNoise ]
    if "`generate'"!="" {
        if "`replace'"=="" confirm new var `generate'
    }
    if "`id'"!="" {
        if "`replace'"=="" confirm new var `id'
    }
    local isconstant: list isconstant | check
    if "`missing'"!="" {
        marksample touse, strok novarlist
    }
    else {
        marksample touse, strok
    }
    qui count if `touse'
    local N = r(N)
    tempname tag newid
    sort `touse' `varlist'
    foreach var of local isconstant {
        capt noisily by `touse' `varlist': ///
            assert (`var' == `var'[1]) if `touse'
        if _rc==9 {
            di as err "`var' not constant within panels"
            exit _rc
        }
        else if _rc exit _rc
    }
    qui by `touse' `varlist': gen `tag' = _N if _n==1 & `touse'
    if "`id'"!="" {
        qui gen byte `newid' = `tag'<. if `touse'
        qui by `touse': replace `newid' = `newid' + `newid'[_n-1] if _n>1 & `touse'
    }
    su `tag', mean
    local N_g = r(N)
    local g_min = r(min)
    local g_avg = r(mean)
    local g_max = r(max)
    if "`noisily'`noise'"=="" {
        di _n as txt "Number of obs      = " as res %9.0g `N'
        di    as txt "Number of groups   = " as res %9.0g `N_g'
        di _n as txt "Obs per group: min = " as res %9.0g `g_min'
        di    as txt "               avg = " as res %9.0g `g_avg'
        di    as txt "               max = " as res %9.0g `g_max'
    }
    ret scalar g_max = `g_max'
    ret scalar g_avg = `g_avg'
    ret scalar g_min = `g_min'
    ret scalar N_g = `N_g'
    ret scalar N = `N'
    if "`generate'"!="" {
        if "`fillin2'"!="" {
            qui by `touse' `varlist': gen `fillin2' = `tag'[1] if `touse'
        }
        if "`fillin'"!="" {
            qui by `touse' `varlist': replace `tag' = `tag'[1] if `touse'
        }
        if "`replace'"!="" {
            capt confirm new var `generate'
            if _rc drop `generate'
        }
        rename `tag' `generate'
    }
    if "`id'"!="" {
        if "`replace'"!="" {
            capt confirm new var `id'
            if _rc drop `id'
        }
        rename `newid' `id'
    }
end
