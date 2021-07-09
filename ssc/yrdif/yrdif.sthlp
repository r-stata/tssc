{smcl}
{* 21 October 2012/22 October 2012/25 October 2012/16 January 2013}{...}
{hline}
help for {hi:yrdif} 
{hline}

{title:Calculate daily date differences}

{p 8 17 2}
{cmd:yrdif} 
{it:bdatevar}
{it:cdatevar}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:,} 
{cmdab:g:enerate(}{it:yearsvar}{cmd:)}
[
{cmdab:yr:unit(}{it:yrunit}{cmd:)}
{cmdab:s:nm(}{it:savenameprefix}{cmd:)}
]

{p 8 17 2}
{cmd:yrdif} 
{it:bdatevar}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:,} 
{cmd:currdate(}{it:current_date}{cmd:)}
{cmdab:g:enerate(}{it:yearsvar}{cmd:)}
[
{cmdab:yr:unit(}{it:yrunit}{cmd:)}
{cmdab:s:nm(}{it:savenameprefix}{cmd:)}
]

{title:Description}

{p 4 4 2}{cmd:yrdif} Calculates people's ages from data on their birth date 
and some "current" daily date.{break}
default: {it:yrunit(actual)} ... ~SAS yrdif 'ACT/ACT' or equivalently 'ACTUAL'.
option: {it:yrunit(actact)} is equivalent.{break}
option:  {it:yrunit(age)}    ... ~SAS yrdif 'AGE' (28Feb={it:anniversary} if 
{it:bdatevar}=29Feb) per 365 days.{break}
option:  {it:yrunit(ageact)} ... (28Feb or 29Feb={it:anniversary} if {it:bdatevar}=29Feb) 
per 365 or 366 days.{break}

{p 4 4 2}There are two syntaxes. In the first, the user supplies two
daily date variables, the first of which is birth date {it:bdatevar} and
the second of which is some "current" date {it:cdatevar}. As is usual,
such variables may be genuinely variable, taking on different values in
different observations. 

{p 4 4 2}In the second syntax, the user supplies a daily date variable,
which is taken to be the birth date {it:bdatevar}, and also through the
{cmd:currdate()} option an expression defining the current daily date.   

{p 4 4 2}This is motivated by the observation that 
SAS ydif( {it:bdatevar} , {it:cdatevar} , 'ACTUAL')
is used to calculate age. {cmd:yrdif}, by default ({it:yrunit(actual)}), 
calculates an approximation to 
SAS yrdif( {it:bdatevar} , {it:cdatevar} , 'ACTUAL'). 
Optionally, {it:yrunit(age)} approximates 
SAS yrdif( {it:bdatevar} , {it:cdatevar} , 'AGE'). 
Lastly, an option {it:yrunit(ageact)} calculates the fractional 
year as the fraction of days since the last {it:anniversary} divided by the 
actual days to the next {it:anniversary}, 365 or 366. Furthermore, with option 
{it:snm(savenameprefix)} (1) a new variable is generated containing age in 
(completed) years, or the number of anniversaries of the original
date of {it:bdatevar}, (2) days since the last {it:anniversary}, and (3) days-length of the 
current year.

{title:Remarks} 

{p 4 4 2}{cmd:yrdif} warns if any variable specified has a format
that does not start with "%d" or "%td". 

{p 4 4 2}{cmd:yrdif} is not suitable for date-times measured in
milliseconds. Use {help dofc()} or {help dofC()} as appropriate first to
convert to daily dates. 

{p 4 4 2}The author's opinion is that the SAS AGE basis is perfect for use 
because the integer part closely reflects the common stated age. The 
fraction part is on a defined basis of 365ths of a year. It's 
consistent with SAS Institutes' AGE basis of YRDIF. 

{p 4 4 2}SAS YRDIF is a financial calculation.{break}
Refer to: SAS 9.4 Functions and CALL Routines: Reference, Fifth Edition

{p 4 4 2}{it:Calculations That Use ACT/ACT Basis}{break}
"In YRDIF calculations that use the ACT/ACT basis, both a 365–day 
year and 366–day year are taken into account. For example, if n365 equals 
the number of days between the start and end dates in a 365–day year, and 
n366 equals the number of days between the start and end dates in a 366–day 
year, the YRDIF calculation is computed as YRDIF=n365/365.0 + n366/366.0. 
This calculation corresponds to the commonly understood ACT/ACT day count 
basis that is documented in the financial literature."

{p 4 4 2}{it:Computing a Person’s Age}{break}
"The YRDIF function can compute a person’s age. The first two arguments, 
start-date and end-date, are required. If the value of basis is AGE, then YRDIF 
computes the age. The age computation takes into account leap years. No other 
values for basis are valid when computing a person’s age."

{title:Options}

{p 4 8 2}{cmd:yrunit()} By default {it:yrunit(actual)}, calculates an approximation to 
SAS yrdif( , 'ACTUAL'). Optionally, {it:yrunit(age)} approximates SAS 
yrdif( , 'AGE'). Lastly, an option {it:yrunit(ageact)} calculates the fractional 
year as the fraction of days since the last birthday divided by the 
actual days to the next birthday, 365 or 366

{p 4 8 2}{cmd:currdate()} provides a specification of the "current"
daily date(s) as numeric value(s) through a defining expression.
Commonly, but not necessarily, this will be an expression defining a
constant such as "mdy(10, 20, 2012)".  {cmd:currdate()} is required as
an option with the second syntax and not allowed with the first syntax. 

{p 4 8 2}{cmd:snm()} specifies one new variable prefix name.  
One new variable is generated containing age as number of completed years. 
A second new variable is generated containing the number of days since 
last {it:anniversary}. 
A third new variable the number of days in the year that ends with the 
next {it:anniversary}, which will be 365 or 366 for {it:yrunit(ageact)} 
and is 365 for {it:yrunit(age)}.

{title:Examples}
{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. mat mbdate = (29,29,19,16,28,19,28,29,29,29\ 2, 2, 1, 7, 3,11, 2, 2, 2, 2\1996,1996,2005,2014,1952,1952,2011,2012,2012,1996)}{p_end}
{p 4 8 2}{cmd:. mat mcdate = (28,29,19,26,19,19,19,19,29,31\ 2, 2, 1,12,10,10,10,10, 2, 8\2000,2000,2020,2019,2012,2012,2012,2012,2012,2013)}{p_end}
{p 4 8 2}{cmd:. set obs `=colsof(mbdate)'}{p_end}
{p 4 8 2}{cmd:. gen bdate = mdy(mbdate[2, _n], mbdate[1, _n], mbdate[3, _n])}{p_end}
{p 4 8 2}{cmd:. gen cdate = mdy(mcdate[2, _n], mcdate[1, _n], mcdate[3, _n])}{p_end}
{p 4 8 2}{cmd:. format bdate cdate %td}{p_end}
{p 4 8 2}{cmd:. yrdif bdate cdate , gen(actual) yrunit(actual)}{p_end}
{p 4 8 2}{cmd:. yrdif bdate cdate , gen(age) yrunit(age)}{p_end}
{p 4 8 2}{cmd:. yrdif bdate cdate , gen(ageact) yrunit(ageact) snm(agect)}{p_end}
{p 4 8 2}{cmd:. list}

{title:Author} 

{p 4 4 2}Allen Buxton{break}
abuxton@childrenoncologygroup.org

{title:Acknowledgments} 

{p 4 4 2}This is a modification of {cmd:personage} by Nicholas J. Cox.

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
n.j.cox@durham.ac.uk



