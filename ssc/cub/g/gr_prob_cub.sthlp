{smcl}
{* 08apr2020}{...}
{cmd:help gr_prob_cub}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:gr_prob_cub}}{hline 1} Module to graph predicted probabilities for the model "cub00"{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd: gr_prob_cub}
{it: varname} 
{ifin}
{weight}{cmd:,}
[
{cmd:shelter}{cmd:(}{it:#}{cmd:)} 
{cmd:prob}{cmd:(}{it:stub}{cmd:)}
{cmd:save_graph}{cmd:(}{it:filename}{cmd:)}
{cmd:outname}{cmd:(}{it:name}{cmd:)}
]

{pstd}{cmd:fweight}s and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:gr_prob_cub} estimates the model cub00 (see {helpb cub}) and generates the predicted probabilities of the ordinal outcome variable {it:varname}.

{title:Options}

{phang} {cmd:shelter}{cmd:(}{it:#}{cmd:)} specifies the "shelter", i.e. the category presenting an exceptional high frequency.

{phang} {cmd:prob}{cmd:(}{it:stub}{cmd:)} generates the variable named {it:stub} containing the predicted probabilities of the ordinal outcome variable.

{phang} {cmd:save_graph}{cmd:(}{it:filename}{cmd:)} saves the graph plotting the actual and predicted probabilities.

{phang} {cmd:outname}{cmd:(}{it:name}{cmd:)} allows to provide a customized {it:name} to the outcome's name appearing in the graph. 

{title:Example} 

********************************************************************************
* LOAD THE DATASET
********************************************************************************
. use universtata.dta , clear
********************************************************************************
* ESTIMATE "cub00", ESTIMATE AND GRAPH THE PREDICTED PROBABILITIES
********************************************************************************
. gr_prob_cub informat , prob(_PROB) save_graph(mygraph)
********************************************************************************


{title:References}

{phang}
Piccolo, D., and Simone, R. 2019a. The class of CUB models: statistical foundations, inferential issues and empirical evidence. {it:Statistical Methods & Applications}, Vol. 28, pp. 389–435.
{p_end}

{phang}
Piccolo, D., and Simone, R. 2019b. Rejoinder to the discussion of "The class of cub models: statistical foundations, inferential issues and empirical evidence". {it:Statistical Methods & Applications}, Vol. 28, Issue 3, pp. 477–493.
{p_end}

{phang}
Baum, F.C., Cerulli, G., Di Iorio, F., Piccolo, D., Simone, R. 2018, {it:The Stata module CUB for fitting mixture models for ordinal data}. Presented at: "The 2018 Italian Stata Users Group meeting", Bologna, 15 November. 
{p_end}

{phang}
Piccolo, D. 2006. Observed information matrix for cub models. {it:Quaderni di Statistica}, Vol. 8.
{p_end}



{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Acknowledgements}

{phang}
I wish to thank Kit Baum, Francesca Di Iorio, Domenico Piccolo, and Rosaria Simone for their help and suggestions in improving this work. I am also grateful to the organizers and participants to the 2018 Italian Stata Users Group meeting held in Bologna (Italy) on the 15th of November 2018.  
{p_end}     

{title:Also see}

{psee}
Online: {helpb cub} , {helpb pr_prob_cub} , {helpb scattercub} , {helpb glm}
{p_end}