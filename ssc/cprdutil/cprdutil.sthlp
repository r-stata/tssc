{smcl}
{hline}
help for {cmd:cprdutil}{right:(Roger Newson)}
{hline}


{title:Utilities for inputting {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} datasets into Stata}

{pstd}
Input a set of CPRD {it:XYZ} lookups from text files in a directory, creating Stata datasets in another directory
and/or a do-file to create {help label:value labels}:

{p 8 21 2}
{cmd:cprd_xyzlookup} , {opt txtd:irspec(directory)} [ {opt dtad:irspec(directory)} {opt replace} {break}
{cmdab:do:file}{cmd:(}{it:filename} [ , {cmd:replace}]{cmd:)} ]

{pstd}
Input a set of CPRD non-{it:XYZ} lookups from text files in a directory, creating Stata datasets in another directory:

{p 8 21 2}
{cmd:cprd_nonxyzlookup} , {opt txtd:irspec(directory)} [ {opt dtad:irspec(directory)} {opt replace} ]

{pstd}
Input a single CPRD non-{it:XYX} lookup from a single text file into memory:

{p 8 21 12}{cmd:cprd_batchnumber} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_bnfcodes} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_common_dosages} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_entity} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_medical} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_packtype} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_product} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{p 8 21 12}{cmd:cprd_scoremethod} {cmd:using} {it:filename} [ , {cmd:clear} ]{p_end}

{pstd}
Input a single CPRD non-lookup dataset from a single text file into memory:

{p 8 21 2}{cmd:cprd_additional} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 2}{cmd:cprd_clinical} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} ]{p_end}

{p 8 21 2}{cmd:cprd_consultation} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 2}{cmd:cprd_immunisation} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} ]{p_end}

{p 8 21 2}{cmd:cprd_patient} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 2}{cmd:cprd_practice} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 2}{cmd:cprd_referral} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} ]{p_end}

{p 8 21 2}{cmd:cprd_staff} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 2}{cmd:cprd_test} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} ]{p_end}

{p 8 21 2}{cmd:cprd_therapy} {cmd:using} {it:filename} [ , {cmd:clear} {opt do:file(filename)} ]{p_end}

{pstd}
Add observation-window variables to a CPRD patient dataset in memory, using practice variables from a practice dataset on disk:

{p 8 21 2}{cmd:cprd_patientobs} {cmd:using} {it:practice_datafile_name} [ , {cmdab:acc:ept} ]{p_end}

{pstd}
Input a single CPRD browser-export dataset from a single text file into memory

{p 8 21 12}{cmd:cprd_browser_medical} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}

{p 8 21 12}{cmd:cprd_browser_product} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}


{title:Description}

{pstd}
The {cmd:cprdutil} package is a suite of utility programs for inputting text datasets
produced by the {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)},
and outputting Stata datasets and/or {help do:do-files} to create {help label:value labels}.
CPRD text datasets may contain {it:XYZ} lookup tables, non-{it:XYZ} lookup tables,
non-lookup datasets, or browser-export datasets,
with one text row for each of a set of things of a kind known to the primary-care sector of the British Health Service,
such as patients, primary-care practices, clinical events or prescriptions.
All of these may be output into Stata datasets,
with one output observation per input text row.
An {it:XYZ} lookup table may alternatively be translated into a set of Stata {help label:value labels},
created using a generated {help do:do-file},
to be assigned to variables in other Stata datasets after running the do-file in the dataset.
The {cmd:cprdutil} package uses the {help ssc:SSC} packages {helpb keyby}, {helpb addinby}, {helpb lablist}, {helpb chardef},
and {helpb intext},
which need to be installed for {cmd:cprdutil} to work.


{title:Options for {cmd:cprd_xyzlookup} and {cmd:cprd_nonxyzlookup}}

{phang}
{opt txtdirspec(directory)} specifies an existing input directory,
assumed to contain text files with the extension {cmd:.txt},
with 1 row of text for each entry in a lookup table.
These rows of text are keyed (uniquely identified) by the value of the first variable.

