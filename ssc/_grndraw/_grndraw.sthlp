{smcl}
{* 1.0.0 created 2017-05-19}{...}
{vieweralsosee "[D] egen" "mansection D egen"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[On SSC] smfit" "help smfit"}{...}
{vieweralsosee "[On SSC] dagumfit" "help dagumfit"}{...}
{vieweralsosee "[On SSC] paretofit" "help paretofit"}{...}
{vieweralsosee "[On SSC] gb2fit" "help gb2fit"}{...}
{vieweralsosee "[On SSC] fiskfit" "help fiskfit"}{...}
{hline}
{hi:help _grndraw()}{...}
{right:P. Van Kerm (May 2017)}
{hline}

{title:Title}

{pstd}{hi:egen rndraw} {hline 2} Random number generation from the GB2, Singh-Maddala, Dagum, Fisk and Pareto distributions{p_end}


{title:Syntax}

{p 8 14 2}
{cmd:egen} {dtype} {newvar} {cmd:=} {cmd:rndraw()} {ifin} 
{cmd:,}{break}{c -(}{opt par:eto}{cmd:(}{it:# #}{cmd:)} | {opt fisk}{cmd:(}{it:# #}{cmd:)} | {opt loglog:istic}{cmd:(}{it:# #}{cmd:)} | {opt sm}{cmd:(}{it:# # #}{cmd:)} | {opt dag:um}{cmd:(}{it:# # #}{cmd:)} | {opt gb2}{cmd:(}{it:# # # #}{cmd:)}{c )-}  {p_end}


{title:Description}

{pstd}
{cmd:egen rndraw} generates a new variable {newvar} (of the optionally specified storage type) filled with random values drawn from one of five possible distributions: the Pareto distribution, the Fisk (or log-logistic) distribution,
the Singh-Maddala distribution, the Dagum distribution or the Generalized Beta distribution of the Second Kind (GB2). Kleiber and Kotz (2003) provide a thorough analysis of these distributions; also see Jenkins (2004) and McDonald (1984). 

{pstd}
Simulation is based on standard inverse transform sampling methods. {helpb runiform()} is used to generate pseudo-random draws from a uniform distribution
which are then mapped onto draws from the chosen distribution through its quantile function. 


{pstd}
The four-parameter GB2 distribution has density

{p 8 8 2}                        
        f(x) = {bf:a}x^({bf:ap}-1)*{({bf:b}^({bf:ap}))*B({bf:p},{bf:q})*[1 + (x/{bf:b})^{bf:a} ]^({bf:p}+{bf:q})}^-1

{pstd}
where {bf:a}, {bf:b}, {bf:p}, {bf:q} are strictly positive parameters and B() is the Beta distribution. {bf:b} is a scale parameter while {bf:a}, {bf:p}, {bf:q} are shape parameters; {bf:a} determines the overall shape, {bf:p} drives the left tail and {bf:q} the right tail.

{pstd}
The Singh-Maddala, Dagum and Fisk distributions can be derived from the GB2.
The Singh-Maddala distribution is obtained with {bf:p}=1; the Dagum with {bf:q}=1 and the Fisk distribution with {bf:p}={bf:q}=1.

{pstd}
The Pareto distribution has density

{p 8 8 2}                        
        f(x) =  {bf:a}*({bf:x0}^{bf:a})*x^(-{bf:a}-1)

{pstd}
where {bf:a} is a positive shape parameter and {bf:x0} is a scale parameter


{title:Options}

{phang}
{opth gb2(numlist)} selects the Genralized Beta Distribution of the Second Kind; it requires four values in {it:numlist} for specifying parameters {it:a}, {it:b}, {it:p} and {it:q}.{p_end}

{phang}
{opth sm(numlist)} selects the Singh-Maddala distribution; it requires three values in {it:numlist} for specifying parameters {it:a}, {it:b} and {it:q}.{p_end}

{phang}
{opth dagum(numlist)} selects the Dagum distribution; it requires three values in {it:numlist} for specifying parameters {it:a}, {it:b} and {it:p}.{p_end}

{phang}
{opth fisk(numlist)} selects the Fisk distribution (also known as a log-logistic distribution); it requires two values in {it:numlist} for specifying parameters {it:a} and {it:b}.{p_end}

{phang}
{opth loglogistic(numlist)} is equivalent to {opth fisk(numlist)}.{p_end}

{phang}
{opth pareto(numlist)} selects a Pareto distribution; it requires two values in {it:numlist} for specifying parameters {it:x0} and {it:a}.{p_end}


{pstd}
Only one option can be specified.


{title:Examples}
	
{phang2}{cmd:. set obs 1000}

{phang2}{cmd:. egen double ysm = rnddraw() , sm(5 100 1.2) }

{phang2}{cmd:. egen double ygb2 = rnddraw() , gb2(5 100 0.8 1.2) }

{phang2}{cmd:. egen double ypareto = rnddraw() , pareto(100 2.5) }

{phang2}{cmd:. graph twoway (kdensity ysm) (kdensity ygb2) (kdensity ypareto)}


{title:References}

{phang}
Jenkins, S.P. (2004). Fitting functional forms to distributions, using {cmd:ml}. Presentation at Second German Stata Users Group Meeting, Berlin.

{phang}
Kleiber, C. and Kotz, S. (2003).  {it:Statistical Size Distributions in Economics and Actuarial Sciences}. Hoboken, NJ: John Wiley.

{phang}
McDonald, J.B. (1984). Some generalized functions for the size distribution of income. {it:Econometrica} 52: 647-663.

	
{title:Author}

{pstd}Philippe Van Kerm, Luxembourg Institute of Socio-Economic Research & University of Luxembourg, philippe.vankerm@liser.lu


{title:Citation}

{phang}
Van Kerm, P. (2017). rnddraw {c -} Random number generation from the GB2, Singh-Maddala, Dagum, Fisk and Pareto distributions,
Statistical Software Components S458349, Boston College Department of Economics. Available from 
{browse "http://ideas.repec.org/c/boc/bocode/s458349.html"}.


{title:Acknowledgements}

{pstd}
This package has been developed in the framework of the SimDeco project ({it:Tax-benefit systems, employment structures and cross-country differences in income inequality in Europe: a micro-simulation approach})
supported by the Luxembourg Fonds National de la Recherche (grant C13/SC/5937475).
	

{title:Also see}

{psee}
	User-written commands:
    {stata ssc describe gb2fit:{bf:gb2fit}},
    {stata ssc describe smfit:{bf:smfit}},
    {stata ssc describe dagumfit:{bf:dagumfit}},
    {stata ssc describe fiskfit:{bf:fiskfit}},
    {stata ssc describe paretofit:{bf:paretofit}}

