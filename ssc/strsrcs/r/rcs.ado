*! version 1.0
*! orthog option added by Paul Lambert 28/Sep/2007
*! Chris Nelson 16/May/2008


program define rcs
        version 9.0
        syntax  varlist(max=1) [if] [in]                ///
                [, Gen(string) DGen(string) Knots(string) Orthog]      ///

        marksample touse

		
*************** CHECK FOR GENERATE NAME

        if "`gen'" == "" ///
        {
                di in red "Must specify name for cubic splines basis"
                exit 198
        }
        tempvar x 
        gen `x'=`varlist'

*************** CREATE FIRST REGRESSION VARIABLE RCS1 = X
		tempvar rcs1 orcs1
        quietly gen double `rcs1' = `x' if `touse'

*************** CREATE FIRST REGRESSION VARIABLE DRCS1 = 1

       if "`dgen'" != "" ///
        {
				tempvar drcs1 odrcs1
                quietly gen double `drcs1' = 1 if `touse'
        }

*************** EXTRACT KNOTS

        local nk : word count `knots'
        local i = 1 
        tokenize "`knots'"
        while "``i''" != "" ///
        {
                local k`i' ``i''
                local i = `i'+1
        }

*************** CREATE REGRESSION VARIABLES
        
        local kmin = `k1'
        local kmax = `k`nk''
        local interior  = `nk'-1

		local rcslist `rcs1' 
		local orcslist `orcs1' 
		local drcslist `odrcs1'
		local odrcslist `odrcs1'

        forvalues j=2/`interior' /// 
        {
                ******** CREATE LAMBDA
                local lambda = (`kmax' - `k`j'')/(`kmax' - `kmin')
                ******** CREATE RCS 
				tempvar rcs`j' orcs`j'
                quietly gen double `rcs`j'' = ((`x'-`k`j'')^3)*(`x'>`k`j'') - ///
                                    `lambda'*((`x'-`kmin')^3)*(`x'>`kmin') - ///
                                    (1-`lambda')*((`x'-`kmax')^3)*(`x'>`kmax')  if `touse'
				local rcslist `rcslist' `rcs`j''
				local orcslist `orcslist' `orcs`j''

        
*************** IF DERIVATIVES ARE SPECIFIED

        if "`dgen'"!="" ///
                {
                        ******** CREATE DRCS 
						tempvar drcs`j' odrcs`j'
                        quietly gen double `drcs`j'' = (3*(`x'-`k`j'')^2)*(`x'>`k`j'') - ///
                                            `lambda'*(3*(`x'-`kmin')^2)*(`x'>`kmin') - ///
                                            (1-`lambda')*(3*(`x'-`kmax')^2)*(`x'>`kmax')  if `touse'
					local drcslist `drcslist' `drcs`j''
					local odrcslist `odrcslist' `odrcs`j''					
											
                }       
        }
		
		if "`orthog'" != "" {
			tempname R Rinv
			orthog `rcslist' if `touse', gen(`orcslist') matrix(`R')
			if "`dgen'" != "" {
				matrix `Rinv' = inv(`R')
				forvalues i = 1/`interior' {
					local ortheqlist 0	

					forvalues j = 1/`i' {
						local ortheqlist "`ortheqlist' + `Rinv'[`j',`i']*`drcs`j''"
					}
					gen `odrcs`i''  if `touse' = `ortheqlist'
				}
			}
		}
			
/* create returned variables */
	
		forvalues i = 1/`interior' {
			if "`orthog'" != "" {
				local addo o
			}
			gen `gen'`i' if `touse' = ``addo'rcs`i''
			if "`dgen'" != "" {
				gen `dgen'`i' if `touse' = ``addo'drcs`i''
			}
		}
			
        if "`dgen'"!="" ///
        {
                di in green "Variables `gen'1 to `gen'`interior' and `dgen'1 to `dgen'`interior' were created"
        }
        else ///
        {
                di in green "Variables `gen'1 to `gen'`interior' were created"
        }
end
        
