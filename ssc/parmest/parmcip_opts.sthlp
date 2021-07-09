{smcl}
{hline}
{cmd:help parmcip_opts}{right:(Roger Newson)}
{hline}


{title:Options for {helpb metaparm} and {helpb parmcip}}


{title:Syntax}

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


{title:Description}

{pstd}
These options are available for {helpb metaparm} and for {helpb parmcip}.
They control the calculation of confidence limits and {it:P}-values.
They are not often used, as {helpb metaparm} and {helpb parmcip} have defaults for these options,
which are usually sensible.


{title:Options}
 
{p 4 8 2}
{cmd:notdist} specifies whether or not a {it:t}-distribution is used
to calculate confidence limits. If {cmd:tdist} is specified, then a {it:t}-distribution is used.
If {cmd:notdist} is specified, then a standard Normal distribution is used.
If neither {cmd:tdist} nor {cmd:notdist} is specified by the user,
then the option is set to {cmd:tdist} if the {cmd:dof()} option
is set to the name of an existing variable, and is set to {cmd:notdist} otherwise.
If {cmd:tdist} is specified with {helpb metaparm}, then the degrees of freedom in the output dataset
are calculated from the degrees of freedom and standard errors in the input dataset,
using the Satterthwaite formula (Satterthwaite, 1946),
or using the Welch formula (Welch, 1947) if the user specifies {cmd:dfcombine(welch)},
or using the common constant degrees of freedom if the user specifies {cmd:dfcombine(constant)}.

{p 4 8 2}
{cmd:eform} indicates that the input estimates are exponentiated,
and that the input standard errors are multiplied by the exponentiated estimate,
and that the output confidence limits are to be exponentiated.
If {cmd:eform} is used with {helpb metaparm}, then the estimate variable in the output dataset is exponentiated,
and the standard error variable in the output dataset is multiplied
by the exponentiated estimate variable.

{p 4 8 2}
{cmd:float} specifies that the numeric output variables will be created as type {hi:float} or below.
If {cmd:float} is unset, then the numeric output variables are created as type {hi:double}.
Note that all generated variables are compressed as much as possible without loss of information,
whether or not {cmd:float} is specified.

{p 4 8 2}
{cmd:nozerop} specifies that {it:P}-values less than {help creturn:c(smallestdouble)},
the smallest full-precision {help datatypes:double} value greater than zero,
will be reset to {help creturn:c(smallestdouble)}.
This can be useful if the user wants to compute or plot their logs.
Note that these {it:P}-values will be reset back to zero if {cmd:float} is specified.

