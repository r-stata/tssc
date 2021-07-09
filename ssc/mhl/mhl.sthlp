{smcl}
{* *! version 1.1.0  7Mars2013}{...}
{cmd:help mhl}{right: ({browse "http://www.stata-journal.com/article.html?article=st0001":SJ15-1: st0001})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{cmd:mhl} {hline 2}}Hodges and Lehman (1963) robust measure of location{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:mhl} {varname} {ifin}


{title:Description}

{pstd}
{cmd:mhl} estimates the Hodges-Lehman (HL) (1963) measure of location.  HL is
a robust measure of location based on the pairwise comparison of data points.
HL consistently estimates the mean in the case of Gaussian data.  In comparison
with the median -- the classical robust measure of location -- HL is less
resistant to outliers but more efficient (for Gaussian data).

{pstd}
When estimating location parameters, please see {manhelp summarize R} for
classical estimators.


{title:Example}

{pstd}Setup{p_end}
{phang2}{bf:. {stata "webuse auto"}}{p_end}

{pstd}Estimating location parameter HL{p_end}
{phang2}{bf:. {stata "mhl price"}}{p_end}


{title:Stored results}

{pstd}
{cmd:mhl} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(hl)}}HL location statistic{p_end}

{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Reference}

{phang}
Hodges, J. L., Jr., and E. L. Lehmann. 1963. Estimates of location based
on ranks tests.  {it:Annals of Mathematical Statistics} 34: 598-611.


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

{p 5 14 2}Manual:  {manlink R summarize}{p_end}
