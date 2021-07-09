{smcl}
{* version 1.8.6   Ian White   17jan2018}{...}
{* 17jan2018, updated to UCL}{...}
{* 14mar2017, small changes to Introduction}{...}
{title:Title}

{phang}
{bf:strbee} {hline 2} Estimate a treatment effect adjusting for treatment switches
{viewerjumpto "Introduction" "strbee##introduction"}{...}
{viewerjumpto "Syntax" "strbee##syntax"}{...}
{viewerjumpto "Description" "strbee##description"}{...}
{viewerjumpto "Options to specify the model (estimation syntax)" "strbee##opts_model"}{...}
{viewerjumpto "Options to specify the estimator (estimation syntax)" "strbee##opts_estimator"}{...}
{viewerjumpto "Options to specify the search procedure (estimation syntax)" "strbee##opts_search"}{...}
{viewerjumpto "Options controlling storage of results (estimation syntax)" "strbee##opts_storage"}{...}
{viewerjumpto "Options controlling output (both syntaxes)" "strbee##opts_output"}{...}
{viewerjumpto "Changes from version 1.2 to version 1.5" "strbee##whatsnew15"}{...}
{viewerjumpto "Changes from version 1.5 to version 1.8" "strbee##whatsnew18"}{...}
{viewerjumpto "Estimation by interval bisection" "strbee##bisection"}{...}
{viewerjumpto "Examples" "strbee##examples"}{...}
{viewerjumpto "Troubleshooting" "strbee##troubleshooting"}{...}
{viewerjumpto "Updates" "strbee##updates"}{...}
{viewerjumpto "Technical notes" "strbee##technotes"}{...}
{viewerjumpto "Limitations" "strbee##limitations"}{...}
{viewerjumpto "References" "strbee##refs"}{...}



{title:Introduction}{marker introduction}

{p 4 4 2}{cmd:strbee} analyzes a two-arm clinical trial with a survival outcome, in which
some subjects may "crossover" or "switch" to receive the treatment of the other arm. 

