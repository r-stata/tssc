*! 1.0 MB & NO 29 Dec 2003

capture program drop xtvc
program define xtvc, eclass

	syntax  [, Level(int $S_level)  H0(numlist min=1 max=1)  ] 
 	
	version 6 
 
if replay() {
		if `"`e(cmd)'"'==`"xtreg"' {

                if "`e(model)'" != "ml"   {
                        noi di in red "xtreg, mle not found"
                        exit 301 
					}
				}
			else {
                        noi di in red "xtreg, mle not found"
                        exit 301 
				}						
		}
    
  preserve

    /* CHECK THE OPTION H0 FOR SIGMA_U */
   
			if "`h0'" != ""  {	 

					if `h0' < 0 {
							di as err "option h0(#): null value must be greater than or equal to zero"
							exit 198
							}
 
                              scalar PT = `h0'
                                     }
   
    /* CHECK SIGNIFICANCE LEVEL */

	 if `level' <10 | `level'>99 { 
						di in red "level() invalid"
						exit 198
						}   
                                
   	local levelci = `level'/100	
	scalar chi2 = invchi2(1,`levelci')
   
    /* GET RESULTS FROM XTREG, MLE */
                              
	local ivar "`e(ivar)'"
      local dep  "`e(depvar)'"
      local m = e(N_g)
      scalar sigma_e = e(sigma_e)
	scalar sigma_u = e(sigma_u)
	
 	tempvar xb pr res n  qres  sqres   Sqres 
	
 	qui predict `xb'
      qui gen double `res' = `dep' - `xb'

    /*  DROP MISSING VALUES */
    
    qui keep if `res' != .

    quietly  {
	sort  `ivar'
		by  `ivar': gen `n' = cond(_n == _N,_N,.)
		by  `ivar': gen `qres' = cond(_n==_N, sum(`res'/_N),.)		
		gen `sqres' = .
		gen `Sqres' = .
              }
            
/* SCORE TEST AT SIGMA_U == # */

 if  e(sigma_u)  == 0 {                    

                     scalar S0 = 0
                     scalar pval = 1
                     scalar PTEST = 0
                
            if "`h0'" != ""  {
                    scalar PTEST = PT
                    qui replace `sqres' =  `qres'^2 / ( PTEST ^2 + sigma_e^2/`n')
			  qui replace `Sqres' = sum(`sqres') if  `n' != .

			  scalar SUMSQRES = `Sqres' in l
			  scalar S0 = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) )  
                    scalar pval = chi2tail(1, S0)
                         	}
                     }
                else {
                	  scalar PTEST = 0
                
                      if "`h0'" != ""  {
                              	    scalar PTEST = PT
                                   	    }
 
					qui replace `sqres' =  `qres'^2 / ( PTEST ^2 + sigma_e^2/`n')
					qui replace `Sqres' = sum(`sqres') if  `n' != .

					scalar SUMSQRES = `Sqres' in l
					scalar S0 = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) )  
                    		scalar pval = chi2tail(1, S0)
 					}
 					
est scalar score = S0
est scalar pval = pval
est local pcmd "xtvc"

/* EQUATION SOLVING BY BISECTION METHOD - CONFIDENCE INTERVAL FOR SIGMA_U */
   
* SEEK THE UPPER BOUND FOR SIGMA_U
 
        scalar IMP = 0
        
        scalar NOT = 0
       	    	    
	  scalar p1  = sigma_u
		
	  qui replace `sqres' =  `qres'^2 / (p1^2 + sigma_e^2/`n')
  	  qui replace `Sqres' = sum(`sqres') if  `n' != .
  
  	  scalar SUMSQRES = `Sqres' in l
    	  scalar SUP = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2
		           
			if SUP > 0 {
				      scalar NOT = 1
			            scalar IMP = 1
			            scalar uppb = .
			            }
		           
      scalar p2  = sigma_u + 2  
					  			    	  		        	  		    
    	scalar STEP = p2
 
	while SUP < 0 & IMP != 1  & NOT != 1 {  
		    
		scalar p2 = p2 + STEP
		
					qui replace `sqres' =  `qres'^2 / (p2^2 + sigma_e^2/`n')
  		  			qui replace `Sqres' = sum(`sqres') if  `n' != .
  
  		  		    scalar SUMSQRES = `Sqres' in l
    	  		    	    scalar SUP = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2	
                     
    	 if sigma_u == 0 | sigma_u < 1 {
    	            		    
         		if p2 > (sigma_u + 100 )   { 
                   					       scalar IMP = 1
                   					       scalar uppb = .
                     					     }
                       }
           
          if sigma_u > 1 {
                     
                       if p2 > (sigma_u * 100 )   {   
                   					       scalar IMP = 1
                   					       scalar uppb = .
                     					     }
                     	}
                     					             					     
                     }   
 

   if IMP != 1  & NOT != 1  {
 
   while  abs(p1-p2) >  1e-9  {
					
                 local t = (p1+p2)/2
          
             quietly {
          			replace `sqres' =  `qres'^2 / (`t'^2 + sigma_e^2/`n')
  		  		replace `Sqres' = sum(`sqres') if  `n' != .
  
  		  		scalar SUMSQRES = `Sqres' in l
    	  		      scalar St = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2
                                          
          			replace `sqres' =  `qres'^2 / (p1^2 + sigma_e^2/`n')
  		  	      replace `Sqres' = sum(`sqres') if  `n' != .
  
  		  		scalar SUMSQRES = `Sqres' in l
    	  		      scalar Sp1 = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2
        		 	}      
    		 	
	    	   		   
    		 if (St*Sp1) > 0 {
    		 		 	scalar p1 = `t' 
 					}
 							
 		  if (St*Sp1) < 0 {
    	   		             scalar p2 =  `t' 
    		 		       }
    		 	   }	
   		
	           scalar uppb =  p1
        }
        	 
