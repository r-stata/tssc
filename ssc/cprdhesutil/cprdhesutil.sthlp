{smcl}
{hline}
help for {cmd:cprdhesutil}{right:(Roger Newson)}
{hline}


{title:Inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} HES-linkage datasets into Stata}

{p 8 21 12}{cmd:cprdhes_patient} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)} ]{p_end}

{p 8 21 12}{cmd:cprdhes_hospital} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_episodes} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_diagnosis_epi} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_diagnosis_hosp} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_primary_diag_hosp} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_procedures_epi} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_acp} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_ccare} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_maternity} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}

{p 8 21 12}{cmd:cprdhes_hrg} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} {cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)} {cmdab:enc:oding(}{it:string}{cmd:)}  ]{p_end}


{title:Description}

{pstd}
The {cmd:cprdhesutil} package is designed for use with the {helpb cprdutil} package,
which creates Stata datasets from text data files
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}.
{cmd:cprdhesutil} is a suite of utility programs for inputting linkage text data files produced by CPRD
to contain data on the same patients from the Hospital Episodes System (HES),
and creating equivalent Stata datasets in the memory.
Each program in the suite imports into Stata a dataset type produced by a CPRD HES linkage retrieval,
with 1 observation for each of a set of things of a kind on which HES collects data,
such as patients, hospitalisation events, or episodes within hospitalisations.
{cmd:cprdhesutil} uses the {help ssc:SSC} packages {helpb keyby}, {helpb chardef}, and {helpb lablist},
which need to be installed for {cmd:cprdhesutil} to work.


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

{phang}
{cmd:encoding(}{it:string}{cmd:)} specifies the encoding of the text file being imported.
This option functions as the option of the same name for {helpb import delimited} in {help version:Stata Versions} 14 or above,
or as the {cmd:charset()} option for {helpb import delimited} in {help version:Stata Version} 13.


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
but recorded by data sources other than CPRD, such as the Hospital Episodes System (HES).
The {cmd:cprdhesutil} package allows users to do this.
It should be used in combination with the {helpb cprdlinkutil} package,
also downloadable from {help ssc:SSC}.


{title:Datasets created by {cmd:cprdhesutil} modules}

{pstd}
Each module of the {cmd:cprdhesutil} package inputs a text file on disk and creates a Stata dataset in memory,
with 1 observation per row of the input text file.
If the {cmd:nokey} option is not specified,
then the observations in the dataset will be keyed
(sorted and uniquely identified)
by the values of a list of variables, known as a primary key.
These variables, in each observation, identify a thing,
belonging to a class of things such as patients, hospital spells,
or hospital episodes under the care of a particular team.

{pstd}
The modules of {cmd:cprdhesutil} create datasets in memory,
whose primary keys are as follows:

{p2colset 4 36 38 2}{...}
{p2col:Module}Primary key{p_end}
{p2line}
{p2col:{cmd:cprdhes_patient}}{cmd:patid}{p_end}
{p2col:{cmd:cprdhes_hospital}}{cmd:patid spno}{p_end}
{p2col:{cmd:cprdhes_episodes}}{cmd:patid spno epikey}{p_end}
{p2col:{cmd:cprdhes_diagnosis_epi}}{cmd:patid spno epikey d_order}{p_end}
{p2col:{cmd:cprdhes_diagnosis_hosp}}(No primary key){p_end}
{p2col:{cmd:cprdhes_primary_diag_hosp}}(No primary key){p_end}
{p2col:{cmd:cprdhes_procedures_epi}}{cmd:patid spno epikey p_order}{p_end}
{p2col:{cmd:cprdhes_acp}}{cmd:patid spno epikey acpn}{p_end}
{p2col:{cmd:cprdhes_ccare}}(No primary key){p_end}
{p2col:{cmd:cprdhes_maternity}}{cmd:patid spno epikey matordr}{p_end}
{p2col:{cmd:cprdhes_hrg}}{cmd:patid spno epikey}{p_end}
{p2line}
{p2colreset}

{pstd}
The key variable {cmd:patid} is an anonymised CPRD patient ID variable,
the key variable {cmd:spno} is a hospital spell ID variable,
the key variable {cmd:epikey} is a hospital episode ID variable,
and the key variables {cmd:d_order}, {cmd:p_order}, {cmd:acpn} and {cmd:matordr}
are within-episode identifiers for diagnoses, procedures, augmented care periods and maternity events,
respectively.
CPRD-linked HES data are provided mostly as records identified by patient,
hospitalisation spell,
and episode within hospitalisation spell,
where an episode is a period of time, within a hospitalisation spell,
in which the patient is under the care of an identifiable health care team.
Datasets with no primary key may contain the primary key variables of other datasets
as a foreign key,
but do not have a key of variables uniquely identifying the observations.


{title:Examples}

{pstd}
The following examples assume that the current folder has a sister folder {cmd:../cprdhesdata},
containing a tab-delimited data file {cmd:hes_patient_18_109_Request4.txt},
with the correct variables for a CPRD HES patient dataset.

{p 8 12 2}{cmd:. cprdhes_patient using "../cprdhesdata/hes_patient_18_109_Request4.txt", clear}{p_end}

{p 8 12 2}{cmd:. cprdhes_patient using "../cprdhesdata/hes_patient_18_109_Request4.txt", clear nokey}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb cprdutil}, {helpb cprdlinkutil}, {helpb keyby}, {helpb chardef}, {helpb lablist} if installed
{p_end}
