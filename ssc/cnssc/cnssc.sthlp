{smcl}
{* *! version 1.06  14June2021}{...}
{vieweralsosee "[R] ssc" "mansection R ssc"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] ado update" "help ado update"}{...}
{vieweralsosee "[R] net" "help net"}{...}
{vieweralsosee "[R] search" "help search"}{...}
{vieweralsosee "[R] sj" "help sj"}{...}
{vieweralsosee "[P] sysdir" "help sysdir"}{...}
{viewerjumpto "Introduction" "cnssc##Intro"}{...}
{viewerjumpto "Quick Start" "cnssc##quickstart"}{...}
{viewerjumpto "Syntax" "cnssc##syntax"}{...}
{viewerjumpto "Links to PDF documentation" "cnssc##linkspdf"}{...}
{viewerjumpto "Command overview" "cnssc##overview"}{...}
{viewerjumpto "Options for  ssc new" "cnssc##options_ssc_new"}{...}
{viewerjumpto "Options for  ssc hot" "cnssc##options_ssc_hot"}{...}
{viewerjumpto "Option for  ssc describe" "cnssc##option_ssc_describe"}{...}
{viewerjumpto "Options for  ssc install" "cnssc##options_ssc_install"}{...}
{viewerjumpto "Option for  ssc type" "cnssc##option_ssc_type"}{...}
{viewerjumpto "Options for  ssc copy" "cnssc##options_ssc_copy"}{...}
{viewerjumpto "Remarks" "cnssc##remarks"}{...}
{viewerjumpto "Examples" "cnssc##examples"}{...}
{viewerjumpto "Description" "cnssc##description"}{...}
{p2colset 1 12 14 2}{...}
{p2col:{bf:cnssc} {hline 2}}To mirror SSC Archive in China{p_end}
{p2col:}({mansection R ssc:View complete PDF manual entry}){p_end}
{p2colreset}{...}


{marker Intro}{...}
{title:Introduction}

{pstd}
{cmd:cnssc} is used mainly for Chinese users who may experience timeouts in using the {help ssc:ssc}
command with large packages. {cmd:cnssc} periodically mirrors the contents accessible 
from the {help ssc:ssc} command with a domestic server maintained by {browse "https://www.lianxh.cn":lianxh.cn}.

{pstd}
Selected packages from Github and other sources can also be downloaded 
using {cmd:cnssc} command. These packages are stored in {browse "https://www.lianxh.cn":lianxh.cn} server
and will be constant updating.

{pstd}
The new features of {cmd:cnssc} is as follows. You can use {cmd:cnssc get pkgname} 
to copy ancillary files from package {cmd:pkgname}. Meanwhile,
when you type {cmd:cnssc describe pkgname} or {cmd:cnssc install pkgname},
if there are ancillary files with this package, {cmd:cnssc} will automatally prompt you to install them. 

{pstd}
{cmd:cnssc} is fast for Chinese users. 


{marker quickstart}{...}
{title:Quick start}

{pstd}. {stata "cnssc new"}  (same as {cmd:ssc new})

{pstd}. {stata "cnssc hot, n(20)"} (same as {cmd:ssc hot, n(20)})

{pstd}. {stata "cnssc install reghdfe"}

{pstd}. {stata "cnssc install xtivreg2, replace"}

{pstd}. {stata "cnssc get rdbalance"}


{marker syntax}{...}
{title:Syntax}

{pstd}
The following contents are same as {help ssc:help ssc}, except the newly added {cmd:cnssc get}.

{phang}
Summary of packages most recently added or updated at SSC

{p 8 12 2}
{cmd:cnssc}
{cmd:new}
[{cmd:,}
{opt sav:ing}{cmd:(}{it:{help filename}}[{cmd:,} {opt replace}]{cmd:)}
{opt type}]

{phang}
Summary of most popular packages at SSC

