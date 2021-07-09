{smcl}
{* *! version 1.1  08sep2014}{...}
{hline}
help for {cmd:xmiss}{right:Version 1.1, 8 September 2014}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col: {bf:xmiss}}{hline 2} Cross-tabulation of missing data

{title:Syntax}

{p 8 18 2}
{opt xmiss} {it:byvar missvar} {ifin} [, {opt s:ort} {opt replace}]

{phang}{opt by} may be used with {cmd:xmiss}; see {helpb by}.{p_end}


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt s:ort}}display results in ascending order of missingness{p_end}
{synopt:{opt replace}}replace the dataset with the missing data table{p_end}


{title:Description}

{pstd}{bf:xmiss} tabulates the frequency and percentage of missing values in {it:missvar} by levels of {it:byvar}.{p_end}


{title:Example}

{phang}{cmd:. sysuse nlsw88}{p_end}
{phang}{cmd:. xmiss race union}{p_end}
{phang}{cmd:. xmiss race union if age<40, sort}{p_end}


{title:Author}

{p 4 4 2}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au

