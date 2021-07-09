{smcl}
{* 10oct2007}{...}
{hline}
help for {hi:scoretest_cox}
{hline}

{title:Perform a score test on the coefficients of a Cox model}

{p 4 13 2}{cmd:scoretest_cox} {it:varlist} 

{p 4 4 2}
{cmd:scoretest_cox} is for use after stcox; see help {help stcox}. 
{p_end}


{title:Description}

{p 4 4 2}
After fitting a Cox model by using {cmd:stcox}, 
{cmd:scoretest_cox} performs a score test on the simultanous significance of the
 coefficients of the variables specified in {it:varlist}. It reports the value 
of the statistic for
the test (to be compared with a chi2 distribution), as well as the degrees of freedom
of the test and the p-value.
{p_end}


{title:Examples}

{p 4 4 2}Use the drugtr.dta dataset and run a Cox model with covariates {cmd:drug}
and {cmd:age} {p_end}
  
{p 12 20 2}{cmd:. use http://www.stata-press.com/data/r10/drugtr}

{p 12 20 2}{cmd:. stcox drug age }

{p 4 4 2}Perform a score test on the significance of the coefficient for variable drug{p_end}

{p 12 20 2}{cmd:. scoretest_cox drug}{p_end}

{p 4 4 2}Perform a score test on the simultaneous significance of the coefficients for variables 
drug and age{p_end}

{p 12 20 2}{cmd:. scoretest_cox drug age}{p_end}



{title:References}

{p 4 8 2}Klein, J.P. and M. L. Moeschberger.1997. 
{it:Survival Analysis. Techniques for Censored and Truncated Data}.
New York, USA: Springer.

{title:Author}

        Isabel Canette, StataCorp LP
        icanette@stata.com

 
{title:Also see}

{p 4 13}
Online:  help for {help stset}, {help stcox}{p_end}

{p 4 13}
Manual:  {hi:{bind:[ST] stset}}, {hi:{bind:[ST] stcox}}.
{p_end}
