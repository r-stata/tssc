{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:qrkd} {hline 2} Executes estimation and robust inference for heterogeneous causal effects of a continuous treatment in the quantile regression kink designs (QRKD).


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:qrkd}
{it:y}
{it:x}
{ifin}
[{cmd:,} {bf:k}({it:real}) {bf:bpl}({it:real}) {bf:bpr}({it:real}) {bf:cover}({it:real}) {bf:ql}({it:real}) {bf:qh}({it:real}) {bf:qn}({it:real}) {bf:bw}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:qrkd} executes estimation and robust inference for heterogeneous causal effects of a continuous treatment in the quantile regression kink designs (QRKD) based on 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300387":Chiang and Sasaki (2019)}. 
The command takes an outcome variable {it:y} and a running variable or forcing variable {it:x}.
The primary results consist of estimates and a {it:uniform} 95% confidence band of causal effects across multiple quantiles. In addition to these primary results, the command also conducts tests of: 1. the null hypothesis that the causal effects are zero for all the quantiles (i.e., uniformly null causal effects); and 2. the null hypothesis that the causal effects are constant across all the quantiles (i.e., homogeneous causal effects) against the alternative of heterogeneous treatment effects.


{marker options}{...}
{title:Options}

{phang}
{bf:k({it:real})} sets the kink location for the QRKD. The default value is {bf: k(0)}. (Note: the kink location itself is included as a part of the observations with negative {bf:x}.)

{phang}
{bf:bpl({it:real})} sets the derivative {it: b}'({it:kink}-) of the policy function {it: b} to the left of the kink location {it:kink}. The default value is {bf: bpl(0)}.

{phang}
{bf:bpr({it:real})} sets the derivative {it: b}'({it:kink}+) of the policy function {it: b} to the right of the kink location {it:kink}. The default value is {bf: bpr(1)}.

{phang}
{bf:cover({it:real})} sets the nominal probability that the uniform confidence band covers the true causal effects. The default value is {bf: cover(.95)}.

{phang}
{bf:ql({it:real})} sets the lowest quantile at which the QRKD is estimated. The default value is {bf: ql(.25)}.

{phang}
{bf:qh({it:real})} sets the highest quantile at which the QRKD is estimated. The default value is {bf: qh(.75)}.

{phang}
{bf:qn({it:real})} sets the number of quantile points at which the QRKD is estimated. The default value is {bf: qn(3)}.

{phang}
{bf:bw({it:real})} sets the bandwidth with which to estimate the QRKD. A non-positive argument, as is the case with the default value {bf:bw(-1)}, will translate into an optimal rate.


{marker examples}{...}
{title:Examples}

{phang}
({bf:y} outcome variable, {bf:x} running variable)

{phang}Estimation with the policy derivatives {it:b}'({it:k}-)=0.04 and {it:b}'({it:k}+)=0.00 as in the analysis of heterogeneous effects of unemployment insurance on unemployment duration
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300387":(Chiang and Sasaki, 2019, Sec. 5)}
:

{phang}{cmd:. qrkd y x, bpl(0.04) bpr(0.00)}{p_end}

{phang}Estimation of the QRKD at 10th, 20th, ..., and 90th percentiles:

{phang}{cmd:. qrkd y x, bpl(0.04) bpr(0.00) ql(0.1) qh(0.9) qn(9)}{p_end}

{phang}(The default is the inter-quartile range: 25th, 50th & 75th percentiles.)


{title:Reference}

{p 4 8}Chiang, H.D. and Y. Sasaki. 2019. Causal Inference by Quantile Regression Kink Designs.
{it:Journal of Econometrics}, 210 (2), pp. 405-433.
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619300387":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Harold. D. Chiang, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



