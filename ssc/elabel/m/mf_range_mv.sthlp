{smcl}
{cmd:help mata range_mv()}
{hline}

{title:Title}

{phang}
{cmd:range_mv()} {hline 2} Real vector over range


{title:Syntax}

{p 8 12 2}
{it:real colvector} 
{cmd:range_mv(}{it:real scalar a}{cmd:,}
{it:real scalar b}{cmd:)}

{p 8 12 2}
{it:real colvector} 
{cmd:range_mv(}{it:real scalar a}{cmd:,}
{it:real scalar b}{cmd:,}
{it:real scalar d}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:   }
{cmd:_range_mv(}{it:R}{cmd:,}
{it:real scalar a}{cmd:,}
{it:real scalar b}{cmd:)}

{p 8 12 2}
{it:real scalar}{bind:   }
{cmd:_range_mv(}{it:R}{cmd:,}
{it:real scalar a}{cmd:,}
{it:real scalar b}{cmd:,}
{it:real scalar d}{cmd:)}


{p 4 10 2}
where either none or both {it:a} and {it:b} may be missing value codes 
{cmd:.}, {cmd:.a}, {cmd:.b}, ..., {cmd:.z}.

{p 10 12 2}
The type of {it:R} is irrelevant because it is replaced with a real column 
vector.


{title:Description}

{pstd}
{cmd:range_mv()} is similar to {helpb mata range:range()} (but restricted 
to real numbers) and returns a column vector from {it:a} to <={it:b} 
({it:b}>{it:a}) or >={it:b} ({it:b}<{it:a}) in steps of 
{cmd:abs(}{it:d}{cmd:)}. The function returns the same result as Stata's 
{helpb nlist:numlist} command. The sign of {it:d} is irrelevant; if not 
specified, {it:d} defaults to {it:d}=1.

{pstd}
{cmd:_range_mv()} does the same as above but places the resulting column 
vector into {it:R} and returns the error code.

{pstd}
The ordering of missing value codes is as usual

{phang2}
{cmd:.} < {cmd:.a} < {cmd:.b} < ... < {cmd:.z}

{pstd}
and, additionally, the distance between successive missing values is set 
to 1. Thus, {cmd:range_mv(., .c)} returns (. \ .a \ .b \ .c) and 
{cmd:range_mv(., .c, 3)} returns (. \ .c). When {it:a} and {it:b} are 
missing, {it:d} is interpreted as {helpb mata trunc():trunc(d)}.


{title:Conformability}

    {cmd:range_mv(}{it:a}{cmd:,} {it:b}{cmd:,} {it:d}{cmd:)}
            {it:a}: 1 {it:x} 1
            {it:b}: 1 {it:x} 1
            {it:d}: 1 {it:x} 1
       {it:result}: {it:r x} 1
		
    {cmd:_range_mv(}{it:R}{cmd:,} {it:a}{cmd:,} {it:b}{cmd:,} {it:d}{cmd:)}
        {it:input}:   
            {it:a}: 1 {it:x} 1
            {it:b}: 1 {it:x} 1
            {it:d}: 1 {it:x} 1
       {it:output}:
            {it:R}: {it:r x} 1
       {it:result}: 1 {it:x} 1		
		
		
{title:Diagnostics}

{pstd}
{cmd:range_mv()} aborts with error if {it:d} contains missing 
or 0, or if only one of {it:a} or {it:b} contain missing.

{pstd}
{cmd:_range_mv()} places in {it:R}, {cmd:J(0, 1, .)} and returns 
!=0 if {it:d} contains missing or 0, or if only one of {it:a} or 
{it:b} contain missing.


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
Online: {helpb mata}, {helpb mata tokenget:range()}
{p_end}
