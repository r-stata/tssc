{smcl}
{hline}
help for {cmd:qqvalue} {right:(Roger Newson)}
{hline}


{title:Generate frequentist {it:q}-values by inverting multiple-test procedures}

{p 8 15} {cmd:qqvalue} {varname} {ifin} [ ,
 {break}
 {cmdab:me:thod}{cmd:(}{it:method_name}{cmd:)} {cmdab:be:stof}{cmd:(}{it:#}{cmd:)}
 {break}
 {opth qv:alue(newvarname)}
 {opth np:value(newvarname)}
 {opth ra:nk(newvarname)}
 {opth sv:alue(newvarname)}
 {opth rv:alue(newvarname)}
 {break}
 {cmd:float} {cmd:fast} ]

{pstd}
where {it:method_name} is one of

{pstd}
{cmd:bonferroni} | {cmd:sidak} | {cmd:holm} | {cmd:holland} | {cmd:hochberg} | {cmd:simes} | {cmd:yekutieli}

{pstd}
{cmd:by} {varlist}{cmd::} can be used with {cmd:qqvalue}.
(See help for {helpb by}.)
If {cmd:by} {varlist}{cmd::} is used,
then all generated variables are calculated using the specified multiple-test procedure
within each by-group defined by the variables in the {varlist}.


{title:Description}

{pstd}
{cmd:qqvalue} is similar to the {browse "http://www.r-project.org/":R} package {cmd:p.adjust}.
It inputs a single variable, assumed to contain {it:P}-values calculated for multiple comparisons,
in a dataset with 1 observation per comparison.
It outputs a new variable,
containing the frequentist {it:q}-values corresponding to these {it:P}-values,
calculated by inverting a multiple-test procedure specified by the user.
These {it:q}-values represent, for each corresponding {it:P}-value,
the minimum uncorrected {it:P}-value threshold for which that {it:P}-value would be in the discovery set,
assuming that the specified multiple-test procedure was used on the same set of input {it:P}-values
to generate a corrected {it:P}-value threshold.
These minimum uncorrected {it:P}-value thresholds may represent familywise error rates or false discovery rates,
depending on the procedure used.
Optionally, {cmd:qqvalue} may output other variables,
containing the various intermediate results used in calculating the {it:q}-values.
The multiple-test procedures available for {cmd:qqvalue}
are a subset of those available using the {helpb multproc} module of the {helpb smileplot} package,
which can be downloaded from {help ssc:SSC}.


{title:Options for {cmd:qqvalue}}

{p 4 8 2}
{cmd:method(}{it:method_name}{cmd:)} specifies the multiple-test procedure method to be used
for calculating the {it:q}-values from the input {it:P}-values.
The {it:method_name} may be
{cmd:bonferroni}, {cmd:sidak}, {cmd:holm}, {cmd:holland}, {cmd:hochberg}, {cmd:simes}, or {cmd:yekutieli}.
These method names specify that the {it:q}-values will be calculated from the input {it:P}-values
by inverting the multiple-test procedure specified by the {cmd:method()} option of the same name
for the {helpb multproc} option of the {helpb smileplot} package,
which can be downloaded from {help ssc:SSC}.
If {cmd:method()} is unset, then it is set to {cmd:bonferroni}.

{p 4 8 2}
{cmd:bestof(}{it:#}{cmd:)} specifies an integer number.
If the {cmd:bestof()} option is specified (and is greater than the number of input {it:P}-values),
then the {it:q}-values are calculated
assuming that the input {it:P}-values are a subset (usually the smallest) of a superset of {it:P}-values.
If the {cmd:method()} option specifies a one-step method (such as {cmd:bonferroni} or {cmd:sidak}),
then the {it:q}-values do not depend on the other {it:P}-values in the superset,
but only on the number of {it:P}-values in the superset.
If the {cmd:method()} option specifies a  step-down method (such as {cmd:holm} or {cmd:holland}),
then it is assumed that all the other {it:P}-values in the superset
are greater than the largest of the input {it:P}-values.
If the {cmd:method()} option specifies a step-up method (such as {cmd:hochberg}, {cmd:simes}, or {cmd:yekutieli}),
then it is assumed that all the other {it:P}-values in the superset are equal to 1,
implying that the {it:q}-values will be conservative,
and define an upper bound to the respective {it:q}-values that would have been calculated,
if we knew the other {it:P}-values in the superset.
If {cmd:bestof()} is unspecified (or non-positive),
then the input {it:P}-values are assumed to be the full set of {it:P}-values calculated.
The {cmd:bestof()} option is useful if the input {it:P}-values are known (or suspected)
to be the smallest of a greater set of {it:P}-values,
which we do not know.
This often happens if the input {it:P}-values are from a genome scan reported in the literature.

{p 4 8 2}
{opth qvalue(newvarname)} specifies the name of a new output variable to be generated,
containing the {it:q}-values calculated from the input {it:P}-values,
using the multiple-test procedure specified by the {cmd:method()} option.

{p 4 8 2}
{opth npvalue(newvarname)} specifies the name of a new output variable to be generated,
containing, in each observation, the total number of {it:P}-values in the sample of observations specified by the {helpb if} and {helpb in} qualifiers,
or in the by-group containing that observation, if the {helpb by:by:} prefix is specified.

{p 4 8 2}
{opth rank(newvarname)} is the name of a new variable to be generated,
containing, in each observation,
the rank of the corresponding {it:P}-value, from the lowest to the highest.
Tied {it:P}-values are ranked according to their position in the input dataset.
If  the {helpb by:by:} prefix is specified,
then the ranks are defined within the by-group.

{p 4 8 2}
{opth svalue(newvarname)} specifies the name of a new output variable to be generated,
containing the {it:s}-values calculated from the input {it:P}-values.
The {it:s}-values are an intermediate result,
calculated in the course of calculating the {it:q}-values,
and are used mainly for validation.
They are calculated from the input {it:P}-values
by inverting the formulas used for the rank-specific critical {it:P}-value thresholds
calculated by the {helpb multproc} module of the {helpb smileplot} package.
These rank-specific {it:P}-value thresholds are returned in the generated variable
specified by the {cmd:critical()} option of {helpb multproc}.
Note that the {it:s}-values may have values greater than 1.

{p 4 8 2}
{opth rvalue(newvarname)} specifies the name of a new output variable to be generated,
containing the {it:r}-values calculated from the input {it:P}-values.
The {it:r}-values are an intermediate result,
calculated in the course of calculating the {it:q}-values,
and are used mainly for validation.
They are calculated from the {it:s}-values by truncating the {it:s}-values to a maximum of 1.
The {it:q}-values are calculated from the {it:r}-values
using a procedure dependent on the multiple-test procedure specified by the {cmd:method()} option.
If the multiple-test procedure is a one-step procedure,
such as {cmd:bonferroni} or {cmd:sidak},
then the {it:q}-values are equal to the corresponding {it:r}-values.
If the multiple-test procedure is a step-down procedure,
such as {cmd:holm} or {cmd:holland},
then the {it:q}-value for each {it:P}-value
is equal to the cumulative maximum of all the {it:r}-values
corresponding to {it:P}-values of rank equal to or less than that {it:P}-value.
If the multiple-test procedure is a step-up procedure,
such as {cmd:hochberg}, {cmd:simes} or {cmd:yekutieli},
then the {it:q}-value for each {it:P}-value
is equal to the cumulative minimum of all the {it:r}-values
corresponding to {it:P}-values of rank equal to or greater than that {it:P}-value.

{p 4 8 2}
{cmd:float} specifies that the output variables specified by the
{cmd:qvalue()},  {cmd:rvalue()} and {cmd:svalue()} options
will be created as variables of {help data_types:type} {cmd:float}.
If {cmd:float} is absent,
then these variables are created as variables of {help data_types:type} {cmd:double}.
Whether or not {cmd:float} is specified,
all generated variables are stored to the lowest precision possible without loss of information.

{p 4 8 2}{cmd:fast} is an option for programmers.
It specifies that {cmd:qqvalue} will not take any action
so that it can restore the original data in the event of failure,
or if the user presses {cmd:Break}.


{title:Remarks}

{pstd}
The methods and formulas for {cmd:qqvalue} are given in {help qqvalue##newson_2010a:Newson, 2010a}.
A presentation on {cmd:qqvalue} is given in {help qqvalue##newson_2010b:Newson, 2010b}.
Multiple-test procedures are reviewed in {help qqvalue##newson_2003a:Newson {it:et al}, 2003a},
and described in the on-line help for {helpb multproc}.
A presentation on multiple-test procedures
is given in {help qqvalue##newson_2003b:Newson {it:et al}, 2003b}.
All of these sources contain extensive references for further reading.

{pstd}
The {cmd:qqplot} package is similar to the {browse "http://www.r-project.org/":R} package
{cmd:p.adjust},
which also calculates frequentist {it:q}-values
corresponding to multiple-test procedures.
Note that, in the on-line documentation for {cmd:p.adjust} in {browse "http://www.r-project.org/":R},
the {it:q}-values are referred to as "adjusted {it:P}-values",
although a lot of users refer to them as "{it:q}-values".
There is no clear consensus regarding the correct terminology to use,
even among statisticians.
The term "{it:q}-value" was introduced in {help qqvalue##storey_2003:Storey (2003)}
to describe a minimum positive false discovery rate (pFDR)
under which a {it:P}-value will be included in a discovery set,
assuming that this discovery set is defined to control the pFDR.
The pFDR is a quantity defined for empirical Bayesian methods.
By contrast, the multiple-test procedures used by {cmd:qqvalue} and {cmd:p.adjust}
define the discovery set to control either the familywise error rate (FWER)
or the false discovery rate (FDR),
both of which are defined for purely frequentist methods.
For this reason, I originally used the term "quasi-{it:q}-values"
to denote frequentist {it:q}-values,
and chose the name {cmd:qqvalue} for the package to compute these.
However, I was later advised that the prefix "quasi-" was not really necessary.
I therefore now simply use the term "{it:q}-values",
or "frequentist {it:q}-values" if I need to distinguish them from Bayesian {it:q}-values.

{pstd}
{cmd:qqvalue}, {helpb multproc} and {helpb smileplot} all require input datasets with 1 observation for each of a set of {it:P}-values,
usually corresponding to a set of estimated parameters.
Such input datasets may be produced using the official Stata utilities {helpb statsby} and {helpb postfile},
or alternatively by the user-written Stata package {helpb parmest},
which can be downloaded from {help ssc:SSC}.


{title:Technical note}

{pstd}
If the user specifies {cmd:method(sidak)},
then {cmd:qqvalue} uses the formula for {cmd:method(bonferroni)}
to calculate the {it:s}-values, {it:r}-values and {it:q}-values
corresponding to input {it:P}-values too small to be subtracted from 1 in double precision
to give a result less than 1.
Similarly, if the user specifies {cmd:method(holland)},
then {cmd:qqvalue} uses the formula for {cmd:method(holm)}
to calculate the {it:s}-values, {it:r}-values and {it:q}-values
corresponding to input {it:P}-values too small to be subtracted from 1 in double precision
to give a result less than 1.
See {help qqvalue##newson_2013:Newson (2013)} for the justification for this practice.


{title:Examples}

{pstd}
The following example uses the {helpb sysuse:auto} data,
distributed with Stata.
The {helpb somersd} package is used to measure the Somers' {it:D} parameters
for rank associations between a list of car-specific variables and non-US origin.
The {helpb parmest} package is then used to replace the dataset in memory with a new dataset,
with 1 observation per estimated parameter and data on parameter estimates, confidence limits and {it:P}-values.
We then use {cmd:qqvalue} to calculate {it:q}-values corresponding to the {it:P}-values,
using the Simes procedure.
The {helpb parmest} and {helpb somersd} packages can be downloaded from {help ssc:SSC}.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. somersd foreign price mpg headroom trunk weight length turn displacement gear_ratio, tdist}{p_end}
{p 16 20}{inp:. parmest, norestore}{p_end}
{p 16 20}{inp:. qqvalue p, method(simes) qvalue(myqval)}{p_end}
{p 16 20}{inp:. list}{p_end}

{pstd}
The following example also uses the {helpb sysuse:auto} data.
It first uses the {helpb somersd} package,
together with the {helpb parmby} module of the {helpb parmest} package,
to create a new dataset in the memory,
with 1 observation for each of a list of rank correlations involving car price
in each car origin group (US and non-US cars).
We then use {cmd:qqvalue}, with the {cmd:by} {varlist}{cmd::} prefix,
to demonstrate the calculation of 2 separate sets of {it:q}-values,
one for US-made cars and one for non-US-made cars.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. parmby "somersd price mpg headroom trunk weight length turn displacement gear_ratio, tdist", by(foreign) norestore}{p_end}
{p 16 20}{inp:. by foreign: qqvalue p, method(simes) qvalue(myqval)}{p_end}
{p 16 20}{inp:. by foreign: list}{p_end}


{title:Author}

{pstd}
Roger B. Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References} 

{marker newson_2013}{...}
{phang}
Newson, R. B.  2013.
Bonferroni and Holm approximations for Šidák and Holland-Copenhaver {it:q}-values.
{it:The Stata Journal} 13(2): 379-381.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0300":{it:The Stata Journal} website}.

{marker newson_2010a}{...}
{phang}
Newson, R. B.  2010a.
Frequentist {it:q}-values for multiple-test procedures.
{it:The Stata Journal} 10(4): 568-584.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0209":{it:The Stata Journal} website}.

{marker newson_2010b}{...}
{phang}
Newson, R. B.  2010b.
Post-{helpb parmest} peripherals: {helpb fvregen}, {helpb invcise}, and {cmd:qqvalue}.
Presented at
{browse "http://ideas.repec.org/p/boc/usug10/01.html":the 16th UK Stata User Meeting, 9-10 September, 2010}.

{marker newson_2003a}{...}
{phang}
Newson, R. and the ALSPAC Study Team.  2003a.
Multiple-test procedures and smile plots.
{it:The Stata Journal} 3(2): 109-132.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0035":{it:The Stata Journal} website}.

{marker newson_2003b}{...}
{phang}
Newson, R. and the ALSPAC Study Team.  2003b.
Multiple test procedures and smile plots.
Presented at
{browse "http://ideas.repec.org/p/boc/usug03/16.html":the 9th UK Stata User Meeting, 19-20 May, 2003}. 

{marker storey_2003}{...}
{phang}
Storey, J. D.  2003.
The positive false discovery rate: a Bayesian interpretation and the {it:q}-value.
{it:The Annals of Statistics}
31(6):  2013–2035.


{title:Also see}

{p 0 10}
{bind: }Manual:   {hi:[R] by}, {hi:[R] statsby}, {hi:[P] postfile}.
{p_end}
{p 0 10}
On-line:  help for {manhelp by D}, {manhelp statsby D}, {manhelp postfile P}
 {break} help for {helpb multproc}, {helpb smileplot}, {helpb parmest}, {helpb somersd}, {helpb fvregen}, {helpb invcise} if installed
{p_end}
