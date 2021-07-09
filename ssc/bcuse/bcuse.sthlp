{smcl}
{* *! version 1.0.0 13mar2012}{...}
{cmd:help bcuse}
{hline}

{title:Title}
{phang}
{bf: bcuse -- Access BC Economics Stata datasets}

{title:Syntax}
{p 8 17 2}
{cmd:bcuse}
{it:filename} 
[ 
{cmd:,}
{cmd:nodesc} 
{cmd:clear}
]

{title:Description}

{pstd}{cmd:bcuse} provides easy access to a number of Stata-format datasets used
in BC Economics labs for Statistics (ECON1151) and Econometric Methods (ECON2228).
If you are told to use the {bf:crime1} dataset, give the command {bf:bcuse crime1}. 
If you receive an error message, check the web page listing
these datasets on the BC Economics web site, 
{browse "http://fmwww.bc.edu/ec-p/data/wooldridge/datasets.list.html"}

{pstd}If a Stata data file has been saved in .zip format on the server (usually because 
it is very large), you may give the {it:filename}, including .zip, and the zip file
will be copied to your working directory, unzipped, and read into Stata.

{pstd}If the dataset is declared as a timeseries or panel, the {cmd:tsset} command will be 
issued to display those characteristics.

{title:Options}

{phang}{opt nodesc} specifies that the dataset should not be described after loading.
By default, the {cmd:describe} command is automatically issued after the dataset is
loaded.

{phang}{opt clear} specifies that you want to clear Stata's memory before loading 
the new dataset.

{title:Examples} 

{phang}{stata "bcuse crime1" : . bcuse crime1}{p_end}
{phang}{stata "bcuse crime1, clear" : . bcuse crime1, clear}{p_end}
{phang}{stata "bcuse crime1, nodesc" : . bcuse crime1, nodesc}{p_end}
{phang}{stata "bcuse auto.zip, clear" : . bcuse auto.zip, clear}{p_end}

{title:Author}
{phang}Christopher F Baum, Boston College{break} 
 baum@bc.edu{p_end}

{title:Also see} 

{psee} 
On-line: help for {help use}, {help sysuse}, {help webuse}
