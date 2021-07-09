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
		
