{smcl}
{hline}
{cmd:help parmest_resultssets}{right:(Roger Newson)}
{hline}


{title:Output datasets created by {helpb parmest} and {helpb parmby}}

{pstd}
The output dataset (or resultsset) created by {helpb parmest} or {helpb parmby} has one observation per parameter
of a set of estimation results, or one observation per parameter per by-group if
the {cmd:by()} option is specified with {helpb parmby}.
If the {cmd:rename()} option is not specified, then the output dataset contains the following variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{hi:idnum}}Numeric dataset ID{p_end}
{p2col:{hi:idstr}}String dataset ID{p_end}
{p2col:{hi:eq}}Equation name{p_end}
{p2col:{hi:parm}}Parameter name{p_end}
{p2col:{hi:msetype}}Parameter matrix stripe element type{p_end}
{p2col:{hi:omit}}Parameter omit status{p_end}
{p2col:{hi:empty}}Parameter empty cell status{p_end}
{p2col:{hi:label}}Parameter label{p_end}
{p2col:{hi:ylabel}}{it:Y}-variable label{p_end}
{p2col:{hi:estimate}}Parameter estimate{p_end}
{p2col:{hi:stderr}}SE of parameter estimate{p_end}
{p2col:{hi:dof}}Degrees of freedom{p_end}
{p2col:{hi:t}}{it:t}-test statistic{p_end}
{p2col:{hi:z}}{it:z}-test statistic{p_end}
{p2col:{hi:p}}{it:P}-value{p_end}
{p2col:{hi:stars}}Stars for {it:P}-value{p_end}
{p2col:{hi:min}{it:yy}}Lower {it:xx}% confidence limit{p_end}
{p2col:{hi:max}{it:yy}}Upper {it:xx}% confidence limit{p_end}
{p2col:{hi:em_}{it:y}}{it:y}th macro estimation result specified by {cmd:emac()}{p_end}
{p2col:{hi:es_}{it:y}}{it:y}th scalar estimation result specified by {cmd:escal()}{p_end}
{p2col:{hi:ev_}{it:y}}{it:y}th vector estimation result specified by {cmd:evec()}{p_end}
{p2col:{hi:er_}{it:y}{hi:_}{it:k}}{it:k}th row of {it:y}th estimation result specified by {cmd:erows()}{p_end}
{p2col:{hi:ec_}{it:y}{hi:_}{it:k}}{it:k}th column of {it:y}th estimation result specified by {cmd:ecols()}{p_end}
{p2line}
{p2colreset}

{pstd}
The variables {hi:idnum} and {hi:idstr} are only present if the user specifies the options
{cmd:idnum()} and {cmd:idstr()}, respectively.
The variable {hi:eq} is only present if the estimation results
are from a command which creates estimation matrices with {help matrix coleq:equation names}.
The variables {hi:msetype}, {hi:omit}, {hi:empty}, {hi:label} and {hi:ylabel} are only present
if the user specifies the options {cmd:msetype}, {cmd:omit}, {cmd:empty}, {cmd:label} and {cmd:ylabel}, respectively.
Either the variables {hi:dof} and {hi:t} are present or the variable {hi:z} is present,
depending on whether the confidence limits and {it:P}-values are calculated
using the {it:t}-distribution or the standard Normal distribution.
The variable {hi:dof} is calculated as specified by the {cmd:dof()} and {cmd:dfmatrix()} options,
or from the {help ereturn:estimation result} {cmd:e(df_r)},
if {cmd:dof()} and {cmd:dfmatrix()} are not specified.
Note that the degrees of freedom in {hi:dof} may be different
for different parameters of the same model,
and are not always integers.
The {it:P}-values in the variable {hi:p} test the hypothesis that the corresponding parameters
are equal to the null value,
which defaults to zero, or to one if the {cmd:eform} option is specified,
unless specified otherwise by the {cmd:nullvalue()} option.
The variable {hi:stars} is only present if the option {cmd:stars()} is specified,
and contains the specified numbers of stars for the {it:P}-values in the variable {hi:p}.
The {it:xx}% confidence limits {hi:min}{it:yy} and {hi:max}{it:yy}
are calculated using a list of one or more confidence levels {it:xx}, which may be specified in the
{cmd:level()} option, or by {help set level}, and which is a single confidence level of 95% if not specified.
The number {it:yy} used to number the {it:xx} percent confidence limits {hi:min}{it:yy} and {hi:max}{it:yy}
is equal to the confidence level {it:xx} unless the user specifies {cmd:clnumber(rank)},
in which case the number {it:yy} is the rank, in ascending order, of the confidence level {it:xx}.
There is one {hi:em_}{it:y} variable for each macro estimation result in the list specified by the
{cmd:emac()} option, one {hi:es_}{it:y} variable for each scalar estimation result specified by the
{cmd:escal()} option, one {hi:ev_}{it:y} variable for each vector estimation result specified by the
{cmd:evec()} option,
one {hi:er_}{it:y}{hi:_}{it:k} variable for each row of each matrix estimation result
specified by the {cmd:erows()} option,
and one {hi:ec_}{it:y}{hi:_}{it:k} variable for each column of each matrix estimation result
specified by the {cmd:ecols()} option.
The variables {hi:em_}{it:y} are string variables, truncated if necessary to the
maximum length for a string variable under the edition of Stata used.
All of these variables can be renamed using the {cmd:rename()} option.

