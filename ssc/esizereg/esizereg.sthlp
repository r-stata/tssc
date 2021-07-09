{smcl}
{* *! version 2.0.0 29May2019}{...}

{title:Title}

{p2colset 5 17 18 2}{...}
{p2col:{hi:esizereg} {hline 2}} Effect size based on a linear regression coefficient  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Postestimation version of esizereg 

{p 8 14 2}
{cmd:esizereg}
{it: coef_name}
[{it:aweight}]
{cmd:,}
[
{opt lev:el(#)}
]


{pstd}
Immediate form of esizereg

{p 8 14 2}
{cmd:esizeregi}
{it: #coefficient}
{cmd:,}
{opt sd:y(#)}
{opt n1(#)}
{opt n2(#)}
[
{opt lev:el(#)}
]


{pstd}
In the postestimation version of {cmd:esizereg}, {it: coef_name} identifies a coefficient in the preceding estimation model. {it: coef_name} is typically a variable name with or without a level indicator (see {helpb fvvarlist}). The easiest
way to identify the {it: coef_name} assigned by the estimation model is to specify the {cmd: coeflegend} option; see {helpb estimation options}.  

{pstd}
In the immediate version of {cmd:esizereg}, {it: coefficient} is the actual numeric value of the coefficient.

{pstd}
In either version of {cmd:esizereg}, the coefficient must be for binary level variable, as {cmd: esizereg} computes the standardized mean difference between 2 levels of a variable.


{synoptset 16 tabbed}{...}
{synopthdr:esizereg}
{synoptline}
{synopt:{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p 4 6 2} {cmd:aweights} are allowed.{p_end}


{synoptset 16 tabbed}{...}
{synopthdr:esizeregi}
{synoptline}
{p2coldent:* {opt sd:y(#)}}standard deviation of the dependent variable{p_end}
{p2coldent:* {opt n1(#)}}number of observations in group 1{p_end}
{p2coldent:* {opt n2(#)}}number of observations in group 2{p_end}
{synopt:{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p 4 6 2}* {opt sdy, n1} and {opt n2} are required.{p_end}



{title:Description}

{pstd}
{opt esizereg} is a postestimation command that calculates Cohen's {it:d} effect size (Cohen 1988) for the {it: adjusted} mean difference of a continuous variable 
between two groups. {opt esizereg} uses the unstandardized regression coefficient of the treatment variable as the numerator (which is equivalent to the difference 
between two covariate adjusted means) and estimates the within groups pooled standard deviation as the denominator. Estimation models currently supported by {opt esizereg} 
are {helpb regress}, {helpb tobit}, {helpb truncreg}, {helpb hetregress}, and {helpb xtreg}. When {cmd: aweights} are specified in the estimation model, 
{opt esizereg} produces a weighted effect size estimate.

{pstd}
{cmd: esizeregi} is the immediate form of {cmd:esizereg}; see {helpb immed}.



{title:Options}

{p 4 8 2}
{cmd:sdy(}{it:#}{cmd:)} specifies the standard deviation of the dependent variable. This can be found by running the {helpb summarize} command on the dependent variable;
{cmd: sdy() is required for esizeregi}.

{p 4 8 2}
{cmd:n1(}{it:#}{cmd:)} specifies the number of observations in group 1. The number of observations in each group can be found by running the {helpb tabulate oneway} command on the
treatment variable; {cmd: n1() is required for esizeregi}.

{p 4 8 2}
{cmd:n2(}{it:#}{cmd:)} specifies the number of observations in group 2; {cmd: n2() is required for esizeregi}.

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for confidence intervals. The default is {cmd:level(95)}. 



{title:Examples}

{pstd}
{opt 1) esizereg:}{p_end}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "webuse cattaneo2": . webuse cattaneo2}} {p_end}

{pmore} Estimate the treatment effect of {cmd: mbsmoke} on {cmd: bweight}, controlling for several covariates. {p_end}
{pmore2}{bf:{stata "regress bweight mbsmoke mmarried mage fbaby medu": . regress bweight mbsmoke mmarried mage fbaby medu}} {p_end}

{pmore} Compute the effect size for {cmd: mbsmoke}. {p_end}
{pmore2}{bf:{stata "esizereg mbsmoke": . esizereg mbsmoke}} {p_end}

{pmore} Re-estimate the model, now specifying {cmd:mbsmoke} as a factor variable, and adding an aweight. {p_end}
{pmore2}{bf:{stata "regress bweight i.mbsmoke mmarried mage fbaby medu [aw=nprenatal]": . regress bweight i.mbsmoke mmarried mage fbaby medu [aw=nprenatal]}} {p_end}

{pmore} Compute the weighted effect size for {cmd: 1.mbsmoke}. {p_end}
{pmore2}{bf:{stata "esizereg 1.mbsmoke": . esizereg 1.mbsmoke}} {p_end}

{pstd}
{opt 2) esizeregi:}{p_end}

{pmore} Estimate the treatment effect of {cmd: mbsmoke} on {cmd: bweight}, controlling for several covariates. {p_end}
{pmore2}{bf:{stata "regress bweight mbsmoke mmarried mage fbaby medu": . regress bweight mbsmoke mmarried mage fbaby medu}} {p_end}

{pmore} Get the standard deviation of the dependent variable {cmd: bweight}. {p_end}
{pmore2}{bf:{stata "sum bweight": . sum bweight}} {p_end}

{pmore} Get the number of observations in each group of {cmd: mbsmoke}. {p_end}
{pmore2}{bf:{stata "tab mbsmoke": . tab mbsmoke}} {p_end}

{pmore} Compute the effect size. {p_end}
{pmore2}{bf:{stata "esizeregi -224.422, sdy(578.8196) n1(864) n2(3778)": . esizeregi -224.422, sdy(578.8196) n1(864) n2(3778)}} {p_end}

{pmore} Conduct a sensitivity analysis using the effect size and standard error values produced by {cmd: esizereg}. {p_end}
{pmore2}{bf:{stata "evalue smd -0.383382, se(0.037920)": . evalue smd -0.383382, se(0.037920)}} {p_end}

{pmore} Same as above, but using the local macros d and se generated by {cmd: esizereg} or {cmd: esizeregi}. {p_end}
{pmore2}{bf:{stata "evalue smd `d', se(`se')": . evalue smd `d', se(`se')}} {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:esizereg} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(est)}}model coefficient for the point estimate{p_end}
{synopt:{cmd:r(sdy)}}standard deviation of the dependent variable{p_end}
{synopt:{cmd:r(n1)}}sample size of group 1{p_end}
{synopt:{cmd:r(n2)}}sample size of group 2{p_end}
{synopt:{cmd:r(d)}}Cohen's d{p_end}
{synopt:{cmd:r(se)}}standard error of the Cohen's d estimate{p_end}
{synopt:{cmd:r(lb_d)}}lower confidence bound for Cohen's d{p_end}
{synopt:{cmd:r(ub_d)}}upper confidence bound for Cohen's d{p_end}
{p2colreset}{...}

{pstd}
{cmd:esizereg} also stores the following local macros, making them accessible for later use:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:d}}Cohen's d{p_end}
{synopt:{cmd:se}}standard error of the Cohen's d estimate{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Cohen, J. (1988).  {it: Statistical Power Analysis for the Behavioral Sciences}. 2nd ed.  Hillsdale, NJ: Erlbaum.{p_end}

{p 4 8 2}
Lipsey, M. W., and Wilson, D. B. (2001). Applied social research methods series; Vol. 49. {it:Practical meta-analysis}. Thousand Oaks, CA, US: Sage Publications, Inc. {p_end}



{marker citation}{title:Citation of {cmd:esizereg}}

{p 4 8 2}{cmd:esizereg} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). ESIZEREG: Stata module for calculating effect size based on a linear regression coefficient. 
Statistical Software Components S458607, Boston College Department of Economics. {p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb esize}, {helpb evalue} if installed {p_end}

