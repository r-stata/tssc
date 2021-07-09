{smcl}
{* *! version 1.0 03apr2020}{...}
{cmd:help rassign}
{hline}

{title:Title}

{p2colset 4 18 20 2}{...}
{p2col:{hi:rassign} {hline 1}}{title:Regression-based test for random assignment to peer groups (Jochmans, 2020)}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 15 2}
{cmd:rassign} {depvar} {it:indepvar} [{it:w}]  {ifin} {cmd:,} {opt group(varname)}

{pstd} where w are optional additional control variables to be included 

{synoptset 15 tabbed}
{marker rassign}{...}
{synopthdr}
{synoptline}
{synopt:{opt g:roup}}Specifies the urn from which peers are drawn {p_end}
{p2colreset}{...}


{title:Description}

{pstd}{opt rassign} performs a regression-based test for the (conditional) random assignment of individuals in urns to peer groups (Jochmans, 2020). The dependent variable is a characteristic of the individual. 
The independent variable is the average characteristic of the individual's peers. The test controls for fixed effects at the urn level by default. The optional w are additional covariates that can be controlled for. The command can equally be used to test for the presence of peer effects in the linear-in-means model without modification.

{title:Saved results}

{pstd}
{cmd:rassign} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 4: Scalars}{p_end}
{synopt:{cmd:r(t)}}the test statistic{p_end}
{synopt:{cmd:r(r_pvalue)}}right-sided p-value{p_end}
{synopt:{cmd:r(pvalue)}}two-sided p-value{p_end}
{synopt:{cmd:r(l_pvalue)}}left-sided p-value{p_end}
{synopt:{cmd:r(Ng)}}Number of urns{p_end}
{synopt:{cmd:r(maxG)}}Size of largest urn{p_end}
{synopt:{cmd:r(minG)}}Size of smallest urn {p_end}

{title:Example}

{phang}{cmd:. use pga_data}{p_end}
{phang}{cmd:. rassign handicap hand_i if round==1, group(tourn)}{p_end}

{phang}
The data set pga_data.dta of Guryan, Kroft and Notowidigo (2009) can be downloaded from https://www.aeaweb.org/articles?id=10.1257/app.1.4.34


{title:References}

{phang} Guryan, J., D. Kroft, and N. J. Notowidigdo (2009). Peer effects in the workplace: Evidence from random groupings in professional golf tournaments. American Economic Journal: Applied Economics 44, 289–302.

{phang}Jochmans, K. (2020). Testing random assignment to peer groups.
Mimeo, April 2020.



{title:Authors}

{pstd}Koen Jochmans, University of Cambridge; and Vincenzo Verardi, FNRS-UNamur{p_end}


