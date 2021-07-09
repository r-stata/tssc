{smcl}
{* 08may2018}{...}
{hline}
help for {hi:mads}  {it: Version 4.0} {right:May 10, 2018}
{hline}

{title:mads}: {title:A utility to calculate Median Absolute Deviations}	

{bf:With kind advice from Dr. Nicholas J. Cox, University of Durham, U.K.}

{p 8 17 2}{cmd:mads}
[{it:varlist}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{it:weight}] 
[{cmd:,}
{cmdab:all:obs} 
{cmdab:f:ormat(}{it:numeric_format(s)}{cmd:)} 
{cmdab:m:atname(}{it:matrix_name}{cmd:)}
{it:tabdisp_options}
{cmd:variablenames}
]

{p 8 17 2}{cmd:mads}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{it:weight}] 
[{cmd:,}
{cmdab:all:obs} 
{cmd:by(}{it:varlist}{cmd:)} 
{cmdab:f:ormat(}{it:numeric_format(s)}{cmd:)} 
{cmdab:m:atname(}{it:matrix_name}{cmd:)}
{it:tabdisp_options}
]

{p 4 4 2}{cmd:by ... :} may be used with {cmd:mads}: 
see help on {help by}.

{p 4 4 2}
{cmd:aweight}s and {cmd:fweight}s are allowed; see help
{help weights}.  

{title:Description}

{p 4 4 2}{cmd:mads} calculates mean, standard deviation, median and 
median absolute deviation for {it:varlist}. Any string variables in {it:varlist} are 
ignored. 

{title:Options}

{p 4 8 2}{cmd:allobs} specifies use of the maximum possible 
number of observations for each variable. The default is to 
use only those observations for which all variables in 
{it:varlist} are not missing. 

{p 4 8 2}{cmd:by()} specifies one or more variables defining distinct groups
for which mads should be calculated. {cmd:by()} is allowed
only with a single {it:varname}.  

{p 4 8 2}{cmd:format()} controls the display format of mean, standard 
deviation, median and mad: up to four numeric formats may be given for
the four statistics respectively. 
Formats not specified default to {cmd:%9.3f}.

{p 4 8 2}{cmd:matname()} specifies the name of a matrix in which to save
the results of (the last set of) calculations. There will be 5 columns. 
The columns will contain n, mean, standard deviation, median
and mad.  

{p 4 8 2}{it:tabdisp_options} are options of {help tabdisp} 
other than {cmd:format()}. 

{p 4 8 2}{cmd:variablenames} specifies that the variable names of {it:varlist}
should be used in display. The default is to use variable labels to indicate a
set of variables. 

{title:Examples} 

{p 4 8 2}{cmd:. mads price} 

{p 4 8 2}{cmd:. mads price-foreign}{p_end} 
{p 4 8 2}{cmd:. mads price-foreign, format(%5.1f %5.1f)}

{p 4 8 2}{cmd:. mads price, by(foreign)}

{p 4 8 2}{cmd:. mads price, by(rep78)}

{p 4 8 2}{cmd:. bysort rep78: mads mpg}

{p 4 8 2}{cmd:. bysort foreign: mads price, by(rep78)}

{p 4 8 2}{cmd:. mads price if rep78 == 5, by(foreign)}

{hline}

{cmd: uses logic and code snippets from moments.ado and .sthlp files.}

{title:Author}

{p 4 4 2}Basharat Hussain{break} 
        bhgillani@gmail.com

{hline}

