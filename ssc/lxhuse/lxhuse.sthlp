{smcl}
{* *! version 1.02 19may2021}{...}
{cmd:help lxhuse}
{hline}

{pstd}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: lxhuse} {hline 2}}Access Stata datasets of {browse "https://www.lianxh.cn":lianxh.cn} blogs, 
see {stata "help lianxh":help lianxh}.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:lxhuse}
[
{it:filename}  
{cmd:,}
{cmdab:nod:esc}
{cmd:clear}
{cmdab:s:ave}
{cmd:replace}
{cmdab:u:rl(string)} 
]

{p 2 8 2}

{synoptset 10}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:nodesc}}
the dataset should not be described after loading.
By default, the {cmd:describe} command is automatically issued after the dataset is
loaded.
{p_end}
{synopt:{cmdab:clear}}
clear Stata's memory before loading the new dataset.
{p_end}
{synopt:{cmdab:save}}
save the dataset in your current working directory (use {stata "pwd":pwd} to check it).
{p_end}
{synopt:{cmdab:replace}}
overwrite the datasets with same filename as the dataset loaded. 
{p_end}
{synopt:{cmdab:url()}}
specifies that the dataset will be download from {opt url} you provied. 
{p_end}
{synoptline}
{pstd}Notes:{p_end}
{pstd}(1) {cmd:lxhuse} with no argument is used to list the datasets available.
{p_end}
{pstd}(2) {opt url()} provide an easy way to download dataset from various sources. 
For example, the following commands are equivalent:{p_end}
{phang}{stata "lxhuse jtrain, url(http://fmwww.bc.edu/ec-p/data/wooldridge)" : . lxhuse jtrain, url(http://fmwww.bc.edu/ec-p/data/wooldridge)}{p_end}
{phang}{stata " bcuse jtrain" : . bcuse jtrain}{p_end}


{marker description}{...}
{title:Description}

{pstd}{cmd:lxhuse} provides easy access to a number of Stata-format datasets used
in blogs of {browse "https://www.lianxh.cn":lianxh.cn}. 
Those blogs can be easily searched with {stata "help lianxh":lianxh} command in Stata Command Window.

{pstd}To use the {bf:auto_test.dta} dataset, give the command {bf:lxhuse auto_test}. 
If you receive an error message, check the {browse "https://gitee.com/lianxh/data/tree/master/data01":web page} listing
these datasets.

{pstd}If a Stata data file has been saved in .zip format on the server (usually because 
it is very large), you may give the {it:filename}, including .zip, and the zip file
will be copied to your working directory, unzipped, and read into Stata.

{pstd}If the dataset is declared as a timeseries or panel, the {cmd:tsset} command will be 
issued to display those characteristics.

{pstd}The {bf:anciliary files} can be downloaded using {stata "help lxh":lxh get} command.


{title:Examples} 

{phang}{stata "lxhuse" : . lxhuse} {space 6} // list datasets{p_end}
{phang}{stata "lxhuse auto_test" : . lxhuse auto_test}{p_end}
{phang}{stata "lxhuse auto_test, clear" : . lxhuse auto_test, clear}{p_end}
{phang}{stata "lxhuse auto_test, nodesc" : . lxhuse auto_test, nodesc}{p_end}
{phang}{stata "lxhuse auto_test.zip, clear" : . lxhuse auto_test.zip, clear}{p_end}


{title:Acknowledgements}

{p 4 8 2}
Codes from {help bcuse} by Prof. C.F. Baum have been incorporated.


{title:Author}

{phang}
{cmd:Yujun, Lian} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}


{title:Other Commands}

{pstd}

{synoptset 30 }{...}
{synopt:{help lianxh} (if installed)} {stata ssc install lianxh} (to install){p_end}
{synopt:{help bdiff} (if installed)} {stata ssc install bdiff} (to install){p_end}
{synopt:{help hhi5} (if installed)} {stata ssc install hhi5} (to install){p_end}
{synopt:{help songbl} (if installed)} {stata ssc install songbl} (to install){p_end}
{synopt:{help xtbalance} (if installed)} {stata ssc install xtbalance} (to install){p_end}
{synopt:{help imusic} (if installed)} {stata ssc install imusic} (to install){p_end}
{p2colreset}{...}


{title:Also see}

{psee} 
Online:  
{help use}, 
{help webuse},
{help net get}, 
{help bcuse} (if installed),
{help lxh} (if installed).

