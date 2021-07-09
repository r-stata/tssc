{smcl}
{* *! version 1.0.0  26Sept2018}{...}
{vieweralsosee "[D] codebook" "help codebook"}{...}
{vieweralsosee "cb2html" "help cb2html"}{...}
{viewerjumpto "Syntax" "htmlcb##syntax"}{...}
{viewerjumpto "Description" "htmlcb##description"}{...}
{viewerjumpto "Options" "htmlcb##options"}{...}
{viewerjumpto "Remarks" "htmlcb##remarks"}{...}
{viewerjumpto "Examples" "htmlcb##examples"}{...}
{title:Title}

{phang}
{bf:htmlcb} {hline 2} Write a codebook as an html file


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:htmlcb}
{cmd:,} {opt saving(filename)} [{it:options}]


{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth saving(filename)}}filename for the codebook{p_end}
{synopt:{opt replace}}overwrite file specified in {opt saving()} if it already 
exists{p_end}
{synopt:{opt f:iles}{cmd:(}[{cmd:"}]{it:{help filename}}[{cmd:"}] [[{cmd:"}]{it:{help filename}}[{cmd:"}]] [...]{cmd:)}}
Stata data files for which the codebook is to be created{p_end}
{synopt:{opt dir}{cmd:(}[{cmd:"}]{it:directory_name}[{cmd:"}]{cmd:)}}the codebook is made for all Stata data files in {it:directory_name}{p_end}
{synopt:{opt title(string)}}title for the codebook; default is Codebook{p_end}
{synopt:{opt self:contained}}codebook is viewable on devise without internet access{p_end}
{synopt:{opt fast}}creating the codebook is faster, but the codebook will contain less information{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:htmlcb} creates an codebook in an html file from one or more Stata datasets. 
By default it will make a codebook for the dataset that is currently in memory, 
unless either the {cmd:files()} or {cmd:dir()} option is specified.

{pstd}
{cmd:htmlcb} displays for each dataset the data label, notes, number of variables,
number of observations, when it was last saved, and the {help datasignature}. For 
each variable it always displays the variable label, notes, the number of missing 
and non-missing values. 

{pstd}
If the {cmd:fast} option is not specified it will also display the number of 
distinct non-missing values. In that case {cmd:htmlcb} will also show for each 
variable a frequency table if that variable has value labels or the number of 
distinct values is less than or equal to 10. If the number of distinct values is 
larger than 10 and it has no value labels, then it will show the minimum, the 
three quartiles, and the maximum.

{pstd}
If the {cmd:fast} option is specified {cmd:htmlcb} will show the minimum, mean,
and maximum for all variables.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth saving(filename)} the filename under which the codebook is to be stored.

{phang}
{opt replace} overwrite file specified in {opt saving()} if it already exists.

{phang}
{opt f:iles}{cmd:(}[{cmd:"}]{it:{help filename}}[{cmd:"}] [[{cmd:"}]{it:{help filename}}[{cmd:"}]] [...]{cmd:)}
specifies the Stata data files that the codebook will describe. Specifiying 
multiple files is particularly useful for a dataset that is stored in multiple
files, so you want to describe all files in one codebook.

{phang}
{opt dir}{cmd:(}[{cmd:"}]{it:directory_name}[{cmd:"}]{cmd:)} the codebook will 
describe all Stata datasets in the directory {it:directory_name}. If you want
to specify the current working directory you can use {cmd:dir(.)}.

{phang}
{opt title(string)} title for the codebook; default is Codebook

{phang}
{opt self:contained} codebook is viewable on devise without internet 
access. The codebook uses the W3.CSS framework, and by default a link to the
w3.css file. If one intends to use the codebook on a divise without internet
access, then the codebook will not look as intended. For those instances one
can specify the {opt selfcontained} option which will copy the entire w3.css
file in the {cmd:<style>} block.

{phang}
{opt fast} creating the codebook is faster, but the codebook will contain less 
information. Especially in large dataset, {cmd:htmlcb} can take a while. The 
{cmd:fast} option can speed that up, but at the cost of a less informative 
codebook. The differences are discussed in the Description. 



{marker examples}{...}
{title:Examples}

{pstd}
Use the data file currently in memory

{phang2}{cmd:. sysuse auto}{p_end}

{phang2}{cmd:. htmlcb, saving(autocb.html) }{p_end}

{pstd}
Copy some datasets in the current working directory 

{phang2}{cmd:. sysuse auto}{p_end}

{phang2}{cmd:. save auto_copy}{p_end}

{phang2}{cmd:. sysuse nlsw88}{p_end}

{phang2}{cmd:. save nlsw88_copy}{p_end}

{pstd}
Use the {cmd:files()} option to indicate which datasets will be described.

{phang2}{cmd:. htmlcb , files(auto_copy nlsw88_copy) saving(files.html)}{p_end}

{pstd}
Use the {cmd:dir()} option to describe all Stata datasets in the current working
directory.

{phang2}{cmd:. htmlcb , dir(.) saving(dir.html)}{p_end}




{title:Author}

{pstd}Maarten Buis, University of Konstanz{break} 
      maarten.buis@uni.kn         
          
    
