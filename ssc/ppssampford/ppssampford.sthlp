{smcl}
{* *! version 0.1.0 14dec2014}{...}
help for {cmd:ppssampford} - version 0.1.0 - 14dec2014
{hline}
{title:Title}

{p 5}
{cmd:ppssampford} {hline 2} Draw sample with probability proportionate to size without replacement, using Sampford's method.

{title:Syntax}

{p 8}
{cmd:ppssampford} {ifin}, {cmd:sampsize}({it:variable}) {cmdab:out:name}({it:newvar}) {cmd:mos}({it:variable}) [{cmd:strata}({it:variable}) {cmdab:rescale} {cmdab:outpos}({it:newvar}) {cmdab:rep:lace}]

{phang}
{opt sampsize(variable)} specifies a numeric variable containing, for each case, the desired sample size to be drawn within stratum.
{it}(Note: sampsize must be uniform within stratum.){sf}{p_end}

{phang}
{opt outname(newvar)} specifies the name of the output sampling variable (e.g., "sampled");
a variable will be created with this name and will be set to 1 for cases sampled, 0 for cases not sampled, and missing for cases omitted from sampling via "if" or due to missing data.
{p_end}

{phang}
{opt mos(variable)} specifies the measure of size (MOS) to be used.
{it}(Note: Unless you specify {opt rescale}, a case's MOS divided by the total MOS within stratum must not be greater than the sampling fraction for the stratum.
Otherwise, this would lead to a greater-than-100% probability of selection.)
{sf}{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt strata(variable)} optionally specifies a numeric variable indicating the strata assignment for each case.
{p_end}

{phang}
{opt rescale} optionally specifies that if any measures of size lead to an impossibly high probability of selection, the program should select such cases with certainty.
Then, the Sampford design (with a recalculated target sample size) should be implemented on the remaining cases.
{it}(Note: If this option is specified, the user is strongly urged to also specify {opt outpos(newvar)}, given that the probability of selection will no longer be proportional to the original MOS.){sf}
{p_end}

{phang}
{opt outpos(newvar)} optionally specifies a new variable that should be created containing a given case's probability of selection (i.e., first order inclusion probability).
{p_end}

{phang}
{opt replace} optionally specifies that if any variables already exist with the names specified by {opt outname(newvar)} and/or {opt rescale} (if applicable), they should be replaced.
{p_end}

{title:Description of Program}

{pstd}
{cmd:ppssampford} implements Sampford's method of selecting samples with inclusion probability proportionate to size, without replacement (PPSWOR). Sampford (1967) provides details.{p_end}

{title:Summary of Sampford's Method}

{pstd}Sampford's method is a probability proportionate to size sampling procedure without replacement.
There are several algorithms for implementing Sampford sampling designs (e.g., see Tillé, 2006; also see Grafström, 2008).
This particular program implements Sampford's original algorithm, described by Tillé (2006) as a multinomial rejective procedure:{p_end}

{phang2}1. Select one case with probability proportionate to size with replacement (PPSWR) sampling with probability proportionate to the initial MOS.{p_end}
{phang2}2. Select n-1 cases with PPSWR based on a MOS that has been recalculated as lambda[i] = p[i]/(1-n*p[i]), where p[i] = MOS[i]/summation(MOS[i], for i=1/N);
i.e., p[i] equals the measure of size for a particular case divided by the sum of all measures of size.{p_end}
{phang2}3. Combine the samples from (1) and (2). If no cases have been selected more than once, keep the sample, otherwise repeat steps (1) through (3).{p_end}

{pstd}Benefits of Sampford's method are that it allows for the selection of PPSWOR samples for a fixed sample size, and allows for positive second-order inclusion probabilities, which are necessary for unbiased variance estimates;
however, a drawback of rejective Sampford algorithms is that they can be slow.
The algorithm can be particularly slow when a high sampling fraction is used and/or when a case has a probability of selection of just below 100%.
However, Grafström's paper provides a non-rejective algorithm for implementing the Sampford design, which I plan to incorporate into a subsequent version of this program.{p_end}

{title:On Sampling Without Replacement When the MOS Leads to an Impossibly High Probability of Selection}

{pstd}As noted in the description for the {it}mos{sf} option, a problematic scenario can sometimes occur in which the measure of size leads to an impossibly high probability of selection (i.e., greater than 100%).
A practical situation in which this can commonly occur is that in which a high sampling fraction is used for a particular stratum.
For example, assume 400 cases are to be sampled from a population of 500, and 250 cases have a MOS of 1, and the other 250 cases have a MOS of 2.
This would lead to 133 cases sampled from the first group and 267 cases sampled from the second group, which is impossible since the second group only contains 250 population members.{p_end}

{pstd}A simple recursive solution can be employed in this situation, assuming that the number of cases to be sampled in the stratum does not exceed the stratum population size.
First, determine whether any cases have a MOS that will lead to a probability of selection greater than 100%.  Select these cases with certainty.
Second, for each stratum, reduce the number of cases to be sampled by the number that were selected in the previous step, and remove these cases from the sampling universe so that they cannot be selected again.
Repeat the previous two steps until no remaining cases are sampled with certainty, and then employ Sampford's algorithm on the remaining cases.
The set of cases to be sampled is the union of the set of cases sampled with certainty and the set of cases sampled without certainty.{p_end}

{pstd}In the previous example, this would lead to the 250 cases with a MOS of 2 being selected with certainty. Then, 150 cases would be sampled from the remaining 250 cases.{p_end}

{pstd}This algorithm has been implemented via the {opt rescale} option.{p_end}

{title:Technical Notes}

{pstd}-If the {opt strata} or {opt mos} options are specified, cases with missing data on either of these two variables are omitted from the analysis, though a warning is displayed.{p_end}
{pstd}-This is a beta version of a program implementing the Sampford algorithm.
While it seems to be operating correctly, the author urges users to verify that it is operating as intended and to email him with any bug reports.
Note that {stata net search ppschromy:ppschromy} is a PPSWOR program by the same author that has been thoroughly tested, though it has different properties for the joint inclusion probabilities.{p_end}

{title:To-Do List}

{phang}Possible modifications that may be made for future versions include:{p_end}
{phang2}-Conduct additional testing prior to a v1.0.0 release;{p_end}
{phang2}-Implement a non-rejective version of Sampford's algorithm, to improve program speed;{p_end}
{phang2}-Add an option for the computation of the second-order probabilities of inclusion.{p_end}

{title:References}

{pstd}Grafström, A. (2009). Non-rejective implementations of the Sampford sampling design. {it}Journal of Statistical Planning and Inference, 139{sf}(6), 2111-2114.{p_end}

{pstd}Sampford, M. R. (1967). On sampling without replacement with unequal probabilities of selection. {it}Biometrika, 54{sf}(3-4), 499-513.{p_end}

{pstd}Tillé, Y. (2006). {it}Sampling Algorithms{sf}. Springer.{p_end}

{title:Author}

{pstd}Jonathan Mendelson, Fors Marsh Group, jmendelson@forsmarshgroup.com.{p_end}
{pstd}The author welcomes any comments or questions.{p_end}
