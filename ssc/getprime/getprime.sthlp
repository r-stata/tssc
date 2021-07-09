{smcl}
{* *! Version 1.0.1 17 April 2014}{...}
{cmd:help getprime}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:getprime} {hline 2}}Gets the prime number closer to the specified
	number{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}{cmd:getprime} {it:number} [{cmd:,} {opt a:bove} {opt pr:int} 
	{opt sca:lar(name)}]{p_end}

{title:Description}

{pstd}{cmd:getprime} gets the prime number that is closer to {it:number}.

{pstd}This becomes useful, for example, when wanting to have about a certain
number of draws for simulation. In particular for Hemmersley and Halton
sequences it's better to make the number of draws prime. This way you just enter
the number of draws you want as {it:number} and {cmd:getprime} finds the prime
number closer to it, whether above or below depending on whether you specified
{opt a:bove} or not. I'm sure you will find many other applications.

{pstd}{cmd:getprime} uses, and thus requires, the command {cmd:isprime}.

{title:Options}

{phang}{opt a:bove} specifies that the prime number ought to be larger than
	{it: number}. If omitted, {cmd:getprime} gets the prime number closer to
	{it:number} but below it.{p_end}

{phang}{opt pr:int} specifies that {cmd:getprime} displays the retrieved prime
	number, and whether it is greater or lower than {it:number}, depending on
	whether {opt a:bove} was specified or not.{p_end}

{phang}{opt sca:lar(name)} allows you to specify the name of a scalar to hold
	the prime number so you can use it later.{p_end}

{title:Examples}

{phang}{stata "getprime 500" : . getprime 500}{p_end}
{phang}{stata "return list" : . return list}{p_end}

{phang}{stata "getprime 350, above" : . getprime 350, above}{p_end}
{phang}{stata "return list" : . return list}{p_end}

{phang}{stata "getprime 230, a pr" : . getprime 230, a pr}{p_end}
{phang}{stata "return list" : . return list}{p_end}

{phang}{stata "getprime 125, a sca(prime)" : . getprime 125, a sca(prime)}{p_end}
{phang}{stata "display prime" : . display prime}{p_end}

{title:Stored results}

{pstd}
{cmd:getprime} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(pnum)}}The prime number.{p_end}
{synopt:{cmd:r(rnum)}}The submitted {it: number}.{p_end}
{p2colreset}{...}

{title:Author}

{phang}Alfonso S{c a'}nchez-Pe{c n~}alver{p_end}
{phang}Lock Haven University of Pennsylvania{p_end}
{phang}Lock Haven, PA USA{p_end}
{marker email}{...}
{phang}asp155@lhup.edu{p_end}

{* Version 1.0.1 2014-04-17}

