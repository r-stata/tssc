{smcl}
{* *! version 1.1.0}{...}
{vieweralsosee "boilerplate" "help boilerplate"}{...}
{viewerjumpto "Syntax" "mkproject##syntax"}{...}
{viewerjumpto "Description" "mkproject##description"}{...}
{viewerjumpto "Options" "mkproject##option"}{...}
{viewerjumpto "Example" "mkproject##example"}{...}
{title:Title}

{phang}
{bf:mkproject} {hline 2} Creates project folder with some boilerplate code and research log


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mkproject}
{it:proj_abbrev} ,
{cmd:[}
{opt dir:ectory(dir)}
{cmd:]}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mkproject} creates a project directory (folder) called {it:proj_abbrev}
inside the directory {it:dir}. If {cmd:directory()} has not been specified, the
project directory will be created in the {help pwd:current working directory}.
The project directory will have the following structure:

{p 4 4 2}{it:proj_abbrev}{p_end}
{p 8 8 2}admin{p_end}
{p 8 8 2}docu{p_end}
{p 8 8 2}posted{p_end}
{p 12 12 2}data{p_end}
{p 8 8 2}work{p_end}

{pstd}
Moreover, the work folder will contain 3 .do files {it:proj_abbrev}_main.do,
{it:proj_abbrev}_dta01.do and {it:proj_abbrev}_ana01.do. These 
.do files will contain boilerplate code. The docu folder will contain the file
research_log.txt, with some boilerplate for the start for a research log. The 
main {it:proj_abbrev} folder will contain a {it:proj_abbrev}.stpr
Stata {help Project Manager:Stata project file}.

{pstd}
Once {cmd:mkproject} has done that, it will change the working directory to the
directory work, and opens the Stata project file. 

{pstd}
Additional .do files with boilerplate code can be created with {help boilerplate}.

{pstd}
This command was inspired by the book by {help mkproject##ref:Scott Long (2009)}. 


{marker option}{...}
{title:Option}

{phang}
{opt dir:ectory(dir)} specifies the directory in which the project is to be created.


{marker example}{...}
{title:Example}

{phang}{cmd:. mkproject foo, dir(c:/temp)}{p_end}


{marker ref}{...}
{title:Reference}

{phang}
J. Scott Long (2009) {it:The Workflow of Data Analysis Using Stata}. College Station, TX: Stata Press.


{title:Author}

{pstd}Maarten Buis, University of Konstanz{break} 
      maarten.buis@uni.kn   

