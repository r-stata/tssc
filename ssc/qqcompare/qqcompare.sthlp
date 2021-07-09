{smcl}
{hline}
help for {hi:qqcompare}
{hline}

{title:Evaluating balance after matching using quantile-quantile plots.}


{p 8 21 2}{cmd:qqcompare} {it:varlist} [{cmd:,}
{cmd:precision}{cmd:(}{it:integer}{cmd:)}
{cmd:treatment}{cmd:(}{it:varname}{cmd:)}
{cmd:weight}{cmd:(}{it:varname}{cmd:)} {cmd:drawgraph}
{cmd:matchopts}{cmd:(}{it:string}{cmd:)}
{cmd:unmatchopts}{cmd:(}{it:string}{cmd:)}
{cmd:lineopts}{cmd:(}{it:string}{cmd:)}
{cmd:indivoptions}{cmd:(}{it:string}{cmd:)}
{cmd:overalloptions}{cmd:(}{it:string}{cmd:)}]


{title:Description}

{pstd}{cmd:qqcompare} helps evaluate balance after propensity score or
Mahalanobis matching by comparing covariate balance using
quantile-quantile plots. This allows for comparing the entire
distribution of covariates, and not just their means, and thereby
choosing the best matching algorithm among different alternatives
according to which algorithm is most effective in reducing imbalance.
{cmd:qqcompare} reports the mean and maximum deviation in
quantile-quantile plots from the 45 degree line of identical
distribution post-matching, and the relative (percentage) reduction
that results from matching, compared to the unmatched data. Higher relative reductions indicate
better balance. If the {it:drawgraph} option is specified,
{cmd:qqcompare} draws quantile-quantile plots for each covariate, before
and after matching. {p_end}

{pstd}{cmd:qqcompare} also reports the difference in means as a
proportion of the pooled standard deviation, which, according to
Cochran and Rubin's (1973) rule of thumb, should be less than 0.25. {p_end}

{pstd}Imai et al (2008) and Stuart (2010) suggest using these, amongst
other measures to evaluate balance (and explain why t-tests are not
appropriate). While not mandatory, {cmd:qqcompare} is designed to be
used after {help psmatch2}, as detailed below. {p_end}

{pstd} {help cquantile} must be installed for {cmd:qqcompare} to work.
Type {inp: ssc install cquantile} if required. {p_end}


{title: Basic Syntax}

(if used after {cmd:psmatch2})

{inp: . qqcompare varlist}

{phang} {it:varlist} specifies the covariates for which balance is to be
evaluated. {cmd:qqcompare} compares the distribution of each variable
specified in {it:varlist} post-matching, between treatment and control
groups. {p_end}

{phang} To also obtain quantile-quantile plots in addition to their
summary measures, specify the {it:drawgraph} option. {p_end}

{inp: . qqcompare varlist, drawgraph}


{title:Options}

{phang} {opt precision(integer)} specifies the accuracy with which
{cmd:qqcompare} functions. Matching results in a set of weights for
treatment and control units. To construct quantile-quantile plots, we
need to create a new set of data consisting of matched treated and
control units where the frequency of each unit is proportional to its
weight. Since weights are seldom integers, {cmd:qqcompare} works by
multiplying weights by an integer specified by {opt precision} and
rounding off to the nearest whole number. The default value for
{cmd:precision} is 10. {p_end}

{pmore} So, for example, if the matching results in weights of 1, 0.33
and 0.5, then the default for {opt precision} results in an expanded
data set that duplicates respective units 10, 3 and 5 times. Clearly,
the higher the value of {opt precision}, the more precise the
quantile-quantile plots and their summary measures. However, since
{cmd:qqcompare} creates a temporary, expanded dataset, higher values of
{opt precision} may lead to memory problems on versions of Stata older
than 12, in which case more memory should be allocated beforehand using
{help set memory}. {p_end}

{phang}{cmd:treatment}{cmd:(}{it:varname}{cmd:)} need not be specified
if matching was undertaken using {cmd:psmatch2}. Otherwise, this can be
used to specify the treatment variable. {p_end}

{phang}{cmd:weight}{cmd:(}{it:varname}{cmd:)} need not be specified if
matching was undertaken using {cmd:psmatch2}. Otherwise, {it:varname}
can be used to specify the weights that the matching process resulted
in. {p_end}

{phang}{cmd:drawgraph} is used when the actual quantile-quantile plots
are also required to be drawn (the default is to omit these plots).
{p_end}

{pstd}The following options can be used to change the default rendering
of quantile-quantile plots. {cmd:qqcompare} constructs a twoway plot for
each variable, consisting of quantiles of treated and control
observations for unmatched and matched data, and in addition, a line to
show identical distributions. These plots are then combined.

{phang}{cmd:matchopts}{cmd:(}{it:string}{cmd:)} can be used to pass
{help marker_options} and {help jitter_options} to change the rendering
of quantiles for matched units. {p_end}

{phang}{cmd:unmatchopts}{cmd:(}{it:string}{cmd:)} can be used to pass
{help marker_options} and {help jitter_options} options to change the
rendering of quantiles for unmatched units. {p_end}

{phang}{cmd:lineopts}{cmd:(}{it:string}{cmd:)} can be used to pass {help line_options} 
to change the rendering of the line showing identical
distribution. {p_end}

{phang}{cmd:indivoptions}{cmd:(}{it:string}{cmd:)} can be used to pass
{help twoway_options} to change the rendering of all quantile-quantile
plots (together). {p_end}

{phang}{cmd:overalloptions}{cmd:(}{it:string}{cmd:)} can be used to pass
options for {help graph combine} to change how the individual
quantile-quantile plots are combined. {p_end}


{pstd}
The results of {cmd:qqcompare} are returned in r(qqcompare).

{title:Example}

{pstd}In the following, collgrad is the binary treatment and the outcome is wage. 

    {inp: . sysuse nlsw88.dta, clear}
    {inp: . psmatch2 collgrad age tenure race married, outcome(wage) n(2)}
    {inp: . qqcompare age tenure, drawgraph}
    {inp: . qqcompare age tenure, drawgraph matchopts(jitter(3) msize(0.3)) overalloptions(scheme(s2manual))}



{title:References}

{phang} Cochran, W. G. and Rubin, D. B. (1973) Controlling bias in observational studies: a review. {it:Sankhya A}, 35,417Ð446. {p_end}

{phang} Imai, K., G. King, and E.A. Stuart. 2008.â Misunderstandings
Between Experimentalists and Observationalists About Causal Inference.
{it:Journal of the Royal Statistical Society: Series A (Statistics in
Society)} 171 (2): 481-502. {p_end}

{phang} Stuart, E.A. 2010. Matching Methods for Causal Inference: A
Review and a Look Forward. {it:Statistical Science} 25 (1): 1-21.
{p_end}

{title:Author}

{pstd} Sunil Mitra Kumar, King's College London.
stuff.sunil@gmail.com



