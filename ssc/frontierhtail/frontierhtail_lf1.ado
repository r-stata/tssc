*! version 1.0.0
*! The Normal-Uniform evaluator for the command frontierhtail
*! Method lf1
*! Diallo Ibrahima Amadou
*! All comments are welcome, 14oct2011


capture program drop frontierhtail_lf1
program frontierhtail_lf1
        version 11
        args todo b lnfj g1 g2 g3
        tempvar xb lnsigma lntheta
        mleval `xb'      = `b' , eq(1)
        mleval `lnsigma' = `b' , eq(2)
        mleval `lntheta' = `b' , eq(3)
        quietly {
                 tempvar epsilon phi1 phi2 gam1 gam2
                 gen double `epsilon' = $ML_y1 - `xb'
                 gen double `phi1'    = normalden(exp(-`lnsigma')*`epsilon')
                 gen double `phi2'    = normalden(exp(-`lnsigma')*(exp(`lntheta')+`epsilon'))
                 gen double `gam1'    = normal(exp(-`lnsigma')*`epsilon')
                 gen double `gam2'    = normal(exp(-`lnsigma')*(exp(`lntheta')+`epsilon'))
                 replace `lnfj'       = -`lntheta'+ln(-`gam1'+`gam2')
                 if (`todo'==0) exit
                 replace `g1'         = (exp(-`lnsigma')*`phi1'-exp(-`lnsigma')*`phi2')/(-`gam1'+`gam2')
                 replace `g2'         = (exp(-`lnsigma')*`phi1'*`epsilon'-exp(-`lnsigma')*`phi2'*(exp(`lntheta')+`epsilon'))/(-`gam1'+`gam2')
                 replace `g3'         = -1+(exp(`lntheta'-`lnsigma')*`phi2')/(-`gam1'+`gam2')
        }
end
