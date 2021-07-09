{smcl}
{* *! version 1.0.0  26jun2011}{...}
{cmd:help xtmixed_corr}
{hline}

{title:Title}

{p2colset 5 18 22 2}{...}
{synopt:{cmd:xtmixed_corr}} {hline 2} Model-implied intracluster correlations after {helpb xtmixed}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:xtmixed_corr} [{cmd:,} {it:{help xtmixed_corr##options:options}}]


{synoptset 18 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{syntab:Main}
{synopt:{cmd:at(}{it:{help xtmixed_corr##atspec:at_spec}}{cmd:)}}specify level values; the default is the first level-two cluster{p_end}
{synopt:{cmd:all}}correlations for all the data{p_end}
{synopt:{cmd:list}}list model data corresponding to displayed correlations{p_end}
{synopt:{cmd:nosort}}list matrices in the row order as listed in the data{p_end}
{synopt:{cmd:format(}{it:format}{cmd:)}}specify display format{p_end}
{synopt :{it:matlist_options}}style options for displaying matrices;
see {helpb matlist:[P] matlist}{p_end}
{synoptline}


{title:Description}

{pstd}
Linear mixed models as fit by {cmd:xtmixed} have complex expressions for
intracluster correlation.  Correlation comes from two sources:  (1) 
the design of the random effects and their assumed covariance 
from the multiple levels in your model; and (2) the correlation structure of
the residuals, whether they be treated as independent, auto-regressive,
Toeplitz, etc.  Residuals may also be modeled as heteroskedastic; see
{helpb xtmixed} for details.

{pstd}
{cmd:xtmixed_corr} is designed to combine all sources of correlation
into one overall correlation matrix for a given cluster (or for a given
group of clusters, if you wish).  This allows you to compare different
multilevel models in terms of the ultimate intracluster correlation matrix
that each model implies.


{title:Options}

{dlgtab:Main}

{marker atspec}{...}
{phang}{opt at(at_spec)}, where {it:at_spec} is

{phang3}
{it:level_var} {cmd: = } {it:value} [{it: level_var} {cmd: = } {it:value} ...]

{pmore}
specifies the cluster of observations for which you want the intracluster 
correlation matrix.  

{pmore}
For example, if you specify

{phang3}
{cmd:. xtmixed_corr, at(school = 33)}

{pmore}
you get the intracluster correlation matrix for those observations 
in school 33.  If  you specify,

{phang3}
{cmd:. xtmixed_corr, at(school = 33 classroom = 4)}

{pmore}
you get the correlation matrix for classroom 4 in school 33.

{pmore}
If {cmd:at()} is not specified, then you get the correlations
for the first level-two cluster encountered in the data.  This is
usually what you want.

{phang}{opt all} specifies that you want the correlation matrix for all 
the data.  This is not recommended unless you have a relatively small dataset
or you enjoy seeing large N x N matrices.  However, this can prove
useful in some cases.

{phang}{opt list} lists the model data for those observations depicted in 
the displayed correlation matrix.  This option is useful if you have many 
random-effects design variables (Z's in {cmd:xtmixed} terminology) and you 
wish to see the represented values of these design variables.

{phang}{opt nosort} lists the rows and columns of the correlation matrix in 
the order that they were originally present in the data.  Normally,
{cmd:xtmixed_corr} will first sort the data according to level variables,
by-group variables, and time variables in order to produce correlation matrices
whose rows and columns follow a natural ordering.  {opt nosort} 
suppresses this.

{phang}{opt format(format)} sets the display format for the
standard-deviation vector and correlation matrix.  The default is 
{cmd:%6.3f}.

{phang}
{it:matlist_options} control how matrices are displayed.  See 
{helpb matlist:[P] matlist} for details.


{title:Remarks}

{pstd}
The intracluster variance-covariance matrix is given by V = Z*Psi*Z' +
R, where Z is the design matrix for the random effects, Psi is the
variance-covariance matrix of the random effects, and R is the residual
variance-covariance matrix.  {cmd:xtmixed_corr} performs this
calculation for the data subset that you specify and displays the
resulting standard deviations and correlations based on V.


{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse pig, clear}{p_end}

{pstd}Random-intercept model, analogous to {cmd:xtreg}{p_end}
{phang2}{cmd:. xtmixed weight week || id:}{p_end}
{phang2}{cmd:. xtmixed_corr}{p_end}

{pstd}Random-intercept and random-slope (coefficient) model{p_end}
{phang2}{cmd:. xtmixed weight week || id: week, cov(un)}{p_end}
{phang2}{cmd:. xtmixed_corr, at(id = 33)}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse productivity, clear}{p_end}

{pstd}Three-level model, observations nested within {cmd:state} nested within {cmd:region}{p_end}
{phang2}{cmd:. xtmixed gsp private emp hwy water other unemp || region: ||}
           {cmd:state:}{p_end}
{phang2}{cmd:. xtmixed_corr, at(region = 2 state = 28)}{p_end}
{phang2}{cmd:. xtmixed_corr, at(region = 2) format(%5.2f)}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse pig, clear}{p_end}

{pstd}Crossed random effects{p_end}
{phang2}{cmd:. xtmixed weight week || _all: R.week || id:}{p_end}
{phang2}{cmd:. xtmixed_corr}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use http://www.stata-press.com/data/mlmus2/wagepan, clear}{p_end}
{phang2}{cmd:. gen educt = educ - 12}{p_end}
{phang2}{cmd:. gen yeart = year - 1980}{p_end}

{pstd}Linear mixed model with AR 1 errors{p_end}
{phang2}{cmd:. xtmixed lwage black hisp union yeart educt || nr:, nocons res(ar 1, t(yeart))}{p_end}
{phang2}{cmd:. xtmixed_corr}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ovary, clear}{p_end}
{phang2}{cmd:. keep if time<=7}{p_end}

{pstd}Linear mixed model with MA 2 errors{p_end}
{phang2}{cmd:. xtmixed follicles sin1 cos1 || mare: sin1, residuals(ma 2, t(time))}{p_end}
{phang2}{cmd:. xtmixed_corr, list}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse childweight, clear}{p_end}

{pstd}Linear mixed model with heteroskedastic error variances{p_end}
{phang2}{cmd:. xtmixed weight age || id:age, cov(un) residuals(independent, by(girl))}{p_end}
{phang2}{cmd:. xtmixed_corr, list}{p_end}
{phang2}{cmd:. xtmixed_corr, at(id=4108) list}{p_end}

    {hline}


{title:Saved results}

{pstd}
{cmd:xtmixed_corr} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(sd)}}standard deviations{p_end}
{synopt:{cmd:r(corr)}}correlation{p_end}
{synopt:{cmd:r(V)}}variance-covariance{p_end}
{synopt:{cmd:r(psi)}}variance-covariance of random effects{p_end}
{synopt:{cmd:r(Z)}}model-based design matrix{p_end}
{synopt:{cmd:r(R)}}variance-covariance matrix of level-one errors{p_end}


{title:Also see}

{psee}
{space 2}Help:  {manhelp xtmixed XT:xtmixed}; {manhelp xtmixed_postestimation XT:xtmixed postestimation}
{p_end}
