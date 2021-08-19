{smcl}
{* 10Mar2021}{...}

{title:Title}

{p2colset 5 15 16 2}{...}
{p2col :{hi:xtitsa} {hline 2}}Interrupted time-series analysis for panel data {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:xtitsa} {depvar} [{indepvars}] {ifin} {weight}{cmd:,}
{cmdab:trp:eriod(}{it:{help numlist:numlist}}{cmd:)}
[{cmd:}{it:options}]

{pstd}
{it:indepvars} may contain factor variables; see {helpb fvvarlist}.
{it:depvar} and {it:indepvars} may contain time-series operators; see 
{helpb tsvarlist}.  {opt iweight}, {opt fweight}, and {opt pweight}s are allowed; see {helpb weight}.{p_end}

{pstd}
The panel data must be strongly balanced and be declared to be time-series data by using either {cmd:tsset} {it:panelvar} {it:timevar} or {cmd:xtset} {it:panelvar} {it:timevar}.  See {helpb tsset} or {helpb xtset}.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt trp:eriod}{cmd:(}{it:{help numlist:numlist}}{cmd:)}}specify the time period(s) when the intervention begins (e.g. {cmd:trperiod(2020)} or {cmd:trperiod(2001q2)} or {cmd:trperiod(21jan2020; 08feb2020)})  {p_end}
{synopt:{opt sing:le}}indicate that {cmd:xtitsa} will be used for a single-group analysis {p_end}
{synopt:{opt treat}{cmd:(}{it:{help varname:varname}}{cmd:)}}specify the binary treatment group variable. Not required when only the treatment group is in the data 
and {cmd:single} is specified {p_end}
{synopt:{opt posttr:end}}produce post-intervention trend estimates using {helpb lincom}, for the specified model {p_end}
{synopt:{opt pre:fix}{cmd:(}{it:string}{cmd:)}}add a prefix to the names of variables created by {cmd:xtitsa}. Short prefixes are recommended {p_end}
{synopt:{opt repl:ace}}replace variables created by {cmd:xtitsa} if they already exist {p_end}
{synopt:{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]}plot the average actual and predicted {it:depvar} variable over time. Specifying {cmd:figure} without options uses the default graph settings {p_end}
{synopt:[{it:model_options}]}specify all available options for {helpb xtgee}{p_end}
{synoptline}
{p 4 6 2}
{p2colreset}{...}



{title:Description}

{pstd}
{cmd:xtitsa} performs an interrupted times series analysis (ITSA) when individual-level 
data are available for analysis (panel data). Conversely, {helpb itsa} should be used 
when only aggregated (pooled) data are available for analysis. 

{pstd}
{cmd:xtitsa} estimates the effect of an intervention when the outcome variable
is ordered as an evenly-spaced time series and a number of observations are available 
in both preintervention and postintervention periods.  The study design is 
referred to as an interrupted time-series analysis because the
intervention is expected to interrupt the level or trend subsequent to its
introduction (Campbell and Stanley 1966; Glass, Willson, and Gottman 1975;
Shadish, Cook, and Campbell 2002).

{pstd}
{cmd:xtitsa} estimates treatment effects for either a single-group
(i.e., the treatment group with preintervention and postintervention observations) 
or a multiple-group comparison (that is, the treatment group is compared with a
control group).  Additionally, {cmd:xtitsa} can estimate treatment effects for
multiple treatment periods. {cmd:xtitsa} is a wrapper for {helpb xtgee} so
all available options are allowed except "eform". 


{title:Options}

