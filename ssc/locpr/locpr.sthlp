{smcl}
{* 7may2008}{...}
{hline}
help for {hi:locpr}
{hline}

{title:Semi-parametrically estimate probability/proportion as a function of one regressor}

{title:Syntax}

{p 6 16 2}
{cmd:locpr} [{vars}] 
[{cmd:,} {cmdab:s:tub(}{it:string}{cmd:)}  
{cmdab:l:ogit} {cmdab:c:ombine}
{help twoway_options:other options} ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt s:tub(string)}}save graphed predictions to new variables with names beginning with {it:string}{p_end}
{synopt:{opt plot(string)}}add {it:string} to each graph command (useful for adding plots){p_end}
{synopt:{opt l:ogit}}estimate a logit model and graph results{p_end}
{synopt:{opt c:ombine}}combine logit and semi-parametric estimates in one graph{p_end}
{synopt:{opt rarea(string)}}pass options {it:string} to {help twoway_rarea:rarea} command graphing CI{p_end}
{synopt:{opt loptions(string)}}pass options {it:string} to {help twoway_options:logit prediction graph}{p_end}
{synopt:{opt coptions(string)}}pass options {it:string} to {help graph_combine:combined graph}{p_end}
{synopt:{opt n:quantiles(integer)}}specifies how many points at which to estimate the local regression (default is 99)}{p_end}
{synopt:{opt levels}}estimate the local regression at each distinct value of the regressor}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{p}{cmd:locpr} semi-parametrically estimates a probability or proportion as 
a function of one other variable and graphs the result.  Specifically, it
estimates a local linear regression using {help lpoly} and approximates the endpoints
of the confidence interval via a logit transformation. The estimates are computed at
a number of quantiles (99 percentiles by default) of the regressor 
(or at each value of the regressor within the range of those quantiles, if
there are fewer distinct values than the number of quantiles, unless
the {cmd:levels} option requests estimation at {it:every} distinct value of the regressor)
and graphed. The {cmd:logit} option
offers a direct comparison to parametric logistic regression. 
Other {help twoway_options:twoway options} may be specified that apply to the
graph of local regression estimates.{p_end}

{marker s_examples}{title:Examples}
{hline}
{p 8 12}{stata "sysuse nlsw88, clear" : sysuse nlsw88, clear } {p_end}
{p 8 12}{stata "locpr never_married hours, l c" : locpr never_married hours, l c }{p_end}
{hline}
{p 8 12}{stata "webuse nhanes2, clear" : webuse nhanes2, clear } {p_end}
{p 8 12}{stata "g bmi=weight/height^2*10000" : g bmi=weight/height^2*10000 } {p_end}
{p 8 12}{stata "lpoly highbp bmi [aw=finalwgt], nosc ci name(lpoly, replace)" : lpoly highbp bmi [aw=finalwgt], nosc ci name(lpoly)} {p_end}
{p 8 12}{stata "locpr highbp bmi [pw=finalwgt], l c name(hibp)" : locpr highbp bmi [pw=finalwgt], l c name(hibp)} {p_end}
{p 8 12}{stata "locpr diabetes bmi [pw=finalwgt], l c name(diab)" : locpr diabetes bmi [pw=finalwgt], l c name(diab)} {p_end}
{hline}
{p 8 12}{stata "webuse psidextract, clear" : webuse psidextract, clear} {p_end}
{p 8 12}{stata "locpr ms lwage, l c name(lwage)" : locpr ms lwage, l c name(lwage)} {p_end}
{p 8 12}{stata "locpr ms wks, l c name(wks)" : locpr ms wks, l c name(wks)} {p_end}
{p 8 12}{stata "locpr ms ed, l c name(ed)" : locpr ms ed, l c name(ed)} {p_end}
{p 8 12}*why graphs exclude bottom and top 1% of X by default:{p_end}
{p 8 12}*(also add a rug plot and vertical lines at 1%ile and 99%ile){p_end}
{p 8 12}{stata `"g l="|""':g l="|"}{p_end}
{p 8 12}{stata "g o=-.1":g o=-.1}{p_end}
{p 8 12}{stata "_pctile wks, nq(100)":_pctile wks, nq(100)}{p_end}
{p 8 12}{stata "loc p1=r(r1)":loc p1=r(r1)}{p_end}
{p 8 12}{stata "loc p99=r(r99)":loc p99=r(r99)}{p_end}
{p 8 12}{stata "locpr union wks, yla(0(.5)1) xli(`p1') xli(`p99') plot(|| scatter o wks, ms(none) mlabel(l) mlabp(0))":locpr union wks, yla(0(.5)1) xli(`p1') xli(`p99') plot(|| scatter o wks, ms(none) mlabel(l) mlabp(0))}{p_end}
{p 8 12}{stata "locpr union wks, levels yla(0(.5)1) xli(`p1') xli(`p99') plot(|| scatter o wks, ms(none) mlabel(l) mlabp(0))":locpr union wks, levels yla(0(.5)1) xli(`p1') xli(`p99') plot(|| scatter o wks, ms(none) mlabel(l) mlabp(0))}{p_end}


{hline}

{title:Author}

    Austin Nichols
    Urban Institute
    Washington, DC, USA
    austinnichols@gmail.com

{title:Also see}

{p 1 10}On-line: {help logit}, {help probit}, {help glm}, {help lpoly}, {help lowess}, {stata "findit mlowess":mlowess (on SSC)}, {stata "findit transint":transint (on SSC)}{p_end}

