{smcl}
{* *! version 1.7 22jan2016}{...}
{vieweralsosee "[SVY] svy" "help svy"}{...}
{vieweralsosee "[R] pisastats" "help pisastats"}{...}
{vieweralsosee "[R] pisareg" "help pisareg"}{...}
{vieweralsosee "[R] piaacreg" "help piaacreg"}{...}
{vieweralsosee "[R] piaacdes" "help piaacdes"}{...}
{vieweralsosee "[R] piaactab" "help piaactab"}{...}
{viewerjumpto "Description" "repest##description"}{...}
{viewerjumpto "Options" "repest##options"}{...}
{viewerjumpto "Remarks" "repest##remarks"}{...}
{viewerjumpto "Examples" "repest##examples"}{...}
{viewerjumpto "Stored results" "repest##storedresults"}{...}
{viewerjumpto "Authors" "repest##authors"}{...}
{title:Title}

{p2colset 8 25 20 2}{...}
{p2col :{hi:[R] repest}} Estimation with weighted replicate samples and plausible values{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:repest}
		{it:{help repest##svyname:svyname}}
        {ifin} 
		, {bf:{ul:est}imate(}{it:cmd} [,{it:cmd_options}]{bf:)} 
		[{it:options}] 

     
{synoptset 40 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{bf:{ul:est}imate(}stata: {it:{help repest##e_cmd:e_cmd}} [,{it:e_cmd_options}]{bf:)}}runs stata estimation command {it:{help repest##e_cmd:e_cmd}} with options {it:e_cmd_options}. {p_end}
{synopt :{bf:{ul:est}imate(}{it:{help repest##n_cmd:n_cmd}} [,{it:n_cmd_options}]{bf:)}}runs built-in command {it:{help repest##n_cmd:n_cmd}} with options {it:n_cmd_options}. {p_end}

{synoptset 40 tabbed}{...}
{syntab:Optional}
{synopt :{bf:by(}{it:{help varname:varname}} [,{it:{help repest##by_options:by_options}}]{bf:)}}produces separate estimates by levels of varname. Averaged results can optionally be requested.{p_end}
{synopt :{bf:over(}{it:{help varlist:varlist}} [,test]{bf:)}}jointly estimates across levels of {it:{varlist}}.{p_end}
{synopt :{bf:outfile(}{it:{help filename:filename}} [,{it:{help repest##of_options:of_options}}]{bf:)}}
saves results to disk.{p_end}
{synopt :{bf:results(}{it:{help repest##results_options:results_options}}{bf:)}}keep, add, and combine estimation results.{p_end}
{synopt :{bf:display}}displays results in output window.{p_end}
{synopt :{bf:flag}}flags elements of results which should not be reported.{p_end}
{synopt :{bf:coverage}}Reports coverage of estimation sample relative to target sample.{p_end}
{synopt :{bf:{ul:svy}parms(}{it:{help repest##svy_options:svy_options}}{bf:)}}overrides default parameters set by {it:{help repest##svyname:svyname}}.{p_end}
{synopt :{bf:fast}} when a {help repest##pv:pvvarlist} is specified, computes sampling variance only for the first plausible value. {p_end}
{synopt :{bf:store(}{it:string}{bf:)}} saves the estimation results stored in e().{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{bf:ALL}, {bf:IALS}, {bf:IELS}, {bf:PIAAC}, {bf:PISA}, {bf:PISA2015}, {bf:PISAOOS}, {bf:SVY}, {bf:TALISSCH} and {bf:TALISTCH}  are valid {it:{help repest##svyname:svynames}}. Option {bf:svyparms()} is required with {bf:SVY}.
{p_end}
{p 4 6 2}
You have to specify one {bf:{ul:est}imate()} option.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:repest}  estimates statistics using replicate weights (BRR weights, Jackknife replicate 
weights,...), thus accounting for complex survey designs in the estimation of sampling 
variances. It is specially designed to be used with the IELS, PIAAC, PISA and TALIS datasets produced by 
the OECD, but works for ALL and IALS datasets as well.  It also allows for analyses with multiply imputed variables (plausible values); where 
plausible values are included in a {help repest##pv:pvvarlist},  the average estimator across plausible values is 
reported and the imputation error is added to the variance estimator.

{marker svyname}{...}
{pstd}
{it:svyname} is a shortcut for declaring survey settings. Use {it:svyname} to indicate the data 
source. {it:svyname}  must be equal to {bf:ALL}, {bf:IALS}, {bf:IELS}, {bf:PIAAC}, {bf:PISA}, {bf:PISA2015}, {bf:PISAOOS}, {bf:TALISSCH} 
(for TALIS data, using school weights) or {bf:TALISTCH} (for TALIS data, using teacher weights).
In addition, {it:svyname} can be equal to {bf:SVY}: in this case, you must specify survey settings using option {bf:svyparms()}.
Also see {help repest##svyremarks:remarks} below.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{bf:{ul:est}imate(}stata: {it:{help repest##e_cmd:e_cmd}} 
[,{it:e_cmd_options}]{bf:)} runs stata estimation command {it:{help repest##e_cmd:e_cmd}} 
with options {it:e_cmd_options}.

{pmore}
{marker e_cmd}{...}
{it:e_cmd} can be any {help estimation command:estimation command}  that posts results in {bf:e(b)} 
and accepts {help weight:pweights} or {help weight:aweights}, including 
user-defined {help program:e-class programs} (see {help repest##remarks:remarks} below). 
Options for {it:e_cmd} must be declared after 
a comma, as in the original syntax of {it:e_cmd}. Weights are used but should not be declared, as they are passed to the estimation command from the survey 
settings.  Optional {ifin} statements are not to be included in {it:e_cmd} and 
should be declared after the command {cmd:repest}. 

{pmore}
As a Stata 11 command, {cmd: repest} runs any {it:e_cmd} assuming Stata version 11.0. 
To change this, a {cmd: version ##:} prefix can be included in the {it:e_cmd} 
(as in {cmd: repest PIAAC, estimate(stata: version 13: ivregress}{it:...}{cmd:)}.
Most other {help prefix:prefix commands} cannot be included. 

{pmore}
{help varlist: varlists} within {it:e_cmd} or {it:e_cmd_options} that include plausible values 
should be specified as {help repest##pv:pvvarlists}. {help varlist: varlists}
and {help repest##pv:pvvarlists} can contain {help fvvarlist:factor variables}.

{phang}
{bf:{ul:est}imate(}{it:{help repest##n_cmd:n_cmd}} [,{it:n_cmd_options}]{bf:)} runs built-in command {it:{help repest##n_cmd:n_cmd}} with options {it:n_cmd_options}.

{pmore}
{marker n_cmd}{...}
{it:n_cmd} refers to predefined commands for standard descriptive analyses. The following {it:n_cmd} exist: 

{phang2}
{bf:means} {help repest##pv:pvvarlist} {bf:[, pct]} 
computes means of all variables in {help repest##pv:pvvarlists}. {help repest##pv:pvvarlists} may contain a mix of {help repest##pv:pvvarnames} 
and {help varname: varnames}. Option {bf:pct} multiplies means by 100 - e.g. to report percentages on binary (0/1) indicator variables.

{phang2}
{bf:freq} {help repest##pv:pvvarname} {bf:[, count levels(}{it:levelslist}{bf:)]} computes frequency counts of categorical variable {help repest##pv:pvvarname}. 
{help repest##pv:pvvarname} may be a {help varname:varname} or a {it:set of plausible values}, such as plausible proficiency levels. By default, {cmd: freq} 
reports frequencies as percentages. If sub-option {cmd:count} is specified, raw counts are reported.
 If sub-option {cmd:levels()} is specified, only levels of {help repest##pv:pvvarname} in {it: levelslist} are reported. 

{phang2}
{bf:corr} {help repest##pv:pvvarlist} {bf:[, pairwise]} computes pearson correlation coefficients among variables of {help repest##pv:pvvarlists}. 
{help repest##pv:pvvarlists} may contain a mix of {help repest##pv:pvvarnames} and {help varname: varnames}. Option {bf:pairwise} requests pairwise 
correlations (see {help pwcorr:pwcorr}). The default is to delete observations listwise. 

{phang2}
{bf:summarize} {help repest##pv:pvvarlist} {bf:, stats({it:statlist})} computes summary statistics of all variables in {help repest##pv:pvvarlists}. 
{help repest##pv:pvvarlists} may contain a mix of {help repest##pv:pvvarnames} and {help varname: varnames}. You have to specify sub-option {cmd: stats()}.

{phang3}
{cmd:stats(}{it:statname} [{it:statname ...}]{cmd:)}
   specifies the statistics to be estimated;  ou have to specify at least one {it:statname}. Multiple statistics may be specified
   and are separated by white space, such as {cmd:stats(mean sd)}.
   Available statistics are

{marker statlist}{...}
{synoptset 25}{...}
{synopthdr:{space 12} statname}
{space 12}{synoptline}
{synopt:{space 12}{bf:mean}}mean{p_end}
{synopt:{space 12}{bf:sd}}standard deviation{p_end}
{synopt:{space 12}{bf:kurtosis}}kurtosis {p_end}
{synopt:{space 12}{bf:skewness}}skewness {p_end}
{synopt:{space 12}{bf:min}}minimum{p_end}
{synopt:{space 12}{bf:max}}maximum{p_end}
{synopt:{space 12}{bf:p1}}1st percentile {p_end}
{synopt:{space 12}{bf:p5}}5th percentile {p_end}
{synopt:{space 12}{bf:p10}}10th percentile {p_end}
{synopt:{space 12}{bf:p25}}25th percentile {p_end}
{synopt:{space 12}{bf:p50}}50th percentile {p_end}
{synopt:{space 12}{bf:p75}}75th percentile {p_end}
{synopt:{space 12}{bf:p90}}90th percentile {p_end}
{synopt:{space 12}{bf:p95}}95th percentile {p_end}
{synopt:{space 12}{bf:p99}}99th percentile {p_end}
{synopt:{space 12}{bf:Var}}variance{p_end}
{synopt:{space 12}{bf:sum}}sum of variable{p_end}
{synopt:{space 12}{bf:N}}number of observations{p_end}
{synopt:{space 12}{bf:sum_w}}sum of the weights{p_end}
{space 12}{synoptline}
{p2colreset}{...}
 

{phang2}
{bf:quantiletable} {it: index outcome} {bf:[,} {bf:{ul:nq}uantiles(}{it:n}{bf:)} 
{bf:{ul:noindexq}uantiles} {bf:{ul:nooutcomeq}uantiles} {bf:{ul:relr}isk} {bf:{ul:odds}ratio} {bf:{ul:su}mmarize(}{it:var1}{bf:)} {bf:{ul:reg}ress(}{it:var2 var3}{bf:)} {bf:test]} 
computes a quantile table, similar to tables introducing indices in PISA international reports. {bf:quantiletable} {it:index outcome} generates quantile categories of {it:index} and 
reports the average of {it:index} and {it:outcome} within {it:index} quantile categories. 
{bf:{ul:nq}uantiles(}{it:n}{bf:)} specifies how many quantile categories are generated - the default is 4 (quarters). 
{bf:{ul:noindexq}uantiles} drops averages of {it:index} within {it:index} quantile categories from the results.
{bf:{ul:nooutcomeq}uantiles} drops averages of {it:outcome} within {it:index} quantile categories from the results.
{bf:{ul:relr}isk} adds to the results a measure of relative risk for the likelihood of {it:outcome} being in the top quantile category of {it:outcome} if {it:index} 
is in the bottom quantile category of {it:index}.
{bf:{ul:odds}ratio} adds to the results the odds ratios for the likelihood of {it:outcome} being in the top quantile category of {it:outcome} if {it:index} 
is in the bottom quantile category of {it:index}.
{bf:{ul:su}mmarize(}{it:var1}{bf:)} adds to the results the mean and standard deviation of {it:var1}.
{bf:{ul:reg}ress(}{it:var2 var3}{bf:)} adds to the results the r-squared from the regression of {it:var2} on {it:var3}.
{bf:test} adds to the results the difference between the average of {it:outcome} in the top {it:index} quantile category and the average of {it:outcome} in the bottom {it:index} quantile category.
 
{dlgtab:Other}

{phang}
{marker by_options}{...}
{bf:by(}{it:{help varname:varname}} [, levels({it:string}) average({it:string}) ]{bf:)} produces separate estimates by levels of {it: varname}. The following options can be specified:

{phang2}
{bf:levels(}{it:string}{bf:)} requests estimates only for the listed levels of {it:varname}. The default is to produce estimates for all levels of {it:varname}.

{phang2}
{bf:average(}{it:string}{bf:)} requests averaged estimates for the listed levels of {it:varname}.

{phang}
{bf:over(}{it:{help varlist:varlist}} [,test]{bf:)} requests estimates to be obtained 
separately for each level of categorical variables {it:varlist}.  The variables must be 
numerical. If more than one variable is specified, {help repest##of_options:long_over} is assumed.

{phang2}
{bf:test} computes the difference between estimates obtained for the 
highest and the lowest values of {it:varname}. It is useful to test for differences. Also see {help repest##results_options:results(combine())}.

{phang}
{marker results_options}{...}
{bf:results(}[keep({it:string}) add({it:string})  combine({it:string})]{bf:)} can be
 used to keep only estimation results of interest, to add scalars from {it: ereturn} to
 the results, and to  combine elements of {bf:e(b)} to form new scalars (e.g. to test
 for differences).

{phang2}
{bf:keep(}{it:keeplist}{bf:)} requests that only the listed elements of {bf:e(b)} be
 kept. {it:keeplist} must specify names exactly as in the output, except if the name 
 contains a {it: pvvarname}, in which case the "@" character must be used.

{phang2}
{bf:add(}{it:addlist}{bf:)} requests that the listed elements be added to the results of {bf: repest}. {bf:add()} can only be used after  {bf:estimate(}stata: {it: e_cmd}{bf:)}. 
{it:addlist} must contain names of scalar returned by {it: e_cmd}, such as {bf:r2} (rsquared), {bf:ll} (log-likelihood), {bf:N} (number of observations). 
To see the list of available scalars, type {bf: help} {it: e_cmd} in the command prompt. 

{phang2}
{bf:combine(}{it:name: myexp [, name: myexp] [, ...]}{bf:)} computes {it: myexp} and adds the result to the output of {bf: repest}, with name {it: name}. 
{it: myexp} must contain names of estimated results, together with
{help operators: operators} and/or {help mathematical functions: mathematical functions}.
Estimated results must be enclosed by {bf: _b[}{it:...}{bf:]} . 


{phang}
{marker of_options}{...}
{bf:outfile(}{it:filename [, long_over pvalue]}{bf:)} saves the results of {bf: repest} to a .dta file (Stata dataset). This makes further manipulation of results easy. .dta files can be exported to excel using {bf: export excel}.

{phang2}
{bf:long_over} Requests the outfile to be organised in long form (see {help reshape##overview:reshape long/wide}). The default is to store results in wide form. (Only to be used in combination with the {bf:over()} option.)

{phang2}
{bf:pvalue} Requests the outfile to include p-values for tests of statistical significance. The reported pvalues are based on a z-test assuming an asymptotically normal distribution for the estimated parameter.

{phang}
{bf:display} forces the results of {bf: repest} to be displayed in Stata's result window. The default is to display results only if no {bf: outfile()} option is specified.

{phang}
{bf:flag} replaces estimation results which are based on fewer observations than required for reporting with a specific missing code ({bf:.f}) in the {bf: outfile}, and by (omitted) in {bf: display}. 
{bf: repest PISA, flag} checks that each estimation result is based on at least 30 observations and 5 schools. {bf: repest PIAAC, flag} 
checks that each estimation result is based on at least 30 observations. {bf: repest TALISSCH, flag} checks that each estimation result is based on at least 10 schools.
{bf: repest TALISTCH, flag} checks that each estimation result is based on at least 30 observations and 10 schools.

{phang}
{bf:coverage} computes the (weighted) proportion of observations in the target sample (i.e. accounting for any {ifin} statements) that is included in the estimation sample. 
Coverage proportions are stored as additional coefficients in e(b).
{it:Note}: if option {bf:over} is specified, the target population is restricted to observations where variables specified within this option are not missing; if, in addition, 
suboption {bf:test} is specified within {bf:over}, the coverage reported for the difference corresponds to the lowest coverage of the two. 

{phang}
{bf:fast} When a {help repest##pv:pvvarlist} is specified, the share of variance accounted for by the sampling error is computed only for the first {bf: plausible value}. This is an unbiased shortcut that makes computation of the variance-covariance matrix faster.

{phang}
{bf:store(}{it:string}{bf:)} saves the results stored in e(), renaming the output with {it:string} as prefix (see {it:{help estimates store:store}}).

{phang}
{marker svy_options}{...}
{bf:{ul:svy}parms(}[NBpv(#) final_weight_name({it:string}) rep_weight_name({it:string}) variancefactor(#) NREP(#)]{bf:)} 
sets or overrides survey parameters, which are usually defined by {it:{help repest##svyremarks:svyname}}. Option {bf:svyparms()} is required
if {it:{help repest##svyname:svyname}} equals {bf:SVY}.

{marker remarks}{...}
{title:Remarks}

{marker pv}{...}
{bf: Plausible values}
{pstd}
A {it: pvvarname} is a set of plausible values. A {it: pvvarname} looks like a valid stata name 
that contains the character "@" (e.g. "pv@math"). When it encounters a {it: pvvarname}, {cmd:repest} checks that variables 
"*1*" to "*{it:M}*" exist (e.g. pv1math-pv5math), where {it:M} is the number of plausible values in survey 
{it:{help repest##svyname: svyname}}, and uses them as appropriate in the estimation. 

{pstd}
{it: pvvarlists} are {it:{help varlist: varlists}} that may, or not, include a {it: pvvarname} . 

{pstd}
Plausible values are multiply imputed measures of unobserved characteristics, such as students' 
skills, that allow estimates to be unbiased by measurement error.

{marker svyremarks}{...}
{bf: Survey options}
{pstd}
{help repest##svyname:svyname} sets the following parameters (bold indicates variable names that must 
exist in the dataset in use). These parameters can be overridden by values set in option {bf:svyparms({it:{help repest##svy_options:svy_options}})}.  {p_end}

{p2colset 10 45 45 15} 
{p 10 10 15}{bf:PISA2015}: Programme for International Student Assessment{p_end}
{p2line}
{p2col:Final weight} {bf:w_fstuwt}{p_end}
{p2col:Replicate weights} {bf:w_fsturwt1-w_fsturwt80}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 80 {p_end}
{p2col:Number of plausible values} 10{p_end}
{p2col:Primary sampling unit (for flags)} {bf:cnt cntschid}{p_end}

{p 10 10 15}{bf:PISA}: Programme for International Student Assessment{p_end}
{p2line}
{p2col:Final weight} {bf:w_fstuwt}{p_end}
{p2col:Replicate weights} {bf:w_fstr1-w_fstr80}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 80 {p_end}
{p2col:Number of plausible values} 5{p_end}
{p2col:Primary sampling unit (for flags)} {bf:cnt schoolid}{p_end}
{p 10 15 15}{it:Note}: with PISA 2015 data, {bf: repest} automatically changes to {bf:PISA2015} options. {p_end}


{p 10 10 15}{bf:PISAOOS}: PISA for Development - assessment of out-of-school youth {p_end}
{p2line}
{p2col:Final weight} {bf:spfwt0}{p_end}
{p2col:Replicate weights} {bf:spfwt1-spfwt30}{p_end}
{p2col:Variance factor} Jackknife 1 {p_end}
{p2col:Number of replications} 30 {p_end}
{p2col:Number of plausible values} 10 {p_end}

{p 10 10 15}{bf:TALISTCH}: Teaching and Learning International Survey (teacher weights){p_end}
{p2line}
{p2col:Final weight} {bf:tchwgt}{p_end}
{p2col:Replicate weights} {bf:trwgt1-trwgt100}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 100 {p_end}
{p2col:Primary sampling unit (for flags)} {bf:cntry idschool}{p_end}


{p 10 10 15}{bf:TALISSCH}: Teaching and Learning International Survey (school weights){p_end}
{p2line}
{p2col:Final weight} {bf:schwgt}{p_end}
{p2col:Replicate weights} {bf:srwgt1-srwgt100}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 100 {p_end}

{p 10 10 15}{bf:TALISEC_STAFF}: Teaching and Learning International Survey - Starting Strong (staff weights){p_end}
{p2line}
{p2col:Final weight} {bf:staffwgt}{p_end}
{p2col:Replicate weights} {bf:srwgt1-srwgt92}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 92 {p_end}
{p2col:Primary sampling unit (for flags)} {bf:idcntpop idcentre}{p_end}


{p 10 10 15}{bf:TALISEC_LEADER}: Teaching and Learning International Survey - Starting Strong (leader weights){p_end}
{p2line}
{p2col:Final weight} {bf:cntrwgt}{p_end}
{p2col:Replicate weights} {bf:crwgt1-crwgt92}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 92 {p_end}


{p 10 10 15}{bf:PIAAC}: Programme for the International Assessment of Adult Competencies{p_end}
{p2line}
{p2col:Final weight} {bf:spfwt0}{p_end}
{p2col:Replicate weights} {bf:spfwt1-spfwt80}{p_end}
{p2col:Variance method*} Jackknife 1 or 2, depending on {bf:vemethodn}{p_end}
{p2col:Number of replications} 80 {p_end}
{p2col:Number of plausible values} 10{p_end}

{p 10 10 15}*The correct estimation of standard errors with PIAAC data is done with Jackknife 1 
(Australia, Austria, Canada, Denmark, Germany) or Jackknife 2 (all other countries). 
In Jackknife 1, the covariance matrix of replicate estimates is adjusted with a factor equal to 79/80. 
When Jacknife 1 and 2 country samples are pooled, the adjustment factor is computed as a convex mixture
of 79/80 and 1, with mixture weights proportional to the share of the sample from Jackknife 1 countries; 
this share is computed using {bf:spfwt0} weights.


{p 10 10 15}{bf:ALL}: Adult Literacy and Lifeskills Survey{p_end}
{p 10 10 15}{bf:IALS}: International Adult Literacy Survey{p_end}
{p2line}
{p2col:Final weight} {bf:popwt}{p_end}
{p2col:Replicate weights} {bf:REPLIC1-REPLIC30}{p_end}
{p2col:Variance factor} Jackknife 2 {p_end}
{p2col:Number of replications} 30 {p_end}
{p2col:Number of plausible values} 10{p_end}

{p 10 10 15}{bf:IELS}: International Early Learning Study {p_end}
{p2line}
{p2col:Final weight} {bf:CHILDWGT}{p_end}
{p2col:Replicate weights} {bf:SRWGT1-SRWGT92}{p_end}
{p2col:Variance method} balanced repeated replication with Fay's adjustment {p_end}
{p2col:Fay's parameter} 0.5{p_end}
{p2col:Number of replications} 92 {p_end}
{p2col:Number of plausible values} 5 {p_end}
{p2col:Primary sampling unit (for flags)} {bf:IDCNTRY IDCENTRE}{p_end}


{p 10 10 15}{bf:SVY}: User-defined survey settings (requires option {bf:{ul:svy}parms()}){p_end}
{p2line}
{p2col:Final weight} set by suboption {bf:final_weight_name({it:string})} {p_end}
{p2col:Replicate weights} set by suboption {bf:rep_weight_name({it:string})} {p_end}
{p2col:Variance factor} set by suboption {bf:variance_factor(#)}  {p_end}
{p2col:Number of replications} set by suboption {bf:NREP(#)}  {p_end}
{p2col:Number of plausible values} set by suboption {bf:NBpv(#)}  {p_end}

{bf: User-defined estimation commands}
{pstd}
The syntax of user-defined estimation commands must be such that 
all variables required for their execution, except weights, are 
declared on the command line, as in the last example below. 
User-defined commands must accept aweights or pweights. A typical syntax statement
 for user-defined programmes is {p_end}
 {phang}{cmd:. syntax varlist [if] [in] [pweight] [,} {it:options}{cmd:]}{p_end} 


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Built-in estimation commands: means, summarize, corr, etc.{p_end}

{phang}{cmd:. repest PIAAC, estimate(means age_r) by(cnt)}{p_end}

{phang}{cmd:. repest TALISTCH, estimate(freq tchagegr) by(cnt)}{p_end}
   {hline}
{pstd}Combining results{p_end}

{phang}{cmd:. repest PISA, estimate(summarize escs, stats(p5 p95)) by(cnt) results(combine(escs_length: _b[escs_p95] - _b[escs_p5]))}{p_end}
    {hline}
{pstd}Using plausible values{p_end}

{phang}{cmd:. repest PISA, estimate(corr pv@math pv@read pv@scie) by(cnt)}{p_end}
    {hline}
{pstd}Stata estimation commands: regress, logistic, sureg, etc.{p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: reg lnwage pvlit@ yrsqual) by(cnt)}{p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: sureg (lnwage pvlit@ yrsqual) (lnwage pvnum@ yrsqual)) by(cnt)}{p_end}
    {hline}
{pstd}Estimation on pooled country samples{p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: reg lnwage pvlit@ yrsqual)}{p_end}
    {hline}
{pstd}Adding estimated scalars to results (e.g. r2){p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: reg lnwage pvlit@ yrsqual) by(cnt) results(add(r2))}{p_end}
   {hline}
{pstd}Requesting averaged results{p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: reg lnwage pvlit@ yrsqual) by(cnt, levels(ITA FRA DEU) average(FRA DEU))}{p_end}
    {hline}
{pstd}Saving results to excel{p_end}

{phang}{cmd:. repest PIAAC, estimate(stata: reg lnwage pvlit@ yrsqual) by(cnt) outfile(wagereturns)}{p_end}
{phang}{cmd:. use wagereturns, clear}{p_end}
{phang}{cmd:. export excel using wagereturns.xls, first(var)}{p_end}
    {hline}
{pstd}User-defined estimation command: 1. simultaneous weighted quantile regressions{p_end}

{phang2}{cmd: cap program drop mysqreg }{p_end}
{phang2}{cmd: program define mysqreg, eclass}{p_end}
{asis}
        syntax varlist [if] [in] [pweight] [, flag Quantiles(numlist)]
        version 12.1
        // compute quantile regressions, store results in vectors
        foreach q in `quantiles' {
            tempname q`q'
            qreg `varlist' [pw `exp'] `if' `in', quantile(`q')
            matrix `q`q'' = e(b)
            matrix coleq `q`q'' = q`q'
            local results = "`results'" + "`q`q''" + " , "
            }
        // post results
        tempname b
        local results = regexr("`results'", "\,.$" ,"")
        matrix `b' = [`results']
        ereturn post `b' 
{smcl}
{phang2}{cmd: end}{p_end}
{phang}{cmd:. repest PISA, estimate(stata: mysqreg pv@math escs girl, q(25 75)) by(cnt) results(keep(q25_girl q75_girl) combine(qdiffgirl: _b[q75_girl] - _b[q25_girl]))}{p_end}

    {hline}
{pstd}User-defined estimation command: 2. logit postestimation {p_end}

{phang2}{cmd: cap program drop mylogitmargins }{p_end}
{phang2}{cmd: program define mylogitmargins, eclass}{p_end}
{asis}
        syntax [if] [in] [pweight], logit(string) [margins(string) loptions(string) moptions(string)]
        tempname b m
        // compute logit regressions, store results in vectors
                logit `logit' [`weight' `exp'] `if' `in', `loptions'
                matrix `b'= e(b)
        // compute logit postestimation, store results in vectors
                if "`margins'" != "" | "`moptions'" != ""{
                        margins `margins', post `moptions'
                        matrix `m' = e(b)
                        matrix colnames `m' =  margins:
                        matrix `b'= [`b', `m']
                        }
        // post results
                ereturn post `b' 
{smcl}
{phang2}{cmd: end}{p_end}
{phang}{cmd:. repest PISA, estimate(stata: mylogitmargins, logit(repeat pv@math escs ib1.st04q01) margins(st04q01) moptions(atmeans))} {p_end}
    {hline}


{marker storedresults}{...}
{title:Stored results}

{pstd}
{cmd:repest} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimator vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators. 
{ul:Note:} If option {bf:over()} is used, only diagonal (variance) 
elements are included in stored results.{p_end}

{marker authors}{...}
{title:Authors}

Francesco Avvisati
Directorate for Education and Skills
Organisation for Economic Co-operation and Development (OECD)
francesco.avvisati@oecd.org

Francois Keslair
Directorate for Education and Skills
Organisation for Economic Co-operation and Development (OECD)
francois.keslair@oecd.org


{title:Also see}

{help svy:svy}, {help pisastats:pisastats}, {help pisareg:pisareg}, {help piaacreg:piaacreg}, {help piaacdes:piaacdes}, {help piaactab:piaactab}
