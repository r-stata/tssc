


capture program drop msum
program msum,rclass
version 14
syntax varlist(min=1 max=1)  [if]  [in] [, BY(varlist max=1) Detail  Missing]

marksample touse, strok novarlist
tokenize `varlist'
local myvar "`1'"
capture mat drop M
capture mat drop S
capture mat drop Q

   	
	if "`by'"==""  {
		    capture matrix drop M
		    mat M=J(1,1,.)
			mat colnames M=mean
			capture matrix drop S
			mat S=J(1,1,.)
			mat colnames S="sd"
			if "`detail'"=="detail" {
				sum `1' if `touse' , d
			}
		    if "`detail'"=="" {
				sum `1' if `touse'
				qui sum `1' if `touse' , d
			}
			mat M[1,1]=r(mean)
			mat S[1,1]=r(sd)
			local mylist "1 5 10 25 50 75 90 95 99"
			capture matrix drop Q
			mat Q=J(9,2,.)
			mat colnames Q= quantile `1'
			local i=1
			foreach x of local mylist  {
				mat Q[`i',1]=`x'
				mat Q[`i',2]=r(p`x')
				local i= `i' + 1
			} 
display _newline(1)"***** Matrix for the mean *****"			
			mat list M
display _newline(1)"***** Matrix for the standard deviation *****"			
			mat list S
display _newline(1)"***** Matrix for the quantiles *****"
			mat list Q
			return mat mean=M
			return mat sd=S
			return mat quantile=Q
	}
	
	if "`by'"!="" {
		if "`misssing'"=="missing" {
					tab `by', matrow(R) missing
		}
		
		if "`misssing'"=="" {
					tab `by', matrow(R) 
		}
		
		local rn=rowsof(R)
		capture matrix drop M
		mat M=J(`rn',1,.)
		mat colnames M=mean
		capture matrix drop S

		mat S=J(`rn',1,.)
		mat colnames S="sd"
		
		mat Q0=(1 \ 5\  10\  25\  50\  75\  90\  95\  99)
		mat colnames Q0="quantile"
		mat list Q0
		capture mat drop Q
		mat Q=Q0
		foreach x of numlist 1/`rn' {
			display _newline(3)"********** `myvar'= `x' **********"
			capture matrix drop Q`x'
			mat Q`x'=J(9,1,.)
			local Qnamenum=R[`x',1]
			mat colnames Q`x'= "`1'_`by'=`Qnamenum'" 
			if "`detail'"=="detail" {
			sum `1' if  `touse'  & `by'==R[`x',1], detail
			}
			if "`detail'"=="" {
			sum `1' if  `touse'  & `by'==R[`x',1]
			}
			mat M[`x',1]= r(mean)
			mat S[`x',1]= r(sd)
			local mylist "1 5 10 25 50 75 90 95 99"
			qui sum `1' if  `touse'  & `by'==R[`x',1], d
			local i=1
			foreach j of local mylist  {
				mat Q`x'[`i',1]=r(p`j')
				local i= `i' + 1
			} 
	
			mat Q= Q,Q`x'

			
		}
display _newline(1)"***** Matrix for the mean *****"		
		mat list M
display _newline(1)"***** Matrix for the standard deviation *****"		
		mat list S
		return mat mean=M
		return mat sd=S
		
display _newline(1)"***** Matrix for the quantiles *****"	
        mat list Q	
		return mat quantile=Q	
		
	}
/*	
	if "`nolabel'"=="nolabel"  & "`missing'"=="" {
		    tab `1' if `touse', matcell(F) nolabel 
	}
	if "`nolabel'"==""  & "`missing'"=="missing" {
			tab `1' if `touse', matcell(F) missing 
	}	
	
	if "`nolabel'"==""  & "`missing'"=="" {
		tab `1' if `touse', matcell(F) 
	}




	local NN=r(N)
	local rn=rowsof(F)
	mat P=J(`rn',1,.)
	foreach r of numlist 1/`rn' {
	    mat P[`r',1]=(F[`r',1]/`NN')*100
	}
	
	return mat frequency=F 
	return mat percent=P
*/


end

