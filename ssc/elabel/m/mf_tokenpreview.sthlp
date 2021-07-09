{smcl}
{cmd:help mata tokenpreview()}
{hline}

{title:Title}

{phang}
{cmd:tokenpreview()} {hline 2} Peek ahead at tokens


{title:Syntax}

{p 8 12 2}
{it:string rowvector} 
{cmd:tokenpreview(}{it:t}{cmd:)}

{p 8 12 2}
{it:string rowvector} 
{cmd:tokenpreview(}{it:t}{cmd:,} {it:real rowvector v}{cmd:)}


{p 4 10 2}
where 

{p 12 12 2}
{it:t} is a parsing environment obtained from 
{helpb mata tokenget:tokeninit()} or 
{helpb mata tokenget:tokeninitstata()}.

{p 12 12 2}
{it:v} selects from {it:t} the tokens to be previewed. 


{title:Description}

{pstd}
{cmd:tokenpreview()} is similar to {helpb mata tokenget:tokenpeek()} 
and returns tokens from {it:t} without actually getting them.

{pstd}
If {it:v} is scalar, returned is

{p 12 12 2}
{it:v}>0 the {it:v}th token

{p 12 12 2}
{it:v}<0 the {it:v}th last token

{p 12 12 2}
{it:v}=0 {cmd:""} (i.e., empty string)

{p 12 12 2}
{it:v}>=. all tokens (same as not specifying {it:v})

{pstd}
If {it:v} is 1 {it:x c}, it may not contain missing. Returned 
is 1 {it:x c} with elements according to the rules above.


{title:Conformability}

    {cmd:tokenpreview(}{it:t}{cmd:)}
            {it:t}: {it:transmorphic}
       {it:result}: 1 {it:x c}
		
    {cmd:tokenpreview(}{it:t}{cmd:,} {it:v}{cmd:)}
            {it:t}: {it:transmorphic}
            {it:v}: 1 {it:x c}
       {it:result}: 1 {it:x c}

		
{title:Diagnostics}

{pstd}
{cmd:tokenpreview()} returns {cmd:""} (i.e., empty string) for each {it:v} 
if |{it:v}|>{cmd:cols(tokengetall(}{it:t}{cmd:))}. The function aborts 
with error if {it:v} is 1 {it:x c} and contains missing.


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
