{smcl}
{* *! version 1.0.0 12july2019}{...}
{title:Title}

{p2colset 5 16 17 2}{...}
{p2col :{hi:adftest} {hline 2}}series of Augmented Dickey-Fuller test along
with the Breusch-Godfrey autocorrelation test{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 22 2}
{cmd:adftest} {varname} {ifin} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nocon:stant}}suppress constant term in regression{p_end}
{synopt:{opt tr:end}}include trend term in regression{p_end}
{synopt:{opt dr:ift}}include drift term in regression{p_end}
{synopt:{opth adf:lags(numlist)}}include {it:numlist} augmentations{p_end}
{synopt:{opth bg:lags(numlist)}}test {it:numlist} lag orders{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Since {opt adftest} uses {help dfuller} function, you must {help tsset} your data
{p_end}
{p 4 6 2}
before using {opt adftest}; see {it:varname} may contain time-series operators;
{p_end}
{p 4 6 2}
see {help tsvarlist}.
{p_end}


{title:Description}

{pstd}{cmd:adftest} performs Dickey-Fuller unit root test and displays
the results along with the Breusch-Godfrey autocorrelation test results. 
The null hypothesis of the Dickey-Fuller test is that the variable 
is non-stationary, while the alternative is that the variable is 
stationary. Optional arguments allow to include a trend term, exclude 
the drift term, and add augmentations in the regression. The Breusch-Godfrey
test is a test of the null hypothesis of the lack of serial correlation
in the disturbance.


{title:Options}

{dlgtab:Main}

{phang}{opt noconstant} suppresses the constant term (intercept) in 
the model and indicates that the process under the null hypothesis 
is a random walk without drift. By default, the constant term is 
excluded from the regression. It may not be used with the {opt drift}
or {opt trend} option.

{phang}{opt trend} specifies that a trend term be included in 
the associated regression and that the process under the null 
hypothesis is a random walk, perhaps with drift. It may not be used 
with the {opt noconstant} or {opt drift} option.

{phang}{opt drift} indicates that the process under the null hypothesis
is a random walk with nonzero drift. It may not be used 
with the {opt noconstant} or {opt trend} option.

{phang}{opth adflags(numlist)} defines a list of augmentations, that is
number of lagged differences that appear in the right-hand-side of
the regression. By default, no lags are used, equivalently to lags(0), thus 
(not-augmented) Dickey-Fuller test is performed.

{phang}{opth bglags(numlist)} specifies a list of numbers, indicating 
the lag orders to be tested. The test will be performed separately for 
each order. By default this test is not performed.
 

{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "sysuse sp500, clear" : . sysuse sp500, clear}{p_end}
{phang2}{stata "bcal create sp500, from(date) generate(bussdate) replace" : . bcal create sp500, from(date) generate(bussdate) replace}{p_end}
{phang2}{stata "tsset bussdate" : . tsset bussdate}{p_end}

{pstd}Test whether {cmd:close} follows a unit-root process{p_end}
{phang2}{stata "adftest close, adflags(0) bglags(1/4)" : . adftest close, adflags(0) bglags(1/4)}{p_end}

{pstd}Perform 4 Dickey-Fuller tests with augmentations 0/3 supressing the constant term{p_end}
{phang2}{stata "adftest close, adflags(0/3) bglags(1/4) noconst" : . adftest close, adflags(0/3) bglags(1/4) noconst}{p_end}

{pstd}Same as above, but for {cmd:close} first-differenced{p_end}
{phang2}{stata "adftest D.close, adflags(0/3) bglags(1/4) noconst" : . adftest D.close, adflags(0/3) bglags(1/4) noconst}{p_end}

{pstd}Same as above, with extended {it:numlists} of both arguments{p_end}
{phang2}{stata "adftest D.close, adflags(0/3 10) bglags(1/4 12) noconst" : . adftest D.close, adflags(0/3 10) bglags(1/4 12) noconst}{p_end}


{title: Stored results}

{pstd}
{cmd:adftest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Martix}{p_end}
{synopt:{cmd:r(results)}}matrix of displayed results{p_end}
{p2colreset}{...}


{title:Author}

{phang}Piotr Wojcik, Faculty of Economic Sciences, University of Warsaw
proposed the original R function.{p_end}

{phang}Rafal Wozniak, Faculty of Economic Sciences, University of Warsaw
translated the original R function into STATA and added some modifications.{p_end}
{p 8 6 2}rwozniak@wne.uw.edu.pl{p_end}


{title:Additional info}

{phang}Some parts of the description were copied from help files of 
{help dfuller} and {help estat bgodfrey}. The reason was not to cause
any confusion among users.
