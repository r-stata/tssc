{smcl}
{* *! Version 2.20 04JUN2019}{...}

{title:Title}

{phang}
{bf:qfactor} {hline 2} Q Factor analysis
    

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qfactor} {varlist} {ifin}
{cmd:,}
{cmdab:nfa:ctor(#)} [{cmdab:ext:raction(string)} {cmdab:rot:ation(string)} 
{cmdab:sco:re(string)} {cmdab:es:ize(string)} {cmdab:bip:olar(string)}] 

{p}
{bf:varlist} includes Q-sorts that need to be factor-analyzed.

{title: Description}

{pstd}
{cmd:qfactor} performs factor analysis on Q-sorts.  The command performs factor analysis based on principal 
factor, iterated principal factor, principal-component factor, and maximum-likelihood factor extraction methods. 
{cmd:qfactor} also rotate factors based on all factor rotation techniques available in Stata (orthogonal and oblique)
including varimax, quartimax, equamax, obminin, and promax. 
{cmd:qfactor} displays the eigenvalues of the correlation matrix, the factor loadings, and the uniqueness of the variables. 
It also provides number of Q-sorts loaded on each factor, distinguishing statements for each factor, and consensus statements. 
{cmd:qfactor} is able to handle bipolar factors and identify distinguishing statements based on {it:Cohen's effect size (d)}.

{pstd}
{cmd:qfactor} expects data in the form of variables and can be run for subgroups using “if” and “in” options. 

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt nfactor(#)}}maximum number of factors to be retained{p_end}
{synopt :{opt extraction(string)}}factor extraction method which includes:{p_end}
{synoptline}
      {bf:pf}             principal factor
      {bf:pcf}            principal-component factor
      {bf:ipf}            iterated principal factor; the default
      
{synopt :{opt rotation(string)}}{cmd:qfactor} accommodates almost every rotation technique in Stata including:{p_end}
{synoptline}
{synopt:{opt none}}this option is used if no rotation is required{p_end}
{synopt:{opt varimax}}varimax; {ul:varimax is the default option}{p_end}
{synopt:{opt quartimax}}quartimax{p_end}
{synopt:{opt equamax}}equamax{p_end}
{synopt:{opt promax(#)}}promax power # (implies oblique); default is promax(3){p_end}
{synopt:{opt oblimin(#)}}oblimin with gamma=#; default is oblimin(0){p_end}
{synopt:{opt target(Tg)}}rotate toward matrix Tg; this option accommodates theoretical rotation{p_end}

{synopt :{opt sco:re(string)}}it identifies how the factor scores to be calculated. The options include:{p_end}
{synoptline}
{synopt:{opt brown}}factor scores are calculated as described by Brown (1980); brown is the default approach.{p_end}
{synopt:{opt r:egression }}regression scoring method{p_end}
{synopt:{opt b:artlett}}Bartlett scoring method{p_end}
{synopt:{opt t:hompson}}Thompson scoring method{p_end}

{synopt :{opt es:ize(string)}}it specifies how the distinguishing statements to be identified for each factor. The options include:{p_end}
{synoptline}
{synopt:{opt stephenson}}distinguishing statements are identified based on Stephenson's formula as described by Brown (1980); {ul:this is the default option}.{p_end}
{synopt:{opt any #}}for any # between zero and one (0<#≤1) distinguishing statements are identified based on Cohen's d.{p_end}

{synopt :{opt bip:olar(string)}}it identifies the criteria for bipolar factor and calculates the factor scores for any bipolar factor. Currently,  bipolar() option works only with Brown’s factor scores.The options include:{p_end}
{synoptline}
{synopt:{opt 0 or no}}indicates no assessment of a bipolar factor; the default option{p_end}
{synopt:{opt any #}}any number more than 0 indicates number of negative loadings required for a bipolar factor.{p_end}

{title: Options for factor extraction}

{phang}
{opt pf}, {opt pcf}, and {opt ipf}
indicate the type of extraction to be used. The default is {opt ipf}.

{phang2}
{opt pf} 
specifies that the principal-factor method be used to analyze the correlation matrix. 
The factor loadings, sometimes called the factor patterns, are computed using the 
squared multiple correlations as estimates of the communality.  

{phang2}
{opt pcf} 
specifies that the principal-component factor method be used to analyze the correlation matrix. 
The communalities are assumed to be 1.

{phang2}
{opt ipf} 
specifies that the iterated principal-factor method be used to analyze the correlation matrix. 
This reestimates the communalities iteratively. ipf is the default.


{title:Saved results}

{phang}
In addition to the displayed results, qfactor saves a data file ({bf:FactorLoadings.dta}) in the working directory for subsequent use.
The variables included in this file are Qsort (Qsort number), unrotated and rotated factor 
loadings, unique (for the uniqueness of each Qsort), h2 (communality of the extracted factors), 
Factor (which indicates which Q-sort was loaded on which factor). This file can be used for 
subsequent analysis, e.g. producing loading-based graphs.


{title:Examples of qfactor}

{phang} 
1-{bf:mldataset.dta:} This dataset includes 40 participants on their views on marijuana legalization. 
The study was conducted using 19 statements. Suppose the dataset is transposed 
(each column represents a Q-sort) and Q-sorts are named v1, v2,…, v40. The following 
commands will conduct qfactor analysis to extract 3 principal component factors using varimax:{p_end}

{phang2}
{bf:qfactor v1-v40, nfa(3) ext(pcf)}

{phang}
or

{phang2}
{bf:qfactor v*, nfa(3) ext(pcf)}

{phang}
The same as above using quartimax rotation:

{phang2}
{bf:qfactor v*, nfa(3) ext(pcf) rot(quartimax)}

{phang}
Same as above with varimax rotation but if there is 2 or more negative loadings on any factor it treats it as bipolar factor:

{phang2}
{bf:qfactor v1-v30, nfa(3) ext(pcf) bip(2)}

{phang}
Same as above without bipolar option but Cohen's d=0.80:

{phang2}
{bf:qfactor v1-v30, nfa(3) ext(pcf) es(0.80)}

{phang}
The following command runs qfactor on only 30 Q-sorts and uses iterated principal factors (ipf) to extract 3 factors using varimax rotation:

{phang2}
{bf:qfactor v1-v30, nfa(3) ext(ipf)}

{phang2}
{bf:qfactor v1-v30, nfa(3)} 

{phang}
The same as above but with 40 Q-sorts and promax(3) rotation:

{phang2}
{bf:qfactor v1-v40, nfa(3) rot(promax(3))}

{phang}
2-	{bf:mldata2.dta} a non-transposed dataset: This non-transposed dataset includes 19 statements named v1, v2,…, v19 and 40 Q-sorts. The statement file is named Statements.dta. 
    The following commands will conduct qfactor analysis to extract 3 principal component factors and varimax rotation:{p_end}

{title:Stored results: Useful for Stata programmers}

    {bf:qfactor} stores the following in e():

    {bf:Scalars}        
      e(f)                number of retained factors
      e(evsum)            sum of all eigenvalues
      e(df_m)             model degrees of freedom
      e(df_r)             residual degrees of freedom
      e(chi2_i)           likelihood-ratio test of "independence vs. saturated"
      e(df_i)             degrees of freedom of test of "independence vs.  saturated"
      e(p_i)              p-value of "independence vs. saturated"

    {bf:Macros}         
      e(cmd)              factor
      e(cmdline)          command as typed
      e(method)           pf, pcf, or ipf
      e(wtype)            weight type (factor only)
      e(wexp)             weight expression (factor only)
      e(title)            Factor analysis
      e(mtitle)           description of method (e.g., principal factors)
      e(heywood)          Heywood case (when encountered)
      e(factors)          specified factors() option
      e(properties)       nob noV eigen
      e(rotate_cmd)       factor_rotate
      e(estat_cmd)        factor_estat
      e(predict)          factor_p
      e(marginsnotok)     predictions disallowed by margins

    {bf:Matrices}       
      e(sds)              standard deviations of analyzed variables
      e(means)            means of analyzed variables
      e(C)                analyzed correlation matrix
      e(Phi)              variance matrix common factors
      e(L)                factor loadings
      e(Psi)              uniqueness (variance of specific factors)
      e(Ev)               eigenvalues

	  
{title:Author}

{pstd}
{bf:Noori Akhtar-Danesh} ({ul:daneshn@mcmaster.ca}), McMaster University, Hamilton, CANADA

{title:Reference}

{pstd}
{bf:Akhtar-Danesh N.} qfactor: A command for Q-methodology analysis. {it:The Stata Journal}. 2018;18(2):432-446.
