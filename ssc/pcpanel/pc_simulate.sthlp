{smcl}
{* *! version 3.0 14apr2020}{...}
{vieweralsosee "[R] reghdfe" "help reghdfe"}{...}
{vieweralsosee "[R] pc_dd_analytic" "help pc_dd_analytic"}{...}
{vieweralsosee "[R] pc_dd_covar" "help pc_dd_covar"}{...}
{viewerjumpto "Syntax" "pc_simulate##syntax"}{...}
{viewerjumpto "Description" "pc_simulate##description"}{...}
{viewerjumpto "Design parameters" "pc_simulate##opt_params"}{...}
{viewerjumpto "Model options" "pc_simulate##opt_model"}{...}
{viewerjumpto "Simulation options" "pc_simulate##opt_sims"}{...}
{viewerjumpto "Advanced options" "pc_simulate##opt_advanced"}{...}
{viewerjumpto "Examples" "pc_simulate##examples"}{...}
{viewerjumpto "Contact" "pc_simulate##contact"}{...}
{viewerjumpto "References" "pc_simulate##references"}{...}
{title:Title}

{p2colset 5 20 20 2}{...}
{p2col :{cmd:pc_simulate} {hline 2}}Power calculations by simulation, using existing dataset{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:pc_simulate} {depvar} {ifin} {cmd:,} {opth mod:el(pc_simulate##description:model)} {opth mde(numlist)} 
[{help pc_simulate##options:options}] {p_end}


{marker opt_summary}{...}
{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required {help pc_simulate##description:[+]}}
{synopt :{opth mod:el(pc_simulate##description:model)}}type of model to be estimated; must be one of 
{opt ONE:SHOT}, {opt PO:ST}, {opt DD}, {opt AN:COVA}.{p_end}
{synopt :{opth mde(numlist)}}list of minimum detectable effect sizes for calculating statistical power, in units of {depvar} ({it:not} in percent of {depvar}); 
e.g. {cmd:mde(}10 20 30{cmd:)}.{p_end}

{syntab:Experimental design parameters {help pc_simulate##opt_params:[+]}}
{synopt :{opt i(panelvar)}}cross-sectional unit of randomization, required for {opt POST}, {opt DD}, and {opt ANCOVA} models; must be numeric; 
will default to stored r({it:panelvar}) if not specified.{p_end}
{synopt :{opt t(timevar)}}time period variable, required for {opt POST}, {opt DD}, and {opt ANCOVA} models; must be numeric; 
will default to stored r({it:timevar}) if not specified.{p_end}
{synopt :{opth n(numlist)}}list of sample sizes for experiment (the number of cross-sectional units included in the randomization); 
must be positive integer(s), e.g. {cmd:n(}50(10)80{cmd:)}; default is # of unique values of {it:panelvar}.{p_end}
{synopt :{opth p(numlist)}}list of treatment ratios (the proportion of cross-sectional units to receive treatment); must be between 0 and 1, 
e.g. {cmd:p(}0.5 0.75{cmd:)}; default is {cmd:p(0.5)}.{p_end}
{synopt :{opth pre(numlist)}}list of number of pre-treatment periods for {opt DD} and {opt ANCOVA} models; must be positive integer(s), 
e.g. {cmd:pre(}2(2)10{cmd:)}; default is {cmd:pre(1)}.{p_end}
{synopt :{opth post(numlist)}}list of number of post-treatment periods for {opt POST}, {opt DD}, and {opt ANCOVA} models; 
must be positive integer(s), e.g. {cmd:post(}1 2 3{cmd:)}; 
defaults are {cmd:post(2)} for {opt POST} model, and {cmd:post(1)} for {opt DD} and {opt ANCOVA} models.{p_end}
{synopt :{opt alp:ha(#)}}desired Type-I error rate (or false discovery rate); must be between 0 and 1; default is {cmd:alpha(0.05)}.{p_end}
{synopt :{opt onesid:ed}}assumes one-sided hypothesis test, with the direction of the test determined by the sign of each {opth mde(numlist)} value; 
if not specified, default is a two-sided hypothesis test.{p_end}

{syntab:Model options {help pc_simulate##opt_model:[+]}}
{synopt :{opth a:bsorb(varlist)}}fixed effects to be included in estimating equation; must be numeric; will default to 
{opt a:bsorb(panelvar timevar)} for {opt DD} model only.{p_end}
{synopt :{opth cont:rols(varlist)}}linear control variables to be included in estimating equation; must be numeric.{p_end}
{synopt :{opt vce}{cmd:(}{help reghdfe##opt_vce:{it:vcetype}}{cmd:)}}{it:vcetype} may be {opt un:adjusted}, {opt r:obust} or 
{opt cl:uster} {help fvvarlist} (see {help reghdfe##opt_vce:reghdfe} for detail); {p_end}
{synopt :}default is {opt vce(unadjusted)} for {opt ONESHOT} model, {opt DD} model with 1 pre-treatment and 1 post-treatment period, 
and {opt ANCOVA} model with 1 post-treatment period;{p_end}
{synopt :}default is {opt vce(cluster panelvar)} for {opt POST} model, {opt DD} model with ({it:pre+post})>2, and {opt ANCOVA} model with {it:post>}1.{p_end}

{syntab:Simulation and output options {help pc_simulate##opt_sims:[+]}}
{synopt :{opt boot:strap}}samples cross-sectional units {it:with} replacement;
accommodates sample sizes larger than # of units in the existing dataset; default is to sample 
units {it:without} replacement (if {opt boot:strap} is 
not specified).{p_end}
{synopt :{opt nsim(#)}}number of simulations performed for each set of experimental design parameters; default is {cmd:nsim(500)}.{p_end}
{synopt :{opth out:file(filename)}}.csv file that stores simulation results in current directory; if not specified, filename will be automatically generated.{p_end}
{synopt: [{cmd:append}|{cmd:replace}]}{cmd:append} adds simulation results to an existing .csv file; {cmd:replace} overwrites existing .csv file (if {cmd:append} is 
not also specified).{p_end}

{syntab:Design options {help pc_simulate##opt_design:[+]}}
{synopt :{opt coll:apse}}estimates a collapsed regression model, with a single cross-sectional outcome averaged across all (pre- and) post-treatment periods; 
this yields a cross-sectional regression for {opt POST} and {opt ANCOVA} models, and a two-period panel regression for a {opt DD} model.{p_end}
{synopt :{opth strat:ify(varlist)}}stratifies randomization by a (list of) categorical covariate(s); if specified, then {opth n(numlist)} 
governs the number of units {it:in each stratified randomization cell}; note that the resulting power calculations still estimate a model 
with a {it:pooled} average treatment effect; cannot be combined with {opt idcl:uster(groupvar)}.{p_end}
{synopt :{opt idcl:uster(groupvar)}}defines a cross-sectional group identifier, in order to accommodate cluster-randomization; if specified, 
simulations randomize at the cluster (i.e {it:groupvar}) level, and {opth n(numlist)} governs the number of clusters; {it:panelvar} units must 
nest within {it:groupvar} clusters; cannot be combined with {opth strat:ify(varlist)}.{p_end}
{synopt :{opt sizecl:uster(#)}}defines the number of {it:panelvar} units within each {it:groupvar} cluster; must be combined with {opt idclu:ster(groupvar)}; 
default is size of each cluster in existing dataset.{p_end}
{synopt :{opth pcl:uster(numlist)}}defines the treatment intensity within each {it:groupvar} cluster; must be between 0 and 1; must be combined with {opt idcl:uster(groupvar)}; 
multiple values yield heterogeneous treatment intensities, in equal proportions across treated clusters; default is {cmd:pcluster(1)}.{p_end}

{syntab:Advanced options {help pc_simulate##opt_advanced:[+]}}
{synopt :{opt ts:tart(# [#])}}restricts the range of time periods over which to begin experiment; for example, {cmd:tstart(}4 7{cmd:)} 
will simulate experiments beginning in time periods {it:timevar}={4,5,6,7} with equal probability; 
note that this indicates the first {it:pre-treatment} period in a {opt DD} or {opt ANCOVA} model.{p_end}
{synopt :{opth absorbf:actor(fvvarlist)}}accommodates factor variable fixed effects, as allowed by {help reghdfe##absvar:reghdfe}; 
can be combined with the simpler {opth a:bsorb(varlist)} option.{p_end}
{synopt :{opth w:eight(weight)}}{opt fw:eight}s, {opt aw:eight}s and {opt pw:eight}s are allowed; syntax is {opt w:eight(aw=varname)}; 
see {help weight}.{p_end}
{synopt :{opt reghdfeopt:ions}{cmd:(}{help reghdfe##options:options}{cmd:)}}allows users to pass through additional reghdfe options 
(not all of which are supported); see {help reghdfe}.{p_end}	
{synoptline}

{break}
{marker description}{...}
{title:Description}

{pstd}
This program performs power calculations by simulating a randomized experiment using an existing dataset. For each iteration, 
it randomly assigns units to treated and control groups, imposes an average treatment effect on treated units, 
estimates this treatment effect using a regression model, 
and records whether the null hypothesis of zero treatment effects is 
rejected at the chosen significance level.{p_end}

{pstd}
This program accommodates four types of experiments:{p_end}
{break}
{p2col 8 12 12 2: -}{opt ONESHOT}, with exactly 1 observation of post-treatment data 
for each cross-sectional unit, and 0 pre-treatment observations {p_end}
{p2col 8 12 12 2: -}{opt POST}, with 2+ observations of post-treatment data 
for each cross-sectional unit, and 0 pre-treatment observations {p_end}
{p2col 8 12 12 2: -}{opt DD} (difference-in-differences), with 1+ observations of both pre-treatment and post-treatment data  
for each cross-sectional unit; 
estimated as a two-dimensional panel regression with pre-treatment and post-treatment time periods for each unit {p_end}
{p2col 8 12 12 2: -}{opt ANCOVA}, with 1+ observations of both pre-treatment and post-treatment data  
for each cross-sectional unit; 
estimated using post-treatment observations only, and including the pre-treatment average of the outcome variable as a linear control {p_end}

{pstd}
For each model, the default specification is as follows (where {it:D} is the treatment indicator):{p_end}
{break}
{p2col 8 12 12 2: -}{opt ONESHOT}:  {it:Y_i {space 1}= b*D_i {space 1}+ e_i} {p_end}
{p2col 8 12 12 2: -}{opt POST}: {space 3}  {it:Y_it = b*D_i {space 1}+ e_it} {p_end}
{p2col 8 12 12 2: -}{opt DD}: {space 5} {it:Y_it = b*D_it + fe_i {space 2}+ fe_t + e_it} {p_end}
{p2col 8 12 12 2: -}{opt ANCOVA}: {space 1} {it:Y_it = b*D_i {space 1}+ Ypre_i + e_it} {p_end}

{pstd} 
For each iteration, the program randomly assigns units as either treated ({it:D_it=}1) or control ({it:D_it=}0). It then constructs the outcome variable  
{it:Y_it = depvar_it + mde*D_it}.

{pstd} 
For a (default) two-sided test, the model rejects the null hypothesis if {it:b} is statistically different from zero, given significance level {it:alpha}.

{pstd}
The average rejection rate across all {it:nsim} simulations is the statistical power, or the probability 
that the experiment would reject a true effect size of at least {it:mde}. 

{pstd}
Researchers typically design experiments to achieve 80% power, or {it:power=}0.8.
However, this value is arbitrary.

{break}
{marker options}{...}
{title:Options}
{marker opt_params}{...}
{dlgtab:Experimental design parameters}

{phang}
{opt i(panelvar)} assigns the cross-sectional unit identifier. This 
is required for {opt POST}, {opt DD}, and {opt ANCOVA} models, which assume 2-dimensional panel datasets. For 
{opt ONESHOT} model, {opt i(panelvar)} is still necessary if the dataset contains 2 (or more) dimensions. If 
not specified for a {opt ONESHOT} model, the program assumes that {it:each row} of the dataset represents a separate cross-sectional unit.

{phang}
{opt t(timevar)} assigns the time-period identifier. This 
is required for {opt POST}, {opt DD}, and {opt ANCOVA} models, which assume 2-dimensional panel datasets. For 
{opt ONESHOT} model, {opt t(timevar)} is still necessary if the dataset contains 2 (or more) dimensions. 
 
{phang}
{opth n(numlist)} governs the sample size of the experiment, or the number of cross-sectional units to be included in the randomization. If 
not specified, {it:n} defaults to the number of unique values of {it:panelvar} in the dataset.

{pmore}
If {it:n} is less than the number of cross-sectional units in the dataset and the option {opt boot:strap} is not specified, then each iteration 
will sample a (different) random subset of {it:n} units 
without replacement to include in the experiment.

{pmore}
If {it:n} is greater than the number of cross-sectional units in the dataset, the option {opt boot:strap} is required
to sample units with replacement. 

{pmore}
Note that {cmd:pc_simulate} drops all observations with missing data, and users 
should interpret {it:n} as the sample size conditional on each unit having
at least 1 observation of non-missing post-treatment data (and 1 observation of
non-missing pre-treatment data,
for {cmd:DD} and {cmd:ANCOVA} models).

{phang}
{opth p(numlist)} governs the proportion of units randomized into treatment. The program rounds {it:p*n} to the nearest integer, 
and randomly chooses this number of treated units in each iteration.

{phang}
{opth pre(numlist)} governs the number of pre-treatment periods for {opt DD} and {opt ANCOVA} models. For 
{opt ONESHOT} and {opt POST} models, this option must be either {cmd:pre(}0{cmd:)} or missing.

{phang}
{opth post(numlist)} governs the number of post-treatment periods for {opt POST}, {opt DD}, and {opt ANCOVA} models. For 
{opt ONESHOT} model, this option must be either {cmd:post(}1{cmd:)} or missing.

{pmore}
The total number of periods, {it:pre + post}, cannot exceed the number of time periods in the dataset. Except
 in very short panels (i.e., {it:pre}<5 or {it:post}<5), including additional pre- or post-treatment periods should weakly increase statistical power.

{phang}
{opt alp:ha(#)} assigns a Type-I error rate (or false discovery rate). The conventional significance level is {it:alpha=}0.05, which is also the default value.

{phang}
{opt onesid:ed} toggles a one-sided hypothesis test, instead of the default two-sided test. For 
{it:mde>}0, the one-sided null hypothesis becomes {it:H_0: b{c 178}0}. For 
{it:mde<}0, the one-sided null hypothesis becomes {it:H_0: b{c 179}0}. 


{marker opt_model}{...}
{dlgtab:Model options}

{phang}
{opth a:bsorb(varlist)} allows users to add fixed effects to the default specifications above. 

{pmore}
Note that for {opt ONESHOT}, {opt POST}, and {opt ANCOVA} models, fixed effects are not required for identification, but may improve precision. (This
 is especially true for {it:timevar} fixed effects in {opt POST} and {opt ANCOVA} models.)

{pmore}
{opt DD} model requires fixed effects, and this option will default to {opt a:bsorb(panelvar timevar)} if missing. However, 
users may specify alternative fixed effect variables, e.g. {opt a:bsorb(panelvar month year)}, if {it:timevar=month_year}. 

{phang}
{opth cont:rols(varlist)} allows users to add linear control variables to default specifications, including linear time trends. Control 
variables cannot also be used as fixed effects.

{phang}
{opt vce}{cmd:(}{help reghdfe##opt_vce:{it:vcetype}}{cmd:)} may be {opt un:adjusted}, {opt r:obust} or {opt cl:uster} {help fvvarlist}, 
which are the three {it:vcetypes} supportd by {help reghdfe##opt_vce:reghdfe}. This
program does not support {opt vce(vcetype, subopt)}.

{pmore}
In a randomized experiment, {opt un:adjusted} standard errors will yield correct inference for cross-sectional specifications 
(i.e. {opt ONESHOT} model, {opt ANCOVA} model with {it:post=}1)
and for two-period panel specifications with unit fixed effects 
(i.e. {opt DD} model with {it:pre=}1 and {it:post=}1).

{pmore}
For all other experiments, {opt un:adjusted} standard errors will lead to incorrect inference in the presence of within-unit serial correlation 
(i.e. models with 3+ time periods, or with 2+ time periods and no unit fixed effects).
Standard errors clustered by unit allow for arbitrary within-unit error correlations, and the program uses {opt vce(cluster panelvar)} as a default in these cases.

{pmore}
Unit-level randomization obviates the need for clustering along other dimensions, even in the presence of correlated errors within groups of units, 
or correlated errors within time periods across units. 

{pmore}
Note that the cluster-robust variance estimator is biased with fewer than ~30 clusters, 
and that {cmd: pc_simulate} will not correct for such bias in experimental designs with too few clusters.

{marker opt_sims}{...}
{dlgtab:Simulation and output options}

{phang}
{opt boot:strap} controls whether the program samples cross-sectional units with or without replacement. 
The default is to sample {it:without} replacement (if {opt boot:strap} is not specified), which requires {it:n} to be weakly less than the 
number of units in the dataset.

{pmore}
If {opt boot:strap} is specified, each simulation will draw {it:n} cross-sectional units {it:with} replacement from the existing dataset, 
and {it:n} may be larger or smaller than the number of units in the dataset.

{pmore}
For stratified randomization, {opt boot:strap} draws units with replacement from within each randomization cell.

{pmore}
For cluster randomization, {opt boot:strap} draws whole clusters with replacement. If the option {opt sizecl:uster} is specified, 
{opt boot:strap} also draws individual units with replacement from within each cluster (yielding clusters of homogeneous size).

{pmore}
(This option replaces the old program {it:pc_bootstrap_units}, which is now obsolete.)

{phang}
{opt nsim(#)} governs the number of simulations (or iterations) performed number of simulations performed for each set of experimental design parameters. A 
"set" of parameters denotes each combination of {opth mde(numlist)}, {opth n(numlist)}, 
{opth p(numlist)}, {opth pre(numlist)}, and {opth post(numlist)}.

{pmore}
The program defaults to {it:nsim=}500. Users 
may begin with fewer simulations (e.g. {it:nsim=}100) to narrow down a range of parameter values. However, 
{it:nsim} of at least 1000 (or even 5000) is recommended for more precise convergence (although this does increase runtime).

{phang}
{opth out:file(filename)} specifies the name of the .csv output file that stores {cmd:pc_simulate} results in the current directory. 

{pmore}
If not specified, the program will generate the default {it:filename=}"c({it:filename})_power.csv". If 
the dataset in memory (i.e. c({it:filename})) is stored in a temp folder,
the default becomes {it:filename=}"pc_simulations_power.csv".

{pmore} Option {cmd:append} will append {cmd:pc_simulate} results below previous results in an existing {it:filename}. 
Option {cmd:replace} will overwrite an existing {it:filename}.
If {it:filename} exists, then either {cmd:append} or {cmd:replace} is required.


{marker opt_design}{...}
{dlgtab:Design options}

{phang}
{opt coll:apse} estimates a collapsed regression model. For 
{opt POST} and {opt ANCOVA} models, this collapses all post-treatment observations
to a unit-specific average, and estimates a cross-sectional regression.

{pmore}
For {opt DD} models, this collapses to separate pre-treatment and post-treatment unit-specific averages, and estimates a two-period pre/post panel. In 
a {opt coll:apse}d {opt DD} model, the default fixed effects become r({it:panelvar}) and a post-period dummy variable.

{pmore}
Collapsing data eliminates within-unit serial correlation, and the default standard
errors for all collapsed models are {opt vce(unadjusted)}, which yields correct inference.

{pmore}
To use the option {opt coll:apse}, fixed effects variables cannot vary along {it:both} unit and time dimensions.

{phang}
{opth strat:ify(varlist)} allows users to simulate stratified randomization, where randomization occurs within cells defined by {it:egen cell = group(varlist)}. 
For {opt stratify(gender age_group)}, each {it:gender-age_group} combination would represent a separate randomization cell. 
Each {it:panelvar} unit must be nested within a single cell.

{pmore}
Importantly, when using this option, {opt n(numlist)} governs the number of units {it:in each cell}, and {it:p*n} units per cell will be assigned to treatment. 
(The dataset must either contain at least {it:n} units in each randomization cell, or the option {opt boot:strap} must be specified.)

{pmore}
Note that {cmd:pc_simulate} still reports power associated with estimating sample-wide average treatment effects, even when simulating a stratified randomization.

{pmore}
Note also that in order to conduct proper inference, users must {it:either} include stratification variable(s) as fixed effects via option {opth a:bsorb(varlist)}, 
{it:or} cluster by the level(s) of stratification via option {opt vce}{cmd:(}{help reghdfe##opt_vce:{it:vcetype}}{cmd:)}.

{phang}
{opt idcl:uster(groupvar)} accommodates cluster randomization, where randomization occurs at the {it:groupvar} level. 
For example, if groups of {it:panelvar} units are located in villages, then {opt idcluster(village_id)} will randomize whole {it:villages} 
into treatment ({it:panelvar} units must fully nest within {it:groupvar} clusters).

{pmore}
Importantly, when using this option, {opt n(numlist)} governs the number of {it:clusters} 
(not the number of {it:units}), and {it:p*n} cluster will be assigned to treatment. 
(The dataset must either contain at least {it:n} distinct clusters, or the option {opt boot:strap} must be specified.)

{pmore}
Note that {cmd:pc_simulate} still reports power associated with estimating average treatment effects at the {it:unit level}.

{pmore}
Note also that in order to conduct proper inference, users should cluster standard errors by {it:groupvar} 
(i.e. the level of randomization) via option {opt vce}{cmd:(}{help reghdfe##opt_vce:{it:vcetype}}{cmd:)}.

{phang}
{opt sizecl:uster(#)} is a cluster randomization sub-option that defines the number of {it:panelvar} units within each {it:groupvar} cluster. 
If combined with {opt boot:strap}, each simulation will draw units with replacement from within each cluster (yielding clusters of the proscribed size). 
If {it:not} combined with {opt boot:strap}, then all clusters must contain sufficient units to achieve the proscribed size by drawing {it: without} replacement. 

{pmore}
If {opt sizecl:uster(#)} is not specified, {cmd: pc_simulate} will not alter the size of individual clusters. 
The program supports two cases: (i) clusters of homogeneous size, or (ii) potentially heterogeneous cluster sizes as given by the existing dataset.

{phang}
{opth pcl:uster(numlist)} is a cluster randomization sub-option that defines the intensity of treatment within each {it:groupvar} cluster. The program supports 3 cases:

{pmore}
(1): If {cmd: pcluster} is not specified, the default is to treat 100% of units within treated clusters (i.e. every unit within a treated cluster is treated, 
and every unit with a control cluster is not treated).

{pmore}
(2): If {cmd: pcluster} has a single value, all treated clusters will have this (uniform) treatment intensity. 
For example, {cmd: pcluster(0.6)} yields a 60% treatment intensity, 
whereby 60% of units in treated clusters are randomized into treatment. The other 40% of units in treated clusters are not treated, 
and every unit with a control cluster is likewise not treated.

{pmore}
(3): If {cmd: pcluster} has multiple values, treated clusters will have {it:heterogeneous} treatment intensities, 
assigned in equal proportions across treated clusters. For {cmd: p(0.25)} and {cmd: pcluster(0.4 0.7 1)}, 
25% of clusters receive 0%, 40%, 70%, and 100% treatment intensity (respectively).

{pmore}
Note that as with option {opth p(numlist)}, {cmd: pc_simulate} rounds to the nearest integer when randomizing 
(i) unit-level treatment within clusters and (ii) treatment intensities across clusters. For example, suppose {it:n=10}, 
{it:p=0.667}, {cmd: sizecluster(10)}, and {cmd: pcluster(0.25 1)}. In this case, 7 clusters will be treated (rounding {it:p*n}).
4 treated clusters will be assigned treatment intensity 0.25, and 3 treated clusters will be assigned treatment 
intensity 1 (since 2 intensities do not split evenly across 7 treated clusters). Within each of the 4 0.25-intensity clusters, 
3 out of 10 units will be treated (rounding {it:pcluster*sizecluster}).

{pmore}
Also, note that {cmd: pc_simulate} ignores any potential spillover effects within clusters, which are often a primary motivation for randomizing at the cluster level.


{marker opt_advanced}{...}
{dlgtab:Advanced options}

{phang}
{ifin} restrict the observations to be included in the power calculation, based on user-provided criteria. If
specified, the program begins by keeping only observations that meet these criteria. After 
finishing, the program restores the full original dataset.

{phang}
{opt ts:tart(# [#])} restricts the range of time periods over which to begin experiment. For example, {cmd:tstart(}4 7{cmd:)} 
will simulate experiments beginning in time periods {it:timevar}={4,5,6,7} with equal probability.

{pmore}
If only one number is specified, the option will default to {opt ts:tart(# max(timevar))}.

{pmore}
This option indicates the first {it:pre-treatment} period in a {opt DD} or {opt ANCOVA} model, the first {it:post-treatment} 
period in a {opt POST} model, and the {it:only} period in a {opt ONESHOT} model.

{pmore}
Unless {opt ts:tart(# [#])} is specified, each iteration will randomly select a ({it:pre+post})-period window from the full range of {it:timevar} in the dataset. 
For example, if {it:timevar}={1,2,...,100} and {it:pre+post}=8, then each iteration will simulate an 8-period experiment beginning 
in a time period drawn randomly from {it:timevar}={1,2,...,93}.

{phang}
{opth absorbf:actor(fvvarlist)} allows users to include factor variables as fixed effects, following the {help reghdfe##absvar:reghdfe} syntax. This 
option may be combined with the simpler {opth a:bsorb(varlist)}, and it overrides default fixed effects in {opt DD} models.

{phang}
{opth w:eight(weight)} allows users to specify three types of OLS weights: {opt fw:eight}s, {opt aw:eight}s and {opt pw:eight}s. This 
option uses the syntax {opt w:eight(aw=varname)}, and it does not support functions of weight variables. See {help weight} for further detail.

{phang}
{opt reghdfeopt:ions}{cmd:(}{help reghdfe##options:options}{cmd:)} allows users to pass through additional {help reghdfe} options. Most 
of these advanced options will not be compatible with {cmd:pc_simulate}, 
and most are unnecessary when estimating a randomized experiment. 

{pmore}
This program does not support instrumental variables, two-stage least squares, or other non-linear estimation techniques.


{hline}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. pc_simulate z, model(ONESHOT) mde(1) weight(fw=pop) n(50(5)100) vce(robust) nsim(50)}{p_end}

{phang}{cmd:. pc_simulate y if year>2000, model(DD) mde(10 20 50) i(id) t(year) n(100(50)300) bootstrap absorb(id year) nsim(100) out(power_calcs) replace}{p_end}

{phang}{cmd:. pc_simulate income, model(POST) mde(5) i(household) t(month) post(1:20) n(100) boot absorbf(i.village#i.month) nsim(200) stratify(village) append}{p_end}

{phang}{cmd:. pc_simulate consumption, model(ANCOVA) mde(-40) onesided i(indiv) t(week) post(10 20 30) pre(10 20 30) n(50 100 150) a(week) nsim(50) vce(cluster indiv) control(age female) replace}{p_end}

{hline}

{marker contact}{...}
{title:Contact}

{pstd}Louis Preonas{break}
Department of Agricultural and Resource Economics{break}
University of Maryland{break}
Email: {browse "mailto:lpreonas@umd.edu":lpreonas@umd.edu}
{p_end}

{pstd}This program is part of the {help ssc} package {cmd:pcpanel}.{p_end}

{hline}

{marker references}{...}
{title:References}

{p 0 0 0}
This program grew out of analysis conducted in:

{phang}
{browse "https://doi.org/10.1016/j.jdeveco.2020.102458":Burlig, Fiona, Louis Preonas, and Matt Woerman (2020). "Panel Data and Experimental Design." {it:Journal of Development Economics} 144: 102548.}
{p_end}

{p 0 0 0}
Additional references include:

{phang}
Athey, Susan, and Guido W. Imbens (2016). "The Econometrics of Randomized Experiments." Working Paper.
{p_end}

{phang}
Bertrand, Marianne, Esther Duflo, and Sendhil Mullainathan (2004). "How Much Should We Trust Differences-in-Differences Estimates?" {it:The Quarterly Journal of Economics} 119(1): 249-275.
{p_end}

{phang}
Bloom, Howard S. (1995). "Minimum Detectable Effects: A Simple Way to Report the Statistical Power of Experimental Designs." {it:Evaluation Review} 19(5): 547-556.
{p_end}

{phang}
Cameron, A. Colin, and Douglas L. Miller (2015). "A Practitioner's Guide to Cluster-Robust Inference." {it:Journal of Human Resources} 50(2): 317-372.
{p_end}

{phang}
Campbell, Cathy (1977). "Properties of Ordinary and Weighted Least Square Estimators of Regression Coefficients for Two-Stage Samples." {it:Proceedings of the Social Statistics Section, American Statistical Association}: 800-805.
{p_end}

{phang}
Duflo, Esther, Rachel Glennerster, and Michael Kremer (2007). "Using Randomization in Development Economics Research: A Toolkit."  Chap. 61 in {it:Handbook of Development Economics}, 
edited by Paul T. Schultz and John A. Strauss, 3895-3962. Volume 4. Oxford, UK: Elsevier.
{p_end}

{phang}
Frison, L., and S. J. Pocock (1992). "Repeated Measures in Clinical Trials: Analysis Using Mean Summary Statistics and its Implications for Design." {it:Statistics in Medicine} 11(13): 1685-1704.
{p_end}

{phang}
McKenzie, David (2012). "Beyond Baseline and Follow-up: The Case for More T in Experiments." {it:Journal of Development Economics} 99(2): 210-221.
{p_end}

{phang}
Moulton, Brent (1986). "Random Group Effects and the Precision of Regression Estimates." {it:Journal of Econometrics} 32(3): 385-397.
{p_end}

{phang}
Rubin, Donald B. (1974). "Estimating Causal Effects of Treatments in Randomized and Nonrandomized Studies." {it:Journal of Educational Psychology} 66(5): 688-701.
{p_end}



