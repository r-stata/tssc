* Parametric likelihood definition for Waiting Time Distribution
* with LogNormal FRD and Uniform h, no censoring
* Henrik Støvring, Dec 2001

program define mlwtd_lnorm
        version 7.0
	args lnf transp mu lnsigma 

        tempname p
qui{
        scalar `p' = exp(`transp')/(1+exp(`transp'))
	
        replace `lnf' = ln( `p' *                   /*
                        */ normprob(-(ln($ML_y1) - `mu')/exp(`lnsigma')) /*
                        */ / exp(`mu' + exp(2 * `lnsigma')/2) +  /*
                        */ (1 - `p') )
      }
end
