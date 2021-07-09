{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:npss} {hline 2} Executes nonparametric estimation of heteroskedastic state space models.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:npss}
{it:y1}
{it:y2}
{ifin}
[{cmd:,} {bf:skedastic}({it:varname}) {bf:tp1}({it:real}) {bf:tp2}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:npss} executes nonparametric estimation of conditionally heteroskedastic state space models based on 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407617302427":Botosaru and Sasaki (2018)}. 
Consider a state space model {it:y}({it:it}) = {it:u}({it:it}) + {it:v}({it:it}), where {it:y}({it:it}) is observed (e.g., earnings), {it:u}({it:it}) is unobserved (e.g., permanent component of earnings), and {it:v}({it:it}) is unobserved (e.g., transitory component of earnings), with the process {it:u}({it:it}) = {it:u}({it:it-1}) + {it:w}({it:it}). Taking {it:y}({it:i1}) and {it:y}({it:i2}) as input, the command nonparametrically estimates and draws the density functions of {it:u}({it:i1}) and {it:v}({it:i1}). Taking {it:y}({it:i1}), {it:y}({it:i2}) and {it:y}({it:i3}) as input, the command also nonparametrically estimates and draws the conditional skedastic function of {it:u}({it:i2}) given {it:u}({it:i1}), e.g., as a measure of heterogeneous risks in permanent component of earnings.


{marker options}{...}
{title:Options}

{phang}
{bf:skedastic({it:varname})} tells the command to estimate the skedastic function of {it:u}({it:i2}) given {it:u}({it:i1}). The input in this option is {bf:y3}, the observed variable in the third time period after the first two, {bf:y1} and {bf:y2}. Not calling this option tells the command to estimate only the density functions of {it:u}({it:i1}) and {it:v}({it:i1}).

{phang}
{bf:tp1({it:real})} sets the scale-normalized tuning parameter for estimation of the density functions. The default value is {bf: tp1(4)}.

{phang}
{bf:tp2({it:real})} sets the scale-normalized tuning parameter for estimation of the skedastic function. The default value is {bf: tp2(2)}.

{marker examples}{...}
{title:Examples}

{phang}
({bf:y1} period-1 earnings, {bf:y2} period-2 earnings, {bf:y3} period-3 earnings){p_end}

{phang}Estimation of the density functions of {it:u}({it:1}) and {it:v}({it:1}), using {bf:y1} and {bf:y2} as input:

{phang}{cmd:. npss y1 y2}{p_end}

{phang}Estimation the conditional skedastic function of {it:u}({it:2}) given {it:u}({it:1}), in addition to the density functions of {it:u}({it:1}) and {it:v}({it:1}), using {bf:y1}, {bf:y2} and {bf:y3} as input:

{phang}{cmd:. npss y1 y2, skedastic(y3)}{p_end}

{phang}
(Note that it is a common practice in the earnings dynamics literature that {bf:y1}, {bf:y2} and {bf:y3} are defined as the residual of earnings on observed attributes.s){p_end}

{title:Reference}

{p 4 8}Botosaru, I. and Y. Sasaki. 2018. Nonparametric Heteroskedasticity in Persistent Panel Processes: An Application to Earnings Dynamics. {it:Journal of Econometrics}, 203 (2), pp. 283-296. 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407617302427":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Irene Botosaru, University of Bristol, Bristol, UK.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



