{smcl}
{* *! version 1.1.0  7Mars2013}{...}
{cmd:help robjb}{right: ({browse "http://www.stata-journal.com/article.html?article=st0001":SJ15-1: st0001})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:robjb} {hline 2}}Brys, Hubert, and Struyf (2008) robust Jarque-Bera normality test{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:robjb} {varname} {ifin} [{cmd:,} {opt level(#)} {{opt s:kewness}|{opt k:urtosis}} {opt r:ight}]


{title:Description}

{pstd}
{cmd:robjb} tests the normality of a given variable using a modified
Jarque-Bera (1980) statistic.  Like the standard Jarque-Bera test, the
test is based on the variable's asymmetry ({cmd:skewness}) and tail
heaviness ({cmd:kurtosis}).  However, rather than relying on classical
estimators for skewness and kurtosis, the robust Jarque-Bera statistic
relies on robust estimates of asymmetry and tail heaviness using 
{helpb medcouple}.

{pstd}
{cmd:robjb}, without options, relies both on asymmetry and on tail
heaviness to perform the test of normality.  Using the option
{cmd:skewness}, the test is based exclusively on asymmetry; using
{cmd:kurtosis}, it is based on the heaviness of both tails; and using
{cmd:right}, the test is based only on the heaviness of the right tail.

{pstd}
When testing for normality, please see {helpb jb6} for the equivalent
classical estimators.


{title:Options}

{phang}
{opt level(#)} specifies the confidence level for inference.  The
default is {cmd:level(0.95)}.

{phang}
{opt skewness} specifies that a test exclusively based on skewness be run.

{phang}
{opt kurtosis} specifies that a test exclusively based on the
heaviness of the tails be run.

{phang}
{opt right} specifies that a test exclusively based on the heaviness
of the right tail be run.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{bf:. {stata "webuse auto"}}{p_end}

{pstd}Testing for normality{p_end}
{phang2}{bf:. {stata "robjb price"}}{p_end}

{pstd}Testing for normality exclusively relying on skewness{p_end}
{phang2}{bf:. {stata "robjb price, skewness"}}{p_end}

{pstd}Testing for normality exclusively relying on the heaviness of the tails{p_end}
{phang2}{bf:. {stata "robjb price, kurtosis"}}{p_end}


{title:Stored results}

{pstd}
{cmd:robjb} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(T)}}test statistic T{p_end}
{synopt:{cmd:r(Chi2)}}critical value{p_end}
{synopt:{cmd:r(dof)}}degrees of freedom{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}


{title:References}

{phang}
Brys, G., M. Hubert, and A. Struyf. 2008. Goodness-of-fit tests based on
a robust measure of skewness.  {it:Computational Statistics} 23:
429-442.

{phang}
Jarque, C. M., and A. K. Bera. 1980. Efficient tests for normality,
homoscedasticity and serial independence of regression residuals.
{it:Economics Letters} 6: 255-259.


{title:Authors}

{pstd}Wouter Gelade{p_end}
{pstd}University of Namur{p_end}
{pstd}CRED{p_end}
{pstd}Namur, Belgium{p_end}
{pstd}wouter.gelade@unamur.be{p_end}

{pstd}Vincenzo Verardi{p_end}
{pstd}University of Namur{p_end}
{pstd}CRED{p_end}
{pstd}Namur, Belgium{p_end}
{pstd}and Universit{c e'} libre de Bruxelles{p_end}
{pstd}ECARES and iCite{p_end}
{pstd}Brussels, Belgium{p_end}
{pstd}vincenzo.verardi@unamur.be

{pstd}Catherine Vermandele{p_end}
{pstd}Universit{c e'} libre de Bruxelles{p_end}
{pstd}LMTD{p_end}
{pstd}Brussels, Belgium{p_end}
{pstd}catherine.vermandele@ulb.ac.be


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 1: {browse "http://www.stata-journal.com/article.html?article=st0001":st0001}

{p 5 14 2}Manual:  {manlink  R swilk}

{p 7 14 2}Help:  {helpb jb6} (if installed){p_end}
