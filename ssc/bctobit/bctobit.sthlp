{smcl}
{* *! version 1.0 31jul2010}{...} 

{cmd: help bctobit}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:bctobit} {hline 2}}Test of the tobit specification{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:bctobit} [{cmd:,} {cmd:Fixed} {cmd: Nodots} {cmd:bfile(}{it:string}{cmd:)} {cmd:reps(}{it:integer 499}{cmd:)}]

{title:Description}

{pstd}{cmd:bctobit} computes the LM-statistic for testing the tobit specification, against the alternative of a model
that is non-linear in the regressors and contains an error term that can be heteroskedastic and non-normally 
distributed. The test is carried out by taking a Box-Cox transformation of the dependent variable [y^(lambda)-1]/lambda and testing whether 
the parameter lambda=1. A rejection of the null suggests that the Tobit specification is unsuitable, as an alternative value for lambda would be required to
return the linearity, homoskedasticity and normality assumptions that are necessary for consistent estimation. 
Critical values are obtained via the parametric bootstrap, where the regressors are assumed to be stochastic.


{title:Options}

{phang}{opt Fixed} specifies that the regressors are fixed in the bootstrap null distribution.

{phang}{opt Nodots} suppresses the bootstrap replication dots.

{phang}{opt bfile(string)} specifies the name of the saved file which contains the LM-statistics computed from the bootstrap samples.

{phang}{opt reps(#)} specifies the number of samples to be drawn from the bootstrap DGP in estimating the bootstrap critical values. 


{title:Remarks}

{pstd}{cmd:bctobit} can only be used after {help tobit} estimation and for data that is left-censored at zero. Bootstrap critical values
are displayed for 1%, 5% and 10% level tests. Asymptotic critical values are not displayed, as using these can result in large size distortions 
for small to moderate samples.  


{title:Example}


. use smoking

. tobit cigarettes income age, ll(0)

{txt}Tobit regression{col 51}Number of obs{col 67}= {res}       100
{txt}{col 51}LR chi2({res}2{txt}){col 67}= {res}    384.59
{txt}{col 51}Prob > chi2{col 67}= {res}    0.0000
{txt}Log likelihood = {res}-239.60931{txt}{col 51}Pseudo R2{col 67}= {res}    0.4452

{col 1}{text}{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}
{col 1}{text}  cigarettes{col 14}{c |}      Coef.{col 26}   Std. Err.{col 37}      t{col 46}   P>|t|{col 55}    [95% Conf. Interval]
{col 1}{text}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}
{col 1}{text}      income{col 14}{c |}{result}{space 2} .2971682{col 26}{space 2} .0045094{col 37}{space 1}   65.90{col 46}{space 3}0.000{col 55}{space 3} .2882194{col 67}{space 3}  .306117
{col 1}{text}         age{col 14}{c |}{result}{space 2} 1.030025{col 26}{space 2} .0623708{col 37}{space 1}   16.51{col 46}{space 3}0.000{col 55}{space 3} .9062523{col 67}{space 3} 1.153798
{col 1}{text}       _cons{col 14}{c |}{result}{space 2}-130.1278{col 26}{space 2} 3.480886{col 37}{space 1}  -37.38{col 46}{space 3}0.000{col 55}{space 3}-137.0355{col 67}{space 3}-123.2201
{col 1}{text}{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}
{col 1}{text}      /sigma{col 14}{c |}{result}{space 2} 4.612162{col 27}{space 1} .3614768{col 55}{space 3} 3.894823{col 67}{space 3}   5.3295
{col 1}{text}{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}
  Obs. summary:{col 18}{res}       20{col 28}{txt} left-censored observations at cigarettes<={res}0
{txt}{col 18}{res}       80{col 28}{txt}    uncensored observations
{col 18}{res}        0{col 28}{txt}right-censored observations

{com}. bctobit, nodots

{txt}LM test of Tobit specification 
{col 20}Bootstrap critical values
{col 5}lm{col 15}%10{col 25}%5{col 35}%1
{res}  .036358{col 13}3.29870{col 22}4.6837926{col 32}9.4022799



{title:Author}
{txt}
{phang}David W. Vincent, Hewlett Packard, UK{break}
david.vincent@hp.com{p_end}



{title:References} 

{p 4 4} Box, G. E. P. and D. R. Cox (1964) “An Analysis of Transformations”, {it:Journal of the Royal Statistical Society}, 26, 211-243.

{p 4 4} Drukker, D. M. (2002) “Bootstrapping a conditional moments test for normality after tobit estimation”, {it:The Stata Journal}, 2, 125-139}.

{p 4 4} Moffatt, P. G. (2003) “Hurdle models of loan default”, {it:School of Economic and Social Studies, University of East Anglia, Norwich, UK}



{p_end}