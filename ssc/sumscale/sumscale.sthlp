{smcl}
{* *! version 1.0 22jan2015}
{cmd:help sumscale}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:sumscale }{hline 1}}generating summated scales{p_end}
{p2colreset}{...}

{p 8 8}
{cmd:sumscale}
[{cmd:,} {it:f1(varlist) f2(varlist) etc....  options}]


{title:Description}

{bf:sumscale} generates new variables by combining the scores of a set of
ordinal/dummy variables of an underlying factor/construct. 

There are two ways in which sumscale combines the scores of a set of 
ordinal variables/items: 1) take the average and 2) take the sum. The 
first option is the {bf:default} of sumscale. The second option can be 
chosen by adding {bf:fsum} as shown below. sumscale displays also 
some descriptive statistics as well as the Cronbach Alpha coefficient 
of reliability for the newly generated summated scale/s.      

sumscale allows also for combining the scores of a set of dummy variables.
This is simply done by taking the sum of the scores. This option can be
chosen by adding {bf:fdummy} as shown below. For the resulting variables
the program displays the descriptive statistics and the Kuder-Richardson 
coefficient of reliability.    

{title:options}

{bf:fsum} sums/aggregates the scores of a set of ordinal variables/items 
{bf:fdummy} sums/aggregates the scores of a set of dummy variables/items 


KW: summated 
KW: scale
KW: reliability
KW: alpha
KW: factor analysis 


{title:Examples}

{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13 item14 item15 item16 item32 item41": . keep item13 item14 item15 item16 item32 item41}{p_end}
{phang}{stata "sumscale, f1(item13 item14 item15 item16) f2(item32 item41)": . sumscale, f1(item13 item14 item15 item16) f2(item32 item41)}{p_end}
{phang}{stata "sumscale, f1(item13 item14 item15 item16) f2(item32 item41) fsum": . sumscale, f1(item13 item14 item15 item16) f2(item32 item41) fsum}{p_end}


{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13 item14 item15 item16 item32 item41": . keep item13 item14 item15 item16 item32 item41}{p_end}
{phang}{stata "qui recode item13 item14 item15 item16 item32 item41 (1 2 3 = 0) (4 5 = 1)": . qui recode item13 item14 item15 item16 item32 item41 (1 2 3 = 0) (4 5 = 1)}{p_end}
{phang}{stata "sumscale, f1(item13 item14 item15 item16) f2(item32 item41) fdummy": . sumscale, f1(item13 item14 item15 item16) f2(item32 item41) fdummy}{p_end}

 
 
{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no




  
