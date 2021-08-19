{smcl}
{* *! Version 1.0 08FEB2021}{...}

{title:Title}

{phang}
{bf:qpair} {hline 2} Analysis of paired Q-sorts
    

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qpair} {ifin}
{cmd:,}
{cmdab:fir:st(varlist)} {cmdab:sec:ond(varlist)} {cmdab:nfa:ctor(#)} [{cmdab:ext:raction(string)} {cmdab:rot:ation(string)} 
{cmdab:app:roach(string)} {cmdab:sco:re(string)} {cmdab:es:ize(string)} {cmdab:bip:olar(string)} {cmdab:stl:ength(#)}] 

{p}
{bf:varlist} includes Q-sorts that need to be factor-analyzed.

{title: Description}

{pstd}
{cmd:qpair} performs by-person factor analysis on paired Q-sorts. The command performs factor analysis on pairs of Q-sorts (matched Q-sorts) using either principal factor, iterated principal factor, or principal-component factor extraction methods. 
{cmd:qpair} is also able to rotate factors using all factor rotation techniques available in Stata (orthogonal and oblique) including varimax, quartimax, equamax, obminin, and promax. 
{cmd:qpair} displays the eigenvalues of the correlation matrix, the factor loadings, and the uniqueness of the variables. It also provides number of Q-sorts loaded on each factor, distinguishing statements for each factor, and consensus statements. 
{cmd:qpair} is able to handle bipolar factors and identify distinguishing statements based on {it:Cohen's effect size (d)}.

{pstd}
Variables used in {cmd:qpair} are Q-sorts. {cmd:qpair} is able to extract factors for subgroup of Q-sorts using “if” and “in” options. 

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt first(varlist)}}Q-sorts from the first set (Q-sorts from time 1 or baseline){p_end}
{synopt :{opt second(varlist)}}Q-sorts from the second set (Q-sorts from time 2 or follow-up ){p_end}
{synopt :{opt nfactor(#)}}maximum number of factors to be retained{p_end}

{synopt :{opt extraction(string)}}factor extraction method which includes:{p_end}
{synoptline}
      {bf:pf}             		principal factor
      {bf:pcf}            		principal-component factor
      {bf:ipf}           		iterated principal factor; the default
      
{synopt :{opt rotation(string)}}{cmd:qpair} accommodates almost every rotation technique in Stata including:{p_end}
{synoptline}
{synopt:{opt none}}this option is used if no rotation is required{p_end}
{synopt:{opt varimax}}varimax; {ul:varimax is the default option}{p_end}
{synopt:{opt quartimax}}quartimax{p_end}
{synopt:{opt equamax}}equamax{p_end}
{synopt:{opt promax(#)}}promax power # (implies oblique); default is promax(3){p_end}
{synopt:{opt oblimin(#)}}oblimin with gamma=#; default is oblimin(0){p_end}
{synopt:{opt target(Tg)}}rotate toward matrix Tg; this option accommodates theoretical rotation{p_end}

{synopt :{opt approach(string)}}the analysis can be coducted using the following two approaches:{p_end}
{synoptline}
{synopt:{opt one, 1, or I}}the analysis is conducted on the differenes between Q-sorts from time 1 and time 2; {ul:this is the default option}{p_end}
{synopt:{opt two, 2, or II}}Q-sorts from time one are used as the baseline Q-sorts{p_end}

{synopt :{opt sco:re(string)}}it identifies how the factor scores to be calculated. The options include:{p_end}
{synoptline}
{synopt:{opt brown}}factor scores are calculated as described by Brown (1980); {ul:the default approach}.{p_end}
{synopt:{opt r:egression }}regression scoring method{p_end}
{synopt:{opt b:artlett}}Bartlett scoring method{p_end}
{synopt:{opt t:hompson}}Thompson scoring method{p_end}

{synopt :{opt es:ize(string)}}it specifies how the distinguishing statements to be identified for each factor. The options include:{p_end}
{synoptline}
{synopt:{opt stephenson}}distinguishing statements are identified based on Stephenson's formula as described by Brown (1980); {ul:this is the default option}.{p_end}
{synopt:{opt any #}}for any # between zero and one (0<#≤1) distinguishing statements are identified based on Cohen's d.{p_end}

{synopt :{opt bip:olar(string)}}defines the criteria for a bipolar factor, it calculates the factor scores for each bipolar factor seperately. This option works only with Brown’s factor scores. The options include:{p_end}
{synoptline}
{synopt:{opt 0 or no}}indicates no assessment of a bipolar factor; {ul:the default approach}{p_end}
{synopt:{opt any #}}any integer number more than 0 indicates number of negative loadings required for a bipolar factor.{p_end}

{synopt :{opt stl:ength(#)}}it identifies the maximum length of characters for each statement to be displayed; {ul:the default length is 50 characters}.{p_end}

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
This reestimates the communalities iteratively. {ul:ipf is the default approach}.


{title:Saved results}

{phang}
In addition to the displayed results, qpair saves a data file ({bf:FactorLoadings.dta}) in the working directory for subsequent use. The variables included in this file are Qsort (Qsort number), unrotated and rotated factor 
loadings, unique (for the uniqueness of each Qsort), h2 (communality of the extracted factors), 
Factor (which indicates which Q-sort was loaded on which factor). This file may be used for 
subsequent analysis, e.g. producing loading-based graphs.


{title:Examples of qpair}

{phang} 
{bf:qpairdata.dta:} This dataset includes perceptions of 50 IT professionals on person-organization fit with training and development priorities (Wingreen & Blanton 2018). Each IT professional completed two Q-sorts, one Q-sort for the person’s priorities and one Q-sort for the organization's priorities. The organizational priorities are the basically the person’s subjective perception or understanding of the organizational priorities. 
The study was conducted using 27 statements. Q-sorts are named Q-sort1_1, Q-sort2_1,…, Q-sort50_1 for person's priorities and Q-sort1_2, Q-sort2_2,…, Q-sort50_2 for organization's priorities.{p_end} 

{phang}
The following commands conduct analysis using {bf:approach I} to extract 3 {bf:ipf} factors using varimax rotation:{p_end}

{phang2}
{bf:qpair, first(qsort*_1) second(qsort*_2) nfa(3)}

{phang}
or

{phang2}
{bf:qpair, first(qsort1_1-qsort50_1) second(qsort1_2-qsort50_2) nfa(3)}

{phang}
The same as above using pcf extraction and esize 0.50:

{phang2}
{bf:qpair, first(qsort*_1) second(qsort*_2) nfa(3) ext(pcf) esize(.50)}

{phang}
Same as above with varimax rotation but if there is 2 or more negative loadings on any factor it treats it as a bipolar factor:

{phang2}
{bf:qpair, first(qsort*_1) second(qsort*_2) nfa(3) ext(pcf) esize(.50) bip(2)}

{phang}
The following command runs qpair on only 30 Q-sorts to extract 3 {bf:ipf} factors using varimax rotation:

{phang2}
{bf:qpair, first(qsort1_1-qsort30_1) second(qsort1_2-qsort30_2) nfa(3) ext(ipf)}

{phang}
Same as above but to display only a maximum of 25 characters for each statement:

{phang2}
{bf:qpair, first(qsort1_1-qsort30_1) second(qsort1_2-qsort30_2) nfa(3) ext(ipf) stlength(25)}

{phang}
The following commands conducts analysis using {bf:approach II} to extract 3 {bf:pcf} factors using varimax rotation:{p_end}

{phang2}
{bf:qpair, first(qsort*_1) second(qsort*_2) nfa(3) app(II) ext(pcf)}

{phang}
Same as above to use {bf:regression} factor scores

{phang2}
{bf:qpair, first(qsort*_1) second(qsort*_2) nfa(3) app(II) ext(pcf) score(regression)}

{title:Stored results: Useful for Stata programmers}

    {bf:qpair} stores the following in e():

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

{pstd}
{bf:Akhtar-Danesh, N., & Wingreen, SC.} How to analyze change in perception from paired Q-sorts. {it:Communication in Statistics- Theory and Methods}. 2020;doi:10.1080/03610926.2020.1845734

{pstd}
{bf:Wingreen, SC., & Blanton, JE.} IT professionals' person–organization fit with IT training and development priorities. {it:Information Systems Journal}. 2018;28(2):294-317.
