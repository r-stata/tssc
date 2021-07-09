
{smcl}
{.-}
help for {cmd:group2hdfe} {right:()}
{.-}
 
{title:Title}

group2hdfe - Computes the number of restrictions in a linear regression model with two high dimensional fixed effects.

{title:Syntax}

{p 8 15}
{cmd:group2hdfe} {it:{help varname1}} {it:{help varname2}}, [{it:options}]

{p}

{title:Description}

{p} This command calculates the number of restrictions needed to ensure identifiability of the fixed effects
in a linear regression model with two high dimensional fixed effects (2hdfe). The number of restrictions is stored
in r(rest). The command is a Mata implementation of the {help a2group} developed by Amine Ouazad.

{title:Options}

{p 0 4} {cmd:group (}{it:new varname}{cmd:)} Creates a new variable with an indicator for membership 
to each connected set. 

{p 0 4} {cmd:largest (}{it:new varname}{cmd:)} Creates a new variable with an indicator for membership to the
largest connected dataset.

{p 0 4}{cmdab:verb:ose} Provides more information while the algorithm is running.

{title:Examples}

Example 1:

Compute the number of restrictions in the data and display it.

{p 8 16}{inp:. group2hdfe i j }{p_end}

{p 8 16}{inp:. display r(rest)}{p_end}

Example2:

Identify the largest "connected" data set 

{p 8 16}{inp:. group2hdfe i j, largest(big)} {p_end}

{p 8 16}{inp:. keep if big==1} {p_end}

{title:Saved Results}

{cmd:group2hdfe} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}

{synopt:{cmd:r(rest)}}number of restrictions (connected sets).{p_end}

{title:Acknowledgment}

This command was based on a previous version of Amine Ouazad's {help a2group} command.

{title:Author}

{p}
Paulo Guimaraes, BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:pguimaraes2001@gmail.com":pguimaraes2001@gmail.com}

Comments welcome!

{title:Also see}

{p 0 21}
{help reghdfe} (if installed). 
{p_end}

