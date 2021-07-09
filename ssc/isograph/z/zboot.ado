	program zboot, rclass sortpreserve   
			version 10.0   
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
			

