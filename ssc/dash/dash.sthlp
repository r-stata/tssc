
^dash^ program
___________________



dash calculates the ^DASH score^ (Disabilities of the Arm, Shoulder and Hand) from your records.


-----------------------------------------------------------------------------------------
^DISCLAIMER^: 
Terms and Conditions for Using the DASH questionnare may apply. 
In order to use the DASH please register at: http://www.dash.iwh.on.ca/conditions.htm
Every effort is made to test code as thoroughly as possible but user must accept
responsibility for use.
-----------------------------------------------------------------------------------------


The DASH is scored in two components: the disability/symptom questions (30 items in
the regular version and 11 items in the quick version of the DASH, scored 1-5)
and the optional high performance sport/music or work section (4 items, scored 1-5).

Syntax: 
^dash^ varlist [if] [in], generate(newvarname) [optional] [quick]

	^varlist^ must contain the 30 numeric variables to calculate the DASH score.

	^gen(^varname^)^ is used to specify where the score has to be stored.

	^optional^ is specified if the optional component of the DASH has to be calculated.
	This option requires ^varlist^ to contain 4 numeric variables.
		
 	^quick^ is specified if the quick version of the DASH has to be calculated.
	This option requires ^varlist^ to contain 11 numeric variables.

		  
Examples: 

^dash^ DASH1-DASH30, gen(DASH)  
^dash^ DASH*, gen(DASH)
^dash^ DASHop1-DASHop4, GEN(DASH_sport) optional
^dash^ DASH1-DASH11, gen(QuickDASH) quick 


Note:
The variables containing the information for the calculation have to be numerical and 
contain values between 1 and 5. 

Treatment of Missing Data:
A summary score is calculated if a respondent answered at least 27 out of 30 questions 
for the disability/symptom component of the DASH.
A summary score is calculated if a respondent answered at least 10 out of 11 questions 
for the disability/symptom component of the Quick DASH.
No imputation of missing data is performed for the optional component of the DASH, where
all four questions have to be completed in order to have a score calculated.



References: 
Details regarding the scoring algorithm are available at:
http://www.dash.iwh.on.ca/assets/images/pdfs/dash_scoring_2010.pdf

________________________________________________________
AO Clinical Investigation and Documentation
Program authors: Monica Daigl, Jackie Honeysett & Johann Blauth
Date: 15.06.2012 
