{smcl}
{* *! version 10.1.1  20mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:crater} {hline 2} Calculates computer scorer vs. human rater agreement statistics


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:crater}
[{human_scores computer_scores}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:crater} calculates the number of computer scores produced for each human score, 
% missing, agreement raters,  correlation, Kappa (unweighted, weighted, and quadratic weighted),
mean difference, and standardized mean difference. Detailed describtions of the kappa statistic 
can be found in Fleiss, 1981. SMD is calculated as the mean difference between the computer and 
human rater divided by the average variance.

{marker options}{...}
{title:Options}

{phang}
There are no options available for this command.

{marker remarks}{...}
{title:Remarks}

{pstd}
For rules of thumb regarding reccomended agreement rates between computers and raters see 
Williamson et. al. 2012.

{marker examples}{...}
{title:Example syntax}

{phang}{cmd:. use reading.dta, clear}{p_end}
{phang}{cmd:. crater human computer}{p_end}


{marker refereces}{...}
{title:References}

Fleiss, J. L. (1981) Statistical methods for rates and proportions. 2nd ed.
	(New York: John Wiley) pp. 38–46.

Williamson, D. M., Xi, X. and Breyer, F. J. (2012), A Framework for Evaluation and Use 
	of Automated Scoring. Educational Measurement: Issues and Practice, 31: 2–13. 
