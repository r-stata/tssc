{smcl}
{* 1.0.0 HG 10 May 2020}{...}
{hline}
{cmd:help vardistinct}
{hline}

{title:Title}

{p2colset 5 20 19 2}{...}
{p2col: {hi:vardistinct} {hline 2}}Generate a variable representing the number(s) of distinct observations or values{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}{cmd:vardistinct} {varlist} {ifin} {cmd:,} {opt gen:erate(newvar)} [ {opt by(varlist)} {opt m:issing} ]
{p2colreset}{...}


{title:Description}

{p 4 4 2}The {cmd:vardistinct} command generates a new variable representing the number of distinct
observations or values with respect to the variables in {varlist}. Variables are considered jointly
so that {newvar} represents the number of distinct groups defined by the values of variabes in {it:varlist}.

{p 4 4 2}By default, missing values are not counted. {it:varlist} may
contain both numeric and string variables.  


{title:Options} 

{p 4 4 2}{opt by(varlist)} repeats the command on subsets of the data based on {it:varlist}. 

{p 4 4 2}{cmd:missing} specifies that missing values are to be included
in calculating the number of distinct observations. 


{title:Examples}

{p 4 4 2}{cmd:. sysuse auto}{p_end}
{p 4 4 2}{cmd:. vardistinct rep78, generate(newvar)}{p_end}
{p 4 4 2}{cmd:. vardistinct rep78, generate(newvar) missing}{p_end}
{p 4 4 2}{cmd:. vardistinct rep78 foreign, generate(newvar)}{p_end}
{p 4 4 2}{cmd:. vardistinct rep78, by(foreign) generate(newvar)}{p_end}
{p 4 4 2}{cmd:. vardistinct rep78, by(foreign) generate(newvar) missing}{p_end}


{title:Author}

{p 4 4 2}Harrison Garrett, hgarrett515@gmail.com


{title:Acknowledgment}

{p 4 4 2}This program grew out of a response posted to Statalist by Nicholas J. Cox.
