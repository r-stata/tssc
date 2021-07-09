{smcl}
{* documented: 10oct2010}{...}
{* revised: 14nov2010}{...}
{* revised: 25oct2012}{...}
{cmd:help twopm postestimation}{right: ({browse "http://www.stata-journal.com/article.html?article=st0368":SJ15-1: st0368})}
{hline}

{title:Title}

{p2colset 5 29 33 2}{...}
{p2col :{cmd:twopm postestimation} {hline 2}}Postestimation tools for twopm{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are available for {opt twopm}:

{synoptset 13}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt:{bf:{help estat}}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_margins
INCLUDE help post_nlcom
{synopt :{helpb twopm postestimation##predict:predict}}predictions{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 15 2}
{cmd:predict} {dtype} {newvar} {ifin}{cmd:,} [{it:{help twopm postestimation##options:options}}] 

{p 8 15 2}
{cmd:predict} {dtype} {c -(}{it:stub}{cmd:*}{c |}{it:newvar1} ... {it:newvarq}{c )-}
{ifin}{cmd:,} {opt sc:ores}

{synoptset 16}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt normal}}normal theory retransformation to obtain fitted values{p_end}
{synopt :{opt duan}}Duan's smearing retransformation to obtain fitted values{p_end}
{synopt :{opt sc:ores}}calculate first derivative of the log likelihood with respect to xb{p_end}
{synopt :{opt nooff:set}}ignore any {opt offset()} or {opt exposure()} variable{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:predict} returns E({it:depvar}|{it:indepvar}).  In particular, the
combined prediction is computed as the product of the probability of a
positive outcome (first part) and the expected value of Y | Y>0 (second
part).  This statistic is available both in and out of sample; type
{cmd:predict} ... {cmd:if e(sample)} ... if wanted only for the
estimation sample.


{title:Options for predict}

{phang}
{opt normal} uses normal theory retransformation to obtain fitted
values.  Either {opt normal} or {opt duan} must be specified when a
linear regression of the log of the second-part outcome is
estimated.

{phang}
{opt duan} uses Duan's smearing retransformation to obtain fitted
values.  Either {opt normal} or {opt duan} must be specified when a
linear regression of the log of the second-part outcome is
estimated.

{phang}
{opt scores} creates a score variable for each part in the
model.  Because the score for the second part of the model makes sense only
for the estimation subsample (where Y>0), the calculation is
automatically restricted to the estimation subsample.

{phang}
{opt nooffset} specifies that the calculation should be made ignoring
any offset or exposure variable specified when fitting the model.  This
may be used with most statistics.

{pmore}
If neither the {opt offset(varname)} option nor the 
{opt exposure(varname)} option is specified when fitting the model,
specifying {opt nooffset} does nothing.


{title:Remarks}

{pstd}
Retransformation after ordinary least-squares regression of ln({it:depvar}) is
needed to obtain consistent predictions of {it:depvar}.  {cmd:twopm}
implements this using normal theory and smearing retransformations, but both
assume that the errors in the regression are homoskedastic.  Retransformation
with heteroskedastic errors is conceptually complex, and we have not
implemented it in {cmd:twopm}.  We suggest the gamma generalized linear model
({cmd:glm}) with log link as an alternative to a regression of
ln({it:depvar}).


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse womenwk}{p_end}
{phang2}{cmd:. replace wage = 0 if wage==.}{p_end}

{pstd}Two-part model with logit and glm with Gaussian family and identity link{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(logit) secondpart(glm)}{p_end}
{phang2}{cmd:. predict wagehat1}{p_end}
  
{pstd}Two-part model with probit and glm with gamma family and log link{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(glm, family(gamma) link(log))}{p_end}
{phang2}{cmd:. margins, dydx(*)}{p_end}

{pstd}Two-part model with probit and linear regression{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(regress)}{p_end}
{phang2}{cmd:. margins, dydx(*)}{p_end}

{pstd}Two-part model with probit and linear regression of log({it:depvar>0}){p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(regress, log)}{p_end}
{phang2}{cmd:. margins, predict(duan) dydx(*)}{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Partha Deb{p_end}
{pstd}Hunter College and Graduate Center, CUNY{p_end}
{pstd}New York, NY{p_end}
{pstd}and National Bureau of Economic Research{p_end}
{pstd}Cambridge, MA{p_end}
{pstd}partha.deb@hunter.cuny.edu{p_end}

{pstd}Willard G. Manning{p_end}
{pstd}University of Chicago{p_end}
{pstd}Chicago, IL{p_end}
{pstd}w-manning@uchicago.edu{p_end}

{pstd}Edward C. Norton{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}and National Bureau of Economic Research{p_end}
{pstd}Cambridge, MA{p_end}
{pstd}ecnorton@umich.edu{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 1: {browse "http://www.stata-journal.com/article.html?article=st0368":st0368}{p_end}

{p 7 14 2}Help:  {helpb twopm} (if installed){p_end}
