{smcl}
{* *! version 1.0.0  20aug2015}{...}
{cmd:help gmemultinomial}
{hline}


{title:Title}

{p2colset 5 23 25 2}{...}
{p2col:{hi: gmemultinomial} {hline 2}}Generalized maximum entropy discrete choice model for the multinomial case{p_end}
{p2colreset}{...}

{p 8 11 2}
{opt gmentropylogit:}
{depvar} [{indepvars}] {ifin}
[{cmd:,} {opt base:outcome(#)} {opt gen:erate(varname)} {opt NOC:ons}]


{title:Description}

{pstd}
Given finite samples, {cmd:gmemultinomial} is more efficient than
its maximum entropy and maximum likelihood counterparts because it
incorporates noise terms in its results.  It also performs better than
its maximum likelihood counterparts when working with small sample
sizes.  {cmd:gmemultinomial} models the probability of a positive
outcome given a set of regressors.  {it:depvar} is equal to zero or one.
{it:depvar}={cmd:0} indicates a negative outcome, and
{it:depvar}={cmd:1} indicates a positive outcome.

It is recommended that users utilize {cmd:gmentropylogit} in the binary case
due to the possibility of estimating marginal effects. 


{title:Options}

{phang}
{cmd:generate(}{it:varname}{cmd:)} creates a new variable with a user-selected
name that will contain the predicted probability of the fitted model.

{cmd:nocons} estimates the model without a constant term.

{cmd:baseoutcome(}{it:#}{cmd:)} selects the value of the dependent variable that will be the base outcome


{title:Example}

{phang}{cmd:. webuse sysdsn1}{p_end}
{phang}{cmd:. gmemultinomial insure age male nonwhite}{p_end}


{marker Authors}{...}
{title:Authors}

{pstd}Paul Corral{p_end}
{pstd}American University{p_end}
{pstd}Washington, DC{p_end}
{pstd}paulcorral@gmail.com{p_end}

{marker also_see}{...}
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=st0390":st0390}
{p_end}




