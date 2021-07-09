/* Revised 10/16/2010 */
/* Version 3.0 */  



/*------------------------------------------------------------------------------------------------------------------*/
/*  Program to compute ASCOT survival probability.  The user should first run program trauma (or choose "ICD-9-CM   */
/*  Trauma" from the ICDPIC dialog box) on his/her data to add maximum severity, anatomic profile component         */
/*  category and blunt/penetrating trauma variables to their data.  The user should then run his/her data through   */
/*  program rts (or choose "Revised Trauma Score" from the ICDPIC dialog box) to add the revised trauma score and   */
/*  coded GCS, systolic blood pressure and respiratory rate variables.  Finally, the user's data should contain a   */
/*  variable for age of type integer and a discharge status variable of type byte where 0 indicates the patient     */
/*  survived and 1 indicates the patient died.                                                                      */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be     */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0     */
/*  requires STATA 8.0 or higher.                                                                                   */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Only Anatomic Profile components A, B and C with severities between 3 and 5 inclusive are used to         */
/*  calculate the ASCOT value.  Also, survival probabilities for certain set-aside conditions are calculated        */
/*  separately.  These set-aside conditions are: MAXAIS = 6 & RTS = 0; MAXAIS < 6 & RTS = 0; MAXAIS = 6 & RTS > 0   */
/*  and; MAXAIS = 1 or 2 & RTS > 0.  Survival probabilities for these set-aside conditions are determined by the    */
/*  number of survivors with a given set-aside condition divided by the number of survivors + the number of         */
/*  non survivors with that set-aside condition individually for both blunt and penetrating trauma.                 */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: ASCOT coefficients are the original weights.  If the user has their own database and wishes to            */
/*  calculate their own weights or use weights provided by others, they need only to substitute those weights in    */
/*  the dialog box.                                                                                                 */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Variables mA, mB, mC, KB and KP are rounded to the nearest 0.0001.                                        */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: ASCOT probabilities are rounded to the nearest 0.0001.  ASCOT probabilities that are equal, or round to,  */
/*  0.0000 and 1.0000 are replaced with 0.0001 and 0.9999 respectively.                                             */
/*------------------------------------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program ascot can be run by typing "db ascot", without the quotation marks, or running the ICDPIC         */
/*  program and choosing "ASCOT" from the ICDPIC dialog box.                                                        */
/*------------------------------------------------------------------------------------------------------------------*/


