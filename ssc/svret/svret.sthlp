{smcl}
{hi:help svret}
{hline}
{title:Title}

{p 4 4 2}{cmd:svret} {hline 2} Save returned results to your dataset.


{title:Syntax}

{p 8 14 2}{cmd:svret} [{it:classlist}] [, {cmd:long} {cmd:type(}{it:type}{cmd:)} {cmd:format(}{it:%fmt}{cmd:)} {cmd:keep(}{it:returnlist}{cmd:)}]

{p 4 4 2}where 

{p 8 14 2}{it: classlist} is one or more of the following: {it: e, r, s, all},

{p 8 14 2}{it: type} can be one of the following: {it:all}, {it:scalars}, or {it:macros}, and

{p 8 14 2}{it: returnlist} is a list of returned results currently in memory, e.g., {cmd:r(}{it:N}{cmd:)}.


{title:Description}

{p 4 4 2}{cmd:svret} replaces the dataset in memory with the scalars and macros stored in {cmd:e()}, {cmd:r()}, and {cmd:s()}.


{title:Options}

{p 4 8 2}
{cmd:long} instructs {cmd:svret} to store the results in long form. The default is to store them in wide form.


{p 4 8 2}
{cmd:type(}{it:type}{cmd:)} specifies which type of returns ({it:scalars} or {it:macros}) to save.  The default is to save results from all classes.


{p 4 8 2}
{cmd:format(}{it:%fmt}{cmd:)} allows you to specify the formats of the numbers in your table.
For example, a format of %7.2f specifies that numbers are to be rounded to two decimal places.  See {help format:[D] format} for details.  


{p 4 8 2}
{cmd:keep(}{it:returnlist}{cmd:)} specifies the variables to be kept from the returned results.


{title:Remarks}

{p 4 4 2}LaTeX users can use the user-written command {help texsave:texsave} (if installed) to automatically output their results into a LaTeX table.  See example 3 below.


{title:Examples}

{p 4 4 2}1. Store results from {cmd:summarize} in wide form:

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata summarize price}}

{col 8}{cmd:. {stata svret all}}


{p 4 4 2}2. Store results from {cmd:summarize} in long form:

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata summarize price}}

{col 8}{cmd:. {stata svret r, long format(%8.2fc)}}


{p 4 4 2}3. Output selected statistics from {cmd:summarize} into a LaTeX table.  (This example requires the user-written commands
{help texsave:texsave} and {help sortobs:sortobs} to be installed.):

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata summarize price}}

{col 8}{cmd:. {stata svret r, long format(%8.2fc) keep(r(sd) r(mean) r(min) r(max))}}

{col 8}{cmd:. {stata replace variable = "Standard deviation" if variable == "r(sd)"}}

{col 8}{cmd:. {stata replace variable = "Mean" if variable == "r(mean)"}}

{col 8}{cmd:. {stata replace variable = "Min" if variable == "r(min)"}}

{col 8}{cmd:. {stata replace variable = "Max" if variable == "r(max)"}}

{col 8}{cmd:. {stata rename variable Statistic}}

{col 8}{cmd:. {stata rename contents Value}}

{col 8}{cmd:. {stata sortobs Statistic, values(Mean "Standard deviation" Min Max)}}

{col 8}{cmd:. {stata texsave using "table.tex", title(Price statistics (units in dollars)) footnote("Data obtained from Stata's built-in auto.dta dataset") size(large) replace}}


{title:Author}

{p 4 4 2}Julian Reif, University of Illinois

{p 4 4 2}jreif@illinois.edu


{title:Also see}

{p 4 4 2}
{help svmat:svmat},
{help savedresults:savedresults}

