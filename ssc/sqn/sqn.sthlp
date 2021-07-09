{smcl}
{* *! version 1.1.0  7Mars2013}{...}
{cmd:help sqn}{right: ({browse "http://www.stata-journal.com/article.html?article=st0001":SJ15-1: st0001})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{cmd:sqn} {hline 2}}Rousseeuw and Croux (1993) robust measure of dispersion{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:sqn} {varname} {ifin}


{title:Description}

{pstd}
{cmd:sqn} estimates Qn, a robust measure of dispersion based on pairwise
comparisons of data points.  Qn consistently estimates the standard deviation
for Gaussian data.  Compared with other robust measures of dispersion --
interquartile range and median absolute deviation -- Qn is at least as
resistant to outliers but more efficient (for Gaussian data).

{pstd}
When estimating dispersion parameters, please see {manhelp summarize R}
for classical estimators.


{title:Example}

{pstd}Setup{p_end}
{phang2}{bf:. {stata "webuse auto"}}{p_end}

{pstd}Estimating measure of dispersion Qn {p_end}
{phang2}{bf:. {stata "sqn price"}}{p_end}


{title:Stored results}

{pstd}
{cmd:sqn} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(qn)}}Qn dispersion statistic{p_end}

{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Reference}

{phang}
Rousseeuw, P. J., and C. Croux. 1993.  Alternatives to the median absolute
deviation.  {it:Journal of the American Statistical Association} 88:
1273-1283.


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
