{smcl}
{* 17sep2017}{...}
{cmd:help cluster_ra}{right:Version 1.1}
{hline}

{title:Title}

{pstd}
{hi:cluster_ra} {hline 2} implements a random assignment procedure in which groups of units are assigned together (as a cluster) to treatment conditions. 
This function conducts complete random assignment at the cluster level.
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:cluster_ra} [{it:treatvar}] {cmd:, }
{opt cluster_var:(var)}
[{opt m:(num)}
{opt m_each:(numlist)}
{opt prob:(num)}
{opt prob_each:(numlist)}
{opt num_arms:(num)}
{opt condition_names:(string)}
{opt replace}
{opt skip_check_inputs}]

{marker desc}{title:Description}

{pstd} {cmd:cluster_ra} implements a random assignment procedure in which groups of units are assigned together (as a cluster) to treatment conditions. 
This function conducts complete random assignment at the cluster level.

{marker opt}{title:Options}

{pstd} {it: treatvar} The name of the treatment variable, you want this command to generate. 
If left unspecified the resulting variable is called "assignment" by default.{p_end}

{pstd} {opt clustervar:(var)} The variable that indicates which cluster each unit belongs to. Can be a string or numeric variable.{p_end}

{pstd} {opt m:(num)} Use for a two-arm design in which m clusters are assigned to treatment and N-m clusters are assigned to control.{p_end} 
{pstd} {opt m_each:(numlist)} Use for a multi-arm design in which the values of m_each determine the number of clusters assigned to each condition.
 m_each must be a numeric list in which each entry is a nonnegative integer 
that describes how many clusters should be assigned to the 1st, 2nd, 3rd... treatment condition. m_each must sum to N. {p_end} 
{pstd} {opt prob:(num)} Use for a two-arm design in which either floor(N_clusters*prob) or ceiling(N_clusters*prob) clusters are assigned to 
treatment. The probability of assignment to treatment is exactly prob because with probability 1-prob, floor(N_clusters*prob) clusters will be 
assigned to treatment and with probability prob, 
ceiling(N_clusters*prob) clusters will be assigned to treatment. prob must be a real number between 0 and 1 inclusive. {p_end} 
{pstd} {opt prob_each:(numlist)} Use for a multi-arm design in which the values of prob_each determine the probabilties of assignment to each 
treatment condition. prob_each must be a numeric list giving the probability of assignment to each condition. All entries must be nonnegative real 
numbers between 0 and 1 inclusive and the total must sum to 1. Because of integer issues, the exact number of clusters assigned 
to each condition may differ (slightly) from assignment to assignment, but the overall probability of assignment is exactly prob_each.{p_end} 
{pstd} {opt num_arms:(num)} The number of treatment arms. If unspecified, num_arms will be determined from the other arguments.{p_end} 
{pstd} {opt condition_names:(string)} A string list giving the names of the treatment groups. If unspecified, the treatment groups will be named 0 (for control) and 1 (for treatment) 
in a two-arm trial and 1, 2, 3, in a multi-arm trial. 
An execption is a two-group design in which num_arms is set to 2, in which case the condition names are 1 and 2, as in a multi-arm trial with two arms.{p_end} 
{pstd} {opt replace} If treatvar exists in dataset, the command replaces it.{p_end}

{pstd} {opt skip_check_inputs} Suppress error checking.{p_end}

{marker ex}{title:Examples}

{pstd} {inp:. set obs 100 }{p_end}
{pstd} {inp:. gen cluster=runiformint(1,26) }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) m(13) replace }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) m_each(10 16) condition_names(control treatment) replace }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) num_arms(3) replace }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) m_each(7 7 12) replace }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) m_each(7 7 12) condition_names(control placebo treatment) replace }{p_end}
{pstd} {inp:. cluster_ra, cluster_var(cluster) condition_names(control placebo treatment) replace }{p_end}


{title:Authors}

{pstd}John Ternovski{p_end}
{pstd} Alex Coppock {p_end}
{pstd} Yale University{p_end}
{pstd} {browse "mailto:john.ternovski@yale.edu":john.ternovski@yale.edu}{p_end}
