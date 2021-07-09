^odi^ program
___________________


odi calculates the ^ODI^ (Oswestry Disability Index) from your records

-----------------------------------------------------------------------------------------
^DISCLAIMER^: 
Terms and Conditions for using the ODI version 2.1a apply
In order to use the ODI version  2.1a and scoring algorithms you must register at:
http://www.mapi-trust.org/services/questionnairelicensing/cataloguequestionnaires/128-odi 
Every effort is made to test code as thoroughly as possible but user must accept
responsibility for use
-----------------------------------------------------------------------------------------


Syntax: 

^odi^ varlist, gen(name)

^varlist^ needs to contain 10 variables, one for each of the sections of the ODI. 

^gen(^name^)^ specifies the name of the generated ODI variable and needs to be specified.
Any name is admissible.

		  
Examples:

^odi^ varlist, gen(odi)
	
	
Supported Versions:
	
This algorithm supports ODI versions 1.0, 2.0, and 2.1a.
	
	
Admissible Values:
	
All variables need to be scored from 5 - 0. The following value labels apply:
	
	0: First Statement (No Pain)
	1: Second Statement
	2: Third Statement
	3: Fourth Statement
	4: Fifth Statement
	5: Last Statement (Worst Pain)
	
Values outside this range for any variable will terminate the program.
		
	
Calculation of Values:

This algorithm computes the mean score across all sections of the ODI, divides it by 5,
and subsequently multiplies it by 100 to generate percentages.
Values are rounded to the nearest full percentage.
	
	
Treatment of Missing Data:
	
Missing data in one section is replaced by the average score for all sections.
There is a limit of 1 missing section.
More than 1 missing section will result in a missing score.
	
	
References:
	
Fairbank JCT, Pynsent PB. The Oswestry Disability Index.
SPINE 25(22): 2940-2953, 2000.

________________________________________________________
AO Clinical Investigation and Documentation
Program author: Johann Blauth and Monica Daigl
Date: 26.04.2012
