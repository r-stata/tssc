{smcl}
{* *! version 1.0 25June2015}
{cmd:help mint}
{hline}

{title:Title}


{p2colset 3 12 18 12}{...}
{p2col :{hi:mint }{hline 2}}{bf:M}easurement {bf:in}variance {bf:t}est{p_end}
{p2colreset}{...}


{title:Description}

{bf:mint} examines across-groups equivalence of confirmatory factor 
  analysis (CFA) measurement model parameters as well as testing 
  the equality of factor means among groups. The sequence of 
  measurement invariance followed by{bf: mint} is:

1){bf:Equal form/configural invariance} solution has the same form/
  structure with the same indicators loading on the latent variables 
  for each group. 

2){bf:Equal loadings/weak invariance} solution constrains the loadings 
  to be equal for each group.

3){bf:Equal intercepts/strong invariance} solution constrains the intercepts 
  (+ loadings) to be equal for each group. 

4){bf:Equal error variances/strict invariance} solution constrains the error 
  variances (+ loadings and intercepts) to be equal for each group. 
	 
5){bf:Equal factor means} solution constrains the latent means (+ loadings
  intercepts, and error variances) to be equal for each group.  
  
  
KW: latent
KW: cfa
KW: measurement
KW: invariance
KW: constraints


{title:Examples}

{phang}{stata "use http://www.stata-press.com/data/r14/sem_2fmmby,clear": . use http://www.stata-press.com/data/r14/sem_2fmmby,clear}{p_end}

{phang}{stata "qui sem (Peer -> peerrel1 peerrel2 peerrel3 peerrel4)(Par -> parrel1 parrel2 parrel3 parrel4), group(grade)": . qui sem (Peer -> peerrel1 peerrel2 peerrel3 peerrel4)(Par -> parrel1 parrel2 parrel3 parrel4), group(grade)}{p_end}
{phang}{stata "mint": . mint}{p_end}

{phang}{stata "qui sem(Appear->appear1 appear2 appear3)(Phy->phyab1 phyab2 phyab3),group(grade)": . qui sem(Appear->appear1 appear2 appear3)(Phy->phyab1 phyab2 phyab3),group(grade)}{p_end}
{phang}{stata "mint": . mint}{p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:Reference}
Hirschfeld, G. and von Brachel, R. (2014). Multi-Group confirmatory factor
analysis in R - A tutorial in measurement invariance with continuous and 
ordinal indicators. Practical Assessment, Research & Evaluation. Volume 19,
Number 7, 1-12. 


	

  
