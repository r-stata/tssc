{smcl}
{* *! version 1.0.9  23apr2012}{...}
{cmd:help for xpredict}{right:Patrick Royston}
{hline}


{title:Extension to predict}


{title:Syntax}

{phang2}
{cmd:xpredict}
{it:newvarname}
{ifin}
{cmd:,}
{opt with(varlist)}
[{it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt a(numlist)}}defines constants for use in contrasts{p_end}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt cons:tant}}includes the regression constant in predictions{p_end}
{synopt :{opt dou:ble}}makes {it:newvarname} double precision{p_end}
{synopt :{opt eq(eqname)}}defines the equation for {it:varlist}{p_end}
{synopt :{opt mean:zero}}centres the prediction on its mean{p_end}
{synopt :{opt s:tdp}}predicts the standard error of (partial) xb{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:xpredict} gives predictions of the (partial) `index' xb from variables
in the most recently fitted regression model.

{pstd}
Note that none of the options of {cmd:predict} available with specific regression
commands are available with {cmd:xpredict}. Only prediction of xb and its SE are 
supported. Multi-equation models are supported via the {opt eq()} option.


{title:Options}

{phang}
{opt a(numlist)} defines a set of constants by which the regression coefficients
    for members of varlist are multiplied before prediction. This can be used
    to estimate contrasts e.g. after {cmd:regress} or {cmd:anova}.

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = 50. This is a useful way to obtain out of sample predictions.

{phang}
{opt constant} includes the regression constant ({opt _cons}) in the prediction. It is
    counted as the last predictor in {opt with()}.

{phang}
{opt double} specifies that newvarname be of type double (double precision).
    The default type is float.

{phang}
{opt eq(eqname)} defines the name of the equation for varlist in {opt with(varlist)}.
    Only when {it:eqname} is the name of a subsidiary equation (i.e. not the 'main'
    equation or linear predictor) does it need to be specified at all. By default
    {cmd:xpredict} works out the name of the main equation itself, by inspecting
    {cmd:e(b)}.

{phang}
{opt meanzero} centres the predicted values on their mean. If the {opt stdp}
    option is used, the standard error is adjusted accordingly. Note that with
    the {opt meanzero} option, {cmd:xpredict} subtracts the mean
    xb computed in the subsample defined by the {ifin} filter, if any.
    The prediction of xb and its standard error ({opt stdp} option) are
    done out of sample. Cases with any missing values for any member of 
    {opt with()} are excluded.

{phang}
{opt stdp} predicts the standard error of (partial) xb.

{phang}
{opt with(varlist)} is not optional and specifies the variables to be used.
    These must be among the variables fitted in the most recent model.
    Factor variables are allowed.

{phang}
{it:predict_options} are any of the options of {cmd:predict} (in general, these will
    be estimation-command specific, though some are always available; see 
    {helpb predict}).


{title:Examples}

{phang}{cmd:. regress y x1 x2 x3}{p_end}
{phang}{cmd:. xpredict f, with(x1 x2) double}{p_end}
{phang}{cmd:. xpredict fs, with(x1 x2) stdp}{p_end}
{phang}{cmd:. xpredict f, with(x1 x2) constant}{p_end}
{phang}{cmd:. xpredict f2, with(x1 x2) meanzero}{p_end}
{phang}{cmd:. xpredict f2s, with(x1 x2) meanzero stdp}{p_end}

{phang}{cmd:. poisson y x1 x2, exposure(pyears)}{p_end}
{phang}{cmd:. xpredict f, with(x1) eq(y)}

{phang}{cmd:. stcox rem##sex i.who}{p_end}
{phang}{cmd:. xpredict xb, with(1.sex 1.rem 1.sex#1.rem)}{p_end}
{phang}{cmd:. table rem sex, contents(mean xb) format(%6.3)}


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London.{break}
pr@ctu.mrc.ac.uk


{title:Also see}

{psee}
On-line:  help for {help predict}.
