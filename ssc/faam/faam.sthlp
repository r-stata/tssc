^faam^ program
___________________


faam calculates the ^FAAM^ (Foot and Ankle Ability Measure) from your records

-----------------------------------------------------------------------------------------
^DISCLAIMER^: 
Every effort is made to test code as thoroughly as possible but user must accept
responsibility for use
-----------------------------------------------------------------------------------------


Syntax: 

^faam^ varlist, dim(dimension) gen(scorename)

^varlist^ needs to contain 21 variables for the computation of the activities of daily
living subscale score. 
^varlist^ needs to contain 8 variables for the computation of the sport subscale score. 
Any kind of variable name is admissible.

^dim(^dimension^)^ specifies which subscale is scored and needs to be specified.
Admissible dimensions are "adl" and "sport".
"adl" indicates computation of the activities of daily living subscale score.
"sport" indicates computation of the sport subscale score.

^gen(^scorename^)^ specifies the name of the generated subscale score and needs to be
specified.
Any scorename is admissible.

		  
Examples:

^faam^ varlist, dim(adl) gen(adlscore)
^faam^ varlist, dim(sport) gen(sportscore)
	
	
Admissible Values:
	
All variables need to be scored from 4 - 0. The following value labels apply:
	
	4: No difficulty at all
	3: Slight difficulty
	2: Moderate difficulty
	1: Extreme difficulty
	0: Unable to do
	
Values outside this range for any variable will terminate the program.


Treatment of Missing Data:
	
Missing data is replaced by the mean score for the applicable subscale.
There is a limit of 2 missing values for the activities of daily living subscale.
There is a limit of 1 missing value for the sport subscale.
	
	
References:
	
Martin RL, Irrgang JJ, Burdett RG, Conti SF, Van Swearingen JM. Evidence of
Validity for the Foot and Ankle Ability Measure (FAAM).
Foot & Ankle International 26: 968-983, 2005.

Nauck T, Lohrer H. Translation, cross-cultural adaption and validation of
the German version of the Foot and Ankle Ability Measure for patients
with chronic ankle instability.
British Journal of Sports Medicine 45: 785-790, 2011.


________________________________________________________
AO Clinical Investigation and Documentation
Program author: Johann Blauth and Monica Daigl
Date: 19.04.2012
