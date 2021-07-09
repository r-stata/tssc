*! version 1.1.2  05nov2019  Ben Jann & Simon Seiler

program udiff_lf
    version 11
    
    // collect information
    local mtype    $UDIFF_mtype
    local nout     $UDIFF_nout
    local olist    $UDIFF_out
    local ibase    $UDIFF_ibase
    local nunidiff $UDIFF_nunidiff
    forv j = 1/`nunidiff' {
        if "`mtype'"!="0" local philist `philist' phi`j'
        forv i = 1/`nout' {
            if `i'==`ibase' continue
            local psilist `psilist' psi`j'_`i'
        }
    }
    forv i = 1/`nout' {
        if `i'==`ibase' continue
        local thetalist `thetalist' theta`i'
    }
    args lnf `philist' `psilist' `thetalist'
    
    // fill-in likelihood
    tempvar tmp
    qui gen double `tmp' = .
    qui replace `lnf' = 1 if $ML_samp
    forv i = 1/`nout' {
        if `i'==`ibase' continue
        if "`mtype'"!="0" local expphi " * exp(`phi1')"
        qui replace `tmp' = `psi1_`i''`expphi' if $ML_samp
        forv j=2/`nunidiff' {
            if "`mtype'"!="0" local expphi " * exp(`phi`j'')"
            qui replace `tmp' = `tmp' + `psi`j'_`i''`expphi' if $ML_samp
        }
        qui replace `lnf' = `lnf' + exp(`theta`i'' + `tmp') if $ML_samp
    }
    forv i = 1/`nout' {
        gettoken out olist : olist
        if `i'==`ibase' {
            qui replace `lnf' = -ln(`lnf') if $ML_samp & $ML_y1==`out'
            continue
        }
        if "`mtype'"!="0" local expphi " * exp(`phi1')"
        qui replace `tmp' = `psi1_`i''`expphi' if $ML_samp & $ML_y1==`out'
        forv j=2/`nunidiff' {
            if "`mtype'"!="0" local expphi " * exp(`phi`j'')"
            qui replace `tmp' = `tmp' + `psi`j'_`i''`expphi' if $ML_samp & $ML_y1==`out'
        }
        qui replace `lnf' = `theta`i'' + `tmp' - ln(`lnf') if $ML_samp & $ML_y1==`out'
    }
end

