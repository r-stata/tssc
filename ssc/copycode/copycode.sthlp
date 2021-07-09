{smcl}
{* *! version 1.0.0, 14aug2012}{...}
{cmd:copycode}
{hline}

{title:Title}

{phang}
{bf:copycode -- produce modular self-written ado files}


{title:Syntax}

{p 8 17 2}
{cmd:copycode} {it:projectname} {cmd:,} {opt i:nputfile(inputfilename)}{break}[ {cmd:{c -(}}{opt t:argetfile(targetfilename)} | {opt noc:opy} {cmd:{c )-}} {it:other_options} ]

{synoptset 30 tabbed}{...}
{synopthdr:main_options}
{synoptline}
{synopt: {it:projectname}}Name of project to be processed{p_end}
{synopt: {opt i:nputfile(inputfilename)}}Name/path of input file that contains the file listings{p_end}
{synopt: {opt t:argetfile(targetfilename)}}Name/path of output file{p_end}
{synopt: {opt noc:opy}}Show command output without performing the copy operation{p_end}
{synopt:}{p_end}
{synopthdr:other_options}
{synoptline}
{synopt: {opt si:mplemode}}Process project under simple mode (as opposed to ado mode){p_end}
{synopt: {opt replace}}Replace target file if it already exists{p_end}
{synopt: {opt force}}Do not confine copying of lines to copy regions{p_end}
{synopt: {opt st:arbang(stb_mode)}}Determine whether starbang lines should be copied{p_end}
{synopt: {opt nop:rogdrop}}Do not automatically drop program corresponding to {it:targetfilename} from memory{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:copycode} copies different source code files into one file.
A typical application would be an ado file whose final version is supposed to contain subroutines and/or Mata routines that you are accustomed to use and re-use in your ados.

{pstd}
{cmd:copycode} is thought to facilitate code production, code maintenance and code distribution for Stata programmers who write Stata/Mata code on a large scale.
You can write small programs and functions, each one in a separate file, test them thoroughly, and then include them in any ado file using {cmd:copycode}.
When you have to make changes to these general purpose functions the re-make of the ado files is completely automated.

{pstd}
If you have written many ado files with many interdependencies (i.e. many of your self-written ados call other self-written ados), {cmd:copycode} enables you to organize your code in such a way that each final ado file is "modular", i.e. does not depend on other user-written code files.
This makes the distribution of your files easier.