{phang}
{cmd:trperiod(}{it:numlist}{cmd:)} specifies the time period when the
intervention begins.  The value(s) entered for time period(s) must be in the same
units as the panel time variable specified in {cmd:tsset} {it:timevar}; see
{helpb tsset}. Dates should be specified as human readible dates using the respective
pseudofunction (see {helpb datetime##s9:datetime}), such as {cmd:trperiod(2020)} 
for a four-digit year, or {cmd:trperiod(2019m11)} for quarterly data. 
Multiple periods may be specified, separated by a semicolon, as follows
{cmd:trperiod(2019m6; 2019m11)}; {cmd:trperiod()} is required.

{phang}
{cmd:single} indicates that {cmd:xtitsa} will be used for a single-group
analysis.  Conversely, omitting {cmd:single} indicates that {cmd:xtitsa} is for
a multiple-group comparison.

{phang}
{cmd:treat(}{it:varname}{cmd:)} indicates the binary treatment variable (where the control group
is equal to 0 and the treatment group is equal to 1). When the dataset contains data for
only the treatment group, {cmd:treat()} must be omitted.

{phang}
{cmd:posttrend} produces posttreatment trend estimates using {helpb lincom},
for the specified model.  In the case of a single-group ITSA, one estimate is
produced.  In the case of a multiple-group ITSA, an estimate is produced for
the treatment group, the control group, and the difference.  In the case of
multiple treatment periods, a separate table is produced for each treatment
period.

{phang}
{cmd:prefix(}{it:string}{cmd:)} adds a prefix to the names of variables
created by {cmd:xtitsa}.  Short prefixes are recommended.

{phang}
{cmd:replace} replaces variables created by {cmd:xtitsa} if they already exist.
If {cmd:prefix()} is specified, only variables created by {cmd:xtitsa} with the
same prefix will be replaced.

{phang}
{cmd:figure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}] produces
a line plot of the average predicted {it:depvar} variable combined with a scatterplot
of the average actual values of {it:depvar} over time. Specifying {cmd:figure} 
without options uses the default graph settings.

{phang}
{it:model_options} specify all available options for {helpb xtgee}.


{title:Remarks} 

{pstd}
Regression (with methods to account for autocorrelation) is the most commonly
used modeling technique in interrupted time-series analyses.  When there is
only one group under study (no comparison groups), the regression model
assumes the following form (Simonton 1977a, 1977b; Huitema and McKean 2000;
Linden and Adams 2011):

{pmore}
Y_t = Beta_0 + Beta_1(T) + Beta_2(X_t) + Beta_3(TX_t){space 5}(1)

{pstd}
Here Y_t is the aggregated outcome variable measured at each equally spaced
time point t, T is the time since the start of the study, X_t is a dummy
(indicator) variable representing the intervention (preintervention periods 0,
otherwise 1), and TX_t is an interaction term.

{pstd}
In the case of a single-group study, Beta_0 represents the intercept or
starting level of the outcome variable.  Beta_1 is the slope or trajectory of
the outcome variable until the introduction of the intervention.  Beta_2
represents the change in the level of the outcome that occurs in the period
immediately following the introduction of the intervention (compared with the
counterfactual).  Beta_3 represents the difference between preintervention and
postintervention slopes of the outcome.  Thus we look for significant p-values
in Beta_2 to indicate an immediate treatment effect, or in Beta_3 to indicate
a treatment effect over time (Linden and Adams 2011).  However, single-group
ITSA models may provide misleading results, so multiple-group ITSA models
should be implemented whenever possible (Linden 2017b and 2017c).

{pstd}
When a control group is available for comparison, the regression
model in (1) is expanded to include four additional terms (Beta_4 to Beta_7)
(Simonton 1977a, 1977b; Linden and Adams 2011):

{pmore} Y_t = Beta_0 + Beta_1(T) + Beta_2(X_t) + Beta_3(TX_t) +
Beta_4(Z) + Beta_5(ZT) + Beta_6(ZX_t) + Beta_7(ZTX_t){space 5}(2)

{pstd}
Here Z is a dummy variable to denote the cohort assignment (treatment or
control), and ZT, ZX_t, and ZTX_t are all interaction terms among previously
described variables.  Now the coefficients Beta_0 to Beta_3 represent the
control group, and the coefficients Beta_4 to Beta_7 represent values of the
treatment group.  More specifically, Beta_4 represents the difference in the
level (intercept) of the dependent variable between treatment and controls
prior to the intervention, Beta_5 represents the difference in the slope
(trend) of the dependent variable between treatment and controls prior to the
intervention, Beta_6 indicates the difference between treatment and control
groups in the level of the dependent variable immediately following
introduction of the intervention, and Beta_7 represents the difference between
treatment and control groups in the slope (trend) of the dependent variable
after initiation of the intervention compared with preintervention (akin to a
difference-in-differences of slopes).

{pstd}
The two parameters Beta_4 and Beta_5 play a particularly important role in
establishing whether the treatment and control groups are balanced on both the
level and the trajectory of the dependent variable in the preintervention
period.  If these data were from a randomized controlled trial, we would
expect similar levels and slopes prior to the intervention.  However, in an
observational study where equivalence between groups cannot be ensured, any
observed differences will likely raise concerns about the ability to draw
causal inferences about the relationship between the intervention and the
outcomes (Linden and Adams 2011).  See Linden (2017a) for many
additional ITSA postestimation measures.


{title:Examples}

{pstd}
There are three general scenarios in which {cmd:xtitsa} can be implemented: 1) a
single-group ITSA when the dataset contains data for the treatment group only, 
2) a single-group ITSA in a dataset where there are also other data, and 
3) a multiple-group ITSA:

