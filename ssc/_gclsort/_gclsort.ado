*! version 1.4 Philippe VAN KERM, 17oct2002
*!    version 1.3 Philippe VAN KERM, 02may2002
*!    version 1.0 Philippe VAN KERM, 23oct2001
*! Sorts a single column in a dataset
*! Syntax: egen NEWVARNAME = clsort(INITIALVAR [SORTVAR]) [if <exp>] 
*!	[in <range>] [, inplace pos(var) ] 

cap pr drop _gclsort
program define _gclsort , sortpreserve
	version 7

	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varlist(min=1 max=2) [if] [in] [, INplace POSvar(string) ]

	tokenize `varlist' 

	quietly {

	  tempvar n ny x y sortinit 
	  gen `sortinit' = _n
        if "`posvar'"~="" {sort `posvar' } 
	  marksample touse , novarlist strok
 	  /* set to 0 if outside the if in statements; 1 otherwise*/

	  if (("`inplace'"!="") & ("`if'"=="" & "`in'"=="")) {
		noi di as text "Note: option -inplace- irrelevant without" /*
			*/ " if/in clauses."
		}
 
	  /* Now I sort the data so that the positions to be filled are on top:
		if -inplace- NOT specified, do nothing
		if -inplace- specified (or with a key specified), sort by (1-touse)
		 (and by key)  */

	  if ("`inplace'"!="") {
                  if "`posvar'"~="" {gsort - `touse' +  `posvar'} 
			else {gsort - `touse' + `sortinit'} 
			}	/* if inplace selected sort, else do nothing */


	  tempfile pourtri

	  if "`2'"=="" {	
	    loc typ : type `1'
        gen `typ' `x' = `1' if `touse' /* select the observations to sort */ 
        gen `ny' = _n 		 /* create a current sort variable */

        preserve
	  	  keep if `touse'
	  	  keep `x'	
	  	  /* keep only the variable to sort */
	  	  sort `x'			/* sort it */
          rename `x' `h'		/* rename to newvarname */
        }  
	  else {  /* if a key is specified */	
	    loc typ1 : type `1'
	    loc typ2 : type `2'
        gen `typ2' `x' = `2' if `touse' /* select the observations to sort */ 
        gen `typ1' `y' = `1' if `touse' /* select the observations to sort */ 
        gen `ny' = _n 		 /* create a current sort variable */

        preserve
	  	  keep if `touse'
	  	  keep `x' `y'			/* keep only the variable to sort */
	  	  sort `x' 			/* sort it */
          rename `y' `h'		/* rename to newvarname */
        }           

      gen `ny' = _n		/* generate the current sort key */
	  sort `ny' 		/* useless but required for merge */ 
      save `pourtri'		/* temporary file pourtri is sorted on x */
      restore

      sort `ny'			/* useless but required for merge */

      cap drop _merge		/* plug the sorted x var back in main data */
      merge `ny' using `pourtri'
      drop _merge

	  sort `sortinit'		/* restore original sort order */
        } /* end quietly*/

end

