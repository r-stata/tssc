{smcl}

{* * ! version 1.1 7-31-2013}{...}
{cmd:help iccvar}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:iccvar} {hline 2}}intraclass correlation values and stadard errors for 2, 3, and 4 level models after {cmd:xtmixed} or {cmd:mixed}.{p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:iccvar}{cmd:,} [{it:unb}]

{synoptline}

{syntab:{cmd:iccvar} has a special routine for 3-level models with unbalanced data. To enact this routine use the {it:unb} option. }

{synoptline}

{title:Description}

{pstd}{cmd:iccvar} is a post-estimation command for {cmd:xtmixed} or {cmd:mixed}.  After fitting a 2, 3, or 4 level model with a random intercept 
(random slopes are not supported), {cmd:iccvar} will calculate the intraclass correlation (ICC) values and the associated standard 
errors based on the variance components and standard errors of the variance components estimated from {cmd:xtmixed}. 

{title:Saved results}

{pstd}
{cmd:iccvar} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}the harmonic mean number of level 2 units per level 3 unit{p_end}
{synopt:{cmd:r(r)}}the harmonic mean number of level 3 units per level 4 unit{p_end}
{synopt:{cmd:r(tv)}}the total estimated variance{p_end}
{synopt:{cmd:r(l{it:k}vc)}}the {it:k} level variance component{p_end}
{synopt:{cmd:r(l{it:k}vc_v)}}the {it:k} level variance component variance{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(model)}}the {cmd:xtmixed} model{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}the matrix of ICCs{p_end}
{synopt:{cmd:r(V)}}the variance-covariance matrix of ICCs{p_end}

{title:Acknowledgments}

The algorithms used in this program are based on
{phang}Hedges, L. V., E. C. Hedberg and A. M. Kuyper. 2012. The Variance of Intraclass Correlations in Three- and Four-Level Models. Educational and Psychological Measurement. DOI: 10.1177/0013164412445193. Click for paper: {browse "http://epm.sagepub.com/content/early/2012/04/30/0013164412445193":link.}

{title:Contact}

{pstd}This program was written by Eric Hedberg, National Opinion Research Center at the University of Chicago.  
Any questions or comments can be directed to ech@uchicago.edu.


