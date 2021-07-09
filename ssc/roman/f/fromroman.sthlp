{smcl}
{* 11jan2011}{...}
{hline}
help for {hi:fromroman}
{hline}

{title:Conversion of Roman numerals to decimal numbers}

{p 8 17 2}
{cmd:fromroman}
{it:romanvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,}  
{cmdab:g:enerate(}{it:numvar}{cmd:)} 
[{cmd:re(}{it:regex}{cmd:)}] 
   
   
{title:Description} 

{p 4 4 2} 
{cmd:fromroman} creates a numeric variable {it:numvar} from a string
variable {it:romanvar} following these rules: 

{p 8 8 2}1. Any spaces are ignored. 

{p 8 8 2}2. Lower case letters are treated as if upper case. 

{p 8 8 2}3. Numerals must match the Stata regular expression
"^M*(CM|DCCC|DCC|DC|D|CD|CCC|CC|C)?(XC|LXXX|LXX|LX|L|XL|XXX|XX|X)?(IX|VIII|VII|VI|V|IV|III|II|I)?$".  
Note that this forbids e.g. CCCC, XXXX or IIII. But see documentation of the {cmd:re()} 
option below. 

{p 8 8 2}4. Single occurrences of CM, CD, XC, XL, IX, IV are treated as
900, 400, 90, 40, 9, 4 respectively. 

{p 8 8 2}5. M, D, C, L, X, V, I are treated as 1000, 500, 100, 50, 10,
5, 1 respectively as many times as they occur.

{p 8 8 2}6. The results of 4 and 5 are added.  

{p 8 8 2}7. Input of any other expression or characters is trapped as an
error and results in missing. Examples would be minus signs and decimal
points. 

{p 4 4 2}
Note that there is no explicit upper limit for the integer values
created. In practice, the limit is implied by the limits on string
variables, so that using these rules any number greater than 244000 (and
some numbers less than that) could not be stored as Roman numerals in a
Stata string variable.  (The smallest problematic number is 233888, which
would convert to a Roman numeral consisting of 233 Ms followed by
DCCCLXXXVIII, i.e. a numeral 245 characters long.) See help on 
{help data types}. 


{title:Options} 

{p 4 8 2} 
{cmd:generate()} specifies the name of the new numeric variable to be
created and is not optional. 

{p 4 8 2}
{cmd:re()} specifies a regular expression other than the default for checking 
input. 


{title:Examples} 

{p 4 8 2}{cmd:. fromroman roman, gen(numeq)}


{title:Acknowledgments} 

{p 4 4 2}Peter A. [Tony] Lachenbruch suggested this problem on
Statalist. Sergiy Radyakin's comments on that list provoked more error
checking.  


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Also see} 

{p 4 4 2}Online: help for {help toroman} 

