{smcl}
{* *! version v0.0.0.9000 25jun2018}{...}
{title:Title}

{phang}
{bf:bfmcorr} {hline 2} Correct surveys using tax data with the method of Blanchet, Flores and Morgan (2018)

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bfmcorr} {cmd:using} {it:{help filename}}{cmd:,} {opt w:eight(varname)} {opt inc:ome(varname)} {opt hou:seholds(varname)} {opt taxu:nit(i|h)} {{opt trust:start(real)}|{opt merg:ingpoint(real)}} [, {it:options}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Inputs}
{synopt:{cmd:using} {it:{help filename}}}file containing the tabulated tax data; it should follow the {browse "http:wid.world/gpinter":gpinter} format;
supports Stata, CSV and Excel files;
see {help bfmcorr##taxdata:input tax data} for details{p_end}
{synopt:{opth w:eight(varname)}}variable referring to the original survey weights;
the weights must be nonmissing, greater or equal to one and be identical within households;
they are assumed to sum up to the population size;
see {help bfmcorr##surveydata:input survey data} for details{p_end}
{synopt:{opth inc:ome(varname)}}survey variable referring to income; this is the variable that drives non-response in the method;
see {help bfmcorr##surveydata:input survey data} for details{p_end}
{synopt:{opth hou:seholds(varname)}}survey variable identifying households;
see {help bfmcorr##surveydata:input survey data} for details{p_end}
{synopt:{opt taxu:nit(i|h)}}if starting with {it:i}, the distribution in the tax data refers to individuals;
if starting with {it:h}, the distribution in the tax data refers to households;
see {help bfmcorr##taxdata:input tax data} for details{p_end}
{synopt:{opt trust:start(real)}}fractile beyond which the tax data is assumed to be reliable;
must be strictly between zero and one;
see {help bfmcorr##mergingpoint:merging point} for details{p_end}
{synopt:{opt merg:ingpoint(real)}}fractile to use as the merging point;
if not specified, it is determined automatically (this is the recommended choice);
must be strictly between zero and one;
see {help bfmcorr##mergingpoint:merging point} for details{p_end}

{syntab:Calibration}
{synopt:{opth taxinc:ome(varname)}}variable referring to the income concept in the tax data, where it is distinct from the default variable in {opt inc:ome}; 
if not specified, the income concept in survey data and tax data are taken to be equivalent;
see {help bfmcorr##reference:reference}, particularly section 2.2.2, for details{p_end}
{synopt:{opth holdmar:gins(varlist)}}variables whose distribution must remain constant during the calibration;
only categorical variables are supported (typically gender and age groups);
see {help bfmcorr##calibration:calibration} for details{p_end}
{synopt:{opth varmar:gins(varlist)}}dummy variables whose average should take a given value after calibration;
see {help bfmcorr##calibration:calibration} for details{p_end}
{synopt:{opth freqmar:gins(numlist)}}values of the averages for the variables in the option {opt varmar:gins};
see {help bfmcorr##calibration:calibration} for details{p_end}
{synopt:{opth incomecomp:osition(numlist)}}file containing the taxable income composition by taxable income bracket;
see {help bfmcorr##calibration:calibration} for details{p_end}
{synopt:{opth incomepop:ulation(numlist)}}file containing the population composition by taxable income bracket;
see {help bfmcorr##calibration:calibration} for details{p_end}

{syntab:Options}
{synopt:{opt min:bracket(real)}}minimum number of survey observations required in each tax bracket;
brackets with less survey observations than this value are automatically grouped into larger ones;
default is 5 observations{p_end}
{synopt:{opt thetalim:it(real)}}constrains the number of times weights are expanded or reduced;
brackets with a theta coefficient outside the boundary defined by 1/n<=theta<=n are automatically grouped into larger ones;
default is 5; thus theta cannot be smaller than 0.2 or larger than 5 in this case; 
the theta coefficient is the ratio of frequencies in the survey data and tax data by income bracket; see {help bfmcorr##reference:reference} for details{p_end}
{synopt:{opt size:top(real)}}target number of observations to be created at the top of the distribution;
default is 50 000;
see {help bfmcorr##newobservations:new observations} for details{p_end}
{synopt:{opt samp:letop(real)}}target sampling rate (fraction of the population in the sample) at the top of the distribution for the creation of new observations;
default is 0.05 (for 5%);
see {help bfmcorr##newobservations:new observations} for details{p_end}
{synopt:{opt k:nn(real)}}number of nearest neighbors to draw from in the imputation procedure; default is 10;
see {help bfmcorr##newobservations:new observations} for details{p_end}
{synopt:{opt norep:lace}}do not create new observations at the top; only perform the calibration{p_end}
{synopt:{opt sl:ope(real)}}baseline value of the elasticity of nonresponse to income;
only used if an extrapolation is required to estimate the merging point;
default is -1;
see {help bfmcorr##mergingpoint:merging point} for details{p_end}
{synopt:{opt pe:nalization(real)}}penalization of the deviation from the baseline elasticity of nonresponse to income;
the lower it is, the closer the extrapolation will be to the available data, at the cost of greater instability;
default is 20;
see {help bfmcorr##mergingpoint:merging point} for details{p_end}
{synopt:{opt taxp:erc(name)}}name of the column with bracket fractiles in the tax data;
default is {it:p};
see {help bfmcorr##taxdata:input tax data} for details{p_end}
{synopt:{opt taxt:hr(name)}}name of the column with bracket thresholds in the tax data;
default is {it:thr};
see {help bfmcorr##taxdata:input tax data} for details{p_end}
{synopt:{opt taxa:vg(name)}}name of the column with bracket averages in the tax data;
default is {it:bracketavg};
see {help bfmcorr##taxdata:input tax data} for details{p_end}

{synoptline}
{pstd}
The command changes the data in memory without any warning.
It creates the following variables: {it:_correction}, {it:_weight}, {it:_pid}, {it:_hid} and {it:_factor}. See {help bfmcorr##results:results} for details.
If any of these variables exists in the data, the command will generate an error.
See {help postbfm} for features available after the estimation.

{marker description}{...}
{title:Description}

{pstd}
{cmd:bfmcorr} improves the representativeness of survey data at the top of the income distribution using tax data.
It reweights the observations and creates new ones to obtain a new survey sample that is consistent with the information
in the tax data but otherwise replicates all the statistical properties of the survey in terms of covariates,
household structure and behavior at the bottom of the income distribution.

{pstd}
The command treats the data in memory as the survey data to be corrected, and corrects them using an external file
containing the tabulated tax data. The methodology combines a calibration procedure that simulatenously corrects
the representativeness of the survey along the different dimensions with a replacement/imputation procedure that increases
the number of observations at the top to get better estimates of top tail inequality.

{marker taxdata}{...}
{title:Input tax data}

{pstd}
The argument {cmd:using} {it:{help filename}} specifies the file containing the tax data to use for the correction.
The tax data should take the form of a tabulation that indicates (at least) bracket fractiles, bracket thresholds and bracket averages, using the following form:

{pmore}
{hline 60}{break}
{space 9}p{space 10}{space 8}thr{space 9}{space 5}bracketavg{break}
{hline 60}{break}
{space 11}0{space 8}{space 14}0{space 7}{space 10}190{break}
{space 8}0.01{space 8}{space 12}378{space 7}{space 10}568{break}
{space 8}0.02{space 8}{space 12}757{space 7}{space 10}947{break}
{space 9}...{space 8}{space 12}...{space 7}{space 10}...{break}
{space 5}0.99997{space 8}{space 5}10,597,050{space 7}{space 3}12,059,701{break}
{space 5}0.99998{space 8}{space 5}13,889,397{space 7}{space 3}17,180,048{break}
{space 5}0.99999{space 8}{space 5}22,006,175{space 7}{space 3}64,444,108{break}
{hline 60}

{pstd}
This format corresponds to the output of the online tool {browse "http://wid.world/gpinter":gpinter} and its associated R package.
We recommend that you use it to process your raw tax data and retrieve a detailed distribution of income.

{pstd}
You can change the default column names of the example above if you need to with the options {opt taxp:erc(name)}, {opt taxt:hr(name)} and {opt taxa:vg(name)}.
The default names correspond to the default output of {browse "http://wid.world/gpinter":gpinter}.

{pstd}
The distributional unit of observation in the tax data usually refers to either individuals or households.
You must use the option {opt taxu:nit(i|h)} to specify which one it is.
If you specify {it:i} or any other string starting with {it:i}, then the tax data must correspond to the distribution of individual incomes.
If you specify {it:h} or any other string starting with {it:h}, then the tax data must correspond to the distribution of household incomes.
You should make sure that the population of reference in the tax data is the same as the population in the survey data:
in particular, children should either be removed from the survey data or added to the tax data with zero income.

{pstd}
The command supports Stata, CSV and Excel files. The type of the file is determined automatically from its extension.

{marker surveydata}{...}
{title:Input survey data}

{pstd}
The command treats the data in memory as the survey data to be corrected.
Each observation must correspond to an individual.
You must specify the following variables:

{phang}
{opt hou:seholds(varname)} variable that uniquely identifies each household;
there can be an arbitrary number of individuals within households.

{phang}
{opt w:eight(varname)} variable containing the original survey weights;
these weights should be nonmissing, greater or equal to one and are assumed to sum up to the total number of individuals in the population;
weights have to be constant within households. If this is not the case, we recommend to replace existing weights with the average individual weight within households.

{phang}
{opt inc:ome(varname)} income variable to use.
You need to make sure that the income concept that you use matches, as close as possible, the income concept in the tax data. If the concepts are unreconcilable, then you can specify the tax income concept in the option {opt taxinc:ome}, which will be accounted for in the calibration.
This variable should be equal to zero for individuals with no income (including children if any).
If you specify the option {opt taxu:nit(h)}, then this variable should refer to household income, i.e. the sum of all individual incomes within the household.
As a consequence, it should be identical for all the household members.

{pstd}
All the other variables in your data are presserved and are treated as covariates.

{marker mergingpoint}{...}
{title:Merging point}

{pstd}
The "merging point" is the point above which we start using the tax data to adjust the survey data.
The command contains a data-driven procedure that automatically selects an appropriate merging point by comparing the survey and the tax data.
If you wish to bypass this procedure, you can do so by specifying the following option (although this is not recommended):

{phang}
{opt merg:ingpoint(real)} specify your own merging point, by-passing the normal procedure.
It should be specified as a fractile of the income distribution, strictly between zero and one.

{pstd}
In general, you should let the command determine the merging point itself. In this case, you need the specify the following option:

{phang}
{opt trust:start(real)} point from which the tax data is assumed to be reliable. 
It should be specified as a fractile of the income distribution, strictly between zero and one.

{pstd}
In the best scenario, the trustable span of the tax data covers enough of the distribution to observe the merging point directly.
In this case, the command will display the message "merging point found within trust region".
Sometimes this isn't true, so the program needs to extrapolate the shape of the bias {it:theta(income)} into the lower part of the distribution.
To do so, it assumes the relationship:

{pin}
log({it:theta(income)}) = b0 + b1*log({it:income})

{pstd}
at the top of the distribution. The coefficients {it:b0} and {it:b1} are estimated from the available data and reported by the command.
They are estimated using a ridge regression with a baseline value for {it:b1} noted {ul:{it:b1}} and a penalization term {it:lambda} that discourages deviations from this baseline value.
Formally, the ridge regression minimizes:

{pin}
{it:lambda}*({it:b1} - {ul:{it:b1}})^2 + sum of (log({it:theta(income)}) - b0 - b1*log({it:income}))^2

{pstd}
when {it:lambda} = 0, this correspond to the standard OLS regression. When {it:lambda} goes to infinity, this amounts to imposing the value {it:b1} = {ul:{it:b1}}.
Intermediate values of {it:lambda} can be interpreted in a bayesian way, where {ul:{it:b1}} is the central value of our prior and {it:lambda} controls how tight the prior is.
The main goal is to only deviate from this prior to the extent that our data provide a compelling enough reason to do so.
This leads to much more reliable results in situations where the data are limited to provide any information about the overall shape of the bias.
These two parameters can be controlled using the following options:

{phang}
{opt sl:ope(real)} value of the baseline {ul:{it:b1}};
default is -1. Thus in this case, when income is higher by 1%, the person is 1% less likely to be represented in the survey. 

{phang}
{opt pe:nalization(varname)} value of the penalization {it:lambda};
default is 20.

{marker calibration}{...}
{title:Calibration}

{pstd}
The calibration procedure improves the representativeness of the survey along several dimensions at the same time.
The main point of the method is to ensure the survey's representativeness of top incomes using the tax data.
But the procedure can also preserve or enforce representativeness of other variables, and can enforce representativeness
in terms of the composition of taxable income, or the composition of the population by income bracket.

{pstd}
First, there are variables for which the survey is assumed to be already representative, for instance because it was already reweighted using census data.
In this case, there are some variables whose distribution should be left unchanged by the calibration procedure.
They typically correspond to gender and age groups. These variables should be specified using the following argument:

{phang}
{opth holdmar:gins(varlist)} variables whose distribution whould be left constant in the calibration procedure.
The command only supports categorical variables. For better results, the number of categories should preferrably not be too high,
although larger survey samples usually allow for more categories.{p_end}

{pstd}
The second case corresponds to variables for which the survey is not currently representative, but for which we want to enforce representativeness based on external data.
These variables and their distribution should be specified using the following arguments:

{phang}
{opth varmar:gins(varlist)} a {it:varlist} of dummy variables whose average (i.e. the frequency of ones) should be enforced by the calibration. A typical example could be gender.

{phang}
{opth freqmar:gins(numlist)} a {it:numlist} of averages between zero and one, matching the variables in the option {opt varmar:gins}.

{pstd}
The third case happens when we have additional information on the composition of taxable income by income bracket (ie. share of capital income),
and/or additional information on population characteristics by income brackets (ie. fraction of women). These data should be specified in their
own files using the following arguments:

{phang}
{opth incomecomp:osition(filename)} the name of a file with the composition of taxable income by taxable income bracket.
Supports Stata, CSV and Excel files. The file must have the following format:

{pmore}
{hline 60}{break}
{space 9}thr{space 10}{space 8}labor{space 9}{space 5}capital{break}
{hline 60}{break}
{space 8}1000{space 8}{space 11}0.93{space 7}{space 10}0.07{break}
{space 8}2000{space 8}{space 11}0.90{space 7}{space 10}0.10{break}
{space 8}3000{space 8}{space 11}0.88{space 7}{space 10}0.12{break}
{space 9}...{space 8}{space 12}...{space 7}{space 11}...{break}
{space 7}10000{space 8}{space 11}0.62{space 7}{space 10}0.38{break}
{space 7}15000{space 8}{space 11}0.53{space 7}{space 10}0.47{break}
{space 7}20000{space 8}{space 11}0.41{space 7}{space 10}0.59{break}
{hline 60}

{pstd}
where {it:thr} refers to thresholds of the taxable income variable, and the other columns are shares of each income source
in the corresponding income bracket. For example, here, 93% of the income of people earning between 1000 and 2000 in total comes from
labor, while 7% comes from capital income. Each column name other than {it:thr} should correspond to a variable in the dataset,
otherwise it will be ignored with a warning.

{phang}
{opth incomepop:ulation(filename)} the name of a file with the composition of population by taxable income bracket.
Supports Stata, CSV and Excel files. The file must have the following format:

{pmore}
{hline 60}{break}
{space 9}thr{space 10}p{space 8}women{space 9}{space 3}employees{break}
{hline 60}{break}
{space 8}1000{space 7}0.10{space 9}0.60{space 7}{space 10}0.90{break}
{space 8}2000{space 7}0.15{space 9}0.56{space 7}{space 10}0.88{break}
{space 8}3000{space 7}0.30{space 9}0.53{space 7}{space 10}0.89{break}
{space 9}...{space 8}...{space 10}...{space 7}{space 11}...{break}
{space 7}10000{space 7}0.90{space 9}0.37{space 7}{space 10}0.74{break}
{space 7}15000{space 7}0.95{space 9}0.31{space 7}{space 10}0.71{break}
{space 7}20000{space 7}0.99{space 9}0.25{space 7}{space 10}0.69{break}
{hline 60}

{pstd}
where {it:thr} refers to thresholds of the taxable income variable, {it:p} refers to the corresponding fractile in the tax data, and the other columns refer the frequency of a
given population characteristics in the tax data. For example, here, people earning between 1000 and 2000 represent 5% of the population and are between the 10% and the 15%
fractile. Among them, 60% of are women, and 90% are employees. Each column name other than {it:thr} should correspond to a dummy variable in the dataset
equal to 1 if the observation belongs to the population category, and 0 otherwise.

{pstd}
{bf:WARNING:} using too many variables in the calibration can cause convergence of the algorithm to fail. This is true in particular
of the variables introduced by the arguments {opt incomecomp:osition} and {opt incomepop:ulation}, since the command does not attempt
to regroup categories with too few observations automatically. If you get convergence issues, you can try regrouping variables
or income brackets for composition data into fewer categories, and/or use a higher value for the {opt thetalim:it} and {opt min:bracket} arguments.

{marker newobservations}{...}
{title:New observations}

{pstd}
While the calibration ensures the overall representativeness of the survey, the limited sample size of surveys can make it impossible to
properly convey the shape of the very top of the distribution. For this reason, we complement the adjustment of the weights with a replacement/imputation
procedure that creates new observations at the top following the tax data distribution and fills in the household structure and the covariates using
a nearest-neighbor imputation method that preserves the statistical properties of the data.

{pstd}
This part of the method is of little interest if the goal is to use income as a covariate, as opposed to precisely estimating the income distribution
itself. Therefore it can be switched off using the following option:

{phang}
{opt norep:lace} do not create new observations at the top, only perform the calibration{p_end}

{pstd}
Otherwise, you can control the procedure using the following options:

{phang}
{opt samp:letop(real)} target sampling rate (fraction of the population in the sample) at the top of the distribution for the creation of new observations;
default is 0.05 (for 5%), which means that the generated survey sample will be 5% of the total population at the top. If the population is large,
then this can take a lot of time and use a lot of memory. Adjusting this value will not change any linearly weighted statistic. Note that the imputation procedure takes longer if you have individual
tax data because the program has to reconstruct the household structure.{p_end}

{phang}
{opt k:nn(real)} number of nearest neighbors to draw from in the imputation procedure. Default is 10.{p_end}

{marker results}{...}
{title:Results}

{pstd}
The command changes the data in memory directly. The data left in the memory correspond to the corrected survey.
The command creates a handful of new variables:

{phang}
{bf:_weight} The new, corrected weights. These are the weights that should be used in all subsequent estimation procedures.

{phang}
{bf:_factor} During the imputation procedure, the program generates new observations based on the income distribution
in the tax data, and then attributes them the covariates of a survey observation with a similar income. For income-related
covariates, such as income subcomponents, this can create small inconsistencies in the data because the sum of income
subcomponents may not exactly sum to total income anymore. To avoid these problems, we recommend multiplying all
income related variables by {bf:_factor}, which contains the ratio of imputed to original income. By construction, this
variable is equal to 1 for reweighted observations.

{phang}
{bf:_correction} Indicates wether an observation was reweighted or replaced during the procedure.

{phang}
{bf:_hid} Newly generated household IDs. These properly identify households that were generated as part of the imputation procedure.

{phang}
{bf:_pid} Newly generated individual IDs. These properly identify individuals that were generated as part of the imputation procedure.

{title:Stored results}

{pstd}
{cmd:bfmcorr} stores the following in {bf:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(mergingpoint)}}location of the merging point as a fractile{p_end}
{synopt:{cmd:e(truststart)}}beginning of the trustable span{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(income_var)}}name of the income variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(theta)}}estimates of the bias for each tax bracket{p_end}
{synopt:{cmd:e(beta_ridge)}}coefficient of the ridge regression for the extrapolation{p_end}
{synopt:{cmd:e(mat_lorenz_old)}}Lorenz curve for the unadjusted distribution{p_end}
{synopt:{cmd:e(mat_sum_old)}}summary statistics for the unadjusted distribution{p_end}
{synopt:{cmd:e(adj_factors)}}calibrtion factors{p_end}

{marker reference}{...}
{title:Reference}

{pstd}
Blanchet, T., Flores, I. and Morgan, M. (2018). {browse "https://wid.world/document/the-weight-of-the-rich-improving-surveys-using-tax-data-wid-world-working-paper-2018-12/": The Weight of the Rich: Improving Surveys Using Tax Data}. WID.world Working Paper Series No. 2018/12.

{title:Contact}

{pstd}
If you have comments, suggestions, or experience any problem with this command, please contact
Thomas Blanchet ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":thomas.blanchet@wid.world}),
Ignacio Flores ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":i.floresbeale@gmail.com}) and
Marc Morgan ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":marc.morgan@psemail.eu}).