{pstd}
{opt 1) Single-group ITSA (treatment group only):}{p_end}

{pmore}
Load data and declare the dataset as time series: {p_end}

{pmore2}{bf:{stata "use xtitsa_example_single.dta, clear":. use xtitsa_example_single.dta, clear}}{p_end}
{pmore2}{bf:{stata "tsset id month": . tsset id month}} {p_end}

{pmore}
We specify a single-group ITSA with period 2019m11 as the start of the intervention.
We then plot the results and produce a table of the posttreatment trend estimates.

{phang3}{bf:{stata "xtitsa y, single trperiod(2019m11) vce(robust) posttrend figure": . xtitsa y, single trperiod(2019m11) vce(robust) posttrend figure}}{p_end}

{pmore}
We now generate residuals and test them for autocorrelation using {helpb actest} with the robust option.{p_end}

{phang3}{bf:{stata "gen resid = y - _s__y_pred": . gen resid = y - _s__y_pred}}{p_end}
{phang3}{bf:{stata "actest resid, lags(12) robust": . actest resid, lags(12) robust}}{p_end}

{pmore}
We see from the output that there is autocorrelation up to lag 9, so we reestimate the model specifying an autoregressive correlation.{p_end}

{phang3}{bf:{stata "xtitsa y, single trperiod(2019m11) vce(robust) posttrend figure replace corr(ar 9)": . xtitsa y, single trperiod(2019m11) vce(robust) posttrend figure replace corr(ar 9)}}{p_end}

{pmore}
We specify a single-group ITSA for a fractional response (i.e. 0 to 1.0 scale) with family(binomial) link(logit) and vce(robust) {p_end}

{phang3}{bf:{stata "xtitsa y01, single trperiod(2019m11) family(binomial) link(logit) vce(robust) figure posttr replace":. xtitsa y01, single trperiod(2019m11) family(binomial) link(logit) vce(robust) figure posttr replace}} {p_end}

{pstd}
{opt 2) Single-group ITSA in dataset with other data:}{p_end}

{pmore}
Load multiple-panel data and declare the dataset as panel: {p_end}

{phang3}{bf:{stata "use xtitsa_example.dta, clear":. use xtitsa_example.dta, clear}}{p_end}
{phang3}{bf:{stata "tsset id month":. tsset id month}}{p_end}

{pmore}
We specify a single-group ITSA with the variable z as the treatment group 
and period 2019m11 as the start of the intervention, plot
the results, and produce a table of the posttreatment trend estimates.

{phang3}{bf:{stata "xtitsa y, single treat(z) trperiod(2019m11) vce(robust) posttrend figure": . xtitsa y, single treat(z) trperiod(2019m11) vce(robust) posttrend figure}}{p_end}

{pmore}
Same as above, but we specify corr(ar 9) to fit an AR(9) model.

{phang3}{bf:{stata "xtitsa y, single treat(z) trperiod(2019m11) vce(robust) posttrend figure replace corr(ar 9)":. xtitsa y, single treat(z) trperiod(2019m11) vce(robust) posttrend figure replace corr(ar 9)}}{p_end}

{pmore}
Here we specify two treatment periods - 2019m6 and 2019m11.

{phang3}{bf:{stata "xtitsa y, single treat(z) trperiod(2019m6; 2019m11) vce(robust) posttrend replace fig":. xtitsa y, single treat(z) trperiod(2019m6; 2019m11) vce(robust) posttrend replace fig}} {p_end}

{pstd}
{opt 3) Multiple-group ITSA (treatment vs control):}{p_end}

{pmore}
We specify a multiple-group ITSA by omitting {cmd:single}. The variable z includes both treatment and control observations. {p_end}

{phang3}{bf:{stata "xtitsa y, treat(z) trperiod(2019m11) vce(robust) posttrend figure replace":. xtitsa y, treat(z) trperiod(2019m11) vce(robust) posttrend figure replace}}{p_end}

{pmore}
We specify a multiple-group ITSA for a fractional response (i.e. 0 to 1.0 scale) with family(binomial) link(logit) and vce(robust) {p_end}

{phang3}{bf:{stata "xtitsa y01, treat(z) trperiod(2019m11) family(binomial) link(logit) vce(robust) figure replace":. xtitsa y01, treat(z) trperiod(2019m11) family(binomial) link(logit) vce(robust) figure replace}} {p_end}


{marker output_table}{...}
{title:Output table}

