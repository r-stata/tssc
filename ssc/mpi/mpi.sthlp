{smcl}
{* *! 1.0.2 09apr2017}{...}
help {hi:mpi}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p 2 2 2} {hi:mpi} {hline 2} Estimates the entire parametric class of Alkire-Foster multidimensional poverty measures.
{p2colreset}{...}

{title:Syntax}

{p 8 11 2}{hi:mpi} {cmd:d1(}{help varlist}{cmd:)} [{cmd:d2(}{help varlist}{cmd:)} ...]
[{cmd:w1(}{help numlist}{cmd:)} {cmd:w2(}{help numlist}{cmd:)} ...]
[{cmd:t1(}{help numlist}{cmd:)} {cmd:t2(}{help numlist}{cmd:)} ...]
 {ifin} {weight}{cmd:,}
{cmdab:c:utoff(}{it:real}{cmd:)}
[{cmd:by(}{help varname}{cmd:)}
 {cmdab:a:lpha(}{help numlist}{cmd:)}
 {cmdab:l:evel(}{it:#}{cmd:)}
 {cmdab:s:vy} {cmdab:sub:pop(}[{help varlist}] [{help if}]{cmd:)}
 {cmdab:deprivedd:ummy(}{help varname}{cmd:)}
 {cmdab:depriveds:core(}{help varname}{cmd:)}
 {cmdab:nos:ummary} {cmdab:nod:ecomposition}
 {it:{help mpi##postoptions:post-options}}
]

{title:Description}

{p 2 2 2} For a set of binary deprivation indicators {hi:mpi} computes the Adjusted Multidimensional Headcount Ratio (M0)
developed by {help mpi##References:Alkire and Foster (2011a)}, also known as the Multidimensional Poverty Index (MPI).
With real-valued indicators {hi:mpi} allows computing the entire parametric class of Alkire-Foster (AF) poverty
measures for arbitrary values of the poverty-aversion parameter (alpha).
{hi:mpi} provides the decomposition of the AF measures by deprivation indicators and, when specified, by population sub-groups; it allows
for a flexible weighting structure of the indicators and takes fully into account the survey design.

{p 2 2 2} An important characteristic of {hi:mpi} is the possibility to group indicators into policy
domains. This does not affect the statistical properties of the AF measures but facilitates the
interpretation of the results. Let us consider 2 deprivation domains, e.g. {it:monetary poverty} and {it:health}.
{it:Monetary poverty} can be operationalised in the data
by 1 indicator, e.g. household income, whereas {it:health} by 2 indicators, e.g. the number
of visits to the doctor and the distance to the closest medical center. In this example,
there are 3 deprivation indicators for 2 policy domains and {hi:mpi} provides
information at both the indicator and the domain level.


{marker Outcomes}{...}
{p 2 2 2} Given a poverty cutoff and suitable set of indicators,
{hi:mpi} computes the following output:

{p 2 2 2}{it:Main indicators:}

{phang}
{cmd:H}: The Multidimensional Deprivation Headcount (the share of poor
individuals in the population)

{phang}
{cmd:M0}: The Adjusted Headcount Ratio, M0 = H*A, which
accounts for both the incidence of poor individuals and the intensity
of their multiple deprivations

{phang}
{cmd:M1}: The Adjusted Poverty Gap, M0 = H*A*G, which takes into
account the incidence of poverty, the average range of deprivations and the average depth across deprivations. It is computed only with real-valued indicators.

{phang}
{cmd:M(2)}: The Adjusted Foster-Greer-Thorbecke (FGT) Measure, M(2) = H*A*S(2). It is computed only with real-valued indicators.

{phang}
{cmd:M({it:alpha})}: The {it:class} of Adjusted Foster-Greer-Thorbecke (FGT) Measures for any {it:alpha} bigger than 1. It is computed only with real-valued indicators.

{p 2 2 2}{it:Additional indicators:}

{phang}
{cmd:A}: The Average Multidimensional Poverty Intensity, the average percentage of simultaneous
deprivations suffered by the poor individuals.

{phang}
{cmd:G}: The Average Poverty Gap across all instances where poor individuals are deprived. It is computed only with real-valued indicators.

{phang}
{cmd:S(2)}: Average Squared Poverty Gap or Average Severity across all
instances where individuals are deprived. It is computed only with real-valued indicators.

{p 2 2 2}Main indicators are the most often considered poverty indices.
The main reason for separating them is functional.
The additional indicators are averages over deprived individuals,
whereas the main indicators are averages over all individuals.
Hence, the underlying samples are different and reporting within one
variance-covariance matrix would be inappropriate.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opth d1(varlist)}, ...}List of deprivation domains, each domain should be composed of at least 1 indicator.{p_end}
{synopt:{opth c:utoff(real)}}The poverty cutoff, a deprivation score between 0 and 1 above which a parson is condered poor.{p_end}

{syntab:Optional}
{synopt:{opth w1(numlist)}, ...}List of weights to be applied to the list of indicators.{p_end}
{synopt:{opth t1(numlist)}, ...}List of deprivation {help mpi##thresholds:thresholds} for real-valued indicators.{p_end}
{synopt:{opth by(varname)}}Exact decomposition of the AF measures across the categories of {help varname}.{p_end}
{synopt:{opth a:lpha(numlist)}}Additional AF measures for arbitrary values of alpha>1.{p_end}
{synopt:{opth l:evel(#)}}Confidence levels.{p_end}
{synopt:{opth cat:egories(#)}}Minimum number of categories for the detection of binary/ordinal versus real-valued variables{p_end}
{synopt:{opt s:vy}}Takes into account the survey design; See {help svyset}.{p_end}
{synopt:{opt sub:pop}}Requires the {opt svy} option;  Identify a subpopulation, see {help svy##svy_options:svy}.{p_end}

{synopt:{opth depriveddummy(varname)}}Create a new variable containing whether an individual is multidimensionally deprived.{p_end}
{synopt:{opth deprivedscore(varname)}}Create a new variable containing an individual's multidimensional deprivation score.{p_end}

{synopt:{opt nos:ummary}}Does not display the summary table.{p_end}
{synopt:{opt nod:ecomposition}}Does not compute the decompositions by indicators.{p_end}

{syntab:{it:post-options}}

{marker postoptions}{...}
Specify at most one of the following at the same time. These options control which results are returned in {cmd:e(b)} and {cmd:e(V)}.
Independently of the selected option, results are all conveniently stored in the ereturn list with a standardized notation (see the returned values below).

{synopt:{cmdab:postm:ain}}Return the indicators H, M0, M1, M2 and all M({it:alpha}). The default option.{p_end}
{synopt:{cmdab:posta:dditional}}Return additional indicators A, S and G.{p_end}
{synopt:{cmdab:posti:ndicators}}Return decomposition by indicators.{p_end}
{synopt:{cmdab:postd:omains}}Return decomposition by domains.{p_end}
{synopt:{cmdab:postby:main}}Return H, M0, M1, M2 and all M({it:alpha}) indicators over by-groups.{p_end}
{synopt:{cmdab:postbyp:roportion}}Return proportional contributions of the by-groups to the main indicators.{p_end}
{synopt:{cmdab:postbyi:ndicators}}Return decomposition both by indicators and over by-groups.{p_end}
{synopt:{cmdab:postbyd:omains}}Return decomposition both by domains and over by-groups.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:pweight} and {it:fweight} are allowed; see {help weight}.

{title:Options}

{phang}
{cmd:d1(}{help varlist}{cmd:)} {cmd:d2(}{help varlist}{cmd:)} ... : denote deprivation domains, e.g. health, housing, 
education, etc. Users can specify an indefinite number of domains and, for each domain, an indefinite number of
indicators. At least one indicator is required and observations with missing values are excluded from the estimation
sample. If users do not specify deprivation thresholds in the corresponding option ({cmd:t1}, see below) then
{cmd:mpi} treats the indicators as binary variables taking values one (deprived) or zero (not deprived). If users
specify deprivation thresholds, {cmd:mpi} considers the related indicators as real-valued variables. Deviations from
these rules will result in an error message, which means that combining binary and real-valued indicators is possible
only when selecting the corresponding threshold also for the binary indicators (i.e. 0, or any value between 0 and 0.5).

{pmore}
{help mpi##References:Alkire and Foster (2011a)} suggest caution when combining binary and real-value indicators in the calculation of multidimensional poverty measures with alpha>0.
In these cases, binary indicators would automatically receive a higher weight than real-valued variables in the calculation of the M({it:alpha}) measures based on the normalised poverty gaps, as these gaps would be always the highest possible.
If one wants to combine binary and real-valued indicators, a different weighing structure of each indicator can counterbalance the implicit higher weight of binary indicators.
See also {help mpi##References:Alkire and Foster (2008, 18-20)} for a discussion.
{cmd:mpi} detects real-valued indicators based on the number of different values characterizing the variable.
Indicators with more than 20 different values are considered real-valued variables and users get an alert when the variable has fewer values.
The threshold of 20 values can be changed using the option {cmd:categories}.
According to {help mpi##References:Alkire and Foster (2011a)}, ordinal and categorical indicators should not be included in the calculation of the AF measures with alpha>0.
Instead, M(0) provides for both meaningful comparisons and favourable axiomatic properties when data are ordinal or categorical, so long as they can be recoded into dichotomous indicators.

{phang}
{opth c:utoff(real)} : is required and specifies a number between zero and one, above which the
individual is considered poor. For each individual {hi:mpi} computes the  {it: weighted} sum of the indicators and the individual is
considered poor only if the resulting score is higher then the selected poverty cutoff. 
Weights are specified in the corresponding {cmd:mpi} option (see below); if no weights are
specified, mpi assumes equal weights at the domain level and within each domain.
Hence, when the number of indicators is equal to the number of domains and the
indicators have equal weights the poverty cutoff will simply indicate the percentage
of simultaneous deprivations above which a person is considered poor.

{pmore}
Let us consider an example with 3 indicators, {hi:ind1}, {hi:ind2} and {hi:ind3}:

{pmore} Example: {cmd: mpi d1(ind1 ind2 ind3) cutoff(0.66)}

{pmore}
Since no thresholds are specified, {hi:mpi} assumes that the indicators are all binary variables.
Since no weights are specified, {hi:mpi} assumes equal weight at the domain level and within each domain.
In the example above, a person is therefore considered poor if she faces at least two deprivations, as the
the weighted sum of two deprivations (0.3334+0.3334) is just above the poverty cutoff of 0.66.

{marker thresholds}{...}
{phang}
{cmd:t1(}{it:thresholds}{cmd:)} {cmd:t2(}{it:thresholds}{cmd:)} ... : denote the deprivation thresholds for the indicators of each domain. This option is required only when using real-valued
indicators. Individuals are considered deprived for values strictly below the thresholds.

{pmore}
The command line below shows an example of different deprivation thresholds: for
ind1, ind2 and ind3, deprivation occurs for values strictly below 4, 3.5 and 5, respectively.

{pmore} Example: {cmd: mpi d1(ind1 ind2) d2(ind3) t1(4 3.5) t2(5), cutoff(0.74)}

{pmore}
Note that mixing different types of indicators (binary/ordinal and real-valued)
is generally not recommended. See {help mpi##References:Alkire and Foster (2008, 2011b)} for a discussion on this point.

{phang}
{cmd:w1(}{help numlist}{cmd:)} {cmd:w2(}{help numlist}{cmd:)} ... : denote the weights of the indicators. Weights are
numbers between zero and one and must sum up to 1; when this is not the case,
mpi gives an error. This option uses as many weights as indicators, and the order in
the lists must follow the order of the corresponding indicators. The default option is
equal weighting, where domains are equally weighted and indicators in each domain
are equally weighted. The two command lines below are therefore equivalent:

{pmore} Example: {cmd: mpi d1(ind1 ind2) d2(ind3), cutoff(0.74)}

{pmore} Example: {cmd: mpi d1(ind1 ind2) d2(ind3) w1(0.25 0.25) w2(0.5), cutoff(0.74)}


{phang}
{opth by(varname)} : requires {hi:mpi} to compute the decomposition of the AF measures by categories of {it:varname}.
The variables must be numeric. missing values are excluded from the estimation sample.

{phang}
{opt s:vy} : requires {hi:mpi} to take into account the survey design. The survey design has to be declared through {help svyset:svyset} {it:before} using {hi: mpi}.
If the only information about the survey design relates to the sampling weights, the user can supply {help svyset:svyset} with such information and use the {cmd:svy} option of mpi. Equivalently, the user can specify the sampling weights in the command line using the standard syntax.

{phang}
{opt sub:pop} : requires {hi:mpi} to perform subpopulation estimation on the sample. See {help svy##svy_options:svyset} for details. This option requires the user to specify the {cmd:svy} option. In this case, {cmd:if} and {cmd:in} are no longer allowed.

{phang}
{opth a:lpha(numlist)} : triggers the computation of additional, non-standard indices M(a). This option is possible only with real-valued indicators.
Measures M1 and M(2) are computed by default. Hence, the option {cmd:alpha(3)} means that {hi:mpi} computes M1, M(2) {it:and} M(3).
Decompositions by indicators and population sub-groups are computed also for the new M({it:alpha})s.

{phang}
{opth l:evel(#)} : changes the confidence levels. See {help set level:set level}.

{phang}
{opth cat:egories(#)} : changes how {hi:mpi} detects {it:real-valued} indicators by counting the
number of {it:different} values characterizing the variable. The default is 20.
A more detailed discussion is provided above in the section on the {cmd:d} option.

{phang}
{opth deprivedd:ummy(varname)} : Create a new variable containing whether an individual is multidimensionally deprived.

{phang}
{opth depriveds:core(varname)} : Create a new variable containing an individual's multidimensional deprivation score.

{phang}
{opt nos:ummary} : suppresses the display of the summary table at the beginning of {hi:mpi} output.

{phang}
{opt nod:ecomposition} : suppresses the computation of the decompositions by indicators. This increases the execution speed.

{title:Examples}

{p 2 2 2} Consider survey data with the following indicators (0/1 dummies) for the domains {it:health},
{it:education} and {it:housing}: health_i1, health_i2, health_i3, education_i1, education_i2, housing_i1, housing_i2.

{p 2 2 2} Multidimensional poverty index with equal weighting and a cutoff of 0.3:

{p 4 2 2} . {cmd:mpi d1(education_i1 education_i2) d2(health_i1 health_i2 health_i3) d3(housing_i1), cutoff(0.3)}

{p 2 2 2} Multidimensional poverty index with user-defined weights and a cutoff of 0.3:

{p 4 2 2} . {cmd:mpi d1(education_i1 education_i2) d2(health_i1 health_i2 health_i3) d3(housing_i1 housing_i2)) w1(0.1 0.1) w2(0.2 0.05 0.05) w3(0.5), cutoff(0.3)}

{p 2 2 2} Multidimensional poverty index decomposed by geographic area, with equal weighting and a cutoff of 0.3:

{p 4 2 2} . {cmd:mpi d1(education_i1 education_i2) d2(health_i1 health_i2 health_i3) d3(housing_i1), cutoff(0.3) by(region)}

{p 2 2 2} Consider now survey data with two indicators: 'poverty1', ranging from 0 to 10, and 'poverty2', ranging from 10 to 20. A person is poor in terms of 'poverty1' at a level below 5,
but poor in terms of 'poverty2' at a level below 15. A person is poor if the person is deprived in at least one deprivation indicator. The correct specification of thresholds is given below:

{p 4 2 2} . {cmd:mpi d1(poverty1) t1(5) d2(poverty2) t2(15), cutoff(0.5)}

{p 2 2 2} Note that to identify as poor a person with poverty1=5 the corresponding threshold has to be slightly higher than 5, for example {cmd:t1(5.01)}

{title:Stored results}

{pstd}
{hi:mpi} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}Number of observations used{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}The results stored in this vector depend on the selected {cmd:post} option {p_end}
{synopt:{cmd:e(V)}}The Variance-covariance matrix of {cmd:e(b)} {p_end}

{synopt:{cmd:e(mpi_main)}}Estimates of H, M0, M1, M2 and all M({it:alpha}){p_end}
{synopt:{cmd:e(mpi_main_V)}}Variance-covariance matrix of {cmd:e(mpi_main)}{p_end}
{synopt:{cmd:e(mpi_add)}}Estimates of A, G and S{p_end}
{synopt:{cmd:e(mpi_add_V)}}Variance-covariance matrix of {cmd:e(mpi_add)}{p_end}
{synopt:{cmd:e(ind)}}Contribution of each indicator to M0, M1, M2, M({it:alpha}){p_end}
{synopt:{cmd:e(ind_V)}}Variance-covariance matrix of {cmd:e(ind)}{p_end}
{synopt:{cmd:e(dom)}}Contribution of each domain to M0, M1, M2, M({it:alpha}){p_end}
{synopt:{cmd:e(dom_V)}}Variance-covariance matrix of {cmd:e(dom)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{hi:mpi}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(properties)}}{hi:b V}{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}Observations used for the computation of {hi:mpi}{p_end}

{pstd}
When the option {cmd:by} is specified, {hi:mpi} stores also the following information:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(by_mpi)}}H, M0, M1, M2, M({it:alpha}), by level of the by-variable{p_end}
{synopt:{cmd:e(by_mpi_V)}}Variance-covariance matrix of {cmd:e(by_mpi)}{p_end}
{synopt:{cmd:e(by_mpi_pc)}}Proportional contribution of every level of the by-variable to the main indicators{p_end}
{synopt:{cmd:e(by_mpi_pc_V)}}Variance-covariance matrix of {cmd:e(by_mpi_pc)}{p_end}
{synopt:{cmd:e(by_ind)}}Contribution for each indicator to M0, M1, M2, M({it:alpha}), by level of the by-variable{p_end}
{synopt:{cmd:e(by_ind_V)}}Variance-covariance matrix of {cmd:e(by_ind)}{p_end}
{synopt:{cmd:e(by_dom)}}Contribution for each domain to M0, M1, M2, M({it:alpha}), by level of the by-variable{p_end}
{synopt:{cmd:e(by_dom_V)}}Variance-covariance matrix of {cmd:e(by_dom)}{p_end}

{p 2 2 2}Note that when a given indicator is missing the related standard errors and covariances will enter as zero
in {cmd:e()} while they will be shown as missing in the displayed results. This depends on the output
of the built-in Stata commands {cmd:mean} and {cmd:ratio}, which {cmd:mpi} runs internally to compute the indices and
the variance-covariance matrices.

{marker References}{...}
{title:References}

{p 4 2 2}Alkire, S., and J. Foster. 2008. Counting and multidimensional poverty measurement. OPHI Working Paper 7. {browse "http://www.ophi.org.uk/wp-content/uploads/ophi-wp7.pdf":www.ophi.org.uk/wp-content/uploads/ophi-wp7.pdf}.

{p 4 2 2}Alkire, Sabina & Foster, James, 2011a. "Counting and multidimensional poverty measurement," Journal of Public Economics, Elsevier, vol. 95(7), pages 476-487.

{p 4 2 2}Alkire, Sabina & Foster, James, 2011b. "Understandings and misunderstandings of multidimensional poverty measurement," Journal of Economic Inequality, Springer, vol. 9(2), pages 289-314.


{title:Further information about Multidimensional Poverty}

{p 4 2 2} {browse www.ophi.org.uk:www.ophi.org.uk}

{title:Authors}

{p 4 4 2}Daniele Pacifico, OECD{break}daniele.pacifico@oecd.org

{p 4 4 2}Felix Poege, Max Planck Institute for Innovation and Competition{break}felix.poege@ip.mpg.de
