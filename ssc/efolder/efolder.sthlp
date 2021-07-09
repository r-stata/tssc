{smcl}
{* *! version 1.0  8 Aug 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "efolder##syntax"}{...}
{viewerjumpto "Description" "efolder##description"}{...}
{viewerjumpto "Options" "efolder##options"}{...}
{viewerjumpto "Remarks" "efolder##remarks"}{...}
{viewerjumpto "Examples" "efolder##examples"}{...}
{title:Title}
{phang}
{bf:efolder} {hline 2}  stata module to esaily create folders and/or subfolders

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab: ef:older}
[foldername]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt foldername}} The name of folder you want to create.

{synopt:{opt (note)}} Only one folder allowed, but you can use the option {cmd:sub()} to creat more folder at one time.

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:efolder} provides an easy way to creat folders and/or subfolders in any geiven directory path(with the current working directory as default).
For example, we can have a folder named {cmd:mainf} created with four subfolder, named by {cmd:a b c d} respectively, in path {cmd:"D:\stata15\temp\zero"}, eventhough the folder {cmd:zero} dose not exist, just using the command 
 {cmd: efolder mainf, cd(D:\stata15\temp\zero) sub(a b c d)} .
You can have a folder created freely and easily any where. And you can quickly open the mainfolder,by clik the link generated automatically, you have just created.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt c:d(string)} The directory you want  folders been created in,it dose not necessarily exist.

{p 4 8}{opt s:ub} When this option is selected without {cmd:subname()},three folder, named by {cmd:f1 f2} and {cmd: f3} will be created under your main folder or default path.

{p 4 8}{opt sub:name(string)} Namelist of subfolders you want to created, separated by blanks,so names for subfolder should not contain blanks.

{p 4 8}{opt noc:hange} If you do not have the current working directory changed, this option is needed.

{marker examples}{...}
{title:Examples}

{phang} 
efolder

{p 4 8}efolder, cd(D:\stata15\hxs\temp2)

{p 4 8}{cmd:*Folder name with blanks can be created use cd option.}

{p 4 8}efolder, cd(D:\stata15\hxs\tem p2)

{p 4 8}efolder, cd(D:\stata15\hxs\tem p2) s

{p 4 8}{cmd:*Using subname() option to creat subfolders.}

{p 4 8}efolder, cd(D:\stata15\hxs\tem p3) sub(2 5)

{p 4 8}efolder tt2, sub(6 5)

{p 4 8}efolder tt6, cd(D:\stata15\hxs\temp folder28) sub(n h j)

{p 4 8}{cmd:*Folder name with blanks can be also created use [foldername] option.}

{p 4 8}efolder t t6, cd(D:\stata15\hxs\temp folder29)

{p 4 8}{cmd:*A abbreviation way}

{p 4 8}ef temp, cd(D:\stata15\hxs\temp folder29)

{title:Author}
{p}

{p 4 12}X.S. Hou (Hou Xinshuo),Xiangtan University,P.R. China .
         
{p 4 12}Email {browse "mailto:houxinshuo@126.com":houxinshuo@126.com}

{title: Install}

 {p 4 12} {stata ssc install efolder} (to install this command)

 {p 4 12} net install efolder, from("https://github.com/houxinshuo/efolder/releases/download/efolder_v1.0")

 {p 4 12} {cmd: If failing to install, you can download the ado package first, and net install it(with the path of your downloaded folder replacing ~).}
 
 {p 4 16}  https://github.com/houxinshuo/efolder/archive/efolder_v1.0.zip
   
 {p 4 16}  net install efolder, from("~\efolder-efolder_v1.0")


{title:See Also}

{p 4 12}NOTE: efolder also changed the working directory to the path of mainfolder(defined by {cmd:foldername}) automatically.

{p 4 12}Related commands:

    {help cd} (if installed)
  
    {help cdout} (if installed)
	

	

	
{p}
	