{smcl}
{hline}
help for {cmd:cprdlinkutil}{right:(Roger Newson)}
{hline}


{title:Inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} linkage-source datasets into Stata}

{p 8 21 12}{cmd:cprdlink_linkage_eligibility} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 12}{cmd:cprdlink_linkage_coverage} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 12}{cmd:cprdlink_linked_practices} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}


{title:Description}

{pstd}
The {cmd:cprdlinkutil} package is designed for use with the {helpb cprdutil} package,
which creates Stata datasets from text data files
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}.
{cmd:cprdlinkutil} is a suite of utility programs for inputting linkage-source text data files produced by CPRD
for linkage to one or more non-CPRD sources of data on the same patients,
and creating equivalent Stata datasets in the memory.
Possible linkage-data sources include  the Hospital Episodes System (HES) for data on hospitalisations,
and the Office of National Statistics (ONS) for data on deaths.
CPRD can carry out data retrievals to provide linkage datasets,
with data about patients known to CPRD,
and with one observation per event of the type recorded by the linkage-data source.
Datasets produced by {cmd:cprdlinkutil} contain information on patients and practices known to CPRD,
and on the times at which patients in these practices can be said to be at risk
of experiencing recorded events of the types recorded by each linkage-data source.
{cmd:cprdlinkutil} uses the {help ssc:SSC} packages {helpb keyby} and {helpb chardef},
which need to be installed for {cmd:cprdlinkutil} to work.


{title:Options}

{phang}
{cmd:clear} specifies that any existing dataset in memory will be replaced.

{phang}
{cmd:nokey} specifies that the dataset produced will not be {help sort:sorted} by a primary key of variables.
If {cmd:nokey} is not specified for a command that has a {cmd:nokey} option,
then the dataset will be sorted by a primary key of variables,
whose values will normally identify the observations uniquely,
with each value combination present in only one observation.


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
but recorded by data sources other than CPRD.
These events include deaths recorded by the Office of National Statistics (ONS),
cancer registrations from cancer registries,
and hospitalisations recorded by the Hospital Episodes System (HES).
Some of the practices sending data to CPRD also have arrangements with CPRD,
allowing CPRD to attempt to identify the CPRD patients to which these events have happened,
and therefore to carry out retrievals to create text datasets on these events,
together with the CPRD variables identifying the CPRD patients for which these events happened.

{pstd}
The role of the {cmd:cprdlinkutil} package is to produce datasets identifying the practices with these arrangements,
the patients in these practices who can be said to be at risk of experiencing recorded events from the non-CPRD sources,
and the time windows in which these patients can be said to be at risk of experiencing these non-CPRD recorded events.
The datasets containing information on the non-CPRD recorded events themselves are produced by other {help ssc:SSC} packages,
such as {helpb cprdhesutil}, which creates datasets on events recorded by the Hospital Episodes System (HES).

{pstd}
In the {cmd:cprdlinkutil} package, there is one command for inputting each linkage-source dataset type.
The {cmd:cprdlink_linkage_eligibility} command creates a dataset with 1 observation per patient,
and data on the eligibility of the patient for experiencing recorded events of the types recorded by the linkage-data sources.
The {cmd:cprdlink_linkage_coverage} command creates a dataset with 1 observation per linkage-data source,
and data on the dates beginning and ending the time window covered by the retrieval.
The {cmd:cprdlink_linked_practices} command creates a dataset
with 1 observation per practice providing information allowing linkage to other data sources.


{title:Examples}

{pstd}
The following examples will work if the current folder has a sister folder {cmd:../cprdlinkdata},
containing tab-delimited text datasets {cmd:linked_practices.txt}, {cmd:linkage_coverage.txt},
and {cmd:linkage_eligibility.txt},
with the correct variables for linked practices, linkage coverage, and patient linkage eligibility,
respectively.

{p 8 12 2}{cmd:. cprdlink_linked_practices using "../cprdlinkdata/linked_practices.txt", clear}{p_end}
{p 8 12 2}{cmd:. summ pracid, de}{p_end}

{p 8 12 2}{cmd:. cprdlink_linkage_coverage using "../cprdlinkdata/linkage_coverage.txt", clear nokey}{p_end}
{p 8 12 2}{cmd:. list, abbr(32)}{p_end}

{p 8 12 2}{cmd:. cprdlink_linkage_eligibility using "../cprdlinkdata/linkage_eligibility.txt", clear}{p_end}
{p 8 12 2}{cmd:. summ linkdate_n, de format}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb cprdutil}, {helpb cprdhesutil}, {helpb keyby}, {helpb chardef} if installed
{p_end}
