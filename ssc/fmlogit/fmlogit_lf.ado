*! version 1.0.0 MLB 11Nov2008
*! Fitting of fractional multinomial logit by ML
*! Called by fmlogit.ado

program define fmlogit_lf
        version 8.2
        gettoken ref rest: (global) S_depvars
        local eqs : subinstr local rest " " " eta_", all
        args lnf `eqs'
       
        local denom "1"
        foreach eq of local rest {
        	local denom "`denom' + exp(`eta_`eq'')"
        }
        local lnff "$ML_y1 * ln(1/(`denom'))"
        local i = 2
        tokenize $S_depvars
        local k : word count $S_depvars
        forvalues i = 2/`k' {
              	local lnff "`lnff' + ${ML_y`i'} * ln(exp(`eta_``i''')/(`denom'))"
        }
        quietly replace `lnf' = `lnff'
end
