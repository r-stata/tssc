{smcl}
{* *! version 1.0 05Dec2015}
{cmd:help vaf}
{hline}

{title:Title}

{p2colset 3 12 18 12}{...}
{p2col :{hi:vaf }{hline 2}}VAF in mediation models with SEM{p_end}
{p2colreset}{...}


{pstd} A simple mediation model will include the following links: 
INDEPENDENT->MEDIATOR->DEPENDENT
INDEPENDENT->DEPENDENT


{title:Description}

{pstd} {bf:vaf} computes the magnitude of the indirect effect in relation
to the total effect. That is, {bf:vaf} computes the proportion of
the variance of a dependent variable explained by an independent 
variable indirectly via a mediator variable/s. This means that the 
mediator/s variable absorbs some of the direct effect between the 
independent and dependent variable. The amount of indirect 
effect determines whether no/partial/full mediation takes place.

{pstd} VAF < 20% indicates (almost) no mediation

{pstd} 20% < VAF > 80% indicates partial mediation

{pstd} VAF > 80% indicates (almost) full mediation   

 
 
KW: mediation
KW: indirect
KW: effect
KW: SEM 
KW: variance


{title:Examples}
{phang}{stata "use http://www.stata-press.com/data/r14/sem_sm2.dta, clear": . use http://www.stata-press.com/data/r14/sem_sm2.dta, clear}{p_end}

{phang}{stata . qui sem (Alien67->anomia67 pwless67)(Alien71->anomia71 pwless71)(SES->educ66 occstat66)(Alien67<-SES)(Alien71<-Alien67 SES)}{p_end}
{phang}{stata "vaf": . vaf}{p_end}

{phang}{stata . qui sem (F1->educ66 occstat66)(F2->anomia66 pwless66)(F3->anomia67 pwless67)(F4->anomia71 pwless71)(F2 F3<-F1)(F4<-F1 F2 F3)}{p_end}
{phang}{stata "vaf": . vaf}{p_end}

{phang}{stata . qui sem (F1->educ66 occstat66)(F2->anomia66 pwless66)(F3->anomia67 pwless67)(F4->anomia71 pwless71)(F3<-F1 F2)(F4<-F1 F2 F3)}{p_end}
{phang}{stata "vaf": . vaf}{p_end}

{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}
{pstd} Hair, J. F., Hult, G. T. M., Ringle, C. M., & Sarstedt, M. (2013). 
A PRIMER ON PARTIAL LEAST SQUARES STRUCTURAL EQUATION MODELING 
(PLS-SEM). London: Sage.





	

  
