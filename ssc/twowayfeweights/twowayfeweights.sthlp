{smcl}
{* *! version 1  2019-02-25}{...}
{viewerjumpto "Syntax" "twowayfeweights##syntax"}{...}
{viewerjumpto "Description" "twowayfeweights##description"}{...}
{viewerjumpto "Options" "twowayfeweights##options"}{...}
{title:Title}

{p 4 8}{cmd:twowayfeweights} {hline 2} Estimates the weights attached to the two-way fixed effects regressions studied in Chaisemartin & D'Haultfoeuille (2018), as well as summary measures of these regressions' robustness to heterogeneous treatment effects.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:twowayfeweights Y G T D [D0]} {if} 
[{cmd:,} 
{cmd:type(}{it:string}{cmd:)} 
{cmd:test_random_weights(}{it:varlist}{cmd:)}
{cmd:controls(}{it:varlist}{cmd:)}
{cmd:breps(}{it:integer}{cmd:)} 
{cmd:brepscluster(}{it:varname}{cmd:)}
{cmd:path(}{it:string}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:twowayfeweights} {hline 2} Estimates the weights attached to the two-way fixed effects regressions studied in Chaisemartin & D'Haultfoeuille (2018), as well as summary measures of these regressions' robustness to heterogeneous treatment effects.{p_end}

{p 4 8}{cmd:Y} is the dependent variable in the regression. {cmd:Y} is the level of the outcome if one wants to estimate the weights attached to the fixed-effects regression, and {cmd:Y} is the first difference of the outcome if one wants to estimate the weights attached to the first-difference regression.{p_end}

{p 4 8}{cmd:G} is a variable identifying each group.{p_end}

{p 4 8}{cmd:T} is a variable identifying each period.{p_end}

{p 4 8}{cmd:D} is the treatment variable in the regression. {cmd:D} is the level of the treatment if one wants to estimate the weights attached to the fixed-effects regression, and {cmd:D} is the first difference of the treatment if one wants to estimate the weights attached to the first-difference regression.{p_end}

{p 4 8} If {cmd:type(}{it:fdTR}{cmd:)} is specified in the option {cmd:type} below, then the command requires a fifth argument, {cmd:D0}. {cmd:D0} is the mean of the treatment in group g and at period t. It should be non-missing at the first period when a group appears in the data (e.g. at t=1 for the groups that are in the data from the beginning), and for all observations for which the first-difference of the group-level mean outcome and treatment are non missing.{p_end}

{marker options}{...}
{title:Options}

{p 4 8}{cmd:type} is a required option that can take four values: {it:feTR, feS, fdTR, fdS}. If {it:feTR} is specified, the command estimates the weights and sensitivity measures attached to the fixed-effects regression under the common trends assumption. With {it:feS}, it estimates the weights and sensitivity measures attached to the fixed-effects regression under the common trends and stable treatment effect assumptions. With {it:fdTR}, it estimates the weights and sensitivity measures attached to the first-difference regression under the common trends assumption. Finally, with {it:fdS} it estimates the weights and sensitivity measures attached to the first-difference regression under the common trends and stable treatment effect assumptions.{p_end}

{p 4 8} {cmd:test_random_weights} when this option is specified, the command estimates the correlation between each variable in {it:varlist} and the weights. Testing if those correlations significantly differ from zero is a way to assess whether the weights are as good as randomly assigned to groups and time periods.{p_end}

{p 4 8}{cmd:controls} is a list of control variables that are included in the regression. Controls should not vary within each group*period cell, because the results in de Chaisemartin, C. and D'Haultfoeuille, X. (2018) apply to two-way fixed effects regressions with group*period level controls. If a control does vary within a group*period cell, the command will replace it by its average value within each group*period cell. {p_end}

{p 4 8}{cmd:breps} specifies the number of bootstrap replications to be used for inference. The minimum is 2. When this option is specified, the command returns two inference measures to the user: the standard error of the sum of negative weights, and a 95% confidence interval for the sensitivity measure of the regression's robustness to heterogeneous treatment effects.{p_end}

{p 4 8}{cmd:brepscluster} specifies the clustering variable to be used when one wants to use a block bootstrap for inference.{p_end}

{p 4 8}{cmd:path} allows the user to specify a path (e.g D:\FolderName\project.dta) where a .dta file containing 3 variables (Group, Time, Weight) will be saved. This option allows the user to see the weight attached to each group*time cell.{p_end}

{marker references}{...}
{title:References}

{p 0 0} de Chaisemartin, C. and D'Haultfoeuille, X. (2018). Two-way fixed effects estimators with heterogeneous treatment effects. {p_end}

{title:Authors}

{p 4 8}Clement de Chaisemartin, University of California at Santa Barbara, Santa Barbara, California, USA.
{browse "mailto:clementdechaisemartin@ucsb.edu":clementdechaisemartin@ucsb.edu}.{p_end}

{p 4 8}Xavier D'Haultfoeuille, CREST, Palaiseau, France.
{browse "mailto:xavier.dhaultfoeuille@ensae.fr":xavier.dhaultfoeuille@ensae.fr}.{p_end}

{p 4 8}Antoine Deeb, University of California at Santa Barbara, Santa Barbara, California, USA.
{browse "mailto:antoinedib@ucsb.edu":antoinedib@ucsb.edu}.{p_end}
