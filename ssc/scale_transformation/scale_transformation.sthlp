{smcl}
{* *! version 1.0 12dec2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "scale_transformationfile##syntax"}{...}
{viewerjumpto "Description" "scale_transformationfile##description"}{...}
{viewerjumpto "Options" "scale_transformationfile##options"}{...}
{viewerjumpto "References" "scale_transformationfile##references"}{...}
{viewerjumpto "Examples" "scale_transformationfile##examples"}{...}
{viewerjumpto "Author" "scale_transformationfile##author"}{...}
{title:Title}

{phang}
{bf:scale_transformation} {hline 1} Finds a 6th-degree monotonic polynomial transformation 
for a test score scale, which optimizes a specific objective function (see Description section for details). 
The optimization object includes scores at two points of time (e.g. year 1 and 2) and two comparison groups (e.g. male vs female). 
This program uses the Stata mata function {manhelp optimize M-5} to perform a grid search from multiple random initial 
parameters to find the desired values. The main use of this program is to estimate the maximum and minimum gap difference for an (ordinal) test score scale 
between two groups across two points of time. Other optimization objects (i.e. correlation, R-squared and controls) are available to run robustness checks.
{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:scale_transformation}
{cmd:,} {it:options}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main (Required)}

{synopt:{opt t:ype(integer)}}indicates the type of optimization (i.e. max or min) 
		to be performed as well as the objective function (i.e. Gap Growth, 
		Correlation, R-squared, or Controls Explanation - see details below).{p_end}
{synopt:{opt score1(varname)}}numeric variable that contains test scores at (initial) period 1.{p_end}
{synopt:{opt score2(varname)}}numeric variable that contains test scores at (final) period 2.{p_end}

{syntab:Secondary (Optional)}

