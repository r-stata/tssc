{smcl}
{* *! version 1.0.2 20dec2014}{...}
{cmd:help ppschromy}
{hline}
{title:Title}

{p 5}
{cmd:ppschromy} {hline 2} Draw sample with probability proportionate to size, using Chromy's method of sequential random sampling.

{title:Syntax}

{p 8}
{cmd:ppschromy} {ifin}, {cmd:sampsize}({it:variable}) {cmdab:out:name}({it:newvar}) {cmd:sort}({it:varlist}) [{cmd:strata}({it:variable}) {cmd:mos}({it:variable}) {cmd:pmr} {cmdab:rep:lace}]

{phang}
{opt sampsize(variable)} specifies a numeric variable containing, for each case, the desired sample size to be drawn within the case's (explicit) stratum.
{it}(Note: sampsize must be uniform within [explicit] stratum.){sf}{p_end}

{phang}
{opt outname(newvar)} specifies the name of the output sampling variable (e.g., "sampled"); a variable will be created with this name and will be set to the number of times the case has been selected.
For PNR (i.e., probability non-replacement, or sampling without replacement), it will equal 1 for cases sampled, 0 for cases not sampled, and missing for cases omitted from sampling (via "if" or due to missing data).
{p_end}

{phang}
{opt sort(varlist)} specifies, in order, the list of (numeric) sorting variables to be used.
{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt strata(variable)} optionally specifies a numeric variable indicating the (explicit) strata assignments for each case.
{p_end}

{phang}
{opt mos(variable)} optionally specifies the measure of size (MOS) to be used; by default, an equal probability sample design is assumed.
{it}(Note: If using sampling without replacement, that case's MOS divided by the total MOS within stratum must not be greater than the sampling fraction for the stratum.
Otherwise, the program will not run, given that this would lead to a greater-than-100% probability of selection.)
{sf}{p_end}

{phang}
{opt pmr} optionally specifies probability minimum replacement (i.e., a special case of sampling with replacement, in which the number of selections is either the floor or the ceiling of the expected number of selections);
by default, PNR (probability non-replacement, i.e., for sampling without replacement) is used.
{p_end}

{phang}
{opt replace} specifies that if a variable already exists with the name specified by {opt outname(newvar)}, it should be replaced.
{p_end}

{title:Description of Program}

{pstd}
{cmd:ppschromy} implements Chromy's method of probability-proportionate-to-size (PPS) sequential random sampling, including hierarchical serpentine sorting.
Chromy (1979) and Williams and Chromy (1980) provide details.{p_end}

