{smcl}
{* 2013}{...}
{hline}
help for {hi:validscale}{right:Bastien Perrot}
{hline}

{title:Syntax}

{p 8 14 2}{cmd:validscale} {it:varlist}, {opt part:ition}({it:numlist}) [{it:options}]

{p 4 4 2}{it:varlist} contains the variables (items) used to compute the scores. The first items of {it:varlist} compose the first dimension, the following items define the second dimension, and so on.

{p 4 4 2}{cmd:partition} allows defining in {it:numlist} the number of items in each dimension.


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt : {opt scoren:ame(string)}}define the names of the dimensions{p_end}
{synopt : {opt scores(varlist)}}use scores from the dataset{p_end}
{synopt : {opt cat:egories(numlist)}}define minimum and maximum response categories for the items{p_end}
{synopt : {opt imp:ute(method)}}impute missing item responses{p_end}
{synopt : {help validscale##impute_options:{it:impute_options}}}options for imputation of missing data {p_end}
{synopt : {opt comps:core(method)}}define how scores are computed{p_end}
{synopt : {opt desc:items}}display a descriptive analysis of items and dimensions{p_end}
{synopt : {opt graph:s}}display graphs for items description{p_end}
{synopt : {opt cfa}}assess structural validity of the scale by performing a confirmatory factor analysis (CFA){p_end}
{synopt : {help validscale##cfa_options:{it:cfa_options}}}options for confirmatory factor analysis (CFA){p_end}
{synopt : {opt conv:div}}assess convergent and divergent validities assessment{p_end}
{synopt : {help validscale##convdiv_options:{it:conv_div_options}}}options for convergent and divergent validities{p_end}
{synopt : {help validscale##reliability_options:{it:reliability_options}}}options for reliability assessment{p_end}
{synopt : {opt rep:et(varlist)}}assess reproducibility of scores and items{p_end}
{synopt : {help validscale##repet_options:{it:repet_options}}}options for reproducibility{p_end}
{synopt : {opt kgv(varlist)}}assess known-groups validity by using qualitative variable(s){p_end}
{synopt : {help validscale##kgv_options:{it:kgv_options}}}options for known-groups validity assessment{p_end}
{synopt : {opt conc(varlist)}}assess concurrent validity{p_end}
{synopt : {help validscale##conc_options:{it:conc_options}}}options for concurrent validity assessment{p_end}
{synopt : {opt * }}options from {help sem_estimation_options} command (additional estimation options for {help validscale##cfa_options:{it:cfa_options}}) {p_end}


{p2colreset}{...}


{title:Description}

{phang}{cmd:validscale} assesses validity and reliability of a multidimensional scale. Elements to provide
structural validity, convergent and divergent validity, reproducibility, known-groups validity, internal consistency, scalability and sensitivity are computed. {cmd:validscale} can be used with a dialog box by typing {stata db validscale}.

{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opt scoren:ame(string)} allows defining the names of the dimensions. If the option is not used, the dimensions are named {it:Dim1}, {it:Dim2},... unless {opt scores(varlist)} is used. 

{phang}{opt scores(varlist)} allows selecting scores from the dataset. {opt scores(varlist)} and {opt scorename(string)} cannot be used together.

{phang}{opt cat:egories(numlist)} allows specifying the minimum and maximum possible values for items responses. If all the items have the same response
categories, the user may specify these 2 values in {it:numlist}. If the items response categories differ from a dimension to another, the user must define the possible minimum and maximum values of items responses for each
dimension. So the number of elements in {it:numlist} must be equal to the number of dimensions times 2. Eventually, the user may specify the minimum and maximum response categories for each item. In this case, the
number of elements in {it:numlist} must be equal to the number of items times 2. By default, the minimum and maximum values are assumed to be the minimum and maximum for each item.      

{marker impute_options}{...}
{phang}{opt imp:ute(method)} imputes missing items responses with Person Mean Substitution ({bf:pms}) or Two-way imputation method applied in each dimension ({bf:mi}). With PMS method, missing data are imputed only if the number of
missing values in the dimension is less than half the number of items in the dimension. 

{phang2} By default, imputed values are rounded to the nearest whole number but with the {opt nor:ound} option, imputed values are not rounded. If {opt impute} is absent then {opt noround} is ignored.

{phang}{opt comp:score(method)} defines the method used to compute the scores. {it:method} may be either {bf:mean} (default), {bf:sum} or {bf:stand}(set scores from 0 to 100). {opt comp:score(method)} is ignored
if the {opt scores(varlist)} option is used.

{phang}{opt desc:items} displays a descriptive analysis of the items. This option displays missing data rate per item and distribution of item responses. It also computes for each item the Cronbach's alphas
obtained by omitting each item in each dimension. Moreover, the option computes Loevinger's Hj coefficients and the number of non-significant Hjk. See {help loevh} for details about Loevinger's coefficients.     

{phang}{opt graph:s} displays graphs for items and dimensions descriptive analyses. It provides histograms of scores, a biplot of the scores and a graph showing the correlations between the items.

{marker cfa_options}{...}
{phang}{opt cfa} performs a Confirmatory Factor Analysis (CFA) using {help sem} command. It displays estimations of parameters and several goodness-of-fit indices.

{phang2} {opt cfam:ethod}({it:method}) specifies the method to estimate the parameters. {it:method} may be either {bf:ml} (maximum
likelihood), {bf:mlmv} ({bf:ml} with missing values) or {bf:adf} (asymptotic distribution free). 

{phang2} {opt cfasb} produces Satorra-Bentler adjusted goodness-of-fit indices using the vce(sbentler) option from sem ({help sem_option_method##vcetype})

{phang2} {opt cfas:tand} displays standardized coefficients.

{phang2} {opt cfanocovd:im} asserts that the latent variables are not correlated.

{phang2} {opt cfac:ovs} option allows adding covariances between measurement errors. The syntax cfacov(item1*item2)
allows estimating the covariance between the errors of item1 and item3. To specify more than one covariance, the form of the syntax is cfacov(item1*item2 item3*item4).

{phang2} {opt cfar:msea(#)} option allows adding automatically the covariances between measurement errors found
with the estat mindices command until the RMSEA (Root Mean Square Error
of Approximation) of the model is less than #. More precisely, the "basic" model
(without covariances between measurement errors) is estimated then we add the covariance corresponding to the greatest modification index and the model is re-
estimated with this extra-parameter, and so on. The option only adds the covari-
ances between measurement errors within a dimension and can be combined with
cfacov. The specified value # may not be reached if all possible within-dimension
measurement errors have already been added.

{phang2} {opt cfacf:i(#)} option allows adding automatically the covariances between measurement errors found with
the estat mindices command until the CFI (Comparative Fit Index) of the model
is greater than #. More precisely, the "basic" model (without covariances between
measurement errors) is estimated then we add the covariance corresponding to the
greatest modification index and the model is re-estimated with this extra-parameter,
and so on. The option only adds the covariances between measurement errors within
a dimension and can be combined with cfacov. The specified value # may not
be reached if all possible within-dimension measurement errors have already been
added.

{phang2} {opt cfaor} option is useful when both {opt cfar:msea} and {opt cfacf:i} are used. By default, covariances between measurement errors are added and the model is estimated until both RMSEA
and CFI criteria are met. If cfaor is used, the estimations stop when one of the two
criteria is met.

{phang2} {opt *} options from {help sem_estimation_options} (e.g. {opt iterate(#)}, {opt vce(vcetype)}, etc.)

{marker convdiv_options}{...}
{phang}{opt conv:div} assesses convergent and divergent validities. The option displays the matrix of correlations between items and rest-scores. If {opt scores(varlist)} is used, then the correlations coefficients are computed between
items and scores of {opt scores(varlist)}. 

{phang2} {opt tconv:div(#)} defines a threshold for highlighting some values. # is a real number between 0 and 1 which is equal to 0.4 by
default. Correlations between items and their own score are displayed
in red if it is less than #. Moreover, if an item has a smaller correlation coefficient with the score of its own dimension than the correlation coefficient computed with other scores, this coefficient is displayed
in red. 

{phang2} {opt convdivb:oxplots} displays boxplots for assessing convergent and divergent validities. The boxes represent the correlation coefficients between the items of a given dimension and all scores. Thus the
box of correlation coefficients between items of a given dimension and the corresponding score must be higher than other boxes. There are as many boxplots as dimensions.

{marker reliability_options}{...}
{phang}{it:reliability_options} allow defining the thresholds for reliability and scalability indices. 

{phang2} {opt a:lpha(#)} defines a threshold for Cronbach's alpha (see {help alpha}). # is a real number between 0 and 1 which is equal to 0.7
by default. Cronbach's alpha coefficients less than # are printed in red.

{phang2} {opt d:elta(#)} defines a threshold for Ferguson's delta coefficient (see {help delta}). Delta coefficients are computed only if {opt compscore}({it:sum}) is used
and {opt scores}({it:varlist)} is not used. # is a real number between 0 and 1 which is equal to 0.9
by default. Ferguson's delta coefficients less than # are printed in red.

{phang2} {opt h(#)} defines a threshold for Loevinger's H coefficient (see {help loevh}). # is a real number between 0 and 1 which is equal to
0.3 by default. Loevinger's H coefficients less than # are printed in red. 

{phang2} {opt hj:min(#)} defines a threshold for Loevinger's Hj coefficients. The displayed value is the minimal Hj coefficient for a item in the dimension. (see {help loevh}). # is a real number between 0 and 1 which is equal to
0.3 by default. If the minimal Loevinger's Hj coefficient is less than # then it is printed in red and the corresponding item is displayed.

{marker repet_options}{...}
{phang}{opt rep:et(varlist)} assesses reproducibility of scores by defining in {it:varlist} the variables corresponding to responses at time 2 (in the same order than for time 1). Scores are computed according to
the {opt partition()} option. Intraclass
Correlation Coefficients (ICC) for scores and their 95% confidence interval are computed with Stata's {help icc} command.

{phang2} {opt kap:pa} computes kappa statistic for items with Stata's {help kap} command. 

{phang2} {opt ickap:pa(#)} computes confidence intervals for kappa statistics using {help kapci}. # is the number of replications for bootstrap used to estimate confidence intervals if items are polytomous. If they are dichotomous, an analytical method is used. See {help kapci} for more details about
calculation of confidence intervals for kappa's coefficients. If the {opt kappa} option is absent then {opt ickappa(#)} is ignored. 

{phang2} {opt scores2}({it:varlist}) allows selecting scores at time 2 from the dataset. 

{phang}{opt kgv(varlist)} assesses known-groups validity according to the grouping variables defined in {it:varlist}. The option performs an ANOVA which compares the scores between groups of individuals, constructed with variables in {it:varlist}. A p-value based on a Kruskal-Wallis test is also given.       

{marker kgv_options}{...}

{phang2} {opt kgvb:oxplots} draws boxplots of the scores split into groups of individuals. 

{phang2} {opt kgvg:roupboxplots} groups all boxplots into one graph. If {opt kgvboxplots} is absent then the {opt kgvgroupboxplots} option is ignored.

{phang}{opt conc(varlist)} assesses concurrent validity with variables precised in {it:varlist}. These variables are scores from one or several other scales.  

{marker conc_options}{...}
{phang2} {opt tc:onc(#)} defines a threshold for correlation coefficients between the computed scores and the scores of other scales defined in {it:varlist}. Correlation
coefficients greater than # (0.4 by default) are displayed in bold.

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. validscale item1-item20, part(5 4 6 5)}{p_end}

{phang2}{cmd:. validscale item1-item20, part(5 4 6 5) imp graphs cfa cfastand cfacovs(item1*item3 item5*item7 item17*item18) convdiv convdivboxplots kgv(factor_variable) kgvboxplots conc(scoreA-scoreD)}{p_end}

{phang2}{cmd:. validscale item1-item20, part(5 4 6 5) imp scores(s1-s4) rep(item1bis-item20bis) scores2(s1bis-s4bis) kappa}{p_end}

{title:References}

{phang}Blanchette, D. 2010. LSTRFUN: Stata module to modify long local macros. {it:Statistical Software Components}, Boston College Department of Economics.

{phang}Gadelrab, H. 2010. {it:Evaluating the fit of structural equation models: Sensitivity to specification error and descriptive goodness-of-fit indices.} Lambert Academic Publishing.

{phang}Hamel, J.-F. 2014. MI TWOWAY: Stata module for computing scores on questionnaires containing missing item responses. {it:Statistical Software Components}, Boston College Department of Economics.

{phang}Hardouin, J.-B. 2004. LOEVH: Stata module to compute Guttman errors and Loevinger H coeficients. {it:Statistical Software Components}, Boston College Department of Economics.

{phang}Hardouin, J.-B. 2007. DELTA: Stata module to compute the Delta index of scale discrimination. {it:Statistical Software Components}, Boston College Department of Economics.

{phang}Hardouin, J.-B. 2013. IMPUTEITEMS: Stata module to impute missing data of binary items.

{phang}Hardouin, J.-B., A. Bonnaud-Antignac, V. Sbille, et al. 2011. Nonparametric item response theory using Stata. {it:Stata Journal} 11(1): 30.

{phang}Reichenheim, M. E. 2004. Confidence intervals for the kappa statistic. {it:Stata Journal} 4(4): 421{428(8).

{title:Author}

{phang}Bastien Perrot, EA 4275 SPHERE, "methodS in Patient-centered outomes and HEalth ResEarch", University of Nantes, France
{browse "mailto:bastien.perrot@univ-nantes.fr":bastien.perrot@univ-nantes.fr}{p_end}

{marker alsosee}{...}
{title:Also see}

{p 4 13 2}help for {help alpha}, {help delta}, {help loevh}, {help icc}, {help kapci}.{p_end}
