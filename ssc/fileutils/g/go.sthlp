{smcl}
{* *! version August 26, 2018 @ 19:41:45}{...}
{vieweralsosee "" "--"}{...}
{* link to other help files which could be of use}{...}
{vieweralsosee "[D] cd" "help cd"}{...}
{vieweralsosee "[user] pushd" "help pushd"}{...}
{viewerjumpto "Syntax" "go##syntax"}{...}
{viewerjumpto "Description" "go##description"}{...}
{viewerjumpto "Options" "go##options"}{...}
{viewerjumpto "Remarks" "go##remarks"}{...}
{viewerjumpto "Examples" "go##examples"}{...}
{viewerjumpto "Author" "go##author"}{...}
{...}
{title:Title}

{phang}
{cmd:go} {hline 2} Change to directories via nicknames
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 8 16 2}
   {cmd: go}
   {cmd: [to]}
   {it: nickname}
   [{cmd:,}
   {opt nopush}
   ]
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: add}
   {it:nickname}
   [{help using} {it:directory}]
   [{cmd:,}
   {opt nowrite}
   {opt noexist}
   ]
{p_end}

{p 8 16 2}
   {cmd: go}
   [{cmd: list}]
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: drop}
   {it: nickname}
   [{cmd:,}
   {opt nowrite}
   ]   
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: rename}
   {it: old_nickname} {it:new_nickname}
   [{cmd:,}
   {opt nowrite}
   ]   
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: copy}
   {it: old_nickname} {it:new_nickname}
   [{cmd:,}
   {opt nowrite}
   ]   
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: replace}
   {it:nickname}
   [{help using} {it:directory}]
   [{cmd:,}
   {opt nowrite}
   {opt noexist}
   ]
{p_end}

{p 8 16 2}
   {cmd: go}
   {cmd: write}
{p_end}


{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:General}
{synopt:{opt nowrite}}Suppress writing of the do-file needed to recreate the nickname lookups after quitting Stata.{p_end}
{synopt:{opt noexist}}Suppress checking that a directory exists before adding it to the lookup list. Useful if the directory is on a network drive or disk image which may or may not be mounted/available.{p_end}
{synopt:{opt nopush}}Do not push the current directory onto the directory stack. See {help pushd}.{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:go} is a utility for giving directorys/folders nicknames, so that jumping to them is simpler. This is particularly useful if you have projects in different locations and possibly deeply buried.
{p_end}

{pstd}
Using the various subcommands, you can add, drop, copy, and rename nicknames as well as replace the directory to which a nickname points.  
{p_end}

{pstd}
By default, all changes that you make to your list of nicknames is written to a do-file right away, so that you will not curse if you set up nicknames and then quit Stata.
If you would like to postpone writing the nickname file, you can use the {cmd:nowrite} option for all commands which alter the list of nicknames.
{p_end}

{marker options}{...}
{title:Options}

{phang}{opt nowrite} suppresses writing out the file used for storing nicknames and their definitions. This is mostly meant for debugging, and for the definition file itself.
{p_end}

{phang}{opt noexist} suppresses the check that a directory/folder exists.
This is mostly useful when defining nicknames for directories/folders which are on network or virtual drives which may or may not always be mounted.
{p_end}

{phang}{opt nopush} suppresses pushing the current working directory onto the directory stack and uses {help cd} instead.
This is only useful if you have {help pushd} installed.
If you do not have {cmd:pushd} installed, do not worry, {cmd:go} will use a simple {cmd:cd} instead. 
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Those who live in a fractured world may end up with their various projects in widely-scattered directories/folders.
Even with Stata's tab-completion of file names, typing endless {cmd:cd} commands can become both annoying and a waste of time.
The {cmd:go} command allows you to define short nicknames for commonly used directories/folders so that you can jump to different locations easily.
{p_end}

{pstd}
If a directory is not specified for {cmd:go add} or {cmd:go replace}, the current working directory gets used.
{p_end}

{pstd}
The nicknames act as actual directory names, so you can drop into a subfolder of a nicknamed folder via
{p_end}
{p 8 16 2}
   {cmd: go}
   {it: nickname}{cmd:/}{it:subfolder}
{p_end}

{pstd}
These nicknames get written to a do-file in your PERSONAL directory named {bf:golookup_}{it:your_os}{bf:.do} which can then be read back in the next time you start Stata.
({stata display "`c(os)'":Click here} to see in the Results window what Stata uses for {it:your_os}.)
This do-file may be edited by hand, if you like.
{p_end}

{pstd}
Embedded double-quotes are not allowed in the nicknames.
This is intentional, as the nicknames should be nice short names.
{p_end}


{marker examples}{...}
{title:Example(s)}{* Be sure to change Example(s) to either Example or Examples}

{phang}{cmd:. go add start}{break}
adds the nickname {bf:start} which points to whatever the current directory is---a useful way to have a starting directory
{p_end}

{phang}{cmd:. go add projects ~/Documents/Projects}{break}
adds the nickname {bf:projects} which points to {bf:~/Documents/Projects}
{p_end}

{phang}{cmd:. go projects}{break}
changes the working directory to {bf:~/Documents/Projects}
{p_end}

{phang}{cmd:. popd}{break}
goes back to whereever you were.
{p_end}

{phang}{cmd:. go projects/FunCity}{break}
changes the working directory to {bf:~/Documents/Projects/FunCity}
{p_end}

{phang}{cmd:. go}{break}
lists all available nicknames along with clickable links to actually go to the directories (the idea for the clickable links was copied from Scott Long's {net "describe workingdir, from(http://www.indiana.edu/~jslsoc/stata)":workingdir} package)
{p_end}

{phang}{cmd:. go list}{break}
does the same as {cmd:go list}
{p_end}

{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org":http://louabill.org}
{p_end}