{phang}
{opt dtadirspec(directory)} specifies an existing output directory,
to be populated by generated Stata datasets, one generated from each input text file,
with 1 observation per row of the input text file,
and with the same filename as the input text file
(apart from the extension, which will be {cmd:.dta} instead of {cmd:.txt}).
These observations will be keyed (uniquely identified), and sorted, by the value of the first variable.
This enables each dataset to be used as a lookup table,
with the first variable acting as a foreign key for use by the official Stata {helpb merge} command,
or by the {help ssc:SSC} command {helpb addinby}.

{phang}
{opt replace} specifies that any existing datasets in the output directory
with the same names as the generated Stata datasets
will be replaced.

{pstd}
Note that {cmd:cprd_xyzlookups} {cmd:cprd_nonxyzlookups} create multiple datasets in directories on disk.
Any pre-existing dataset in memory will be restored after this work is done.


{title:Options for {cmd:cprd_xyzlookups} only}

{phang}
{cmd:dofile(}{it:filename} [ , {cmd:replace}]{cmd:)} specifies a {help do:do-file} to be created,
with one command line for each code value for each {it:XYZ} lookup,
to create a {help label:value label} for each of the {it:XYZ} lookups
if the do-file is executed in a non-lookup dataset.
These value labels can then be assigned to variables in the dataset.
The suboption {cmd:replace} specifies that any existing do-file of the same name in the same location
will be replaced.
An {it:XYZ} lookup table has 2 variables.
One is named {cmd:code}, and gives the numeric code for each table row.
The other has another name, and gives the value label for the corresponding value of {cmd:code}.
The {cmd:dofile()} option allows the user to translate the {it:XYZ} lookups into Stata value labels.


{title:Options for commands creating datasets in memory from {helpb using} files}

{phang}
{cmd:clear} specifies that any existing dataset in memory will be replaced.

{phang}
{cmd:dofile(}{it:filename}{cmd:)} specifies the name of an existing {help do:Stata do-file},
usually created using the {cmd:dofile()} option of {cmd:cprd_xyzlookups}.
This do-file is executed by the dataset creation command,
and usually creates a set of {help label:value labels},
some of which are then allocated to variables in the generated dataset in memory.

{phang}
{cmd:nokey} specifies that the dataset produced will not be {help sort:sorted} by a primary key of variables.
If {cmd:nokey} is not specified for a command that has a {cmd:nokey} option,
then the dataset will be sorted by a primary key of variables,
whose values will normally identify the observations uniquely,
with each value combination present in only one observation.
In browser-export datasets, the default key consists of a single variable,
such as a medical code named {cmd:medcode} or a product code named {cmd:prodcode},
which identifies the observations uniquely.
The {cmd:nokey} option is useful in the case where the input text file has been produced
by concatenating multiple CPRD browser outputs,
which may contain some of the same medical or product code values.
The user may then add an extra variable (or variables) to the input text file,
to identify the browser output from which each observation comes,
input the input text file with a {cmd:nokey} option,
and then use the SSC package {helpb keyby} to sort the dataset primarily by the extra variable (or variables),
and secondarily by the medical or product code.


{title:Options for {cmd:cprd_patientobs} only}

{phang}
{cmd:accept} specifies that the observation-window entry and exit variables will be computed only for patients
for which the CPRD variable {cmd:accept} is equal to 1.
If absent,
then {cmd:cprd_patientobs} computes the observation-window entry and exit variables
for all patients with the necessary non-missing values
for the patient-specific and practice-specific date variables used to calculate the observation-window entry and exit variables.

