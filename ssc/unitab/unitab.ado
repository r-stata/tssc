*! version 1.0  22 Sep 2003 N.Orsini & M.Bottai  
*! version 2.0  26 Sep 2003 N.Orsini & M.Bottai  
*! version 3.0  04 Apr 2004 N.Orsini & M.Bottai (only changed help file)

program define unitab
version 8.1

	 syntax varlist (min=1) [if] [in] [, Level(integer $S_level) /*
           			      */ Format(string) Categorical(varlist) EXact ]
	 
		// check the format  

           		if "`format'"=="" { 
            				local fmt  "%7.3f"
						} 	
            			else { 
						local fmt "`format'"
						} 

		// to use the option if/in  
	
			marksample touse, strok novarlist

		// assign a progressive number to continuous independent variables  
			 
             	parse "`varlist'" , parse(" ")

		// check significance level  

			if `level' <10 | `level'>99 { 
							di in red "level() invalid"
							exit 198
							} 

	 	local l1  `level'
		local level = `level' * 0.005 + 0.50

		preserve

	      // check how dependent variable is coded  
		
          	qui tab `1' if `touse', matrow(r)
	
		tempvar  dv 
		qui gen int `dv' = `1' if `touse'

  	      if r[1,1] != 0 {
			 		tempname MIN
				      qui sum `1' if `touse', mean
                   		scalar MIN = r(min)
                   		qui recode `dv' MIN = 0   if `touse'
			         } 
         
	// Display heading column of the univariate table    

	if "`categorical'" == "" & "`2'"=="" {
            di in red "specify at least one independent variable (continuous or categorical)"
            exit 198
		}
      else {
            di in g  "{hline 12}" _col(12) "{c TT}{hline 65}
     		di in g %8s abbrev("`1'",8) _col(13) "{ c |}" _col(10) %7s abbrev("`1'",4) "=" r[2,1] "(%)" _col(32)/*
 			      */ "Total(%)" _col(45) "OR" _col(50)"[`l1'% Conf. Interval]" /*
   	 			*/ _col(72)"p-value"
		}
	 	
	// for each continuous independent variable  

while "`2'"!="" {
			
			di in g"{hline 12}{c +}{hline 65}
			
			capture confirm string variable `2'

			if _rc==0 {
					noi di in red "nonnumeric variable `2' not allowed"
					exit 198
					}
				else { 
                 			tempvar iv
                		      qui gen int `iv' = `2' if `touse'
					}
                  
			qui tab `dv' if `iv'!=. & `touse' , matcell(p)
                 
			// Maximum likelihood estimation of odds ratio and confidence interval using logit command  

      		qui logit `dv' `iv'  if `touse', level(`l1')

			mat b = e(b)
      		mat vm = e(V)
      		mat v = vecdiag(vm)
			mat SE = sqrt(v[1,1])
                  local ab =  abs(b[1,1])/SE[1,1]
	 		local pval = (1- norm(`ab'))* 2 
		   

				noi di in g _col(1) %8s abbrev("`2'",8) _col(11)  /*
				*/ _col(13) "{c |}"  in y  _col(14) %8.0g p[2,1]  _col(20) "(" %2.0f p[2,1]/(p[1,1]+p[2,1])*100 ")"  /*
				*/ _col(27) %9.0f p[1,1]+p[2,1] "(100)"   /*
           			 */  _col(42)`fmt' exp(b[1,1])  /*
		 		*/  _col(51) `fmt' exp(b[1,1]-invnorm(`level')*SE[1,1])  /*
				*/_col(61) `fmt' exp(b[1,1]+invnorm(`level')*SE[1,1]) /*
                        */ _col(72) %6.3f   `pval' 			 
	                             		 
macro shift 
}

	
      // assign a progressive number to categorical independent variables  

	           	parse "`categorical'" , parse(" ")

	// for each categorical independent variable  

while "`1'" != "" {				
			di in g"{hline 12}{c +}{hline 65}
		
			capture confirm string variable `1'

			if _rc==0 {
					noi di in red "nonnumeric variable `1' not allowed"
					exit 198
					}
				else { 
                 			 tempvar iv
                			 qui gen int `iv' = `1' if `touse'
					}
		
			tempname NTOT BASE MAX EPV RN CN

      		qui sum `dv' if `iv'!=. & `touse',  mean
     			scalar NTOT = r(N) 
		      		
				if "`exact'" == "" {
					 qui tab `dv' `iv' if `touse', matcell(F) matcol(c) chi2
					scalar EPV=r(p)
					}
				else { 
                  		qui tab `dv' `iv' if `touse', matcell(F) matcol(c) exact 
                  		scalar EPV = r(p_exact)
					}

      		scalar RN = rowsof(F) 
      		scalar CN = colsof(F)

                  qui sum `iv', mean
                  scalar BASE = r(min)
                  scalar MAX = r(max)
		 		
			// Maximum likelihood estimation of odds ratio and confidence interval using logit command  

      		qui xi:logit `dv' i.`iv' if `touse', level(`l1')

			mat b = e(b)
      		mat vm = e(V)
      		mat v = vecdiag(vm)

			local i 1
      		local j 1


     			 while `i'  <= CN  {
		
				if `i' == 1 { 
						
				noi di in g _col(1) %8s abbrev("`1'",8) _col(11) c[1,`i'] /*
				*/ _col(13) "{c |}"  in ye %9.0g /*
				*/ _col(14) %8.0g F[2,`i'] _col(20) "(" %2.0f ( F[2,`i'] / (F[1,`i']+ F[2,`i']))*100 ")" _col(27) /*
           			 */ %9.0g F[1,`i']+ F[2,`i'] _col(35) "(" %2.0f (F[1,`i']+ F[2,`i'])/ NTOT*100 ")" _col(41) "    .    "  /*
		 		*/_col(51) "   .   "  /*
				*/_col(61) %9.6f "   .   " _col(73) %4.3f EPV
				} 

			else { 
				scalar SE`j' = sqrt(v[1,`j'])

				if F[2,`i'] != 0 {
					noi di in g  _col(11) c[1,`i'] /*
				 	*/ _col(13) "{c |}"  in ye %9.0g /*
					*/ _col(14) %8.0g F[2,`i'] _col(20) "(" %2.0f ( F[2,`i'] / (F[1,`i']+ F[2,`i']))*100 ")" _col(27) /*
        				*/ %9.0g F[1,`i']+ F[2,`i'] _col(35) "(" %2.0f (F[1,`i']+ F[2,`i'])/NTOT*100 ")" /*
					*/ _col(42)`fmt' exp(b[1,`j']) /*
					*/_col(51) `fmt' exp(b[1,`j']-invnorm(`level')*SE`j')   /*
					*/_col(61) `fmt' exp(b[1,`j']+invnorm(`level')*SE`j')

                              local j=`j'+1
					}
		      	  else {
					noi di in g  _col(11) c[1,`i'] /*
				 	*/ _col(13) "{c |}"  in ye %9.0g /*
					*/ _col(14) %8.0g F[2,`i'] _col(20) "(" %2.0f ( F[2,`i'] / (F[1,`i']+ F[2,`i']))*100 ")" _col(27) /*
        				*/ %9.0g F[1,`i']+ F[2,`i'] _col(35) "(" %2.0f (F[1,`i']+ F[2,`i'])/NTOT*100 ")" /*
					*/ _col(42) "    .    " /*
					*/_col(51) "    .    "   /*
  					*/_col(61) "    .    "
					}					

				}			

			local i = `i' + 1       
      		}
      		 
macro shift 
}

di in g"{hline 12}{c BT}{hline 65}

end