{p 4 4 2}The model is the Rank-Preserving Structural Nested Failure Time Model 
(RPSFTM) of {help strbee##RT91:Robins and Tsiatis (1991)}. 
This model uses an accelerated life model to relate the observed event time T to
an underlying event time U that would have been observed in the absence of
treatment.  
The effect of treatment is expressed through a parameter psi
which represents the log of the "acceleration factor", 
the factor by which life is accelerated by treatment. 
Negative values of psi mean that treatment improves survival.

{p 4 4 2}Psi is estimated as the value at which U is balanced between the treatment arms 
(on a user-specified test applied to all patients whether or not they switch). 
Point estimation ("G-estimation") is performed by searching over a range of values of psi for a value where the test statistic Z(psi) is close to 0. 
Confidence limits are similarly found where the test statistic Z(psi) is close to its critical values.

{p 4 4 2}{cmd:strbee} was originally described in {help strbee##White++02:White et al (2002)}. This version has new features described {help strbee##whatsnew15:below}.



{title:Syntax}{marker syntax}

Estimation syntax:

{p 8 17 2}
    {cmd:strbee} {it:treatvar} [{cmd:if} exp] [{cmd:in} range]
    [{cmd:,}
    {cmd:xo0(}{it:timevar eventvar}{cmd:)} 
    {cmd:xo1(}{it:timevar eventvar}{cmd:)} 
    {cmdab:end:study(}{it:varname}{cmd:)} 
    {cmd:psimult(}{it:exp}{cmd:)} 
    {cmdab:te:st(}{cmdab:log:rank}|{cmdab:wil:coxon}|{cmd:cox}|{cmdab:wei:bull}|{cmdab:exp:onential}{cmd:)}
    {cmdab:adj:vars(}{it:varlist}{cmd:)}
    {cmdab:st:rata(}{it:varlist}{cmd:)} 
    {cmd:ipe} 
    {cmd:ipecens}
    {cmd:psistep(}#{cmd:)}
    {cmd:tol(}#{cmd:)}
    {cmd:noci}  
    {cmd:trace}  
    {cmd:psistart(}#{cmd:)}
    {cmd:maxiter(#)}
    {cmdab:save:dta(}{it:filename}[{cmd:,append}|{cmd:replace}]{cmd:)}
    {cmd:ipestore(}{it:name}{cmd:)}
    {it:common_options}
    ]

{p 4 4 2}where {it:treatvar} is the treatment arm, which must have values 0 and 1; 
{it:timevar} and {it:eventvar} are time to switch and an indicator of switching.

{p 4 4 2}This is the standard syntax. Results for psi and Z(psi) may be
stored or appended to an existing results file.

Replay syntax:

{p 8 17 2}
    {cmd:strbee} [{cmd:using} {it:filename}]
    [{cmd:,} 
    {it:common_options}
    ]

{p 4 4 2}This uses previously stored results for psi and Z(psi). 
If  {cmd:using} {it:filename} is omitted and {cmd:strbee} was the last r-class command run, then the results from the last run of {cmd:strbee} are used.

{it:common_options} are
{p 8 17 2}    {cmd:list}
    {cmd:psimin(}#{cmd:)}
    {cmd:psimax(}#{cmd:)}
    {cmdab:zgr:aph}[{cmd:(}{it:graph_options}{cmd:)}]
    {cmd:level(}#{cmd:)} 
    {cmd:hr}
    {cmdab:km:graph}[{cmd:(}{it:graph_options}{cmd:)}]
    {cmd:gen(}{it:newvarname}{cmd:)}



{title:Description}{marker description}

{p 4 4 2}{cmd:strbee} is an {help st} command: data must be {help stset} before running {cmd:strbee}.
Each subject must have a single record starting at time 0.

{p 4 4 2}Censored data present an extra problem for {cmd:strbee}, since noninformative
censoring of T implies informative censoring of U. To avoid bias, users must
specify the potential censoring time for all subjects: {cmd:strbee} then computes
a recensoring time, which may be earlier than the actual censoring time, and
recensors the data.



{title:Options to specify the model (estimation syntax)}{marker opts_model}

{p 4 4 4}Simple switching patterns may be specified using {cmd:xo0()} and/or {cmd:xo1()}.
More complex switching patterns may be specified using {cmd:ton()} and/or {cmd:toff()}.
These options cannot be used together.

{phang}{cmd:xo0(}{it:timevar eventvar}{cmd:)} specifies time to switch and a switch
    indicator in arm 0. If not specified, it is assumed that there is no
    switch from arm 0 to arm 1.

{phang}{cmd:xo1(}{it:timevar eventvar}{cmd:)} does the same for arm 1. If not specified, it is
    assumed that there is no switch from arm 1 to arm 0.

{phang}{cmd:ton(}{it:varname}[,{it:suboptions}]) is an alternative way to specify times to switch. 
It is suitable for more complex switching patterns.
{it:varname} must be a variable containing the total time on treatment for each individual. 

{p 8 8 8}The suboptions are {cmd:min0(}{it:exp}{cmd:)}, {cmd:min1(}{it:exp}{cmd:)}, {cmd:max0(}{it:exp}{cmd:)}
and {cmd:max1(}{it:exp}{cmd:)}, 
which allow the user to make the recensoring procedure more efficient by specifying logical limits on
the lengths of time spent on treatment. For example, {cmd:max0(1) max1(1)} would be appropriate if it was not possible to receive treatment, in either arm, for more than 1 year (and assuming year is the unit of time).

{phang}{cmd:toff(}{it:varname}[,{it:suboptions}]) specifies the total time off treatment for each individual. 
The suboptions are the same as for {cmd:ton()}.
{cmd:toff()} may be used as an alternative to {cmd:ton()} or as a complement. 
Continuing the example given under {cmd:ton()}, if it were also known that no control arm individual could switch in the first 6 months, then one might code {cmd:ton(tonvar, max0(1) max1(1)) toff(, min(0.5))}.

{phang}{cmd:endstudy(}{it:varname}{cmd:)} specifies the time of the end of study (the potential
    censoring time). U values are then recensored at the minimum possible
    potential censoring time on the U scale, where the minimization is carried
    out over all treatment profiles possible for the subject's randomized arm.
    The potential censoring time must be specified both for censored
    and uncensored subjects.

{p 8 8 8}Censoring due to random events (e.g. competing risk or loss to follow-up)
    should ideally be treated differently from censoring at end of study.
    However, if small amounts of random censoring are present, a reasonable
    approximation is to set the potential censoring time for subjects who are
    randomly censored equal to the actual time of random censoring.

{phang}{cmd:psimult(}{it:exp}{cmd:)} allows the acceleration factor to vary between individuals.
Specifying {cmd:psimult(k)}, for example, specifies that the log acceleration factor
is psi*k where psi is to be estimated. 
If k is a variable then this allows the acceleration factor to vary between individuals.
This option is typically used to assess sensitivity to departures from the common treatment effect assumption:
for example, to fit the model with the effect of treatment 30% smaller in the control arm, 
you would specify {cmd:psimult(k)} where {cmd:k} is 1 in the experimental arm and 0.7 in the control arm.


{title:Options to specify the estimator (estimation syntax)}{marker opts_estimator}

{phang}{cmd:test(}{it:sts_test_option}|{cmdab:stc:ox}|{cmdab:cox}|{it:streg_dist}{cmd:)} 
specifies the test used
to compare the underlying event time U between the two randomized arms. 
{cmd:test(}{it:sts_test_option}{cmd:)} uses {help sts test} with the given option: for example, the commonest choice {cmd:test(logrank)} uses {cmd:sts test}{it: treatvar}{cmd:, logrank}.
{cmd:test(}{it:streg_dist}{cmd:)} uses the Wald test from {help streg} with the specified distribution: for example, {cmd:test(weibull)} uses {cmd:streg}{it: treatvar}{cmd:, dist(weibull)}.
{cmd:test(}{cmdab:stc:ox}|{cmdab:cox}{cmd:)} uses the Wald test from {help stcox}.
The default is the logrank test (or the weibull test if {cmd:ipe} is specified).

{phang}{cmdab:adj:vars(}{it:varlist}{cmd:)} modifies 
regression-based tests (that is, using {cmd:test(}{it:streg_dist}{cmd:)} or 
{cmd:test(}{cmdab:stc:ox}|{cmdab:cox}{cmd:)} by 
adjusting for the specified variables.

{phang}{cmdab:st:rata(}{it:varlist}{cmd:)} requests the tests to be stratified by the specified variables.

{phang}{cmd:ipe} invokes {help strbee##BW02:Branson and Whitehead}'s Iterative Parameter Estimation (IPE). 
This uses a parametric accelerated life model and estimates the parameter psi by iteratively comparing the counterfactual survival times of arm 1 if completely treated with those of arm 0 if completely untreated. 
{cmd:test(weibull}|{cmd:exponential)} is required.
Note that the standard error and confidence interval from this method do not allow for all the  uncertainty, and bootstrap methods are preferable. 

{phang}{cmd:ipecens} modifies IPE to use {help strbee##BW02:Branson and Whitehead}'s procedure for recensoring. The standard Robins-Tsiatis recensoring procedure is preferable {help strbee##White06:(White, 2006)} and is used by default. 



{title:Options to specify the search procedure (estimation syntax)}{marker opts_search}

{phang}{cmd:psimin(}#{cmd:)} and {cmd:psimax(}#{cmd:)}: with the estimation syntax, these specify the extreme permitted values of the parameter psi.
    Defaults are -10 and 10. 
With the replay syntax, they instead affect the {cmd:zgraph} - see {help strbee##opts_output:options controlling output}.

{phang}{cmd:psistep(}#{cmd:)} with #>0 specifies the step size between the extreme values for
    a grid search, while
    {cmd:psistep(0)} (the default) specifies an {help strbee##bisection:interval-bisection approach} for psi. 

{phang}{cmd:tol(}#{cmd:)} specifies the convergence criterion for interval-bisection
    estimation. {cmd:strbee} searches until bounds for each solution differ by
    less than 10{cmd:}(-tol). {cmd:tol()} also defines the number of decimal places
    reported.  The default is {cmd:tol(3)}.

{phang}{cmd:noci} suppresses searching for the confidence limits. {cmd:strbee} still reports
    what limited information it has about them.

{phang}{cmd:level(}#{cmd:)} specifies searching the confidence interval, in percent, for
    confidence intervals.  The default is {cmd:level(95)} or as set by {cmd:set}
    {cmd:level}; see {help level}.

{phang}{cmd:trace} gives details on recensoring and prints psi and the test statistic at
    each step. It also saves a file {cmd:rbeetrace.dta} containing variables {cmd:u},
    {cmd:du}, {cmd:z0}, {cmd:dz0}, {cmd:z1}, {cmd:dz1}, and {cmd:recens} evaluated at the last value
    of psi used.  Note that with grid search this is the value of {cmd:psimax()},
    and with interval-bisection search it is the upper confidence limit
    without {cmd:noci} or the point estimate with {cmd:noci}.

{phang}{cmd:psistart(#)} specifies a starting value for the IPE method. Default is 0.

{phang}{cmd:maxiter(#)} limits the number of iterations for the IPE method. Default is 100.



{title:Options controlling storage of results (estimation syntax)}{marker opts_storage}

{phang}{cmd:savedta(}filename[{cmd:,append}|{cmd:replace}]{cmd:)} directs the values of psi and the test statistic to the specified file which can later be used with the replay syntax.
If {cmd:append} is specified, {cmd:strbee} checks that the current test statistics
and the stored test statistics were computed using the same model. In this
case, the results reported only use test statistics computed in this run of
{cmd:strbee}: to get full results, run {cmd:strbee using} filename.
If {cmd:savedta()} is omitted then results are stored in _strbee_results.dta.

{phang}{cmd:ipestore(}{it:name}{cmd:)} stores the last model fit in the IPE algorithm. It can later be retrieved using {help estimates store} {it:name}.



{title:Options controlling output (both syntaxes)}{marker opts_output}

{phang}{cmd:list} lists the values of psi and the test statistic.

{phang}
    {cmdab:zgr:aph}[{cmd:(}{it:graph_options}{cmd:)}]
graphs the test statistic Z against psi. 
{it:graph_options} are most of the options allowed with {cmd:graph, twoway}; see {help graph}. 

{phang}{cmd:psimin(}#{cmd:)} and {cmd:psimax(}#{cmd:)}: with the replay syntax only, these control the values plotted on the graph, if {cmd:zgraph} is specified.

{phang}{cmd:hr} outputs the estimated hazard ratio comparing arm 1 if always 
treated with arm 0 if never treated. 
A test-based confidence interval is given. 
For details, see {help strbee##White++99:White et al (1999)}. 

{phang}
{cmdab:km:graph}[{cmd:(}{it:suboptions}{cmd:)}] 
draws the Kaplan-Meier graph for the observed event times 
and also, for each arm with switches, the counterfactual event times 
if that arm had never received treatment 
and if that arm had always received treatment.

{pmore}Possible {it:suboptions} are:

{pmore}most of the options allowed with {cmd:sts graph}; see {help sts graph}. 

{pmore}{cmdab:showa:ll} causes all six graphs to be drawn, even when one arm has no switches.

{pmore}{cmdab:untr:eated} causes only the two graphs for the counterfactual untreated event times to be drawn.

{pmore}{cmdab:lp:atterns(}{it:pattern1 pattern2}{cmd:)} lists the line patterns 
for the control arm (default: dash) and then the treatment arm (default: solid).

{pmore}{cmdab:lc:olors(}{it:color1 color2 color3}{cmd:)} lists the line colours 
for the observed data (default: black), 
then the counterfactual untreated data (default: orange),
and then the counterfactual fully treated data (default: blue).

{phang}
{cmd:gen(}{it:newvarname}{cmd:)} generates 
a new variable {it:newvarname} containing the values of the counterfactual untreated outcome;
a new variable d{it:newvarname} containing the event indicator for {it:newvarname};
and if {cmd:endstudy(}{cmd:)} is specified, a new variable c{it:newvarname} containing the censoring time of {it:newvarname}.

{pmore}
With the IPE method, {it:newvarname} is instead the ideal outcome, defined as the counterfactual untreated outcome in arm 0 and the counterfactual fully-treated outcome in arm 1.



{title:Changes from version 1.2 to version 1.5}{marker whatsnew15}

{phang}Main new options: 
{cmd:hr}  
{cmd:adjvars()} 
{cmd:kmgraph(}{cmd:)}
{cmd:gen()}.

{phang}{cmd:ipe}, formerly an undocumented option, is now fully documented.

{phang}{cmd:psimin()} and {cmd:psimax()} are now unlikely to be needed, 
since by default the search for suitable parameter values starts with the range -1 to 1, 
but is extended as far as necessary towards -10 and 10. 

{phang}The replay syntax is new. 

{phang}Some bugs have been fixed, including: 
switch times greater than event times are now handled correctly;
test(wilcoxon) now works correctly.

{phang}{cmd:graph} has been renamed {cmd:zgraph}, but the former syntax is still allowed.

{phang}Graphs use the improved graphics introduced in Stata 8.



{title:Changes from version 1.5 to version 1.8}{marker whatsnew18}

{phang}Main new options: 
{cmd:strata()}
{cmd:ton()}
{cmd:toff()}.

{phang}More tests available: almost everything available with {help sts test} or {help streg}.

{phang}New options for {cmd:kmgraph}.



{title:Estimation by interval bisection}{marker bisection}

{phang}1.  An initial interval is found by searching for two values of psi with Z(psi) above the upper critical value (1.96 with 5% significance level) and below the lower critical value.

{phang}2.  A value of psi solving Z(psi)=0 is found by evaluating Z(psi) at the midpoint of the interval, narrowing psi down to the appropriate half of the interval, and repeating until the desired accuracy is achieved.

{phang}3.  Value of psi solving Z(psi)= the lower and upper critical values are found similarly.

{phang}    Interval bisection may give wrong answers if the test statistic is
    nondecreasing in psi, and should always be checked using the {cmd:zgraph}
    option.



{title:Examples}{marker examples}

{pstd}Example using simulated data of immediate vs. deferred treatment:

        {com}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/noncomp/immdef.dta, clear"}
        {com}. {stata stset progyrs prog}{txt}

{pstd}Intention-to-treat analysis

        {com}. {stata strbee imm}{txt}

{pstd}RBEE analysis without recensoring

        {com}. {stata strbee imm, xo0(xoyrs xo)}{txt}

{pstd}RBEE analysis with recensoring

        {com}. {stata strbee imm, xo0(xoyrs xo) endstudy(censyrs) savedta(recens)}{txt}

{pstd}Grid search to check for multiple axis-crossings

{phang2}{com}. {stata strbee imm, xo0(xoyrs xo) endstudy(censyrs) savedta(recens,append) psimin(-0.5) psimax(0.1) psistep(0.02) zgraph(title(RBEE with recensoring))}{txt}

{pstd}Hazard-based interpretation of results

        {com}. {stata strbee using recens, hr kmgraph}{txt}

{pstd}The same using the ton() syntax

        {com}. {stata gen ton = progyrs if imm}{txt}
        {com}. {stata replace ton = progyrs - xoyrs if !imm & xo}{txt}
        {com}. {stata replace ton = 0 if !imm & !xo}{txt}
        {com}. {stata strbee imm, ton(ton) endstudy(censyrs)}{txt}



{title:Troubleshooting}{marker troubleshooting}

{phang}If you run into trouble, try the following:

{phang}1. Use the {cmd:trace} option to see what values of psi are being considered and how much recensoring is occurring.

{phang}2. Use the {cmd:zgraph} option to inspect the graph of Z(psi) against psi. Ideally it should start above 1.96 (or other critical value if used) and descend to below -1.96 as psi increases.

{phang}3. Use grid search instead of interval bisection.

{phang}4. Try updating the software (see below).

{phang}If all else fails, feel free to email me, ian.white@ucl.ac.uk, sending me a log file showing your problem. 
The log file should include at least {cmd:which strbee}, a summary of your data and an {cmd:strbee} call with the trace option. 
It's very helpful if you can also send me some data to illustrate your problem.



{title:Updates}{marker updates}

{phang}I put updates from time to time on my website.
You can install them using 
{stata "net install http://www.homepages.ucl.ac.uk/~rmjwiww/stata/noncomp/strbee, replace"}.



{title:Technical notes}{marker technotes}

{phang}{cmd:strbee} is an r-class command. 
Typed without options (or with only output options), it should redisplay the latest results provided no later  r-class command has been run.

{phang}Results for psi and Z(psi) are saved in the file specified by {cmd:savedta()} or else in _strbee_results.dta. 
This file contains details of the original data set as {help char:characteristics}.
If results are appended to this file then {cmd:strbee} checks that the characteristics match.



{title:Limitations}{marker limitations}

{phang}. Censored switches occurring before the event are assumed to represent no switch.{p_end}
{phang}. Switches occurring after the event are censored at the event time.{p_end}
{phang}. Only two-arm trials are allowed.{p_end}
{phang}. Treatment at any time must be yes/no, so that it can be summarised by the total time on or off treatment. Thus varying doses can not be allowed for in {cmd:strbee}, though the RPSFTM does allow for them.{p_end}



{title:References}{marker refs}

{phang}{marker BW02}Branson M, Whitehead J (2002). Estimating a treatment effect in survival studies in which patients switch treatment. Statistics in Medicine 21: 2449-2463.

{phang}{marker RT91}Robins JM, Tsiatis AA (1991). Correcting for non-compliance in randomized trials using rank preserving structural failure time models. Communications in Statistics - Theory and Methods 20: 2609-2631.

{phang}{marker White++02}White IR, Walker S, Babiker A (2002). strbee: Randomisation-based efficacy estimator. Stata Journal 2: 140-150.

{phang}{marker White++99}White IR, Babiker AG, Walker S, Darbyshire JH (1999). Randomisation-based methods for correcting for treatment changes: examples from the Concorde trial. Statistics in Medicine 18: 2617-2634.

{phang}{marker White06}White IR (2006).
Estimating treatment effects in randomised trials with treatment switching.
Statistics in Medicine 25: 1619-1622.       



{title:Authors}

  Ian R. White
  MRC Clinical Trials Unit at UCL, London, UK
  ian.white@ucl.ac.uk

  Sarah Walker
  MRC Clinical Trials Unit at UCL, London, UK

  Abdel Babiker
  MRC Clinical Trials Unit at UCL, London, UK

