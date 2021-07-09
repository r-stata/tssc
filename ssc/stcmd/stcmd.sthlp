{smcl}
{hline}
help for {cmd:stcmd}, {cmd:inputst}, {cmd:outputst} and {cmd:outputstold}{right:(Roger Newson)}
{hline}


{title:Running the Stat/Transfer command from inside Stata}

{p 8 21 2}
{cmd:stcmd} [ {it:filetype1} ] {it:infilename}{cmd:.}{it:ext1} [ {it:filetype2} ] {it:outfilename}{cmd:.}{it:ext2} [ {it:switches} ]

{p 8 21 2}
{cmd:stcmd} {it:command_filename}{cmd:.stcmd}

{p 8 21 2}
{cmd:inputst} [ {it:filetype} ] {it:infilename}{cmd:.}{it:ext} [ {it:switches} ]

{p 8 21 2}
{cmd:outputst} [ {it:filetype} ] {it:outfilename}{cmd:.}{it:ext}  [ {it:switches} ]

{p 8 21 2}
{cmd:outputstold} [ {it:filetype} ] {it:outfilename}{cmd:.}{it:ext}  [ {it:switches} ]


{title:Description}

{pstd}
{cmd:stcmd} calls the Stat/Transfer command {cmd:st} to convert the data file {it:infilename.ext1} to
a new data file {it:outfilename.ext2}, or to obey the commands in the Stat/Transfer command file
{it:command_filename}{cmd:.stcmd}.
{cmd:inputst} inputs into the memory a Stata-converted version
of the data file {it:infilename.ext}, overwriting any existing dataset.
{cmd:outputst} outputs a converted version of the Stata dataset in memory to the data file {it:outfilename.ext}.
{cmd:outputstold} is an alternative version of {cmd:outputst},
for use if the user's version of Stat/Transfer is not advanced enough 
to read datasets in the format of the user's version of Stata.
File types are determined by {it:filetype}, {it:filetype1} and/or {it:filetype2}, if present,
and by Stat/Transfer from the extensions {it:ext}, {it:ext1} and/or {it:ext2} otherwise.
File names containing spaces must be given in quotes.
{cmd:stcmd}, {cmd:inputst} or {cmd:outputst} output a running commentary on the transfer process
(including the Stat/Transfer command to be submitted)
to the {help log:Stata log} or Results window,
unless the user uses the {helpb quietly} prefix.


{title:Switches for use with  {cmd:stcmd}, {cmd:inputst}, {cmd:outputst} and {cmd:outputstold}}

{pstd}
These are usually prefixed by {cmd:/} under Windows and by {cmd:-} under Linux.
A list of these switches can be found in the Stat/Transfer {cmd:.pdf} manual for the user's installation.
Some Windows switches for Version 15 of Stat/Transfer are as follows:

{p 4 8 2}
{cmd:/ex}{it:filename} tells Stat/Transfer to execute the commands
in the Stat/Transfer command file {it:filename}
before executing the supplied Stat/Transfer command.
For instance, the switch {cmd:\exmysetup.stcmd}
will cause Stat/Transfer to run {cmd:mysetup.stcmd}
before executing the Stat/Transfer command.

{p 4 8 2}
{cmd:/o-} specifies that Stat/Transfer will not optimize the output data set to be as small as possible
(as Stat/Transfer does by default).
Stat/Transfer Technical Support do not recommend users to use this switch,
because it causes files to be needlessly large,
and because the optimization process also guarantees that Unicode string variables will be well-formed,
which is important with {help version:Stata Versions} 14 or higher.

{p 4 8 2}
{cmd:/oc} specifies that Stat/Transfer will optimize the output data set to be as small as possible,
and automatically drop constant or missing variables.

{p 4 8 2}
{cmd:/od} specifies that Stat/Transfer will optimize the output data set to be as small as possible,
but produce double precision variables where appropriate.

{p 4 8 2}
{cmd:/ocd} specifies that Stat/Transfer will optimize the output data set to be as small as possible,
and automatically drop constant or missing variables, but produce double precision variables where appropriate.

{p 4 8 2}
{cmd:/q} specifies that Stat/Transfer will execute quietly, producing no messages,
with the exception of error messages and warnings that a file is about to be overwritten.

{p 4 8 2}
{cmd:/r}[{it:page}{cmd:!}]{it:coor} specifies a worksheet range,
limited to page {it:page} and coordinates specified by {it:coor},
in an input worksheet file.
The coordinates specify a top left and bottom right cell in the worksheet.
For instance, {cmd:/r2!b5:e75} specifies that the data are on page 2 of the input file,
between the top left cell {cmd:b5} and the bottom right cell {cmd:e75}.

{p 4 8 2}
{cmd:/s} will turn on messages and leave the Stat/Transfer window open until the return key is pressed.  
This may be useful if Stat/Transfer appears not to be working.

{p 4 8 2}
{cmd:/t}{it:tablename} is used in order to specify a table (or worksheet)
within a data source containing multiple tables (or worksheets).

{p 4 8 2}
{cmd:/v} (verbose) specifies that Stat/Transfer will write messages monitoring the progress of the transfer
to the operating-system window.
This can be useful if used with the {cmd:/s} switch,
which causes the operating-system window to stay open until the return key is pressed.

{p 4 8 2}
{cmd:/y} specifies that {it:outfilename}{cmd:.}{it:ext} will be overwritten, if it already exists.
(If {cmd:/y} is not specified, then Stat/Transfer consults the user before overwriting files.)


