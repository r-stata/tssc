{smcl}
{* *! version 1.0.0 29Oct2019}{...}

{title:Title}

{p2colset 5 18 19 2}{...}
{p2col:{hi:fragility} {hline 2}} Fragility index and quotient {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:fragility}
{it:#Y1 #N1 #Y2 #N2}
[{cmd:,}
{opt lev:el(#)}
{opt chi:2}
{opt det:ail}
]


{pstd}
In the syntax, {it:#Y1} is the number of events in Group 1, {it:#N1} is the sample size of Group 1, {it:#Y2} is the number of events in Group 2, and {it:#N2} is the sample size of Group 2.


{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt lev:el(#)}}the desired {it:P}-value threshold level at which to test statistical significance; {opt default is 0.05}{p_end}
{synopt :{opt chi:2}}compute fragility index based on Pearson's chi-squared test; {opt default is Fisher's exact test}{p_end}
{synopt:{opt det:ail}}display all output documenting the steps performed to obtain the final results{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt fragility} computes both the fragility index as described in Walsh et al. (2014) and the fragility quotient as proposed by Ahmed et al. (2016). 
The fragility index represents the absolute number of additional events (primary endpoints) required to obtain a {it: P}-value greater than or equal to a predetermined 
statistical significance threshold (typically set to 0.05). The fragility index is computed by adding an event to the group with the smaller number of events 
(and subtracting a non-event from the same group to keep the total number of patients constant) and recomputing the two-sided significance test (either 
Fisher's exact test or Pearson's chi-squared test). Events are iteratively added until the first time the computed {it:P}-value becomes equal to or greater 
than the desired {opt level()}.

{pstd}
The fragility quotient is a relative measure of fragility which simply divides the absolute fragility index by the total sample size (Ahmed et al. 2016). 
The user is directed to the references provided below for a comprehensive discussion of the usefulness and limitations of these two measures.



{title:Options}

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the desired {it:P}-value threshold level at which to test statistical significance. Most disciplines tend to use the {it:P}-value 
threshold of 0.05 to imply that the observed result is unlikely to occur by chance. However, some disciplines set the threshold for statistical significance more 
liberally to 0.10, while others may set the threshold more conservatively, such as 0.01. {opt level(#)} allows users to set their own threshold. The default is {opt level(0.05)}. 

{p 4 8 2}
{cmd:chi2} calculates and displays Pearson's chi-squared for the hypothesis that the rows and columns in a two-way table are independent. The default is Fisher's exact test, which
generally produces more conservative estimates.

{p 4 8 2}
{cmd:detail} displays all of the 2 X 2 tables produced during the iterative process of adding events to the group with the lowest actual number of events, until the {it:P}-value
threshold is met or surpassed.



{title:Examples}

{pmore}Example 1 from Walsh et al. (2014) in which Group 1 has 1 event and Group 2 has 9 events. The resulting fragility index of 1 suggests 
that the inference of a treatment effect is "fragile". That is, only one additional event is needed to flip the results
from being statistically significant to non-significant at the 0.05 level. {p_end}
{pmore2}{bf:{stata "fragility 1 100 9 100": . fragility 1 100 9 100}} {p_end}

{pmore}Example 2 from Walsh et al. (2014) in which Group 1 has 200 events and Group 2 has 250 events. Here the resulting fragilty index is 9, 
suggesting the results are less "fragile". {p_end}
{pmore2}{bf:{stata "fragility 200 4000 250 4000": . fragility 200 4000 250 4000}} {p_end}

{pmore}Same as above, but specifying that Pearson's chi-squared test be used rather than the default Fisher's exact test. {p_end}
{pmore2}{bf:{stata "fragility 200 4000 250 4000, chi2": . fragility 200 4000 250 4000, chi2}} {p_end}

{pmore}Same as above, but further requesting to display all the detail. {p_end}
{pmore2}{bf:{stata "fragility 200 4000 250 4000, chi2 detail": . fragility 200 4000 250 4000, chi2 detail}} {p_end}





{title:Acknowledgments}

{p 4 4 2}
I thank John Moran for advocating that I write this package. 



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:fragility} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(fi)}}fragility index{p_end}
{synopt:{cmd:r(fq)}}fragility quotient{p_end}
{synopt:{cmd:r(pval)}}{it:P}-value at the fragility index{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Ahmed W, Fowler RA, McCredie VA: Does Sample Size Matter When Interpreting the Fragility Index?
{it:Critical Care Medicine} 2016;44(11):e1142-e1143. {p_end}

{p 4 8 2}
Brown J, Lane A, Cooper C, Vassar M: The Results of Randomized Controlled Trials in Emergency Medicine 
Are Frequently Fragile. {it:Annals of Emergency Medicine} 2019;73(6):565-576.

{p 4 8 2}
Brown J, Lane A, Cooper C, Vassar M: Fragility Measures: More Limitations Considered Reply. 
{it:Annals of Emergency Medicine} 2019;73(6):697-698.

{p 4 8 2}
Carter RE, McKie PM, Storlie CB: The Fragility Index: a P-value in sheep's clothing?
{it:European Heart Journal} 2017;38(5):346-348. {p_end}

{p 4 8 2}
Niforatos JD, Zheutlin AR, Pescatore RM: Fragility Measures: More Limitations Considered. 
{it:Annals of Emergency Medicine} 2019;73(6):696-697.

{p 4 8 2}
Tignanelli CJ, Napolitano LM: The Fragility Index in Randomized Clinical Trials as a Means of Optimizing Patient Care.
{it:JAMA Surgery} 2019;154(1):74-79. {p_end}

{p 4 8 2}
Walsh M, Srinathan SK, McAuley DF, Mrkobrada M, Levine O, Ribic C, Molnar AO, Dattani ND, Burke A, Guyatt G et al: 
The statistical significance of randomized controlled trial results is frequently fragile: a case for a Fragility Index.
{it: Journal of Clinical Epidemiology} 2014;67(6):622-628. {p_end}



{marker citation}{title:Citation of {cmd:fragility}}

{p 4 8 2}{cmd:fragility} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). Fragility: Stata module for computing the fragility index.{p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb tabi} {p_end}

