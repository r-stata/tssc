{smcl}
{* 13Oct2011}{...}
{hline}
help for {hi:ipdforest}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:ipdforest} {hline 2}} Forest plot for individual patient data IPD meta-analysis (one stage){p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:ipdforest}
{it:varname}
[{cmd:,} {it:{help ipdforest##options:options}}]

{p 4 4 2}
where

{p 6 6 2}
{it:varname} the exposure variable (continuous or binary, e.g. intervention/control).

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth re(varlist)}}Random effects covariate(s)
{p_end}
{synopt :{opth fe(varlist)}}Fixed effect(s) covariate(s)
{p_end}
{synopt :{opth fets(namelist)}}Fixed study-specific effect(s) covariate(s)
{p_end}
{synopt :{opth ia(varname)}}Interaction covariate
{p_end}
{synopt :{opt auto}}Automatically detect model specification
{p_end}
{synopt :{opth label(varlist)}}Study label variable(s)
{p_end}
{synopt :{opt or}}Report Odds Ratios
{p_end}
{synopt :{opt firstmi}}For multiple imputation only, use first imputed dataset for study-specific estimates
{p_end}
{synopt :{opt gsavedir(string)}}Directory to save forest-plot(s)
{p_end}
{synopt :{opt gsavename(string)}}Name prefix for forest-plot(s)
{p_end}
{synopt :{opt eps}}Save forest-plot(s) in eps format
{p_end}
{synopt :{opt gph}}Save forest-plot(s) in gph format (default)
{p_end}
{synopt :{opt export(string)}}Export results to Stata file
{p_end}

{p 4 4 2}
The forest plot has been edited to use the popular _DISPGBY display program from {cmd:metan} which offers numerous formatting options (see below)


{title:Description}

{p 4 4 2}
{cmd:ipdforest} is a post-estimation command which uses the saved estimates of an {cmd:xtmixed}/{cmd:mixed} or {cmd:xtmelogit}/{cmd:meqrlogit} command for multi-level linear or
logistic regression respectively. It will only work following one of these estimation commands (as stand-alone or as part of a bootstrap or mi estimate
command) and will automatically identify the model and the outcome and cluster variables (both numerical). Only two-level data structures are allowed
(patients nested within studies). The command requires one variable name as input, the exposure grouping variable, and executes a
regression analysis for each study to obtain the study effects. Binary or continuous exposure variables are allowed and if exposure is categorical
users should create dummy variables and focus on the comparison of interest through one of those, under {cmd:ipdforest}. Users need to follow the model
specified in the multi-level regression command and include all independent variables for which the meta-analysis regression was controlled,
using the {opt re()}, {opt fe()}, {opt fets()} or {opt ia()} options. This ensures that covariates are modelled in the individual study regressions as
they were modelled in the multi-level regression (i.e. as random,fixed, or study-specific fixed factors). Alternatively, users can use use the
{opt auto} option and allow {cmd:ipdforest} to automatically detect the exact specification of the preceding regression model and this will work in
most situations (see below).
A table with the study and overall effects is provided along with heterogeneity measures (some can only be calculated for {cmd:xtmixed}/{cmd:mixed} since an
estimate of within-study variance is not returned with {cmd:xtmelogit}/{cmd:meqrlogit}).

{title:Options}

{phang}
{opth re(varlist)} Covariates to be included as random factors. For each covariate specified, a different regression coefficient is estimated for
each study.

{phang}
{opth fe(varlist)} Covariates to be included as fixed factors. For each covariate specified, the respective coefficient in the study-specific
regressions is fixed to the value returned by the multi-level regression.

{phang}
{opth fets(namelist)} Covariates to be included as study-specific fixed factors (i.e. using the estimated study fixed effects from the main regression
in all individual study regressions). Only baseline scores and/or study identifiers can be included. For each covariate specified, the respective
coefficient in the study-specific regressions is fixed to the  value returned by the multi-level regression, for the specific study. For study-specific
intercepts the study identifier, not in factor variable format (e.g. studyid), or the stub of the dummy variables whould be included (e.g. studyid_ when
dummy study identifiers are studyid_1 studyid_3 etc). For study-specific baseline scores only the stub of the dummy variables is accepted (e.g.
dept0s_ when dummy study baseline scores are dept0s_1 dept0s_3 etc)

{phang}
{opth ia(varname)} Covariate for which the interaction with the exposure variable will be calculated and displayed. The covariate should
also be specified as a fixed, random or study-specific fixed effect. If binary, the command will provide two sets of results, one for each group.
If categorical, it will provide as many sets of results as there are categories. If continuous, it will provide one set of results for the main effect
and one for the interaction.
Although the command will accept a variable to be interacted with the exposure variable as a fixed or study-specific fixed effect, the variable
necessarily will be included as a random effect in the individual regressions (will not run a regression with the interaction term only, the main effects
must be included as well). Therefore, although the overall effect will differ between a model with a fixed effect interacted variable and a random effect
one, the individual study effects will be identical across the two approaches.

{phang}
{opt auto} Allows {cmd:ipdforest} to automatically detect the specification of the preceding model. This option cannot be issued along with options
{opt re()}, {opt fe()}, {opt fets()} or {opt ia()}. The {opt auto} option will work in most situations but it comes with certain limitations. It uses
the returned command string of the preceding command which is effectively constrained to 244 characters and therefore the auto option will return an
error if {cmd:ipdforest} follows a very wide regression model - in such a situation only the manual specification can be used. In addition, the variable
names used in the preceding model must follow certain rules: i) fixed-effect covariates (manually with option {opt fe()}) must not contain underscores,
ii) for study-specific intercepts (manually with option {opt fets()}) factor variable format is allowed or a {it:varlist} (e.g. cons_2-cons_16) but
each variable must contain a single underscore followed by the study number (not necessarily continuous) and iii) for study-specific baseline scores
(manually with option {opt fets()}) each variable must contain a single underscore followed by the study number (again, not necessarily continuous).
Note that there are no restrictions for random-effects covariates (manually with option {opt re()}). For interactions (manually with option {opt ia()})
the factor variable notation should be preferred (e.g. i.group#c.age) and alternatively the older {opt xi} notation. Interactions expanded to dummy
variables cannot be identified with the {opt auto} option and only the manual specification should be used in this case. Variables whose names start
with an '_I' and contain a capital 'X' will be assumed to be expanded interaction terms and, if detected in last model, {cmd:ipdforest} will
terminate with a syntax error.

{phang}
{opth label(varname)} Selects labels for the studies. Up to two variables can be selected and converted to strings. If two variables are selected they
will be separated by a comma. Usually, the author names and the year of study are selected as labels. If this option is not selected the command
automatically uses the value labels of the numeric cluster variable, if any, to label the forest plot. Either way, the final string is truncated to 30
characters.

{phang}
{opt or} Reporting odds ratios instead of coefficients. Can only be used following execution of {cmd:xtmelogit}.

{phang}
{opt firstmi} For multiple imputation only, use only the first imputed dataset to obtain the study-specific estimates for the graphs. This is not an ideal
approach but it is much less computationally expensive than obtaining multiple imputation based estimates for each study-specific analysis. In some cases the 
differences may be negligible, but users are urged to use with caution. Note that this only relates to the study-specific estimates, not the overall estimates
(which are always obtained from the previously executed multi-level model). 

{phang}
{opt gsavedir(string)} The directory where to save the graph(s), if different from the active directory.

{phang}
{opt gsavename(string)} Optional name prefix for the graph(s). Graphs are saved as `gsavename'_`graphname'.gph or `gsavename'_`graphname'.eps
where `graphname' includes a description of the summary effect (e.g. "main_group" for the main effect, if group is the intervention variable)

{phang}
{opt eps} Save the graph(s) in eps format, instead of the default gph.

{phang}
{opt gph} Save the graph(s) in gph format - the default. Use to save in both formats, since inlcluding only
the {opt eps} option will save the graph(s) in eps format only.

{phang}
{opt export(string)} Export the study identifiers, weights, effects and standard errors in a Stata dataset (named after {it:string}). Provided for users
wishing to use other commands or software to draw the forest plots.

{dlgtab:Graph formatting options}

{phang}
{opt dp(#)} Decimal points for the reported effects. The default value is 2.

{phang}
{opt effect(string)} This allows the graph to name the summary statistic used (e.g. OR, RR, SMD).

{phang}
{opt favours(string # string)} Applies a label saying something about the treatment effect to either
side of the graph (strings are separated by the # symbol).

{phang}
{opt null(#)} Displays the null line at a user-defined value rather than 0 or 1.

{phang}
{opt nulloff} Removes the null hypothesis line from the graph.

{phang}
{opt nooverall} Prevents display of overall effect size on graph (automatically enforces the {opt nowt} option).

{phang}
{opt nowt} Prevents display of study weight on the graph.

{phang}
{opt nostats} Prevents display of study statistics on graph.

{phang}
{opt nowarning} Switches off the default display of a note warning that studies are
weighted from random-effects anaylses.

{phang}
{opt nohet} Prevents display of heterogeneity statistics in the graph.

{phang}
{opt nobox} Prevents a weighted boc being drawn for each study and markers for point estimates are only shown.

{phang}
{opt boxsca(#)} Controls box scaling. The default is 100 (as in a percentage) and may be increased or decreased
as such (e.g., 80 or 120 for 20% smaller or larger respectively)

{phang}
{opth xlabel(numlist)} Defines x-axis labels. Any number of points may defined and the range can be enforced
with the use of the {opt force} option. Points must be comma separated.

{phang}
{opth xtick(numlist)} Adds tick marks to the x-axis. Points must be comma separated.

{phang}
{opt force} Forces the x-axis scale to be in the range specified by {opth xlabel()}.

{phang}
{opt texts(#)} Specifies font size for text display on graph. The default is 100 (as in a 
percentage) and may be increased or decreased as such (e.g., 80 or 120 for 20% smaller or larger respectively)

{phang}
{opt astext(#)} Specifies the percentage of the graph to be taken up by text. The default is 50
and the percentage must be in the range 10-90.

{phang}
{opt summaryonly} Shows only summary estimates in the graph.

{phang}
{opt classic} Specifies that solid black boxes without point estimate markers are used as in previous versions.

{phang}
{opth lcols(varlist)}, {opth rcols(varlist)} Define columns of additional data to the left or right of the graph.
The first two columns on the right are automatically set to effect size and weight, unless suppressed using 
the options {opt nostats} and {opt nowt}. {opth textsize()} can be used to fine-tune the size of the text
in order to acheive a satisfactory appearance. The columns are labelled with the variable label, or the variable name 
if this is not defined. The first variable specified in {opt lcols()} is assumed to be the study identifier and this
is used in the table output.

{phang}
{opt double} Allows variables specified in {opt lcols} and {opt rcols} to run over two lines in the plot.
This may be of use if long strings are to be used.

{phang}
{opt boxopt()}, {opt diamopt()}, {opt pointopt()}, {opt ciopt()}, {opt olineopt()}
Specify options for the graph routines within the program, allowing theuser to alter the appearance of the graph.
Any options associated with a particular graph command may be used, except some that would cause incorrect graph appearance.

{p 8 8 2}
{opt boxopt()} controls the boxes and uses options for a weighted marker
(e.g., shape, colour; but not size). See {help marker options}.

{p 8 8 2}
{opt diamopt()} controls the diamonds and uses options for pcspike (not horizontal/vertical).
See {help line options}.

{p 8 8 2}
{opt pointopt()} controls the point estimate using marker options.
See {help marker options} and {help marker label options}.

{p 8 8 2}
{opt ciopt()} controls the confidence intervals for studies using options
for pcspike (not horizontal/vertical). See {help line options}.

{p 8 8 2}
{opt olineopt()} controls the overall effect line with options for an additional 
line (not position). See {help line options}.

{phang}
Various {it:graph_options} can be used to specify overall graph options that would appear at the end of a {cmd:twoway}
graph command. This allows the addition of titles, subtitles, captions etc., control of margins, plot regions, graph size,
aspect ratio and the use of schemes. See {search graph options}.


{title:Remarks}

{p 4 4 2}
Each study estimate is calculated using a simple linear ({cmd:regress}) or logistic ({cmd:logit}) regression, limited to each study sample. The overall
effect is retrieved from the preceding mixed-effects regression command. Categorical variables can be specified with the 'i.' prefix, since the command
accepts factor variables.
If the multi-level regression was executed with the 'xi:' prefix, the dummy variables included in the model need to be specified individually. However,
we do not recommend this approach since full compatibility with interactions has not been ensured. Users should generate the interactions manually,
using the xi command before executing the regression command OR use the latest factor variable notation, available in v11 or later ({help fvvarlist}).
Although the command does not accept {opt if} or {opt in} options, it makes use of {cmd:e(sample)} in the preceding
regression command to automatically use the selected sample.
The forest plot(s) will be saved to disc if the user provides any of the four optional graph options.
The command is compatible with multiple imputation and bootstrap commands.
In the regression models please make sure you include both main effects and interactions, if you wish to investigate interactions; otherwise the command
will fail to execute.
A description of IPD meta-analysis methods and details in the use of {cmd:ipdforest} have been provided in a Stata Journal paper (http://www.stata-journal.com/article.html?article=st0309).

{title:Examples}

{p 4 4 2}
Assuming a dataset with six studies where {it:deptC} is a continuous outcome, {it:deptB} a binary outcome , {it:group} the intervention/control grouping
variable, {it:studyid} the numeric study cluster variable, {it:deptC_*} the baseline study dummy variables for the continuous outcome and {it:deptB_*}
the baseline study dummy variables for the binary outcome (e.g. if {it:deptC}_ is the outcome baseline variable, {it:deptC_1=deptC_ if studyid==1}).

{p 4 4 2}
Fixed common intercept; random treatment effect; fixed study-specific effect for baseline; fixed effects for age and sex:

{phang2}{cmd:. xtmixed deptC group age sex deptC_1 deptC_2 deptC_3 deptC_4 deptC_5 deptC_6 || studyid:group, nocons}{p_end}
{phang2}{cmd:. ipdforest group, fe(sex age) fets(deptC_)}{p_end}

{p 4 4 2}
Fixed study-specific intercept; random treatment effect; fixed study-specific effect for baseline; random effect sex, fixed for age:

{phang2}{cmd:. xtmelogit deptB group i.studyid age sex deptB_* || studyid:group sex, nocons}{p_end}
{phang2}{cmd:. ipdforest group, re(sex) fe(age) fets(studyid deptB_) label(author year) or}{p_end}

{p 4 4 2}
Random intercept; random treatment effect; fixed study-specific effect for baseline; random effects for age and sex, fixed effect for measure type:

{phang2}{cmd:. xtmelogit deptB group age sex i.measure i.group#i.measure deptB_* || studyid:group sex age, cov(uns)}{p_end}
{phang2}{cmd:. ipdforest group, re(sex age) fe(i.measure) fets(deptB_) ia(i.measure) label(author year) or}{p_end}

{p 4 4 2}
More examples provided in the Stata Journal paper. The data file used for the examples can be obtained from within Stata:

{phang2}{cmd:. net from http://www.stata-journal.com/software/sj13-3/}{p_end}
{phang2}{cmd:. net describe st0309}{p_end}

{title:Saved results}

{pstd}
{cmd:ipdforest} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(Isq)}}Heterogeneity measure I^2{p_end}
{synopt:{cmd:r(Isqlo)}}Heterogeneity measure I^2, lower 95% CI{p_end}
{synopt:{cmd:r(Isqup)}}Heterogeneity measure I^2, upper 95% CI{p_end}
{synopt:{cmd:r(Hsq)}}Heterogeneity measure H^2{p_end}
{synopt:{cmd:r(Hsqlo)}}Heterogeneity measure H^2, lower 95% CI{p_end}
{synopt:{cmd:r(Hsqup)}}Heterogeneity measure H^2, upper 95% CI{p_end}
{synopt:{cmd:r(tausq)}}Between study variance estimate tau^2{p_end}
{synopt:{cmd:r(tausqlo)}}Between study variance estimate tau^2, lower 95% CI{p_end}
{synopt:{cmd:r(tausqup)}}Between study variance estimate tau^2, upper 95% CI{p_end}
{synopt:{cmd:r(eff1pe_overall)}}Overall effect estimate{p_end}
{synopt:{cmd:r(eff1se_overall)}}Standard error of the overall effect{p_end}
{synopt:{cmd:r(eff1pe_st'i')}}Effect estimate for study 'i'{p_end}
{synopt:{cmd:r(eff1se_st'i')}}Standard error of the effect for study 'i'{p_end}

{pstd}
If an interaction with a continuous variable is included in the model the command also returns:

{synopt:{cmd:r(eff2pe_overall)}}Overall interaction effect estimate for{p_end}
{synopt:{cmd:r(eff2se_overall)}}Standard error of the overall interaction effect{p_end}
{synopt:{cmd:r(eff2pe_st'i')}}Interaction effect estimate for study 'i'{p_end}
{synopt:{cmd:r(eff2se_st'i')}}Interaction effect standard error for study 'i'{p_end}

{pstd}
If the variable interacted with the intervention is binary the command returns all the resuls described above, but the first set of effect results
corresponds to the effects for the first category of the binary (e.g. sex=0) and the second set for the second category (e.g. sex=1). If the variable
is categorical the command returns as many sets of effect results as there are categories (with each set corresponding to one category).


{title:Authors}

{p 4 4 2}
Evangelos Kontopantelis, Centre for Primary Care, Institute of Population Health

{p 29 4 2}
University of Manchester, e.kontopantelis@manchester.ac.uk

{p 4 4 2}
David Reeves, Centre for Primary Care, Institute of Population Health, University of Manchester


{title:Please cite as}

{p 4 4 2}
Kontopantelis E and Reeves D. A short guide and a forest plot command (ipdforest) for one-stage meta-analysis. The Stata Journal, 2013 Oct; 13(3): 574-587.
{browse "https://www.researchgate.net/publication/257316967_A_short_guide_and_a_forest_plot_command_%28ipdforest%29_for_one-stage_meta-analysis":http://www.stata-journal.com/article.html?article=st0309}

{title:Also see}

{p 4 4 2}
help for {help xtmixed}, {help xtmelogit}, {help mixed}, {help meqrlogit}

