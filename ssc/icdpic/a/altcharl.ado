/* Revised 10/15/2010 */
/* Version 3.0 */ 



/*--------------------------------------------------------------------------------------------------------------------*/
/*  Program to add to the user's data variables indicating the presence of Charlson comorbidities, the number of      */
/*  Charlson comorbidities present and the Charlson score.                                                            */
/*                                                                                                                    */
/*  Comorbidity weights are assigned per Charlson^ (1987).  Charlson comorbidities are as modified by Romano# (1993)  */
/*  for surgical admissions.  Comorbidity diagnostic categories are included if and only if they include diagnosis    */
/*  codes identified by Romano with an asterisk in Table 1 under the column Dartmouth-Manitoba codes.  Within these   */
/*  included categories, only diagnosis or procedure codes with asterisks are included.                               */
/*                                                                                                                    */
/*  For a more standardized treatment of the Charlson index, with options that include ICD-9-CM, ICD-10-CM and        */
/*  enhanced ICD-9-CM versions, the user is encouraged to type "findit charlson" from within STATA without the        */
/*  quotation marks. STATA will locate this module on the Internet.  Just follow the instructions given to download   */
/*  it.                                                                                                               */
/*                                                                                                                    */
/*  ^Charlson ME, Pompei P, Ales KL, MacKenzie CR.  A new method of classifying prognostic comorbidity in             */
/*  longitudinal studies:  Development and validation.  Journal of Chronic Disease 1987; 40:373.                      */
/*  #Romano PS, Roos LL, Jollis JG.  Adapting a clinical comorbidity index for use with ICD-9-CM administrative       */
/*  data:  Differing perspectives.  Journal of Clinical Epidemiology 1993; 46:1075                                    */
/*--------------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be       */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0       */
/*  requires STATA 8.0 or higher.                                                                                     */
/*--------------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Diagnosis and procedure code tables have been updated to reflect new codes within above specified ranges.   */
/*  No attempt has been made to identify and include individual codes that may be applicable.                         */
/*--------------------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program altcharl can be run by typing "db altcharl", without the quotation marks, or running the ICDPIC     */
/*  program and choosing "Charlson Score\Comorbidities (Alternate Version)" from the ICDPIC dialog box.               */
/*--------------------------------------------------------------------------------------------------------------------*/


