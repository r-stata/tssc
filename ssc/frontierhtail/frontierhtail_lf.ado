*! version 1.0.0
*! The Normal-Uniform evaluator for the command frontierhtail
*! Method lf
*! Diallo Ibrahima Amadou
*! All comments are welcome, 14oct2011


capture program drop frontierhtail_lf
program frontierhtail_lf
        version 11
        args lnfj xb lnsigma lntheta
        tempvar epsilon
        quietly gen double `epsilon' = $ML_y1 - `xb'
        quietly replace `lnfj' = -`lntheta'+ln(normal((exp(`lntheta')+`epsilon')/exp(`lnsigma'))-normal(`epsilon'/exp(`lnsigma')))
end
