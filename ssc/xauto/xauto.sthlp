{smcl}
{hline}
help for {cmd:xauto}{right:(Roger Newson)}
{hline}

{title:Input an extended version of the {helpb sysuse:auto} data}

{p 8 21 2}
{cmd:xauto} [ , {cmdab:clear} ]


{title:Description}

{pstd}
{cmd:xauto} inputs an extended version of the {helpb sysuse:auto} dataset shipped with official Stata,
with extra variables and a primary key,
and all variables compressed,
and {helpb describe}s the new dataset.
{cmd:xauto} requires the {help ssc:SSC} package {helpb keyby}. 


{title:Options}

{phang}
{opt clear} specifies that any pre-existing dataset in the memory will be overwritten.


{title:Remarks}

{pstd}
The dataset created contains the variablss of the {cmd:auto} dataset distributed with Stata,
plus extra variables {cmd:firm}, {cmd:odd}, {cmd:us}, {cmd:tons} and {cmd:npm}.
{cmd:tons} is weight in US tons (equal to 2,000 US pounds).
The variable {cmd:npm} is fuel consumption in nipperkins per mile,
where a nipperkin is 1/256 of a gallon,
forming part of a binary system of Imperial/US capacity measures.


{title:Examples}

{p 8 12 2}{cmd:. xauto, clear}{p_end}
{p 8 12 2}{cmd:. scatter npm tons, by(us)}{p_end}


{title:Saved results}

{pstd}
{cmd:xauto} saves in {cmd:r()} the returned results of the {helpb describe} command
with the {cmd:varlist} option.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] describe}
{p_end}
{p 4 13 2}
On-line: help for {helpb describe}, {helpb sysuse}
{break}
help for {helpb keyby} if installed
{p_end}
