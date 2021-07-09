{smcl}
{hline}
help for {cmd:cprdonsutil}{right:(Roger Newson)}
{hline}


{title:Inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} ONS-linkage datasets into Stata}

{p 8 21 12}{cmd:cprdons_death_patient} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}



{title:Description}

{pstd}
The {cmd:cprdonsutil} package is designed for use with the {helpb cprdutil} package,
which creates Stata datasets from text data files
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}.
{cmd:cprdonsutil} is a suite of utility programs for inputting linkage text data files produced by CPRD
to contain data on the same patients from the United Kingdom (UK) Office of National Statistics (ONS),
and creating equivalent Stata datasets in the memory.
Currently, there is one program in the suite, which imports into Stata a dataset type produced by a CPRD ONS linkage retrieval,
with 1 observation for each of a set of patients on which ONS collects death data.
{cmd:cprdonsutil} uses the {help ssc:SSC} packages {helpb keyby}, {helpb chardef}, and {helpb lablist},
which need to be installed for {cmd:cprdonsutil} to work.


{title:Options}

{phang}
{cmd:clear} specifies that any existing dataset in memory will be replaced.

{phang}
{cmd:nokey} specifies that the dataset produced will not be {help sort:sorted} by a primary key of variables.
If {cmd:nokey} is not specified for a command that has a {cmd:nokey} option,
then the dataset will be sorted by a primary key of variables,
whose values will normally identify the observations uniquely,
with each value combination present in only one observation.

{phang}
{cmd:delimiters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)}
specifies the delimiters used in the input text file.
This option functions as the option of the same name for {helpb import delimited}.


{title:Remarks}

{pstd}
The {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} is a database of information
from primary-care practices in the British Health Service.
Tab-delimited text data files of various types can be produed by CPRD,
containing data on things known to these practices,
such as practices, patients, staff members, clinical events, additional details on clinical events,
consultations, immunisations, referrals, tests, and prescribed therapies.
These text datafiles can then be converted to Stata datasets using the {helpb ssc:SSC} package {helpb cprdutil}.

{pstd}
Researchers sometimes aim to answer questions about the incidence of events experienced by CPRD patients,
but recorded by data sources other than CPRD, such as the Office of National Statistics (ONS).
The {cmd:cprdonsutil} package allows users to do this.
It should be used in combination with the {helpb cprdlinkutil} package,
also downloadable from {help ssc:SSC}.

{title:Examples}

{pstd}
The following examples assume that the current folder has a sister folder {cmd:../cprdonsdata},
containing a tab-delimited data file {cmd:death_patient_18_109_Request4.txt},
with the correct variables for a CPRD ONS patient death dataset.

{p 8 12 2}{cmd:. cprdons_death_patient using "../cprdonsdata/death_patient_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdons_death_patient using "../cprdonsdata/death_patient_18_109_Request4.txt", clear nokey}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb cprdutil}, {helpb cprdlinkutil}, {helpb keyby}, {helpb chardef}, {helpb lablist} if installed
{p_end}
