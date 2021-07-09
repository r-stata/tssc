{smcl}
{hline}
{cmd:help metaparm_content_opts}{right:(Roger Newson)}
{hline}


{title:Output-content options for {helpb metaparm}}


{title:Syntax}

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


{title:Description}

{pstd}
These options are available for {helpb metaparm} but not for {helpb parmcip}.
They control the contents of the output dataset (or resultsset) created by {helpb metaparm}.


{title:Options}

{p 4 8 2}
{cmd:by(}{varlist}{cmd:)} specifies a list of existing by-variables in the input dataset.
{helpb metaparm} creates an output dataset with one observation in each by-group,
or with one observation only if {cmd:by()} is not specified,
and data on estimates, {it:P}-values, {it:z-} or {it:t}-statistics  and confidence limits
for the weighted sums of parameters within the by-group,
or in the whole input dataset if {cmd:by()} is not specified.
The weightings for the weighted sums are specified using the {help weight:weight specification}.

{p 4 8 2}
{cmd:sumvar(}{varlist}{cmd:)} specifies a list of variables in the input dataset
to be included in the output dataset, with values equal to their unweighted sums in the input dataset
(if {cmd:by()} is not specified) or to their unweighted sums within the by-group
(if {cmd:by()} is specified). For instance, if the input dataset contains one observation
per study to be entered into a meta-analysis, and contains a variable {hi:N} specifying the number
of subjects in the study, then the user can specify {cmd:sumvar(N)}, and {hi:N} will be present
in the output dataset, where it will contain the total number of subjects in all the studies.

{p 4 8 2}
{cmd:dfcombine(}{it:combination_rule}{cmd:)} specifies a rule for combining the degrees of freedom of the input parameters
to define the degrees of freedom for the output parameters,
if the {it:t}-distribution is used to define confidence limits and {it:P}-values.
If {cmd:dfcombine(satterthwaite)} is specified, then the formula of Satterthwaite (1946) is used.
If {cmd:dfcombine(welch)} is specified, then the formula of Welch (1947) is used.
If {cmd:dfcombine(constant)} is specified, then {helpb metaparm} checks that the degrees of freedom
are constant (or constant within by-groups if {cmd:by(}{it:{help varlist}}{cmd:)} is specified),
and then sets the output degrees of freedom to the constant input degrees of freedom.
{cmd:dfcombine()} is set to {cmd:satterthwaite} by default,
but is ignored if the {it:t}-distribution is not used to define confidence limits and {it:P}-values.
The option {cmd:dfcombine(constant)} is useful if the input parameters are uncorrelated parameters
belonging to the same model estimation with pooled degrees of freedom,
such as group means estimated using the {helpb regress} command
with group membership indicators as {it:X}-variables,
using the {cmd:noconst} option,
and the user uses {helpb metaparm} to estimate contrasts of interest, such as differences or interactions.
In these circumstances, using {helpb regress} without the {cmd:robust} option
and using {cmd:dfcombine(constant)} with {helpb metaparm}
gives confidence limits and {it:P}-values equivalent to those of the equal-variance {help ttest:{it:t}-test}.
By contrast, if the user estimates group means using a separate constant-only model for each group,
and then uses {helpb metaparm} with the option {cmd:dfcombine(satterthwaite)} or {cmd:dfcombine(welch)},
then the confidence limits and {it:P}-values
are equivalent to those of the Satterthwaite or Welch unequal-variance {help ttest:{it:t}-test}.


{p 4 8 2}
{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable, with default name {hi:idnum}, in the output dataset,
with that value for all observations.
This is useful if the output resultsset is concatenated with other resultssets
using {helpb append}.

{p 4 8 2}
{cmd:nidnum(}{help newvar:{it:newvarname}}{cmd:)} specifies a name for the numeric ID variable
evaluated by {cmd:idnum()}.
If {cmd:idnum()} is present and {cmd:nidnum()} is absent,
then the name of the numeric ID variable is set to {hi:idnum}.

{p 4 8 2}
{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable, with default name {hi:idstr}, in the output dataset,
with that value for all observations.
This is useful if the output resultsset is concatenated with other resultssets
using {helpb append}.

{p 4 8 2}
{cmd:nidstr(}{help newvar:{it:newvarname}}{cmd:)} specifies a name for the string ID variable
evaluated by {cmd:idstr()}.
If {cmd:idstr()} is present and {cmd:nidstr()} is absent,
then the name of the string ID variable is set to {hi:idstr}.

{p 4 8 2}
{cmd:format(}{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {help varlist:{it:varlist}s}.


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
Manual:  {manlink D append}, {manlink D format}
{p_end}

{psee}
{space 2}Help:  {manhelp append D}, {manhelp format D}{break}
{helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm},
{help metaparm_outdest_opts:{it:metaparm_outdest_opts}}, {help parmcip_opts:{it:parmcip_opts}},
{help metaparm_resultssets:{it:metaparm_resultssets}}
{p_end}
