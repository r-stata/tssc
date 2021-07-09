{smcl}
{* 14June2012}{...}
{hline}
help for {hi:repsample}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:repsample} {hline 2}} Representative sampling from a population or theoretical distributions{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:repsample}
{it:#}
{ifin}
[{cmd:,} {it:{help repsample##options:options}}]

{p 4 4 2}
where

{p 6 6 2}
{it:#} the size of the desired sample.

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth cont(varlist)}}Continuous variable(s)
{p_end}
{synopt :{opth bincat(varlist)}}Binary and categorical variable(s)
{p_end}
{synopt :{opth mean(numlist)}}Means for continuous variables, for sampling from theoretical only
{p_end}
{synopt :{opth sd(numlist)}}SDs for continuous variables, for sampling from theoretical only
{p_end}
{synopt :{opth perc(numlist)}}Percentages for binary variables, for sampling from theoretical only
{p_end}
{synopt :{opth seednum(#)}}Seed number (default is 7)
{p_end}
{synopt :{opth randomperc(#)}}Percentage of randomly selected cases (default is 10)
{p_end}
{synopt :{opth srule(#)}}Early stopping rule based on overall test p-value
{p_end}
{synopt :{opth rrule(#)}}Early stopping rule based on random sampling
{p_end}
{synopt :{opth wght(numlist)}}Weighting for variables to sample on
{p_end}
{synopt :{opth retain(varname)}}Sampling on top of provided binary variable
{p_end}
{synopt :{opt exact}}Use exact tests instead of asymptotic approximations
{p_end}
{synopt :{opt force}}Force replace sample information variable {it:repsample}, if present in the dataset
{p_end}


{title:Description}

{p 4 4 2}
{cmd:repsample} is a greedy algorithm that uses appropriate tests to generate a sample that is as representative as possible in terms of the selected parameters.
If details for the theoretical distributions are not provided (i.e. options {opt mean()}, {opt sd()} and {opt perc()} are not used) the program uses the whole
dataset as a population from which to sample. In this case it employs two-sample Kolmogorov-Smirnov tests ({help ksmirnov}) for continuous variables and Chi-square (or Fisher's exact) tests for
binary and categorical variables ({help tabulate twoway}). If details for the theoretical distributions are provided, the program uses one-sample Kolmogorov-Smirnov tests for continuous variables,
assuming normal distributions. For binary variables (categorical vars are not allowed in theoretical sampling), one-sample tests of proportions are used ({help prtest}) or binomial probability tests
({help bitest}) if the {opt exact} option is specified. The sample information is stored in variable {it:repsample} after execution is finished.


{title:Options}

{phang}
{opth cont(varlist)} Continuous variable(s) on which 'representativeness' will be based.

{phang}
{opth bincat(varlist)} Binary and categorical variable(s) on which 'representativeness' will be based. For theoretical sampling only binary variables are allowed.

{phang}
{opth mean(numlist)} List of means for continuous variables. Order must correspond to order in {opt cont()}. Only required for sampling using one or more theoretical distributions.

{phang}
{opth sd(numlist)} List of standard deviations for continuous variables. Order must correspond to order in {opt cont()}. Only required for sampling using one or more theoretical distributions.

{phang}
{opth perc(numlist)} List of percentages for continuous variables. Order must correspond to order in {opt bincat()} and percentages need to be in the (0,100) range.
Only required for sampling using one or more theoretical distributions.

{phang}
{opth seednum(#)} Random seed number; the default is 7.

{phang}
{opth randomperc(#)} The percentage of cases that will be randomly selected at the start of the algorithm. The percentage must be in the [0,100] range and the default value is 10.
Setting to zero will provide a completely deterministic sample and to 100 a completely random sample.

{phang}
{opth srule(#)} Early stopping rule that speeds up the process, using the p-value for Fisher's combined probability (chi-square) test. It must be in the [0.5,1) range and once a sub-sample is identified
for which the p-value is above the one specified, that sub-sample is selected the the search is stopped early (without going through all cases). Then the algorithm proceeds to select the next case in the
sample using the same decision rule. This option is a compromise and the smaller the threshold value, the less likely the resulting sample will be a close match.

{phang}
{opth rrule(#)} Early stopping rule that speeds up the process, using a random sampling approach. Within each iteration, rather than sequentially going through all the cases in fully deterministic way,
this options randomly selects # cases from which it picks the single case that leads to the highest p-value in Fisher's combined probability (chi-square) test.
The minimum number allowed is 10 and there is no maximum limit (obviously constrained by the number of cases available for selection - although the command will not return an error if #>available cases).
The two stopping rules {opt srule()} and {opt rrule()} can be combined to greatly increase speed.

{phang}
{opth wght(numlist)} Variable weighting, to give greater importance to some in the process. User needs to provide as many numbers as there are variables and the total weight needs to add up to 100. The order
the weights are assigned is always the same, with the continuous variables (if any) prioritised and the weights assigned to them in the order provided in the two options, then the same for binary and categorical
variables. Note that the overall matching measures reported in {cmd:r(chi2)} and {cmd:r(p)} are using the weighted scores and therefore quantify the matching under the provided weights assumption. But the 
individual variable matching measures are unaffected.

{phang}
{opth retain(varname)} If a sampling variable to be retained is provided the program will sample on top of the current sample. This option is provided for batched sampling (running time can be very long
for large samples and populations), and replacing cases that have withdrawn or become unavailable. For example, if the idea is to sample 100 representative patients to be enrolled in a study
the researcher might wish to replace patients who did not agree to participate in the first instance. Cases that are not eligible for selection and cannot be dropped since they define the population should
be set to missing in variable {it:varname} prior to executing the {cmd:repsample} command.

{phang}
{opt exact} Use exact tests instead of asymptotic approximations. For population sampling, this option increases computation time considerably since it calculates exact p-values in the two-sample
Kolmogorov-Smirnov tests (for continuous variables) and Fisher's exact test (for categorical and binary variables). For theoretical sampling, the increase in computation time is not as dramatic since only
binary variables are affected with the use of the binomial probability test ({help bitest}).

{phang}
{opt force} Force replace sample information variable {it:repsample}, if present in the dataset. Cannot be used along with {opt retain(repsample)}, but can be used with that option if another variable
name is specified.


{title:Remarks}

{p 4 4 2}
The algorithm starts with a random selection of cases (default is 10%) and then at each step and for each eligible case for selection, it compares the sample (assuming the
eligible case was selected) to the population or theoretical distribution(s) on the selected variables and calculates an overall score using Fisher's combined probability test.
The test transforms the p-values and combines them in a chi-square test with 2*k degrees of freedom, where k is the number of tests to be combined.
The case that leads to minimum deviation between the sample and the population, or the theoretical distributions, is selected and the algorithm proceeds in such a manner at each
step, until the selected size is sampled.


{title:Examples}

{p 4 4 2}
Sampling from population:

{p 4 4 2}

{phang2}{cmd:. repsample 10, cont(soaimd07 totalpatients) bincat(ruralvar gps_num_cat) seednum(10) force}{p_end}
{phang2}{cmd:. repsample 20, cont(soaimd07 totalpatients) bincat(ruralvar gps_num_cat) seednum(10) retain(repsample)}{p_end}

{p 4 4 2}
Sampling using theoretical distributions:

{p 4 4 2}

{phang2}{cmd:. repsample 10, cont(soaimd07 totalpatients) bincat(ruralvar) mean(30 7000) sd(15 4000) perc(30) seednum(10) force}{p_end}
{phang2}{cmd:. repsample 20, cont(soaimd07 totalpatients) bincat(ruralvar) mean(30 7000) sd(15 4000) perc(30) seednum(10) retain(repsample)}{p_end}


{title:Saved results}

{pstd}
{cmd:repsample} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}p-value from Fisher's combined probability test{p_end}
{synopt:{cmd:r(chi2)}}chi^2 statistic from Fisher's combined probability test{p_end}
{synopt:{cmd:r(df)}}degrees of freedom for Fisher's combined probability test{p_end}

{pstd}
For continuous variables:

{synopt:{cmd:r({it:varname}_p)}}p-value from one- or two-sample Kolmogorov-Smirnov test for continuous variable {it:varname}, corrected or exact{p_end}
{synopt:{cmd:r({it:varname}_D)}}combined D from one- or two-sample Kolmogorov-Smirnov test for continuous variable {it:varname}{p_end}

{pstd}
For binary variables, population sampling:

{synopt:{cmd:r({it:varname}_p)}}p-value from Chi-square or Fisher's exact test for binary or categorical variable {it:varname}{p_end}
{synopt:{cmd:r({it:varname}_chi2)}}chi-square test statistic for binary or categorical variable {it:varname} (not reported under exact test){p_end}

{pstd}
For binary variables, theoretical sampling:

{synopt:{cmd:r({it:varname}_p)}}p-value from one-sample test of proportions or exact binomial probability test for binary variable {it:varname}{p_end}
{synopt:{cmd:r({it:varname}_z)}}z statistic for binary variable {it:varname} (not reported under exact test){p_end}


{title:Authors}

{p 4 4 2}
Evangelos Kontopantelis, Centre for Biostatistics,

{p 29 4 2}
University of Manchester, e.kontopantelis@manchester.ac.uk


{title:Please cite as}

{phang}
Kontopantelis, E. 2013.
{it:A Greedy Algorithm for Representative Sampling: repsample in Stata}.
Journal of Statistical Software, Vol 55, CS1.
{browse "http://www.jstatsoft.org/v55/c01":http://www.jstatsoft.org/v55/c01}


{title:Also see}

{p 4 4 2}
help for {help ksmirnov}, {help tabulate twoway}, {help prtest}, {help bitest}

