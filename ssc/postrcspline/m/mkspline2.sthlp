{smcl}
{* 12Dec2013}
help for {hi:mkspline2}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi: mkspline2} {hline 2}} Linear and restricted cubic spline construction for use with the {cmd:postrcspline} package{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:mkspline2} works exactly the same as {helpb mkspline}, except that
it leaves behind information on which variables have been created,
the original variable, and the knots as {help char:characteristics}. 
If other restricted cubic splines were created using {cmd:mkspline2},
than {cmd:mkspline2} will overwrite information from the previous
splines. As a consequence, the post-estimation commands 
{help adjustrcspline} and {help mfxrcspline} will only use information 
from the last spline created by {cmd:mkspline2}.

{pstd}
The syntax and the options are discussed in the helpfile of
{helpb mkspline}.


{title:Author}

{p 4 4 2}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung (WZB){break}
Research unit Skill Formation and Labor Markets{break}
maarten.buis@wzb.eu
{p_end}


{title:Also see}


{psee}Online:  {helpb mkspline}, {helpb mfxrcspline}, {helpb adjustrcspline}, {helpb char}{p_end}

