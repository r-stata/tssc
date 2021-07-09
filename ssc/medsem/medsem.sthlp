{smcl}
{* *! version 1.0 02Apr2016}
{cmd:help medsem}
{hline}

{title:Title}

{p2colset 3 12 18 12}{...}
{p2col :{hi:medsem }{hline 1}}Mediation analysis using structural equation modelling{p_end}
{p2colreset}{...}


{p 11 8}
{bf:medsem, indep(varname) med(varname) dep(varname)} [{it:mcreps(number) stand zlc rit rid}]


{title:Description}
  
{pstd} {bf: medsem} conducts a mediation analysis based on a model (including observed or latent variables 
  as well as combination of observed and latent variables) estimated using Stata's -sem- command. There are 
  two methods {bf:medsem} uses as the basis for its procedures. The first method is the commonly known Baron 
  and Kenny approach which is adjusted by Iacobucci et al. (2007) for use with structural equation modelling. 
  The second approach is that of Zhao et al. (2010).

  
{pstd}{it:Adjusted Baron and Kenny's approach}{bf: (default)}  

{pstd}  1)If both or one of the X->M and M->Y coefficients is not significant, there is {bf:no mediation}
  
{pstd}  2)When both of the X->M and M->Y coefficients are significant, there is "some" mediation 
 
{pstd} 2a)If the Sobel's z-test is significant and the X->Y coefficient is not significant, then there is {bf:complete} mediation

{pstd}  2b)If both the Sobel's z-test and the X->Y coefficients are significant, then there is {bf:partial} mediation
 
{pstd} 2c)If the Sobel's z-test is not significant but the X->Y coefficient is significant, then there is {bf:partial} mediation

{pstd}  2d)If neither Sobel's z-test nor the X->Y coefficient are significant, then there is {bf:partial} mediation     

  
  
{pstd}  {it:Zhao, Lynch & Chen's approach}

{pstd}  1)If neither Monte Carlo z-test nor the X->Y coefficient are significant, then there is {bf:no-effect nonmediation} (i.e. no mediation)
  
{pstd}  2)If Monte Carlo z-test is not significant and X->Y coefficient is significant, then there is {bf:direct-only nonmediation} (i.e. no mediation) 
  
{pstd}  3)If Monte Carlo z-test is significant and X->Y coefficient is not significant, then there is {bf:indirect-only mediation} (i.e. full mediation)
  
{pstd}  4)If both of the Monte Carlo z-test and X-Y coefficient are significant and their coefficients point in same direction, 
    then there is {bf:complementary mediation} (i.e. partial mediation)
  
{pstd}  5)If both of the Monte Carlo z-test and X-Y coefficient are significant and their coefficients point in opposite direction, 
    then there is {bf:competitive mediation} (i.e. partial mediation)
 
{pstd} Note: Zhao et al. suggest bootstrap test of the indirect effect, {bf: medsem} uses the Monte Carlo test instead as it is less time-consuming 
and still acceptable (see Jose(2013), page 122).
 
  
{title:options}

{pstd} {bf:mcreps}, number of Monte Carlo replications, the default is the number of the sample size.

{pstd} {bf:stand}, output displayed based on standardised coefficients.
       If stand option is not selected, the ({bf:default}) output is based on unstandardised coefficients
	   
{pstd} {bf:zlc}, mediation procedures described by Zhao et al. (2010) described above.
     If zlc option is not selected, the mediation analysis displayed is the one conducted
     based on Baron and Kenny's approach ({bf:default}) adjusted by Iacobucci et al. (2007) described above.
 
{pstd} {bf:rit}, ratio of the indirect effect to the total effect

{pstd} {bf:rid}, ratio of the indirect effect to the direct effect
 
 
KW: mediation
KW: indirect effect
KW: Barron and Kenny
KW: mediator 
KW: Sobel


{title:Examples}
{phang}{stata "use http://www.ats.ucla.edu/stat/data/hsbdemo, clear": . use http://www.ats.ucla.edu/stat/data/hsbdemo, clear}{p_end}
{phang}{stata . qui sem (read <- math)(science <- read math)}{p_end}
{phang}{stata "medsem, indep(math) med(read) dep(science) stand mcreps(5000) zlc rit rid": . medsem, indep(math) med(read) dep(science) stand mcreps(5000) zlc rit rid}{p_end}

{phang}{stata "use http://www.stata-press.com/data/r14/sem_sm2.dta, clear": . use http://www.stata-press.com/data/r14/sem_sm2.dta, clear}{p_end}
{phang}{stata . qui sem (Alien67->anomia67 pwless67)(Alien71->anomia71 pwless71)(SES->educ66 occstat66)(Alien67<-SES)(Alien71<-Alien67 SES)}{p_end}
{phang}{stata "medsem, indep(SES) med(Alien67) dep(Alien71) stand mcreps(5000) zlc rit rid": . medsem, indep(SES) med(Alien67) dep(Alien71) stand mcreps(5000) zlc rit rid}{p_end}

{phang}{stata "use http://www.stata-press.com/data/r14/sem_sm2.dta, clear": . use http://www.stata-press.com/data/r14/sem_sm2.dta, clear}{p_end}
{phang}{stata . qui sem (F1->educ66 occstat66)(F2->anomia66 pwless66)(F3->anomia67 pwless67)(F4->anomia71 pwless71)(F2 F3<-F1)(F4<-F1 F2 F3)}{p_end}
{phang}{stata "medsem, indep(F1) med(F2) dep(F4) ": . medsem, indep(F1) med(F2) dep(F4) }{p_end}
{phang}{stata "medsem, indep(F1) med(F3) dep(F4) zlc": . medsem, indep(F1) med(F3) dep(F4) zlc}{p_end}

{phang}{stata "use http://www.stata-press.com/data/r14/sem_sm2.dta, clear": . use http://www.stata-press.com/data/r14/sem_sm2.dta, clear}{p_end}
{phang}{stata . qui sem (F1->educ66 occstat66)(F2->anomia66 pwless66)(F3->anomia67 pwless67)(F2<-F1)(F3<-F1 F2)}{p_end}
{phang}{stata "medsem, indep(F1) med(F2) dep(F3) stand rit": . medsem, indep(F1) med(F2) dep(F3) stand rit}{p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References} 

{pstd} Iacobucci, D., Saldanha, N., & Deng, X. (2007). A Mediation on 
Mediation: Evidence That Structural Equation Models Perform Better 
Than Regressions. Journal of Consumer Psychology, 17(2), 140-154. 

{pstd} Jose, P. E. (2013). Doing Statistical Mediation & Moderation. 
London: Guilford.

{pstd} MacKinnon, D. P. (2008). Introduction to statistical mediation 
analysis. New York: Lawrence Erlbaum.
	
{pstd} Zhao, X., Lynch, J. G. Jr., & Chen, Q. (2010). Reconsidering Baron 
and Kenny: Myths and Truths about Mediation Analysis. Journal of 
Consumer Research, 37(August), 197-206. 






	

  
