{smcl}
{* 17Jan2015/}{...}
{cmd:help pagetrend}
{hline}

{title:Title}

{p2colset 8 22 20 2}{...}
{p2col :{hi: pagetrend} {hline 2}}Page's L trend test for ordered alternatives{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:pagetrend}
{varlist}
{ifin}

{title:Description}

{pstd}{cmd:pagetrend} is a module to perform Page's (1963) non-parametric test for ordered alternatives. 
This test is commonly known as Page's trend test or Page's L test. 

{pstd} The data are required to be in wide form (see {stata help reshape}). For example, consider 
an experiment in which each of N individuals has been subjected to K different treatments, and the researcher is interested 
in the analysis of individual-level treatment outcomes. Then, the data may be organized as: 

{cmd}	      group    x1     x2     ...  xK-1	    xK    
           1      3      7  	...	8	6      
           2      4      3  	...	4	5    
          ...    ...    ... 	...   ...      ...    
          N-1     5      5  	...	7	6    
           N      9      7  	...	8	8  {txt}     
		   
{pstd} where variable {cmd:group} identifies individuals, and variable {cmd:x{it:k}} records individual-specific outcomes under the {it:k}th treatment.     

{pstd} Page's trend test is useful when the researcher has a specific hypothesis about the rank ordering of treatments in terms of outcomes 
(that is, about which treatments tend to induce greater outcomes). Empirical applications of this test can be found in Abdellaoui, Klibanof and Placido (2013) and Reuben and Riedl (2013) among others. 

{pstd} The researcher's hypothesized rank ordering becomes the {it:alternative} hypothesis (e.g. K=4 and Ha: m1 < m2 < m4 < m3 where m{it:k} can be the population mean or median of variable {cmd:x{it:k}}). 
Page's L statistic is based on within-group ranks of treatment outcomes. Given a sample L statistic that exceeds a critical value,  
the null (e.g. Ho: m1 = m2 = m4 = m3) would be rejected in {it:favour} of the {it:alternative}. 

{pstd} The exact distribution of Page's L statistic (L) is a non-standard one. Page (1963, pp.220-221) tabulates a selection of exact critical values. Following Sheskin (2003, p.860), 
{cmd:pagetrend} computes an approximate p-value based on an asymptotically standard normal transformation of L: specifically, 
based on z = (L - E(L))/sd(L) where E(L) and sd(L) are the expected value and standard deviation of L, respectively.        

{pstd}Note: Cox's (2009) {cmd:rowranks} ({bf:{stata findit pr0046}})
must be installed before {cmd:pagetrend} can be used. {cmd:pagetrend} calls {cmd:rowranks} to compute within-group ranks, 
and specifies {cmd:method(}mean{cmd:)} option of {cmd:rowranks} to address tied ranks. 

{title:Example}

{pstd}
Continuing with the K=4 example, suppose that the alternative hypothesis is Ha: m1 < m2 < m4 < m3. Then:

{phang2}{cmd:. pagetrend x1 x2 x4 x3} {p_end}

{pstd} 
Suppose that the alternative hypothesis is Ha: m2 < m4 < m3 < m1 instead. Then:

{phang2}{cmd:. pagetrend x2 x4 x3 x1} {p_end}

{pstd}
Note: The variable names do not need to include any common prefix or numeric suffix.    

{title:Stored results}

{pstd}{cmd:pagetrend} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N_group)}}number of groups{p_end}
{synopt:{cmd:r(N_treat)}}number of treatments (i.e. of variables in {varlist}){p_end}
{synopt:{cmd:r(L)}}L statistic{p_end}
{synopt:{cmd:r(z)}}approximate z statistic (transformation of {cmd:r(L)}){p_end}
{synopt:{cmd:r(p)}}approximate p-value{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(treat{it:k})}}name of the {it:k}th variable in {varlist}{p_end}


{p2colreset}{...}


{title:References}

{phang} 
Abdellaoui, M., Klibanof P., and Placido, L. 2013. Experiments on compound risk in relation to simple risk and to ambiguity. 
Forthcoming in {it:Management Science}. [{browse "http://www.kellogg.northwestern.edu/faculty/klibanof/ftp/workpap/AKP2011.pdf":Link}] 

{phang}
Cox, N. J.  2009.  Speaking Stata: Rowwise. {it:Stata Journal} 9(1):  
{browse "http://www.stata-journal.com/article.html?article=pr0046":pr0046}.

{phang}
Page, E. B.  1963. Ordered Hypotheses for Multiple Treatments: 
A Significance Test for Linear Ranks. {it:Journal of the American Statistical Association} 58(301): 216-230.

{phang}
Reuben, E. and Riedl, A. 2013. Enforcement of contribution norms in public good games with
heterogeneous populations. {it:Games and Economic Behavior} 77: 122-137.

{phang}
Sheskin, D. J. 2003. {it:Handbook of Parametric and Nonparametric Statistical Procedures: Third Edition}. CRC Press.  

{title:Author}

{pstd}Dr. Hong Il Yoo{p_end}
{pstd}Durham University Business School{p_end}
{pstd}Durham University{p_end}
{pstd}Durham, UK{p_end}
{pstd}h.i.yoo@durham.ac.uk{p_end}


{title:Also see}

{p 7 14 2}
Help:  {helpb nptrend}, {helpb ktau}, {helpb ranksum}, {helpb rowranks} (if installed), {helpb jonter} (if installed)
{p_end}
