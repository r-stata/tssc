{smcl}
{cmd:help corsp}
{hline}

{title:Title}

{p 5}
{cmd:corsp} {hline 2} Pearson and Spearman correlation matrix


{title:Syntax}

{p 8}
{cmd:corsp} {varlist} {ifin} [ {cmd:,} {it:options} ]


{p 5}
{helpb by} is allowed


{title:Description}

{pstd}
{cmd:corsp} displays a correlation matrix of the variables in 
{varlist}. By default, Pearson's correlation coefficients are shown 
in the lower triangle, including the diagonal, while Spearman's rank 
correlations appear above the diagonal. Optionally, {cmd:corsp} 
calculates Kendall's tau.

{pstd}
Type {cmd:corsp} without arguments to replay results.


{title:Options}

{phang}
{opt pw} calculates pairwise correlation coefficients. By default, 
casewise deletion is used.

{phang}
{opt lo:wer(coef)} and {opt up:per(coef)} specify which coefficents 
are shown below and above the diagonal. The available coefficients 
are

{p2colset 9 16 16 2}{...}
{p2col:{opt r}}Pearson correlation coefficient{p_end}
{p2col:{opt rho}}Spearman's rank correlation coefficient{p_end}
{p2col:{opt taua}}Kendall's tau_a rank correlation coefficient{p_end}
{p2col:{opt taub}}Kendall's tau_b rank correlation coefficient{p_end}

{phang}
{opt switch} displays coefficents specified in {opt lower()} 
above the diagonal and those specified in {opt upper()} in 
the lower triangle.

{phang}
{opt sig} reports p-values below each correlation coefficient. 

{phang}
{opt p:rint(#)} specifies the significant level of coefficients to 
be displayed. Coefficients with larger p-values are left blank.

{phang}
{opt b:onferroni} calculates Bonferroni-adjusted p-values.

{phang}
{opt sid:ak} calculates Sidak-adjusted p-values.

{phang}
{opt returnrp} returns the results matrix with coefficients and 
p-values combined.


{title:Examples}

{pstd}
Load example dataset

{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
Calculate Pearson and Spearman correlation matrix

{phang2}{cmd:. corsp price mpg rep78}{p_end}

{pstd}
Calculate pairwise correlations

{phang2}{cmd:. corsp price mpg rep78 , pw}{p_end}

{pstd}
Replay results, this time with Pearson correlatios 
above the diagonal

{phang2}{cmd:. corsp , lower(rho) upper(r)}{p_end}

{pstd}
Calculate Spearman's and Kendall's rank correlations 
with Bonferroni-adjusted p-values

{phang2}{cmd:. corsp price mpg rep78 , lower(rho) upper(taua) sig bonferroni}
{p_end}


{title:Saved results}

{pstd}
{cmd:corsp} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:corsp}{p_end}
{synopt:{cmd:r(lower)}}{it:coef} from {opt lower()}{p_end}
{synopt:{cmd:r(upper)}}{it:coef} from {opt upper()}{p_end}

{pstd}
Matrices{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(R)}}correlation coefficients{p_end}
{synopt:{cmd:r(P)}}two-sided p-values (possibly adjusted){p_end}
{synopt:{cmd:r(Nobs)}}number of observations used{p_end}

{synopt:{cmd:r(C)}}correlation coefficients (Pearson){p_end}
{synopt:{cmd:r(Rho)}}correlation coefficients (Spearman){p_end}
{synopt:{cmd:r(Tau_a)}}correlation coefficients (Kendall){p_end}
{synopt:{cmd:r(Tau_b)}}correlation coefficients (Kendall){p_end}
{synopt:{cmd:r(C_p)}}two-sided p-values (possibly adjusted){p_end}
{synopt:{cmd:r(Rho_p)}}two-sided p-values (possibly adjusted){p_end}
{synopt:{cmd:r(Tau_a_p)}}two-sided p-values (possibly adjusted){p_end}
{synopt:{cmd:r(Tau_b_p)}}two-sided p-values (possibly adjusted){p_end}
{synopt:{cmd:r(RP)}}coefficients and p-values ({opt returnrp} only)
{p_end}


{title:Acknowledgments}

{pstd}
Alina Sigel reported a bug on 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1371688-pearson-spearman-correlation-table-corsp-formatting-error-and-transfer-to-excel":Statalist}.

{pstd}
This problem was suggested by Ahmed Abdalla on 
{browse "http://www.stata.com/statalist/archive/2014-01/msg00345.html":Statalist} 
and an anonymous poster on 
{browse "http://www.stata-forum.de/post1967.html":Stata-Forum}.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb correlate}, {helpb spearman}
{p_end}

{psee}
if installed: {helpb corrtbl}
{p_end}
