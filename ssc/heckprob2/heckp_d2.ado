/**********************************************************/
/*             Heckman probit d2 evoluator                */
/*                                                        */
/*             by Jerzy Mycielski                         */
/*             Warsaw Univeristy                          */
/*             16.07.2004                                 */
/**********************************************************/     



program define heckp_d2
	version 8
      args todo b lnf g negH
	tempvar Lj gamma1 gamma2
      tempname athrho 
      mleval `gamma1'  = `b', eq(1)
      mleval `gamma2'  = `b', eq(2)
      mleval `athrho'  = `b', eq(3) scalar             /*assuming that rho is scalar, can be generalized*/
       
      tempname rho 
      tempvar `Lj'
      scalar `rho'   = tanh(`athrho')                          /*if $ML_y1!=0  assuming that rho is scalar, can be generalized*/

                 /**************Logrithm of likelihood function****************/
      
      local prob_0    normprob(-`gamma2')               
      local prob_11   binorm(`gamma2',`gamma1',`rho') 
      local prob_10  (1-`prob_0'-`prob_11')                 

      quiet gen double `Lj' = `prob_0'   if $ML_y2==0
      quiet replace    `Lj' = `prob_10'  if $ML_y2!=0 & $ML_y1==0
      quiet replace    `Lj' = `prob_11'  if $ML_y2!=0 & $ML_y1!=0          
      
      mlsum `lnf' = ln(`Lj')      
      
      if (`todo'==0 | `lnf'==.) exit

                /**********************First order derivatives of binominal normal distribution*******************/
      tempvar Fg1 Fg2 Fr

      quietly gen double `Fg1' = normprob((`gamma2'-`rho'*`gamma1')/sqrt(1-(`rho')^2))*normden(`gamma1')                  if $ML_y2!=0
      quietly gen double `Fg2' = normprob((`gamma1'-`rho'*`gamma2')/sqrt(1-(`rho')^2))*normden(`gamma2')                  if $ML_y2!=0
      quietly gen double `Fr'  = normden((`gamma2'-`rho'*`gamma1')/sqrt(1-(`rho')^2))*normden(`gamma1')/sqrt(1-(`rho')^2) if $ML_y2!=0     

                       /*First order derivatives with respect to g1, g2 i rho*/
      tempvar lg1 lg2 lr                            
                                    /*for y2=0*/
      quietly gen double  `lg1' = 0                         if $ML_y2==0
      quietly gen double  `lg2' = -normden(`gamma2')/`Lj'   if $ML_y2==0
      quietly gen double  `lr'  = 0                         if $ML_y2==0

                                        /*for y2=1 y1=0*/
      quietly replace `lg1' = -`Fg1'/`Lj'                     if $ML_y2!=0 & $ML_y1==0
      quietly replace `lg2' = (normden(`gamma2')-`Fg2')/`Lj'  if $ML_y2!=0 & $ML_y1==0
      quietly replace `lr'  = -`Fr' /`Lj'                     if $ML_y2!=0 & $ML_y1==0


                                       /*for y2=1 y1=1*/
      quietly replace  `lg1' = `Fg1'/`Lj'         if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lg2' = `Fg2'/`Lj'         if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lr'  = `Fr' /`Lj'         if $ML_y2!=0 & $ML_y1!=0
     
     
                        /*First order derivatives with respect with respect to g1,g2, tan(rho)*/

      tempname dg1 dg2 dr
      mlvecsum `lnf' `dg1' = `lg1',              eq(1)
      mlvecsum `lnf' `dg2' = `lg2',              eq(2)
      mlvecsum `lnf' `dr'  = `lr'*(1-(`rho')^2), eq(3)                 /*tanh(rho)!*/
      matrix `g' = (`dg1',`dg2',`dr')   

      if (`todo'==1 | `lnf'==.) exit

           /**********************Second order derivatives of binominal normal distribution***********************/
      local Fg11  (-`rho'*`Fr'-`gamma1'*`Fg1')
      local Fg22  (-`rho'*`Fr'-`gamma2'*`Fg2')
      local Fg12  `Fr'
      local Fg1r  -(`gamma1'-`rho'*`gamma2')/(1-(`rho')^2)*`Fr'
      local Fg2r  -(`gamma2'-`rho'*`gamma1')/(1-(`rho')^2)*`Fr'
      local Frr   1/(1-(`rho')^2)*(1+(`gamma2'-`rho'*`gamma1')*(`gamma1'-`rho'*`gamma2')/(1-(`rho')^2))*`Fr'

                         /*Second order derivatives with respect to g1, g2 i rho*/
      tempvar lg11 lg22 lg12 lg1r lg2r lrr                    
                                      /*for y1=0*/
      quietly gen double  `lg11' = 0                        if $ML_y2==0
      quietly gen double  `lg22' = -`gamma2'*`lg2'-`lg2'^2  if $ML_y2==0
      quietly gen double  `lg12' = 0                        if $ML_y2==0
      quietly gen double  `lg1r' = 0                        if $ML_y2==0
      quietly gen double  `lg2r' = 0                        if $ML_y2==0
      quietly gen double  `lrr'  = 0                        if $ML_y2==0
                                        /*for y2=1 y1=0*/
      quietly replace `lg11' = -`Fg11'/`Lj'-`lg1'^2                                if $ML_y2!=0 & $ML_y1==0
      quietly replace `lg22' = (-`gamma2'*normden(`gamma2')-`Fg22')/`Lj'-`lg2'^2   if $ML_y2!=0 & $ML_y1==0
      quietly replace `lg12' = -`Fg12'/`Lj'-`lg1'*`lg2'                            if $ML_y2!=0 & $ML_y1==0
      quietly replace `lg1r' = -`Fg1r'/`Lj'-`lg1'*`lr'                             if $ML_y2!=0 & $ML_y1==0
      quietly replace `lg2r' = -`Fg2r'/`Lj'-`lg2'*`lr'                             if $ML_y2!=0 & $ML_y1==0
      quietly replace `lrr'  = -`Frr' /`Lj'-`lr'^2                                 if $ML_y2!=0 & $ML_y1==0

                                       /*for y2=1 y2=1*/
      quietly replace  `lg11' = `Fg11'/`Lj'-`lg1'^2          if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lg22' = `Fg22'/`Lj'-`lg2'^2          if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lg12' = `Fg12'/`Lj'-`lg1'*`lg2'      if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lg1r' = `Fg1r'/`Lj'-`lg1'*`lr'       if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lg2r' = `Fg2r'/`Lj'-`lg2'*`lr'       if $ML_y2!=0 & $ML_y1!=0
      quietly replace  `lrr'  = `Frr' /`Lj'-`lr'^2           if $ML_y2!=0 & $ML_y1!=0

                  /*Matrix of second order derivatives with respect with respect to g1,g2, tan(rho)*/

      tempname dg11 dg12 dg1r dg22 dg2r drr     

      mlmatsum `lnf' `dg11' = `lg11',                                       eq(1)
      mlmatsum `lnf' `dg12' = `lg12',                                       eq(1,2)
      mlmatsum `lnf' `dg1r' = `lg1r'*(1-`rho'^2),                           eq(1,3)   /*tanh(rho)! */ 
      mlmatsum `lnf' `dg22' = `lg22',                                       eq(2)
      mlmatsum `lnf' `dg2r' = `lg2r'*(1-`rho'^2),                           eq(2,3)   /*tanh(rho)! */ 
      mlmatsum `lnf' `drr'  = `lrr'*(1-`rho'^2)^2-2*`lr'*`rho'*(1-`rho'^2), eq(3)     /*tanh(rho)! */

      matrix `negH' = -(`dg11' ,`dg12' ,`dg1r' \/*
                     */ `dg12'',`dg22' ,`dg2r' \/* 
                     */ `dg1r'',`dg2r'',`drr' ) 


end