{synopt:{opt compg:roup(varname)}}numeric variable that contains a group classification; {bf: required} if type 
		is 1, 2 or 7 only.{p_end}
{synopt:{opt cont:rols(varlist)}}include varlist as controls at BOTH periods 1 and 2.{p_end}
{synopt:{opt controls1(varlist)}}include varlist as controls at period 1 ONLY.{p_end}
{synopt:{opt controls2(varlist)}}include varlist as controls at period 2 ONLY.{p_end}
{synopt:{opt w:eights(varname)}}uses varname as inverse probability weights.{p_end}
{synopt:{opt iter:ations(integer)}}specifies number of times that the program will find optimal values 
		using unique random-generated initial parameters; 
		default is {cmd:iterations(1000)}.{p_end}
{synopt:{opt maxoptiter:ations(integer)}}specifies maximum number of iterations before 
		each optimization stops and return results as if convergence was achieved; 
		default is {cmd:maxoptiterations(25)}; see {manhelp mf_optimize##i_maxiter M-5}.{p_end}
{synopt:{opt singhmet:hod(integer)}}specifies what the optimizer should do when, at an iteration 
		step, it finds that H is singular; default is {cmd:singhmethod(1)} for "hybrid"; 
		see {manhelp mf_optimize##i_singularH M-5}.{p_end}
{synopt:{opt boundd:own(integer)}}specifies lower bound for the random-generated initial 
		parameters for the optimization; default is {cmd:bounddown(-1500)}.{p_end}
{synopt:{opt boundu:p(integer)}}specifies upper bound for the random-generated initial 
		parameters for the optimization; default is {cmd:boundup(1500)}.{p_end}
{synopt:{opt mono:tonicity(integer)}}specifies the type of monotonicity check to be 
		applied; default is {cmd:monotonicity(1)} for "Standard" - see below for details.{p_end}
{synopt:{opt monofile(filename)}}specifies the file to be used when monotonicity 
		type is set to "External"; should only be used with monotonicity(3).{p_end}
{synopt:{opt timeroff}}turn off the timer; default is set to include timer.{p_end}
{synopt:{opt save(filename)}}save optimization results using filename once program is done.{p_end}
{synopt:{opt seed(integer)}}set seed for replication.{p_end}
{synopt:{opt robust(integer)}}activates option to use first {it:K} iterations (in addition to 
N specified by {it:iterations}) to check for a possible change of sign in Max/Min Gap Growth optimizations.{p_end}
		
{synoptline}
{p2colreset}{...}



{marker description}{...}
{title:Description}

{pstd}
{cmd:scale_transformation} finds a 6th degree polynomial monotonic transformation for a test score scale
that optimizes one of the following:{p_end}

{phang}a) {ul on}{bf:Gap Growth}{ul off}: gap difference between the bottom and top groups from the compgroup variable in period 2, minus the same gap difference in period 1. In other words,
it is the difference between the regression coefficient of the top compgroup indicator (controlling for groups in the middle) in period 2, MINUS the same regression coefficient 
of the top compgroup indicator (also controlling for other groups in the middle) in period 1. In both, the coefficient of the top compgroup indicator measures the difference between the top and bottom groups.
Note that the Gap Growth is positive when the Gap widens and negative when the Gap shrinks. Thus, the Gap Growth will always be negative when the coefficient changes 
signs between period 1 and 2 (regardless of whether it is from + to -, or from - to +). Conversely, it will be positive when the gap widens, for instance, from -.1 to -.3;{p_end}
{phang}b) {ul on}{bf:Correlation}{ul off}: coefficient from regressing test scores from period 1 on test scores from period 2 (no controls allowed);{p_end}
{phang}c) {ul on}{bf:R-squared}{ul off}: from regressing test scores from period 1 on test scores from period 2 (no controls allowed); or{p_end}
{phang}d) {ul on}{bf:Controls Explanation}{ul off}: measures how much Gap Growth coefficients change when including controls in 
{it:{bf:controls1}(varlist)} and {it:{bf:controls2}(varlist)} - {bf:NOT} in {it:{bf:controls}(varlist)}. This allows to test the explanatory 
power of only a subset of desired control variables. That means that, if you want to measure how much Gap Growth coefficients change by 
introducing time-invariant controls, you must include these variables in {ul on}both{ul off} {it:{bf:controls1}(varlist)} and {it:{bf:controls2}(varlist)}.
The Controls Explanation term is estimated by taking the distance (i.e. absolute value of the difference) between the Gap Growth calculated without variables included in 
controls1 and constrols2, minus the Gap Growth calculated with these two controls varlists. To make the interpretation easier, both Gap Growths coefficients - with and without
controls - are included in the results.{p_end}

{pstd}The {ul on}{bf:scale_transformation}{ul off} command is designed to verify the robustness of your results by finding plausible 
test score scale transformations that maximize or minimize one of the above using a dataset in wide-format (i.e. one observation per row). 
All the transformations found by this command are theoretically possible given the ordinal nature of test scores. Thus, the command helps to
verify that any results you obtained by comparing test scores using panel data (and potentially across different groups)
are robust to any arbitrary choice of scale by finding bounds for your estimations.

{pstd}The methodology was originally developed in the  {ul on}{bf:Bond and Lang (2013)}{ul off} {it: RESTAT} paper, which also explains more in detail 
the challenges posed by the ordinal nature of test scores and choice of scale. The current program builds on this 
methodology, adjusts coefficient signs to allow for more flexibility, includes one more coefficient in the calculations and makes the optimization process more efficient, 
precise and accessible.{p_end}

{pstd}A 6th-degree polynomial monotonic transformation is used because it provides flexibility to approach numerous continuous functions.
Nevertheless, a monotonicity checks needs to be applied to these transformations. These two characteristics yield a very complex optimization 
problem that does not have a closed form solution. Furthermore, the monotonicity restriction introduces a discontinuity into the objective 
function that creates multiple local maxima and minima. Considering all the above, this program takes advantage of the mata {manhelp optimize M-5} function and
performs a grid search to find multiple solutions from several different initial parameters. The results are reported in a dataset format that
includes the values of the evaluated objective functions, the resulting parameters of each optimization iteration and the initial parameters 
that yielded that result.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main (Required)}

