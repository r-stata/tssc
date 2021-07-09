
	capture which oaxaca
	if _rc==111 ssc install oaxaca
	capture which apcd
	if _rc==111 ssc install apcd
	capture which apch
	if _rc==111 ssc install apch
	
  
     
 program define apcgo, rclass     
    version 11.0      
      
syntax [anything] [fw aw pw iw] [if] [in], ///     
    [age(varname numeric) period(varname numeric) ///      
      offset(varname numeric) exposure(varname numeric) gap(varname numeric)  rep(real 1) *]     
    
        
 marksample touse                          
    markout `touse' `age' `period' `offset' `exposure'                          
           tempvar explained unexpx diffx toto gap1  
        
qui{    
noi di "1" _c
if "`weight'" == ""   gen `toto' = 1    
else gen `toto' `exp'  if `touse'      
forval i=1 2 to `rep' {     
 preserve     
 bsample     
 if mod(`i',50)==0 noi di `i' _c    
     
  di "start `period' `age'"    
  su `period' if `touse'    
 gen `explained'=.      
 gen `unexpx'=.      
 gen `diffx'=. 
 gen `gap1'=1-`gap'
 di r(min)    
 local start=r(min)    
 local end=r(max)    
 su `period' if `period'>`start'    
 local interval=r(min)-`start'    
 su `age' if `touse'    
 local young=r(min)    
 local old=r(max)    
    
qui {      
forvalues ii=`start'(`interval')`end'{              
forvalues jj=`young'(`interval')`old'{             
   oaxaca `anything'   [w =`toto'] if   `period'==`ii'  & `age'==`jj' & `touse'    , by(`gap1')  pooled     noisily   nose `options'    
	mat  A=e(b)           
replace `explained'=A[1,4]   if   `period'==`ii'  & `age'==`jj'        
replace `unexpx'=A[1,5]   if   `period'==`ii'  & `age'==`jj'       
replace `diffx'=A[1,3]   if   `period'==`ii'  & `age'==`jj'      
 }                      
 }                      
}      

capture apctlagb `explained'  [w =`toto'] if `touse', age(`age') period(`period')    
mat std1=r(table)
mat std1=std1*std1'
mat std1=vecdiag(std1)'
if `i'==1 { 
	mat sd1=std1 
	mat bs1=r(table)
	}
	else {
	mat sd1=(std1+sd1)
	mat  bs1 =(r(table)+bs1)
    }
capture apctlagb `unexpx'  [w =`toto'] if `touse', age(`age') period(`period')    
mat std2=r(table)
mat std2=std2*std2'
mat std2=vecdiag(std2)'
if `i'==1 { 
	mat sd2=std2 
	mat bs2=r(table)
	}
	else {
	mat sd2=(std2+sd2)
	mat  bs2 =(r(table)+bs2)
    }
 
capture apctlagb `diffx'  [w =`toto'] if `touse', age(`age') period(`period')    
mat std3=r(table)
mat std3=std3*std3'
mat std3=vecdiag(std3)'
if `i'==1 { 
	mat sd3=std3 
	mat bs3=r(table)
	}
	
	else {
	mat sd3=(std3+sd3)
	mat  bs3 =(r(table)+bs3)
    }


if mod(`i',10)==0 noi di "+"  _c    
 restore     
}    
   
}


** explained
capture mat drop table     
 capture mat drop tos 
 
 mat meanbs1=bs1/`rep'
 mat bssq1=vecdiag(meanbs1*meanbs1')'
 mat sdmean1=sd1/`rep'
 mat Vbs1=sdmean1-bssq1

 
 local en= rowsof(bs1)    
 forval i=1 2 to  `en' {    
 loc lb=meanbs1[`i',1]-(Vbs1[`i',1])^0.5*2    
 loc ub=meanbs1[`i',1]+(Vbs1[`i',1])^0.5*2     
 mat def rtab=meanbs1[`i',1],`lb', `ub'    
 mat def table=(nullmat(table)\rtab)    
 }    
 

 
 
 local names : rownames meanbs1    
 local vrnam : colnames r(table)    
 matrix rownames table=`names'    
     
 matrix colnames table="explained" "[Cl_L" "Cl_U]" 
 if table[1,1]!=. matlist table, format(%9.3f)    
 return matrix explained=table    
 capture mat drop bs1     
 capture mat drop table     
 capture mat drop meanbs1     
 capture mat drop sdmean1     
 capture mat drop cl     
 capture mat drop sl     
 capture mat drop dis     
 capture mat drop Vbs1     
 capture mat drop dsl     
 capture mat drop sd1    
 capture mat drop std1    
 
 

 ** unexplained    
     
 mat meanbs2=bs2/`rep'
 mat bssq2=vecdiag(meanbs2*meanbs2')'
 mat sdmean2=sd2/`rep'
 mat Vbs2=sdmean2-bssq2

 
 local en= rowsof(bs2)    
 forval i=1 2 to  `en' {    
 loc lb=meanbs2[`i',1]-(Vbs2[`i',1])^0.5*2    
 loc ub=meanbs2[`i',1]+(Vbs2[`i',1])^0.5*2     
 mat def rtab=meanbs2[`i',1],`lb', `ub'    
 mat def table=(nullmat(table)\rtab)    
 }  
 

 
 
 local names : rownames meanbs2    
 local vrnam : colnames r(table)    
 matrix rownames table=`names'    
     
 matrix colnames table="unexp" "[Cl_L" "Cl_U]" 
  matlist table, format(%9.3f)    
 return matrix unexp=table    
 capture mat drop bs2     
 capture mat drop table     
 capture mat drop meanbs2     
 capture mat drop sdmean2     
 capture mat drop cl     
 capture mat drop sl     
 capture mat drop dis     
 capture mat drop Vbs2     
 capture mat drop dsl     
 capture mat drop sd2    
 capture mat drop std2    
 

 
** difference    
     
 mat meanbs3=bs3/`rep'
 mat bssq3=vecdiag(meanbs3*meanbs3')'
 mat sdmean3=sd3/`rep'
 mat Vbs3=sdmean3-bssq3

 
 local en= rowsof(bs3)    
 forval i=1 2 to  `en' {    
 loc lb=meanbs3[`i',1]-(Vbs3[`i',1])^0.5*2    
 loc ub=meanbs3[`i',1]+(Vbs3[`i',1])^0.5*2     
 mat def rtab=meanbs3[`i',1],`lb', `ub'    
 mat def table=(nullmat(table)\rtab)    
 }  
 

 
 
 local names : rownames meanbs3    
 local vrnam : colnames r(table)    
 matrix rownames table=`names'    
     
 matrix colnames table="gap" "[Cl_L" "Cl_U]" 
  matlist table, format(%9.3f)    
 return matrix gap=table    
 capture mat drop bs3    
 capture mat drop table     
 capture mat drop meanbs3     
 capture mat drop sdmean3     
 capture mat drop cl     
 capture mat drop sl     
 capture mat drop dis     
 capture mat drop Vbs3  
 capture mat drop dsl     
 capture mat drop sd3    
 capture mat drop std3    
 
 
end    
    
    
