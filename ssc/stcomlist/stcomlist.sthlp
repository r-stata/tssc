{smcl}
{* *! version 1.3 11jan2016}{...}

{title:Title}

{phang}
{bf:stcomlist} {hline 2} list cumulative incidence function (CIF) in presence of competing risks


{title:Syntax}

{p 8 17 2}
{cmd:stcomlist} {ifin}, compet1({help numlist}) [{it:other_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:required}
{synopt:{opth compet1(numlist)}}failure value(s) for first competing risk{p_end}

{syntab:other options}
{synopt:{opth compet2(numlist)}}failure value(s) for second competing risk{p_end}
{synopt:{opth compet3(numlist)}}failure value(s) for third competing risk{p_end}
{synopt:{opth compet4(numlist)}}failure value(s) for fourth competing risk{p_end}
{synopt:{opth compet5(numlist)}}failure value(s) for fifth competing risk{p_end}
{synopt:{opth compet6(numlist)}}failure value(s) for sixth competing risk{p_end}
{synopt:{opth at(numlist)}}timepoint(s) at which to list CIF{p_end}
{synopt:{opth by(varname)}}list CIF separately by groups defined by this variable{p_end}
{synopt:{opt allign:ol}}alternative confidence interval estimation{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is level(95){p_end}
{synopt:{opt noci}}do not calculate standard errors and confidence intervals{p_end}
{synopt:{bf:saving(}{help filename}[, {bf:replace}]{bf:)}}save results to {it:filename}; use replace to overwrite existing filename{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stcomlist}; see
{manhelp stset ST}.{p_end}


{title:Description}

{pstd}
{cmd:stcomlist} uses the SSC command
{net "describe stcompet, from(http://fmwww.bc.edu/RePEc/bocode/s)":stcompet} to calculate
the cumulative incidence function (CIF) and confidence intervals in the presence of
competing risks. It then lists the CIF at specific time points analogously to the official
{help sts list} command.


{title:Options}

{phang}
{opth compet1(numlist)} is required and specifies the failure value(s) for the first
competing risk. The failure variable {it:failvar} and value(s) denoting the main outcome
of interest must have already been declared using {manhelp stset ST}. This option
specifies the value(s) that denote the first competing failure.

{phang}
{opt compet2-compet6} specify value(s) denoting additional competing failures.

{phang}
{opth at(numlist)} specifies the timepoint(s) at which to list the CIF. The list must
contain positive numbers in ascending order. If not specified, the default is to list all
the timepoints at which the CIF increases

{phang}
{opth by(varname)} calculates CIFs and confidence intervals for the groups defined by
{it:varname}

{phang}
{opt allign:ol} alternative confidence interval estimation; see {help stcompet}

{phang}
{opt level(#)} specifies the confidence level, as a percentage

{phang}
{opt noci} prevents the calculation of standard errors and confidence intervals, which
results in much faster execution

{phang}
{bf:saving(}{help filename}[, {bf:replace}]{bf:)} saves the results in a Stata data
file ({bf:.dta} file).

{pmore}
{bf:replace} specifies that filename be overwritten if it exists.


{title:Remarks}

{pstd}
{cmd:stcomlist} is intended to be a "competing risks" version of the official
{help sts list} command. It uses the SSC program
{net "describe stcompet, from(http://fmwww.bc.edu/RePEc/bocode/s)":stcompet}
to calculate cumulative incidence functions (CIFs) for each competing outcome, optionally
in groups, and reports the CIFs along with confidence intervals.

{pstd}
If the {bf:saving()} option is used to save the results, the resulting dataset will
contain the CIFs for each competing outcome at each timepoint. The original failure event
specified in {bf: stset} will be recorded with {it:compet}==0, and the competing outcomes
will be recorded with {it:compet} corresponding to the {bf:compet()} option. For example,
with two possible failure types, the one specified using {bf:stset} will have
{it:compet}==0 and the one specified by {bf:compet1()} will have {it:compet}==1.


{title:Example}

{phang}{cmd:. webuse hypoxia}{p_end}
{phang}{cmd:. stset dftime, failure(failtype==1)}{p_end}
{phang}{cmd:. stcomlist, compet1(2) at(1 5) by(pelvicln)}{p_end}


{title:Author}

{pstd}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au{p_end}