{pstd}
The output dataset (or resultsset) created by {helpb parmby}
contains all the variables in the output dataset created by {helpb parmest},
and also the following additional variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{it:by-variables}}Variables specified in the {cmd:by()} option{p_end}
{p2col:{hi:parmseq}}Parameter sequence number{p_end}
{p2col:{hi:command}}Estimation command{p_end}
{p2line}
{p2colreset}

{pstd}
The {it:by-variables} are only present if the {cmd:by()} option is specified.
The variable {hi:command} is only present if the {cmd:command} option is specified.
The {helpb parmby} output dataset is sorted primarily by the {it:by-variables},
in the order specified in the {cmd:by()} option, if the {cmd:by()} option is specified,
and sorted secondarily by {hi:parmseq}, which contains the sequential order of the parameter
in the estimation result vector (which is usually {hi:e(b}}).
The variables {hi:command} and {hi:parmseq} can be renamed by {helpb parmby} using the {cmd:rename()} option,
but the {it:by-variables} cannot be renamed by {helpb parmby}.

{pstd}
The {cmd:eform}, {cmd:dof()}, {cmd:level()} and {cmd:clnumber()} options are described in
{help parmest_ci_opts:{it:parmest_ci_opts}}.
The {cmd:idnum()}, {cmd:idstr()}, {cmd:label}, {cmd:ylabel}, {cmd:stars()},
{cmd:emac()}, {cmd:escal()}, {cmd:evec()}, {cmd:erows()} and {cmd:ecols()} options are described in
{help parmest_varadd_opts:{it:parmest_varadd_opts}}.
The {cmd:rename()} and {cmd:nullvalue()} options are described in
{help parmest_varmod_opts:{it:parmest_varmod_opts}}.
The {cmd:by()} and {cmd:command} options are described in
{help parmby_only_opts:{it:parmby_only_opts}}.


{title:Saved characteristics}

{pstd}
The variables {hi:min}{it:yy} and {hi:max}{it:yy}, containing the {it:xx}% confidence limits,
all have the {help char:variable characteristic} {hi:level},
containing the respective percentage confidence levels {hi:xx}
specified for these variables by the {cmd:level()} option.
The variables {hi:min}{it:yy}, {hi:max}{it:yy} and {hi:p} have the {help char:variable characteristic} {hi:mcom},
containing the multiple comparison adjustment method used in calculating them,
which is set by the options {cmd:mcompare()} and {cmd:mcomci()}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frestimate}{break}
{p_end}

{psee}
{space 2}Help:  {manhelp estcom U:20 Estimation and postestimation commands}{break}
{helpb parmest}, {helpb parmby},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {help parmest_ci_opts:{it:parmest_ci_opts}},
{help parmest_varadd_opts:{it:parmest_varadd_opts}}, {help parmest_varmod_opts:{it:parmest_varmod_opts}},
{help parmby_only_opts:{it:parmby_only_opts}}
{p_end}
