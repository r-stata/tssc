{smcl}
{hline}
help for {cmd:cprdhesaeutil}{right:(Roger Newson)}
{hline}


{title:Inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} HES A&E linkage datasets into Stata}

{p 8 21 12}{cmd:cprdhesae_attendance} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhesae_diagnosis} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhesae_investigation} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhesae_treatment} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhesae_hrg} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhesae_pathway} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} ]{p_end}


{title:Description}

{pstd}
The {cmd:cprdhesaeutil} package is designed for use with the {helpb cprdutil} package,
which creates Stata datasets from text data files
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}.
{cmd:cprdhesaeutil} is a suite of utility programs for inputting linkage text data files produced by CPRD
to contain data on the same patients from the Hospital Episode System Accident and Emergency (HES A&E) data warehouse,
and creating equivalent Stata datasets in the memory.
{cmd:cprdhesaeutil} uses the {help ssc:SSC} packages {helpb keyby}, {helpb chardef} and {helpb lablist},
which need to be installed for {cmd:cprdhesaeutil} to work.


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
but recorded by data sources other than CPRD, such as the Hospital Episode System accident and emergency (HES A&E).
The {cmd:cprdhesaeutil} package allows users to do this.
It should be used in combination with the {helpb cprdhesutil} and {helpb cprdlinkutil} packages,
also downloadable from {help ssc:SSC}.
In particular, if the user wants to input a HES A&E patient dataset,
then the user should use the {helpb cprdhes_patient} module of the {helpb cprdhesutil} package.


{title:Datasets created by {cmd:cprdhesaeutil} modules}

{pstd}
Each module of the {cmd:cprdhesaeutil} package inputs a text file on disk and creates a Stata dataset in memory,
with 1 observation per row of the input text file.
If the {cmd:nokey} option is not specified,
then the observations in the dataset will be keyed
(sorted and uniquely identified)
by the values of a list of variables, known as a primary key.
These variables, in each observation, identify a thing,
belonging to a class of things such as patients or hospital accident and emergency (A&E) attendances.

{pstd}
The modules of {cmd:cprdhesaeutil} create datasets in memory,
whose primary keys are as follows:

{p2colset 4 36 38 2}{...}
{p2col:Module}Primary key{p_end}
{p2line}
{p2col:{cmd:cprdhesae_attendance}}{cmd:patid aekey}{p_end}
{p2col:{cmd:cprdhesae_diagnosis}}{cmd:patid aekey diag_order}{p_end}
{p2col:{cmd:cprdhesae_investigation}}{cmd:patid aekey invest_order}{p_end}
{p2col:{cmd:cprdhesae_treatment}}{cmd:patid aekey treat_order}{p_end}
{p2col:{cmd:cprdhesae_hrg}}{cmd:patid aekey}{p_end}
{p2col:{cmd:cprdhesae_pathway}}{cmd:patid aekey}{p_end}
{p2line}
{p2colreset}

{pstd}
The key variable {cmd:patid} is an anonymised CPRD patient ID variable,
the key variable {cmd:aekey} is a hospital accident and emergency (A&E) attendance ID variable,
and the key variables {cmd:diag_order}, {cmd:invest_order} and {cmd:treat_order}
are within-attendance identifiers for diagnoses, investigations and treatments,
respectively.
CPRD-linked HES A&E data are provided mostly as records identified by patient
and A&E attendance.


{title:Examples}

{pstd}
The following examples assume that the current folder has a sister folder {cmd:../cprdhesopdata},
containing tab-delimited data files for each data type,
with the correct variables.

{p 8 12 2}{cmd:. cprdhesae_attendance using "../cprdhesaedata/hesae_attendance_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdhesae_diagnosis using "../cprdhesaedata/hesae_diagnosis_18_109_Request4.txt", clear", clear}{p_end}

{p 8 12 2}{cmd:. cprdhesae_investigation using "../cprdhesaedata/hesae_investigation_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdhesae_treatment using "../cprdhesaedata/hesae_treatment_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdhesae_hrg using "../cprdhesaedata/hesae_hrg_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdhesae_pathway using "../cprdhesaedata/hesae_pathway_18_109_Request4.txt", clear}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb cprdutil}, {helpb cprdlinkutil}, {helpb cprdhesutil}, {helpb keyby}, {helpb chardef}, {helpb lablist} if installed
{p_end}
