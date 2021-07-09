/* Revised 10/16/2010 */
/* Version 3.0 */  



/*-------------------------------------------------------------------------------------------------------------------*/
/*  Program to compute TRISS survival probability.  The user should first run program trauma (or choose "ICD-9-CM    */
/*  Trauma" from the ICDPIC dialog box) on his/her data to add injury severity score and blunt/penetrating trauma    */
/*  variables to their data.  The user should then run his/her data through program rts (or choose "Revised Trauma   */
/*  Score" from the ICDPIC dialog box) to add the revised trauma score variable.  Finally, the user's data should    */
/*  contain a variable for age of type integer.                                                                      */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be      */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0      */
/*  requires STATA 8.0 or higher.                                                                                    */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: TRISS coefficients are the original MTOS weights.  If the user has their own database and wishes to        */
/*  calculate their own weights or use weights provided by others, they need only to substitute those weights in     */
/*  the dialog box.                                                                                                  */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: This TRISS algorithm makes no distinction between adult and pediatric patients.                            */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Variables JB and JP are rounded to the nearest 0.0001.                                                     */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: TRISS probabilities are rounded to the nearest 0.0001.  TRISS probabilities that are equal, or round to,   */
/*  0.0000 or 1.0000 are replaced with 0.0001 and 0.9999 respectively.                                               */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program triss can be run by typing "db triss", without the quotation marks, or running the ICDPIC program  */
/*  and choosing "TRISS" from the ICDPIC dialog boxes.                                                               */
/*-------------------------------------------------------------------------------------------------------------------*/


program define triss
   version 8.0
   quietly {

      /* Get arguments for input file, output file, revised trauma score, injury severity score, blunt\penetrating
         trauma and the various TRISS coefficients.                                                                */

      args filein fileout u_rts u_iss u_age u_bpt J0B J1B J2B J3B J0P J1P J2P J3P

      /* Input data and clear old data out of memory. */ 

      use "`filein'", clear

      /* Preserve user's data. */
 
      preserve 

      /* Check if user entered a correct name for Revised Trauma Score variable. */

      capture confirm variable `u_rts'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Revised Trauma Score variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Injury Severity Score variable. */

      capture confirm variable `u_iss'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Injury Severity Score variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Age variable. */

      capture confirm variable `u_age'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Age variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Blunt\Penetrating Trauma variable. */

      capture confirm variable `u_bpt'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Blunt\Penetrating Trauma variable.  Please try again."
         exit
      }

      /* Create TRISS coded Age variable. */

      generate byte tcage = .

      /* Create temporary variable to hold JB. */

      generate float JB = .

      /* Create temporary variable to hold JP. */

      generate float JP = .

      /* Create TRISS Survival Probability variable. */

      generate float ps_triss = .

      /* Determine TRISS Age code. */

      replace tcage = 0 if `u_age' >= 0 & `u_age' <= 54
      replace tcage = 1 if `u_age' > 54 & `u_age' < .

      /* Determine JB and JP. */ 

      replace JB = `J0B' + (`J1B' * `u_rts') + (`J2B' * `u_iss') + (`J3B' * tcage) if `u_bpt' == "B" & `u_rts' != . & `u_iss' > 0/*
      */ & `u_iss' <= 75 & tcage != .
      
      replace JP = `J0P' + (`J1P' * `u_rts') + (`J2P' * `u_iss') + (`J3P' * tcage) if `u_bpt' == "P" & `u_rts' != . & `u_iss' > 0/*
      */ & `u_iss' <= 75 & tcage != .
      
      /* Calculate TRISS Survival Probability if blunt trauma.  Round to nearest 0.0001. */

      replace ps_triss = (round((1/(1 + exp(-JB))), 0.0001)) if `u_bpt' == "B" & JB != .
      
      /* Calculate TRISS Survival Probability if penetrating trauma.  Round to nearest 0.0001. */

      replace ps_triss = (round((1/(1 + exp(-JP))), 0.0001)) if `u_bpt' == "P" & JP != .

      /* Round JB and JP to nearest 0.0001. */

      replace JB = round(JB, 0.0001) if JB != .      
      replace JP = round(JP, 0.0001) if JP != .
 
      /* Assign new values to TRISS survival probability if TRISS value is equal to 1.0 or 0.0 respectively. */

      replace ps_triss = 0.9999 if ps_triss == 1.0000
      replace ps_triss = 0.0001 if ps_triss == 0.0000
 
      /* Set display format for variables for Revised Trauma Score, JB, JP, and TRISS Survival Probability. */ 

      format JB %06.4f
      format JP %06.4f
      format ps_triss %06.4f

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end


