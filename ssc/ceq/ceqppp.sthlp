{smcl}
{* 15jun2015}{...}
{cmd:help ceqppp} (beta version; please report bugs) {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:ceqppp} {hline 2} Extracts numbers needed for purchasing power parity (PPP) conversion.

{title:Syntax}

{p 8 11 2}
    {cmd:ceqppp} {cmd:,} {opth c:ountry(string)} {opth b:aseyear(real)} {opth s:urveyyear(real)} [{opt l:ocals}]{break}

{synoptset 29}{...}
{synopthdr}
{synoptline}
{synopt :{opth c:ountry(string)}}Three letter country code (see {stata help wbopendata}){p_end}
{synopt :{opth b:aseyear(real)}}Base year for PPP conversion (either 2005 or 2011){p_end}
{synopt :{opth s:urveyyear(real)}}Year of household survey{p_end}
{synopt :{opt l:ocals}}Store these numbers as locals{p_end}

{title:Required commands}

{pstd} 
{cmd:ceqppp} requires installation of {cmd:wbopendata} (Azevedo, 2014). To install, {stata ssc install wbopendata}. If not installed, {cmd: ceqppp} automatically installs {cmd:wbopendata}, 
assuming there is an internet connection.

{title:Description}

{pstd} 
{cmd:ceqppp} uses {cmd:wbopendata} (Azevedo, 2014) to extract the three numbers needed to perform
purchasing power parity (PPP) conversions from local currency reported in household surveys to 
PPP dollars. It serves two purposes. First, if {opt l:ocals} is specified, the needed numbers 
are saved in the locals `ppp', `cpibase', and `cpisurvey', which can then be used directly in 
other commands from the {cmd:ceq} package that have PPP Conversion options, such as 
{cmd:ceqlorenz}, {cmd:ceqfi}, and others. Second, it can be used to quickly confirm that the 
numbers used by a country team for the PPP conversion (printed in row 3 of the sheets in the 
Master Workbook Part II Output Tables that include a PPP conversion, such as sheets E2, E3, 
etc.) match those from World Development Indicators, which {cmd:ceqppp} draws from.

{title:Examples}

{pstd}Brazil with 2009 survey, using 2005 as base year{p_end}
{phang} {cmd:. ceqppp , country("bra") baseyear(2005) surveyyear(2009) locals}{p_end}

{pstd}Then the results can be fed directly into another {cmd:ceq} command:{p_end}
{phang} {cmd:. ceqfi [pw=w] using C:/Output_Tables.xlsx, }{p_end}
{phang2} {cmd:hhid(hh_code) psu(psu_var) strata(stra_var) }{p_end}
{phang2} {cmd:m(ym) mplusp(ymplusp) n(yn) g(yg) d(yd) c(yc) f(yf) }{p_end}
{phang2} {cmd:ppp(`ppp') cpibase(`cpibase') cpisurvey(`cpisurvey') }{p_end}
{phang2} {cmd:country("Brazil") surveyyear("2008-2009")}{p_end}
{phang2} {cmd:authors("Higgins, Pereira") baseyear(2005) }{p_end}
{phang2} {cmd:open}{p_end}

{title:Author}

{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu


{title:References}

{pstd}Azevedo, J. P. 2014.  wbopendata: Stata module to access World Bank databases. Boston
College Department of Economics Statistical Software Components S457234.{p_end}

{pstd}Commitment to Equity (CEQ) {browse "http://www.commitmentoequity.org":website}.{p_end}

