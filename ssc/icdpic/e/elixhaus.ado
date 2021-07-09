/* Revised 10/15/2010 */
/* Version 3.0 */ 
  


/*-------------------------------------------------------------------------------------------------------------------*/
/*  Program to add to the user's data, variables indicating the presence of Elixhauser comorbidities and the number  */
/*  of Elixhauser comorbidities present.  The user's data should contain a numerical variable with Diagnosis         */
/*  Related Group (DRG) information.                                                                                 */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be      */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0      */
/*  requires STATA 8.0 or higher.                                                                                    */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE:  This program is a STATA interpretation of SAS software found on the Healthcare Cost and Utilization       */
/*  Project (HCUP) website:  http://www.hcup-us.ahrq.gov/toolssoftware/comorbidity/comorbidity.jsp#download.  It     */
/*  uses data on comorbidity categories, comorbidity diagnosis codes and DRG codes found on their website.  This     */
/*  data is valid through September 30, 2008.  This data may differ from that found in Elixhauser's original         */
/*  article.  Notably, Elixhauser's second comorbidity category of Cardiac Arrhythmias has been dropped.  Congest-   */
/*  ive Heart Failure, Complicated Hypertension and Renal Failure comorbidity categories no longer have mutually     */
/*  exclusive diagnosis codes.  Numerous diagnosis codes and DRG codes have been added to comorbidity categories,    */
/*  while a few others have been dropped.  This program is only valid for use with DRG's prior to Version 25.        */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Variables representing Elixhauser's comorbidity categories are numbered in order, elix1-elix30.  The       */
/*  user will notice the absence of variable elix2, which represents the Cardiac Arrhythmias category which is not   */
/*  included in this program.  See note above.                                                                       */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Variables elix6A and elix6B represent the existence of hypertension, uncomplicated and complicated         */
/*  respectively, before combining into the hypertension, combined, category elix6.                                  */
/*-------------------------------------------------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program elixhaus can be run by typing "db elixhaus", without the quotation marks, or running the ICDPIC    */
/*  program and choosing "Elixhauser Comorbidities" from the ICDPIC dialog box.                                      */
/*-------------------------------------------------------------------------------------------------------------------*/


