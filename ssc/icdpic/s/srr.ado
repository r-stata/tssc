/* Revised 10/16/2010 */
/* Version 3.0 */



/*--------------------------------------------------------------------------------------------------------------*/
/*  Program to calculate the Survival Risk Ratio (SRR) and the independent Survival Risk Ratio (SRRi) for each  */
/*  valid ICD-9-CM trauma code found in a given data set.                                                       */
/*--------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may    */
/*  be downloaded from the SSC archives website or installed from within STATA using the ssc command.           */
/*  Version 3.0 requires STATA 8.0 or higher.                                                                   */
/*--------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------*/
/*  NOTE: SRR and SRRi are rounded to the nearest 0.0001.  If SRR or SRRi are equal, or round to, 0.0000 or     */
/*  1.0000 they are replaced with 0.0001 and 0.9999 respectively.                                               */
/*--------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program srr can be run by typing "db srr", without the quotation marks, or running the ICDPIC         */
/*  program and choosing "SRR\SRRi Table" from the ICDPIC program dialog box.                                   */
/*--------------------------------------------------------------------------------------------------------------*/


program define srr
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i             /* Index */
      scalar numrecs = 0  /* Number of observations */
      scalar missing = 0  /* Number of observations with missing values for a given variable */  
      local code          /* Holds name of current temporary diagnosis code variable added to the end of each observation
                             of the dataset in memory for SRR calculation */
      local disp          /* Holds name of current temporary disposition (condition on discharge--alive or dead) variable
                             added to the end of each observation of the dataset in memory for SRR calculation */
      local dx_test       /* Used to test for a correct diagnosis code variable name prefix or the number of diagnosis code
                             variables in the user's data */
      local num_dx        /* Number of diagnosis code variables in the user's data */  
      local curr_dx       /* Holds name of current diagnosis code variable */
      local p1 dx         /* Merge variable name */

      
      /* Get arguments for input file, output file, switch to indicate which N-Code table to use, diagnosis code prefix
         and discharge status.                                                                                          */

      args filein fileout switch p_user doa

      /* Input data and clear old data out of memory. */

      use "`filein'", clear

      /* Preserve user's data. */

      preserve 

      /* Get number of observations. */
 
      scalar numrecs = _N

      /* If the data contains no observations. */

      if numrecs == 0 {
         capture window stopbox stop "Data contains no observations."
         exit
      }

      /* Check if user entered a correct prefix for the diagnosis code variables. */

      local dx_test = "`p_user'" + "1"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code prefix.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Discharge Status variable. */

      capture confirm variable `doa'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Discharge Status variable.  Please try again."
         exit
      }

      local i = 1

      /* Determine how many diagnosis code variables there are in the data. */

      while 1 {
         local dx_test = "`p_user'" + "`i'"
         capture confirm variable `dx_test'
         if _rc != 111 {
            local i = `i' + 1
         }
         else {
            local i = `i' - 1
            continue, break
         }
      }

      /* Assign number of diagnosis codes. */

      local num_dx = `i'

      /* Get temporary file names. */
   
      tempfile temp0
      tempfile temp1
      tempfile temp2



      /*------------------------------------------------------------------------*/
      /*  Merge diagnosis codes with N-Code reference table to determine which  */
      /*  are trauma codes.                                                     */
      /*------------------------------------------------------------------------*/


      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_dx' {

         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`p_user'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)
 
         /* Rename current diagnosis code variable to the diagnosis code variable name in the N-Code table. */

         rename `curr_dx' `p1'

         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {
            
            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `p1'

            /* Merge with N-Code table. */
      
            if `switch' == 1 {
               capture findfile ntab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile ntab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Drop variables barell, severity, issbr, and apc. */

            drop barell severity issbr apc

            /* Create new variables for diagnosis code and disposition and add them to the end of each observation of
               the dataset in memory.  Used for SRR calculation.                                                      */

            if `switch' == 1 {
               generate str5 dx_cpy = ""
            }
            else if `switch' == 2 {
               generate str6 dx_cpy = ""
            }
            generate byte disp_cpy = .

            /* Copy current diagnosis code and discharge status variable values to the new variables respectively if
               the diagnosis code was found in the N-Code table.  Used for SRR calculation.                          */

            replace dx_cpy = `p1' if _merge == 3
            replace disp_cpy = `doa' if _merge == 3

            /* Delete the _merge variable created by the merge process. */

            drop _merge
         }
         else {
         
            /* Create new variables for diagnosis code and disposition and add them to the end of each observation of
               the dataset in memory.  Used for SRR calculation.                                                      */

            if `switch' == 1 {
               generate str5 dx_cpy = ""
            }
            else if `switch' == 2 {
               generate str6 dx_cpy = ""
            }
            generate byte disp_cpy = .
         }

         /* Rename merge variable back to its original name. */

         rename `p1' `curr_dx'

         /* Keep variables dx_cpy and disp_cpy. */

         keep dx_cpy disp_cpy

         /* Rename variable dx_cpy dx. */

         rename dx_cpy dx

         /* Rename variable disp_cpy died. */

         rename disp_cpy died

         /* Drop observations where variable dx has missing values or variable died is not equal to either 0 or 1. */

         drop if dx == "" | (died != 0 & died != 1)

         /* If index i is equal to 1, save data to disk in temporary file. */

         if `i' == 1 {
            save `temp0'
         }

         /* Otherwise, append data in temporary file to data in memory and then save new data to disk in temporary file. */

         else {
            append using `temp0'
            save `temp0', replace
         }

         /* Restore user's original data while continuing to preserve it on disk. */

         restore, preserve

         local i = `i' + 1
      }



      /*-------------------------------------------------------------------*/
      /*  Perform operations necessary to produce the Survival Risk Ratio  */
      /*  (SRR) portion of the SRR\SRRi table.                             */
      /*-------------------------------------------------------------------*/


      /* Use data in temporary file temp0. */

      use `temp0', clear

      /* Get number of observations. */

      scalar numrecs = _N

      /* If number of observations is greater than zero. */

      if numrecs > 0 {

         /* Contract data in memory on the variables dx and died. */

         contract dx died

         /* Create two new variables, survive1 and expire1. */

         generate long survive1 = 0
         generate long expire1 = 0

         /* Populate the new variables survive1 and expire1. */

         replace survive1 = _freq if died == 0
         replace expire1 = _freq if died == 1

         /* Replace the value in the variable expire in the current observation with the value in the variable expire in 
            the next observation if the values in both dx variables are the same and delete the next observation.        */

         replace expire1 = expire1[_n + 1] if dx == dx[_n + 1]
         drop if dx == dx[_n - 1]

         /* Create a new variable to hold Survival Risk Ratio. */

         generate float srr = .

         /* Calculate Survival Risk Ratio.  Round to nearest 0.0001. */

         replace srr = round((survive/(survive + expire)), 0.0001)

         /* Merge current data in memory with N-Code reference table to create SRR table. */

            if `switch' == 1 {
               capture findfile ntab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile ntab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

         /* Keep variables dx, survive1, expire1, and srr. */ 

         keep dx survive1 expire1 srr

         /* Sort on variable dx. */

         sort dx

         /* Set display format for variable srr. */

         format srr %06.4f

         /* Assign new values to srr if srr is equal to 1.0 or 0.0 respectively. */

         replace srr = 0.9999 if srr == 1.0
         replace srr = 0.0001 if srr == 0.0

         /* Save temporary file with SRR data to disk. */

         save `temp1', replace
      }
      else {
      
         /* Use appropriate N-Code reference table. */

         if `switch' == 1 {
            use ntab_s1, clear
         }
         else if `switch' == 2 {
            use ntab_s2, clear
         }
   
         /* Create two new variables, survive1 and expire1. */

         generate long survive1 = .
         generate long expire1 = .

         /* Create a new variable to hold Survival Risk Ratio. */

         generate float srr = .
     
         /* Set display format for variable srr. */

         format srr %06.4f

         /* Keep variables dx, survive1, expire1, and srr. */ 

         keep dx survive1 expire1 srr

         /* Save temporary file with SRR data to disk. */

         save `temp1', replace
      }



      /*--------------------------------------------------------------------*/
      /*  Perform operations necessary to produce the Independent Survival  */
      /*  Risk Ratio(SRRi) portion of the SRR\SRRi table.                   */
      /*--------------------------------------------------------------------*/


      /* Load user's original data. */

      use "`filein'"

      /* Get number of observations. */
 
      scalar numrecs = _N

      /* Create temporary variables to hold diagnosis code and count for SRRi calculation. */

      if `switch' == 1 {
         generate str5 dx_code = ""
      }
      else if `switch' == 2 {
         generate str6 dx_code = ""
      }

      generate byte dx_count = 0

      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_dx' {

         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`p_user'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)
 
         /* Rename current diagnosis code variable to the diagnosis code variable name in the N-Code table. */

         rename `curr_dx' `p1'

         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {
            
            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `p1'

            if `switch' == 1 {
               capture findfile ntab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile ntab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Drop variables barell, severity, issbr, and apc. */

            drop barell severity issbr apc

            /* Copy current diagnosis code value to dx_code variable and increment the value in the dx_count variable if
               the diagnosis code was found in the N-Code table.  Used for SRRi calculation.                             */

            replace dx_code = `p1' if _merge == 3
            replace dx_count = (dx_count + 1) if _merge == 3

            /* Delete the _merge variable created by the merge process. */

            drop _merge

         }

         /* Rename merge variable back to its original name. */

         rename `p1' `curr_dx'

         local i = `i' + 1
      }

      /* Drop observation if value in count variable is greater than 1. */

      drop if dx_count > 1

      /* Keep variable dx_code and the user's discharge status variable. */ 

      keep dx_code `doa'

      /* Rename variable dx_code to dx. */

      rename dx_code dx

      /* Order the variables as below. */

      order dx `doa'

      /* Drop observations where variable dx has missing values or variable doa is not equal to either 0 or 1. */

      drop if dx == "" | (`doa' != 0 & `doa' != 1)

      /* Get number of observations. */

      scalar numrecs = _N

      /* If number of observations is greater than zero. */

      if numrecs > 0 {

         /* Contract data in memory on the variable dx and the user's discharge status variable. */

         contract dx `doa'

         /* Create two new variables, survive2 and expire2. */

         generate long survive2 = 0
         generate long expire2 = 0

         /* Populate the new variables survive2 and expire2. */

         replace survive2 = _freq if `doa' == 0
         replace expire2 = _freq if `doa' == 1

         /* Replace the value in the variable expire in the current observation with the value in the variable expire in 
            the next observation if the values in both dx variables are the same and delete the next observation.        */
   
         replace expire2 = expire2[_n + 1] if dx == dx[_n + 1]
         drop if dx == dx[_n - 1]

         /* Create a new variable to hold Independent Survival Risk Ratio (SRRi). */

         generate float srri = .

         /* Calculate Independent Survival Risk Ratio.  Round to nearest 0.0001. */

         replace srri = round((survive2/(survive2 + expire2)), 0.0001)
 
         /* Merge current data in memory with N-Code reference table to create SRRi table. */

            if `switch' == 1 {
               capture findfile ntab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile ntab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

         /* Keep variables dx, survive, expire, and srri. */ 

         keep dx survive2 expire2 srri

         /* Sort on variable dx. */

         sort dx

         /* Set display format for variable srri. */

         format srri %06.4f

         /* Assign new values to srri if srri is equal to 1.0 or 0.0 respectively. */

         replace srri = 0.9999 if srri == 1.0
         replace srri = 0.0001 if srri == 0.0

         /* Save temporary file with SRRi data to disk. */

         save `temp2', replace

         /* Merge SRR and SRRi temporary files to create SRR\SRRi table. */

         use `temp1', clear
         merge dx using `temp2', nokeep

         /* Delete the _merge variable created by the merge process. */

         drop _merge
      }
      else {
      
         /* Use temporary file temp1. */

         use `temp1', clear 

         /* Create two new variables, survive2 and expire2. */

         generate long survive2 = .
         generate long expire2 = .

         /* Create a new variable to hold Independent Survival Risk Ratio (SRRi). */

         generate float srri = .

         /* Set display format for variable srri. */

         format srri %06.4f  
      }

      /* Sort on variable dx. */

      sort dx

      /* Save new version of table to disk. */

      save "`fileout'", replace

      restore
   }
end
