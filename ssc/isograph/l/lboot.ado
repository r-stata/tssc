	program lboot, rclass   
				version 10.0   
			syntax varlist(numeric ts)  [if] [in][,span(real 3)]  
			 marksample touse  
			 capture graph drop ga  
			 local revabc : word 1 of `varlist'  
			   preserve
				bsample
				*di "zboot `revabc' , span(`span')"
				zboot `revabc' , span(`span')
				mat def tesr=r(isograph)
				local msam=-`span'
				local nsam=`span'*4+1
				local i=1
				forvalues i=1 2 to `nsam' {
				*di `i'
				return scalar iso`i'=tesr[`i',2]
				}
			restore
 end  
			 
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
	
	program zboot, rclass sortpreserve   
			
			syntax varlist(numeric ts) [aweight fweight pweight] [if] [in] [, span(real 3)  ]
			 marksample touse  
			preserve  
			tempname A B V 
			tempvar Yvar  
			tempvar hw1
			tempvar Iso
			tempvar Lri
			tempvar rll
			tempvar Rll
			tempvar toto  
	qui{
		if "`weight'" == ""  & `touse'    gen `toto' = 1  
		else gen `toto' `exp'  if `touse'    
		su `toto'
			local revabc : word 1 of `varlist'  
			di "`revabc'"
			_isograph `revabc' , geniso(`Iso') genlogitx(`Lri')  
			gen `Yvar'=`Iso'*`Lri'
			su   `Yvar' 
			gen `rll'=round(`Lri',.5) if  `touse'
			su `Lri'
			replace `rll' =. if abs(`rll')>`span' &  `touse'
			ta `rll' 
			gen `Rll'=`rll'
			mat `A'=J(r(r),4,.)
			mat li `A'
			local i=0
			levelsof `rll', local(levels)
				foreach l of local levels {
				
				  local i=`i'+1
				
				  di `rll'  "L:" `l' "RLL" `Rll'
				  su `Yvar' if  `l'==`Rll'
				  if `r(N)'!=0 {
				  reg `Yvar' `Lri' [pw =`toto']   if `l'==`Rll' &  `touse' ,  nocons
				  mat `B'=e(b)
				  mat `V'=e(V)
				  mat `A'[`i',1]=`l'
				  mat `A'[`i',2]=`B'[1,1]
				  mat `A'[`i',3]=`B'[1,1]-2*sqrt(`V'[1,1])
				  mat `A'[`i',4]=`B'[1,1]+2*sqrt(`V'[1,1])
				  }
				  }
				return matrix isograph=`A'
	}			
			end
			
		
			 		

		program isoboot, rclass   
			version 10.0   
			syntax varlist(numeric ts) [aweight fweight pweight] [if] [in][, repeats(real 50) seed(real 123) span(real 3)]
					 marksample touse  
			 local revabc : word 1 of `varlist' 
			 tempvar toto  
			qui{
			*di `span'
			loc mspan=-`span'
			loc pspan=`mspan'+0.5
			loc cn=1
			tempname A
			preserve
			if "`weight'" == ""  & `touse'    gen `toto' = 1  
			else gen `toto' `exp'  if `touse' 
			local listy=" "
			*di "`listy'"
			local nsam=`span'*4+1
			mat `A'=J(`nsam',4,.)

			*di `nsam'
			forval i=1 2 to `nsam' {
			*di `i'
			loc listy="`listy'iso`i'=r(iso`i') "
			}
			}
			simulate `listy', reps(`repeats') seed(`seed'): lboot `revabc', span(`span')
			forval t=`mspan' `pspan' to `span'{
			qui su iso`cn'
			*di `cn'
			mat `A'[`cn',1]=`t'
			mat `A'[`cn',2]= r(mean)
			mat `A'[`cn',3]=r(mean)-2*(r(sd))
			mat `A'[`cn',4]=r(mean)+2*(r(sd))
			local cn=`cn'+1
			}
			
			restore
			return matrix isograph=`A'
		end
		


