{smcl}
{* *! version 0.12.4 13dec2018}{...}
{viewerjumpto "Description" "rctmiss##description"}{...}
{viewerjumpto "Syntax" "rctmiss##syntax"}{...}
{viewerjumpto "Graphical sensitivity analyses" "rctmiss##gsa"}{...}
{viewerjumpto "Specifying delta" "rctmiss##IM_expression"}{...}
{viewerjumpto "Missing values of outcome: pattern mixture model" "rctmiss##PM"}{...}
{viewerjumpto "Missing values of outcome: selection model" "rctmiss##SM"}{...}
{viewerjumpto "Missing values of baseline covariates" "rctmiss##basemiss"}{...}
{viewerjumpto "What substantive analyses are allowed?" "rctmiss##substantive"}{...}
{viewerjumpto "Limitations" "rctmiss##limitations"}{...}
{viewerjumpto "Examples" "rctmiss##examples"}{...}
{viewerjumpto "References" "rctmiss##references"}{...}
{viewerjumpto "Author and updates" "rctmiss##updates"}{...}
{title:Title}

{phang}{bf:rctmiss} {hline 2} Analyse a randomised controlled trial (RCT) allowing for informatively missing outcome data.

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:rctmiss} analyses a randomised trial with missing outcome data under a range of assumptions about the missing data. 
For example, if a main analysis has been performed under an assumption of missing at random (MAR), then {cmd:rctmiss} can be used to assess the sensitivity of the results to plausible departures from MAR.
This forms a part of an intention-to-treat analysis strategy ({help rctmiss##WHCP11:White et al, 2011}).

{p 4 4 2}
The data and missingness are modelled jointly using either 
a pattern-mixture model (modelling the differences between missing and observed data)
or a selection model (modelling the missing data mechanism).
Assumptions about the missing data are expressed via a sensitivity parameter delta which measures the degree of departure from missing at random.
I recommend the use of the pattern-mixture model as it usually makes the sensitivity parameter delta easier to interpret.
Results can be obtained for a single assumption (a single value of delta, possibly varying between individuals), 
or graphed over a range of assumptions (a range of values of delta).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
    {cmd:rctmiss}, {it:options}: {it:estimation_command}

{p 4 4 2}
where {it:estimation_command} is the {help rctmiss##substantive:substantive analysis} that would be performed in the absence of missing data: 
a regression of an outcome y on covariates x. 
Randomised group is one of the covariates in x.

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Model options}
{synopt:{opt pmmd:elta(IM_exp)}}Specifies a pattern-mixture model (PMM) analysis: see {help rctmiss##IM_expression:Specifying delta}.{p_end}
{synopt:{opt smd:elta(IM_exp)}}Specifies a selection model (SM) analysis: see {help rctmiss##IM_expression:Specifying delta}.{p_end}
{synopt:{opt aux:iliary(varlist)}}Specifies any auxiliary variables -- 
variables that are not in the substantive model 
but are in the imputation model (for PMM analysis) or the missingness model (for SM analysis).{p_end}
{synopt:{opt fulls:andwich}}In a PMM analysis, 
specifies that the full sandwich estimation method is to be used: see 
{help rctmiss##PM:Missing values of outcome: pattern mixture model}.{p_end}
{synopt:{opt sens(varname[,suboptions])}}
Defines the randomised group variable (which must be coded 0/1) 
whose coefficient is to be explored as the sensitivity parameter delta varies in a sensitivity analysis. 
If not specified, then the analysis uses a single value of delta.
{help rctmiss##sensopts:Suboptions for the sensitivity analysis}
and
{help rctmiss##sensgraphopts:suboptions for the sensitivity analysis graph}
are described below.{p_end}

{marker sensopts}{syntab:Suboptions of {opt sens()} for the sensitivity analysis}

{synopt:{opt senstype(string)}}{opt senstype(equal|unequal)} requests sensitivity analyses with delta equal/unequal across randomised groups; 
    {opt senstype(all)} (the default) requests all sensitivity analyses. 
    The sensitivity analyses are defined in {help rctmiss##gsa:Graphical sensitivity analyses}.{p_end}
{synopt:{opt list} or {opt list(options)}}Requests a listing of the sensitivity analysis results.{p_end}
{synopt:{opt savedta(file[,replace])}}Writes the sensitivity analysis results to the specified file.{p_end}
{synopt:{opt clear}}Clears the current data and loads the sensitivity analysis results into memory. This is useful for editing the graph command, which is stored in F9.{p_end}
{synopt:{opt nograph}}Suppresses graph. Only allowed with {opt list}, {opt savedta} or {opt clear} option.{p_end}

{marker sensgraphopts}{syntab:Suboptions of {opt sens()} for the sensitivity analysis graph}

{synopt:{opt stagger(#)}}Controls the horizontal separation of the different sensitivity analyses at each value of delta.{p_end}
{synopt:{opt col:ors(string)}}Up to three {help colorstyle:colours} for sensitivity analyses.{p_end}
{synopt:{opt lw:idth(#)}}{help linewidthstyle:Line width} option for the whole graph.{p_end}
{synopt:{opt lpat:terns(string)}}Names {help  linepatternstyle:line patterns} for sensitivity analyses; 
or, with the {opt ciband} option, for point estimate and confidence limits.{p_end}
{synopt:{opt ms:ymbol(string)}}{help symbolstyle:Symbol style} option for the graph. 
Use {cmd:msymbol(none)} to suppress marker symbols.{p_end}
{synopt:{opt ciband}}Joins confidence limits to each other (as a confidence band) rather than to the point estimates (as in a forest plot).{p_end}
{synopt:graph_options}Other {help twoway_options:options for twoway graphs}: for example {opt name()}, {opt saving()}, {opt ylab()}, {opt title()} etc.

{syntab:Handling incomplete baseline variables}
{synopt:{opt basemiss(mean|mim [, min(#)])}}See {help rctmiss##basemiss:Missing values of baseline covariates}.
{opt basemiss(mean)} (the default) imputes missing values of baseline variables with the mean of all observed values.
{opt basemiss(mim)} applies the missing indicator method which also includes a dummy variable for missingness of any baseline variable with # or more missing values: default # is 3.
I don't recommend excluding observations with missing baseline values; 
if you want to do this then you must use {help if} or {help in} on your estimation command.
{p_end}

{syntab:Display}
{synopt:{opt eform(string)}}Reports estimated coefficients on the exponentiated scale, named as {it:string}. 
{opt eform(Odds ratio)} is the default when the main command is {help logistic}.{p_end}

{syntab:Selection model options}
{synopt:{opt nosw}}Causes the weights not to be stabilised.{p_end}
{synopt:{opt savewt(newvarname)}}Saves the weights as {it:newvarname}.{p_end}
{synopt:{opt nommconst:ant}}Omits the constant from the missingness model.{p_end}
{synoptline}
{p2colreset}


{marker gsa}{title:Graphical sensitivity analyses}

{phang}{cmd:rctmiss} presents, by default, three sensitivity analyses: 

{phang}1. delta varies over the specified range in arm 1 only, and takes its base value (usually 0) in arm 0.

{phang}2. delta is equal in the two arms and varies over the specified range.

{phang}3. delta varies over the specified range in arm 0 only, and takes its base value (usually 0) in arm 1.


{marker IM_expression}{title:Specifying delta}

{phang}
In options {opt smdelta(IM_exp)} and {opt pmmdelta(IM_exp)}, {it:IM_exp} defines the informatively missing parameter delta with the syntax:

{p 8 17 2}
    {cmd:expression|numlist}, [{opt exp:delta} {opt b:ase(#)}]

{phang}
If {opt sens(varname)} is not specified,  the main argument must be an {help expression}, giving a single analysis. 

{phang}
If {opt sens(varname)} is specified, the main argument must be a {help numlist}, giving a sensitivity analysis. 

{phang}{opt exp:delta} indicates that the main argument gives exp(delta). If this is 0 then delta is taken as -999.

{phang}{opt b:ase(#)} is used when {opt sens(varname)} is specified, 
and indicates the value of delta assumed in sensitivity analyses 1 and 3. Default is {opt base(0)} meaning MAR.


{title:Missing values of outcome: pattern mixture model}{marker PM}

{p 4 4 2}
Under the pattern mixture model approach, 
the assumptions about the missing data are expressed as the coefficient of m in a model for y on x and m.
For linear regression, the coefficient is the difference between 
the mean unobserved outcome and the mean observed outcome.
For logistic regression, the coefficient is the log odds ratio between the outcome and missingness,
and equals the log IMOR of {help rctmiss##HWW08:Higgins et al (2008)}.

{p 4 4 2}
Estimation follows the mean score method 
which uses the imputation model to construct and solve the expected score equation
(see {help rctmiss##WCH17:White et al 2017}). 
There are two options for the variance:

{p 8 11 2} 1. Full Sandwich method: the most general method.
Variances are computed from a sandwich variance which takes proper account 
of the same data being used in imputation and substantive models. 

{p 8 11 2}2. Two Regressions method: only applicable for linear regression without auxiliary variables.
Here the regression coefficients for the substantive model are expressed as the sum of two regressions
(the complete cases analysis plus a correction term),
and the final variance is the sum of the two variances.

{p 4 4 2}The Full Sandwich method is used if the Two Regressions method is not applicable
or if the {cmd:fullsandwich} option is specified.


{title:Missing values of outcome: selection model}{marker SM}

{p 4 4 2}
Using the selection model approach, the assumptions about the missing data are expressed 
as the coefficient of y in a model for m on x and y (selection model): 
the coefficient is the increase in the log odds of missingness for a 1-unit increase in y. 
If y is binary then this is again the log IMOR of {help rctmiss##HWW08:Higgins et al (2008)}.


{marker basemiss}{title:Missing values of baseline covariates}

{p 4 4 2}
{ul:Missing values of a baseline covariate are handled in an unusual (and superior) way.} 
Stata's usual way is to drop observations with missing values of any baseline covariate.
This is not recommended in a RCT ({help rctmiss##WT05:White & Thompson, 2005}). 
Instead, {cmd:rctmiss} imputes missing values of a covariate with the mean of the observed values of that covariate (computed across all randomised groups), 
or with the {cmd:basemiss(mim)} option, using the missing indicator method.
To get Stata's standard procedure, you need to explicitly exclude observations, e.g. using {cmd:rctmiss: reg y rand x if !missing(x)}.

{p 4 4 2}
Including a missing indicator for a variable with 1 missing value amounts to dropping that observation, 
which is undesirable. 
By default, {cmd:rctmiss} therefore only includes missing indicators 
for variables with 3 or more missing values; 
you can change this using the {cmd:basemiss(mim, min(#))} option.


{title:What substantive analyses are allowed?}{marker substantive}

{phang}At present, {it:estimation_command} must use {help regress}, {help logistic} / {help logit} or {help poisson}. 
{help if} and {help in} are allowed.
Weights are not allowed, except that (experimentally) iweights may be used with the full sandwich method.

{phang}The following {it:estimation_command} options are allowed: 

{p 8 12 2}{opt robust} only affects the complete-case analysis in the Two Regressions method. 
Otherwise, robust variances are used throughout.

{p 8 12 2}{opt noconstant} applies to the substantive model and (in the PMM case) to the imputation model.

{p 8 12 2}{opt cluster(varname)} and {cmd:vce(cluster }{it:varname}{cmd:)} 
modify variance calculations in all models.

{p 8 12 2}Other options may work but have not been tested.


{title:Limitations}{marker limitations}

{phang}Only two-arm trials are supported at present.

{phang}Stata 11 factor variables  are not supported: you need to use {help xi} before {cmd:rctmiss}. 
That is, use {cmd:xi:rctmiss...} and not {cmd:rctmiss:xi...}.

{phang}The only regression commands currently allowed are regress, logistic/logit and poisson. 


{marker examples}{...}
{title:Examples}

{p 0 0 0}{cmd:UK500 data (quantitative outcome)}

{phang}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/missing/uk500.dta, clear"}
{* -net- always downloads file name as lower-case, and -use- is case-sensitive over the internet}

{p 0 0 0}Analysis assuming MAR, dropping missing baselines:

{phang}. {stata reg sat96 rand sat94 i.centreid}

{p 0 0 0}Analysis assuming MAR, with mean imputation for missing baselines:

{phang}. {stata "gen sat94fill = sat94"}

{phang}. {stata "summ sat94"}

{phang}. {stata "replace sat94fill = r(mean) if mi(sat94)"}

{phang}. {stata "reg sat96 rand sat94fill i.centreid"}

{p 0 0 0}Same using rctmiss:

{phang}. {stata "xi: rctmiss, pmmdelta(0): reg sat96 rand sat94 i.centreid"}

{p 0 0 0}Single MNAR analysis, assuming missing values are 5 units lower than observed values in both arms:

{phang}. {stata "xi: rctmiss, pmmdelta(-5): reg sat96 rand sat94 i.centreid"}

{p 0 0 0}Sensitivity analysis, assuming missing values are from 0 to 10 units lower than observed values, 
in one arm or in both arms:

{phang}. {stata "xi: rctmiss, sens(rand) pmmdelta(-10/0): reg sat96 rand sat94 i.centreid"}

{p 0 0 0}Improving appearance:

{phang}. {stata "xi: rctmiss, sens(rand, legend(rows(3)) title(Sensitivity analysis for UK500 data)) pmmdelta(-10/0) stagger(0.05) list(sepby(delta)): reg sat96 rand sat94 i.centreid"}


{p 0 0 0}{cmd:Smoking data (binary outcome)}

{phang}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/missing/smoke.dta, clear"}

{phang}. {stata tab rand quit, miss}

{p 0 0 0}Analysis assuming missing = smoking:

{phang}. {stata gen quit2 = quit}

{phang}. {stata replace quit2 = 0 if missing(quit)}

{phang}. {stata logistic quit2 rand}

{p 0 0 0}Same analysis using {cmd:rctmiss}:

{phang}. {stata "rctmiss, pmmdelta(0, expdelta): logistic quit rand"}

{p 0 0 0}Sensitivity analysis based around missing=smoking:

{phang}. {stata "rctmiss, sens(rand) pmmdelta(0(0.1)1, expdelta base(0)): logistic quit rand"}


{title:References}{marker references}

{marker WCH17}{phang}White IR, Carpenter J, Horton NJ. 
A mean score method for sensitivity analysis
to departures from the missing at random assumption in randomised trials.
Statistica Sinica 2018;28:1985–2003. 
{browse "http://www3.stat.sinica.edu.tw/statistica/J28N4/J28N415/J28N415.html"}

{marker WHCP11}{phang}White IR, Horton NJ, Carpenter J, Pocock SJ. An intention-to-treat analysis strategy for randomised trials with missing outcome data. British Medical Journal 2011;342:d40.
{browse "http://www.bmj.com/content/342/bmj.d40.full"}

{marker HWW08}{phang}Higgins JPT, White IR, Wood AM. Imputation methods for missing outcome data in meta-analysis of clinical trials. Clinical Trials 2008; 5: 225-239.
{browse "http://ctj.sagepub.com/content/5/3/225.short"}

{marker WT05}{phang}White IR, Thompson SG. Adjusting for partially missing baseline measurements in randomised trials. Statistics in Medicine 2005; 24: 993-1007.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.1981/abstract"}


{title:Author and updates}{marker updates}

{p}Ian White, MRC Clinical Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{p}You can get the latest version of this and my other Stata software using 
{stata "net from http://www.homepages.ucl.ac.uk/~rmjwiww/stata/"}.

{p}I thank James Carpenter (MRC CTU at UCL, UK) and Nicholas Horton (Amherst College, USA) 
for working with me on the theory behind this method,
and Tim Morris (MRC CTU at UCL, UK) for helpful comments on the progam.

