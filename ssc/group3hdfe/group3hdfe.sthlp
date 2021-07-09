
{smcl}
{.-}
help for {cmd:group3hdfe} {right:()}
{.-}
 
{title:Title}

group3hdfe - Computes the number of restrictions in a linear regression model with three high dimensional fixed effects.

{title:Syntax}

{p 8 15}
{cmd:group3hdfe} {it:{help varname1}} {it:{help varname2}} {it:{help varname3}}, [{it:options}]

{p}

{title:Description}

{p} This command calculates the number of restrictions needed to ensure identifiability of the fixed effects
in a linear regression model with three high dimensional fixed effects (3hdfe). This number of restrictions can be used
to compute the exact degrees of freedom of a regression with 3hdfe. With the option {cmd:largest} the command can be used to identify
 a subset of the data. If estimation is restricted to this subset then the estimates of the fixed effects are comparable up to an additive scalar factor.


{title:Options}

{p 0 4}{cmd:initi}{cmd:(}{it:value}{cmd:)} {cmd:initj}{cmd:(}{it:value}{cmd:)} {cmd:initk}{cmd:(}{it:value}{cmd:)} Allows
the user to specify the first two restrictions to apply to the data. {cmd:initi} is for the first variable, {cmd:initj} is for the
second variable and {cmd:initk} is for the third variable. The user must select exactly two initial values and these
have to be valid values of the selected variables.  

{p 0 4} {cmd:largest (}{it:new varname}{cmd:)} Creates a new variable with an indicator for membership 
in a subset of the data. If estimation is restricted to this subset then the estimates of the fixed effects are comparable
up to an additive scalar factor.

{p 0 4}{cmdab:verb:ose} Provides more information while the algorithm is running.

{title:Examples}

Example 1:
Compute the number of restrictions in the data and estimate a regression

{p 8 16}{inp:. group3hdfe i j k}{p_end}


Example2:

Identify a subset of the data where estimates of the fixed effects are comparable

{p 8 16}{inp:. group3hdfe i j k, largest(big)} {p_end}

{p 8 16}{inp:. keep if big==1} {p_end}

{title:Author}

{p}
Paulo Guimaraes, BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:pguimaraes2001@gmail.com":pguimaraes2001@gmail.com}

Comments welcome!

{title:Dependencies}

This program requires the {help moremata} set of Mata functions written by Ben Jann

{title:Reference}

If you use this program in your research cite:

Paulo Guimaraes and Pedro Portugal. "A Simple Feasible Alternative Procedure to Estimate Models with 
High-Dimensional Fixed Effects", Stata Journal, 10(4), 628-649, 2010.

{title:Also see}

{p 0 21}
{help reghdfe} (if installed). 
{p_end}