{p 8 12 2}
{cmd:cnssc}
{cmd:hot}
[{cmd:,}
{cmd:n(}{it:#}{cmd:)}
{cmdab:auth:or}{cmd:(}{it:name}{cmd:)}]

{phang}
Describe a specified package at SSC

{p 8 12 2}
{cmd:cnssc}
{opt d:escribe}
{c -(} {it:pkgname} | {it:letter} {c )-}
[{cmd:,}
{cmd:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)}]

{phang}
Install a specified package from SSC

{p 8 12 2}
{cmd:cnssc}
{opt inst:all}
{it:pkgname}
[{cmd:,}
{opt all}
{opt replace}]

{phang}
Get ancillary files from a package

{p 8 12 2}
{cmd:cnssc}
{opt get}
{it:pkgname}
[{cmd:,}
{opt all}
{opt replace}
{opt force}]]

{phang}
Uninstall from your computer a previously installed package from SSC

{p 8 12 2}
{cmd:cnssc}
{opt uninstall}
{it:pkgname}

{phang}
Type a specific file stored at SSC

{p 8 12 2}
{cmd:cnssc}
{opt type}
{it:{help filename}}
[{cmd:, asis}]

{phang}
Copy a specific file from SSC to your computer

{p 8 12 2}
{cmd:cnssc}
{opt copy}
{it:{help filename}}
[{cmd:,}
{opt pl:us}
{opt p:ersonal}
{opt replace}
{opt pub:lic}
{opt bin:ary}]


{p 4 6 2}
where {it:letter} in {opt cnssc describe} is {opt a}-{opt z} or {opt _}.


{marker linkspdf}{...}
{title:Links to PDF documentation}

        {mansection R sscQuickstart:Quick start}

        {mansection R sscRemarksandexamples:Remarks and examples}

{pstd}
The above sections are not included in this help file.


{marker overview}{...}
{title:Command overview}

{phang}
{opt cnssc new} summarizes the packages made available or
    updated recently.   Output is presented in the Stata Viewer, and from
    there you may click to find out more about individual packages or 
    to install them.

{phang}
{opt cnssc hot} 
    lists the most popular packages -- popular based on a moving 
    average of the number of downloads in the past three months.
    By default, 10 packages are listed.

{phang}
{opt cnssc describe} {it:pkgname} describes, but does not install, the specified
    package.  Use {cmd:search} to find packages; see {manhelp search R}.  If
    you know the package name but do not know the exact spelling, type
    {opt cnssc describe} followed by one letter, {opt a}-{opt z} or {opt _}
    (underscore), to list all the packages starting with that letter.

{phang}
{opt cnssc install} {it:pkgname} installs the specified package.  You do not
    have to describe a package before installing it. (You may also
    install a package by using {cmd:net} {cmd:install}; see {manhelp net R}.)

{phang}
{opt cnssc get} {it:pkgname} copies the ancillary files of a specified package to your computer.
    Specifing {cmd:cnssc install pkgname, all} can install the package and copy its ancillary files in one step.
    (You may also copy the ancillary files by using {cmd:net} {cmd:get}; see {manhelp net R}.)

{phang}
{opt cnssc uninstall} {it:pkgname} removes the previously installed
    package from your computer.  It does not matter how the package was
    installed.  ({opt cnssc uninstall} is a synonym for {opt ado uninstall}, so
    either may be used to uninstall any package.)

{phang}
{opt cnssc type} {it:{help filename}} types a specific file stored at SSC.
    {opt cnssc cat} is a synonym for {opt cnssc type}, which may appeal to those
    familiar with Unix.

{phang}
{opt cnssc copy} {it:filename} copies a specific file stored at SSC to your
    computer.  By default, the file is copied to the current directory, but
    you can use options to change this.  {opt cnssc copy} is a rarely used
    alternative to {opt cnssc install} ...{cmd:, all}.  {opt cnssc cp} is a
    synonym for {opt cnssc copy}.


{marker options_ssc_new}{...}
{title:Options for  ssc new}

{phang}
{cmd:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)} specifies that the
    "what's new" summary be saved in {it:filename}.  If {it:filename} is
    specified without a suffix, {it:filename}{cmd:.smcl} is assumed.  If
    {opt saving()} is not specified, {cmd:saving(ssc_result.smcl)} is assumed.

{phang}
{opt type} specifies that the "what's new" results be displayed in the
    Results window rather than in the Viewer.


{marker options_ssc_hot}{...}
{title:Options for  ssc hot}

