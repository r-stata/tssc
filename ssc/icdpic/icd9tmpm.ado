/* Revised 10/15/2010 */
/* Version 3.0 */



/*----------------------------------------------------------------------------------------------------------------------*/
/*  Program to compute the probability of death using the Trauma Mortality Prediction Model (TMPM) based on ICD-9-CM    */
/*  diagnosis codes (N-Codes).  The program adds a model-averaged regression coefficient (MARC) value for each N-Code   */
/*  in the user's data.  It then adds variables for the five worst injuries, those corresponding to the 5 highest       */
/*  MARC values, along with variables containing their corresponding N-Code and ISS body region, variables indicating   */
/*  the body regions of the 2 worst injuries (2 highest MARC values) and a Boolean variable to indicate if the 2 worst  */
/*  injuries occur in the same body region.  Finally, it adds a variable for the TMPM value and a variable for          */
/*  probability of death.                                                                                               */
/*----------------------------------------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be         */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0         */
/*  requires STATA 8.0 or higher.                                                                                       */
/*----------------------------------------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: ICD-9-CM TMPM and probability of death values are rounded to the nearest 0.000001.                            */
/*----------------------------------------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program icd9tmpm can be run by typing "db icd9tmpm", without the quotation marks, or running the ICDPIC       */
/*  program and choosing "ICD-9-CM TMPM from the ICDPIC dialog box.                                                     */
/*----------------------------------------------------------------------------------------------------------------------*/