{pstd}
If you do not want to use {cmd:copycode} to produce your final ado files, you can still use it to shed light on the dependency structure of your files (see the {help copycode##nocopy:nocopy subsection} below).

{pstd}
Another feature of {cmd:copycode} is that it allows you to add "private" comments to your source code file.
Your final published file will not include these lines.

{pstd}
There is also a wrapper command for {cmd:copycode} available called {help fastcc} ("fast copycode") that will allow you to work with {cmd:copycode} more efficiently when using it interactively.

{pstd}
For an alternative description of {cmd:copycode} see {help copycode##references:Schneider (2012)}.


{title:Defintions used in this help entry}

{pstd}
The definitions of the following table are repeated in the help text as terms appear.
The table is thought to serve as a reference for a more thorough reading of this help entry.

{p2colset 5 34 34 0}{...}
{p2col:modular ado file}A (user-written) ado file whose functioning does not require the presence/installation of other user-written code files.{p_end}
{p2col:project}Identifies a set of code files that belong together.{p_end}
{p2col:main adv}File that is listed first for a project and whose name corresponds to the project name and that has an .adv extension.
It contains the main program of a (ado) project.{p_end}
{p2col:project component file}Each file entry under a project in the input file.{p_end}
{p2col:dependency}Program or function that is called by another program or function.
There can be direct/first-order and indirect/higher-order dependencies.{p_end}
{p2col:copy region limits}Strings '!copycodebeg=>' (beginning of a copy region) and '!copycodeend||' (end of a copy region).{p_end}
{p2col:copy region}Lines of a text file between the strings '!copycodebeg=>' and '!copycodeend||'.{p_end}


{title:Options}

{phang}
{cmd:{it:projectname}} Name of project in the input file that pins down the file listing.

{phang}
{cmd:inputfile(inputfilename)} specifies the file path and name of the input file.
Relative file paths are accepted.
The absolute part of the path is assumed to be the working directory.

{phang}
{cmd:targetfile(targetfilename)} determines the file path and name of the output file.
Relative file paths are accepted.
The absolute part of the path is assumed to be the working directory.

{phang}
{cmd:nocopy} can be used to specify that no targetfile should be created.
If this option is used, {cmd:copycode} performs fewer consistency checks of what you supply as input.
It still performs a consistency check of the input file.
It does not, however, check for the existence of files, nor does it check for the consistency of copy region limits within code files.

{pmore}
When using option {opt nocopy}, options {opt replace}, {opt force} and {opt starbang} are ignored.
Option {opt nocopy} does observe the usual rules that apply in determining whether {cmd:copycode} is run in simple mode or in ado mode.

{phang}
{cmd:simplemode} will force simple mode.
Ado mode is entered when the first file for the project to be processed is a "main adv" file.
Option {opt simplemode} overrides this.
Then, only the files listed under {it:projectname} (direct dependencies) will be copied together, without checking for dependencies of adv files that belong to the project (see section {help copycode##modes:Simple mode and ado mode} below).

{phang}
{cmd:replace} will overwrite the outputfile if it already exists.

{phang}
{cmd:force} tells {cmd:copycode} to perform copy operations irrespective of copy regions of the code files.
Under option {opt force} all lines of all files will be copied except for starbang lines.
What happens to starbang lines is determined by option {opt starbang(stb_mode)}.

{phang}
{cmd:starbang(stb_mode)} specifies whether starbang lines should be copied to the output file.
The contents of starbang lines are displayed by the {help which} command.
There are three modes, i.e. {it:stb_mode} may assume three values:
"skip" will not copy any starbang lines.
"first" will only copy starbang lines of the main adv file.
"all"  will copy all starbang lines.

{pmore}
Typically, when producing an ado file you only want to have the starbang line(s) of the main adv displayed by {cmd:which} and not the ones of subordinate advs or subroutines, which is why {it:stb_mode} defaults to "first" in ado mode.
In simple mode, however, {it:stb_mode} defaults to "all".

{phang}
{cmd:noprogdrop} will prevent {cmd:copycode} from automatically issuing a{break}{cmd:. capture program drop {it:targetbasename}}{break}statement, where {it:targetbasename} is the file name "base" of {it:targetfilename}.
For example, if you specify {cmd:targetfile(mypath/mytarget.ado)}, copycode normally issues a{break}{cmd:. capture program drop mytarget}{break}to ensure that after the re-make of the project no old version of the project resides in memory.
Option {opt noprogdrop} prevents this statement from being executed.

{pmore}
Usage of option {opt nocopy} will also prevent the "program drop" statement.


{title:Remarks}

{pstd}
Remarks are presented under the following headings:

    {help copycode##overview:Overview}
    {help copycode##backup:Backup}
    {help copycode##modes:Simple mode and ado mode}
    {help copycode##fileextensions:File extensions} 
    {help copycode##inputfile:Input file structure}
    {help copycode##dependencies:Code dependencies}
    {help copycode##copyregions:Copy regions}
    {help copycode##fileloss:Avoiding file loss}
    {help copycode##downsides:Downsides}    
    {help copycode##nocopy:The 'nocopy' option}
    {help copycode##misc:Miscellaneous}

{marker overview}{...} {* -------------------------------- REMARKS: OVERVIEW ----------------------------- }
{title:Overview}

{pstd}
{cmd:copycode} compiles a list of code files (text files) that accounts for code dependencies of a project and copies code from these files to {it:targetfile}.

{pstd}
A dependency is a user-written program or function that is called by another user-written program or function.
There can be direct/first-order and indirect/higher-order dependencies.
If a.ado calls b.ado and b.ado calls c.ado, b.ado is a direct dependency of a.ado, c.ado is a direct dependency of b.ado, and c.ado is an indirect dependency of a.ado.
With many ado files, these dependency structures can become complex.

{pstd}
{cmd:copycode} will figure out dependency structures if you supply it with an input file that lists, for each project, the direct dependencies.
This input file must have the following structure:

{p2colset 5 10 12 0}{...}
{p2col:}- Each line must contain exactly two tokens.{p_end}
{p2col:}- The first token specifies the project.{p_end}
{p2col:}- The second token specifies the path and name to a file.{p_end}

{pstd}
An example of an input file is given in the {help copycode##inputfile:Input file structure} section.
Once all dependencies have been determined, {cmd:copycode} copies all relevant code into {it:targetfile} which then does not depend on any other user-written files.
The targetfile must always be specified explicitly.
This is to prevent accidental overwriting of existing files.

{pstd}
While copying, {cmd:copycode} takes so-called "copy regions" into account.
It copies only lines that you have marked to be copied.


{marker backup}{...} {* -------------------------------- REMARKS: BACKUP ----------------------------- }
{title:Backup of files}

{pstd}
{cmd:copycode} concerns itself mainly with writing ado files to disk.
If you use or try out {cmd:copycode}, 1) make a backup of your self-written files and 2) keep the backup in a safe place.
Otherwise there is the danger of accidentially overwriting and losing self-written code files.


{marker modes}{...} {* -------------------------------- REMARKS: MODES ----------------------------- }
{title:Simple mode and ado mode}

{pstd}
{cmd:copycode} compiles file lists differently, depending whether it is run in simple mode or in ado mode.
Simple mode can be invoked e.g. by using option {opt simplemode}.
Then the files to be copied correspond exactly to the lines of the input file whose first-column entry equals {it:projectname}.

{pstd}
In ado mode, {cmd:copycode} works differently.
Ado mode is related to the following problem:
When you write an ado file and your ado file depends on other ados you have written it becomes difficult to distribute your code - especially if you have many ados with many interdependencies.

{pstd}
One solution is to use {cmd:copycode} to assemble the new ado file that contains the code of all ados that are necessary to make the new ado file run.
For example, if new.ado calls your user-written function existing.ado, you can (sort of) simply copy the code from existing.ado into new.ado, that way making it a modular routine.
Roughly speaking, this is the approach taken by {cmd:copycode}.
What you have to supply to the command is an input file that lists the direct dependencies of your (ado) projects.

{pstd}
Ado mode is entered when the first file of a project is an adv file (see the next section on file extensions) whose file name is identical to the project name.
This file is then called the "main adv" of the project.

{pstd}
Most of what follows is related to using {cmd:copycode} in ado mode.


{marker fileextensions}{...} {* -------------------------------- REMARKS: FILE EXTENSIONS ----------------------------- }
{title:File extensions}

{pstd}
{cmd:copycode} handles the following file extensions in a special way:

{p2colset 12 22 22 0}{...}
{p2col:.adv}"ado development file", contains the newly written code necessary for your new ado project.
In ado mode, when encountering an adv file that is listed as a dependency in the input file, {cmd:copycode} will search the input file for a correspondingly named project.
This project must exist, otherwise {cmd:copycode} will error out.
Any files listed under this project (which may just consist of one adv file) are included in the list of files to be copied and in turn searched for further dependencies.{p_end}
{p2col:.ado}Existing modular user-written ado files to be used as subroutines (appended) to the new ado project{p_end}
{p2col:.stp}"Stata program file", contains modular Stata code to be appended to the code in the adv file.
stp files are thought to contain short and simple Stata programs that do not depend on other programs.
You may ignore stp file types and put all of your Stata programs into adv files.{p_end}
{p2col:.mata}Mata source code file, contains modular Mata code to be appended to the code in the adv file{p_end}

{pstd}
These files contain Stata programs and Mata functions.
You should always name your files according to the names of the programs, e.g. sub1.stp should contain a Stata program called "sub1", and func2.mata should contain a Mata function called "func2".

{pstd}
{cmd:copycode} will copy the code from the files indicated in your input file in the order given in the table above:
First it copies your new code from your new adv, then (possibly) codes from other adv files, then code from modular (i.e. non-dependent) ado files.
Then it copies code from stp files, then code from mata files, and finally code from files with any other extension.

{pstd}
In ado mode, within each extension group, files are copied in the order of appearance in the input file.
In simple mode files are copied exactly in the order of appearance in the input file.

{pstd}
{cmd:copycode} does not check for dependencies of stp files because they should only contain small programs that do not call other programs.
Checking for the depenencies among mata files would be desirable, but this has not yet been implemented.
To summarize, only adv files are checked for dependencies.


{marker inputfile}{...} {* -------------------------------- REMARKS: INPUT FILE STRUCTURE ----------------------------- }
{title:Input file structure}

{pstd}
{cmd:copycode} can detect complex dependency structures among user-written files.
What it needs as an input, and what you have to provide, is a file that lists all (ado) projects and their direct dependencies.
This is enough information to create a list of dependencies of all orders, for any project in the input file.

{pstd}
Here is an example of such an input file:

{p2colset 12 22 22 0}{...}
{p2col:myinput.txt ------------------------------------}{p_end}
{p2col://}Optional project A description goes here{p_end}
{p2col://}note that comments are allowed in the input file{p_end}
{p2col:proj_a}c:\ado\personal\proj_a.adv{p_end}
{p2col:proj_a}c:\ado\personal\proj_b.adv{p_end}
{p2col:proj_a}c:\ado\personal\modular.ado{p_end}
{p2col:proj_a}c:\ado\personal\sub1.stp{p_end}
{p2col:proj_a}c:\ado\personal\sub2.stp{p_end}
{p2col:proj_a}c:\ado\personal\func1.mata{p_end}
{p2col:proj_a}c:\ado\personal\func2.mata{p_end}
{p2col:}{p_end}
{p2col://}Optional project B description goes here{p_end}
{p2col:proj_b}c:\ado\personal\proj_b.adv{p_end}
{p2col:proj_b}c:\ado\personal\proj_c.adv{p_end}
{p2col:proj_b}c:\ado\personal\func3.mata{p_end}
{p2col:proj_b}c:\ado\personal\sub2.stp{p_end}
{p2col:proj_b}c:\ado\personal\sub3.stp{p_end}
{p2col:proj_b}c:\ado\personal\func2.mata{p_end}
{p2col:proj_b}c:\ado\personal\remarks.txt{p_end}
{p2col:}{p_end}
{p2col://}Optional project C description goes here{p_end}
{p2col:proj_c}c:\ado\personal\proj_c.adv{p_end}
{p2col:------------------------------------------------}{p_end}

{pstd}
The first column of your input file specifies the project name.
The second column specifies the path to the files whose code goes into the output file.

{pstd}
Suppose you want to create a new ado file proj_a.ado that you want to generate using {cmd:copycode}, in ado mode.
Then you create a project "proj_a.ado" in your input file.
The first entry of that project references a file "proj_a.adv".
This is the "main adv" of proj_a and contains the main routine of the new ado file.
Then you add entries for all direct dependencies that occur in the code contained in proj_a.adv.

{pstd}
Project names are not case-sensitive and may not contain blanks.
File paths may contain blanks but be sure to surround the entries by double quotes or compound double quotes in this case.
File names may not contain blanks.
File paths must be supplied as absolute paths (e.g. c:\ado\personal\mydir\myfile.adv).
Relative file paths (e.g. mydir\myfile.adv) are not allowed in the input file.
File paths may not exceed 244 characters.

{pstd}
Tab characters on comment lines and in between input tokens are allowed and are interpreted as blanks.

{pstd}
As can be seen from the above example, the input file may contain empty lines and comments.
Comments must be indicated by "//" which must be the first non-blank character sequence on a comment line.
Comments must be on a separate line, i.e. they may not occur on the same line as an input entry.

{pstd}
When running {cmd:copycode} in ado mode, the above input file will produce ado files that contain code from the following files, in the order as given below:

{p2colset 12 22 22 0}{...}
{p2col:Project A}{p_end}
{p2col:}proj_a.adv{p_end}
{p2col:}proj_b.adv{p_end}
{p2col:}proj_c.adv{p_end}
{p2col:}modular.ado{p_end}
{p2col:}sub1.stp{p_end}
{p2col:}sub2.stp{p_end}
{p2col:}sub3.stp{p_end}
{p2col:}func1.mata{p_end}
{p2col:}func2.mata{p_end}
{p2col:}func3.mata{p_end}
{p2col:}remarks.txt{p_end}
{p2col:} {p_end}
{p2col:Project B}{p_end}
{p2col:}proj_b.adv{p_end}
{p2col:}proj_c.adv{p_end}
{p2col:}sub2.stp{p_end}
{p2col:}sub3.stp{p_end}
{p2col:}func3.mata{p_end}
{p2col:}func2.mata{p_end}
{p2col:}remarks.txt{p_end}
{p2col:} {p_end}
{p2col:Project C}{p_end}
{p2col:}proj_c.adv{p_end}

{pstd}
When running {cmd:copycode} in simple mode, the output files will contain code from the file list recorded unter each project, in the same order:

{p2colset 12 22 22 0}{...}
{p2col:Project A}{p_end}
{p2col:}proj_a.adv{p_end}
{p2col:}proj_b.adv{p_end}
{p2col:}modular.ado{p_end}
{p2col:}sub1.stp{p_end}
{p2col:}sub2.stp{p_end}
{p2col:}func1.mata{p_end}
{p2col:}func2.mata{p_end}
{p2col:} {p_end}
{p2col:Project B}{p_end}
{p2col:}proj_b.adv{p_end}
{p2col:}proj_c.adv{p_end}
{p2col:}func3.mata{p_end}
{p2col:}sub2.stp{p_end}
{p2col:}sub3.stp{p_end}
{p2col:}func2.mata{p_end}
{p2col:}remarks.txt{p_end}
{p2col:} {p_end}
{p2col:Project C}{p_end}
{p2col:}proj_c.adv{p_end}

{pstd}
The composition of the final ado files produced under ado mode is discussed in the next section.


{marker dependencies}{...} {* -------------------------------- REMARKS: CODE DEPENDENCIES ----------------------------- }
{title:Code dependencies}

{p2colset 5 10 12 0}{...}
{p2col:From the above example, note the following:}{p_end}
{p2col:}{p_end}
{p2col:}- The order of file types to be copied into the final ado file is: adv - ado - stp - mata - other.{p_end}
{p2col:}- Apart from the main adv, you do not have to stick to any particular order in which you specifiy project component files.
The only exception to this concerns {help copycode##matastructures:Mata structures}.
As you can see from func3.mata of project B above which is somewhat hidden, it makes things more transparent to keep the order adv-ado-stp-mata-other in the input file.{p_end}
{p2col:}- The main adv file of the project (the first project entry) will always be copied first.{p_end}
{p2col:}- All subroutines from adv dependencies are copied:
Files that are referenced by proj_b are copied into proj_a.ado since proj_a has proj_b.adv as dependency (sub3.stp and remarks.txt are used directly by proj_b only and not by proj_a).
proj_a.ado requires all of its calls to its private program proj_b to work; hence, all project component files for proj_b have to be present in proj_a.ado.{p_end}
{p2col:}- proj_c.adv is copied into the targetfile for proj_a because proj_a depends on proj_c.adv through proj_b.adv.
proj_c.adv is a second-order dependency of proj_a.{p_end}
{p2col:}- There is no duplicate copying of files: sub2.stp is copied only once into proj_a.ado, even though proj_a has proj_b.adv as dependency and both proj_a and proj_b require the usage of sub2.stp.{p_end}
{p2col:}- In proj_a, modular.ado is copied without any attempt to detect its dependencies, i.e. if you specify an ado file it is presumed to be modular.{p_end}
{p2col:}- If an adv file is specified as a project component file, a project with the same name must exist.
In the above example, when processing project A or project B, copycode sooner or later stumbles upon the reference proj_c.adv which it needs to resolve.
If it cannot determine whether proj_c.adv has dependencies (which is the case if project proj_c does not exist) it will error out.{p_end}

{pstd}
Circular references of adv files are not allowed: If proj_1.adv depends proj_2.adv, proj_2.adv must not depend on proj_1.adv.
If you try to process a project that has such a structure {cmd:copycode} will issue an error.
To detect circular references, a maximum of 1000 direct or indirect adv dependencies (in total) is set.
You will necessarily hit this limit if your input file defines a circular reference.
Note that a circular reference error will also be issued if these circular dependencies are not on the top level of dependencies.
For example, consider the input file

{p2colset 12 22 22 0}{...}
{p2col:proj_1}c:\ado\personal\proj_1.adv{p_end}
{p2col:proj_1}c:\ado\personal\proj_2.adv{p_end}
{p2col:proj_2}c:\ado\personal\proj_2.adv{p_end}
{p2col:proj_2}c:\ado\personal\proj_3.adv{p_end}
{p2col:proj_3}c:\ado\personal\proj_3.adv{p_end}
{p2col:proj_3}c:\ado\personal\proj_1.adv{p_end}

{pstd}
An error is issued because proj_1 depends on proj_2 which depends on proj_3 which in turn depends on proj_1, so the references have a circular structure.


{marker copyregions}{...} {* -------------------------------- REMARKS: COPY REGIONS ----------------------------- }
{title:Copy regions}

{pstd}
Before {cmd:copycode} starts copying the lines of a file, it searches the file for the strings '!copycodebeg=>' and '!copycodeend||'.
Then it only copies the lines in between the two strings (excluding the lines containing these strings) to {it:targetfile}.
Henceforth, the two strings are called "copy region limits" and the lines between the limits are called a "copy region".
A file may contain multiple copy regions.
Copy region limits must be present in each file, occur in the correct order, and reside on different lines.
Otherwise an error is issued.
You can prevent the error from being issued by using option {opt force}.
In this case the entire contents of the files are copied, except for starbang lines.
What happens to starbang lines is determined by option {opt starbang}.
The usage or omission of option {opt force} applies to all files in the project listing.

{pstd}
The purpose of copy regions is that you can keep comments and auxiliary commands/functions in the original files and still have a clean composite file.


{marker fileloss}{...} {* -------------------------------- REMARKS: AVOIDING FILE LOSS ----------------------------- }
{title:Avoiding file loss}

{pstd}
The output files that you want to create with {cmd:copycode} normally are ado files.
This means that the ado files that you are creating are fully overwritten whenever you make changes to component files and re-process a project.
Even if you proceed carefully, it may happen that you accidentially overwrite code that you have newly written.

{pstd}
In particular, this may happen if some of your ado files have a complex dependency structure so you create these ado files using {cmd:copycode}, but other ado files are very simple, do not have dependencies and are outside of the {cmd:copycode} system, i.e. written in the usual way.  Then you may get into the habit of sometimes modifying adv files (to modify ado files created by {cmd:copycode}), and sometimes ado files (to directly modify the small and simple ado files).  You can then easily by accident change the ado file of one of the complex ado projects.  The next time you re-process this project, this ado file will get overwritten and your work will be lost.

{pstd}
One save solution is to {bf:make it a rule to never ever edit ado files}.
Include all of your files in the {cmd:copycode} system, even the small and simple ones that do not have dependencies.
This means giving the simple ado files an adv extension, adding one project line per adv file to the {cmd:copycode} input file, and producing the ado file using {cmd:copycode}.
This may sound complicated but it is usually a change that can be implemented very quickly.
Once you have done so, you should have a look at {help fastcc} to make working with {cmd:copycode} more efficient.


{marker downsides}{...} {* -------------------------------- REMARKS: DOWNSIDES ----------------------------- }
{title:Downsides}

{pstd}
While {cmd:copycode} makes your life as a developer easier by reducing the amount of code that needs to be written and maintained, its major disadvantage is that it produces code bloat {hi:for the user} of your ado routines.
Including the code of general purpose functions or even full-blown ado routines in a new ado file means that larger parts of the code are probably not necessary to make the new ado work.
If a user of your ados wants to look at your code, it may take longer to read through it.

{pstd}
You may alleviate this problem by including a comment at the top of each adv file, e.g.

{pmore}
// Some portions of the code for subroutines may not be necessary for the{break}
// functionality of this ado file since it has been produced with -copycode-.{break}
// More information is available on SSC: type -ssc help copycode-{break}
// A separate help file for the program below may be available on SSC.

{pstd}
If the adv code is used as a subroutine, the user may be able to just read through the help file if it is available, instead of having to work through the code itself.

{pstd}
Another downside is the limited ability to format the target file.
Last but not least, it takes a little while to understand how the command works (as you may have noticed).


{marker nocopy}{...} {* -------------------------------- REMARKS: NOCOPY ----------------------------- }
{title:The 'nocopy' option}

{pstd}
If you do not want to use {cmd:copycode} to generate your self-written final ado files, you can still put it to use to shed light on the dependency structure of your code files.

{pstd}
You still have to create an input file like the one above that matches the direct dependencies of the projects that you have written.
The screen output of {cmd:copycode} and the results saved in {bf:r()} will then tell you the details about the full dependency structure of your projects.

{pstd}
Be sure to give your self-written ado file dependencies in your input file an adv extension.
These files may actually exist as ado files (not as adv files) on your hard drive.
You must still give them an adv extension in the input file, because only then will {cmd:copycode} check for their dependencies.

{pstd}
Use option 'nocopy' then.
Then you do not have to create a bogus target file.
Also, {cmd:copycode} concerns itself only with the dependency structure that it can glean from the input file and does not check for the existence of files and the consistency of copy region limits within the code files.


{marker misc}{...} {* -------------------------------- REMARKS: MISCELLANEOUS REMARKS ----------------------------- }
{title:Miscellaneous remarks}

{pstd}
{bf: Relationship of ado mode / simple mode, option {opt force}, and option {opt starbang}}.
Running {cmd:copycode} in ado mode / simple mode, using option {opt force} and using option {opt starbang} are in principle three different things independent of each other.{break}

{p2colset 5 10 12 0}{...}
{p2col:}- Choosing ado mode / simple mode determines whether higher-order dependencies of a project should be copied.{p_end}
{p2col:}- Option {opt force} says that copy operations should not be confined to copy regions.{break}{p_end}
{p2col:}- Option {opt starbang} determines whether starbang lines should be included in the copy operations.{p_end}

{pstd}
The only link between the above three features is that in ado mode {it:stb_mode} of option {opt starbang} defaults to "first".
In simple mode, it defaults to "all".

{pstd}
{bf:Potential function name clashes}.
There is a potential naming conflict between private subroutines that exist in adv/ado files referenced in the input file and other programs that you are refering to in the input file.
As an example, consider the input file

{p2colset 12 22 22 0}{...}
{p2col:------------------------------------------------}{p_end}
{p2col:proj_a}c:\ado\personal\proj_a.adv{p_end}
{p2col:proj_a}c:\ado\personal\modular.ado{p_end}
{p2col:proj_a}c:\ado\personal\sub1.stp{p_end}
{p2col:------------------------------------------------}{p_end}

{pstd}
If modular.ado has a private subroutine (program) called "sub1" the output file produced by {cmd:copycode} will have two programs named "sub1" and Stata will refuse to load the ado.
One way to remedy this is to adopt appropriate naming conventions, e.g. give subroutines within adv/ado files prefixes according to the adv/ado file name, etc.

{pstd}
It is perfectly fine to have subroutines in your main adv or any other adv/ado file.
If you have a special purpose program/function whose only application is within one particular adv/ado file, the only issue of adding this function to the adv/ado (project component) file is to pay attention to potential naming conflicts.
Make sure to keep these program/functions within copy regions so they will always be copied to the output file.

{pstd}
If you have a subroutine that turns out to be useful in other contexts as well it is beneficial to include this program in a separate adv or stp file, and add corresponding stp entries to projects that make use of the subroutine.

{pstd}
{bf:Debugging and certification scripts.}
Each of the files that go into the final ado can be loaded separately into Stata for debugging purposes.
If you have a look at func1.mata used in the {help copycode##examples:examples section}, you can see that the code file func1.mata is used in the copycode system but can be loaded separately into memory:

{pmore}
{cmd:. do func1.mata}

{pstd}
will define func1() as a Mata function.
This works because the actual code that gets copied by {cmd:copycode} is confined to copy region limits.

{pstd}
You can even push it further and use the file func1.mata as a certification script by adding initialization statements at the top of the file (see {help cscript}) and add certification {help assert} and {help confirm} statements at the bottom of the file.
You will still be able to use this file within the {cmd:copycode} context since, by default, {cmd:copycode} only copies the code that is located within copy region limits.
If all certification-related lines are located outside of copy regions, you can use func1.mata as both a source code file for the {cmd:copycode} system and as a certification script.
The same holds true for adv and for stp files.

{pstd}
{bf:Using code from other users.}
If your project depends on an ado file written by some other user, you can include this ado file in your {cmd:copycode} project as a dependency in order to make your project modular.
Your final ado file will then contain the code from the "third-party" user-written ado file.
It goes without saying that in these cases you should ask for permission first and give proper acknowledgements in your help files when you distribute your code.

{pstd}
{bf:Version statements.}
Another potential conflict concerns version statements.
If you plan to build a new ado, say under "version 11", and accidentially include a program via {cmd:copycode} that has a "version 12" statement, the ado file will not execute under Stata 11.
A cursory look at the (top of the) ado code, however, would (misleadingly) suggest that.
You must manually check for appropriate version control statements in your output ado files.

{pstd}
{bf:Exit statements.}
If you routinely include "exit" statements at the end of your main adv definition programs (after the closing "end" statement), make sure to exclude them from the copy region so they do not show up in the new composite ado file.
Otherwise it will not work.

{pstd}{marker matastructures}
{bf:Mata structures.}
In ado mode, within each file extension group, the order of files copied is the order of appearance in the input file.
This is important if you use Mata structures.
In the Mata code, structures have to be defined before they can be used in subsequent code.
If you use Mata structure definitions in separate files, it is the safest strategy to put these files right underneath the main adv file of your project.

{pstd}
{bf:Other uses.}
You may discover other uses of {cmd:copycode}, especially using option {opt simplemode}.
For example, you can use it to produce nice estimation output reports.
First, generate various smcl log files with estimation output and manually write other smcl files that comment on the output.
You can then use {cmd:copycode} to copy the smcl files into one file in any order desired, that way producing a nice and clean report.

{pstd}
{bf:Reverting to non-modular ado files.} All you have to do is to create a copy of your input file and comment out all adv files of a project except for the main adv.
Using the two input files you can very easily switch between creating modular ado files and non-modular ado files.

{pstd}
{bf:Using do-files.} If you have many ado files, you probably want to have a "master" do file that processes all of your projects.
For the input file used above, this do file could read

{p2colset 12 14 14 0}{...}
{p2col:copycode_runall.do: --------------------------------------------------------}{p_end}
{p2col:}// FILE PURPOSE: GENERATE ALL SELF-WRITTEN ADO FILES{p_end}
{p2col:}copycode proj_a, inp(c:\ipath\myinput.txt) target(c:\tpath\proj_a.ado) replace{p_end}
{p2col:}copycode proj_b, inp(c:\ipath\myinput.txt) target(c:\tpath\proj_b.ado) replace{p_end}
{p2col:}copycode proj_c, inp(c:\ipath\myinput.txt) target(c:\tpath\proj_c.ado) replace{p_end}
{p2col:----------------------------------------------------------------------------}{p_end}


{pstd}
{bf:Operating system}.
While {cmd:copycode} can be used on any operating system that Stata runs on, it has only been tested on Windows.


{marker examples}{...} {* ---------------------------------------------------- EXAMPLES ---------------------------------------------------------- }
{title:Examples}

{pstd}
Consider the following input file

{p2colset 12 22 22 0}{...}
{p2col:input.txt: -------------------------------------}{p_end}
{p2col://}Files for project A{p_end}
{p2col:proj_a}c:\ado\personal\proj_a.adv{p_end}
{p2col:proj_a}c:\ado\personal\sub1.stp{p_end}
{p2col:proj_a}c:\ado\personal\func1.mata{p_end}
{p2col://}Files for project B{p_end}
{p2col:proj_b}c:\ado\personal\proj_b.adv{p_end}
{p2col:proj_b}c:\ado\personal\proj_a.adv{p_end}
{p2col:proj_b}c:\ado\personal\sub1.stp{p_end}
{p2col:proj_b}c:\ado\personal\func2.mata{p_end}
{p2col:------------------------------------------------}{p_end}

{marker example_a}{...} {* ---------------------------------------------------- EXAMPLES PROJ_A ---------------------------------------------------------- }
{pstd}
The files that go into the final ado could look like this:

{p2colset 12 22 22 0}{...}
{p2col:proj_a.adv: ------------------------------------}{p_end}
{p2col:}// !copycodebeg=>{p_end}
{p2col:}*! version 1.0.1  12jun2011  dcs{p_end}
{p2col:}program define proj_a{p_end}
{p2col:} display "hello world says proj_a"{p_end}
{p2col:} proj_a_sub1{p_end}
{p2col:} sub1{p_end}
{p2col:} /* !copycodeend||{p_end}
{p2col:} TODO: improve sub1{p_end}
{p2col:} by switching to...{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:} !copycodebeg=> */{p_end}
{p2col:} mata: func1(){p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define proj_a_sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}// !copycodeend||{p_end}
{p2col:}{p_end}
{p2col:}/*{p_end}
{p2col:}TODO:{p_end}
{p2col:}- make the routine do something useful{p_end}
{p2col:}- {it:(...)}{p_end}
{p2col:}{p_end}
{p2col:}VERSION HISTORY{p_end}
{p2col:}0.0.1 12apr 2011 {it:(...)}{p_end}
{p2col:}*/{p_end}
{p2col:------------------------------------------------}{p_end}


{p2colset 12 22 22 0}{...}
{p2col:sub1.stp: ------------------------------------}{p_end}
{p2col:}capture program drop sub1{p_end}
{p2col:}// !copycodebeg=>{p_end}
{p2col:}program define sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}// !copycodeend||{p_end}
{p2col:}{p_end}
{p2col:}/*{p_end}
{p2col:}TODO{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}*/{p_end}
{p2col:------------------------------------------------}{p_end}


{p2colset 12 22 22 0}{...}
{p2col:func1.mata: ------------------------------------}{p_end}
{p2col:}capture mata mata drop func1(){p_end}
{p2col:}// !copycodebeg=>{p_end}
{p2col:}mata:{p_end}
{p2col:}void func1() {{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}// !copycodeend||{p_end}
{p2col:}{p_end}
{p2col:}/*{p_end}
{p2col:}TODO{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}*/{p_end}
{p2col:------------------------------------------------}{p_end}

{pstd}
The statement

{pmore}
{cmd:. copycode proj_a, inputfile(c:\mypath\input.txt) targetfile(c:\mytargetdir\proj_a.ado)}

{pstd}
would produce c:\mytargetdir\proj_a.ado which reads:

{p2colset 12 22 22 0}{...}
{p2col:proj_a.ado: ------------------------------------}{p_end}
{p2col:}*! version 1.0.1  12jun2011  dcs{p_end}
{p2col:}program define proj_a{p_end}
{p2col:} display "hello world says proj_a"{p_end}
{p2col:} proj_a_sub1{p_end}
{p2col:} sub1{p_end}
{p2col:} mata: func1(){p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define proj_a_sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}mata:{p_end}
{p2col:}void func1() {{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}}{p_end}
{p2col:}end{p_end}
{p2col:------------------------------------------------}{p_end}

{p2colset 5 10 12 0}{...}
{p2col:From the above example, note the following:}{p_end}
{p2col:}{p_end}
{p2col:}- {cmd:copycode} found the first file of proj_a to be an adv file whose name is identical to the project.
It therefore entered ado mode.
However, since there are no other adv files specified, there are no dependencies to detect.{p_end}
{p2col:}- By default, {cmd:copycode} copies only copy regions.
The private comments in the source code files do not show up in the output file.{p_end}
{p2col:}- In ado mode, the {opt starbang(stb_mode)} option defaults to "first", which means that the starbang lines from the main adv file are copied to the output file.{p_end}
{p2col:}- The main adv file contains a subroutine.
Prepending the name of the subroutine by the name of the adv file ("proj_a_sub1") prevented a function name clash.{p_end}

{marker example_b}{...} {* ---------------------------------------------------- EXAMPLES PROJ_B ---------------------------------------------------------- }
{pstd}
If, in addition, we assume the following files:

{p2colset 12 22 22 0}{...}
{p2col:proj_b.adv: ------------------------------------}{p_end}
{p2col:}// !copycodebeg=>{p_end}
{p2col:}*! version 1.2.0  30dec2011  dcs{p_end}
{p2col:}program define proj_b{p_end}
{p2col:} display "hello world again"{p_end}
{p2col:} proj_a{p_end}
{p2col:} sub1{p_end}
{p2col:} mata: func2(){p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}// !copycodeend||{p_end}
{p2col:}{p_end}
{p2col:}/*{p_end}
{p2col:}TODO:{p_end}
{p2col:}- {it:(...)}{p_end}
{p2col:}{p_end}
{p2col:}VERSION HISTORY{p_end}
{p2col:}- {it:(...)}{p_end}
{p2col:}*/{p_end}
{p2col:------------------------------------------------}{p_end}


{p2colset 12 22 22 0}{...}
{p2col:func2.mata: ------------------------------------}{p_end}
{p2col:}capture mata mata drop func2(){p_end}
{p2col:}// !copycodebeg=>{p_end}
{p2col:}mata:{p_end}
{p2col:}void func2() {{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}// !copycodeend||{p_end}
{p2col:}{p_end}
{p2col:}/*{p_end}
{p2col:}TODO{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}*/{p_end}
{p2col:------------------------------------------------}{p_end}


{pstd}
The statement

{pmore}
{cmd:. copycode proj_b, inputfile(c:\mypath\input.txt) targetfile(c:\mytargetdir\proj_b.ado)}

{pstd}
would produce c:\mytargetdir\proj_b.ado which reads:

{p2colset 12 22 22 0}{...}
{p2col:proj_b.ado: ------------------------------------}{p_end}
{p2col:}*! version 1.2.0  30dec2011  dcs{p_end}
{p2col:}program define proj_b{p_end}
{p2col:} display "hello world again"{p_end}
{p2col:} proj_a{p_end}
{p2col:} sub1{p_end}
{p2col:} mata: func2(){p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define proj_a{p_end}
{p2col:} display "hello world says proj_a"{p_end}
{p2col:} proj_a_sub1{p_end}
{p2col:} sub1{p_end}
{p2col:} mata: func1(){p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define proj_a_sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}program define sub1{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}mata:{p_end}
{p2col:}void func2() {{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}}{p_end}
{p2col:}end{p_end}
{p2col:}{p_end}
{p2col:}mata:{p_end}
{p2col:}void func1() {{p_end}
{p2col:} {it:(...)}{p_end}
{p2col:}}{p_end}
{p2col:}end{p_end}
{p2col:------------------------------------------------}{p_end}

{p2colset 5 10 12 0}{...}
{p2col:From the above example, note the following:}{p_end}
{p2col:}{p_end}
{p2col:}- {cmd:copycode} found the first file of proj_b to be an adv file whose name is identical to the project.
It therefore entered ado mode.
It found proj_a as an adv input to proj_b and checked for a proj_a project entry in the input file.
It included the files found there in the output file.{p_end}
{p2col:}- If proj_a would have had a component file proj_c.adv, {cmd:copycode} would have included the component files from proj_c as well, and so forth.{p_end}
{p2col:}- Again, in ado mode, option {opt starbang(stb_mode)} option defaults to "first", which means that the starbang lines from the main adv file are copied to the output file.
The starbang lines from proj_a have not been copied.{p_end}


{marker savedresults}{...} {* ---------------------------------------------------- SAVED RESULTS ---------------------------------------------------------- }
{title:Saved results}

{pstd}
{cmd:copycode} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 0: Macros}{p_end}
{synopt:{cmd:r(project)}}Name of project that has been processed{p_end}
{synopt:}{p_end}
{synopt:}in simple mode, the following is also saved:{p_end}
{synopt:{cmd:r(dep_direct)}}File names of direct dependencies of the project{p_end}
{synopt:{cmd:r(dep_direct_path)}}Full file paths of the direct dependencies{p_end}
{synopt:}{p_end}
{synopt:}in ado mode, the following is also saved:{p_end}
{synopt:{cmd:r(dep_all)}}File names of all dependencies of the project{p_end}
{synopt:{cmd:r(dep_adv)}}File names of adv dependencies{p_end}
{synopt:{cmd:r(dep_ado)}}File names of ado dependencies{p_end}
{synopt:{cmd:r(dep_stp)}}File names of stp dependencies{p_end}
{synopt:{cmd:r(dep_mata)}}File names of mata dependencies{p_end}
{synopt:{cmd:r(dep_other)}}File names of other dependencies{p_end}
{synopt:{cmd:r(dep_all_path)}}Full file paths corresponding to r(dep_all){p_end}
{synopt:{cmd:r(dep_adv_path)}}Full file paths corresponding to r(dep_adv){p_end}
{synopt:{cmd:r(dep_ado_path)}}Full file paths corresponding to r(dep_ado){p_end}
{synopt:{cmd:r(dep_stp_path)}}Full file paths corresponding to r(dep_stp){p_end}
{synopt:{cmd:r(dep_mata_path)}}Full file paths corresponding to r(dep_mata){p_end}
{synopt:{cmd:r(dep_other_path)}}Full file paths corresponding to r(dep_other){p_end}
{p2colreset}{...}

{pstd}
All returned values are lower case, irrespective of what the actual casing of the files on disk or in the input file is.

{title:Author}

{phang}
Daniel C. Schneider, Goethe University Frankfurt, schneider_daniel@hotmail.com


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
I thank Kevin Crow from StataCorp and the participants of the German Stata Users Group Meeting 2012 for helpful comments.


{marker references}{...}
{title:References}

{phang}
Schneider, D.C. (2012).
Modular Programming in Stata.
Presentation at the German Stata Users Group Meeting 2012, Berlin.
Available at {browse "http://www.stata.com/meeting/germany12/abstracts/desug12_schneider.pdf":http://www.stata.com/meeting/germany12/abstracts/desug12_schneider.pdf}.


{marker alsosee}{...}
{title:Also see}

{psee}
Online:
{manhelp net R}
{p_end}

{psee}
User-written, if installed:

{col 5}{bf:adolist}{col 20}{stata help adolist:-help-}{col 27}{stata ssc install adolist:-install-}{col 37}{stata "view net describe adolist, from(http://fmwww.bc.edu/repec/bocode/a)":-remote help-}
