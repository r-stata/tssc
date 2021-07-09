{smcl}
{* 17sep2017}{...}
{cmd:help complete_ra}{right:Version 1.8}
{hline}

{title:Title}

{pstd}
{hi:complete_ra} {hline 2} implements a random assignment procedure in which fixed numbers of units are assigned to treatment conditions.  
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:complete_ra} [{it:treatvar}] {cmd:, }
[{opt m:(num)}
{opt m_each:(numlist)}
{opt prob:(num)}
{opt prob_each:(numlist)}
{opt num_arms:(num)}
{opt condition_names:(string)}
{opt replace}
{opt skip_check_inputs}]

{marker desc}{title:Description}

{pstd} {cmd:complete_ra} implements a random assignment procedure in which fixed numbers of units are assigned to treatment conditions. 
The canonical example of complete random assignment is a procedure in which exactly m of N units are assigned to treatment and N-m units are assigned to control.
Users can set the exact number of units to assign to each condition with m or m_each. Alternatively, users can specify probabilities of assignment 
with prob or prob_each and complete_ra will infer the correct number of units to assign to each condition.
In a two-arm design, complete_ra will either assign floor(N*prob) or ceiling(N*prob) units to treatment, choosing between these two values to ensure 
that the overall probability of assignment is exactly prob.
In a multi-arm design, complete_ra will first assign floor(N*prob_each) units to their respective conditions, then will assign the remaining 
units using simple random assignment, choosing these second-stage probabilties so that the overall probabilities of assignment are exactly prob_each.
In most cases, users should not more than one of m, m_each, prob, prob_each, or num_arms. 
If no options are specified, a two-arm trial in which N/2 units are assigned to treatment is assumed. 
If N is odd, either floor(N/2) units or ceiling(N/2) units will be assigned to treatment.


{marker opt}{title:Options}

{pstd} {it: treatvar} The name of the treatment variable, you want this command to generate. 
If left unspecified the resulting variable is called "assignment" by default.{p_end}

{pstd} {opt m:(num)} Use for a two-arm design in which m units are assigned to treatment and N-m units are assigned to control.{p_end} 
{pstd} {opt m_each:(numlist)} Use for a multi-arm design in which the values of m_each determine the number of units assigned to each condition. m_each must 
be a list of numbers in which each entry is a nonnegative integer that describes how many units should be assigned to the 1st, 2nd, 3rd... treatment condition. m_each must sum to N.{p_end} 
{pstd} {opt prob:(num)} Use for a two-arm design in which either floor(N*prob) or ceiling(N*prob) units are assigned to treatment. The probability of assignment to 
treatment is exactly prob because with probability 1-prob, floor(N*prob) units will be assigned to treatment and with probability prob, ceiling(N*prob) units will be assigned 
to treatment. prob must be a real number between 0 and 1 inclusive.{p_end} 
{pstd} {opt prob_each:(numlist)} Use for a multi-arm design in which the values of prob_each determine the probabilties of assignment to each treatment condition. 
prob_each must be a list of numbers giving the probability of assignment to each condition. 
All entries must be nonnegative real numbers between 0 and 1 inclusive and the total must sum to 1. Because of integer issues, 
the exact number of units assigned to each condition may differ (slightly) from assignment to assignment, but the overall probability of assignment is exactly prob_each.{p_end} 
{pstd} {opt num_arms:(num)} The number of treatment arms. If unspecified, num_arms will be determined from the other arguments.{p_end} 
{pstd} {opt condition_names:(string)} A string list giving the names of the treatment groups. If unspecified, the treatment groups will be named 0 (for control) and 1 (for treatment) 
in a two-arm trial and 1, 2, 3, in a multi-arm trial. 
An execption is a two-group design in which num_arms is set to 2, in which case the condition names are 1 and 2, as in a multi-arm trial with two arms.{p_end} 
{pstd} {opt replace} If treatvar exists in dataset, the command replaces it.{p_end}

{pstd} {opt skip_check_inputs} Suppress error checking.{p_end}

{marker ex}{title:Examples}

{pstd} {inp:. set obs 100 }{p_end}
{pstd} {inp:. complete_ra }{p_end}
{pstd} {inp:. complete_ra, m(50) replace }{p_end}
{pstd} {inp:. complete_ra, prob(.111) replace }{p_end}
{pstd} {inp:. complete_ra, condition_names(control treatment) replace }{p_end}
{pstd} {inp:. complete_ra, num_arms(3) replace }{p_end}
{pstd} {inp:. complete_ra, m_each(30 30 40) replace }{p_end}
{pstd} {inp:. complete_ra, prob_each(.1 .2 .7) replace }{p_end}
{pstd} {inp:. complete_ra, condition_names(control placebo treatment) replace }{p_end}


{title:Authors}

{pstd}John Ternovski{p_end}
{pstd} Alex Coppock {p_end}
{pstd} Yale University{p_end}
{pstd} {browse "mailto:john.ternovski@yale.edu":john.ternovski@yale.edu}{p_end}