{pstd}
{cmd:xtitsa} produces several variables, as defined under {cmd:Remarks} above.
Below is a cross reference to default names for those variables that appear in
the regression output tables (and used when {cmd:posttrend} is specified).
Variables starting with {cmd:_z} are added to the dataset only when a
multiple-group comparison is specified.  {cmd:(trperiod)} is a suffix added to
certain variables indicating the start of the intervention period.  This is
particularly helpful for differentiating between added variables when multiple
interventions are specified.  If the user specifies a {cmd:prefix()}, it will
be applied to all variables generated by {cmd:xtitsa}.

{synoptset 18}{...}
{synopt:Variable}Description{p_end}
{synoptline}
{synopt:{cmd:_}{it:depvar}}dependent variable{p_end}
{synopt:{cmd:_t}}time since start of study{p_end}
{synopt:{cmd:_x(trperiod)}}dummy variable representing the intervention periods (preintervention periods {cmd:0}, otherwise {cmd:1}){p_end}
{synopt:{cmd:_x_t(trperiod)}}interaction of {cmd:_x} and {cmd:_t}{p_end}
{synopt:{cmd:_z}}dummy variable to denote the cohort assignment (treatment or control){p_end}
{synopt:{cmd:_z_x(trperiod)}}interaction of {cmd:_z} and {cmd:_x}{p_end}
{synopt:{cmd:_z_x_t(trperiod)}}interaction of {cmd:_z}, {cmd:_x}, and {cmd:_t}{p_end}
{synopt:{cmd:_s_}{it:depvar}{cmd:_pred}}predicted value generated after running {cmd:xtitsa} for a single group {p_end}
{synopt:{cmd:_m_}{it:depvar}{cmd:_pred}}predicted value generated after running {cmd:xtitsa} for a multiple-group comparison {p_end}
{synoptline}
{p2colreset}{...}


{title:Acknowledgments}

{p 4 4 2}
I thank Kit Baum for assisting with the {helpb actest} specification. 


{title:References}

{phang}
Campbell, D. T., and J. C. Stanley. 1966. 
{it:Experimental and Quasi-Experimental Designs for Research.}
Chicago: Rand McNally.

{phang}
Glass, G. V., V. L. Willson, and J. M. Gottman. 1975. 
{it:Design and Analysis of Time-Series Experiments.} 
Boulder, CO: Colorado Associated University Press.

{phang}
Huitema, B. E., and J. W. McKean. 2000.
Design specification issues in time-series intervention models.
{it:Educational and Psychological Measurement}
60: 38-58.

{phang}
Linden, A. 2015.
{browse "http://www.stata-journal.com/article.html?article=st0389":Conducting interrupted time series analysis for single and multiple group comparisons}.
{it:Stata Journal}.
15: 480-500.

{phang}
------. 2017a.
{browse "http://www.stata-journal.com/article.html?article=st0389_3":A comprehensive set of postestimation measures to enrich interrupted time-series analysis}.
{it:Stata Journal}
17: 73-88.

{phang}
------. 2017b.
Challenges to validity in single-group interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}.
23: 413-418.

{phang}
------. 2017c.
Persistent threats to validity in single-group interrupted time series analysis with a crossover design.
{it:Journal of Evaluation in Clinical Practice}.
23: 419-425.

{phang} 
Linden, A., and J. L. Adams. 2011. 
Applying a propensity-score based weighting model to interrupted time
series data: Improving causal inference in program evaluation. 
{it:Journal of Evaluation in Clinical Practice} 
17: 1231-1238.

{phang}
Linden, A., and P. R. Yarnold. 2016.
Using machine learning to identify structural breaks in single-group
interrupted time series designs.
{it:Journal of Evaluation in Clinical Practice}
22: 855-859.

{phang}
Shadish, S. R., T. D. Cook, and D. T. Campbell. 2002.
{it:Experimental and Quasi-Experimental Designs for Generalized Causal Inference.} 
Boston: Houghton Mifflin.

{phang} 
Simonton, D. K. 1977a. 
Cross-sectional time-series experiments: Some suggested statistical analyses. 
{it:Psychological Bulletin} 
84: 489-502.

{phang} 
Simonton, D. K. 1977b. Erratum to Simonton. {it:Psychological Bulletin}
84: 1097.


{marker citation}{title:Citation of {cmd:xtitsa}}

{p 4 8 2}{cmd:xtitsa} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2021). XTITSA: Stata module to perform interrupted time-series analysis with panel data.{p_end}



{title:Author}

{pstd}Ariel Linden{p_end}
{pstd}Linden Consulting Group, LLC{p_end}
{pstd}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
       
 
{p 7 14 2}Help: {helpb actest} (if installed), {helpb itsa} (if installed), {helpb xtgee}, {helpb lincom} {p_end}
