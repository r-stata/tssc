{smcl}
{* 17sep2017}{...}
{cmd:help simple_ra}{right:Version 1.5}
{hline}

{title:Title}

{pstd}
{hi:simple_ra} {hline 2} implements a random assignment procedure in which units are independently assigned to treatment conditions.
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:simple_ra} [{it:treatvar}] {cmd:, }
[{opt prob:(num)}
{opt prob_each:(numlist)}
{opt num_arms:(num)}
{opt condition_names:(string)}
{opt replace}
{opt skip_check_inputs}]

{marker desc}{title:Description}

{pstd} {cmd:simple_ra} implements a random assignment procedure in which units are independently assigned to treatment conditions. 
Because units are assigned independently, the number of units that are assigned to each condition can vary from assignment to assignment. 
For most experimental applications in which the number of experimental units is known in advance, complete_ra is better 
because the number of units assigned to each condition is fixed across assignments.
In most cases, users should specify not more than one of prob, prob_each, or num_arms.
If no options are specified, a two-arm trial with prob = 0.5 is assumed.

{marker opt}{title:Options}

{pstd} {it: treatvar} The name of the treatment variable, you want this command to generate. 
If left unspecified the resulting variable is called "assignment" by default.{p_end}

{pstd} {opt prob:(num)} Use for a two-arm design. prob is the probability of assignment to treatment and must be a real number between 0 and 1 inclusive. {p_end} 
{pstd} {opt prob_each:(numlist)} Use for a multi-arm design in which the values of prob_each determine the probabilties of assignment to each treatment condition. prob_each must 
be a numeric vector giving the probability of assignment to each condition. All entries must be nonnegative real numbers between 0 and 1 inclusive and the total must sum to 1.{p_end} 
{pstd} {opt num_arms:(num)} The number of treatment arms. If unspecified, num_arms will be determined from the other arguments.{p_end} 
{pstd} {opt condition_names:(string)} A string list giving the names of the treatment groups. If unspecified, the treatment groups will be named 0 (for control) and 1 (for treatment) 
in a two-arm trial and 1, 2, 3, in a multi-arm trial. 
An execption is a two-group design in which num_arms is set to 2, in which case the condition names are 1 and 2, as in a multi-arm trial with two arms.{p_end} 
{pstd} {opt replace} If treatvar exists in dataset, the command replaces it.{p_end}

{pstd} {opt skip_check_inputs} Suppress error checking.{p_end}

{marker ex}{title:Examples}

{pstd} {inp:. simple_ra treat }{p_end}
{pstd} {inp:. simple_ra treat, replace prob(.5) }{p_end}
{pstd} {inp:. simple_ra treat, replace prob_each(.3 .7) condition_names(control treatment) }{p_end}
{pstd} {inp:. simple_ra treat, replace num_arms(3) }{p_end}
{pstd} {inp:. simple_ra treat, replace prob_each(.3 .3 .4) condition_names(control treatment placebo) }{p_end}


{title:Authors}

{pstd}John Ternovski{p_end}
{pstd} Alex Coppock {p_end}
{pstd} Yale University{p_end}
{pstd} {browse "mailto:john.ternovski@yale.edu":john.ternovski@yale.edu}{p_end}
