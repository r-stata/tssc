{smcl}
{* *! version 1.1.3  8apr2021}{...}
{viewerjumpto "Syntax" "outdetect##syntax"}{...}
{viewerjumpto "Description" "outdetect##description"}{...}
{viewerjumpto "Options" "outdetect##options"}{...}
{viewerjumpto "Examples" "outdetect##examples"}{...}
{viewerjumpto "Stored results" "outdetect##results"}{...}
{viewerjumpto "Reference" "outdetect##reference"}{...}
{p2colset 1 14 19 2}{...}
{p2col:{bf: outdetect} {hline 2}}Outlier detection and diagnostics for welfare analysts
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{p 8 15 2}
{cmd:outdetect}  {it:{help varname:varname}} [{help if}] [{help in}]
[{it:{help outdetect##weight:weight}}]
	[{cmd:,} {it:{help outdetect##opts:options}}]



{marker opts}{...}
{synoptset 29 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt :{cmdab:norm:alize(}{it:{help outdetect##normtype:normtype}})}specify the transformation for normalizing {help varname}; default is {help outdetect##MV2021:Yeo and Johnson (2000)}{p_end}
{synopt :{cmdab:best:normalize}}use the best fitting transformation for normalizing {help varname}{p_end}
{synopt :{cmdab:zscore(}{it:{help outdetect##stat1:stat1}} {it:{help outdetect##stat2:stat2}})}define the {it:z}-score of the normalized variable; default is {it:{help outdetect##stat1:stat1}} = median,
{it:{help outdetect##stat2:stat2}} = Q-statistic {help outdetect##MV2021:(Rousseeuw and Croux, 1993)}{p_end}
{synopt :{opt alpha(#)}}specify the threshold of the outlier detection region; default is 3{p_end}
{synopt :{opt out:liers(bottom|top|both)}}specify whether outliers are to be flagged at the bottom, top, or on both sides of the distribution of {help varname}{p_end}
{synopt :{opt non:egative}}exclude negative values of {help varname} from all calculations{p_end}
{synopt :{opt noz:ero}}exclude zero values of {help varname} from all  calculations{p_end}
{synopt :{opt nog:enerate}}do not create {it:_out} variable{p_end}
{synopt :{opt replace}}replace existing {it:_out} variable{p_end}
{synopt :{opt rew:eight}}create a new variable containing the post-detection adjusted weights. Only if {help weights} or {help svyset} are specified{p_end}
{synopt :{opt madf:actor(#)}}specify Fisher consistency factor for median absolute deviation; default is 1.4826{p_end}
{synopt :{opt sf:actor(#)}}specify Fisher consistency factor for S-statistic; default is 1.1926{p_end}
{synopt :{opt qf:actor(#)}}specify Fisher consistency factor for Q-statistic; default is 2.2219{p_end}

{syntab:Reporting}
{synopt :{opt sformat(%fmt)}}specify format for summary statistics panel{p_end}
{synopt :{cmd:pline(# | {help varname})}}specify a poverty line and report poverty estimates{p_end}
{synopt :{cmd:excel({help filename} [, replace])}}export output in Excel{p_end}

{syntab:Graphics}
{synopt :{cmdab:g:raph(}{it:{help outdetect##gtype:gtype}})}produce diagnostic plots{p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weights}.
{p_end}
{p 4 6 2}
{help svyset} can be used to designate variables containing information about the survey design, such as the sampling units and probability weights.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:outdetect} identifies extreme values, either "too small" or "too large" observations, in the distribution of {help varname}. We shall call these observations {it:bottom outliers} and {it:top outliers}, respectively
(small values being at the bottom of the distribution of {help varname}, and large values being at the top).

{pstd}
Users may exploit {help svyset} to specify the survey design of the data before using {cmd:outdetect}.
By default, {cmd:outdetect} creates a new variable, {it:_out}, containing numeric codes that flag outliers of {help varname}:

	Numeric
	 code	  Description
	{hline 57}
	   {cmd:0}	observation is not an outlier
	   {cmd:1}      observation is a bottom outlier ("too small")
	   {cmd:2}      observation is a top outlier ("too large")
	{hline 57}

{pstd}
The output of {cmd:outdetect} reports "Raw" statistics (computed using {help varname}), as well as "Trimmed" statistics (computed using just those observations of {help varname} that are not flagged as outliers).

{pstd}
The procedure by which outliers are detected is described in {help outdetect##MV2021:Belotti et al. (2021)}, and involves two steps.
First, the distribution of the target
variable ({help varname}) is transformed to approach a standard normal distribution.
To do so, {help varname} is normalized (a transformation is applied so that its distribution approaches a Normal), then standardized (a {it:z}-score of the transformed variable is computed).
Second, a threshold is applied to the transformed variable, to set the bounds of an outlier detection region (typically corresponding to the tails of the transformed distribution).
The threshold is set at a conventional value ({it:e.g.} 3).

{pstd}
In formulas:

{pstd}
target variable (varname) = v{p_end}
{pstd}
normalized variable 	  = x 	= {it:t}(v){p_end}

{pstd}
where {it:t} is a normalizing transformation.
{p_end}

{pstd}
{it:z}-score of x 			  = z 	= (x - {it:stat1})/{it:stat2}{p_end}

{pstd}
where {it:stat1} is a measure of location and {it:stat2} is a measure of scale.{p_end}

{pstd}
alpha					  = 	  conventional threshold{p_end}

{pstd}
An observation of {it:v} is flagged as an outlier if:
{p_end}

{p 4}
|z| > alpha (both bottom and top outliers), or{p_end}
{p 5}
 z  > alpha (top outlier), or{p_end}
{p 5}
 z  < -alpha (bottom outlier).{p_end}



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt norm:alize(normtype)} specifies the method for transforming {help varname} into a distribution that approaches a Normal distribution. {it:normtype} may be selected among the following transformations:

{marker normtype}{...}
{phang2}
{cmd:normalize(yj)} applies {help outdetect##MV2021:Yeo and Johnson (2000)} (default);

{phang2}
{cmd:normalize(asinh)} applies the inverse hyperbolic sine {help outdetect##MV2021:(Friedline et al. 2014)}.

{phang2}
{cmd:normalize(bcox)} applies the Box-Cox transform {help outdetect##MV2021:(Box and Cox 1964)};

{phang2}
{cmd:normalize(ln)} applies the natural logarithm, i.e. ln(x);

{phang2}
{cmd:normalize(log10)} applies {cmd:log10(x + a)} with a = max(0, -(min(x) - 0.0001));

{phang2}
{cmd:normalize(log)} applies {cmd:log(x + a)} with a = max(0, -(min(x) - 0.0001));

{phang2}
{cmd:normalize(sqrt)} applies the square root;

{phang2}
{cmd:normalize(none)} applies no transformation ({help varname} used as is).

{phang}
{opt best:normalize} selects the best transformation according to the value of the Pearson P statistic divided by its degrees of freedom (df) {help outdetect##MV2021:(Snedecor and Cochran, 1989)}.
This ratio converges to 1 when the data approaches a Gaussian distribution.
Therefore, the Pearson/df ratio can be interpreted as a measure of how close a distribution is to normality, and used to rank transformations according to how successful they are in normalizing the data.
When this option is specified, {cmd:outdetect} stores the Pearson/df ratio corresponding to the best normalizing transformation.

{phang}
{opt zscore(stat1 stat2)} specifies the {it:z}-score of the normalized variable. If {it:x} is the normalized variable, the {it:z}-score is defined as {it: z = (x - stat1)/stat2}.

{marker stat1}{...}
{p 10}
{it:stat1} can be chosen among the following:{p_end}
{p 12}
{it:mean}, mean of {it:x};{p_end}
{p 12}
{it: median}, median of {it:x} (default);{p_end}

{marker stat2}{...}
{p 10}
{it:stat2} can be chosen among the following:{p_end}
{p 12}
{it: std}, standard deviation of {it:x};{p_end}
{p 12}
{it: mad}, median absolute deviation;{p_end}
{p 12}
{it: iqr}, interquartile range;{p_end}
{p 12}
{it: s}, S-statistic {help outdetect##MV2021:(Rousseeuw and Croux, 1993)};{p_end}
{p 12}
{it: q}, Q-statistic {help outdetect##MV2021:(Rousseeuw and Croux, 1993)} (default);{p_end}

{phang}
{opt alpha(#)} specifies the threshold of the outlier detection region, which is defined with reference to the distribution of the {it:z}-score. The default is 3, but conventional values may range between 2 and 4, depending on  the context.

{phang}
{opt out:liers(bottom|top|both)} specifies whether outliers are to be flagged at one or both sides of the distribution of {help varname}:

{p 12}
{it: bottom}, only flags bottom ("too small") outliers;{p_end}
{p 12}
{it: top}, only flags top ("too large") outliers;{p_end}
{p 12}
{it: both}, flags both bottom and top outliers (default).{p_end}

{phang}
{opt non:egative} excludes negative values of {help varname} from the detection routine, the computation of summary statistics, and all other calculations.

{phang}
{opt noz:ero} excludes zeros of {help varname} from the detection routine, the computation of summary statistics, and all other calculations.

{phang}
{opt nog:enerate} specifies that variable {it:_out} (which flags outliers of {help varname}) not be created.

{phang}
{opt replace} replaces any existing variable named {it:_out} with the new {it:_out} variable created by issuing {cmd:outdetect}.

{phang}
{opt rew:eight} creates a new variable containing the post-detection adjusted weights. The option can only be specified when {help weights} or {help svyset} are used to specify a weight variable.

{phang}
{opt madf:actor(#)} specifies the Fisher consistency factor to be applied to the median absolute deviation, if this statistic is selected for the calculation of the z-score. The default is 1.4826.

{phang}
{opt sf:actor(#)} specifies the Fisher consistency factor to be applied to the S-statistic, if this statistic is selected for the calculation of the z-score. The default is 1.1926.

{phang}
{opt qf:actor(#)} specifies the Fisher consistency factor to be applied to the Q-statistic, if this statistic is selected for the calculation of the z-score. The default is 2.2219.


{dlgtab:Reporting}

{phang}
{opt sformat(%fmt)} specifies a format for the summary statistics panel.

{phang}
{opt pline(# | varname)} specifies a poverty line, either as a scalar or as a variable. If {cmd:pline()} is specified, the output reports three poverty indices from the Foster, Greer and Thorbecke (1984) class,
namely the poverty headcount (H), poverty gap (PG), and poverty gap squared (PG2).

{phang}
{opt excel}({it:{help filename}} [, replace]) exports the output table produced by the program in Excel workbook {help filename}. If the {cmd:replace} option is specified, the existing {help filename} is overwritten.

{dlgtab:Graphics}

{phang}
{marker gtype}{...}
{opt graph}({it:gtype} [, {it:twoway_options}]) produces diagnostic plots. Any options documented in {help twoway_options} other than {cmd:by()} can be specified. {it:gtype} can be chosen among the following:

{phang2}
{cmd:qqplot} plots the quantiles of the normalized variable against the quantiles of a Normal distribution with the same mean and variance (Quantile-Quantile plot). It uses Stata's {help qnorm}. It can be used to assess the success of the normalization of {help varname}.

{phang2}
{opt itc}([{it:#} :] {help outdetect##itc_options:{it:itc_options}}) produces the Incremental Trimming Curve (ITC) for a statistic of interest {help outdetect##MV2021:(Mancini and Vecchi, 2021)}.
The ITC reports the value of the statistic of choice, as a function of how many extreme values are discarded (trimmed) from the distribution of {help varname}. Weights are adjusted at each iteration. The ITC can be used to assess the sensitivity of the statistic of interest to the choice of the outlier detection threshold. By default, the horizontal axis reports the number of trimmed observations as a percentage of all non-missing values of {help varname}, but the number can be reported in absolute terms, too.


{synoptset 20 tabbed}{...}
{synopthdr:itc_options}
{synoptline}
{synopt :{opt #}}specifies the maximum percentage of trimmed observations. Default is 10%{p_end}
{synopt :{opt abs:olute}}treats {opt #} as the number of trimmed observations{p_end}
{synopt :{opt gi:ni}}Gini index (default){p_end}
{synopt :{opt m:ean}}Sample mean{p_end}
{synopt :{opt mld}}Mean Logarithmic Deviation{p_end}
{synopt :{opt th:eil}}Theil index{p_end}
{synopt :{opt cv2}}Squared coefficient of variation{p_end}
{synopt :{opt atk0}}Atkinson index, A(0.125){p_end}
{synopt :{opt atk1}}Atkinson index, A(1){p_end}
{synopt :{opt atk2}}Atkinson index, A(2){p_end}
{synopt :{opt h}}Poverty headcount ratio{p_end}
{synopt :{opt pg}}Poverty gap index{p_end}
{synopt :{opt pg2}}Poverty gap squared index{p_end}
{synopt :{cmd:pline({help varname} | #)}}specifies the poverty line. It must be specified when {cmd:h}, {cmd:pg}, or {cmd:pg2} are specified. If only {cmd:pline({help varname} | #)} is specified, then {cmd:h} is forced{p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{pstd}Set up and default use{p_end}
{synoptline}

{pstd}Load demo data{p_end}
{phang2}{it:{stata "use https://raw.github.com/fbelotti/Stata/master/dta/hbs.dta, clear":use hbs.dta, clear}}

{pstd}Run {cmd:outdetect} using {help weights}{p_end}
{phang2}{it:{stata "outdetect pce [pweight=weight]":outdetect pce [pweight=weight]}}

{pstd}Specify survey settings before running {cmd:outdetect}{p_end}
{phang2}{it:{stata "svyset [pweight=weight]":svyset [pweight=weight]}}{p_end}
{phang2}{it:{stata "outdetect pce, replace":outdetect pce, replace}}


{pstd}Flag outliers using different normalizations, z-scores, outlier detection thresholds{p_end}
{synoptline}

{pstd}Flag outliers of pce using Box-Cox transformation and z-score based on the mean and variance{p_end}
{phang2}{it:{stata "outdetect pce, norm(bcox) zscore(mean std) replace":outdetect pce, norm(bcox) zscore(mean std) replace}}

{pstd}Flag outliers of pce using the best normalizing transformation{p_end}
{phang2}{it:{stata "outdetect pce, best replace":outdetect pce, best replace}}

{pstd}Only flag top outliers ("too large" values), and set outlier detection threshold to 2 (more "severe" than the default){p_end}
{phang2}{it:{stata "outdetect pce, out(top) alpha(2) replace":outdetect pce, out(top) alpha(2) replace}}


{pstd}Format and export summary statistics, produce diagnostic graphs{p_end}
{synoptline}

{pstd}Format summary statistics{p_end}
{phang2}{it:{stata "outdetect pce, sformat(%10.0fc) replace":outdetect pce, sformat(%10.0fc) replace}}

{pstd}Report poverty estimates and export output table in Excel{p_end}
{phang2}{it:{stata "outdetect pce, pline(300000) excel(demo, replace) replace":outdetect pce, pline(300000) excel(demo, replace) replace}}

{pstd}Generate Quantile-Quantile plot{p_end}
{phang2}{it:{stata "outdetect pce, graph(qqplot) replace":outdetect pce, graph(qqplot) replace}}

{pstd}Generate Incremental Trimming Curve (ITC) for the Gini index and poverty headcount ratio, discarding the 10% smallest and largest observations{p_end}
{phang2}{it:{stata "outdetect pce, graph(itc)":outdetect pce, graph(itc)}}{p_end}
{phang2}{it:{stata "outdetect pce, graph(itc(pline(300000)))":outdetect pce, graph(itc(pline(300000)))}}

{pstd}Generate ITC for the Gini index, discarding the 15 smallest and largest observations{p_end}
{phang2}{it:{stata "outdetect pce, graph(itc(15:abs))":outdetect pce, graph(itc(15:abs))}}

{pstd}Generate ITC for the poverty gap index, discarding the 5% smallest and largest observations and export output table in Excel{p_end}
{phang2}{it:{stata "outdetect pce, graph(itc(5:pg pline(300000))) excel(demo, replace)":outdetect pce, graph(itc(5:pg pline(300000))) excel(demo, replace)}}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:outdetect} stores the following in {cmd:r()}:

{synoptset 17 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N_raw)}}number of used observations{p_end}
{synopt:{cmd:r(N_trimmed)}}number of observations after outliers trimming{p_end}
{synopt:{cmd:r(bestnormalize)}}1 if bestnormalize, 0 otherwise{p_end}
{synopt:{cmd:r(pearson_df)}}ratio of the Pearson P statistic and df{p_end}
{synopt:{cmd:r(alpha)}}threshold used for defining the outlier detection region{p_end}


{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(normalization)}}applied normalization{p_end}
{synopt:{cmd:r(cmd)}}command name{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(out)}}matrix containing information on the outliers' incidence{p_end}
{synopt:{cmd:r(b)}}matrix containing statistics for the raw and trimmed variable{p_end}



{marker reference}{...}
{title:Reference}

{marker MV2021}{...}
{phang}
Belotti, F., Mancini, G., and Vecchi, G. 2021. {it:Outlier Detection for Welfare Analysts using Stata}. Mimeo.

{phang}
Mancini, G. and Vecchi, G. 2021. {it:On the Construction of a Consumption Aggregate for Inequality and Poverty Analysis}, World Bank, mimeo.

{phang}
Box, G. E., and Cox, D. R. 1964. {it:An analysis of transformations}. Journal of the Royal Statistical Society: Series B (Methodological), 26(2), 211-243.

{phang}
Foster, J., Greer, J., and Thorbecke, E. 1984. {it:A class of decomposable poverty measures.} Econometrica, 761-766.

{phang}
Friedline, T., Masa, R. D., and Chowa, G. A. 2015. {it:Transforming wealth: Using the inverse hyperbolic sine (IHS) and splines to predict youth’s math achievement}. Social science research, 49, 264-287.

{phang}
Rousseeuw, P. J., and Croux, C. 1993. {it:Alternatives to the median absolute deviation}. Journal of the American Statistical association, 88(424), 1273-1283.

{phang}
Snedecor, G. W., Cochran, W. G. 1989. {it:Statistical methods}. Ames: Iowa State Univ. Press.

{phang}
Yeo, I. and Johnson, R.A. 2000. {it:A new family of power transformations to improve normality or symmetry}. Biometrika, 87, 954-959.
{p_end}


{marker contact}{...}
{title:Contact}

{phang}
To report any issues, please contact Giovanni Vecchi (giovanni.vecchi@uniroma2.it).
{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Giulia Mancini{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giulia.mancini@uniroma2.it{p_end}

{pstd}Giovanni Vecchi{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giovanni.vecchi@uniroma2.it{p_end}
