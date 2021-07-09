{smcl}
{cmd:help mimrgns}
{hline}

{title:Title}

{p 4 8 2}
{cmd:mimrgns} {hline 2} {helpb margins} after {helpb mi estimate}


{title:Syntax}

{p 4 8 2}
Use after {cmd:mi estimate}

{p 8 16 2}
{cmd:mimrgns} 
[{help fvvarlist:{it:marginlist}}] 
{ifin} 
{weight} 
[ {cmd:,} {it:options} ]


{p 4 8 2}
Use after {cmd:mi estimate , saving() esample()}

{p 8 16 2}
{cmd:mimrgns} [{help fvvarlist:{it:marginlist}}] 
{ifin} {weight}
{helpb using} {it:{help filename:miestfile}} 
{cmd:, esample(}{it:{help varname}}{cmd:)} 
[ {it:options} ] 


{p 4 10 2}
where {it:miestfile}{cmd:.ster} contains estimation results 
previously saved by 

{p 8 16 2}
{cmd:mi estimate , saving(}{it:miestfile}{cmd:)} 
{cmd:esample(}{it:newvarname}{cmd:)}


{synoptset 20 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {cmd:esample(}{it:{help varname}}{cmd:)}}specify {it:varname} 
identifying the estimation sample
{p_end}
{synopt:{cmd:{ul:pr}edict(default)}}use {cmd:margins}' default 
prediction; {cmd:mimrgns}' default is {cmd:predict(xb)}
{p_end}
{synopt:{opt eform}}display (final) estimates in exponentiated form
{p_end}
{synopt:{opt cmdmargins}}set {cmd:r(cmd)} to {cmd:margins}; required 
before {helpb marginsplot}
{p_end}
{synopt:{opt noestimate}}do not re-estimate margins; only allowed 
with {opt cmdmargins}
{p_end}

