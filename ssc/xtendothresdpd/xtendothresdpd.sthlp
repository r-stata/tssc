{smcl}
{* *! version 1.0.1  }{...}
{cmd:help xtendothresdpd}
{hline}

{title:Title}

{pstd}
    {hi: Performs Estimations of a Dynamic Panel Data Threshold Effects Model with Endogenous Regressors}


	
{title:Syntax}

{pstd}
{cmd:xtendothresdpd}
{depvar}
{indepvars}
{ifin}
{cmd:,} {cmd:thresv(}{varname}{cmd:)} {cmdab:stub:(}string{cmd:)} {cmd:pivar(}{varname}{cmd:)} {cmdab:dg:mmiv(}{varlist} [...]{cmd:)} [{it:options}]



{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt thresv}{cmd:(}{varname}{cmd:)}}indicates the threshold variable {p_end}
{p2coldent :* {cmdab:stub:}{cmd:(}string{cmd:)}}designates a string name from which new variable names will be created {p_end}
{p2coldent :* {opt pivar}{cmd:(}{varname}{cmd:)}}is the variable that depends on the threshold {p_end}
{p2coldent :* {opt dg:mmiv}{cmd:(}{varlist}[{it:...}]{cmd:)}}GMM-type instruments
for the difference equation; can be specified more than once {p_end}
{synopt :{opt fpctile(#)}}specifies the lower bound percentile of the threshold variable {p_end}
{synopt :{opt lpctile(#)}}specifies the upper bound percentile of the threshold variable {p_end}
{synopt: {opt xaddendog}{cmd:(}{varlist}{cmd:)}}list of additional endogenous variables correlated with the error term {p_end}
{synopt: {opt sig(#)}}designates the significance level we want to set for the confidence interval for the estimated threshold {p_end}
{synopt: {opt zaddinst}{cmd:(}{varlist}{cmd:)}}list of additional instrumental variables for the intermediate computations {p_end}
{synopt:{opt nographs}}removes the display of the graphic after the estimations are performed {p_end}
{synopt:{opt sav:ing(string)}}allows to save the graphic that the command creates {p_end}
{synopt :{opt grid(#)}}designates the number of grid points used to estimate the threshold {p_end}
{synopt:{opt forcereg}}this option explicitly balances the panel data before the estimation {p_end}
{synopt: {opt lagsret(#)}}indicates the number of lags of the lagged dependent variable to use as instruments for the intermediate computations {p_end}
{synopt :{it:{help xtdpd:xtdpd_options}}}in addition to the options listed above, all options of the command {bf:{manhelp xtdpd XT}} 
can be used {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} * {cmd:thresv()}, {cmd:stub()}, {cmd:pivar()} and {cmd:dgmmiv()} are required.{p_end}
{p 4 6 2} You must {opt tsset}  or {opt xtset} your data before using {cmd:xtendothresdpd};
see {manhelp tsset TS} and {manhelp xtset XT}.{p_end}
{p 4 6 2} {depvar} is the dependent variable and {indepvars} are the regime-independent variables.{p_end}
{p 4 6 2} {depvar}, {indepvars}, and all {varname} and {varlist} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2} {cmd:by} is allowed with {cmd:xtendothresdpd}; see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:xtendothresdpd} performs estimations of a dynamic panel data threshold effects model with endogenous regressors. If we have a 
panel data model which is dynamic, meaning that we have the dependent variable and its lagged value in the model. If, in this 
model, we also have a threshold effect and the regressors are endogenous, then we can use the command {cmd:xtendothresdpd} 
to estimate both the threshold effect and the slope coefficients. In this command, the threshold is determined endogenously. That 
is, if there is a threshold, the command finds it by using the information given by the data. The theory behind the 
command {cmd:xtendothresdpd} is provided by Kremer, Bick and Nautz (2013).



{title:Econometric Model}

{p 4 6 2} The general equation to be estimated is given by: {p_end}

{p 4 6 2}  {it:y_it = psi*y_{it-1} + beta_1*pi_it*I(q_it <= gamma) + beta_2*pi_it*I(q_it > gamma) + phi_1'*x_{1 it} + phi_2'*x_{2 it} + mu_i + epsilon_it} {space 3}  {hi:(1)} {p_end}

{p 4 6 2}  where {p_end}

{p 4 6 2}  {it:p_it = (y_{it-1}{space 2}x_{2 it})'} {p_end}

{p 4 6 2}  {it:y_it} is the dependent variable {p_end}

{p 4 6 2}  {it:y_{it-1}} is the lagged dependent variable {p_end}

{p 4 6 2}  {it:pi_it} is the variable that depends on the threshold (regime dependent variable) {p_end}

{p 4 6 2}  {it:q_it} is the threshold variable {p_end}

{p 4 6 2}  {it:gamma} is the threshold parameter to be estimated {p_end}

{p 4 6 2}  {it:I(.)} is the indicator function {p_end}

{p 4 6 2}  {it:x_{1 it}} vector of exogenous variables uncorrelated with {it:epsilon_it} (first set of regime independent variables) {p_end}

{p 4 6 2}  {it:x_{2 it}} vector of endogenous variables correlated with {it:epsilon_it} (second set of regime independent variables) {p_end}

{p 4 6 2}  {it:p_it} is the vector of all endogenous variables {p_end}

{p 4 6 2}  {it:mu_i} are the fixed effects {p_end}

{p 4 6 2}  {it:epsilon_it} are the idiosyncratic errors {p_end}

{p 4 6 2}  {it:psi, beta_1, beta_2, phi_1', phi_2'} are parameters to be estimated {p_end}

{p 4 6 2}  i = 1,...,N {space 3}  and {space 3}  t = 1,...,T {p_end}

{p 4 6 2}  We will also need the following equations to understand the command {cmd:xtendothresdpd}: {p_end}

{p 4 6 2}  {it:LR(gamma) = (S(gamma) - S(gamma_hat))/sigma_hat^2} {space 3}  {hi:(2)} {p_end}

{p 4 6 2}  {it:C(alpha) = -2*ln(1-sqrt(1-alpha))} {space 19}  {hi:(3)} {p_end}

{p 4 6 2}  {it:GAMMA = {gamma: LR(gamma) <= C(alpha)}} {space 14}  {hi:(4)} {p_end}

{p 4 6 2}  with {p_end}

{p 4 6 2}  {it:C(alpha)} is the {it:alpha} {it:percent}, percentile of the asymptotic distribution of the
likelihood ratio statistic {it:LR(gamma)} {p_end}

{p 4 6 2}  {it:LR(gamma)} the likelihood ratio statistic {p_end}

{p 4 6 2}  {it:S(gamma)} the sum of squared errors of the Second Stage of Estimation at {it:gamma} {p_end}

{p 4 6 2}  {it:S(gamma_hat)} the sum of squared errors of the Second Stage of Estimation at {it:gamma_hat} {p_end}

{p 4 6 2}  {it:sigma_hat^2} the residual variance at {it:gamma_hat} {p_end}

{p 4 6 2}  The correspondence between the econometric models given in equations {hi:(1)}, {hi:(2)}, {hi:(3)}, {hi:(4)} and 
the syntax of the command {cmd:xtendothresdpd} is given as follows:  {p_end}

{p 4 6 2} {depvar} corresponds to {it:y_it} {p_end}

{p 4 6 2} L.{depvar} corresponds to {it:y_{it-1}} {p_end}

{p 4 6 2} {opt pivar}{cmd:(}{varname}{cmd:)} corresponds to {it:pi_it} {p_end}

{p 4 6 2} {opt thresv}{cmd:(}{varname}{cmd:)} corresponds to {it:q_it} {p_end}

{p 4 6 2} {indepvars} corresponds to {it:x_{1 it}} {p_end}

{p 4 6 2} {opt xaddendog}{cmd:(}{varlist}{cmd:)} corresponds to {it:x_{2 it}} {p_end}

{p 4 6 2} {opt sig(#)} corresponds to {it:alpha} {p_end}

{p 4 6 2} {it:LR(gamma)}, {it:C(alpha)} and expression {hi:(4)} are used for the Confidence Interval Construction for 
the Threshold Model. These objects are graphed in the graphic that appears after the estimations are performed if 
the {opt nographs} option is not specified {p_end}



{title:Options}

{phang}
{opth thresv(varname)} indicates the threshold variable. To form this option,
you put inside the parentheses the variable name representing the threshold variable.
You must specify this option in order to get a result. Hence this option is required.

{phang}
{opt stub(string)} designates a string name from which new variable names will be 
created. To form this option, you put inside the parentheses a string name (without the 
double quotes). Then new variable names will be created from this string. You must 
specify this option in order to get a result. Hence this option is required.

{phang}
{opt pivar}{cmd:(}{varname}{cmd:)} is the variable that depends on the threshold (regime dependent variable). To form 
this option, you put inside the parentheses the name of the variable that depends on 
the threshold variable. This variable may be the same as the threshold variable or it 
may be different from the threshold variable. You must specify this option in order 
to get a result. Hence this option is required.

{phang}
{cmd:dgmmiv(}{varlist} [{cmd:,} {opt l:agrange}{cmd:(}{it:flag}
[{it:llag}]{cmd:)}]{cmd:)} specifies GMM-type instruments for the
difference equation.  Levels of the variables are used to form GMM-type
instruments for the difference equation.  All possible lags are used,
unless {opt lagrange}{cmd:(}{it:flag} {it:llag}{cmd:)} restricts the lags to
begin with {it:flag} and end with {it:llag}.  You may specify as many sets
of GMM-type instruments for the difference equation as you need within the
standard Stata limits on matrix size.  Each set may have its own {it:flag}
and {it:llag}.  {cmd:dgmmiv()} is required. {cmd:dgmmiv()} is one of the 
options of the command {bf:{manhelp xtdpd XT}}. See 
{it:{help xtdpd:xtdpd_options}} below for more details.

{phang}
{opt fpctile(#)} specifies the lower bound percentile of the threshold variable that
must be included in the search for {it:gamma}. The default value of this option is 10.
Hence the search for {it:gamma} starts at the 10th percentile of the threshold variable.

{phang}
{opt lpctile(#)} specifies the upper bound percentile of the threshold variable that
must be included in the search for {it:gamma}. The default value of this option is 90.
Hence the default search for {it:gamma} starts at the 10th percentile and goes up to the 90th
percentile of the threshold variable. Thus the options {opt fpctile(#)} and  {opt lpctile(#)} 
determine the interval that is used when constructing a grid for estimating 
{it:gamma}. That is, with the default values for these two options, the values below and above 
the 10th and the 90th percentile of the threshold variable are eliminated and only the values 
between the 10th and the 90th percentile of the threshold variable are utilized for the 
grid search for {it:gamma}.

{phang}
{opt xaddendog}{cmd:(}{varlist}{cmd:)} list of additional endogenous variables correlated with 
the error term. These variables represent the second set of regime independent variables. If you 
have any additional endogenous variables, you put them in this option. To form this option, you 
put inside the parentheses one, two or more of your additional endogenous variables separated by space.

{phang}
{opt sig(#)} designates the significance level we want to set for the confidence interval for the 
estimated threshold. The default value of this option is 0.10. This default value of 0.10 means 
that we want a 90 percent confidence interval for the estimated threshold parameter.

{phang}
{opt zaddinst}{cmd:(}{varlist}{cmd:)} list of additional instrumental variables used for the intermediate 
computations by the command {cmd:xtendothresdpd}. Note that the use of the option 
{opt zaddinst}{cmd:(}{varlist}{cmd:)} does not prevent employing the numerous instrumental variables 
options of the command {bf:{manhelp xtdpd XT}} (see {it:{help xtdpd:xtdpd_options}} below for more details). 
Hence the option {opt zaddinst}{cmd:(}{varlist}{cmd:)} may or may not be used in conjunction with the 
instrumental variables options of the command {bf:{manhelp xtdpd XT}}. The instrumental variables options 
of the command {bf:{manhelp xtdpd XT}} are employed for the final computations while the 
{opt zaddinst}{cmd:(}{varlist}{cmd:)} option is utilized for the intermediate calculations. To form the 
option {opt zaddinst}{cmd:(}{varlist}{cmd:)}, you put inside the parentheses one, two or more 
of your additional instrumental variables separated by space. Contrarily to the options of the 
command {bf:{manhelp xtdpd XT}}, the option {opt zaddinst}{cmd:(}{varlist}{cmd:)} may be only 
specified once. If you have any additional instrumental variables for the intermediate computations, 
you put them in the option {opt zaddinst}{cmd:(}{varlist}{cmd:)}.

{phang}
{opt nographs} suppresses the display of the graphic after the estimations are performed. This
option is used when we do not want to display the graphic after the estimations are done.

{phang}
{opt sav:ing(string)} in this option, you specify the complete file path where you want to save the
graphic produced by the command. You must enclose the path in double quotes. If you do not
specify this option, the graphic will be displayed, if you do not choose the {opt nographs}
option, but it will not be saved.

{phang}
{opt grid(#)} designates the number of grid points used to estimate the threshold. The default 
value of this option is 400. This default value means that 400 quantiles are used as a grid in 
computing the threshold.

{phang}
{opt forcereg} explicitly balances the panel data before the estimation. The command {cmd:xtendothresdpd} 
works for both unbalanced panel data and strongly balanced panel data. Generally, the option {opt forcereg} is for 
specific use when you are utilizing the {opt fodeviation} option of the command {bf:{manhelp xtdpd XT}} 
(see {it:{help xtdpd:xtdpd_options}} below for more details). In fact, the option {opt fodeviation} is 
not allowed when there are gaps in the data or when {cmd:lgmmiv()} option 
(from the command {bf:{manhelp xtdpd XT}}) is specified. Hence, if your panel data is unbalanced, 
and you want to employ the {opt fodeviation} option, then use it in conjunction with the option 
{opt forcereg}. You can also use the {opt forcereg} option if you desire to strongly balance your 
panel data before performing the estimation.

{phang}
{opt lagsret(#)} indicates the number of lags of the lagged dependent variable to use as instruments 
for the intermediate computations. The default value of this option is 1. This default value means 
that only the first lag of the lagged dependent variable is used as instrument for the intermediate 
computations. Note that the use of the option {opt lagsret(#)} does not prevent employing the numerous 
instrumental variables options of the command {bf:{manhelp xtdpd XT}} (see {it:{help xtdpd:xtdpd_options}} 
below for more details). Hence the option {opt lagsret(#)} may be used in conjunction with the instrumental 
variables options of the command {bf:{manhelp xtdpd XT}}. The instrumental variables options of the command 
{bf:{manhelp xtdpd XT}} are employed for the final computations while the {opt lagsret(#)} option is utilized 
for the intermediate calculations. Contrarily to the options of the command {bf:{manhelp xtdpd XT}}, the 
option {opt lagsret(#)} may be only specified once.

{phang}
{it:{help xtdpd:xtdpd_options}}:
{opt dg:mmiv}{cmd:(}{varlist}[{it:...}]{cmd:)},
{opt lg:mmiv}{cmd:(}{varlist}[{it:...}]{cmd:)},
{cmd:iv(}{varlist}[{it:...}]{cmd:)},
{cmd:div(}{varlist}[{it:...}]{cmd:)},
{cmd:liv(}{varlist}{cmd:)},
{opt nocons:tant},
{opt two:step},
{opt h:ascons},
{opt fod:eviation},
{opth vce(vcetype)},
{opt l:evel(#)}, etc.
See {bf:{manhelp xtdpd XT}}.
In addition to the options described above, all options of the {bf:{manhelp xtdpd XT}} command can be used.

{phang2}
You can use all the options of the command {bf:{manhelp xtdpd XT}}. To utilize them with the 
command {cmd:xtendothresdpd}, enter them in the same manner that you would do with 
the {bf:{manhelp xtdpd XT}} command. Hence, it is strongly advised that you read both all the 
help file of the command {cmd:xtendothresdpd} (this help file), and all the help file of the 
command {bf:{manhelp xtdpd XT}}, including all of its complete PDF manual entry 
at {mansection XT xtdpd:View complete PDF manual entry}. This will help you to efficiently 
employ the command {cmd:xtendothresdpd}.



{title:Syntax for predict}

{p 8 16 2}{cmd:predict}
{dtype}
{newvar}
{ifin}
[{cmd:,} {opt xb} {opt e} {opt stdp} {opt di:fference}] 



{title:Description for predict}

{pstd}
{cmd:predict} creates a new variable containing predictions such as linear
predictions.



{title:Options for predict}

{phang}
{opt xb}, the default, calculates the linear prediction. 

{phang}
{opt e} calculates the residual error. 

{phang}
{opt stdp} calculates the standard error of the prediction, which can be
thought of as the standard error of the predicted expected value or mean for
the observation's covariate pattern.  The standard error of the prediction
is also referred to as the standard error of the fitted value.  {opt stdp} may
not be combined with {opt difference}.

{phang}
{opt difference} specifies that the statistic be calculated for the first
differences instead of the levels, the default.



{title:Syntax for xtendothresdpdtest}

{p 8 16 2}{cmd:xtendothresdpdtest}
{cmd:,} {it:comdline(string)} [{it:options}]



{title:Description for xtendothresdpdtest}

{pstd}
{cmd:xtendothresdpdtest} allows us to test for a threshold after we perform the estimations with the command {cmd:xtendothresdpd}. 
The command {cmd:xtendothresdpdtest} permits to find out if the threshold effect is statistically significant. The hypothesis of 
no threshold effect in equation {hi:(1)} can be characterized by the linear constraint:

{p 4 6 2}  {hi:H0:} {it:beta_1 = beta_2} {space 3}  {hi:(5)} {p_end}

{pstd}
Hence, the {it:Null Hypothesis} is that there is no threshold effect in equation {hi:(1)} and the {it:Alternative Hypothesis} 
is that there is a threshold effect in equation {hi:(1)} . The test for the presence of a threshold effect is also known in 
the literature as {hi:test of linearity}. To test {hi:H0} in expression {hi:(5)}, we use an extension of the Davies (1977) 
Sup test to the Dynamic Panel Data Threshold Effects Model with Endogenous Regressors framework. The statistic that allows 
us to test for {hi:H0} in expression {hi:(5)} is called {hi:SupWStar} in the table of results of the 
command {cmd:xtendothresdpdtest}. See the {hi:Examples} section below for more details.



{title:Options for xtendothresdpdtest}

{phang}
{opt comdline(string)} designates a string name representing the command line that was typed by the user when he was using 
the command {cmd:xtendothresdpd}. You enter the command line in the option {opt comdline(string)} as: {hi:comdline(`e(cmdline)')}. To 
see the command line you typed when you were using the command {cmd:xtendothresdpd}, you can type {hi:ereturn list} immediately 
after you perform your estimations with the command {cmd:xtendothresdpd}. The option {opt comdline(string)} is required.

{phang}
{opt reps(#)} specifies the number of replications to be performed. The default value of this option is 50.

{phang}
{it:{help simulate:simulopts(string)}} in this option, you specify a list of all the options allowed by 
the {bf:{manhelp simulate R}} command. To form them, enter inside the parentheses the options of 
the {bf:{manhelp simulate R}} command separated by blank spaces as you would do with 
the {bf:{manhelp simulate R}} command. See {bf:{manhelp simulate R}} for more details.

{phang}
{it:{help bstat:bstatopts(string)}} in this option, you specify a list of nearly all the options allowed by 
the {bf:{manhelp bstat R}} command. Except the following options: {opt stat(vector)}, {opt n(#)} which are 
already used internally by the command {cmd:xtendothresdpdtest}, nearly all the other options of 
the {bf:{manhelp bstat R}} command can be included in the option {it:{help bstat:bstatopts(string)}}. To form 
them, enter inside the parentheses the options of the {bf:{manhelp bstat R}} command separated by blank spaces 
as you would do with the {bf:{manhelp bstat R}} command. See {bf:{manhelp bstat R}} for more details.



{title:Warning}

{pstd}
The command {cmd:xtendothresdpd}, like many panel data threshold effects estimation techniques, is 
highly computationally intensive and may for that reason take a very long time to run on a sluggish machine. The 
command {cmd:xtendothresdpdtest} is far more computationally intensive than the 
command {cmd:xtendothresdpd}. So, please, be patient when using both of these commands. The 
command {cmd:xtendothresdpdtest} does not work when the option {hi:nographs} is specified with the 
command {cmd:xtendothresdpd}.



{title:Important Advice}

{pstd}
Please keep the {cmdab:stub:}{cmd:(}string{cmd:)} option you use with the command {cmd:xtendothresdpd} 
very short as possible because {hi:Stata} variables names must not exceed 32 characters and the 
command internally employs already long names for the internal variables utilized in the internal 
computations. As a suggestion and guideline, in the examples given below (see the {hi:Examples} section below), 
the {cmdab:stub:}{cmd:(}string{cmd:)} option contains only three (3)  characters (three (3) letters). 
Also , in your equation specification for the command {cmd:xtendothresdpd}, please put the name of 
the lagged dependent variable always immediately after the name of the dependent variable as it is done 
in the {hi:Examples} section below. Additionally, contrarily to the command {bf:{manhelp xtdpd XT}} which may 
allow more than one lag of the dependent variable, only one lag of the dependent variable is allowed in 
the equation specification of the command {cmd:xtendothresdpd}. See the {hi: Econometric Model} section 
above and the {hi:Examples} section below for more details. Lastly, if the command {cmd:xtendothresdpd} aborts 
with an error message before displaying the final results, you may need to clear {hi:Stata} memory 
(see for {bf:{manhelp clear D}} more details) before running your next regression with the command {cmd:xtendothresdpd}.



{title:Return values for xtendothresdpd}

{pstd}
{cmd:xtendothresdpd} saves the following in {cmd:e()}. The command {cmd:xtendothresdpd} saves all the 
Stored Results returned by the command {bf:{manhelp xtdpd XT}}. So I advise you to look at the Stored 
Results of the command {bf:{manhelp xtdpd XT}} in conjunction with the Stored Results provided below 
to see the descriptions and the explanations of all the Stored Results returned by the 
command {cmd:xtendothresdpd}. Hence, in this help file, only the Stored Results that are not 
given by the command {bf:{manhelp xtdpd XT}} are explained. For the other remaining Stored 
Results, please see the help file for the command {bf:{manhelp xtdpd XT}} for more details:


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(gammahat)}}value of the estimated threshold parameter{p_end}
{synopt:{cmd:e(sofgammahat)}}the sum of squared errors of the Second Stage of Estimation at the estimated threshold parameter{p_end}
{synopt:{cmd:e(sigmahatsq)}}the residual variance at the estimated threshold parameter{p_end}
{synopt:{cmd:e(confalpha)}}is the {it:alpha percent}, percentile of the asymptotic distribution of the likelihood ratio statistic. This corresponds to {it:C(alpha)}{p_end}
{synopt:{cmd:e(noptimal)}}number of groups at the estimated threshold parameter{p_end}
{synopt:{cmd:e(toptimal)}}average group size at the estimated threshold parameter{p_end}
{synopt:{cmd:e(lowbgamma)}}lower bound of the confidence interval of the estimated threshold parameter{p_end}
{synopt:{cmd:e(uppbgamma)}}upper bound of the confidence interval of the estimated threshold parameter{p_end}
{synopt:{cmd:e(firstpctz)}}the lower bound percentile of the threshold variable that must be included in the search for {it:gamma}. This corresponds to {opt fpctile(#)}{p_end}
{synopt:{cmd:e(lastpctz)}}the upper bound percentile of the threshold variable that must be included in the search for {it:gamma}. This corresponds to {opt lpctile(#)}{p_end}
{synopt:{cmd:e(alphaparam)}}the significance level we want to set for the confidence interval for the estimated threshold. This corresponds to {opt sig(#)}{p_end}
{synopt:{cmd:e(gridpoints)}}the number of grid points used to estimate the threshold. This corresponds to {opt grid(#)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(lesoptionsdp)}}all the options of the command {bf:{manhelp xtdpd XT}} that was typed by the user{p_end}
{synopt:{cmd:e(thresvaribzha)}}the threshold variable that was typed by the user{p_end}
{synopt:{cmd:e(pivaribzha)}}the variable that depends on the threshold (regime dependent variable) that was typed by the user{p_end}
{synopt:{cmd:e(additendox)}}list of additional endogenous variables correlated with the error term that was typed by the user{p_end}
{synopt:{cmd:e(additinstrz)}}list of additional instrumental variables used for the intermediate computations by the command {cmd:xtendothresdpd} that was typed by the user{p_end}
{synopt:{cmd:e(gammavarzha)}}is the threshold parameter sequence. This corresponds to {it:gamma}{p_end}
{synopt:{cmd:e(sofgammazha)}}the sum of squared errors of the Second Stage of Estimation at {it:gamma} sequence. This corresponds to {it:S(gamma)}{p_end}
{synopt:{cmd:e(lrofgammazha)}}the likelihood ratio statistic sequence. This corresponds to {it:LR(gamma)}{p_end}
{synopt:{cmd:e(subsetgammazha)}}subset of the {it:gamma} sequence used for the Confidence Interval Construction for the Threshold Model{p_end}
{synopt:{cmd:e(belowthreszha)}}the regime dependent variable below the estimated threshold. This corresponds to {it:pi_it*I(q_it <= gamma_hat)}{p_end}
{synopt:{cmd:e(abovethreszha)}}the regime dependent variable above the estimated threshold. This corresponds to {it:pi_it*I(q_it > gamma_hat))}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(cmd)}}name of command{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}



{title:Return values for xtendothresdpdtest}

{pstd}
{cmd:xtendothresdpdtest} saves the following in {cmd:e()}. The command {cmd:xtendothresdpdtest} saves all the Stored Results 
returned by the command {bf:{manhelp bstat R}}. So I advise you to look at the Stored Results of the 
command {bf:{manhelp bstat R}} to see the descriptions and the explanations of all the Stored Results returned by the 
command {cmd:xtendothresdpdtest}. Hence to avoid duplication, in this help file, I do not list any Stored Results 
returned by the command {cmd:xtendothresdpdtest} because they are provided by the command {bf:{manhelp bstat R}}. Thus 
I advise you, please, to look at the help file for the command {bf:{manhelp bstat R}} to see all the Stored Results 
returned by the command {cmd:xtendothresdpdtest}.



{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We illustrate the use of the command {cmd:xtendothresdpd} with the dataset {hi: xtendothresdpddata.dta}. This 
dataset contains a sample of panel data for developed and developing countries in the World. It contains 8 periods of 
5 non overlapping years from 1975-1979 to 2010-2014. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/x/xtendothresdpddata.dta, clear"}{p_end}

{p 4 8 2} Next we describe the dataset to see the definition of each variable. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We regress the dependent variable (lggdppccstd) on the lagged dependent variable (L.lggdppccstd) and on the 
regime independent variables (lginvestgdpr lginflation). We put the threshold variable (debtpcgdpr) in the option 
{cmd:thresv()}. We put the string {hi:enr} without the double quotes in the option {cmd:stub()}. We put the variable 
that depends on the threshold (debtpcgdpr) in the option {cmd:pivar()}. In this specification, the threshold variable 
and the variable that depends on the threshold are the same. We will relax this assumption in some other regressions 
below. We put the GMM-type instruments for the difference equation (lggdppccstd) in the option {cmd:dgmmiv()}. We 
indicate that we want to compute the two-step estimator with the option {cmd:twostep}. Finally, we specify that we 
want the {hi:vcetype} to be robust with the option {cmd:vce(robust)}. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust)"}{p_end}

{p 4 8 2} We see that we have two tables of results. One big table (first table) and one small table (second table). In 
the big table of results with the title {it:Dynamic panel-data estimation}, we notice that two more variables have been 
generated: {hi:below_thres_enr} and {hi:above_thres_enr}. The variable {hi:below_thres_enr} corresponds to the regime 
dependent variable below the estimated threshold. This corresponds to {it:pi_it*I(q_it <= gamma_hat)}. The variable 
{hi:above_thres_enr} corresponds to the regime dependent variable above the estimated threshold. This corresponds to 
{it:pi_it*I(q_it > gamma_hat))}. The other variables in this big table correspond to the lagged dependent variable and 
the regime independent variables. This big table have also headers and footers. The small table of results with tile 
{it:Threshold Parameter (level = 90)} gives the statistics for the estimated threshold parameter (Gamma_Hat). The {it:(level = 90)} 
means that the reported threshold parameter have a 90 {it:percent} confidence interval. The results in this small table 
indicate that we have a threshold value of {hi: .30745} with lower bound confidence interval of {hi:.30192} and an upper 
bound confidence interval of {hi:.319}. The graphic indicates the Confidence Interval Construction for the Threshold 
Model. In this graphic, the Blue curve represents the likelihood ratio statistic: {it:LR(gamma)}. The Greene horizontal 
line represents the {it:alpha percent}, percentile of the asymptotic distribution of the likelihood ratio statistic: 
{it:C(alpha)}. The intersection of the two curves in this graphic correspond to the confidence interval. The point at 
which the Blue curve touches the x-axis corresponds to the estimated threshold parameter {it:Gamma_Hat}. {p_end}

{p 4 8 2} The estimations also generates additional variables that are thoroughly documented in the 
{hi:Return values for xtendothresdpd} section above and also explained by their respective labels. To see 
these variables, we type: {p_end}

{p 4 8 2}{stata "des enr_* below_thres_enr above_thres_enr"}{p_end}

{p 4 8 2} From an {it:Economics} point of view, the results above illustrate that {hi:Debt over GDP divided by 100} 
has a negative and significant effect, in both below and above the threshold of {hi:.30745}, on economic growth (see the big table and the small table). The 
effect below the threshold is economically larger than that above the threshold (see the big table). The small table 
shows that since {hi:0} ({hi:zero}) is not in the confidence interval for {hi:Gamma_Hat}, the estimated threshold is 
statistically significant at the 90 {it:percent} confidence interval. {p_end}

{p 4 8 2} In the next line, we estimate the same regression as above with the {cmd:noconstant} option. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) noconstant"}{p_end}

{p 4 8 2} We show how to use the {opt fpctile(#)} and  {opt lpctile(#)} options. In the next expression, the search 
for {it:gamma} starts at the 5th percentile and goes up to the 95th percentile of the threshold variable instead of the default. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) fpctile(5) lpctile(95)"}{p_end}

{p 4 8 2} The command {cmd:xtendothresdpd} handles time series operators in any of its variables. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr L.lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) fpctile(5) lpctile(95)"}{p_end}

{p 4 8 2} We demonstrate the use of the option {opt sig()}. We enter the value 0.05 to request the 95 {it:percent} confidence 
interval for the estimated threshold (the small table of results). {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) sig(0.05)"}{p_end}

{p 4 8 2} We estimate the previous equation with a 99 {it:percent} confidence interval for the {it:Dynamic panel-data estimation} 
(the big table of results). {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) sig(0.05) level(99)"}{p_end}

{p 4 8 2} Now, we exhibit how to employ additional endogenous variables correlated with the error. We 
suspect {hi:Log Fertility rate} to be endogenous. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr lgllgdpr, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) xaddendog(lgfertrate)"}{p_end}

{p 4 8 2} We have the {hi:Log Average Debt over GDP of other countries} as an instrument. We specify this instrument in both 
the {hi:zaddinst()} option for the additional instrumental variables for the intermediate computations and the {hi:iv()} 
option for the standard instruments for the difference and level equations. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr lgllgdpr, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) xaddendog(lgfertrate) zaddinst(lgdebtothers) iv(lgdebtothers)"}{p_end}

{p 4 8 2} In the next regression, we add more lags of the {hi:Log Fertility rate} in the {hi:iv()} option. Note that the {hi:iv()} option, 
being an option of the command {bf:{manhelp xtdpd XT}}, can be specified more than once. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) xaddendog(lgfertrate) zaddinst(lgdebtothers) iv(lgdebtothers) iv(L(1/2).lgfertrate, nodif)"}{p_end}

{p 4 8 2} If we do not want to display the graphic, we type: {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) nographs"}{p_end}

{p 4 8 2} In the following, we demonstrate how to use the {opt saving(string)} option. Assume that you have Windows as 
your Operating System and you want to save the graphic produced by the command {cmd:xtendothresdpd} in a folder named "mystatagraphs" 
located in the "C:\" drive. So the full path name is "C:\mystatagraphs". Note that, you must physically create this folder; 
otherwise the next instruction will not work at all. Also if you have an Operating System other than Windows, you must supply
the correct file path according to your Platform. To save the graphic in the "mystatagraphs" folder, just type 
(without forgetting the double quotes): {p_end}

{p 4 8 2}{stata `"xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) saving("C:\mystatagraphs")"'}{p_end}

{p 4 8 2} Now, we increase the number grid points used to estimate the threshold to 500. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) grid(500)"}{p_end}

{p 4 8 2} We demonstrate the use of the {cmd:fodeviation} option in conjunction with the {cmd: forcereg} option. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) forcereg fodeviation"}{p_end}

{p 4 8 2} We augment the number of lags of the lagged dependent variable to use as instruments for the intermediate computations to 2. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr lgllgdpr, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) lagsret(2)"}{p_end}

{p 4 8 2} As indicated above, the threshold variable needs not to be same as the variable that depends on the threshold. Here, we specify the threshold variable to 
be {hi:Liquid liabilities to GDP divided by 100}. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr lghc, thresv(llgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd)"}{p_end}

{p 4 8 2} The command {cmd:xtendothresdpd} can handle more control variables. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lggovconsgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust)"}{p_end}

{p 4 8 2} Next, we augment the control variables even more. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lggovconsgdpr lghc lgllgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd)"}{p_end}

{p 4 8 2} In the following, we increase the number of options of the command {bf:{manhelp xtdpd XT}} even more. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) lgmmiv(lggdppccstd) div(L(0/3).lgdebtothers, nodifference) vce(robust)"}{p_end}

{p 4 8 2} Let us explain how to use the {cmd:xtendothresdpd} command with the {bf:{manhelp if U}} qualifier. We run the 
regressions  for {it:period > 2}. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation if period > 2, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) noconstant"}{p_end}

{p 4 8 2} We exhibit how to employ the command {cmd:xtendothresdpd} with the {bf:{manhelp by D}} prefix. First, we 
tabulate by the development level of the countries. {p_end}

{p 4 8 2}{stata "tabulate developingcty"}{p_end}

{p 4 8 2} Then, we sort the dataset by the development level of the countries. {p_end}

{p 4 8 2}{stata "sort developingcty"}{p_end}

{p 4 8 2} Finally, we use the command {cmd:xtendothresdpd} with the {bf:{manhelp by D}} prefix.  {p_end}

{p 4 8 2}{stata "by developingcty: xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) noconstant"}{p_end}

{p 4 8 2} To continue this {hi:Examples} section, we now illustrate how to use the command {cmd:xtendothresdpd} with the {cmd:predict} 
command. First, we restore the original ordering of the dataset.  {p_end}

{p 4 8 2}{stata "tsset"}{p_end}

{p 4 8 2} We start by running the following regression.  {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) lgmmiv(lggdppccstd) div(L(0/3).lgdebtothers, nodifference) vce(robust)"}{p_end}

{p 4 8 2} We calculate the linear prediction. {p_end}

{p 4 8 2}{stata "predict double xbhat, xb"}{p_end}

{p 4 8 2} We calculate the residuals. {p_end}

{p 4 8 2}{stata "predict double residshat, e"}{p_end}

{p 4 8 2} We calculate the standard error of the prediction. {p_end}

{p 4 8 2}{stata "predict double stanerphat, stdp"}{p_end}

{p 4 8 2} We describe all the previously created variables to see their labels. {p_end}

{p 4 8 2}{stata "describe xbhat residshat stanerphat"}{p_end}

{p 4 8 2} We summarize these variables. {p_end}

{p 4 8 2}{stata "summarize xbhat residshat stanerphat"}{p_end}

{p 4 8 2} We compute the residuals for the first differences. {p_end}

{p 4 8 2}{stata "predict double residshatde, e difference"}{p_end}

{p 4 8 2} We describe the previously created variable to see its label. {p_end}

{p 4 8 2}{stata "describe residshatde"}{p_end}

{p 4 8 2} We summarize this variable. {p_end}

{p 4 8 2}{stata "summarize residshatde"}{p_end}

{p 4 8 2} To finish this {hi:Examples} section, we now illustrate how to use the command {cmd:xtendothresdpd} with 
the {cmd:xtendothresdpdtest} command. Before beginning, it is important to remind the user that the 
command {cmd:xtendothresdpdtest} is a postestimation command. So, you have to run it immediately after executing the 
command {cmd:xtendothresdpd}. Also, be sure to save your data before using the command {cmd:xtendothresdpdtest} because 
it removes the original dataset in memory. Additionally, remember that the command {cmd:xtendothresdpdtest} is highly 
computationally intensive. Hence, I advise you to be very patient when you execute it please. To begin, we first 
reload the dataset {hi: xtendothresdpddata.dta}. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/x/xtendothresdpddata.dta, clear"}{p_end}

{p 4 8 2} Second, we run the following regression. {p_end}

{p 4 8 2}{stata "xtendothresdpd lggdppccstd L.lggdppccstd lginvestgdpr lginflation, thresv(debtpcgdpr) stub(enr) pivar(debtpcgdpr) dgmmiv(lggdppccstd) twostep vce(robust) grid(100)"}{p_end}

{p 4 8 2} Third, we display the returned values of the previous regression. {p_end}

{p 4 8 2}{stata "ereturn list"}{p_end}

{p 4 8 2} Fourth, we set the random-number seed for reproducibility purposes. {p_end}

{p 4 8 2}{stata "set seed 542020"}{p_end}

{p 4 8 2} Fifth, we test if there is a threshold effect or not in the previous regression with the command {cmd:xtendothresdpdtest}. To 
run this test, we begin by indicating the name of command. Then, we specify the option {hi:comdline(`e(cmdline)')} by supplying the 
command line of the previous regression, in {it:left and right single quotes}, as was returned by the preceding {hi:ereturn list}. Finally, 
we indicate that we want 50 replications for our bootstrap. {p_end}

{p 4 8 2}{stata `"xtendothresdpdtest, comdline(`e(cmdline)') reps(50)"'}{p_end}

{p 4 8 2} In the table of results of the command {cmd:xtendothresdpdtest}, the statistic {hi:SupWStar} allows to test for {hi:H0} in 
expression {hi:(5)}. The {it:Null Hypothesis} for this test, is that there is no threshold effect in equation {hi:(1)} and 
the {it:Alternative Hypothesis} is that there is a threshold effect in equation {hi:(1)}. Since the statistic {hi:SupWStar} is 
statistically significant at the {it:5 percent} level, we conclude that there is a threshold effect in the previous regression. {p_end}

{p 4 8 2} To see the returned values of the command {cmd:xtendothresdpdtest}, we type: {p_end}

{p 4 8 2}{stata "ereturn list"}{p_end}

{p 4 8 2} To see the {it:Observed Coefficient} of the {hi:SupWStar} statistic, we type: {p_end}

{p 4 8 2}{stata "matrix list e(b)"}{p_end}



{title:References}

{pstd}
{hi:Caner Mehmet and Hansen Bruce E.: 2004,} "Instrumental Variable Estimation of a Threshold Model", {it:Econometric Theory} {bf:20}(5), 813-843.
{p_end}

{pstd}
{hi:Davies Robert B.: 1977,} "Hypothesis Testing when a Nuisance Parameter is Present only under the Alternative", {it:Biometrika} {bf:64}, 247-254.
{p_end}

{pstd}
{hi:Hansen Bruce E.: 1999,} "Threshold Effects in Non-Dynamic Panels: Estimation, Testing, and Inference", {it:Journal of Econometrics} {bf:93}, 345-368.
{p_end}

{pstd}
{hi:Kremer Stephanie, Bick Alexander and Nautz Dieter: 2013,} "Inflation and Growth: New Evidence from a Dynamic Panel Threshold Analysis", {it:Empirical Economics} {bf:44}, 861-878.
{p_end}



{title:Acknowledgements}

{pstd}
I thank Stephanie Kremer, Alexander Bick and Dieter Nautz; Bruce E. Hansen; Mehmet Caner; Robert B. Davies; and Sebastian Kripfganz for writing 
and making their programs and articles publically available. This current {hi:Stata} package is based and inspired by their 
works. The usual disclaimers apply: all errors and imperfections in this package are mine and all comments are very welcome.



{title:Author}

{p 4}Diallo Ibrahima Amadou {p_end}
{p 4}CERDI, University of Clermont Auvergne {p_end}
{p 4}26 Avenue Leon Blum  {p_end}
{p 4}63000 Clermont-Ferrand   {p_end}
{p 4}France {p_end}
{p 4}{hi:E-Mail}: {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for {bf:{manhelp xtdpd XT}}, {bf:{help xthreg}} (if installed), {bf:{help xthenreg}} (if installed), {bf:{help tstransform}} (if installed), {bf:{help suchowtest}} (if installed), {bf:{help tslstarmod}} (if installed)
{p_end}


