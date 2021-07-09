{smcl}
{* *! version 2.0.1 12Jul2018}{...}
{* *! version 2.0.0 03Oct2017}{...}
{* *! version 1.0.1 29May2016}{...}
{* *! version 1.0.0 29Dec2015}{...}
{title:Title}

{p2colset 5 18 21 2}{...}
{p2col:{hi:classtabi} {hline 2}} Classification statistics and table using summarized data {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Manual entry of values

{p 8 17 2}
{cmd:classtabi} {it:#a #b #c #d} [{cmd:,} {opt row:label}{it:(string)} {opt col:label}{it:(string)}]


{pstd}
Referring to a saved 2 X 2 matrix

{p 8 17 2}
{cmd:classtabi} {it:matname} [{cmd:,} {opt row:label}{it:(string)} {opt col:label}{it:(string)}]


{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt row:label(string)}}create label for row variable; default label is {cmd:row}{p_end}
{synopt :{opt col:label(string)}}create label for column variable; default label is {cmd:col}{p_end}
{synoptline}

{p 4 6 2}
{p2colreset}{...}				
	
{title:Description}

{pstd}
{cmd:classtabi} reports various summary statistics, including a 2 x 2 table for discrete classification data. {cmd:classtabi} is 
helpful in cases where only summarized data are available. For example, data-mining software generally produce a 2 X 2 classification table (referred to as
{it: confusion matrix}) as part of the output. Those values can then be entered into {cmd:classtabi} to produce the additional classification statistics.   

{title:Remarks}

{pstd}
In {cmd:classtabi}, row values indicate the true (binary) state of the observation, such as diseased and nondiseased, or normal and abnormal. Column values represent
the binary rating or outcome of the diagnostic test, or predicted class from a classification algorithm. As such, when manually entering the four values (syntax 1), 
the data should be entered as follows (for example, we use disease as the reference [row] variable, and diagnostic test outcome as the classifier [column] variable):{p_end} 

{pstd}
-------------------------------------------------------------------------------------- {p_end}
{pstd}
{it:#a} -- disease=0, test=0 (true negative) | {it:#b} -- disease=0, test=1 (false positive) {p_end}
{pstd}
-------------------------------------------------------------------------------------- {p_end}
{pstd}
{it:#c} -- disease=1, test=0 (false negative)| {it:#d} -- disease=1, test=1 (true positive){p_end}
{pstd} 
-------------------------------------------------------------------------------------- {p_end}

{pstd}
To use the second syntax (syntax 2), the four values must be saved in a 2 X 2 matrix (see example below).

{pstd}
In addition to the conventional indices of classification accuracy, {cmd:classtabi} includes the {it:effect strength for sensitivity} (ESS), introduced by Yarnold and 
Soltysik (2005). ESS is a chance-corrected (0 = the level of accuracy expected by chance) and maximum-corrected (100 = perfect, errorless prediction) index of 
predictive accuracy. The formula for computing ESS for binary case classification is:{p_end} 

{pstd}
ESS = [(Mean Percent Accuracy in Classification –50)]/ 50 x 100%, {p_end}

{pstd}
where {p_end}

{pstd}
Mean Percent Accuracy in Classification = (sensitivity + specificity)/2 x 100. {p_end}
  
{pstd}
Yarnold and Soltysik (2005) consider ESS values less than 25% to indicate a relatively weak, 25% to 50% to indicate a moderate, 50% to 75% to indicate a relatively strong, 
and 75% or greater to indicate a strong effect.{p_end}


{title:Options}

{p 4 8 2}
{cmd:rowlabel(}{it:string}{cmd:)} creates a label for the row ({it:reference}) variable; default label is {cmd:row}.

{p 4 8 2}
{cmd:collabel(}{it:string}{cmd:)} creates a label for the column ({it:classification}) variable; default label is {cmd:column}.
		

{title:Examples}

{pstd}Entering values manually{p_end}

{phang2}{cmd:. classtabi 1231 397 50 324}{p_end}

{phang2}{cmd:. classtabi 1554 74 234 140, row(actual disease status) col(predicted disease status)}{p_end}

{pstd}Referring to a matrix{p_end}

{phang2}{cmd:. matrix input B = (1554 74\234 140)}{p_end}

{phang2}{cmd:. classtabi B, row(actual disease status) col(predicted disease status)}{p_end}


{title:Stored results}

{pstd}
{cmd:classtabi} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(P_corr)}}percent correctly classified{p_end}
{synopt:{cmd:r(P_p1)}}sensitivity{p_end}
{synopt:{cmd:r(P_n0)}}specificity{p_end}
{synopt:{cmd:r(P_0p)}}false-positive rate{p_end}
{synopt:{cmd:r(P_1n)}}false-negative rate{p_end}
{synopt:{cmd:r(P_1p)}}positive predictive value{p_end}
{synopt:{cmd:r(P_0n)}}negative predictive value{p_end}
{synopt:{cmd:r(roc)}}ROC curve{p_end}
{synopt:{cmd:r(ess)}}effect strength for sensitivity{p_end}
{p2colreset}{...}


{title:Acknowledgments}

{p 4 4 2}
Adam Ross Nelson suggested that {cmd:classtabi} accept matrix arguments, and Nicholas J. Cox supplied some elegant code to do just that!
Anders Alexandersson found a bug when the user enters a zero into any cell, and Daniel Klein found the source of the bug and provided a simple fix. 
Bruce Weaver noted an error in the output label for "Correctly classified". {p_end}


{title:References}

{p 4 8 2}
Linden A. (2006) Measuring diagnostic and predictive accuracy in disease management: an introduction to receiver operating characteristic (ROC) analysis. 
{it:Journal of Evaluation in Clinical Practice} 12: 132-139.{p_end}

{p 4 8 2}
Yarnold, P. R., and R. C. Soltysik. (2005) {it:Optimal data analysis: A Guidebook with Software for Windows}. Washington, DC: APA Books. 


{marker citation}{title:Citation of {cmd:classtabi}}

{p 4 8 2}{cmd:classtabi} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2015). classtabi: Stata module for generating classification statistics and table for summarized data. 
 {browse "http://ideas.repec.org/c/boc/bocode/s458127.html":http://ideas.repec.org/c/boc/bocode/s458127.html}{p_end}


{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         

{title:Also see}

{p 4 8 2} Online: {helpb estat classification}, {helpb roccomp}, {helpb roctabi} (if installed), {helpb looclass} (if installed), {helpb kfoldclass} (if installed){p_end}

