{smcl}
{hline}
help for {cmd:rsource}{right:(Roger Newson)}
{hline}

{title:Run R from inside Stata using an R source file and/or inline R code}

{p 8 21 2}
{cmd:rsource}
[ {helpb using} {it:R_source_filename} ] [ {cmd:,}
{cmdab:te:rminator}{cmd:(}{it:string}{cmd:)}
{cmdab:max:lines}{cmf:(}{it:#}{cmd:)}
{cmd:no}{cmdab:lo:utput} {cmdab:ls:ource}
{cmdab:rp:ath}{cmd:(}{it:R_pathname}{cmd:)}
{cmdab:ro:ptions}{cmd:(}{it:R_options}{cmd:)}
]

{pstd}
where {it:R_source_filename} is the name of a file containing R source code,
{it:R_pathname} is the name of the path of the R command to be used under the user's system,
and {it:R_options} is a set of options for the R command.


{title:Description}

{pstd}
{cmd:rsource} runs an R source program,
from an inline sequence of lines and/or from a file,
in batch mode from within Stata,
optionally listing the R output and/or the R source code
to the Stata Results window and/or the Stata {help log:log file}.
This allows the user to call R at a point in the execution of a Stata program
to input data files previously created by Stata
and/or to create output data files for later input by Stata.
The R software system must be installed on the user's system if the {cmd:rsource} package is to work.


{title:Options for use with {cmd:rsource}}

{p 4 8 2}
{cmd:terminator(}{it:string}{cmd:)} specifies a string,
to be used as a terminator for an inline R program inside the Stata program.
If {cmd:terminator()} is specified,
then {cmd:rsource} reads lines of R code from the following lines of the Stata program,
until it encounters a line containing only the {cmd:terminator()} string,
or until the number of lines of R code reaches the limit set by the {cmd:maxlines()} option (see below).
The user may specify a {cmd:terminator()} option and/or a {cmd:using} file qualifier,
both of which will be assumed to contain lines of R code for the R program to be run.
If the user specifies both a {cmd:terminator()} string and a {cmd:using} file qualifier,
then the inline R code will be placed before the R code from the file.

{p 4 8 2}
{cmd:maxlines(}{it:#}{cmd:)} specifies the maximum number of lines allowed
in the inline R code terminated by the {cmd:terminator()} string.
In default, {cmd:maxlines(1024}) is assumed.

{p 4 8 2}
{cmd:noloutput} specifies that the output from the R source code is not listed
to the Stata Results window and/or the Stata {help log:log file}.
If {cmd:noloutput} is not specified,
then the output from the R source code is listed.

{p 4 8 2}
{cmd:lsource} specifies that the R source code is listed
to the Stata Results window and/or the Stata {help log:log file}.
If {cmd:lsource()} is specified and {cmd:noloutput} is not specified,
then the R source file is listed before the output from the R command.

{p 4 8 2}
{cmd:rpath(}{it:R_pathname}{cmd:)} specifies a path name for invoking the R command.
If {cmd:rpath()} is not specified,
then it is set to the value of the {help macro:global macro} {hi:Rterm_path},
if that macro has been specified,
and to {hi:"Rterm.exe"} otherwise.
(See {hi:{help rsource##rsource_technote:Technical note}} below.)

{p 4 8 2}
{cmd:roptions(}{it:R_options}{cmd:)} specifies a set of options for the R command.
If {cmd:roptions()} is not specified,
then it is set to the value of the {help macro:global macro} {hi:Rterm_options},
if that macro has been specified,
and to the empty string {hi:""} otherwise.
(See {hi:{help rsource##rsource_technote:Technical note}} below.)


{title:Remarks}

{pstd}
The R statistical software system can be downloaded from {browse "http://www.r-project.org/":the R Project Website}.
It is complementary to Stata in its capabilities, as it contains implementations of many methods unavailable in Stata,
but does not have as many easy-to-use data management tools as Stata.
It may therefore be useful to be able to call R in batch mode from within a Stata do-file.

{pstd}
R can read Stata dataset files using the {cmd:read.dta} and {cmd:write.dta} modules of the {cmd:foreign} package.
Alternatively, it is possible to translate between Stata and R datasets using {browse "http://www.stattransfer.com/":Stat/Transfer},
which can be accessed from within Stata using the {helpb stcmd} package, downloadable from {help ssc:SSC}.
More recent R packages for exchange of data between Stata and R include {cmd:haven} and {cmd:readstata13}.
For more about import and export of data to and from R, refer to {it:R Data Import/Export}
(see {hi:{help rsource##rsource_references:References}})
Note that packages for import of data to R from Stata may be added at any time.
Note, also, that new {help version:Stata versions} may also be released,
which may or may not disable these R packages.

{pstd}
For more about the use of R for Stata users,
see {hi:{help rsource##rsource_references:Muenchen and Hilbe (2010)}}.


{marker rsource_technote}{...}
{title:Technical note}

{pstd}
{cmd:rsource} works by running the {cmd:Rterm.exe} program of R.
The assumed R program path is displayed by {cmd:rsource} before any other output,
and is the assumed name and address of the R program run by {cmd:rsource}.
If the user does not specify the {cmd:rpath()} and {cmd:roptions()} options,
then {cmd:rsource} sets defaults.
In the case of {cmd:rpath()}, the default is the value of the {help macro:global macro} {hi:Rterm_path},
if that macro has been specified,
and otherwise is {hi:"Rterm.exe"} if the operating system is Windows and {hi:"/usr/bin/r"} otherwise.
In the case of {cmd:roptions()}, the default is the value of the {help macro:global macro} {hi:Rterm_options},
if that macro has been specified,
and is the empty string {hi:""} otherwise.
Therefore, the user should either set the system default file search path to include the directory containing the current version of R,
or set the {help macro:global macros} {hi:Rterm_path} and {hi:Rterm_options} to sensible default values before using {cmd:rsource}.

{pstd}
The setting of default values for {hi:Rterm_path} and {hi:Rterm_options}
is probably done most easily by inserting two lines into the user's Stata {help profile:profile do-file}
to initialize these {help macro:global macros} every time the user starts Stata.
For instance, under Windows, if the user's {help profile:profile do-file} contains the lines

{p 8 12 2}{cmd:. global Rterm_path `"c:\r\R-2.5.0\bin\Rterm.exe"'}{p_end}
{p 8 12 2}{cmd:. global Rterm_options `"--vanilla"'}{p_end}

{pstd}
and the {cmd:Rterm.exe} program of R, in the user's system, has path {hi:c:\r\R-2.5.0\bin\Rterm.exe},
then the user does not need to specify the {cmd:rpath()} and {cmd:roptions()} options of {cmd:rsource},
because the R path is then set to its correct value,
and the R options are set to the sensible default value {hi:--vanilla}.
Other possible R options, which can be set using {cmd:roptions()},
are listed in Appendix B of {it:An Introduction to R}
(see {hi:{help rsource##rsource_references:References}}).

{pstd}
Note that, when the user downloads a new version of R, the installation process creates a new directory,
containing the new version of {hi:Rterm.exe}.
Therefore, when R is upgraded,
the user should either change the system default file search path,
or change the line of code in the {help profile:profile do-file} setting the {help macro:global macro} {hi:Rterm_path}.


{title:Examples}

{p 8 12 2}{cmd:. rsource using nitz2.R}{p_end}

{p 8 12 2}{cmd:. rsource using nitz2.R, lsource}{p_end}

{p 8 12 2}{cmd:. rsource using nitz2.R, noloutput roptions(--slave)}{p_end}

{pstd}
The following example illustrates the use of the {cmd:terminator()} option
to run an R program embedded inside a Stata program.
We use Stata to write the {cmd:auto} dataset to a file {cmd:myauto.dta}.
We then use {cmd:rsource} to run an instream R program,
which uses the module {cmd:read.dta} of the R package {cmd:foreign}
to read {cmd:myauto.dta} into a data frame in R,
and then lists this data frame and its attributes.
The module {cmd:read.dta} inputs a Stata dataset from a file
and outputs it to an R data frame,
with attributes that can be listed using the {cmd:attributes()} command in R.
The use of {helpb saveold} to write the dataset {cmd:myauto.dta}
is probably a sensible precaution,
because the user's version of the R package {cmd:foreign}
may not be able to read Stata datafiles produced by the latest version of Stata.
Note that, in {help version:Stata Version 14},
the {helpb saveold} command in this example should have the added option {cmd:version(12)}.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. saveold myauto.dta, replace}{p_end}
{p 8 12 2}{cmd:. rsource, terminator(END_OF_R)}{p_end}
{p 8 12 2}{cmd:. library(foreign);}{p_end}
{p 8 12 2}{cmd:. rauto<-read.dta("myauto.dta", convert.f=TRUE);}{p_end}
{p 8 12 2}{cmd:. rauto;}{p_end}
{p 8 12 2}{cmd:. attributes(rauto);}{p_end}
{p 8 12 2}{cmd:. q();}{p_end}
{p 8 12 2}{cmd:. END_OF_R}{p_end}

{pstd}
The following example does the same things as the previous example,
using the {helpb outputst} module of the {help ssc:SSC} package {helpb stcmd}
to call {browse "http://www.stattransfer.com/":Stat/Transfer}
to output the {cmd:auto} dataset to an R workspace file {cmd:myauto.dta},
which is then input to R using {cmd:rsource}.
The present author has been advised that {browse "http://www.stattransfer.com/":Stat/Transfer}
is now the officially approved tool
for converting Stata datasets to R workspace files,
because, at the time of writing,
the module {cmd:read.dta} of the R library {cmd:foreign}
only reads Stata datasets in the formats of {help version:Stata versions 5-12},
and there is no promise from StataCorp that the {helpb saveold} command in Stata
will continue to output datasets in {help version:Stata versions 5-12} formats
in Stata versions 15 or higher.
Note that, in {help version:Stata Version 14},
the {helpb saveold} command in this example should have the added option {cmd:version(12)}.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. saveold myauto.dta, replace}{p_end}
{p 8 12 2}{cmd:. rsource, terminator(END_OF_R)}{p_end}
{p 8 12 2}{cmd:. library(foreign);}{p_end}
{p 8 12 2}{cmd:. rauto<-read.dta("myauto.dta", convert.f=TRUE);}{p_end}
{p 8 12 2}{cmd:. rauto;}{p_end}
{p 8 12 2}{cmd:. attributes(rauto);}{p_end}
{p 8 12 2}{cmd:. q();}{p_end}
{p 8 12 2}{cmd:. END_OF_R}{p_end}

{pstd}
The following advanced example demonstrates the use of the {cmd:roptions()} option of {cmd:rsource}
with the {cmd:--args} option of the R command
to pass {help tempfile:Stata temporary filenames} to R.
This practice enables the user to pass temporary R workspace files between Stata and R,
knowing that these temporary files will be deleted after the current Stata session,
or even after the end of execution of the current {help do:do-file},
if {cmd:rsource} is executed in a {help do:do-file}.
This practice can also be generalized
to pass other {help macro:Stata macro values} to R,
apart from temporary filenames.
On the other hand, this practice seems, at present,
to require the user to have a high level of R programming knowledge.
This example is intended as a demonstration,
and only transfers the {cmd:auto} dataset to R,
and then transfers it back to Stata,
reporting the various changes that have been made by {browse "http://www.stattransfer.com/":Stat/Transfer}
in the course of transferring the dataset in both directions.
The present author is currently thinking about how to make the integration of R and Stata easier to use,
and will welcome any suggestions from other users.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. tempfile tf1 tf2}{p_end}
{p 8 12 2}{cmd:. outputst r "`tf1'" /y}{p_end}
{p 8 12 2}{cmd:. rsource, terminator(END_OF_R) roptions(`" --vanilla --args "`tf1'" "`tf2'" "')}{p_end}
{p 8 12 2}{cmd:. trailargs<-commandArgs(trailingOnly=TRUE);}{p_end}
{p 8 12 2}{cmd:. trailargs;}{p_end}
{p 8 12 2}{cmd:. loaded<-load(trailargs[1]);}{p_end}
{p 8 12 2}{cmd:. loaded;}{p_end}
{p 8 12 2}{cmd:. loaded[1];}{p_end}
{p 8 12 2}{cmd:. .GlobalEnv[[loaded[1]]];}{p_end}
{p 8 12 2}{cmd:. myauto<-.GlobalEnv[[loaded[2]]];}{p_end}
{p 8 12 2}{cmd:. .GlobalEnv[[loaded[2]]]<-NULL;}{p_end}
{p 8 12 2}{cmd:. ls();}{p_end}
{p 8 12 2}{cmd:. myauto;}{p_end}
{p 8 12 2}{cmd:. attributes(myauto);}{p_end}
{p 8 12 2}{cmd:. save(myauto, file=trailargs[2]);}{p_end}
{p 8 12 2}{cmd:. END_OF_R}{p_end}
{p 8 12 2}{cmd:. clear}{p_end}
{p 8 12 2}{cmd:. inputst r "`tf2'"}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. char list}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker rsource_references}{...}
{title:References}

{phang}
Muenchen R. A. and J. M. Hilbe.
{it:R for Stata users}.
New York, NY: Springer; 2010.

{phang}
Venables W. N., D. M. Smith, and the R Development Core Team.
{it:An Introduction to R}.
Downloadable from
{browse "http://www.r-project.org/":the R Project Website}.

{phang}
The R Development Core Team.
{it:R Data Import/Export}.
Downloadable from
{browse "http://www.r-project.org/":the R Project Website}.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[GSW] C.3 Executing commands every time Stata is started},
{hi:[GSM] C.1 Executing commands every time Stata is started},
{hi:[GSU] C.1 Executing commands every time Stata is started}
{p_end}
{p 4 13 2}
On-line: help for {help profile}, {help profilew}, {help profilem}, {help profileu}{break}
         help for {helpb stcmd} if installed
{p_end}