{pstd}
For more information on the new variables created by {cmd:cprd_patientobs},
refer to the section
{hi:{help cprdutil##cprd_patientobs_variables:New patient variables generated by the cprd_patientobs module}}
below.


{title:Remarks}

{pstd}
The {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)} is a database of information
from primary-care practices in the British Health Service.
Tab-delimited text data files of various types can be retrieved,
containing data on things known to these practices,
such as practices, patients, staff members, clinical events, additional details on clinical events,
consultations, immunisations, referrals, tests, and prescribed therapies.
More information about CPRD and {cmd:cprdutil} can be found in a presentation by {help cprdutil##newson_2018:Newson (2018)}.

{pstd}
When a CPRD data retrieval is made, a set of lookup tables may also be provided,
also as tab-delimited text data files,
so the user can identify the meaning of the numbers in the datasets.
The {cmd:cprdutil} packages enables the user to translate the text lookup tables and datasets
into Stata datasets.
The lookups may be {it:XYZ} lookups, with 3-character names,
or non-{it:XYZ} lookups, with longer names.
The {it:XYZ} lookups typically have fewer data rows,
and only 2 variables (containing numeric codes and text labels),
making them suitable for translation into Stata {help label:value labels}.
The non-{it:XYZ} lookups typically have more data rows,
and often have more than 2 variables,
making them suitable for translation into Stata datasets,
which can be merged into the non-lookup datasets,
using the {helpb merge} command in official Stata,
or using the {help ssc:SSC} package {helpb addinby}.

{pstd}
CPRD data retrievals are usually made following a request to CPRD.
However, CPRD also provides a Web-aware browser program,
enabling the user to create lists of CPRD medical codes (identifying classes of medical events),
or lists of CPRD product codes (identifying classes of prescribed products).
The user may then export these lists to human-readable tab-delimited text files,
with one row per medical code or product code,
and columns describing the medical event or product.
These CPRD browser-export text files can then be input into Stata browser-export datasets in memory,
with one observation for each medical or product code in the list.

{pstd}
Stata datasets produced from CPRD data are sometimes (but not always) keyed by a primary key,
which is a list of variables by which the observations are sorted and uniquely identified.
The primary key is always present in lookup datasets, and contains only one variable.
It may or may not be present in non-lookup datasets, where it may contain more than one variable.
The presence of the primary key, and the variables contained, depends on the dataset type.
Datasets of non-keyed types may even contain duplicate observations,
with the same values for all variables.

{pstd}
Stata datasets created by {cmd:cprdutil} have variables corresponding to the tab-delimited columns of the input text file.
They may also have added generated variables.
For instance, in datasets with one observation per event,
the event date, and the date on which the event was logged into the CPRD system,
are provided by CPRD as the string variables {cmd:eventdate} and {cmd:sysdate}, respectively.
The Stata dataset will then also contain corresponding converted numeric Stata {help datetime:date variables},
named {cmd:eventdate_n} and {cmd:sysdate_n}, respectively.

{pstd}
The {cmd:cprdutil} package uses Roger Newson's {help ssc:SSC} packages
{helpb keyby}, {helpb addinby}, {helpb lablist}, {helpb chardef}, and {helpb intext},
which need to be installed in order for {cmd:cprdutil} to work.
The user may download all Roger Newson's packages using the {helpb instasisay} suite of do-files from Roger Newson's website.

{pstd}
The {cmd:cprdutil} package frequently produces a lot of output to the {help log:Stata log}.
However, the user can prevent this by using the {helpb quietly} prefix.


{marker cprd_patientobs_variables}{...}
{title: New patient variables generated by the {cmd:cprd_patientobs} module}

{pstd}
These are added to a patient dataset in memory,
created using the module {cmd:cprd_patient}.
The new variables are created using practice observation-window date variables
merged in from a practice dataset on disk,
which was created using the module {cmd:cprd_practice} and then saved.
The new variables specify the dates and modes of entry and exit of the patient
to and from observation by CPRD.

{p2colset 4 20 22 2}{...}
{p2col:Name}Description{p_end}
{p2line}
{p2col:{cmd:obscalc}}Observation window calculated{p_end}
{p2col:{cmd:entrystat}}Entry status to observation by CPRD{p_end}
{p2col:{cmd:entrydate}}Date of entry to observation by CPRD{p_end}
{p2col:{cmd:exitstat}}Exit status from observation by CPRD{p_end}
{p2col:{cmd:exitdate}}Date of exit from observation by CPRD{p_end}
{p2col:{cmd:observed}}Patient observed by CPRD{p_end}
{p2line}
{p2colreset}

{pstd}
The observation window is specified by variables calculated
if the necessary practice-specific and patient-specific dates are non-missing,
and (if {cmd:accept} is specified} if the patient-specific variable {cmd:accept} is also equal to 1,
indicating that the patient's data are of a quality acceptable to CPRD.
The variable {cmd:obscalc} is 1 if the observation window is calculated and 0 otherwise.
The variable {cmd:entrydate} specifies the date on which the patient entered into observation by CPRD,
and is the maximum of the date when the patient's practice started returning up-to-standard data,
the date when the patient most recently joined the practice,
and the earliest possible birth date for the patient.
The variable {cmd:entrystat} indicates which of these dates was the maximum,
and can be 0, 1, or 2 for practice up-to-standard date, patient joining date, and patient birth date, respectively,
with ties resolved preferentially in the order {cmd:2 > 1 > 0}.
The vatiable {cmd:exitdate} specifies the date on which the patient exited from observation by CPRD,
and is the minimum of the date when the practice last sent data to CPRD,
the date when the patient left the practice,
and the patient's death date (if present).
The variable {cmd:exitstat} indicates which of these dates was the minimum,
and can be 0, 1, or 2 for practice data-reporting date, patient leaving date, or death date, respectively,
with ties resolved preferentially in the order {cmd:2 > 1 > 0}.
The variable {cmd:observed} indicates that the patient was observed in an observation window
containing a non-zero number of days,
and is zero if {cmd:obscalc} is zero,
and otherwise is 1 if and only if {cmd:entrydate <= exitdate}, and zero otherwise.
Outside the observation window from {cmd:entrydate} to {cmd:exitdate} (inclusive),
a patient cannot be considered to be at risk of a CPRD event,
such as a therapy event or a clinical diagnosis.


{title:Examples}

{pstd}
These examples all assume that the CPRD text data are stored in a folder {cmd:../cprddata},
with subfolders {cmd:/Lookups}, {cmd:/Data} and {cmd:/Browserexports},
containing the lookups, the non-lookup data, and the browser exports,
respectively.

{pstd}
The following commands produce a do-file {cmd:xyzlookuplabs.do} to create {help label:Stata value labels}
corresponding to the {it:XYZ} lookups,
a set of {it:XYZ} lookup datasets in the directory {cmd:./xyzlookupdta},
and a set of non-{it:XYZ} lookups in the directory {cmd:./nonxyzlookupdta}.
Note that all the directories must already exist for these commands to work.

{p 8 12 2}{cmd:. cprd_xyzlookup, txtdir("../cprddata/Lookups/TXTFILES") dtadir("./xyzlookupdta") replace dofile(xyzlookuplabs.do, replace)}{p_end}
{p 8 12 2}{cmd:. cprd_nonxyzlookup, txtdir("../cprddata/Lookups") dtadir("./nonxyzlookupdta") replace}{p_end}

{pstd}
The following command creates a CPRD practice dataset in memory,
using a text data file named {cmd:practice.txt}.
Value labels for the new dataset in memory are created using the do-file {cmd:xyzlookuplabs.do},
which was produced by the previous commands.

{p 8 12 2}{cmd:. cprd_practice using "../cprddata/Data/practice.txt", clear dofile(xyzlookuplabs.do)}{p_end}

{pstd}
The user can save the dataset created in memory to a disk file, using {helpb save}.
It is also possible to produce patient datasets, clinical-event datasets, and other kinds of CPRD datasets in this way.

{pstd}
The following command creates a non-{it:XYZ} lookup dataset in memory
from the lookup file {cmd:medical.txt} in the subfolder {cmd:/Lookups},
with 1 observation per CPRD medical code specified by the variable {cmd:medcode},
and data on the Read codes and verbal descriptions of these CPRD medical codes.

{p 8 12 2}{cmd:. cprd_medical using "../cprddata/Lookups/medical.txt", clear}{p_end}

{pstd}
The {cmd:cprdutil} package frequently produces a lot of output to the {help log:Stata log}.
However, the user can prevent this by using the {helpb quietly} prefix.
For instance, the previous example could have been written as follows:

{p 8 12 2}{cmd:. quietly cprd_medical using "../cprddata/Lookups/medical.txt", clear}{p_end}

{pstd}
This would have produced no output to the {help log:Stata log}.
This capability might be useful if the user is mass-producing a large number of gigabyte-sized CPRD datasets
for a large research study.

{pstd}
The following command sequence creates disk-file Stata datasets in the directory {cmd:./nonlookupdta},
using text data files in the {cmd:/Data} subfolder
and the do-file {cmd:xyzlookuplabs.do} created in the first example.
First, we create a practice dataset in {cmd:practice.dta}.
Then, we create a patient dataset in {cmd:patient.dta},
with added patient observation-window variables,
computed using the {cmd:cprd_patientobs} module
to input practice information from {cmd:practice.dta}.
We then tabulate, summarize and plot the patient observation-window variables.

{p 8 12 2}{cmd:. cprd_practice using "../cprddata/Data/practice.txt", clear dofile(xyzlookuplabs.do)}{p_end}
{p 8 12 2}{cmd:. save "./nonlookupdta/practice.dta", replace}{p_end}
{p 8 12 2}{cmd:. cprd_patient using "../cprddata/Data/patient.txt", clear dofile(xyzlookuplabs.do)}{p_end}
{p 8 12 2}{cmd:. cprd_patientobs using "./nonlookupdta/practice.dta", accept}{p_end}
{p 8 12 2}{cmd:. save "./nonlookupdta/patient.dta", replace}{p_end}
{p 8 12 2}{cmd:. tab accept obscalc, miss}{p_end}
{p 8 12 2}{cmd:. tab observed obscalc, miss}{p_end}
{p 8 12 2}{cmd:. tab entrystat obscalc, miss}{p_end}
{p 8 12 2}{cmd:. tab exitstat obscalc, miss}{p_end}
{p 8 12 2}{cmd:. summ entrydate, detail format}{p_end}
{p 8 12 2}{cmd:. summ exitdate, detail format}{p_end}
{p 8 12 2}{cmd:. scatter exitdate entrydate || line entrydate entrydate, sort || , by(observed) legend(row(1))}{p_end}

{pstd}
The following command sequence uses the {cmd:cprd_browser_product} command
to input a CPRD browser-export text file in the {cmd:/Browserexports} subfolder
and produce a CPRD browser-export dataset on disk in the directory {cmd:./browserexportdta},
with 1 observation per product code appearing in the text file.
We then use the command {cmd:cprd_therapy} to input a CPRD therapy text file
in the {cmd:/Data} subfolder,
producing a CPRD therapy dataset in memory,
and then use the {help ssc:SSC} package {helpb addinby:addinby}
to drop all therapy records with product codes not matched in the browser-export disk dataset.
Finally, we tabulate the frequency distribution of the other product codes,
which are matched in the browser-export disk dataset.

{p 8 12 2}{cmd:. cprd_browser_product using "../cprddata/Browserexports/myprodcodes.txt", clear}{p_end}
{p 8 12 2}{cmd:. list, abbr(32)}{p_end}
{p 8 12 2}{cmd:. save "./browserexportdta/myprodcodes.dta", replace}{p_end}
{p 8 12 2}{cmd:. cprd_therapy using "../cprddata/Data/therapy.txt", clear}{p_end}
{p 8 12 2}{cmd:. addinby prodcode using "./browserexportdta/myprodcodes.dta", unm(drop) keep(prodcode)}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. tab prodcode, miss}{p_end}


{title:Acknowledgments}

{pstd}
I would like to thank Sophia Amjad and Sarah Cousins of CPRD Enquiries
for providing me with simulated sample CPRD-format libraries of text datasets,
complete with a full set of lookups and documents.
I found these sample libraries to be very useful when validating {cmd:cprdutil}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker newson_2018}{...}
{phang}
Newson, R. B.  2018.  A fleet of packages for inputting United Kingdom primary care data.
Presented at {browse "https://ideas.repec.org/p/boc/usug18/01.html":the 2018 London Stata Conference, 8-9 September, 2018}.


{title:Also see}

{psee}
{space 2}Help:  {browse "http://www.cprd.com":Clinical Practice Research Datalink (CPRD)}{break}
{helpb keyby}, {helpb addinby}, {helpb lablist}, {helpb chardef}, {helpb intext} if installed
{p_end}
