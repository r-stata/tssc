{smcl}
{* *! version 1.0.0 4dec2017}{...}
{vieweralsosee "[ME] meqrlogit" "help ME meqrlogit"}{...}
{vieweralsosee "[ME] meqrlogit" "mansection ME meqrlogit"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] binreg" "help R binreg"}{...}
{vieweralsosee "[R] binreg" "mansection R binreg"}{...}
{viewerjumpto "Syntax" "metadta##syntax"}{...}
{viewerjumpto "Menu" "metadta##menu"}{...}
{viewerjumpto "Description" "metadta##description"}{...}
{viewerjumpto "Options" "metadta##options"}{...}
{viewerjumpto "Remarks" "metadta##remarks"}{...}
{viewerjumpto "Examples" "metadta##examples"}{...}
{viewerjumpto "Stored results" "metadta##results"}{...}

{title:Title}
{p2colset 5 23 25 2}{...}
{p2col :{opt metadta} {hline 2}} Fixed- and random-effects meta-analysis and meta-regression 
of diagnostic accuracy studies{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
[{help by} {varlist}{cmd::}] {opt metadta tp tn fp fn} [{indepvars}] {ifin} {cmd:,} 
{opt stu:dyid}({var})
[{it:{help metadta##options_table:options}} {it:{help metadta##foptions_table:foptions}}
{it:{help metadta##soptions_table:soptions}}]

{p 4 4 2}
{it:studyid} is a variable identifying each study.{p_end}
	
{p 4 6 2}{it:indepvars} should be {cmd:string} for categorical variables and/or {cmd:numeric} for continous variables. 
{cmd:The variable names should not contain underscores}.{p_end}

{marker options_table}{...}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Modeling}
{synopt :{opt mod:el(random|fixed [, modelopts])}}the type of model to fit; default is {cmd:random}. {help metadta##optimization_options:modelopts}
control the control the optimization process{p_end}
{synopt :{opth cov:(metadta##vartype:vartype)}}variance-covariance structure of 
the random-effects; default is {cmd: un}structured{p_end}
{synopt : {opth cv:effect(se|sp|sesp)}} specify which latent outcome is to be affected by 
covariate information; default is {cmd:sesp}{p_end}
{synopt : {opth in:teraction(se|sp|sesp)}} specify for latent outcome to include the interaction terms; default is {cmd:sesp}{p_end}
{synopt :{opt pair:ed}}indicate that for each study there are two observations so as to fit repeated measures logistic regression model{p_end}
{synopt :{opt nomc}}do not perform {cmd:m}odel {cmd:c}omparison with likelihood-ratio tests comparison the specified model with other simpler models{p_end}

{syntab:Reporting}
{synoptline}
{synopt :{opt prog:ress}} show the {cmd:progress} of the model estimation process{p_end}
{synopt :{opt out:table(logodds|abs|rr|all)}} which summary tables to present from the model estimates. Default is none of the tables. {p_end}
{synopt :{opt nofp:lot }} suppress the forest plot(s){p_end}
{synopt :{opt nosr:oc}} suppress the sroc plot {p_end}
{synopt :{opt noit:able}} suppress display of the table containing the studies{p_end}
{synopt :{opth label:(varname:[namevar=varname], [yearvar=varname])}}specifies that date be labelled by its name and/or year{p_end}
{synopt :{opt nove:rall}} suppress the display of overall estimates in the itable and fplot{p_end}
{synopt :{opt nosubg:roup}} suppress the display of the group estimates in the itable and fplot{p_end}
{synopt :{opt summ:aryonly}} suppress the individual studies in the itable and fplot{p_end}
{synopt :{opt down:load}} specify the location where a copy of data used to plot the forest plot should be stored {p_end}
{synopt :{opt dp:(#)}} set decimal points to display; default is {cmd: 3}{p_end}
{synopt :{opth l:evel(level)}} set confidence level; default is {cmd: level(95)}{p_end}
{synopt :{opt pow:er(#)}} set the exponentiating power; default is {cmd: 0}{p_end}
{synopt :{opth sort:by(varlist)}} sort the appearance of studies in the itable and fplot based on the variables in {help varlist}{p_end}
{synopt :{opt A:lphasort}} sort the categorical variables alphabetically {p_end}
{synopt :{opth ci:method(metapreg##citype:citype)}} specifies how the confidence intervals 
for the individuals study proportions are computed; default is {cmd:citype(exact)} for proportions. 
For relative ratios, the score/Koopman CI are computed{p_end}
{synoptline}

{marker foptions_table}{...}
{synopthdr:foptions}
{synoptline}
{synopt :{opt xla:bel(list)}} defines x-axis labels. No checks are made as to whether these points are sensible.  
The points in the list {cmd:must} be comma separated.{p_end}
{synopt :{opt xt:ick(list)}} adds the listed tick marks to the x-axis. The points in the list {cmd:must} be comma separated.{p_end}
{synopt :{opt plots:tat(label)}} specifies the label(name) for proportions/relative ratios in the forest plot{p_end}
{synopt :{opth outp:lot(abs|rr)}} specifies to plot absolute or relative measures when data is paired; default is {cmd:outplot(abs)}{p_end}
{synopt :{opt tex:ts(#)}}increases or decreases the text size of the label. Default value is 1{p_end}
{synopt :{opth lc:ols(varlist)}}specifies additional columns to the left of the plot{p_end}
{synopt :{opt double:}}allows more white space in the fplot by running the text on the left i.e {cmd:lcols(varlist)} over two lines in the fplot{p_end}
{synopt :{opth diam:opt(scatter##connect_options:connect_options)}}controls the diamonds{p_end}
{synopt :{opth point:opt(scatter##marker_options:marker_options)}}controls the points for the study estimates{p_end}
{synopt :{opth arr:owopt(twoway_pcarrow:marker_options)}}controls the arrows for the truncated confidence intervals of the study estimates{p_end}
{synopt :{opth ol:ineopt(scatter##connect_options:connect_options)}}controls the overall and subgroup estimates line{p_end} 
{synopt :{opt as:text(percent)}} percentage of the forest plot to be taken up by the text. Default is 50 {p_end}
{synopt :{opth cio:pt(scatter##connect_options:connect_options)}}controls the appearance of confidence intervals for studies{p_end}
{synopt :{opt subl:ine}} displays the line with group estimates{p_end}
{synopt :{opt noovl:ine}} suppress the overall line; by default the overall line is displayed{p_end}
{synopt :{opt nost:at}} suppress the text with estimates and confidence intervals; by default the text is displayed{p_end}
{synopt :{help twoway_options}} specifies other overall graph options{p_end}
{synoptline}

{marker soptions_table}{...}
{synopthdr:soptions}
{synoptline}

{synopt :{opt col:orpalette(string)}} specify the colour for each class of the grouping categorical variable. {p_end}
{synopt :{opt nopred:iction}} suppress the prediction region{p_end}
{synopt :{opt b:ubbles}} show the study size as weight{p_end}
{synopt :{opt bub:bleid}} identify the bubbles by row index {p_end}
{synopt :{opth sp:ointopt(scatter##marker_options:marker_options)}}controls the appearance of study points{p_end}
{synopt :{opth op:ointopt(scatter##marker_options:marker_options)}}controls the appearance of summary point(s){p_end}
{synopt :{opth cu:rveopt(scatter##connect_options:connect_options)}}controls the appearance of curve(s){p_end}
{synopt :{opth ci:opt(line_options:line_options)}}controls the appearance of confidence line(s){p_end}
{synopt :{opth predci:opt(line_options:line_options)}}controls the appearance of prediction line{p_end}
{synopt :{opth bubo:pt(scatter##marker_options:marker_options)}}controls the appearance of bubbles{p_end}
{synopt :{opth bid:opt(scatter##marker_label_options:label_options)}}controls the appearance of labels for the bubbles{p_end}
{synopt :{help twoway_options}} specifies other overall graph options e.g legend{p_end}

{marker optimization_options}{...}
{synoptline}
{synopthdr :Model options}
{synoptline}
{dlgtab: random-effects model}

{syntab:Integration}
{synopt :{opt intp:oints(# [# ...])}}set the number of 
integration (quadrature) points; default is {cmd:intpoints(7)}{p_end}
{synopt :{opt lap:lace}}use Laplacian approximation; equivalent to 
{cmd:intpoints(1)}{p_end}

{syntab :Maximization}
{synopt :{it:{help meqrlogit##maximize_options:maximize_options}}}control
the maximization process; seldom used{p_end}
{synopt :{opt retol:erance(#)}}tolerance for random-effects estimates; default 
is {cmd:retolerance(1e-8)}; seldom used{p_end}
{synopt :{opt reiter:ate(#)}}maximum number of iterations for random-effects
estimation; default is {cmd:reiterate(50)}; seldom used{p_end}
{synopt :{opt matsqrt}}parameterize variance components using matrix square
roots; the default{p_end}
{synopt :{opt matlog}}parameterize variance components using matrix logarithms
{p_end}
{synopt :{opth refine:opts(meqrlogit##maximize_options:maximize_options)}}control
the maximization process during refinement of starting values
{p_end}

{dlgtab: fixed-effects model}

{synopt :{it:{help binreg##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synopt :{opt fisher(#)}}Fisher scoring steps{p_end}
{synopt :{opt search}}search for good starting values{p_end}
{synoptline}

{marker vartype}{...}
{synopthdr :cov}
{synoptline}
{synopt :{opt ind:ependent}}different parameter for logit sensitivity and logit specificity random-effects, covariance is 0; the default{p_end}
{synopt :{opt exc:hangeable}}equal variances for logit sensitivity and logit specificity random-effects, 
and different covariance parameter{p_end}
{synopt :{opt id:entity}}equal variances for logit sensitivity and logit specificity random-effects,  
covariance is 0{p_end}
{synopt :{opt un:structured}}all variances logit sensitivity and logit specificity random-effects and covariances to be distinctly 
estimated{p_end}
{synoptline}

{marker citype}{...}
{synopthdr :citype}
{synoptline}
{synopt :{opt exact}}calculate exact confidence intervals; the default{p_end}
{synopt :{opt wald}}calculate Wald confidence intervals{p_end}
{synopt :{opt wilson}}calculate Wilson confidence intervals{p_end}
{synopt :{opt agres:ti}}calculate Agresti-Coull confidence intervals{p_end}
{synopt :{opt jeff:reys}}calculate Jeffreys confidence intervals{p_end}

{p2colreset}{...}

{synoptline}
{p2colreset}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:metadta} is a routine that performs meta-analytical pooling of diagnostic accuracy data from seperate but modelologically and 
epidemiologically similar studies. The routine implements the generalized linear model for the binomial family 
with a logit link, i.e logistic regression. 
It allows for meta-regression, and presents the results in tables, forest plot and/or SROC curve.  

{pstd}
The routine allows meta-regression and repeated measures analysis. When repeated measures analysis is perfomed, either the proportions
or the relative ratios can be tabulated and/or plotted (i.e with 1 or 2 covariates). When there are no covariates, heterogeneity is 
also quantified using the I-squared measure({help metapreg##ZD2014:Zhou and Dendukuri 2014}).

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt mod:el(modeltype [, modelopts])} specifies the type of model to fit. {it: modeltype} can be either {cmd:fixed} or {cmd:random}.
{it: modelopts} are options controlling the maximisation (both for the fixed- and random-effects model), 
and integration (only for the random-effects model) process.{p_end}

{phang2}
{opt mod:el(fixed [, modelopts])} fits a fixed-effects logistic regression model using  {helpb binreg}. 
{it: modelopts}:
{opt fisher(#)},
{opt search},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
{opt dif:ficult},
{opt iter:ate(#)},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance}, and
{opt from(init_specs)}; see {manhelp maximize R}. These options are seldom used.

{pmore2}
Setting {cmd:technique()} set to something other than BHHH, changes the {it:vcetype} to {cmd:vce(oim)}. 
Specifying {cmd:technique(bhhh)} changes {it:vcetype} to {cmd:vce(opg)}.

{phang2}
{opt fisher(#)} specifies the number of Newton-Raphson steps that should use
the Fisher scoring Hessian or expected information matrix (EIM) before
switching to the observed information matrix (OIM). This option is useful only for Newton-Raphson
optimization.

{phang2}
{opt search} specifies that the command search for good starting values. This
option is useful only for Newton-Raphson optimization.

{phang2}
{opt mod:el(random [, integrate_options maximize_options])} fits a mixed-effects logistic regression model using {helpb meqrlogit}. 
The model accounts for the between study heterogeneity and the intrisinc correlation between sensitivity and specificity. 

{pmore2}
{it:integrate_options}: {help meqrlogit##laplace:laplace}, {opt intpoints(#)}  

{phang3}
{opt intpoints(#)} sets the number of integration points for adaptive
Gaussian quadrature.  The more integration points, the more accurate the
approximation to the log likelihood.  However, computation time increases with
the number of quadrature points. {cmd:intpoints(7)} is the default.

{phang3}
{help meqrlogit##laplace:laplace} specifies that log likelihoods be calculated using 
the Laplacian approximation, equivalent to adaptive Gaussian quadrature with
one integration point; {cmd:laplace} is equivalent to {cmd:intpoints(1)}.  The computational time
saved by using {cmd:laplace} is a function of the number of quadrature points raised to a power 2 (the
dimension of the random-effects specification).

{pmore3}
The Laplacian approximation has been known to produce biased parameter
estimates, and the bias tends to be more prominent in the estimates of the
variance components rather than in the estimates of the fixed effects.

{phang2}
{help meqrlogit##maximize_options:maximize_options}:
{opt dif:ficult},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
{opt iter:ate(#)},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance}, and
{opt from(init_specs)};
see {helpb maximize:[R] maximize}.  These options are seldom used. 

{phang}
{opt cov(vartype)} specifies the structure of the covariance matrix for the two random-effects.  {it:vartype} is one of the following:
{cmd:independent}, {cmd:exchangeable}, {cmd:identity}, or {cmd:unstructured}.

{pmore}
{cmd:covariance(independent)} covariance structure allows a distinct
variance for each of the two random-effects and assumes the covariance is 0. 
The independent covariance matrix has 2 unique parameters. 


{phang2}
{cmd:covariance(exchangeable)} structure specifies one common variance for two
random effects and 'non-zero' covariance. The exchangeable covariance matrix has 2 unique parameters. 

{phang2}
{cmd:covariance(identity)} is all variances are equal and the covariance is 0. 
The identity covariance matrix has 1 unique parameters. 

{phang2}
{cmd:covariance(unstructured)} allows for all variances and covariances to be
distinct. The unstructured covariance matrix has 3 unique parameters. 
The default is {cmd:covariance(unstructured)}.

{phang}
{cmd: cveffect(effect)} specify which latent outcome is to be affected by 
covariate information. {it:effect} can be one of the following: {cmd:sesp}, {cmd:se}, {cmd:sp}. 
The default is {cmd:sesp}{p_end}

{phang2}
{cmd: cveffect(sesp)} specifies that the covariate be included in the equations for the logit sensitivity and logit specificity. 
{cmd: cveffect(sesp)} is the default. 

{phang2}
{cmd: cveffect(se)} specifies that the covariate be included only in the equations for the logit sensitivity.  

{phang2}
{cmd: cveffect(sp)} specifies that the covariate be included only in the equations for the logit specificity.  

{phang}
{cmd: interaction(effect)} specifies on which latent outcome the interactions between the {cmd:main} variable of interest and 
other confounding variables should be included. {it:effect} can be one of the following: {cmd:sesp}, {cmd:se}, {cmd:sp}. 
The default is {cmd:sesp}. This requires at-least two independent variables. 

{phang2}
{cmd: interaction(sesp)} specifies that interactions be included in the equations for the logit sensitivity and logit specificity. 
{cmd: interaction(sesp)} is the default. 

{phang2}
{cmd: interaction(se)} specifies that interactions be included in the equation for the logit sensitivity.  

{phang2}
{cmd: interaction(sp)} specifies that interactions be included in the equationfor the logit specificity.  

{phang}
{cmd: paired} indicate that for each study there are two observations so as to fit repeated measures logistic regression model. 
The variable identifying the pairs should be a {cmd: string} variable and should be the {cmd:fifth} variable after 
{cmd: tp tn fp fn}. 

{phang}
{cmd: nomc} indicates not perform {cmd:m}odel {cmd:c}omparison with likelihood-ratio tests comparison the specified model with other simpler models. 
By default, simpler models are also fitted to the data and model comparison done using a likelihood ratio tests. For a model with interactions, 
the simpler models have one less interaction term  in each of the two equations. For a model without interactions, the simpler model leaves one 
covariate effect in each of the two equations. A null model, i.e without covariates, is also compared with the specified model.
By default, model comparison is perfomed. By imposing {cmd: nomc}, substantial time can be saved 
especially for complex models involving many covariates and interactions.


{dlgtab:Reporting}

{phang}
{cmd: progress} specifies whether the noisily or quitely display the model maximization process as is being executed. 
By defualt the maximization process is executed quitely. This options is useful is stata is taking too long and you want 
to see if its actually busy with the maximisation process. On the down-side, there is alot of unnecessary ouput.

{phang}
{cmd: outtable(parameter)}} specifies which summary margins tables to present from the logistic regression model estimates. 
{it:parameter} can be one of the following:
{cmd: logodds}, {cmd: abs}, {cmd: rr}, {cmd: all} or a list eg {cmd: logodds abs rr}. By default none of the tables is displayed. 
The estimates are obtained using {help margins} which calculates predictions from a fitted model at fixed values of some covariates
and averaging or otherwise integrating over the remaining covariates. The tables present the parameter estimates, their standard-errors,
the z-statistic, and a confidence interval.

{phang2}
{cmd: outtable(logodds)}} requests the marginal {cmd:log-odds} for each class of the categorical variable, and the log-odds 
at the mean of continous varibles. When there are interaction, the log-odds are computed for the each combination of the 
variable of interest and the confounding factor.

{phang2}
{cmd: outtable(abs)}} requests the marginal {cmd:proportions} i.e {absolute} estimates for each class of the categorical variable, and the log-odds 
at the mean of continous varibles. When there are interaction, the proportions are computed for the each combination of the 
variable of interest and the confounding factor. The standard-errors, Z-statistic and p-value are in the log-odds scale.

{phang2}
{cmd: outtable(rr)}} requests the marginal {cmd:r}elative {cmd:r}atio estimates. When data is not paired, the ratio are computed using the first class in 
the categorical variable as the base. With paired data, the ratio comparing the two classes in the variable of interest is presented for each class of the 
confounding variables.  The standard-errors, Z-statistic and p-value are in the log scale. {cmd: outtable(rr)} requires at-least one covariate.

{phang}
{cmd: nofplot} suppress the forest plot(s). By default, a forest plot is presented.  

{phang}
{cmd: nosroc} suppress the sroc/cross plot. By default an sroc/cross plot is presented. For the model with no covariates, more than one 
covariates, or only continous variables, the sroc plots presents a center, an sroc curve, and the corresponding confidence and prediction regions for the 
overall sensitivity and specificity. A scatter of the studies in the meta-analysis is also plotted.
When there is one categorical variable, the center, sroc curve, confidence and prediction region, and the studies in each level 
are plotted each in a distinct colour. When a fixed-effects model is fitted, the sroc curve, and the confidence and prediction intervals are not presented.
Instead, a cross is plotted spanning the confidence intervals of sensitivity and specificity.

{phang}
{cmd: noitable} suppress display of the table containing the studies and the summary estimates. By default, the table presented. 

{phang}
{cmd: label(varname[namevar=varname], [yearvar=varname])} specifies that date be labelled by its name and/or year.  
Either or both option/s may be left blank.

{phang}
{cmd: noverall} suppress the display of overall estimates in the itable and fplot. By default, the overall summary estimate is presented. 

{phang}
{cmd: nosubgroup} suppress the display of the group estimates for each level of the grouping variable in the itable and fplot. 
By default, the group estimates are displayed. The group absolute estimates are displayed with one categorical variable. 
With paired data, two categorical variables where one is the variable of interest and the other a confounding variable, it is possible to 
present the group relative ratios with the options {cmd:paired} and {cmd: outplot(rr)}. The group estimates are not presented when there are more 
than one (for {cmd: outplot(abs)}) or two(for {cmd: outplot(rr)}) independent variables.

{phang}
{cmd: summaryonly} suppress the individual studies in the itable and fplot. This options is usefull when you want to present the group and overall estimates only,
or when the number of studies in each of the groups are too many to avoid over-crowding the itable and/or forest plot.

{phang}
{cmd: download(filepath)} specify the location where a copy of data used to plot the forest plot should be stored. The is useful if you need to fit other models to the 
exact data used by {cmd:metadta}, or when you want to generate other plots with the generated data. 
The saved dataset is in the long format and contains the following variables:

{pmore}
_ES			{space 10}Estimate proportion/relative ratio{p_end}
{pmore}
_LCI		{space 9}The lower confidence limit for _ES {p_end}
{pmore}
_UCI		{space 9}The upper confidence limit for _ES{p_end}
{pmore}
_ESAMPLE 	{space 5}Indicator variable if the study was included ({cmd:1}) or excluded({cmd:0}) in the model.{p_end}
{pmore}
_USE 		{space 9}Indicator variable for the role of an observation in the dataset: {cmd:-2} = labels, {cmd:0} = blanks, {cmd:1} = studies, {cmd:2} = group data, & {cmd:3} = overall data.{p_end}
{pmore}
_LABEL 		{space 7}Labels for each observations {p_end}
{pmore}
_ID			{space 10}A numeric observations ID equivalence of _LABEL{p_end}
{pmore}
_PARAMETER 	{space 3}Indicator variable to identify data on the sensitivity({cmd:1}) and specificity({cmd:0})
{p_end}

{phang}
{opt dp:(#)} sets the decimal points to display in the summary tables, the itable and the forestplot; default is {cmd: 3}. {cmd:#} is an any sensible positive integer.

{phang}
{cmd: level(level)} sets the confidence level. The default is {cmd: level(95)}. The set level is used in all computations for the confidence intervals, 
regions, prediction regions, and other computations that require a specification of the significance level. Other typical values are {cmd:level(90)} and {cmd:level(99)}.

{phang}
{cmd: power(#)} sets the exponentiating power with base {cmd:10}; default is {cmd: 0}. Any integer is allowed.  
When specified, the estimates in the summary tables, itable and the forest plot are multiplied by 10 raised to power {cmd:#}. 
The x-axis labels of the forest plot should be adjusted accordingly when power(#) is adjusted. This option is useful to present percentages instead of proportions or
when the estimates are very small and still want to display a reasonable number of decimal places.

{phang}
{cmd: sortby(varlist)} sort the appearance of studies in the itable and fplot based on the variables in {help varlist}. By default, the studies in the itable
and the forest plot are displayed as they appear in the data editor. If there group summaries are requested, data is sorted by group but within the group, the order
is maintained. The groups are sorted by their rank index in the data, i.e, the groups are sorted according to their appearance in the data.

{phang}
{cmd: alphasort} sort the categorical variables alphabetically. By default, are encoded such that the value labels are sorted according to the 
rank order as they appear in the data. The option {cmd:alphasort} sorts the categorical variables in the model alphabetical so that the class that appears
first alphabetically is assigned the base level. 

{phang}
{cmd: cimethod(citype)} specifies how the binomial confidence intervals 
for the individuals study proportions are computed. {it:citype} can be any of the following: 
{opt exact}, {opt wald}, {opt wilson}, {opt agresti}, and {opt jeffreys}. 

{pmore}
{cmd:cimethod(exact)} is the default and specifies exact (also known in the literature
as Clopper-Pearson [{help metadta##CP1934:1934}]) binomial confidence intervals.

{pmore}
{cmd:cimethod(wald)} specifies calculation of Wald confidence intervals.

{pmore}
{cmd:cimethod(wilson)} specifies calculation of Wilson confidence intervals.

{pmore}
{cmd:cimethod(agresti)} specifies calculation of Agresti-Coull confidence intervals.

{pmore}
{cmd:cimethod(jeffreys)} specifies calculation of Jeffreys confidence intervals.

{pmore}
See {help metadta##BCD2001:Brown, Cai, and DasGupta (2001)} for a discussion and
comparison of the different binomial confidence intervals. 

{pmore}
For relative ratios, the score/Koopman[{help metadta##KOOPMAN1984:1984}] CI are computed{p_end}

{dlgtab:foptions}

{phang}
{opt xla:bel(list)} defines x-axis labels. No checks are made as to whether these points are sensible.  The points in the list {cmd:must} be comma separated.{p_end}

{phang}
{opt xt:ick(list)} adds the listed tick marks to the x-axis. The points in the list {cmd:must} be comma separated.{p_end}

{phang}
{opt plots:tat(label)} specifies the label(name) for proportions/relative ratios in the forest plot.{p_end} 

{phang}
{cmd: outplot(abs|rr)} specifies to plot absolute or relative measures when data is {cmd:paired}; default is {cmd:outplot(abs)}. 

{pmore}
{cmd: outplot(abs)}  specifies to plot the absolute measures, i.e the sensitivity and specificity.

{pmore}
{cmd:outplot(rr)} specifies to plot the relative measures. 

{phang}
{opt tex:ts(#)}increases or decreases the text size of the label. Default value is 1{p_end}

{phang}
{cmd: lcols(varlist)}specifies additional columns to the left of the plot. {cmd: texts(#)} can be used to fine-tune the size of the text in order to 
achieve a satisfactory appearance.  The columns are labelled with the variable label, or the variable name if
this is not defined. The first variable specified in {cmd:lcols()} is assumed to be the study identifier and this is used in the itable output.

{phang}
{opt double:}allows more white space in the fplot by running the text on the left i.e {cmd:lcols(varlist)} over two lines in the fplot. This might be useful to make
the forest plot look less crowded.

{phang}
{opt diamopt(options)} controls the appearance of the diamonds. 
See {help scatter##connect_options:connect_options} for the relevant options. e.g {cmd: diamopt(lcolor(red))}
displays {cmd:red} (a) red diamond(s).

{phang}
{opt pointopt(options)} controls the points for the study estimates. 
See {help scatter##marker_options:marker_options} for the relevant options. e.g {cmd: pointopt(msymbol(x) msize(0))}

{phang}
{opt arrowopt(options)} controls the arrows for the truncated confidence intervals of the study estimates. 
See {help twoway_pcarrow:marker_options} for the relevant options. e.g {cmd: arrowopt(barbsize(small) msize(1))}

{phang}
{opt ciopt(options)} ontrols the appearance of confidence intervals for studies. 
See {help scatter##connect_options:connect_options} for the relevant options.

{phang}
{opt olineopt(options)} controls the overall and subgroup estimates line. 
See {help scatter##connect_options:connect_options} for the relevant options.

{phang}
{help twoway_options} specifies other overall graph to control how the look of the plot. This allows the addition of titles, subtitles, captions,
etc., control of margins, plot regions, graph size, aspect ratio, and the use of schemes. eg
{cmd: graphregion(color(white))}

{phang}
{opt astext(percent)} percentage of the forest plot to be taken up by the text. Default is 50. The percentage must be in the range 10-90.

{phang}
{cmd: subline} displays the line with group estimates. By default, the only the diamonds for the groups is displayed but not the lines.

{phang}
{cmd: noovline} suppress the overall line; by default the overall line is displayed.

{phang}
{opt nost:at} suppress the text with estimates and confidence intervals; by default the text is displayed{p_end}

{dlgtab:soptions}

{phang}
{cmd: colorpalette(string)} specify the colour for each class of the grouping categorical variable. The default color palette has the following
colours: {cmd: black forest_green cranberry blue sienna orange emerald magenta dknavy gray purple}. Each class of the grouping
variable is assigned a colour from the palette.

{phang}
{cmd: noprediction} suppress the prediction region. By default, the prediction region is displayed whenever the 
a random-effects model is fitted.

{phang}
{cmd: bubbles} show the study size as weight. By default, only a scatter points are displayed to indicate the studies. This option 
might be useful if interested in seeing the the study sizes since the bubble are proportional to the studies sizes.

{phang}
{cmd: bubbleid} identify the bubbles by row index. When the bubbles are plotted, one might be interested in identifying some studies. Each
bubble is identified by a number which is the row number of the submitted data.

{phang}
{opt spointopt(marker_options)} See {help scatter##marker_options:marker_options} controls the appearance of study points{p_end}

{phang}
{opt opointopt(marker_options)} See {help scatter##marker_options:marker_options} controls the appearance of summary point(s){p_end}

{phang}
{opt curveopt(connect_options)} See {help scatter##connect_options:connect_options} controls the appearance of curve(s){p_end}

{phang}
{opt ciopt(line_options)} See {help line_options:line_options} controls the appearance of confidence line(s){p_end}

{phang}
{opt predciopt(line_options)} See {help line_options:line_options} controls the appearance of prediction line{p_end}

{phang}
{opt bubopt(marker_options)} See {help scatter##marker_options:marker_options} controls the appearance of bubbles{p_end}

{phang}
{opt bidopt(label_options)} See {help scatter##marker_label_options:label_options} controls the appearance of labels for the bubbles{p_end}

{phang}
{help twoway_options} specifies the graph options for the SROC plot giving control of axis, scales, legend, titles, subtitles, captions,
 margins, plot regions, graph size, aspect ratio, etc. e.g
{cmd: graphregion(color(white))}


{marker remarks}{...}
{title:Remarks}

{pstd}
With {help metadta}, a fixed-effects or a random-effects model can be fitted. A random-effects model accounts for correlation between logit sentivity and specificity 
and allows the quantification of heterogeneity between studies. On the other hand, a fixed-effects model assuming homogeneous studies or whenever 
the random-effects model cannot be fitted, i.e when there are less than {cmd:3} studies.

{pstd}
In fitting the logistic regression, {helpb meqrlogit} is used for the random-effects model and {helpb binreg} for the fixed-effects model. 
The binomial distribution is used to model the within-study variability ({help metadta##Hamza2008:Hamza et al. 2008}).
Studies with less variability have more influence in the pooled estimate since they contribute more to the likelihhod function. The 
weighting is not explicit because parameter estimation is an iterative procedure. Therefore, even though the forest plot does not display
weights for the individual studies, weighting is indeed done. The logistic regression requires at least two studies to run.


{marker examples}{...}
{title:Examples}
{marker example_one}{...}
{pstd}
{cmd :1. Intercept-only random-effects model}

{pmore}
The intercept-only model is the classical model for meta-anlysis to pool data. The data is obtained from
a systematical review of sensitivity and specificity of cytology and other markers including telomerase for 
primary diagnosis of bladder cancer {help metadta##Glass200:Glas et al (2003)}.   

{pmore}
The look of the sroc and forest plot is enhanced via {cmd:soptions(...)} and {cmd:foptions(...)}.

{pmore2}
{stata `"use "http://fmwww.bc.edu/repec/bocode/t/telomerase.dta""':. use "http://fmwww.bc.edu/repec/bocode/t/telomerase.dta"}
{p_end}

{pmore2}
{cmd:. metadta tp tn fp fn,												///} 
{p_end}
{pmore3}
{cmd:studyid(study) model(random) dp(2) outtable(all)					///}   
{p_end}
{pmore3}
{cmd:soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))					///} 
{p_end}
{pmore3}
{cmd:ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 							///} 
{p_end}
{pmore3}
{cmd:graphregion(color(white)) plotregion(margin(medium)) xsize(15) ysize(15)									///} 
{p_end}
{pmore3}
{cmd:legend(order(1 "Summary" 3 "Observed data" 2  "SROC" 4 "Confidence region" 5 "Prediction region") 	///} 
{p_end}
{pmore3}
{cmd:cols(1) ring(0) bplacement(6)))									///}  
{p_end}
{pmore3}
{cmd:foptions(graphregion(color(white)) texts(2.5) xlabel(0, 0.5, 1) 									///} 
{p_end}
{pmore3}
{cmd:diamopt(color(red)) olineopt(color(red) lpattern(dash)))}
{p_end}

{pmore2} 
{it:({stata "metadta_examples example_one":click to run})}

{marker example_two}{...}
{pstd}
{cmd :2. Metaregression - Paired data - 1 Covariate}

{pmore}
This example demonstrates how the intercept only model is extended in a meta-regression setting. 
The data is from a Cochrane review on the accuracy of human papillomavirus testing and repeat cytology to 
triage of women with an equivocal Pap smear to diagnose cervical precancer performed by {help metadta##Arbyn2013:Arbyn et al(2013)}.   

{pmore}
The option {cmd:paired} indicates that the data is in pairs and automatically the first covariate serves as the pair identifying variable. 
With one categorical variable, different sroc curves each for every category is also displayed. The look of the sroc and forest plot is enhanced 
via {cmd:soptions(...)} and {cmd:foptions(...)}. 

{pmore2}
{stata `"use "http://fmwww.bc.edu/repec/bocode/a/ascus.dta""':. use "http://fmwww.bc.edu/repec/bocode/a/ascus.dta"}
{p_end}

{pmore2}
{cmd:. metadta tp tn fp fn test, 									///}  
{p_end}
{pmore3}
{cmd:studyid(studyid) model(random) paired outtable(all)  									///} 
{p_end}
{pmore3}
{cmd:soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1)) 									///} 
{p_end}
{pmore3}
{cmd:ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid)  									///} 
{p_end}
{pmore3}
{cmd:legend(order(1 "Repeat Cytology" 2 "HC2") ring(0) bplacement(6)) 									///} 
{p_end}
{pmore3}
{cmd:graphregion(color(white)) plotregion(margin(zero)) col(red blue)) 									///}  	
{p_end}
{pmore3}
{cmd:foptions(graphregion(color(white)) outplot(abs) texts(2) xlabel(0, 1, 1) 									///}  
{p_end}
{pmore3}
{cmd:diamopt(color(red)) olineopt(color(red) lpattern(dash)))} 
{p_end}

{pmore2} 
{it:({stata "metadta_examples example_two":click to run})}

{marker example_three}{...}
{pstd}
{cmd :3. Metaregression - Paired data - 2 Covariates} 

{pmore}
This example demonstrates how to examine (dis-)similarity of relative sensitivity and specificity across the different clinical setup. 
Using sample of data from a meta-analysis on accuracy of human papillomavirus testing on self-collected versus
clinician-samples {help metadta##Arbyn2014:Arbyn et al(2014)}, we test whether the relative sensitivity and relative specificity between self and 
clinician sample are similar across the clinical settings.

{pmore}
From simple analysis via tables, it was suspected that the sensitivity and specificity was different by the clinical setting and sample collection.
We therefore include an interaction between {cmd:sample} and {cmd:Setting} with the option {cmd:interaction(sesp)}. {cmd:sesp} implies that the interaction
terms are introduced in both the logit {cmd:se}nsitivity and logit {cmd:sp}ecificity equations. Model comparison with simpler models that do exclude the 
interaction terms happens automatically. 

{pmore}
With the option {cmd:outtable(rr)} only the summary relative ratios are presented. The option {cmd:noitable} also suppresses 
the table with individual studies.

{pmore}
The look of the sroc and forest plot is enhanced via {cmd:soptions(...)} and {cmd:foptions(...)}. With more than one covariate, 
the sroc plot presents the overall curve.

{pmore2}
{stata `"use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta""':. use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta"}
{p_end}

{pmore2}
{cmd:. metadta tp tn fp fn sample Setting,  									///}
{p_end}
{pmore3}
{cmd:studyid(study) interaction(sesp) model(random)  									///}
{p_end}
{pmore3}
{cmd:summaryonly  paired outtable(rr) noitable  									///}
{p_end}
{pmore3}
{cmd:soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1)) 									///}
{p_end}
{pmore3}
{cmd:ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid)  									///}
{p_end}
{pmore3}
{cmd:graphregion(color(white)) plotregion(margin(zero)))  									///}
{p_end}
{pmore3}
{cmd:foptions(diamopt(color(red)) olineopt(color(red) lpattern(dash)) 									///} 
{p_end}
{pmore3}
{cmd:outplot(RR) graphregion(color(white)) texts(2) xlabel(0.7, 1, 1.2))} 
{p_end}	

{pmore2} 
{it:({stata "metadta_examples example_three":click to run})}
			
{marker example_four}{...}
{pstd}
{cmd :4. Metaregression - Paired data - 3 Covariates}

{pmore}
We extend {help metadta##example_three:Example 3} above and examine differences in relative sensitivity and specificity by test assay while 
accounting for the clinical setup. The look of the sroc and forest plot is enhanced via {cmd:soptions(...)} and {cmd:foptions(...)}.

{pmore2}
{stata `"use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta""':. use "http://fmwww.bc.edu/repec/bocode/c/clinself.dta"}
{p_end}

{pmore2}
{cmd:. metadta tp tn fp fn sample Setting TA,									///} 
{p_end}
{pmore3}
{cmd:studyid(study) interaction(sesp) model(random) cov(unstructured)									///}  
{p_end}
{pmore3}
{cmd:paired noitable outtable(rr)									///}
{p_end}
{pmore3}
{cmd:soptions(xtitle("False positive rate") xlabel(0(0.2)1) xscale(range(0 1))									///}
{p_end}
{pmore3}
{cmd:ytitle("Sensitivity") yscale(range(0 1)) ylabel(0(0.2)1, nogrid) 									///}
{p_end}
{pmore3}
{cmd:graphregion(color(white)) plotregion(margin(zero)))									///} 
{p_end}
{pmore3}
{cmd:foptions(outplot(rr) graphregion(color(white)) texts(1.5) xlabel(0.7, 1, 1.3)									///} 
{p_end}
{pmore3}
{cmd:arrowopt(msize(1)) diamopt(color(red)) olineopt(color(red) lpattern(dash)))} 
{p_end}

{pmore2} 
{it:({stata "metadta_examples example_four":click to run})}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:metadta} stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(cmd)}} {cmd:metadta}{p_end}
{synopt:{cmd:e(cmdline)}} command as typed{p_end}
{synopt:{cmd:e(i_sq)}} estimated I squared{p_end} 
{synopt:{cmd:e(p_chi2)}} p-value for LR test comparing the fixed and random effects models{p_end}
{synopt:{cmd:e(chi2)}} chisq. for LR test comparing the fixed and random effects models{p_end}
{synopt:{cmd:e(df)}} degrees of freedom{p_end}
{synopt:{cmd:e(sp_df_het)}} degrees of freedom for the LR test on significance of the covariates on specificity{p_end}
{synopt:{cmd:e(sp_p_het)}} p-value for the LR test on significance of the covariates on specificity{p_end}
{synopt:{cmd:e(sp_het)}} chi square statistic for the LR test on significance of the covariates on specificity{p_end}
{synopt:{cmd:e(se_df_het)}} degrees of freedom for the LR test on significance of the covariates on sensitivity{p_end}
{synopt:{cmd:e(se_p_het)}} p-value for the LR test on sigficance of the covariates on sensitivity{p_end}
{synopt:{cmd:e(se_het)}} chi square statistic for the LR test on significance of the covariates on sensitivity{p_end}
{synopt:{cmd:e(sp_p_z)}} p-value for testing if specificity = 0.5 or rel. specificity = 1 {p_end}
{synopt:{cmd:e(sp_z)}} z-statistic for testing if specificity = 0.5 or rel. specificity = 1 {p_end}
{synopt:{cmd:e(sp_ci_upp)}} upper confidence limit of the overall specificity estimate{p_end}
{synopt:{cmd:e(sp_ci_low)}} lower confidence limit of the overall specificity estimate{p_end}
{synopt:{cmd:e(sp_seES)}} standard error of the overall specificity estimate{p_end}
{synopt:{cmd:e(sp_ES)}} overall specificity estimate (either a proportion or ratio){p_end}
{synopt:{cmd:e(se_p_z)}} p-value for testing if sensitivity = 0.5 or rel. sensitivity = 1{p_end}
{synopt:{cmd:e(se_z)}} z-statistic for testing if sensitivity = 0.5 or rel. sensitivity = 1 {p_end}
{synopt:{cmd:e(se_ci_upp)}} upper confidence limit of the overall sensitivity estimate{p_end}
{synopt:{cmd:e(se_ci_low)}} lower confidence limit of the overall sensitivity estimate{p_end}
{synopt:{cmd:e(se_seES)}} standard error of the overall sensitivity estimate{p_end}
{synopt:{cmd:e(se_ES)}}	overall sensitivity estimate (either a proportion or ratio){p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(sprrout)}} summary relative specificity ratios {p_end}
{synopt:{cmd:e(serrout)}} summary relative sensitivity ratios {p_end}
{synopt:{cmd:e(rrout)}} summary relative ratios {p_end}
{synopt:{cmd:e(absoutsp)}} summary specificity proportions{p_end}
{synopt:{cmd:e(absoutse)}} summary sensitivity proportions{p_end}
{synopt:{cmd:e(absout)}}  summary proportions{p_end}
{synopt:{cmd:e(logodds)}} summary log-odds{p_end}
{synopt:{cmd:e(vcovar)}} variance-covariance matrix of logit sensitivity and specificity.{p_end} 

{p2colreset}{...}

{title:Technical notes}
{cmd: by}
{pstd}
When prefix {cmd:by} is used, only the results from the last group or the first model will be stored respectively.

{cmd: Post-estimation}
{pstd}
{cmd:metadta} also stores (in memory) the estimation results from the specified model in {cmd:metadta_modest}. These results can be 
saved, restored and stored and used in making comparisons. See {help estimates}.

{title:Author}
{pmore}
Victoria N. Nyaga ({it:Victoria.NyawiraNyaga@sciensano.be}) {p_end}
{pmore}
Unit Cance Epidemiology - Belgian Cancer Center, {p_end}
{pmore}
Sciensano,{p_end}
{pmore} 
Juliette Wytsmanstraat 14, {p_end}
{pmore}
1050 Brussels, {p_end}
{pmore}
Belgium.{p_end}

{title:References}

{marker Hamza2008}{...}
{phang}
Hamza et al. 2008. The binomial distribution of meta-analysis was preferred to model within-study variability. 
{it:Journal of Clinical Epidemiology} 61: 41-51.

{marker BCD2001}{...}
{phang}
Brown, L. D., T. T. Cai, and A. DasGupta. 2001.  
Interval estimation for a binomial proportion. 
{it:Statistical Science} 16: 101-133.

{marker CP1934}{...}
{phang}
Clopper, C. J., and E. S. Pearson. 1934.  The
use of confidence or fiducial limits illustrated in the case of the binomial.  
{it:Biometrika} 26: 404-413.

{marker KOOPMAN1984}{...}
{phang}
Koopman, P. A. R. 1984. Confidence intervals for the ratio of two binomial proportions.
{it:Biometrics} 40(2): 513-517.

{marker Arbyn2013}{...}
{phang}
Arbyn M., Roelens J., Simoens C., Buntinx F., Paraskevaidis E., Martin-Hirsch PPL., Prendiville W. 2013. 
Human Papillomavirus Testing Versus Repeat Cytology for Triage of Minor Cytological Cervical Lesions.
{it:Cochrane Database of Systematic Reviews}: 31-201.
{marker Arbyn2014}{...}
{phang}
Arbyn, M., Verdoodt, F., Snijders, P.J., Verhoef, V.M., Suonio, E., Dillner, L., Minozzi, S., Bellisario, C., Banzi, R., Zhao, F.H. and Hillemanns, P., 2014. 
Accuracy of human papillomavirus testing on self-collected versus clinician-collected samples: a meta-analysis. 
{it:The lancet oncology} 15(2): 172-183.
{p_end}