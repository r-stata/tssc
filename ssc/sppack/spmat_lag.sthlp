{smcl}
{* *! version 1.0.2  16oct2015}{...}
{cmd:help spmat lag}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{cmd:spmat lag} {hline 2}}Create a spatial lag variable
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat lag} [{it:type}] {it:newvar objname varname} [{cmd:,} {opt id(varname)}]


{title:Description}

{pstd}
{opt spmat lag} creates a new variable that is a product of the
spatial-weighting matrix contained in the {cmd:spmat} object {it:objname}
and the variable {it:varname}.  Algebraically, {cmd:spmat lag} computes
{bf:W*y}, where {bf:W} is the spatial-weighting matrix and {bf:y} is the
variable.

{pstd}
The default storage type is {cmd:float}. Specify {cmd:double} for the {it:type} to
store the result in double precision.

{pstd}
When specified, the {bf:id()} option causes {bf:spmat lag} to assert that the
identifiers in the dataset match the identifiers in the spmat object.
The data do not need to be sorted on id variable.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Create the variable {cmd:pollution_w} containing a spatial lag of variable {cmd:pollution}{p_end}
{phang2}{cmd:. spmat lag double pollution_w cobj pollution}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

