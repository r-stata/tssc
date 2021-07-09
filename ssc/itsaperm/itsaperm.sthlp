{smcl}
{* 03Apr2018}{...}
{title:Title}

{p2colset 5 17 22 2}{...}
{p2col :{hi:itsaperm} {hline 2}} Permutation tests for matched multiple group interrupted time series analysis {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:itsaperm} {depvar} [{indepvars}] {ifin} {weight}{cmd:,}
{opt trp:eriod(#)}
{opt treat:id(#)}
[ {opt p:r(#)}
{opt l:ag(#)}
{opt match:var(varlist)}
{opt plo:t}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
{opt fav:ors(string # string)} 
{opt prais}
{opt noi:sily}
{opt repl:ace}
{it:model_options} ]


{pstd}
The panel variable must be declared by using either {cmd:tsset} {it:panelvar} {it:timevar} 
or {cmd:xtset} {it:panelvar} {it:timevar}. See {helpb tsset} or {helpb xtset}.{p_end}


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt trp:eriod(#)}}specifies the time period when the intervention begins{p_end}
{p2coldent:* {opt treat:id(#)}}specifies the identifier of the true treated unit{p_end}
{synopt:{opt p:r(#)}}specifies the minimum significance level ({it:P}-value) for assessing balance{p_end}
{synopt :{opt l:ag(#)}}specifies the maximum lag to be considered when a {cmd:newey} model is chosen; 
the default is {cmd:lag(0)}{p_end}
{synopt:{opt match:var}{cmd:(}{it:{help varlist:varlist}}{cmd:)}}specifies the variables used for finding 
matches; the default is variables specified in {it:depvar} and {it:indepvars}{p_end}
{synopt:{opt prais}}fits a {helpb prais} model; the default model is {helpb newey}{p_end}
{synopt:{opt noi:sily}}specifies that estimates be shown in the output window as they are computed; the 
default is to show dots{p_end}
{synopt:{opt plo:t}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]}produces a forest plot of 
the difference-in-differences in trends{p_end}
{synopt:{opt fav:ors(string # string)}}inserts a label saying something about the treatment effect on 
either side of zero (strings are separated by the # symbol){p_end}
{synopt:{opt repl:ace}}replaces variables created by {cmd:itsaperm} if they already exist.{p_end}
{synopt:{it:model_options}}specifies all available options for {help prais} when the {cmd:prais} 
option is chosen; otherwise all available options of {help newey} {p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}* {opt trperiod(#)} and {opt treatid(#)} must be specified.{p_end}
{p 4 6 2}{opt aweight}s are allowed when a {helpb newey} model is specified; see
{help weight}.{p_end}


{title:Description}

{pstd}
{cmd:itsaperm} performs a robustness check in the form of permutation tests to assess whether the treatment 
effect (identified in a multiple group interrupted time series analysis with matched sets), 
remains plausible under a pseudo-treatment assignment process [Linden 2018b].

{pstd}
{cmd:itsaperm} iteratively casts each unit into the role of “treated”, creating a comparable 
control group from other units in the sample using {helpb itsamatch}, and then evaluates treatment effects using 
{helpb itsa}. The specific treatment effect evaluated is the differences-in-differences in trends (see Remarks 
section below). The results of the permutation tests are presented in a forest plot. If statistically significant 
“treatment effects” are estimated for pseudo-treated units, then any significant changes in the outcome of the true 
treatment unit cannot be attributed to the intervention (see [Linden 2018b] for a detailed discussion). 


   
{title:Options}

{phang}
{cmd:trperiod(}{it:#}{cmd:)} specifies the time period when the
intervention begins. The values entered for time period must be in the same
units as the panel time variable specified in {cmd:tsset} {it:timevar}; see
{helpb tsset}. {cmd:trperiod()} is required.

{phang}
{cmd:treatid(}{it:#}{cmd:)} specifies the identifier of the true treated
unit. The value entered must be in the same units as the panel variable 
specified in {cmd:tsset} {it:panelvar timevar}; see {helpb tsset}.
{cmd:treatid()} is required.

{phang}
{cmd:pr(}{it:#}{cmd:)} specifies the minimum significance level ({it:P}-value) for determining
balance on each variable in the {it:{varlist}}. While {cmd:pr} can be set to any value between
0 and 1.0, 0.05 is the usual convention for considering balance. Naturally, higher values will
ensure closer balance, but it comes at a trade-off of losing observations as potential matches.

{phang}
{cmd:lag(}{it:#}{cmd:)} specifies the maximum lag to be considered in the
autocorrelation structure when a {cmd:newey} model is chosen.  If the user
specifies {cmd:lag(0)}, the default, the output is the same as {cmd:regress,}
{cmd:vce(robust)}.  An error message will appear if both {cmd:prais} and
{cmd:lag()} are specified, because {cmd:prais} implements an AR(1) model by
design.

{phang}
{cmd:matchvar(}{it:varlist}{cmd:)} specifies the variables that are passed to {helpb itsamatch} 
for finding matched controls. When {cmd: matchvar} is not specified, variables specified in 
{it:depvar} and {it:indepvars} are used for matching (thus ensuring that, at a minimum, the 
the treatment unit and its matched controls will be balanced on the preintervention level 
and trend of the outcome time series).

{phang}
{cmd:prais} specifies to fit a {helpb prais} model.  If {cmd:prais} is
not specified, {cmd:itsa} will use {helpb newey} as the default model.

{phang}
{cmd:noisily} specifies that the outcome estimates (difference-in-differences in trends) be 
shown in the output window as they are computed for each (pseudo)treatment unit. The 
default is to show dots representing each unit permuted in the sample.

{phang}
{cmd:plot}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}] produces
a forest plot of the outcome (difference-in-differences in trends) for all of the permuted 
units in the sample (including a blank line for units in which controls could not be found). 
Specifying {cmd:plot} without options uses the default graph settings.

{phang}
{cmd:favors(}{it:string # string}{cmd:)} inserts a label saying something about the treatment effect 
on either side of zero -- most typically "favors treatment" and "favors control"; strings are separated by the # symbol.

{phang}
{cmd:replace} replaces the following variables created by {cmd:itsaperm} if they already exist:

{p 8 17 15}
{cmd:id:}{p_end}
{p 12 12 15}
Identifier for each unit permuted in the sample. If the {it:panelvar} specified in {help tsset} has a label,
it will be assigned to {cmd: id}  as well. {p_end}

{p 8 17 15}
{cmd:idC:}{p_end}
{p 12 12 15}
A string variable containing the IDs of controls matched to that unit.{p_end}

{p 8 17 15}
{cmd:estimate:}{p_end}
{p 12 12 15}
The point estimate of the difference-in-differences in trends.{p_end} 

{p 8 17 15}
{cmd:se:}{p_end}
{p 12 12 15}
The standard error of the difference-in-differences in trends estimate.{p_end} 

{p 8 17 15}
{cmd:t:}{p_end}
{p 12 12 15}
The t-statistic of the difference-in-differences in trends estimate.{p_end} 

{p 8 17 15}
{cmd:p:}{p_end}
{p 12 12 15}
The p-value of the difference-in-differences in trends estimate.{p_end} 

{p 8 17 15}
{cmd:lcl:}{p_end}
{p 12 12 15}
The lower bound of the 95% confidence interval of the difference-in-differences in trends estimate.{p_end} 

{p 8 17 15}
{cmd:ucl:}{p_end}
{p 12 12 15}
The upper bound of the 95% confidence interval of the difference-in-differences in trends estimate.{p_end} 

{phang}
{it:model_options} specify all available options for {helpb prais} when the
{cmd:prais} option is chosen; otherwise, all available options for 
{helpb newey} other than {cmd:lag()} are specified.


{title:Remarks} 

{pstd}
The basic regression model for a multiple group ITSA is as follows [Linden and Adams 2011; Linden 2015]:

{pmore} Y_t = Beta_0 + Beta_1(T) + Beta_2(X_t) + Beta_3(TX_t) +
Beta_4(Z) + Beta_5(ZT) + Beta_6(ZX_t) + Beta_7(ZTX_t){space 5}

{pstd}
Beta_0 represents the intercept or starting level of the outcome variable for 
the control group,

{pstd}
Beta_1 is the slope or trajectory of the outcome variable 
in the control group until the introduction of the intervention,

{pstd}
Beta_2 represents the change in the level of the outcome for the control group that occurs 
in the period immediately following the introduction of the intervention (compared with the
counterfactual),

{pstd}
Beta_3 represents the difference between preintervention and
postintervention slopes of the outcome in the control group,

{pstd}
Beta_4 represents the difference in the level (intercept) of the outcome variable between the treatment unit 
and controls prior to the intervention,

{pstd}
Beta_5 represents the difference in the slope (trend) of the outcome variable between the treatment unit and 
controls prior to the intervention,

{pstd}
Beta_6 indicates the difference between the treatment unit and control groups in the level of the outcome 
variable immediately following introduction of the intervention,

{pstd}
Beta_7 represents the difference between the treatment unit and control groups in the slope (trend) of the 
outcome variable after initiation of the intervention compared with preintervention (akin to a difference-in-differences
of trends). It is this parameter estimate that {cmd: itsaperm} uses for comparison between
the true treatment unit and all pseudo-treated units. 



{title:Examples}

{pmore}
Load data and declare the dataset as panel: {p_end}

{phang3}{cmd:. use cigsales, clear}{p_end}
{phang3}{cmd:. tsset state year}{p_end}

{pmore}
We generate a single-lag variable of the outcome: {p_end}

{phang3}{cmd:. gen Lcigsale = L1.cigsale}{p_end}

{pmore}
We run permutation tests across all units in the sample data, with the true treated unit being California (3) and the outcome variable "cigsale". 
We set the minimum cutoff {it:P}-value at 0.40, use cigsale and lagged cigsales for finding matches, specify autocorrelation at lag 1, 
and specify the titles on the left and right side of zero to indicate the treatment effect (this replicates data in Figure 3 of [Linden 2018b]).{p_end}

{phang3}{cmd:. itsaperm cigsale, trperiod(1989) treatid(3) matchvar(cigsale Lcigsale) lag(1) pr(0.40) plot favors(Favors treatment # Favors controls)}{p_end}

{pmore}
List control IDs associated with each pseudo-treatment ID (this replicates data in Table 1 of [Linden 2018b]).{p_end}

{phang3}{cmd:. list id idC if id !=.}{p_end}

{pmore}
Same as above but we reverse the yscale and change the presentation of the xlabels. We use {cmd: replace} to replace the variables generated in the previous run.{p_end}

{phang3}{cmd:. itsaperm cigsale, trperiod(1989) treatid(3) matchvar(cigsale Lcigsale) lag(1) pr(0.40) plot(yscale(reverse) xlabel(-6(1)6)) favors(Favors treatment # Favors controls) replace}{p_end}

{pmore}
We add retprice as a matching variable, and set the {it:P}-value cutoff to 0.20. We use {cmd:noisily} to see the output as it is produced.{p_end}

{phang3}{cmd:. itsaperm cigsale, trperiod(1989) treatid(3) matchvar(cigsale Lcigsale retprice) lag(1) pr(0.20) plot(yscale(reverse) xlabel(-6(1)6)) favors(Favors treatment # Favors controls) replace noisily}{p_end}

{pmore}
Same as above, but we now estimate the model using the {cmd: prais} option with robust standard errors and change the xlabel specification.{p_end}

{phang3}{cmd:. itsaperm cigsale, trperiod(1989) treatid(3) matchvar(cigsale Lcigsale retprice) pr(0.20) plot(yscale(reverse) xlabel(-10(2)10)) favors(Favors treatment # Favors controls) replace noisily prais vce(robust)}{p_end}


{title:References}

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
------. 2018a.
A matching framework to improve causal inference in interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}.
24: 408-415.

{phang}
------. 2018b.
Using permutation tests to enhance causal inference in interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}.
DOI:10.1111/jep.12899

{phang} 
Linden, A., and J. L. Adams. 2011. 
Applying a propensity-score based weighting model to interrupted time
series data: Improving causal inference in program evaluation. 
{it:Journal of Evaluation in Clinical Practice} 
17: 1231-1238.


{marker citation}{title:Citation of {cmd:itsaperm}}

{p 4 8 2}{cmd:itsaperm} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2018). ITSAPERM: Stata module for conducting permutation tests of matched sets in multiple group interrupted time series analysis {p_end}


{title:Author}

{pstd}Ariel Linden{p_end}
{pstd}Linden Consulting Group, LLC{p_end}
{pstd}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
       
 
{title:Also see}

{p 7 14 2}Help:  {helpb newey}, {helpb prais}, {helpb itsa} (if installed), {helpb itsamatch} (if installed)
 {p_end}
