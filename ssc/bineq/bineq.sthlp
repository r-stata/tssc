{smcl}
{* 08April2016/}{...}
{cmd:help bineq}
{hline}

{title:Title}

{p2colset 8 18 20 2}{...}
{p2col :{hi: bineq} {hline 2}}Bidimensional inequality indices and associated hypothesis tests{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:bineq}
{it:{help varname:varname1}} {it:{help varname:varname2}}
{ifin}
{cmd:,}
[{opt a:lpha(#)}
{opt b:eta(#)}
{opt t:ype(index_type)}
{opt l:evel(#)}]

{p 8 15 2}
{cmd:bineqdiff}
{it:estname1} {it:estname2}
{cmd:,}
[{opt r:estrict(matname)}
{opt n:ull(matname)}]

{title:Description}

{pstd}{cmd:bineq} is a module to analyze multidimensional inequality in the joint distribution of two different dimensions of wellbeing. Abul Naga, Shen and Yoo (2016) summarizes 
the underlying methods. To facilitate discussion, suppose that the two dimensions of interest are income and health as in the study of Zhong (2009). 
{cmd:bineq} can be used to:

{pstd} (1) estimate Tsui's (1995) bidimensional Atkinson-Kolm-Sen (AKS) or Mean Log Deviation (MLD) inequality index. Each index is a scalar that measures inequality 
in the joint distribution of income and health.

{pstd} (2) estimate Abul Naga and Geoffard's (2006) decomposition of the bidimensional AKS (MLD) index into two unidimensional AKS (MLD) indices, one measuring inequality in income 
and the other measuring inequality in health. In case of the bidimensional AKS index, this decomposition also produces a measure of association between income and health;  
Zhong (2009) argues that this association measure can be interpreted as an index of income-related inequality in health.   

{pstd} {3} use the method of Abul Naga, Shen and Yoo (2016) to obtain an asymptotic covariance matrix, hence standard errors, to carry out hypothesis tests on (1) and (2) using 
Wald-type statistics. 

{pstd} The covariance matrix and standard errors of the disaggregated indices, (2), are computed by applying the analytic formula of Abul Naga, Shen and Yoo (2016, p.140). The standard error of 
the overall index, (1), is then computed by using this covariance matrix and {stata help:nlcom}.

{pstd} {cmd:bineqdiff} is a postestimation command that tests for systematic difference between two sets of {cmd:bineq} estimates. The test statistic is based on
equation (22) of Abul Naga, Shen and Yoo (2016, p.140) and can be used, for example, to test for the urban-rural difference in inequality structure. 
{it:estname1} ({it:estname2}) refers to the name under which the first (second) set of estimates was stored using {stata help:estimates store}.

{title: Options for bineq}

{phang}
{opt a:lpha(#)} is the weight on {it:varname1} in the social welfare function. See Section 1 of Abul Naga, Shen and Yoo (2016). A larger 
absolute value of this weight reflects greater aversion to inequality in {it:varname1}. For the AKS index, changing this weight affects both overall (i.e. bidimensional) and
disaggregated (i.e. unidimensional) indices. For the MLD index, changing this weight only affects the overall index. The default for the AKS index is {bf:alpha(-1)}; 
the default for the MLD index is {bf:alpha(1)}.  

{phang}
{opt b:eta(#)} is the weight on {it:varname2} in the social welfare function. See Section 1 of Abul Naga, Shen and Yoo (2016). A larger 
absolute value of this weight reflects greater aversion to inequality in {it:varname2}. For the AKS index, changing this weight affects both overall (i.e. bidimensional) and
disaggregated (i.e. unidimensional) indices. For the MLD index, changing this weight only affects the overall index. The default for the AKS index is {bf:beta(-1)}; 
the default for the MLD index is {bf:beta(1)}. 

{phang}
{opt t:ype(index_type)} is either aks (to estimate the AKS index) or mld (to estimate the MLD index). The default is {bf:type(aks)}. 

{phang}
{opt l:evel(#)} sets confidence level. The default is {bf:level(95)}. 

{title: Options for bineqdiff}

{phang}
{opt r:estrict(matname)} supplies the name of the matrix of linear restrictions, or "A" in equation (22) of Abul Naga, Shen and Yoo (2016). The default for the AKS index is 
a 3-by-3 identity matrix; the default for the MLD index is a 2-by-2 identity matrix. 

{phang2} For the AKS index, one may set A = [1, 0, 0 \ 0, 1, 0 \ 0, 0, 1] to test for between-group differences in all three disaggregated indices; 
A = [1, 0, 0 \ 0, 1, 0] to test for between-group differences in unidimensial AKS indices; A = [1, 0, 0 \ 0, 0, 1] to test for between-group differences 
in the unidimensional AKS index of {it:varname1} and the association measure; A = [0, 1, 0 \ 0, 0, 1] to test for between-group differences in the
unidimensional AKS index of {it:varname2} and the association measure; A = [1, 0, 0] to test for between-group difference in the unidimensional AKS index of {it:varname1};
A = [0, 1, 0] to test for between-group difference in the unidimensional AKS index of {it:varname2}; and A = [0, 0, 1] to test for between-group difference in the association measure. 

{phang2} For the MLD index, one may set A = [1, 0 \ 0, 1] to test for between-group differences in all two disaggregated indices; A = [1, 0] to test for 
between-group difference in the MLD index of {it:varname1}; and A = [0, 1] to test for between-group difference in the MLD index of {it:varname2}.

{phang}
{opt n:ull(matname)} supplies the name of the row vector of the null hypotheses, or the transpose of "eta" in equation (22) of Abul Naga, Shen and Yoo (2016). 
The default for the AKS index is a 1-by-3 vector of zeroes; the default for the MLD index is a 1-by-2 vector of zeroes. In both cases, therefore, the default null 
states that there is no between-group difference. 

{phang2} When specifying a non-zero null hypothesis concerning unidimensional AKS or MLD indices, note that {cmd:bineqdiff} expects the user to specify the null 
in terms of between-group differences in unidimensional "equality" indices, even though {cmd:bineq} reports unidimensional "inequality" indices: see Section 1 of 
Abul Naga, Shen and Yoo (2016) for the algebraic relationship between equality and inequality indices.        

{title: Examples}

{pstd} Suppose that each row in the data set is an observation on a particular person. Assume further that there are three variables in the data set: 
{cmd:income} that records each person's income, {cmd:health} that records each peson's health, and {cmd:urban} that equals 1 for people who live in urban areas and 
0 for people who live in rural areas.

{pstd} The AKS and MLD analysis of inequality in income and health can be respectively executed as follows. 

{phang2}{cmd:. bineq income health} {p_end}

{phang2}{cmd:. bineq income health, type(mld)} {p_end}

{pstd} The rest of this document illustrates the use of {cmd:bineqdiff} after estimating the AKS indices. Note, however, that {cmd:bineqdiff} can also be used 
after estimating the MLD indices. Suppose now that the objective of the analysis is to test for the urban-rural difference in inequality structure. 
This can be achieved by using {cmd:bineqdiff}, once area-specific inequality indices have been obtained as follows. 

{phang2}{cmd:. bineq income health if urban == 1} {p_end}
{phang2}{cmd:. est store urban} {p_end}
{phang2}{cmd:. bineq income health if urban == 0} {p_end}
{phang2}{cmd:. est store rural} {p_end}

{pstd} To test the null that there is no urban-rural difference in all disaggregated indices, {cmd:bineqdiff} can be executed under its default settings.

{phang2}{cmd:. bineqdiff urban rural} {p_end}

{pstd} To test the null that there is no urban-rural difference in the unidimensional index of {cmd:health} and the association measure (i.e. Zhong's (2009) 
measure of income-related inequality in health), a linear restriction matrix {cmd:A} should be specified and supplied as follows. 
 
{phang2}{cmd:. matrix A = [0, 1, 0 \ 0, 0, 1]} {p_end}
{phang2}{cmd:. bineqdiff urban rural, restrict(A)} {p_end}

{pstd} Using {help bootstrap} and/or {help bsample} in conjunction with {cmd:bineq} and {cmd:bineqdiff} may improve the joint hypothesis test's size accuracy in finite samples. 
The Monte Carlo experiment of Abul Naga, Shen and Yoo (2016) reports substantial size accuracy gains from using percentile-t bootstrapping that 
compares the asymptotic test statistics produced by {cmd:bineqdiff} against bootstrapped critical values.

{title:Stored results}

{pstd}{cmd:bineq} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(alpha)}}# in {opt a:lpha(#)}{p_end}
{synopt:{cmd:e(beta)}}# in {opt b:eta(#)}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:bineq}{p_end}
{synopt:{cmd:e(alphavar)}}{it:varname1}{p_end}
{synopt:{cmd:e(betavar)}}{it:varname2}{p_end}
{synopt:{cmd:e(type)}}{it:index_type} in {opt t:ype(index_type)}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}row vector that reports disaggregated indices{p_end}
{synopt:{cmd:e(V)}}asympotic covariance matrix for disaggregated indices{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks the estimation sample{p_end}

{pstd}{cmd:bineqdiff} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(chi2)}}chi-squared test statistic{p_end}
{synopt:{cmd:r(df)}}degrees of freedom for the test statistic{p_end}
{synopt:{cmd:r(p)}}p-value for the test statistic{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(restrict)}}contents of matrix {it:matname} in {opt r:estrict(matname)}{p_end}
{synopt:{cmd:r(null)}}contents of matrix {it:matname} in {opt null(matname)}{p_end}

{p2colreset}{...}

{title:References}

{phang}
Abul Naga, R. H., Geoffard, P.-Y. 2006. Decomposition of bivariate inequality indces by attributes. {it:Economics Letters} 90: 362-367. 

{phang} 
Abul Naga, R. H., Shen, Y. and Yoo, H. I. 2016. Joint hypothesis tests for multidimensional inequality indices. {it:Economics Letters} 141: 138-142.

{phang}
Tsui, K. Y. 1995. Multidimensional generalizations of the relative and absolute inequality indices: the Atkinson-Kolm-Sen Approach. {it:Journal of Economic Theory} 67: 251-265. 

{phang}
Zhong, H. 2009. A multivariate analysis of the distribution of individual's welfare in China: What is the role of health? {it:Journal of Health Economics} 28: 1062-1070.

{title:Author}

{pstd}Dr. Hong Il Yoo{p_end}
{pstd}Durham University Business School{p_end}
{pstd}Durham University{p_end}
{pstd}Durham, UK{p_end}
{pstd}h.i.yoo@durham.ac.uk{p_end}

{title:Also see}

{p 7 14 2}
Help:  {helpb bootstrap}, {helpb bsample}
{p_end}