program define ascot
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i         /* Index */
      local apc_test  /* Used to test for a correct anatomic profile component variable name prefix or the number of
                         anatomic profile component variables in the user's data */
      local sev_test  /* Used to test for a correct severity variable name prefix in the user's data */
      local num_apc   /* Number of anatomic profile component variables in the user's data */       
      local apc       /* Holds Anatomic Profile components for current diagnosis code variable */
      local sev       /* Holds severity for current diagnosis code variable */


      /* Get arguments for input file, output file, anatomic profile component category variables prefix, severity
         variables prefix, revised trauma score, coded GCS, coded systolic blood pressure, coded respiratory rate,
         maximum severity variable, age, discharge status, blunt/penetrating trauma and the various ASCOT coefficients. */

      args filein fileout p_apc p_sev u_rts u_cgcs u_cbp u_crr u_mxais u_age u_stat u_bpt K0B K1B K2B K3B K4B K5B/*
      */ K6B K7B K0P K1P K2P K3P K4P K5P K6P K7P

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

      /* Check if user entered a correct name for the Revised Trauma Score variable. */

      capture confirm variable `u_rts'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Revised Trauma Score variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the coded GCS variable. */

      capture confirm variable `u_cgcs'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such coded GCS variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the coded Systolic Blood Pressure variable. */

      capture confirm variable `u_cbp'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such coded Systolic Blood Pressure variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the coded Respiratory Rate variable. */

      capture confirm variable `u_crr'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such coded Respiratory Rate variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Maximum Severity variable. */

      capture confirm variable `u_mxais'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Maximum Severity variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Age variable. */

      capture confirm variable `u_age'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Age variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Discharge Status variable. */

      capture confirm variable `u_stat'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Discharge Status variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Blunt\Penetrating Trauma variable. */

      capture confirm variable `u_bpt'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Blunt\Penetrating Trauma variable.  Please try again."
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

      /* Create temporary variables to hold AP component values. */

      for newlist apc_a apc_b apc_c: generate int X = 0

      /* Create variables to hold square root of the sum of squares of AP component category values. */

      for newlist mA mB mC: generate float X = 0
   
      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_apc' {

         /* Generate name of current anatomic profile component category variable. */

         local apc = "`p_apc'" + "`i'"

         /* Generate name of current severity variable. */

         local sev = "`p_sev'" + "`i'"

         /* Update AP component values. */

         replace apc_a = apc_a + (`sev' * `sev') if `apc' == "A" & `sev' != 6
         replace apc_b = apc_b + (`sev' * `sev') if `apc' == "B" & `sev' != 6
         replace apc_c = apc_c + (`sev' * `sev') if `apc' == "C" & `sev' != 6

         local i = `i' + 1
      }

      /* Calculate the square root of the sum of the squares for AP component categories A, B and C. */

      replace mA = sqrt(apc_a)
      replace mB = sqrt(apc_b)
      replace mC = sqrt(apc_c)

      /* Create ASCOT coded Age variable. */

      generate byte acage = .

      /* Create variable to hold KB. */

      generate float KB = .

      /* Create variable to hold KP. */

      generate float KP = .

      /* Create variable to hold ASCOT set aside condition. */

      generate byte aside = 0

      /* Create variable to hold ASCOT survival probability. */

      generate float ps_ascot = .

      /* Update ASCOT set-aside variable for ASCOT set-aside cases. */

      replace aside = 1 if `u_mxais' == 6 & `u_rts' == 0
      replace aside = 2 if `u_mxais' > 0 & `u_mxais' < 6 & `u_rts' == 0
      replace aside = 3 if `u_mxais' == 6 & `u_rts' > 0 & `u_rts' < .
      replace aside = 4 if `u_mxais' > 0 & `u_mxais' <= 2 & `u_rts' > 0 & `u_rts' < .

      /* Update ASCOT set-aside variable if maximum severity equals 0 or 9. */

      replace aside = . if `u_mxais' == 0 | `u_mxais' == 9
 
      /* Determine ASCOT Age code. */

      replace acage = 0 if `u_age' >= 0 &`u_age' <= 54
      replace acage = 1 if `u_age' >= 55 & `u_age' <= 64
      replace acage = 2 if `u_age' >= 65 & `u_age' <= 74
      replace acage = 3 if `u_age' >= 75 & `u_age' <= 84
      replace acage = 4 if `u_age' >= 85 & `u_age' < .      

      /* Determine KB. */

      replace KB = `K0B' + (`K1B' * `u_cgcs') + (`K2B' * `u_cbp') + (`K3B' * `u_crr') + (`K4B' * mA)/*
      */ + (`K5B' * mB) + (`K6B' * mC) + (`K7B' * acage) if `u_bpt' == "B" & `u_cgcs' != ./*
      */ & `u_cbp' != . & `u_crr' != . & acage != . & aside == 0  

      /* Determine KP. */ 
   
      replace KP = `K0P' + (`K1P' * `u_cgcs') + (`K2P' * `u_cbp') + (`K3P' * `u_crr') + (`K4P' * mA)/*
      */ + (`K5P' * mB) + (`K6P' * mC) + (`K7P' * acage) if `u_bpt' == "P" & `u_cgcs' != ./*
      */ & `u_cbp' != . & `u_crr' != . & acage != . & aside == 0      
        
      /* Calculate ASCOT Survival Probability if blunt trauma.   Round to nearest 0.0001. */  

      replace ps_ascot = (round((1/(1 + exp(-KB))), 0.0001)) if `u_bpt' == "B" & KB != .       
      
      /* Calculate ASCOT Survival Probability if penetrating trauma.  Round to nearest 0.0001. */

      replace ps_ascot = (round((1/(1 + exp(-KP))), 0.0001)) if `u_bpt' == "P" & KP != .

      /* Round KB and KP to nearest 0.0001. */

      replace KB = round(KB, 0.0001) if KB != .      
      replace KP = round(KP, 0.0001) if KP != .

      /* Create variable to hold number of survivors for ASCOT set-asides. */

      generate long sa_alive = .

      /* Create variable to hold number of deceased for ASCOT set-asides. */

      generate long sa_died = .



      /*----------------------------------------------------------------------*/
      /*  Calculate ASCOT set-aside survival probabilities for blunt trauma.  */
      /*----------------------------------------------------------------------*/


      /* Max AIS equals 6 and RTS == 0. */

      capture count if aside == 1 & `u_stat' == 0 & `u_bpt' == "B"
      replace sa_alive = r(N) if aside == 1 & `u_bpt' == "B"
      capture count if aside == 1 & `u_stat' == 1 & `u_bpt' == "B"
      replace sa_died = r(N) if aside == 1 & `u_bpt' == "B"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 1 & `u_bpt' == "B"

      /* Max AIS less than 6 and RTS == 0. */

      capture count if aside == 2 & `u_stat' == 0 & `u_bpt' == "B"
      replace sa_alive = r(N) if aside == 2 & `u_bpt' == "B"
      capture count if aside == 2 & `u_stat' == 1 & `u_bpt' == "B"
      replace sa_died = r(N) if aside == 2 & `u_bpt' == "B"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 2 & `u_bpt' == "B"

      /* Max AIS equals 6 and RTS > 0. */

      capture count if aside == 3 & `u_stat' == 0 & `u_bpt' == "B"
      replace sa_alive = r(N) if aside == 3 & `u_bpt' == "B"
      capture count if aside == 3 & `u_stat' == 1 & `u_bpt' == "B"
      replace sa_died = r(N) if aside == 3 & `u_bpt' == "B"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 3 & `u_bpt' == "B"

      /* Max AIS equals 1 or 2 and RTS > 0. */

      capture count if aside == 4 & `u_stat' == 0 & `u_bpt' == "B"
      replace sa_alive = r(N) if aside == 4 & `u_bpt' == "B"
      capture count if aside == 4 & `u_stat' == 1 & `u_bpt' == "B"
      replace sa_died = r(N) if aside == 4 & `u_bpt' == "B"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 4 & `u_bpt' == "B"



      /*----------------------------------------------------------------------------*/
      /*  Calculate ASCOT set-aside survival probabilities for penetrating trauma.  */
      /*----------------------------------------------------------------------------*/


      /* Max AIS equals 6 and RTS == 0. */

      capture count if aside == 1 & `u_stat' == 0 & `u_bpt' == "P"
      replace sa_alive = r(N) if aside == 1 & `u_bpt' == "P"
      capture count if aside == 1 & `u_stat' == 1 & `u_bpt' == "P"
      replace sa_died = r(N) if aside == 1 & `u_bpt' == "P"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 1 & `u_bpt' == "P"
  
      /* Max AIS less than 6 and RTS == 0. */ 

      capture count if aside == 2 & `u_stat' == 0 & `u_bpt' == "P"
      replace sa_alive = r(N) if aside == 2 & `u_bpt' == "P"
      capture count if aside == 2 & `u_stat' == 1 & `u_bpt' == "P"
      replace sa_died = r(N) if aside == 2 & `u_bpt' == "P"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 2 & `u_bpt' == "P"

      /* Max AIS equals 6 and RTS > 0. */

      capture count if aside == 3 & `u_stat' == 0 & `u_bpt' == "P"
      replace sa_alive = r(N) if aside == 3 & `u_bpt' == "P"
      capture count if aside == 3 & `u_stat' == 1 & `u_bpt' == "P"
      replace sa_died = r(N) if aside == 3 & `u_bpt' == "P"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 3 & `u_bpt' == "P"

      /* Max AIS equals 1 or 2 and RTS > 0. */

      capture count if aside == 4 & `u_stat' == 0 & `u_bpt' == "P"
      replace sa_alive = r(N) if aside == 4 & `u_bpt' == "P"
      capture count if aside == 4 & `u_stat' == 1 & `u_bpt' == "P"
      replace sa_died = r(N) if aside == 4 & `u_bpt' == "P"
      replace ps_ascot = (round((sa_alive/(sa_alive + sa_died)), 0.0001)) if aside == 4 & `u_bpt' == "P"

      /* Assign new values to ASCOT survival probability if ASCOT value is equal to 1.0 or 0.0 respectively. */

      replace ps_ascot = 0.9999 if ps_ascot == 1.0000
      replace ps_ascot = 0.0001 if ps_ascot == 0.0000

      /* Set display format for variables mA, mB, mC, KB, KP and ASCOT Survival Probability. */ 

      format mA %07.4f
      format mB %07.4f
      format mC %07.4f
      format KB %06.4f
      format KP %06.4f
      format ps_ascot %06.4f

      /* Delete temporary variables apc_a apc_b apc_c. */

      drop apc_a apc_b apc_c

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end

