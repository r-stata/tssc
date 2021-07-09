/* Revised 10/24/2010 */
/* Version 3.0 */



/*-------------------------------------------------------------------------------------------------------------------*/
/*  Program to calculate the Survival Risk Ratio (SRR) product, the independent Survival Risk Ratio (SRRi) product,  */
/*  the minimum SRR and the minimum SRRi for each observation in a given data set using any SRR\SRRi table in the    */
/*  required format.  Also, adds SRR & SRRi values for each valid ICD-9-CM trauma code found in a given data set.    */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be      */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0      */
/*  requires STATA 8.0 or higher.                                                                                    */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: The user can produce the required SRR\SRRi table by first running his/her data through program srr or      */
/*  running the ICDPIC program and choosing "SRR\SRRi Table and ICISS" and then choosing "ICISS" from the ICDPIC     */
/*  program dialog boxes.                                                                                            */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: SRR, SRRi, SRR product, SRRi product, minimum SRR and minimum SRRi are rounded to the nearest 0.0001.      */
/*  If any of these values are equal, or round to, 0.0000 or 1.0000 they are replaced with 0.0001 and 0.9999         */
/*  respectively.                                                                                                    */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program iciss can be run by typing "db iciss", without the quotation marks, or running the ICDPIC program  */
/*  and choosing "ICISS" from the ICDPIC program dialog box.                                                         */
/*-------------------------------------------------------------------------------------------------------------------*/



program define iciss
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i             /* Index */
      scalar numrecs = 0  /* Number of observations */
      scalar missing = 0  /* Number of observations with missing values for a given variable */
      local dx_test       /* Used to test for a correct diagnosis code variable name prefix, a correct SRR\SRRi table
                             diagnosis code variable name or the number of diagnosis code variables in the user's data */
      local num_dx        /* Number of diagnosis code variables in the user's data */       
      local curr_dx       /* Holds name of current diagnosis code variable */
      local srr           /* Holds SRR for current diagnosis code variable */
      local srri          /* Holds SRRi for current diagnosis code variable */
      local p1 srr_       /* Prefix of all SRR variables */
      local p2 srri_      /* Prefix of all SRRi variables */
      
      /* Get arguments for input and output files, the input file diagnosis code prefix and the SRR\SRRi table 
         diagnosis code field name.                                                                            */

      args filein fileout filetab p_user tab_dx

      /* Check if user entered a correct prefix for the diagnosis code variable in the SRR\SRRi table file. */

      use "`filetab'", clear
      local dx_test = "`tab_dx'"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code variable in SRR\SRRi table.  Please try again."
         exit
      }

      /* Get input data and clear old data out of memory. */

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

      /* Check if user entered a correct prefix for the diagnosis code variables in the input file. */

      local dx_test = "`p_user'" + "1"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code prefix in the input file.  Please try again."
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

      /* Create temporary variable to hold record number */

      generate long rec_no = _n

      /* Create variable to hold product of SRR's. */

      generate float srrprod = 1.0

      /* Create variable to hold minimum SRR. */

      generate float min_srr = .

      /* Create variable to hold product of SRRi's. */

      generate float srriprod = 1.0

      /* Create variable to hold minimum SRRi. */

      generate float min_srri = .

      /* Create variable to hold SRR count. */

      generate byte srr_cnt = 0

      /* Create variable to hold SRRi count. */

      generate byte srri_cnt = 0



      /*------------------------------------------------------------------------*/
      /*  Join diagnosis codes with SRR\SRRi reference table to obtain SRR and  */
      /*  SRRi variables for each diagnosis code and add them to the data.      */
      /*------------------------------------------------------------------------*/
        

      /* Get number of observations. */
 
      scalar numrecs = _N

      local i = 1
      
      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                           
      while `i' <= `num_dx' { 
 
         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`p_user'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)
 
         /* Rename current diagnosis code variable to the diagnosis code variable name in the SRR reference table. */

         rename `curr_dx' `tab_dx'

         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `tab_dx'

            /* Merge with SRR\SRRi table. */

               merge `tab_dx' using "`filetab'", nokeep

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename merge variable back to its original name. */

            rename `tab_dx' `curr_dx'

            /* Rename 'ssr' variable added by the merge process to 'srr_' + the number of the current diagnosis code
               variable.  This is the SRR for the current diagnosis code.                                            */

            local srr = "`p1'" + "`i'"
            rename srr `srr'

            /* Rename 'ssri' variable added by the merge process to 'srri_' + the number of the current diagnosis code
               variable.  This is the SRRi for the current diagnosis code.                                             */

            local srri = "`p2'" + "`i'"
            rename srri `srri'        

            /* Move `srri' variable to it's proper position. */

            move `srri' `curr_dx'

            /* Move `srr' variable to it's proper position. */

            move `srr' `srri'

           /* Move `curr_dx' variable to it's proper position. */

            move `curr_dx' `srr'
         }
         else {

            /* Rename merge variable back to its original name. */

            rename `tab_dx' `curr_dx'

            /* Fill in current diagnosis code associated variable for SRRi with missing values and move it to
               it's proper position.                                                                          */
                     
            local srri = "`p2'" + "`i'"
            generate float `srri' = .
            move `srri' `curr_dx'
            
            /* Fill in current diagnosis code associated variable for SRR with missing values and move it to
               it's proper position.                                                                         */
                     
            local srr = "`p1'" + "`i'"
            generate float `srr' = .
            move `srr' `curr_dx'

            /* Move `curr_dx' variable to it's proper position. */

            move `curr_dx' `srr'
         }

         /* Update SRR Product.  Round to nearest 0.0001. */

         replace srrprod = (round((srrprod * `srr'), 0.0001)) if `srr' != .

         /* Update SRR count. */

         replace srr_cnt = srr_cnt + 1 if `srr' != .

         /* Update minimum SRR. */

         replace min_srr = `srr' if `srr' < min_srr

         /* Update SRRi Product. Round to nearest 0.0001. */

         replace srriprod = (round((srriprod * `srri'), 0.0001)) if `srri' != .

         /* Update SRRi count. */

         replace srri_cnt = srri_cnt + 1 if `srri' != .

         /* Update minimum SRRi. */

         replace min_srri = `srri' if `srri' < min_srri

         local i = `i' + 1
      }
      
      /* Set SRR product equal to missing if SRR product equals 1.0. */ 

      replace srrprod = . if srrprod == 1.0

      /* Set SRR product to 0.0001 if SRR product < 0.0001. */

      replace srrprod = 0.0001 if srrprod < 0.0001

      /* Set SRRi product equal to missing if SRRi product equals 1.0. */

      replace srriprod = . if srriprod == 1.0

      /* Set SRRi product to 0.0001 if SRRi product < 0.0001. */

      replace srriprod = 0.0001 if srriprod < 0.0001

      /* Sort table on num_rec variable. */ 

      sort rec_no

      /* Delete temporary variable rec_no. */ 

      drop rec_no

      /* Delete variables added by the join process which are not needed. */

      drop survive1 expire1 survive2 expire2

      /* Set display format for variable srrprod, min_srr, srriprod and min_srri. */ 

      format srrprod %6.4f
      format min_srr %6.4f
      format srriprod %6.4f
      format min_srri %6.4f

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end
