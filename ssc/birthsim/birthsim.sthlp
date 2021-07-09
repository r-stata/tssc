{smcl}
{* *! version 11.1 25Jan2013}{...}
{cmd:help birthsim}
{hline}

{title: Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:birthsim} {hline 2}}Simulate completed fertility and birth intervals{p_end}
{p2colreset}{...}



{title:Syntax}

{p 8 17 2}
{cmd:birthsim} [,startyear(real 2000) endyear(real 2100) birthday(real 5) birthmonth(real 5) 
birthyear(real 1985) marriageday(real 5) marriagemonth(real 5) marriageyear(real 2005) 
 latestageatbirth(real 50) probabilityconceive(real .2) contraceptioneffectiveness(real 0)
 probabilitymiscarriage(real .25) fetallossinfertility(real 4) monthsofpostpartum(real 12)]



{title: Description}

{cmd:birthsim} simulates birth intervals and number of children born according to inputted parameters. Calculations 
are based on Preston, Heuvaline, and Guillot (2001). It creates a column of lived months, with values 
for months that resulted in a conception. From this data it is also easy to calculate respective birthdays 
and ages of the simulated offspring. To obtain a statistical range of births given the parameters,
simulate the process multiple times using the {cmd:simulate} command as shown in the example below. 



{title: Parameters/Options}

{phang}{probabilityconceive} This is the probability that the sexually active woman will conceive in any given month. 
The default value is set to .2, which is average (Preston, Heuvaline, and Guillot 2001). 

{phang}{latestageatconception} This is the latest age at which the woman will conceive. The demographic assumption is 
that the reproductive lifespan runs from 15-50, so 49.25 is set as the default value (making 50 the latest age at which
one has children).This is in exact age and not age at last birthday,so 50 years and one day is not within the reproductive lifespan.

{phang}{contraceptioneffectiveness} This is the effectiveness rate of contraception. A contraceptive practice that works 
70% of the time would have a rate of .7. The default value here is 0, or no contraception. 

{phang}{probabilitymiscarriage} This is the probability that any given pregnancy will end in miscarriage. The default value is set at
.25, which is the average in the absence of induced abortion according to Preston, Heuvaline, and Guillot's (2001). 

{phang}{fetallossinfertility} This is the number of months of infertility due to a miscarriage, including months of 
reproductive lifespan used up by the initial pregnancy. The default value is set to 4, (three months 
pregnant, one month postpartum) which is average (Preston, Heuvaline, and Guillot 2001). 

{phang}{birthinfertility} This is the number of months of infertility due to a live birth. The default is set at 12 
(9 months pregnancy, 3 months postpartum), which assumes an absence of breastfeeding.  

{phang}{endyear} This is the year that the simulation ends, it could be considered the death date, but any date after the last
date of reproduction will suffice. 

{phang}{birthday} This is the numerical day of the month that the woman was born. 

{phang}{birthmonth} This is the numerical month that the woman was born (1=Jan, etc.)

{phang}{birthyear} This is the numerical year that the woman was born, it also represents the beginning year of the simulation.

{phang}{marriageday} This is the numerical day of the month that the woman began having sex. 

{phang}{marriagemonth} This is the numerical month that the woman started having sex.

{phang}{marriageyear} This is the numerical year that the woman started having sex.



{title: Example}

{phang}birthsim, marriageyear(2005) marriagemonth(5) marriageday(1) birthyear(1985) birthmonth(5) birthday(5) endyear(2100)

{phang}simulate children=r(children), nodots reps(1000): birthsim 



{title: Author}

{phang} Stephen Cranney, PhD Candidate in Sociology/Demography, University of Pennsylvania{break}
scranney@sas.upenn.edu



{title: Reference}

{phang}Preston, Samuel H., Patrick Heuveline, and Michel Guillot. "Demography: measuring and modeling population processes," 2001.  
{p_end}