{title:Summary of Chromy's Algorithm}

{pstd}Chromy's sequential selection algorithm is a probability proportionate to size (PPS) sampling procedure that uses implicit stratification based on sorting variables.
This implicit stratification can yield benefits in terms of variance reduction, by spreading the sample throughout the given explicit strata.
When specified without a measure of size (MOS), the algorithm operates as an equal probability of selection method (EPSEM) within each explicit stratum.{p_end}

{pstd}As described by Chromy (1979), the algorithm can be specified as probability nonreplacement (PNR) or probability minimum replacement (PMR).
When PNR is specified, cases cannot be selected more than once (i.e., sampling without replacement).
When PMR is specified, cases can be selected multiple times, but the number of times a case will be selected can only be one of two possibilities:
either the floor or the ceiling of the expected number of selections for that case.
This can be computed as the measure of size (MOS) multiplied by the number of cases to be selected within the stratum divided by the total MOS within the stratum.
E.g., consider a scenario where 50 cases are to be sampled from a stratum in which the measures of size sum to 1000, and the case has a MOS of 75.
In general, a PPS algorithm with replacement will ensure that the expected number of selections for the case will equal 75*50/1000, or 3.75.
However, whereas some other PPS selection methods with replacement could lead to the case being selected 0, 1, or 2 times, or 5, 6, 7, or more times, using PMR, the case can only be selected either 3 or 4 times.
{p_end}

{pstd}Implicit stratification can be used to ensure that the distributions of key sample characteristics reflect those within the sampling frame, by taking into account an ordering in which nearby cases are similar in some respect.
Chromy's algorithm uses hierarchic serpentine sorting, which improves over simply sorting all variables in ascending order, by virtue of alternating sort orderings when a boundary is crossed, in order to increase the similarity of nearby cases.
For example, when simply sorting by age and income in ascending order, an 18-year-old with the highest income would be followed by a 19-year-old with the lowest income;
whereas, with serpentine hierarchic sorting, if 18-year-olds were sorted in ascending order, 19-year-olds would be sorted in descending order;
thus, using serpentine hierarchic sorting, the 18-year-old with the highest income would be followed by the 19-year-old with the highest income.{p_end}

{pstd}An additional benefit of Chromy's algorithm is that while it uses implicit stratification, the samples can also be designed to allow for positive second-order inclusion probabilities (e.g., any pair of elements can be selected).
This property is necessary in order to allow for the computation of unbiased variance estimates.
By comparison, ordered systematic sampling methods often produce joint inclusion probabilities equal to zero, and thus do not allow for unbiased variance estimates (e.g., see Tillé, 2006).
{it}(Note: technically, it's possible to construct certain nonsensical sample designs for which Chromy's algorithm does not yield positive second-order inclusion probabilities;
e.g., sampling only one case in an explicit stratum in which there are at least two population members;
or, sampling two cases in a stratum with a population of at least three, in which one case is sampled with certainty.
However, in most practical applications, the second-order inclusion probabilities will all be positive.){sf}{p_end}

{title:On Sampling Without Replacement When the MOS Leads to an Impossibly High Probability of Selection}

{pstd}As noted in the description for the {it}mos{sf} option, a problematic scenario can sometimes occur in which the measure of size leads to an impossibly high probability of selection (i.e., greater than 100%).
A practical situation in which this can commonly occur is that in which a high sampling fraction is used for a particular stratum.
For example, assume 400 cases are to be sampled from a population of 500, and 250 cases have a MOS of 1, and the other 250 cases have a MOS of 2.
This would lead to 133 cases sampled from the first group and 267 cases sampled from the second group, which is impossible since the second group only contains 250 population members.{p_end}

{pstd}A simple recursive solution can be employed in this situation, assuming that the number of cases to be sampled in the stratum does not exceed the stratum population size.
First, determine whether any cases have a MOS that will lead to a probability of selection greater than 100%.  Select these cases with certainty.
Second, for each stratum, reduce the number of cases to be sampled by the number that were selected in the previous step, and remove these cases from the sampling universe so that they cannot be selected again.
Repeat the previous two steps until no remaining cases are sampled with certainty, and then employ Chromy's method of sequential random sampling on the remaining cases.
The set of cases to be sampled is the union of the set of cases sampled with certainty and the set of cases sampled without certainty.{p_end}

{pstd}In the previous example, this would lead to the 250 cases with a MOS of 2 being selected with certainty. Then, 150 cases would be sampled from the remaining 250 cases.{p_end}

{title:Example 1}

{pstd}Set a random seed.{p_end}
{phang2}{cmd:. set seed 54900988}{p_end}

{pstd}As necessary, recode any string sorting variables to be numeric.{p_end}
{phang2}{cmd:. encode zip_code_string, gen(zip_code_num)}{p_end}
{phang2}{cmd:. encode region, gen(region_num)}{p_end}

{pstd}After any necessary recodes are done, run ppschromy to conduct the sampling, using region for explicit strata, and sorting by gender, age, and ZIP code.{p_end}
{phang2}{cmd:. ppschromy, sampsize(n_to_draw_by_strata) sort(gender age zip_code_num) outname(sampled) strata(region_num) mos(mos)}{p_end}

{title:Example 2: Sampling proportion}

{pstd}The previous example assumed that a variable was available indicating how many cases to sample per stratum.
This example shows how to use the program with a single stratum in conjunction with a sampling proportion rather than a sample size.{p_end}

{phang2}{cmd:. set seed 674222085}{p_end}
{phang2}{cmd:. scalar sampling_fraction = .2}{p_end}
{phang2}{cmd:. count}{p_end}
{phang2}{cmd:. scalar numObs = r(N)}{p_end}
{phang2}{cmd:. gen nInStrata = round(numObs*sampling_fraction)}{p_end}

{phang2}{cmd:. ppschromy, sampsize(nInStrata) sort(gender age zip_code_num) outname(sampled) mos(mos)}{p_end}

{title:Technical Notes}

{pstd}-If the {opt strata} or {opt mos} options are specified, cases with missing data on either of these two variables are omitted from the analysis, though a warning is displayed.{p_end}
{pstd}-Missing data is allowable for sorting variables (i.e., these are treated as valid values and taken into account in sorting).{p_end}

{title:To-Do List}

{phang}Possible modifications that may be made for future versions include:{p_end}
{phang2}-Requiring random seed (or use of an explicit 'no_seed' option), to prevent user error;{p_end}
{phang2}-Adding an option to automatically deal with measures of size that would lead to impossible probabilities of selection, using the previously described recursive algorithm; and{p_end}
{phang2}-Adding options for the computation of the first-order and second-order probabilities of inclusion.{p_end}

{title:References}

{pstd}Chromy, J. R. (1979). "Sequential sample selection methods." In {it}Proceedings of the American Statistical Association, Survey Research Methods Section{sf}.{p_end}

{pstd}Williams, R. L., & Chromy, J. R. (1980). "SAS sample selection macros." In {it}Proceedings of the Fifth Annual SAS Users Group International Conference{sf}.{p_end}

{pstd}Tillé, Y. (2006). {it}Sampling Algorithms{sf}. Springer.{p_end}

{title:Author}

{pstd}Jonathan Mendelson, Fors Marsh Group, jmendelson@forsmarshgroup.com.{p_end}
{pstd}The author welcomes any comments or questions.{p_end}

{title:Acknowledgements}

{pstd}Thanks to Joe Luchman for helping to test various versions of the program and for his helpful suggestions for features. Thanks also to Pengyu Huang for his helpful suggestions relating to the documentation.{p_end}
