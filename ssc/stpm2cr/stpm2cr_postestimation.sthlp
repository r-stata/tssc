{smcl}
{* *! version 2.3 11Nov2018}{...}
{cmd:help stpm2cr postestimation} 
{right:also see:  {help stpm2cr}}
{hline}

{title:Title}

{p2colset 5 34 36 2}{...}
{p2col :{hi:[ST] stpm2cr postestimation} {hline 2}}Post-estimation tools for stpm2cr{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following standard post-estimation commands are available:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_adjust2
{p2col :{helpb estat##predict:estat}}post estimation statistics{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb stpm2 postestimation##predict:predict}}predictions, residuals etc{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}


{p 8 16 2}
{cmd:predict} {newvar} {ifin} [{cmd:,} {it:statistic} ]


{phang}
Note: in the table below, {it:vn} is an abbreviation for {it:varname}. Each cause-specific prediction is stored in {newvar}{cmd:_c#} where {cmd:#} is the indicator value. 

{synoptset 35 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt cumh:azard}}cumulative subdistribution hazard{p_end}
{synopt :{opt cumo:dds}}cumulative odds{p_end}
{synopt :{opt cure:d}}cure proportion{p_end}
{synopt :{opt subdens:ity}}subdensity function{p_end}
{synopt :{opt subh:azard}}subdistribution hazard function{p_end}
{synopt :{opt csh}}cause-specific hazard function{p_end}
{synopt :{opt shrn:umerator(vn # [vn # ...])}}numerator for (time-dependent) subdistribution hazard ratio{p_end}
{synopt :{opt shrd:enominator(vn # [vn # ...])}}denominator for (time-dependent) subdistribution hazard ratio{p_end}
{synopt :{opt chrn:umerator(vn # [vn # ...])}}numerator for (time-dependent) cause-specific hazard ratio{p_end}
{synopt :{opt chrd:enominator(vn # [vn # ...])}}denominator for (time-dependent) cause-specific hazard ratio{p_end}
{synopt :{opt cifdiff1(vn # [vn # ...])}}1st cumulative incidence function for difference in cumulative incidence functions{p_end}
{synopt :{opt cifdiff2(vn # [vn # ...])}}2nd cumulative incidence function for difference in cumulative incidence functions{p_end}
{synopt :{opt cifratio}}relative contribution to overall risk of a cause-specific cumulative incidence function{p_end}
{synopt :{opt stdp}}standard error of predicted function{p_end}
{synopt :{opt time:var(vn)}}time variable used for predictions (default {cmd:_t}){p_end}
{synopt :{opt unc:cured}}obtain cause-specific cumulative incidence and subdistribution hazard functions for the 'uncured'{p_end}
{synopt :{opt xb}}the linear predictor{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}

{syntab:Subsidiary}
{synopt :{opt dxb}}derivative of linear predictor{p_end}
{synopt :{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} 
Statistics are available both in and out of sample; type
{cmd:predict} {it:...} {cmd:if e(sample)} {it:...} if wanted only for the
estimation sample.{p_end}
{p 4 6 2} 


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = 50. This is a useful way to obtain
out of sample predictions. Note that if {opt at()} is used together
with {opt zeros} all covariates not listed in {opt at()}
are set to zero. If {opt at()} is used without {opt zeros} then
all covariates not listed in {opt at()} are set to their sample
values. See also {opt zeros}.

{phang}
{opt cifdiff1(varname # ...)}, {opt cifdiff2(varname # ...)} predicts
the difference in cause-specific cumulative incidence functions with the first 
cause-specific cumulative incidence function defined by the covariate values 
listed for {opt cifdiff1()} and the second by
those listed for {opt cifdiff2()}. By default, covariates not specified
using either option are set to zero. Note that setting the remaining values
of the covariates to zero may not always be sensible. If {it:#} is set to
missing ({cmd:.}) then {it:varname} takes its observed values in the dataset.

{pmore}
Example: {cmd:cifdiff1(stage 1)} (without specifying {cmd:cifdiff2()})
computes the difference in predicted cause-specific cumulative incidence functions at {cmd:stage}
= 1 compared with {cmd:stage} = 0 and all other covariates are set to 0.

{pmore}
Example: {cmd:cifdiff1(stage 2) cifdiff2(stage 1)} computes the difference in
predicted cause-specific cumulative incidence functions at {cmd:stage} = 2 compared with {cmd:stage} = 1.

{pmore}
Example: {cmd:cifdiff1(stage 2 age 50) cifdiff2(stage 1 age 30)}
computes the difference in predicted cause-specific cumulative incidence functions at
{cmd:stage} = 2 and {cmd:age} = 50 compared with {cmd:stage} = 1
and {cmd:age} =30.

{phang}
{opt cifratio} predicts the relative contribution of failing from an event to the overall
cumulative incidence function. For example, if the event of interest is in cancer, this is the
relative contribution of dying fromcancer to the total mortality.

{phang}
{opt csh} predicts the cause-specific hazard function.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt cumsubhazard} predicts the cumulative subdistribution hazard function.

{phang}
{opt cumodds} predicts the cumulative odds of failure function.

{phang}
{opt cure} predicts the cause-specific cure proportion after fitting a cure model.

{phang}
{opt subdensity} predicts the sub-density function.

{phang}
{opt subhazard} predicts the subdistribution hazard function.

{phang}
{opt shrdenominator(varname # ...)} and {opt chrdenominator(varname # ...)} 
specifies the denominator of the cause-specific hazard ratio or subdistribution 
hazard ratio for a specific cause. By default, all covariates not specified using 
this option are set to zero. See the cautionary note in {\opt chrnumerator} 
and {\opt shrnumerator}  below. If {it:#} is set to missing ({cmd:.}) 
then {it:varname} takes its observed values in the dataset.

{phang}
{opt shrnumerator(varname # ...)} and {opt chrnumerator(varname # ...)} predicts 
the (time-dependent) cause-sepcific or subdistribution hazard ratio
with the numerator of the hazard ratio for a particular cause. By default all covariates other than
{it:varname} and any other variables mentioned are set to zero. Note that
setting the remaining values of the covariates to zero may not always be
sensible, particularly with models other than on the cumulative subdistribution hazard scale,
or when more than one variable has a time-dependet effect. If {it:#} is set
to missing ({cmd:.}) then {it:varname} takes its observed values in the dataset.

{phang}
{opt stdp} calculates standard error of prediction and stores it in
{newvar}{cmd:_se}. Only available for the {opt xb}, {opt dxb},
{opt xbnobaseline} and {opt rmst} options.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions.
Default {it:varname} is {cmd:_t}. This is useful for large datasets where 
for plotting purposes predictions are only needed for 200 observations for example. 
Note that some caution should be taken when using this option as predictions may be 
made at whatever covariate values are in the first 200 rows of data.
This can be avoided by using the {opt at()} option and/or the {opt zeros} option to 
define the covariate patterns for which you require the predictions.

{phang}
{opt uncured} can be used after fitting a cure model. It can be used with the
{cmd:cif} or the {cmd:subhazard} options to base predictions 
for the 'uncured' group.

{phang}
{opt xb} predicts the linear predictor, including the spline function.

{phang}
{opt zeros} sets all covariates to zero (baseline prediction). For 
example, {cmd:predict s0, survival zeros} calculates the baseline
survival function. See also {opt at()}.

{dlgtab:Subsidiary}

{phang}
{opt centol(#)} defines the  tolerance when searching for predicted
suvival time at a given centile of the survival distribution. Default
{it:#} is 0.0001.

{phang}
{opt dxb} calculates the derivative of the linear predictor.

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by (help set level}.


{title:Examples}

{pstd}Setup{p_end}

{phang2}{stata "use http://www.stata-journal.com/software/sj4-2/st0059/prostatecancer"}{p_end}
{phang2}{stata "stset time, failure(status==1, 2, 3) scale(12) id(id) noshow"}{p_end}
{phang2}{stata "tab treatment, gen(trt)"}{p_end}

{pstd}Proportional subdistribution hazards model{p_end}
{phang2}{stata "stpm2cr [prostate: , scale(hazard) df(4)] [CVD: , scale(hazard) df(4)] [other: , scale(hazard) df(4)], events(status) cause(1 2 3) cens(0) eform"}{p_end}

{phang2}{stata "predict cif, cif ci"}{p_end}
{phang2}{stata "gen CVD = cif_c1 + cif_c2"}{p_end}
{phang2}{stata "gen Other = CVD + cif_c3"}{p_end}
{phang2}{stata "gen Cancer = cif_c1"}{p_end}
{phang2}{stata "twoway (area Other _t, sort) (area CVD _t, sort) (area Cancer _t, sort), ylab(0(0.2)1) ytitle(Cumulative Incidence)"}{p_end}

{pstd}Time-dependent effects on cumulative hazard scale{p_end}
{phang2}{stata "stpm2cr [prostate: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)] [CVD: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)] [other: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)], events(status) cause(1 2 3) cens(0) eform"}{p_end}

{pstd}Use of at() option{p_end}
{phang2}{stata "predict cif_trt2, cif at(trt1 0 trt2 1) ci"}{p_end}
{phang2}{stata "gen CVD_trt2 = cif_c1 + cif_trt2_c2"}{p_end}
{phang2}{stata "gen Other_trt2 = CVD_trt2 + cif_trt2_c3"}{p_end}
{phang2}{stata "gen Cancer_trt2 = cif_trt2_c1"}{p_end}
{phang2}{stata "twoway (area Other_trt2 _t, sort) (area CVD_trt2 _t, sort) (area Cancer_trt2 _t, sort), ylab(0(0.2)1) ytitle(Cumulative Incidence)"}{p_end}

{pstd}Obtain relative and absolute predictions{p_end}
{phang2}{stata "predict shr_trt2, shrnumerator(trt2 1) shrdenominator(trt1 1) ci"}{p_end}
{phang2}{stata "line shr_trt2_c1 shr_trt2_c2 shr_trt2_c3 _t, sort yline(1, lpattern(dash)) ytitle(Rate of Failure)"}{p_end}

{phang2}{stata "predict cifdiff, cifdiff1(trt2 1) ci"}{p_end}
{phang2}{stata "line cifdiff_c1* _t, sort lpattern(solid dash dash) scheme(sj) ytitle(Cumulative Incidence) title(Prostate Cancer) name(g1) legend(off)"}{p_end}
{phang2}{stata "line cifdiff_c2* _t, sort lpattern(solid dash dash) scheme(sj) ytitle(Cumulative Incidence) title(CVD) name(g2) legend(off)"}{p_end}
{phang2}{stata "line cifdiff_c3* _t, sort lpattern(solid dash dash) scheme(sj) ytitle(Cumulative Incidence) title(Other) name(g3) legend(off)"}{p_end}
{phang2}{stata "graph combine g1 g2 g3, nocopies ycommon cols(3)"}{p_end}


{phang2}{stata "predict cifratio, cifratio at(trt2 1)"}{p_end}
{phang2}{stata "gen CVD_ratio = cifratio_c1 + cifratio_c2"}{p_end}
{phang2}{stata "gen Other_ratio = CVD_ratio + cifratio_c3"}{p_end}
{phang2}{stata "gen Cancer_ratio = cifratio_c1"}{p_end}
{phang2}{stata "twoway (area Other_ratio _t, sort) (area CVD_ratio _t, sort) (area Cancer_ratio _t, sort), ytitle(Relative Contribution to Total Mortality)"}{p_end}



{title:References}

{phang}
P. C. Lambert and P. Royston. Further development of flexible parametric
models for survival analysis. Stata Journal 2009;9:265-290

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata: 
Beyond the Cox model StataPress, 2011

{title:Also see}

{psee}
Online:  {manhelp stpm2cr ST}; 
{p_end}

