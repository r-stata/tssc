
^sf36v2^ program
___________________


sf36v2 calculates the ^SF36 version 2 score^ (SF36) from your records

-----------------------------------------------------------------------------------------
^DISCLAIMER^: 
Terms and Conditions for Using the 36-Item Short Form Health Survey apply
In order to use the SF-36 Health Survey and scoring algorithms you must register at:
http://www.qualitymetric.com/DefaultPermissions/RequestInformation/tabid/233/Default.aspx
Every effort is made to test code as thoroughly as possible but user must accept
responsibility for use
-----------------------------------------------------------------------------------------


Syntax: 

^sf36v2^ , acute ref(population) fsc(year) details suffix(text) 

^acute^ specifies that the data refer to acute (1 week recall) form of the SF36 score 
        If this option is not specified, the score is used assuming that the data have
        been collected using the standard (4 week recall) form

^ref(^population^)^ can be used to specify the reference population and year
					default reference population is US 1998. The program supports
					US 1998 and JP 2002 reference populations 
		
^fsc(^year^) can be used to specify which factor score coefficients have to be used
             for the computation of the physical and mental component score. Default
			 coefficients are 1990 coefficients

^details^ will produce a table with the norms and factor score coeffients which
          have been used for the calculation			 

^suffix(^text^)^ allows use of suffixes to the variable names specified below
 
		  
Examples: 

^sf36v2^, ref(US 1998)  
^sf36v2^, acute d
^sf36v2^, ref(JP 2002) FCS(1995) suf(1y)                                                    


Note:
The variables containing the information for the calculation need first to be 
named as defined below. Suffixes may be specified as wished (see options above). 

PF01-PF10: Physical Functioning Questions 1-10
RP01-RP04: Role-Physical Questions 1-4
BP01-BP02: Bodily Pain Questions 1-2
GH01-GH05: General Health Questions 1-5
VT01-VT04: Vitality Questions 1-4
SF01-SF02: Social Functioning Questions 1-2
RE01-RE03: Role-Emotional Questions 1-3
MH01-MH05: Mental Health Questions 1-5
HT: Reported Health Transition


Treatment of Missing Data:
A scale score is calculated if a respondent answered at least half of the items in 
a multi-item scale (or half plus one in case of odd nr. of items)



References and norms: 

US norms according to:
Ware JE, Kosinski M, Dewey JE. How to Score Version 2 of the SF-36 (R) Health Survey. 
Lincon, RI: QualityMetric Incorporated, 2000.

Japanese norms according to:
Fukuhara S, Suzukamo Y. Manual of SF-36v2 Japanese version: Institute for Health 
Outcomes & Process Evaluation Research, Kyoto, 2004

________________________________________________________
AO Clinical Investigation and Documentation
Program author: Monica Daigl 
Date: 22.09.2010 
