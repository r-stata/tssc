program nl_choi_support_interval
version 14

*    This program is used by nl to calculate the upper and lower  
*    bounds of the k = $k_global support interval.
 
     syntax varlist(min=1 max=1) [if], at(name)

     tempname psi dummy 
     scalar `psi' = `at'[1, 1]
     scalar `dummy' = `at'[1, 2]

     tempvar yh
     choi_lr_hyperg_prob n1 n2 y1 y2 `psi'
     local val = r(lnf)

*    We seek the value of psi such that the likelihood ratio at
*    psi equals $k_global. If f(psi) equals the log of this likelihood
*    ratio - log($k_global) then setting yh = f(psi) + 1 will result in
*    the nl program finding the value of psi that gives f(psi)=0.
*    This is either the upper or lower bound of the k=$k_global support
*    interval.

     gen double `yh' =max_lnf - `val' -log($k_global) +1  in 1 
     replace `yh' = `dummy'      in 2

     replace `varlist' = `yh'
     
 end // *******************************************************
