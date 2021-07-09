{smcl}
{* *! version 1.0 07Apr2015}
{cmd:help relicoef}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:relicoef }{hline 1}}Raykov's factor reliability coefficient{p_end}
{p2colreset}{...}


{title:Description}

{bf:relicoef} computes Raykov's reliability coefficient (RRC) for factors from 
confirmatory factor analyses, a measure which is commonly seen as a more 
accurate one than that of Cronbach's alpha which is computed based on the 
assumption of tau-equivalent measures.

Raykov (1997) proposes two different formulas for estimating reliability 
coefficients which {bf:relicoef} employs for the computation:

{bf:For factors without correlated errors (no error covariance)}
RRC = (Sum of unstandardised loadings squared)*(factor variance)/
      (Sum of unstandardised loadings squared)*(factor variance) + 
      (Sum of unstandardised error variances)
	  
{bf:For factors with correlated errors (at least one error covariance)}
RRC = (Sum of unstandardised loadings squared)*(factor variance)/
      (Sum of unstandardised loadings squared)*(factor variance) + 
      (Sum of unstandardised error variances) +
      (2*Sum of unstandardised error covariances)
  


KW: factor
KW: reliability
KW: coefficient
KW: scale


{title:Examples}

{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13 item14 item15 item25 item32": . keep item13 item14 item15 item25 item32}{p_end}
{phang}{stata "qui sem (Factor1 ->  item13 item14 item15) (Factor2 -> item25 item32)": . qui sem (Factor1 ->  item13 item14 item15) (Factor2 -> item25 item32)}{p_end}
{phang}{stata "relicoef": . relicoef}{p_end}

{phang}{stata "qui sem (Factor1 ->  item13 item14 item15) (Factor2 -> item25 item32), cov(e.item13*e.item15)": . qui sem (Factor1 ->  item13 item14 item15) (Factor2 -> item25 item32), cov(e.item13*e.item15)}{p_end}
{phang}{stata "relicoef": . relicoef}{p_end}



{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}
Raykov, T. (1997). Estimation of composite reliability for congeneric measures. 
Applied Psychological Measurement, 21, 173-184. 
	

  
