{smcl}

{title:Title}

{phang}
{bf:sicff} {hline 2} Create Fama French Industry Variable from SIC Code


{title:Syntax}

{p 8 17 2}
{cmd:sicff}
{varname}
{cmd:,} industry(#)
[generate(newvar)]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth ind:ustry(#)}}choose which Fama French industry you want to create; options are 5, 10, 12, 17, 30, 38, 48, or 49.{p_end}
{synopt:{opth gen:erate(newvar)}}create variable named {it:newvar}; default name for {it:newvar} is {it:ff_#}.{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:sicff} takes a 4-digit numeric SIC code ({it:varname}) and creates a new variable that contains one of the Fama and French industries. See Ken French's website for more details on the industry classifications: http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html


{title:Examples}

{phang}{cmd:. sicff sic, ind(48)}{p_end}

{phang}{cmd:. sicff sic, ind(12) gen(ff12industry)}{p_end}


{title:Author}
Tyson Van Alfen
Email: tyson@vanalfen.io
Website: https://vanalfen.io
