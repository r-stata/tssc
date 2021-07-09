{smcl}
{cmd:help mata aandb()}
{hline}

{title:Title}

{phang}
{cmd:aandb()} {hline 2} Manipulate row vectors


{title:Syntax}

{p 8 37 2}
{it:transmorphic rowvector} 
{cmd:aandb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}{bind:       }
{it:real rowvector} 
{cmd:_aandb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}
{it:transmorphic rowvector} 
{cmd:adups(}{it:transmorphic rowvector a}{cmd:)}

{p 8 37 2}{bind:          }
{it:real scalar} 
{cmd:aequivb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}{bind:          }
{it:real scalar} 
{cmd:ainb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}
{it:transmorphic rowvector} 
{cmd:anotb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}
{it:transmorphic rowvector} 
{cmd:aorb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}{bind:       }
{it:real rowvector} 
{cmd:aposb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}{bind:       }
{it:real rowvector} 
{cmd:_aposb(}{it:transmorphic rowvector a}{cmd:,}
{it:transmorphic rowvector b}{cmd:)}

{p 8 37 2}
{it:transmorphic rowvector} 
{cmd:auniq(}{it:transmorphic rowvector a}{cmd:)}

{p 8 37 2}{bind:       }
{it:real rowvector} 
{cmd:_auniq(}{it:transmorphic rowvector a}{cmd:)}


{p 4 10 2}
where both {it:a} and {it:b} must be of type {it:real} or {it:string}


{title:Description}

{pstd}
These functions mimic some of Stata's 
{help macro list:macro list functions}.

{pstd}
{cmd:aandb()}, read: {it:a} and {it:b}, returns the elements of {it:a} 
that are found in {it:b}. The result is equivalent to Stata's 
{cmd:list} {it:a} {cmd:&} {it:b}.

{pstd}
{cmd:_aandb()} returns a row vector indicating the elements of {it:a} 
that are found in {it:b}.

{pstd}
{cmd:adups()} returns the duplicate elements of {it:a}, omitting the first 
occurrence. The result is equivalent to Stata's {cmd:list dups} {it:a}.

{pstd}
{cmd:aequivb()} returns 1 if {it:a} has the same elements as {it:b}. The 
result is equivalent to Stata's {cmd:list} {it:a} {cmd:===} {it:b}.

{pstd}
{cmd:ainb()}, read: {it:a} in {it:b}, returns 1 if all elements of 
{it:a} are found in {it:b}, or if {cmd:cols(}{it:a}{cmd:)}==0; otherwise 
the function returns 0. The result is equivalent to Stata's 
{cmd:list} {it:a} {cmd:in} {it:b}.

{pstd}
{cmd:anotb()}, read: {it:a} not {it:b}, returns the elements of {it:a} 
not found in {it:b}. The result is equivalent to Stata's 
{cmd:list} {it:a} {cmd:-} {it:b}.

{pstd}
{cmd:aorb()}, read: {it:a} or {it:b}, returns the elements found in 
{it:a} or {it:b}; the function adds to {it:a} the elements 
of {it:b} not found in {it:a}. The result is equivalent to Stata's 
{cmd:list} {it:a} {cmd:|} {it:b}.

{pstd}
{cmd:aposb()} returns a row vector of column indices that indicate 
the positions in {it:b} where {it:a} occurs. If {it:a} is a vector, 
its starting position in {it:b} is returned. If {it:b} does not 
contain {it:a}, the function returns 0.

{pstd}
{cmd:_aposb()} returns a row vector indicating the positions in {it:b} 
where {it:a} occurs.

{pstd}
{cmd:auniq()} returns the distinct elements of {it:a}; elements in the 
returned row vector are unique. The result is equivalent to Stata's 
{cmd:list uniq} {it:a}.

{pstd}
{cmd:_auniq()} returns a row vector indicating the distinct elements 
of {it:a}.


{title:Conformability}
	   
    {cmd:aandb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c3}, {it:c3}<={it:c1}

    {cmd:_aandb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c1}
	   
    {cmd:adups(}{it:a}{cmd:)}
            {it:a}: 1 {it:x c1}
       {it:result}: 1 {it:x c2}, {it:c2}<{it:c1}
		
    {cmd:aequivb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x} 1
	   
    {cmd:ainb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x} 1
	   
    {cmd:anotb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c3}, {it:c3}<={it:c1}

    {cmd:aorb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c3}, {it:c3}>={it:c1}
	   
    {cmd:aposb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c3}, {it:c3}>=1

    {cmd:_aposb(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c2}
	   
    {cmd:auniq(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
       {it:result}: 1 {it:x c2}, {it:c2}<={it:c1}

    {cmd:_auniq(}{it:a}{cmd:,} {it:b}{cmd:)}
            {it:a}: 1 {it:x c1}
            {it:b}: 1 {it:x c2}
       {it:result}: 1 {it:x c1}
	   
	   
{title:Diagnostics}

{pstd}
{cmd:_aandb()}, if {cmd:cols(}{it:a}{cmd:)}==0 and 
{cmd:cols(}{it:b}{cmd:)}==0, returns {cmd:J(1, 0, 1)}; if 
{cmd:cols(}{it:b}{cmd:)}!=0 or if the types of {it:a} and {it:b} 
are different, the function returns {cmd:J(1, cols(}{it:a}{cmd:), 0)}. 

{pstd}
{cmd:_aposb()}, if {cmd:cols(}{it:a}{cmd:)}==0 and 
{cmd:cols(}{it:b}{cmd:)}==0, returns {cmd:J(1, 0, 1)}; if 
{cmd:cols(}{it:b}{cmd:)}!=0 or if the types of {it:a} and {it:b} 
are different, the function returns {cmd:J(1, cols(}{it:b}{cmd:), 0)}.  

{pstd}
{cmd:_auniq()}, if {cmd:cols(}{it:a}{cmd:)}==0, returns 
{cmd:J(1, 0, 1)}.

{pstd}
All other functions are implemented in terms of 
{helpb mf_select:select(}{it:...}{cmd:,} 
{cmd:_aandb(}{it:...}{cmd:)}{helpb mf select:)},
{helpb mf_select:select(}{it:...}{cmd:,} 
{cmd:_aposb(}{it:...}{cmd:)}{helpb mf select:)}, or
{helpb mf_select:select(}{it:...}{cmd:,} 
{cmd:_auniq(}{it:...}{cmd:)}{helpb mf select:)}


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
Online: {helpb mata}, {helpb macrolists:macro lists}
{p_end}
