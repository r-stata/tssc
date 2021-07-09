{smcl}
{* *! version 1.0 20Dec2014}
{cmd:help percat}
{hline}

{title:Title}

{p2colset 9 18 18 2}{...}
{p2col :{hi:percat }{hline 1}}percentile-based categorisation{p_end}
{p2colreset}{...}


{p 8 8}
{cmd:percat}
{it:varlist}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
[{cmd:,} {it:options}]


{title:Description}

With {bf:percat}, one can categorise a continous variable based on percentiles 
provided by the programme. The default option is the 50th percentile (median), 
meaning that {bf:percat} will convert the chosen variable into a dummy variable 
using the median split procedure. For other options, see below:   


{title:options}

{bf:b25}, categorises bottom 25% in the first, and the rest in the second category 
{bf:bt25}, categorises bottom 25% in the first, and top 25% in the second category
{bf:t25}, categorises bottom 75% in the first, and top 25% in the second category 
{bf:f25}, categorises in four equal segments (25% each)


KW: categorical
KW: percentile
KW: dummy 


{title:Examples}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "percat price": . percat price}{p_end}
{phang}{stata "percat price, b25": . percat price, b25}{p_end}
{phang}{stata "percat price, bt25": . percat price, bt25}{p_end}
{phang}{stata "percat price, t25": . percat price, t25}{p_end}
{phang}{stata "percat price, f25": . percat price, f25}{p_end}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "percat price if foreign==1": . percat price if foreign==1}{p_end}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "percat price in 1/25": . percat price in 1/25}{p_end}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "percat price mpg turn": . percat price mpg turn}{p_end}
 


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no




  
