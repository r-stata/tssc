{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:cdecompose} {hline 2} Executes estimation of canonical permanent-transitory state space models.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:cdecompose}
{it:y1}
{it:y2}
...
{it:yT}
{ifin}
[{cmd:,} {bf:p}({it:real}) {bf:q}({it:real}) {bf:delta}({it:real}) {bf:nboot}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:cdecompose} executes estimation of canonical permanent-transitory state space models based on 
{browse "https://onlinelibrary.wiley.com/doi/full/10.3982/QE1117":Hu, Moffitt, and Sasaki (2019)}. 
Consider the state space model {it:Y}({it:t}) = {it:U}({it:t}) + {it:V}({it:t}) where {it:U}({it:t}) is an unobserved permanent component that follows the unit-root process {it:U}({it:t}) = {it:U}({it:t}-1) + {it:W}({it:t}) and {it:V}({it:t}) is an unobserved transitory component that follows the semiparametric ARMA({it:p},{it:q}) process {it:V}({it:t}) = {it:r}(1){it:V}({it:t}-1) + ... + {it:r}({it:p}){it:V}({it:t}-{it:p}) + {it:G}({it:e}({it:t}),...,{it:e}({it:t}-{it:q})). 
The command takes {it:p} + 2{it:q} + 2 periods of {it:y}({it:t}) as input and estimates the mean, standard deviation, skewness, and kurtosis of the permanent component {it:U}({it:t}) and transitory component {it:V}({it:t}). In order to estimate these statistics for time period {it:t},  
a user should use {it:y}({it:t}-{it:p}-{it:q})...{it:y}({it:t}+{it:q}+1) as input.


{marker options}{...}
{title:Options}

{phang}
{bf:p({it:real})} sets the AR order {it:p} of the ARMA({it:p},{it:q}) model of transitory process. The default value is {bf: p(1)}.
{p_end}

{phang}
{bf:q({it:real})} sets the MA order {it:q} of the ARMA({it:p},{it:q}) model of transitory process. The default value is {bf: q(1)}.
{p_end}

{phang}
{bf:delta({it:real})} sets a precision parameter for computing numerical derivative in approximating derivatives of empirical characteristic functions for moment estimation. The default value is {bf: delta(5)}.
{p_end}

{phang}
{bf:nboot({it:real})} sets the number of bootstrap iterations for approximating standard errors. The default value is {bf: nboot(1000)}.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}
({bf:y37}...{bf:y42} earnings at ages 38...42, respectively){p_end}

{phang}Estimation at age 40 under the ARMA(1,1) transitory process:{p_end}

{phang}{cmd:. cdecompose y38 y39 y40 y41 y42}{p_end}

{phang}Estimation at age 40 under the ARMA(2,1) transitory process:{p_end}

{phang}{cmd:. cdecompose y37 y38 y39 y40 y41 y42, p(2) q(1)}{p_end}

{phang}(Note that it is a common practice in the earnings dynamics literature
        that {bf:y37}...{bf:y42} are defined as the residual of earnings on
        observed attributes.){p_end}

{title:Reference}

{p 4 8}Hu, Y., R. Moffitt, and Y. Sasaki. 2019. Semiparametric Estimation of the Canonical Permanent‐Transitory Model of Earnings Dynamics. {it:Quantitative Economics}, 10 (4), pp. 1495-1536. 
{browse  "https://onlinelibrary.wiley.com/doi/full/10.3982/QE1117":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Yingyao Hu, Johns Hopkins University, Baltimore, MA.{p_end}

{p 4 8}Robert Moffitt, Johns Hopkins University, Baltimore, MA.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



