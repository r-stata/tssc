{smcl}
{* *! version 1.0.1  09jan2018}{...}
{* *! version 1.0.0  01jan2018}{...}
{* viewerdialog xtsfkk "dialog xtsfkk"}{...}
{vieweralsosee "sfkk: SJ17-1: st0466" "browse http://www.stata-journal.com/article.html?article=st0466"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "sfkk" "help sfkk"}{...}
{vieweralsosee "[R] frontier" "help frontier"}{...}
{vieweralsosee "[XT] xtfrontier" "help xtfrontier"}{...}
{viewerjumpto "Syntax" "xtsfkk##syntax"}{...}
{viewerjumpto "Description" "xtsfkk##description"}{...}
{viewerjumpto "Options" "xtsfkk##options"}{...}
{viewerjumpto "Examples" "xtsfkk##examples"}{...}
{viewerjumpto "Stored Results" "xtsfkk##results"}{...}
{viewerjumpto "Program Author" "xtsfkk##author"}{...}
{viewerjumpto "Recommended Citation" "xtsfkk##citation"}{...}
{viewerjumpto "Acknowledgments" "xtsfkk##acknowledgments"}{...}
{viewerjumpto "Disclaimer" "xtsfkk##disclaimer"}{...}
{title:Title}

{p2colset 9 19 23 2}{...}
{p2col :{hi:xtsfkk} {hline 2}}Endogenous panel stochastic frontier models in the style of {help xtsfkk##KK2017:{bind:Karakaplan and Kutlu (2017)}}{p_end}
{p2colreset}{...}


{title:Contents}

{pstd}{help xtsfkk##syntax:Syntax}{p_end}
{pstd}{help xtsfkk##description:Description}{p_end}
{pstd}{help xtsfkk##options:Options}{p_end}
{pstd}{help xtsfkk##examples:Examples}{p_end}
{pstd}{help xtsfkk##results:Stored Results}{p_end}
{pstd}{help xtsfkk##author:Program Author}{p_end}
{pstd}{help xtsfkk##citation:Recommended Citation}{p_end}
{pstd}{help xtsfkk##acknowledgments:Acknowledgments}{p_end}
{pstd}{help xtsfkk##disclaimer:Disclaimer}{p_end}


{marker syntax}{...}
{title:Syntax}

    Estimation Syntax

{p 8 17 2}
{cmd:xtsfkk} {depvar} [{indepvars}] {ifin} {weight} [{cmd:,} {it:options}]

    Version Syntax

{p 8 17 2}
{cmd:xtsfkk}, {opt ver:sion}

    Replay Syntax
	
{p 8 17 2}
{cmd:xtsfkk} [, {help level##remarks:level({it:#})}]


{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Frontier}
{synopt :{opt nocons:tant}}suppress constant term{p_end}
{synopt :{opt prod:uction}}fit production frontier model; can be omitted{p_end}
{synopt :{opt cost}}fit cost frontier model; default is production frontier model{p_end}

{syntab :Equations}
{synopt :{cmdab:en:dogenous(}{it:{help varlist:endovarlist}}{cmd:)}}specify endogenous variables{p_end}
{synopt :{cmdab:i:nstruments(}{it:{help varlist:ivarlist}}{cmd:)}}specify instrumental variables{p_end}
{synopt :{cmdab:ex:ogenous(}{it:{help varlist:exovarlist}}{cmd:)}}specify included exogenous variables;  
seldom used and can be omitted.{p_end}
{synopt :{cmdab:leave:out(}{it:{help varlist:lovarlist}}{cmd:)}}specify included exogenous variables
to be left out; seldom used and can be omitted.{p_end}
{synopt :{cmdab:u:het(}{it:{help varlist:uvarlist}}[{cmd:,} {opt nocons:tant}]{cmd:)}}explanatory
variables for inefficiency variance function; use {opt noconstant}
to suppress constant term{p_end}
{synopt :{cmdab:w:het(}{it:{help varlist:wvarlist}}{cmd:)}}explanatory
variables for idiosyncratic error variance function{p_end}

{syntab :Regression}
{synopt :{cmdab:init:ial(}{it:{help matrix:matname}}{cmd:)}}specify initial values matrix{p_end}
{synopt :{opt delve}}delve into maximization problem to find better initial values{p_end}
{synopt :{cmd:fast(}{it:#}{cmd:)}}specify speed to explore approximate results faster{p_end}
{synopt:{opt dif:ficult}}use a different stepping algorithm in nonconcave regions{p_end}
{synopt:{cmdab:tech:nique(}{it:{help maximize##algorithm_spec:algorithm_spec}}{cmd:)}}specify maximization technique{p_end}
{synopt:{opt iter:ate(#)}}perform maximum of {it:#} iterations; default is {cmd:iterate(16000)}{p_end}
{synopt :{cmdab:mlmod:el(}{it:{help ml##model_options:model_options}})}control ml model options; seldom used{p_end}
{synopt :{cmd:mlmax({it:{help ml##ml_maximize_options:maximize_options}})}}control ml maximize options; seldom used{p_end}

{syntab :Reporting}
{synopt :{opt ver:sion}}display {cmd:xtsfkk} version and program author information; can be used in Version Syntax only{p_end}
{synopt :{cmd:level(}{it:#}{cmd:)}}sets confidence level; default is {cmd:level(95)}; can be used in Replay Syntax
or in {cmd:mldisplay({it:display_options})} {p_end}
{synopt :{opt header}}display constraints header{p_end}
{synopt :{opt timer}}display elapsed time to command completion{p_end}
{synopt :{opt beep}}beep when command completes{p_end}
{synopt :{opt comp:are}}display exogenous model regression results after displaying
endogenous model regression results{p_end}
{synopt :{cmdab:eff:iciency(}{it:{help newvar:effvar}}[{cmd:,} {opt replace}]{cmd:)}}create efficiency variables
and summarize them in detail; use {opt replace} to replace contents of existing variables{p_end}
{synopt :{opt test}}test endogeneity and report results{p_end}
{synopt :{opt nice:ly}}display regression results nicely in single table{p_end}
{synopt :{cmdab:mldis:play(}{it:{help ml##display_options:display_options}})}control ml display options; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
All the variable lists above except {it:depvar} are allowed to contain {help fvvarlist:factor variables}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt xtsfkk} fits endogenous panel stochastic production or cost frontier models following
the methodology provided by {help xtsfkk##KK2017:{bind:Karakaplan and Kutlu (2017)}}. {opt xtsfkk} provides
estimators for the parameters of a linear model with a disturbance that is assumed to be 
a mixture of two components: a measure of inefficiency which is strictly nonnegative and 
a two-sided error term from a symmetric distribution. {opt xtsfkk} can handle endogenous
variables in the frontier and/or the inefficiency, and the {opt xtsfkk}
estimates outperform the standard {cmd:{help xtfrontier}} estimates that ignore endogeneity. 
See {help xtsfkk##KK2017:{bind:Karakaplan and Kutlu (2017)}} for a detailed
explanation of their methodology and empirical analyses.


{marker options}{...}
{title:Options}

{dlgtab:Frontier}

{phang}
{opt noconstant} suppresses the constant term (intercept) in the frontier.

{phang}
{opt production} specifies that the model to be fitted is a production frontier model. Since
the {opt xtsfkk} default is production, this option can be omitted.

{phang}
{opt cost} specifies that the model to be fitted is a cost frontier model. The
{opt xtsfkk} default is production.

{dlgtab:Equations}

{phang}
{cmd:endogenous({it:{help varlist:endovarlist}})}
specifies that the variables in {it:endovarlist} are to be treated as endogenous.
If this option is not specified, {opt xtsfkk} assumes that the model is exogenous.

{phang}
{cmd:instruments({it:{help varlist:ivarlist}})}
specifies that the variables in {it:ivarlist} are to be used as instrumental variables to handle
endogeneity. If this option is not specified, {opt xtsfkk} assumes that the model is exogenous.

{phang}
{cmd:exogenous({it:{help varlist:exovarlist}})}
specifies that {it:exovarlist} is the complete list of included exogenous variables. The
{opt xtsfkk} default for the complete list of included exogenous variables is {it:indepvars} + 
{it:uvarist} + {it:wvarlist}. Notice that depending on the model, {it:exovarlist} can be 
different than {it:indepvars} + {it:uvarist} + {it:wvarlist}. For an illustration, please see the
{help xtsfkk##examples:examples} below.
{cmd:exogenous({it:exovarlist})} cannot
be used with {cmd:leaveout({it:lovarlist})}. {cmd:exogenous({it:exovarlist})}
option is seldom used and can safely be omitted.

{phang}
{cmd:leaveout({it:{help varlist:lovarlist}})}
specifies that the variables in {it:lovarlist} are to be taken out of the {opt xtsfkk} default list of
included exogenous variables which is {it:indepvars} + {it:uvarist} + {it:wvarlist}. Notice that
depending on the model, some variables such as functions of some included exogenous variables 
can be left out of the 
complete list of included exogenous variables. For an illustration, please see the
{help xtsfkk##examples:examples} below. {cmd:leaveout({it:lovarlist})} cannot be used with
{cmd:exogenous({it:exovarlist})}. {cmd:leaveout({it:lovarlist})} 
option is seldom used and can safely be omitted.

{phang}
{cmd:uhet(}{it:{help varlist:uvarlist}}[{cmd:, noconstant}]{cmd:)}
specifies that the inefficiency component is heteroskedastic,
with the variance function depending on a linear combination of
{it:uvarlist}.  Specifying {opt noconstant} suppresses the
constant term from the variance function.

{phang}
{cmd:whet(}{it:{help varlist:wvarlist}}{cmd:)}
specifies that the idiosyncratic error component is heteroskedastic,
with the variance function depending on a linear combination of 
{it:wvarlist}.

{dlgtab:Regression}

{phang}
{cmd:initial(}{it:{help matrix:matname}})
specifies that {it:matname} is the initial value matrix. 

{phang}
{cmd:delve} provides a regression-based methodology to search for better initial values. The {opt xtsfkk}
default is to use {helpb ml search:ml search}. {cmd:delve} is often successful in finding better
initial values. Using {cmd:delve} is recommended.

{phang}
{cmd:fast({it:#})} provides a tolerance-based methodology to complete the regression faster. {it:#} can be specified
to take any value larger than 0. The regression completes faster with larger values of {it:#}, but larger values 
of {it:#} result in less accurate findings. Experimenting with various {it:#} is suggested as different 
values of {it:#} work better with different models. Using {cmd:fast({it:#})} is recommended
to explore the direction
of the maximization problem faster. However, in order to improve the accuracy of the findings,
it is highly recommended to avoid using {cmd:fast({it:#})} once the model is decided and 
specification is finalized.

{phang}
{opt difficult} specifies that the likelihood function is likely to be
difficult to maximize because of  nonconcave regions. When the message "not
concave" appears repeatedly, {opt ml}'s standard stepping algorithm may not be
working well. {opt difficult} specifies that a different stepping algorithm be
used in nonconcave regions. There is no guarantee that {opt difficult} will
work better than the default; sometimes it is better and sometimes it is
worse. {opt difficult} option should only be used when the default stepper
declares convergence and the last iteration is "not concave" or when the
default stepper is repeatedly issuing "not concave" messages and producing only
tiny improvements in the log likelihood.

{phang}
{cmd:technique({it:{help maximize##algorithm_spec:algorithm_spec}})} specifies how the likelihood function is to be
maximized. The following algorithms are allowed. For details, see 
{help maximize##GPP2010:Gould, Pitblado, and Poi (2010)}.

{pmore}
        {cmd:technique(nr)} specifies Stata's modified Newton-Raphson (NR)
        algorithm.

{pmore}
        {cmd:technique(bhhh)} specifies the Berndt-Hall-Hall-Hausman (BHHH)
        algorithm. BHHH is only allowed with {cmd:fast({it:#})} specification.

{pmore}
	{cmd:technique(dfp)} specifies the Davidon-Fletcher-Powell (DFP)
	algorithm.

{pmore}
        {cmd:technique(bfgs)} specifies the Broyden-Fletcher-Goldfarb-Shanno
        (BFGS) algorithm.

{pmore}The default is {cmd:technique(bfgs)}.

{pmore}
    Switching between algorithms is possible by specifying more than one algorithm in the
    {opt technique(.)} option. By default, an algorithm is used for
    five iterations before switching to the next algorithm. To specify a
    different number of iterations, include the number after the technique in
    the option. For example, specifying {cmd:technique(bfgs 10 nr 1000)}
    requests that {cmd:xtsfkk} perform 10 iterations with the BFGS algorithm
    followed by 1000 iterations with the NR algorithm, and then switch back
    to BFGS for 10 iterations, and so on. The process continues until the
    convergence or the maximum number of iterations is reached.

{phang}
{cmd:iterate({it:#})} specifies the maximum number of iterations. When the number
of iterations equals {it:#}, the optimizer stops and
presents the current results. If convergence gets declared before this
threshold is reached, the optimizer would stop and present the optimized results. The default
value of {it:#} for {cmd:xtsfkk} is the current value of
{bf:{help maximize##description:maxiter}}, which is {cmd:16000}.

{phang}
{cmd:mlmodel({it:{help ml##mlmode:model_options}})} can be used to control the {cmd:ml model}
options; seldom used

{phang}
{cmd:mlmax({it:{help ml##ml_max_descript:maximize_options}})} can be used to control the {cmd:ml max}
options; seldom used

{dlgtab:Reporting}

{phang}
{opt version} displays the version of {cmd:xtsfkk} installed on Stata, and the program author information.
This option can only be used in Version Syntax.

{phang}
{cmd:level({it:#})} specifies the confidence level, as a percentage, for confidence
intervals. The default is {cmd:level(95)} or as set by {help set level:set level}. This option can be
used in Replay Syntax or in {cmd:mldisplay(}{it:{help ml##mldisplay:display_options}}{cmd:)}

{phang}
{opt header} displays a summary of the model constraints in the beginning of the regression. {opt header}
provides a way to check the model specifications quickly while the estimation is running, or a guide to 
distinguish different regression results that are kept in a single {helpb log:log} file.

{phang}
{opt timer} displays the total elapsed time {opt xtsfkk} took to complete. 
The total elapsed time is measured
from the moment the command is entered to the moment the reporting of all findings is completed.

{phang}
{opt beep} produces a beep when {opt xtsfkk} reports all of the findings. {opt beep} is
useful for multitasking.

{phang}
{cmd:compare} estimates the specified model with exogeneity assumption and displays the regression
results after displaying the endogenous model regression results.  

{phang}
{cmd:efficiency(}{it:{help newvar:effvar}}[{cmd:, replace}]{cmd:)} generates the production or cost efficiency variable 
{it:effvar}_EN once the estimation is completed, and displays its summary statistics in detail. Notice that the option 
automatically extends any specified variable name {it:effvar} with _EN. If {cmd:compare}
option is specified, {cmd:efficiency} option also generates {it:effvar}_EX, the production or cost efficiency 
variable of the exogenous model, and displays its summary statistics. Specifying {opt replace}
replaces the contents of the existing {it:effvar}_EN and {it:effvar}_EX with the new efficiency values
from the current model. 

{phang}
{cmd:test} provides a method to test the endogeneity in the model. {cmd:test} tests the joint
significance of the components of the eta term, and reports the findings after displaying the regression
results. For more information about {cmd:test} see {help xtsfkk##KK2017:{bind:Karakaplan and Kutlu (2017)}}. 
 
{phang}
{cmd:nicely} displays the regression results nicely in a single table. {cmd:nicely} requires 
{helpb estout:estout}, a user-written command by Ben Jann, to format some parts of the table,
and {cmd:xtsfkk} table style
resembles that of {help xtsfkk##KK2017:{bind:Karakaplan and Kutlu (2017)}}. {cmd:nicely} option checks
if {helpb estout:estout} package
is installed on Stata or not, and if not, then {cmd:nicely} option installs the package. If
{cmd:compare} option is specified,
{cmd:nicely} displays the exogenous and endogenous models with their corresponding equations and
statistics side by side in a single table for easy comparison. {cmd:nicely} estimates the production
or cost efficiency and tests endogeneity, and reports them in the table
even if {cmd:efficiency(}{it:{help newvar:effvar}}) or {cmd:test} options are not specified.

{phang}
{cmd:mldisplay({it:{help ml##mldisplay:display_options}})} can be used to control the {cmd:ml display}
options; seldom used


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}{bf:Endogenous Panel Stochastic Cost Frontier Example}{p_end}
    Setup
{phang2}{cmd:. {stata "use http://www.mukarakaplan.com/files/xtsfkkcost.dta, clear"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk, version"}}{p_end}
{phang2}{cmd:. {stata "xtset id t"}}{p_end}

{pstd}Panel stochastic cost model with endogenous frontier and uhet variables{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) delve header timer beep"}}{p_end}

{pstd}Examples of using {cmd:fast(}{it:#}{cmd:)}, {cmd:initial(}{it:matname}{cmd:)},
{cmd:efficiency(}{it:effvar}{cmd:)}, and {opt test} options{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) fast(5) timer beep"}}{p_end}
{phang2}{cmd:. {stata "matrix EST = e(b)"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) init(EST) eff(costef) test beep"}}{p_end}

{pstd}Examples of using {opt compare} and {opt nicely} options{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) delve fast(10) compare beep"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) compare nicely beep"}}{p_end}

{pstd}Example of using {opt noconstant} option in the frontier{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 z1, cost u(z2) en(z1 z2) i(iv1 iv2) nicely nocons"}}{p_end}

    {hline}
{pstd}{bf:Endogenous Panel Stochastic Production Frontier Example}{p_end}
    Setup
{phang2}{cmd:. {stata "use http://www.mukarakaplan.com/files/xtsfkkprod.dta, clear"}}{p_end}
{phang2}{cmd:. {stata "summ"}}{p_end}
{phang2}{cmd:. {stata "xtset firm year"}}{p_end}

{pstd}Exogenous panel stochastic production model{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, prod u(z2)"}}{p_end}

{pstd}Panel stochastic production model with endogenous frontier and uhet variables{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, prod u(z2) en(z1 z2) i(iv1 iv2) nicely header beep"}}{p_end}

{pstd}Panel stochastic production model with an endogenous frontier variable and no uhet specification{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, en(z1) i(iv1) nicely header timer"}}{p_end}

{pmore}Notice that when uhet is not specified in the example above, the results table shows that uhet
included a constant by default. Uhet can also be specified with a variable but no
constant such as {bind:{cmd:uhet(z2, nocons)}}. Uhet specification would require at least one variable or the constant in uhet, and
specifying {bind:{cmd:uhet( , nocons)}} to exclude uhet altogether from the model would give an error as the 
inefficiency component is a necessary part of the model.

{pstd}
Examples of using the {cmd:exogenous()} and {cmd:leaveout()} options{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) exogenous(x1 x3) header"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) leave(x2) header"}}{p_end}

{pmore}Note that the two examples above generate the same results.
{cmd:exogenous()} and {cmd:leaveout()} provide two different ways to specify
the list of included exogenous variables to be used.  In these two models,
even though {cmd:x2} is used as an independent variable in the frontier
equation, it is not used as an independent variable in the endogenous variable
equations ({cmd:z1} and {cmd:z2}).

{pstd}Examples of using {opt difficult}, {cmd:technique(}{it:algorithm_spec}{cmd:)}, and {cmd:iterate(}{it:#}{cmd:)}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) diff compare nicely timer"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) tech(nr 5 bfgs 10) compare nicely timer"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) iter(30) compare nicely timer"}}{p_end}

{pmore}Notice that in the last example above, because of {cmd:iterate(30)} specification,
the optimizer stops prematurely and presents the results before the convergence is achieved. Hence, the
presented results are different than that in the two preceding examples. 

{pstd}Examples of using {cmd:mlmodel(}{it:model_options}{cmd:)}, 
{cmd:mlmax(}{it:maximize_options}{cmd:)}, {cmd:mldisplay(}{it:display_options}{cmd:)}, and
the Replay Syntax{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) mlmod(obs(1000))"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) diff mlmax(trace gradient)"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1, u(z2) en(z1 z2) i(iv1 iv2) tech(dfp 4 nr 4) diff compare mldis(coeflegend)"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk, level(80)"}}{p_end}

{pstd}Examples of using {opt weight} and {opt factor variables}{p_end}
{phang2}{cmd:. {stata "gen count = 1"}}{p_end}
{phang2}{cmd:. {stata "replace count = 2 if y > 0.8"}}{p_end}
{phang2}{cmd:. {stata "tab count"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1 [fweight = count], u(z2) en(z1 z2) i(iv1 iv2) nicely"}}{p_end}
{phang2}{cmd:. {stata "gen type = 1 + round(uniform())"}}{p_end}
{phang2}{cmd:. {stata "tab type"}}{p_end}
{phang2}{cmd:. {stata "xtsfkk y x1 x2 x3 z1 i2.type, u(z2 i2.type) en(z1 z2) i(iv1 iv2) nicely compare diff"}}{p_end}

    {hline}
  
  
{marker results}{...}
{title:Stored Results}

{pstd}
{cmd:xtsfkk} stores the following in {bf:{help e()}}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(effmed)}}median efficiency{p_end}
{synopt:{cmd:e(effmean)}}mean efficiency{p_end}
{synopt:{cmd:e(etatestX2)}}eta test chi-squared{p_end}
{synopt:{cmd:e(etatestp)}}eta test p value{p_end}
{synopt:{cmd:e(sigma_v)}}standard deviation of V_i{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(_estimates_name)}}name of stored results{p_end}
{synopt:{cmd:e(estimates_title)}}title of stored results{p_end}
{synopt:{cmd:e(cmdbase)}}base command{p_end}
{synopt:{cmd:e(cmd)}}name of user command{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(het)}}heteroskedastic components{p_end}
{synopt:{cmd:e(function)}}{bf:production} or {bf:cost}{p_end}
{synopt:{cmd:e(dist)}}distribution assumption for U_i{p_end}
{synopt:{cmd:e(chi2type)}}type of model chi-squared test{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(u_hetvar)}}{it:varlist} in {cmd:uhet()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable(s){p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{pstd}
{cmd:xtsfkk} stores the following in {bf:{help estimates}} memory:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Estimates}{p_end}
{synopt:{cmd:ModelEN}}stored estimates of endogenous model{p_end}
{synopt:{cmd:ModelEX}}stored estimates of exogenous model if {cmd:compare} option is specified{p_end}
{p2colreset}{...}

{pstd} Note that if {opt compare} option is specified, {bf:{help ereturn:ereturn list}}
would list the results from the last specification, which is the exogenous model. In order to retrieve
the stored results from the endogenous model, {bf:{help estimates:estimates restore ModelEN}} can be used.


{marker author}{...}
{marker citation}{...}
{marker KK2017}{...}
{marker acknowledgments}{...}
{marker disclaimer}{...}
{title:Program Author}

    Dr. Mustafa Ugur Karakaplan
    E-mail: {browse "mailto:mukarakaplan@yahoo.com":mukarakaplan@yahoo.com}
    Webpage: {browse www.mukarakaplan.com}

{pstd}For comments, suggestions, or questions about {cmd: xtsfkk}, please send
an email to me. {p_end}


{title:Recommended Citations}

{pstd}The following citations are recommended for referring to the {cmd:xtsfkk} program package,
underlying econometric methodology, and examples:

{phang}
+ Karakaplan, Mustafa U. (2018) "xtsfkk: Stata Module for Endogenous Panel Stochastic Frontier Models." Available at Boston College, Department of Economics, Statistical Software Components (SSC) 
{browse "https://ideas.repec.org/c/boc/bocode/s458445.html":S458445}{p_end}

{phang}
+ Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Endogeneity in Panel Stochastic Frontier Models."
{browse "http://www.tandfonline.com/doi/abs/10.1080/00036846.2017.1363861":Applied Economics}{p_end}


{title:More Recommended Citations}

{phang}
Karakaplan, Mustafa U. (2017) "Fitting Endogenous Stochastic Frontier Models in Stata."
{browse "http://www.stata-journal.com/article.html?article=st0466":The Stata Journal}{p_end}

{phang}
Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Handling Endogeneity in Stochastic Frontier Analysis."
{browse "http://www.accessecon.com/Pubs/EB/2017/Volume37/EB-17-V37-I2-P79.pdf":Economics Bulletin}{p_end}

{phang}
Karakaplan, Mustafa U. and Kutlu, Levent (2018) "School District Consolidation Policies: Endogenous Cost Inefficiency and Saving Reversals."
{browse "http://rdcu.be/DFEj":Empirical Economics}{p_end}

{phang}
Kutlu, Levent (2010) "Battese–Coelli Estimator with Endogenous Regressors." 
{browse "http://www.sciencedirect.com/science/article/pii/S0165176510002727":Economics Letters}{p_end}


{title:Acknowledgments}

{pstd}I would like to thank Levent Kutlu, Isabel Canette, Ben Jann, and Kit Baum for their amazing support.


{title:Disclaimer}

{pstd}{cmd:xtsfkk} is not an official Stata command. It is a third-party command
programmed by {help xtsfkk##author:Mustafa U. Karakaplan} as a free contribution
to the research society. By choosing to download, install and use the {cmd:xtsfkk} package,
users assume all the liability for any {cmd:xtsfkk} package related risk. If you encounter
any problems with the {cmd:xtsfkk} package, or if you have comments, suggestions, or questions,
please send an email to Mustafa U. Karakaplan at 
{browse "mailto:mukarakaplan@yahoo.com":mukarakaplan@yahoo.com}