program define icd9tmpm
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i                 /* Index */
      local j                 /* Index */
      local k                 /* Index */
      scalar numrecs = 0      /* Number of observations */
      scalar missing = 0      /* Number of observations with missing values for a given variable */
      scalar num_marc = 5     /* Number of MARC values used in calculating TMPM and probability of death */
      scalar C0 = -2.217565   /* Constant */
      scalar C1 = 1.406958    /* MARC 1 coefficient */
      scalar C2 = 1.409992    /* MARC 2 coefficient */
      scalar C3 = 0.5205343   /* MARC 3 coefficient */
      scalar C4 = 0.4150946   /* MARC 4 coefficient */
      scalar C5 = 0.8883929   /* MARC 5 coefficient */
      scalar C6 = -0.0890527  /* Same body region for two highest MARC values (2 worst injuries) coefficient */
      scalar C7 = -0.7782696  /* Coefficient for interaction between two highest MARC values (two worst injuries) */
      local dx_test           /* Used to test for a correct diagnosis code variable name prefix or the number of diagnosis
                                 code variables in the user's data */
      local num_dx            /* Number of diagnosis code variables in the user's data */  
      local curr_dx           /* Holds name of current diagnosis code variable */
      local curr_mo           /* Holds name of current MARC value variable associated with an original diagnosis code
                                 variable */
      local curr_mi           /* Holds name of current top 5 MARC value variable associated with a top 5 injury variable */
      local curr_inj          /* Holds name of current injury variable associated with a top 5 MARC value variable */
      local bodyreg           /* Holds ISS body region for current top 5 injury */
      local f_dx              /* Holds name of first diagnosis code variable */
      local l_dx              /* Holds name of last diagnosis code variable */
      local f_marc            /* Holds name of first MARC value variable */
      local l_marc            /* Holds name of last MARC value variable */      
      local p1 dx             /* Prefix of all diagnosis code variables */
      local p2 marc_          /* Prefix of all MARC value variables */
      local p3 marc           /* Prefix of all top 5 MARC value variables */
      local p4 inj            /* Prefix of all injury variables associated with a top 5 MARC value variable */
      local p5 bodyreg        /* Prefix of all ISS body regions associated with a top 5 injury variable */
      local cmp_m1            /* Holds name of first MARC value variable (associated with an original diagnosis code
                                 variable) used for comparison in insertion sort */
      local cmp_m2            /* Holds name of second MARC value variable (associated with an original diagnosis code
                                 variable) used for comparison in insertion sort */
      local cmp_ma1           /* Holds name of diagnosis code variable associated with first MARC value variable used in
                                 comparison for insertion sort */
      local cmp_ma2           /* Holds name of diagnosis code variable associated with second MARC value variable used in
                                 comparison for insertion sort */


      /* Get arguments for input file, output file, switch to indicate which MARC value table to use and diagnosis code
         prefix.                                                                                                        */

      args filein fileout switch p_user

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

      /* Check if user entered a correct prefix for the diagnosis code variables in the input file. */

      local dx_test = "`p_user'" + "1"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code prefix in the input file.  Please try again."
         exit
      }

      /* Determine how many diagnosis code variables there are in the data. */

      local i = 1

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

      /* Create temporary variable to hold record number. */

      generate long rec_no = _n
 
      /* Get temporary file name. */
   
      tempfile temp1



      /*----------------------------------------------------------------------------------*/
      /*  Merge diaagnosis code variables with MARC value reference table to obtain MARC  */
      /*  values for each trauma diagnosis code and add them to the data.  Save results   */
      /*  to temporary file number 1.                                                     */
      /*----------------------------------------------------------------------------------*/
        
   
      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_dx' {

         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`p_user'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)
 
         /* Rename current diagnosis code variable to the diagnosis code variable name in the MARC value reference table. */

         rename `curr_dx' `p1'

         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on merge variable. */

            sort `p1'

            /* Merge with MARC value reference table. */
      
            if `switch' == 1 {
               capture findfile micd9_s1.dta
               if _rc == 601 {
                  window stopbox stop "File micd9_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile micd9_s2.dta
               if _rc == 601 {
                  window stopbox stop "File micd9_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Delete the _merge variable created by the merge process and the ISS bpdy region variable added by the
               merge process.                                                                                        */

            drop _merge issbr
            
            /* Rename merge variable back to its original name. */

            rename `p1' `curr_dx'

            /* Rename 'marc' variable added by the merge process to 'marc_' + the number of the current diagnosis
               code variable.  This is the MARC value associated with the current diagnosis code.                 */

            local marc = "`p2'" + "`i'"
            rename marc `marc'

            /* Move 'marc' variable to it's proper position. */

            move `marc' `curr_dx'
            move `curr_dx' `marc'
         }
         else {
     
            /* Fill in current diagnosis code associated variable for MARC value with missing values and move it to
               it's proper position.                                                                                */

            local marc = "`p2'" + "`i'"
            generate float `marc' = .
            move `marc' `curr_dx'
            move `curr_dx' `marc'              
         }
         local i = `i' + 1
      }
        
      /* Sort table on num_rec variable. */

      sort rec_no

      /* Save temporary file temp1. */

      save `temp1', replace



      /*----------------------------*/
      /*  Drop unwanted variables.  */
      /*----------------------------*/

      /* Construct names of the first and last diagnosis code and MARC value variables. */

      local i = 1

      local f_dx = "`p_user'" + "`i'"
      local f_marc = "`p2'" + "`i'"
      local l_dx = "`p_user'" + "`num_dx'"
      local l_marc = "`p2'" + "`num_dx'"

      /* Keep only the diagnosis code and MARC value variables plus the rec_no variable. */

      keep `f_dx'-`l_dx' `f_marc'-`l_marc' rec_no



      /*--------------------------------------------------------------------------------------------------------*/
      /*  Prepare data, and create variables necessary, for sorting and sort MARC values using insertion sort.  */
      /*--------------------------------------------------------------------------------------------------------*/


      local i = 1

      /* Replace any MARC variables that have missing values with a number guaranteed to be lower than the lowest MARC
         value expected to be encountered.  For our purposes, -10^36 should be sufficient.                             */
   
      while `i' <= `num_dx' {
         local marc = "`p2'" + "`i'"
         replace `marc' = -10^36 if `marc' == .
         local i = `i' + 1
      }

      /* Create temporary variables for insertion sort swap of MARC values and movement of associated diagnosis
         code variables.                                                                                        */   

      generate float tmp_marc = .

      if `switch' == 1 {
         generate str5 tmp_dx = ""
      }
      else if `switch' == 2 {
         generate str6 tmp_dx = ""
      }

      /* Perform insertion sort using MARC values.  Move associated diagnosis code variables accordingly. */

      local i = 2

      while `i' <= `num_dx' {
         local curr_dx = "`p_user'" + "`i'"
         local marc = "`p2'" + "`i'" 
         local j = `i'
         while 1 {
            local k = `j' - 1
            replace tmp_marc = 10^36 
            if `k' == 0 {
               continue, break
            }  
            local cmp_m1 = "`p2'" + "`k'"
            local cmp_m2 = "`p2'" + "`j'"
            local cmp_ma1 = "`p_user'" + "`k'"
            local cmp_ma2 = "`p_user'" + "`j'"
            replace tmp_marc = `cmp_m1' if `cmp_m1' < `cmp_m2'
            replace tmp_dx = `cmp_ma1' if `cmp_m1' < `cmp_m2'
            replace `cmp_ma1' = `cmp_ma2' if `cmp_m1' < `cmp_m2'
            replace `cmp_m1' = `cmp_m2' if `cmp_m1' < `cmp_m2'
            replace `cmp_ma2' = tmp_dx if tmp_marc < `cmp_m1'
            replace `cmp_m2' = tmp_marc if tmp_marc < `cmp_m1'
            local j = `j' - 1
         }
         local i = `i' + 1
      }



      /*-----------------------------------------------------------------------------------------*/
      /*  Create new set of variables to hold the 5 worst injuries and their corresponding MARC  */
      /*  values.                                                                                */
      /*-----------------------------------------------------------------------------------------*/


      /* Create variables to hold injuries (N-Codes) associated with top 5 MARC values (5 worst injuries). */

      if `switch' == 1 {
         for newlist inj1-inj5: generate str5 X = "" 
      }
      else if `switch' == 2 {
         for newlist inj1-inj5: generate str6 X = "" 
      }

      /* Create variables to hold top 5 MARC values (5 worst injuries). */

      for newlist marc1-marc5: generate float X = .

      /* Place top five MARC values and associated injuries (N-Codes) into variables marc1-marc5 and inj1-inj5
         respectively.                                                                                         */ 

      local i = 1

      while 1 {
         local curr_dx = "`p_user'" + "`i'"
         local curr_inj = "`p4'" + "`i'"
         local curr_mo = "`p2'" + "`i'"
         local curr_mi = "`p3'" + "`i'"
         replace `curr_inj' = `curr_dx' if `curr_mo' != float(-10^36)
         replace `curr_mi' = `curr_mo' 
         move `curr_inj' `curr_mi' 
         replace `curr_mi' = 0 if `curr_mi' == float(-10^36)
         if `i' == num_marc | `i' == `num_dx' {
            continue, break
         }      
         local i = `i' + 1       
      }

      /* If any MARC value variable still contains a missing value, replace it with 0 (zero). */

      for varlist marc1 marc2 marc3 marc4 marc5: replace X = 0 if X == .



      /*-----------------------------------------------------------------------*/
      /*  Add ISS body region to five worst injuries (5 highest MARC values).  */
      /*-----------------------------------------------------------------------*/


      local i = 1

      /* Get ISS body regions associated with the 5 worst injuries (N-Codes). */

      while `i' <= num_marc {

         /* Generate name of current injury variable. */

         local curr_inj = "`p4'" + "`i'"
            
         /* Rename current injury variable to the diagnosis code variable name in the MARC value reference table. */

         rename `curr_inj' `p1'

         /* Sort table in memory on current renamed injury variable. */

         sort `p1'

         /* Merge with MARC value reference table. */
      
            if `switch' == 1 {
               capture findfile micd9_s1.dta
               if _rc == 601 {
                  window stopbox stop "File micd9_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile micd9_s2.dta
               if _rc == 601 {
                  window stopbox stop "File micd9_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

         /* Delete the _merge variable created by the merge process and the marc variable added by the merge process. */

         drop _merge marc

         /* Rename injury variable back to its original name. */

         rename `p1' `curr_inj'

         /* Rename 'issbr' variable added by the merge process to 'bodyreg' + the number of the current injury
            variable.  This is the body region value associated with the current injury.                       */

         local bodyreg = "`p5'" + "`i'"
         rename issbr `bodyreg'

         /* Move 'bodyreg' variable and associated injury variable to their proper positions. */
         
         local curr_mi = "`p3'" + "`i'"
         local curr_inj = "`p4'" + "`i'"
         move `curr_inj' `curr_mi'
         move `bodyreg' `curr_mi'

         local i = `i' + 1
      }



      /*------------------------------------------------------------------------------*/
      /*  Create variables to hold ISS body regions of two highest MARC values and a  */
      /*  variable to indicate if these two body regions are the same.                */
      /*------------------------------------------------------------------------------*/


      /* Create variables to hold ISS body region of two highest MARC values (two worst injuries). */
       
      for newlist high1-high2: generate byte X = .
    
      /* Get ISS body regions of the two worst injuries (two highest MARC values). */

      replace high1 = bodyreg1 if marc1 != 0
      replace high2 = bodyreg2 if marc2 != 0

      /* Create Boolean variable to indicate if body region of the top 2 MARC values (2 worst injuries) are equal. */   

      generate byte same_reg = 0

      /* Set same_reg variable to 1 if the ISS body regions of the two worst injuries (two highest marc values)
         are equal.                                                                                             */

      replace same_reg = 1 if high1 == high2 & marc1 != 0



      /*--------------------------------------------------------------------------------------------*/
      /*  Create variables to hold TMPM and probability of death (POD) and calculate their values.  */
      /*--------------------------------------------------------------------------------------------*/


      /* Create variable to hold Trauma Mortality Prediction Model (TMPM) value. */

      generate float ICD9TMPM = .

      /* Create variable to hold probability of death (POD) value. */

      generate float ICD9_POD = .

      /* Calculate TMPM. */

      replace ICD9TMPM = C0 + (C1 * marc1) + (C2 * marc2) + (C3 * marc3) + (C4 * marc4) + (C5 * marc5) + (C6 * same_reg)/*
      */ + (C7 * marc1 * marc2) if marc1 != 0

      /* Calculate probability of death (POD). */

      replace ICD9_POD = normal(ICD9TMPM) 



      /*-----------------------------------------------------------------------------------------*/
      /*  Drop unwanted variables, sort on variable rec_no and save to temporary file number 2.  */
      /*-----------------------------------------------------------------------------------------*/


      /* Keep marc variables, injury variables, ISS body region variables, ICD9TMPM variable, ICD9_POD variable,
         same_reg variable and rec_no variable.                                                                  */

      keep marc1-marc5 inj1-inj5 bodyreg1-bodyreg5 high1-high2 ICD9TMPM ICD9_POD same_reg rec_no

      /* Sort file on variable rec_no. */

      sort rec_no 

      /* Get temporary file name. */
   
      tempfile temp2

      /* Save temporary file temp2. */

      save `temp2', replace



      /*-----------------------------------------------------------------------------------------*/
      /*  Input temporary file number 1 data and merge it with temporary file number 2 data and  */
      /*  do some light house keeping.  Save everything to user's designated output file.        */
      /*-----------------------------------------------------------------------------------------*/


      /* Input data from temporary file temp1 and clear out old data. */

      use `temp1', clear
  
      /* Merge temporary file temp1 data with temporary file temp2 data using the rec_no variable. */

      merge rec_no using `temp2'

      /* Round ICD-9-CM TMPM and ICD9_POD variables to nearest 0.000001. */

      replace ICD9TMPM = round(ICD9TMPM, 0.000001)
      replace ICD9_POD = round(ICD9_POD, 0.000001)

      /* Format variables ICD-9-CM TMPM and POD. */

      format ICD9TMPM ICD9_POD %9.6f

      /* Delete the _merge variable created by the merge process. */
  
      drop _merge

      /* Delete temporary variable rec_no. */ 

      drop rec_no

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end
