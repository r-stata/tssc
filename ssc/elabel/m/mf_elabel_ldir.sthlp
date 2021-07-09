{smcl}
{cmd:help mata elabel_ldir()}
{hline}

{title:Title}

{phang}
{cmd:elabel_ldir()} {hline 2} Obtain list of label languages


{title:Syntax}

{p 8 12 2}
{it:string colvector} {cmd:elabel_ldir()}

{p 8 12 2}
{it:void}{bind:            }
{cmd:elabel_ldir(}{it:clanguage}[{cmd:,}
{it:languages}[{cmd:,} {it:real scalar uniq}]]{cmd:)}


{p 4 10 2}
where the types of {it:clanguage} and {it:languages} are irrelevant 
because they are replaced with {it:string scalar} and 
{it:string colvector}, respectively.

{p 10 10 2}
{it:uniq}!=0 excludes {it:clanguage} in {it:languages}


{title:Description}

{pstd}
{cmd:elabel_ldir()} returns a column vector with all defined label languages.

{pstd}
{cmd:elabel_ldir(}{it:clanguage} [{cmd:,} {it:languages} 
{cmd:,} {it:uniq}]{cmd:)} places in {it:clanguage} the name of the current 
label language and in {it:languages} a column vector of all defined label 
languages, excluding {it:clanguage} when {it:uniq}!=0; {it:uniq}=0 includes 
{it:clanguage} in {it:languages}.


{title:Conformability}
	
    {cmd:elabel_ldir()}
        {it:result}: r {it:x} 1
	
    {cmd:elabel_ldir(}{it:clanguage}{cmd:,} {it:languages}{cmd:,} {it:uniq}{cmd:)}
        {it:input}:
            {it:clanguage}: {it:r x c}
            {it:languages}: {it:r x c}
                 {it:uniq}: 1 {it:x} 1
       {it:output}:
            {it:clanguage}: 1 {it:x} 1
            {it:languages}: {it:r x} 1
		
		
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
Online: {helpb mata}
{p_end}

{psee}
if installed: {help elabel}
{p_end}

