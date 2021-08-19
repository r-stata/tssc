{smcl}
{* *! version 1.0.1 06jul2021}{...}
{viewerjumpto "Title" "docd##title"}{...}
{viewerjumpto "Syntax" "docd##syntax"}{...}
{viewerjumpto "Description" "docd##description"}{...}
{viewerjumpto "Examples" "docd##examples"}{...}
{viewerjumpto "Author" "docd##author"}{...}
{viewerjumpto "Raison d'être" "docd##raisondêtre"}{...}
{marker title}{...}
{title:Title}

{pstd}
docd / runcd {hline 2} Change the working directory before executing a do-file


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:docd} 
{it:path_to_dofile}
[{it:arguments}]

{phang2}
{cmd:runcd} 
{it:path_to_dofile}
[{it:arguments}]


{marker description}{...}
{title:Description}

{pstd}
{cmd:docd} and {cmd:runcd} are similar and do four things. They will remember
the current directory, change the working directory to the path of the do-file,
do respectively run the do-file and then change the working directory back again. The
programs can be used in do-files that are themselves executed by {cmd:docd} or {cmd:runcd}.

{pstd}
This means that the do-file can be ran by a runner calling the do-file using {cmd:docd}
or {cmd:runcd} without the need to specify hardwired paths (relative to the directory of the
runner) in the target do-file. It can find the associated data and other do-files in the
subdir because it is executed in its own subdir. And hence the do-file can also be ran
independently (when stata is started with the directory of the do file as working
directory). This reduces the need for specifying hardwired paths in do-files in subdirs
to a bare minimum, making project management easier.

{pstd}
The commands pass at most 10 arguments to the do-file that is being executed.


{marker examples}{...}
{title:Examples}

	{cmd:. docd "sub\dir\example.do"}
	{cmd:. runcd "..\dir\example.do"}


{marker author}{...}
{title:Author} 

{pstd}
Hendri Adriaens, Centerdata, The Netherlands.{break}
hendri.adriaens@centerdata.nl


{marker raisondêtre}{...}
{title:Raison d'être}

{pstd}
{cmd:docd} and {cmd:runcd} are created to help in project management. The situation: you
have several do-files, neatly organized in (sub)directories. You want to
be able to execute these do-files standalone, for instance for the purpose of
debugging a part of your process, or rebuilding only a few data files. But
you also want to be able to execute them all at once from a main runner do-file
in the main project directory. Of course, you have the data for each do-file
in the associated subdir and you want the do-file in the subdir to be able
to find that data.

{pstd}
The usual suggestion to approach this case is to create a do-file containing
a lot of macro definitions with all the relevant paths in your project. For this
to work, you always need to start Stata in the main project file to which all
the path definitions are relative. (Of course you never use absolute paths.)
This takes some additional maintenance when you change the structure of your
project. And what if you decide to rename a directory? Do you keep the name of
the local the same and hence the local name does not match the directory anymore,
which is very confusion when using the local. Or do you also rename the local,
needing you to check each of your project files by hand to change the use of the local?

{pstd}
Why not using Statas project management? Because starting the project file
will start Stata in the directory of the project file, while most of your do-files
are in subdirs of that directory. Being able to load data in a do-file in a subdir therefore requires
specifying all paths relative to your project dir. This will mean that you will need
to hardwire a lot of directory names in your do-files, basically meaning that you will
be using absolute paths. Maybe not absolute to your drive letter, but absolute to your project
directory. All these paths in your do-files are a no-go because changing anything in the
structure of your project will mean that you have to go through all your do-files
and check each of them very carefully.

{pstd}
It would help a lot if do-files in subdirs could change the current
directory to where the do-file is located. This is not possible in Stata. Nor do the
{cmd:do} or {cmd:run} commands offer the option to change the working directory before
executing the do-file. That's why {cmd:docd} and {cmd:runcd} were created.
