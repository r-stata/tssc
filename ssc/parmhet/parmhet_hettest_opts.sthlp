{smcl}
{hline}
{cmd:help parmhet_hettest_opts}{right:(Roger Newson)}
{hline}


{title:Heterogeneity-test options for {helpb parmhet} and {helpb parmiv}}

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


{title:Description}

{pstd}
These options specify the names of generated variables,
containing heterogeneity-test statistics for the input dataset,
or for the by-group if the {cmd:by()} option is specified.
If specified for {helpb parmhet},
these options refer to generated variables in the {helpb parmhet} resultsset
(see help for {help parmhet_resultsset:{it:parmhet_resultsset}}),
and cause the variable with the same name as the option to be renamed to the name specified by the option.
If specified for {helpb parmiv},
these options cause a new variable of the specified name to be added to the existing dataset in memory.


{title:Options}

{p 4 8 2}
{cmd:chi2het(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the heterogeneity chi-squared statistic defined by Cochrane (1954).

{p 4 8 2}
{cmd:dfhet(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the degrees of freedom for the heterogeneity chi-squared statistic defined by Cochrane (1954).

{p 4 8 2}
{cmd:i2het(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the heterogeneity {it:I}-squared statistic defined by Higgins and Thompson (2002).
This statistic is expressed on a percentage scale from 0 to 100,
and denotes the percentage excess of the heterogeneity chi-squared statistic,
compared to its mean value under the null hypothesis of no heterogeneity,
specified by its degrees of freedom.
If the chi-squared statistic is less than its degrees of freedom,
then the {it:I}-squared statistic is zero.

{p 4 8 2}
{cmd:tau2het(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the heterogeneity tau-squared statistic defined by Higgins and Thompson (2002).
The tau-squared statistic is an estimate of the variance of the true population values of the estimated parameters,
in the meta-population from which these populations are sampled.
It is expressed in squared units of the input parameter estimates,
or in squared log units of the input parameter estimates,
if the {cmd:eform} option is specified
(see help for {help parmhet_basic_opts:{it:parmhet_basic_opts}}).
If the chi-squared statistic is less than its degrees of freedom,
then the tau-squared statistic is zero.

{p 4 8 2}
{cmd:fhet(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the heterogeneity {it:F}-statistic defined by Welch (1951) and popularized by Cochrane (1954).
This variable is only calculated if the user specifies an input degrees of freedom variable,
in addition to the input estimate and standard error variables.
If an input degrees of freedom variable is not provided,
then the {cmd:fhet()} option is ignored.

{p 4 8 2}
{cmd:resdfhet(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the residual (or denominator) degrees of freedom
for the heterogeneity {it:F}-statistic output to the {cmd:fhet()} variable.
This denominator degrees of freedom variable may have non-integer values,
and is used,
together with the numerator degrees of freedom output to the {cmd:dfhet()} variable,
to calculate a {it:P}-value (output to the {cmd:phet()} variable)
for the heterogeneity {it:F}-statistic (output to the {cmd:fhet()} variable).
The {cmd:resdfhet()} variable is only calculated if the user specifies an input degrees of freedom variable,
in addition to the input estimate and standard error variables.
If an input degrees of freedom variable is not provided,
then the {cmd:resdfhet()} option is ignored.

{p 4 8 2}
{cmd:phet(}{help newvar:{it:newvarname}}{cmd:)} specifies the name of an output variable
containing the heterogeneity {it:P}-value.
If an input degrees of freedom variable is specified,
then this {it:P}-value is calculated using the {it:F}-statistic output to the {cmd:fhet()} variable,
with the numerator degrees of freedom output to the {cmd:dfhet()} variable
and the denominator degrees of freedom output to the {cmd:resdfhet()} variable.
If an input degrees of freedom variable is not specified,
then this {it:P}-value is calculated using the chi-squared statistic output to the {cmd:chi2het()} variable,
with the degrees of freedom output to the {cmd:dfhet()} variable.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Cochrane, W. G.  1954.  The combination of estimates from different experiments.
{it:Biometrics} 10(1): 101-129.

{phang}
Higgins, J. P. T. and Thompson, S. G.  2002.  Quantifying heterogeneity in a meta-analysis.
{it:Statistics in Medicine} 21(11): 1539-1558.

{phang}
Welch, B. L.  1951.  On the comparison of several mean values: an alternative approach.
{it:Biometrika} 36(3/4): 330-336.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] meta}, {hi:[R] test}
{p_end}
{p 4 13 2}
On-line: help for {helpb parmhet}, {helpb parmiv},
{help parmhet_basic_opts:{it:parmhet_basic_opts}},
{help parmhet_resultsset_opts:{it:parmhet_resultsset_opts}},
{help parmhet_resultsset:{it:parmhet_resultsset}}
{break} help for {helpb test}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb metan} if installed
{p_end}
