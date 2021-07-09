{smcl}
{cmd:help mata tokendiscard()}
{hline}

{title:Title}

{phang}
{cmd:tokendiscard()} {hline 2} Discard successive tokens


{title:Syntax}

{p 8 12 2}
{it:void} 
{cmd:tokendiscard(}{it:t}{cmd:,} {it:real scalar n}{cmd:)}


{p 4 8 2}
where {it:t} is a parsing environment obtained from 
{helpb mata tokenget:tokeninit()} or 
{helpb mata tokenget:tokeninitstata()}.


{title:Description}

{pstd}
{cmd:tokendiscard()} discards the next {helpb mf_abs:abs({it:n})} 
tokens from {it:t}. If {it:n}>=., all tokens are discarded.


{title:Conformability}

    {cmd:tokendiscard(}{it:t}{cmd:,} {it:n}{cmd:)}
            {it:t}: {it:transmorphic}
            {it:n}: 1 {it:x} 1
			
		
{title:Diagnostics}

{pstd}
None.


{title:Source code}

{pstd}
Distributed with the {cmd:elabel} package.
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mata}, {helpb mata tokenget:tokenget()}
{p_end}
