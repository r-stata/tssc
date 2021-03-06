{smcl}
{* 3sep2015/16sep2015}{...}
{hi:help cpcorr}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:cpcorr} {hline 2}}Correlations for each row vs each column variable{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2} 
{cmd:cpcorr}
{it:rowvarlist}
{cmd:\} 
{it:colvarlist}
{weight}
{ifin}
[ 
{cmd:,}
{opt c:ovariance}
{opt s:quare}
{opt m:atrix(matname)}
{it:matlist_options} 
]

{p 8 18 2} 
{cmd:cpcorr}
{it:varlist}
{weight}
{ifin}
[ 
{cmd:,}
{opt c:ovariance}
{opt s:quare}
{opt m:atrix(matname)}
{it:matlist_options} 
]


{title:Description}

{pstd}
{cmd:cpcorr} produces a matrix of correlations for {it:rowvarlist}
versus {it:colvarlist} (first syntax) or for {it:varlist} (second
syntax). With the first syntax, the matrix may thus be oblong, and need
not be square. With the second syntax, the matrix is square. 

{pstd}
The stub {cmd:cp} is derived from Cartesian product; it may also be
interpreted as "cross pairs". 

{pstd} 
The backslash {cmd:\} must be used to separate the {it:rowvarlist} and
the {it:colvarlist} in the first syntax.
 

{title:Options}

{phang}
{opt covariance} specifies calculation of the covariance. 

{phang} 
{opt square} specifies squaring of correlations. 

{phang}
{opt matrix(matname)} specifies that the matrix produced be saved as
matrix {it:matname}. 

{phang}
{it:matlist_options} are options of {help matrix list}.  The default
includes {cmd:format(%5.4f)}. 


{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. cpcorr mpg-foreign \ price}{p_end}
{phang}{cmd:. cpcorr mpg-foreign, f(%4.2f)}{p_end}


{title:Author}

{pstd}
Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:Saved results} 

    r(N)      number of observations 
    r(C)      matrix of correlations or covariances 
    r(p)      matrix of P-values 


{title:Also see}

{p 4 4 2}Official commands:{p_end} 
{p2colset 5 27 29 2}{...}
{synopt: {bf:{help correlate:[R] correlate}}}Correlations and
covariances{p_end}
{synopt: {bf:{help graph matrix:[G-2] graph matrix}}}Scatter plot
matrices{p_end}
{p2colreset}{...}

{p 4 4 2}User-written commands (if installed):{p_end} 
{p2colset 5 27 29 2}{...}
{synopt: {bf:{help corrci}}}Correlations with confidence intervals{p_end}
{synopt: {bf:{help corrtable}}}Correlation matrix as graphical table{p_end}
{synopt: {bf:{help cpspear}}}Spearman correlations for row and column variables{p_end}
{synopt: {bf:{help crossplot}}}Twoway plots for each y vs each x variable{p_end}
{p2colreset}{...}


