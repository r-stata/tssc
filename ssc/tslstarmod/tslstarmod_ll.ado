*! version 1.0.1
*! The Max. Lik. Estimation Evaluator 
*! for the Command tslstarmod
*! Method lf
*! Diallo Ibrahima Amadou
*! All comments are welcome, 18Sep2019



capture program drop tslstarmod_ll
program tslstarmod_ll
		version 15.1
        args lnf regime1 regime2 lngamma cpar lnsigma 
        tempvar theta gammap sigma lagy 
        quietly {
                generate double `gammap' = exp(`lngamma')
                generate double `sigma'  = exp(`lnsigma')
                tsset
                generate double `lagy' = $MZHAWA_ZVAR
                generate double `theta'  = (1+exp(-`gammap'*(`lagy' - `cpar')))^(-1)
                replace `lnf' = ln(normalden($ML_y1,`regime1' + `theta'*(`regime2'),`sigma'))
        }
end


