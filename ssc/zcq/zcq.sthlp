^zcq^ program
___________________


zcq calculates the score for the ^ZCQ^ (Zurich Claudication Questionnaire) from your records

-----------------------------------------------------------------------------------------
^DISCLAIMER^: 
Every effort is made to test code as thoroughly as possible but user must accept
responsibility for use
-----------------------------------------------------------------------------------------


Syntax: 

^zcq^ varlist, dim(dimension) gen(scorename) [per]

^varlist^ needs to contain 7 variables for the computation of the symptom severity subscale
 score. 

^varlist^ needs to contain 5 variables for the computation of the physical function subscale 
score.

^varlist^ needs to contain 6 variables for the computation of the satisfaction subscale
 score. 

Any kind of variable name is admissible.

^dim(^dimension^)^ specifies which scale is scored and needs to be specified.
Admissible dimensions are "symptom", "function", and "satisfaction".
"symptom" indicates computation of the symptom severity subscale score. 
"function" indicates computation of the physical function subscale score. 
"satisfaction" indicates computation of the satisfaction subscale score. 

^gen(^scorename^)^ specifies the name of the generated subscale score and needs to be
specified.
Any scorename is admissible.


^per^ is optional and expresses all scores in percent of the maximum score for the 
applicable subscale.
		
	  
Examples:

^zcq^ varlist, dim(symptom) gen(symptomscore)
^zcq^ varlist, dim(function) gen(functionscore)
^zcq^ varlist, dim(satisfaction) gen(satisfactionscore)
	
	
Admissible Values:
	

Admissible values vary across questions and subscales.

For all but two items of the symptom severity subscale the following value labels
describe the pain experienced by respondents:
	
	1: None
	2: Mild
	3: Moderate
	4: Severe
	5: Very Severe
	
The balance disturbance item of the symptom severity subscale is scored as follows:

	1: None
	3: Sometimes
	5: Often

The frequency of pain item of the symptom severity is scored as follows:

	1: Less than once a week
	2: At least once a week
	3: Everyday, for at least a few minutes
	4: Everyday, for most of the day
	5: Every minute of the day

For all but one item of the physical function subscale the following value labels describe
the walking ability of respondents:

	1: Yes, comfortably
	2: Yes, but sometimes with pain
	3: Yes, but always with pain
	4: No

The walk distance item of the physical function subscale is scored as follows:

	1: Over 2 miles
	2: Over 2 blocks but less than 2 miles
	3: Over 50 feet but less than 2 blocks
	4: Less than 50 feet

The satisfaction subscale is scored as follows:

	1: Very satisfied
	2: Satisfied
	3: Dissatisfied
	4: Very dissatisfied

Values outside these ranges for any variable will terminate the program.


Treatment of Missing Data:
	
Missing data is replaced by the mean score for the applicable subscale.
There is a limit of 2 missing values for the symptom severity subscale.
There is a limit of 1 missing value for the physical function subscale.
There is a limit of 1 missing value for the satisfaction subscale.
	

References:

Stucki G, Daltroy L, Liang MH, Lipson SJ, Fossel AH, Katz JN. Measurement Properties of a 
Self-Administered Outcome Measure in Lumbar Spinal Stenosis.
Spine 21: 796-803, 1996.

Pratt RK, Fairbank JCT, Virr A. The Reliability of the Shuttle Walking Test, the Swiss
Spinal Stenosis Questionnaire, the Oxford Spinal Stenosis Score, and the Oswestry
Disability Index in the Assessment of Patients With Lumbar Spinal Stenosis.
Spine 27: 84-91, 2002.
________________________________________________________
AO Clinical Investigation and Documentation
Program author: Johann Blauth and Monica Daigl
Date: 26.06.2012
