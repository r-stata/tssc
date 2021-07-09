{smcl}
{cmd:help mata elabel_dir()}
{hline}

{title:Title}

{phang}
{cmd:elabel_dir()} {hline 2} Obtain lists of value label names


{title:Syntax}

{p 8 12 2}
{it:string colvector} {cmd:elabel_dir()}

{p 8 12 2}
{it:void}{bind:            }
{cmd:elabel_dir(}{it:names}
[{cmd:,} {it:real scalar mlang}]{cmd:)}

{p 8 12 2}
{it:void}{bind:            }
{cmd:elabel_dir(}{it:nonexistent}{cmd:,} 
{it:orphans}{cmd:,}
{it:used} [{cmd:,}
{it:real scalar mlang}]{cmd:)}


{p 4 10 2}
where the types of {it:names}, {it:nonexistent}, {it:orphans}, and {it:used} 
is irrelevant because they are replaced with {it:string colvectors}.

{p 10 10 2}
{it:mlang}!=0 respects multilingual datasets (see {help label language})


{title:Description}

{pstd}
{cmd:elabel_dir()} returns a column vector with all value label names stored 
in memory.

{pstd}
{cmd:elabel_dir(}{it:names} [{cmd:,} {it:mlang}]{cmd:)} places in {it:names} 
a column vector of value labels attached to at least one variable in the 
dataset, including value labels that are not stored in memory (nonexistent 
value 
labels). Value labels in memory that are not used by any of the variables 
(so-called orphans) are omitted. {it:mlang}=0 restricts nonexisting value 
labels to those in the current {help label language}.

{pstd}
{cmd:elabel_dir(}{it:nonexistent}{cmd:,} {it:orphans}{cmd:,} {it:used}
[{cmd:,} {it:mlang}]{cmd:)} places in {it:nonexistent} a column vector of 
value labels that are not stored in memory but attached to at least one 
variable in the dataset; in {it:orphans} a column vector of value labels 
that are stored in memory but are not used by any of the variables in the 
dataste; in {it:used} a column vector of value labels that are stored in 
memory and used by at least one variable in the dataset. {it:mlang}=0 
considers value labels in the current {help label language} only.

{pstd}
See {helpb mf_elabel_ldir:elabel_ldir()} to obtain a list of label languages. 


{title:Conformability}

    {cmd:elabel_dir()}
            {it:result}: {it:r x} 1
		
    {cmd:elabel_dir(}{it:names}[{cmd:,} {it:mlang}]{cmd:)}
             {it:input}:
                      {it:names}: {it:r x c}
                      {it:mlang}: 1 {it:x} 1
            {it:output}:	
                      {it:names}: {it:r x} 1

    {cmd:elabel_dir(}{it:nonexistent}{cmd:,} {it:orphans}{cmd:,} {it:used}[{cmd:,} {it:mlang}]{cmd:)}
             {it:input}:
                {it:nonexistent}: {it:r x c}
                    {it:orphans}: {it:r x c}
                       {it:used}: {it:r x c}
                      {it:mlang}: 1 {it:x} 1
            {it:output}:	
                {it:nonexistent}: {it:r x} 1
                    {it:orphans}: {it:r x} 1
                       {it:used}: {it:r x} 1


{title:Diagnostics}

{pstd}
{cmd:elabel_dir()} is implemented in terms of Stata's {helpb label dir} 
command.

{pstd}
{cmd:elabel_dir()} returns {cmd:J(0, 1, "")} if no value labels are in 
memory. {it:names}, {it:nonexistent}, {it:orphans}, and {it:used} are 
replaced with {cmd:J(0, 1, "")}, if the respective type of value label 
does not exist.


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
