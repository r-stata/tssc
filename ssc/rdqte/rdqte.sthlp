 {smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:rdqte} {hline 2} Executes estimation and robust inference for quantile treatment effects (QTE) in regression discontinuity designs (RDD).


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:rdqte}
{it:y}
{it:x}
{ifin}
[{cmd:,} {bf:c}({it:real}) {bf:fuzzy}({it:varname}) {bf:cover}({it:real}) {bf:ql}({it:real}) {bf:qh}({it:real}) {bf:qn}({it:real}) {bf:bw}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:rdqte} executes estimation and robust inference for quantile treatment effects (QTE) in the sharp and fuzzy regression discontinuity designs (RDD) based on 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300569":Chiang, Hsu, and Sasaki (2019)}. 
The command takes an outcome variable {it:y} and a running variable or forcing variable {it:x}.
In case of a fuzzy design, a binary treatment variable {it:d} is specified in the option {bf:fuzzy}({it:varname}) - see below for details of the usage.
The primary results consist of estimates and a {it:uniform} 95% confidence band of QTEs across multiple quantiles. In addition to these primary results, the command also conducts tests of: 
1. the null hypothesis that the QTEs are zero for all the quantiles 
(i.e., uniformly null treatment effects); 
and 2. the null hypothesis that the QTEs are constant across all the quantiles 
(i.e., homogeneous treatment effects) 
against the alternative of heterogeneous treatment effects.
The method is robust against large bandwidths and unknown functional forms.


{marker options}{...}
{title:Options}

{phang}
{bf:c({it:real})} sets the discontinuity location for the RDD. The default value is {bf: c(0)}. (Note: the discontinuity location itself is included as a part of the observations with negative {bf:x}.)

{phang}
{bf:fuzzy({it:varname})} sets the treatment variable used for estimation in a fuzzy design. Not calling this option tells the command to assume a sharp design by default.

{phang}
{bf:cover({it:real})} sets the nominal probability that the uniform confidence band covers the true QTE. The default value is {bf: cover(.95)}.

{phang}
{bf:ql({it:real})} sets the lowest quantile at which the QTE is estimated. The default value is {bf: ql(.25)}.

{phang}
{bf:qh({it:real})} sets the highest quantile at which the QTE is estimated. The default value is {bf: qh(.75)}.

{phang}
{bf:qn({it:real})} sets the number of quantile points at which the QTE is estimated. The default value is {bf: qn(3)}.

{phang}
{bf:bw({it:real})} sets the bandwidth with which to estimate the QTE. A non-positive argument, as is the case with the default value {bf:bw(-1)}, will translate into an optimal rate.


{marker examples}{...}
{title:Examples}

{phang}
1. {bf:y} outcome variable, {bf:d} treatment variable, {bf:x} running variable

{phang}Estimation and inference under a sharp design:

{phang}{cmd:. rdqte y x}{p_end}

{phang}Estimation and inference under a fuzzy design:

{phang}{cmd:. rdqte y x, fuzzy(d)}{p_end}

{phang}Estimation of the QTE at 10th, 20th, ..., and 90th percentiles:

{phang}{cmd:. rdqte y x, fuzzy(d) ql(0.1) qh(0.9) qn(9)}{p_end}

{phang}(The default is the inter-quartile range: 25th, 50th & 75th percentiles.)

{phang}
2. {bf:score} scores on the Woodcock-Johnson sub-tests, {bf:treat} an indicator for participation in the pre-K program in the previous year, {bf:bdate} birth date - example drawn from 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300569":Chiang, Hsu, and Sasaki (2019, Sec. 6)}.
Students with {bf:bdate} >= 0 (location-normalized) are eligible for a participation in the pre-K program.
Participation in the program is not sharp, and we therefore use a fuzzy RDD.
Quantile treatment effects of the program on scores on the Woodcock-Johnson sub-tests are estimated with 90% uniform confidence bands by:

{phang}{cmd:. rdqte score bdate, fuzzy(treat) cover(0.9) ql(0.1) qh(0.9) qn(9)}{p_end}


{title:Reference}

{p 4 8}Chiang, H.D., Y.-C. Hsu, and Y. Sasaki. 2019. Robust Uniform Inference for Quantile Treatment Effects in Regression Discontinuity Designs.
{it:Journal of Econometrics}, 211 (2), pp. 589-618.
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300569":Link to Paper}.
{p_end}


{title:Authors}

{p 4 8}Harold. D. Chiang, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Yu-Chin Hsu, Academia Sinica, Taipei, Taiwan.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