{phang}
{cmd:n(}{it:#}{cmd:)} 
    specifies the number of packages to list; {cmd:n(10)} is the default.
    Specify {cmd:n(.)} to list all packages in order of popularity.

{phang}
{cmd:author(}{it:name}{cmd:)} 
     lists the 10 most popular packages by the specified author.
     If {cmd:n(}{it:#}{cmd:)} is also specified, the top {it:#} 
     packages are listed.


{marker option_ssc_describe}{...}
{title:Option for  ssc describe}

{phang}
{cmd:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)} specifies that, in
     addition to the description's being displayed on your screen, it be saved
     in the specified file.

{pmore}
    If {it:filename} is specified without an extension, {opt .smcl} will be
    assumed, and the file will be saved as a {help smcl:SMCL} file.

{pmore}
    If {it:filename} is specified with an extension, no default extension
    is added.  If the extension is {opt .log}, the file will be stored as
    a text file.

{pmore}
    If {opt replace} is specified, {it:filename} is replaced if it already
    exists.


{marker options_ssc_install}{...}
{title:Options for  ssc install}

{phang}
{opt all} specifies that any ancillary files associated with the
    package be downloaded to your current directory, in addition
    to the program and help files being installed.  Ancillary files are files
    that do not end in {opt .ado} or {opt .sthlp} and typically contain
    datasets or examples of the use of the new command.

{pmore}
    You can find out which files are associated with the package by typing
    {cmd:cnssc describe} {it:pkgname} before or after installing.  If you
    install without using the {opt all} option and then want the ancillary
    files, you can {opt cnssc install} again.

{phang}
{opt replace} specifies that any files being downloaded that already exist
    on your computer be replaced by the downloaded files.  If
    {opt replace} is not specified and any files already exist, none of the
    files from the package is downloaded or installed.

{pmore}
    It is better not to specify the {opt replace} option and wait to see if
    there is a problem.  If there is a problem, it is usually better to
    uninstall the old package by using {opt cnssc uninstall} or
    {opt ado uninstall} (which are, in fact, the same command).


{marker options_ssc_get}{...}
{title:Options for  ssc get}

{phang}
{opt all} typed with either {cmd:cnssc install} or {cmd:cnssc get} is equivalent to typing {cmd:cnssc install} followed by {cmd:cnssc get}.

{phang}
{opt replace} specifies that the downloaded files replace existing files if any of the files already exists.

{phang}
{opt force} specifies that the downloaded files replace existing files if any of the files already exists, even if
        Stata thinks all the files are the same. {cmd:force} implies {cmd:replace}.


{marker option_ssc_type}{...}
{title:Option for  ssc type}

{phang}
{opt asis} affects how files with the suffixes {cmd:.smcl} 
    and {cmd:.sthlp} are displayed.  The default is to interpret SMCL
    directives the file might contain.  {cmd:asis} specifies that the file be
    displayed in raw, uninterpreted form.


{marker options_ssc_copy}{...}
{title:Options for  ssc copy}

{phang}
{opt plus} specifies that the
    file be copied to the {cmd:PLUS} directory, the directory where
    community-contributed additions are installed.  Typing {helpb sysdir}
    will display the identity of the {cmd:PLUS} directory on your computer.

{phang}
{opt personal} specifies that the file be copied to your {cmd:PERSONAL}
    directory as reported by {helpb sysdir}.

{pmore}
    If neither {opt plus} nor {opt personal} is specified,
    the default is to copy the file to the current directory.

{phang}
{opt replace} specifies that, if the file already exists on your computer,
    the new file replace it.

{phang}
{opt public} specifies that the new file be made readable by everyone;
    otherwise, the file will be created according to the default permission you
    have set with your operating system.

{phang}
{opt binary} specifies that the file being copied is a binary file and that it
    is to be copied as is.  The default is to assume that the file is a text
    file and change the end-of-line characters to those appropriate for your
    computer/operating system.


{marker remarks}{...}
{title:Remarks}

{pstd}
See {help ssc:help ssc}.


{marker examples}{...}
{title:Examples}

{pstd}Describe most recently added or updated packages at SSC{p_end}
{phang2}{stata ". cnssc new"}

{pstd}Describe the most popular packages at SSC{p_end}
{phang2}{stata ". cnssc hot"}{p_end}
{phang2}{stata ". cnssc hot, n(10) author(Cox)"}

{pstd}Describe the package {cmd:firthlogit}{p_end}
{phang2}{stata ". cnssc describe firthlogit"}

{pstd}Describe the package {cmd:firthlogit} and save the description to the
file {cmd:firthlogit.log}{p_end}
{phang2}{stata ". cnssc describe firthlogit, saving(firthlogit.log)"}

{pstd}List all packages, along with a brief description, that begin with the
letter {cmd:f}{p_end}
{phang2}{stata ". cnssc describe f"}

{pstd}Same as above, but also save the listing to the file {cmd:f.index}{p_end}
{phang2}{stata ". cnssc describe f, saving(f.index)"}

{pstd}Install package {cmd:firthlogit}{p_end}
{phang2}{stata ". cnssc install firthlogit"}{p_end}

{pstd}Install package {cmd:firthlogit} and ancillary files{p_end}
{phang2}{stata ". cnssc install firthlogit, all"}

{pstd}Copy ancillary files of package {cmd:firthlogit} to current directory{p_end}
{phang2}{stata ". cnssc get firthlogit"}

{pstd}Uninstall previously installed package {cmd:firthlogit}{p_end}
{phang2}{stata ". cnssc uninstall firthlogit"}

{pstd}Type file {cmd:potter.do} that is stored at SSC{p_end}
{phang2}{stata ". cnssc type potter.do"}

{pstd}Copy file {cmd:fuzzydid_Gentzkowappli.do} from SSC to your computer{p_end}
{phang2}{stata ". cnssc copy fuzzydid_Gentzkowappli.do"}{p_end}



{marker description}{...}
{title:Description and brief history of SSC}

{pstd}
{bf:ssc} is based on {bf:archutil} by Nicholas J. Cox of the Department of Geography at Durham
University, UK, who is coeditor of the {it:Stata Journal} and author of {it:Speaking Stata Graphics} and by
Christopher F. Baum of the Department of Economics at Boston College and author of the Stata
Press books {it:An Introduction to Modern Econometrics Using Stata} and
{it:An Introduction to Stata Programming}. The reworking of the original was done with their blessing and their participation.
Baum maintains the Stata-related files stored at the SSC Archive. We thank him for this contribution
to the Stata community (See [{bf:R}] {mansection R sscAcknowledgments:Acknowledgments}).

{pstd}
{opt ssc} works with packages (and files) from the Statistical Software
Components (SSC) Archive, which is often called the Boston College Archive and
is provided by {browse "http://www.repec.org"}.

{pstd}
The SSC has become the premier Stata download site for community-contributed
software on the web.  {opt ssc} provides a convenient interface to the
resources available there.  For example, on
{browse "http://www.statalist.org/":Statalist}, users will often
write

{p 8 8 4}
The program can be found by typing {cmd:cnssc install newprogramname}.

{pstd}
Typing that would load everything associated with {cmd:newprogramname},
including the help files.

{pstd}
If you are searching for what is available, 
type {cmd:cnssc} {cmd:new} and {cmd:cnssc} {cmd:hot}, and
see {manhelp search R}.
{opt search} searches the SSC and other places, too.
{cmd:search}
provides a GUI interface from which programs can be
installed, including the programs at the SSC Archive.

{pstd}
You can uninstall particular packages by using {cmd:cnssc} {cmd:uninstall}.
For the packages that you keep, 
see {helpb ado update:[R] ado update}
for an automated way of keeping those packages up to date.


{marker Authors}{...}
{title:Authors}

{pstd}
Yujun Lian{break}
Lingnan College, Sun Yat-Sen University, China.{break}
{browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}

{pstd}
Christopher F. Baum{break}
Boston College{break}
Chestnut Hill, MA USA{break}
{browse "mailto:baum@bc.edu":baum@bc.edu}{p_end}


{title:Also see}

{psee} 
{help adoupdate}, {help net}, {help findit}, {help search}, {help sj}

{psee} 
{help lianxh} (if installed), {help songbl} (if installed), {help lxhuse} (if installed)
