
{smcl}
{* v 1.0.3 Chunsen Wu 10August2019 generate/simulate child variables for a given DAG (directed acyclic graph)}{...}

{cmd:help dag}{right: ({browse "http://medical-statistics.dk/MSDS/epi/dag/dag.html":Directed acyclic graph (DAG) in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:dag} {hline 2} A package for simulating binary and continous variables for a given DAG (directed acyclic graph)

{title:Description}

{pstd}
The {it:dag} package consists of three commands: {helpb ancestor}, {helpb child}, and {helpb childc}. Combining the commands can simulate a dataset comprising binary and continous variables for a given DAG.
{p_end}
{pstd}
{helpb ancestor} is a command creating binary {it:ancestor-variables} for a given DAG.{p_end}
{pstd}
{helpb child} is a command creating binary {it:child-variable} for a given DAG.{p_end}
{pstd}
{helpb childc} is a command creating normally distributed continous {it:child-variable} for a given DAG.{p_end}

{title:More information}: click on {browse "http://medical-statistics.dk/MSDS/epi/dag/dag.html":her} 

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


       ../a/ancestor.ado
       ../a/ancestor.sthlp
       ../c/child.ado
       ../c/child.sthlp
       ../c/childc.ado
       ../c/childc.sthlp

{title:Also see}

{p 7 14 2}
Help: {helpb ancestor}, {helpb child}, {helpb childc}
{p_end}
