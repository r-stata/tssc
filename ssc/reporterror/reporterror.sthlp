{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:reporterror} {hline 2} Executes estimation of the probability masses of an unobserved discrete random variable using two measurements with possibly nonclassical and nonseparable measurement errors.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:reporterror}
{it:x}
{it:y}
{ifin}
[{cmd:,} {bf:minu}({it:real}) {bf:maxu}({it:real}) {bf:nounderreport}({it:real}) {bf:boot}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:reporterror} executes estimation of the probability masses of an unobserved discrete random variable using two measurements with possibly nonclassical and nonseparable measurement errors based on 
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/identification-of-paired-nonseparable-measurement-error-models/34749A2AE4307F631BE6CC8C9C8D7266":Hu and Sasaki (2017)}. 
The command takes two measurements, {bf:x} (e.g., self-reported years of education) and {bf:y} (e.g., sibling-reported years of education), of an unobserved discrete latent variable {bf:u} (e.g., true years of education), and estimates the probability masses {it:f}({bf:u}) of {bf:u}. Also reported are the conditional probabilities of correct reports {bf:x} and {bf:y} given {bf:u}.


{marker options}{...}
{title:Options}


{phang}
{bf:minu({it:real})} sets the lower bound of the support of {bf:u}. Not calling this option automatically sets it to the minimum value of the common support of {bf:x} and {bf:y}.

{phang}
{bf:maxu({it:real})} sets the upper bound of the support of {bf:u}. Not calling this option automatically sets it to the maximum value of the common support of {bf:x} and {bf:y}.

{phang}
{bf:nounderreport({it:real})} can be used to toggle between the assumption of no under-reporting and no over-reporting. Not calling this option or setting a non-zero argument in this option implies the assumption of no under-reporting. Calling this option with zero as an argument implies the assumption of no over-reporting

{phang}
{bf:boot({it:real})} sets the number of bootstrap iterations. The default value is {bf: boot(2500)}.

{marker examples}{...}
{title:Examples}

{phang}
({bf:x} first measurement of {bf:u}, {bf:y} second measurement of {bf:u})

{phang}Estimation on the whole support of {bf:u}:

{phang}{cmd:. reporterror x y}{p_end}

{phang}Estimation focusing on individuals with high-school diploma {bf:u}=12 or higher degrees:

{phang}{cmd:. reporterror x y, minu(12)}{p_end}

{title:Reference}

{p 4 8}Hu, Y. and Y. Sasaki. 2017. Identification of Paired Nonseparable Measurement Error Models.
{it:Econometric Theory}, 33 (4), pp. 955-979.
{browse "https://www.cambridge.org/core/journals/econometric-theory/article/identification-of-paired-nonseparable-measurement-error-models/34749A2AE4307F631BE6CC8C9C8D7266":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Yingyao Hu, Johns Hopkins University, Baltimore, MD.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



