 {smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:rkqte} {hline 2} Executes estimation and robust inference for quantile treatment effects (QTE) in regression kink designs (RKD).


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:rkqte}
{it:y}
{it:d}
{it:x}
{ifin}
[{cmd:,} {bf:k}({it:real}) {bf:cover}({it:real}) {bf:ql}({it:real}) {bf:qh}({it:real}) {bf:qn}({it:real}) {bf:bw}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:rkqte} executes estimation and robust inference for quantile treatment effects (QTE) in regression kink designs (RKD) based on 
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/quantile-treatment-effects-in-regression-kink-designs/75836ABC1C92059C67F4D132AE3B4EDD":Chen, Chiang, and Sasaki (2020)}. 
The command takes an outcome variable {it:y}, a binary treatment variable {it:d}, and a running variable or forcing variable {it:x}.
The primary results consist of estimates and a {it:uniform} 95% confidence band of QTEs across multiple quantiles. In addition to these primary results, the command also conducts tests of: 1. the null hypothesis that the QTEs are zero for all the quantiles (i.e., uniformly null treatment effects); and 2. the null hypothesis that the QTEs are constant across all the quantiles (i.e., homogeneous treatment effects) against the alternative of heterogeneous treatment effects.


{marker options}{...}
{title:Options}

{phang}
{bf:k({it:real})} sets the kink location for the RKD. The default value is {bf: k(0)}. (Note: the kink location itself is included as a part of the observations with negative {bf:x}.)

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
({bf:y} outcome variable, {bf:d} treatment variable, {bf:x} running variable)

{phang}Estimation of the QTE:

{phang}{cmd:. rkqte y d x}{p_end}

{phang}Estimation of the QTE at 10th, 20th, ..., and 90th percentiles:

{phang}{cmd:. rkqte y d x, ql(0.1) qh(0.9) qn(9)}{p_end}

{phang}(The default is the inter-quartile range: 25th, 50th & 75th percentiles.)


{title:Reference}

{p 4 8}Chen, H., H.D. Chiang, and Y. Sasaki. 2020. Quantile Treatment Effects in Regression Kink Designs.
{it:Econometric Theory}, 36 (6), pp. 1167-1191.
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/quantile-treatment-effects-in-regression-kink-designs/75836ABC1C92059C67F4D132AE3B4EDD":Link to Paper}.
{p_end}


{title:Authors}

{p 4 8}Heng Chen, Bank of Canada, Ottawa, ON.{p_end}

{p 4 8}Harold. D. Chiang, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



