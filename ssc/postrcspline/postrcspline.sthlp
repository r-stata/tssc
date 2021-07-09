{smcl}
{* 12Dec2013}
help for {hi:postrcspline}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi: postrcspline} {hline 2}}Post-estimation commands for models using restricted cubic spline.{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The {cmd:postrcspline} package consists of programs that can 
help with the interpretation of a model that uses a 
restricted cubic spline as one of the explanatory variables. 
The restricted cubic spline must be genereated by
{help mkspline2}. These {cmd: postrcspline} programs are:


{phang}{help adjustrcspline} which displays the adjusted predictions 
after using a restricted cubic spline.{p_end}
{phang}{help mfxrcspline} which displays the marginal effect of a restricted cubic spline{p_end}
{phang}{help mkspline2} creates restricted cubic splines in exactly the same way as 
{helpb mkspline}, but leaves information behind that is used by {cmd:adjustrcspline} and 
{cmd:mfxrcspline}.{p_end}


{title:Author}

{p 4 4 2}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung (WZB){break}
Research unit Skill Formation and Labor Markets{break}
maarten.buis@wzb.eu
{p_end}


{title:Acknowledgement}

{p 4 4 2}
Phil Clayton has given useful comments.


{title:Suggested citation if using postrcspline in published work}

{p 4 4 2}
{cmd:postrcspline} is not an official Stata command. It is a free contribution 
to the research community, like a paper. Please cite it as such.

{p 4 4 2}
Buis, Maarten L.  2009. "POSTRCSPLINE: Stata module containing 
post-estimation commands for models using a restricted cubic spline" 
{browse "http://ideas.repec.org/c/boc/bocode/s456928.html"}


{title:Also see}


{psee} {helpb mkspline2}, {helpb adjustrcspline}, {helpb mfxrcspline}, {helpb rcspline}{p_end}
