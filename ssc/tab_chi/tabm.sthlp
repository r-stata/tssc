{smcl}
{* 11dec2002/1nov2010/27jul2015/1apr2016}{...}
{hline}
help for {hi:tabm}
{hline}

{title:Tabulation of multiple variables}

{p 8 17 2}
{cmd:tabm}
{it:varlist}
[{it:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,}
{cmdab:miss:ing}
{cmdab:one:way} 
{cmd:replace}
{cmdab:tr:anspose}
{cmdab:v:aluelabel(}{it:lblname}{cmd:)}
{it:tabulate_options}]

{p 4 4 2}
{cmd:by} {it:...} {cmd::} may be used with {cmd:tabm}: 
see help {help by}.

{p 4 4 2}
{cmd:fweight}s, {cmd:aweight}s and {cmd:iweight}s are allowed with
{cmd:tabm}; see help {help weights}.


{title:Description}

{p 4 4 2}
{cmd:tabm} tabulates {it:varlist}, containing two or more comparable
variables. 
By default a combined two-way table is shown of variables in {it:varlist} by
values in {it:varlist}. Either all variables should be numeric, or all
variables should be string: the type of the first variable named is
taken to indicate the user's intentions. By default also, variables are
listed in the rows of the table and values in the columns. Optionally, 
two-way tables may be transposed. 

{p 4 4 2}
Optionally, a one-way table may be shown of values in {it:varlist} pooled 
across all variables. 


{title:Remarks} 

{p 4 4 2}For further discussion of handling multiple responses in Stata, 
see Cox and Kohler (2003) and Jann (2005). 


{title:Options}

{p 4 8 2}
{cmd:missing} specifies that observations with missing values are to be
included. 

{p 4 8 2}
{cmd:oneway} specifies display of a one-way table. 

{p 4 8 2}
{cmd:replace} specifies that the tabulated data overwrite the data in
question. The new variables will be {cmd:_stack}, indexing variables,
{cmd:_values}, the distinct values of {it:varlist}, and (if weights are
specified) {cmd:_weight}, the weights. {cmd:replace} may not be specified
with {cmd:by:}. 

{p 4 8 2}
{cmd:transpose} transposes rows and columns as compared with the
default.  This option may be needed if there are too many values to show
as columns.
 
{p 4 8 2}
{cmd:valuelabel(}{it:lblname}{cmd:)} specifies a value label name to be
used in tabulation. The default is that any value label associated with
the first numeric variable in {it:varlist} will be used.  This option
will be ignored in tabulation of string variables.

{p 4 8 2}
{it:tabulate_options} are options allowed with {help tabulate} for two-way or 
one-way tables. 


{title:Examples} 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 100}{p_end}
{p 4 8 2}{cmd:. forval j = 1/7 {c -(}}{p_end}
{p 4 8 2}{cmd:. 	gen y`j' = floor(10 * runiform()^`j')}{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}
{p 4 8 2}{cmd:. tabm y*}{p_end}
{p 4 8 2}{cmd:. tabm y*, transpose}{p_end}
{p 4 8 2}{cmd:. tabm y*, oneway}{p_end}



{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
        n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Lee Sieswerda suggested making {cmd:tabm} {cmd:by}able and 
helped in testing. Svend Juul gave a careful analysis of how missing
values were not being supported properly. 


{title:References} 

{p 4 8 2}
Cox, N.J. and Kohler, U. 2003. 
On structure and shape: the case of multiple responses. 
{it:Stata Journal} 3: 81{c -}99. 

{p 4 8 2}
Jann, B. 2005. Tabulation of multiple responses. 
{it:Stata Journal} 5: 92{c -}122. 


{title:Also see} 

{p 4 13 2}On-line: help for {help tabulate}; {help mrtab} (if installed) 

