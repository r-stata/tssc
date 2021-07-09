	{smcl}
{* *!Paul C. Lambert 21Nov2016}{...}
{cmd:help stpm2_standsurv} 
{right:also see:  {helpb stpm2}{space 2}{helpb stpm2_postestimation}}
{hline}

{title:Title}

{p2colset 5 24 22 2}{...}
{p2col:{hi: stpm2_standsurv} {hline 2}}Post-estimation tool to estimate standardised survival curves and contrasts{p_end}
{p2colreset}{...}


{title:Syntax}
{phang2}
{cmd: stpm2_standsurv} [{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opt at1()}{it:...}{opt atn()}}fix specific covariate values for each cause{p_end}
{synopt:{opt atv:ars()}}the new variable names (or stub) for each at{it:n}() option{p_end}
{synopt:{opt atr:eference()}}the reference at{it:n}() option (default 1){p_end}
{synopt:{opt centile(numlist)}}centiles of the standardised survival function{p_end}
{synopt:{opt centileu:pper(#)}}upper starting value when calculating centiles{p_end}
{synopt:{opt centv:ar()}}the new variable to denote centiles{p_end}
{synopt:{opt ci}}calculates confidence intervals for each at{it:n}() option and for contrasts{p_end}
{synopt:{opt contrast()}}perform contrast between covariate patterns defined by at{it:n}() options{p_end}
{synopt:{opt contrastv:ars()}}the new variable names (or stub) for each contrast{p_end}
{synopt:{opt f:ailure}}calculate standardised failure function (1-S(t)){p_end}
{synopt:{opt h:azard}}calculate hazard function of standardised survival curve{p_end}
{synopt:{opt indw:eights(varname)}}variable containing weights (for external standardisation){p_end}
{synopt:{opt lincom}}linear combination of at options{p_end}
{synopt:{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synopt:{opt mest:imation}}use M-estimation for standard errors & confidence intervals{p_end}
{synopt:{opt no:des(#)}}number of nodes for numerical integration (default 30){p_end}
{synopt:{opt rmst}}calculate restricted mean survival time{p_end}
{synopt:{opt se}}calculates standard errors for each at{it:n}() option and for contrasts{p_end}
{synopt:{opt ti:mevar()}}time variable used for predictions (default _t){p_end}
{synopt:{opt tr:ansform()}}transformation to calculate standard errors when obtaining confidence intervals{p_end}
{synopt:{opt userf:unction()}}user defined function{p_end}
{synopt:{opt userfunctionv:ar()}}the new variable names (or stub) for each user defined function{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:stpm2_standsurv} can be used after {helpb stpm2} to obtain standardised (average) survival curves and 
contrasts between standardised curves. It is similar to the {cmd:meansurv} option of {cmd:stpm2}'s {cmd:predict} command,
but allows multiple at options and contrasts (differences or ratios of standardised survival curves). It is 
substantially faster than performing contrasts using {cmd:predictnl} with {cmd:meansurv} as partial derivatives are calculated analytically. It can use either the delta-method
or M-estimation (Stefanski and Boos 2002) to calculated standard errors and hence confidence intervals. 

{pstd}In addition, {cmd:stpm2_standsurv} will calculate various functions of the standardised survival curves. These are the hazard function, the restricted mean survival time 
(area under the survival curve), and centiles of the standardised curve. Contrasts can be made between any of these measures (differences, ratios or percentage differences).
The delta-method is the default for obtaining standard errors with the exception of obtaining centiles (and their contrasts) where only 
M-estimation can be used.

{title:Options}

{phang}
{opt at1(varname # [varname # ..])}{it:..}{opt atn(varname # [varname # ..])}
specifies covariates to fix at specific values when averaging survival curves. 
For example, if {it:x} denotes a binary covariate and you want to standardise
over all other variables in the model then using {bf:at1(x 0) at2(x 1)} will give
two standardised survival functions, one where {bf:x=0} and one where {bf:x=1}. 

{pmore}
Using {bf:at1(.)} will calculated the standardized quanity with all observations set to their observed values.

{pmore}
It can be sometimes be useful to set certain variables to take the values of a different covariate. This can be done using {bf:at1(x1 = x2)} for examlpe. This can be useful when there are interactions: 
consider a model with {bf: treat age treat_age} as covariates where {bf: treat_age} is an interaction with age. When standardising for when {bf:treat=0} and {bf:treat=1}, the {bf:at()} options should be
{bf: at1(treat 0 treat_age 0)} and {bf: at1(treat 1 treat_age = age)}

{phang}
{opt atvars(stub | newvarnames)} gives the new variables to create. This can be
specified as a varlist equal to the number of at() options or a {it:stub}
where new variables are named {it:stub}{bf:1} - {it:stub}{bf:n}. If this
option is not specified, the names default to {bf:_at1} to {bf:_at}{it:n}. 

{phang}
{opt atreference(#)} the {bf:atn()} option that defines the reference category.
By default this is {bf:at1()}.

{phang}
{opt centile(numlist)} calculates centiles of the standardised survival curve
for the centiles given in {it:numlist}. The centile values are given in a
new variable, {cmd:_centvar}, or that defined using the {cmd:centvar()} option.

{phang}
{opt centileupper(#)} upper starting value when calculating centiles of the 
standardised survival curve. The default is twice the maximum survival time.

{phang}
{opt centileupper(newvarname)} name of new varaible giving values of centiles.
The default is {cmd:_centvar}.

{phang}
{opt ci} calculates a {opt level(#)}% confidence interval for each standardised
survival function or contrast. The confidence limits are stored using the
suffix {bf:_lci} and {bf:_uci}.

{phang}
{opt contrast(contrastname)} calculates contrasts between standardised survival
curves. Options are {bf:difference} and {bf:ratio}. There will be {it:n-1} 
new variables created, where {it:n} is the number of {bf:at()} options.

{phang}
{opt contrastvars(stub | newvarnames)} gives the new variables to create when
using the {bf:contrast()} option. This can be specified as a varlist or a {it:stub},
whereby new variables are named {it:stub}{bf:1} - {it:stub}{bf:n-1}. 
The names default to {bf:_contrast1} to {bf:_contrast}{it:n-1}.

{phang}
{opt failure} calculates the standardised failure function rather than
the standardised survival function.

{phang}
{opt hazard} calculates the hazard function of the standardised survival
function. Note that this is not the mean of the predicted hazard functions,
but a weighted mean with weights S(t). The weights are time-dependent.

{phang}
{opt lincom(#...#)} calculates a linear combination of at{it:n} options. As an example, if
there were two at options then {bf:lincom(1 -1)} would calculate the difference in the
standardized estimate. This would be the same as using the {bf:contrast(difference)} option.

{phang}
{opt mestimation} requests that standard errors are obtained using M-estimation (Stefanski and Boos 2002) rather than the delta-method.
When calculating centiles of standardized curves it is only possible to use M-estmation.

{phang}
{opt nodes(#)} number of nodes when performing numerical integration to
calculate the restricted mean survival time.

{phang}
{opt rmst} calculates the restricted mean survival time. These are calculated at
the time points give in variable given in the {cmd:timevar()} option.

{phang}
{opt se} calculates the standard error  for each standardised
function or contrast. This is stored using the suffix {bf:_se}.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions. The
option is useful for large datasets where, for plotting purposes, predictions
are needed only for (say) 200 observations. Note that predictions are averaged
over the whole sample, not just those where {it:timevar} is not missing. It is
recommended that {opt timevar()} is used, as otherwise an estimate of the survival
function is obtained at each value of {bf:_t} for all subjects.
Default varname is {cmd:_t}.

{phang}
{opt trans(name)} transformation to apply when calculating standard errors to
obtain confidence intervals for the standardised curves. The default is
log(-log S(t)). Other possible {it:name}s are {bf:none}, {bf:log}, {bf:logit}.

{phang}
{opt userfunction(name)} give a Mata function that calculates transformations the standardized functions. This enables flexibility to calculate 
a wide range of potential functions. An example of a Mata function to calculate a difference  between two standardized function is shown below


{pstd}{cmd:mata:}{p_end}
{pstd}{cmd:function user_eg(at) {c -(}}{p_end}
{pstd}{space 4}{cmd:return(at[2] - at[1])}{p_end}
{pstd}{cmd:{c )-}}{p_end}
{pstd}{cmd:end}{p_end}

{phang}
{cmd:stpm2_standsurv, at1(x1 0) at2(x1 1) timevar(tt) ci userfunction(user_eg)}

{phang}
{opt userfunctionvar(newvarname)} gives the new variable to create when
using the {bf:userfunction()} option. The name defaults to {bf:_userfunc}.

{title:Example}

For some more detailed examples see {browse "https://pclambert.net/software/stpm2_standsurv/":https://pclambert.net/software/stpm2_standsurv/}

{pstd}Load example dataset:{p_end}
{phang}{stata ". webuse brcancer, clear"}

{pstd}{cmd:stset} the data:{p_end}
{phang}{stata ". stset rectime, f(censrec==1) scale(365.24)"}

{pstd}Fit {cmd:stpm2} model:{p_end}
{phang}{stata ". stpm2 hormon x5 x1 x3 x6 x7, scale(hazard) df(4) tvc(hormon x5 x3) dftvc(3)"}

{pstd}Generate variable that defines timepoints to predict at. The following creates 50 equally spaced time points between 0.05 and 5 years:{p_end}
{phang}{stata ". range timevar 0 5 50"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}.
In each case the survival curves are the average of the 686
survival curves using the observed covariate values except for {bf:hormon}.{p_end}
{phang}{stata ". stpm2_standsurv, atvars(S0a S1a) at1(hormon 0) at2(hormon 1) timevar(timevar) ci"}

{pstd}Plot standardised curves:{p_end}
{phang}{stata ". line S0a S1a timevar"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}, but apply the covariate distribution amongst those with {bf:hormon=1}.{p_end}
{phang}{stata ". stpm2_standsurv if hormon==1, atvars(S0b S1b) at1(hormon 0) at2(hormon 1) timevar(timevar) ci"}

{pstd}Plot standardised curves:{p_end}
{phang}{stata ". line S0b S1b timevar"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}, and calculate difference in standardised survival curves and 95 confidence interval.

{phang}{stata ". stpm2_standsurv, atvars(S0c S1c) at1(hormon 0) at2(hormon 1) timevar(timevar) ci contrast(difference) contrastvar(Sdiffc)"}

{pstd}Plot difference in standardised curves and 95% confidence interval:{p_end}
{phang}{stata ". line Sdiffc* timevar"}



{title:Acknowledgements}

The idea to implemnt centiles of the standardized survival curve aroise through discussions with David Drukker at the Nordic Stata User Group meetings in Oslo and Stockholm. 
Thanks to Michael Crowther for strong encouragement to use structures and pointers to help generalise this command.

{title:Also see}

{psee}
Online:  {manhelp stpm2 ST}, {manhelp stpm2_postestimation ST} 


{title:References}

{phang}Stefanski L.A. and Boos, DD. The calculus of M-estimation. {it: The American Statistician} 2002;{bf:56};29-38.
{p_end}