{phang}
{opt t:ype(integer)} indicates the type of optimization and the objective function to be performed. The options are as follows:{p_end}

		1. Gap Growth Maximization
		2. Gap Growth Minimization
		3. Correlation Maximization
		4. Correlation Minimization
		5. R-squared Maximization
		6. R-squared Minimization
		7. Controls Explanation Maximization

{phang}
{opt score1(varname)} specifies the variable that contains scores at (initial) period 1. In order to 
improve processing speed, this variable is automatically scaled to be between 0 and 1 prior to running the program. 
The transformation used for this process is the same for variables {it:score1} and {it:score2}, and does not affect
the resulting estimations in any way.

{phang}
{opt score2(varname)} specifies the variable that contains scores at (final) period 2. In order to 
improve processing speed, this variable is automatically scaled to be between 0 and 1 prior to running the program. 
The transformation used for this process is the same for variables {it:score1} and {it:score2}, and does not affect
the resulting estimations in any way.


{dlgtab:Secondary (Optional)}

{phang}
{opt compg:roup(varname)} specifies the variable that contains the group classification to be analyzed
and from which the program will compare the top and bottom groups. This variable 
needs to be numeric. The program will take the lowest and highest values (i.e. groups) and compare them, 
while controlling for all other groups in the middle at the same time. Note that the variable compgroup 
should only take on integers greater or equal to 0 (all missings will be ignored). Only allowed 
when optimizing Gap Growth or Controls Explanation (i.e. type 1, 2 or 7).

{phang}
{opt cont:rols(varlist)} include varlist as controls at BOTH period 1 and 2. Variables should be numeric as they 
will be used directly in regressions. Only allowed when optimizing Gap Growth or Controls Explanation (i.e. type 1, 2 or 7).

{phang}
{opt controls1(varlist)} include varlist as controls at period 1 ONLY. Variables should be numeric as they 
will be used directly in regressions. Only allowed when optimizing Gap Growth or Controls Explanation (i.e. type 1, 2 or 7). 

{phang}
{opt controls2(varlist)} include varlist as controls at period 2 ONLY. Variables should be numeric as they 
will be used directly in regressions. Only allowed when optimizing Gap Growth or Controls Explanation (i.e. type 1, 2 or 7).

{phang}
{opt w:eights(varname)} uses varname as inverse probability weights. If not specified, weights are set to 1.

{phang}
{opt iter:ations(integer)} specifies number of times that the program will find optimal values using unique 
random-generated initial parameters. The default is set to {cmd:iterations(1000)}. The more iterations,
the longer it will take the program to run and finish. Note that by default, if the program is stopped before 
ending, the results will not be stored. It is recommended that you test your program with a low number of iterations. 
		
