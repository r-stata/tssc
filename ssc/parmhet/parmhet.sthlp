{smcl}
{hline}
help for {cmd:parmhet} and {cmd:parmiv} {right:(Roger Newson)}
{hline}


{title:Heterogeneity tests and inverse-variance weights in {helpb parmest} resultssets}

{p 8 21 2}
{cmd:parmhet} {help varname:{it:est_varname}} {help varname:{it:se_varname}} [  {help varname:{it:dof_varname}} ] 
{ifin} [ {cmd:,}
{it:{help parmhet##basic_opts:basic_opts}}
{it:{help parmhet##resultsset_opts:resultsset_opts}}
{it:{help parmhet##hettest_opts:hettest_opts}}
]

{p 8 21 2}
{cmd:parmiv} {help varname:{it:est_varname}} {help varname:{it:se_varname}} [  {help varname:{it:dof_varname}} ]
{ifin} [ {cmd:,} {it:{help parmhet##basic_opts:basic_opts}} {it:{help parmhet##hettest_opts:hettest_opts}} ]


{title:Description}

{pstd}
{cmd:parmhet} and {cmd:parmiv} are designed for use with {helpb parmest} resultssets,
which have one observation per estimated parameter and data on parameter estimates.
{cmd:parmhet} inputs variables containing parameter estimates, standard errors and (optionally) degrees of freedom,
and outputs an output dataset (or resultsset) with one observation,
or one observation per by-group,
and data on heterogeneity test statistics on the input parameters
in the dataset or by-group.
The output dataset can be listed to the Stata log, saved to a disk file,
or written to memory, overwriting the existing dataset.
Optionally, {cmd:parmhet} may also add variables to the existing dataset,
containing inverse-variance weights and/or semi-weights and/or semi-weight-based standard errors.
These additional variables may then be input to the {helpb metaparm} module of the {helpb parmest} package,
to produce summary meta-analysed parameter estimates,
using the fixed-effect method or the DerSimonian-Laird randomly-variable-effect method.
{cmd:parmiv} is a routine intended for use by programmers,
and inputs variables containing estimates, standard errors and (optionally) degrees of freedom,
and outputs additional variables in the existing dataset,
containing inverse-variance weights and/or semi-weights and/or semi-weight-based standard errors
and/or heterogeneity test statistics for the dataset or by-group.


{title:Options}

{pstd}
{cmd:parmhet} and {cmd:parmiv} have a large number of options, which fall into the following 3 groups:

{p2colset 4 26 28 2}{...}
{p2col:Option group}Description{p_end}
{p2line}
{p2col:{it:{help parmhet##basic_opts:basic_opts}}}Basic options for {cmd:parmhet} and {cmd:parmiv}{p_end}
{p2col:{it:{help parmhet##resultsset_opts:resultsset_opts}}}Resultsset options for {cmd:parmhet}{p_end}
{p2col:{it:{help parmhet##hettest_opts:hettest_opts}}}Heterogeneity-test options for {cmd:parmhet} and {cmd:parmiv}{p_end}
{p2line}
{p2colreset}


{marker basic_opts}{...}
{title:Basic options for {cmd:parmhet} and {cmd:parmiv}}

{synoptset 28}
{synopthdr}
{synoptline}
{synopt:{cmd:by(}{varlist}{cmd:)}}Variables specifying by-groups{p_end}
{synopt:{opt ef:orm}}Estimates and confidence limits exponentiated{p_end}
{synopt:{opt float}}Numeric output variables of type {cmd:float} or less{p_end}
{synopt:{opt dfc:ombine(combination_rule)}}Rule for combining degrees of freedom{p_end}
{synopt:{opt ivw:eight}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of generated inverse-variance weight variable{p_end}
{synopt:{opt sw:eight}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of generated semi-weight variable{p_end}
{synopt:{opt sst:derr}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of generated semi-weight-based standard error variable{p_end}
{synoptline}

{pstd}
where {it:combination_rule} is

{pstd}
{cmd:welch} | {cmd:constant}

{pstd}
See {it:{help parmhet_basic_opts}} for details of these options.


{marker resultsset_opts}{...}
{title:Resultsset options for {cmd:parmhet}}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt li:st(list_spec)}}List output dataset to Stata log and/or Results window{p_end}
{synopt:{cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}}Save output dataset to a disk file{p_end}
{synopt:{cmdab::no}{cmdab:re:store}}Write output dataset to memory{p_end}
{synopt:{opt fast}}Write output dataset to memory without precautions{p_end}
{synopt:{opt fl:ist(global_macro_name)}}Append output filename to a global macro{p_end}
{synopt:{opt idn:um(#)}}Value of numeric dataset ID variable{p_end}
{synopt:{cmdab:nidn:um}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of numeric dataset ID variable{p_end}
{synopt:{opt ids:tr(string)}}Value of string dataset ID variable{p_end}
{synopt:{cmdab:nids:tr}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of string dataset ID variable{p_end}
{synopt:{cmdab:su:mvar}{cmd:(}{varlist}{cmd:)}}Variables to be summed in the output dataset{p_end}
{synopt:{opt fo:rmat(formatting_list)}}Display formats for variables in the output dataset{p_end}
{synopt:{cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}}Variables to be kept in the output dataset{p_end}
{synoptline}

{pstd}
where {it:formatting_list} is a list of form

{pstd}
{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}

{pstd}
and {it:list_spec} is a specification of the form

{pstd}
[{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ]

{pstd}
and {help list:{it:list_options}} is a list of options used by the {helpb list} command.

{pstd}
See {it:{help parmhet_resultsset_opts}} for details of these options.


{marker hettest_opts}{...}
{title:Heterogeneity-test options for {cmd:parmhet} and {cmd:parmiv}}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{opt chi:2het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity chi-squared statistic variable{p_end}
{synopt:{opt df:het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity degrees of freedom variable{p_end}
{synopt:{opt i:2het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity {it:I}-squared statistic variable{p_end}
{synopt:{opt tau:2het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity tau-squared statistic variable{p_end}
{synopt:{opt f:het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity {it:F}-statistic variable{p_end}
{synopt:{opt res:dfhet}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity residual degrees of freedom variable{p_end}
{synopt:{opt p:het}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Heterogeneity {it:P}-value variable{p_end}
{synoptline}

{pstd}
See {it:{help parmhet_hettest_opts}} for details of these options.


{title:Output dataset created by {cmd:parmhet}}

{pstd}
This output dataset (or resultsset) is described in detail in {it:{help parmhet_resultsset}}.


{title:Methods and formulas}

{pstd}
{cmd:parmhet} and {cmd:parmiv} use formulas introduced by Cochran (1954) and Welch (1951),
and later extended by DerSimonian and Laird (1986)
and by Higgins and Thompson (2002).
In general, it is assumed that, in the input dataset (or in a by-group of the input dataset),
there are {hi:N} observations, corresponding to parameters {hi:theta_1, ..., theta_N},
with corresponding standard errors {hi:se_1, ..., se_N},
and corresponding degrees of freedon {hi:df_1, ..., df_N}
if a degrees of freedom variable is specified.
The parameters {hi:theta_j} and the standard errors {hi:se_j}
are given by the input variables specified by {help varname:{it:est_varname}} and {help varname:{it:se_varname}},
unless the {cmd:eform} option is specified,
in which case the {hi:theta_j} are the logs of the values of {help varname:{it:est_varname}},
and the {hi:se_j} are the standard errors of these logs.
We assume that the {hi:theta_j} were sampled independently,
or at least in an uncorrelated way,
from {hi:N} respective sub-populations.

{pstd}
The inverse-variance weights, output in the {cmd:ivweight()} variable,
are defined by the formula

{pstd}
{hi:ivweight_j = (se_j)^(-2)}

{pstd}
for each {hi:j} from 1 to {hi:N}. The inverse-variance-weighted mean parameter value is

{pstd}
{hi:Theta = Sum ( iwweight_j * theta_j ) / Sum (ivweight_j)}

{pstd}
where {hi:Sum()} is the sum for {hi:j} from 1 to {hi:N}.
{hi:Theta} can be used as an estimate for a common sub-population mean parameter value,
assuming that there is no heterogeneity between sub-populations.
This estimate, with a standard error, confidence limits and a {it:P}-value,
can be calculated by inputting the estimates, standard errors and (optionally) degrees of freedom
to the {helpb metaparm} option of the {helpb parmest} package,
with {help weight:aweights} equal to the {cmd:ivweight()} variable.

{pstd}
The heterogeneity chi-squared statistic is defined by

{pstd}
{hi:Q = Sum ( ivweight_j * (theta_j - Theta)^2 ) }

{pstd}
Under the null hypothesis of no heterogeneity,
{hi:Q} is sampled from a distribution approximating to a chi-squared distribution
with {hi:N-1} degrees of freedom.
The I-squared statistic of Higgins and Thompson (2002) is equal to

{pstd}
{hi:I^2 = 100*max( 0 , (Q-N+1)/Q )}

{pstd}
and is equal to zero if the heterogeneity chi-squared statistic
is no more than its mean of {hi:N-1} under the null hypothesis of no heterogeneity,
and otherwise measures the percent relative excess of heterogeneity,
compared to this null mean.
And the tau-squared statistic of Higgins and Thompson (2002)
is given by

{pstd}
{hi:tau^2 = max( 0 , (Q-N+1)/( Sum(ivweight_j) - (Sum((ivweight_j)^2))/(Sum(ivweight_j)) ) )}

{pstd}
and estimates the sampling variance of the true sub-population values of the {hi:theta_j}
in the meta-population from which their respective sub-populations were sampled.
It is expressed in squared {hi:theta_j} units.

{pstd}
The sampling variance of each {hi:theta_j},
in the two-stage sampling process where the {hi:j}th sub-population is sampled from the meta-population
and the {hi:theta_j} is sampled from the {hi:j}th subpopulation,
can be estimated by {hi:(se_j)^2 + tau^2}.
It follows that the two-stage sampling standard error of {hi:theta_j},
output in the {cmd:sstderr()} variable,
is equal to

{pstd}
{hi:sstderr_j = sqrt((se_j)^2 + tau^2)}

{pstd}
and the two-stage inverse-variance weights (or semi-weights),
output in the {cmd:sweight()} variable,
is equal to

{pstd}
{hi:sweight_j = ((se_j)^2 + tau^2)^{-1}}

{pstd}
These two-stage sampling standard errors and two-stage inverse-variance weights can then be input
to the {helpb metaparm} module of the {helpb parmest} package,
to produce an estimate, a standard error, confidence limits, and a {it:P}-value
for the common meta-population mean of the {hi:theta_j}.
The {cmd:sstderr()} variable generated by {cmd:parmhet} or {cmd:parmiv}
is input to {helpb metaparm} as the {cmd:stderr()} option,
and the {cmd:sweight()} variable generated by {cmd:parmhet} or {cmd:parmiv}
is input to {helpb metaparm} as the {help weight:aweights}.
This computation implements the randomly-variable-effect method
of DerSimonian and Laird (1986).

{pstd}
An alternative to fixed-effect meta-analysis and randomly-variable-effect meta-analysis
is nonrandomly-variable-effect meta-analysis.
This can be implemented using {helpb metaparm}
by setting the {help weight:aweights} equal to the respective sample numbers
used in estimating the {hi:theta_j}.
The nonrandomly-variable-effect method
does not assume that the sub-population means of the {hi:theta_j} are equal
(as the fixed-effect method does),
and does not assume that we can estimate the meta-population variance
(as the randomly-variable-effect method does).
However, it does assume that the sample-size-weighted average of the sub-population effects
is a useful parameter to know,
even thought the sub-population effects may vary between sub-populations.
Whichever of the three methods we use,
our colleagues will usually expect a heterogeneity test to be done.

{pstd}
The {it:F}-test statistic,
computed if a degrees of freedom variable is supplied to {cmd:parmhet} or {cmd:parmiv},
is defined by a method specified by the {cmd:dfcombine()} option.
If the user specifies {cmd:dfcombine(welch)} (the default),
then the {it:F}-test statistic, and its denominator degrees of freedom,
are defined using the formulas of Welch (1951),
popularized by Cochran (1954).
If the user specifies {cmd:dfcombine(constant)},
then {cmd:parmhet} and {cmd:parmiv} check that the input degrees of freedom variable is constant,
or constant within by-groups if a {cmd:by()} option is specified,
and then defines the {it:F}-statistic as {hi:Q/(N-1)},
with {hi:N-1} numerator degrees of freedom,
and the denominator degrees of freedom given by the constant value
of the input degrees of freedom variable.
The option {cmd:dfcombine(constant)} is useful
if the input parameters are uncorrelated parameters of a single regression model,
and their standard errors are computed using an equal-variance formula,
and the degrees of freedom is pooled for all parameters in the model.


{title:Remarks}

{pstd}
{cmd:parmhet} and {cmd:parmiv} are designed for use with the {helpb parmest} package,
and particularly with the {helpb metaparm} module of that package.
More information about the production and use of {helpb parmest} resultssets
can be found in Newson (2010), Newson (2008),  Newson (2006), Newson (2004), Newson (2003) and Newson (2002).
{cmd:parmhet} can be used with {helpb parmest}, {helpb metaparm}, {helpb eclplot} and {helpb listtab}
to form a comprehensive system for meta-analyses and/or interaction analyses,
enabling the user to produce plots and/or tables of results.

{pstd}
Other programs are available in the Stata community for carrying out meta-analyses,
notably {helpb metan},
written by Michael J. Bradburn, Jonathan J. Deeks, Douglas G. Altman,
Ross J. Harris, Roger M. Harbord, and Jonathan A. C. Sterne.
(See {helpb meta} and {hi:[R] meta} for details.)
The combination of {cmd:parmhet}, {helpb parmest}, {helpb metaparm}, {helpb eclplot} and {helpb listtab}
is arguably even more flexible than {helpb metan},
at the price of having to know some Stata programming.

{pstd}
Other programs for heterogeneity tests on {helpb parmest} resultssets
are the {helpb estparm} and {helpb estparmtest} modules of the {helpb estparm} package.
These allow the user to carry out Wald heterogeneity tests,
comparing each other parameter estimate with the first parameter estimate.
The Cochran and Welch heterogeneity tests, by contrast,
weight the parameters inversely by variance,
and do not otherwise treat the first parameter differently from the others.
It is therefore expected that {cmd:parmhet} will supersede {helpb estparm} for most purposes.

{pstd}
The {helpb parmest}, {helpb eclplot}, {helpb listtab}, {helpb estparm} and {helpb metan} packages
can be downloaded from {help ssc:SSC}.


{title:Examples: Sequence 1}

{pstd}
The first example sequence uses the dataset {cmd:parmhet_example1},
which is distributed with the {cmd:parmhet} package as an ancillary file.
This dataset contains data from a meta-analysis of Glasziou {it:et al.} (1993),
distributed in Bland (2000),
and involving 5 clinical trials,
comparing death rates in subjects treated with vitamin A and untreated control subjects.
The dataset contains 1 observation per treatment group per trial,
and data on total numbers of subjects, and numbers of deaths,
in that treatment group in that trial,
and also data on the quantity (in international units or IU)
and frequency (per unit time)
of the vitamin A dosage applied to the treated group in that trial.
The set-up uses the {helpb parmby} module of the {helpb parmest} package,
downloadable from {help ssc:SSC},
to replace this dataset with a new dataset (or resultsset) in memory,
with 1 observation per trial,
and data on odds ratios of death with respect to vitamin A treatment,
with their confidence limits and {it:P}-values,
and also the total number of subjects in the trial (in variable {cmd:N}).

{pstd}
Set-up

{phang2}{inp:. use "http://www.imperial.ac.uk/nhli/r.newson/stata10/parmhet_example1.dta", clear}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. parmby "blogit deaths number vitamina, or", by(studyseq doseiu dosefreq) eform norestore escal(N) rename(es_1 N)}{p_end}
{phang2}{inp:. keep if parm=="vitamina"}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list studyseq doseiu dosefreq parm N estimate stderr min* max* p}{p_end}

{pstd}
Simple examples

{phang2}{inp:. parmhet estimate stderr, eform list(,)}{p_end}

{phang2}{inp:. parmhet estimate stderr, eform by(doseiu) list(, subvarname abbr(32))}{p_end}

{phang2}{inp:. parmhet estimate stderr, eform by(doseiu) saving(myhet1.dta, replace)}{p_end}

{pstd}
Note that,
if we do separate heterogeneity tests for different vitamin A doses using the option {cmd:by(doseiu)},
then dosage groups with only 1 study have zero heterogeneity chi-squared statistics,
zero heterogeneity degrees of freedom,
zero {it:I}-squared and tau-squared statistics,
and missing heterogeneity {it:P}-values.
Note, also, that the suboptions {cmd:subvarname abbr(32)} of the {cmd:list()} option
cause the heterogeneity test statistics to be listed with informative headings.
These are set by the {cmd:varname} {help char:characteristic},
set by {cmd:parmhet} and used by the {helpb list} command.

{pstd}
The following example uses the {cmd:norestore} option.
This replaces the resultssetset in memory, containing 1 observation per study,
with a new resultsset, containing 1 observation per vitamin A dosage group,
and data on heterogeneity test results:

{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmhet estimate stderr, eform by(doseiu) norestore}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list}{p_end}
{phang2}{inp:. restore}{p_end}

{pstd}
The following example uses {cmd:parmhet}
together with the {helpb metaparm} module of the {helpb parmest} package.
{cmd:parmhet} tests for heterogeneity,
and also adds to the existing dataset a new variable {cmd:ivwt},
containing inverse-variance weights for each study.
These are then used as {help weight:aweights} by {helpb metaparm}
to perform a fixed-effect meta-analysis,
estimating a common odds ratio for all studies,
and assuming that such a common odds ratio exists.

{phang2}{inp:. parmhet estimate stderr, eform list(,) ivweight(ivwt)}{p_end}
{phang2}{inp:. metaparm [aweight=ivwt], eform sumvar(N) list(,)}{p_end}

{pstd}
The following example uses {cmd:parmhet} with {helpb metaparm}
to perform a DerSimonian-Laird randomly-variable-effects meta-analysis
(DerSimonian and Laird, 1986).
This time, {cmd:parmhet} adds variables {cmd:semiwt} and {cmd:swse},
containing semi-weights and semi-weight-based standard errors, respectively.
These are passed to {helpb metaparm} as {help weight:aweights} and standard errors,
respectively.

{phang2}{inp:. parmhet estimate stderr, eform list(,) sweight(semiwt) sstderr(swse)}{p_end}
{phang2}{inp:. metaparm [aweight=semiwt], eform sumvar(N) stderr(swse) list(,)}{p_end}

{pstd}
The following example performs a nonrandomly-variable-effects analysis,
weighted by the study size variable {cmd:N}.

{phang2}{inp:. parmhet estimate stderr, eform sumvar(N) list(,)}{p_end}
{phang2}{inp:. metaparm [aweight=N], eform sumvar(N) list(,)}{p_end}

{pstd}
The following example carries out a nonrandomly-variable-effects meta-analysis,
saving the resultssets from {cmd:parmhet} and {helpb metaparm}
in disk-file datasets {cmd:myhet} and {cmd:mymeta}, respectively.
These resultssets are appended to the existing resultsset to produce an extended resultsset,
which is listed to show the study odds ratios, the weighted geometric mean (GM) odds ratio,
and {it:P}-values for the odds ratios and for the heterogeneity test.

{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. gene idstr="Single study"}{p_end}
{phang2}{inp:. order idstr}{p_end}
{phang2}{inp:. parmhet estimate stderr, eform sumvar(N) idstr(Heterogeneity) phet(p) keep(idstr N p) saving(myhet.dta, replace)}{p_end}
{phang2}{inp:. metaparm [aweight=N], eform sumvar(N) idstr("Weighted GM") saving(mymeta.dta, replace)}{p_end}
{phang2}{inp:. append using mymeta}{p_end}
{phang2}{inp:. append using myhet}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list idstr studyseq doseiu dosefreq N estimate min* max* p, sepby(idstr)}{p_end}
{phang2}{inp:. restore}{p_end}


{title:Examples: Sequence 2}

{pstd}
The following examples also use the dataset {cmd:parmhet_example1}.
However, this time, the {helpb parmby} module of {helpb parmest} is used
to produce a dataset of log odds ratios.
These are then tested for heterogeneity,
using {cmd:parmhet} without the {cmd:eform} option.

{pstd}
Set-up

{phang2}{inp:. use "http://www.imperial.ac.uk/nhli/r.newson/stata10/parmhet_example1.dta", clear}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. parmby "blogit deaths number vitamina", by(studyseq doseiu dosefreq) norestore escal(N) rename(es_1 N)}{p_end}
{phang2}{inp:. keep if parm=="vitamina"}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list studyseq doseiu dosefreq parm N estimate stderr min* max* p}{p_end}

{pstd}
Simple examples

{phang2}{inp:. parmhet estimate stderr, list(,)}{p_end}

{phang2}{inp:. parmhet estimate stderr, by(doseiu) list(,)}{p_end}


{title:Examples: Sequence 3}

{pstd}
The following example uses the {helpb datasets:auto} data, distributed with official Stata,
and adds a new variable {cmd:continent},
containing the continent of origin of a car model.
The {helpb parmby} module of {helpb parmest} is then used
to create a resultsset with 1 parameter per continent
and data on mean weights of cars (in US pounds),
with numbers of car models, estimates, standard errors, degrees of freedom, confidence limits,
and {it:P}-values.
This resultsset is then input to {cmd:parmhet}
to perform a Welch unequal-variance heterogeneity test (Welch, 1951),
which shows that mean car weights vary between continents.

{pstd}
Set-up

{phang2}{inp:. sysuse auto, clear}{p_end}
{phang2}{inp:. gene firm=word(make,1)}{p_end}
{phang2}{inp:. lab var firm "Firm"}{p_end}
{phang2}{inp:. lab def continent 1 "America" 2 "Asia" 3 "Europe"}{p_end}
{phang2}{inp:. gene continent=1 if !foreign}{p_end}
{phang2}{inp:. replace continent=2 if inlist(firm,"Datsun","Honda","Mazda","Subaru","Toyota")}{p_end}
{phang2}{inp:. replace continent=3 if inlist(firm,"Audi","BMW","VW","Fiat","Peugeot","Renault","Volvo")}{p_end}
{phang2}{inp:. lab val continent continent}{p_end}
{phang2}{inp:. lab var continent "Continent of origin"}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. tab firm continent, missing}{p_end}
{phang2}{inp:. parmby "mean weight", by(continent) norestore}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}

{pstd}
Examples

{phang2}{inp:. parmhet estimate stderr dof, list(,)}{p_end}

{phang2}{inp:. parmhet estimate stderr dof, list(, subvarname abbr(32))}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Bland, M.  2000.  {it:An introduction to medical statistics. 3rd ed.}
Oxford: Oxford University Press.

{phang}
Cochran, W. G.  1954.  The combination of estimates from different experiments.
{it:Biometrics} 10(1): 101-129.

{phang}
DerSimonian, R. and Laird, N.  1986.  Meta-analysis in clinical trials.
{it:Controlled Clinical Trials} 7(3): 177-188.

{phang}
Glasziou, P.P. and Mackerras, D. E. M.  1993.
Vitamin A supplementation in infectious disease: a meta–analysis.
{it:British Medical Journal} 306(6874): 366-370.

{phang}
Higgins, J. P. T. and Thompson, S. G.  2002.  Quantifying heterogeneity in a meta-analysis.
{it:Statistics in Medicine} 21(11): 1539-1558.

{phang}
Newson, R. B.  2010.  Post-{cmd:parmest} peripherals: {cmd:fvregen}, {cmd:invcise}, and {cmd:qqvalue}.
Presented at {browse "http://ideas.repec.org/s/boc/usug10.html" :the 16th United Kingdom Stata Users' Group Meeting, London, 9-10 September, 2010}.

{phang}
Newson, R. B.  2008.  {cmd:parmest} and extensions.
Presented at {browse "http://ideas.repec.org/s/boc/usug08.html" :the 14th United Kingdom Stata Users' Group Meeting, London, 8-9 September, 2008}.

{phang}
Newson, R.  2006.  Resultssets, resultsspreadsheets, and resultsplots in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/dsug06.html" :the 4th German Stata Users' Group Meeting, Mannheim, 31 March, 2006}.

{phang}
Newson, R.  2004.  From datasets to resultssets in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/usug04.html" :the 10th United Kingdom Stata Users' Group Meeting, London, 29-30 June, 2004}.

{phang}
Newson, R.  2003.  Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.
Download from {browse "http://www.stata-journal.com/article.html?article=st0043":{it:The Stata Journal} website}.

{phang}
Newson, R.  2002.  Creating plots and tables of estimation results using {cmd:parmest} and friends.
Presented at {browse "http://ideas.repec.org/s/boc/usug02.html" :the 8th United Kingdom Stata Users' Group Meeting, 20-21 May, 2002}.

{phang}
Welch, B. L.  1951.  On the comparison of several mean values: an alternative approach.
{it:Biometrika} 36(3/4): 330-336.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] meta}, {hi:[R] test}
{p_end}
{p 4 13 2}
On-line: help for {help parmhet_basic_opts:{it:parmhet_basic_opts}},
{help parmhet_resultsset_opts:{it:parmhet_resultsset_opts}},
{help parmhet_hettest_opts:{it:parmhet_hettest_opts}},
{help parmhet_resultsset:{it:parmhet_resultsset}}
{break} help for {helpb test}, {helpb list}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb eclplot}, {helpb listtab},
{helpb estparm}, {helpb metan} if installed
{p_end}