program define elixhaus
   version 8.0
   quietly {

      /* Define local macros and scalars. */

      local i             /* Index */
      scalar missing = 0  /* Number of observations with missing values for a given variable */
      local dx_test       /* Used to test for the number of diagnosis code variables in the user's data */
      local num_dx        /* Number of diagnosis code variables in the user's data */        
      local curr_dx       /* Holds name of current diagnosis code variable */
      local p1 drgroup    /* Merge variable name used with diagnosis related group (DRG) table */
      local p2 dx         /* Merge variable name used with Elixhauser table */


      /* Get arguments for input file, output file, switch to indicate N-Code format, diagnosis code prefix and
         diagnosis related group.                                                                               */

      args filein fileout switch p_user drg_user

      /* Input data and clear old data out of memory. */

      use "`filein'", clear

      /* Preserve user's data. */

      preserve

      /* Check if user entered a correct prefix for the diagnosis code variables. */

      local dx_test = "`p_user'" + "1"
      capture confirm variable `dx_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such diagnosis code prefix.  Please try again."
         exit
      }

      /* Check if user entered a correct name for the Diagnosis Related Group variable. */

      capture confirm variable `drg_user'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such Diagnosis Related Group variable.  Please try again."
         exit
      }

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

      /* Create Elixhauser comorbidity variables and number of Elixhasuer comorbidities present variable. */

      for newlist elix1 elix3 elix4 elix5 elix6 elix6A elix6B elix7 elix8 elix9 elix10 elix11 elix12 elix13 elix14/*
      */ elix15 elix16 elix17 elix18 elix19 elix20 elix21 elix22 elix23 elix24 elix25 elix26 elix27 elix28 elix29/*
      */ elix30 elix_cnt: generate byte X = 0

      /* Create temporary variable, temp_6B, to hold temporary values for the elix6B variable. */

      generate byte temp_6B = 99

      /* Create temporary variable to hold record number. */

      generate long rec_no = _n

      /* Rename diagnosis related group variable to that used in the diagnosis related group (DRG) table. */

      rename `drg_user' `p1'

      /* Sort table in memory on current renamed diagnosis related group (DRG) variable. */

      sort `p1'

      /* Merge with diagnosis related group table. */

      capture findfile drgtab_h.dta
      if _rc == 601 {
         window stopbox stop "File drgtab_h.dta not found.  This file must be in one of the ado path directories."
         exit
      }
      else {
         merge `p1' using `"`r(fn)'"', nokeep
      }

      /* Delete the _merge variable created by the merge process. */

      drop _merge

      /* Rename merge variable back to its original name. */

      rename `p1' `drg_user'

      local i = 2

      /* While index number value is less than or equal to maximum number of diagnosis codes. */
                                                  
      while `i' <= `num_dx' {

         /* Generate name of current diagnosis code variable. */

         local curr_dx = "`p_user'" + "`i'"

         /* Get number of missing observations for the current diagnosis code variable. */

         capture count if `curr_dx' == ""
         scalar missing = r(N)

         /* Rename current diagnosis code variable to the diagnosis code variable name in the Elixhauser table. */

         rename `curr_dx' `p2'

         /* Process current diagnosis code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on current renamed diagnosis code variable. */

            sort `p2'

            /* Merge with Elixhauser diagnosis code table. */
      
            if `switch' == 1 {
               capture findfile xtab_s1h.dta
               if _rc == 601 {
                  window stopbox stop "File xtab_s1h.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p2' using `"`r(fn)'"', nokeep
               }
            }
            else if `switch' == 2 {
               capture findfile xtab_s2h.dta
               if _rc == 601 {
                  window stopbox stop "File xtab_s2h.dta not found.  This file must be in one of the ado path directories."
                  exit
               }
               else {
                  merge `p2' using `"`r(fn)'"', nokeep
               }
            }

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename merge variable back to its original name. */

            rename `p2' `curr_dx'

            /* Check for congestive heart failure. */

            replace elix1 = 1 if elixhaus == "1" | elixhaus == "6B2" | elixhaus == "6B6" | elixhaus == "6B8"

            /* Check for valvular disease. */

            replace elix3 = 1 if elixhaus == "3"

            /* Check for pulmonary circulation disorders. */

            replace elix4 = 1 if elixhaus == "4"

            /* Check for peripheral vascular disorders. */

            replace elix5 = 1 if elixhaus == "5"

            /* Check for hypertension, uncomplicated. */

            replace elix6A = 1 if elixhaus == "6A"

            /* Check for hypertension, complicated. */

            replace elix6B = 1 if substr(elixhaus, 1, 2) == "6B"

            /* Generate temporary values for hypertension, complicated. */

            replace temp_6B = real(substr(elixhaus, 3, 1)) if substr(elixhaus, 1, 2) == "6B"

            /* Check for paralysis. */

            replace elix7 = 1 if elixhaus == "7"

            /* Check for other neurological disorders. */

            replace elix8 = 1 if elixhaus == "8"

            /* Check for chronic pulmonary disease. */

            replace elix9 = 1 if elixhaus == "9"

            /* Check for diabetes, uncomplicated. */

            replace elix10 = 1 if elixhaus == "10"

            /* Check for diabetes, complicated. */

            replace elix11 = 1 if elixhaus == "11"

            /* Check for hypothyroidism. */

            replace elix12 = 1 if elixhaus == "12"

            /* Check for renal failure. */

            replace elix13 = 1 if elixhaus == "13" | elixhaus == "6B4" | elixhaus == "6B7" | elixhaus == "6B8"

            /* Check for liver disease. */

            replace elix14 = 1 if elixhaus == "14"

            /* Check for peptic ulcer disease, excluding bleeding. */

            replace elix15 = 1 if elixhaus == "15"

            /* Check for AIDS. */

            replace elix16 = 1 if elixhaus == "16"

            /* Check for lymphoma. */

            replace elix17 = 1 if elixhaus == "17"

            /* Check for metastatic cancer. */

            replace elix18 = 1 if elixhaus == "18"

            /* Check for solid tumor. */

            replace elix19 = 1 if elixhaus == "19"

            /* Check for rheumatoid arthritis/collagen vascular diseases. */

            replace elix20 = 1 if elixhaus == "20"

            /* Check for coagulopathy. */

            replace elix21 = 1 if elixhaus == "21"

            /* Check for obesity. */

            replace elix22 = 1 if elixhaus == "22"

            /* Check for weight loss. */

            replace elix23 = 1 if elixhaus == "23"

            /* Check for fluid and electrolyte disorders. */

            replace elix24 = 1 if elixhaus == "24"

            /* Check for blood loss anemia. */

            replace elix25 = 1 if elixhaus == "25"

            /* Check for deficiency anemias. */

            replace elix26 = 1 if elixhaus == "26"

            /* Check for alcohol abuse. */

            replace elix27 = 1 if elixhaus == "27"

            /* Check for drug abuse. */

            replace elix28 = 1 if elixhaus == "28"

            /* Check for psychoses. */

            replace elix29 = 1 if elixhaus == "29"

            /* Check for depression. */

            replace elix30 = 1 if elixhaus == "30"

            /* Drop variable elixhaus added by the merge process. */
         
            drop elixhaus
         }
         else {

            /* Rename merge variable back to its original name. */

            rename `p2' `curr_dx'
         }
         local i = `i' + 1
      }

      /* Update for congestive heart failure with cardiac DRG. */

      replace elix1 = 0 if drg_cat == "A"

      /* Update for valvular disease with cardiac DRG. */

      replace elix3 = 0 if drg_cat == "A"

      /* Update for pulmonary circulation disorders with cardiac or COPD or asthma DRG's. */

      replace elix4 = 0 if drg_cat == "A" | drg_cat == "B" | drg_cat == "G"

      /* Update for peripheral vascular disorders with peripheral vascular DRG. */

      replace elix5 = 0 if drg_cat == "C"

      /* Update for hypertension, uncomplicated, with hypertension DRG. */

      replace elix6A = 0 if drg_cat == "D"



      /*-------------------------------------------------------------------------------------------------------*/
      /*  Begin update for hypertension, complicated, with hypertension or cardiac or renal DRG combinations.  */
      /*-------------------------------------------------------------------------------------------------------*/


      /* Hypertension, complicated, or pre-existing hypertension complicating pregnancy with hypertension,
         complicated, DRG.                                                                                 */

      replace elix6B = 0 if (temp_6B == . | temp_6B == 0) & (drg_cat == "D" | drg_cat == "DF")

      /* Hypertensive heart disease, with or without heart failure, with cardiac or hypertension, complicated, DRG's. */
 
      replace elix6B = 0 if (temp_6B == 1 | temp_6B == 2) & (drg_cat == "A" | drg_cat == "D" | drg_cat == "DF")

      /* Hypertensive renal disease, with or without renal failure, with renal failure with kidney transplant or
         renal failure/dialysis or hypertension, complicated, DRG's.                                             */

      replace elix6B = 0 if (temp_6B == 3 | temp_6B == 4) & (drg_cat == "Z" | drg_cat == "KZ" | drg_cat == "LZ" |/*
      */ drg_cat == "QZ" | drg_cat == "D" | drg_cat == "DF")

      /* Hypertensive heart and renal disease, without heart or renal failure, or with heart failure only, or
         with renal failure only, or with both heart and renal failure, or other hypertension in pregnancy with
         cardiac or renal failure with kidney transplant or renal failure/dialysis or hypertension, complicated, DRG's. */
   
      replace elix6B = 0 if (temp_6B == 5 | temp_6B == 6 | temp_6B == 7 | temp_6B == 8 | temp_6B == 9) &/*
      */ (drg_cat == "A" | drg_cat == "Z" | drg_cat == "KZ" | drg_cat == "LZ" | drg_cat == "QZ" | drg_cat == "D" |/*
      */ drg_cat == "DF")

      /* Hypertensive renal disease with renal failure, hypertensive heart and renal disease with renal failure or
         hypertensive heart and renal disease, with heart and renal failure.                                       */

      replace elix13 = 0 if (temp_6B == 4 | temp_6B == 7 | temp_6B == 8) & (drg_cat == "Z" | drg_cat == "KZ" |/*
      */ drg_cat == "LZ" | drg_cat == "QZ")



      /*-----------------------------------------------------------------------------------------------------*/
      /*  End update for hypertension, complicated, with hypertension or cardiac or renal DRG combinations.  */
      /*-----------------------------------------------------------------------------------------------------*/


      /* Update for paralysis with cerebrovascular DRG. */

      replace elix7 = 0 if drg_cat == "EF"

      /* Update for other neurological disorders with nervous system DRG. */

      replace elix8 = 0 if drg_cat == "DF" | drg_cat == "EF" | drg_cat == "F" | drg_cat == "FQ"

      /* Update for chronic pulmonary disease with COPD or asthma DRG's. */

      replace elix9 = 0 if drg_cat == "B" | drg_cat == "G"

      /* Update for diabetes, uncomplicated, with diabetes DRG. */

      replace elix10 = 0 if drg_cat == "H"

      /* Update for diabetes, complicated, with diabetes DRG. */

      replace elix11 = 0 if drg_cat == "H"

      /* Update for hypothyroidism with thyroid or endocrine DRG's. */

      replace elix12 = 0 if drg_cat == "I" | drg_cat == "J"

      /* Update for renal failure with kidney transplant or renal failure/dialysis DRG's. */

      replace elix13 = 0 if drg_cat == "LZ" | drg_cat == "KZ"

      /* Update for liver disease with liver DRG. */

      replace elix14 = 0 if drg_cat == "M" | drg_cat == "MQ"

      /* Update for peptic ulcer disease, excluding bleeding, with GI hemorrhage or ulcer DRG. */

      replace elix15 = 0 if drg_cat == "N"

      /* Update for AIDS with HIV DRG. */

      replace elix16 = 0 if drg_cat == "O"

      /* Update for lymphoma with leukemia/lymphoma DRG. */

      replace elix17 = 0 if drg_cat == "P" | drg_cat == "PQ"

      /* Update for metastatic cancer with cancer DRG. */

      replace elix18 = 0 if drg_cat == "FQ" | drg_cat == "MQ" | drg_cat == "PQ" | drg_cat == "Q"/*
      */ | drg_cat == "QZ"

      /* Update for solid tumor with metastasis with cancer DRG. */

      replace elix19 = 0 if drg_cat == "FQ" | drg_cat == "MQ" | drg_cat == "PQ" | drg_cat == "Q"/*
      */ | drg_cat == "QZ"

      /* Update for rheumatoid arthritis/collagen vascular diseases with connective tissue DRG. */

      replace elix20 = 0 if drg_cat == "R"

      /* Update for coagulopathy with coagulation DRG. */

      replace elix21 = 0 if drg_cat == "S"

      /* Update for obesity with obesity procedure or nutrition/metabolic DRG's. */

      replace elix22 = 0 if drg_cat == "T" | drg_cat == "U"

      /* Update for weight loss with nutrition/metabolic DRG. */

      replace elix23 = 0 if drg_cat == "U"

      /* Update for fluid and electrolyte disorders with nutrition/metabolic DRG. */

      replace elix24 = 0 if drg_cat == "U"

      /* Update for blood loss anemia with anemia DRG. */

      replace elix25 = 0 if drg_cat == "V"

      /* Update for deficiency anemias with anemia DRG. */

      replace elix26 = 0 if drg_cat == "V"

      /* Update for alcohol abuse with alcohol or drug DRG. */

      replace elix27 = 0 if drg_cat == "W"

      /* Update for drug abuse with alcohol or drug DRG. */

      replace elix28 = 0 if drg_cat == "W"

      /* Update for psychoses with psychoses DRG. */

      replace elix29 = 0 if drg_cat == "X"

      /* Update for depression with depression DRG. */

      replace elix30 = 0 if drg_cat == "Y"

      /* Set uncomplicated hypertension to FALSE if complicated hypertension is TRUE. */

      replace elix6A = 0 if elix6B == 1

      /* Set uncomplicated diabetes to FALSE if complicated diabetes is TRUE. */

      replace elix10 = 0 if elix11 == 1

      /* Set solid tumor without metastasis to FALSE if metastatic cancer is TRUE. */

      replace elix19 = 0 if elix18 == 1

      /* Combine hypertension without complications and hypertension with complications. */

      replace elix6 = 1 if elix6A == 1 | elix6B == 1

      /* Calculate number of Elixhauser comorbidities present. */

      replace elix_cnt = elix1 + elix3 + elix4 + elix5 + elix6 + elix7 + elix8 + elix9 + elix10 +/*
      */ elix11 + elix12 + elix13 + elix14 + elix15 + elix16 + elix17 + elix18 + elix19 + elix20 + elix21 + elix22 +/*
      */ elix23 + elix24 + elix25 + elix26 + elix27 + elix28 + elix29 + elix30

      /* Sort table on num_rec variable. */

      sort rec_no

      /* Drop temporary variables rec_no, temp_6B and variable drg_cat. */

      drop rec_no temp_6B drg_cat

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end
