/*****************************************************************************************************
Version: 1.004
Program: Bronchiolitis
Author: Carl Mitchell
Decription: Bronchiolitis is an ado file that uses data from a study conducted in Dublin, Ireland called 
"A validated clinical model to predict the need of admission and length of stay in children with acute bronchiolitis."
The study was a response to the growing need to improve clinical jugdement when deciding whether to admit or discharge
children diagnosed with acute bronchiolitis. The data from that study is used to create the criteria for this statistical function.
******************************************************************************************************/



/*The capture command here is placed to capture the error message
generated when a old bronchiolitis is removed.*/

capture program drop bronchHelper
capture program drop bronch
capture program drop bronchi
 
 
version 11
set more off


program define bronchi, byable (recall)


syntax anything [if] [, nch optional_string ol optional_string olhsc optional_string prob optional_string probability optional_string ageyear optional_string ageweeks optional_string agedays]

marksample touse



/*******************************************************************************************
	Select the Model:
	1. National Children's Hospital in Dublin, Ireland (NCH)
    2. Our Lady's Hosiptal of Sick Children (OLHSC)
    
    This is done by the "olhsc" option
*******************************************************************************************/



/*The coeficients to the linear equations that will be inputed into the logistic equation are 
list here. These numbers represent the ln( odds ratio) from the study
1. work_of_breathing_coef  is the odd ratio of Work of Breathing as it relates to the study.
2. tachycardia_coef is the odds ratio of the heart rate over what is expected for the child.
3. age_coef is the odds ratio of the patient in months.
4. dehydration_coef is the odds ratio of the degree of dehydration of the patent 

Coefficients from National Children's Hospital in Dublin, Ireland (NCH)
These coeffiecients are the ln(odds) form Derivation section of "A validated clinical
model to predict the need of admission and length of stay in children with acute bronchiolitis"
The odd where as follows:
-------------------------------------------------------------------------------------------
								Odds ratio              95% CI    P values   ln(odds ratio)
-------------------------------------------------------------------------------------------
Increase work of breathing		3.39				1.29-8.92		0.013		1.221
Dehydration						2.54				1.34-4.82 		0.004		0.933
Age(per month)					0.86				0.76-0.97		0.015		-0.150
Tachycardia						3.78				1.05-13.57		0.041		1.33

*/

local work_of_breathing_coef_nch = 1.221
local tachycardia_coef_nch = 1.33
local age_coef_nch = -0.150
local dehydration_coef_nch = 0.933
 
/*
Coefficients from Our Lady's Hosiptal of Sick Children (OLHSC)
The odd where as follows:
-------------------------------------------------------------------------------------------
								Odds ratio              95% CI    P values   ln(odds ratio)
-------------------------------------------------------------------------------------------
Increase work of breathing		6.94				3.04-15.84		<0.001		1.937
Dehydration						10.94				4.00-30.08 		<0.001		2.395
Age(per month)					0.82				0.73-0.93		0.002		-0.194
Tachycardia						5.58				1.42-21.98		0.014		1.791

*/
local work_of_breathing_coef_olhsc = 1.937
local tachycardia_coef_olhsc = 1.791
local age_coef_olhsc = -0.194
local dehydration_coef_olhsc = 2.395

/*
This is the section of code that the user input variable are collected.
1. first_parameter is work of breathing
2. second_parameter is tachycardia
3. third_parameter is age in month
4. fouth_parameter is dehydration
*/

	gettoken first_parameter  0:0
	gettoken second_parameter 0:0
	gettoken third_parameter  0:0
	gettoken fourth_parameter 0:0




/*
This is the section of the code that will try to force the seemly impossible collection of arguments into either binary or
ordinal values.
*/

/*
Work of breathing as it is defined by the article is a binary variable where 0 represents no increase work of breathing and 1 represents
an increase work of breathing.
*/

//set trace on

local valid_calculation = 1
local missing_wob = 0
local missing_hr = 0
local missing_age =0
local missing_dehydration=0

capture confirm number `first_parameter'
		
		if "`first_parameter'"=="." local valid_calculation = 0  
		if "`first_parameter'"=="." local missing_wob = 1  
		if trim("`first_parameter'")=="" local valid_calculation = 0  
		if trim("`first_parameter'")=="" local missing_wob = 1  
		
		local wob_processed = 0 
		local wob_processed_mod =0
	
	if !_rc {
		 assert inrange(`first_parameter',0,1) 
		 local wob_processed = `first_parameter'
		 local wob_processed_mod = `first_parameter'
	}
	else {
	
	 	    if lower(trim("`first_parameter'")) =="mild" local wob_processed = 1
			if lower(trim("`first_parameter'")) =="moderate" local wob_processed = 2 
			if lower(trim("`first_parameter'")) =="mod" local wob_processed = 2 
			if lower(trim("`first_parameter'")) =="severe" local wob_processed = 3
			if lower(trim("`first_parameter'")) =="normal" local wob_processed = 0
			if lower(trim("`first_parameter'")) =="none" local wob_processed = 0 
			if lower(trim("`first_parameter'")) =="" local wob_processed = 0
			if `wob_processed' < 2 local wob_processed_mod = 0
			if `wob_processed' >=2 local wob_processed_mod = 1
        
	}



/*
The age is any number of months starting from 0 to infinity. However, since the study only covered patients upto 72 months, the result can not be
validated for any ages above this value. This pre processing will make a few assumptions for example. There are 12 months in a year, 4 weeks in a month
and there are 30 days in a month. This representation of age doesn't account for variation in age based on prematurity.
*/
capture confirm number `third_parameter'

		if "`third_parameter'"=="." local valid_calculation = 0  
		if "`third_parameter'"=="." local missing_age = 1  
		if trim("`third_parameter'")=="" local valid_calculation = 0  
		if trim("`third_parameter'")=="" local missing_age = 1  
	
	if _rc==0 {
			  
		local age_processed = `third_parameter'
		
		//This flags those ages that are less than 0 ages
		if (`age_processed' < 0){ 
			local valid_calculation = 0
		}
		
		//This flags those ages that are greater than 24 ages
		if(`age_processed' > 24){
			local valid_calculation = 0
		}
		
		if("`ageyears'" == ""){
			/* Do Nothing*/
		}
		else{
			local age_processed =`third_parameter'*12
		}
		
		if("`ageweeks'" == ""){
			/* Do Nothing*/
		}
		else{
			local age_processed =`third_parameter'/4.33
		}

		
		if("`agedays'" == ""){
			/* Do Nothing*/
		}
		else{
			local age_processed =`third_parameter'/30.25
		}
	}
	else{
		    noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:"
				display "`third_parameter' should be of number type and should represent a valid age."
				display ""
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-24"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
				}
	}

