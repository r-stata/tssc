{smcl}
{hline}
help for {cmd:metaparm} and {cmd:parmcip} {right:(Roger Newson)}
{hline}


{title:Meta-analysis and calculating confidence intervals using {helpb parmest}-format resultssets}

{p 8 21 2}
{cmd:parmcip} {ifin} [ {cmd:,} {it:{help metaparm##parmcip_opts:parmcip_opts}} ]

{p 8 21 2}
{cmd:metaparm} {weight} {ifin} [ {cmd:,}
{it:{help metaparm##metaparm_outdest_opts:metaparm_outdest_opts}}
{it:{help metaparm##metaparm_content_opts:metaparm_content_opts}}
{it:{help metaparm##parmcip_opts:parmcip_opts}}
]

{pstd}
{cmd:aweight}s and {cmd:iweight}s are allowed with {cmd:metaparm}.
See help for {help weights}.

{pstd}
{cmd:by} {varlist}{cmd::} can be used with {cmd:parmcip} and {cmd:metaparm}.
(See help for {helpb by}.)
However, if {cmd:by} {varlist}{cmd::} is used with {cmd:metaparm},
then a {cmd:by()} option must also be present,
and must start with the variables in the {cmd:by} {varlist}{cmd::} prefix.


{title:Description}

{pstd}
{cmd:metaparm} and {cmd:parmcip} are resultsset-processing programs
designed for use with {helpb parmest} and {helpb parmby} resultssets,
which have one observation per estimated parameter and data on parameter estimates.
(See Newson (2010), Newson (2008), Newson (2006), Newson (2004), Newson (2003) and Newson (2002).)
{cmd:metaparm} inputs a dataset in memory with one observation per parameter and variables containing
estimates, standard errors and (optionally) degrees of freedom, and creates an output dataset with one observation,
or one observation per by-group, and data on estimates, standard errors,
{it:z}- or {it:t}-statistics, {it:P}-values and confidence limits
for a linear combination (weighted sum) of the input parameters,
assuming that the input parameters are estimated independently (or at least are uncorrelated) for different sub-populations.
The output dataset can be listed to the Stata log, saved to a new data frame, saved to a disk file,
or written to the current data frame, overwriting the existing dataset.
{cmd:metaparm} is useful for meta-analyses (where {help weight:aweights} are used),
and can also be used with {help weight:iweights} for calculating confidence intervals
and {it:P}-values for differences or ratios between parameters for different subpopulations.
{cmd:parmcip} inputs a dataset in memory with one observation per parameter
and variables containing parameter estimates, standard errors and (optionally) degrees of freedom,
and adds new variables to the dataset, containing the confidence limits, {it:z}- or {it:t}-statistics,
{it:P}-values, and (optionally) stars for {it:P}-values.
{cmd:parmcip} is useful if the user requires confidence intervals for a Normalizing
and/or variance-stabilizing transformation of the original parameters.
{cmd:metaparm} works by calling {cmd:parmcip}, and therefore should not be downloaded without {cmd:parmcip}.


{title:Output datasets created by {cmd:metaparm} and {cmd:parmcip}}

{pstd}
These output datasets (or resultssets) are described in detail in {it:{help metaparm_resultssets}}.


{title:Options for {cmd:metaparm} and {cmd:parmcip}}

{pstd}
{cmd:metaparm} and {cmd:parmcip} have a large number of options, which fall into the following 3 groups:

{p2colset 4 26 28 2}{...}
{p2col:Option group}Description{p_end}
{p2line}
{p2col:{it:{help metaparm##metaparm_outdest_opts:metaparm_outdest_opts}}}Output-destination options for {cmd:metaparm}{p_end}
{p2col:{it:{help metaparm##metaparm_content_opts:metaparm_content_opts}}}Output-content options for {cmd:metaparm}{p_end}
{p2col:{it:{help metaparm##parmcip_opts:parmcip_opts}}}Options for {cmd:metaparm} and {cmd:parmcip}{p_end}
{p2line}
{p2colreset}


{marker metaparm_outdest_opts}{...}
{title:Output-destination options for {cmd:metaparm}}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt li:st(list_spec)}}List output dataset to Stata log and/or Results window{p_end}
{synopt:{cmdab:fra:me}{cmd:(}{it:framename}[,replace {cmdab:cha:nge}]{cmd:)}}Save output dataset to a data frame{p_end}
{synopt:{cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}}Save output dataset to a disk file{p_end}
{synopt:{cmdab::no}{cmdab:re:store}}Write output dataset to memory{p_end}
{synopt:{opt fast}}Write output dataset to memory without precautions{p_end}
{synopt:{opt fl:ist(global_macro_name)}}Append output filename to a global macro{p_end}
{synoptline}

{pstd}
where {it:list_spec} is a specification of the form

{pstd}
[{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ]

{pstd}
and {help list:{it:list_options}} is a list of options used by the {helpb list} command.

{pstd}
See {it:{help metaparm_outdest_opts}} for details of these options.


{marker metaparm_content_opts}{...}
{title:Output-content options for {cmd:metaparm}}

{synoptset 28}
{synopthdr}
{synoptline}
{synopt:{cmd:by(}{varlist}{cmd:)}}Variables specifying by-groups{p_end}
{synopt:{cmdab:su:mvar}{cmd:(}{varlist}{cmd:)}}Variables to be summed in output dataset{p_end}
{synopt:{opt dfc:ombine(combination_rule)}}Rule for combining degrees of freedom{p_end}
{synopt:{opt idn:um(#)}}Value of numeric dataset ID variable{p_end}
{synopt:{cmdab:nidn:um}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of numeric dataset ID variable{p_end}
{synopt:{opt ids:tr(string)}}Value of string dataset ID variable{p_end}
{synopt:{cmdab:nids:tr}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of string dataset ID variable{p_end}
{synopt:{opt fo:rmat(formatting_list)}}Display formats for variables in the output dataset{p_end}
{synoptline}

{pstd}
where {it:combination_rule} is

{pstd}
{cmdab:s:atterthwaite} | {cmdab:w:elch} | {cmdab:c:onstant}

{pstd}
and {it:formatting_list} is a list of form

{pstd}
{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}

{pstd}
See {it:{help metaparm_content_opts}} for details of these options.


{marker parmcip_opts}{...}
{title:Options for {cmd:metaparm} and {cmd:parmcip}}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{cmdab::no}{cmdab:td:ist}}Use Normal or {it:t}-distribution{p_end}
{synopt:{opt ef:orm}}Estimates and confidence limits exponentiated{p_end}
{synopt:{opt float}}Numeric output variables of type {cmd:float} or less{p_end}
{synopt:{cmdab::no}{cmdab:ze:rop}}Reset zero {it:P}-values to smallest positive double-precision number{p_end}
{synopt:{opt nu:llvalue(#)}}Value of estimated parameters under null hypotheses{p_end}
{synopt:{opt fast}}Calculate confidence limits without precautions{p_end}
{synopt:{cmdab:est:imate}{cmd:(}{it:{help varname}}{cmd:)}}Name of input estimate variable{p_end}
{synopt:{cmdab:std:err}{cmd:(}{it:{help varname}}{cmd:)}}Name of input standard error variable{p_end}
{synopt:{cmdab:d:of}{cmd:(}{it:{help varname}}{cmd:)}}Name of input degrees of freedom variable{p_end}
{synopt:{cmdab:z:stat}{cmd:(}{it:{help newvar:newvarname}}{cmd:)}}Name of output {it:z}-statistic variable{p_end}
{synopt:{cmdab:t:stat}{cmd:(}{it:{help newvar:newvarname}}{cmd:)}}Name of output {it:t}-statistic variable{p_end}
{synopt:{cmdab:p:value}{cmd:(}{it:{help newvar:newvarname}}{cmd:)}}Name of output {it:P}-value variable{p_end}
{synopt:{cmdab:sta:rs}{cmd:(}{it:{help numlist}}{cmd:)}}List of {it:P}-value thresholds for stars{p_end}
{synopt:{cmdab:nsta:rs}{cmd:(}{it:{help newvar:newvarname}}{cmd:)}}Name of output stars variable{p_end}
{synopt:{cmdab:le:vel}{cmd:(}{it:{help numlist}}{cmd:)}}Confidence level(s) for calculating confidence limits{p_end}
{synopt:{cmdab:cln:umber}{cmd:(}{it:numbering_rule}{cmd:)}}Numbering rule for naming confidence limit variables{p_end}
{synopt:{cmdab:minp:refix}{cmd:(}{it:prefix}{cmd:)}}Prefix for lower confidence limits{p_end}
{synopt:{cmdab:maxp:refix}{cmd:(}{it:prefix}{cmd:)}}Prefix for upper confidence limits{p_end}
{synopt:{cmdab:mcomp:are}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method{p_end}
{synopt:{cmdab:mcomc:i}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method for confidence limits only{p_end}
{synopt:{opt replace}}Replace variables with same names as output variables{p_end}
{synoptline}

{pstd}
where {it:numbering_rule} is

{pstd}
{cmd:level} | {cmd:rank}

{pstd}
and {it:method} is

{pstd}
{cmdab:noadj:ust} | {cmdab:bonf:erroni} | {cmdab:sid:ak}

{pstd}
See {it:{help parmcip_opts}} for details of these options.


{title:Methods and formulas}

{pstd}
{cmd:metaparm} generates an output dataset with one observation, or one observation per by-group,
and data on estimates, standard errors and degrees of freedom
for linear combinations (weighted sums) of parameters,
and then uses {cmd:parmcip} to derive the {it:t}- or {it:z}-statistics, {it:P}-values and confidence limits.
The exact method used to calculate the estimates, standard errors and degrees of freedom
depends on whether the {helpb parmcip_opts:tdist} option is used,
and on whether {help weight:aweights} or {help weight:iweights} are specified.
In general, it is assumed that, in the input dataset (or in a by-group of the input dataset),
there are {hi:N} observations, corresponding to parameters {hi:theta_1, ..., theta_N},
with corresponding standard errors {hi:se_1, ..., se_N},
corresponding coefficients {hi:a_1, ..., a_N},
and corresponding degrees of freedon {hi:df_1, ..., df_N} if the {helpb parmcip_opts:tdist} option is used.
We wish to calculate an estimate
for the linear combination 

{pstd}
{hi:Theta = Sum ( a_j * theta_j )}

{pstd}
and a corresponding standard error

{pstd}
{hi:SE = sqrt( Sum (a_j * se_j)^2} )

{pstd}
and degrees of freedom (if {helpb parmcip_opts:tdist} is specified) calculated 
from the {hi:df_j} and the {hi:se_j}.
The calculation of the degrees of freedom uses
the Satterthwaite formula (Satterthwaite, 1946) if {helpb metaparm_content_opts:dfcombine(satterthwaite)} is specified,
or the Welch formula (Welch, 1947) if {helpb metaparm_content_opts:dfcombine(welch)} is specified.
If {helpb metaparm_content_opts:dfcombine(constant)} is specified.
then {cmd:metaparm} checks that the input degrees of freedom {hi:df_j} are all equal,
and then sets the output degrees of freedom to the input degrees of freedom.
The definition of the {cmd:a_j} depends on whether
{help weight:iweights} or {help weight:aweights} are specified. If {help weight:iweights} are specified,
then the {hi:a_j} are given by the result of the {help weight:weight expression},
which may be positive, zero or negative.
If {help weight:aweights} are specified, then the result of the {help weight:weight expression}
must be non-negative, and is divided by its total within the input dataset or by-group to give the {hi:a_j}.
If no weights are specified, then {help weight:aweights} are assumed, and are set to 1,
so that the {cmd:a_j} are equal to {hi:1/N}, and their sum in the dataset or by-group is equal to 1.
{help weight:aweights} are typically specified if the user wishes to carry out a meta-analysis,
whereas {help weight:iweights} are typically specified if the user wishes to estimate a difference
between two parameters {hi:theta_1} and {hi:theta_2} in each by-group.

{pstd}
To perform meta-analyses,
{cmd: metaparm} should usually be used together with the {helpb parmhet} package,
which can also be downloaded from {help ssc:SSC},
and which calculates heterogeneity test statistics,
and also inverse-variance weights for input to {cmd:metaparm}.


{title:Remarks}

{pstd}
More information about {helpb parmest} and {helpb parmby} resultssets
can be found in Newson (2010), Newson (2008),  Newson (2006), Newson (2004), Newson (2003) and Newson (2002).

{pstd}
Other programs are available in the Stata community for carrying out meta-analyses,
including {helpb metan},
written by Stephen Sharp and Jonathan Sterne and downloadable from {help ssc:SSC}.
(See {manhelp meta R} for details.)
{cmd:metaparm} is complementary to these, and is designed specifically for use with {helpb parmest} resultssets,
and with the {help ssc:SSC} package {helpb parmhet}.
Note, however, that the input resultsset does not have to be produced by {helpb parmest}.
It need only contain an estimate variable, a standard error variable, and a degrees of freedom variable
(if {cmd:tdist} is specified).
Linear combinations of parameters for the same model can be estimated
using the official Stata command {helpb lincom}, or by the {helpb lincomest} package,
downloadable from {help ssc:SSC}.
{cmd:metaparm} is complementary to these, and is designed for use when parameters are estimated 
by sampling independently from distinct subpopulations.

{pstd}
{cmd:parmcip} may be used for defining additional confidence limits in a {helpb parmest} resultsset,
with different {help level:confidence levels} from those originally calculated by {helpb parmby}
or {helpb parmest}. However, {cmd:parmcip} is also useful for calculating confidence limits for
transformed parameters, using standard errors calculated using the
{browse "http://www.stata.com/support/faqs/stat/deltam.html":delta method}.

{pstd}
The confidence limits calculated by {cmd:metaparm} or {cmd:parmcip} can be plotted
using the {helpb eclplot} command, which is downloadable from {help ssc:SSC},
and which can be used to calculate Cochrane forest plots for meta-analyses.


{title:Examples}

{p 16 20}{inp:. metaparm, list(,)}{p_end}

{p 16 20}{inp:. metaparm [awei=studynum], sumvar(studynum) list(,)}{p_end}

{p 16 20}{inp:. parmcip}{p_end}

{p 16 20}{inp:. parmcip, replace}{p_end}

{pstd}
The following example uses the {hi:auto} data. A variable {hi:mod4} is defined, equal to 0, 1, 2 or 3 for approximately equal numbers of cars.
We then use {helpb parmby} to fit a regression model, comparing mileage in non-American and American cars, for cars with each value of {hi:mod4},
and to store the parameters in a {helpb parmby} resultsset in memory, which is listed.
Finally, we carry out a meta-analysis on the differences between the non-American and American cars in the 4 {hi:mod4} groups,
weighting the differences by numbers of cars to produce a weighted mean difference, which is listed,
together with its 95% confidence limits and {it:P}-value.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. gene byte mod4=mod(_n,4)}{p_end}
{p 16 20}{inp:. parmby "regress mpg foreign", by(mod4) norestore escal(N) rename(es_1 N) format(estimate min* max* %8.2f p %-8.2g)}{p_end}
{p 16 20}{inp:. bysort mod4 (N parmseq): list}{p_end}
{p 16 20}{inp:. metaparm [awei=N] if parm=="foreign", sumvar(N) list(,)}{p_end}

{pstd}
The following example uses the {hi:auto} data. A variable {hi:odd} is defined, equal to 0 for even-numbered cars
and 1 for odd-numbered cars in the order in the dataset. We then demonstrate that {cmd:metaparm} (with {help weight:iweights})
produces the same results as {helpb ttest} with the {cmd:unequal} option when comparing the weights of American and non-American cars
within the odd-numbered and even-numbered categories. {cmd:metaparm} has the advantage that it can store the confidence intervals in a resultsset
on disk or memory, which can later be plotted using {helpb eclplot}, although this is not done here.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. gene byte odd=mod(_n,2)}{p_end}
{p 16 20}{inp:. bysort odd: ttest weight, by(foreign) unequal}{p_end}
{p 16 20}{inp:. parmby "regress weight", by(odd foreign) norestore format(estimate min* max* %8.2f p %-8.2g)}{p_end}
{p 16 20}{inp:. list}{p_end}
{p 16 20}{inp:. metaparm [iwei=!foreign-foreign], by(odd) norestore}{p_end}
{p 16 20}{inp:. list odd estimate min* max* p dof}{p_end}

{pstd}
The following example uses the {hi:auto} data to demonstrate the use of {cmd:metaparm},
with the option {helpb metaparm_content_opts:dfcombine(constant)}, to carry out an equal-variance {help ttest:{it:t}-test}
between weights of US and non-US cars.
This is done using a {helpb parmby} output dataset,
in which the command {helpb factext} (downloadable from {help ssc:SSC}) has been used
to reconstruct the variable {hi:foreign}.
Again, the use of {cmd:metaparm} allows the user to save confidence intervals to be plotted and/or tabulated,
although this is not done here.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. ttest weight, by(foreign)}{p_end}
{p 16 20}{inp:. parmby "xi, noomit: regress weight i.foreign, noconst", norestore label format(estimate min* max* %8.2f p %-8.2g)}{p_end}
{p 16 20}{inp:. factext}{p_end}
{p 16 20}{inp:. list}{p_end}
{p 16 20}{inp:. metaparm [iwei=!foreign-foreign], dfcombine(constant) list(,)}{p_end}

{pstd}
The following example uses the {helpb svyset} and {helpb svy tabulate twoway:svy: tabulate} commands,
and the {help ssc:SSC} package {helpb xcontract}, in the {hi:auto} data
to demonstrate the use of {cmd:parmcip} for calculating transformed confidence intervals.
It uses {helpb xcontract} to calculate counts and proportions and save them to a file on disk,
uses {helpb svy tabulate twoway:svy: tabulate}
to calculate confidence intervals for the proportions of cars with each combination of
the values of the variables {hi:rep78} and {hi:foreign},
and uses {helpb parmest}
to save the estimates and standard errors of these proportions in a resultsset in memory.
We then replace the estimates and standard errors of the proportions
with the estimates and standard errors of the corresponding logged odds,
drop the existing {it:t}-statistics, {it:P}-values and confidence limits,
use {cmd:parmcip} to calculate {it:t}-statistics, {it:P}-values and confidence limits for the logged odds,
and then calculate new estimates and confidence limits for the proportions by
back-transforming the estimates and confidence limits for the logged odds.
These confidence limits are listed,
and are identical to those displayed by {helpb svy tabulate twoway:svy: tabulate},
but have the advantage that they may then be plotted using {helpb eclplot},
or listed using {help format:formats} chosen by the user.
(This is an example of the
{browse "http://www.stata.com/support/faqs/stat/deltam.html":delta method}.
See {hi:[SVY] svy: tabulate twoway} for details of the formulas.)

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tempfile tf1}{p_end}
{p 16 20}{inp:. xcontract rep78 foreign, zero saving(`"`tf1'"', replace)}{p_end}
{p 16 20}{inp:. gene byte pwt=1}{p_end}
{p 16 20}{inp:. version 8: svyset [pweight=pwt]}{p_end}
{p 16 20}{inp:. svy: tabulate rep78 foreign, ci}{p_end}
{p 16 20}{inp:. parmest, norestore}{p_end}
{p 16 20}{inp:. list}{p_end}
{p 16 20}{inp:. replace stderr=stderr/(estimate*(1-estimate))}{p_end}
{p 16 20}{inp:. replace estimate=log(estimate/(1-estimate))}{p_end}
{p 16 20}{inp:. drop t p min* max*}{p_end}
{p 16 20}{inp:. parmcip}{p_end}
{p 16 20}{inp:. gene estimate_2=exp(estimate)/(1+exp(estimate))}{p_end}
{p 16 20}{inp:. gene min95_2=exp(min95)/(1+exp(min95))}{p_end}
{p 16 20}{inp:. gene max95_2=exp(max95)/(1+exp(max95))}{p_end}
{p 16 20}{inp:.merge using `"`tf1'"'}{p_end}
{p 16 20}{inp:. sort rep78 foreign}{p_end}
{p 16 20}{inp:. list rep78 foreign _freq estimate_2 min95_2 max95_2, sepby(rep78)}{p_end}


{title:Acknowledgements}

{pstd}
I would like to thank Jill Starkes and Lee Sieswerda of Thunder Bay District Health Unit for drawing my attention
to the example of the delta method used to calculate the confidence intervals
displayed by {helpb svy tabulate twoway:svy: tabulate}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

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
Download from
{browse "http://www.stata-journal.com/article.html?article=st0043":the {it:Stata Journal} website}.

{phang}
Newson, R.  2002.  Creating plots and tables of estimation results using {cmd:parmest} and friends.
Presented at {browse "http://ideas.repec.org/s/boc/usug02.html" :the 8th United Kingdom Stata Users' Group Meeting, 20-21 May, 2002}.

{phang}
Satterthwaite, F. E.  1946.  An approximate distribution of estimates of variance components.
{it:Biometrics Bulletin} 2(6): 110-114.

{phang}
Welch, B. L. 1947. The generalization of `Student's' problem when several different population variances are involved.
{it:Biometrika} 34(1/2): 28-35.


{title:Also see}

{psee}
Manual:  {findalias frestimate},{break}
{manlink I estimation commands},{break}
{manlink D append}, {manlink R lincom}, {manlink R meta}, {manlink SVY svyset},
{bf:{mansection SVY svytabulateoneway:[SVY] svy{c 58} tabulate oneway}}, {bf:{mansection SVY svytabulatetwoway:[SVY] svy{c 58} tabulate twoway}}.
{p_end}

{psee}
{space 2}Help:  {manhelp postest U:20 Estimation and postestimation commands},{break}
{manhelp estimation_commands I:estimation commands},{break}
{manhelp append D}, {manhelp lincom R}, {manhelp meta R}, {manhelp svyset SVY},
{manhelp svy_tabulate_oneway SVY:svy{c 58} tabulate oneway}, {manhelp svy_tabulate_twoway SVY:svy{c 58} tabulate twoway}{break}
{helpb parmest}, {helpb parmby},
{help metaparm_outdest_opts:{it:metaparm_outdest_opts}}, {help metaparm_content_opts:{it:metaparm_content_opts}},
{it:{help parmcip_opts}}, {it:{help metaparm_resultssets}}, {help parmest_resultssets:{it:parmest_resultssets}}{break}
{helpb meta}, {helpb eclplot}, {helpb factext}, {helpb lincomest}, {helpb parmhet}, {helpb qqvalue}, {helpb xcontract} if installed
{p_end}
