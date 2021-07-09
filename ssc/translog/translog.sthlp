{smcl}
{* 14March2017}{...}

{title:Title}

{cmd:translog } creates new variables for a translog function. 
     
{marker syntax}{...}
{title:Syntax}

{p 4 10 2}
{cmd:translog }[{it:varlist}] 
[,{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt t:ime(varname)}}specify the time trend variable{p_end}
{synopt :{opt norm:alize}}normalize the varibales{p_end}
{synopt :{opt l:ocal(str)}}specify the local name to store the generating varlist{p_end}

{synoptline}
 

{marker description}{...}
{title:Description}

{pstd}
{cmd:translog} generates new variables for a translog function with the specified variables. The translog function form is widely applied in empirical studies for it is regarded as the second order approximation to the unknown function. 
For the regression with a translog function, it is need to create a combination of the fundmental variables. This command provides a convenient way.



{marker examples}{...}
{title:Examples}

{pstd}

{phang2}{cmd:. webuse greene9}{p_end}

{phang2}{cmd:. gen year=_n}{p_end}

{phang2}{cmd:. translog capital labor, t(year) norm l(xvar) }{p_end}

{phang2}{cmd:. display "`xvar'" }{p_end}

{phang2}{cmd:. reg lnv `xvar' }{p_end}
{pstd}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:translog} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macro}{p_end}
{synopt:{cmd:r(xvar)}}the generating variables{p_end}


{hline}

{title:Authors}
{phang}
{cmd:Kerry Du}, Center for Economic Research, Shandong University, China.{break}
 E-mail: {browse "mailto:kerrydu@sdu.edu.cn":kerrydu@sdu.edu.cn}. {break}



