

{smcl}
{* 19April2019}{...}
{cmd:help biastab2}{right: ({browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":Quantitative Bais Aanlysis in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:biastab2} {hline 2} Two-way table of frequencies


{title:Syntax}

{p 4 4 2}
{cmd:biastab2}
{it:depvar indepvar}
{ifin}

{title:Description}

{pstd}
Command {helpb biastab2}, which is similar to the the official Stata command {helpb tab2}, produces a two-way table of frequency counts.
However, the category values are presented from highest to the lowest, which faciliates {it:bias analysis}, instead of from the lowest to the highest as the official Stata command {helpb tab2} does.


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb biasepi}, {helpb biasselect}, {helpb biascon}, {helpb biasmis}, {helpb biassurv}, {helpb biastab2}
{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:biastab2} stores the following in {cmd:r()}:

{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(B)}}a two-way table of frequency counts{p_end}