program define altcharl
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i             /* Index */
      local j             /* Index */
      scalar numrecs = 0  /* Number of observations */
      scalar missing = 0  /* Number of observations with missing values for a given variable */
      local dx_test       /* Used to test for the number of diagnosis code variables in the user's data */
      local px_test       /* Used to test for the number of procedure code variables in the user's data */
      local num_dx        /* Number of diagnosis code variables in the user's data */
      local num_px        /* Number of procedure code variables in the user's data */                
      local curr_dx       /* Holds name of current diagnosis code variable */
      local curr_px       /* Holds name of current procedure code variable */
      local p1 dx         /* Merge variable name for diagnosis codes */
      local p2 px         /* Merge variable name for procedure codes */


      /* Get arguments for input file, output file, switch to indicate N-Code and P-Code format, and diagnosis and
         procedure code prefixes.                                                                                  */

      args filein fileout switch dx_pre px_pre

      /* Input data and clear old data out of memory. */

      use "`filein'", clear

      /* Preserve user's data. */

      preserve 

      /* Check if user entered a correct prefix for the diagnosis code variables. */

      local dx_test = "`dx_pre'" + "1"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code prefix.  Please try again."
         exit
      }

      /* Check if user entered a correct prefix for the procedure code variables. */

      local px_test = "`px_pre'" + "1"
      capture confirm variable `px_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such procedure code prefix.  Please try again."
         exit
      }

      /* Create Charlson comorbidity variables and number of Charlson comorbidities present variable. */

      for newlist mi pvd dementia copd rheum mld sld mdm ccdm renal any_mal mst aids charlcnt: generate byte X = 0

      /* Create Charlson score variable. */

      generate byte charlval = .

      /* Get number of observations. */
 
      scalar numrecs = _N

      /* If the data contains no observations. */

      if numrecs == 0 {
         capture window stopbox stop "Data contains no observations."
         exit
      }

      /* Determine how many diagnosis code variables there are in the data. */

      local i = 1

      while 1 {
         local dx_test = "`dx_pre'" + "`i'"
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

      /* Determine how many procedure code variables there are in the data. */

      local i = 1

      while 1 {
         local px_test = "`px_pre'" + "`i'"
         capture confirm variable `px_test'
         if _rc != 111 {
            local i = `i' + 1
         }
         else {
            local i = `i' - 1
            continue, break
         }
      }

      /* Assign number of procedure codes. */

      local num_px = `i'

      /* Create temporary variable to hold record number. */

      generate long rec_no = _n

      local i = 1

      /* While index number is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_dx' {

         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`dx_pre'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)

         /* Rename current diagnosis code variable to the diagnosis code variable name in the diagnosis code table. */

         rename `curr_dx' `p1'
 
         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `p1'

            /* Merge with Charlson diagnosis code table. */
      
            if `switch' == 1 {
               capture findfile cdtab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File cdtab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile cdtab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File cdtab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p1' using `"`r(fn)'"', nokeep
               }
            }

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename merge variable back to its original name. */

            rename `p1' `curr_dx'

            /* Check for myocardial infarction. */

            replace mi = 1 if charlson == 1

            /* Check for peripheral vascular disease. */

            replace pvd = 1 if charlson == 2

            /* Check for dementia. */

            replace dementia = 1 if charlson == 3

            /* Check for chronic obstructive pulmonary disease. */

            replace copd = 1 if charlson == 4

            /* Check for rheumotologic disease. */

            replace rheum = 1 if charlson == 5

            /* Check for mild liver disease. */

            replace mld = 1 if charlson == 6

            /* Check for moderate to severe liver disease. */

            replace sld = 1 if charlson == 7

            /* Check for mild to moderate diabetes mellitus. */

            replace mdm = 1 if charlson == 8

            /* Check for chronic complications of diabetes mellitus. */

            replace ccdm = 1 if charlson == 9

            /* Check for renal disease. */

            replace renal = 1 if charlson == 10

            /* Check for any malignancy. */

            replace any_mal = 1 if charlson == 11

            /* Check for metastatic solid tumor. */

            replace mst = 1 if charlson == 12

            /* Check for AIDS. */

            replace aids = 1 if charlson == 13

            /* Drop variable charlson added by the merge process. */
         
            drop charlson
         }
         else {

            /* Rename merge variable back to its original name. */

            rename `p1' `curr_dx'
         }
         local i = `i' + 1
      }

      local j = 1

      /* While index number is less than or equal to maximum number of procedure codes. */

      while `j' <= `num_px' {

         /* Generate name of current procedure code variable. */

         local curr_px = "`px_pre'" + "`j'"

         /* Get number of missing observations for the current procedure code variable. */

         capture count if `curr_px' == ""
         scalar missing = r(N)

         /* Rename current procedure code variable to the procedure code variable name in the procedure code table. */

         rename `curr_px' `p2'
 
         /* Process current procedure code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on current renamed procedure code variable. */

            sort `p2'

            /* Merge with Charlson procedure code table. */
      
            if `switch' == 1 {
               capture findfile cptab_s1.dta
               if _rc == 601 {
                  window stopbox stop "File cptab_s1.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p2' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile cptab_s2.dta
               if _rc == 601 {
                  window stopbox stop "File cptab_s2.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p2' using `"`r(fn)'"', nokeep
               }
            }

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename merge variable back to its original name. */

            rename `p2' `curr_px'

            /* Check for myocardial infarction. */

            replace mi = 1 if charlson == 1

            /* Check for peripheral vascular disease. */

            replace pvd = 1 if charlson == 2

            /* Check for dementia. */

            replace dementia = 1 if charlson == 3

            /* Check for chronic obstructive pulmonary disease. */

            replace copd = 1 if charlson == 4

            /* Check for rheumotologic disease. */

            replace rheum = 1 if charlson == 5

            /* Check for mild liver disease. */

            replace mld = 1 if charlson == 6

            /* Check for moderate to severe liver disease. */

            replace sld = 1 if charlson == 7

            /* Check for mild to moderate diabetes mellitus. */

            replace mdm = 1 if charlson == 8

            /* Check for chronic complications of diabetes mellitus. */

            replace ccdm = 1 if charlson == 9

            /* Check for renal disease. */

            replace renal = 1 if charlson == 10

            /* Check for any malignancy. */

            replace any_mal = 1 if charlson == 11

            /* Check for metastatic solid tumor. */

            replace mst = 1 if charlson == 12

            /* Check for AIDS. */

            replace aids = 1 if charlson == 13

            /* Drop variable charlson added by the merge process. */

            drop charlson
         }
         else {

            /* Rename merge variable back to its original name. */

            rename `p2' `curr_px'
         }
         local j = `j' + 1
      }

      /* Set mild liver disease to FALSE if moderate to severe liver disease is TRUE. */
 
      replace mld = 0 if sld == 1

      /* Set mild to moderate diabetes mellitus to FALSE if chronic complications of diabetes mellitus is TRUE. */

      replace mdm = 0 if ccdm == 1

      /* Set any malignancy to FALSE if metastatic solid tumor is TRUE. */

      replace any_mal = 0 if mst == 1

      /* Calculate number of Charlson comorbidities present. */

      replace charlcnt = mi + pvd + dementia + copd + rheum + mld + sld + mdm + ccdm + renal + any_mal + mst + aids

      /* Calculate Charlson score. */

      replace charlval = mi + pvd + dementia + copd + rheum + mld + mdm + (renal * 2) + (ccdm * 2) + (any_mal * 2) +/*
      */ (sld * 3) + (mst * 6) + (aids * 6)

      /* Sort table on num_rec variable. */

      sort rec_no

      /* Delete temporary variable rec_no. */ 

      drop rec_no

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end

