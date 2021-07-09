{smcl}
{* *! version 2.0.1  27jul2013}{...}
{viewerjumpto "Syntax" "vam##syntax"}{...}
{viewerjumpto "Description" "vam##description"}{...}
{viewerjumpto "Options" "vam##options"}{...}
{viewerjumpto "Author" "vam##author"}{...}
{viewerjumpto "Acknowledgements" "vam##acknowledgements"}{...}
{viewerjumpto "References" "vam##references"}{...}
{title:Title}

{p2colset 5 12 21 2}{...}
{p2col :{hi:vam} {hline 2}}Computes teacher value-added (VA) measures{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:vam}
{it:depvar}, {bf:teacher}(varname) {bf:year}(varname) {bf:class}(varname)
[{it:options}]


{synoptset 22 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opth teacher(varname)}}teacher identifier{p_end}
{synopt :{opth year(varname)}}year identifier{p_end}
{synopt :{opth class(varname)}}class identifier{p_end}

{syntab :Model}
{synopt :{opth by(varlist)}}perform VA estimation separately for each by-group{p_end}
{synopt :{opth controls(varlist)}}residualize {it:depvar} on a control vector{p_end}
{synopt :{opth absorb(varname)}}residualize {it:depvar} on absorbed fixed effects{p_end}
{synopt :{opth tfx_resid(varname)}}absorb fixed effects during {it:depvar} residualization, but include those fixed effects in the residual{p_end}

{syntab :Output}
{synopt :{opth output(filename)}}specifies file to save VA estimates (.dta), variance estimates (.csv), and log (.smcl){p_end}
{synopt :{opth data:(vam##data_suboptions:data_suboptions)}}specifies the dataset loaded at termination; default is to restore initial dataset{p_end}

{syntab :Advanced}
{synopt :{opt quasi:experiment}}generate leave-2-year-out and leave-5-year-out VA estimates{p_end}
{synopt :{opt driftlimit(#)}}estimate only # autocovariances; set all further autocovariances equal to the last estimate{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt vam} uses student-level outcomes (typically test scores) to compute teacher value-added (VA) measures.
The estimation procedure accounts for drift in teacher VA over time.

{pstd}
{opt vam} must be run on a dataset of student-level scores, with one row per student-year(-{it:byvars}),
and identifiers for teacher, classroom and year.

{pstd}
For each teacher, {opt vam} estimates the best linear prediction of value-added in each observed year,
based on the scores of students taught by that teacher in other years (prior and future).  Each teacher's VA
is not assumed to be fixed over time; drift is accounted for by permitting the coefficients on score data to
vary non-parametrically according to the distance between each observed score and the forecast year.

{pstd}
The computed VA estimates are stored in a variable named {it:tv}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}{opth teacher(varname)} specifies the variable that contains teacher identifiers.

{phang}{opth year(varname)} specifies the variable that contains year identifiers. In theory, a different
unit of time could be used (e.g. semesters), so long as the variable remains an integer.

{phang}{opth class(varname)} specifies the variable that contains class identifiers. A classroom is defined as a
teacher-year(-{it:byvars})-class cell.  Observations with the same class identifier but different teachers, years
or by-variables are considered to be different classrooms.

{dlgtab:Model}

{phang}{opth by(varlist)} causes the VA estimation to be performed separately for each by-group. For
example, one may wish to compute VA separately by(subject).  All steps of the VA estimation are performed separately for each
by-group; the output is equivalent to running {cmd:vam} separately on each group and then appending the results
together.

{phang}{opth controls(varlist)} residualizes the {it:depvar} on a set of controls (e.g. lagged scores)
before it is used to estimate teacher VA.  The VA estimates will therefore represent the effect of
teachers' on the component of the {it:depvar} that is orthogonal to the controls.

{phang}{opth absorb(varlist)} residualizes the {it:depvar} on fixed effects for an absorbed categorical
variable. This option cannot be combined with {opt tfx_resid()}.

{phang}{opth tfx_resid(varlist)} residualizes the {it:depvar} on fixed effects for an absorbed
categorical variable, then adds the estimated fixed effects back to the residuals. This option
was designed with teacher fixed effects in mind.  By including teacher fixed effects in this way,
the coefficients on the other controls are estimated purely from within-teacher variation.  This
option cannot be combined with {opt absorb()}.

{dlgtab:Output}

{phang}{opth output(filename)} saves three files: a dataset of VA estimates ({it:filename.dta}), a table
of variance/covariance estimates ({it:filename_variance.csv}), and a log ({it:filename_log.smcl}).

{phang}{opth data:(vam##data_suboptions:data_suboptions)} specifies a dataset to be loaded at termination:

{marker data_suboptions}{...}{p2colset 12 34 36 12}
{p2col :{it:data_suboptions}}dataset loaded at termination{p_end}
{synoptline}
{p2col :preserve}initial dataset (default setting){p_end}
{p2col :tv}VA estimates{p_end}
{p2col :variance}variance/covariance estimates{p_end}
{p2col :merge tv}initial dataset, with VA estimates merged on{p_end}
{p2col :merge score_r}initial dataset, with score residuals merged on{p_end}
{p2col :merge tv score_r}initial dataset, with both VA estimates & score residuals merged on{p_end}
{synoptline}
{p2colreset}{...}


{dlgtab:Advanced}

{phang}{opt quasi:experiment} generates three additional leave-out VA measures, which are used for
quasi-experimental tests in the paper cited below.  The default {it:tv} variable contains standard
leave-year-out (jackknife) VA estimates.
This option adds:

{p2col 8 9 11 2:}{it:tv_2yr_l}, which leaves out the forecast year and the prior year{p_end}
{p2col 8 9 11 2:}{it:tv_2yr_f}, which leaves out the forecast year and the following year{p_end}
{p2col 8 9 11 2:}{it:tv_ss}, which leaves out the forecast year, two prior years, and two following years{p_end}

{phang}{opt driftlimit(#)} instructs the program to estimate the autocovariance between year-mean scores only up to # years
apart; the autocovariance for observations that are further apart is set equal to the estimate for observations that are #
years apart.  {opt driftlimit()} is useful if the autocovariance vector converges to a steady state, but sample attrition
causes the autocovariance for distant years to be estimated imprecisely.  Additionally, {opt driftlimit()} is necessary for
out-of-sample predictions where one attempts to predict VA in years that are further apart than any scores observed in the data.


{marker author}{...}
{title:Author}

{pstd}Michael Stepner{p_end}
{pstd}stepner@mit.edu{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}This program was written and tested under the guidance of John Friedman and Raj Chetty.
It implements the VA estimation methods described in Appendix A of their paper, cited below.

{pstd}Additionally, frequent reference was made to an earlier VA estimation program, written by Jessica Laird and Heather Sarsons.


{marker references}{...}
{title:References}

{marker CFR2013}{...}
{phang}Chetty, Raj, John N. Friedman, and Jonah E. Rockoff. 2013.
{it:Measuring the Impacts of Teacher I: Evaluating Bias in Teacher Value-Added Estimates.} Harvard University Working Paper.

