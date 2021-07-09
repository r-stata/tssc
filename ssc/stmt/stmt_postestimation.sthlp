{smcl}
{* *! version 1.4.7 06Nov2020}{...}
{cmd:help stmt postestimation}
{right:also see:  {help stmt}}
{hline}

{title:Title}

{p2colset 5 34 36 2}{...}
{p2col :{hi:[ST] stmt postestimation} {hline 2}}Post-estimation tools for {cmd:stmt}{p_end}
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
{p2col :{helpb strcs postestimation##predict:predict}}predictions, residuals etc{p_end}
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
Note: in the table below, {it:vn} is an abbreviation for {it:varname}.

{synoptset 31 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{*:{synopt :{opt cumh:azard}}cumulative hazard function{p_end}}
{synopt :{opt h:azard}}hazard function{p_end}
{synopt :{opt nodes(#)}}specifies the number of nodes used in Gauss-Legendre quadrature numerical integration
when predicting the cumulative hazard and calculating the survival (default is 30){p_end}
{synopt :{opt per(#)}}express hazard rates (and differences) per # person years{p_end}
{*:{synopt :{opt s:urvival}}survival function{p_end}}
{synopt :{opt xb}}the linear predictor{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}

{syntab:Timescale-related}
{synopt :{opt time1var(varname)}} variable which defines timescale 1 for predictions {p_end}
{synopt :{opt time2var(varname)}} variable which defines timescale 2 for predictions {p_end}
{synopt :{opt time3var(varname)}} variable which defines timescale 3 for predictions {p_end}


{syntab:Subsidiary}
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
{cmd:x3} = 50. This is a useful way to obtain out of sample predictions.
Note that if {opt at()} is used together with {opt zeros} all covariates not
listed in {opt at()} are set to zero. If {opt at()} is used without {opt zeros}
then all covariates not listed in {opt at()} are set to their sample
values. See also {opt zeros}.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt cumh:azard} predicts the cumulative hazard function. Note that each timescale must increase in the same
number of steps and that predictions must start at zero for one timescale.

{phang}
{opt h:azard} predicts the hazard function.

{phang}
{opt nodes(#)} specifies the number of nodes to be used when numerically integrating
the estimated hazard function using Gauss-Legendre quadrature. Numerical integration is required
when predicting the cumulative hazard and survival functions. The default number of nodes is 30.

{phang}
{opt per(#)} express hazard rates and difference in hazard rates per # person years.

{phang}
{opt s:urvival} predicts the survival function. Note that each timescale must increase in the same
number of steps and that predictions must start at zero for one timescale.

{phang}
{opt xb} predicts the linear predictor, including the spline function.

{phang}
{opt zeros} sets all covariates to zero (baseline prediction). For
example, {cmd:predict s0, survival zeros} calculates the baseline
survival function. See also {opt at()}.


{dlgtab:Timescale-related}

{phang}
{opt time1var(varname)} specifies a the variable in the dataset which defines the for values
of timescale 1 that the user wishes to predict over.

{phang}
{opt time2var(varname)} specifies a the variable in the dataset which defines the for values
of timescale 2 that the user wishes to predict over.

{phang}
{opt time3var(varname)} specifies a the variable in the dataset which defines the for values
of timescale 3 that the user wishes to predict over.


{dlgtab:Subsidiary}

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by (help set level}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}

{pstd}Stset with time since diagnosis as timescale 1 {p_end}
{phang2}{stata "stset rectime, f(censrec==1) scale(365.25) exit(time 365.25*5)"}{p_end}

{pstd}Fit model with attained age as timescale 2 and time-dependent effects of hormon on both timescales {p_end}
{phang2}{stata "stmt hormon, time1(df(5) tvc(hormon) dftvc(2)) time2(df(2) start(x1) tvc(hormon) dftvc(2) logtoff)"}{p_end}

{pstd} Predict the hazard rate with predictions on timescale 1 (time since diagnosis) from 0 to 3 years where variable hormon is set to 1
when timescale 2 (attained age) is 53. Note that the user must create the timescale variables first before using the predict command.{p_end}
{phang2}{stata "range time1 0 3 200"}{p_end}
{phang2}{stata "gen time2=53"}{p_end}
{phang2}{stata "predict h, h time1var(time1) time2var(time2)  at(hormon 1)"}{p_end}

{pstd} Predict the hazard ratio over timescale 1 (0-3) at attained age 53, comparing hormon =1 and hormon =0{p_end}
{phang2}{stata "predictnl hr= exp(ln(predict(h time1var(time1) time2var(time2) at(hormon 1)))- ln(predict(h time1var(time1) time2var(time2) at(hormon 0))))"}{p_end}
{phang2}{stata "scatter hr time1, sort name(hr_scatter, replace)"}{p_end}

{pstd} Predict the hazard rate on timescale 2 (attained age) from 50 to 60 years for 2 years post diagnosis where variable hormon is set to 1 {p_end}
{phang2}{stata "cap drop time1 time2"}{p_end}
{phang2}{stata "gen time1=2"}{p_end}
{phang2}{stata "range time2 50 60 200"}{p_end}
{phang2}{stata "predict h2, h time1var(time1) time2var(time2)  at(hormon 1)"}{p_end}

{pstd} Predict the hazard with predictions on timescale 1 (time since diagnosis) between
0 and 3 years, in steps of 0.1.  Predictions on timescale 2 (attained age) from age 50 until age 53, in steps of 0.25. Predictions are then made of every combination of timescale 1 and 2.
Firstly create timescales using the following:{break}{p_end}

{phang} cap drop time1 time2 {break}
preserve {break}
forvalues j=0(0.1)3 { {break}
	qui clear {break}
	qui set obs 13 {break}
	qui gen time1 = `j' {break}
	qui range time2 50 53 13 {break}
	qui tempfile temppred`n' {break}
	qui save `temppred`n'' {break}
	local datalist `datalist' `temppred`n'' {break}
	local n=`n'+1 {break}
} {break}
clear {break}
set obs 0 {break}
append using `datalist' {break}
tempfile timedata {break}
save `timedata' {break}
restore{break}
merge 1:1 _n using `timedata', nogen {p_end}

{pstd}Then use the following predict command:{p_end}

{phang2}{ stata "predict h3, h time1var(time1) time2var(time2) at(hormon 1) "}{p_end}

{title:References}

{phang}
H. Bower, M.J. Crowther, P. C. Lambert. strcs: A command for fitting flexible parametric
survival models on the log-hazard scale. The Stata Journal, 2016;16:989-1012.

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata:
Beyond the Cox model StataPress, 2011

{title:Also see}

{psee}
Online:  {manhelp strcs ST};
{p_end}
