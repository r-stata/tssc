*! Version 1.0   14 May 2003 N.Cox
*! Version 1.1   15 Oct 2003 N.Orsini
*! Version 1.2   26 Mar 2004 N.Orsini & R.Bellocco
*! Version 1.3   31 Mar 2004 N.Orsini 
*! Version 1.4   27 Nov 2004 N.Orsini

capture program drop pnrcheck
program pnrcheck, rclass

	version 8 

	syntax varname [if] [in] [, SAVEPnr(string) SAVEInd(string) DIsplay LISTWrong LISTMissing]

// CHECK THE OPTIONS
 
	if  "`savepnr'"  != "" { 
					local pnrname   "`savepnr'"	
					}
                          
	if  "`saveind'"  != "" { 
					local pnrind   "`saveind'"	
					}

// to use the option if/in 

marksample touse, strok novarlist

// CHECK THE STORAGE TYPE OF PNR

local sttype : type `varlist'   
local stcheck = substr("`sttype'",1,3)

if "`stcheck'" != "str"  {
				 // convert the pnr_variable from numeric to string
				 tempvar pnrnumb
 
				 qui tostring `varlist'  , generate(`pnrnumb')  format(%14.0f) 
				 local varlist = "`pnrnumb'"
				 }
				
// CHECK THE PNR VARIABLE

tempname CASE
		
	capture 
		assert length(trim(`varlist')) == 9   ///
		| length(trim(`varlist')) == 10   ///
		| length(trim(`varlist')) == 11  ///
		| length(trim(`varlist')) == 12 ///
		| length(trim(`varlist')) == 13   ///

	if _rc != 0 { 
			di as err "The lenght of the variable is not acceptable!"
			exit 198
			}
		else {
			if length(trim(`varlist')) == 9 {
				                            scalar `CASE' = 7	
								    local l =  length(trim(`varlist'))
								   }

			if length(trim(`varlist')) == 10 {
				                            scalar `CASE' = 1	
								    local l =  length(trim(`varlist'))
								   }
			if length(trim(`varlist')) == 12 {
				                            scalar `CASE' = 2
								    local l =  length(trim(`varlist'))	
								   }
			if length(trim(`varlist')) == 11 {
				                            scalar `CASE' = 3	
								    local l =  length(trim(`varlist'))
								   }			
			if length(trim(`varlist')) == 13 {
				                            scalar `CASE' = 4	
								    local l =  length(trim(`varlist'))							
	   							  }
			}

	if `CASE' == 1  {			
				checkcontent `varlist'
			     }

	if `CASE' == 2  {
				checkcontent `varlist'
				tempvar pnr10	
				gen  `pnr10' = substr(`varlist',3,10)   
				local varlist = "`pnr10'" 
				* di as err "Be careful pnr_variable is `l' characters, I work with the last 10"
		 		}

	if `CASE' == 3    {
				local sign = substr(`varlist',`l'-4,1)
				if "`sign'" == "-" {
									tempvar pnr11A pnr11B				
									gen str6 `pnr11A' = substr(`varlist',1,`l'-5)  
									gen str4 `pnr11B' = substr(`varlist',`l'-3,4)  
									local varlist = "`pnr11A'+`pnr11B'" 
									checkcontent `varlist'
									}
				}

	if  `CASE' == 4  {		
	
				local sign = substr(`varlist',`l'-4,1)
				if "`sign'" == "-" {
									tempvar pnr11A pnr11B				
									gen str6 `pnr11A' = substr(`varlist',3,`l'-5)  
									gen str4 `pnr11B' = substr(`varlist',`l'-3,4)  
									local varlist = "`pnr11A'+`pnr11B'" 
									checkcontent `varlist'
									}
				}


	if  `CASE' == 7  {		
				checkcontent `varlist'
				}
			
			
// CREATE 9 local macros ranging from 1 to 9 
	
	tokenize 2 1 2 1 2 1 2 1 2

  quietly { 
		tempvar pnr chk digit result sum length correct bad correct1 correct2 pnrcorrect
		generate `pnr' = trim(`varlist')  
		char `pnr'[varname] "input_pnr" 
		generate `chk' = real(substr(`pnr',10,1))  
		char `chk'[varname] "i_check" 

		generate byte `digit' = .  
		generate `result' = ""  
		generate `sum' = 0  
            generate `pnrcorrect' = ""  
	
 
    forval j = 1/9 { 
			 replace `digit' = real(substr(`pnr',`j',1))  
			 replace `result' = `result' + string(`digit' * ``j'')  
 			} 

		generate `length' = length(`result')  
		local len = substr("`: type `result''",4,.) 
		
		forval j = 1/`len' { 
					replace `sum' = `sum' + real(substr(`result',`j',1)) ///
					if `j' <= `length' & `touse'
					} 
	
		generate byte `correct' = mod(10 - mod(`sum',10),10)  
		char `correct'[varname] "o_check" 
		generate byte `bad' = `chk' != `correct'   & `chk' != . & `touse'

 					qui generate `correct1'  =  substr(`pnr',1,9)     
					qui generate `correct2' =   string(`correct')  
					qui replace `pnrcorrect' = `correct1' + `correct2'   
					char `pnrcorrect'[varname] "output_pnr"  
	}


	if "`savepnr'"  != "" { 
					qui gen  `pnrname' =   `pnrcorrect'  
 					}

	if "`saveind'"  != "" {
					gen byte `pnrind' = `bad'  
					replace `pnrind' = 2 if `chk' == .   
 					}

		qui count if `bad' == 1    
		scalar NWRONG = r(N)
		qui count if `chk' == .    
		scalar NMISS = r(N) 

		scalar NOBS = c(N)  
		scalar NRIGHT = NOBS-NWRONG-NMISS
	
		return scalar N = NOBS
		return scalar pnrwrong = NWRONG
		return scalar pnrright = NRIGHT

	if "`display'"  != "" {

		noi di in smcl _n _col(2) in gr "Check digit"  _col(16) "Obs"  _col(25) "Perc.(%)"
		noi di in smcl in gr "{hline 40}"
		noi di in smcl _col(2) in gr "Wrong"  _col(18) in y NWRONG _col(26) %3.1f (NWRONG/NOBS)*100
		noi di in smcl _col(2) in gr "Right"  _col(18) in y  NRIGHT _col(26) %3.1f (NRIGHT/NOBS)*100
		noi di in smcl _col(2) in gr "Missing"  _col(18) in y  NMISS _col(26) %3.1f (NMISS/NOBS)*100
		noi di in smcl in gr "{hline 40}"
		noi di in smcl _col(2) in gr "Total"  _col(18) in y  NOBS _col(26) %3.1f ((NRIGHT+NWRONG+NMISS)/NOBS)*100
 			}

	if "`listwrong'"  != "" {
	            	 list `pnr' `chk' `pnrcorrect' `correct' if `bad'    , subvarname sep(0)
 				 }

	if "`listmissing'"  != "" {
	            	 list `pnr' `chk' `pnrcorrect' `correct' if `chk' ==.    , subvarname sep(0)
 				 }
 
end 

capture program drop checkcontent
program checkcontent
args varlist
capture assert real(`varlist') < .   

	if _rc !=0 { 
			di as err "`varlist' contains non-numeric characters" 
			exit 7 
			} 
end