/*
Tachycardia as it is defined by the article is a binary variable where 0 represents the absents of tachycardia and 1 represents the 
presents of tachycardia.  This value can be further define by the definition supplied by the Harriet Lane text. Therefore, tachycardia
is as follows:

Age    		|   (Mean) Heart Rate
---------------------------------
0-7 days	|      	160
1-3 wk  	|		180
1-6 mo 		|		180
6-12mo		|		170
1-3yr(36)	|		150
4-5yr(60)	|		135	
6-8yr(96)	|		130
9-11yr(132)	|		110
12-16yr(192)|		110
>16	(192)	|		100

Because the target age range is 0 to 72 per the article, the average tachycardic HR of the set of patients from that age range is 162.5 

*/
capture confirm number `second_parameter'
		if "`second_parameter'"=="." local valid_calculation = 0  
		if "`second_parameter'"=="." local missing_hr = 1  
		if trim("`second_parameter'")=="" local valid_calculation = 0  
		if trim("`second_parameter'")=="" local missing_hr = 1  
		
		
	if _rc== 0{
	    if `second_parameter' < 0 local valid_calculation = 0
		local tachy_processed = 0
		
		if `age_processed' <= (7/30.25)  & `second_parameter' >  160 local tachy_processed= 1 
		if `age_processed' >  (7/30.25) & `age_processed' < (21/30.25)  & `second_parameter' > 183 local tachy_processed =1
		if `age_processed' >  1 & `age_processed' < 6  & `second_parameter' > 180 local tachy_processed =1 
		if `age_processed' >= 6    & `age_processed' < 12 & `second_parameter' > 170 local tachy_processed =1
		if `age_processed' >  12 & `second_parameter' >150 local tachy_processed =1

	}
	else {
	 noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:"
				display "`second_parameter' should be of number type and should represent a valid heart rate."
				display ""
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-24"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
		}
	}

/***
Dehydration is defined as none mild moderate and severe. This is encoded as 0, 1, 2, and 3 respectively.
*/
//set trace on
capture confirm number `fourth_parameter'
		if "`fourth_parameter'"=="." local valid_calculation = 0  
		if "`fourth_parameter'"=="." local missing_dehydration = 1  
		if trim("`fourth_parameter'")=="" local valid_calculation = 0  
		if trim("`fourth_parameter'")=="" local missing_dehydration = 1  
		
		local dehyd_processed = 0
	
	if _rc==0{
	
		 assert inrange(`fourth_parameter',0,3)
		 local dehyd_processed = `fourth_parameter'
	}
	else {
		
		if strpos(trim("`fourth_parameter'"),",")==0 {
	   		if lower(trim("`fourth_parameter'")) =="mild" local dehyd_processed = 1
			if lower(trim("`fourth_parameter'")) =="moderate" local dehyd_processed = 2
			if lower(trim("`fourth_parameter'")) =="severe" local dehyd_processed = 3 
			if lower(trim("`fourth_parameter'")) =="normal" local dehyd_processed = 0 
			if lower(trim("`fourth_parameter'")) =="none" local dehyd_processed = 0
			if lower(trim("`fourth_parameter'")) =="" local dehyd_processed = 0	         
   		}
   		else {
	 	noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:"
				display "`fourth_parameter' should have a trailing space."
				display "The values for dehydration can be as mention below. Please see help file for details."
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-24"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
			}
		}	
   }


/*
The observed ordinal variable Y is a function of Y* that is not measured.
Y* is a continuous latent variable that determines Y.
The observed variable Y depends on whether or not you have crossed a particular threshold or cutpoint.
Derivation Group: National Children's Hospital in Dublin, Ireland (NCH)
 k1 =-0.654
 k2 = 1.866

Validation Group: Our Lady's Hosiptal of Sick Children (OLHSC)
 k1 =-0.33
 k2 = 1.866
 	
These cutpoint create te ordinal ranges of the outcome space.
M  = 3, ie there are 3 possible ordinal outcomes:

1. Discharge										|---> Mild Bronchiolitis
2. Hospital stay less than or equal to the mean     |---> Moderate Bronchiolitis
3. Hospital stay greater than the mean              |---> Severe Bronchiolitis

The ordinal outcomes are define by the cutpoint as follows:

	Y(i) = 1 if Y*(i) is </= k1    ---> Mild Bronchiolitis
 	Y(i) = 2 if k1 </= Y* </= k2   ---> Moderate Bronchiolitis
 	Y(i) = 3 if Y*(i) is >/= k2    ---> Severe Bronchiolitis
 
*/

/*Cutpoints for NCH*/
local k1_nch = -0.654
local k2_nch = 1.866

/*Cutpoints for OLHSC*/
local k1_olhsc= -0.33
local k2_olhsc=1.866



