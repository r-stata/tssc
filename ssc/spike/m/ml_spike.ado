*! version 1.1          <20080317>          JP Azevedo
*  Projeto WTP - Futura

program define ml_spike
    version 6

    args lnf theta1 theta2
    tempvar t1 t2 t3

    quietly gen double `t1' = (1/(1+exp(`theta2')))
    quietly gen double `t2' = (1/(1+exp(`theta2'-`theta1')))-(1/(1+exp(`theta2')))
    quietly gen double `t3' = (1/(1+exp(-(`theta2'-`theta1'))))

    quietly replace `lnf' =  (1-$ML_y1)*(1-$ML_y2)*log(`t1') + $ML_y1*(1-$ML_y2)*log(`t2') + $ML_y1*$ML_y2*log(`t3')

end
