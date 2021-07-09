{smcl}
{* *! usewsz.sthlp, Chris Charlton and George Leckie}{...}
{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{cmd:usewsz} {hline 2}}Load MLwiN worksheet as Stata dataset{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Load MLwiN worksheet into memory

{p 8 12 2}
{opt u:se}
{it:{help filename}}
[{cmd:,}
{it:{help usewsz##usewsz_options:usewsz_options}}]

{phang}
Load subset of Stata-format dataset

{p 8 12 2}
{opt u:se}
[{varlist}]
{ifin}
{cmd:using}
{it:{help filename}}
[{cmd:,}
{it:{help usewsz##usewsz_options:usewsz_options}}]

{synoptset 17}{...}
{marker usewsz_options}{...}
{synopthdr :usewsz_options}
{synoptline}
{synopt :{opt batch}}prevents any MLwiN GUI windows being displayed{p_end}
{synopt :{opt nol:abel}}omit value labels from the loaded worksheet{p_end}
{synopt :{opt mlwinpath:(string)}}mlwin.exe file address, including the file name{p_end}
{synopt :{opt clear}}clear the data currently in memory{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{opt usewsz} loads the worksheet named {it:{help filename}} into memory.  If your
{it:filename} contains embedded spaces, remember to enclose it in double
quotes.


{marker options_usewsz}{...}
{title:Options for usewsz}

{phang}
{opt batch} prevents any MLwiN GUI windows being displayed.

{phang}
{opt nolabel} omits value labels from the saved worksheet.

{phang}{opt mlwinpath(string)} specifies the file address for mlwin.exe, including the file name.
For example: {bf:mlwinpath(C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe)}.

{phang}
{opt clear} permits {opt usewsz} to overwrite data in memory.


{marker remarks}{...}
{title:Remarks}

{pstd}
In order to get {cmd:usewsz} working, the user must then: 

{p 8 12 2}
(1) install the latest version of MLwiN on their computer;

{p 8 12 2}
(2) set the MLwiN path using {opt mlwinpath(string)} or a {cmd:global} macro called MLwiN_path.

{pstd}
If you don't have the latest version of MLwiN, visit:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/software/mlwin":http://www.bristol.ac.uk/cmm/software/mlwin}. 

{pstd}
MLwiN is free for UK academics (thanks to support from the UK Economic and Social Research Council).
A fully unrestricted 30-day trial version is available for non-UK academics.

{pstd}
Advanced users may wish to set the MLwiN path every time Stata is started by simply inserting the following line into the profile do-file profile.do.
See {bf:{help profile}}.

{p 8 12 2}
{cmd:. global MLwiN_path "C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe"}

{pstd}
Where you must substitute the MLwiN path that is correct for your computer for the path given in quotes in the above example. 


{marker examples}{...}
{title:Examples}

{pstd}Load MLwiN worksheet into memory{p_end}
{phang2}{bf:{stata "usewsz c:\Program Files (x86)\MLwiN v2.26\samples\tutorial.ws, clear":. usewsz c:\Program Files (x86)\MLwiN v2.26\samples\tutorial.ws, clear}}{p_end}


{marker about_cmm}{...}
{title:About the Centre for Multilevel Modelling}

{pstd}
The MLwiN software is developed at the Centre for Multilevel Modelling.
The Centre was established in 1986, and has been supported largely by project grants from the UK Economic and Social Research Council.
The Centre has been based at the University of Bristol since 2005.

{pstd}
The Centre’s website:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm":http://www.bristol.ac.uk/cmm}

{pstd}
contains much of interest, including new developments, and details of courses and workshops.
This website also contains the latest information about the MLwiN software, including upgrade information,
maintenance downloads, and documentation.

{pstd}
The Centre also runs a free online multilevel modelling course:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/learning/course.html":http://www.bristol.ac.uk/cmm/learning/course.html}

{pstd}
which contains modules starting from an introduction to quantitative research progressing to multilevel modelling of 
continuous and categorical data.
Modules include a description of concepts and models and instructions of how to carry out analyses in MLwiN, Stata and R.
There is a also a user forum, videos and interactive quiz questions for learners’ self-assessment.


{marker citation}{...}
{title:How to cite {cmd:runmlwin} and MLwiN}

{pstd}{cmd:runmlwin} is not an official Stata command.
It is a free contribution to the research community, like a paper.
Please cite it as such:

{p 8 12 2}
Leckie, G. and Charlton, C. 2013. {cmd:runmlwin} - A Program to Run the MLwiN Multilevel Modelling Software from within Stata. Journal of Statistical Software, 52 (11),1-40.
{browse "http://www.jstatsoft.org/v52/i11":http://www.jstatsoft.org/v52/i11}

{pstd}Similarly, please also cite the MLwiN software:

{p 8 12 2}
Rasbash, J., Charlton, C., Browne, W.J., Healy, M. and Cameron, B. 2009. MLwiN Version 2.1. Centre for Multilevel Modelling, 
University of Bristol.

{pstd}For models fitted using MCMC estimation, we ask that you additionally cite:

{p 8 12 2}
Browne, W.J. 2012. MCMC Estimation in MLwiN, v2.26. Centre for Multilevel Modelling, University of Bristol.


{marker user_forum}{...}
{title:The {cmd:runmlwin} user forum}

{pstd}Please use the {cmd:runmlwin} user forum to post any questions you have about {cmd:runmlwin}.
We will try to answer your questions as quickly as possible, but where you know the answer to another user's question please also reply to them!

{p 8 12 2}{browse "http://www.cmm.bristol.ac.uk/forum/viewforum.php?f=3":http://www.cmm.bristol.ac.uk/forum/}


{marker authors}{...}
{title:Authors}

{p 4}Chris Charlton{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}
{p 4}{browse "mailto:c.charlton@bristol.ac.uk":c.charlton@bristol.ac.uk}{p_end}

{p 4}George Leckie{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}


{title:Also see}

{psee}
Online:  {bf:{help runmlwin}}, {bf:{help mcmcsum}}, {bf:{help savewsz}}
{p_end}
