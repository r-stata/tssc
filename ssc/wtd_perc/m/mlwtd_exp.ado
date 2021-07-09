* Parametric likelihood definition for Waiting Time Distribution
* with Exponential FRD and Uniform h, no censoring
* Henrik Støvring, Dec 2001

program define mlwtd_exp
        version 7.0
	args lnf transp lnbeta 

        tempname p beta
qui{
        scalar `p' = exp(`transp')/(1+exp(`transp'))
	scalar `beta' = exp(`lnbeta')
	
        replace `lnf' = ln(`p' * `beta' * exp(- `beta' * $ML_y1) + /*
                              */ (1 - `p'))
      }
end