/************************************************************
Calculate the Regression Coefficents Beta1, Beta2, Beta3, Beta4
**************************************************************/
//set trace on
	
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product(Beta1X1)
*/
		if ("`olhsc'" == ""&&"`ol'"==""){
			local work_of_breathing = `work_of_breathing_coef_nch'
		} 
		else {
			local work_of_breathing =`work_of_breathing_coef_olhsc'
		}	
		
		
		`if' local work_of_breathing_product = (`wob_processed_mod' * `work_of_breathing')
		
		
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product (Beta2X2)
*/

		if ("`olhsc'" == ""&& "`ol'"==""){
			local tachycardia= `tachycardia_coef_nch'
		} 
		else {
			local tachycardia =`tachycardia_coef_olhsc'
		}	
		
		`if' local tachycardia_product =  (`tachy_processed'*`tachycardia')
		
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product (Beta3X3)
*/

		if ("`olhsc'" == ""&&"`ol'"=="" ){
			local age = `age_coef_nch'
		} 
		else {
			local age =`age_coef_olhsc'
		}	
		
		`if' local age_product = (`age_processed' *`age')		
	
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product(Beta4X4)
*/
		
		if ("`olhsc'" == ""&&"`ol'"==""){
			local dehydration = `dehydration_coef_nch'
		} 
		else {
			local dehydration =`dehydration_coef_olhsc'
		}
		
		`if' local dehydration_product = (`dehyd_processed' * `dehydration')	
		
		
/*********************************************************
Calculate the sum of the products (Z)
  		K
  		----
		\
Y*(i) =  \  Beta(k)X(ki) + Random disturbance(i) = Z(i) + Random disturbance(i)
		/
		----
		k =1
		
		Random disturbance indicate that this is not a perfect distribution
		
This can be re-written as follows:

  		K
  		----
		\
  Z(i) =  \  Beta(k)X(ki) = E(Y*(i)) 
		/
		----
		k =1

*********************************************************************************************************************/
		`if' local Z =( `work_of_breathing_product'+ `tachycardia_product'+ `age_product'+ `dehydration_product')


/**********************************************************************************************************************
               						1
  P(Y=1) = Discharge|Mild =		-------------------
  								1 + exp(Z(i) - k1)
  								
***********************************************************************************************************************/
	
		
		if ("`olhsc'" == ""&& "`ol'"==""){
			local k1 = `k1_nch'
		} 
		else {
			local k1 =`k1_olhsc'
		}
		
		`if' local difference_Zi_k1 = (`Z' - `k1')

		`if' local logit1_1 = (1/(1 + exp(`difference_Zi_k1')))	
		
		
		`if' local _pdischarge = `logit1_1'
	    `if' local _padmit = (1 - `logit1_1')  	
	
		if("`prob'"==""){
		/* Do Nothing*/
		}
		else {
			`if' local _pmild =`logit1_1'
		}
		
		if("`probability'"==""){
		/* Do Nothing*/
		}
		else {
			
			`if' local _pmild =`logit1_1'
		}


/***********************************************************************************************************************
               																	1						   1
  P(Y=2) =  Hospital stay less than or equal to the mean |Moderate =	    ------------------    -  --------------
  																		   1 + exp(Z(i) - k2)  	      1 + exp(Z(i) - k1)
  								
************************************************************************************************************************/
		
		
		if ("`olhsc'" == "" && "`ol'" ==""){
			local k2 = `k2_nch'
		} 
		else {
			local k2 =`k2_olhsc'
		}

		`if' local difference_Zi_k2 = (`Z' - `k2')
		
			
		`if' local probability_Zi_k2 =(1.0/ (1.0 + exp(`difference_Zi_k2')))
		
		`if' local logit2_1 =(`probability_Zi_k2'-`logit1_1')
		
		
			if("`prob'"==""){
		/* Do Nothing*/
		}
		else {
			 `if' local _pmoderate =	`logit2_1'
		}
		
		if("`probability'"==""){
		/* Do Nothing*/
		}
		else {
			`if' local _pmoderate =logit2_1
		}

/***********************************************************************************************************************
               																			  1
  P(Y=3) =  Hospital stay greater than the mean|Severe Bronchiolitis =	    1   -  --------------
  																		    	    1 + exp(Z(i) - k2)
  								
************************************************************************************************************************/
		
		`if' local logit3_1 =(1 -`probability_Zi_k2')     
		
		if("`prob'"==""){
		/* Do Nothing*/
		}
		else {
			`if' local _psevere =`logit3_1'
		}
		
		if("`probability'"==""){
		/* Do Nothing*/
		}
		else {
			`if' local _psevere' =`logit3_1'
		}


		/*
		The ordinal outcomes are define by the cutpoint as follows:

			Y(i) = 1 if Y*(i) is </= k1    ---> Mild Bronchiolitis
 			Y(i) = 2 if k1 </= Y* </= k2   ---> Moderate Bronchiolitis
 			Y(i) = 3 if Y*(i) is >/= k2    ---> Severe Bronchiolitis
		
		1. Discharge										|---> Mild Bronchiolitis
		2. Hospital stay less than or equal to the mean     |---> Moderate Bronchiolitis
		3. Hospital stay greater than the mean   
		*/
		 
