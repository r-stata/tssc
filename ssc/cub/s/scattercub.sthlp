{smcl}
{* 23dec2019}{...}
{cmd:help scattercub}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:scattercub}}{hline 1} Module to estimate the "uncertainty vs. feeling" scatterplot for the model "cub00"{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd: scattercub}
{it: varlist} 
{ifin}
{weight}{cmd:,}
[
{cmd:m}{cmd:(}{it:list_of_integers}{cmd:)}
{cmd:save_data}{cmd:(}{it:filename}{cmd:)}
{cmd:save_graph}{cmd:(}{it:filename}{cmd:)}
]

{pstd}{cmd:fweight}s and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:scattercub} estimates the model cub00 (see {helpb cub}) and generates the scatterplot of the "uncertainty vs. feeling" measures. The model cub00 is the simplest {it:cub} model possible as it does not contain covariates. 
It takes ordinal outcome variables as inputs and draws the related "uncertainty vs. feeling" graph. 

{title:Options}

{phang} {cmd:m}{cmd:(}{it:list_of_integers}{cmd:)} allows, for each ordinal dependent variable in {it:varlist}, to optionally specify the total number of categories. This total number comprises both observed and unobserved categories. 
If this option is not specified, only observed categories are considered in the estimation phase. 

{phang} {cmd:save_data}{cmd:(}{it:filename}{cmd:)} saves in {it:filename} the dataset containing the "uncertainty" and "feeling" measures.    

{phang} {cmd:save_graph}{cmd:(}{it:filename}{cmd:)} saves in {it:filename} the "uncertainty vs. feeling" scatterplot. 



{title:Example} 

********************************************************************************
* LOAD THE DATASET
********************************************************************************
. use universtata.dta , clear
********************************************************************************
* ESTIMATE "cub00" AND PRODUCE THE SCATTERPLOT OF "UNCERTAINTY" VS. "FEELING"
********************************************************************************
. scattercub informat willingn officeho compete global , ///
m(9 10 12 10 12) save_graph(mygraph1) save_data(mydata1)  
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
Online: {helpb cub} , {helpb pr_prob_cub} , {helpb gr_prob_cub} , {helpb glm}
{p_end}