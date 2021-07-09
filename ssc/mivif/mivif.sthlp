{smcl}
{* version 1.0.5 13feb2013}{...}
{cmd:help mivif}
{hline}

{title:Title}

{p 5}
{cmd:mivif} {hline 2} Variance inflation factors in 
multiply imputed datasets


{title:Syntax}

{p 5}
Post estimation after {helpb mi estimate} {cmd::} {helpb regress}

{p 8}
{cmd:mivif} 
[{cmd:, {ul:i}mputations(}{it:{help numlist}}{cmd:)} {opt unc:entered} 
{opt nofisherz}]


{p 5}
Variance inflation factors for variables

{p 8}
{cmd:mivif} {varlist} {ifin} 
[{cmd:, {ul:i}mputations(}{it:{help numlist}}{cmd:)} {opt unc:entered} 
{opt nofisherz}]

{p 12 14}
Stata's {help fvvarlist:factor variable notation} is allowed, with the 
exception of the {cmd:ibn.} operator in a user supplied {it:varlist}.


{title:Description}

{pstd}
{cmd:mivif} calculates variance inflation factors in multiply imputed 
datasets. See {help mivif##rm:Remarks}.

{pstd}
{cmd:mivif} requires the data to be {it:flong} 
{help mi_styles:{it:style}}. To change the style of mi data see 
{helpb mi convert}.

{marker rm}
{title:Remarks}

{pstd}
According to Rubin's combination rules, the MI point estimate is the 
mean of the estimates for each imputed dataset. This value of interest 
is assumed to be normally distributed. The VIF for a right-hand-side 
variable {hi:x1} is calculated as 1/(1 - R2), where R2 is the 
coefficient of determination in a model that regresses {hi:x1} on the 
other right-hand-side variables. To improve normality for R-squared, 
Harel (2009) suggests to apply Fisher's z-transformation. 

{pstd}
{cmd:mivif} runs the regression of {hi:x1} on all other {hi:x} in each 
imputed dataset and calculates the mean of the z-transformed R-squares 
as R2_MI. The VIF reported for each variable is calculated as 
1/(1 - R2_MI).


{title:Options}

{phang}
{opt imputations(numlist)} combines VIFs from imputed datasets 
{it:numlist}. Default is to pool VIFs from imputed datasets used in 
the last estimation, or from all imputed datasets, if a {it:varlist} 
is supplied. The synonym {opt m(numlist)} may be used.

{phang}
{opt uncentered} reports uncentered VIFs. If the previous regression 
model is fit without the constant, option {opt uncentered} is implied. 
See {helpb regress postestimation##estatvif:vif}.

{phang}
{opt nofisherz} requests that Fisher's z-transformation not be used.


{title:Example}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. mi set flong}{p_end}
{phang2}{cmd:. mi register imputed rep78}{p_end}
{phang2}{cmd:. mi impute pmm rep78 price mpg weight foreign ,add(5)}{p_end}
{phang2}{cmd:. mi estimate : regress price mpg weight foreign i.rep78}{p_end}
{phang2}{cmd:. mivif}{p_end}


{title:Saved results}

{pstd}
{cmd:mivif} saves the following in {cmd:r()}:

{pstd}
Matrices{p_end}
	{cmd:r(mivif)}		result matrix


{title:References}

{pstd}
Harel, Ofer (2009). The estimation of R2 and adjusted R2 in incomplete 
data sets using multiple imputation. Journal of Applied Statistics, 
36(10), 1109-1118.

	
{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81.@gmail.com


{title:Also see}

{psee}
Online: {helpb mi}, {help vif}{p_end}

{psee}
if installed: {helpb mibeta}, {help collin}{p_end}