/*

This displays the users input options:
1. first_parameter is work of breathing
2. second_parameter is tachycardia
3. third_parameter is age in month
4. fouth_parameter is dehydration
*/
display "------------------------------------------------------------------------------------------"
display "Work of Breathing ('none' 'mild' 'moderate' 'severe'):"_col(60)"`first_parameter'"
display "Tachycardia ( 60 - 300) :"_col(60)"`second_parameter'"
display "Age (0-24):"_col(60)"`third_parameter'"
display "Dehydration ('none' 'mild' 'moderate' 'severe'):"_col(60)"`fourth_parameter'"
display "------------------------------------------------------------------------------------------"
if(`valid_calculation' == 1){		 
		 		
//display _col(20)"-----------------------------------------------------------------------"
display _col(20)"| Probability"
display "------------------------------------------------------------------------------------------"
display _col(5)"_bronch"_col(20)"|"_col(25)"Mild"_col(45)"Moderate"_col(65)"Severe"
display "-------------------+----------------------------------------------------------------------"
		 	if `Z' <= `k1' display _col(5)"[mild]"_col(20)"|"_col(25)"`logit1_1'"_col(45)"`logit2_1'"_col(65)"`logit3_1'" 
		 	if  inrange(`Z',`k1',`k2') display _col(5)"[moderate]"_col(20)"|"_col(25)"`logit1_1'"_col(45)"`logit2_1'"_col(65)"`logit3_1'"
		 	if `Z' >= `k2' display _col(5)"[severe]"_col(20)"|"_col(25)"`logit1_1'"_col(45)"`logit2_1'"_col(65)"`logit3_1'" 
display "------------------------------------------------------------------------------------------"
display " Z = `Z'"
display "------------------------------------------------------------------------------------------"
}
else {
 noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:"
				
				if(`missing_wob'==1) display "`first_parameter' should be of number type or string type."
				if(`missing_hr'==1) display "`second_parameter' should be of number type."
				if(`missing_age'==1) display "`third_parameter' should be of number type."
				if(`missing_dehydration'==1) display "`fourth_parameter' should be of number type or string type."
				
				display ""
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-24"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
		}
}
		
	
 //set trace off		


//set trace off
set more on



end


program define bronch, byable (recall)

syntax varlist (max=4)[if/] [, nch optional_string ol optional_string olhsc optional_string prob optional_string probability optional_string print optional_string printscreen optional_string ageyear optional_string ageweeks optional_string agedays optional_string dis optional_string discharge optional_string adm optional_string admit optional_string by(name) generate(name)]
marksample touse

local first_parameter : word 1 of `varlist'
local second_parameter : word 2 of `varlist'
local third_parameter : word 3 of `varlist'
local fourth_parameter : word 4 of `varlist'

display "------------------------------------------------------------------------------------------"
display "Work of Breathing ('none' 'mild' 'moderate' 'severe'):"_col(60)"`first_parameter'"
display "Tachycardia ( 60 - 300) :"_col(60)"`second_parameter'"
display "Age (0-24):"_col(60)"`third_parameter'"
display "Dehydration ('none' 'mild' 'moderate' 'severe'):"_col(60)"`fourth_parameter'"
display "------------------------------------------------------------------------------------------"

//set trace on
	if("`by'"==""){ 	
	 	if("`if'"==""){
	 		bronchHelper `varlist',  `nch' `ol' `olhsc' `print' `printscreen' `ageyear' `ageweeks' `agedays' `dis'  `discharge' `adm' `admit' `probability' `prob' generate(`generate')
	 			
	 	}
	 	else {
	 		bronchHelper `varlist' if `if',  `nch' `ol' `olhsc' `print' `printscreen' `ageyear' `ageweeks' `agedays' `dis'  `discharge' `adm' `admit' `probability' `prob' generate(`generate')
		}
	}
	else{
		if("`if'"==""){
			bysort `by': bronchHelper `varlist', `nch' `ol' `olhsc' `print' `printscreen' `ageyear' `ageweeks' `agedays' `dis'  `discharge' `adm' `admit' `probability' `prob' generate(`generate')
		}
		else{
			bysort `by': bronchHelper `varlist' if `if', `nch' `ol'  `olhsc' `print' `printscreen' `ageyear' `ageweeks' `agedays' `dis'  `discharge' `adm' `admit' `probability' `prob' generate(`generate')
		}
	}
//set trace off
end


/*The bronchHelper program is defined.*/
program define bronchHelper, byable (recall) sortpreserve
//version 11
set more off

/*
	On the command line you can run the following:
	
		bronch var1 var2 var3 var4
		or
		bronch var1 var2 var3 var4,olhsc
*/
/**
Remove the generated variables
*/
capture drop _pmild  
capture drop _pmoderate
capture drop _psevere
capture drop _tachycardia_product 
capture drop _age_product 
capture drop _dehydration_product 
capture drop _Z _difference_Zi_k1 
capture drop _logit1_1 
capture drop _difference_Zi_k2 
capture drop _probability_Zi_k2 
capture drop _logit2_1 
capture drop _logit3_1 
capture drop _work_of_breathing_product
capture drop _wob_processed 
capture drop _age_processed  
capture drop _dehyd_processed  
capture drop _tachy_processed
capture drop _bronch
capture label drop _dispo
capture drop _padmit 
capture drop _pdischarge
capture drop _wob_processed
capture drop _wob_processed_mod
capture drop _valid_calculation
capture drop _missing_wob
capture drop _missing_age
capture drop _missing_tachy
capture drop _missing_dehydration
capture drop _logit1_1 

syntax varlist (max=4)[if] [, nch optional_string ol optional_string olhsc optional_string prob optional_string probability optional_string print optional_string printscreen optional_string ageyear optional_string ageweeks optional_string agedays optional_string dis optional_string discharge optional_string adm optional_string admit optional_string generate(name)]

marksample touse



/*******************************************************************************************
	Select the Model:
	1.  National Children's Hospital in Dublin, Ireland (NCH)
    2. Our Lady's Hosiptal of Sick Children (OLHSC)
    
    This is done by the "olhsc" option
*******************************************************************************************/



/*The coeficients to the linear equations that will be inputed into the logistic equation are 
list here. These numbers represent the ln( odds ratio) from the study
1. work_of_breathing_coef  is the odd ratio of Work of Breathing as it relates to the study.
2. tachycardia_coef is the odds ratio of the heart rate over what is expected for the child.
3. age_coef is the odds ratio of the patient in months.
4. dehydration_coef is the odds ratio of the degree of dehydration of the patent 

Coefficients from National Children's Hospital in Dublin, Ireland (NCH)
These coeffiecients are the ln(odds) form Derivation section of "A validated clinical
model to predict the need of admission and length of stay in children with acute bronchiolitis"
The odd where as follows:
-------------------------------------------------------------------------------------------
								Odds ratio              95% CI    P values   ln(odds ratio)
-------------------------------------------------------------------------------------------
Increase work of breathing		3.39				1.29-8.92		0.013		1.221
Dehydration						2.54				1.34-4.82 		0.004		0.933
Age(per month)					0.86				0.76-0.97		0.015		-0.150
Tachycardia						3.78				1.05-13.57		0.041		1.33

*/

local work_of_breathing_coef_nch = 1.221
local tachycardia_coef_nch = 1.33
local age_coef_nch = -0.150
local dehydration_coef_nch = 0.933
 
/*
Coefficients from Our Lady's Hosiptal of Sick Children (OLHSC)
The odd where as follows:
-------------------------------------------------------------------------------------------
								Odds ratio              95% CI    P values   ln(odds ratio)
-------------------------------------------------------------------------------------------
Increase work of breathing		6.94				3.04-15.84		<0.001		1.937
Dehydration						10.94				4.00-30.08 		<0.001		2.395
Age(per month)					0.82				0.73-0.93		0.002		-0.194
Tachycardia						5.58				1.42-21.98		0.014		1.791

*/
local work_of_breathing_coef_olhsc = 1.937
local tachycardia_coef_olhsc = 1.791
local age_coef_olhsc = -0.194
local dehydration_coef_olhsc = 2.395

		

/*
This is the section of code that the user input variable are collected.
1. first_parameter is work of breathing
2. second_parameter is tachycardia
3. third_parameter is age in month
4. fouth_parameter is dehydration
*/

local first_parameter : word 1 of `varlist'
local second_parameter : word 2 of `varlist'
local third_parameter : word 3 of `varlist'
local fourth_parameter : word 4 of `varlist'




/*
This is the section of the code that will try to force the seemly impossible collection of arguments into either binary or
ordinal values.
*/

/*
Work of breathing as it is defined by the article is a binary variable where 0 represents no increase work of breathing and 1 represents
an increase work of breathing.
*/
//set trace on
qui{	
set more off

	generate _valid_calculation =1
	generate _missing_wob   =0
	generate _missing_age   =0
	generate _missing_tachy =0
	generate _missing_dehydration =0
	
	
	label variable _valid_calculation "Valid Calculation"
	label variable _missing_wob "Missing Work of Breathing"
	label variable _missing_age  "Missing Age"
	label variable _missing_tachy "Missing Tachycardia"
	label variable _missing_dehydration  "Missing Dehydration"
	
	
capture confirm numeric variable `first_parameter'
		
	generate _wob_processed = 0 	
	generate _wob_processed_mod =0
	label variable _wob_processed_mod "Mapping of Work of Breathing Data"
	
	replace _valid_calculation = 0  if missing(`first_parameter')
	replace _missing_wob = 1  if missing(`first_parameter')
	
	if _rc==0 {
		if inrange(`first_parameter',0,1){ 
			replace _wob_processed_mod = `first_parameter'
			label variable _wob_processed "Direct Mapping of Work of Breathing from Input" 
		}
		else{
		 noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:																					"
				display "`first_parameter' should be of number type or string type.	"
				display "																								"
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status	"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-240"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
				}
		
		}
	}
	else {
		capture confirm string variable `first_parameter'
        if !_rc {
    		replace _wob_processed = 1 if lower(trim(`first_parameter')) =="mild"
			replace _wob_processed = 2 if lower(trim(`first_parameter')) =="moderate"
			replace _wob_processed = 2 if lower(trim(`first_parameter')) =="mod"
			replace _wob_processed = 3 if lower(trim(`first_parameter')) =="severe"
			replace _wob_processed = 0 if lower(trim(`first_parameter')) =="normal"
			replace _wob_processed = 0 if lower(trim(`first_parameter')) =="none"
			replace _wob_processed =. if lower(trim(`first_parameter')) ==""
			replace _wob_processed_mod = 0 if _wob_processed < 2
			replace _wob_processed_mod = 1 if _wob_processed >=2
			label variable _wob_processed "Direct Mapping of Work of Breathing from Input" 
          }
          else {
           noisily{
				display "----------------------------------------------------------------------------------------------"
				display " Input Error:																					"
				display "`first_parameter' should be of number type or string type.	"
				display "																								"
				display "----------------------------------------------------------------------------------------------"
				display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status	"
				display "-------------------+--------------------------------------------------------------------------"
				display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
				display "heart-rate:  	    |  60 - 300"
				display "age-in-months:     |  0-240"
				display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
				display "-----------------------------------------------------------------------------------------------"
				exit 198
				}
          }
	}


//set trace off

/*	if(_wob_processed_mod >=.){
		replace _wob_processed_mod =.
	}*/
	
/*
The age is any number of months starting from 0 to infinity. However, since the study only covered patients upto 72 months, the result can not be
validated for any ages above this value. This pre processing wil make a few assumptions for example. There are 12 months in a year, 4.33 weeks in a month
and there are 30.25 days in a month. This representation of age doesn't account for variation in age based on prematurity.
*/
capture confirm numeric variable `third_parameter'

	replace _valid_calculation = 0  if missing(`third_parameter')
	replace _missing_age = 1  if missing(`third_parameter')
	
	if _rc==0 {
		generate _age_processed = 0.0
		
		replace _age_processed = `third_parameter'
		replace _valid_calculation =0 if _age_processed < 0
		replace _valid_calculation =0 if _age_processed > 24
		label variable _age_processed "Mapping of Age Data"
		
		if("`ageyears'" == ""){
			/* Do Nothing*/
		}
		else{
			replace _age_processed =`third_parameter'*12
		}
		
		if("`ageweeks'" == ""){
			/* Do Nothing*/
		}
		else{
			replace _age_processed =`third_parameter'/4.33
		}
		
		if("`agedays'" == ""){
			/* Do Nothing*/
		}
		else{
			replace _age_processed =`third_parameter'/30.25
		}
	}
	else{
	  noisily{
		display "----------------------------------------------------------------------------------------------"
		display " Input Error:																					"
		display "`third_parameter' should be of number type.													"
		display "																								"
		display "----------------------------------------------------------------------------------------------"
		display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
		display "-------------------+--------------------------------------------------------------------------"
		display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
		display "heart-rate:  	    |  60 - 300"
		display "age-in-months:     |  0-240"
		display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3 4; type can be number or string"
		display "-----------------------------------------------------------------------------------------------"
		exit 198
		}
	}

/*
Tachycardia as it is defined by the articles is a binary variable where 0 represents the absents of tachycardia and 1 represents the 
presents of tachycardia.  This value can be further define by the definition supplied by the Harriet Lane text. Therefore, tachycardia
is as follows:

Age    		|   (Mean) Heart Rate
---------------------------------
0-7 days	|      	160
1-3 wk  	|		180
1-6 mo 		|		180
6-12mo		|		170
1-3yr(36)	|		150
4-5yr(60)	|		135	
6-8yr(96)	|		130
9-11yr(132)	|		110
12-16yr(192)|		110
>16	(192)	|		100

Because the target age range is 0 to 72 per the article, the average tachycardic HR of the set of patients from that age range is 162.5 

*/
capture confirm numeric variable `second_parameter'
 
	
	replace _valid_calculation = 0  if missing(`second_parameter')
	replace _missing_tachy = 1  if missing(`second_parameter')
	
	if _rc== 0{
		generate _tachy_processed = 0
	replace _valid_calculation =0 if `second_parameter' < 0
	
		if (`second_parameter'>=.) {
			replace _tachy_processed =.
		    label variable _tachy_processed "Mapping of Tachycardia Data"
		}
		else{
			replace _tachy_processed= 1 if _age_processed <= (7/30.25)  & `second_parameter' >  160
			replace _tachy_processed =1 if _age_processed >  (7/30.25) & _age_processed < (21/30.25)  & `second_parameter' > 183
			replace _tachy_processed =1 if _age_processed >  1 & _age_processed < 6  & `second_parameter' > 180 
			replace _tachy_processed =1 if _age_processed >= 6    & _age_processed < 12 & `second_parameter' > 170
			replace _tachy_processed =1 if _age_processed >  12 & `second_parameter' >150
		    label variable _tachy_processed "Mapping of Tachycardia Data"
		}
		
	}
	else {
	noisily{
		display "----------------------------------------------------------------------------------------------"
		display "Input Error:"
		display "`second_parameter' should be of number type.													"
		display "----------------------------------------------------------------------------------------------"
		display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
		display "-------------------+--------------------------------------------------------------------------"
		display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
		display "heart-rate:  	    |  60 - 300"
		display "age-in-months:     |  0-240"
		display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3 4; type can be number or string"
		display "-----------------------------------------------------------------------------------------------"
		exit 198
		}
	}

/***
Dehydration is defined as none mild moderate and severe. This is encoded as 0, 1, 2, and 3 respectively.
*/
//set trace on
capture confirm numeric variable `fourth_parameter'

		generate _dehyd_processed = 0
	replace _valid_calculation = 0  if missing(`fourth_parameter')
	replace _missing_dehydration = 1  if missing(`fourth_parameter')
	
	if _rc==0{
	
		if inrange(`fourth_parameter', 0 ,4) {
			replace _dehyd_processed = `fourth_parameter'
	    	label variable _dehyd_processed "Mapping of Dehydration data"
           
	    }
	    else{
	    
	    noisily{
			display "----------------------------------------------------------------------------------------------"
			display "Input Error:"
			display "`fourth_parameter' should be of number type.													"
			display "----------------------------------------------------------------------------------------------"
			display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
			display "-------------------+--------------------------------------------------------------------------"
			display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
			display "heart-rate:  	    |  60 - 300"
			display "age-in-months:     |  0-240"
			display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
			display "-----------------------------------------------------------------------------------------------"
			exit 198
			}
	    
	    }
	}
	else {

	   capture confirm string variable `fourth_parameter'
          if !_rc {
                	replace _dehyd_processed = 1 if lower(trim("`fourth_parameter'")) =="mild"
					replace _dehyd_processed = 2 if lower(trim("`fourth_parameter'")) =="moderate"
					replace _dehyd_processed = 3 if lower(trim("`fourth_parameter'")) =="severe"
					replace _dehyd_processed = 0 if lower(trim("`fourth_parameter'")) =="normal"
					replace _dehyd_processed = 0 if lower(trim("`fourth_parameter'")) =="none"
					label variable _dehyd_processed "Mapping of Dehydration data"
           }
           else {
    		noisily{
			display "----------------------------------------------------------------------------------------------"
			display "Input Error:"
			display "`fourth_parameter' should be of number type.													"
			display "----------------------------------------------------------------------------------------------"
			display "Usage: bronch work-of-breathing heart-rate age-in-month dehydration-status"
			display "-------------------+--------------------------------------------------------------------------"
			display "work-of-breathing: | 'none' 'mild' 'moderate' 'severe' 0 1; type can be number or string"
			display "heart-rate:  	    |  60 - 300"
			display "age-in-months:     |  0-240"
			display "dehydration-status:| 'none' 'mild' 'moderate' 'severe' 0 1 2 3; type can be number or string"
			display "-----------------------------------------------------------------------------------------------"
			exit 198
			}
          }
	}
//set trace off

/*
The observed ordinal variable Y is a function of Y* that is not measured.
Y* is a continuous latent variable that determines Y.
The observed variable Y depends on whether or not you have crossed a particular threshold or cutpoint.
Derivation Group: National Children's Hospital in Dublin, Ireland (NCH)
 k1 =-0.654
 k2 = 1.866

Validation Group: Our Lady's Hosiptal of Sick Children (OLHSC)
 k1 =-0.33
 k2 = 1.866
 	
These cutpoint create te ordinal ranges of the outcome space.
M  = 3, ie there are 3 possible ordinal outcomes:

1. Discharge										|---> Mild Bronchiolitis
2. Hospital stay less than or equal to the mean     |---> Moderate Bronchiolitis
3. Hospital stay greater than the mean              |---> Severe Bronchiolitis

The ordinal outcomes are define by the cutpoint as follows:

	Y(i) = 1 if Y*(i) is </= k1    ---> Mild Bronchiolitis
 	Y(i) = 2 if k1 </= Y* </= k2   ---> Moderate Bronchiolitis
 	Y(i) = 3 if Y*(i) is >/= k2    ---> Severe Bronchiolitis
 
*/

/*Cutpoints for NCH*/
local k1_nch = -0.654
local k2_nch = 1.866

/*Cutpoints for OLHSC*/
local k1_olhsc= -0.33
local k2_olhsc=1.866



/************************************************************
Calculate the Regression Coefficents Beta1, Beta2, Beta3, Beta4
**************************************************************/
//set trace on
	
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product(Beta1X1)
*/
		
		if ("`olhsc'" == ""&&"`ol'" == ""){
			local work_of_breathing = `work_of_breathing_coef_nch'
		} 
		else {
			local work_of_breathing =`work_of_breathing_coef_olhsc'
		}	
		
		
		generate _work_of_breathing_product = 0.0
		if(_wob_processed_mod >=.){
			replace _work_of_breathing_product =.
			label variable _work_of_breathing_product "Product of Odds Ratio and Record Observation of Work of Breathing"			
		}
		else {
			replace _work_of_breathing_product = (_wob_processed_mod * `work_of_breathing') `if'
			label variable _work_of_breathing_product "Product of Odds Ratio and Record Observation of Work of Breathing"	
		}
		
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product (Beta2X2)
*/
		
		
		if ("`olhsc'" == ""&&"`ol'" == ""){
			local tachycardia= `tachycardia_coef_nch'
		} 
		else {
			local tachycardia =`tachycardia_coef_olhsc'
		}	
		
		generate _tachycardia_product = 0.0
		if missing(_tachy_processed){
			replace _tachycardia_product=.
			label variable _tachycardia_product "Product of Odds Ratio and Record Observation of Tachycardia"
		}
		else{
			replace _tachycardia_product =  (_tachy_processed*`tachycardia') `if'
			label variable _tachycardia_product "Product of Odds Ratio and Record Observation of Tachycardia"
		}
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product (Beta3X3)
*/

		if ("`olhsc'" == ""&&	"`ol'" == ""){
			local age = `age_coef_nch'
		} 
		else {
			local age =`age_coef_olhsc'
		}	
		
		generate _age_product = 0.0
		if(_age_processed >=.){
			replace _age_product=.
		    label variable _age_product "Product of Odds Ratio and Record Observation of Age"
		}
		else{
			replace _age_product = (_age_processed *`age') `if'		
		    label variable _age_product "Product of Odds Ratio and Record Observation of Age"
		}
/*
Calculate the product of work of breathing and place the information in work_of_breathing_product(Beta4X4)
*/

		
		if ("`olhsc'" == ""&&"`ol'" == ""){
			local dehydration = `dehydration_coef_nch'
		} 
		else {
			local dehydration =`dehydration_coef_olhsc'
		}
		
		generate _dehydration_product = 0.0
		if(_dehyd_processed >=.){
			replace _dehydration_product =.
			label variable _dehydration_product "Product of Odds Ratio and Record Observation of Dehydration"	
	
		}
		else {
			replace _dehydration_product = (_dehyd_processed * `dehydration') `if'
			label variable _dehydration_product "Product of Odds Ratio and Record Observation of Dehydration"	
		}
		
/*********************************************************
Calculate the sum of the products (Z)
  		K
  		----
		\
Y*(i) =  \  Beta(k)X(ki) + Random disturbance(i) = Z(i) + Random disturbance(i)
		/
		----
		k =1
		
		Random disturbance indicate that this is not a perfect distribution
		
This can be re-written as follows:

  		K
  		----
		\
  Z(i) =  \  Beta(k)X(ki) = E(Y*(i)) 
		/
		----
		k =1

*********************************************************************************************************************/
		generate _Z =.
		replace _Z =( _work_of_breathing_product + _tachycardia_product + _age_product+ _dehydration_product) if _valid_calculation ==1
		label variable _Z "Summation of parameter products"

/**********************************************************************************************************************
               						1
  P(Y=1) = Discharge|Mild =		-------------------
  								1 + exp(Z(i) - k1)
  								
***********************************************************************************************************************/
	
		
		if ("`olhsc'" == ""&&"`ol'" == ""){
			local k1 = `k1_nch'
		} 
		else {
			local k1 =`k1_olhsc'
		}
		
		generate _difference_Zi_k1 = .
		replace _difference_Zi_k1 = (_Z - `k1') if _valid_calculation ==1
		label variable _difference_Zi_k1 "Data of Mild Disease"

		generate _logit1_1 = .
		replace _logit1_1 = (1/(1 + exp(_difference_Zi_k1))) if _valid_calculation ==1	
		label variable _logit1_1 "Probability of Mild Disease"
		
		generate _padmit = .
		generate _pdischarge =.
		
		
		if "`dis'"=="" && "`discharge'"==""{
		  /* Do Nothing */
		}
		else{
			replace _pdischarge = _logit1_1 if _valid_calculation ==1
			label variable _pdischarge "Probability of Discharge"
		}
		
		if "`adm'"=="" && "`admit'"==""{
		  /* Do Nothing */
		}
		else{
			replace _padmit = (1 - _logit1_1) if _valid_calculation ==1  	
			label variable _padmit "Probability of Admission"
		}
		
		if "`prob'"==""&& "`probability'"=="" {
		/* Do Nothing*/
		}
		else {
			generate _pmild =.
			replace _pmild =_logit1_1 if _valid_calculation ==1
			label variable _pmild "Probability of mild disease"
		}


/***********************************************************************************************************************
               																	1						   1
  P(Y=2) =  Hospital stay less than or equal to the mean |Moderate =	    ------------------    -  --------------
  																		   1 + exp(Z(i) - k2)  	      1 + exp(Z(i) - k1)
  								
************************************************************************************************************************/
		
		
		
		if ("`olhsc'" == ""&&"`ol'" == ""){
			local k2 = `k2_nch'
		} 
		else {
			local k2 =`k2_olhsc'
		}

		generate float _difference_Zi_k2 =1
		replace _difference_Zi_k2 = (_Z - `k2') 
		label variable _difference_Zi_k2 "Data of Mild and Moderate"
			
		generate float _probability_Zi_k2 =.
		replace _probability_Zi_k2 =(1.0/ (1.0 + exp(_difference_Zi_k2))) if _valid_calculation ==1
		label variable _probability_Zi_k2 "Combined probability of Mild and Moderate Bronchiolitis"
		
		generate float _logit2_1 = .
		replace _logit2_1 =(_probability_Zi_k2-_logit1_1) if _valid_calculation ==1
		label variable _logit2_1 "Probability of Moderate Bronchiolitis"
		
		
		
		if("`prob'"=="" && "`probability'"==""){
		/* Do Nothing*/
		}
		else {
			generate _pmoderate =.
			replace _pmoderate =_logit2_1 if _valid_calculation ==1
			label variable _pmoderate "Probability of Moderate Bronchiolitis"
		}

/***********************************************************************************************************************
               																			  1
  P(Y=3) =  Hospital stay greater than the mean|Severe Bronchiolitis =	    1   -  --------------
  																		    	    1 + exp(Z(i) - k2)
  								
************************************************************************************************************************/
		
		generate float _logit3_1 =.
		replace _logit3_1 =(1 -_probability_Zi_k2) if _valid_calculation ==1      
		label variable _logit3_1 "Probability of Severe Bronchiolitis"
		
		if("`prob'"=="" && "`probability'"==""){
		/* Do Nothing*/
		}
		else {
			generate _psevere =.
			replace _psevere =_logit3_1 if _valid_calculation ==1
			label variable _psevere "Severe Bronchiolitis"
		}


		/*
		The ordinal outcomes are define by the cutpoint as follows:

			Y(i) = 1 if Y*(i) is </= k1    ---> Mild Bronchiolitis
 			Y(i) = 2 if k1 </= Y* </= k2   ---> Moderate Bronchiolitis
 			Y(i) = 3 if Y*(i) is >/= k2    ---> Severe Bronchiolitis
		
		1. Discharge										|---> Mild Bronchiolitis
		2. Hospital stay less than or equal to the mean     |---> Moderate Bronchiolitis
		3. Hospital stay greater than the mean   
		*/
			
			
		label define _dispo 0 "Mild" 1 "Moderate" 2 "Severe"
		 		
		if ("`generate'" == ""){
		 	generate _bronch = .
		 	label variable _bronch "Bronchiolitis Severity"
		 	label values _bronch _dispo
		 	replace _bronch = 0 if _Z <= `k1' & _valid_calculation ==1
		 	replace _bronch = 1 if  inrange(_Z,`k1',`k2') & _valid_calculation ==1 
		 	replace _bronch = 2 if _Z >= `k2' & _valid_calculation ==1
		}
		else {
			generate `generate' = .
			replace `generate' = 0 if _Z <= `k1' &  _valid_calculation ==1
		 	replace `generate' = 1 if  inrange(_Z,`k1',`k2')  &  _valid_calculation ==1
		 	replace `generate' = 2 if _Z >= `k2' &  _valid_calculation ==1
		    label variable `generate' "Bronchiolitis Severity"
			label values `generate' _dispo
			
		}
		
	
 	
}
//set trace on
if "`generate'"=="" {
	if "`printscreen'"=="" {
		/* do not display*/
	}
	else{
		list `varlist' _bronch _logit1_1 _logit2_1 _logit3_1 _Z `if'
	}

	if "`print'"=="" {
		/* do not display*/
	}
	else{
		list `varlist' _bronch _logit1_1 _logit2_1 _logit3_1 _Z `if' 
	}
}
else {
	if "`printscreen'"=="" {
		/* do not display*/
	}
	else{
		list `varlist' `generate' _logit1_1 _logit2_1 _logit3_1 _Z `if'
	}

	if  "`print'"=="" {
		/* do not display*/
	}
	else{
		list `varlist' `generate' _logit1_1 _logit2_1 _logit3_1 _Z `if' 
	}
}

//set trace off	
/*
This section calculates the number of valid calculations and the missing values.
*/
qui{
count
local obs =r(N)
count if _valid_calculation == 1
local valid =r(N)
count if _missing_wob == 1
local missing_wob =r(N)
count if _missing_age == 1
local missing_age =r(N)
count if _missing_tachy == 1
local missing_tachy =r(N)
count if _missing_dehydration == 1
local missing_dehydration =r(N)
}

display "Observations:"_column(20)"Valid Calculations:"
display "------------"_column(20)"------------------"
display "`obs'"_column(20)"`valid'"
display
display _column(5)"Missing Values:"
display _column(5)"---------------"
display _column(5)"`first_parameter': `missing_wob'"
display _column(5)"`second_parameter': `missing_tachy'"
display _column(5)"`third_parameter': `missing_age'"
display _column(5)"`fourth_parameter': `missing_dehydration'"


set more on
            
end
