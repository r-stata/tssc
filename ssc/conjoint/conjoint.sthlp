{smcl}
{* *! version 1.0.0 22may2021}{...}
{viewerjumpto "Syntax" "conjoint##syntax"}{...}
{viewerjumpto "Description" "conjoint##description"}{...}
{viewerjumpto "Options" "conjoint##options"}{...}
{viewerjumpto "Examples" "conjoint##examples"}{...}
{viewerjumpto "Remarks" "conjoint##remarks"}{...}
{viewerjumpto "Stored results" "conjoint##stored_results"}{...}
{viewerjumpto "Acknowledgements" "conjoint##acknowledgments"}{...}
{viewerjumpto "References" "conjoint##references"}{...}
{viewerjumpto "Author" "conjoint##author"}{...}

{marker title}{...}
{title:Title}

{phang}
{bf:conjoint} {hline 2} Analysis and visualisation of conjoint (factorial) experiments 


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:conjoint}
{depvar}
{indepvars}
{ifin}
{cmd:,}
{cmdab:est:imate(}{it:{help conjoint##syntax_estimate_options:estimate_options}}{cmd:)}
[{it:{help conjoint##syntax_options:options}} {it:{help conjoint##display_options:display_options}}]


{synoptset 22 tabbed}{...}
{synopthdr:Options}
{synoptline}
{marker syntax_estimate_options}{...}
{syntab:Estimate Options}
{synopt: {opt amce}}estimate average marginal component effects (AMCEs){p_end}
{synopt: {opt mm}}estimate marginal means (MMs){p_end}

{marker syntax_options}{...}
{syntab:Options}
{synopt: {opth id(varname)}}variable identifying respondents for calculating clustered standard errors{p_end}
{synopt: {opth sub:group(varname)}}variable identifying subgroups to be analysed{p_end}
{synopt: {opth base:levels(numlist)}}list of the baselevels for each variable {bf:(if amce are estimated)}{p_end}
{synopt: {opth con:straints(varlist)}}list of sets of variables to identify profile constraints 
{bf:(if amce are estimated)}{p_end}
{synopt: {opt h0(#)}}null hypothesis value {bf:(if mm are estimated)}{p_end}

{marker display_options}{...}
{syntab:Display Options}
{synopt: {opt no:table}}suppress coefficient table{p_end}
{synopt: {bf:graph[(#)]}}plot coefficients and type of plot{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:conjoint} can analyse and visualise choice-based conjoint (factorial) experiments. More specifically, {cmd:conjoint} can 
estimate average marginal component effects (AMCE) and marginal means (MM) following the methods described in 
{help conjoint##H2014:Hainmueller et al., (2014)} and {help conjoint##L2020:Leeper et al., (2020)} and 
implemented in the {bf:R} packages, {bf:cjoint} {help conjoint##B2018:(Barari et al., 2018)} 
and {bf:cregg} {help conjoint##L2020b:(Leeper and Barnfield, 2020)}. {cmd:conjoint} can estimate these 
for fully randomised designs and AMCEs for designs with unlimited and complex profile constraints. {cmd:conjoint} 
can also calculate estimates across subgroups, with different baselevels (AMCEs only) and null hypothesis 
values (MMs only). The results can be simply and easily plotted via {helpb coefplot}.


{marker options}{...}
{title:Options}

{dlgtab:Estimate Options}

{phang}
{opt estimate()} specifies the estimate type which can be {cmd:amce} or {cmd:mm}. {cmd:amce} 
represent the average change in probability of a profile being selected if an attribute (variable) changes 
from one level (the baselevel) to another level (the focal level). Alternatively, {cmd:mm} represent the 
average probability a profile is selected given an attribute level.

{dlgtab:Options}

{phang}
{opth id(varname)} specifies a variable identifying respondents for calculating clustered standard errors. 

{phang}
{opth sub:group(varname)} specifies a variable identifying subgroups over which to repeat the estimation.

{phang}
{opth base:levels(numlist)} manually specifies the baselevel for each attribute in order to estimate the ACME 
of each attribute level relative to that level. If not specified, the default baselevels are the first level 
for each attribute. If specified, baselevels must be entered for every attribute 
and in the order they appear in {indepvars}. The default is the first level of each attribute. For example, 
with three attributes, baselevels could be manually specified with {bf:base(1 1 4)} if the baselevels are to
be those represented by values of 1 for the first and second variable, and the level represented by 
values of 4 for the third variable {bf:(only applicable if AMCEs are estimated)}.

{phang}
{opth con:straints(varlist)} specifies sets of attributes (variables) where there are constrained or restricted 
attribute level combinations. Sets of attributes should be described using interactions ({cmd:#}) between the 
attributes and the constrained level combinations (within those sets of variables) will be detected 
automatically. Although multiple sets of constraints are possible, and each set can include unlimited 
attributes, each attribute can only appear in one set. Attributes can also be included here and not in 
{indepvars} if their AMCEs are not to be estimated. For example, if there are implausible, and so constrained
level combinations involving variables {bf:X} and {bf:Y}, this could be specified using {bf:constraint(X#Y)}
{bf:(only applicable if AMCEs are estimated)}.

{phang}
{opt h0(#)} specifies the null hypothesis value for calculating t-statistics and p-values. If not specified, the 
default value is 0.5 as most conjoints involve selecting from two alternatives and so the null hypothesis value 
for each attribute level is 50%, or more specifically, H0 = 0.5 {bf:(only applicable if MMs are estimated)}.

{marker display_options_detail}{...}
{dlgtab:Display Options}

{phang}
{opt no:table} suppresses the display of the coefficients table.

{marker graph_options_detail}{...}
{phang}
{bf:graph[(#)]} specifies to plot the coefficients via {helpb coefplot}. {cmd:graph} or {cmd:graph(0)} specifies that all 
estimates (which can include from different subgroups if relevant) are plotted on the same set of axes. Otherwise 
{cmd:#} specifies that each set of estimates are plotted on separate sets of axes or subgraphs and arranged as # columns 
with the number of rows necessary for the number of subgraphs. For example, if plotting two sets of 
estimates, {cmd:graph} or {cmd:graph(0)} would plot them on the same set of axes, {cmd:graph(1)} would plot them 
on separate axes stacked vertically in one column, and {cmd:graph(2)} would plot them side-by-side arranged in two columns.


{marker examples}{...}
{title:Examples}

{marker example_one}{...}
{dlgtab:Example 1}

{pstd}
For an example using {cmd:conjoint}, we can use a immigration conjoint experiment dataset 
{help conjoint##H2013:(Hainmueller et al., 2013)} as analysed in {help conjoint##H2014:Hainmueller et al., (2014)}, 
and using the two main R conjoint packages, {bf:cjoint} {help conjoint##B2018:(Barari et al., 2018)} 
and {bf:cregg} {help conjoint##L2020b:(Leeper and Barnfield, 2020)}. This dataset, included as an ancillary file 
(immigration_conjoint.dta) with accompanying do file (immigration_conjoint.do), includes responses from a sample 
of American adults who were asked to choose from hypothetical immigrants that they believe should be allowed 
into the United States. {p_end}

{pstd}
First we can load in the data:{p_end}

{phang2}{cmd:. use immigration_conjoint}{p_end}

{pstd}
We can estimate {bf:AMCEs} using all attributes in the design with the standard errors adjusted for 
clustering:{p_end}

{phang2} {cmd:. conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin Job Job_Experience}
{cmd: Job_Plans Reason_for_Application Prior_Entry, est(amce) id(CaseID)}{p_end}

{pstd}
Next, and knowing that some combinations of {bf:country of origin} and {bf:reason for application} and {bf:education} 
and {bf:job} were considered implausible and so restricted from the profiles seen by the participants, the same model 
can be run but incorporating these {bf:constraints}. This would equate to the first model that would be estimated using 
{bf:cjoint} on page 5 of {help conjoint##B2018:Barari et al., (2018)}:{p_end}

{phang2} {cmd:. conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin Job Job_Experience }
{cmd: Job_Plans Reason_for_Application Prior_Entry, est(amce) id(CaseID)}
{cmd: constraint(Country_of_Origin#Reason_for_Application Education#Job)}{p_end}

{pstd}
We could also run the same model but change the baselevel for {bf:language skills} (the third attribute), 
but remember we must also specify the baselevels for every attribute:{p_end} 
{phang2} {cmd:. conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin Job Job_Experience }
{cmd: Job_Plans Reason_for_Application Prior_Entry, est(amce) id(CaseID)}
{cmd: constraint(Country_of_Origin#Reason_for_Application Education#Job) base(1 1 4 1 1 1 1 1 1)}{p_end}

{pstd}
We could also use the same variables but estimate {bf:MMs} as would be estimated using {bf:cregg} on 
page 9 of {help conjoint##L2020b:Leeper and Barnfield (2020)}:{p_end}

{phang2} {cmd:. conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin Job Job_Experience }
{cmd: Job_Plans Reason_for_Application Prior_Entry, est(mm) id(CaseID)}{p_end}


{marker example_two}{...}
{dlgtab:Example 2}

{pstd}
For a second example using {cmd:conjoint}, we can use a refugee return conjoint experiment dataset 
{help conjoint##G2021a:(Ghosn et al., 2021a)} as analysed in {help conjoint##G2021b:Ghosn et al., (2021b)}. This dataset, 
included as an ancillary file (refugee_return_conjoint.dta) with accompanying do file (refugee_return_conjoint.do), includes 
responses from a sample of Syrian refugees who were asked to choose from hypothetical locations to which to 
consider returning.{p_end}

{pstd}
First we can load in the data:{p_end}

{phang2}{cmd:. use refugee_return_conjoint}{p_end}

{pstd}
We can estimate {bf:AMCEs} across all participants and using all attributes and the standard errors adjusted for clustering
as shown in the left panel in Figure 3 of {help conjoint##G2021b:Ghosn et al., (2021b)} using:{p_end}

{phang2} {cmd:. conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID)}{p_end}

{pstd}
We can also estimate the {bf:AMCEs} by experience, or not, of violence as shown in the middle and right panel 
in the same figure by specifying {bf:ExpViol} as the {bf:subgroup} variable:{p_end}

{phang2} {cmd:. conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID) subgroup(ExpViol)}{p_end}

{pstd}
The {bf:graph} option can be specified with both of these commands to produce separate graphs of the effects. However to 
combine them into the same figure (as per Figure 3) we could extract the results matrices from {bf:e()} after each
{bf:conjoint} command and adapt the code used to create each figure which is stored in {bf:e(graph_code)} after each
commands.{p_end}

{pstd}
Specifically, we would re-run the command estimating {bf:AMCEs} across all participants:{p_end}

{phang2} {cmd:. conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID)}{p_end}

{pstd}
If we use {bf:ereturn list} we can see these results are stored in {bf:e(results)} and can be saved (as they will be 
deleted when {bf:conjoint} is run again) using:{p_end}

{phang2} {cmd:. matrix overall_results = e(results)}{p_end}

{pstd}
We would also re-run the command estimating {bf:AMCEs} for those who have, and have not, experienced violence but this time append
the option {bf:graph(2)} to generate the graph code. Note we specify {bf:2} as this will plot the estimates on two subgraphs
which are arranged side-by-side (in 2 columns) and this is most similar to our final intended graph (of 3 plots side-by-side). {p_end}

{phang2} {cmd:. conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID) subgroup(ExpViol) graph(2)}{p_end}

{pstd}
We can again use {bf:ereturn list} again and see the results are stored in {bf:e(results_No)} and {bf:e(results_Yes)} based on
the labels of the two levels. We should again save these matrices:{p_end}

{phang2} {cmd:. matrix no_exp_viol_results = e(results_No)}{p_end}
{phang2} {cmd:. matrix exp_viol_results = e(results_Yes)}{p_end}

{pstd}
Next we can use the {bf:display} command with {bf:_asis} (see {helpb display}) to view the code used to generate the graph:{p_end}

{phang2} {cmd:. display _asis "`e(graph_code)'"}{p_end}

{pstd}
From this code we can see how the results matrices (in this case they were called {bf:results_No} and {bf:results_Yes})
are referred to and used. So, by adding our other matrix, {bf: matrix(overall_results[,1]), bylabel(Overall)}, 
renaming the current two matrix references to match our new matrix names (e.g. {bf:exp_viol_results} instead of 
{bf:results_Yes}), and change {bf:cols(2)} to {bf:cols(3)} to show our plots in 3 columns rather than 2, we can replicate 
Figure 3 from {help conjoint##G2021b:Ghosn et al., (2021b)} by:{p_end}

{phang2} {cmd:. coefplot  matrix(overall_results[,1]), bylabel(Overall) || matrix(no_exp_viol_results[,1]), bylabel(No experience) }
{cmd: || matrix(exp_viol_results[,1]), bylabel(Experienced violence) ||, ci(( 5 6)) keep(*:) xline(0, lpattern(-) lcolor(black)) }
{cmd: coeflabels( Low= "Low"  Moderate= "Moderate"  High= "High"  Easy= "Easy"  Moderate= "Moderate"  Hard= "Hard"  Low= "Low"  }
{cmd: Moderate= "Mo derate"  High= "High"  None= "None"  Some= "Some"  Many= "Many" ) eqlabels( "{bf:Chance of peace lasting a year}" }
{cmd: "{bf:Ease of finding work}" "{bf:Chance of harm on route}" "{bf:Number of people known there}", asheadings) byopts(graphregion(col(white)) }
{cmd: cols(3)) subtitle(, fcolor (gs15)) scale(0.7) xtitle({bf:Estimated AMCEs})}

{pstd}
Note you might want to change the sizes (or styles) of various parts of the plot. For example, the marker size: by adding {bf:msize()}, 
the x-axis title: by adding {bf:size()} to {bf:xtitle()}, and labels: by adding {bf:xlabel(,labsize())}, the level labels: by adding
{bf:labsize()} to {bf:coeflabels()}, attribute labels: by adding {bf:labsize()} to {bf:eqlabels()}, and the subplot labels: by adding
{bf:size()} to {bf:subtitle()} (see also {helpb coefplot}). If we repeat the above plot but change all these to small we finish with:{p_end}

{phang2} {cmd:. coefplot  matrix(overall_results[,1]), bylabel(Overall) || matrix(no_exp_viol_results[,1]), bylabel(No experience) || }
{cmd: matrix(exp_viol_results[,1]), bylabel(Experienced violence) ||, ci(( 5 6)) keep(*:) xline(0, lpattern(-) lcolor(black)) coeflabels( Low= "Low"  }
{cmd: Moderate= "Moderate"  High= "High"  Easy= "Easy"  Moderate= "Moderate"  Hard= "Hard"  Low= "Low"  Moderate= "Moderate"  High= "High"  }
{cmd: None= "None"  Some= "Some"  Many= "Many", labsize(small)) eqlabels( "{bf:Chance of peace lasting a year}" "{bf:Ease of finding work}" }
{cmd: "{bf:Chance of harm on route}" "{bf:Number of people known there}", asheadings labsize(small)) byopts(graphregion(col(white)) cols(3)) }
{cmd: subtitle(, fcolor (gs15) size(small)) scale(0.7) xtitle({bf:Estimated AMCEs}, size(small))  xlabel(,labsize(small)) msize(small)}


{marker remarks}{...}
{title:Remarks}

{pstd}
Although {bf:conjoint} can theoretically handle constraints involving sets of unlimited variables, estimation requires the generation of an 
expression and this can exceed the limit allowed by {bf:Stata}. This can happen in {bf:conjoint} when there are too many variables 
in a particular set, there are too many levels across the variables in a set, or the variable names are collectively too long. This should 
not however occur when there are large numbers of constraints but each constraint only involves a few variables. For example, when you have 
constraints involving a and b, c and d (specified as a#b c#d); whereas Stata may report an {bf:"expression too long"} error if 
you have complex constraints involving combinations of a,b,c and d (specified as a#b#c#d). This may be addressed in a future version.{p_end}


{marker stored_results}{...}
{title:Stored Results}

{pstd}
{cmd:conjoint} stores some or all of the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations*{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom*{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom* {bf:(if AMCEs are estimated)}{p_end}
{synopt:{cmd:e(r2)}}R-squared* {bf:(if AMCEs are estimated)}{p_end}
{synopt:{cmd:e(F)}}F statistic* {bf:(if AMCEs are estimated)}{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters* {bf:(if {cmd:id()} is specified)}{p_end}
{synopt:{cmd:e(h0)}}null hypothesis value {bf:(if MMs are estimated)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(graph_code)}}code used to generate graph {bf:(if {cmd:graph[()]} is specified)}{p_end}
{synopt:{cmd:e(baselevels)}}list of baselevels {bf:(if AMCEs are estimated)}{p_end}
{synopt:{cmd:e(constraints)}}list of constraints {bf:(if AMCEs are estimated {cmd:constraints()} is specified)}{p_end}
{synopt:{cmd:e(estimate)}}estimate type{p_end}
{synopt:{cmd:e(indepvars)}}name of independent variables{p_end}
{synopt:{cmd:e(model)}}{cmd:ols}{p_end}
{synopt:{cmd:e(vce)}}vcetype{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:conjoint}{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable {bf:(if {cmd:id()} is specified)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(results)}}results table*{p_end}

{pstd}
Note: Stored results marked with * will be stored for each subgroup using the notation {bf:e('stored result'_'subgroup label')} 
if {cmd:subgroup()} is specified.


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}
This was completed as part of the award W911-NF-17-1-0030 from the Department of Defense and U.S. Army Research Office/Army 
Research Laboratory under the Minerva Research Initiative. The views expressed are those of the author and should 
not be attributed to the Department of Defense or the Army Research Office/Army Research Laboratory.


{marker references}{...}
{title:References}

{marker B2018}{...}
{phang}
Barari, S., Berwick, E., Hainmueller, J., Hopkins, D., Liu, S., Strezhnev, A., & Yamamoto, T. 2018. cjoint: AMCE Estimator for 
Conjoint Experiments. R package.

{marker G2021a}{...}
{phang}
Ghosn, F., Chu, T.S., Simon, M., Braithwaite, A., Frith, M.J., & Jandali, J. 2021a. Replication Data for Journey Back Home: 
Violence, Anchoring, and Refugee Decisions to Return. {browse "https://doi.org/10.7910/DVN/UGI0MH"}

{marker G2021b}{...}
{phang}
Ghosn, F., Chu, T.S., Simon, M., Braithwaite, A., Frith, M.J., & Jandali, J. 2021b. The Journey Home: Violence, Anchoring, and 
Refugee Decisions to Return. American Political Science Review, 1–17. {browse "https://doi.org/10.1017/S0003055421000344"}

{marker H2013}{...}
{phang}
Hainmueller, J., Hopkins, D.J., & Yamamoto, T. 2013. Replication data for: Causal Inference in Conjoint Analysis: Understanding 
Multidimensional Choices via Stated Preference Experiments. {browse "https://doi.org/10.7910/DVN/THJYQR"}

{marker H2014}{...}
{phang}
Hainmueller, J., Hopkins, D.J., & Yamamoto, T. 2014. Causal Inference in Conjoint Analysis: Understanding Multidimensional 
Choices via Stated Preference Experiments. Political Analysis, 22(1): 1-30. {browse "https://doi.org/10.1093/pan/mpt024"}

{marker L2020b}{...}
{phang}
Leeper, T.J., & Barnfield, M. 2020. cregg: Simple Conjoint Tidying, Analysis, and Visualization. R package.

{marker L2020}{...}
{phang}
Leeper, T., Hobolt, S., & Tilley, J. 2020. Measuring Subgroup Preferences in Conjoint Experiments. Political Analysis, 
28(2): 207-221. {browse "https://doi.org/10.1017/pan.2019.30"}



{marker author}{...}
{title:Author}

{pstd}
Michael J. Frith{break}
University College London{break}
London, UK{break}
michael.frith@ucl.ac.uk

{pstd}
Comments, criticisms, and suggestions are all welcome.

{p_end}