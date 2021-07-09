{smcl}
{cmd:help nwind}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:nwind} {hline 2}}Postestimation command for ivreg2{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd} {cmd:nwind}{p_end}

{pstd}
{it:if}, {it:in} and {cmd:cluster}({it:varname}) are used from the preceding regression.{p_end}

{title:Description}

{pstd} {cmd:nwind} calculates Newey and Windmeijer's SE for the continuously updated estimator (CUE).{p_end}

{title:Examples:}

{phang2}{cmd:. ivreg2 y (x=z*) if female==1, cue robust}{p_end}
{phang2}{cmd:. nwind}{p_end}

{title:Reference}

{psee}Newey WK, Windmeijer F, 2009. Generalized method of moments with many weak moment conditions. {it:Econometrica} 77(3): 687-719.{p_end}
{psee}Farbmacher, H., 2012. GMM with many weak moment conditions: Replication and application of Newey and Windmeijer (2009). {it:Journal of Applied Econometrics} 27(2): 343-346.{p_end}

{title:Author}

{pstd}Helmut Farbmacher{p_end}
{pstd}Munich Center for the Economics of Aging (MEA){p_end}
{pstd}Max Planck Society, Germany{p_end}
{pstd}farbmacher@mea.mpisoc.mpg.de{p_end}

{title:Also see}

{pstd}Help: {manhelp ivreg2 R}{p_end}
