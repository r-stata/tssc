{smcl}
{* 13apr2010}{...}
{hline}
help for {hi:lmose}
{hline}

{title:Standard errors for L-moments and derived statistics}

{p 8 17 2}{cmd:lmose}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,}
{it:matlist_options}
]

{p 4 4 2}{cmd:by ... :} may also be used with {cmd:lmose}: 
see help on {help by}.


{title:Description}

{p 4 4 2}{cmd:lmose} calculates standard errors for L-moments and derived 
statistics for a numeric variable {it:varname}. 


{title:Remarks}

{p 4 4 2}Specifically, the variance matrix of sample L-moments and
the standard error vector of sample L-moments and derived ratios is displayed.
The variance matrix of sample L-moments is estimated using the exact unbiased
distribution-free estimator of Elamir and Seheult (2004).  Note that negative
estimates of each variance are possible, especially with very small samples. 
The standard errors of sample L-moments are the square roots of the diagonal
elements of that matrix. The standard errors of t, t_3 and t_4 are obtained
from the variances of ratios l_2/l_1, l_3/l_2, l_4/l_2 using
Taylor-series-based approximations: for a ratio U/V,  

{p 8 8 2}var(U/V) = {c -(}var(U)/E(U)^2 + var(V)/E(V)^2 - 2 cov(U,V)/(E(U) E(V)){c )-} {c -(}E(U)/E(V){c )-}^2.

{p 4 4 2}This information is reported for the one variable only. 
However, {cmd:by:} may be used to obtain listings of 
standard errors for each of several groups. 
This program can be rather slow for larger sample sizes. 


{title:Options}

{p 4 8 2}{it:matlist_options} are options of {help matrix list}. 
The default display has {cmd:format(%9.3f)}.


{title:Examples} 

{p 4 8 2}{cmd:. lmose price}


{title:Saved results} 

    r(V)     variance matrix of l_1 ... l_4
    r(SE)    standard error vector of l_1 ... l_4 t t_3 t_4 


{title:Acknowledgments} 

{p 4 4 2}Allan Seheult kindly provided and discussed reprints of his 
joint work. William Gould was most helpful over the first version of 
the Mata code. 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:References}

{p 4 8 2}{browse "http://www.research.ibm.com/people/h/hosking/lmoments.html": The L-moments page}

{p 4 8 2}Elamir, E.A.H. and A.H. Seheult. 2004. 
Exact variance structure of sample L-moments. 
{it:Journal of Statistical Planning and Inference} 124: 337{c -}359. 

{p 4 8 2}Hosking, J.R.M. 1990. L-moments: Analysis and estimation of
distributions using linear combinations of order statistics. 
{it:Journal of the Royal Statistical Society} Series B 52: 105{c -}124.

{p 4 8 2}Hosking, J.R.M. 1998. L-moments. In Kotz, S., C.B. Read and 
D.L. Banks (eds) {it:Encyclopedia of Statistical Sciences Update Volume 2.} 
New York: Wiley, 357{c -}362.

{p 4 8 2}Hosking, J.R.M. and J.R. Wallis. 1997. 
{it:Regional frequency analysis: an approach based on L-moments.}
Cambridge University Press.

{p 4 8 2}Royston, P. 1992. 
Which measures of skewness and kurtosis are best? 
{it:Statistics in Medicine} 11: 333{c -}343. 


{title:See also} 

{p 4 8 2}{help lmo} (if installed); {help lmoments} (if installed; older version with some discontinued features) 

