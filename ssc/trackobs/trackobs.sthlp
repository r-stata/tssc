{smcl}
{cmd:help trackobs}
{hline}

{title:Title}

{p 5 18}
{cmd:trackobs} {hline 2} Keep track of number of observations


{title:Syntax}

{p 5 8}
Basic syntax (required)

{p 8 18 2}
{cmd:trackobs set} [ {cmd:,} {opt clear} ]

{p 8 18 2}
{cmd:trackobs} [{cmd::}] {it:command}


{p 4 10 2}
where {it:command} is a Stata command


{p 5 8}
Advanced syntax (optional)

{p 8 18 2}
{cmd:trackobs saving} {it:{help filename}} [ {cmd:,} {opt replace} ]

{p 8 18 2}
{cmd:trackobs report} [ {helpb using} {it:{help filename}} ]

{p 8 18 2}
{cmd:trackobs clear}


{title:Description}

{pstd}
{cmd:trackobs} keeps a record of the number of observations in the 
current dataset. The syntax diagram represents the typical workflow: 

{pstd}
{cmd:trackobs set} specifies that the number of observation is to be 
recorded. Technically, the command defines a characteristic, 
{cmd:_dta[trackobs_counter]}, that is used by {cmd:trackobs}; see 
{helpb char}. 

{pstd}
{cmd:trackobs}, when specified as a prefix, records the number of 
observations before {it:command} is executed and after {it:command} 
has concluded; {it:command} itself is recorded, too. The full syntax is 

{p 8 18 2}
{cmd:trackobs} [[ {cmd:,} {opt return} ] {cmd::} ] [ {it:command} ]

{pstd}
where the colon, following {cmd:trackobs}, must be typed if option 
{opt return} is specified or if {it:command} is also a {cmd:trackobs} 
subcommand. Technically, {cmd:trackobs} defines a characteristic, 
{cmd:_dta[trackobs_{it:i}]}, where {cmd:{it:i}} is the counter that 
is stored in {cmd:_dta[trackobs_counter]}; see {helpb char}. 

{pstd}
{cmd:trackobs saving} saves the recorded commands and associated numbers of 
observations to a Stata dataset. This is useful when you want to manipulate 
the recorded information. Concering workflow, {cmd:trackobs saving} is 
optional; {cmd:trackobs} results are saved along with the dataset when 
they are not cleared.

{pstd}
{cmd:trackobs report} lists the recorded commands and associated numbers of 
observations, optionally from {it:filename}. When {it:filename} is not 
specified, {cmd:trackobs} creates a temporary file from chracteristics; see 
{helpb char}.

{pstd}
{cmd:trackobs clear} discards all records. Records are saved with the 
dataset when they are not cleared. Technically, the command deletes 
the contents of all characteristics {cmd:_dta[trackobs_{it:*}]}; see 
{helpb char}. 

{pstd}
{cmd:trackobs} might fail when {it:command} modifies the {cmd:_dta} 
characteristics; see {helpb char}. Some commands, such as 
{helpb preserve} and {helpb restore}, do not work correctly when 
they are prefixed with {cmd:trackobs}.


{title:Options}

{phang}
{opt clear} clears previous {cmd:trackobs} results and resets the 
counter. 

{phang}
{opt return} returns the number of observations before {it:command} was 
executed, the number of observations when {it:command} concluded, and 
{it:command} itself in {cmd:r()}. When {it:command} is not specified, 
the last recorded command and the associated numbers of observations 
are returned.

{phang}
{opt replace} allows {cmd:trackobs} to overwrite {it:filename}.


{title:Examples}

{phang2}{cmd:. trackobs set}{p_end}
{phang2}{cmd:. trackobs : sysuse auto}{p_end}
{phang2}{cmd:. trackobs : drop if foreign}{p_end}
{phang2}{cmd:. trackobs report}{p_end}
{phang2}{cmd:. trackobs clear}{p_end}


{title:Saved results}

{pstd}
{cmd:trackobs} stores its results in characteristics; see {helpb char}.

{pstd}
{cmd:trackobs} with the {opt return} option saves the 
following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(N_was)}}number of observations before {it:command} 
was executed{p_end}
{synopt:{cmd:r(N_now)}}number of observations when {it:command} 
concluded{p_end}

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(cmdline)}}{it:command} as typed{p_end}


{title:Acknowledgments}

{pstd}
{cmd:trackobs} was first published on Statalist as an answer to a 
request from an anonymous poster.


{title:Author}

{pstd}
Daniel Klein, INCHER-Kassel, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb log}, {helpb char}, {helpb list}
{p_end}
