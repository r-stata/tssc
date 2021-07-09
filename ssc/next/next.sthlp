{smcl}
{* *! version 1.0 30Aug2016}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "R:\Project\rd\Stata\next##syntax"}{...}
{viewerjumpto "Description" "R:\Project\rd\Stata\next##description"}{...}
{viewerjumpto "Options" "R:\Project\rd\Stata\next##options"}{...}
{viewerjumpto "Remarks" "R:\Project\rd\Stata\next##remarks"}{...}
{viewerjumpto "Examples" "R:\Project\rd\Stata\next##examples"}{...}
{title:Title}
{phang}

{p2colset 5 22 24 2}{...}
{p2col:{bf:next} {hline 2} Regression discontinuity (RD) estimator}{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{opt next} {it:outcomevar} {it:assignmentvar}
{ifin}
{cmd:,}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opth r:egtype(strings:string)}} regression type{p_end}
{synopt:{opth t:hreshold(real)}} threshold{p_end}
{synopt:{opth data_min(int)}} minimum number of data points that must be used to predict the next value{p_end}
{synopt:{opth p1(int)}} minimum order of the polynomial{p_end}
{synopt:{opth p2(int)}} maximum order of the polynomial{p_end}
{synopt:{opth base(real)}}  base weight for the weighting scheme{p_end}
{synopt:{opth mspe_min(int)}} minimum number of MSPEs that are allowed to be included in a weighted average of MSPE{p_end}
{synopt:{opth con:fidence(real)}} confidence interval{p_end}
{synopt:{opth bin_left(int)}} number of bins used set by the user{p_end}
{synopt:{opth bin_right(int)}} number of bins used set by the user{p_end}

{syntab:Reporting}
{synopt:{opt details}} print details{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{phang}
{cmd:next} simultaneously selects the polynomial specification and bandwidth
 that minimizes the predicted mean squared error at the threshold of a discontinuity. 
 It achieves this selection by evaluating the combinations of specification and bandwidth 
 that perform best in estimating the next point in the oberved sequence on each side of the 
 discontinuity. For more information on the model, see {browse "http://evans.uw.edu/profile/long":{it:Next: An Improved Method for Identifying Impacts in Regression Discontinuity Design}.}
{p_end}
 
{marker options}{...}
{title:Options}
{dlgtab:Model}

{phang}
{opth r:egtype(strings:string)} sets the regression type. Values can be {it:{help regress}}, {it:{help probit}}, or {it:{help logit}}. If not specified by user, regression type is {it:{help regress}}.{p_end}

{phang}
{opth t:hreshold(real)} sets the threshold of the discontinuity. If not specified by the user, the threshold is assumed to be 0. Note that if X=T, the observation is assumed to be to the right of the threshold. {p_end}

{phang}
{opth data_min(int)} sets the minimum number of data points that must be used to 
predict the next value in the series. Note that value should be in the range 
of 1 to min(number of distinct values of X on left of threshold-1, number of 
distinct values of X on right of threshold-1). If data_min>1, then random walk 
specification is skipped. If the user does not specify, the minimum number of 
data points is set at 5.{p_end}

{phang}
{opth p1(int)}, {opth p2(int)} sets the minimum(maximum) order of the polynomial to be tested. 
If the user does not specify, the minimum is an order of 0 and the maximum 
is an order of 5.{p_end}

{phang}
{opth base(real)} sets the base weight for the weighting scheme and should lie in the 
interval of 1 (uniform weight) to infinity. If the user does not specify, the 
base weight is set at 1000.{p_end}

{phang}
{opth mspe_min(int)} sets the minimum number of MSPEs that are allowed to be included 
in a weighted average of MSPE. Must be >=2. If the user does not specify, the 
minimum number of MSPEs is 5.{p_end}

{phang}
{opth con:fidence(real)} sets the confidence interval and can be between 0 and 100. 
If the user does not specify, the confidence interval is set at 80.{p_end}

{phang}
{opth bin_left(int)}, {opth bin_right(int)} sets the number of bins used on each side of the discontinuity. 
If set by the user, then {cmd:bin_left} and {cmd:bin_right} is set equal to 
Min(user set bin size, Min(matsize,maxvar)/(number of specifications used)-2) 
on each side of the discontinuity. If not set by the user, then the bins on each 
side of discontinuity is set equal to Min(100, number of distinct values on that 
side of the discontinuity).{p_end}


{dlgtab:Reporting}

{phang}
{opt details} prints the details of each sepcification tested by the model.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Setup (data from Jacob et al., 2012, with simulated treatment effect of -10 at threshold=215){p_end}
{col 9}{stata `"import excel using http://www.mdrc.org/sites/default/files/img/RDD_Guide_Dataset_0.xls, firstrow sheet("Data")"' : import excel using http://www.mdrc.org/sites/default/files/img/RDD_Guide_Dataset_0.xls, firstrow sheet("Data")}

{pstd}Run regression discontinuity analysis with default settings, except threshold set at 215 (as in Jacob et al., 2012){p_end}
{col 9}{stata "next posttest pretest, t(215)" : next posttest pretest, t(215)}

{title:Author}
{p}

{phang}
Mark C. Long, University of Washington (corresponding author){p_end}
{p2colset 10 22 24 2}{...}
{p2col:Email {browse "mailto:marklong@uw.edu":marklong@uw.edu}}{p_end}
{p2colreset}{...}

{phang}
Jordan Rooklyn, University of Washington{p_end}

{title:References}

{phang}
Long, M., and J. Rooklyn. 2016.
{browse "http://evans.uw.edu/profile/long":{it:Next: An Improved Method for Identifying Impacts in Regression Discontinuity Design}.}.
Working paper.
{p_end}

{phang}
Jacob, R.T., P. Zhu, M.A. Somers, and H. Bloom. 2012.
{browse "http://www.mdrc.org/sites/default/files/RDD%20Guide_Full%20rev%202016_0.pdf":{it:A Practical Guide to Regression Discontinuity}}. 
New York: MDRC.
{p_end}

{title:See Also}
{help rd} (if installed)     {stata ssc install rd} (to install this command)
