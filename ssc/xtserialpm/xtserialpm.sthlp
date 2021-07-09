{smcl}
{* *! version 1.0 24apr2019}{...}
{cmd:help xtserialpm}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:xtserialpm} {hline 2}}{title:Jochmans (2019) test for serial correlation in panel-data models}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:xtserialpm} {depvar} [{indepvars}]  {ifin} {cmd:,} {opt center}

{synoptset 19 tabbed}
{marker semiparopts}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt centre}}Specifies that a centered covariance matrix should be used {p_end}


{synoptline}
{p2colreset}{...}




{title:Description}

{pstd}{opt xtserialpm} performs the portmanteau test developed in Jochmans (2019). The procedure tests for serial correlation  in the errors of a linear panel model after estimation of the regression coefficients by the within-group estimator. Unbalanced data is allowed.

{title:Saved results}

{pstd}
{cmd:xtserialpm} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(stat)}}the test statistic{p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}


{title:References}

{phang}Jochmans, K. (2019).  Testing for Correlation in Error-Component Models.
{it:Cambridge Working Paper in Economics 19/10}.

{phang}Jochmans, K. and V. Verardi (2019).  xtserialpm: A portmanteau test for serial correlation in a linear panel model.
{it:Mimeo}.


{title:Authors}

{pstd}Koen Jochmans, University of Cambridge; and Vincenzo Verard, FNRS-UNamur{p_end}


{title:Also see}

{p 7 14 2}Help:  {helpb xtserial} (if installed){p_end}
{p 7 14 2}Help:  {helpb xtistest} (if installed){p_end}
