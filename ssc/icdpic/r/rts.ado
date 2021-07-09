/* Revised 10/16/2010 */
/* Version 3.0 */



/*-------------------------------------------------------------------------------------------------------------*/
/*  Program to compute the Revised Trauma Score (RTS).  The user's data should contain GCS, systolic blood     */
/*  pressure and respiratory rate variables of type integer.  The user's data may also contain an optional     */
/*  inclusion variable.  This variable should be of type byte and take on the values 0 and 1.  0 to exclude    */
/*  an observation from having RTS calculated and 1 to include it.                                             */
/*                                                                                                             */
/*  RTS will not be calculated if GCS, systolic blood pressure, respiratory rate or the include variable (if   */
/*  this option is chosen) contain missing values.                                                             */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may   */
/*  be downloaded from the SSC archives website or installed from within STATA using the ssc command.          */
/*  Version 3.0 requires STATA 8.0 or higher.                                                                  */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: RTS coefficients are the original MTOS weights.  If the user has their own database and wishes to    */
/*  calculate their own weights or use weights provided by others, they need only to substitute those weights  */
/*  in the dialog box.                                                                                         */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: RTS is rounded to the nearest 0.0001.                                                                */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program rts of ICDPIC produces a variable necessary for program triss of ICDPIC.  This variable      */
/*  is revised trauma score (rts).  The user may rename this variable, but if he/she intends on running the    */
/*  results of program rts through program triss, he/she should not delete it.                                 */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program rts of ICDPIC produces variables necessary for program ascot of ICDPIC.  These variables     */
/*  are revised trauma score (rts), coded GCS (cgcs), coded systolic blood pressure (cbp) and coded respir-    */
/*  atory rate (crr).  The user may rename these variables, but if he/she intends on running the results of    */
/*  program rts through program ascot, he/she should not delete them.                                          */
/*-------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program rts can be run by typing "db rts", without the quotation marks, or running the ICDPIC        */
/*  program and choosing "Revised Trauma Score" from the ICDPIC dialog box.                                    */
/*-------------------------------------------------------------------------------------------------------------*/


program define rts
   version 8.0
   quietly {
      
      /* Define local macros and scalars. */

      local inc_var  /* Copy of name of user's RTS inclusion variable */
      
      /* Get arguments for input file, output file, GCS variable name, systolic blood pressure variable name,
         respiratory rate variable name, RTS inclusion variable name and coefficients for GCS, systolic blood
         pressure and respiratory rate.                                                                       */

      args filein fileout switch u_gcs u_bp u_rr u_inc A1 A2 A3

      /* Input data and clear old data out of memory. */ 

      use "`filein'", clear

      /* Preserve user's data. */

      preserve 

      /* Check if user entered a correct name for the GCS variable. */

      capture confirm variable `u_gcs'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such GCS variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Systolic Blood Pressure variable. */

      capture confirm variable `u_bp'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Systolic Blood Pressure variable.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Respiratory Rate variable. */

      capture confirm variable `u_rr'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Respiratory Rate variable.  Please try again."
         exit
      }

      if `switch' == 2 {

         /* Check if user entered a correct name for RTS Inclusion variable. */
   
         capture confirm variable `u_inc'
         if _rc == 111 | _rc == 198 {
            window stopbox stop "No such RTS Inclusion variable.  Please try again."
            exit
         }
      }

      /* Create coded GCS variable. */

      generate byte cgcs = .

      /* Create coded Systolic Blood Pressure variable. */

      generate byte cbp = .

      /* Create coded Respiratory Rate variable. */

      generate byte crr = .

      /* Create Revised Trauma Score variable. */

      generate float rts = .

      if "`u_inc'" == "" {

         /* Determine GCS code. */

         replace cgcs = 4 if `u_gcs' >= 13 & `u_gcs' <= 15
         replace cgcs = 3 if `u_gcs' >= 9 & `u_gcs' <= 12
         replace cgcs = 2 if `u_gcs' >= 6 & `u_gcs' <= 8
         replace cgcs = 1 if `u_gcs' >= 4 & `u_gcs' <= 5
         replace cgcs = 0 if `u_gcs' == 3

         /* Determine Systolic Blood Pressure code. */

         replace cbp = 4 if `u_bp' > 89 & `u_bp' < .
         replace cbp = 3 if `u_bp' >= 76 & `u_bp' <= 89
         replace cbp = 2 if `u_bp' >= 50 & `u_bp' <= 75
         replace cbp = 1 if `u_bp' >= 1 & `u_bp' <= 49
         replace cbp = 0 if `u_bp' == 0

         /* Determine Respiratory Rate code. */

         replace crr = 4 if `u_rr' >= 10 & `u_rr' <= 29
         replace crr = 3 if `u_rr' > 29 & `u_rr' < .
         replace crr = 2 if `u_rr' >= 6 & `u_rr' <= 9
         replace crr = 1 if `u_rr' >= 1 & `u_rr' <= 5
         replace crr = 0 if `u_rr' == 0
         }
      
      else if "`u_inc'" != "" {

         /* Determine GCS code. */

         replace cgcs = 4 if `u_gcs' >= 13 & `u_gcs' <= 15 & `u_inc' == 1
         replace cgcs = 3 if `u_gcs' >= 9 & `u_gcs' <= 12 & `u_inc' == 1
         replace cgcs = 2 if `u_gcs' >= 6 & `u_gcs' <= 8 & `u_inc' == 1
         replace cgcs = 1 if `u_gcs' >= 4 & `u_gcs' <= 5 & `u_inc' == 1
         replace cgcs = 0 if `u_gcs' == 3 & `u_inc' == 1

         /* Determine Systolic Blood Pressure code. */

         replace cbp = 4 if `u_bp' > 89 & `u_bp' < . & `u_inc' == 1
         replace cbp = 3 if `u_bp' >= 76 & `u_bp' <= 89 & `u_inc' == 1
         replace cbp = 2 if `u_bp' >= 50 & `u_bp' <= 75 & `u_inc' == 1
         replace cbp = 1 if `u_bp' >= 1 & `u_bp' <= 49 & `u_inc' == 1
         replace cbp = 0 if `u_bp' == 0 & `u_inc' == 1

         /* Determine Respiratory Rate code. */

         replace crr = 4 if `u_rr' >= 10 & `u_rr' <= 29 & `u_inc' == 1
         replace crr = 3 if `u_rr' > 29 & `u_rr' < . & `u_inc' == 1
         replace crr = 2 if `u_rr' >= 6 & `u_rr' <= 9 & `u_inc' == 1
         replace crr = 1 if `u_rr' >= 1 & `u_rr' <= 5 & `u_inc' == 1
         replace crr = 0 if `u_rr' == 0 & `u_inc' == 1
      }

      /* Calculate Revised Trauma Score. */

      if "`u_inc'" == "" {

         replace rts = (`A1' * cgcs) + (`A2' * cbp) + (`A3' * crr) if cgcs != . & cbp != . & crr != .
      }

      else if "`u_inc'" != "" {

         replace rts = (`A1' * cgcs) + (`A2' * cbp) + (`A3' * crr) if cgcs != . & cbp != . & crr != . & `u_inc' == 1
      }

      /* Round rts to nearest 0.0001. */

      replace rts = (round(((`A1' * cgcs) + (`A2' * cbp) + (`A3' * crr)), 0.0001)) if cgcs != . & cbp != . & crr != .

      /* Set display format for Revised Trauma Score. */ 

      format rts %06.4f

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end

