/* Revised 10/15/2010 */
/* Version 3.0 */



/*-----------------------------------------------------------------------------------------------------------------*/
/*  For each observation, program to assign severity and ISS body region values to each valid ICD-9-CM trauma      */
/*  code, assign Barell and AP component categories to each valid ICD-9-CM trauma code, calculate injury severity  */
/*  score (ISS) and new injury severity score (NISS), assign major mechanism, minor mechanism and intent for up    */
/*  to 4 E-Codes (excluding E-Code place) and assign trauma type (blunt or penetrating) based on major mechanism   */
/*  of the first E-Code found.                                                                                     */
/*-----------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be    */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0    */
/*  requires STATA 8.0 or higher.                                                                                  */
/*-----------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------*/
/*  NOTE:  Program trauma can be run by typing "db trauma", without the quotation marks, or running the ICDPIC     */
/*  program and choosing "ICD-9-CM Trauma" from the ICDPIC program dialog box.                                     */
/*-----------------------------------------------------------------------------------------------------------------*/



program define trauma
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i             /* Index */
      local j             /* Index */
      local k             /* Index */
      scalar numrecs = 0  /* Number of observations */
      scalar missing = 0  /* Number of observations with missing values for a given variable */ 
      scalar num_ais = 3  /* Number of maximum AIS/ISS body region variables used in computation of ISS */
      scalar num_sev = 3  /* Number of severity values used to calculate NISS */ 
      scalar num_br = 6   /* Number of ISS body regions */
      scalar max_e = 4    /* Maximum number of E-codes for which to collect data */
      local dx_test       /* Used to test for a correct diagnosis code variable name prefix or the number of diagnosis code
                             variables in the user's data */
      local num_dx        /* Number of diagnosis code variables in the user's data */       
      local curr_dx       /* Holds name of current diagnosis code variable */
      local curr_e        /* Holds name of current E-Code variable used with merge command */
      local apc           /* Holds AP component category for current diagnosis code variable */
      local brl           /* Holds Barell category for current diagnosis code variable */
      local issbr         /* Holds ISS body region for current diagnosis code variable */
      local sev           /* Holds AIS severity for current diagnosis code variable */
      local mxaisbr       /* Holds maximum AIS severity for the current ISS body region */
      local itmpais       /* Used to calculate ISS */
      local ntmpais       /* Used to calculate NISS */
      local ecode         /* Holds current E-Code */
      local maj           /* Holds major mechanism for current E-Code */
      local min           /* Holds minor mechanism for current E-Code */
      local intent        /* Holds intent for current E-Code */
      local p1 dx         /* Merge variable name */
      local p2 mxaisbr    /* Prefix of all maximum AIS/ISS body region variables */
      local p3 apc_       /* Prefix of all AP component variables */
      local p4 brl_       /* Prefix of all Barell category variables */
      local p5 issbr_     /* Prefix of all ISS body region variables */
      local p6 sev_       /* Prefix of all AIS severity variables */
      local p7 itmpais    /* Prefix of all temporary AIS severity variables used to calculate ISS values */
      local p8 ntmpais    /* Prefix of all temporary AIS severity variables used to calculate NISS values */
      local p9 ecode_     /* Prefix of all E-code variables */
      local p10 mechmaj   /* Prefix of all major mechanism variables */
      local p11 mechmin   /* Prefix of all minor mechanism variables */
      local p12 intent    /* Prefix of all intent variables */


      /* Get arguments for input file, output file, switch to indicate which N-Code and E-Code tables to use and
         diagnosis code prefix.                                                                                  */

      args filein fileout switch1 switch2 p_user 

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

      /* Create temporary variable to hold record number. */

      generate long rec_no = _n

      /* Create temporary variable to count the number of diagnosis codes with both an unknown severity and an unknown
         ISS body region.                                                                                              */

      generate byte unk_unk = 0



      /*---------------------------------------------------------------------------------*/
      /*  Merge diagnosis code variables with N-Code reference table to obtain severity  */
      /*  and ISS body region variables, anatomic profile component variables and        */
      /*  Barell category variables for each diagnosis code and add them to the data.    */
      /*---------------------------------------------------------------------------------*/
       
 
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
      
            if `switch1' == 1 {
               capture findfile ntab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch1' == 2 {
               capture findfile ntab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File ntab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename diagnosis code variable back to its original name. */

            rename `p1' `curr_dx'

            /* Rename 'apc' variable added by the merge process to 'apc_' + the number of the current diagnosis code
               variable.  This is the AP component category associated with the current diagnosis code.              */

            local apc = "`p3'" + "`i'"
            rename apc `apc'

            /* Move 'apc' variable to it's proper position. */

            move `apc' `curr_dx'

            /* Rename 'barell' variable added by the merge process to 'brl_' + the number of the current diagnosis code
               variable.  This is the Barell category associated with the current diagnosis code.                       */

            local brl = "`p4'" + "`i'"
            rename barell `brl'

            /* Move 'brl' variable to it's proper position. */

            move `brl' `apc'

            /* Rename 'issbr' variable added by the merge process to 'issbr_' + the number of the current diagnosis code
               variable.  This is the ISS body region variable associated with the current diagnosis code.               */

            local issbr = "`p5'" + "`i'"
            rename issbr `issbr'

            /* Move 'issbr' variable to it's proper position. */
      
            move `issbr' `brl'

            /* Rename 'severity' variable added by the merge process to 'sev_' + the number of the current diagnosis code
               variable.  This is the severity variable associated with the current diagnosis code.                       */

            local sev = "`p6'" + "`i'"
            rename severity `sev'

            /* Move 'sev' variable to it's proper position. */

            move `sev' `issbr'

            /* Move `curr_dx' variable to it's proper position. */

            move `curr_dx' `sev'

            /* Change any severity of 6 to a severity of 5 if warranted by ISS calculation method chosen by user. */
            
            if `switch2' == 2 {
               replace `sev' = 5 if `sev' == 6
            }

            /* Increment value in the temporary variable unk_unk if severity equals 9 and ISS body region equals 9. */
                                          
            replace unk_unk = unk_unk + 1 if `sev' == 9 & `issbr' == 9

         }
         else {

            /* Rename merge variable back to its original name. */

            rename `p1' `curr_dx'
            
            /* Fill in current diagnosis code associated variables for Barell category, ISS body region, severity
               and AP component category with missing values and move them to their proper positions.             */

            local apc = "`p3'" + "`i'"
            generate str3 `apc' = ""
            move `apc' `curr_dx'                 
            local brl = "`p4'" + "`i'"
            generate str3 `brl' = ""
            move `brl' `apc'                 
            local issbr = "`p5'" + "`i'" 
            generate byte `issbr' = .     
            move `issbr' `brl'
            local sev = "`p6'" + "`i'"
            generate byte `sev' = .
            move `sev' `issbr'
            move `curr_dx' `sev'
         }
         local i = `i' + 1
      }



      /*----------------------------------------------------*/
      /* Create variables for maximum AIS/ISS body region.  */
      /*----------------------------------------------------*/


      /* Create a temporary variable to flag unknown severity for a diagnosis code, i.e. severity value equals 9. */

      generate byte flag = .

      local i = 1

      /* While index number is less than or equal to number of ISS body regions. */
  
      while `i' <= num_br {

         /* Generate name of maximum AIS/ISS body region variable. */
 
         local mxaisbr = "`p2'" + "`i'"

         /* Create a variable for maximum severity for current ISS body region. */
   
         generate byte `mxaisbr' = 0

         /* Set value of unknown severity flag temporary variable to 0. */

         replace flag = 0
   
         local j = 1

         /* While index number is less than or equal to number of diagnosis codes. */
 
         while `j' <= `num_dx' {

            /* Generate name of ISS body region variable associated with current diagnosis code. */

            local issbr = "`p5'" + "`j'"

            /* Generate name of severity variable associated with current diagnosis code. */

            local sev = "`p6'" + "`j'"
       
            /* Replace the AIS severity value in the current mxaisbr variable with the value in the severity
               variable for the current diagnosis code if:

               1. The value in the ISS body region variable for the current diagnosis code is the
                  same as the value in the current mxaisbr variable and;         
               2. The value in the severity variable for the current diagnosis code is greater than
                  the severity value in the current mxaisbr variable and;
               3. The value in the severity variable for the current diagnosis code is not missing and;
               4. The value in the severity variable for the current diagnosis code is not equal to 9.       */
              
            replace `mxaisbr' = `sev' if `issbr' == `i' & `sev' > `mxaisbr' & `sev' != . & `sev' != 9

            /* Set the temporary variable flag to 1 if the severity is 9 and the value in the ISS body region variable
               for the current diagnosis code is the same as the value in the current mxaisbr variable.                */

            replace flag = 1 if `issbr' == `i' & `sev' == 9

            local j = `j' + 1
         }

         /* Set the variable mxaisbr to 9 if the severity is 0 and the value in the temporary variable flag is
            equal to 1.                                                                                        */
 
         replace `mxaisbr' = 9 if `mxaisbr' == 0 & flag == 1

         local i = `i' + 1
      }

      /* Delete the temporary variable flag. */

      drop flag



      /*---------------------------------------------------------*/
      /*  Calculate maximum severity over all ISS body regions.  */
      /*---------------------------------------------------------*/


      /* Create a variable to hold the maximum severity over all ISS body regions. */

      generate byte maxais = 0

      /* Create a temporary variable to hold maximum severity over all ISS body regions including those with an unknown
         severity.                                                                                                      */

      generate byte unk_sev = .

      local i = 1

      /* While index number is less than the number of ISS body regions, loop thru and get maximum severity value over
         all ISS body regions with a known severity.                                                                   */

      while `i' <= num_br {
         local mxaisbr = "`p2'" + "`i'"
         replace maxais = `mxaisbr' if `mxaisbr' > maxais & `mxaisbr' != 9
         local i = `i' + 1
      }

      /* Get maximum severity over all ISS body regions including those with an unknown severity. */

      replace unk_sev = max(mxaisbr1, mxaisbr2, mxaisbr3, mxaisbr4, mxaisbr5, mxaisbr6)

      /* Replace maxais with unk_sev if there are no ISS body regions with a known severity. */

      replace maxais = unk_sev if maxais == 0

      /* Replace maxais with 9 if there are no ISS body regions with a known or unknown severity and there are valid
         diagnosis codes whose severity and ISS body region are both unknown.                                        */

      replace maxais = 9 if maxais == 0 & unk_unk > 0

      /* Delete the temporary variables unk_sev and unk_unk. */

      drop unk_sev unk_unk



      /*------------------------------------------*/
      /*  Get components to calculate ISS value.  */
      /*------------------------------------------*/


      /* Create temporary variables to hold the three highest maximum AIS/ISS body region variable values overall. */

      for newlist index1-index3 : generate byte X = 0
 
      local i = 1

      /* While index number is less than the number of maximum AIS/ISS body region variables used in calculating ISS. */

      while `i' <= num_ais {

         /* Generate name for one of the temporary variables that hold one of the top three maximum AIS/ISS body region
            values.                                                                                                     */
       
         local itmpais = "`p7'" + "`i'"

         /* Create one of the temporary variables that hold one of the top three maximum AIS/ISS body region values. */

         generate byte `itmpais' = 0

         local j = 1

         /* While index number is less than the number of ISS body regions. */

         while `j' <= num_br {

            /* Generate name of maximum AIS/ISS body region variable. */

            local mxaisbr = "`p2'" + "`j'"

            /* Get the three highest maximum AIS/ISS body region variable values overall.  Ignore any value in a previous
               run already chosen as the maximum.                                                                         */

            if `i' == 1 {
               replace index1 = `j' if `mxaisbr' > `itmpais' & `mxaisbr' != 9
               replace `itmpais' = `mxaisbr' if `mxaisbr' > `itmpais' & `mxaisbr' != 9
            }
            else if `i' == 2 {
               replace index2 = `j' if `mxaisbr' > `itmpais' & `j' != index1 & `mxaisbr' != 9
               replace `itmpais' = `mxaisbr' if `mxaisbr' > `itmpais' & `j' != index1 & `mxaisbr' != 9
            }
            else if `i' == 3 {
            replace index3 = `j' if `mxaisbr' > `itmpais' & `j' != index1 & `j' != index2 & `mxaisbr' != 9
            replace `itmpais' = `mxaisbr' if `mxaisbr' > `itmpais' & `j' != index1 & `j' != index2 & `mxaisbr' != 9
            }
            local j = `j' + 1
         }
         local i = `i' + 1
      }



      /*------------------------*/
      /*  Calculate ISS value.  */
      /*------------------------*/


      /* Create ISS variable and populate it. */

      generate byte xiss = itmpais1^2 + itmpais2^2 + itmpais3^2

      /* Replace ISS value with 75 if maximum severity is 6. */

      replace xiss = 75 if maxais == 6

      /* Replace ISS value with 99 if maximum severity is 9. */

      replace xiss = 99 if maxais == 9

      /* Delete temporary variables index1-index3 and itmpais1-itmpais3. */

      drop index1 index2 index3 itmpais1 itmpais2 itmpais3



      /*-------------------------------------------*/
      /*  Get components to calculate NISS value.  */
      /*-------------------------------------------*/


      /* Create temporary variables to hold the three highest severity values overall. */

      for newlist index11-index13 : generate byte X = 0
 
      local i = 1

      /* While index number is less than the number of severity values used in calculating NISS. */

      while `i' <= num_sev {

         /* Generate name for one of the temporary variables that hold one of the top three severity values. */
       
         local ntmpais = "`p8'" + "`i'"

         /* Create one of the temporary variables that hold one of the top three severity values. */

         generate byte `ntmpais' = 0

         local j = 1

         /* While index number is less than the number of diagnosis codes. */

         while `j' <= `num_dx' {

            /* Generate name of current severity variable. */

            local sev = "`p6'" + "`j'"

            /* Get the three highest severity values overall. */

            if `i' == 1 {
               replace index11 = `j' if `sev' > `ntmpais' & `sev' != 9 & `sev' != .
               replace `ntmpais' = `sev' if `sev' > `ntmpais' & `sev' != 9 & `sev' != .
            }
            else if `i' == 2 {
               replace index12 = `j' if `sev' > `ntmpais' & `j' != index11 & `sev' != 9 & `sev' != .
               replace `ntmpais' = `sev' if `sev' > `ntmpais' & `j' != index11 & `sev' != 9 & `sev' != .
            }
            else if `i' == 3 {
               replace index13 = `j' if `sev' > `ntmpais' & `j' != index11 & `j' != index12 & `sev' != 9 & `sev' != .
               replace `ntmpais' = `sev' if `sev' > `ntmpais' & `j' != index11 & `j' != index12 & `sev' != 9 & `sev' != .
            } 
            local j = `j' + 1
         }
         local i = `i' + 1
      }



      /*-------------------------*/
      /*  Calculate NISS value.  */
      /*-------------------------*/


      /* Create NISS variable and populate it. */

      generate byte niss = ntmpais1^2 + ntmpais2^2 + ntmpais3^2

      /* Replace NISS value with 75 if maximum severity is 6. */

      replace niss = 75 if maxais == 6

      /* Replace NISS value with 99 if maximum severity is 9. */

      replace niss = 99 if maxais == 9

      /* Delete temporary variables index11-index13 & ntmpais1-ntmpais3. */

      drop index11 index12 index13 ntmpais1 ntmpais2 ntmpais3



      /*---------------------------------------------------------------------*/
      /*  Merge diagnosis codes with E-Code reference table to obtain major  */
      /*  mechanism, minor mechanism and intent variables for up to 4        */
      /*  E-Codes and add them to the data.                                  */
      /*---------------------------------------------------------------------*/


      local i = 1

      /* Create 4 E-Code, major mechanism, minor mechanism and intent variables. */

      while `i' <= max_e {
         local ecode = "`p9'" + "`i'"
         generate str5 `ecode' = ""
         local maj = "`p10'" + "`i'"
         generate byte `maj' = .
         local min = "`p11'" + "`i'"
         generate byte `min' = .
         local intent = "`p12'" + "`i'"
         generate byte `intent' = .
         local i = `i' + 1
      }

      /* Create temporary variable to hold current E-Code. */

      if `switch1' == 1 {
         generate str5 ecode = ""
      }
      else if `switch1' == 2 {
         generate str6 ecode = ""
      }

      /* Create temporary variable to keep track of which E-Code and associated info variables are to be assigned data. */

      generate byte index0 = 0

      local i = 1

      /* Loop through diagnosis code variables to find E-Codes, ignoring E-Code place E-Codes, and setting index to which
         E-Code variable it should be assigned.                                                                           */

      while `i' <= `num_dx' {
         local j = 1
         local curr_dx = "`p_user'" + "`i'"
         replace ecode = `curr_dx' if substr(`curr_dx', 1, 1) == "E" & substr(`curr_dx', 2, 3) != "849"
         replace index0 = index0 + 1 if substr(`curr_dx', 1, 1) == "E" & substr(`curr_dx', 2, 3) != "849"

         /* Assign E-Code to the proper E-Code variable. */

         while `j' <= max_e {
            local ecode = "`p9'" + "`j'"
            replace `ecode' = ecode if index0 == `j'
            local j = `j' + 1
         }
         local i = `i' + 1
      }

      /* Delete temporary variables ecode and index0. */

      drop ecode index0

      local k = 1

      /* Loop though E-Code variables obtaining major mechanism, minor mechanism and intent information. */

      while `k' <= max_e {

         /* Generate name of current E-Code variable. */

         local curr_e = "`p9'" + "`k'"

         /* Get number of missing observations for the current E-Code variable. */

         capture count if `curr_e' == ""
         scalar missing = r(N)

         /* Rename current E-Code variable to the E-Code variable name in the E-Code table. */

         rename `curr_e' `p1'

         /* Process current E-Code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `p1'

            /* Merge with E-Code table. */
      
            if `switch1' == 1 {
               capture findfile etab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File etab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch1' == 2 {
               capture findfile etab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File etab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Rename merge variable back to its original name. */

            rename `p1' `curr_e'

            /* Generate current E-Code and associated variable names. */

            local maj = "`p10'" + "`k'"
            local min = "`p11'" + "`k'"
            local intent = "`p12'" + "`k'"

            /* Assign E-Code data to proper E-Code and associated variables. */

            replace `maj' = mechmaj  
            replace `min' = mechmin  
            replace `intent' = intent 

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Delete variables added by the merge process for E-codes. */

            drop mechmaj mechmin intent
         }

         else {

            /* Rename merge variable back to its original name. */

            rename `p1' `curr_e'
         }
         local k = `k' + 1
      }

      /* Create lowmech variable to hold the lowest major E-code mechanism code. */

      generate byte lowmech = min(mechmaj1, mechmaj2, mechmaj3, mechmaj4)

      /* Create bluntpen variable to hold type of trauma: blunt or penetrating. */

      generate str1 bluntpen = ""

      /* Determine blunt or penetrating trauma. */

      replace bluntpen = "B" if mechmaj1 == 2 | mechmaj1 == 5 | mechmaj1 == 6 | mechmaj1 == 7 | mechmaj1 == 8 |/*
      */ mechmaj1 == 9 | mechmaj1 == 13
      replace bluntpen = "P" if mechmaj1 == 0 | mechmaj1 == 4 

      /* Sort table on num_rec variable. */

      sort rec_no

      /* Delete temporary variable rec_no. */ 

      drop rec_no

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end
