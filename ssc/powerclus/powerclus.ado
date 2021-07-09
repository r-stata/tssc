*! version 3.0.0 JGarrett 13Dec02  (update to "sampclus)
/* Program to calculate sample size for cluster designs            */
/* Follows power command                                           */
/* Form:  powerclus, obsclus(#) numclus(#) rho(#)                  */
  
program define powerclus
  version 13.0
  syntax [, OBSclus(int 0) NUMclus(int 0) RHo(real 0)] 
  if r(N1)==.  {
    disp in red "You must run the power command before powerclus"
    exit
    }
  if `obsclus'~=0 & `numclus'~=0 {
    #delimit ;
    disp in red _n(1) "Only select one: " in yel "obclus(#)"
       in red " or " in yel "numclus(#)";
    #delimit cr
    exit
    }
  if `obsclus'==0 & `numclus'==0 {
    #delimit ;
    disp in red _n(1) "Must select one: " in yel "obsclus(#)"
       in red " or " in yel "numclus(#)";
    #delimit cr
    exit
    }
  if `rho'<0 | `rho'>1 {
    disp in red "rho must be between " in yel "0" in red /*
      */  " and " in yel "1"
    exit
    }

* Set up local variables for all calculations
  local n1=r(N1)
  local n2=r(N2)
  if `n2'==. {
    local n2=0
    }
  local ratio=`n2'/`n1'
  local obs=`obsclus'
  local numcl=`numclus'
  local rh=`rho'

* Calculate numclus and sample sizes (obsclus and rho specified)
  if `obsclus'>0 {
    local newn1=`n1'*(1+`rh'*(`obs'-1))
      if mod(`newn1',1)~=0 {
         local newn1=int(`newn1')+1
         }
    if `ratio'>0 {
       local newn2=`newn1'*`ratio'
       }
    if `ratio'==0 {
       local newn2=0
       }
    local totaln=`newn1'+`newn2'
    if mod(`totaln',`obs')~=0 {
       local numcl=int(`totaln'/`obs')+1
         }
       else {
         local numcl=int(`totaln'/`obs')
        }
    }

* Calculate obsclus and sample sizes (numclus and rho specified)
  if `numclus'>0 {
    if `numcl'<=(`n1'*`rh')+(`n2'*`rh') {
      local numcl=(`n1'*`rh')+(`n2'*`rh')
      local numcl=int(`numcl')+1 
      #delimit ;
        disp _n(1) in bl "For this rho, the minimum number of clusters"
          " possible is: " in yellow `numcl' ;
      #delimit cr
      exit
      } 
    #delimit ;
      local obs=(`n1'-(`n1'*`rh')+`n2'-(`n2'*`rh')) / 
                (`numcl'-(`n1'*`rh')-(`n2'*`rh')) ;
    #delimit cr
    local obs=round(`obs',1)  
    local newn1=`n1'*(1+`rh'*(`obs'-1))
      if mod(`newn1',1)~=0  {
         local newn1=int(`newn1')+1
         }
    if `ratio'>0 {
         local newn2=`newn1'*`ratio'
         }
    if `ratio'==0 {
         local newn2=0
         }
    local totaln=`newn1'+`newn2'
    if mod(`totaln',`numcl')~=0 {
       local newobs=int(`totaln'/`numcl')+1
         }
       else {
        local newobs=int(`totaln'/`numcl')
        }
    if `newobs'~=`obs' {
      local obs=`newobs'
      local newn1=`n1'*(1+`rh'*(`obs'-1))
      if mod(`newn1',1)~=0  {
         local newn1=int(`newn1')+1
         }
      if `ratio'>0 {
         local newn2=`newn1'*`ratio'
         }
      if `ratio'==0 {
         local newn2=0
         }
    local totaln=`newn1'+`newn2'
    if mod(`totaln',`obs')~=0 {
       local numcl=int(`totaln'/`obs')+1
         }
       else {
         local numcl=int(`totaln'/`obs')
        }
      }
    }



* Display results
  disp in green _n(1) "Sample Size Adjusted for Cluster Design"
  disp in green _n(1) "   n1 (uncorrected) = " in yel `n1'
  if `n2'>0 {
    disp in green       "   n2 (uncorrected) = " in yel `n2'
    }
  disp in green _n(1) "   Intraclass correlation     = " in yellow  `rh'
  disp in green _n(1) "   Average obs. per cluster   = " in yellow  `obs'
  disp in green       "   Minimum number of clusters = " in yel `numcl'
  disp in green _n(2) "   Estimated sample size per group:"
  disp in green _n(1) "      n1 (corrected) = " in yel `newn1'  
  if `n2'>0 {
    disp in green "      n2 (corrected) = " in yel `newn2'
    }

end
