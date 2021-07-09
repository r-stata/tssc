{smcl}
{* 14Jul2018}{...}
{title:Title}

{p2colset 5 17 22 2}{...}
{p2col :{hi:itsarand} {hline 2}} Randomization tests for single-case and multiple-baseline AB phase designs  {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:itsarand} {depvar} [{indepvars}] {ifin} {weight}{cmd:,}
{opt treat(varname)}
[ {opt blm:in(#)}
{opt trm:in(#)}
{opt lev:el}
{opt rep:s(#)}
{opt seed(#)}
{opt nodots}
{opt left}
{opt right}
{opt ci(#)} 
{bf:{ul:sav}ing(}{it:filename}{bf:, ...)} ]


{pstd}
 A dataset for a single panel must be declared to be time-series data by using {cmd:tsset} {it:timevar}.  When the dataset contains multiple panels, a strongly balanced
    panel dataset using {cmd:tsset} {it:panelvar} {it:timevar} must be declared. See {helpb tsset}.{p_end}


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt treat(varname)}}specifies the treatment variable{p_end}
{synopt:{opt blm:in(#)}}specifies the minimum number of periods in the baseline; default is {cmd:2}{p_end}
{synopt:{opt trm:in(#)}}specifies the minimum number of periods in the intervention; default is {cmd:2}{p_end}
{synopt:{opt lev:el}}specifies that the difference in the {it:level} between treatment and baseline periods be analyzed; default is difference in {cmd:trend}{p_end}
{synopt :{opt rep:s(#)}}perform {it:#} random permutations; default is {cmd:reps(100)}{p_end}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synopt :{opt nodots}}suppress replication dots{p_end}
{synopt :{opt left}|{opt right}}compute one-sided p-values; default is two-sided{p_end}
{synopt :{opt ci(#)}}set confidence level; default is {cmd:ci(95)}{p_end}
{synopt :{help prefix_saving_option:{bf:{ul:sav}ing(}{it:filename}{bf:, ...)}}}save
        results to {it:filename}; or {it: replace} existing saved file{p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}* {opt treat(varname)} must be specified.{p_end}
{p 4 6 2}{opt aweight}s, {opt fweight}s and {opt iweight}s are allowed; see
{help weight}.{p_end}


{title:Description}

{pstd}
{cmd:itsarand} performs randomization tests on interrupted time series (ITS) data for a single-case AB design 
and multiple-baseline AB phase designs (i.e. multiple single-case AB phase designs) and estimates {it:p}-values on
the basis of Monte Carlo simulations (see Dugard et al. [2012] and Edgington & Onghena [2007] for comprehensive discussions).


   
{title:Options}

{phang}
{cmd:treat(}{it:varname}{cmd:)} specifies the treatment variable, whcih is typically coded as 0 for baseline observations and 1 for 
observations in the intervention period. {cmd:treat(}{it:varname}{cmd:)} is required.

{phang}
{cmd:blmin(}{it:#}{cmd:)} specifies the minimum number of observations to retain in the baseline period; default is {cmd:2}.

{phang}
{cmd:trmin(}{it:#}{cmd:)} specifies the minimum number of observations to retain in the treatment period; default is {cmd:2}.

{phang}
{cmd:level} specifies that the test statistic should be the difference between treatment and baseline period in the {it:levels}; the 
default test statistic is difference between the treatment and baseline period {it:trends}.

{phang}
{cmd: reps(#)} specifies the number of random permutations to perform. The default is 100.

{phang}
{cmd: seed(#)} sets the random-number seed.  Specifying this option is
equivalent to typing the following command prior to calling {cmd:itsarand}:

{pin2}
{cmd:. set seed} {it:#}

{phang}
{cmd: nodots} suppresses display of the replication dots.

{phang}
{opt left} or {opt right} requests that one-sided p-values be computed.
If {opt left} is specified, an estimate of Pr(T* {ul:<} T) is produced, where
T* is the test statistic and T is its observed value.  If {opt right} is
specified, an estimate of Pr(T* {ul:>} T) is produced.  By default, two-sided
p-values are computed; that is, Pr(|T*| {ul:>} |T|) is estimated.

{phang}
{cmd: ci(#)} specifies the confidence level, as a percentage,
for confidence intervals. The default is {cmd:level(95)} or as set by 
{helpb level:set level}.

{phang}
{cmd: saving(filename [, replace])} creates a Stata data file ({cmd:.dta} file) consisting of a variable containing the 
replicates for the test statistic (labeled either level or trend, accordingly).



{title:Remarks} 

{pstd}
For an effect to be interpreted as causal using a single-case AB phase design, 
the intervention must be introduced at a randomly determined point in time. The permuted {it:p}-value can 
then be computed by randomly reassigning the start of the intervention to all other points in time 
(avoiding the first and last few time points (by specifying {cmd: blmin(#)} and {cmd: trmin(#)}, respectively)
to ensure a sufficient number of observations are available in pre-intervention or intervention periods) and calculating 
the desired test statistic. The permuted {it:p}-value is thus the proportion of all permutations with test statistics (i.e. difference
in the levels or trends of the outcome begtween the two periods) as extreme, or more extreme, than the test statistic of the actual sample. 

{pstd}
The multiple-baseline design is an extension of the basic single-case ITS design in which multiple single-units each 
undergo their own single-case ITSA, but the intervention is assigned in a randomly staggered way to each
unit (similar in concept to the stepped-wedge design). To compute permuted {it:P}-values, each unit is analyzed separately 
(as described above for the single-case) and the results are meta-analyzed to provide an aggregate score.

{pstd}
The test statistic computed by {cmd: itsarand} is based on the basic regression model for a single-group ITSA as follows [Linden and Adams 2011; Linden 2015; Linden 2017]:

{pmore}
Y_t = Beta_0 + Beta_1(T) + Beta_2(X_t) + Beta_3(TX_t){space 5} (1)

{pstd}
Here Y_t is the aggregated outcome variable measured at each equally spaced
time point t, T is the time since the start of the study, X_t is a dummy
(indicator) variable representing the intervention (preintervention periods 0,
otherwise 1), and TX_t is an interaction term that represents the difference between
pre- and post-intervention trends.

{pstd}
{cmd: itsarand} uses the form of the regression in Equation 1 to produce the difference-in-trend
estimate (Beta_3) as the test statistic when the user specifies the {cmd: trend} option (this is achieved by simply not 
specifying {cmd: level}). When there are multiple panels, Equation 1 is estimated for each unit separately
and the Beta_3 coefficients are summed across all units. When the user specifies the difference-in-levels test 
statistic (by specifying {cmd: level}), then a regression is estimated in which the outcome Y_t is regressed on X_t alone. 
In the case of multiple panels, a separate regression is estimated for each unit and the coefficients for X_t are summed. 


{title:Examples}

{pmore}
Load data and declare the dataset as panel: {p_end}

{pmore2}{bf:{stata "use multibaseline, clear":. use multibaseline, clear}}{p_end}
{pmore2}{bf:{stata "tsset id t": . tsset id t}} {p_end}

{pmore}
We run a randomization test for multiple-baselines (i.e. multiple units) and specify that there should be at least 4 observations in
both the baseline and treatment periods, and the test statistic is the difference in pre- and post-intervention levels. We save the 2000 permuted
values to a file named "test".{p_end}

{phang3}{bf:{stata "itsarand y, treat( treat) saving(test) blmin(4) trmin(4) level reps(2000)": . itsarand y, treat( treat) saving(test) blmin(4) trmin(4) level reps(2000)}}{p_end}

{pmore}
Same as above, but we specify {it:trend} as the test statistic (by not including the {cmd: level} option). We replace the existing file named "test".{p_end}

{phang3}{bf:{stata "itsarand y, treat( treat) saving(test, replace) blmin(4) trmin(4) reps(2000)": . itsarand y, treat( treat) saving(test, replace) blmin(4) trmin(4) reps(2000)}}{p_end}

{pmore}
Same as above, but we limit the analysis to a single case (ID 1), specifiy that no dots be shown, and set the seed.{p_end}

{phang3}{bf:{stata "itsarand y if id==1, treat( treat) saving(test, replace) blmin(4) trmin(4) reps(2000) nodots seed(1234)": . itsarand y if id==1, treat( treat) saving(test, replace) blmin(4) trmin(4) reps(2000) nodots seed(1234)}}{p_end}


{title:Stored results}

{pstd}
{cmd:itsarand} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(c)}}count when the event is true{p_end}
{synopt:{cmd:r(n)}}number of nonmissing results{p_end}
{synopt:{cmd:r(p)}}observed proportions{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(xstat)}}T(obs){p_end}


{title:References}

{phang}
Dugard P, File P, Todman J. {it:Single-case and Small-n Experimental Designs}. 
New York: Routledge, 2012.

{phang}
Edgington ES, Onghena P. {it:Randomization tests (4th ed.)}. 
Boca Raton, FL: Chapman & Hall/CRC, 2007.

{phang}
Linden A. 2015.
Conducting interrupted time series analysis for single and multiple group comparisons.
{it:Stata Journal}
15: 480-500.

{phang}
------. 2017a.
A comprehensive set of postestimation measures to enrich interrupted time-series analysis}.
{it:Stata Journal}
17: 73-88.

{phang}
------. 2017b.
Challenges to validity in single-group interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}
23: 413-418.

{phang}
------. 2017c.
Persistent threats to validity in single-group interrupted time series analysis with a crossover design.
{it:Journal of Evaluation in Clinical Practice}
23: 419-425.

{phang}
------. 2018a.
A matching framework to improve causal inference in interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}
24: 408-415.

{phang}
------. 2018b.
Using permutation tests to enhance causal inference in interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}
24: 496-501.

{phang}
------. 2018c.
Combining synthetic controls and interrupted time series analysis to improve causal 
inference in program evaluation.
{it:Journal of Evaluation in Clinical Practice} 
24: 447-453.

{phang}
------. 2018d.
Using group-based trajectory modelling to enhance causal inference in interrupted time series analysis. 
{it:Journal of Evaluation in Clinical Practice}
24: 502-507.

{phang}
------. 2018e.
Using forecast modelling to evaluate treatment effects in single-group interrupted time series analysis. 
{it:Journal of Evaluation in Clinical Practice}
DOI: 10.1111/jep.12946

{phang}
------. 2018f.
Using Randomization tests to assess treatment effects in multiple-group interrupted time series analysis. 
{it:Journal of Evaluation in Clinical Practice}
DOI: 10.1111/jep.12995	

{phang}
Linden A, Yarnold PR. 2018
Using machine learning to evaluate treatment effects in multiple-group interrupted time series analysis. 
{it:Journal of Evaluation in Clinical Practice} 
DOI: 10.1111/jep.12966

{phang} 
Linden A, Adams JL. 2011. 
Applying a propensity-score based weighting model to interrupted time series data: Improving causal inference in program evaluation. 
{it:Journal of Evaluation in Clinical Practice} 
17: 1231-1238.


{marker citation}{title:Citation of {cmd:itsarand}}

{p 4 8 2}{cmd:itsarand} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2018). ITSARAND: Stata module for conducting randomization tests for single-case and multiple-baseline AB phase designs  {p_end}


{title:Author}

{pstd}Ariel Linden{p_end}
{pstd}Linden Consulting Group, LLC{p_end}
{pstd}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
       
 
{title:Also see}

{p 7 14 2}Help:  {helpb permute}, {helpb statsby}, {helpb itsa} (if installed)  {p_end}
