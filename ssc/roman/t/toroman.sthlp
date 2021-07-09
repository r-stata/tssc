{smcl}
{* 12jan2011}{...}
{hline}
help for {hi:toroman}
{hline}

{title:Conversion of decimal numbers to Roman numerals}

{p 8 17 2}
{cmd:toroman}
{it:numvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,}  
{cmdab:g:enerate(}{it:romanvar}{cmd:)} 
[{cmd:lower}] 
   
   
{title:Description} 

{p 4 4 2} 
{cmd:toroman} creates 
a string variable {it:romanvar} containing Roman numerals 
from 
a numeric variable {it:numvar} 
following these rules: 

{p 8 8 2}1. Negative, zero and fractional numbers are ignored. 

{p 8 8 2}2. The conversion uses M, D, C, L, X, V, I to represent 
1000, 500, 100, 50, 10, 5, 1 as many times as they occur, except 
that CM, CD, XC, XL, IX, IV are used to represent 900, 400, 90, 40, 9, 4. 

{p 8 8 2}3. No number that is 233888 or greater is converted.  This
limit is implied by the limits on string variables, so that using these
rules any number greater than 244000 (and some numbers less than that)
could not be stored as Roman numerals in a Stata string variable. (The
smallest problematic number is 233888, which would convert to a Roman
numeral consisting of 233 Ms followed by DCCCLXXXVIII, i.e. a numeral
245 characters long.)  See help on {help data types}. 


{title:Options} 

{p 4 8 2} 
{cmd:generate()} specifies the name of the new string variable to be
created and is not optional. 

{p 4 8 2}
{cmd:lower} specifies that numerals are to be produced as lower case letters, 
such as mmxi rather than MMXI. 


{title:Examples} 

{p 4 8 2}{cmd:. toroman numeq, gen(roman)}


{title:Acknowledgments} 

{p 4 4 2}Peter A. [Tony] Lachenbruch suggested the reverse problem on
Statalist. 


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Also see} 

{p 4 4 2}Online: help for {help fromroman} 