{title:Remarks}

{pstd}
Stat/Transfer can be installed on Microsoft Windows, MacOS, Linux and Solaris.
It is available from {browse "http://www.stata.com/":Stata Corporation}
and developed by {browse "http://www.stattransfer.com/":Circle Systems}.

{pstd}
{cmd:inputst}, {cmd:outputst} and {cmd:outputstold} call {cmd:stcmd},
which in turn calls the Stat/Transfer {cmd:st} command.
For a list of file types and standard extensions used by Stat/Transfer,
see the Stat/Transfer {cmd:.pdf} manual or on-line help.

{pstd}
{cmd:inputst}, {cmd:outputst} and {cmd:outputstold} all use {help tempfile:temporary Stata datafiles}
to pass the data in the memory to and from Stat/Transfer.
These {help tempfile:temporary Stata datafiles} are automatically deleted
when {cmd:inputst} and {cmd:outputst} finish execution.
In the case of {cmd:outputstold},
the {help tempfile:temporary Stata datafile} is written using {helpb saveold},
and will be in the format of an earlier Stata version,
which may be recognized by out-of-date versions of Stat/Transfer.
If the user does not use the {helpb quietly} prefix,
then {cmd:inputst} and {cmd:outputst} give a running commentary to the user
on the creation of these {help tempfile:temporary Stata datafiles},
and on their use as input or output by Stata and Stat/Transfer.
This is done in order to inform the user of the state of progress of the transfer,
in case the transfer is not completed successfully.
The {cmd:/s} or {cmd:-s} switch mentioned above, may also be useful,
if Stat/Transfer does not appear to be working.

{marker stcmd_technote}{...}
{title:Technical notes}

{pstd}
The path for the Stat/Transfer {cmd:st} command varies from system to system.
{cmd:stcmd} assumes that this path is simply {cmd:st}, unless the {help macro:global macro}
{hi:StatTransfer_path} is evaluated, in which case {cmd:stcmd} assumes that the path is equal to the value of that macro.
Therefore, if the directory containing Stat/Transfer is on the user's default path,
then the user need not set a value for the {help macro:global macro} {hi:StatTransfer_path}.
Otherwise, the user should set a value for the {help macro:global macro} {hi:StatTransfer_path}.
This is probably done most easily by inserting a line into the user's {help profile:profile do-file}
to initialize this {help macro:global macro} every time the user starts Stata.
For instance, under Windows, if the user's {help profile:profile do-file} contains the line

{p 8 12 2}{cmd:. global StatTransfer_path `"C:\Program Files\StatTransfer13-64\st.exe"'}{p_end}

{pstd}
and the {cmd:st} program of Stat/Transfer, in the user's system, has path {hi:"C:\Program Files\StatTransfer13-64\st.exe"},
then {cmd:stcmd} will find the {cmd:st} command of Stat/Transfer correctly on that path.

{pstd}
Note that, when the user upgrades to a new version of Stat/Transfer, the upgrade creates a new directory,
containing the new version of {hi:st.exe}.
Therefore, when Stat/Transfer is upgraded,
either the user's default directory search path should be altered,
or the line of code in the user's {help profile:profile do-file} setting the global macro {hi:StatTransfer_path} should be altered.

{pstd}
The user may also find, after a Stat/Transfer upgrade, that the {cmd:stcmd} package has been downgraded to Stata Version 6.
This is because the Stat/Transfer installation program may install the Stata Version 6 version of Stat/Transfer
in the user's {cmd:PERSONAL} directory
(see help for {helpb adopath}).
This installation in the {cmd:PERSONAL} directory typically contains the Stata Version 6 files
{cmd:stcmd.ado}, {cmd:inputst.ado}, {cmd:outputst.ado},
{cmd:stcmd.hlp}, {cmd:inputst.hlp}, and {cmd:outputst.hlp}.
If the user has a higher version of Stat/Transfer installed in a directory
in a position after PERSONAL of the {helpb adopath},
then the user should probably remove these files from the {cmd:PERSONAL} directory.
After the user has done this, Stata will use the higher version of {cmd:stcmd}.


{title:Examples}

{p 8 12 2}{cmd:. inputst spss.sav}{p_end}

{p 8 12 2}{cmd:. outputst mydata.Rdata /y}{p_end}

{p 8 12 2}{cmd:. inputst mydata.Rdata /y}{p_end}

{p 8 12 2}{cmd:. stcmd R mydata.Rdata hisdata.csv /y}{p_end}
{p 8 12 2}{cmd:. insheet using hisdata.csv, comma clear}{p_end}

{p 8 12 2}{cmd:. stcmd mystcom.stcmd}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[P] macro}, {hi:[P] sysdir}, {hi:[D] save},{break}
{hi:[GSW] C.3 Executing commands every time Stata is started},{break}
{hi:[GSM] C.1 Executing commands every time Stata is started},{break}
{hi:[GSU] C.1 Executing commands every time Stata is started}
{p_end}
{p 4 13 2}
On-line: help for {helpb macro}, {helpb adopath}, {helpb sysdir},
{helpb saveold},
{helpb profile}, {helpb profilew}, {helpb profilem}, {helpb profileu}
{p_end}
{p 4 13 2}
{bind:  }Other: {hi:Stat/Transfer {cmd:.pdf} Manual} if installed
{p_end}
