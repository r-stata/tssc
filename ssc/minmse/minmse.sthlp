{smcl}
{* *! version1.0.0    2021/04/22}{...}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "minmse##syntax"}{...}
{viewerjumpto "Description" "minmse##description"}{...}
{viewerjumpto "Options" "minmse##options"}{...}
{viewerjumpto "Remarks" "minmse##remarks"}{...}
{viewerjumpto "Examples" "minmse##examples"}{...}
{viewerjumpto "Author" "minmse##author"}{...}
{viewerjumpto "References" "minmse##references"}{...}
{title:Title}
{phang}
{bf:minmse} {hline 2} create balanced groups for treatment in experiments with one or several treatment arms based on (possibly continuous and multiple) variables specified by the user according to the MinMSE Treatment Assignment Method (Schneider & Schlather, 2017)


{marker syntax}{...}
{title:Syntax}
{p 8 17 2} 
{cmd:minmse}
[{varlist}],
{opth gen:erate(newvar)}
[{it:options}]

{phang}
where {varlist} contains the covariate input (missing values are automatically replaced by a variable's mean), and {newvar} is the name of the variable to be created containing treatment group number(s).

{phang}
Any of the following options might be specified:

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt t:reatments(#)}}number of treatment groups that you want to have additional to the control group; default is {cmd:treatments(1)}.{p_end}
{synopt:{opt i:terations(#)}}number of iterations that you want the algorithm to perform; default is {cmd:iterations(50)}.{p_end}
{synopt:{opth a:ssignment(varname)}}takes a numerical vector of partial treatment assignment as argument, and assigns the missing units (where {varname} == .) to a treatment group while minimizing the objective function.{p_end}
{syntab:Options for Controlling the Optimization Procedure (Simulated Annealing)}
{synopt:{opt c:hange(#)}}how many units should exchange treatment in each iteration; default is {cmd:change(3)}.{p_end}
{synopt:{opt cool:ing(#)}}specify the cooling scheme for the simulated annealing algorithm to use, see details below; default is {cmd:cooling(1)}.{p_end}
{synopt:{opt t:0(#)}}specify the starting temperature for the minimization algorithm, see details below; default is {cmd:t0(10)}.{p_end}
{synopt:{opt tm:ax(#)}}specify the number of function evaluations at each temperature for the minimization algorithm; default is {cmd:tmax(10)}.{p_end}
{syntab:Plot}
{synopt:{opt p:lot(#)}}supress drawing a plot showing the value of the objective function for the last iterations by setting {cmd:plot(0)}; default is {cmd:plot(1)}, which shows a plot.{p_end}
{* *! {synopt:{opt option}}brief  description  of  option{p_end}}{...}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}
{pstd}
{cmd:minmse} performs treatment assignment for (field) experiments based on pre-treatment information, i.e., it assigns treatment group number(s) to observations based on covariates specified by the user. {...}
It is suited for experiments with one or several treatment groups. The created treatment groups are balanced with respect to the specified covariates according to the minMSE method proposed by Schneider and Schlather (2017); the package implements their treatment assignment method (based on work by Kasy, 2016). Pre-treatment information to be considered can be continuous and multivariate (i.e., several variables). {...}
Optimization is performed using the stochastic simulated annealing algorithm (Kirkpatrick, Gelatt, and Vecchi, 1983).

{marker options}{...}
{title:Options}
{dlgtab:Main}
{* *!{phang}}{...}
{* *!{opt optionname}option  description}{...}
{...}
{* *!{pmore}continued  option  description,  if  necessary}{...}
{...}
{* *!{phang}}{...}
{* *!{opt optionname}second  option  description}{...}
{...}
{phang}
{opt treatments(#)} Specifies the number of treatment groups desired (in addition to the control group); minimum and default value is {cmd:treatments(1)}.

{phang}
{opt iterations(#)} specifies the number of iterations the algorithm performs; the default value is {cmd:iterations(50)}.
With small samples and few covariates, depending on the desired method of inference, a relatively small value is recommended, see {help minmse##remarks:Remarks} for details.
Depending on the number of units and the number of covariates to consider for group assignment, a high value could result in a long run-time.

{phang}
{opth assignment(varname)} 
Takes a numerical vector of partial treatment assignment as argument, and assigns the missing units (where {it:varname} == .) to a treatment group while minimizing the objective function.
Non-missing values are copied to the new vector, i.e., treatment group assignment of these observations is unaffected.

{pmore} This option is helpful for, e.g., sequential treatment assignment over several days, or to cope with attrition in an experiment implemented over several days.
For example, before implementing treatment on the second day of an experiment, one might want to readjust balance for attrition on the first day.
Thus, one would create a vector with the number of treatment of the units where treatment was already implemented, and set the value to missing for the remaining ones.
(The subjects that left the experiment can be deleted from the dataset used for treatment assignment.)
Given a vector as just described, the command assigns treatment to the the missing units (where {it:varname} == .).
The goal is to minimize the objective function, where group assignment for units that already received treatment is held constant.

{dlgtab:Controlling the Optimization Procedure (Simulated Annealing)}
{phang} The following options control the minimization process performed by the simulated annealing algorithm.
The {cmd:plot} option might be useful for adjusting these parameters.
Default values correspond to the default values applied in the {it:R} implementation of simulated annealing (in the command {cmd:optim}), and, especially the default value for {cmd:t0} is likely too small for many applications, see below. 

{phang}
{opt change(#)} is a control parameter of the simulated annealing algorithm minimizing the objective function.
It specifies how many units should exchange treatment in each iteration.
In case of big datasets (with more than 100 units), one might consider increasing the default value.

{phang}
{opt cooling(#)} specifies the cooling scheme to be used for the simulated annealing algorithm.

{pmore}{cmd:cooling(1)}, which is default, sets the temperature to{p_end}
		{center:{bind:{it:t_0} / {cmd:ln(floor(}({it:k-1})/{it:t_max}{cmd:)} * {it:t_max} + {cmd:exp(}1{cmd:))},}}

{pmore}
whereas {cmd:cooling(2)} sets the temperature to the faster decreasing sequence{p_end}
		{center:{bind:{it:t_0} / ({cmd:floor(}({it:k-1}) / {it:t_max}{cmd:)} * {it:t_max} + 1).}}

{pmore}
In practice, cooling schemes are mostly of one of these forms.
Users may want to change the cooling scheme if the plot indicates a too slow deacrease of objective values.
For a theoretical discussion of cooling schemes see Belisle (1992, p. 890). 
The default cooling scheme (scheme 1) is the same as for the {it:R} implementation of {cmd:optim}.

{phang}
{opt t0(#)} sets the starting temperature for the minimization algorithm, see Belisle (1992) for theoretical convergence considerations.
In practice, a lower starting temperature {it:t_0} decreases the acceptance rate of a worse solution more rapidly.

{pmore} Specifying a negative number allows values proportional to the objective function, which we recommend. 
That is: Specifying {cmd:t0(-5)} sets the starting temperature to 1/5 of the objective function for the starting point.
Thus, for the first {it:t_max} iterations of the algorithm, the difference of the old and the proposed solution is scaled by 1/5.

{pmore} When changing the default value, it should be considered that also worse solutions have to be accepted in order for the algorithm to escape a local minimum.
Thus, it should be chosen high enough. 
Default value ({cmd:t0(10)}) is the same as for the {it:R} implementation of {cmd:optim}, and likely too small for many applications.

{phang}
{opt tmax(#)} specifies the number of function evaluations at each temperature: 
For instance, {cmd:tmax(10)} makes the algorithm evaluate 10 treatment assignments that are found based on the current solution, before the temperature is decreased and thus the probability of accepting a solution that is worse than the current one is decreased. Default value is the same as for the {it:R} implementation of {cmd:optim}.

{dlgtab:Plot}
{phang}
{opt plot(#)} can be used to suppress drawing a plot showing the value of the objective function for the last iterations by setting {cmd:plot(0)}. 
The default setting is {cmd:plot(1)}, which shows a plot. 
While the convergence plot is a helpful tool for setting the control parameters of the simulated annealing algorithm and for detecting convergence, it might be less interesting when
generating a big number of alternative treatment assignments, e.g., for performing Fisher's exact test for inference when analyzing the experiment.


{marker remarks}{...}
{title:Remarks}
{phang}
Note that the analysis of the data once the experiment has been conducted can be based on a different statistic than the one for which the MSE is to be minimized by the {cmd:minmse} command. Additional variables to the ones used for treatment assignment can also be included in the analysis.

{phang}The number of participants does not need to be even and no difficulties aries for uneven numbers of participants in a certain treatment group.

{phang}In case treatment is not implemented at the same time for all units and attrition is happening, the {cmd:assignment} option can be used for re-balancing the treatment groups, given the units and their treatment group for which treatment has already been implemented.

{phang}The command uses Stata's fast Mata language for computation, and provides a convenient single command line Stata interface for the user.

{phang}The minimization is performed by a combination of random draws for starting points and a variant of simulated annealing with default values as implemented in the {it:R} command {cmd:optim}; see details above.

{phang} 
Should the user wish to perform randomization inference after having conducted the experiment using, e.g., Fisher's exact test, they should make sure that the algorithm does not converge. Otherwise, one cannot compute the test statistic of interest in for different (hypothetical) treatment assignments, as applying the procedure various times always would lead to the same treatment assignment. Convergence can be checked for example by running the command several times with the same settings: If the program always yields the same treatment assignment, one might want to decrease the number of iterations, as the algorithm might have converged. {...} 

{phang}
Note that the {it:R} implementation of this package, available via {it:CRAN} (https://cran.r-project.org/package=minMSE), has several built-in features to facilitate picking appropriate optimization parameters as well as preparing randomization inference, by, e.g., plotting a convergence graph for a desired number of treatment assignment vectors, or by specifying the number of alternative treatment assignment vectors to be used for randomization inference, and by specifying the percentage of equal treatment assignment vectors this number of vectors, which determines the highest, theoretically achievable significance level using this approach. 


{marker examples}{...}
{title:Examples: Basic Treatment Assignment}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse auto}{p_end}

{pstd}Create a treatment and a control group, with group numbers to be stored in variable {it:Treatment}, where trunk size and weight should be balanced. The number of iterations is the default: 50{p_end}
{phang2}{cmd:. minmse trunk weight, gen(Treatment)}{p_end}

{pstd}Inspect the result{p_end}
{phang2}{cmd:. tabstat weight trunk, by(Treatment) stat(mean sd p(25) p(50) p(75) n) long col(stat)}{p_end}

{title:Examples: Improve Basic Treatment Assignment}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse auto}{p_end}

{pstd}Create a treatment and a control group, with group numbers to be stored in variable {it:Treatment_Improved}, where trunk size and weight should be balanced. Set the number of iterations to 500, use the second cooling scheme, set the starting temperature to 1/2 of the initial value of the objective function, and decrease the temperature every $20$ iterations.{p_end}
{phang2}{cmd:. minmse weight trunk, gen(Treatment_Improved) iterations(500) t0(-2) tmax(20) cooling(2)}{p_end}

{pstd}Inspect the result{p_end}
{phang2}{cmd:. tabstat weight trunk, by(Treatment_Improved) stat(mean sd min max n) long col(stat)}{p_end}

{title:Examples: Sequential Treatment Assignment/Correcting for Attrition}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse auto}{p_end}

{pstd}Perform initial treatment assignment as in the example above for half of the sample{p_end}
{phang2}{cmd:. minmse weight trunk, gen(treatmentDayOne) iterations(500) t0(-2) tmax(20) cooling(2)}{p_end}
{phang2}{cmd:. gen u = runiform()}{p_end}
{phang2}{cmd:. sort u, stable}{p_end}
{phang2}{cmd:. drop u}{p_end}
{phang2}{cmd:. replace treatmentDayOne = . if _n > _N/2}{p_end}

{pstd}To partially rebalance your treatment assigment, where the overall balance of trunk and weight should be achieved (across units that already have been assigned and potentially have been treated and those still to be treated) type{p_end}
{phang2}{cmd:. minmse weight trunk, gen(Treatment) assignment(treatmentDayOne) iterations(500) t0(-2) cooling(2)}{p_end}


{marker author}{...}
{title:Author}
{pstd}
Sebastian O. Schneider{break} 
Max Planck Institute for Research on Collective Goods, Bonn (Germany){break}
sschneider@coll.mpg.de{break}
http://sebastianoschneider.com{break}


{marker references}{...}
{title:References}
{phang} Belisle, C. J. P. 1992. "Convergence theorems for a class of simulated annealing algorithms on Rd." {it:Journal of Applied Probability} 29 (4): 885-895.{p_end}
{phang} Bertsimas, D., M. Johnson, and N. Kallus. 2015. "The power of optimization over randomization in designing experiments involving small samples." {it:Operations Research} 63 (4): 868-876.{p_end}
{phang} Kasy, M. 2016. "Why experimenters might not always want to randomize, and what they could do instead." {it:Political  Analysis} 24 (3): 324-338.{p_end}
{phang} Kirkpatrick, S., C. D. Gelatt, and M. P. Vecchi. 1983. "Optimization by simulated annealing." {it:Science} 220 4598): 671-680.{p_end}
{phang} Schneider, S. O., and M. Schlather. 2017. "A new approach to treatment assignment for one and multiple treatment groups." {it:Courant Research Centre: Poverty, Equity and Growth-Discussion Papers} 228.{p_end}
