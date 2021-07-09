
{smcl}

{* *! version 2.1.0 23Dec2019}
{cmd:help pmcalplot}
{hline}

{title:Title}

{phang}
{bf:pmcalplot} {hline 2} Calibration plot of prediction model performance

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:pmcalplot} {varlist} {ifin} [,{it:Pmcalplot_general_options}  {it:Binary_outcome_options} {cmdab:surv:ival} {it:Survival_outcome_options}  {cmdab:cont:inuous} {it:Continuous_outcome_options}  {it:Twoway_options}]

{pstd}
where {it:varlist} varies dependent on the type of outcome of interest (binary, survival or continuous). See below for requirements and options relevant to each outcome type.
General options available for all outcome types are given below.
{p_end}

{synoptset 30}{...}
{synopthdr:pmcalplot_general_options}
{synoptline}
{synopt :{opt nost:atistics}}suppresses display of performance statistics{p_end}
{synopt :{opt r:ange(# #)}}a range describing the square size of the plot region{p_end}
{synopt :{opt sc:atteropts(string)}}twoway options to affect rendition of the groups{p_end}
{synopt :{opt ci:opts(string)}}twoway options to affect rendition of the confidence intervals{p_end}
{synopt :{opt keep}}returns variables for the expected, observed & risk groups{p_end}
{synopt :{opt zoom}}zooms the graph area to fit the risk groups and their CI's{p_end}
{synopt :{it:twoway_options}}all other twoway options{p_end}

{synoptline}

{phang}
{bf:Binary outcomes (Logistic prediction models)}

{pstd}
For binary outcome models {it:varlist} must consist of two variables; the first variable must represent the predicted probabilities from the model (a variable in the range [0,1]). 
The second variable must represent the event indicator i.e. the observed outcome (a binary variable coded 0 for non-events and 1 for events). 
{p_end}

{synoptset 30}{...}
{synopthdr:binary_outcome_options}
{synoptline}
{synopt :{opt b:in(int 10)}}number of bins used to group patients average observed & expected probabilities{p_end}
{synopt :{opt cut:points(numlist)}}unequal cutpoints used to group patients average observed & expected probabilities{p_end}
{synopt :{opt ci}}displays 95% confidence intervals for groups{p_end}
{synopt :{opt nol:owess}}suppresses display of the lowess smoother{p_end}
{synopt :{opt nosp:ike}}suppresses display of the spike plot{p_end}
{synopt :{opt lo:wessopts(string)}}twoway options to affect rendition of the lowess smoother{p_end}
{synopt :{opt sp:ikeopts(string)}}twoway options to affect rendition of the spike plot{p_end}
{synoptline}

{phang}
{bf:Survial outcomes (Cox prediction models)}

{pstd}
For survial outcomes {it:varlist} must consist of only one variable; the first variable must represent the predicted probabilities from the model (a variable in the range [0,1]). 
The observed outcome probabilities are calculated by {cmd:pmcalplot} using Kaplan-Meier estimates.
NOTE: Predicted probabilites provided in {it:varlist} must represent the probability of an event, i.e. 1-S(t).
{p_end}

{synoptset 30}{...}
{synopthdr:survival_outcome_options}
{synoptline}
{synopt :{opt surv:ival}}option required to tell {cmd: pmcalplot} survival outcomes are being used (uses KM estimates for observed data){p_end}
{synopt :{opt t:imepoint(int 1)}}timepoint at which observed & expected probabilities are to be compared{p_end}
{synopt :{opt lp(varname numeric)}}variable name representing the linear predictor values based on the development model, for all patients{p_end}
{synopt :{opt b:in(int 10)}}number of bins used to group patients average observed & expected probabilities{p_end}
{synopt :{opt cut:points(numlist)}}unequal cutpoints used to group patients average observed & expected probabilities{p_end}
{synopt :{opt ci}}displays 95% confidence intervals for groups{p_end}
{synopt :{opt nosp:ike}}suppresses display of the spike plot{p_end}
{synopt :{opt sp:ikeopts(string)}}twoway options to affect rendition of the spike plot{p_end}
{synoptline}

{phang}
{bf:Continuous outcomes (Linear prediction models)}

{pstd}
For continuous outcomes {it:varlist} must consist of two variables; the first variable must represent the predicted outcome values. 
The second variable must represent the observed outcome values. 
{p_end}

{synoptset 30}{...}
{synopthdr:continuous_outcome_options}
{synoptline}
{synopt :{opt cont:inuous}}option required to tell {cmd: pmcalplot} continuous outcomes are being used{p_end}
{synopt :{opt p(int 0)}}number of variables used in development model{p_end}
{synopt :{opt nol:owess}}suppresses display of the lowess smoother{p_end}
{synopt :{opt noh:ist}}suppresses display of the histograms for observed and expected outcomes{p_end}
{synopt :{opt lo:wessopts(string)}}twoway options to affect rendition of the lowess smoother{p_end}
{synopt :{opt obshi:stopts(string)}}twoway options to affect rendition of the histogram of observed values{p_end}
{synopt :{opt exphi:stopts(string)}}twoway options to affect rendition of the histogram of expected values{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}{cmd: pmcalplot} produces a calibration plot of observed against expected probabilities for assessment of prediction model performance. 
Calibration is plotted in groups across the risk spectrum as recommended in the TRIPOD guidelines, and confidence intervals for the groupings can also be displayed (NB: not for continuous outcomes). 
Further, a spike plot of the distribution of events and non-events can be displayed on the plot, as well as a lowess smoother allowing assessment of the calibration at the individual patient level 
[NB: Spike plot and lowess smoother for survival outcomes is work in progress]. 
For continuous outcomes a histogram of observed and expected values can be displayed on the corresponding axes.
Additionally, common prediction model performance statistics can also be displayed on the plot, quantifying the models performance. 

{pstd}{cmd: pmcalplot} is primarily useful for assessment of model performance in an external validation of an existing model. 
However it can also be used during model development to check the apparent performance of the model (which should show perfect calibration). 

{marker options}{...}
{title:General Options}

{phang}{opt nostatistics} specifies that the model performance statistics are not calculated and displayed on the calibration plot (note this may be computationally faster).

{phang}{opt range(# #)} specifies a new plot range given two real numbers. The plot range must lie within the bounds of 0 and 1 for binary and survival outcome models. For continuous outcome models the range is dependent on the outcome measure.
Both axes are forced to have the same range so that the plot remains square in line with the TRIPOD guidelines. The default range is 0 to 1 for binary & survival outcome models.

{phang}{opt zoom} automatically 'zooms' the plot range to fit the risk groups and their CI's. Lowess and spike plots are only plotted within the 'zoomed' ranged. The {opt range()} option overides {opt zoom}. 
Useful for prediction models with a narrow range of predictions.

{phang}{opt scatteropts(string)} specifies any additional options to describe the rendition of the scatter plot. See {helpb scatter}.

{phang}{opt ciopts(string)} specifies any additional options to describe the rendition of the confidence intervals. See {helpb twoway_rspike}.

{phang}{opt keep} specifies that variables for the expected, observed & risk groups defined by {cmd: pmcalplot} be retained in the dataset after the program terminates.

{phang}{it:twoway_options} controls all other graph options, e.g. legend layout, axis titles etc. See {helpb twoway_options}.

{marker options}{...}
{title:Binary outcome options}

{phang}{opt bin(int 10)} specifies the number of equally sized percentiles to divide the predicted risks into. The default is to divide the predicted risks into 10 equally sized groups.

{phang}{opt cutpoints(numlist)} specifies cutpoints to divide the predicted risks into. 
{it:numlist} should contain a list of real numbers in the range [0,1] to define risk thresholds for grouping. 
The {opt cutpoints()} option is a useful alternative to the default when validating an existing prediction model with defined risk thresholds to group patients (allowing unequal group sizes).
It is advisable not to use the {opt cutpoints()} option unless the model has prespecified clinically relevant cut-points.

{phang}{opt ci} specifies that 95% confidence intervals for the observed proportions be added to the plot.

{phang}{opt nolowess} specifies that the lowess smoother not be calculated and displayed on the calibration plot (note this may be computationally faster).

{phang}{opt nospike} specifies that the spike plot not be displayed on the calibration plot.

{phang}{opt lowessopts(string)} specifies any additional options to describe the rendition of the lowess smoother. See {helpb lowess}.

{phang}{opt spikeopts(string)} specifies any additional options to describe the rendition of the spike plot. See {helpb twoway_rspike}.

{marker options}{...}
{title:Survival outcome options}

{phang}{opt survival} option required to tell {cmd: pmcalplot} survival outcomes are being used.

{phang}{opt timepoint(int 1)} specifies a single timepoint at which observed & expected probabilities are to be compared. Units of time are defined by the {cmd: stset} command prior to using {cmd: pmcalplot}. Default = 1 unit of time. 
NOTE: User must provide predicted probabilities at the specific time point of interest. 
This will usually require some estimate of the baseline survival or baseline hazard at the specified time point. 
Please consult the TRIPOD guidelines if unsure. See {helpb sts_list}, {helpb stset}.

{phang}{opt lp(varname numeric)} if a variable containing the linear predictor values for patients in the dataset is provided, then some performance statistics can be displayed on the plot. 
Such a variable should be available as it is used in the calculation of predicted/expected risks which must be given in {it:varlist} for survival outcome models.

{phang}{opt bin(int 10)} specifies the number of equally sized percentiles to divide the predicted risks into. The default is to divide the predicted risks into 10 equally sized groups.

{phang}{opt cutpoints(numlist)} specifies cutpoints to divide the predicted risks into. 
{it:numlist} should contain a list of real numbers in the range [0,1] to define risk thresholds for grouping. 
The {opt cutpoints()} option is a useful alternative to the default when validating an existing prediction model with defined risk thresholds to group patients (allowing unequal group sizes).
It is advisable not to use the {opt cutpoints()} option unless the model has prespecified clinically relevant cut-points.

{phang}{opt ci} specifies that 95% confidence intervals for the observed proportions be added to the plot.

{phang}{opt nospike} specifies that the spike plot not be displayed on the calibration plot. Spike plot for survival models, plots the events and non-events at the timepoint of interest.

{phang}{opt spikeopts(string)} specifies any additional options to describe the rendition of the spike plot. See {helpb twoway_rspike}.

{marker options}{...}
{title:Continuous outcome options}

{phang}{opt continuous} option required to tell {cmd: pmcalplot} continuous outcomes are being used.

{phang}{opt p(int 0)} if the number of variables included in the development model is provided, then R-squared adjusted can additionally be calculated and displayed on the plot. 
NOTE: p is the number of variables in the published model to be validated.

{phang}{opt nolowess} specifies that the lowess smoother not be calculated and displayed on the calibration plot (note this may be computationally faster).

{phang}{opt lowessopts(string)} specifies any additional options to describe the rendition of the lowess smoother. See {helpb lowess}.

{phang}{opt nohist} specifies that the histograms not be displayed on the calibration plot.

{phang}{opt obshistopts(string)} specifies any additional options to describe the rendition of the histogram of observed values (y-axis histogram). See {helpb histogram}.

{phang}{opt exphistopts(string)} specifies any additional options to describe the rendition of the histogram of expected values (x-axis histogram). See {helpb histogram}.

{marker examples}{...}
{title:Examples}

{phang}
{bf:Binary outcomes (Logistic prediction models)}

{pstd}Load dataset{p_end}
{phang2}{cmd:. }{stata webuse lbw, clear}{p_end}

{pstd}For illustration only, create a binary variable to define a development and validation cohort{p_end}
{phang2}{cmd:. }{stata gen val = runiform()<.4}{p_end}

{pstd}Derive a prediction model for low birth weight in the development cohort{p_end}
{phang2}{cmd:. }{stata logistic low age lwt i.race smoke ptl ht ui if val==0}{p_end}

{pstd}Generate a new variable containing the predicted probabilities from the model for all individuals{p_end}
{phang2}{cmd:. }{stata predict p_dev}{p_end}

{pstd}Use {cmd: pmcalplot} to produce a calibration plot of the apparent performance of the development model in the development cohort{p_end}
{phang2}{cmd:. }{stata pmcalplot p_dev low if val==0, ci}{p_end}

{pstd}Now produce the calibration plot for the models performance in the validation cohort{p_end}
{phang2}{cmd:. }{stata pmcalplot p_dev low if val==1, ci}{p_end}

{pstd}We can also remove elements of the calibration plot such as the spike plot and performance statistics{p_end}
{phang2}{cmd:. }{stata pmcalplot p_dev low if val==1, ci nospike nostatistics}{p_end}

{pstd}Other twoway options can be used to alter the rendition of the calibration plot such as to remove the legend or alter titles{p_end}
{phang2}{cmd:. }{stata pmcalplot p_dev low if val==1, ci nospike nostatistics xtitle("Predicted probability", size(medsmall)) ytitle("Observed frequency", size(medsmall)) legend(off)}{p_end}

{pstd}Now produce the calibration plot for the models performance in the validation cohort using risk thresholds of <5%, 5-15%, 15-50% and >50%. This is useful if the model has been proposed for decision making at these thresholds.
Use the {opt keep} option to return the groupings to your dataset{p_end}
{phang2}{cmd:. }{stata pmcalplot p_dev low if val==1, cut(.05 .15 .5) ci keep}{p_end}

{phang}
{bf:Survial outcomes (Cox prediction models)}

{pstd}Load dataset{p_end}
{phang2}{cmd:. }{stata webuse drugtr, clear}{p_end}

{pstd}Fit a flexible parametric survival model & predict survival probabilities for individuals at 10 year follow-up{p_end}
{phang2}{cmd:. }{stata stset}{p_end}
{phang2}{cmd:. }{stata stpm2 drug age, df(3) scale(h)}{p_end}
{phang2}{cmd:. }{stata gen time1 = 10}{p_end}
{phang2}{cmd:. }{stata predict p_surv, s timevar(time1)}{p_end}

{pstd}Derive the probability of an event i.e. 1-S(t) (where S(t) is the probability of survival){p_end}
{phang2}{cmd:. }{stata gen p_event = 1-p_surv}{p_end}

{pstd}Use {cmd: pmcalplot} to produce a calibration plot of the apparent performance of the development model in the development cohort{p_end}
{phang2}{cmd:. }{stata pmcalplot p_event, ci surv t(10)}{p_end}

{pstd}Derive the linear predictor for all individuals{p_end}
{phang2}{cmd:. }{stata predict lp, xbnobaseline}{p_end}

{pstd}Feed the linear predictor to {cmd: pmcalplot} to produce a calibration plot including performance statistics for the apparent performance of the model{p_end}
{phang2}{cmd:. }{stata pmcalplot p_event, ci surv t(10) lp(lp)}{p_end}

{phang}
{bf:Continuous outcomes (Linear prediction models)}

{pstd}Load dataset{p_end}
{phang2}{cmd:. }{stata sysuse auto, clear}{p_end}

{pstd}Derive a prediction model for mpg in the development cohort{p_end}
{phang2}{cmd:. }{stata regress mpg weight foreign}{p_end}

{pstd}Generate a new variable containing the predicted values from the model for all individuals{p_end}
{phang2}{cmd:. }{stata predict exp}{p_end}

{pstd}Use {cmd: pmcalplot} to produce a calibration plot of the apparent performance of the development model in the development cohort. 
Telling {cmd: pmcalplot} the number of factors in the model also allows R-squared adjusted to be calculated{p_end}
{phang2}{cmd:. }{stata pmcalplot exp mpg, cont p(2)}{p_end}

{pstd}Now set the range & histogram axes to better include all data in {cmd: pmcalplot}{p_end}
{phang2}{cmd:. }{stata pmcalplot exp mpg, cont r(10 50) obshi(ylab(10(10)50)) exphi(xlab(10(10)50))}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:pmcalplot} stores the following in {cmd:r()} when the option {opt nostatistics} is not specified (as relevant for specific outcome types):

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(cstat)}}C-statistic for model discrimination{p_end}
{synopt:{cmd:r(eo_ratio)}}Ratio of expected and observed events for model calibration{p_end}
{synopt:{cmd:r(citl)}}Calibration-in-the-large for model calibration{p_end}
{synopt:{cmd:r(cslope)}}Calibration slope for model calibration{p_end}
{synopt:{cmd:r(r2)}}R-squared for overall model performance (linear models){p_end}
{synopt:{cmd:r(r2a)}}R-squared for overall model performance adjusted for optimism (linear models){p_end}
{p2colreset}{...}

{title:Authors}

{phang}Joie Ensor, Keele University {break}
j.ensor@keele.ac.uk{p_end}

{phang}Kym IE. Snell, Keele University{p_end}

{phang}Emma C. Martin, University of Leicester{p_end}

{title:Acknowledgements}

{phang}With thanks to Kenneth Pihl, Rebecca Whittle & Rupert Major for helpful feedback{p_end}

{marker reference}{...}
{title:References}

{p 5 12 2}
Ensor J, Snell KIE, Martin EC. Investigation of prediction model performance with Stata: pmstats and pmcalplot. 2018; {it:In preparation}.{p_end}

{title:Also see}

{psee}
Online: {helpb twoway_options}, {helpb lowess}, {helpb roctab}
{p_end}