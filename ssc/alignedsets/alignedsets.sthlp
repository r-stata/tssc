{smcl}
{* *! version 1.0.0  24aug2014}{...}
{cmd:help alignedsets}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:alignedsets}{hline 2}}Aligned ranks test for matched sets (Hodges-Lehmann){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 19 2}
		{cmd:alignedsets} {depvar} {ifin} {cmd:,} {cmd:by(}{it:{help varlist:groupvar}}{cmd:)} 
		{opt set:}({it:{help varlist:varlist}})
		

{synoptset 21 tabbed}{...}
{synopthdr:options}
{synoptline}
{p2coldent:* {opth by:(varlist:groupvar)}}grouping variable. It must contain integer values of 0 and 1 representing the treatment levels{p_end} 
{p2coldent:* {opth set:(varlist:varlist)}}stratify by {it:varlist}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt by(groupvar)} and {opt set(varlist)} are required.{p_end}
{p 4 6 2}{opt by} is allowed with {cmd:alignedsets};
see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:alignedsets} is the Hodges & Lehmann (1962) extension to the Wilcoxon signed-ranks test {manhelp signrank R} for matching 
with multiple controls. The approach involves ranking observations after they have undergone alignment within their respective sets,
thereby removing set-specific effects from the data. More specifically, each matched set is first centered by subtracting the set's mean from 
each outcome, next the aligned outcomes are ranked over all sets, and finally the sum of ranks is calculated for the treated participants. 

{pstd}
{cmd:alignedsets} produces the Hodges & Lehmann aligned rank statistic which is used to test the null hypothesis of no difference  
between an outcome for the treated unit(s) in the set compared to the outcomes of matched controls.    

{pstd}
For Hodges & Lehmann aligned ranks test on unmatched data, see {cmd:alignedranks} (available for download at SSC).


{marker options_alignedranks}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:by(}{it:{help varlist:groupvar}}{cmd:)} is required.  It specifies the
name of the grouping variable, and must contain integer values of 0 and 1 representing the treatment levels

{phang}
{cmd:set(}{it:{help varlist:varlist}}{cmd:)} specifies the variable on which to stratify the analysis (ie., the set identifier that matched subjects
 belong to). Observations will be ignored for missing values of {cmd:set}. 


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Load example data{p_end}
{p 4 8 2}{stata "use simdata, clear":. use simdata, clear}{p_end}

{pstd}Perform aligned ranks test on the baseline variable {cmd:x1} to demonstrate covariate balance{p_end}
{p 4 8 2}{stata "alignedsets x1, by(treat) set(set)":. alignedsets x1, by(treat) set(set)}{p_end}

{pstd}Perform aligned ranks test on the outcome variable {cmd:y}{p_end}
{p 4 8 2}{stata "alignedsets y, by(treat) set(set)":. alignedsets y, by(treat) set(set)}{p_end}

{pstd}We now limit the analysis to the first 100 sets{p_end}
{p 4 8 2}{stata "alignedsets y if inrange(set, 1, 100), by(treat) set(set)":. alignedsets y if inrange(set, 1, 100), by(treat) set(set)}{p_end}

    {hline}


{marker saved_results}{...}
{title:Saved results}

{pstd}{cmd:alignedsets} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(actual)}}actual sum of ranks for treated group (group coded as 1) {p_end}
{synopt:{cmd:r(expect)}}expected sum of ranks for treated group {p_end}
{synopt:{cmd:r(diff)}}difference (aligned rank statistic){p_end}
{synopt:{cmd:r(var)}}variance{p_end}
{synopt:{cmd:r(se)}}standard error{p_end}
{synopt:{cmd:r(z)}}z statistic{p_end}
{synopt:{cmd:r(p)}}two-sided probability{p_end}


{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Hodges, J. L., and E. L. Lehmann. 1962. Rank methods for combination of
independent experiments in the analysis of variance. 
{it:Annals of Mathematical Statistics} 33: 482–497.

{phang}
Lehmann, E. L. 2006. {it: Nonparametrics: statistical methods based on ranks (Rev. ed.)}
New York: Springer. 
 

{marker citation}{title:Citation of {cmd:alignedsets}}

{p 4 8 2}{cmd:alignedsets} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel. 2014. 
alignedsets: Stata module for implementing aligned ranks test for matched sets (Hodges-Lehmann).
{p_end}



{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
Ann Arbor, MI, USA{break} 
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}

        


{title:Also see}

{p 4 8 2}Online: {helpb signrank}, {helpb ranksum}, {helpb alignedranks} (if installed), 
{helpb somersd} (if installed){p_end}
