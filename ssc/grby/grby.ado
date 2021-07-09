*! version 1.0  22 Sep 2003 N.Orsini & M.Bottai  
*! version 2.0  04 Apr 2004 N.Orsini & M.Bottai (only changed help file)

program define grby
version 7


syntax varlist (min=2 max=3) [if] [in] [, MEans CI(string) COnnect NUmbers Format(string) SHading(integer 1) /*
					*/ YScale (numlist max=2) YLine(string) Vlabel V1label V2label /*
					*/ Title(string) SAving(string)]

preserve

		/* to use the option if/in */
	
			marksample touse, strok novarlist

		/* assign a progressive number to variables */
			 
             	parse "`varlist'" , parse(" ")

			tempvar yvar xvar1 

			qui gen  `yvar' = `1'
		 	qui gen  `xvar1' = `2'
	
		/* check option graph connect */

		if  "`connect'"  != "" { 
				if  "`means'"  == "" { 
							di in red "specify both the option means and ci(##)"
								exit 198
								} 
						}

		/* check significance level for means */

		if  "`ci'"  != "" { 
					if  "`means'"  == "" { 
							di in red "specify the option means too"
								exit 198
								} 
					
					if `ci' <10 | `ci' >99 { 
								di in red "ci() invalid"
								exit 198
								} 

					local level1  `ci'
					local level2 = `level1' * 0.005 + 0.50
					} 						

		/* check variable label */

			if "`vlabel'" != ""  {
				local lb: variable label `1'
				local lb1: variable label `2'
				}
		 

			if "`3'" != ""  {
				tempvar xvar2
				qui gen  `xvar2' = `3'	
				
					if "`vlabel'" != ""  {
						local lb2: variable label  `3'
						}
				}
 
		/*  extract value label xvar1 */

			if "`v1label'" != ""  {
			 
			 	local vlb1: value label `2'
				tempvar last1
				sort `2'
				qui by `2':  gen byte `last1' = 1 if _n==_N  & `touse'
			 
				local s 1
				local i 1

					while `s'<=_N {
			 		 
						if `last1'[`s'] == 1 {
						 
							local x =`2'[`s']
					 						 
 							local labx1: label `vlb1' `x' 
							local labx1`i' = abbrev(`"`labx1'"',7)
								 
							local i = `i' + 1
							}

					local s= `s' + 1
	 				}
				}
 			 
			/*  extract value label xvar2 */

			if "`v2label'" != ""  {
			
				if "`3'" == ""  {
					di in red "specify the second variable"
					exit 198
					}

			 	local vlb2: value label `3'
				tempvar last2
				sort `3'
				qui by `3':  gen byte `last2' =1 if _n==_N  & `touse'
				 
				local s 1
				local j 1

					while `s'<=_N {
			 			 
						if `last2'[`s'] == 1 {
						 
							local x=`3'[`s']

 						 		local labx2: label `vlb2' `x'  
								local labx2`j' = abbrev(`"`labx2'"',12)
							 
						 
							local j = `j' + 1
							}

					local s= `s' + 1
	 				}
				}

		/* check the format */

           		if "`format'"=="" { 
				 		if "`means'" != ""  {local fmt  "%3.2f"
								}
							else { local fmt  "%6.0g"	
								}
						} 	
            	else { 
				local fmt "`format'"
			} 
  

		/* check the yline */

           		if "`yline'" != "" { 
			             	local linea "`yline'"
						} 
		 	
		/* check the shading */

			if `shading' < 0 | `shading' > 4 {
 
            		di in red "specify a shading from 0 to 4"
                        exit 198
				} 	

			
           		if "`shading'" == "" { 
            		local sh = 2
				} 	
            		else { 
				local sh = `shading' 
			} 

 
	/* some useful information about the variables */

		tempname arn amin amax crn cmin cmax
	 
			qui tab `xvar1' if `touse', matrow(B)  
			scalar arn = rowsof(B)
  			qui sum `xvar1' if `touse', mean
			scalar amin = r(min)
			scalar amax = r(max)

		if "`xvar2'" != ""  {
			qui tab `xvar2' if `touse', matrow(D)  
			scalar crn = rowsof(D) 
			qui sum `xvar2' if `touse', mean
			scalar cmin = r(min)	
			scalar cmax = r(max)
			}
		else  { 
			scalar crn = 1
			}
	
 	
	tempname max min

	 
	/* calculate sum or mean of depvar for each covariate pattern */

	local i 1
	local j 1
	local t 0 

	tempname stop`i'`j' punto`i'`j' sum`i'`j'
	
	while `j'  <= crn  {

			if "`xvar2'" != ""  {
			local nvb`j' = D[`j',1]
			}

			while `i'  <= arn  {
	              
					if "`xvar2'" != ""  {
				 		qui sum `yvar' if `xvar2'==D[`j',1] & `xvar1'==B[`i',1] & `touse' 
						}
					else { qui sum `yvar' if `xvar1'==B[`i',1] & `touse' 	
						}
			 
			  		if "`means'" != ""  {
								
								if r(N)== 0  { 
								 	scalar stop`i'`j' = 1
									scalar punto`i'`j' = 0 
									}
							
								if r(N)== 1 { 
								
									if "`ci'" != "" {
										scalar sum`i'`j' = r(mean)
										scalar stop`i'`j' = 1
										scalar punto`i'`j' = 1
										local t = `t' + 1	
											}
									else {
										scalar stop`i'`j' = 0
										scalar punto`i'`j' = 0
										scalar sum`i'`j' = r(mean)
										local t = `t' + 1	
										}
									
									}

								if r(N)!= 0 & r(N) != 1 {

										scalar stop`i'`j' = 0
										scalar punto`i'`j' = 0
										scalar sum`i'`j' = r(mean)
										local t = `t' + 1	
										}

								if "`ci'" != "" & stop`i'`j' != 1 { 
						
									scalar ci`i'`j' = r(sd)*(invnorm(`level2')/sqrt(r(N)))								
									scalar lowb`i'`j' = r(mean)- ci`i'`j'
									scalar uppb`i'`j' = r(mean)+ ci`i'`j'  
											 
											}
								}
					else { 

							if r(N)== 0  { 
									scalar punto`i'`j' = 0
								 	scalar stop`i'`j' = 1
									}

							if r(N)== 1  { 
									scalar punto`i'`j' = 0
									scalar stop`i'`j' = 0
									scalar sum`i'`j' = r(sum)
									local t = `t' + 1	
									}

								else  { 
									scalar stop`i'`j' = 0
									scalar punto`i'`j' = 0
									scalar sum`i'`j' = r(sum)
									local t = `t' + 1
									}
							}
								
					if `j' == 1  { 
							local nv`i' = B[`i',1]
							}
			
		
			if "`means'" == "" & "`ci'" == ""  { 	   
	
				if stop`i'`j' == 0 & punto`i'`j' == 0  | stop`i'`j' == 0 & punto`i'`j' == 1 {  
					
						if  `t'  == 1  {   											
								scalar max = sum`i'`j'
 								scalar min = sum`i'`j'
				  			       		}
				  				
                              	if sum`i'`j' > max {   
                              	  	     scalar max = sum`i'`j'					 
                                     		        }
						
				
                              	if sum`i'`j' < min  {
                                    	scalar min = sum`i'`j'
										}
									}   
						}  						
			 			

			if "`means'" != "" & "`ci'" == "" { 

					if stop`i'`j' == 0 & punto`i'`j' == 0  | stop`i'`j' == 1 & punto`i'`j' == 1 {  
					

						if `t' == 1  {  											
								scalar max = sum`i'`j'
 								scalar min = sum`i'`j'
				  			       		}
				  				
                              	if sum`i'`j' > max {  
                              	  	     scalar max = sum`i'`j'					 
                                     		        }
						
				
                              	if sum`i'`j' < min  {
                                    	scalar min = sum`i'`j'
										}
					}
				}

			if "`means'" != "" & "`ci'" != "" & "`yscale'" == "" { 
				 
					if stop`i'`j' == 0 & punto`i'`j' == 0  {  
					
						if `t' == 1  {  	 										
								scalar max = uppb`i'`j'
 								scalar min = lowb`i'`j'
				  			       		}
				  				
                              	if uppb`i'`j' > max {
                              	  	     scalar max = uppb`i'`j'					 
                                     		        }
						
                              	if lowb`i'`j' < min  {
                                    	scalar min = lowb`i'`j'
										}
								}


				     if stop`i'`j' == 1 & punto`i'`j' == 1 {  
				
						if `t' == 1  {  											
								scalar max = sum`i'`j'
 								scalar min = sum`i'`j'
				  			       		}

						if sum`i'`j' > max {
                              	  	     scalar max = sum`i'`j'					 
                                     		        }
					
                              	if sum`i'`j' < min  {
                                    	scalar min = sum`i'`j'
										}
									}
						}

			if "`means'" != "" & "`ci'" != "" & "`yscale'" != "" { 

					if stop`i'`j' == 0 & punto`i'`j' == 0 | stop`i'`j' == 1 & punto`i'`j' == 1 {  
					
						if `t' == 1  {  											
								scalar max = sum`i'`j'
 								scalar min = sum`i'`j'
				  			       		}
				  				
                              	if sum`i'`j' > max {
                              	  	     scalar max = sum`i'`j'					 
                                     		        }
						
                              	if sum`i'`j' < min  {
                                    	scalar min = sum`i'`j'
										}
							
									}
				  			}

			 

			local i = `i' + 1
           		}
      local i 1
 
	local j = `j' + 1
	 
      }

  

	/* check the min and max value of the graph  */
	
 	tempvar min2 max2

			if "`yscale'" != ""  {	 

             			parse "`yscale'" , parse(" ")
					local min2 = `1'
					local max2 = `2'
				
					if `min2' > min    {	 
						di in red "specify a min value lowest than minimun value of yvar"
						exit 198
					}
					
					if `max2' < max    {	 
						di in red "specify a max value highest than maximum value of yvar"
						exit 198
					}
				
				}		
			else {
				local max2 = max
			  
				if "`ci'" == "" { 
							local min2 = 0
							}
						else { 
							local min2 = min	 
							}
				}
	/* control and cut upper and lower bound for means if option yscale is specified */
	
		local i 1
		local j 1
	
		if "`ci'" != "" & "`yscale'" != "" {	
		
			while `j'  <= crn  {
	
					while `i'  <= arn  {

					if stop`i'`j' != 1  { 

						if uppb`i'`j' > `max2' {
                              		       scalar uppb`i'`j' = `max2'					 
                                    		 	     }

						if lowb`i'`j' < `min2'  {
      	                              	scalar lowb`i'`j' = `min2' 
							       		}   
								}
									       		
 								local i = `i' + 1
								}
     		      			local i 1	
		      			local j = `j' + 1
    						}
					}
					
	/* re-assign a progressive number to variables */
			 
             	parse "`varlist'" , parse(" ")

	
	/* check saving  graph bar */

		if "`saving'" != ""  {
					gph open, saving(`saving')
					}		
		else {
			gph open
			}

	/* graph bar the sum of depvar for each covariate pattern */

		gph pen 1

			if "`title'" != ""  {
				gph text 1000 16000 0 0 `title'		
				}
		gph pen 2
			if "`vlabel'" != ""  {
				gph text 2300 16000 0 0  `lb'
				}
			else {
				gph text 2300 16000 0 0  `1'
				}
	 
		gph pen 1
		gph line 4000 4000 19000 4000 
		gph line 4000 3800 4000 4000 	
		
		local max3 = `max2'
		local max2 : display `fmt' `max2'
		gph text 4000 3500 0 1 `max2'
		local max2 = `max3'
		
		gph line 19000 4000 19000 32000 
		gph line 19000 3800 19000 19000 
		
		local min3 = `min2' 
		local min2 : display `fmt' `min2' 
		gph text 19000 3500 0 1 `min2'
		local min2 = `min3' 
		
		gph pen 2

		if "`vlabel'" != ""  {
				gph text 20500 4000 0 1 `lb1'		
				}
			else {
				gph text 20500 4000 0 1 `2'
				}

		if "`xvar2'" != ""  {
		
				if "`vlabel'" != ""  {
							gph text 22000 4000 0 1 `lb2'	
							}
						else {
							gph text 22000 4000 0 1 `3'
							}	 
					}

	/* to share the available space */
 
		tempname  sv3 sv2 sv4 sv5 sv6 sv7 sv8 sv9 sv10 sv11
		
 		scalar sv3 = 28000 / crn      	
		scalar sv2 = sv3 / (arn + 2)
	
		scalar sv10  = (28000 - sv2)/crn
		scalar sv11 = sv10 / (arn + 1)
	
	  	scalar sv4 = (sv11 * arn)/2
 		scalar sv5 = sv11 / 2
 		scalar sv6 = 4000 + sv11	
 		scalar sv7 = sv6 + sv5
 		scalar sv8 = (sv10 - sv11)/2
		scalar sv9 = 4000 + sv11 + sv8
	
	/* to convert data in coordinates  */
	
  		local ay = -(19000 - 4000)/ (`max2' - `min2')
		local by = 19000
     		local ax = 28000  
		local bx = 4000
	 
		local x1 = 4000	
		local y2 = 19000
		local x2 = 4000 + sv11  

		local i 0
      	local j 1
		local intex = sv7
		local intexb = sv9	
		 
	/* to screen yline */

		if "`yline'" != "" { 
		
			if `linea' > `max2' | `linea' < `min2'  {
					di in r "specify another value for yline (between the lowest and the highest value)"
					exit 198
									}
									
			             	local yline1 = `linea'
			             	local yline2 = `yline1' -  `min2'	
			             	local yline3 = `ay' * `yline2' + `by' 
			             	gph pen 9 
			             	gph line `yline3' 4000 `yline3' 32000
			             	gph pen 1
			             	gph text `yline3' 3500 0 1 `linea'
			             	gph line `yline3' 3800 `yline3' 4000
			             	gph pen 2
						} 

	/* to screen graph bar  */
	
	while `j'  <= crn  {
			
              	while `i'  <= arn  {     
				
				if `i' == 0   { 
							local x1 = `x1' + sv11	
						      local x2 = `x2' + sv11
					 	  }					
				 else {  
				 	 	if stop`i'`j' == 0 | punto`i'`j' == 1 { 
						 	 
							local y =  sum`i'`j'
							local y3 = `y' - `min2'	
					 		local y1 = `ay' * `y3' + `by' 

									 }

					if "`ci'" != ""  {   
						
								if stop`i'`j' != 1  { 
									 
									local ub = uppb`i'`j'  - `min2'
			      			 		local ub2 = `ay' * `ub' + `by' 
									local lb = lowb`i'`j' - `min2'
			      			 		local lb2 = `ay' * `lb' + `by'
							 	}

						if "`connect'" != ""  {   

								if `i' > 1  {  
								
									if stop`i'`j' == 1 & punto`i'`j' == 1 | stop`i'`j' == 0 & punto`i'`j' == 0 {  
										 
										local i = `i' - 1
									
									if stop`i'`j' == 1 & punto`i'`j' == 1 | stop`i'`j' == 0 & punto`i'`j' == 0 {  
									 
							 			local e =  sum`i'`j'
										local e3 = `e' - `min2'	
					 					local e1 = `ay' * `e3' + `by' 
									 						   }
										local i = `i' + 1
															}
										}
									    }
								}
						 
					if "`ci'" == "" { 
	
								if stop`i'`j' != 1  {	
							    			   gph box `y1' `x1' `y2' `x2' `sh'
											}
								}
						else {    
								if stop`i'`j' == 0   {
							      
	  						       gph pen 3
							       gph line  `ub2' `intex' `lb2' `intex'
							 	 gph pen 2
								 gph point `y1' `intex' 225 4	
										
												}

								if "`connect'" != "" { 

									if `i' >= 2  {  
								
									if stop`i'`j' == 1 & punto`i'`j' == 1 |  stop`i'`j' == 0 & punto`i'`j' == 0  {  
									
										local i = `i' - 1
									
									if stop`i'`j' == 1 & punto`i'`j' == 1 |  stop`i'`j' == 0 & punto`i'`j' == 0 {  
									       
										 gph pen 9
							 			 gph line  `y1' `intex' `e1' `intexprec'
															
													 }
										local i = `i' + 1
								 						     
													}					 
											 }			
										}
			
								
						   	if stop`i'`j' == 1 & punto`i'`j' == 1 { 
										 gph pen 2
										 gph point `y1' `intex' 275 7	
										 
													}
 		
							}
	
					 gph pen 1
					 local y1 = `y1' - 120
					 
					 local intex = `intex' 
				
				if stop`i'`j' != 1 | punto`i'`j' == 1 {

				   	 local y : display `fmt' sum`i'`j'
				 	  	}
		

				if "`numbers'" != "" { 
				
					if stop`i'`j' != 1 | punto`i'`j' == 1 { 
					
							if "`ci'" != ""   { 		
							  	   	 gph text `y1' `intex' 0 1 `y'  
													}
								else {		
									 gph text `y1' `intex' 0 0 `y'  								
									}
									}
								}
								
					if "`v1label'" != ""  {
							gph text 20500 `intex' 0 0 `labx1`i''
							}
					else  {
						gph text 20500 `intex' 0 0 `nv`i''
						}

 					 gph pen 2
				  	 local x1 = `x1' + sv11  
					 local x2 = `x2' + sv11 
				       local intexprec = `intex'								
				   
					 local intex = `intex' + sv11
				    	 
 		 			 }
			 
			local i = `i' + 1
           		}
	
      local i 0
	gph pen 1
	
		if "`xvar2'" != ""  {

				if "`v2label'" != ""  {
							gph text 22000 `intexb' 0 0 `labx2`j''
							}
						else  {
							gph text 22000 `intexb' 0 0 `nvb`j''
							}
				}

	gph pen 2

	local j = `j' + 1
	
	 	local intex = `intex' + sv11
		 
	 	local intexb = `intexb' + sv10  
      }

	
      gph close

scalar drop _all

end

 
