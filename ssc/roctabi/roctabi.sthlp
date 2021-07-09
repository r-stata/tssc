{smcl}
{* *! version 1.0.0 29Dec2015}{...}
{title:Title}

{p2colset 5 16 21 2}{...}
{p2col:{hi:roctabi} {hline 2}} Nonparametric ROC analysis using summarized data{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:roctabi} {it:#1_1} {it:#1_2} [{it:...}] {cmd:\} {it:#2_1} {it:#2_2}
[{it:...}] [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt :{opt row:label(string)}}create a label for row variable; default label is {cmd:row}{p_end}
{synopt :{opt col:label(string)}}create label for column variable; default label is {cmd:col}{p_end}
{synopt:{opt lor:enz}}report Gini and Pietra indices{p_end}
{synopt:{opt bino:mial}}calculate exact binomial confidence intervals{p_end}
{synopt:{opt d:etail}}show details on sensitivity/specificity for each
cutpoint{p_end}
{synopt:{opt bam:ber}}calculate standard errors by using the Bamber
method{p_end}
{synopt:{opt han:ley}}calculate standard errors by using the Hanley
method{p_end}
{synopt:{opt g:raph}}graph the ROC curve{p_end}
{synopt:{opt noref:line}}suppress plotting the 45-degree reference line{p_end}
{synopt:{opt sum:mary}}report the area under the ROC curve{p_end}
{synopt:{opt spec:ificity}}graph sensitivity versus specificity{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is
{cmd:level(95)}{p_end}

{syntab:Plot}
{synopt:{cmdab:plotop:ts(}{it:{help roctab##plot_options:plot_options}}{cmd:)}}affect 
        rendition of the ROC curve{p_end}

{syntab:Reference line}
{synopt:{opth rlop:ts(cline_options)}}affect rendition of the reference
line{p_end}

{syntab:Add plots}
{synopt:{opth "addplot(addplot_option:plot)"}}add other plots to generated
graph{p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall}
{synopt:{it:twoway_options}}any options other than {opt by()} documented
in {manhelpi twoway_options G-3}{p_end}
{synoptline}
{p2colreset}{...}
{marker weight}{...}



{marker plot_options}{...}
{synoptset 25}{...}
{synopthdr:plot_options}
{synoptline}
INCLUDE help gr_markopt2
INCLUDE help gr_clopt
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt roctabi} is the immediate form of the official Stata command {manhelp roctab R}. {opt roctabi} is used to perform receiver operating characteristic
(ROC) analyses with rating and discrete classification data.

{pstd}
In {opt roctabi}, {it:row} values indicate the true (binary) state of the observation, such as diseased and nondiseased, or normal and abnormal. {it:Column} values represent
the rating or outcome of the diagnostic test, or predicted class from a classification algorithm, and must be at least ordinal, with higher values indicating higher risk.
As such, the data must be entered in a 2 X {it:k} format representing the reference [row] variable, and classifier [column] variable. Rows are separated by '{cmd:\}'.

{pstd}
{opt roctabi} performs nonparametric ROC analyses. By default, {opt roctabi} calculates the area under the ROC curve, and displays the data in tabular form. Optionally,
{opt roctabi} can plot the ROC curve, and produce Lorenz-like plots.

{pstd}
See {manhelp roctab R} for the non-immediate form of {opt roctabi} and {manhelp rocfit R} for a command that fits maximum-likelihood ROC models.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt rowlabel(string)} creates a label for the row ({it:reference}) variable; default label is {cmd:row}.

{phang}
{opt collabel(string)} creates a label for the column ({it:classification}) variable; default label is {cmd:column}.

{phang}
{opt lorenz} specifies that the Gini and Pietra indices be reported.
Optionally, {opt graph} will plot the Lorenz-like curve.

{phang}
{opt binomial} specifies that exact binomial confidence intervals be
calculated.

{phang}
{opt detail} outputs a table displaying the sensitivity, specificity, the
percentage of subjects correctly classified, and two likelihood ratios for
each possible cutpoint of {it:classvar}.

{phang}
{opt bamber} specifies that the standard error for the area under the
ROC curve be calculated using the method suggested by 
{help roctabi##B1975:Bamber (1975)}.
Otherwise, standard errors are obtained as suggested by
{help roctabi##DDC1988:DeLong, DeLong, and Clarke-Pearson (1988)}.

{phang}
{opt hanley} specifies that the standard error for the area under the
ROC curve be calculated using the method suggested by 
{help roctabi##HM1982:Hanley and McNeil (1982)}.
Otherwise, standard errors are obtained as suggested by 
{help roctabi##DDC1988:DeLong, DeLong, and Clarke-Pearson (1988)}.

{phang}
{opt graph} produces graphical output of the ROC curve. If {opt lorenz}
is specified, the graphical output of a Lorenz-like curve will be produced.

{phang}
{opt norefline} suppresses plotting the 45-degree reference line
from the graphical output of the ROC curve.

{phang}
{opt summary} reports the area under the ROC curve, its standard error,
and its confidence interval. If {opt lorenz} is specified, Lorenz indices are
reported.  This option is needed only when also specifying {opt graph}.

{phang}
{opt specificity} produces a graph of sensitivity versus specificity
instead of sensitivity versus (1 - specificity).  {opt specificity} implies
{opt graph}.

{phang}
{opt level(#)} specifies the confidence level, as a percentage,
for the confidence intervals. The default is {cmd:level(95)} or as set by
{helpb set level}.

{dlgtab:Plot}

{phang}
{opt plotopts(plot_options)}
affects the rendition of the plotted ROC curve -- the curve's plotted points
connected by lines.  The {it:plot_options} can affect the size and color of
markers, whether and how the markers are labeled, and whether and how the
points are connected; see {manhelpi marker_options G-3},
{manhelpi marker_label_options G-3}, and {manhelpi cline_options G-3}.

{dlgtab:Reference line}

{phang}
{opt rlopts(cline_options)} affects the rendition of the reference line; see
{manhelpi cline_options G-3}.

{dlgtab:Add plots}

{phang}
{opt addplot(plot)} provides a way to add other plots to the
generated graph; see {manhelpi addplot_option G-3}.

{dlgtab:Y axis, X axis, Titles, Legend, Overall}

{phang}
{it:twoway_options} are any of the options documented in
{manhelpi twoway_options G-3}, excluding {opt by()}.  These include options for
titling the graph (see {manhelpi title_options G-3}) and for saving the
graph to disk (see {manhelpi saving_option G-3}).


{marker examples}{...}
{title:Examples}

    Nonparametric ROC analysis example


{pstd} A 2 x 5 table (produces the same results as those in the {manhelp roctab R} help file).{p_end}
{phang2}{cmd:. roctabi 33 6 6 11 2 \ 3 2 2 11 33, row(true disease status of subject) col(classification value assigned by reviewer)} {p_end}	
{phang2}{cmd:. roctabi 33 6 6 11 2 \ 3 2 2 11 33, row(true disease status of subject) col(classification value assigned by reviewer) graph summary} {p_end}	
{phang2}{cmd:. roctabi 33 6 6 11 2 \ 3 2 2 11 33, row(true disease status of subject) col(classification value assigned by reviewer) lorenz graph} {p_end}	
{phang2}{cmd:. roctabi 33 6 6 11 2 \ 3 2 2 11 33, row(true disease status of subject) col(classification value assigned by reviewer) detail} {p_end}	

	
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:roctabi} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(se)}}standard error for the area under the ROC curve{p_end}
{synopt:{cmd:r(lb)}}lower bound of CI for the area under the ROC curve{p_end}
{synopt:{cmd:r(ub)}}upper bound of CI for the area under the ROC curve{p_end}
{synopt:{cmd:r(area)}}area under the ROC curve{p_end}
{synopt:{cmd:r(pietra)}}Pietra index{p_end}
{synopt:{cmd:r(gini)}}Gini index{p_end}


{marker references}{...}
{title:References}

{marker B1975}{...}
{phang}
Bamber, D. 1975. The area above the ordinal dominance graph and the area below
the receiver operating characteristic graph.
{it:Journal of Mathematical Psychology} 12: 387-415.

{marker DDC1988}{...}
{phang}
DeLong, E. R., D. M. DeLong, and D. L. Clarke-Pearson. 1988. Comparing the
areas under two or more correlated receiver operating characteristic curves:
A nonparametric approach. {it:Biometrics} 44: 837-845.

{marker HM1982}{...}
{phang}
Hanley, J. A., and B. J. McNeil. 1982.  The meaning and use of the area under
a receiver operating characteristic (ROC) curve. {it:Radiology} 143: 29-36.
{p_end}


{marker citation}{title:Citation of {cmd:roctabi}}

{p 4 8 2}{cmd:roctabi} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2016). roctabi: Stata module for performing nonparametric ROC analysis using summarized data.
{browse "http://ideas.repec.org/c/boc/bocode/s458131.html":http://ideas.repec.org/c/boc/bocode/s458131.html}
{p_end}



{title:Author}

{p 4 8 2}       Ariel Linden{p_end}
{p 4 8 2}       President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         

{title:Also see}

{p 4 8 2} Online: {helpb roctab}, {helpb classtabi} (if installed) {helpb looclass} (if installed) {p_end}

