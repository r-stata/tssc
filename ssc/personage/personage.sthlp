{smcl}
{* 21 October 2012/22 October 2012/25 October 2012/16 January 2013}{...}
{hline}
help for {hi:personage} 
{hline}

{title:Calculate people's ages or similar daily date differences}

{p 8 17 2}
{cmd:personage} 
{it:bdatevar}
{it:cdatevar}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:,} 
{cmdab:g:enerate(}{it:yearsvar} [{it:daysvar} [{it:loyvar}]]{cmd:)}

{p 8 17 2}
{cmd:personage} 
{it:bdatevar}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]  
{cmd:,} 
{cmd:currdate(}{it:current_date}{cmd:)}
{cmdab:g:enerate(}{it:yearsvar} [{it:daysvar} [{it:loyvar}]]{cmd:)}


{title:Description}

{p 4 4 2}{cmd:personage} is designed in the first instance for
calculations of people's ages from data on their birth date and some
"current" daily date. Depending on what is specified, a new variable is
generated containing age in (completed) years, or the number of
anniversaries of that person's original date of birth; and new variables
may be generated containing (1) time since last birthday in days and (2)
length of the current year.  

{p 4 4 2}There are two syntaxes. In the first, the user supplies two
daily date variables, the first of which is birth date {it:bdatevar} and
the second of which is some "current" date {it:cdatevar}. As is usual,
such variables may be genuinely variable, taking on different values in
different observations. 

{p 4 4 2}In the second syntax, the user supplies a daily date variable,
which is taken to be the birth date {it:bdatevar}, and also through the
{cmd:currdate()} option an expression defining the current daily date.   

{p 4 4 2}Although calculating ages of people is the motivating problem,
nothing stops application to any problem requiring completed years, and
optionally extra days, as a representation of the difference between two
daily dates (including differences of either positive or negative sign).
Descriptions here implying birth dates and current dates are for
concreteness and do not exclude other applications. 


{title:Remarks} 

{p 4 4 2}Most differences between dates and/or times are just a matter
of subtraction.  Daily date differences have an extra twist because of
the two-fold complications caused by leap years, namely that years may
be 365 or 366 days long and that 29 February occurs only in leap years.
In {cmd:personage} people born on 29 February are deemed to have a
virtual birthday on 28 February in non-leap years. The approximation
that years average 365.25 days is often used in statistical computing,
but this program offers an "exact" calculation. 

{p 4 4 2}{cmd:personage} warns if any variable specified has a format
that does not start with "%d" or "%td". 

{p 4 4 2}Users wanting a string representation combining years and days
can just concatenate afterwards. 

{p 4 4 2}{cmd:personage} deliberately is shy of offering a computed
fraction of year for time since the last birthday (anniversary), leaving
it to users to decide how to define and store such fractions. Note in
particular for replicable results that fractions will differ slightly as
between storage in {cmd:float} and {cmd:double} variables.  If you do
not understand this, {stata search precision} for material explaining
why.  

{p 4 4 2}{cmd:personage} is not suitable for date-times measured in
milliseconds. Use {help dofc()} or {help dofC()} as appropriate first to
convert to daily dates. 


{title:Options}

{p 4 8 2}{cmd:currdate()} provides a specification of the "current"
daily date(s) as numeric value(s) through a defining expression.
Commonly, but not necessarily, this will be an expression defining a
constant such as "mdy(10, 20, 2012)".  {cmd:currdate()} is required as
an option with the second syntax and not allowed with the first syntax. 

{p 4 8 2}{cmd:generate()} specifies one, two or three new variable
names.  In the first case, a new variable is generated containing age as
number of completed years. In the second case, two new variables are
generated containing age as number of completed years and number of days
since last birthday. In the third case, three new variables are
generated containing age as number of completed years,  number of days
since last birthday, and length of year so far, or number of days in the
year that ends with the next birthday. This last, which will be 365 or
366, is for users wishing to carry out further calculations, most simply
of fraction of year elapsed since the last birthday. {cmd:generate()} is
a required option. 


{title:Examples}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. mat values = (28, 19, 28, 29, 29, 29\3, 11, 2, 2, 2, 2\1952, 1952, 2011, 2012, 2012, 1996)}{p_end} 
{p 4 8 2}{cmd:. set obs `=colsof(values)'}{p_end}
{p 4 8 2}{cmd:. gen bdate = mdy(values[2, _n], values[1, _n], values[3, _n])}{p_end}
{p 4 8 2}{cmd:. gen cdate = mdy(10,19,2012)}{p_end}
{p 4 8 2}{cmd:. replace cdate = mdy(2, 29, 2012) in -2}{p_end} 
{p 4 8 2}{cmd:. replace cdate = mdy(8, 31, 2013) in L}{p_end}
{p 4 8 2}{cmd:. format bdate cdate %td}{p_end}
{p 4 8 2}{cmd:. personage bdate cdate, gen(age1 days1)}{p_end}
{p 4 8 2}{cmd:. personage bdate, currdate(mdy(12,31,2012)) gen(age2 days2)}{p_end}
{p 4 8 2}{cmd:. list}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}A question from Jos{c e'} Maria Pacheco de Souza, Universidade
de S{c a~}o Paulo, rekindled my interest in this problem. Phil Clayton,  
Mike Corbett and Alison Smith all found embarrassing bugs. 