* SEEK THE LOWER BOUND FOR SIGMA_U
      
  if NOT != 1 {

        local c 0
		scalar p1  = sigma_u
		scalar p2  = 0
 
   while  abs(p1-p2) >  1e-9  {

   		 		 local c = `c' + 1

				local t  = (p1+p2)/2
                  
             quietly {
 
          			replace `sqres' =  `qres'^2 / (`t'^2 + sigma_e^2/`n')
  		  		replace `Sqres' = sum(`sqres') if  `n' != .
  
  		  		scalar SUMSQRES = `Sqres' in l
    	  		      scalar St = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2
                                          
          			replace `sqres' =  `qres'^2 / (p1^2 + sigma_e^2/`n')
  		  		replace `Sqres' = sum(`sqres') if  `n' != .
  
  		  		scalar SUMSQRES = `Sqres' in l
    	  		      scalar Sp1 = ( ( SUMSQRES - (`m'-1) )^2 / (2*(`m'-1)) ) - chi2
        		 	}         
    		 	
    		 if (St*Sp1) > 0 {
    		 		      scalar p1 =  `t'  
 					}
 							
 		  if (St*Sp1) < 0 {
    	    		             scalar p2 =  `t' 
    		 		       }
         }	
   		
   			if abs(p1) < 1e-5 {
   			              scalar p1 = 0
   			              }
   			              
	         scalar lowb =  p1
          est scalar suuppb = uppb
          est scalar sulowb = lowb   
      }
 else {
          scalar lowb =  0
          est scalar suuppb = uppb
          est scalar sulowb = lowb   
       }

 
/* SET FORMAT  */

local fmt = "%1.0f" 
                
  if "`h0'" != ""  {
                      local fmt = "%3.2f"
                     }
 
/* DISPLAY RESULTS */

 		noi di _n in smcl in gr "{hline 13}{c TT}{hline 47}"
		noi di in smcl in gr  _col(5) %8s abbrev("`dep'",8) _col(14) in gr "{c |}" _col(20) "ML Estimate" _col(36) in gr "[" "`level'" "% Conf. Interval]"     
 		noi di in smcl in gr "{hline 13}{c +}{hline 47}"
		noi di in smcl in gr   _col(5) in gr "/sigma_u"  _col(14) in gr "{c |}" _col(22)in y %9.0g  sigma_u  _col(35) %9.0g lowb _col(47) %9.0g uppb    
 		noi di in smcl in gr "{hline 13}{c BT}{hline 47}"
 		noi di in smcl in gr "Score test of sigma_u=" in y `fmt'  PTEST  in gr ": chi2(1)= " in y %3.2f S0  in gr " Prob>=chi2 = " in y %4.3f  pval 
end


