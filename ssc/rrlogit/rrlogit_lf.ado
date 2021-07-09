*! version 1.1.2, Ben Jann, 11may2011
program define rrlogit_lf
    version 9.1
    args todo b lnf g negH g1
    tempvar theta1
    mleval `theta1' = `b', eq(1)

    local pw $rrlogit_pw
    if `"`pw'"'=="" local p1 1
    local p1 $rrlogit_p1
    if `"`p1'"'=="" local p1 0
    local p2 $rrlogit_p2
    if `"`p2'"'=="" local p2 0
    
    local c "((1-`p1'-`p2')*(1-`pw')+`p1')"
    local q "((1-`p1'-`p2')*`pw'+`p1')"
    tempname R S
    quietly gen double `R' = `c' + `q' * exp(`theta1') if $ML_samp
    quietly gen double `S' = (1-`c') + (1-`q') * exp(`theta1') if $ML_samp

    mlsum `lnf' = cond($ML_y1, ln(`R'), ln(`S')) - ln(1 + exp(`theta1'))
    if (`todo'==0 | `lnf'>=.)  exit

    quietly replace `g1' = ( ///
        cond($ML_y1, `q'/`R', (1-`q')/`S') - 1/(1+exp(`theta1')) ///
        ) * exp(`theta1')
    mlvecsum `lnf' `g' = `g1', eq(1)
    if (`todo'==1 | `lnf'>=.) exit

    mlmatsum `lnf' `negH' = - ( ///
        cond($ML_y1, `q'*(`R'-`q'*exp(`theta1'))/`R'^2, ///
            (1-`q')*(`S'-(1-`q')*exp(`theta1'))/`S'^2) /// 
            - 1/(1+exp(`theta1'))^2  ///
        ) * exp(`theta1'), eq(1)
              
end

