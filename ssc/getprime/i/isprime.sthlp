{smcl}
{* *! Version 1.0.1 17 April 2014}{...}
{cmd:help isprime}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:isprime} {hline 2}}Determine whether a number is prime or not{p_end}
{p2colreset}{...}

{title:Syntax}
{* p 8 17 2}
{phang}{cmd:isprime} {it:number} [{cmd:,} {opt p:rint}]{p_end}

{title:Description}

{pstd}{cmd:isprime} determines whether the specified {it:number} is a prime
number or not. It returns 1 if it is, and 0 if it is not.

{title:Options}

{phang}{opt p:rint} specifies that the results are to be printed.

{title:Examples}

{phang}{stata "isprime 500" : . isprime 500}{p_end}
{phang}{stata "return list" : . return list}{p_end}

{phang}{stata "isprime 229, p" : . isprime 229, p}{p_end}
{phang}{stata "return list" : . return list}{p_end}

{title:Stored results}

{pstd}
{cmd:isprime} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(prime)}}1 if {it:number} is prime 0 if it is not{p_end}
{synopt:{cmd:r(rnum)}}The {it: number} queried.{p_end}
{p2colreset}{...}

{title:Author}

{phang}Alfonso S{c a'}nchez-Pe{c n~}alver{p_end}
{phang}Lock Haven University of Pennsylvania{p_end}
{phang}Lock Haven, PA USA{p_end}
{marker email}{...}
{phang}asp155@lhup.edu{p_end}

{* Version 1.0.1 2014-04-17}

