{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:robustate} {hline 2} Executes estimation and inference for the average treatment effect (ATE) robustly against the limited overlap.

{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:robustate}
{it:outcome}
{it:treatment}
{it:controls}
{ifin}
[{cmd:,} {bf:h}({it:real}) {bf:k}({it:real})]

{marker description}{...}
{title:Description}

{phang}
{cmd:robustate} executes estimation and inference for the average treatment effect (ATE) robustly against the limited overlap based on
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/abs/estimation-and-inference-for-moments-of-ratios-with-robustness-against-large-trimming-bias/6505FD01751EE01FEFFD34071C873FB6":Sasaki and Ura (2021)} -- Section 7. 
Under the limited overlap, the naive inverse propensity score estimation method suffers from large variances (if not a lack of the consistency or the asymptotic normality).
Hence, it is a common practice to trim observations whose propensity scores are close to 0 or 1, but such a practice biases the estimator of the ATE.
This command, {cmd:robustate}, corrects the bias from the trimming and computes a valid standard error accounting for the bias correction.
The command accepts an outcome variable, a binary treatment variable, and a list of control variables.
It returns both the naive inverse propensity score weighted estimate and the robust inverse propensity score weighted estimate.
The robust estimator in general yields a smaller standard error than the naive estimator.

{marker options}{...}
{title:Options}

{phang}
{bf:h({it:real})} sets the trimming threshold. The default value is {bf: h(0.1)}. It has to be a real number in (0,1). Larger values induce larger biases of the naive estimator.

{phang}
{bf:k({it:real})} sets the sieve dimension for bias correction. The default value is {bf: k(4)}. It has to be an integer which is no smaller than 4.

{marker example}{...}
{title:Example}

{phang}
Average treatment effect of catheterization on 30-day survival.
{p_end}

{phang}{cmd:. use "catheterization_small.dta"}{p_end}
{phang}{cmd:. robustate outcome treat {it:controls}}{p_end}

{phang}where the {cmd:{it:controls}} in the last command line above includes: age, alb1, amihx, aps1, bili1, ca_meta, ca_yes, card, cardiohx, cat1_chf, cat1_cirr, cat1_colon, cat1_coma, cat1_copd, cat1_lung, cat1_mosfmal, cat1_mosfsep, cat2_cirr, cat2_colon, cat2_coma, cat2_lung, cat2_mosfmal, cat2_mosfsep, chfhx, chrpulhx, crea1, das2d3pc, and dementhx{p_end}


{title:Reference}

{p 4 8}Sasaki, Y. and T. Ura 2021. Estimation and Inference for Moments of Ratios with Robustness against Large Trimming Bias. {it:Econometric Theory}, forthcoming.
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/abs/estimation-and-inference-for-moments-of-ratios-with-robustness-against-large-trimming-bias/6505FD01751EE01FEFFD34071C873FB6":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Takuya Ura, University of California, Davis, CA.{p_end}



