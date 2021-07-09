{smcl}
{* *! version 1.0 10March2015}
{cmd:help fsdet}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:fsdet }{hline 2}}Factor score determinacy coefficient{p_end}
{p2colreset}{...}


{title:Description}

{bf:fsdet} computes determinacy coefficient for a factor score obtained from a common 
factor model (exploratory or confirmatory factor analysis) using the following 
formula to find in Beauducel's (2011) work:

mat A = Phi*Lambda'*inv(Sigma)*Lambda*Phi 
       (Phi, Lambda and Sigma represent their respective matrices)
sqrt(A[diag])
  
The value resulting from this formula represents the correlation between the factor 
score estimate and its factor. According to Gorsuch (1983) this coefficient should 
be >= 0.90 if the factor score is to be used as a substitute for the factor itself.


KW: factor
KW: score
KW: indeterminacy


{title:Examples}

{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13 item14 item15 item16 item27 item39": . keep item13 item14 item15 item16 item27 item39}{p_end}

{phang}{stata "qui factor item13 item14 item15 item16 item27 item39, factors(2)": . qui factor item13 item14 item15 item16 item27 item39, factors(2)}  (without rotation){p_end}
{phang}{stata "fsdet": . fsdet}{p_end}

{phang}{stata "qui factor item13 item14 item15 item16 item27 item39, ml factors(2)": . qui factor item13 item14 item15 item16 item27 item39, ml factors(2)}{p_end}
{phang}{stata "qui rotate, equamax": . qui rotate, equamax}  (orthogonal rotation){p_end}
{phang}{stata "fsdet": . fsdet}{p_end}

{phang}{stata "qui factor item13 item14 item15 item16 item27 item39, ipf factors(2)": . qui factor item13 item14 item15 item16 item27 item39, ipf factors(2)}{p_end}
{phang}{stata "qui rotate, promax": . qui rotate, promax}  (oblique rotation){p_end}
{phang}{stata "fsdet": . fsdet}{p_end}

{phang}{stata "qui sem (F1->item13 item14 item15 item16) (F2->item27 item39)": . qui sem (F1->item13 item14 item15 item16) (F2->item27 item39)}  (rotation is not needed){p_end}
{phang}{stata "fsdet": . fsdet}{p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}
Beauducel, A. (2011). Indeterminacy of Factor Score Estimates In Slightly 
Misspecified Confirmatory Factor Models. Journal of Modern Applied Statistical 
Methods, 10(2), 583-598. 	

Gorsuch, R. L. (1983). Factor analysis. Hillsdale, N.J.: L. Erlbaum Associates.
	

  