{p 4 8 2}
{opt nullvalue(#)} specifies a value for the estimated parameters
under the null hypotheses tested using the {it:z}-statistics or {it:t}-statistics
and their {it:P}-values.
If not specified, then it is set to 1 if {cmd:eform} is specified,
and set to 0 otherwise.

{p 4 8 2}
{cmd:fast} is an option for programmers, and specifies that no action will be taken
to restore the original data if the user presses {help break:Break}.
If used with {helpb metaparm}, the {cmd:fast} option implies the {cmd:norestore} option (see {it:{help metaparm_outdest_opts}}).

{p 4 8 2}
{cmd:estimate(}{it:{help varname}}{cmd:)} specifies the name of the input variable containing estimates.
It is set to {hi:estimate} if not specified.

{p 4 8 2}
{cmd:stderr(}{it:{help varname}}{cmd:)} specifies the name of the input variable containing standard errors.
It is set to {hi:stderr} if not specified.

{p 4 8 2}
{cmd:dof(}{it:{help varname}}{cmd:)} specifies the name of the input variable containing degrees of freedom.
It is set to {hi:dof} if not specified.

{p 4 8 2}
{cmd:zstat(}{it:{help newvar:newvarname}}{cmd:)} specifies the name of the output variable containing the {it:z}-statistics.
It is set to {hi:z} if not specified.

{p 4 8 2}
{cmd:tstat(}{it:{help newvar:newvarname}}{cmd:)} specifies the name of the output variable containing the {it:t}-statistics.
It is set to {hi:t} if not specified.

{p 4 8 2}
{cmd:pvalue(}{it:{help newvar:newvarname}}{cmd:)} specifies the name of the output variable containing the {it:P}-values.
It is set to {hi:p} if not specified.

{p 4 8 2}
{cmd:stars(}{it:{help numlist}}{cmd:)} is used to generate a string variable with default name {hi:stars},
containing the stars for the {it:P}-values.
It works in the same way as the {cmd:stars()} option of {helpb parmest}.

{p 4 8 2}
{cmd:nstars(}{it:{help newvar:newvarname}}{cmd:)} specifies the name of the output variable containing the stars,
if {cmd:stars()} is specified. If {cmd:nstars()} is not specified,
then the name is set to {hi:stars}.

{p 4 8 2}
{cmd:level(}{it:{help numlist}}{cmd:)} specifies the confidence levels, in percent, for
the confidence limit variables created in the output dataset.
It works in the same way as the {cmd:level()} option of {helpb parmest}.

{p 4 8 2}
{cmd:clnumber(}{it:numbering_rule}{cmd:)} specifies the rule used to number the names of the
confidence limit variables created in the output dataset.
It works similarly to the {cmd:clnumber()} option of {helpb parmest}.
However, with {helpb parmcip} and {helpb metaparm}, the user may specify
prefixes other than {hi:min} and {hi:max} for the confidence limits, using the
{cmd:minprefix()} and {cmd:maxprefix()} options.

{p 4 8 2}
{cmd:minprefix(}{it:prefix}{cmd:)} specifies the prefix used for naming the lower confidence limit variables.
It is set to {hi:min} if not specified. For instance, if the user specifies {cmd:minprefix(inf)}, then
the lower 95% confidence limit variable will be named {hi:inf95}.

{p 4 8 2}
{cmd:maxprefix(}{it:prefix}{cmd:)} specifies the prefix used for naming the upper confidence limit variables.
It is set to {hi:max} if not specified. For instance, if the user specifies {cmd:maxprefix(sup)}, then
the upper 95% confidence limit variable will be named {hi:sup95}.

{p 4 8 2}
{cmd:mcompare(}{it:method}{cmd:)} specifies a multiple-comparison method
used to adjust the generated confidence limits and {it:P}-values.
This method may be {cmd:noadjust} (the default, indicating no adjustment),
{cmd:bonferroni} (indicating the Bonferroni adjustment),
and {cmd:sidak} (indicating the Sidak adjustment).
The adjustments, if requested, are calculated for the total number of parameters estimated,
or for the number of parameters estimated in the by-group,
if a {cmd:by} {varlist}{cmd::} prefix is specified.
Note that, if a {cmd:by} {varlist}{cmd::} prefix is specified for {cmd:metaparm},
then a {cmd:by()} option must also be specified,
and must begin with the variables in the {cmd:by} {varlist}{cmd::} prefix.

{p 4 8 2}
{cmd:mcomci(}{it:method}{cmd:)} specifies a multiple-comparison method
used to adjust the generated confidence limits only, and not the generated {it:P}-values.
If the user wants to generate adjusted {it:P}-values without adjusting the confidence limits,
or to generate adjusted {it:P}-values using a different method from the one used for adjusting the confidence limits,
then the user is advised to use the {helpb qqvalue} package,
which can be downloaded from {help ssc:SSC}.
Note that the {cmd:mcompci()} and {cmd:mcompare()} options do not affect the names
of the generated variables containing the confidence limits,
only their values.

{p 4 8 2}
{cmd:replace} is a {helpb parmcip} option, ignored by {helpb metaparm}.
It specifies that, if there are existing variables in the input dataset with the same names as the generated variables
specified by the {cmd:zstat()}, {cmd:tstat()}, {cmd:pvalue()}, {cmd:clnumber()}, {cmd:minprefix()} or {cmd:maxprefix()} options,
then those variables will be replaced.
Whether or not {cmd:replace} is specified, the names of the output variables are not allowed to clash
with each other, with the input variables,
or with the variables in the {cmd:by()} and {cmd:sumvar()} options of {helpb metaparm}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Satterthwaite, F. E. 1946. An approximate distribution of estimates of variance components.
{it:Biometrics Bulletin} 2(6): 110-114.

{phang}
Welch, B. L. 1947. The generalization of `Student's' problem when several different population variances are involved.
{it:Biometrika} 34(1/2): 28-35.


{title:Also see}

{psee}
Manual:  {findalias frestimate}
{p_end}

{psee}
{space 2}Help:  {manhelp postest U:20 Estimation and postestimation commands}{break}
{helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm},
{help metaparm_outdest_opts:{it:metaparm_outdest_opts}}, {help metaparm_content_opts:{it:metaparm_content_opts}},
{help metaparm_resultssets:{it:metaparm_resultssets}}, {it:{help parmest_resultssets}}{break}
{helpb qqvalue} if installed

{p_end}
