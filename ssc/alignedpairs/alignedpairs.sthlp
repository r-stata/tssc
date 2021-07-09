{smcl}
{* *! version 1.0.0  05sep2014}{...}
{cmd:help alignedpairs}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:alignedpairs}{hline 2}} Aligned ranks test for matched pairs (Hodges-Lehmann){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 19 2}
		{cmd:alignedpairs} {varname} {cmd:=} {it:{help exp}} {ifin} {cmd:[,} {opt l:evel}(#)]
		
 		
		
{synoptset 16}{...}
{synopthdr}
{synoptline}
{synopt :{opth l:evel(level:level)}}specifies the confidence level for the Hodges-Lehmann estimator; {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{opt by} is allowed with {cmd:alignedpairs}; see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:alignedpairs} performs two analyses for matched-pairs: (1) the standard Wilcoxon signed-ranks test (Wilcoxon 1945) using the official 
Stata {manhelp signrank R}, and (2) the Hodges-Lehmann (1963) treatment effects estimator with distribution-free confidence intervals 
(for exposition, see Hollander et al. [2014] pg 56-60). 

{pstd}
In the case of matched-pairs, the Hodges-Lehmann estimator is defined as the median of the set of n(n+1)/2 Walsh averages (Walsh 1949). 
More specifically, the process entails estimating the average difference in outcomes (x-y) for every possible n(n+1)/2 pair and then deriving the 
overall median of all averages  (the Hodges-Lehmann estimator). A distribution-free confidence interval is estimated using large-sample approximation
(see Hollander et al. [2014] pg. 59).   

{pstd}
For the Hodges-Lehmann aligned ranks test on unmatched data, see {cmd:alignedranks}, and for the Hodges-Lehmann aligned ranks test 
for matched sets, see {cmd:alignedsets} (both available for download at SSC).



{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Load example data{p_end}
{p 4 8 2}{stata "use hamilton, clear":. use hamilton, clear}{p_end}

{pstd}Perform aligned ranks test comparing {cmd:x} and {cmd:y} outcomes specifying a 96% confidence interval (see Hollander et al. [2014] pg 56-60){p_end}
{p 4 8 2}{stata "alignedpairs y=x, level(96)":. alignedpairs y=x, level(96)}{p_end}

{pstd}Compare results using a paired t test{p_end}
{p 4 8 2}{stata "ttest y=x, level(96)":. ttest y=x, level(96)}{p_end}

    {hline}


{marker saved_results}{...}
{title:Saved results}

{pstd}{cmd:alignedpairs} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N_neg)}}number of negative comparisons{p_end}
{synopt:{cmd:r(N_pos)}}number of positive comparisons{p_end}
{synopt:{cmd:r(N_tie)}}number of tied comparisons{p_end}
{synopt:{cmd:r(p_2)}}two-sided probability{p_end}
{synopt:{cmd:r(p_neg)}}one-sided probability of negative comparison{p_end}
{synopt:{cmd:r(p_pos)}}one-sided probability of positive comparison{p_end}

{synopt:{cmd:r(estimate)}}Hodges-Lehmann estimate{p_end}
{synopt:{cmd:r(lb_1)}}lower confidence bound{p_end}
{synopt:{cmd:r(ub_1)}}upper confidence bound{p_end}
{synopt:{cmd:r(hl_obs)}}n(n+1)/2 number of observations{p_end}


{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Hershberger, S. L. 2011. Hodges-Lehmann Estimators. 
In {it:International Encyclopedia of Statistical Science} (pp. 635-636). Berlin: Springer.

{phang}
Hodges, J. L., and E. L. Lehmann. 1962. Rank methods for combination of
independent experiments in the analysis of variance. 
{it:Annals of Mathematical Statistics} 33: 482–497.

{phang}
Hodges, J. L., and E. L. Lehmann. 1963. Estimation of location based on ranks.  
{it: Annals of Mathematical Statistics} 34: 598–611.

{phang}
Hodges, J. L., and E. L. Lehmann. 1983. In S. Kotz, N. L. Johnson, L. Norman, and C.B. Read (Eds),
{it: Encyclopedia of Statistical Sciences}, Volume 3, pp. 642-645. New York: John Wiley and Sons, Inc. 

{phang}
Hollander, M., Wolfe, D.A., and Eric Chicken. 2014. {it: Nonparametric Statistical Methods (3rd ed)}. 
Hoboken, New Jersey: John Wiley and Sons.

{phang}
Lehmann, E. L. 2006. {it: Nonparametrics: statistical methods based on ranks (Rev. ed.)}
New York: Springer.

{phang}
Rosenbaum, P. R. 1993. Hodges-Lehmann point estimates of treatment effect in 
observational studies. {it:Journal of the American Statistical Association} 88: 1250-1253. 

{phang}
Walsh, J. E. 1949. Some significance tests for the median which are
valid under very general conditions. {it: Annals of Mathematical Statistics} 20: 64–81. 

{phang}
Wilcoxon, F. 1945. Individual comparisons by ranking methods.
{it:Biometrics} 1: 80-83.



{marker citation}{title:Citation of {cmd:alignedpairs}}

{p 4 8 2}{cmd:alignedpairs} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel. 2014. 
alignedpairs: Stata module for implementing aligned ranks test for matched pairs (Hodges-Lehmann).
{p_end}



{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
Ann Arbor, MI, USA{break} 
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}


{title:Acknowledgments} 

{p 4 4 2}
I wish to thank Nicholas J. Cox for his support while developing {cmd:alignedpairs}{p_end}
        


{title:Also see}

{p 4 8 2}Online: {helpb signrank}, {helpb ranksum}, {helpb alignedranks} (if installed), 
{helpb alignedsets} (if installed), {helpb somersd} (if installed){p_end}
