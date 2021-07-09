{smcl}
{* *! version 1.0.0 15may2013}{...}
{cmd:help cmaxuse}
{hline}

{title:Title}
{phang}
{bf: cmaxuse -- Access Cmax Stata datasets}

{title:Syntax}
{p 8 17 2}
{cmd:cmaxuse}
{it:filename} 
[ 
{cmd:,}
{cmd:nodesc} 
{cmd:clear}
]

{title:Description}

{pstd}{cmd:cmaxuse} provides easy access to a number of Stata-format datasets used
in Prof. Chris Maxwell's courses.
If you are told to use the {bf:NFLtix.txt} dataset, give the command {bf:cmaxuse NFLtix.txt}. 
If you receive an error message, check the web page listing
these datasets on the CMax web site, 
{browse " http://www.cmaxxsports.com/data/datasets.html"}

{pstd}If a Stata data file has been saved in .zip format on the server (usually because 
it is very large), you may give the {it:filename}, including .zip, and the zip file
will be copied to your working directory, unzipped, and read into Stata.

{title:Options}

{phang}{opt nodesc} specifies that the dataset should not be described after loading.
By default, the {cmd:describe} command is automatically issued after the dataset is
loaded.

{phang}{opt clear} specifies that you want to clear Stata's memory before loading 
the new dataset.

{title:Examples} 

{phang}{stata "cmaxuse NFLtix.txt" : . cmaxuse NFLtix.txt }{p_end}
{phang}{stata "cmaxuse NFLtix.txt, clear" : . cmaxuse NFLtix.txt, clear}{p_end}
{phang}{stata "cmaxuse NFLtix.txt, nodesc" : . cmaxuse NFLtix.txt, nodesc}{p_end}
{phang}{stata "cmaxuse NFLtix.dta.zip, clear" : . cmaxuse NFLtix.dta.zip, clear}{p_end}

{title:Author}
{phang}Christopher F Baum, Boston College{break} 
 baum@bc.edu{p_end}

{title:Also see} 

{psee} 
On-line: help for {help use}, {help sysuse}, {help webuse}
