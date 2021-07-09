{smcl}
{hline}
help for {cmd:qrisk2cmd}, {cmd:qrisk2import} and {cmd:qrisk2export}{right:(Roger Newson)}
{hline}


{title:Running the QRISK2 command from within Stata}

{pstd}
Run QRISK2 from within Stata

{p 8 21 2}
{cmd:qrisk2cmd} {it:infilename} {it:outfilename}

{pstd}
Import a QRISK2 input or output dataset

{p 8 21 12}{cmd:qrisk2import} {cmd:using} {it:filename} [ , {cmd:clear} {cmdab::no}{cmdab:key} ]{p_end}

{pstd}
Export a QRISK2 inpt dataset

{p 8 21 12}{cmd:qrisk2export} {cmd:using} {it:filename} {ifin} [ , {cmd:replace} ]{p_end}


{title:Description}

{pstd}
{cmd:qrisk2cmd} calls the QRISK2 command to convert from a QRISK2 input data file to a QRISK2 output data file.
{cmd:qrisk2import} inputs a QRISK2 input or output data file into a Stata dataset in memory.
{cmd:qrisk2export} exports a QRISK2 input data file,
using variables with standard QRISK2 names from the dataset in memory.
This package requires the QRISK2 program to be installed,
and also requires the {help ssc:SSC} package {helpb keyby}.


{title:Options for {cmd:qrisk2import}}

{phang}
{cmd:clear} specifies that any existing dataset in memory will be replaced.

{phang}
{cmd:nokey} specifies that the dataset produced will not be {help sort:sorted} by the patient ID variable {cmd:row_id}.
If {cmd:nokey} is not specified,
then {cmd:qrisk2import} uses the {help ssc:SSC} package {helpb keyby} to sort the dataset by {cmd:row_id},
and issues an error message
if {cmd:row_id} either does not identify the observations uniquely
or is missing in some observations.
This is done because the datasets input and output by QRISK2 are assumed to have one row per patient,
identified by the variable {cmd:row_id}.


{title:Options for {cmd:qrisk2export}}

{phang}
{cmd:replace} specifies that any existing file with the same name as the {helpb using} file will be replaced. will be replaced.


{title:Remarks}

{pstd}
The QRISK2 command is a Java application sold by {browse "https://clinrisk.co.uk/":ClinRisk}.
It inputs a comma-separated input file and outputs a comma-separated output file,
with the same variables as the input file,
plus some extra variables derived by QRISK2 from the input variables.
These extra variables include a variable {cmd:patientscore},
containing a patient risk score for cardiovascular disease;

{pstd}
The comma-separated input and output files have a format that extends the generic {cmd:.csv} format,
but allows blank lines,
and also comment lines (beginning with {cmd:#}).
Both of these line types are ignored by QRISK2,
and also by {cmd:qrisk2import}.

{marker qrisk2cmd_technote}{...}
{title:Technical notes}

{pstd}
{cmd:qrisk2cmd} calls the command-line version of the QRISK2 batch processor command.
This command-line version is an alternative to the menu-driven Windows version of the QRISK2 batch processor.
When ordering the QRISK2 batch processor from {browse "https://clinrisk.co.uk/":ClinRisk},
it is important for the user to specify either the command-line version
or the menu-driven Windows version.

{pstd}
The path for the QRISK2 command varies from system to system.
In general, it is composed of two components.
These are a library directory in which the QRISK2 command is located
and a filename, ending in the extension {cmd:jar},
identifying the Java archive containing the QRISK2 program.
{cmd:qrisk2cmd} attempts to find these in two {help macro:global macros},
whose names are {cmd:qrisk2_lib} for the library and {cmd:qrisk2_jar} for the {cmd:.jar} filename.
The best way of setting values for these is probably to include two {helpb macro:global} commands
in the user's {help profile:profile do-file}.
These commands might read

{p 8 12 2}{cmd:. global qrisk2_lib "S:\PITA\QRISK2\dist\lib\"}{p_end}
{p 8 12 2}{cmd:. global qrisk2_jar "QRISK2-2016-batchProcessor.jar"}{p_end}

{pstd}
If these {help macro:global macros} are both set, then the Java command passed by {cmd:qrisk2cmd} to the operating environment to execute QRISK2
has the form

{p 8 12 2}{cmd:java -Dderby.system.home={it:$qrisk2_lib} -jar "{it:$qrisk2_lib}{it:$qrisk2_jar}" {it:infilename} {it:outfilename}}{p_end}

{pstd}
If the {help macro:global macro} {cmd:qrisk2_lib} is unset, then {cmd:qrisk2cmd} uses the current directory,
denoted {cmd:.\} under Windows or {cmd:./} under Unix, Linux or MacOSX.
If the {help macro:global macro} {cmd:qrisk2_jar} is unset, then {cmd:qrisk2cmd} uses the value {cmd:QRISK2-2016-batchProcessor.jar}.
Note that the value of the {help macro:global macro} {cmd:qrisk2_lib} must contain the terminating directory separator,
which is {cmd:\} under Windows and {cmd:/} under Unix, Linux or MacOSX.
Note, also, that, when the user upgrades to a new version of QRISK2,
the user may also have to change the name of the Java archive in the {help macro:global macro} {cmd:qrisk2_jar},
and/or the library location in the {help macro:global macro} {cmd:qrisk2_lib}
may also need to be changed.


{title:Examples}

{pstd}
The following examples use the test datasets distributed with QRISK2.

{p 8 12 2}{cmd:. qrisk2cmd qrisk2Input.csv qrisk2Output.csv}{p_end}

{p 8 12 2}{cmd:. qrisk2import using qrisk2Output.csv, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}

{p 8 12 2}{cmd:. qrisk2import using qrisk2TestDataWithNoPostcodesAndZeroTownsend.csv, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. qrisk2export using mysubsetinput.csv in 1/20, replace}{p_end}
{p 8 12 2}{cmd:. qrisk2cmd mysubsetinput.csv mysubsetoutput.csv}{p_end}
{p 8 12 2}{cmd:. qrisk2import using mysubsetoutput.csv, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] Import delimited}

{p 4 13 2}
On-line: help for {helpb import delimited}{break}
{helpb keyby} if installed.
{p_end}
{p 4 13 2}
{bind:  }Other: {browse "https://clinrisk.co.uk/":ClinRisk}
{p_end}
