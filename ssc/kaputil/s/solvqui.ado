*! version 1.0.0 DH 29Sep2004.
program define solvqui, rclass
    version 8.0
    syntax anything(id="coefficients")
    local n : word count `anything'
    if `n'!=3 {
        di as error "3 coefficients required"
    }
	tokenize `anything'
    forvalues i=1/`n' {
        confirm number ``i''
    }
    if `1'==0 {
        if `2'==0 {
            local x1=.
        }
        else {
	        local x1=-`3'/`2'
        }
        local x2=.
    }
    else {
        local discr=(`2')^2-4*`1'*`3'
        if `discr'>=0 {
            if `2'==0 {
                local x1=-sqrt(-`3'/`1')
                local x2=sqrt(-`3'/`1')
            }
            else {
                local q=-(`2'+sign(`2')*sqrt(`discr'))/2
                local r1=`q'/`1'
                local r2=`3'/`q'
                local x1=min(`r1',`r2')
                local x2=max(`r1',`r2')
            }
        }
        else {
            local x1=.
            local x2=.
        }
    }
    return scalar x2=`x2'
    return scalar x1=`x1'
end
