{smcl}
{* *! version 1.0  October 27, 2020}{...}
{cmd:help omega}
{hline}
{viewerjumpto "Syntax" "omega##syntax"}{...}
{viewerjumpto "Options table" "omega##options_table"}{...}
{viewerjumpto "Description" "omega##description"}{...}
{viewerjumpto "Options" "omega##options"}{...}
{viewerjumpto "Examples" "omega##examples"}{...}
{viewerjumpto "Stored results" "omega##stored_results"}{...}
{viewerjumpto "References" "omega##references"}{...}

{title:Title}

{p2colset 4 10 13 2}{...}
{p2col:{bf: omega}}{hline 2} Calculates McDonald's omega, also known as
Raykov's rho, as a desirable reliability estimate for congeneric scales
comprised of continuous variables.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:omega} {it:varlist} [, {it:options}]

{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt iter:ate(#)}}number of iterations; default is 1000{p_end}
{synopt:{opt usem:issing}}Consider cases with missing values; recommended when data are missing at random{p_end}
{synopt:{opt rev:erse(varlist)}}variables that are reverse coded{p_end}
{synopt:{opt norev:erse(varlist)}}variables that should not be treated as reverse coded{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:omega} calculates the scale reliability coefficient known as McDonald's
omega (McDonald, 1999), which is also known as Raykov's rho (Raykov, 1997). 
Omega is similar to the well-known Cronbach's alpha, but is preferable in almost
all practical applications because Cronbach's alpha has very restricve 
assumptions that are rarely met in practice (Hayes and Coutts, 2020; McNeish,
2018). Cronbach's alpha can be regarded as a special case of McDonald's omega
and the two measures will be equivalent when the assumptions for Cronbach's
alpha are met. {cmd:omega} is based on loadings from confirmatory factor
analysis, and is estimated using maximum likelihood. It requires at least three
continuous variables that are all presumed to measure the same construct. The
estimated reliability is often close to Cronbach's alpha, but has been shown to
differ under certain conditions (see McNeish, 2018).


{marker options}{...}
{title:Options}

{phang}
{opt iterate(#)} specifies the number of iterations the confirmatory factor
analysis model will use to attempt to converge. In most applications, the model
should converge with just a few iterations. If it does not converge after the
default 1000 iterations it is most likely a sign that there is a specification
issue, which is often the inclusion of a categorical variable. It is unlikely
to be resolved with more iterations, but you can try!

{phang}
{opt usemissing} requests that the estimation incorporate information from
variables in the scale with missing values if the missingness can be assumed to
be Missing at Random or Missing Completely at Random; i.e., the reason that the
data are missing is not related to the scale score (see Schafer and Graham,
2002).

{phang}
{opt reverse} specifies variables to be treated as reverse coded (i.e., their
values are predicted to be negatively correlated with the majority of the other
items in the scale). By default, the program will use the absolute value of the
loadings of any variables that appear to be reverse coded (i.e., those with
negative factor loadings) to estimate the scale reliability. As such, this
option should rarely be necessary. In rare cases, {opt noreverse} could be used
to force the program not to use the absolute value. However, this option is only
provided for advanced users who have a specific reason to desire the possibility
of negative factor loadings.


{marker examples}{...}
{title:Examples}

{pstd}Basic example to calculate reliability{p_end}
{phang2}{stata "webuse bg2"}{p_end}
{phang2}{stata "omega bg2cost1-bg2cost6"}{p_end}


{pstd}Variables with values that are missing at random{p_end}
{phang2}{stata "webuse cfa_missing"}{p_end}
{phang2}Without using the variables with missingness: {stata "omega test1-test4"}{p_end}
{phang2}Using all information: {stata "omega test1-test4, usem"}{p_end}



{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:omega} saves the following in {cmd:r()}: 

{pstd}Scalars:{p_end}
{synoptset 24 tabbed}{...}

{synopt:{cmd:r(omega)}}the estimated reliability coefficient{p_end}
{synopt:{cmd:r(k)}}the number of items in the scale used to estimate reliability{p_end}

{marker references}{...}
{title:References}

{pstd}Hayes, A. F., & Coutts, J. J. (2020). Use omega rather than Cronbach’s 
alpha for estimating reliability. But….
{it:Communication Methods and Measures, 14}(1), 1–24.
{browse "https://doi.org/10.1080/19312458.2020.1718629"}

{pstd}McDonald, R. P. (1999). {it:Test theory: A unified treatment}. Lawrence
Erlbaum Associates.

{pstd}McNeish, D. (2018). Thanks coefficient alpha, we’ll take it from here.
{it:Psychological Methods, 23}(3), 412–433.
{browse "https://doi.org/10.1037/met0000144"}

{pstd}Raykov, T. (1997). Scale reliability, Cronbach’s coefficient alpha, and 
violations of essential tau-equivalence with fixed congeneric components.
{it:Multivariate Behavioral Research, 32}(4), 329–353.
{browse "https://doi.org/10.1207/s15327906mbr3204_2"}

{pstd}Schafer, J. L., & Graham, J. W. (2002). Missing data: Our view of the 
state of the art. {it:Psychological Methods, 7}(2), 147–177.
{browse "https://doi.org/10.1037//1082-989X.7.2.147"}


{marker author}{...}
{title:Author}

{pstd}Brian Shaw, Indiana University, USA{p_end}
{pstd}bpshaw@indiana.edu{p_end}
