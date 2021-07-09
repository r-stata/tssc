{smcl}
{* 24June2015}{...}
{cmd:help datanet}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:datanet}{hline 1}}Command to facilitate dataset organization for network analysis purposes{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:datanet}
{it: ID} 
{it: X}
,
save({it:filename})
[duplicate]

where:

{it:ID}: string variable
{it:X}: numeric variable


{title:Description}

{pstd} Given a fixed number of units (or nodes) belonging to a same group, 
possibly connected one each other or possibly not, this routine creates all their possible couplings.
To launch the command, one needs to have at least two variables in the dataset, the first we call here ID, and the second we call here X. 
The variable ID must be a string indexing units (such as: individuals, organizations, countries, etc.) forming the nodes (or vertices) of the network; 
the variable X must me numeric and denotes the group to which the single unit belongs, coded through a specific group identifier (chosen by the user).
A tutorial (Cerulli and Zinilli, 2014) with an illustrative example can be accessed
{browse "http://www.stata.com/meeting/italy14/abstracts/materials/it14_cerulli_datanet.pdf":here}.
     
{title:Options}

{phang} save({it:filename}): this option asks the user to save the output dataset in a new dataset called {it:filename}. 
It is mandatory.
    
{phang} {it:duplicate}: this option may be specified or unspecified. When specified, 
it does not remove observations with identical values in IN and OUT. 


{title:Example}

*********************************************
. clear
. set obs 1
. gen str var1 = "a" in 1
. set obs 2
. replace var1 = "b" in 2
. set obs 3
. replace var1 = "c" in 3
. set obs 4
. replace var1 = "d" in 4
. gen var2 = 1 in 1
. replace var2 = 1 in 2
. replace var2 = 2 in 3
. replace var2 = 2 in 4
. rename var1 ID
. rename var2 X
*********************************************
. datanet ID X, dup  save(NEW_DATA)
*********************************************


{title:Remarks} 

{pstd} Rememeber that: ID must be a string; X must be numeric. 

  
{title:References}

{phang}
Cerulli G. and Zinilli A. (2014), 
DATANET: a Stata routine for organizing a dataset for network analysis purposes, 
XI convegno italiano degli utenti di Stata. Milano, 13-14 Novembre. 
{browse "http://www.stata.com/meeting/italy14/abstracts/materials/it14_cerulli_datanet.pdf":Download here}.
{p_end}

{phang}
Borgatti S. (1995), Centrality and AIDS. {it:Connections}, 18, 1, pp. 112-114.
{p_end}

{phang}
Freeman L. (1997), Centrality in social networks conceptual clarification. {it:Social Networks}, 1, 3, pp. 215-239.
{p_end}

{phang}
Miura H. (2012), Stata graph library for network analysis. {it:The Stata Journal}, 12, 1, pp. 94-129.
{p_end}

{phang}
Zinilli A. (2016), Competitive project funding and dynamic complex networks: evidence from Projects of National Interest (PRIN),
{it:Scientometrics}, 108, 2, pp. 633-652.
{p_end}

{title:Authors}

{phang}Antonio Zinilli and Giovanni Cerulli{p_end}
{phang}IRCrES-CNR, Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:antonio.zinilli@ircres.cnr.it":antonio.zinilli@ircres.cnr.it}{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online:  {helpb netsis}
{p_end}
