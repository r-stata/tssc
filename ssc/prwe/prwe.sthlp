
^prwe^ program
___________________


prwe calculates the ^PRWE scores^ (Patient-Rated Wrist Evaluation) from your records

The PRWE is a 15-item questionnaire designed to measure wrist pain and disability in 
activites of daily living. 
It consists of two subscales: pain (5 items scored 0-10) and function (10 items scored 0-10). 

Two subscale scores are computed and a total score is computed by summing the two subscales scores. 

The PRWE includes two subscale scores (pain and function) as well as a total score. 


Syntax: 
^prwe^ varlist [if] [in], generate(newvarname)  [subscales]

	^varlist^ must contain the 15 numeric variables to calculate the PRWE total score, these
	should appear in the same order as in the questionnaire (var1-var5 for pain and var6-var15 for function)

	^gen(^varname^)^ is used to specify where the total score has to be stored

	^subscales^ is specified if the subscales scores have to be stored
		
 
		  
Examples: 

^prwe^ PRWE1-PRWE15, gen(PRWE)  
^prwe^ Pain1-Pain5 Function1-Function10, gen(PRWE) sub
^prwe^ PRWE1-PRWE5, gen(PRWE) sub

Note:
The variables containing the information for the calculation have to be numerical and 
contain values between 1 and 10. 


Treatment of Missing Data:
A summary score calculated if a respondent answered at least 4 out of 5 questions for the 
pain subscale and 8 of 10 questions for the function subscale.

References: 
The questionnaire and detailed scoring instructions are available at:
http://www.srs-mcmaster.ca/Portals/20/pdf/research_resources/PRWE_PRWHEUserManual_Dec2007.pdf

________________________________________________________
AO Clinical Investigation and Documentation
Program author: Monica Daigl 
Date: 04.04.2012 
