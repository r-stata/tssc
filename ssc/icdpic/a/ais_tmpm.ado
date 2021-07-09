/* Revised 10/15/2010 */
/* Version 3.0 */



/*-----------------------------------------------------------------------------------------------------------------*/
/*  Program to compute the probability of death using the Trauma Mortality Prediction Model (TMPM) based on        */
/*  Anatomic Injury Scale (AIS).  The program adds a model-averaged regression coefficient (MARC) value for each   */
/*  AIS value in the user's data.  It then adds variables for the five worst injuries, those corresponding to the  */
/*  5 highest MARC values, along with variables containing their AIS codes, variables indicating the body regions  */
/*  of the 2 worst injuries (2 highest MARC values) and a Boolean variable to indicate if the 2 worst injuries     */
/*  occur in the same body region.  Finally, it adds a variable for the TMPM value and a variable for the          */
/*  probability of death.                                                                                          */
/*-----------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------*/
/*  This program is part of larger group of programs collectively known as ICDPIC.  Version 3.0 programs may be    */
/*  downloaded from the SSC archives website or installed from within STATA using the ssc command.  Version 3.0    */
/*  requires STATA 8.0 or higher.                                                                                  */
/*-----------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------*/
/*  NOTE: AIS TMPM and probability of death values are rounded to the nearest 0.000001.                            */
/*-----------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------*/
/*  NOTE: Program ais_tmpm can be run by typing "db ais_tmpm", without the quotation marks, or running the ICDPIC  */
/*  program and choosing "AIS TMPM" from the ICDPIC dialog box.                                                    */
/*-----------------------------------------------------------------------------------------------------------------*/


