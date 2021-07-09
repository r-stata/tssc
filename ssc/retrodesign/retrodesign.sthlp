{smcl}
{* *! version 1.0.1 10oct2019}{...}

{title:Title}

{p2colset 5 20 21 2}{...}
{p2col:{hi:retrodesign} {hline 2}} Assessing Type-S (Sign) and Type-M (Magnitude) Errors  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:retrodesign}
{it: effect-size}
{cmd:,}
{opt s:e(#)}
[
{opt alpha(#)}
{opt df(#)}
{opt seed(#)}
{opt r:eps(#)}
]

{pstd}
{it:effect-size(s)} can be entered as a single numeric value or as a {helpb numlist} 


{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt s:e(#)}}standard error of the estimate; {cmd: se() is required}{p_end}
{synopt:{opt alpha(#)}}set the alpha level; default is {cmd:0.05}{p_end}
{synopt:{opt df(#)}}degrees of freedom; When {opt df()} is specified, the Gelman and Carlin (2014) simulation method is used for computing type-M error{p_end}
{synopt:{opt seed(#)}}set random-number seed to # when computing type-M error; this option only works when {opt df()} is specified{p_end}
{synopt:{opt r:eps(#)}}set number of simulated observations when computing type-M error. This option only works when {opt df()} is specified; default is {cmd:10,000}{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt retrodesign} computes power, type-S, and type-M errors for one or more specified effect sizes. A type-S (sign) error indicates the probability of an effect size 
estimate being in the wrong direction, and a type-M (magnitude) error indicates the factor by which the magnitude of an effect might be overestimated -- given that the 
test statistic is statistically significant (Gelman and Carlin 2014).

{pstd}
Gelman and Carlin (2014) propose computing the type-M error using the Student's t distribution. This method is implemented in {opt retrodesign} when the 
user specifies {cmd: df()} (and optionally, {cmd: reps()} and {cmd: seed()}). Lu, Qiu, and Deng (2019) propose a closed form solution for computing the type-M error. 
This method is implemented in {opt retrodesign} when the {cmd: df()} is not specified. {opt retrodesign} produces identical results to those computed in the retrodesign 
package for R ({browse "https://cran.r-project.org/web/packages/retrodesign/index.html"}). 



{title:Options}

{p 4 8 2}
{cmd:se(}{it:#}{cmd:)} specifies the standard error of the estimate; {cmd: se() is required}.

{p 4 8 2}
{cmd:alpha(}{it:#}{cmd:)} specifies the desired alpha level;  {cmd: default is 0.05}.

{p 4 8 2}
{cmd:df(}{it:#}{cmd:)} specifies the degrees of freedom used to compute the type-M error when implementing the method by Gelman and Carlin (2014); {cmd:df() cannot exceed 9.007e+15}.

{p 4 8 2}
{cmd:seed(}{it:#}{cmd:)} sets the random-number seed. Specifying this option ensures reproducibility of the computed type-M error when implementing the method by Gelman and Carlin (2014). 

{p 4 8 2}
{cmd:reps(}{it:#}{cmd:)} sets the number of simulated observations to generate when computing the Type M error when implementing the method by Gelman and Carlin (2014); {cmd: default is 10,000}.



{title:Examples}

{pmore}"Beauty and sex ratios" example from Gelman and Carlin (2014). We start by using {helpb getregstats} (if installed) to compute the standard error based on given point estimate of 8.0 and  p-value of 0.015.{p_end}
{pmore2}{bf:{stata "getregstats 8.0, model(lin) pval(0.015)": . getregstats 8.0, model(lin) pval(0.015)}} {p_end}

{pmore}Next, we use {opt retrodesign} with a single true estimate of 0.1, and the std err of 3.3. We compute 
the type-M error using the Lu, Qiu, and Deng (2019) method.{p_end}
{pmore2}{bf:{stata "retrodesign 0.1, se(3.3) alpha(0.05)": . retrodesign 0.1, se(3.3) alpha(0.05)}} {p_end}

{pmore} Same as above, but a range of true effect sizes is applied. {p_end}
{pmore2}{bf:{stata "retrodesign 0.1 0.3 1 2 3, se(3.3) alpha(0.05)": . retrodesign 0.1 0.3 1 2 3, se(3.3) alpha(0.05)}} {p_end}

{pmore} Same as above, but the Gelman and Carlin (2014) method is applied by setting {cmd: df()}. Here we set {cmd: df()} to the maximum value allowed and set the seed to allow for reproducible results.{p_end}
{pmore2}{bf:{stata "retrodesign 0.1 0.3 1 2 3, se(3.3) alpha(0.05) df(9007199254740990) seed(1234)": . retrodesign 0.1 0.3 1 2 3, se(3.3) alpha(0.05) df(9007199254740990) seed(1234)}} {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:retrodesign} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}results table{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Gelman, A. and J, Carlin. 2014. Beyond power calculations: Assessing type S (sign) and type M (magnitude) errors. {it:Perspectives on Psychological Science} 9(6):641-651.{p_end}

{p 4 8 2}
Lu, J., Qiu, Y. and A, Deng. 2019. A note on Type S/M errors in hypothesis testing. {it:British Journal of Mathematical and Statistical Psychology} 72(1):1-17.{p_end}



{marker citation}{title:Citation of {cmd:retrodesign}}

{p 4 8 2}{cmd:retrodesign} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). RETRODESIGN: Stata module for computing type-S (Sign) and type-M (Magnitude) errors.
Statistical Software Components, Boston College Department of Economics. {browse "http://ideas.repec.org/c/boc/bocode/s458631.html":http://ideas.repec.org/c/boc/bocode/s458631.html}{p_end}


{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb power}, {helpb getregstats} (if installed) {p_end}

