{smcl}
{cmd:help mata elabel_numlist()}
{hline}

{title:Title}

{phang}
{cmd:elabel_numlist()} {hline 2} Parse numeric list


{title:Syntax}

{p 8 24 2}
{it:real colvector} 
{cmd:elabel_numlist(}{it:string scalar {help numlist}}[{cmd:,}
{it:real scalar integer}{cmd:,}
{it:real scalar nosysmiss}]{cmd:)}

{p 8 24 2}
{it:real scalar}{bind:   }
{cmd:_elabel_numlist(}{it:nlist}{cmd:,} 
{it:string scalar {help numlist}}[{cmd:,}
{it:real scalar integer}{cmd:,}
{it:real scalar nosysmiss}]{cmd:)}


{p 4 10 2}
where {it:numlist} contains {it:{help numlist:numlist_elements}} 
and may contain sequences of missing value codes, such as 
{cmd:.a/.c} and {cmd:.a(3).o}.

{p 10 12 2}
The type of {it:nlist} is irrelevant and it is replaced 
with a {it:real colvector}.


{title:Description}

{pstd}
{cmd:elabel_numlist()} expands a {it:string scalar} that contains a numeric 
list including sequence operators. The function returns the same thing as 
Stata's {helpb nlist:numlist} command but additionally expands sequences 
of (extended) missing value codes, such as {cmd:.a/.c}, treating the 
distance between successive missing value codes as 1. If {it:integer}!=0, 
only integer values are allowed in {it:numlist}; if {it:nosysmiss}!=0, 
system missing values ({cmd:.}) are not allowed in {it:numlist}.

{pstd}
{cmd:_elabel_numlist()} does the same thing but places the expanded numeric 
list as a {it:real colvector} in {it:nlist} and returns the error code.


{title:Conformability}

    {cmd:elabel_numlist(}{it:numlist}[{cmd:,} {it:integer}{cmd:,} {it:nosysmiss}]{cmd:)}
             {it:input}:
                     {it:numlist}: 1 {it:x} 1
                     {it:integer}: 1 {it:x} 1
                   {it:nosysmiss}: 1 {it:x} 1
            {it:result}:           {it:r x} 1
		
    {cmd:_elabel_numlist(}{it:nlist}{cmd:,} {it:numlist}[{cmd:,} {it:integer}{cmd:,} {it:nosysmiss}]{cmd:)}
             {it:input}:
                     {it:numlist}: 1 {it:x} 1
                       {it:nlist}: {it:r x} 1
                     {it:integer}: 1 {it:x} 1
                   {it:nosysmiss}: 1 {it:x} 1
            {it:output}:
                       {it:nlist}: {it:r x} 1


{title:Diagnostics}

{pstd}
{cmd:elabel_numlist()} exits with Stata return code 121 if 
{it:numlist} is not a valid numlist, with return code 126 if 
{it:numlist} contains noninteger values, and with return code 
127 if {it:numlist} contains system missing values.

{pstd}
{cmd:_elabel_numlist()} places in {it:nlist}, J(0, 1, .) and returns 
the respective error code if {it:numlist} is not a valid numlist.


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
Online: {helpb mata}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
