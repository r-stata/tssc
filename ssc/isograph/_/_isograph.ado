	program _isograph, rclass sortpreserve  
	   
	version 10.0   
	syntax varlist(numeric ts) [aweight fweight pweight] [if] [in] ,  GENIso(string) GENLogitx(string)   
	 
	qui {  
	tempvar temprev xtemp lxtemp ltemprev ytemp lytemp rll y 
	tempname A B V 
	marksample touse  
	local revabc : word 1 of `varlist'  
	gen `temprev'= `revabc' if `touse'  
	*replace temprev = 0 if  temprev==. & `touse'  
	replace `temprev' = `temprev' +runiform()*.000001 if `touse'     
	  
	gen `geniso'=.  
	gen `genlogitx' =.  
	sort  `temprev'      
	tempvar toto  
	  
	if "`weight'" == ""  & `touse'    gen `toto' = 1  
	else gen `toto' `exp'  if `touse'    

	sort `temprev'  
	replace `temprev'=(`temprev'+`temprev'[_n+1]+`temprev'[_n+1])/3 if _n>1 & _n<_N
	 gen `xtemp' = sum(`toto') if  `touse'    
	 su `xtemp' [w =`toto']    if  `touse'    
	 replace `xtemp'=(`xtemp'/r(max)) if  `touse'    
	 su `xtemp' [w =`toto']    if  `touse'    
	 replace `xtemp'=((`xtemp'-r(min)/2)/r(max)) if  `touse'    
	 gen `lxtemp' =ln(`xtemp'/(1-`xtemp')) if  `touse'    
	 
	 gen `lytemp'=ln(`temprev')   
	 reg `lytemp'  `lxtemp'  [w =`toto']   if `touse' & abs(`lxtemp')<.25
	 mat C=e(b)
	 replace `lytemp'=`lytemp'-C[1,2] if  `touse'    
	 gen `ytemp'=exp(`lytemp') if `touse'      
	 
	 
	 replace `geniso' =`lytemp'/`lxtemp' if  `touse'    
	 replace `genlogitx' =`lxtemp' if  `touse'  
	} 
	end 
	