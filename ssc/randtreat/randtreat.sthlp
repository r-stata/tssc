{smcl}
{* *! version 1.4 April 2017}{...}
{title:Title}

{p2colset 5 18 22 2}{...}
{p2col :{hi:randtreat} {hline 2}}Random treatment assignment and dealing with misfits{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:randtreat} {ifin} {cmd:,}
{opth generate(newvar)}
[{it:options}]
{p_end}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synoptset 20 tabbed}{...}
{syntab:{help randtreat##opt_treatvar:Treatment variable}}
{p2coldent:* {opth g:enerate(newvar)}} generate new treatment variable encoding treatment status{p_end}
{synopt:{opt replace}} replace treatment variable if {it:newvar} exists{p_end}
{synopt:{opt se:tseed(#)}} set random-number seed to replicate assignment; see {help set seed}{p_end}

{syntab:{help randtreat##opt_parameters:Assignment parameters}}
{synopt:{opth st:rata(varlist)}} list of variables for stratified treatment assignment{p_end}
{synopt:{opt mult:iple(integer)}} number of equal treatment groups; default is {cmd:multiple(2)}{p_end}
{synopt:{opt un:equal(fractions)}} fractions for unequal treatments (see {help randtreat##opt_unequal:below}); default is {cmd:unequal(1/2 1/2)}{p_end}
{synopt:{opt mi:sfits(method)}} specify a method to deal with "misfits" (see {help randtreat##opt_misfits:below}); {it:method} may be {cmd:missing} (default), {cmd:strata}, {cmd:global}, {cmd:wstrata} or {cmd:wglobal}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt generate(newvar)} is required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
The {cmd:randtreat} command performs random treatment assignment.
It's purpose is twofold: to easily randomize multiple, possibly unequal treatments across strata and to provide methods to deal with "misfits",
an issue first described by Bruhn and McKenzie (2011) and later generalized by Carril (2017).

{pstd}
The program presumes that the current dataset corresponds to units (e.g. individuals, firms, etc.) to be randomly allocated to treatment statuses.
When run, it creates a new variable encoding treatment status, which is randomly assigned.
The seed can be set with the {opt setseed} option, so the random assignment can be replicated.
The command defaults to two treatments, more equally proportioned treatments can be specified with the {opt multiple(integer)} option.
Alternatively, multiple treatments of unequal proportions can be specified with the {opt unequal(fraction)} option.
A stratified assignment can be performed using the {opt strata(varlist)} option.
If specified, the random assignment will be carried out for each stratum defined by the unique combinations of values of {it:varlist}.

{pstd}
Whenever the number of observations in a given stratum is not a multiple of the number of treatments or the least common multiple of the treatment fractions,
then that stratum is going to have {bf:misfits}, that is,
observations that can't be neatly distributed among the treatments.
When run, {cmd:randtreat} reports the number of misfits produced by the combination of assignment parameters and the current dataset.
Misfits are automatically marked with missing values in the treatment variable, but additionally {cmd:randtreat} provides several methods to deal with them.
The method can be specified with the {opt misfits()} option (see {help randtreat##opt_misfits:below}).

{marker options}{...}
{title:Options}

{marker opt_treatvar}{...}
{dlgtab:Treatment variable}

{phang}
{opt generate(newvar)} creates a new variable encoding randomly assigned treatment status. Treatment values are consecutive nonnegative integers.

{phang}
{opt replace} replaces the treatment {it:newvar} if it already exists.

{phang}
{opt setseed(#)} specifies the initial value of the random-number seed used to assign treatments.
It can be set so that the random treatment assignment can be replicated.
See {help set seed:set seed} for more information.


{marker opt_parameters}{...}
{dlgtab:Assignment parameters}

{phang}
{opth strata(varlist)} is used to perform a stratified allocation on the variables in {varlist}.
If specified, the random assignment will be carried out in each stratum identified by the unique combination of the {varlist} variables' values.
Notice that this option is almost identical to using {cmd:by} (see {manhelp by D}), except that the command is not independently run for the specified variables, because global existence of misfits across strata must be accounted for.

{phang}
{opt multiple(integer)} specifies the number of equally proportioned treatments to be assigned.
The default (and minimum) is {cmd:multiple(2)}, unless the {opt unequal()} option is specified, in which case this option is redundant and should not be specified (see below).

{phang}
{marker opt_unequal}{...}
{opt unequal(fractions)} is used to specify unequal treatment fractions.
Each fraction must be of the form a/b and must belong to (0,1).
Fractions must be separated by spaces and their sum must add up exactly to 1.

{pmore}
For example, {cmd:unequal(1/2 1/4 1/4)} will randomly assign half of the observations to the "control" group (assumed to correspond to the first fraction), and then divide evenly the rest of the observations into two treatments.
Notice that this option implicitly defines the number of treatments (e.g. 3), so when {opt unequal()} is used, {opt mult()} is redundant and should be avoided.

{phang}
{marker opt_misfits}{...}
{opt misfits(method)} specifies which method to use in order to deal with misfits.
More details on the internal workings of these methods are available in
{browse "https://www.researchgate.net/publication/292091060_Dealing_with_misfits_in_random_treatment_assignment":Carril (2017)}
or in my related {browse "http://alvarocarril.com/resources/randtreat":blog post}.
The available {it:method}s are:

{phang2}
{it: missing} is the default option and simply leaves misfit observations as missing values in the treatment variable, so the user can later deal with misfits as he sees fit.

{phang2}
{it: strata} randomly allocates misfits independently across all strata, without weighting treatments as specified in {opt unequal}.
This method prioritizes balance of misfits' treatment allocation within each stratum (they can't differ by more than 1), but may harm original treatment fractions if the number of misfits is large.

{phang2}
{it: global} randomly allocates all misfits globally, without weighting treatments as specified in {opt unequal}.
This method prioritizes global balance of misfits' treatment allocation (they can't differ by more than 1), but may harm original treatment fractions if the number of misfits is large.

{phang2}
{it: wstrata} randomly allocates misfits independently across all strata, weighting treatments as specified in {opt unequal}.
This ensures that the fractions specified in {bf:unequal()} affect the within-distribution of treatments among misfits, so overall balance of unequal treatments should be (almost) attained.
However, this method doesn't ensure the balance of misfits' treatment allocation within each stratum (they could differ by more than 1).

{phang2}
{it: wglobal} randomly allocates all misfits globally, weighting treatments as specified in {opt unequal}.
This ensures balance at the the global level and also respects unequal fractions of treatments, even when the number of misfits is large.
However, this method doesn't ensure the global balance of misfits' treatment allocation (they could differ by more than 1).
The downside is that this method could produce even greater unbalance at the finer level (in each stratum), specially if the number of misfits is relatively large.

{marker examples}{...}
{title:Examples}

{pstd}
I suggest you {cmd:{help tabulate}} the generated treatment variable with the {cmd:missing} option after running each example.
First, load the fictional blood-pressure data:

	{cmd:sysuse bpwide, clear}

{pstd}
Basic usage:

	{cmd:randtreat, generate(treatment)}
	{cmd:randtreat, generate(treatment) replace mult(5)}

{pstd}
Define stratification variables and unequal treatments, dealing with misfits:

	{cmd:randtreat, generate(treatment) replace unequal(1/2 1/3 1/6)}
	{cmd:randtreat, generate(treatment) replace unequal(1/2 1/3 1/6) strata(sex agegrp) misfits(strata)}
	{cmd:randtreat, generate(treatment) replace unequal(1/2 1/3 1/6) strata(sex agegrp) misfits(global)}

{pstd}	
Choose very unbalanced treatment fractions and dealing with misfits with and without weights:

	{cmd:randtreat, generate(treatment) replace unequal(2/5 1/5 1/5 1/5) misfits(global) setseed(12345)}
	{cmd:randtreat, generate(treatment) replace unequal(2/5 1/5 1/5 1/5) misfits(wglobal) setseed(12345)}

{title:Notes}

{pstd}
Beware of (ab)using {opt unequal()} with fractions that yield a large least common multiple (LCM), because that may produce a large number of misfits. For example, consider the following setup:
	
	{cmd: sysuse bpwide, clear}
	{cmd: randtreat, generate(treatment) unequal(2/5 1/3 3/20 3/20)}
	{cmd: tab treatment, missing}
	
{pstd}
Since the LCM of the specified fractions is 60, the theoretical maximum number of misfits per stratum could be 59.
In this particular dataset, this configuration produces 58 misfits, which is a relatively large number given that the dataset has 120 observations.

{marker author}{...}
{title:Author}

{pstd}Alvaro Carril{break}
Research Analyst at J-PAL LAC{break}
acarril@fen.uchile.cl

{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}
I'm indebted to several "random helpers" at the Random Help Google user group and in the Statalist Forum, who provided coding advice and snippets.
Colleagues at the J-PAL LAC office, specially Olivia Bordeu and Diego Escobar, put up with my incoherent ideas and helped me steer this into something mildly useful.

{marker references}{...}
{title:References}

{phang}Bruhn, Miriam, and David McKenzie. 2011. Tools of the Trade: Doing Stratified Randomization with Uneven Numbers in Some Strata. Blog. The World Bank: Impact Evaluations.
{browse "http://blogs.worldbank.org/impactevaluations/tools-of-the-trade-doing-stratified-randomization-with-unequal-numbers-in-some-strata"}.

{phang}Carril, Alvaro. 2017. Dealing with misfits in random treatment assignment. Stata Journal (forthcoming). DOI: 10.13140/RG.2.1.2859.8807
{browse "https://www.researchgate.net/publication/292091060_Dealing_with_misfits_in_random_treatment_assignment"}.

