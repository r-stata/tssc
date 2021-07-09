{smcl}
{* *! version 1.0 10sept2015}
{cmd:help sqmc}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:sqmc }{hline 3}}Squared multiple correlation{p_end}
{p2colreset}{...}


{title:Description}

{bf:sqmc} computes the variance each variable shares with 
the remaining variables in a correlation matrix. Each 
variable is regressed on the remaining variables using 
OLS and the resulting R-square values would represent 
the squared multiple correlations.

{bf:sqmc} reports 95% confidence intervals for the resulting
squared multiple correlations as well. 

KW: multiple correlation
KW: communality
KW: factor 



{title:Examples}

{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13-item18": . keep item13-item18} {p_end}

{phang}{stata "sqmc item13 item14 item15 item16 item17 item18 ": . sqmc item13 item14 item15 item16 item17 item18} {p_end}



{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no




  
