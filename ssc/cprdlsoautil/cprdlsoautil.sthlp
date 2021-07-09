{smcl}
{hline}
help for {cmd:cprdlsoautil}{right:(Roger Newson)}
{hline}


{title:Inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} LSOA-linkage datasets into Stata}

{p 8 21 12}{cmd:cprdlsoa_patient_index} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key}
{break}
{cmdab:delim:iters("}{it:chars}{cmd:"}[{cmd:, }{cmd:collapse}|{cmd:asstring}]{cmd:)}
{break}
{cmdab:in:dex(}{it:index_name}{cmd:)} {cmdab:ye:ar(}{it:#}{cmd:)}
]{p_end}

{pstd}
where {it:index_name} may be

{pstd}
{cmd:imd} | {cmd:townsend}


{title:Description}

{pstd}
The {cmd:cprdlsoautil} package is designed for use with the {helpb cprdutil} package,
which creates Stata datasets from text data files
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}.
{cmd:cprdlsoautil} is a suite of utility programs for inputting linkage text data files produced by CPRD
to contain social-deprivation data on patients from these patients' home lower layer super output areas (LSOAs),
and creating equivalent Stata datasets in the memory.
{cmd:cprdlsoautil} {like {helpb cprdutil}) uses the {help ssc:SSC} packages {helpb keyby} and {helpb chardef},
which need to be installed for {cmd:cprdlsoautil} to work.


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
{cmd:index(}{it:index_name}{cmd:)} specifies the name of the index to be used.
This name may be {cmd:imd} for the index of multiple deprivation (IMD) (the default),
or {cmd:townsend} for the Townsend index.

{phang}
{cmd:year(}{it:#}{cmd:)} specifies the year for which deprivation data are recorded.
In default, it is set to 2004.
The {cmd:index()} and {cmd:year()} options are used to define the names of variables containing deprivation indices,
which may be given as quintiles, deciles or twentiles.
For instance, a variable containing twentiles of the IMD for year 2010
will be named {cmd:imd2010_20}.
Higher values of IMD quintiles, deciles or twentiles
correspond to higher levels of social deprivation for the lower super-output area (LSOA).


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
but recorded by data sources other than CPRD, such as lower super-output areas (LSOAs) in which patients live.
The {cmd:cprdlsoautil} package allows users to do this,
creating datasets with 1 observation per patient,
and data on deprivation measures for the patient's home neighbourhood.
For example, the {cmd:cprdlsoa_patient_imd} module creates datasets containing variables
giving the quintile, decile or twentile of the index of multiple deprivation (IMD)
for the patient's neighbourhood.
The higher the IMD or Townsend index, the more deprived the patient's neighbourhood is thought to be.
IMD and Townsend index variables are named informatively to specify the year and percentile.
For instance, a variable containing twentiles of the IMD for year 2010
will be named {cmd:imd2010_20}.
{cmd:cprdlsoautil} should be used in combination with the {helpb cprdlinkutil} package,
also downloadable from {help ssc:SSC}.


{title:Examples}

{pstd}
The following examples assume that the current folder has a sister folder {cmd:../cprdlsoadata},
containing a tab-delimited data file {cmd:death_patient_18_109_Request4.txt},
with the correct variables for a CPRD LSOA patient deprivation dataset.

{pstd}
Input a dataset containing IMD data for the year 2010, keyed by patient ID:

{p 8 12 2}{cmd:. cprdlsoa_patient_index using "../cprdlsoadata/patient_imd2010_18_109_Request4.txt", clear year(2010)}{p_end}

{pstd}
Input an unkeyed dataset containing Townsend index data for the year 2001:

{p 8 12 2}{cmd:. cprdlsoa_patient_index using "../cprdlsoadata/patient_townsend2001_18_109_Request4.txt", clear nokey index(townsend) year(2001)}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb cprdutil}, {helpb cprdlinkutil}, {helpb keyby}, {helpb chardef}, {helpb lablist} if installed
{p_end}
