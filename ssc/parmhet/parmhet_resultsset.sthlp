{smcl}
{hline}
{cmd:help parmhet_resultsset}{right:(Roger Newson)}
{hline}


{title:Output dataset created by {helpb parmhet}}

{pstd}
The output dataset (or resultsset) created by {helpb parmhet} has one observation,
or one observation per by-group if the {cmd:by()} option is specified,
and data on the heterogeneity-test statistics for the dataset or by-group.
The variables are as follows:

{p2colset 4 24 26 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{hi:idnum}}Numeric dataset ID{p_end}
{p2col:{hi:idstr}}String dataset ID{p_end}
{p2col:{it:by-variables}}Variables specified in the {cmd:by()} option{p_end}
{p2col:{it:sumvar-variables}}Variables specified in the {cmd:sumvar()} option{p_end}
{p2col:{hi:chi2het}}Heterogeneity chi-squared{p_end}
{p2col:{hi:dfhet}}Heterogeneity degrees of freedom{p_end}
{p2col:{hi:i2het}}Heterogeneity {it:I}-squared{p_end}
{p2col:{hi:tau2het}}Heterogeneity tau-squared{p_end}
{p2col:{hi:fhet}}Heterogeneity {it:F}{p_end}
{p2col:{hi:resdfhet}}Heterogeneity residual degrees of freedom{p_end}
{p2col:{hi:phet}}Heterogeneity {it:P}-value{p_end}
{p2line}
{p2colreset}

{pstd}
The variables with default names {cmd:idnum} and {cmd:idstr} are only present
if supplied with values (constant in all observations in the resultsset)
by the {cmd:idnum()} {cmd:idstr()} options, respectively.
They may have non-default names,
which can be specified using the {cmd:nidnum()} and {cmd:nidstr()} options, described in
{it:{help parmhet_resultsset_opts}}.
The {it:by-variables}, if present, identify uniquely the observations in the resultsset,
and are specified by the {cmd:by()} option,
described in  {it:{help parmhet_basic_opts}}.
If the {cmd:by()} option is not specified,
then there is only one observation in the resultsset,
containing test statistics for the whole set of input parameters in the input dataset.
The {it:sumvar-variables}, if present, are specified by the {cmd:sumvar()} option,
described in {it:{help parmhet_resultsset_opts}}.
The other variables contain heterogeneity-test statistics for the dataset,
or for the by-group if the {cmd:by()} option is specified.
They are described in {it:{help parmhet_hettest_opts}}.
The variables with default names {cmd:fhet} and {cmd:resdfhet}
are only present if an input degrees-of-freedom variable is specified,
in addition to the input estimate and standard error variables.
The variable with the default name {cmd:phet}
contains a {it:P}-value for the {it:F}-test if an input degrees-of-freedom variable is specified,
and a chi-squared {it:P}-value otherwise.
All of the heterogeneity-test statistic variables
can be renamed from their default names,
using the options of the same names described in {it:{help parmhet_hettest_opts}}.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] meta}, {hi:[R] test}
{p_end}
{p 4 13 2}
On-line: help for {helpb parmhet}, {helpb parmiv},
{help parmhet_basic_opts:{it:parmhet_basic_opts}},
{help parmhet_resultsset_opts:{it:parmhet_resultsset_opts}},
{help parmhet_hettest_opts:{it:parmhet_hettest_opts}}
{break} help for {helpb test}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb metan} if installed
{p_end}
