{smcl}
{hline}
help for {cmd:creplace}{right:(Roger Newson)}
{hline}

{title:Exchange values cyclically between variables}

{p 8 21 2}
{cmd:creplace} [ {varlist} ] {ifin} [ , {opt pr:evious} ]


{title:Description}

{pstd}
{cmd:creplace} is an extended version of {helpb replace},
which exchanges values cyclically between variables in a list of two or more variables.
By default, the values in each variable are replaced by values from the next variable in the list,
or by values from the first variable, in the case of the last variable.
Optionally, the values in each variable are replaced by values from the previous variable in the list,
or by values from the last variable, in the case of the first variable.
If there are only two variables in the list, then their values will simply be exchanged.
Variables in the list must be all numeric or all string.
After exchanging the values,
{cmd:creplace} will {helpb compress} these variables to the smallest {help type:storage type} possible without loss of information.


{title:Options for {cmd:creplace}}

{phang}
{opt previous} specifies that the values of each variable in the list will be replaced
by values from the previous variable in the list,
or by values from the last variable in the list,
in the case of the first variable in the list.
If {cmd:previous} is not specified,
then the values of each variable in the list will be replaced by values from the next variable in the list,
or by values from the first variable in the list,
in the case of the last variable in the list.


{title:Remarks}

{pstd}
{cmd:creplace} can cyclically exchange values between a list with any number of variables greater than one.
However, in most cases, there will only be two variables,
and their values will be exchanged pairwise,
at least in the subset of observations specified by the {helpb if} and {helpb in} qualifiers.

{pstd}
{cmd:creplace} is commonly used in output datasets (or resultssets) produced by the {helpb parmest} package,
downloadable from {help ssc:SSC}.
Such output datasets have one observation for each of a set of estimated parameters,
and data on estimates and lower and upper confidence limits,
which are stored in three variables.
The user may replace the values of these variables
to perform an end point transformation on the confidence intervals.
If the end point transformation is decreasing,
then the user may use {cmd:creplace} to exchange values of the lower and upper confidence limits,
after the transformation has been performed.


{title:Examples}

{phang2}{cmd:.creplace weight length headroom}{p_end}

{phang2}{cmd:.creplace weight length headroom, previous}{p_end}

{phang2}{cmd:.creplace min95 max95}{p_end}

{phang2}{cmd:.creplace min95 max95 if parm=="length"}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {manlink D generate}
{p_end}

{psee}
{space 2}Help:  {manhelp replace D}, {manhelp generate D}{break}
{helpb parmest} if installed
{p_end}
