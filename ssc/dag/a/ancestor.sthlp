

{smcl}
{* v 1.0.3 Chunsen Wu 10August2019 generate/simulate child variables for a given DAG (directed acyclic graph)}{...}
{cmd:help ancestor}{right: ({browse "http://medical-statistics.dk/MSDS/epi/dag/dag.html":Directed acyclic graph (DAG) in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:ancestor} {hline 2} generate/simulate {it:ancesor-variables} for a given DAG (directed acyclic graph)


{title:Syntax}

{p 8 17 2}
{cmd:ancestor}
{it:ancestor1var ancestor2var ... ancestor10var}
{ifin}
[{cmd:,} {it:options}
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt pre1(percent)}}Prevalence for the first {it:ancesor-variable} in the population and the default value of the prevalence is 0.05{p_end}
{synopt :{opt pre2(percent)}}Prevalence for the second {it:ancesor-variable} in the population and the default value of the prevalence is 0.05{p_end}
{synopt :{opt ...}}{p_end}
{synopt :{opt pre15(percent)}}Prevalence for the fifteenth {it:ancesor-variable} in the population and the default value of the prevalence is 0.05{p_end}
{synopt :{opt popu(number)}}The simulated population size and the default value is 10000{p_end}
{synoptline}

{title:Description}

{pstd}
Combining command {helpb ancestor}, {helpb child}, and {helpb childc} can simulate a dataset comprising binary and continous variables for a given DAG.
{helpb ancestor} is a command creating {it:ancestor-variables} for a given DAG.
{helpb child} is a command creating {it:child-variable} for a given DAG.
{helpb childc} is a command creating normally distributed continous {it:child-variable} for a given DAG.{p_end}

{pstd}
At an once, the command {helpb ancestor} can create up to 15 {it:ancestor-variables}. By default, the prevalence of all {it:ancestor-variables} are 0.05. 


{title:Options} 

{phang}
{opt pre1} specifies the prevalence of the first {it:ancestor-variable} in the population. The default value of the prevalence is 0.05 

{phang}
{opt pre2} -  {opt pre15} specifies the prevalence of the second {it:ancestor-variable} - the fifteenth {it:ancestor-variable} in the population, respectively. By default, all prevalence are 0.05 

{phang}
{opt popu} specifies the population size and the default value of the population size is 10000. 


       
{title:Examples}

{pstd}
To simulate a dataset comprising variables in a DAG (E <- C -> O), suppose:

{phang}1. The {it:ancesor-variable} C is a binary variable and prevalence of the C is 0.05.{p_end}
{phang}2. The {it:child-variable} E is a binary variable and the risk of E among the baseline (C=0) is 0.05{p_end}
{phang}3. The causal odds ratio for C -> E is 5 {p_end}
{phang}4. The {it:child-variable} O is a binary variable and the risk of O among the baseline (C=0 & E=0) is 0.05{p_end}
{phang}5. The causal odds ratio for E -> O is 1 and for C -> O is 5, respectively{p_end}
{phang}6. We wish the population size is 10000{p_end}

{phang}{stata "clear": .clear} {p_end}
{phang}{stata "set seed 150": .set seed 150} {p_end}
{phang}{stata "ancestor C, pre1(0.05) popu(10000)": .ancestor C, pre1(0.05) popu(10000)} {p_end}
{phang}{stata "child E C, baserisk(0.05) p1or(5)": .child E C, baserisk(0.05) p1or(5)} {p_end}
{phang}{stata "child O E C, baserisk(0.05) p1or(1) p2or(5)": .child O E C, baserisk(0.05) p1or(1) p2or(5)} {p_end}

{phang}Crude analysis (without adjust for the common cause variable C){p_end}
{phang}{stata "logistic O i.E": .logistic O i.E} {p_end}

{phang}Adjusted for the common cause variable C{p_end}
{phang}{stata "logistic O i.E i.C": .logistic O i.E i.C} {p_end}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/epi/dag/dag.html":her}

{title:Acknowledgment}

{pstd}
Jørn Olsen provided encouragement. 

{title:References} 

{phang}Sander Greenland, Judea Pearl, and James M. Robins 1999.{p_end}
{phang}{browse "https://www.ncbi.nlm.nih.gov/pubmed/9888278":Causal diagrams for epidemiologic research.}

{phang}Judea Pearl{p_end}
{phang}Causality:{it: Models, Reasoning and Inference.} Cambridge University Press, New York, NY, USA, 2nd edition, 2009.

{phang}Lash Kenneth J. Rothman, Sander Greenland, and Timothy L. Lash.{p_end}
{phang}The chapter 12: {bf:Causal Diagrams} in the Epidemiology textbook of {it: Modern Epidemiology}. Wolters Kluwer, 2008.

{phang}Miguel A. Hernán, James M. Robins{p_end}
{phang}The chapter 6: {bf:Graphical representation of causal effects} of {browse "https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/":Causal Inference Book.}	


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}

{title:Also see}

{p 7 14 2}
Help: {helpb child}, {helpb childc}
{p_end}