program define ais_tmpm
   version 8.0
   quietly {
     
      /* Define local macros and scalars. */

      local i              /* Index */
      local j              /* Index */
      local k              /* Index */
      scalar numrecs = 0   /* Number of observations */
      scalar missing = 0   /* Number of observations with missing values for a given variable */
      scalar num_marc = 5  /* Number of MARC values used in calculating TMPM and probability of death */
      scalar C0 = -2.3281  /* Constant */
      scalar C1 = 1.3138   /* MARC 1 coefficient */
      scalar C2 = 1.5136   /* MARC 2 coefficient */
      scalar C3 = 0.4435   /* MARC 3 coefficient */
      scalar C4 = 0.4240   /* MARC 4 coefficient */
      scalar C5 = 0.6284   /* MARC 5 coefficient */
      scalar C6 = -0.1377  /* Same body region for two highest MARC values (2 worst injuries) coefficient */
      scalar C7 = -0.6506  /* Coefficient for interaction between two highest MARC values (two worst injuries) */
      local ais_test       /* Used to test for a correct AIS code variable name prefix or the number of AIS code variables
                              in the user's data */
      local num_ais        /* Number of AIS code variables in the user's data */  
      local curr_ais       /* Holds name of current AIS code variable */
      local curr_mo        /* Holds name of current MARC value variable associated with original AIS code variables */
      local curr_inj       /* Holds name of current injury variable associated with one of the top 5 MARC value variables */
      local curr_mi        /* Holds name of current top 5 MARC value variable associated with top 5 injury variables */
      local p1 marc_       /* Prefix of all MARC value variables */
      local p2 marc        /* Prefix of all top 5 MARC value variables */
      local p3 inj         /* Prefix of all injury variables associated with one of the top 5 MARC value variables */
      local cmp_m1         /* Holds name of first MARC value variable (associated with original AIS code variables)
                              and used for comparison in insertion sort */
      local cmp_m2         /* Holds name of second MARC value variable (associated with original AIS code variables)
                              and used for comparison in insertion sort */
      local cmp_ma1        /* Holds name of AIS code variable associated with first MARC value variable used in comparison
                              for insertion sort */
      local cmp_ma2        /* Holds name of AIS code variable associated with second MARC value variable used in comparison
                              for insertion sort */


      /* Get arguments for input file, output file and AIS code prefix. */

      args filein fileout p_user

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

      /* Check if user entered a correct prefix for the AIS code variables in the input file. */

      local ais_test = "`p_user'" + "1"
      capture confirm variable `ais_test'
      if _rc == 111 | _rc == 198 {
         window stopbox stop "No such AIS code prefix in the input file.  Please try again."
         exit
      }

      /* Determine how many AIS code variables there are in the data. */

      local i = 1

      while 1 {
         local ais_test = "`p_user'" + "`i'"
         capture confirm variable `ais_test'
         if _rc != 111 {
            local i = `i' + 1
         }
         else {
            local i = `i' - 1
            continue, break
         }
      }

      /* Assign number of AIS codes. */

      local num_ais = `i'

      /* Create temporary variable to hold record number. */

      generate long rec_no = _n

      /* Create variable to hold truncated AIS values for merging with lookup table. */

      generate str6 predot = ""
 
      /* Get temporary file name. */
   
      tempfile temp1



      /*---------------------------------------------------------------------------*/
      /*  Merge AIS code variables with MARC value reference table to obtain MARC  */  
      /*  values for each AIS code and add them to the data.  Save results to      */
      /*  temporary file number 1.                                                 */
      /*---------------------------------------------------------------------------*/                   
        
   
      local i = 1

      /* While index number is less than or equal to maximum number of AIS codes. */
                                                  
      while `i' <= `num_ais' {

         /* Generate name of current AIS code variable. */

         local curr_ais = "`p_user'" + "`i'"

         /* Truncate the current AIS code variable and place the results in the predot variable for merging with
            the MARC value reference table.                                                                      */

         replace predot = substr(`curr_ais', 1, 6)

         /* Get number of missing observations for the current AIS code variable. */

         capture count if `curr_ais' == ""
         scalar missing = r(N)
 
         /* Process current AIS code variable if any observation does not contain missing data. */

         if missing < numrecs {

            /* Sort table in memory on merge variable. */

            sort predot

            /* Merge with MARC value reference table. */
      
            capture findfile mais_s.dta
            if _rc == 601 {
               window stopbox stop "File mais_s.dta not found.  This file must be in one of the ado path directories."
               exit
            }
            else {
               merge predot using `"`r(fn)'"', nokeep
            }

            /* Delete the _merge variable created by the merge process. */

            drop _merge

            /* Rename 'marc' variable added by the merge process to 'marc_' + the number of the current AIS code
               variable.  This is the MARC value associated with the current AIS code.                           */

            local marc = "`p1'" + "`i'"
            rename marc `marc'

            /* Move 'marc' variable to proper position in the table. */

            move `marc' `curr_ais'
            move `curr_ais' `marc'
         }
         else {
     
            /* Fill in current AIS code associated variable for MARC value with missing values and move it to the
               proper position in the data.                                                                       */

            local marc = "`p1'" + "`i'"
            generate float `marc' = .
            move `marc' `curr_ais'
            move `curr_ais' `marc'              
         }
         local i = `i' + 1
      }

      /* Drop predot variable. */

      drop predot
        
      /* Sort table on num_rec variable. */

      sort rec_no
     
      /* Save temporary file temp1. */

      save `temp1', replace



      /*--------------------------------------------------------------------------------------------------------*/
      /*  Prepare data, and create variables necessary, for sorting and sort MARC values using insertion sort.  */
      /*--------------------------------------------------------------------------------------------------------*/


      /* Replace any MARC variables that have missing values with a number guaranteed to be lower than the lowest MARC
         value expected to be encountered.  For our purposes, -10^36 should be sufficient.                             */

      local i = 1

      while `i' <= `num_ais' {
         local marc = "`p1'" + "`i'"
         replace `marc' = -10^36 if `marc' == .
         local i = `i' + 1
      }

      /* Create temporary variables for insertion sort swap of MARC values and movement of associated AIS code
         variables.                                                                                            */   

      generate float tmp_marc = .
      generate str8 tmp_ais = ""

      /* Perform insertion sort using MARC values.  Move associated AIS code variables accordingly. */

      local i = 2

      while `i' <= `num_ais' {
         local curr_ais = "`p_user'" + "`i'"
         local marc = "`p1'" + "`i'" 
         local j = `i'
         while 1 {
            local k = `j' - 1
            replace tmp_marc = 10^36 
            if `k' == 0 {
               continue, break
            }  
            local cmp_m1 = "`p1'" + "`k'"
            local cmp_m2 = "`p1'" + "`j'"
            local cmp_ma1 = "`p_user'" + "`k'"
            local cmp_ma2 = "`p_user'" + "`j'"
            replace tmp_marc = `cmp_m1' if `cmp_m1' < `cmp_m2'
            replace tmp_ais = `cmp_ma1' if `cmp_m1' < `cmp_m2'
            replace `cmp_ma1' = `cmp_ma2' if `cmp_m1' < `cmp_m2'
            replace `cmp_m1' = `cmp_m2' if `cmp_m1' < `cmp_m2'
            replace `cmp_ma2' = tmp_ais if tmp_marc < `cmp_m1'
            replace `cmp_m2' = tmp_marc if tmp_marc < `cmp_m1'
            local j = `j' - 1
         }
         local i = `i' + 1
      }



      /*-----------------------------------------------------------------------------------------*/
      /*  Create new set of variables to hold the 5 worst injuries and their corresponding MARC  */
      /*  values.                                                                                */
      /*-----------------------------------------------------------------------------------------*/


      /* Create variables to hold injuries (AIS values) associated with top 5 MARC values (5 worst injuries). */

      for newlist inj1-inj5: generate str8 X = "" 

      /* Create variables to hold top 5 MARC values (5 worst injuries). */

      for newlist marc1-marc5: generate float X = .

      /* Place top five MARC values and associated injuries into variables marc1-marc5 and inj1-inj5 respectively.  */

      local i = 1

      while 1 {
         local curr_ais = "`p_user'" + "`i'"
         local curr_inj = "`p3'" + "`i'"
         local curr_mo = "`p1'" + "`i'"
         local curr_mi = "`p2'" + "`i'"
         replace `curr_inj' = `curr_ais'
         replace `curr_mi' = `curr_mo' 
         replace `curr_mi' = 0 if `curr_mi' == float(-10^36)
         if `i' == num_marc | `i' == `num_ais' {
            continue, break
         }      
         local i = `i' + 1       
      }
     
      /* Move injury variables in front of their corresponcing MARC value variables. */
 
      local i = 1

      while `i' <= num_marc {
         local curr_inj = "`p3'" + "`i'"
         local curr_mi = "`p2'" + "`i'"
         move `curr_inj' `curr_mi'
         move `curr_mi' `curr_inj'
         local i = `i' + 1
      }

      /* If any MARC value variable contains a missing value, replace it with 0 (zero). */

      for varlist marc1 marc2 marc3 marc4 marc5: replace X = 0 if X == .



      /*------------------------------------------------------------------------------*/
      /*  Create variables to hold AIS body regions of two highest MARC values and a  */
      /*  variable to indicate if these two body regions are the same.                */
      /*------------------------------------------------------------------------------*/


      /* Create variables to hold AIS body region of two highest MARC values (two worst injuries). */
       
      for newlist high1-high2: generate str1 X = ""

      /* Get body regions of the two worst injuries (two highest MARC values). */

      replace high1 = substr(inj1, 1, 1) if marc1 != 0
      replace high2 = substr(inj2, 1, 1) if marc2 != 0

      /* Create Boolean variable to indicate if body region of the top 2 MARC values (2 worst injuries) are equal. */   

      generate byte same_reg = 0

      /* Set same_reg variable to 1 if the body regions of the two worst injuries (two highest marc values) are equal. */

      replace same_reg = 1 if high1 == high2



      /*--------------------------------------------------------------------------------------------*/
      /*  Create variables to hold TMPM and probability of death (POD) and calculate their values.  */
      /*--------------------------------------------------------------------------------------------*/


      /* Create variable to hold Trauma Mortality Prediction Model (TMPM) value. */

      generate float AIS_TMPM = .

      /* Create variable to hold probability of death (POD) value. */

      generate float AIS_POD = .

      /* Calculate TMPM. */

      replace AIS_TMPM = C0 + (C1 * marc1) + (C2 * marc2) + (C3 * marc3) + (C4 * marc4) + (C5 * marc5) + (C6 * same_reg)/*
      */ + (C7 * marc1 * marc2) if marc1 != 0

      /* Calculate probability of death (POD). */

      replace AIS_POD = normal(AIS_TMPM) 



      /*-----------------------------------------------------------------------------------------*/
      /*  Drop unwanted variables, sort on variable rec_no and save to temporary file number 2.  */
      /*-----------------------------------------------------------------------------------------*/


      /* Keep marc variables, injury variables, AIS_TMPM variable, AIS_POD variable, same_reg variable and rec_no
         variable.                                                                                                */
 
      keep marc1-marc5 inj1-inj5 high1 high2 AIS_TMPM AIS_POD same_reg rec_no

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

      /* Round TMPM and POD variables to nearest 0.000001. */

      replace AIS_TMPM = round(AIS_TMPM, 0.000001)
      replace AIS_POD = round(AIS_POD, 0.000001)

      /* Format variables TMPM and POD. */

      format AIS_TMPM AIS_POD %9.6f

      /* Delete the _merge variable created by the merge process. */
  
      drop _merge

      /* Delete temporary variable rec_no. */ 

      drop rec_no

      /* Save new version of table to disk. */

      save "`fileout'", replace
   }
end
