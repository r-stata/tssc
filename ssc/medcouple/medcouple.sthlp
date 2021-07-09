{smcl}
{* *! version 1.1.0  7Mars2013}{...}
{cmd:help medcouple}{right: ({browse "http://www.stata-journal.com/article.html?article=st0001":SJ15-1: st0001})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:medcouple} {hline 2}}Medcouple measure of asymmetry and tail heaviness{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:medcouple} {varname} {ifin} [{cmd:,} {opt lmc} {opt rmc} {opt nomc}]



{title:Description}

{pstd}
{cmd:medcouple} estimates medcouple, a robust measure of asymmetry and tail
heaviness.

{pstd}
{cmd:medcouple}, without options, estimates the standard medcouple, which is a
robust measure of asymmetry.  Its value is always between -1 and 1.  The
medcouple is zero for symmetric distributions, while it is positive and
negative for, respectively, right- and left-tailed distributions.

{pstd}
The options {opt lmc} and {opt rmc} can be used to calculate the left and
right medcouple, respectively.  The left medcouple is a robust measure for the
heaviness of the left tail.  It estimates the medcouple for all observations
smaller than the median.  It thus measures the asymmetry of the lower half of
the distribution, which is a measure of the heaviness of the left tail.  The
right medcouple does exactly the same for all values above the median and is
thus a measure of the heaviness of the right tail.

{pstd}
To interpret the left and right medcouple, one should note that both sides of
the distribution are typically skewed, leading to values different from zero.
For both the left and right medcouple, higher values indicate heavier tails.
For comparison, the right medcouple of the standard normal is 0.2.  Values
above 0.2 thus indicate a right tail that is heavier than that of the normal.

{pstd}
When estimating asymmetry and heaviness of the tails, please see
{manhelp summarize R} for classical estimators.


{title:Options}

{phang}
{opt lmc} specifies calculating the medcouple only for observations smaller
than the median.  This is an indicator of the heaviness of the left tail.

{phang}
{opt rmc} specifies calculating the medcouple only for observations larger
than the median.  This is an indicator of the heaviness of the right tail.

{phang}
{opt nomc} specifies not to calculate the global medcouple.  This is useful
when one is interested in only the tail heaviness.


{title:Example}

{pstd}Setup{p_end}
{phang2}{bf:. {stata "webuse auto"}}{p_end}

{pstd}Estimating the medcouple measure of asymmetry{p_end}
{phang2}{bf:. {stata "medcouple price, lmc rmc"}}{p_end}


{title:Stored results}

{pstd}
{cmd:medcouple} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(mc)}}medcouple statistic{p_end}
{synopt:{cmd:e(lmc)}}left medcouple (if called by the option){p_end}
{synopt:{cmd:e(rmc)}}right medcouple (if called by the option){p_end}

{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


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
