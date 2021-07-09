/* Revised 10/24/2010 */
/* Version 3.0 */
   


/*-------------------------------------------------------------------------------------------------------------*/
/*  Program to compute the Anatomic Profile Score.  The user should first run program trauma (or choose        */
/*  "ICD-9-CM Trauma" from the ICDPIC dialog boxes) on his/her data to add AP component variables, severity    */
/*  variables and the max AIS variable.                                                                        */
/*                                                                                                             */
/*  The Anatomic Profile Score (APS) is computed with a logistically calibrated equation derived from three    */
/*  modified components from three different body region groups.  The mA component represents head/brain and   */
/*  spinal cord injures, the mB component represents thorax and neck injuries and the mC component represents  */
/*  all other serious injuries.  The modified components are defined as the square root of the sum of the      */
/*  squares of all serious injuries (AIS = 3, 4, 5 or 6) within their specified body region groups.  Once the  */
/*  modified components are determined, APS = 0.3199(mA) + 0.4381(mB) + 0.1406(mC) + 0.7961(maxAIS).           */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may   */
/*  be downloaded from the SSC archives website or installed from within STATA using the ssc command.          */
/*  Version 3.0 requires STATA 8.0 or higher.                                                                  */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Variables mA, mB, mC and APS are rounded to the nearest 0.0001.                                      */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program aps can be run by typing "db aps", without the quotation marks, or running the ICDPIC        */
/*  program and choosing "Anatomic Profile Score" from the ICDPIC dialog box.                                  */
/*-------------------------------------------------------------------------------------------------------------*/                                                                                              

 
program define aps
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i         /* Index */
      local apc_test  /* Used to test for a correct AP component category variable name prefix or the number of AP
                         component category variables in the user's data */
      local sev_test  /* Used to test for a correct severity variable name prefix */
      local num_apc   /* Number of anatomic profile component variables in the user's data */       
      local apc       /* Holds Anatomic Profile component category for current diagnosis code variable */
      local sev       /* Holds severity for current diagnosis code variable */


      /* Get arguments for input file, output file, anatomic profile component category variables prefix, severity
         variables prefix and maximum severity variable.                                                           */   

      args filein fileout p_apc p_sev mxais

      /* Input data and clear old data out of memory. */

      use "`filein'", clear

      /* Preserve user's data. */

      preserve 

      /* Check if user entered a correct prefix for the AP component category variables. */

      local apc_test = "`p_apc'" + "1"
      capture confirm variable `apc_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such AP component category prefix.  Please try again."
         exit
      }

      /* Check if user entered a correct prefix for the severity variables. */

      local sev_test = "`p_sev'" + "1"
      capture confirm variable `sev_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such severity prefix.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Maximum Severity variable. */

      capture confirm variable `mxais'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Maximum Severity variable.  Please try again."
         exit
      }

      /* Determine how many diagnosis code variables there are in the data by counting anatomic profile component
         variables.                                                                                               */

      local i = 1

      while 1 {
         local apc_test = "`p_apc'" + "`i'"
         capture confirm variable `apc_test'
         if _rc != 111 {
            local i = `i' + 1
         }
         else {
            local i = `i' - 1
            continue, break
         }
      }

      /* Assign number of diagnosis codes. */

      local num_apc = `i'

      /* Create temporary variables to hold sum of squares of AP component category values. */

      for newlist aps_a aps_b aps_c: generate int X = 0

      /* Create variables to hold square root of the sum of squares of AP component category values. */

      for newlist mA mB mC: generate float X = 0

      /* Create variable to hold APS. */ 

      generate float aps = 0    
   
      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_apc' {

         /* Generate name of current anatomic profile component category variable. */

         local apc = "`p_apc'" + "`i'"

         /* Generate name of current severity variable. */

         local sev = "`p_sev'" + "`i'"

         /* Update sum of squares of AP component categories. */

         replace aps_a = aps_a + (`sev' * `sev') if `apc' == "A"
         replace aps_b = aps_b + (`sev' * `sev') if `apc' == "B"
         replace aps_c = aps_c + (`sev' * `sev') if `apc' == "C"

         local i = `i' + 1
      }

      /* Calculate the square root of the sum of the squares for AP component categories A, B and C. */

      replace mA = sqrt(aps_a)
      replace mB = sqrt(aps_b)
      replace mC = sqrt(aps_c)

      /* Calculate Anatomic Profile Score.  Round to nearest 0.0001. */

      replace aps = round((0.3199 * mA) + (0.4381 * mB) + (0.1406 * mC) + (0.7961 * maxais), 0.0001)

      /* Round variables mA, mB and mC to the nearest 0.0001. */

      replace mA = round(mA, 0.0001)
      replace mB = round(mB, 0.0001)
      replace mC = round(mC, 0.0001)

      /* Update aps with 99.9999 if maximum severity is 9 i.e. no valid codes with a known severity. */

      replace aps = 99.9999 if `mxais' == 9

      /* Update square root of the sum of the squares for AP component categories A, B and C with 99.9999 if maximum
         severity is 9, i.e. no valid codes with a known severity.                                                   */

      replace mA = 99.9999 if `mxais' == 9
      replace mB = 99.9999 if `mxais' == 9
      replace mC = 99.9999 if `mxais' == 9

      /* Set display format for variables mA, mB, mC and aps. */ 
      
      format mA %07.4f
      format mB %07.4f
      format mC %07.4f
      format aps %07.4f

      /* Delete temporary variables aps_a aps_b aps_c. */

      drop aps_a aps_b aps_c

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end