{phang}
{opt maxoptiter:ations(integer)} specifies maximum number of iterations before the optimization program stops 
and return results as if convergence was achieved. The default is set to {cmd:maxoptiterations(25)}, which in
practice should be enough to achieve 'convergence' with a fair degree of accuracy. This limit is necessary as
the monotonicity restriction and complexity of the objective functions cause the optimization program to run indefinitely otherwise.
See {manhelp mf_optimize##i_maxiter M-5} for more details.
		
{phang}
{opt singhmet:hod(integer)} specifies what the optimizer should do when, at an iteration step, it finds that H is singular.
The default is set to {cmd:singhmethod(1)} for "hybrid" but can be changed to 2 for "modified Marquardt algorithm".
See {manhelp mf_optimize##i_singularH M-5} for more details.
		
{phang}
{opt boundd:own(integer)} specifies lower bound for the random-generated initial parameters for the optimization. This program
creates random initial values and then uses them to find all the different local maxima or minima, accordingly. The default is
set to {cmd:bounddown(-1500)}.
		
{phang}
{opt boundu:p(integer)} specifies upper bound for the random-generated initial parameters for the optimization. This program
creates random initial values and then uses them to find all the different local maxima or minima accordingly. The default is
set to {cmd:boundup(1500)}.
		
{phang}
{opt mono:tonicity(integer)} specifies the type of monotonicity check to be applied. The default is set to {opt monotonicity(1)} 
for {bf:"Standard"}, which checks for monotonicity at every possible score value (up to 4 decimals within the plausible range) in the original scale that was 
transformed to be between 0 and 1. When less precision is needed, monotonicity can be set to {cmd:2} for {bf:"Sample"}, which only checks for monotonicity at the unique
scores values present in the sample data. If the test scores come from a larger dataset that have scores for multiple years, it is possible to do a more 
thorough check (but more time consuming) by putting together an external file with all theoretical or observed plausible scores where you want the
program to check for monotonicity. For the latter, you must set monotonicity to {cmd:3} for {bf:"External"} and include the filename in {opt monofile(filename)}.  
		
{phang}
{opt monofile(filename)} specifies the file to be used when monotonicity type is set to {cmd:3} for {bf:"External"}. This
option should only be used with {cmd:monotonicity(3)}. You can use .dta, .csv, .xls or .xlsx files. Make sure that .csv, 
.xls and .xlsx files have the name of the variable on the first row.
		
{phang}
{opt timeroff} turn off the timer. The default is set to include the time (in minutes) that the program took to run, which 
is reported only if the program finishes.

{phang}
{opt save(filename)} save optimization results using {it:filename} once program is done. 

{phang}
{opt seed(integer)} set seed for replication, where {it:0 <= integer <= 2,147,483,647}. If missing, the seed is randomly generated and included in the header of the program. 
Always save the log file to ensure you are able to recover the seed number for replication.

{phang}
{opt robust(integer)} Since the optimization problem for the Max/Min Gap Growth options (i.e. type 1 or 2) is complex and does not have a closed-solution, 
in some specific cases the maximization could yield the solutions for the minimization problem (and vice versa). In order to address this issue, the user could  
activate the {it:robust} option to use the first {it:K=integer (where 20<=K<=300; K=even)} iterations (in addition to N specified by the {it:iterations} option) 
to check for a possible change of sign in Max/Min Gap Growth optimization results. Half of the {it:K} iterations are used to find the maximization solution while
the other half {it:K} iterations are used for the minimization problem. Once the correct approach is selected, the program keeps the solutions for the correct specification
and runs the remaining N iterations indicated in the {opt iterations()} option.{p_end}
		


{marker references}{...}
{title:References}

{pstd}
{it: Bond, T. N., & Lang, K. (2013)}. The evolution of the Black-White test score gap in grades K–3: The fragility of results. Review of Economics and Statistics, 95, 1468–1479. doi:10.1162/REST_a_00370


{marker examples}{...}
{title:Examples}

{pstd}
Gap Growth maximization between scores in year 1 and 2 by comparing males vs females: {p_end}

{phang}{cmd:. sysuse timss_testscores.dta, clear}{p_end}

{phang}{cmd:. scale_transformation, type(1) score1(score1) score2(score2) /// }{p_end}
{phang}{cmd:     compgroup(sex) iterations(20) maxoptiterations(15) mono(2) /// }{p_end}
{phang}{cmd:     seed(562) robust(20) }{p_end}


{pstd}
Note that, given the above command, the program will run 40 times from different initial parameters and each time, the program will 
report convergence after 15 iterations, performing a "Sample" monotonicity check. Given the option {opt robust(20)}, the program will 
use the first 20 simulations to check that the sign of the gap is correct by carrying out 10 maximizations and 10 minimizations. 
Once the correct direction is confirmed, the correct half is kept and the other discarded. Thus, in this example, the resulting dataset 
will contain only 30 observations.
{p_end}

{marker author}{...}
{title:Author}

{pstd}Andres Yi Chang{p_end}
{pstd}andresyichang@gmail.com{p_end}