{syntab:margins}
{synopt:{it:{help mimrgns##marg_opts:margins_options}}}options allowed 
with the {cmd:margins} command

{syntab:mi}
{synopt:{opt nosmall}}do not use small-sample correction for 
degrees of freedom
{p_end}
{synopt:{opt dots}}same as with {helpb mi_estimate:mi estimate}
{p_end}
{synopt:{opt noi:sily}}same as with {helpb mi_estimate:mi estimate}
{p_end}
{synopt:{opt trace}}same as with {helpb mi_estimate:mi estimate}
{p_end}
{synopt:{opt errorok}}same as with {helpb mi_estimate:mi estimate}
{p_end}
{synopt:{opt esampvaryok}}same as with {helpb mi_estimate:mi estimate}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt esample()} is required with the second syntax 
and not allowed with the first syntax 


{title:Description}

{pstd}
{cmd:mimrgns} runs {cmd:margins} after {cmd:mi estimate} and obtains margins 
of responses in multiply imputed datasets. 

{pstd}
The command generalizes 
{browse "http://www.stata.com/statalist/archive/2010-03/msg01021.html":Isabel Canette and Yulia Marchenko's} 
approach, which has later been adopted by the 
{browse "https://stats.idre.ucla.edu/stata/faq/how-can-i-get-margins-and-marginsplot-with-multiply-imputed-data/":UCLA Statistical Consulting Group}. See 
{help mimrgns##remarks:Remarks below}.

{pstd}
The first syntax mirrors the regular {cmd:margins} command; when specified, 
{cmd:mimrgns} runs both the estimation command and {cmd:margins} on the 
imputed datasets. The second ({cmd:using}) syntax is preferred; it obtains 
results from {it:miestfile} and only runs {cmd:margins} on the imputed 
datasets.


{title:Remarks}

{pstd}
There might be good reasons why Stata's {cmd:margins} command does not work 
after {cmd:mi estimate}. If you have not read 
{mansection MI miestimatepostestimationRemarksUsingthecommand-specificpostestimationtools:{it:Using the command-specific postestimation tools}}
in {manhelp mi_estimate_postestimation MI:mi estimate postestimation}, please 
do so.

{pstd}
Instead of applying {cmd:margins} to the (final) MI estimates, {cmd:mimrgns} 
treats {cmd:margins} itself as an estimation command and combines its results 
according to Rubin's rules. 

{marker par3}{...}
{phang}
{cmd:{ul:Nonlinear predictions}}
{p_end}

{pstd}
Applying Rubin's rules to {cmd:margins}' results assumes asymptotic 
normality. Assuming asymptotic normality is appropriate for linear 
predictions and for average marginal effects (White, Royston and Wood 2011) 
but might not be appropriate otherwise (also see 
{mansection MI mipredictRemarks:{it:Example 3: Obtain MI estimates of probabilities}} 
in {manhelp mi_predict MI:mi predict}). By default, {cmd:mimrgns} uses linear 
predictions for all estimation commands.

{marker par4}{...}
{phang}
{cmd:{ul:Graph results from mimrgns}}
{p_end}

{pstd}
In principle, {helpb marginsplot} works after {cmd:mimrgns}. However, 
there are two issues to consider. First, the plotted 
{help mimrgns##df:confidence intervals are based on}
{help mimrgns##df:inappropriate degrees of freedom}. {cmd:mimrgns} 
leaves the correct degrees of freedom in {cmd:r(df)} (or {cmd:r(df_vs)}, 
with the {opt pwcompare} option). Although the differences should be small 
for large sample sizes, consider alternatives to {cmd:marginsplot} that 
allow specifying the degrees of freedom used to calculate confidence 
intervals, e.g., Jann's {stata findit coefplot:{bf:coefplot}}. Second, 
graphs might be based on {help mimrgns##at:summary statistics that vary} 
{help mimrgns##at:across imputed datasets}. {cmd:mimrgns} uses dataset 
specific summary statistics, requested in {helpb at()} options, but 
reports their combined point estimate in the legend.

{phang}
{cmd:{ul:Further restrictions}}
{p_end}

{pstd}
{cmd:mimrgns} does not support joint hypothesis tests with 
the {help margins_contrast:{bf:contrast}} option.

{pstd}
{cmd:mimrgns} does not save all results that {cmd:margins} saves. This 
might lead to error messages when running post estimation commands, e.g., 
{helpb mi test}. Even if no error messages appear, such results might not 
be appropriate.


{title:Options}

{it:{dlgtab:Main}}
{phang}
{opt esample(varnme)} specifies the observations to be used in the 
estimation; {it:varname} is the same variable that was previously 
created by {cmd:mi estimate , esample({it:newvarname})}. The option 
is required with the second syntax and not allowed with the first 
syntax.

{phang}
{cmd:predict(default)} specifies that, instead of {cmd:mimrgns} 
default {cmd:predict(xb)}, the default prediction of the {cmd:margins} 
command is used. This option will usually result in nonlinear predictions 
for which Rubin's rules might not be appropriate; see 
{help mimrgns##par3:{ul:Nonlinear predictions}}.

{phang}
{opt eform} displays (final) coefficients in exponentiated form.

{phang}
{opt cmdmargins} sets {cmd:r(cmd)} (or {cmd:e(cmd)}, with {opt post}) 
to {cmd:margins}. This option is required before {cmd:marginsplot} 
(Stata 12 or higher) is used; see 
{help mimrgns##par4:{ul:Graph results from mimrgns}}.

{phang}
{opt noestimate} is only for use with {opt cmdmargins} and does not 
re-estimate margins. When you did not specify {opt cmdmargins} at 
estimation time, you may still (re-)set {cmd:r(cmd)} to {cmd:margins} 
typing

{p 16 16 2}{cmd:. mimrgns , cmdmargins noestimate}{p_end}

{marker marg_opts}{...}
{it:{dlgtab:margins}}

{phang}
{it:{help margins##options:margins_options}} are options allowed with 
the {cmd:margins} command. However, most {it:contrast_options} and option 
{opt nose} are not allowed.

{marker at}{...}
{phang2}
Option {opt at()} is allowed and may request summary statistics, such as 
the mean, minimum, or maximum of covariates. However, when covariates are 
multiply imputed there is no longer one mean (minimum, maximum, ...); there 
are now {it:M} of them. {cmd:mimrgns} fixes covariates at the imputed 
dataset specific statistic for calcutations but reports the combined point 
estimate as a single value. A note is issued below the results table as a 
reminder.

{it:{dlgtab:mi_options}}

{phang}
{opt nosmall} does not use the small-sample correction for the degrees of 
freedom. See the corresponding {help mi estimate##options:mi estimate option} 
for more details.

{phang}
{opt dots}, {opt noisily} and {opt trace} are the corresponding 
{help mi estimate:mi estimate {it:reporting_options}}.

{phang}
{opt errorok} and {opt esampvaryok} are the respective 
{help mi estimate##options:mi estimate options}. With the first syntax, 
you must repeat these options if you have specified them with 
{cmd:mi estimate} before.


{title:Examples}

{pstd}
Setup

{phang2}{stata webuse mheart1s20:. webuse mheart1s20}{p_end}
{phang2}{stata mi convert flong:. mi convert flong}{p_end}

{pstd}
Estimate a logistic regression model and save the results

{phang2}
{stata "mi estimate , saving(miestfile) esample(esample) : logit attack smokes age bmi hsgrad female":. mi estimate , saving(miestfile) esample(esample) : logit attack smokes age bmi hsgrad female}
{p_end}

{pstd}
Obtain average marginal effects (linear predictions)

{phang2}
{stata mimrgns using miestfile , esample(esample) dydx(*):. mimrgns using miestfile , esample(esample) dydx(*)}
{p_end}

{pstd}
Obtain average marginal effects in terms of predicted probabilities 
(but see {help mimrgns##par3:{ul:Nonlinear predictions}}).

{phang2}
{stata mimrgns using miestfile , esample(esample) predict(pr) dydx(*):. mimrgns using miestfile , esample(esample) predict(pr) dydx(*)}
{p_end}

{pstd}
Create age categories and re-run the logistic regression

{phang2}{stata "mi xeq : generate ageg = irecode(age, 20, 40 ,60, 80)":. mi xeq : generate ageg = irecode(age, 20, 40 ,60, 80)}{p_end}
{phang2}{stata "mi estimate : logit attack smokes i.ageg bmi hsgrad female":. mi estimate : logit attack smokes i.ageg bmi hsgrad female}{p_end}

{pstd}
Obtain pairwise comparisons of predictive margins

{phang2}{stata mimrgns ageg , pwcompare:. mimrgns ageg , pwcompare}{p_end}

{pstd}
Contrasts of predictive margins

{phang2}{stata mimrgns ar.ageg:. mimrgns ar.ageg}{p_end}


{pstd}
Erase {cmd:miestfile.ster}, created above.

{phang2}{stata erase miestfile.ster:. erase miestfile.ster}{p_end}


{title:Saved results}

{pstd}
{cmd:mimrgns} saves in {cmd:r()} some of the results that  
{help margins##saved_results:{bf:margins}} saves without the 
{cmd:post} option.

{pstd}
{cmd:mimrgns} additionally saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 24 tabbed}{...}
{synopt:{cmd:r(est_cmdline_mi)}}{cmd:e(cmdline_mi)} from {cmd:mi estimate}{p_end}
{synopt:{cmd:r(est_cmdline_margins)}}{cmd:margins} command{p_end}


{title:Addendum}

{marker df}{...}
{pstd}
{bf:Confidence intervals with marginsplot}

{pstd}
{cmd:marginsplot} internally replays results from the last {cmd:margins} 
command. It then uses the replayed results to recalculate confidence 
intervals (but not point estimates and standard errors). However, the 
replayed results are those obtained by {cmd:margins} in the last imputed 
dataset, not the ones reported by {cmd:mimrgns}. Thus, {cmd:marginsplot} 
does not use the correct degrees of freedom. Unfortunately, there is no 
way of passing the appropriate degrees of freedom to {cmd:marginsplot}; 
therefore, there is no way to get correct confidence intervals from 
{cmd:marginsplot} after {cmd:mimrgns}. Fortunately, the differences are 
often small and you can assess them as described on  
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1481264-mimrgns-and-marginsplot":Statalist}.


{title:References}

{pstd}
Jann, B. 2013. Plotting regression coefficients and other estimates in 
Stata. {it:University of Bern Social Sciences Working Papers Nr. 1}.  Available 
from {browse "http://ideas.repec.org/p/bss/wpaper/1.html"}

{pstd}
White, I. R., Royston, P., Wood, M. A. 2011. Multiple imputation using 
chained equations: Issues and guidance for practice. {it:Statistics in Medicine} 
30:377-399.

{pstd}
Stata FAQ. How can I get margins and marginsplot with multiply 
imputated data? UCLA: Statistical Consulting Group. from 
{browse "http://www.ats.ucla.edu/stat/stata/faq/ologit_mi_marginsplot.htm"}


{title:Acknowledgments}

{pstd}
Filip Safr reported a bug when {opt predict()} was called 
with more than one argument.

{pstd}
Wolf Edler reported problems when using {cmd:mimrgns} via a 
remote access that would not allow {cmd:{it:*}.class} files 
to be uploaded. This led to internal changes; {cmd:mimrgns} 
does no longer rely on such files.

{pstd}
Robbie Dembo reported a bug when {cmd:mimrgns} was called 
after {cmd:xt{it:*}} models fit with the {opt i()} option.

{pstd}
Xiao Yang (StataCorp) tracked down a bug that had gone 
unnoticed under Windows but prevented {cmd:mimrgns} 
from running under Linux.

{pstd}
Jesper Wulff reported a bug with 
{it:contrast-options} and {it:pwcompare-options} in 
Stata 13 (or higher).

{pstd}
Part of the code is borrowed (verbatim) from StataCorp's 
{cmd:_marg_report} routine. 

{pstd}
Evan Kontopantelis suggested support for contrast 
operators and reporting the {opt at} legend. 

{pstd}
Timothy Mak identified a bug with mixed models. 

{pstd}
Oliver Klein originally stimulated the {cmd:mimrgns} command.

	
{title:Author}

{pstd}
Daniel Klein{break}
INCHER-Kassel{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mi}, {helpb margins}{p_end}

{psee}
if installed: {helpb coefplot}{p_end}
